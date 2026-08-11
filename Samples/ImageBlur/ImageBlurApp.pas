unit ImageBlurApp;
{ Image-blur running in a compute shader writing to a storage texture. Also
  demonstrates using shader-shared memory and shader barriers.

  Ported from WebGPU sample: https://webgpu.github.io/webgpu-samples/?sample=imageBlur }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Fetch,
  Neslib.FastMath,
  SampleApp,
  ImageBlurShader;

type
  TImageBlurApp = class(TSampleApp)
  private type
    TCompute = record
    public
      Pip: TPipeline;
      SrcImage: TImage;
      SrcTexView: TView;
      StorageImage: array [0..1] of TImage;
      StorageSImgViews: array [0..1] of TView;
      StorageTexViews: array [0..1] of TView;
    end;
  private type
    TDisplay = record
    public
      Pip: TPipeline;
      PassAction: TPassAction;
    end;
  private type
    TUI = record
    public
      FilterSize: Integer;
      Iterations: Integer;
    end;
  private type
    TIO = record
    public
      Succeeded: Boolean;
      Failed: Boolean;
    end;
  private
    FSrcWidth: Integer;
    FSrcHeight: Integer;
    FSampler: TSampler;
    FCompute: TCompute;
    FDisplay: TDisplay;
    FUI: TUI;
    FIO: TIO;
    FFileBuffer: array [0..(256 * 1024) - 1] of Byte;
  private
    procedure FetchCallback(const AResponse: TFetchResponse);
    procedure Blur(const AFlip: Boolean; const ADstSImgView, ASrcTexView: TView);
  protected
    class function HasImGui: Boolean; override;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure DrawImGui; override;
  end;

implementation

uses
  Neslib.ImGui,
  Neslib.Stb.Image,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue;

{ TImageBlurApp }

procedure TImageBlurApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.DepthFormat := TAppPixelFormat.None;
  AConfig.WindowTitle := 'Image Blur';
end;

procedure TImageBlurApp.Init;
begin
  inherited;
  FDisplay.PassAction.Colors[0].Init(TLoadAction.Clear, 0, 0, 0, 1);
  FUI.FilterSize := 1;
  FUI.Iterations := 2;

  var FetchDesc := TFetchDesc.Create;
  FetchDesc.MaxRequests := 1;
  FetchDesc.NumChannels := 1;
  FetchDesc.NumLanes := 1;
  FetchDesc.Logger := FetchDesc.DefaultLogger;
  FetchDesc.BaseDirectory := 'Data';
  TFetch.Setup(FetchDesc);

  { Create a non-filtering sampler }
  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Nearest;
  SamplerDesc.MagFilter := TFilter.Nearest;
  SamplerDesc.WrapU := TWrap.ClampToEdge;
  SamplerDesc.WrapV := TWrap.ClampToEdge;
  SamplerDesc.TraceLabel := 'NearestSampler';
  FSampler := TSampler.Create(SamplerDesc);

  { Start loading source png file asynchronously. All Neslib.Sokol.Gfx image
    and attachment objects will be created when loading has finished }
  var Request := TFetchRequest.Create('baboon.png', FetchCallback,
    TFetchRange.Create(FFileBuffer));
  Request.Send;

  { Create compute shader and pipeline }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Compute := True;
  PipDesc.Shader := TShader.Create(ComputeShaderDesc);
  PipDesc.TraceLabel := 'ComputePipeline';
  FCompute.Pip := TPipeline.Create(PipDesc);

  { A shader and pipeline to display the result (we'll synthesize the fullscreen
    vertices in the vertex shader so we don't need any buffers or a pipeline
    vertex layout, and default render state is fine for rendering a 2D triangle }
  PipDesc.Init;
  PipDesc.Shader := TShader.Create(DisplayShaderDesc);
  PipDesc.TraceLabel := 'DisplayPipeline';
  FDisplay.Pip := TPipeline.Create(PipDesc);
end;

procedure TImageBlurApp.Frame;
begin
  TFetch.DoWork;

  { If loading hasn't finished yet or has failed, just draw a fallback ui }
  if (not FIO.Succeeded) then
  begin
    var Pass := TPass.Create;
    Pass.Action^ := FDisplay.PassAction;
    Pass.Swapchain.FromAppSwapchain;
    TGfx.BeginPass(Pass);
    DebugFrame;
    TGfx.EndPass;
    TGfx.Commit;
    Exit;
  end;

  { Ping-pong blur passes starting with the source image }
  var Pass := TPass.Create;
  Pass.Compute := True;
  Pass.TraceLabel := 'BlurPass';
  TGfx.BeginPass(Pass);
  TGfx.ApplyPipeline(FCompute.Pip);
  Blur(False, FCompute.StorageSImgViews[0], FCompute.SrcTexView);
  Blur(True,  FCompute.StorageSImgViews[1], FCompute.StorageTexViews[0]);
  for var I := 0 to FUI.Iterations - 1 do
  begin
    Blur(False, FCompute.StorageSImgViews[0], FCompute.StorageTexViews[1]);
    Blur(True,  FCompute.StorageSImgViews[1], FCompute.StorageTexViews[0]);
  end;
  TGfx.EndPass;

  { Swapchain render pass to display the result }
  Pass.Init;
  Pass.Action^ := FDisplay.PassAction;
  Pass.Swapchain.FromAppSwapchain;
  Pass.TraceLabel := 'DisplayPass';
  TGfx.BeginPass(Pass);
  TGfx.ApplyPipeline(FDisplay.Pip);

  var Bindings := TBindings.Create;
  Bindings.Views[VIEW_DISP_TEX] := FCompute.StorageTexViews[1];
  Bindings.Samplers[SMP_DISP_SMP] := FSampler;
  TGfx.ApplyBindings(Bindings);

  TGfx.Draw(0, 3);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TImageBlurApp.Cleanup;
begin
  inherited;
  TFetch.Shutdown;
end;

procedure TImageBlurApp.Blur(const AFlip: Boolean; const ADstSImgView,
  ASrcTexView: TView);
const
  BATCH    = 4;   // Must match shader
  TILE_DIM = 128; // Must match shader
begin
  var FilterSize := FUI.FilterSize or 1; // Must be odd
  var CSParams: TCSParams;
  CSParams.Flip := Ord(AFlip);
  CSParams.FilterDim := FilterSize;
  CSParams.BlockDim := TILE_DIM - (FilterSize - 1);

  var SrcWidth, SrcHeight: Single;
  if (AFlip) then
  begin
    SrcWidth := FSrcHeight;
    SrcHeight := FSrcWidth;
  end
  else
  begin
    SrcWidth := FSrcWidth;
    SrcHeight := FSrcHeight;
  end;

  var NumWorkgroupsX := Ceil(SrcWidth / CSParams.BlockDim);
  var NumWorkgroupsY := Ceil(SrcHeight / BATCH);

  var Bindings := TBindings.Create;
  Bindings.Views[VIEW_CS_INP_TEX] := ASrcTexView;
  Bindings.Views[VIEW_CS_OUTP_TEX] := ADstSImgView;
  Bindings.Samplers[SMP_CS_SMP] := FSampler;
  TGfx.ApplyBindings(Bindings);

  TGfx.ApplyUniforms(UB_CS_PARAMS, TRange.Create(CSParams));
  TGfx.Dispatch(NumWorkgroupsX, NumWorkgroupsY, 1);
end;

procedure TImageBlurApp.FetchCallback(const AResponse: TFetchResponse);
{ Called when texture file has finished loading, this creates a regular image
  object with the source pixels, and a storage attachment image object which
  will be written by the compute shader }
const
  DESIRED_CHANNELS = 4;
  IMG_LABELS: array [0..1] of UTF8String = ('StorageImage0', 'StorageImage1');
  TEX_VIEW_LABELS: array [0..1] of UTF8String = ('StorageImageTexView0', 'StorageImageTexView1');
  ATT_VIEW_LABELS: array [0..1] of UTF8String = ('StorageImageAttView0', 'StorageImageAttView1');
begin
  if (AResponse.Fetched) then
  begin
    var Image := TStbImage.Create;
    try
      if (Image.Load(AResponse.Data.Ptr, AResponse.Data.Size, DESIRED_CHANNELS)) then
      begin
        FSrcWidth := Image.Width;
        FSrcHeight := Image.Height;

        { The source image is a regular texture }
        var ImgDesc := TImageDesc.Create;
        ImgDesc.Width := FSrcWidth;
        ImgDesc.Height := FSrcHeight;
        ImgDesc.PixelFormat := TPixelFormat.Rgba8;
        ImgDesc.Data.MipLevels[0] := TRange.Create(Image.Data, FSrcWidth * FSrcHeight * 4);
        ImgDesc.TraceLabel := 'SourceImage';
        FCompute.SrcImage := TImage.Create(ImgDesc);

        var ViewDesc := TViewDesc.Create;
        ViewDesc.Texture.Image := FCompute.SrcImage;
        ViewDesc.TraceLabel := 'SourceImageTextureView';
        FCompute.SrcTexView := TView.Create(ViewDesc);

        { Create two storage textures for the 2-pass blur, and associated
          storage-image-views and one texture-views }
        for var I := 0 to 1 do
        begin
          ImgDesc.Init;
          ImgDesc.Usage.StorageImage := True;
          ImgDesc.Width := FSrcWidth;
          ImgDesc.Height := FSrcHeight;
          ImgDesc.PixelFormat := TPixelFormat.Rgba8;
          ImgDesc.TraceLabel := IMG_LABELS[I];
          FCompute.StorageImage[I] := TImage.Create(ImgDesc);

          ViewDesc.Init;
          ViewDesc.Texture.Image := FCompute.StorageImage[I];
          ViewDesc.TraceLabel := TEX_VIEW_LABELS[I];
          FCompute.StorageTexViews[I] := TView.Create(ViewDesc);

          ViewDesc.Init;
          ViewDesc.StorageImage.Image := FCompute.StorageImage[I];
          ViewDesc.TraceLabel := ATT_VIEW_LABELS[I];
          FCompute.StorageSImgViews[I] := TView.Create(ViewDesc);
        end;
      end;
    finally
      Image.Free;
    end;
    FIO.Succeeded := True;
  end
  else if (AResponse.Failed) then
    FIO.Failed := True;
end;

class function TImageBlurApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TImageBlurApp.DrawImGui;
begin
  ImGui.SetNextWindowBgAlpha(0.8);
  ImGui.SetNextWindowPos(Vector2(10, 30), TImGuiCond.Once);

  var Flags := TImGuiWindowFlags.NoDecoration + [TImGuiWindowFlag.AlwaysAutoResize,
    TImGuiWindowFlag.NoBringToFrontOnFocus, TImGuiWindowFlag.NoFocusOnAppearing];
  if (ImGui.Begin('Controls', nil, Flags)) then
  begin
    if (not FIO.Succeeded) and (not FIO.Failed) then
      ImGui.Text('Loading...')
    else if (FIO.Failed) then
      ImGui.Text('Failed to load source texture!')
    else
    begin
      ImGui.SliderInt('Filter Size', @FUI.FilterSize, 1, 33);
      ImGui.SliderInt('Iterations', @FUI.Iterations, 1, 10);
    end;
  end;
  ImGui.End;
end;

end.

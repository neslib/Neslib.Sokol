unit WriteStorageImageApp;
{ A simplest possible sample to write image data with a compute shader. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  WriteStorageImageShader;

const
  WIDTH  = 256;
  HEIGHT = 256;

type
  TWriteStorageImageApp = class(TSampleApp)
  private type
    TCompute = record
    public
      SImgView: TView;
      Pip: TPipeline;
    end;
  private type
    TDisplay = record
    public
      TexView: TView;
      Pip: TPipeline;
      Sampler: TSampler;
      PassAction: TPassAction;
    end;
  private
    FTime: Double;
    FImage: TImage;
    FCompute: TCompute;
    FDisplay: TDisplay;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue;

{ TWriteStorageImageApp }

procedure TWriteStorageImageApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 512;
  AConfig.Height := 512;
  AConfig.WindowTitle := 'Write Storage Image';
end;

procedure TWriteStorageImageApp.Init;
begin
  inherited;
  FDisplay.PassAction.Colors[0].LoadAction := TLoadAction.DontCare;

  { An image object with storage attachment usage }
  var ImageDesc := TImageDesc.Create;
  ImageDesc.Usage.StorageImage := True;
  ImageDesc.Width := WIDTH;
  ImageDesc.Height := HEIGHT;
  ImageDesc.PixelFormat := TPixelFormat.Rgba8;
  ImageDesc.TraceLabel := 'StorageImage';
  FImage := TImage.Create(ImageDesc);

  { A storage image view for compute shader access }
  var ViewDesc := TViewDesc.Create;
  ViewDesc.StorageImage.Image := FImage;
  ViewDesc.TraceLabel := 'StorageImageView';
  FCompute.SImgView := TView.Create(ViewDesc);

  { A texture view for binding the same image as texture }
  ViewDesc.Init;
  ViewDesc.Texture.Image := FImage;
  ViewDesc.TraceLabel := 'TextureView';
  FDisplay.TexView := TView.Create(ViewDesc);

  { A compute pipeline object with the compute shader }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Compute := True;
  PipDesc.Shader := TShader.Create(ComputeShaderDesc);
  PipDesc.TraceLabel := 'ComputePipeline';
  FCompute.Pip := TPipeline.Create(PipDesc);

  { A shader and pipeline for a textured 'fullscreen-triangle' with vertex
    positions synthesized in the vertex shader. The default pipeline state is
    sufficient for rendering a 2D triangle }
  PipDesc.Init;
  PipDesc.Shader := TShader.Create(DisplayShaderDesc);
  PipDesc.TraceLabel := 'DisplayPipeline';
  FDisplay.Pip := TPipeline.Create(PipDesc);

  { A sampler needed for sampling the storage image as texture }
  var SamplerDesc := TSamplerDesc.Create(TFilter.Linear);
  SamplerDesc.TraceLabel := 'DisplaySampler';
  FDisplay.Sampler := TSampler.Create(SamplerDesc);
end;

procedure TWriteStorageImageApp.Frame;
begin
  FTime := FTime + FrameDuration;

  { A value that fluctuates between 0 and 1 }
  var TimeOffset: Double := (Sin(FTime * 4) + 1) * 0.5;

  { Compute pass to update the storage image }
  var CSParams: TCSParams;
  CSParams.Offset := TimeOffset;

  var Pass := TPass.Create;
  Pass.Compute := True;
  Pass.TraceLabel := 'ComputePass';
  TGfx.BeginPass(Pass);
  TGfx.ApplyPipeline(FCompute.Pip);

  var Bind := TBindings.Create;
  Bind.Views[VIEW_CS_OUT_TEX] := FCompute.SImgView;
  TGfx.ApplyBindings(Bind);

  TGfx.ApplyUniforms(UB_CS_PARAMS, TRange.Create(CSParams));
  TGfx.Dispatch(WIDTH div 16, HEIGHT div 16, 1);
  TGfx.EndPass;

  { And a swapchain pass to render the result }
  Pass.Init;
  Pass.Action^ := FDisplay.PassAction;
  Pass.Swapchain.FromAppSwapchain;
  Pass.TraceLabel := 'RenderPass';
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FDisplay.Pip);

  Bind.Init;
  Bind.Views[VIEW_DISP_TEX] := FDisplay.TexView;
  Bind.Samplers[SMP_DISP_SMP] := FDisplay.Sampler;
  TGfx.ApplyBindings(Bind);
  TGfx.Draw(0, 3);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TWriteStorageImageApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

end.

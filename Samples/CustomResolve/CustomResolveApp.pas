unit CustomResolveApp;
{ Demonstrate custom MSAA resolve in a render pass which reads individual
  MSAA samples in the fragment shader. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  CustomResolveShader,
  SampleApp;

type
  TCustomResolveApp = class(TSampleApp)
  private type
    TMsaa = record
    public
      Img: TImage;
      TexView: TView;
      Pip: TPipeline;
      Pass: TPass;
    public
      procedure Init;
      procedure Draw;
    end;
  private type
    TResolve = record
    public
      Img: TImage;
      TexView: TView;
      Pip: TPipeline;
      Pass: TPass;
      Bind: TBindings;
      FSParams: TFSParams;
    public
      procedure Init(const AMsaaTexView: TView; const ASampler: TSampler);
      procedure Draw;
    end;
  private type
    TDisplay = record
    public
      Pip: TPipeline;
      Action: TPassAction;
      Bind: TBindings;
    public
      procedure Init(const AResolveTexView: TView; const ASampler: TSampler);
      procedure Draw;
    end;
  private
    FMsaa: TMsaa;
    FResolve: TResolve;
    FDisplay: TDisplay;
    FSampler: TSampler;
  private
    procedure DrawFallback;
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
  Neslib.FastMath,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue;

const
  WIDTH  = 160;
  HEIGHT = 120;
  DEFAULT_WEIGHTS: TFSParams = (
    Weight0: 0.25;
    Weight1: 0.25;
    Weight2: 0.25;
    Weight3: 0.25);

{ TCustomResolveApp }

procedure TCustomResolveApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.WindowTitle := 'Custom Resolve';
  AConfig.Width := 640;
  AConfig.Height := 480;
  AConfig.SampleCount := 1;
  AConfig.DepthFormat := TAppPixelFormat.None;
end;

procedure TCustomResolveApp.Init;
begin
  inherited;
  { Catch GLES3 }
  if (not (TFeature.MsaaTextureBindings in TGfx.Features)) then
    Exit;

  { Common objects }
  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Nearest;
  SamplerDesc.MagFilter := TFilter.Nearest;
  FSampler := TSampler.Create(SamplerDesc);

  { msaa-render-pass objects }
  FMsaa.Init;

  { resolve-render-pass objects }
  FResolve.Init(FMsaa.TexView, FSampler);

  { swapchain-render-pass objects }
  FDisplay.Init(FResolve.TexView, FSampler);
end;

procedure TCustomResolveApp.Frame;
begin
  if (not (TFeature.MsaaTextureBindings in TGfx.Features)) then
  begin
    DrawFallback;
    Exit;
  end;

  { Draw a triangle into an msaa render target }
  FMsaa.Draw;

  { Custom resolve pass (via a 'fullscreen triangle') }
  FResolve.Draw;

  { The final swapchain pass (also via a 'fullscreen triangle') }
  FDisplay.Draw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TCustomResolveApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

procedure TCustomResolveApp.DrawFallback;
begin
  var Pass := TPass.Create;
  Pass.Action.Colors[0].Init(TLoadAction.Clear, 0.5, 0, 0, 1);
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

class function TCustomResolveApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TCustomResolveApp.DrawImGui;
begin
  ImGui.SetNextWindowPos(Vector2(10, 20), TImGuiCond.Once);
  if (ImGui.Begin('#window', nil, TImGuiWindowFlags.NoDecoration +
    [TImGuiWindowFlag.AlwaysAutoResize, TImGuiWindowFlag.NoBackground])) then
  begin
    if (TFeature.MsaaTextureBindings in TGfx.Features) then
    begin
      ImGui.Text('Sample Weights:');
      ImGui.SliderFloat('0', @FResolve.FSParams.Weight0, 0, 1, '%.2f');
      ImGui.SliderFloat('1', @FResolve.FSParams.Weight1, 0, 1, '%.2f');
      ImGui.SliderFloat('2', @FResolve.FSParams.Weight2, 0, 1, '%.2f');
      ImGui.SliderFloat('3', @FResolve.FSParams.Weight3, 0, 1, '%.2f');
      ImGui.CheckboxFlags('Show complex pixels', @FResolve.FSParams.Coverage, 1);
      if (ImGui.Button('Reset')) then
        FResolve.FSParams := DEFAULT_WEIGHTS;
    end
    else
     ImGui.Text('MSAA TEXTURES NOT SUPPORTED ON GLES3');
  end;
  ImGui.End;
end;

{ TCustomResolveApp.TMsaa }

procedure TCustomResolveApp.TMsaa.Draw;
begin
  TGfx.BeginPass(Pass);
  TGfx.ApplyPipeline(Pip);
  TGfx.Draw(0, 3);
  TGfx.EndPass;
end;

procedure TCustomResolveApp.TMsaa.Init;
begin
  var ImgDesc := TImageDesc.Create;
  ImgDesc.Usage.ColorAttachment := True;
  ImgDesc.Width := WIDTH;
  ImgDesc.Height := HEIGHT;
  ImgDesc.PixelFormat := TPixelFormat.Rgba8;
  ImgDesc.SampleCount := 4;
  ImgDesc.TraceLabel := 'MsaaImage';
  Img := TImage.Create(ImgDesc);

  var ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := Img;
  ViewDesc.TraceLabel := 'MsaaTextureView';
  TexView := TView.Create(ViewDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(MsaaShaderDesc);
  PipDesc.SampleCount := 4;
  PipDesc.Depth.PixelFormat := TPixelFormat.None;
  PipDesc.Colors[0].PixelFormat := TPixelFormat.Rgba8;
  PipDesc.TraceLabel := 'MsaaPipeline';
  Pip := TPipeline.Create(PipDesc);

  Pass.Action.Colors[0].Init(TLoadAction.Clear, TStoreAction.Store, 0, 0, 0, 1);

  ViewDesc.Init;
  ViewDesc.ColorAttachment.Image := Img;
  ViewDesc.TraceLabel := 'MsaaAttachmentView';
  Pass.Attachments.Colors[0] := TView.Create(ViewDesc);
end;

{ TCustomResolveApp.TResolve }

procedure TCustomResolveApp.TResolve.Draw;
begin
  TGfx.BeginPass(Pass);
  TGfx.ApplyPipeline(Pip);
  TGfx.ApplyBindings(Bind);
  TGfx.ApplyUniforms(UB_FS_PARAMS, TRange.Create(FSParams));
  TGfx.Draw(0, 3);
  TGfx.EndPass;
end;

procedure TCustomResolveApp.TResolve.Init(const AMsaaTexView: TView;
  const ASampler: TSampler);
begin
  var ImgDesc := TImageDesc.Create;
  ImgDesc.Usage.ColorAttachment := True;
  ImgDesc.Width := WIDTH;
  ImgDesc.Height := HEIGHT;
  ImgDesc.PixelFormat := TPixelFormat.Rgba8;
  ImgDesc.SampleCount := 1;
  ImgDesc.TraceLabel := 'ResolveImage';
  Img := TImage.Create(ImgDesc);

  var ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := Img;
  ViewDesc.TraceLabel := 'ResolveTextureView';
  TexView := TView.Create(ViewDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(ResolveShaderDesc);
  PipDesc.SampleCount := 1;
  PipDesc.Depth.PixelFormat := TPixelFormat.None;
  PipDesc.Colors[0].PixelFormat := TPixelFormat.Rgba8;
  PipDesc.TraceLabel := 'ResolvePipeline';
  Pip := TPipeline.Create(PipDesc);

  Pass.Action.Colors[0].Init(TLoadAction.DontCare, TStoreAction.Store, 0, 0, 0, 0);

  ViewDesc.Init;
  ViewDesc.ColorAttachment.Image := Img;
  ViewDesc.TraceLabel := 'ResolveAttachmentView';
  Pass.Attachments.Colors[0] := TView.Create(ViewDesc);

  Bind.Views[VIEW_TEXMS] := AMsaaTexView;
  Bind.Samplers[SMP_SMP] := ASampler;

  FSParams := DEFAULT_WEIGHTS;
end;

{ TCustomResolveApp.TDisplay }

procedure TCustomResolveApp.TDisplay.Draw;
begin
  var Pass := TPass.Create;
  Pass.Action^ := Action;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);
  TGfx.ApplyPipeline(Pip);
  TGfx.ApplyBindings(Bind);
  TGfx.Draw(0, 3);

  { Don't call TGfx.EndPass here. It's called later. }
end;

procedure TCustomResolveApp.TDisplay.Init(const AResolveTexView: TView;
  const ASampler: TSampler);
begin
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(DisplayShaderDesc);
  PipDesc.TraceLabel := 'DisplayPipeline';
  Pip := TPipeline.Create(PipDesc);

  Action.Colors[0].LoadAction := TLoadAction.DontCare;

  Bind.Views[VIEW_TEX] := AResolveTexView;
  Bind.Samplers[SMP_SMP] := ASampler;
end;

end.

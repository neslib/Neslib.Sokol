unit OffScreenApp;
{ Render to a offscreen rendertarget texture without multisampling, and use this
  texture for rendering to the display (with multisampling).}

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Shape,
  Neslib.FastMath,
  SampleApp,
  OffScreenShader;

type
  TOffScreenApp = class(TSampleApp)
  private const
    OFFSCREEN_SAMPLE_COUNT = 1;
    OFFSCREEN_PIXEL_FORMAT = TPixelFormat.Rgba8;
    DISPLAY_SAMPLE_COUNT   = 4;
  private type
    TOffScreen = record
    public
      Pass: TPass;
      Shader: TShader;
      Pip: TPipeline;
      Bind: TBindings;
    end;
  private type
    TDisplay = record
    public
      PassAction: TPassAction;
      Shader: TShader;
      Pip: TPipeline;
      Bind: TBindings;
    end;
  private
    FOffScreen: TOffScreen;
    FDisplay: TDisplay;
    FDonut: TShapeElementRange;
    FSphere: TShapeElementRange;
    FColorImage: TImage;
    FDepthImage: TImage;
    FRX: Single;
    FRY: Single;
  private
    class function ComputeMvp(const ARX, ARY, AAspect,
      AEyeDist: Single): TMatrix4; static;
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

{ TOffScreenApp }

procedure TOffScreenApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := DISPLAY_SAMPLE_COUNT;
  AConfig.WindowTitle := 'Offscreen Rendering';
end;

procedure TOffScreenApp.Init;
var
  Vertices: array [0..3999] of TShapeVertex;
  Indices: array [0..23999] of UInt16;
begin
  inherited;
  { Display pass action: clear to blue-ish }
  FDisplay.PassAction.Colors[0].Init(TLoadAction.Clear, 0.25, 0.45, 0.65, 1.0);
  { Setup a render pass struct with one color and one depth render attachment
    image.
    NOTE: we need to explicitly set the sample count in the attachment image
    objects, because the offscreen pass uses a different sample count than the
    display render pass (the display render pass is multi-sampled, the offscreen
    pass is not) }
  var ImgDesc := TImageDesc.Create;
  ImgDesc.Usage.ColorAttachment := True;
  ImgDesc.Width := 256;
  ImgDesc.Height := 256;
  ImgDesc.PixelFormat := OFFSCREEN_PIXEL_FORMAT;
  ImgDesc.SampleCount := OFFSCREEN_SAMPLE_COUNT;
  ImgDesc.TraceLabel := 'ColorImage';
  FColorImage := TImage.Create(ImgDesc);

  ImgDesc.PixelFormat := TPixelFormat.Depth;
  ImgDesc.Usage.ColorAttachment := False;
  ImgDesc.Usage.DepthStencilAttachment := True;
  ImgDesc.TraceLabel := 'DepthImage';
  FDepthImage := TImage.Create(ImgDesc);

  { Setup a pass struct with attachment views and pass-actions }
  FOffScreen.Pass := TPass.Create;

  var ViewDesc := TViewDesc.Create;
  ViewDesc.ColorAttachment.Image := FColorImage;
  ViewDesc.TraceLabel := 'ColorAttachment';
  FOffScreen.Pass.Attachments.Colors[0] := TView.Create(ViewDesc);

  ViewDesc := TViewDesc.Create;
  ViewDesc.DepthStencilAttachment.Image := FDepthImage;
  ViewDesc.TraceLabel := 'DepthAttachment';
  FOffScreen.Pass.Attachments.DepthStencil := TView.Create(ViewDesc);

  FOffScreen.Pass.Action.Colors[0]^ := TColorAttachmentAction.Create(
    TLoadAction.Clear, 0.25, 0.25, 0.25, 1);
  FOffScreen.Pass.TraceLabel := 'OffscreenPass';

  { A donut shape which is rendered into the offscreen render target, and a
    sphere shape which is rendered into the default framebuffer }
  var Buf := TShapeBuffer.Create(TRange.Create(Vertices), TRange.Create(Indices));
  var ShapeTorus := TShapeTorus.Create;
  ShapeTorus.Radius := 0.5;
  ShapeTorus.RingRadius := 0.3;
  ShapeTorus.Sides := 20;
  ShapeTorus.Rings := 36;
  Buf := Buf.Build(ShapeTorus);
  Assert(Buf.Valid);
  FDonut := Buf.ElementRange;

  Buf := Buf.Build(TShapeSphere.Create(0.5, 72, 40));
  Assert(Buf.Valid);
  FSphere := Buf.ElementRange;

  var VBufDesc := Buf.VertexBufferDesc;
  var IBufDesc := Buf.IndexBufferDesc;
  VBufDesc.TraceLabel := 'ShapeVBuf';
  IBufDesc.TraceLabel := 'ShapeIBuf';
  var VBuf := TBuffer.Create(VBufDesc);
  var IBuf := TBuffer.Create(IBufDesc);

  { Pipeline-state-object for offscreen-rendered donut.
    NOTE: we need to explicitly set the SampleCount here because the offscreen
    pass uses a different sample count than the default pass (the display pass
    is multi-sampled, but the offscreen pass isn't) }
  FOffScreen.Shader := TShader.Create(OffScreenShaderDesc);
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Buffers[0] := Buf.VertexBufferLayoutState;
  PipDesc.Layout.Attrs[ATTR_OFFSCREEN_POSITION] := Buf.PositionVertexAttrState;
  PipDesc.Layout.Attrs[ATTR_OFFSCREEN_NORMAL] := Buf.NormalVertexAttrState;
  PipDesc.Shader := FOffScreen.Shader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.SampleCount := OFFSCREEN_SAMPLE_COUNT;
  PipDesc.Depth.PixelFormat := TPixelFormat.Depth;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Colors[0].PixelFormat := OFFSCREEN_PIXEL_FORMAT;
  PipDesc.TraceLabel := 'OffscreenPipeline';
  FOffScreen.Pip := TPipeline.Create(PipDesc);

  { And another pipeline-state-object for the default pass }
  FDisplay.Shader := TShader.Create(DefaultShaderDesc);
  PipDesc.Init;
  PipDesc.Layout.Buffers[0] := Buf.VertexBufferLayoutState;
  PipDesc.Layout.Attrs[ATTR_DEFAULT_POSITION] := Buf.PositionVertexAttrState;
  PipDesc.Layout.Attrs[ATTR_DEFAULT_NORMAL] := Buf.NormalVertexAttrState;
  PipDesc.Layout.Attrs[ATTR_DEFAULT_TEXCOORD0] := Buf.TexCoordVertexAttrState;
  PipDesc.Shader := FDisplay.Shader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.TraceLabel := 'DefaultPipeline';
  FDisplay.Pip := TPipeline.Create(PipDesc);

  { A sampler object for sampling the render target texture }
  var SmpDesc := TSamplerDesc.Create;
  SmpDesc.MinFilter := TFilter.Linear;
  SmpDesc.MagFilter := TFilter.Linear;
  SmpDesc.WrapU := TWrap.Repeating;
  SmpDesc.WrapV := TWrap.Repeating;
  SmpDesc.TraceLabel := 'Sampler';
  FDisplay.Bind.Samplers[SMP_SMP] := TSampler.Create(SmpDesc);

  { The resource bindings for rendering a non-textured shape into offscreen
    render target }
  FOffScreen.Bind.VertexBuffers[0] := VBuf;
  FOffScreen.Bind.IndexBuffer := IBuf;

  { Resource bindings to render a textured shape, using the offscreen render
    target as texture }
  FDisplay.Bind.VertexBuffers[0] := VBuf;
  FDisplay.Bind.IndexBuffer := IBuf;

  ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := FColorImage;
  ViewDesc.TraceLabel := 'TextureView';
  FDisplay.Bind.Views[VIEW_TEX] := TView.Create(ViewDesc);
end;

procedure TOffScreenApp.Frame;
begin
  var T: Single := FrameDuration * 60;
  FRX := FRX + (1.0 * T);
  FRY := FRY + (2.0 * T);

  { The offscreen pass, rendering an rotating, untextured donut into a render
    target image }
  var VSParams: TVSParams;
  VSParams.Mvp := ComputeMvp(FRX, FRY, 1, 2.5);

  TGfx.BeginPass(FOffScreen.Pass);
  TGfx.ApplyPipeline(FOffScreen.Pip);
  TGfx.ApplyBindings(FOffScreen.Bind);
  TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(FDonut.BaseElement, FDonut.NumElements);
  TGfx.EndPass;

  { And the display-pass, rendering a rotating textured sphere which uses the
    previously rendered offscreen render-target as texture }
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  VSParams.Mvp := ComputeMvp(-FRX * 0.25, FRY * 0.25, H / W, 2);

  var Pass := TPass.Create;
  Pass.Action^ := FDisplay.PassAction;
  Pass.Swapchain.FromAppSwapchain;
  Pass.TraceLabel := 'SwapchainPass';
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FDisplay.Pip);
  TGfx.ApplyBindings(FDisplay.Bind);
  TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(FSphere.BaseElement, FSphere.NumElements);
  DebugFrame;
  TGfx.EndPass;

  TGfx.Commit;
end;

procedure TOffScreenApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

class function TOffScreenApp.ComputeMvp(const ARX, ARY, AAspect,
  AEyeDist: Single): TMatrix4;
var
  Proj, View, Rxm, Rym: TMatrix4;
begin
  Proj.InitPerspectiveFovRH(Radians(45), AAspect, 0.01, 10.0, True);
  View.InitLookAtRH(Vector3(0, 0, AEyeDist), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  Rxm.InitRotationX(Radians(ARX));
  Rym.InitRotationY(Radians(ARY));
  var Model := Rym * Rxm;
  Result := ViewProj * Model;
end;

end.

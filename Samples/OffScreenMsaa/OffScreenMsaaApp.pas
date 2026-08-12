unit OffScreenMsaaApp;
{ Render to a multisampled offscreen rendertarget texture, resolve into
  a separate non-multisampled texture, and use this as sampled texture
  in the display render pass.}

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Shape,
  Neslib.FastMath,
  SampleApp,
  OffScreenMsaaShader;

type
  TOffScreenMsaaApp = class(TSampleApp)
  private const
    OFFSCREEN_WIDTH        = 256;
    OFFSCREEN_HEIGHT       = 256;
    OFFSCREEN_COLOR_FORMAT = TPixelFormat.Rgba8;
    OFFSCREEN_DEPTH_FORMAT = TPixelFormat.Depth;
    OFFSCREEN_SAMPLE_COUNT = 4;
    DISPLAY_SAMPLE_COUNT   = 4;
  private type
    TOffScreen = record
    public
      PassAction: TPassAction;
      Atts: TAttachments;
      Pip: TPipeline;
      Bind: TBindings;
    end;
  private type
    TDisplay = record
    public
      PassAction: TPassAction;
      Pip: TPipeline;
      Bind: TBindings;
    end;
  private
    FOffScreen: TOffScreen;
    FDisplay: TDisplay;
    FSphere: TShapeElementRange;
    FDonut: TShapeElementRange;
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

{ TOffScreenMsaaApp }

procedure TOffScreenMsaaApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := DISPLAY_SAMPLE_COUNT;
  AConfig.WindowTitle := 'Offscreen MSAA Rendering';
end;

procedure TOffScreenMsaaApp.Init;
var
  Vertices: array [0..7999] of TShapeVertex;
  Indices: array [0..47999] of UInt16;
begin
  inherited;
  { Default pass action: clear to green-ish. }
  FDisplay.PassAction.Colors[0].Init(TLoadAction.Clear, 0.25, 0.65, 0.45, 1.0);

  { Offscreen pass action: clear to grey.
    NOTE: we don't need to store the MSAA render target content, because it will
    be resolved into a non-MSAA texture at the end of the offscreen pass }
  FOffScreen.PassAction.Colors[0].Init(TLoadAction.Clear, TStoreAction.DontCare,
    0.25, 0.25, 0.25, 1.0);

  { Create a MSAA render target image. This will be rendered to in the offscreen
    render pass }
  var ImgDesc := TImageDesc.Create;
  ImgDesc.Usage.ColorAttachment := True;
  ImgDesc.Width := OFFSCREEN_WIDTH;
  ImgDesc.Height := OFFSCREEN_HEIGHT;
  ImgDesc.PixelFormat := OFFSCREEN_COLOR_FORMAT;
  ImgDesc.SampleCount := OFFSCREEN_SAMPLE_COUNT;
  ImgDesc.TraceLabel := 'MsaaImage';
  var MsaaImage := TImage.Create(ImgDesc);

  { Create a depth-buffer image for the offscreen pass. This needs the same
    dimensions and sample count as the render target image }
  ImgDesc.Init;
  ImgDesc.Usage.DepthStencilAttachment := True;
  ImgDesc.Width := OFFSCREEN_WIDTH;
  ImgDesc.Height := OFFSCREEN_HEIGHT;
  ImgDesc.PixelFormat := OFFSCREEN_DEPTH_FORMAT;
  ImgDesc.SampleCount := OFFSCREEN_SAMPLE_COUNT;
  ImgDesc.TraceLabel := 'DepthImage';
  var DepthImage := TImage.Create(ImgDesc);

  { Create a matching resolve-image where the MSAA-rendered content will be
    resolved to at the end of the offscreen pass, and which will be
    texture-sampled in the display pass }
  ImgDesc.Init;
  ImgDesc.Usage.ResolveAttachment := True;
  ImgDesc.Width := OFFSCREEN_WIDTH;
  ImgDesc.Height := OFFSCREEN_HEIGHT;
  ImgDesc.PixelFormat := OFFSCREEN_COLOR_FORMAT;
  ImgDesc.SampleCount := 1;
  ImgDesc.TraceLabel := 'ResolveImage';
  var ResolveImage := TImage.Create(ImgDesc);

  { Populate attachments record with view objects }
  var ViewDesc := TViewDesc.Create;
  ViewDesc.ColorAttachment.Image := MsaaImage;
  ViewDesc.TraceLabel := 'ColorAttachment';
  FOffScreen.Atts.Colors[0] := TView.Create(ViewDesc);

  ViewDesc.Init;
  ViewDesc.ResolveAttachment.Image := ResolveImage;
  ViewDesc.TraceLabel := 'ResolveAttachment';
  FOffScreen.Atts.Resolves[0] := TView.Create(ViewDesc);

  ViewDesc.Init;
  ViewDesc.DepthStencilAttachment.Image := DepthImage;
  ViewDesc.TraceLabel := 'DepthAttachment';
  FOffScreen.Atts.DepthStencil := TView.Create(ViewDesc);

  { Create a couple of meshes }
  var Buf := TShapeBuffer.Create(TRange.Create(Vertices), TRange.Create(Indices));
  var ShapeTorus := TShapeTorus.Create;
  ShapeTorus.Radius := 0.5;
  ShapeTorus.RingRadius := 0.25;
  ShapeTorus.Sides := 40;
  ShapeTorus.Rings := 72;
  Buf := Buf.Build(ShapeTorus);
  FSphere := Buf.ElementRange;

  ShapeTorus := TShapeTorus.Create;
  ShapeTorus.Radius := 0.3;
  ShapeTorus.RingRadius := 0.2;
  ShapeTorus.Sides := 40;
  ShapeTorus.Rings := 72;
  Buf := Buf.Build(ShapeTorus);
  FDonut := Buf.ElementRange;

  var VBufDesc := Buf.VertexBufferDesc;
  var IBufDesc := Buf.IndexBufferDesc;
  VBufDesc.TraceLabel := 'ShapeVBuf';
  IBufDesc.TraceLabel := 'ShapeIBuf';
  var VBuf := TBuffer.Create(VBufDesc);
  var IBuf := TBuffer.Create(IBufDesc);

  { A pipeline object for the offscreen-rendered box }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Buffers[0] := Buf.VertexBufferLayoutState;
  PipDesc.Layout.Attrs[ATTR_OFFSCREEN_POSITION] := Buf.PositionVertexAttrState;
  PipDesc.Layout.Attrs[ATTR_OFFSCREEN_NORMAL] := Buf.NormalVertexAttrState;
  PipDesc.Shader := TShader.Create(OffScreenShaderDesc);
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.SampleCount := OFFSCREEN_SAMPLE_COUNT;
  PipDesc.Depth.PixelFormat := OFFSCREEN_DEPTH_FORMAT;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Colors[0].PixelFormat := OFFSCREEN_COLOR_FORMAT;
  PipDesc.TraceLabel := 'OffscreenPipeline';
  FOffScreen.Pip := TPipeline.Create(PipDesc);

  { Another pipeline object for the display pass }
  PipDesc.Init;
  PipDesc.Layout.Buffers[0] := Buf.VertexBufferLayoutState;
  PipDesc.Layout.Attrs[ATTR_DISPLAY_POSITION] := Buf.PositionVertexAttrState;
  PipDesc.Layout.Attrs[ATTR_DISPLAY_NORMAL] := Buf.NormalVertexAttrState;
  PipDesc.Layout.Attrs[ATTR_DISPLAY_TEXCOORD0] := Buf.TexCoordVertexAttrState;
  PipDesc.Shader := TShader.Create(DisplayShaderDesc);
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.TraceLabel := 'DisplayPipeline';
  FDisplay.Pip := TPipeline.Create(PipDesc);

  { A sampler object for sampling the render target texture }
  var SmpDesc := TSamplerDesc.Create;
  SmpDesc.MinFilter := TFilter.Linear;
  SmpDesc.MagFilter := TFilter.Linear;
  SmpDesc.WrapU := TWrap.Repeating;
  SmpDesc.WrapV := TWrap.Repeating;
  SmpDesc.TraceLabel := 'Sampler';
  var Sampler := TSampler.Create(SmpDesc);

  { Resource bindings for rendering a non-textured shape in the offscreen pass }
  FOffScreen.Bind.VertexBuffers[0] := VBuf;
  FOffScreen.Bind.IndexBuffer := IBuf;

  { The resource bindings for rendering a texture shape in the display pass,
    using the msaa-resolved image as texture }
  FDisplay.Bind.VertexBuffers[0] := VBuf;
  FDisplay.Bind.IndexBuffer := IBuf;

  ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := ResolveImage;
  ViewDesc.TraceLabel := 'TextureView';
  FDisplay.Bind.Views[VIEW_TEX] := TView.Create(ViewDesc);
  FDisplay.Bind.Samplers[SMP_SMP] := Sampler;
end;

procedure TOffScreenMsaaApp.Frame;
begin
  var T: Single := FrameDuration * 60;
  FRX := FRX + (1.0 * T);
  FRY := FRY + (2.0 * T);

  { The offscreen pass, rendering an rotating, untextured sphere into an msaa
    render target image, which is then resolved into a regular non-msaa texture
    at the end of the pass }
  var VSParams: TVSParams;
  VSParams.Mvp := ComputeMvp(FRX, FRY, 1, 2.5);

  var Pass := TPass.Create;
  Pass.Action^ := FOffScreen.PassAction;
  Pass.Attachments^ := FOffScreen.Atts;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FOffScreen.Pip);
  TGfx.ApplyBindings(FOffScreen.Bind);
  TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(FSphere.BaseElement, FSphere.NumElements);
  TGfx.EndPass;

  { And the display-pass, rendering a rotating textured donut which uses the
    previously msaa-resolved texture }
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  VSParams.Mvp := ComputeMvp(-FRX * 0.25, FRY * 0.25, W / H, 1.5);

  Pass.Init;
  Pass.Action^ := FDisplay.PassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FDisplay.Pip);
  TGfx.ApplyBindings(FDisplay.Bind);
  TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(FDonut.BaseElement, FDonut.NumElements);
  DebugFrame;
  TGfx.EndPass;

  TGfx.Commit;
end;

procedure TOffScreenMsaaApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

class function TOffScreenMsaaApp.ComputeMvp(const ARX, ARY, AAspect,
  AEyeDist: Single): TMatrix4;
var
  Proj, View, Rxm, Rym: TMatrix4;
begin
  Proj.InitPerspectiveFovRH(Radians(45), AAspect, 0.01, 10.0);
  View.InitLookAtRH(Vector3(0, 0, AEyeDist), TVector3.Zero, TVector3.UnitY);
  var ViewProj := Proj * View;

  Rxm.InitRotationX(Radians(ARX));
  Rym.InitRotationY(Radians(ARY));
  var Model := Rym * Rxm;
  Result := ViewProj * Model;
end;

end.

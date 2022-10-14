unit OffScreenApp;
{ Render to an offscreen rendertarget texture, and use this texture for
  rendering to the display. }

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
    SAMPLE_COUNT = 4;
  private type
    TOffScreen = record
    public
      PassAction: TPassAction;
      Pass: TPass;
      Shader: TShader;
      Pip: TPipeline;
      Bind: TBindings;
    end;
  private type
    TDefault = record
    public
      PassAction: TPassAction;
      Shader: TShader;
      Pip: TPipeline;
      Bind: TBindings;
    end;
  private
    FOffScreen: TOffScreen;
    FDefault: TDefault;
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
  Neslib.Sokol.Api;

{ TOffScreenApp }

procedure TOffScreenApp.Cleanup;
begin
  FOffScreen.Bind.IndexBuffer.Free;
  FOffScreen.Bind.VertexBuffers[0].Free;
  FDefault.Pip.Free;
  FDefault.Shader.Free;
  FOffScreen.Pip.Free;
  FOffScreen.Shader.Free;
  FOffScreen.Pass.Free;
  FDepthImage.Free;
  FColorImage.Free;
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

procedure TOffScreenApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Offscreen Rendering';
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

  TGfx.BeginPass(FOffScreen.Pass, FOffScreen.PassAction);
  TGfx.ApplyPipeline(FOffScreen.Pip);
  TGfx.ApplyBindings(FOffScreen.Bind);
  TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(FDonut.BaseElement, FDonut.NumElements);
  TGfx.EndPass;

  { And the display-pass, rendering a rotating textured sphere which uses the
    previously rendered offscreen render-target as texture }
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  VSParams.Mvp := ComputeMvp(-FRX * 0.25, FRY * 0.25, H / W, 2);

  TGfx.BeginDefaultPass(FDefault.PassAction, FramebufferWidth, FramebufferHeight);
  TGfx.ApplyPipeline(FDefault.Pip);
  TGfx.ApplyBindings(FDefault.Bind);
  TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(FSphere.BaseElement, FSphere.NumElements);
  DebugFrame;
  TGfx.EndPass;

  TGfx.Commit;
end;

procedure TOffScreenApp.Init;
var
  Vertices: array [0..3999] of TShapeVertex;
  Indices: array [0..23999] of UInt16;
begin
  inherited;
  { Default pass action: clear to blue-ish }
  FDefault.PassAction.Colors[0].Init(TAction.Clear, 0.25, 0.45, 0.65, 1.0);

  { Offscreen pass action }
  FOffScreen.PassAction.Colors[0].Init(TAction.Clear, 0.25, 0.25, 0.25, 1.0);

  { A render pass with one color- and one depth-attachment image }
  var ImgDesc := TImageDesc.Create;
  ImgDesc.RenderTarget := True;
  ImgDesc.Width := 256;
  ImgDesc.Height := 256;
  ImgDesc.PixelFormat := TPixelFormat.Rgba8;
  ImgDesc.MinFilter := TFilter.Linear;
  ImgDesc.MagFilter := TFilter.Linear;
  ImgDesc.WrapU := TWrap.Repeating;
  ImgDesc.WrapV := TWrap.Repeating;
  ImgDesc.SampleCount := SAMPLE_COUNT;
  ImgDesc.TraceLabel := 'ColorImage';
  FColorImage := TImage.Create(ImgDesc);

  ImgDesc.PixelFormat := TPixelFormat.Depth;
  ImgDesc.TraceLabel := 'DepthImage';
  FDepthImage := TImage.Create(ImgDesc);

  var PassDesc := TPassDesc.Create;
  PassDesc.ColorAttachments[0].Image := FColorImage;
  PassDesc.DepthStencilAttachment.Image := FDepthImage;
  PassDesc.TraceLabel := 'OffscreenPass';
  FOffScreen.Pass := TPass.Create(PassDesc);

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

  var VBuf := TBuffer.Create(Buf.VertexBufferDesc);
  var IBuf := TBuffer.Create(Buf.IndexBufferDesc);

  { Pipeline-state-object for offscreen-rendered donut, don't need texture coord
    here }
  FOffScreen.Shader := TShader.Create(OffScreenShaderDesc);
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Buffers[0] := Buf.BufferLayoutDesc;
  PipDesc.Layout.Attrs[ATTR_VS_OFFSCREEN_POSITION] := Buf.PositionAttrDesc;
  PipDesc.Layout.Attrs[ATTR_VS_OFFSCREEN_NORMAL] := Buf.NormalAttrDesc;
  PipDesc.Shader := FOffScreen.Shader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.SampleCount := SAMPLE_COUNT;
  PipDesc.Depth.PixelFormat := TPixelFormat.Depth;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Colors[0].PixelFormat := TPixelFormat.Rgba8;
  PipDesc.TraceLabel := 'OffscreenPipeline';
  FOffScreen.Pip := TPipeline.Create(PipDesc);

  { And another pipeline-state-object for the default pass }
  FDefault.Shader := TShader.Create(DefaultShaderDesc);
  PipDesc.Init;
  PipDesc.Layout.Buffers[0] := Buf.BufferLayoutDesc;
  PipDesc.Layout.Attrs[ATTR_VS_DEFAULT_POSITION] := Buf.PositionAttrDesc;
  PipDesc.Layout.Attrs[ATTR_VS_DEFAULT_NORMAL] := Buf.NormalAttrDesc;
  PipDesc.Layout.Attrs[ATTR_VS_DEFAULT_TEXCOORD0] := Buf.TexCoordAttrDesc;
  PipDesc.Shader := FDefault.Shader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.TraceLabel := 'DefaultPipeline';
  FDefault.Pip := TPipeline.Create(PipDesc);

  { The resource bindings for rendering a non-textured shape into offscreen
    render target }
  FOffScreen.Bind.VertexBuffers[0] := VBuf;
  FOffScreen.Bind.IndexBuffer := IBuf;

  { Resource bindings to render a textured shape, using the offscreen render
    target as texture }
  FDefault.Bind.VertexBuffers[0] := VBuf;
  FDefault.Bind.IndexBuffer := IBuf;
  FDefault.Bind.FragmentShaderImages[0] := FColorImage;
end;

end.

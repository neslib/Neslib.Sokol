unit MrtPixelFormatsApp;
{ Test/demonstrate multiple-render-target rendering with different pixel
  formats. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Shape,
  Neslib.FastMath,
  SampleApp,
  MrtPixelFormatsShader;

const
  { Render target pixel formats }
  DEPTH_PIXEL_FORMAT  = TPixelFormat.R32F;
  NORMAL_PIXEL_FORMAT = TPixelFormat.Rgba16F;
  COLOR_PIXEL_FORMAT  = TPixelFormat.Rgba8;

const
  { Size of offscreen render targets }
  OFFSCREEN_WIDTH  = 512;
  OFFSCREEN_HEIGHT = 512;

type
  TImageAndViews = record
  public
    Image: TImage;
    AttView: TView;
    TexView: TView;
  public
    procedure Init(const AImgDesc: TImageDesc; const AAttLabel,
      ATexLabel: UTF8String);
  end;

type
  TOffscreen = record
  public
    Depth: TImageAndViews;
    Normal: TImageAndViews;
    Color: TImageAndViews;
    Pass: TPass;
    Pip: TPipeline;
    Bind: TBindings;
    ViewProj: TMatrix4;
    Donut: TShapeElementRange;
  public
    procedure Init;
  end;

type
  TDisplay = record
  public
    PassAction: TPassAction;
    VBuf: TBuffer;
    Sampler: TSampler;
    Pip: TPipeline;
  public
    procedure Init;
  end;

type
  TMrtPixelFormatsApp = class(TSampleApp)
  private
    FOffscreen: TOffscreen;
    FDisplay: TDisplay;
    FFeaturesOK: Boolean;
    FRX: Single;
    FRY: Single;
  private
    procedure DrawFallback;
    function ComputeOffscreenParams: TOffscreenParams;
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

const
  { Cube vertex buffer }
  VERTICES: array [0..167] of Single = (
    -1.0, -1.0, -1.0,   1.0, 0.0, 0.0, 1.0,
     1.0, -1.0, -1.0,   1.0, 0.0, 0.0, 1.0,
     1.0,  1.0, -1.0,   1.0, 0.0, 0.0, 1.0,
    -1.0,  1.0, -1.0,   1.0, 0.0, 0.0, 1.0,

    -1.0, -1.0,  1.0,   0.0, 1.0, 0.0, 1.0,
     1.0, -1.0,  1.0,   0.0, 1.0, 0.0, 1.0,
     1.0,  1.0,  1.0,   0.0, 1.0, 0.0, 1.0,
    -1.0,  1.0,  1.0,   0.0, 1.0, 0.0, 1.0,

    -1.0, -1.0, -1.0,   0.0, 0.0, 1.0, 1.0,
    -1.0,  1.0, -1.0,   0.0, 0.0, 1.0, 1.0,
    -1.0,  1.0,  1.0,   0.0, 0.0, 1.0, 1.0,
    -1.0, -1.0,  1.0,   0.0, 0.0, 1.0, 1.0,

    1.0, -1.0, -1.0,    1.0, 0.5, 0.0, 1.0,
    1.0,  1.0, -1.0,    1.0, 0.5, 0.0, 1.0,
    1.0,  1.0,  1.0,    1.0, 0.5, 0.0, 1.0,
    1.0, -1.0,  1.0,    1.0, 0.5, 0.0, 1.0,

    -1.0, -1.0, -1.0,   0.0, 0.5, 1.0, 1.0,
    -1.0, -1.0,  1.0,   0.0, 0.5, 1.0, 1.0,
     1.0, -1.0,  1.0,   0.0, 0.5, 1.0, 1.0,
     1.0, -1.0, -1.0,   0.0, 0.5, 1.0, 1.0,

    -1.0,  1.0, -1.0,   1.0, 0.0, 0.5, 1.0,
    -1.0,  1.0,  1.0,   1.0, 0.0, 0.5, 1.0,
     1.0,  1.0,  1.0,   1.0, 0.0, 0.5, 1.0,
     1.0,  1.0, -1.0,   1.0, 0.0, 0.5, 1.0);

const
  { Index buffer for the cube }
  INDICES: array [0..35] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20);

{ TMrtPixelFormatsApp }

procedure TMrtPixelFormatsApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.WindowTitle := 'MRT Pixelformats';
end;

procedure TMrtPixelFormatsApp.Init;
begin
  inherited;
  { Check if requires features are supported }
  FFeaturesOK := DEPTH_PIXEL_FORMAT.Render
             and NORMAL_PIXEL_FORMAT.Render
             and COLOR_PIXEL_FORMAT.Render;
  if (not FFeaturesOK) then
    Exit;

  { Setup resources for offscreen rendering }
  FOffscreen.Init;

  { Setup resources for rendering to the display }
  FDisplay.Init;
end;

procedure TMrtPixelFormatsApp.Frame;
begin
  if (not FFeaturesOK) then
  begin
    DrawFallback;
    Exit;
  end;

  var T: Single := FrameDuration * 60;
  FRX := FRX + (1 * T);
  FRY := FRY + (2 * T);

  { Render donut shape into MRT offscreen render targets }
  var OffscreenParams := ComputeOffscreenParams;
  TGfx.BeginPass(FOffscreen.Pass);
  TGfx.ApplyPipeline(FOffscreen.Pip);
  TGfx.ApplyBindings(FOffscreen.Bind);
  TGfx.ApplyUniforms(UB_OFFSCREEN_PARAMS, TRange.Create(OffscreenParams));
  TGfx.Draw(FOffscreen.Donut.BaseElement, FOffscreen.Donut.NumElements);
  TGfx.EndPass;

  { Render offscreen render targets to display }
  var DispWidth := FramebufferWidth;
  var DispHeight := FramebufferHeight;
  var QuadWidth := DispWidth div 4;
  var QuadHeight := QuadWidth;
  var QuadGap := (DispWidth - (QuadWidth * 3)) div 4;
  var X0 := QuadGap;
  var Y0 := (DispHeight - QuadHeight) div 2;
  var Bind := TBindings.Create;
  Bind.VertexBuffers[0] := FDisplay.VBuf;
  Bind.Samplers[SMP_SMP] := FDisplay.Sampler;

  var Pass := TPass.Create;
  Pass.Action^ := FDisplay.PassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FDisplay.Pip);

  var QuadParams: TQuadParams;
  QuadParams.ColorBias := 0;
  QuadParams.ColorScale := 1;

  for var I := 0 to 2 do
  begin
    TGfx.ApplyViewport(X0 + (I * (QuadWidth + QuadGap)), Y0, QuadWidth, QuadHeight, True);
    case I of
      0: begin
           Bind.Views[VIEW_TEX] := FOffscreen.Depth.TexView;
           QuadParams.ColorBias := 0;
           QuadParams.ColorScale := 0.5;
         end;
      1: begin
           Bind.Views[VIEW_TEX] := FOffscreen.Normal.TexView;
           QuadParams.ColorBias := 1;
           QuadParams.ColorScale := 0.5;
         end;
      2: begin
           Bind.Views[VIEW_TEX] := FOffscreen.Color.TexView;
           QuadParams.ColorBias := 0;
           QuadParams.ColorScale := 1;
         end;
    end;
    TGfx.ApplyUniforms(UB_QUAD_PARAMS, TRange.Create(QuadParams));
    TGfx.ApplyBindings(Bind);
    TGfx.Draw(0, 4);
  end;
  TGfx.ApplyViewport(0, 0, DispWidth, DispHeight, True);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TMrtPixelFormatsApp.Cleanup;
begin
  inherited;
end;

function TMrtPixelFormatsApp.ComputeOffscreenParams: TOffscreenParams;
begin
  var RXM, RZM: TMatrix4;
  RXM.InitRotationX(Radians(FRX));
  RZM.InitRotationZ(Radians(FRY));
  var Model := RXM * RZM;
  Result.Mvp := FOffscreen.ViewProj * Model;
end;

procedure TMrtPixelFormatsApp.DrawFallback;
begin
  var PassAction: TPassAction;
  PassAction.Colors[0].Init(TLoadAction.Clear, 1, 0, 0, 1);

  var Pass := TPass.Create;
  Pass.Action^ := PassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

{ TImageAndViews }

procedure TImageAndViews.Init(const AImgDesc: TImageDesc; const AAttLabel,
  ATexLabel: UTF8String);
begin
  Image := TImage.Create(AImgDesc);

  var ViewDesc := TViewDesc.Create;
  ViewDesc.ColorAttachment.Image := Image;
  ViewDesc.TraceLabel := AAttLabel;
  AttView := TView.Create(ViewDesc);

  ViewDesc.Init;
  ViewDesc.Texture.Image := Image;
  ViewDesc.TraceLabel := ATexLabel;
  TexView := TView.Create(ViewDesc);
end;

{ TOffscreen }

procedure TOffscreen.Init;
var
  Vertices: array [0..2999] of TShapeVertex;
  Indices: array [0..5999] of UInt16;
begin
  { Create 3 render target textures with different formats }
  var ImgDesc := TImageDesc.Create;
  ImgDesc.Usage.ColorAttachment := True;
  ImgDesc.PixelFormat := DEPTH_PIXEL_FORMAT;
  ImgDesc.Width := OFFSCREEN_WIDTH;
  ImgDesc.Height := OFFSCREEN_HEIGHT;
  ImgDesc.SampleCount := 1;
  ImgDesc.TraceLabel := 'DepthImage';
  Depth.Init(ImgDesc, 'DepthAttachment', 'DepthTexture');

  ImgDesc.PixelFormat := NORMAL_PIXEL_FORMAT;
  ImgDesc.TraceLabel := 'NormalImage';
  Normal.Init(ImgDesc, 'NormalAttachment', 'NormalTexture');

  ImgDesc.PixelFormat := COLOR_PIXEL_FORMAT;
  ImgDesc.TraceLabel := 'ColorImage';
  Color.Init(ImgDesc, 'ColorAttachment', 'ColorTexture');

  ImgDesc.Usage.ColorAttachment := False;
  ImgDesc.Usage.DepthStencilAttachment := True;
  ImgDesc.PixelFormat := TPixelFormat.Depth;
  ImgDesc.TraceLabel := 'DepthBufferImage';
  var ZBufImg := TImage.Create(ImgDesc);

  var ViewDesc := TViewDesc.Create;
  ViewDesc.DepthStencilAttachment.Image := ZBufImg;
  ViewDesc.TraceLabel := 'DepthBufferAttachment';
  var ZBufView := TView.Create(ViewDesc);

  { A render pass descriptor for mrt rendering }
  Pass.Init;
  Pass.Action.Colors[0].Init(TLoadAction.Clear, 0, 0, 0, 0);
  Pass.Action.Colors[1].Init(TLoadAction.Clear, 0, 0, 0, 0);
  Pass.Action.Colors[2].Init(TLoadAction.Clear, 0, 0, 0, 0);
  Pass.Attachments.Colors[0] := Depth.AttView;
  Pass.Attachments.Colors[1] := Normal.AttView;
  Pass.Attachments.Colors[2] := Color.AttView;
  Pass.Attachments.DepthStencil := ZBufView;

  { Create a shape to render into the offscreen render target }
  FillChar(Vertices, SizeOf(Vertices), 0);
  FillChar(Indices, SizeOf(Indices), 0);
  var Buf := TShapeBuffer.Create(TRange.Create(Vertices), TRange.Create(Indices));

  var Torus := TShapeTorus.Create(0.5, 0.3, 20, 36);
  Torus.RandomColors := True;
  Buf := Buf.Build(Torus);
  Assert(Buf.Valid);
  Donut := Buf.ElementRange;
  var VBufDesc := Buf.VertexBufferDesc;
  var IBufDesc := Buf.IndexBufferDesc;
  Bind.VertexBuffers[0] := TBuffer.Create(VBufDesc);
  Bind.IndexBuffer := TBuffer.Create(IBufDesc);

  { Create shader and pipeline object for offscreen MRT rendering }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(OffscreenShaderDesc);;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Layout.Buffers[0] := TShapeBuffer.VertexBufferLayoutState;
  PipDesc.Layout.Attrs[ATTR_OFFSCREEN_IN_POS] := TShapeBuffer.PositionVertexAttrState;
  PipDesc.Layout.Attrs[ATTR_OFFSCREEN_IN_NORMAL] := TShapeBuffer.NormalVertexAttrState;
  PipDesc.Layout.Attrs[ATTR_OFFSCREEN_IN_COLOR] := TShapeBuffer.ColorVertexAttrState;
  PipDesc.Depth.PixelFormat := TPixelFormat.Depth;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.ColorCount := 3;
  PipDesc.Colors[0].PixelFormat := DEPTH_PIXEL_FORMAT;
  PipDesc.Colors[1].PixelFormat := NORMAL_PIXEL_FORMAT;
  PipDesc.Colors[2].PixelFormat := COLOR_PIXEL_FORMAT;
  PipDesc.SampleCount := 1;
  Pip := TPipeline.Create(PipDesc);

  { Constant ViewProj matrix for offscreen rendering }
  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), 1, 0.01, 5.0);
  View.InitLookAtRH(Vector3(0, 0, 2), Vector3(0, 0, 0), Vector3(0, 1, 0));
  ViewProj := Proj * View;
end;

{ TDisplay }

procedure TDisplay.Init;
const
  QUAD_VERTICES: array [0..7] of Single = (0, 0, 1, 0, 0, 1, 1, 1);
begin
  PassAction.Colors[0].Init(TLoadAction.Clear, 0.25, 0.5, 0.75, 1);

  { A vertex buffer for rendering a quad }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(QUAD_VERTICES);
  VBuf := TBuffer.Create(BufferDesc);

  { Shader and pipeline object to render a quad }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(QuadShaderDesc);
  PipDesc.PrimitiveType := TPrimitiveType.TriangleStrip;
  PipDesc.Layout.Attrs[ATTR_QUAD_POS].Format := TVertexFormat.Float2;
  Pip := TPipeline.Create(PipDesc);

  { A sampler for sampling the offscreen render target as textures }
  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Nearest;
  SamplerDesc.MagFilter := TFilter.Nearest;
  SamplerDesc.WrapU := TWrap.ClampToEdge;
  SamplerDesc.WrapV := TWrap.ClampToEdge;
  Sampler := TSampler.Create(SamplerDesc);
end;

end.

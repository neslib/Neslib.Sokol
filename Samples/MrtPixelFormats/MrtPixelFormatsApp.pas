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
  TOffscreen = record
  public
    DepthImg: TImage;
    NormalImg: TImage;
    ColorImg: TImage;
    ZBufferImg: TImage;
    PassAction: TPassAction;
    Pass: TPass;
    Pip: TPipeline;
    Shader: TShader;
    Bind: TBindings;
    ViewProj: TMatrix4;
    Donut: TShapeElementRange;
  public
    procedure Init;
    procedure Free;
  end;

type
  TDisplay = record
  public
    PassAction: TPassAction;
    VBuf: TBuffer;
    Shader: TShader;
    Pip: TPipeline;
  public
    procedure Init;
    procedure Free;
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
  Neslib.Sokol.Api;

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

procedure TMrtPixelFormatsApp.Cleanup;
begin
  FOffscreen.Free;
  FDisplay.Free;
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

procedure TMrtPixelFormatsApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.WindowTitle := 'MRT Pixelformats';
end;

procedure TMrtPixelFormatsApp.DrawFallback;
begin
  var PassAction: TPassAction;
  PassAction.Colors[0].Init(TAction.Clear, 1, 0, 0, 1);
  TGfx.BeginDefaultPass(PassAction, FramebufferWidth, FramebufferHeight);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
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
  TGfx.BeginPass(FOffscreen.Pass, FOffscreen.PassAction);
  TGfx.ApplyPipeline(FOffscreen.Pip);
  TGfx.ApplyBindings(FOffscreen.Bind);
  TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_OFFSCREEN_PARAMS,
    TRange.Create(OffscreenParams));
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

  TGfx.BeginDefaultPass(FDisplay.PassAction, DispWidth, DispHeight);
  TGfx.ApplyPipeline(FDisplay.Pip);

  var QuadParams: TQuadParams;
  QuadParams.ColorBias := 0;
  QuadParams.ColorScale := 1;

  for var I := 0 to 2 do
  begin
    TGfx.ApplyViewport(X0 + (I * (QuadWidth + QuadGap)), Y0, QuadWidth, QuadHeight, True);
    case I of
      0: begin
           Bind.FragmentShaderImages[0] := FOffscreen.DepthImg;
           QuadParams.ColorBias := 0;
           QuadParams.ColorScale := 0.5;
         end;
      1: begin
           Bind.FragmentShaderImages[0] := FOffscreen.NormalImg;
           QuadParams.ColorBias := 1;
           QuadParams.ColorScale := 0.5;
         end;
      2: begin
           Bind.FragmentShaderImages[0] := FOffscreen.ColorImg;
           QuadParams.ColorBias := 0;
           QuadParams.ColorScale := 1;
         end;
    end;
    TGfx.ApplyUniforms(TShaderStage.FragmentShader, SLOT_QUAD_PARAMS,
      TRange.Create(QuadParams));
    TGfx.ApplyBindings(Bind);
    TGfx.Draw(0, 4);
  end;
  TGfx.ApplyViewport(0, 0, DispWidth, DispHeight, True);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TMrtPixelFormatsApp.Init;
begin
  inherited;
  { Check if requires features are supported }
  FFeaturesOK := (TFeature.MultipleRenderTargets in TGfx.Features)
    and DEPTH_PIXEL_FORMAT.Render
    and NORMAL_PIXEL_FORMAT.Render
    and COLOR_PIXEL_FORMAT.Render;
  if (not FFeaturesOK) then
    Exit;

  { Setup resources for offscreen rendering }
  FOffscreen.Init;

  { Setup resources for rendering to the display }
  FDisplay.Init;
end;

{ TOffscreen }

procedure TOffscreen.Free;
begin
  DepthImg.Free;
  NormalImg.Free;
  ColorImg.Free;
  ZBufferImg.Free;
  Shader.Free;
  Pip.Free;
  Bind.VertexBuffers[0].Free;
  Bind.IndexBuffer.Free;
end;

procedure TOffscreen.Init;
var
  Vertices: array [0..2999] of TShapeVertex;
  Indices: array [0..5999] of UInt16;
begin
  PassAction.Colors[0].Init(TAction.Clear, 0, 0, 0, 0);
  PassAction.Colors[1].Init(TAction.Clear, 0, 0, 0, 0);
  PassAction.Colors[2].Init(TAction.Clear, 0, 0, 0, 0);

  { Create 3 render target textures with different formats }
  var ImgDesc := TImageDesc.Create;
  ImgDesc.RenderTarget := True;
  ImgDesc.PixelFormat := DEPTH_PIXEL_FORMAT;
  ImgDesc.Width := OFFSCREEN_WIDTH;
  ImgDesc.Height := OFFSCREEN_HEIGHT;
  ImgDesc.SampleCount := 1;
  ImgDesc.MinFilter := TFilter.Nearest;
  ImgDesc.MagFilter := TFilter.Nearest;
  ImgDesc.WrapU := TWrap.ClampToEdge;
  ImgDesc.WrapV := TWrap.ClampToEdge;
  DepthImg := TImage.Create(ImgDesc);

  ImgDesc.PixelFormat := NORMAL_PIXEL_FORMAT;
  NormalImg := TImage.Create(ImgDesc);

  ImgDesc.PixelFormat := COLOR_PIXEL_FORMAT;
  ColorImg := TImage.Create(ImgDesc);

  ImgDesc.PixelFormat := TPixelFormat.Depth;
  ZBufferImg := TImage.Create(ImgDesc);

  { Create pass object for MRT offscreen rendering }
  var PassDesc := TPassDesc.Create;
  PassDesc.ColorAttachments[0].Image := DepthImg;
  PassDesc.ColorAttachments[1].Image := NormalImg;
  PassDesc.ColorAttachments[2].Image := ColorImg;
  PassDesc.DepthStencilAttachment.Image := ZBufferImg;
  Pass := TPass.Create(PassDesc);

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
  Shader := TShader.Create(OffscreenShaderDesc);
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := Shader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Layout.Buffers[0] := TShapeBuffer.BufferLayoutDesc;
  PipDesc.Layout.Attrs[ATTR_VS_OFFSCREEN_IN_POS] := TShapeBuffer.PositionAttrDesc;
  PipDesc.Layout.Attrs[ATTR_VS_OFFSCREEN_IN_NORMAL] := TShapeBuffer.NormalAttrDesc;
  PipDesc.Layout.Attrs[ATTR_VS_OFFSCREEN_IN_COLOR] := TShapeBuffer.ColorAttrDesc;
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
  Proj.InitPerspectiveFovRH(Radians(60), 1, 0.01, 5.0, True);
  View.InitLookAtRH(Vector3(0, 0, 2), Vector3(0, 0, 0), Vector3(0, 1, 0));
  ViewProj := Proj * View;
end;

{ TDisplay }

procedure TDisplay.Free;
begin
  VBuf.Free;
  Shader.Free;
  Pip.Free;
end;

procedure TDisplay.Init;
const
  QUAD_VERTICES: array [0..7] of Single = (0, 0, 1, 0, 0, 1, 1, 1);
begin
  PassAction.Colors[0].Init(TAction.Clear, 0.25, 0.5, 0.75, 1);

  { A vertex buffer for rendering a quad }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(QUAD_VERTICES);
  VBuf := TBuffer.Create(BufferDesc);

  { Shader and pipeline object to render a quad }
  Shader := TShader.Create(QuadShaderDesc);
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := Shader;
  PipDesc.PrimitiveType := TPrimitiveType.TriangleStrip;
  PipDesc.Layout.Attrs[ATTR_VS_QUAD_POS].Format := TVertexFormat.Float2;
  Pip := TPipeline.Create(PipDesc);
end;

end.

unit MrtApp;
{ Rendering with multi-rendertargets, and recreating render targets when window
  size changes. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  MrtShader;

type
  TMrtApp = class(TSampleApp)
  private const
    OFFSCREEN_SAMPLE_COUNT = 4;
  private type
    TOffscreen = record
      PassAction: TPassAction;
      PassDesc: TPassDesc;
      Pass: TPass;
      Shader: TShader;
      Pip: TPipeline;
      Bind: TBindings;
    end;
  private type
    TFsq = record
      Shader: TShader;
      Bind: TBindings;
      Pip: TPipeline;
    end;
  private type
    TDbg = record
      Shader: TShader;
      Bind: TBindings;
      Pip: TPipeline;
    end;
  private
    FOffscreen: TOffscreen;
    FFsq: TFsq;
    FDbg: TDbg;
    FPassAction: TPassAction;
    FRX: Single;
    FRY: Single;
  private
    procedure CreateOffscreenPass(const AWidth, AHeight: Integer);
    procedure DrawGles2Fallback;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure Resized(const AWindowWidth, AWindowHeight, AFramebufferWidth,
      AFramebufferHeight: Integer); override;
  end;

implementation

uses
  Neslib.Sokol.Api;

type
  TVertex = record
    X, Y, Z, B: Single;
  end;

const
  { Cube vertex buffer }
  CUBE_VERTICES: array [0..23] of TVertex = (
    { Pos + Brightness }
    (X: -1.0; Y: -1.0; Z: -1.0; B: 1.0),
    (X:  1.0; Y: -1.0; Z: -1.0; B: 1.0),
    (X:  1.0; Y:  1.0; Z: -1.0; B: 1.0),
    (X: -1.0; Y:  1.0; Z: -1.0; B: 1.0),

    (X: -1.0; Y: -1.0; Z:  1.0; B: 0.8),
    (X:  1.0; Y: -1.0; Z:  1.0; B: 0.8),
    (X:  1.0; Y:  1.0; Z:  1.0; B: 0.8),
    (X: -1.0; Y:  1.0; Z:  1.0; B: 0.8),

    (X: -1.0; Y: -1.0; Z: -1.0; B: 0.6),
    (X: -1.0; Y:  1.0; Z: -1.0; B: 0.6),
    (X: -1.0; Y:  1.0; Z:  1.0; B: 0.6),
    (X: -1.0; Y: -1.0; Z:  1.0; B: 0.6),

    (X:  1.0; Y: -1.0; Z: -1.0; B: 0.4),
    (X:  1.0; Y:  1.0; Z: -1.0; B: 0.4),
    (X:  1.0; Y:  1.0; Z:  1.0; B: 0.4),
    (X:  1.0; Y: -1.0; Z:  1.0; B: 0.4),

    (X: -1.0; Y: -1.0; Z: -1.0; B: 0.5),
    (X: -1.0; Y: -1.0; Z:  1.0; B: 0.5),
    (X:  1.0; Y: -1.0; Z:  1.0; B: 0.5),
    (X:  1.0; Y: -1.0; Z: -1.0; B: 0.5),

    (X: -1.0; Y:  1.0; Z: -1.0; B: 0.7),
    (X: -1.0; Y:  1.0; Z:  1.0; B: 0.7),
    (X:  1.0; Y:  1.0; Z:  1.0; B: 0.7),
    (X:  1.0; Y:  1.0; Z: -1.0; B: 0.7));

const
  { Index buffer for the cube }
  CUBE_INDICES: array [0..35] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20);

const
  { A vertex buffer to render a fullscreen rectangle }
  QUAD_VERTICES: array [0..7] of Single = (0, 0, 1, 0, 0, 1, 1, 1);

{ TMrtApp }

procedure TMrtApp.Cleanup;
var
  I: Integer;
begin
  for I := 0 to 2 do
    FOffscreen.PassDesc.ColorAttachments[I].Image.Free;
  FOffscreen.PassDesc.DepthStencilAttachment.Image.Free;
  FOffscreen.Pass.Free;
  FOffscreen.Shader.Free;
  FOffscreen.Pip.Free;
  FOffscreen.Bind.VertexBuffers[0].Free;
  FOffscreen.Bind.IndexBuffer.Free;
  FFsq.Bind.VertexBuffers[0].Free;
  FFsq.Shader.Free;
  FFsq.Pip.Free;
  FDbg.Shader.Free;
  FDbg.Pip.Free;
  inherited;
end;

procedure TMrtApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'MRT Rendering';
  AConfig.HighDpi := False;
end;

procedure TMrtApp.CreateOffscreenPass(const AWidth, AHeight: Integer);
{ Called initially and when window size changes }
begin
  FOffscreen.Pass.Free;
  for var I := 0 to 2 do
    FOffscreen.PassDesc.ColorAttachments[I].Image.Free;
  FOffscreen.PassDesc.DepthStencilAttachment.Image.Free;

  { Create offscreen rendertarget images and pass }
  var ColorImgDesc := TImageDesc.Create;
  ColorImgDesc.RenderTarget := True;
  ColorImgDesc.Width := AWidth;
  ColorImgDesc.Height := AHeight;
  ColorImgDesc.MinFilter := TFilter.Linear;
  ColorImgDesc.MagFilter := TFilter.Linear;
  ColorImgDesc.WrapU := TWrap.ClampToEdge;
  ColorImgDesc.WrapV := TWrap.ClampToEdge;
  if (TFeature.MsaaRenderTargets in TGfx.Features) then
    ColorImgDesc.SampleCount := OFFSCREEN_SAMPLE_COUNT
  else
    ColorImgDesc.SampleCount := 1;
  ColorImgDesc.TraceLabel := 'Color Image';

  var DepthImgDesc := ColorImgDesc;
  DepthImgDesc.PixelFormat := TPixelFormat.Depth;
  DepthImgDesc.TraceLabel := 'Depth Image';

  FOffscreen.PassDesc.Init;
  FOffscreen.PassDesc.ColorAttachments[0].Image := TImage.Create(ColorImgDesc);
  FOffscreen.PassDesc.ColorAttachments[1].Image := TImage.Create(ColorImgDesc);
  FOffscreen.PassDesc.ColorAttachments[2].Image := TImage.Create(ColorImgDesc);
  FOffscreen.PassDesc.DepthStencilAttachment.Image := TImage.Create(DepthImgDesc);
  FOffscreen.PassDesc.TraceLabel := 'Offscreen Pass';

  FOffscreen.Pass := TPass.Create(FOffscreen.PassDesc);

  { Also need to update the fullscreen-quad texture bindings }
  for var I := 0 to 2 do
    FFsq.Bind.FragmentShaderImages[I] := FOffscreen.PassDesc.ColorAttachments[I].Image;
end;

procedure TMrtApp.DrawGles2Fallback;
begin
  var PassAction := TPassAction.Create;
  PassAction.Colors[0].Init(TAction.Clear, 1, 0, 0, 1);
  TGfx.BeginDefaultPass(PassAction, FramebufferWidth, FramebufferHeight);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TMrtApp.Frame;
begin
  { Can't do anything useful on GLES2/WebGL }
  if (UsesGles2) then
  begin
    DrawGles2Fallback;
    Exit;
  end;

  { View-projection matrix }
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var Proj, View, RXM, RYM: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), H / W, 0.01, 10.0, True);
  View.InitLookAtRH(Vector3(0, 1.5, 6), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  { Shader parameters }
  var T: Single := FrameDuration * 60;
  var OffscreenParams: TOffscreenParams;
  var FsqParams: TFsqParams;

  FRX := FRX + (1 * T);
  FRY := FRY + (2 * T);
  RXM.InitRotationX(Radians(FRX));
  RYM.InitRotationY(Radians(FRY));
  var Model := RXM * RYM;
  OffscreenParams.MVP := ViewProj * Model;
  FsqParams.Offset := Vector2(
    FastSin(FRX * 0.01) * 0.1,
    FastSin(FRY * 0.01) * 0.1);

  { Render cube into MRT offscreen render targets }
  TGfx.BeginPass(FOffscreen.Pass, FOffscreen.PassAction);
  TGfx.ApplyPipeline(FOffscreen.Pip);
  TGfx.ApplyBindings(FOffscreen.Bind);
  TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_OFFSCREEN_PARAMS,
    TRange.Create(OffscreenParams));
  TGfx.Draw(0, 36);
  TGfx.EndPass;

  { Render fullscreen quad with the 'composed image', plus 3 small debug-view
    quads }
  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  TGfx.ApplyPipeline(FFsq.Pip);
  TGfx.ApplyBindings(FFsq.Bind);
  TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_FSQ_PARAMS,
    TRange.Create(FsqParams));
  TGfx.Draw(0, 4);

  TGfx.ApplyPipeline(FDbg.Pip);
  for var I := 0 to 2 do
  begin
    TGfx.ApplyViewport(I * 100, 0, 100, 100, False);
    FDbg.Bind.FragmentShaderImages[SLOT_TEX] :=
      FOffscreen.PassDesc.ColorAttachments[I].Image;
    TGfx.ApplyBindings(FDbg.Bind);
    TGfx.Draw(0, 4);
  end;

  TGfx.ApplyViewport(0, 0, FramebufferWidth, FramebufferHeight, False);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TMrtApp.Init;
begin
  inherited;
  if (UsesGles2) then
    { This demo needs GLES-3 }
    Exit;

  { A pass action for the default render pass }
  FPassAction.Colors[0].Action := TAction.DontCare;
  FPassAction.Depth.Action := TAction.DontCare;
  FPassAction.Stencil.Action := TAction.DontCare;

  { A render pass with 3 color attachment images, and a depth attachment image }
  CreateOffscreenPass(FramebufferWidth, FramebufferHeight);

  { Vertex- and index-buffer }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(CUBE_VERTICES);
  BufferDesc.TraceLabel := 'Cube Vertices';
  var CubeVBuf := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.BufferType := TBufferType.IndexBuffer;
  BufferDesc.Data := TRange.Create(CUBE_INDICES);
  BufferDesc.TraceLabel := 'Cube Indices';
  var CubeIBuf := TBuffer.Create(BufferDesc);

  { A shader to render the cube into offscreen MRT render targest }
  FOffscreen.Shader := TShader.Create(OffscreenShaderDesc);

  { Pass action for offscreen pass }
  FOffscreen.PassAction := TPassAction.Create;
  FOffscreen.PassAction.Colors[0].Init(TAction.Clear, 0.25, 0, 0, 1);
  FOffscreen.PassAction.Colors[1].Init(TAction.Clear, 0, 0.25, 0, 1);
  FOffscreen.PassAction.Colors[2].Init(TAction.Clear, 0, 0, 0.25, 1);

  { Pipeline object for the offscreen-rendered cube }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Buffers[0].Stride := SizeOf(TVertex);
  PipDesc.Layout.Attrs[ATTR_VS_OFFSCREEN_POS].Offset := 0;
  PipDesc.Layout.Attrs[ATTR_VS_OFFSCREEN_POS].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_VS_OFFSCREEN_BRIGHT0].Offset := SizeOf(TVector3);
  PipDesc.Layout.Attrs[ATTR_VS_OFFSCREEN_BRIGHT0].Format := TVertexFormat.Float;
  PipDesc.Shader := FOffscreen.Shader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.PixelFormat := TPixelFormat.Depth;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.ColorCount := 3;
  PipDesc.TraceLabel := 'Offscreen Pipeline';
  FOffscreen.Pip := TPipeline.Create(PipDesc);

  { Resource bindings for offscreen rendering }
  FOffscreen.Bind.VertexBuffers[0] := CubeVBuf;
  FOffscreen.Bind.IndexBuffer := CubeIBuf;

  { A vertex buffer to render a fullscreen rectangle }
  BufferDesc.Init;
  BufferDesc.Data := TRange.Create(QUAD_VERTICES);
  BufferDesc.TraceLabel := 'Quad Vertices';
  var QuadVBuf := TBuffer.Create(BufferDesc);

  { A shader to render a fullscreen rectangle by adding the 3 offscreen-rendered
    images }
  FFsq.Shader := TShader.Create(FsqShaderDesc);

  { The pipeline object to render the fullscreen quad }
  PipDesc.Init;
  PipDesc.Layout.Attrs[ATTR_VS_FSQ_POS].Format := TVertexFormat.Float2;
  PipDesc.Shader := FFsq.Shader;
  PipDesc.PrimitiveType := TPrimitiveType.TriangleStrip;
  PipDesc.TraceLabel := 'Fullscreen Quad Pipeline';
  FFsq.Pip := TPipeline.Create(PipDesc);

  { Resource bindings to render a fullscreen quad }
  FFsq.Bind.VertexBuffers[0] := QuadVBuf;
  FFsq.Bind.FragmentShaderImages[SLOT_TEX0] := FOffscreen.PassDesc.ColorAttachments[0].Image;
  FFsq.Bind.FragmentShaderImages[SLOT_TEX1] := FOffscreen.PassDesc.ColorAttachments[1].Image;
  FFsq.Bind.FragmentShaderImages[SLOT_TEX2] := FOffscreen.PassDesc.ColorAttachments[2].Image;

  { Pipeline and resource bindings to render debug-visualization quads }
  FDbg.Shader := TShader.Create(DbgShaderDesc);

  PipDesc.Init;
  PipDesc.Layout.Attrs[ATTR_VS_DBG_POS].Format := TVertexFormat.Float2;
  PipDesc.PrimitiveType := TPrimitiveType.TriangleStrip;
  PipDesc.Shader := FDbg.Shader;
  PipDesc.TraceLabel := 'Dbgvis Quad Pipeline';
  FDbg.Pip := TPipeline.Create(PipDesc);

  FDbg.Bind.VertexBuffers[0] := QuadVBuf;
  { Images will be filled right before rendering }
end;

procedure TMrtApp.Resized(const AWindowWidth, AWindowHeight, AFramebufferWidth,
  AFramebufferHeight: Integer);
begin
  inherited;
  CreateOffscreenPass(AFramebufferWidth, AFramebufferHeight);
end;

end.

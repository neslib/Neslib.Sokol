unit DebugTextContextApp;
{ Demonstrate rendering to offscreen render targets with contexts.

  Renders a cube with a different render target texture on each side, and each
  render target containing debug text. Text rendering into render targets uses
  different framebuffer attributes than the default framebuffer (no depth
  buffer, no MSAA), so this needs to happen with separate Neslib.Sokol.DebugText
  contexts. }
interface

uses
  System.UITypes,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.DebugText,
  Neslib.FastMath,
  SampleApp,
  DebugTextContextShader;

const
  NUM_FACES              = 6;
  OFFSCREEN_PIXELFORMAT  = TPixelFormat.Rgba8;
  OFFSCREEN_SAMPLE_COUNT = 1;
  OFFSCREEN_WIDTH        = 32;
  OFFSCREEN_HEIGHT       = 32;
  DISPLAY_SAMPLE_COUNT   = 4;

type
  TVertex = record
  public
    X, Y, Z: Single;
    U, V: UInt16;
  end;

type
  TDebugTextContextApp = class(TSampleApp)
  private type
    TFacePass = record
    public
      TextContext: TDbgTextContext;
      Image: TImage;
      RenderPass: TPass;
      PassAction: TPassAction;
    public
      procedure Init(const ABGColor: TColor);
      procedure Free;
    end;
  private
    FVBuf: TBuffer;
    FIBuf: TBuffer;
    FShader: TShader;
    FPip: TPipeline;

    { Just keep this default-initialized, which clears to gray }
    FPassAction: TPassAction;

    FPasses: array [0..NUM_FACES - 1] of TFacePass;
    FRX: Single;
    FRY: Single;
  private
    function ComputeVSParams(const AW, AH: Integer): TVSParams;
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
  { Face background colors }
  BG_COLORS: array [0..NUM_FACES - 1] of TColor = (
    (R: 0.0; G: 0.0;  B: 0.5;  A: 1.0),
    (R: 0.0; G: 0.5;  B: 0.0;  A: 1.0),
    (R: 0.5; G: 0.0;  B: 0.0;  A: 1.0),
    (R: 0.5; G: 0.0;  B: 0.25; A: 1.0),
    (R: 0.5; G: 0.25; B: 0.0;  A: 1.0),
    (R: 0.0; G: 0.25; B: 0.5;  A: 1.0));

const
  { Cube vertex buffer }
  VERTICES: array [0..23] of TVertex = (
  // Pos                        UVs
    (X: -1.0; Y: -1.0; Z: -1.0; U:      0; V:     0),
    (X:  1.0; Y: -1.0; Z: -1.0; U:  32767; V:     0),
    (X:  1.0; Y:  1.0; Z: -1.0; U:  32767; V: 32767),
    (X: -1.0; Y:  1.0; Z: -1.0; U:      0; V: 32767),
    (X: -1.0; Y: -1.0; Z:  1.0; U:  32767; V:     0),
    (X:  1.0; Y: -1.0; Z:  1.0; U:      0; V:     0),
    (X:  1.0; Y:  1.0; Z:  1.0; U:      0; V: 32767),
    (X: -1.0; Y:  1.0; Z:  1.0; U:  32767; V: 32767),
    (X: -1.0; Y: -1.0; Z: -1.0; U:      0; V:     0),
    (X: -1.0; Y:  1.0; Z: -1.0; U:  32767; V:     0),
    (X: -1.0; Y:  1.0; Z:  1.0; U:  32767; V: 32767),
    (X: -1.0; Y: -1.0; Z:  1.0; U:      0; V: 32767),
    (X:  1.0; Y: -1.0; Z: -1.0; U:  32767; V:     0),
    (X:  1.0; Y:  1.0; Z: -1.0; U:      0; V:     0),
    (X:  1.0; Y:  1.0; Z:  1.0; U:      0; V: 32767),
    (X:  1.0; Y: -1.0; Z:  1.0; U:  32767; V: 32767),
    (X: -1.0; Y: -1.0; Z: -1.0; U:      0; V:     0),
    (X: -1.0; Y: -1.0; Z:  1.0; U:  32767; V:     0),
    (X:  1.0; Y: -1.0; Z:  1.0; U:  32767; V: 32767),
    (X:  1.0; Y: -1.0; Z: -1.0; U:      0; V: 32767),
    (X: -1.0; Y:  1.0; Z: -1.0; U:  32767; V:     0),
    (X: -1.0; Y:  1.0; Z:  1.0; U:      0; V:     0),
    (X:  1.0; Y:  1.0; Z:  1.0; U:      0; V: 32767),
    (X:  1.0; Y:  1.0; Z: -1.0; U:  32767; V: 32767));

const
  { Index buffer for the cube }
  INDICES: array [0..35] of UInt16 = (
     0,  1,  2,   0,  2,  3,
     6,  5,  4,   7,  6,  4,
     8,  9, 10,   8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20);

{ TDebugTextContextApp }

procedure TDebugTextContextApp.Cleanup;
begin
  FVBuf.Free;
  FIBuf.Free;
  FShader.Free;
  FPip.Free;
  for var I := 0 to NUM_FACES - 1 do
    FPasses[I].Free;
  TDbgText.Shutdown;
  inherited;
end;

function TDebugTextContextApp.ComputeVSParams(const AW, AH: Integer): TVSParams;
var
  Proj, View, Rxm, Rym: TMatrix4;
begin
  Proj.InitPerspectiveFovRH(Radians(60), AH / AW, 0.01, 10.0, True);
  View.InitLookAtRH(Vector3(0, 1.5, 6), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  Rxm.InitRotationX(Radians(FRX));
  Rym.InitRotationY(Radians(FRY));
  var Model := Rym * Rxm;
  Result.Mvp := ViewProj * Model;
end;

procedure TDebugTextContextApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := DISPLAY_SAMPLE_COUNT;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'DebugTextContext';
end;

procedure TDebugTextContextApp.Frame;
begin
  var DispWidth := FramebufferWidth;
  var DispHeight := FramebufferHeight;
  var T: Single := FrameDuration * 60;
  var FrameCount: Integer := Self.FrameCount;

  FRX := FRX + (0.25 * T);
  FRY := FRY + (0.5 * T);
  var VSParams := ComputeVSParams(DispWidth, DispHeight);

  { Text in the main display }
  TDbgText.Context := TDbgTextContext.Default;
  TDbgText.Canvas(0.5 * DispWidth, 0.5 * DispHeight);
  TDbgText.Origin(3, 3);
  TDbgText.WriteAnsiLn('Hello from main context!');
  TDbgText.Write('Frame count: %d', [FrameCount]);

  { Text in each offscreen render target }
  for var I := 0 to NUM_FACES - 1 do
  begin
    TDbgText.Context := FPasses[I].TextContext;
    TDbgText.Origin(1, 0.5);
    TDbgText.Font(I);
    TDbgText.Write('%.2x', [((FrameCount shr 4) + I) and $FF]);
  end;

  { Rasterize text into offscreen render targets. We could also put this right
    into the loop above, but this shows that the "text definition" can be
    decoupled from the actual rendering }
  for var I := 0 to NUM_FACES - 1 do
  begin
    TGfx.BeginPass(FPasses[I].RenderPass, FPasses[I].PassAction);
    TDbgText.Context := FPasses[I].TextContext;
    TDbgText.Draw;
    TGfx.EndPass;
  end;

  { Finally render to the default framebuffer }
  TGfx.BeginDefaultPass(FPassAction, DispWidth, DispHeight);

  { Draw the cube as 6 separate draw calls (because each has its own texture) }
  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_PARAMS, TRange.Create(VSParams));
  var Bindings := TBindings.Create;
  for var I := 0 to NUM_FACES - 1 do
  begin
    Bindings.VertexBuffers[0] := FVBuf;
    Bindings.IndexBuffer := FIBuf;
    Bindings.FragmentShaderImages[0] := FPasses[I].Image;
    TGfx.ApplyBindings(Bindings);
    TGfx.Draw(I * 6, 6);
  end;

  { Draw default-display text }
  TDbgText.Context := TDbgTextContext.Default;
  TDbgText.Draw;

  { Conclude the default pass and frame }
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TDebugTextContextApp.Init;
begin
  inherited;
  { Setup Neslib.Sokol.DebugText using all builtin fonts }
  var DbgTextDesc := TDbgTextDesc.Create;
  DbgTextDesc.Fonts[0] := TDbgTextFont.KC853;
  DbgTextDesc.Fonts[1] := TDbgTextFont.KC854;
  DbgTextDesc.Fonts[2] := TDbgTextFont.Z1013;
  DbgTextDesc.Fonts[3] := TDbgTextFont.CPC;
  DbgTextDesc.Fonts[4] := TDbgTextFont.C64;
  DbgTextDesc.Fonts[5] := TDbgTextFont.Oric;
  TDbgText.Setup(DbgTextDesc);

  { Ccreate resources to render a textured cube (vertex buffer, index buffer
    shader and pipeline state object) }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'CubeVertices';
  FVBuf := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.BufferType := TBufferType.IndexBuffer;
  BufferDesc.Data := TRange.Create(INDICES);
  BufferDesc.TraceLabel := 'CubeIndices';
  FIBuf := TBuffer.Create(BufferDesc);

  FShader := TShader.Create(DebugtextContextShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Attrs[ATTR_VS_POS].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_VS_TEXCOORD0].Format := TVertexFormat.Short2N;
  PipDesc.Shader := FShader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.TraceLabel := 'CubePipeline';

  FPip := TPipeline.Create(PipDesc);

  { Create resources for each offscreen-rendered cube face }
  for var I := 0 to NUM_FACES - 1 do
    FPasses[I].Init(BG_COLORS[I]);
end;

{ TDebugTextContextApp.TFacePass }

procedure TDebugTextContextApp.TFacePass.Free;
begin
  TextContext.Free;
  Image.Free;
  RenderPass.Free;
end;

procedure TDebugTextContextApp.TFacePass.Init(const ABGColor: TColor);
begin
  { Each face gets its separate text context. The text canvas size will remain
    fixed, so we can just provide the default canvas size here and don't need to
    TDbgText.Canvas later. }
  var DbgTxtDesc := TDbgTextContextDesc.Create;
  DbgTxtDesc.CharBufSize := 64;
  DbgTxtDesc.CanvasWidth := OFFSCREEN_WIDTH;
  DbgTxtDesc.CanvasHeight := OFFSCREEN_HEIGHT div 2;
  DbgTxtDesc.ColorFormat := OFFSCREEN_PIXELFORMAT;
  DbgTxtDesc.DepthFormat := TPixelFormat.None;
  DbgTxtDesc.SampleCount := OFFSCREEN_SAMPLE_COUNT;
  TextContext := TDbgTextContext.Create(DbgTxtDesc);

  { The render target texture, render pass }
  var ImgDesc := TImageDesc.Create;
  ImgDesc.RenderTarget := True;
  ImgDesc.Width := OFFSCREEN_WIDTH;
  ImgDesc.Height := OFFSCREEN_HEIGHT;
  ImgDesc.PixelFormat := OFFSCREEN_PIXELFORMAT;
  ImgDesc.SampleCount := OFFSCREEN_SAMPLE_COUNT;
  ImgDesc.MinFilter := TFilter.Nearest;
  ImgDesc.MagFilter := TFilter.Nearest;
  Image := TImage.Create(ImgDesc);

  var PassDesc := TPassDesc.Create;
  PassDesc.ColorAttachments[0].Image := Image;
  RenderPass := TPass.Create(PassDesc);

  { Each render target is cleared to a different background color }
  PassAction.Colors[0].Init(TAction.Clear, ABGColor);
end;

end.

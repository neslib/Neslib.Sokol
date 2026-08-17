unit VertexIndexBufferApp;
{ A variant of the Cube sample which puts vertices and indices into the same
  buffer (which isn't allowed on GLES3, but fine on other APIs). }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  VertexIndexBufferShader;

type
  TVertexIndexBufferApp = class(TSampleApp)
  private
    FPip: TPipeline;
    FBind: TBindings;
    FPassAction: TPassAction;
    FRX: Single;
    FRY: Single;
  private
    function ComputeVSParams: TVSParams;
    procedure DrawFallback;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  System.SysUtils,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue,
  Neslib.Sokol.DebugText;

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

{ TVertexIndexBufferApp }

procedure TVertexIndexBufferApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Vertex Index Buffer';
end;

procedure TVertexIndexBufferApp.Init;
begin
  inherited;
  { If combined vertex/index buffers are not supported, setup
    Neslib.Sokol.DebugText to render an error message and return }
  if (TFeature.SeparateBufferTypes in TGfx.Features) then
  begin
    var DbgTextDesc := TDbgTextDesc.Create;
    DbgTextDesc.UseDelphiMemoryManager := True;
    DbgTextDesc.Logger := DbgTextDesc.DefaultLogger;
    DbgTextDesc.Fonts[0] := TDbgTextFont.CPC;
    TDbgText.Setup(DbgTextDesc);

    { Set pass action to render to red }
    FPassAction.Colors[0].Init(TLoadAction.Clear, 1, 0, 0, 1);
    Exit;
  end;

  { Setup pass action to clear to background color }
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0.375, 0.125, 0.25, 1);

  { Create a buffer with both vertices and indices }
  var BufSize := SizeOf(VERTICES) + SizeOf(INDICES);
  var IndicesOffset := SizeOf(VERTICES);
  var Data: TBytes;
  SetLength(Data, BufSize);
  Move(VERTICES, Data[0], SizeOf(VERTICES));
  Move(INDICES, Data[IndicesOffset], SizeOf(INDICES));

  var BufferDesc := TBufferDesc.Create;
  { Indicate that this buffer is going to be bound as vertex- and index-buffer }
  BufferDesc.Usage.VertexBuffer := True;
  BufferDesc.Usage.IndexBuffer := True;
  BufferDesc.Data := TRange.Create(Data);
  BufferDesc.TraceLabel := 'VertexIndexBuffer';
  var Buf := TBuffer.Create(BufferDesc);

  FBind.VertexBuffers[0] := Buf;
  FBind.IndexBuffer := Buf;
  FBind.IndexBufferOffset := IndicesOffset;

  { Create pipeline object (nothing special here) }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(CubeShaderDesc);
  PipDesc.Layout.Attrs[ATTR_CUBE_POSITION].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_CUBE_COLOR0].Format := TVertexFormat.Float4;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.TraceLabel := 'RenderPipeline';

  FPip := TPipeline.Create(PipDesc);
end;

procedure TVertexIndexBufferApp.Frame;
begin
  if (TFeature.SeparateBufferTypes in TGfx.Features) then
  begin
    DrawFallback;
    Exit;
  end;

  var VSParams := ComputeVSParams;
  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyBindings(FBind);
  TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(0, 36, 1);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TVertexIndexBufferApp.Cleanup;
begin
  if (TFeature.SeparateBufferTypes in TGfx.Features) then
    TDbgText.Shutdown;
  inherited;
end;

function TVertexIndexBufferApp.ComputeVSParams: TVSParams;
begin
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var T: Single := FrameDuration * 60;
  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), W / H, 0.01, 10.0);
  View.InitLookAtRH(Vector3(0, 1.5, 4), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  var RXM, RYM: TMatrix4;
  FRX := FRX + (1 * T);
  FRY := FRY + (2 * T);
  RXM.InitRotationX(Radians(FRX));
  RYM.InitRotationY(Radians(FRY));
  var Model := RXM * RYM;
  Result.MVP := ViewProj * Model;
end;

procedure TVertexIndexBufferApp.DrawFallback;
begin
  TDbgText.Canvas(FramebufferWidth * 0.5, FramebufferHeight * 0.5);
  TDbgText.Pos(1, 1);
  TDbgText.Write('Backend doesn''t support combined vertex/index buffers');

  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);
  TDbgText.Draw;
  TGfx.EndPass;
  TGfx.Commit;
end;

end.

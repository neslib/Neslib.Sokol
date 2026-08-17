unit VertexPullApp;
{ Demonstrates vertex pulling from a storage buffer. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  VertexPullShader;

type
  TVertexPullApp = class(TSampleApp)
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
  VERTICES: array [0..23] of TSBVertex = (
    (Pos: (X: -1.0; Y: -1.0; Z: -1.0); Color: (R: 1.0; G: 0.0; B: 0.0; A: 1.0)),
    (Pos: (X:  1.0; Y: -1.0; Z: -1.0); Color: (R: 1.0; G: 0.0; B: 0.0; A: 1.0)),
    (Pos: (X:  1.0; Y:  1.0; Z: -1.0); Color: (R: 1.0; G: 0.0; B: 0.0; A: 1.0)),
    (Pos: (X: -1.0; Y:  1.0; Z: -1.0); Color: (R: 1.0; G: 0.0; B: 0.0; A: 1.0)),
    (Pos: (X: -1.0; Y: -1.0; Z:  1.0); Color: (R: 0.0; G: 1.0; B: 0.0; A: 1.0)),
    (Pos: (X:  1.0; Y: -1.0; Z:  1.0); Color: (R: 0.0; G: 1.0; B: 0.0; A: 1.0)),
    (Pos: (X:  1.0; Y:  1.0; Z:  1.0); Color: (R: 0.0; G: 1.0; B: 0.0; A: 1.0)),
    (Pos: (X: -1.0; Y:  1.0; Z:  1.0); Color: (R: 0.0; G: 1.0; B: 0.0; A: 1.0)),
    (Pos: (X: -1.0; Y: -1.0; Z: -1.0); Color: (R: 0.0; G: 0.0; B: 1.0; A: 1.0)),
    (Pos: (X: -1.0; Y:  1.0; Z: -1.0); Color: (R: 0.0; G: 0.0; B: 1.0; A: 1.0)),
    (Pos: (X: -1.0; Y:  1.0; Z:  1.0); Color: (R: 0.0; G: 0.0; B: 1.0; A: 1.0)),
    (Pos: (X: -1.0; Y: -1.0; Z:  1.0); Color: (R: 0.0; G: 0.0; B: 1.0; A: 1.0)),
    (Pos: (X:  1.0; Y: -1.0; Z: -1.0); Color: (R: 1.0; G: 0.5; B: 0.0; A: 1.0)),
    (Pos: (X:  1.0; Y:  1.0; Z: -1.0); Color: (R: 1.0; G: 0.5; B: 0.0; A: 1.0)),
    (Pos: (X:  1.0; Y:  1.0; Z:  1.0); Color: (R: 1.0; G: 0.5; B: 0.0; A: 1.0)),
    (Pos: (X:  1.0; Y: -1.0; Z:  1.0); Color: (R: 1.0; G: 0.5; B: 0.0; A: 1.0)),
    (Pos: (X: -1.0; Y: -1.0; Z: -1.0); Color: (R: 0.0; G: 0.5; B: 1.0; A: 1.0)),
    (Pos: (X: -1.0; Y: -1.0; Z:  1.0); Color: (R: 0.0; G: 0.5; B: 1.0; A: 1.0)),
    (Pos: (X:  1.0; Y: -1.0; Z:  1.0); Color: (R: 0.0; G: 0.5; B: 1.0; A: 1.0)),
    (Pos: (X:  1.0; Y: -1.0; Z: -1.0); Color: (R: 0.0; G: 0.5; B: 1.0; A: 1.0)),
    (Pos: (X: -1.0; Y:  1.0; Z: -1.0); Color: (R: 1.0; G: 0.0; B: 0.5; A: 1.0)),
    (Pos: (X: -1.0; Y:  1.0; Z:  1.0); Color: (R: 1.0; G: 0.0; B: 0.5; A: 1.0)),
    (Pos: (X:  1.0; Y:  1.0; Z:  1.0); Color: (R: 1.0; G: 0.0; B: 0.5; A: 1.0)),
    (Pos: (X:  1.0; Y:  1.0; Z: -1.0); Color: (R: 1.0; G: 0.0; B: 0.5; A: 1.0)));

const
  { Index buffer for the cube }
  INDICES: array [0..35] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20);

{ TVertexPullApp }

procedure TVertexPullApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Vertex Pull';
end;

procedure TVertexPullApp.Init;
begin
  inherited;
  { If storage buffers are not supported on this platform, render a red screen
    and error message via sokol-debugtext }
  if (not (TFeature.Compute in TGfx.Features)) then
  begin
    var DbgTextDesc := TDbgTextDesc.Create;
    DbgTextDesc.UseDelphiMemoryManager := True;
    DbgTextDesc.Logger := DbgTextDesc.DefaultLogger;
    DbgTextDesc.Fonts[0] := TDbgTextFont.CPC;
    TDbgText.Setup(DbgTextDesc);
    Exit;
  end;

  { A storage buffer with the cube vertex data }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Usage.StorageBuffer := True;
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'CubeVertices';
  var SBuf := TBuffer.Create(BufferDesc);

  { An index buffer with the cube indices }
  BufferDesc.Init;
  BufferDesc.Usage.IndexBuffer := True;
  BufferDesc.Data := TRange.Create(INDICES);
  BufferDesc.TraceLabel := 'CubeIndices';
  var IBuf := TBuffer.Create(BufferDesc);

  { A pipeline object. Note that there is no vertex layout }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(VertexpullShaderDesc);
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.TraceLabel := 'CubePipeline';
  FPip := TPipeline.Create(PipDesc);

  { Resource bindings. Note that there is no vertex buffer binding }
  FBind.IndexBuffer := IBuf;

  var ViewDesc := TViewDesc.Create;
  ViewDesc.StorageBuffer.Buffer := SBuf;
  ViewDesc.StorageBuffer.Offset := 0;
  ViewDesc.TraceLabel := 'CubeVerticesView';
  FBind.Views[VIEW_SSBO] := TView.Create(ViewDesc);

  { Define a clear color }
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0.75, 0.5, 0.25, 1);
end;

procedure TVertexPullApp.Frame;
begin
  if (not (TFeature.Compute in TGfx.Features)) then
  begin
    DrawFallback;
    Exit;
  end;

  var T: Single := FrameDuration * 60;
  FRX := FRX + (1 * T);
  FRY := FRY + (2 * T);

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

procedure TVertexPullApp.Cleanup;
begin
  if (not (TFeature.Compute in TGfx.Features)) then
    TDbgText.Shutdown;
  inherited;
end;

function TVertexPullApp.ComputeVSParams: TVSParams;
begin
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), W / H, 0.01, 10.0);
  View.InitLookAtRH(Vector3(0, 1.5, 4), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  var RXM, RYM: TMatrix4;
  RXM.InitRotationX(Radians(FRX));
  RYM.InitRotationY(Radians(FRY));
  var Model := RXM * RYM;
  Result.MVP := ViewProj * Model;
end;

procedure TVertexPullApp.DrawFallback;
begin
  TDbgText.Canvas(FramebufferWidth * 0.5, FramebufferHeight * 0.5);
  TDbgText.Pos(1, 1);
  TDbgText.Write('STORAGE BUFFERS NOT SUPPORTED');

  var Pass := TPass.Create;
  Pass.Action.Colors[0].Init(TLoadAction.Clear, 1, 0, 0, 1);
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);
  TDbgText.Draw;
  TGfx.EndPass;
  TGfx.Commit;
end;

end.

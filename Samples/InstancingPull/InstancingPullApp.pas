unit InstancingPullApp;
{ Same as Instancing sample, but pull both vertex and instance data from
  storage buffers. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  InstancingPullShader;

type
  TInstancingPullApp = class(TSampleApp)
  private const
    MAX_PARTICLES                   = 512 * 1024;
    NUM_PARTICLES_EMITTED_PER_FRAME = 10;
  private
    FPassAction: TPassAction;
    FInstBuf: TBuffer;
    FPip: TPipeline;
    FBind: TBindings;
    FRY: Single;
    FCurNumParticles: Integer;
    FInst: array [0..MAX_PARTICLES - 1] of TSBInstance;
    FVel: array [0..MAX_PARTICLES - 1] of TVector3;
    FX: UInt32;
  private
    function XorShift32: UInt32;
    procedure DrawFallback;
    procedure EmitParticles;
    procedure UpdateParticles(const AFrameTime: Single);
    function ComputeVSParams(const AFrameTime: Single): TVSParams;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue,
  Neslib.Sokol.DebugText;

const
  R = 0.05;
  VERTICES: array [0..5] of TSBVertex = (
    (Pos: (X: 0.0; Y:  -R; Z: 0.0); Color: (R: 1.0; G: 0.0; B: 0.0; A: 1.0)),
    (Pos: (X:   R; Y: 0.0; Z:   R); Color: (R: 0.0; G: 1.0; B: 0.0; A: 1.0)),
    (Pos: (X:   R; Y: 0.0; Z:  -R); Color: (R: 0.0; G: 0.0; B: 1.0; A: 1.0)),
    (Pos: (X:  -R; Y: 0.0; Z:  -R); Color: (R: 1.0; G: 1.0; B: 0.0; A: 1.0)),
    (Pos: (X:  -R; Y: 0.0; Z:   R); Color: (R: 0.0; G: 1.0; B: 1.0; A: 1.0)),
    (Pos: (X: 0.0; Y:   R; Z: 0.0); Color: (R: 1.0; G: 0.0; B: 1.0; A: 1.0)));

const
  INDICES: array [0..23] of UInt16 = (
    0, 1, 2,    0, 2, 3,    0, 3, 4,    0, 4, 1,
    5, 1, 2,    5, 2, 3,    5, 3, 4,    5, 4, 1);

{ TInstancingPullApp }

procedure TInstancingPullApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Instancing - Pull';
end;

procedure TInstancingPullApp.Init;
begin
  inherited;
  FX := $12345678;

  if (not (TFeature.Compute in TGfx.Features)) then
  begin
    { Storage buffers are not supported on the current backend?
      In this case a red screen and an error message is rendered. }
    var DbgTextDesc := TDbgTextDesc.Create;
    DbgTextDesc.Fonts[0] := TDbgTextFont.CPC;
    TDbgText.Setup(DbgTextDesc);
    Exit;
  end;

  { A pass action for the default render pass }
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0, 0.1, 0.2, 1);

  { A storage buffer and view for the static geometry }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Usage.StorageBuffer := True;
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'GeometryVertices';
  var SBuf := TBuffer.Create(BufferDesc);

  var ViewDesc := TViewDesc.Create;
  ViewDesc.StorageBuffer.Buffer := SBuf;
  ViewDesc.TraceLabel := 'GeometryVerticesView';
  FBind.Views[VIEW_VERTICES] := TView.Create(ViewDesc);

  { An index buffer for the static geometry }
  BufferDesc.Init;
  BufferDesc.Usage.IndexBuffer := True;
  BufferDesc.Data := TRange.Create(INDICES);
  BufferDesc.TraceLabel := 'GeometryIndices';
  FBind.IndexBuffer := TBuffer.Create(BufferDesc);

  { A dynamic storage buffer for the per-instance data }
  BufferDesc.Init;
  BufferDesc.Usage.StorageBuffer := True;
  BufferDesc.Usage.StreamUpdate := True;
  BufferDesc.Size := MAX_PARTICLES * SizeOf(TSBInstance);
  BufferDesc.TraceLabel := 'InstanceData';
  FInstBuf := TBuffer.Create(BufferDesc);

  ViewDesc.Init;
  ViewDesc.StorageBuffer.Buffer := FInstBuf;
  ViewDesc.TraceLabel := 'InstanceDataView';
  FBind.Views[VIEW_INSTANCES] := TView.Create(ViewDesc);

  { A shader and pipeline object, note the lack of a vertex layout definition }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(InstancingShaderDesc);
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.TraceLabel := 'InstancingPipeline';
  FPip := TPipeline.Create(PipDesc);
end;

procedure TInstancingPullApp.Frame;
begin
  if (not (TFeature.Compute in TGfx.Features)) then
  begin
    DrawFallback;
    Exit;
  end;

  var FrameTime: Single := FrameDuration;

  { Emit new particles, and update particle positions }
  EmitParticles;
  UpdateParticles(FrameTime);

  { Update instance data storage buffer }
  FInstBuf.Update(TRange.Create(@FInst, FCurNumParticles * SizeOf(TSBInstance)));

  { Compute model-view-projection matrix }
  var VSParams := ComputeVSParams(FrameTime);

  { And draw }
  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyBindings(FBind);
  TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(0, 24, FCurNumParticles);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TInstancingPullApp.Cleanup;
begin
  inherited;
  if (not (TFeature.Compute in TGfx.Features)) then
    TDbgText.Shutdown;
end;

function TInstancingPullApp.XorShift32: UInt32;
begin
  var X := FX;
  X := X xor (X shl 13);
  X := X xor (X shr 17);
  X := X xor (X shl 5);
  FX := X;
  Result := X;
end;

procedure TInstancingPullApp.DrawFallback;
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

procedure TInstancingPullApp.EmitParticles;
begin
  for var I := 0 to NUM_PARTICLES_EMITTED_PER_FRAME - 1 do
  begin
    if (FCurNumParticles < MAX_PARTICLES) then
    begin
      FInst[FCurNumParticles].Pos.Init;
      FVel[FCurNumParticles].Init(
        ((XorShift32 and $7FFF) / $7FFF) - 0.5,
        ((XorShift32 and $7FFF) / $7FFF) * 0.5 + 2,
        ((XorShift32 and $7FFF) / $7FFF) - 0.5);
      Inc(FCurNumParticles);
    end
    else
      Break;
  end;
end;

procedure TInstancingPullApp.UpdateParticles(const AFrameTime: Single);
begin
  for var I := 0 to FCurNumParticles - 1 do
  begin
    FVel[I].Y := FVel[I].Y - AFrameTime;
    FInst[I].Pos := FInst[I].Pos + (FVel[I] * AFrameTime);

    { Bounce back from "ground" }
    if (FInst[I].Pos.Y < -2) then
    begin
      FInst[I].Pos.Y := -1.8;
      FVel[I].Y := -FVel[I].Y;
      FVel[I] := FVel[I] * 0.8;
    end;
  end;
end;

function TInstancingPullApp.ComputeVSParams(
  const AFrameTime: Single): TVSParams;
begin
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var Proj, View, Rotate: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), W / H, 0.01, 50.0);
  View.InitLookAtRH(Vector3(0, 1.5, 8), TVector3.Zero, TVector3.UnitY);
  var ViewProj := Proj * View;
  FRY := FRY + (60 * AFrameTime);
  Rotate.InitRotationY(Radians(FRY));
  Result.MVP := ViewProj * Rotate;
end;

end.

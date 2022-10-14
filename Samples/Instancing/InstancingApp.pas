unit InstancingApp;
{ Demonstrate simple hardware-instancing using a static geometry buffer and a
  dynamic instance-data buffer. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp;

type
  TInstancingApp = class(TSampleApp)
  private const
    MAX_PARTICLES                   = 512 * 1024;
    NUM_PARTICLES_EMITTED_PER_FRAME = 10;
  private
    FPassAction: TPassAction;
    FShader: TShader;
    FPip: TPipeline;
    FBind: TBindings;
    FRY: Single;
    FCurNumParticles: Integer;
    FPos: array [0..MAX_PARTICLES - 1] of TVector3;
    FVel: array [0..MAX_PARTICLES - 1] of TVector3;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api,
  InstancingShader;

const
  { Vertex buffer for static geometry.
    Goes into vertex-buffer-slot 0. }
  R = 0.05;
  VERTICES: array [0..41] of Single = (
  { Positions            Colors }
     0.0,   -R, 0.0,     1.0, 0.0, 0.0, 1.0,
       R,  0.0,   R,     0.0, 1.0, 0.0, 1.0,
       R,  0.0,  -R,     0.0, 0.0, 1.0, 1.0,
      -R,  0.0,  -R,     1.0, 1.0, 0.0, 1.0,
      -R,  0.0,   R,     0.0, 1.0, 1.0, 1.0,
     0.0,    R, 0.0,     1.0, 0.0, 1.0, 1.0);

const
  { Index buffer for static geometry }
  INDICES: array [0..23] of UInt16 = (
    0, 1, 2,    0, 2, 3,    0, 3, 4,    0, 4, 1,
    5, 1, 2,    5, 2, 3,    5, 3, 4,    5, 4, 1);

{ TInstancingApp }

procedure TInstancingApp.Cleanup;
begin
  FPip.Free;
  FShader.Free;
  FBind.VertexBuffers[0].Free;
  FBind.VertexBuffers[1].Free;
  FBind.IndexBuffer.Free;
  inherited;
end;

procedure TInstancingApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Instancing';
end;

procedure TInstancingApp.Frame;
begin
  var FrameTime: Single := FrameDuration;

  { Emit new particles }
  for var I := 0 to NUM_PARTICLES_EMITTED_PER_FRAME - 1 do
  begin
    if (FCurNumParticles < MAX_PARTICLES) then
    begin
      FPos[FCurNumParticles].Init;
      FVel[FCurNumParticles].Init(Random() - 0.5, (Random() * 0.5) + 2, Random() - 0.5);
      Inc(FCurNumParticles);
    end
    else
      Break;
  end;

  { Update particle positions }
  for var I := 0 to FCurNumParticles - 1 do
  begin
    FVel[I].Y := FVel[I].Y - FrameTime;
    FPos[I] := FPos[I] + (FVel[I] * FrameTime);

    { Bounce back from "ground" }
    if (FPos[I].Y < -2) then
    begin
      FPos[I].Y := -1.8;
      FVel[I].Y := -FVel[I].Y;
      FVel[I] := FVel[I] * 0.8;
    end;
  end;

  { Update instance data }
  FBind.VertexBuffers[1].Update(TRange.Create(@FPos[0], FCurNumParticles * SizeOf(TVector3)));

  { Model-view-projection matrix }
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var Proj, View, Rotate: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), H / W, 0.01, 50.0, True);
  View.InitLookAtRH(Vector3(0, 1.5, 12), TVector3.Zero, Vector3(0, 1, 0));
  var ViewProj := Proj * View;
  FRY := FRY + (60 * FrameTime);
  Rotate.InitRotationY(Radians(FRY));
  var VSParams: TVSParams;
  VSParams.MVP := ViewProj * Rotate;

  { And draw }
  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyBindings(FBind);
  TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(0, 24, FCurNumParticles);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TInstancingApp.Init;
begin
  inherited;
  { A pass action for the default render pass }
  FPassAction.Colors[0].Init(TAction.Clear, 0, 0, 0, 1);

  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'GeometryVertices';
  FBind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.BufferType := TBufferType.IndexBuffer;
  BufferDesc.Data := TRange.Create(INDICES);
  BufferDesc.TraceLabel := 'GeometryIndices';
  FBind.IndexBuffer := TBuffer.Create(BufferDesc);

  { Empty, dynamic instance-data vertex buffer.
    Goes into vertex-buffer-slot 1 }
  BufferDesc.Init;
  BufferDesc.Size := MAX_PARTICLES * SizeOf(TVector3);
  BufferDesc.Usage := TUsage.Stream;
  BufferDesc.TraceLabel := 'InstanceData';
  FBind.VertexBuffers[1] := TBuffer.Create(BufferDesc);

  FShader := TShader.Create(InstancingShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  { Vertex buffer at slot 1 must step per instance }
  PipDesc.Layout.Buffers[1].StepFunc := TVertexStep.PerInstance;
  PipDesc.Layout.Attrs[ATTR_VS_POS].Init(0, 0, TVertexFormat.Float3);
  PipDesc.Layout.Attrs[ATTR_VS_COLOR0].Init(0, 0, TVertexFormat.Float4);
  PipDesc.Layout.Attrs[ATTR_VS_INST_POS].Init(1, 0, TVertexFormat.Float3);
  PipDesc.Shader := FShader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.TraceLabel := 'InstancingPipeline';
  FPip := TPipeline.Create(PipDesc);
end;

end.

unit InstancingComputeApp;
{ Same as Instancing and InstancingPull samples, but compute the particle
  positions in a compute shader. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  InstancingComputeShader;

type
  TInstancingComputeApp = class(TSampleApp)
  private const
    MAX_PARTICLES                   = 512 * 1024;
    NUM_PARTICLES_EMITTED_PER_FRAME = 10;
  private type
    TCompute = record
    public
      SBufView: TView;
      Pip: TPipeline;
    end;
  private type
    TDisplay = record
    public
      VBuf: TBuffer;
      IBuf: TBuffer;
      Pip: TPipeline;
      PassAction: TPassAction;
    end;
  private
    FNumParticles: Integer;
    FRY: Single;
    FBuf: TBuffer;
    FCompute: TCompute;
    FDisplay: TDisplay;
  private
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
  Neslib.Sokol.Glue;

const
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
  INDICES: array [0..23] of UInt16 = (
    0, 1, 2,    0, 2, 3,    0, 3, 4,    0, 4, 1,
    5, 1, 2,    5, 2, 3,    5, 3, 4,    5, 4, 1);

{ TInstancingComputeApp }

procedure TInstancingComputeApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Instancing - Compute';
end;

procedure TInstancingComputeApp.Init;
begin
  inherited;
  FDisplay.PassAction.Colors[0].Init(TLoadAction.Clear, 0, 0.2, 0.1, 1);

  { Create an uninitialized storage buffer for the particle state. This will be
    initialized and updated by compute shaders and then used as vertex buffer to
    provide per-instance data }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Size := MAX_PARTICLES * SizeOf(TParticle);
  BufferDesc.Usage.VertexBuffer := True;
  BufferDesc.Usage.StorageBuffer := True;
  BufferDesc.TraceLabel := 'ParticleBuffer';
  FBuf := TBuffer.Create(BufferDesc);

  { Create a storage-buffer-view on the buffer }
  var ViewDesc := TViewDesc.Create;
  ViewDesc.StorageBuffer.Buffer := FBuf;
  ViewDesc.TraceLabel := 'ParticleBufferView';
  FCompute.SBufView := TView.Create(ViewDesc);

  { A compute shader and pipeline object for updating particle positions }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Compute := True;
  PipDesc.Shader := TShader.Create(UpdateShaderDesc);
  PipDesc.TraceLabel := 'UpdatePipeline';
  FCompute.Pip := TPipeline.Create(PipDesc);

  { Vertex and index buffer for the particle geometry }
  BufferDesc.Init;
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'GeometryVBuf';
  FDisplay.VBuf := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.Usage.IndexBuffer := True;
  BufferDesc.Data := TRange.Create(INDICES);
  BufferDesc.TraceLabel := 'GeometryIBuf';
  FDisplay.IBuf := TBuffer.Create(BufferDesc);

  { Shader and pipeline for rendering the particles. This uses the
    compute-updated storage buffer to provide the particle positions }
  PipDesc.Init;
  PipDesc.Shader := TShader.Create(DisplayShaderDesc);
  PipDesc.Layout.Buffers[1].StepFunc := TVertexStep.PerInstance;
  PipDesc.Layout.Buffers[1].Stride := SizeOf(TParticle);
  PipDesc.Layout.Attrs[ATTR_DISPLAY_POS].Format := TVertexFormat.Float3; // Position
  PipDesc.Layout.Attrs[ATTR_DISPLAY_COLOR0].Format := TVertexFormat.Float4; // Color
  PipDesc.Layout.Attrs[ATTR_DISPLAY_INST_POS].Format := TVertexFormat.Float4; // Particle pos
  PipDesc.Layout.Attrs[ATTR_DISPLAY_INST_POS].BufferIndex := 1;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.TraceLabel := 'RenderPipeline';
  FDisplay.Pip := TPipeline.Create(PipDesc);

  { One-time init of particle velocities in a compute shader }
  PipDesc.Init;
  PipDesc.Compute := True;
  PipDesc.Shader := TShader.Create(InitShaderDesc);
  var Pip := TPipeline.Create(PipDesc);

  var Pass := TPass.Create;
  Pass.Compute := True;
  TGfx.BeginPass(Pass);
  TGfx.ApplyPipeline(Pip);

  var Bindings := TBindings.Create;
  Bindings.Views[VIEW_CS_SSBO] := FCompute.SBufView;
  TGfx.ApplyBindings(Bindings);

  TGfx.Dispatch(MAX_PARTICLES div 64, 1, 1);
  TGfx.EndPass;
  Pip.Free;
end;

procedure TInstancingComputeApp.Frame;
begin
  Inc(FNumParticles, NUM_PARTICLES_EMITTED_PER_FRAME);
  if (FNumParticles > MAX_PARTICLES) then
    FNumParticles := MAX_PARTICLES;

  var DT: Single := FrameDuration;

  { Compute pass to update particle positions }
  var CSParams: TCSParams;
  CSParams.DT := DT;
  CSParams.NumParticles := FNumParticles;

  var Pass := TPass.Create;
  Pass.Compute := True;
  Pass.TraceLabel := 'ComputePass';
  TGfx.BeginPass(Pass);
  TGfx.ApplyPipeline(FCompute.Pip);

  var Bindings := TBindings.Create;
  Bindings.Views[VIEW_CS_SSBO] := FCompute.SBufView;
  TGfx.ApplyBindings(Bindings);

  TGfx.ApplyUniforms(UB_CS_PARAMS, TRange.Create(CSParams));
  TGfx.Dispatch((FNumParticles + 63) div 64, 1, 1);
  TGfx.EndPass;

  { Render pass to render the particles via hardware instancing. The
    per-instance positions are provided by the storage buffer bound as vertex
    buffer at slot 1 }
  var VSParams := ComputeVSParams(DT);
  Pass.Init;
  Pass.Action^ := FDisplay.PassAction;
  Pass.Swapchain.FromAppSwapchain;
  Pass.TraceLabel := 'RenderPass';
  TGfx.BeginPass(Pass);
  TGfx.ApplyPipeline(FDisplay.Pip);

  Bindings.Init;
  Bindings.VertexBuffers[0] := FDisplay.VBuf;
  Bindings.VertexBuffers[1] := FBuf;
  Bindings.IndexBuffer := FDisplay.IBuf;
  TGfx.ApplyBindings(Bindings);

  TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(0, 24, FNumParticles);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TInstancingComputeApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

function TInstancingComputeApp.ComputeVSParams(
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

unit ComputeBoidsApp;
{ A port of the WebGPU compute-boids sample
  (https://webgpu.github.io/webgpu-samples/?sample=computeBoids) }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  ComputeBoidsShader;

const
  MAX_PARTICLES = 10000;

type
  TComputeBoidsApp = class(TSampleApp)
  private type
    TCompute = record
    public
      Buf: array [0..1] of TBuffer;
      View: array [0..1] of TView;
      Pip: TPipeline;
    end;
  private type
    TDisplay = record
    public
      Pip: TPipeline;
      PassAction: TPassAction;
    end;
  private
    FSimParams: TSimParams;
    FCompute: TCompute;
    FDisplay: TDisplay;
    FX: UInt32;
  private
    function XorShift32: UInt32; inline;
    function Rnd: Single; inline;
  protected
    class function HasImGui: Boolean; override;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure DrawImGui; override;
  end;

implementation

uses
  Neslib.ImGui,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue;

{ TComputeBoidsApp }

procedure TComputeBoidsApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.DepthFormat := TAppPixelFormat.None;
  AConfig.WindowTitle := 'Compute Boids';
end;

procedure TComputeBoidsApp.Init;
begin
  inherited;
  FX := $12345678;

  FSimParams.DT := 0.04;
  FSimParams.Rule1Distance := 0.1;
  FSimParams.Rule2Distance := 0.025;
  FSimParams.Rule3Distance := 0.025;
  FSimParams.Rule1Scale := 0.02;
  FSimParams.Rule2Scale := 0.05;
  FSimParams.Rule3Scale := 0.005;
  FSimParams.NumParticles := 1500;

  FDisplay.PassAction.Colors[0].Init(TLoadAction.Clear, 0, 0.15, 0.3, 1);

  { Two storage buffers and views with pre-initialized positions and velocities }
  var InitialData: TArray<TParticle>;
  SetLength(InitialData, MAX_PARTICLES);
  for var I := 0 to MAX_PARTICLES - 1 do
  begin
    InitialData[I].Pos.Init(Rnd, Rnd);
    InitialData[I].Vel.Init(Rnd * 0.1, Rnd * 0.1);
  end;

  for var I := 0 to 1 do
  begin
    var BufferDesc := TBufferDesc.Create;
    BufferDesc.Usage.StorageBuffer := True;
    BufferDesc.Data := TRange.Create(Pointer(InitialData), MAX_PARTICLES * SizeOf(TParticle));
    if (I = 0) then
      BufferDesc.TraceLabel := 'ParticleBuffer0'
    else
      BufferDesc.TraceLabel := 'ParticleBuffer1';
    FCompute.Buf[I] := TBuffer.Create(BufferDesc);

    var ViewDesc := TViewDesc.Create;
    ViewDesc.StorageBuffer.Buffer := FCompute.Buf[I];
    if (I = 0) then
      ViewDesc.TraceLabel := 'ParticleView0'
    else
      ViewDesc.TraceLabel := 'ParticleView1';
    FCompute.View[I] := TView.Create(ViewDesc);
  end;
  InitialData := nil; // No longer needed

  { Compute shader and pipeline }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Compute := True;
  PipDesc.Shader := TShader.Create(ComputeShaderDesc);
  PipDesc.TraceLabel := 'ComputePipeline';
  FCompute.Pip := TPipeline.Create(PipDesc);

  { A render pipeline and shader. Note that vertices for the boids will be
    synthesized by the vertex shader, so there's no separate vertex buffer.
    We also don't need any non-default render state since the boids are just 2D
    triangles }
  PipDesc.Init;
  PipDesc.Shader := TShader.Create(DisplayShaderDesc);
  PipDesc.TraceLabel := 'RenderPipeline';
  FDisplay.Pip := TPipeline.Create(PipDesc);
end;

procedure TComputeBoidsApp.Frame;
begin
  { Input- and output- storage-buffers for this frame }
  var Index: Integer := FrameCount and 1;
  var InView := FCompute.View[Index];
  var OutView := FCompute.View[1 - Index];

  { Compute pass to update boid positions and velocities. This works with
    buffer-ping-ponging, since the compute shader needs random access on the
    input parameters }
  var Pass := TPass.Create;
  Pass.Compute := True;
  Pass.TraceLabel := 'ComputePass';
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FCompute.Pip);

  var Bindings := TBindings.Create;
  Bindings.Views[VIEW_CS_SSBO_IN] := InView;
  Bindings.Views[VIEW_CS_SSBO_OUT] := OutView;
  TGfx.ApplyBindings(Bindings);

  TGfx.ApplyUniforms(UB_SIM_PARAMS, TRange.Create(FSimParams));
  TGfx.Dispatch((FSimParams.NumParticles + 63) div 64, 1, 1);
  TGfx.EndPass;

  { Render pass for rendering the boids, instanced by the current output storage
    buffer }
  Pass.Init;
  Pass.Action^ := FDisplay.PassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FDisplay.Pip);

  Bindings.Init;
  Bindings.Views[VIEW_VS_SSBO] := OutView;
  TGfx.ApplyBindings(Bindings);

  TGfx.Draw(0, 3, FSimParams.NumParticles);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TComputeBoidsApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

class function TComputeBoidsApp.HasImGui: Boolean;
begin
  Result := True;
end;

function TComputeBoidsApp.XorShift32: UInt32;
begin
  var X := FX;
  X := X xor (X shl 13);
  X := X xor (X shr 17);
  X := X xor (X shl 5);
  FX := X;
  Result := X;
end;

function TComputeBoidsApp.Rnd: Single;
{ Return a pseudo-random float between -1.0f and +1.0 }
begin
  Result := (((XorShift32 and $FFFF) / $FFFF) - 0.5) * 2;
end;

procedure TComputeBoidsApp.DrawImGui;
begin
  ImGui.SetNextWindowBgAlpha(0.8);
  ImGui.SetNextWindowPos(Vector2(10, 30), TImGuiCond.Once);

  var Flags := TImGuiWindowFlags.NoDecoration + [TImGuiWindowFlag.AlwaysAutoResize,
    TImGuiWindowFlag.NoBringToFrontOnFocus, TImGuiWindowFlag.NoFocusOnAppearing];
  if (ImGui.Begin('Controls', nil, Flags)) then
  begin
    ImGui.SliderFloat('Delta T', @FSimParams.DT, 0.01, 0.1);
    ImGui.SliderFloat('Rule1 Distance', @FSimParams.Rule1Distance, 0.0, 0.2);
    ImGui.SliderFloat('Rule2 Distance', @FSimParams.Rule2Distance, 0.0, 0.1);
    ImGui.SliderFloat('Rule3 Distance', @FSimParams.Rule3Distance, 0.0, 0.1);
    ImGui.SliderFloat('Rule1 Scale', @FSimParams.Rule1Scale, 0.0, 0.1);
    ImGui.SliderFloat('Rule2 Scale', @FSimParams.Rule2Scale, 0.0, 0.1);
    ImGui.SliderFloat('Rule3 Scale', @FSimParams.Rule3Scale, 0.0, 0.1);
    ImGui.SliderInt('Num Boids', @FSimParams.NumParticles, 0, MAX_PARTICLES);
  end;
  ImGui.End;
end;

end.

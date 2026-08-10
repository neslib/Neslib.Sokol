unit DrawCallPerfApp;

interface

uses
  System.Math,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  DrawCallPerfShader,
  SampleApp;

const
  NUM_IMAGES         = 3;
  IMG_WIDTH          = 8;
  IMG_HEIGHT         = 8;
  MAX_INSTANCES      = 100000;
  MAX_BIND_FREQUENCY = 1000;

type
  TDrawCallPerfApp = class(TSampleApp)
  private type
    TStats = record
    public
      NumUniformUpdates: Integer;
      NumBindingUpdates: Integer;
      NumDrawCalls: Integer;
    end;
  private
    FPassAction: TPassAction;
    FImg: array [0..NUM_IMAGES - 1] of TImage;
    FView: array [0..NUM_IMAGES - 1] of TView;
    FPip: TPipeline;
    FBind: TBindings;
    FNumInstances: Integer;
    FBindFrequency: Integer;
    FAngle: Single;
    FLastTime: Int64;
    FStats: TStats;
    FBackend: String;
    FPositions: array [0..MAX_INSTANCES - 1] of TVSPerInstance;
    FX: UInt32;
  private
    function XorShift32: UInt32;
    function RandPos: TVector4;
    function ComputeViewProj: TMatrix4;
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
  Neslib.Sokol.Glue,
  Neslib.Sokol.Time;

const
  VERTICES: array [0..143] of Single = (
    -1.0, -1.0, -1.0,   0.0, 0.0,  1.0,
     1.0, -1.0, -1.0,   1.0, 0.0,  1.0,
     1.0,  1.0, -1.0,   1.0, 1.0,  1.0,
    -1.0,  1.0, -1.0,   0.0, 1.0,  1.0,

    -1.0, -1.0,  1.0,   0.0, 0.0,  0.9,
     1.0, -1.0,  1.0,   1.0, 0.0,  0.9,
     1.0,  1.0,  1.0,   1.0, 1.0,  0.9,
    -1.0,  1.0,  1.0,   0.0, 1.0,  0.9,

    -1.0, -1.0, -1.0,   0.0, 0.0,  0.8,
    -1.0,  1.0, -1.0,   1.0, 0.0,  0.8,
    -1.0,  1.0,  1.0,   1.0, 1.0,  0.8,
    -1.0, -1.0,  1.0,   0.0, 1.0,  0.8,

    1.0, -1.0, -1.0,    0.0, 0.0,  0.7,
    1.0,  1.0, -1.0,    1.0, 0.0,  0.7,
    1.0,  1.0,  1.0,    1.0, 1.0,  0.7,
    1.0, -1.0,  1.0,    0.0, 1.0,  0.7,

    -1.0, -1.0, -1.0,   0.0, 0.0,  0.6,
    -1.0, -1.0,  1.0,   1.0, 0.0,  0.6,
     1.0, -1.0,  1.0,   1.0, 1.0,  0.6,
     1.0, -1.0, -1.0,   0.0, 1.0,  0.6,

    -1.0,  1.0, -1.0,   0.0, 0.0,  0.5,
    -1.0,  1.0,  1.0,   1.0, 0.0,  0.5,
     1.0,  1.0,  1.0,   1.0, 1.0,  0.5,
     1.0,  1.0, -1.0,   0.0, 1.0,  0.5);

const
  INDICES: array [0..35] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20);

{ TDrawCallPerfApp }

procedure TDrawCallPerfApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.WindowTitle := 'Draw Call Performance';
  AConfig.Width := 1024;
  AConfig.Height := 768;
  AConfig.SampleCount := 4;
end;

procedure TDrawCallPerfApp.Init;
var
  Pixels: array [0..IMG_HEIGHT - 1, 0..IMG_WIDTH - 1] of UInt32;
begin
  inherited;
  TTime.Setup;
  FX := $12345678;

  FPassAction.Colors[0].Init(TLoadAction.Clear, 0, 0.5, 0.75, 1);
  FNumInstances := 100;
  FBindFrequency := MAX_BIND_FREQUENCY;

  case TGfx.Backend of
    TBackend.GLCore: FBackend := 'GL-Core';
    TBackend.Gles3: FBackend := 'GL-ES3';
    TBackend.D3D11: FBackend := 'D3D11';
    TBackend.MetalIOS: FBackend := 'Metal iOS';
    TBackend.MetalMacOS: FBackend := 'Metal MacOS';
    TBackend.Vulkan: FBackend := 'Vulkan';
    TBackend.Dummy: FBackend := 'Dummy';
  else
    FBackend := '???';
  end;

  { Vertices and indices for a 2d quad }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  FBind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.Usage.IndexBuffer := True;
  BufferDesc.Data := TRange.Create(INDICES);
  FBind.IndexBuffer := TBuffer.Create(BufferDesc);

  { Three textures and a sampler }
  for var I := 0 to NUM_IMAGES - 1 do
  begin
    var Color: UInt32;
    case I of
      0: Color := $FF0000FF;
      1: Color := $FF00FF00;
    else Color := $FFFF0000;
    end;

    for var Y := 0 to IMG_HEIGHT - 1 do
      for var X := 0 to IMG_WIDTH - 1 do
        Pixels[Y, X] := Color;

    var ImgDesc := TImageDesc.Create;
    ImgDesc.Width := IMG_WIDTH;
    ImgDesc.Height := IMG_HEIGHT;
    ImgDesc.PixelFormat := TPixelFormat.Rgba8;
    ImgDesc.Data.MipLevels[0] := TRange.Create(Pixels);
    FImg[I] := TImage.Create(ImgDesc);

    var ViewDesc := TViewDesc.Create;
    ViewDesc.Texture.Image := FImg[I];
    FView[I] := TView.Create(ViewDesc);
  end;

  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Nearest;
  SamplerDesc.MagFilter := TFilter.Nearest;
  FBind.Samplers[SMP_SMP] := TSampler.Create(SamplerDesc);

  { A pipeline object }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Attrs[ATTR_DRAWCALLPERF_IN_POS].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_DRAWCALLPERF_IN_UV].Format := TVertexFormat.Float2;
  PipDesc.Layout.Attrs[ATTR_DRAWCALLPERF_IN_BRIGHT].Format := TVertexFormat.Float;
  PipDesc.Shader := TShader.Create(DrawcallperfShaderDesc);
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  FPip := TPipeline.Create(PipDesc);

  { Initialize a fixed array of random positions }
  for var I := 0 to MAX_INSTANCES - 1 do
    FPositions[I].WorldPos := RandPos;
end;

procedure TDrawCallPerfApp.Frame;
begin
  FNumInstances := EnsureRange(FNumInstances, 1, MAX_INSTANCES);

  { View-proj matrix for the frame }
  var VSPerFrame: TVSPerFrame;
  VSPerFrame.Viewproj := ComputeViewProj;

  FStats.NumUniformUpdates := 0;
  FStats.NumBindingUpdates := 0;
  FStats.NumDrawCalls := 0;

  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyUniforms(UB_VS_PER_FRAME, TRange.Create(VSPerFrame));
  Inc(FStats.NumUniformUpdates);

  FBind.Views[VIEW_TEX] := FView[0];
  TGfx.ApplyBindings(FBind);
  Inc(FStats.NumBindingUpdates);

  var CurBindCount := 0;
  var CurImg := 0;
  for var I := 0 to FNumInstances - 1 do
  begin
    Inc(CurBindCount);
    if (CurBindCount = FBindFrequency) then
    begin
      CurBindCount := 0;
      if (CurImg = NUM_IMAGES) then
        CurImg := 0;

      FBind.Views[VIEW_TEX] := FView[CurImg];
      Inc(CurImg);
      TGfx.ApplyBindings(FBind);
      Inc(FStats.NumBindingUpdates);
    end;

    TGfx.ApplyUniforms(UB_VS_PER_INSTANCE, TRange.Create(FPositions[I]));
    Inc(FStats.NumUniformUpdates);

    TGfx.Draw(0, 36);
    Inc(FStats.NumDrawCalls);
  end;

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TDrawCallPerfApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

function TDrawCallPerfApp.XorShift32: UInt32;
begin
  var X := FX;
  X := X xor (X shl 13);
  X := X xor (X shr 17);
  X := X xor (X shl 5);
  FX := X;
  Result := X;
end;

function TDrawCallPerfApp.RandPos: TVector4;
begin
  Result.X := ((XorShift32 and $FFFF) / $10000) - 0.5;
  Result.Y := ((XorShift32 and $FFFF) / $10000) - 0.5;
  Result.Z := ((XorShift32 and $FFFF) / $10000) - 0.5;
  Result.W := 0;
  Result.SetNormalized;
end;

function TDrawCallPerfApp.ComputeViewProj: TMatrix4;
const
  DIST = 4.5;
begin
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  FAngle := FMod(FAngle + 0.01, 360);

  var S, C: Single;
  FastSinCos(FAngle, S, C);
  var Eye := Vector3(S * DIST, 1.5, C * DIST);
  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), W / H, 0.01, 10.0);
  View.InitLookAtRH(Eye, TVector3.Zero, TVector3.UnitY);
  Result := Proj * View;
end;

class function TDrawCallPerfApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TDrawCallPerfApp.DrawImGui;
begin
  var FrameMeasuredTime: Double := TTime.ToSeconds(TTime.LapTime(FLastTime));
  ImGui.SetNextWindowPos(Vector2(20, 20), TImGuiCond.Once);
  ImGui.SetNextWindowSize(Vector2(600, 200), TImGuiCond.Once);
  if (ImGui.Begin('Controls', nil, [TImGuiWindowFlag.NoResize])) then
  begin
    ImGui.Text('Each cube/instance is 1 16-byte uniform update and 1 draw call.');
    ImGui.Text('DC/texture is the number of adjacent draw calls with the same texture binding.');
    ImGui.SliderInt('Num instances', @FNumInstances, 100, MAX_INSTANCES, '%d',
      [TImGuiSliderFlag.Logarithmic]);
    ImGui.SliderInt('DC/texture', @FBindFrequency, 1, MAX_BIND_FREQUENCY, '%d',
      [TImGuiSliderFlag.Logarithmic]);
    ImGui.Text(ImGui.Format('Backend: %s', [FBackend]));
    ImGui.Text(ImGui.Format('Frame duration: %.4fms', [FrameMeasuredTime * 1000]));
    ImGui.Text(ImGui.Format('TGfx.ApplyBindings: %d', [FStats.NumBindingUpdates]));
    ImGui.Text(ImGui.Format('TGfx.ApplyUniforms: %d', [FStats.NumUniformUpdates]));
    ImGui.Text(ImGui.Format('TGfx.Draw: %d', [FStats.NumDrawCalls]));
  end;
  ImGui.End;
end;

end.

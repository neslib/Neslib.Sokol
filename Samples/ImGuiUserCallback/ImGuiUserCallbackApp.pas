unit ImGuiUserCallbackApp;
{ Demonstrate rendering inside an ImGui window with Neslib.Sokol.Gfx and
  Neslib.Sokol.GL using ImGui's UserCallback command. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.GL,
  Neslib.ImGui,
  SampleApp;

type
  TScene1 = record
  public
    RX: Single;
    RY: Single;
    PassAction: TPassAction;
    Shader: TShader;
    Pip: TPipeline;
    Bind: TBindings;
  public
    procedure Init;
    procedure Free;
    procedure Draw(const ACmd: PImDrawCmd);
  end;

type
  TScene2 = record
  public
    R0: Single;
    R1: Single;
    Pip: TGLPipeline;
  private
    class procedure DrawCube; static;
  public
    procedure Init;
    procedure Free;
    procedure Draw(const ACmd: PImDrawCmd);
  end;

type
  TImGuiUserCallbackApp = class(TSampleApp)
  private
    FDefaultPassAction: TPassAction;
    FScene1: TScene1;
    FScene2: TScene2;
  private
    class procedure DrawScene1(const AParentList: PImDrawList;
      const ACmd: PImDrawCmd); cdecl; static;
    class procedure DrawScene2(const AParentList: PImDrawList;
      const ACmd: PImDrawCmd); cdecl; static;
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
  Neslib.FastMath,
  Neslib.Sokol.Api,
  ImGuiUserCallbackShader;

{ TImGuiUserCallbackApp }

procedure TImGuiUserCallbackApp.Cleanup;
begin
  inherited;
  sglShutdown;
end;

procedure TImGuiUserCallbackApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 860;
  AConfig.Height := 440;
  AConfig.WindowTitle := 'ImGui User Callback';
end;

procedure TImGuiUserCallbackApp.DrawImGui;
begin
  ImGui.SetNextWindowPos(Vector2(20, 20), TImGuiCond.Once);
  ImGui.SetNextWindowSize(Vector2(800, 400), TImGuiCond.Once);
  if (ImGui.Begin('Dear ImGui')) then
  begin
    if (ImGui.BeginChild('sokol-gfx', Vector2(360, 360), True)) then
    begin
      var DrawList := ImGui.GetWindowDrawList;
      DrawList.AddCallback(DrawScene1, Self);
    end;
    ImGui.EndChild;

    ImGui.SameLine(0, 10);

    if (ImGui.BeginChild('sokol-gl', Vector2(360, 360), True)) then
    begin
      var DrawList := ImGui.GetWindowDrawList;
      DrawList.AddCallback(DrawScene2, Self);
    end;
    ImGui.EndChild;
  end;
  ImGui.End;
end;

class procedure TImGuiUserCallbackApp.DrawScene1(const AParentList: PImDrawList;
  const ACmd: PImDrawCmd);
begin
  Assert(TObject(ACmd.UserCallbackData) is TImGuiUserCallbackApp);
  TImGuiUserCallbackApp(ACmd.UserCallbackData).FScene1.Draw(ACmd);
end;

class procedure TImGuiUserCallbackApp.DrawScene2(const AParentList: PImDrawList;
  const ACmd: PImDrawCmd);
begin
  Assert(TObject(ACmd.UserCallbackData) is TImGuiUserCallbackApp);
  TImGuiUserCallbackApp(ACmd.UserCallbackData).FScene2.Draw(ACmd);
end;

procedure TImGuiUserCallbackApp.Frame;
begin
  TGfx.BeginDefaultPass(FDefaultPassAction, FramebufferWidth, FramebufferHeight);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

class function TImGuiUserCallbackApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TImGuiUserCallbackApp.Init;
begin
  inherited;
  var GLDesc := TGLDesc.Create;
  sglSetup(GLDesc);

  FDefaultPassAction.Colors[0].Init(TAction.Clear, 0, 0.5, 0.7, 1);
  FScene1.Init;
  FScene2.Init;
end;

{ TScene1 }

const
  { Vertices and indices for rendering a cube via Sokol Gfx }
  CUBE_VERTICES: array [0..167] of Single = (
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
  CUBE_INDICES: array [0..35] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20);

procedure TScene1.Draw(const ACmd: PImDrawCmd);
{ An ImGui draw callback to render directly with Sokol Gfx }
begin
  { First set the viewport rectangle to render in, same as the ImGui draw
    command's clip rect }
  var DpiScale := TApplication.Instance.DpiScale;
  var CX := Trunc(ACmd.ClipRect.Left * DpiScale);
  var CY := Trunc(ACmd.ClipRect.Top * DpiScale);
  var CW := Trunc(ACmd.ClipRect.Width * DpiScale);
  var CH := Trunc(ACmd.ClipRect.Height * DpiScale);
  TGfx.ApplyScissorRect(CX, CY, CW, CH, True);
  TGfx.ApplyViewport(CX, CY, Trunc(360 * DpiScale), Trunc(360 * DpiScale), True);

  { A model-view-proj matrix for the vertex shader }
  var T: Single := TApplication.Instance.FrameDuration * 60;
  var VSParams: TVSParams;
  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), 1, 0.01, 10);
  View.InitLookAtRH(Vector3(0, 1.5, 6), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  RX := RX + (1 * T);
  RY := RY + (2 * T);
  var RXM, RYM: TMatrix4;
  RXM.InitRotationX(Radians(RX));
  RYM.InitRotationY(Radians(RY));
  var Model := RXM * RYM;
  VSParams.Mvp := ViewProj * Model;

  { NOTE: we cannot start a separate render pass here since passes cannot be
    nested. So if we'd need to clear the color- or z-buffer we'd need to render
    a quad instead

    Another option is to render into a texture render target outside the ImGui
    user callback, and render this texture as quad inside the callback (or as a
    standard Image widget). This allows to perform render }
  TGfx.ApplyPipeline(Pip);
  TGfx.ApplyBindings(Bind);
  TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(0, 36);
end;

procedure TScene1.Free;
begin
  Shader.Free;
  Pip.Free;
  Bind.VertexBuffers[0].Free;
  Bind.IndexBuffer.Free;
end;

procedure TScene1.Init;
begin
  { Setup the Sokol Gfx resources needed for the first user draw callback }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(CUBE_VERTICES);
  BufferDesc.TraceLabel := 'CubeVertices';
  Bind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.BufferType := TBufferType.IndexBuffer;
  BufferDesc.Data := TRange.Create(CUBE_INDICES);
  BufferDesc.TraceLabel := 'CubeIndices';
  Bind.IndexBuffer := TBuffer.Create(BufferDesc);

  Shader := TShader.Create(SceneShaderDesc);
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Attrs[ATTR_VS_POSITION].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_VS_COLOR0].Format := TVertexFormat.Float4;
  PipDesc.Shader := Shader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.TraceLabel := 'CubePipeline';
  Pip := TPipeline.Create(PipDesc);
end;

{ TScene2 }

procedure TScene2.Draw(const ACmd: PImDrawCmd);
{ Another ImGui draw callback to render via Sokol GL }
begin
  var T: Single := TApplication.Instance.FrameDuration * 60;
  var DpiScale := TApplication.Instance.DpiScale;
  var CX := Trunc(ACmd.ClipRect.Left * DpiScale);
  var CY := Trunc(ACmd.ClipRect.Top * DpiScale);
  var CW := Trunc(ACmd.ClipRect.Width * DpiScale);
  var CH := Trunc(ACmd.ClipRect.Height * DpiScale);
  TGfx.ApplyScissorRect(CX, CY, CW, CH, True);
  TGfx.ApplyViewport(CX, CY, Trunc(360 * DpiScale), Trunc(360 * DpiScale), True);

  R0 := R0 + (1 * T);
  R1 := R1 + (2 * T);

  sglDefaults;
  sglLoadPipeline(Pip);

  sglMatrixModeProjection;
  sglPerspective(sglRad(45), 1, 0.1, 100);

  sglMatrixModeModelview;
  sglTranslate(0, 0, -12);
  sglRotate(sglRad(R0), 1, 0, 0);
  sglRotate(sglRad(R1), 0, 1, 0);
  DrawCube;
  sglPushMatrix;
    sglTranslate(0, 0, 3);
    sglScale(0.5, 0.5, 0.5);
    sglRotate(-2 * sglRad(R0), 1, 0, 0);
    sglRotate(-2 * sglRad(R1), 0, 1, 0);
    DrawCube;
    sglPushMatrix;
      sglTranslate(0, 0, 3);
      sglScale(0.5, 0.5, 0.5);
      sglRotate(-3 * sglRad(2 * R0), 1, 0, 0);
      sglRotate( 3 * sglRad(2 * R1), 0, 0, 1);
      DrawCube;
    sglPopMatrix;
  sglPopMatrix;

  { Render the Sokol GL command list. This is the only call which actually needs
    to happen here in the callback. Current downside is that only one such call
    must happen per frame }
  sglDraw;
end;

class procedure TScene2.DrawCube;
{ Helper function to draw a cube via Sokol GL }
begin
  sglBeginQuads;
  sglC3F(1.0, 0.0, 0.0);
    sglV3F_T2F(-1.0,  1.0, -1.0, -1.0,  1.0);
    sglV3F_T2F( 1.0,  1.0, -1.0,  1.0,  1.0);
    sglV3F_T2F( 1.0, -1.0, -1.0,  1.0, -1.0);
    sglV3F_T2F(-1.0, -1.0, -1.0, -1.0, -1.0);
  sglC3F(0.0, 1.0, 0.0);
    sglV3F_T2F(-1.0, -1.0,  1.0, -1.0,  1.0);
    sglV3F_T2F( 1.0, -1.0,  1.0,  1.0,  1.0);
    sglV3F_T2F( 1.0,  1.0,  1.0,  1.0, -1.0);
    sglV3F_T2F(-1.0,  1.0,  1.0, -1.0, -1.0);
  sglC3F(0.0, 0.0, 1.0);
    sglV3F_T2F(-1.0, -1.0,  1.0, -1.0,  1.0);
    sglV3F_T2F(-1.0,  1.0,  1.0,  1.0,  1.0);
    sglV3F_T2F(-1.0,  1.0, -1.0,  1.0, -1.0);
    sglV3F_T2F(-1.0, -1.0, -1.0, -1.0, -1.0);
  sglC3F(1.0, 0.5, 0.0);
    sglV3F_T2F(1.0, -1.0,  1.0, -1.0,   1.0);
    sglV3F_T2F(1.0, -1.0, -1.0,  1.0,   1.0);
    sglV3F_T2F(1.0,  1.0, -1.0,  1.0,  -1.0);
    sglV3F_T2F(1.0,  1.0,  1.0, -1.0,  -1.0);
  sglC3F(0.0, 0.5, 1.0);
    sglV3F_T2F( 1.0, -1.0, -1.0, -1.0,  1.0);
    sglV3F_T2F( 1.0, -1.0,  1.0,  1.0,  1.0);
    sglV3F_T2F(-1.0, -1.0,  1.0,  1.0, -1.0);
    sglV3F_T2F(-1.0, -1.0, -1.0, -1.0, -1.0);
  sglC3F(1.0, 0.0, 0.5);
    sglV3F_T2F(-1.0,  1.0, -1.0, -1.0,  1.0);
    sglV3F_T2F(-1.0,  1.0,  1.0,  1.0,  1.0);
    sglV3F_T2F( 1.0,  1.0,  1.0,  1.0, -1.0);
    sglV3F_T2F( 1.0,  1.0, -1.0, -1.0, -1.0);
  sglEnd;
end;

procedure TScene2.Free;
begin
  Pip.Free;
end;

procedure TScene2.Init;
begin
  { Setup a Sokol GL pipeline needed for the second user draw callback }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.CullMode := TCullMode.Back;
  Pip := TGLPipeline.Create(PipDesc);
end;

end.

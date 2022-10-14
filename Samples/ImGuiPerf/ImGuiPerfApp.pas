unit ImGuiPerfApp;
{ Test performance of the Neslib.Sokol.ImGui rendering backend with many
  windows. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Time,
  SampleApp;

const
  MAX_WINDOWS = 999;

type
  TImGuiPerfApp = class(TSampleApp)
  private
    FLastTime: Int64;
    FWindowCount: Integer;
    FMinRawFrameTime: Double;
    FMaxRawFrameTime: Double;
    FMinRoundedFrameTime: Double;
    FMaxRoundedFrameTime: Double;
    FCounter: Integer;
    FPassAction: TPassAction;
  private
    procedure ResetMinMaxFrameTimes;
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
  Neslib.ImGui;

{ TImGuiPerfApp }

procedure TImGuiPerfApp.Cleanup;
begin
  inherited;
end;

procedure TImGuiPerfApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.WindowTitle := 'ImGui Performance Test';
  AConfig.iOSKeyboardResizesCanvas := False;
  AConfig.EnableClipboard := True;
end;

procedure TImGuiPerfApp.DrawImGui;
begin
  var Width: Single := FramebufferWidth / DpiScale;
  var Height: Single := FramebufferHeight / DpiScale;
  var RawFrameTime: Double := TTime.ToSeconds(TTime.LapTime(FLastTime));
  var RoundedFrameTime := FrameDuration;

  if (RawFrameTime > 0) then
  begin
    FMinRawFrameTime := Min(FMinRawFrameTime, RawFrameTime);
    FMaxRawFrameTime := Max(FMaxRawFrameTime, RawFrameTime);
  end;

  if (RoundedFrameTime > 0) then
  begin
    FMinRoundedFrameTime := Min(FMinRoundedFrameTime, RoundedFrameTime);
    FMaxRoundedFrameTime := Max(FMaxRoundedFrameTime, RoundedFrameTime);
  end;

  { Controls window }
  ImGui.SetNextWindowPos(Vector2(10, 20), TImGuiCond.Once);
  ImGui.SetNextWindowSize(Vector2(500, 0), TImGuiCond.Once);
  ImGui.Begin('Controls', nil, [TImGuiWindowFlag.NoResize, TImGuiWindowFlag.NoScrollbar]);
  ImGui.SliderInt('Num Windows', FWindowCount, 1, MAX_WINDOWS, '%d');

  ImGui.Text(ImGui.Format('raw frame time:     %.3fms (min: %.3f, max: %.3f)',
    [RawFrameTime * 1000, FMinRawFrameTime * 1000, FMaxRawFrameTime * 1000]));

  ImGui.Text(ImGui.Format('rounded frame time: %.3fms (min: %.3f, max: %.3f)',
    [RoundedFrameTime * 1000, FMinRoundedFrameTime * 1000, FMaxRoundedFrameTime * 1000]));

  if (ImGui.Button('Reset min/max times')) then
    ResetMinMaxFrameTimes;

  ImGui.End;

  { Test windows }
  Inc(FCounter);
  for var I := 0 to FWindowCount - 1 do
  begin
    var T := FCounter + (I * 2);
    var R: Single := (I * 0.5 * 0.75) / MAX_WINDOWS;

    var ST, CT: Single;
    FastSinCos(T * 0.05, ST, CT);

    var Pos: TVector2;
    Pos.X := Width * (0.5 + (R * ST));
    Pos.Y := Height * (0.5 + (R * CT));

    ImGui.SetNextWindowPos(Pos, TImGuiCond.Always);
    ImGui.SetNextWindowSize(Vector2(100, 10), TImGuiCond.Always);
    ImGui.Begin(ImGui.Format('Hello ImGui %d', [I]), nil,
      [TImGuiWindowFlag.NoResize, TImGuiWindowFlag.NoScrollbar,
       TImGuiWindowFlag.NoFocusOnAppearing]);
    ImGui.End;
  end;
end;

procedure TImGuiPerfApp.Frame;
begin
  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

class function TImGuiPerfApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TImGuiPerfApp.Init;
begin
  inherited;
  TTime.Setup;
  FPassAction.Colors[0].Init(TAction.Clear, 0, 0.5, 0.7, 1);
  FWindowCount := 16;
  ResetMinMaxFrameTimes;
end;

procedure TImGuiPerfApp.ResetMinMaxFrameTimes;
begin
  FMaxRawFrameTime := 0;
  FMinRawFrameTime := 1000;
  FMaxRoundedFrameTime := 0;
  FMinRoundedFrameTime := 1000;
end;

end.

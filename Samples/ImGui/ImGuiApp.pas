unit ImGuiApp;
{ Demonstrates Dear ImGui UI rendering via Neslib.Sokol.Gfx, Neslib.Sokol.ImGui
  and Neslib.ImGui }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.ImGui,
  SampleApp;

type
  TImGuiApp = class(TSampleApp)
  private
    FShowTestWindow: Boolean;
    FShowAnotherWindow: Boolean;
    FPassAction: TPassAction;
    FFloatVal: Single;
    FTextVal: TImGuiText;
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
  System.UITypes,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue,
  Neslib.FastMath;

{ TImGuiApp }

procedure TImGuiApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 1280;
  AConfig.Height := 768;
  AConfig.WindowTitle := 'ImGui';
  AConfig.DepthFormat := TAppPixelFormat.None;
  AConfig.iOS.KeyboardResizesCanvas := False;
  AConfig.EnableClipboard := True;
end;

procedure TImGuiApp.Init;
begin
  inherited;
  FShowTestWindow := True;
  FTextVal := 'The Quick Brown Fox';
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0, 0.5, 0.7, 1);
end;

procedure TImGuiApp.Frame;
begin
  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TImGuiApp.Cleanup;
begin
  inherited;
end;

class function TImGuiApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TImGuiApp.DrawImGui;
begin
  { Show a simple window.
    Tip: if we don't call ImGui.Begin/ImGui.End, the widgets appears in a window
    automatically called "Debug" }
  ImGui.Text('Hello, world!');

  ImGui.InputText('text', FTextVal);
  ImGui.SliderFloat('float', @FFloatVal, 0, 1, '%.3f');
  ImGui.ColorEdit3('clear color', @FPassAction.Colors[0].ClearValue);

  if (ImGui.Button('Test Window')) then
    FShowTestWindow := not FShowTestWindow;

  if (ImGui.Button('Another Window')) then
    FShowAnotherWindow := not FShowAnotherWindow;

  ImGui.Text(ImGui.Format('Application average %.3f ms/frame (%.1f FPS)',
    [1000 / ImGui.GetIO.Framerate, ImGui.GetIO.Framerate]));

  ImGui.Text(ImGui.Format('W: %d, H: %d, DpiScale: %.1f', [FramebufferWidth,
    FramebufferHeight, DpiScale]));

  var Caption: PUTF8Char;
  if (FullScreen) then
    Caption := 'Switch to windowed'
  else
    Caption := 'Switch to fullscreen';
  if (ImGui.Button(Caption)) then
    ToggleFullscreen;

  ImGui.Text(ImGui.Format('FrameDuration: %.6f', [FrameDuration]));
  ImGui.Text(ImGui.Format('FrameDurationUnfiltered: %.6f', [FrameDurationUnfiltered]));

  { 2. Show another simple window, this time using an explicit Begin/End pair }
  if (FShowAnotherWindow) then                    begin
    ImGui.SetNextWindowSize(Vector2(200, 100), TImGuiCond.FirstUseEver);
    ImGui.&Begin('Another Window', @FShowAnotherWindow);
    ImGui.Text('Hello');
    ImGui.&End;
  end;

  { 3. Show the built-in ImGui test window. }
  if (FShowTestWindow) then
  begin
    ImGui.SetNextWindowPos(Vector2(460, 20), TImGuiCond.FirstUseEver);
    ImGui.ShowDemoWindow;
  end;
end;

end.

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
  Neslib.FastMath;

{ TImGuiApp }

procedure TImGuiApp.Cleanup;
begin
  inherited;
end;

procedure TImGuiApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 1024;
  AConfig.Height := 768;
  AConfig.WindowTitle := 'ImGui';
  AConfig.iOSKeyboardResizesCanvas := False;
  AConfig.EnableClipboard := True;
end;

procedure TImGuiApp.DrawImGui;
begin
  { Show a simple window.
    Tip: if we don't call ImGui.Begin/ImGui.End, the widgets appears in a window
    automatically called "Debug" }
  ImGui.Text('Hello, world!');

  ImGui.InputText('text', FTextVal);
  ImGui.SliderFloat('float', FFloatVal, 0, 1, '%.3f');
  ImGui.ColorEdit3('clear color', FPassAction.Colors[0].Value);

  if (ImGui.Button('Test Window')) then
    FShowTestWindow := not FShowTestWindow;

  if (ImGui.Button('Another Window')) then
    FShowAnotherWindow := not FShowAnotherWindow;

  ImGui.Text(ImGui.Format('Application average %.3f ms/frame (%.1f FPS)',
    [1000 / ImGui.GetIO.Framerate, ImGui.GetIO.Framerate]));

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

procedure TImGuiApp.Frame;
begin
  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

class function TImGuiApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TImGuiApp.Init;
begin
  inherited;
  FShowTestWindow := True;
  FTextVal := 'The Quick Brown Fox';
  FPassAction.Colors[0].Init(TAction.Clear, 0.7, 0.5, 0, 1);
  Include(ImGui.GetIO.ConfigFlags, TImGuiConfigFlag.DockingEnable);
end;

end.

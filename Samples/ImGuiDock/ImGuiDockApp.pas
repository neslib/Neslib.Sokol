unit ImGuiDockApp;
{ Using the Dear ImGui docking branch. }

interface

uses
  System.UITypes,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.ImGui,
  SampleApp;

type
  TImGuiDockApp = class(TSampleApp)
  private
    FShowTestWindow: Boolean;
    FShowAnotherWindow: Boolean;
    FPassAction: TPassAction;
    FFloatVal: Single;
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
  Neslib.Sokol.Glue,
  Neslib.ImGui;

{ TImGuiDockApp }

procedure TImGuiDockApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 1024;
  AConfig.Height := 768;
  AConfig.WindowTitle := 'Dear ImGui Docking';
  AConfig.HighDpi := True;
  AConfig.DepthFormat := TAppPixelFormat.None;
  AConfig.iOS.KeyboardResizesCanvas := False;
  AConfig.EnableClipboard := True;
end;

procedure TImGuiDockApp.Init;
begin
  inherited;
  FShowTestWindow := True;

  { Configure Dear ImGui with docking enabled }
  var IO := ImGui.GetIO;
  IO.ConfigFlags := IO.ConfigFlags + [TImGuiConfigFlag.DockingEnable];

  { Initial clear color }
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0.3, 0.7, 0.5, 1);
end;

procedure TImGuiDockApp.Frame;
begin
  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TImGuiDockApp.Cleanup;
begin
  inherited;
end;

class function TImGuiDockApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TImGuiDockApp.DrawImGui;
begin
  { 1. Show a simple window
    Tip: if we don't call ImGui.Begin/ImGui.End the widgets appears in a window
    automatically called "Debug" }
  ImGui.Text('Draw windows over one another!');
  ImGui.SliderFloat('float', @FFloatVal, 0, 1);
  ImGui.ColorEdit3('clear color', @FPassAction.Colors[0].ClearValue);

  if (ImGui.Button('Test Window')) then
    FShowTestWindow := not FShowTestWindow;

  if (ImGui.Button('Another Window')) then
    FShowAnotherWindow := not FShowAnotherWindow;

  ImGui.Text(ImGui.Format('Application average %.3f ms/frame (%.1f FPS)',
    [1000 / ImGui.GetIO.Framerate, ImGui.GetIO.Framerate]));

  { 2. Show another simple window, this time using an explicit Begin/End pair }
  if (FShowAnotherWindow) then
  begin
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

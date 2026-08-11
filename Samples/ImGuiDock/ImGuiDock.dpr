program ImGuiDock;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  ImGuiDockApp in 'ImGuiDockApp.pas';

begin
  RunApp(TImGuiDockApp);
end.

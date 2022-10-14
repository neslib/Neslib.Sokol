program ImGui;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  ImGuiApp in 'ImGuiApp.pas';

begin
  RunApp(TImGuiApp);
end.

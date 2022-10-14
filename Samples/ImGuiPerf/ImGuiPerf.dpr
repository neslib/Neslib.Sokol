program ImGuiPerf;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  ImGuiPerfApp in 'ImGuiPerfApp.pas';

begin
  RunApp(TImGuiPerfApp);
end.

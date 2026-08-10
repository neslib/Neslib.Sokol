program DrawCallPerf;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  DrawCallPerfApp in 'DrawCallPerfApp.pas';

begin
  RunApp(TDrawCallPerfApp);
end.

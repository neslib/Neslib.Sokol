program Restart;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  RestartApp in 'RestartApp.pas';

begin
  RunApp(TRestartApp);
end.

program NonInterleaved;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  NonInterleavedApp in 'NonInterleavedApp.pas';

begin
  RunApp(TNonInterleavedApp);
end.

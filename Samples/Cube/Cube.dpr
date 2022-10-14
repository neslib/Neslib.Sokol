program Cube;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  CubeApp in 'CubeApp.pas';

begin
  RunApp(TCubeApp);
end.

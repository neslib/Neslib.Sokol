program TexCube;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  TexCubeApp in 'TexCubeApp.pas';

begin
  RunApp(TTexCubeApp);
end.

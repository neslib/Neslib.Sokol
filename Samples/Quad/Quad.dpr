program Quad;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  QuadApp in 'QuadApp.pas';

begin
  RunApp(TQuadApp);
end.

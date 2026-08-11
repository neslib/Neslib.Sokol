program Mandelbrot;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  MandelbrotApp in 'MandelbrotApp.pas';

begin
  RunApp(TMandelbrotApp);
end.

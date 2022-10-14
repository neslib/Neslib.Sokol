program Shapes;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  ShapeApp in 'ShapeApp.pas';

begin
  RunApp(TShapeApp);
end.

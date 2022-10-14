program ShapesTransform;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  ShapesTransformApp in 'ShapesTransformApp.pas';

begin
  RunApp(TShapesTransformApp);
end.

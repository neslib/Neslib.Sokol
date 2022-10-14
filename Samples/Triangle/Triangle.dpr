program Triangle;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  TriangleApp in 'TriangleApp.pas';

begin
  RunApp(TTriangleApp);
end.

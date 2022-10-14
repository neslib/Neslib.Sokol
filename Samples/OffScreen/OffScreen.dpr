program OffScreen;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  OffScreenApp in 'OffScreenApp.pas',
  Neslib.Sokol.Shape in '..\..\Neslib.Sokol.Shape.pas';

begin
  RunApp(TOffScreenApp);
end.

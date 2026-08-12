program OffScreenMsaa;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  OffScreenMsaaApp in 'OffScreenMsaaApp.pas',
  Neslib.Sokol.Shape in '..\..\Neslib.Sokol.Shape.pas';

begin
  RunApp(TOffScreenMsaaApp);
end.

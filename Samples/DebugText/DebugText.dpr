program DebugText;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  DebugTextApp in 'DebugTextApp.pas';

begin
  RunApp(TDebugTextApp);
end.

program DebugTextContext;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  DebugTextContextApp in 'DebugTextContextApp.pas';

begin
  RunApp(TDebugTextContextApp);
end.

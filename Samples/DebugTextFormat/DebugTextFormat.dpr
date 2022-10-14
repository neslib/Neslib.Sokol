program DebugTextFormat;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  DebugTextFormatApp in 'DebugTextFormatApp.pas';

begin
  RunApp(TDebugTextFormatApp);
end.

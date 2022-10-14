program DebugTextUserFont;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  DebugTextUserFontApp in 'DebugTextUserFontApp.pas';

begin
  RunApp(TDebugTextUserFontApp);
end.

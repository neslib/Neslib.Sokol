program Cursor;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  CursorApp in 'CursorApp.pas';

begin
  RunApp(TCursorApp);
end.

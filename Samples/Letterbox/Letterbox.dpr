program Letterbox;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  LetterboxApp in 'LetterboxApp.pas';

begin
  RunApp(TLetterboxApp);
end.

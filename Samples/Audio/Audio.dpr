program Audio;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  AudioApp in 'AudioApp.pas';

begin
  RunApp(TAudioApp);
end.

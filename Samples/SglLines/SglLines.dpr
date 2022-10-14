program SglLines;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  SglLinesApp in 'SglLinesApp.pas';

begin
  RunApp(TSglLinesApp);
end.

program SglContext;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  SglContextApp in 'SglContextApp.pas';

begin
  RunApp(TSglContextApp);
end.

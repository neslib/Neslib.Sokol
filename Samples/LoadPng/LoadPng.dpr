program LoadPng;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  LoadPngApp in 'LoadPngApp.pas';

begin
  RunApp(TLoadPngApp);
end.

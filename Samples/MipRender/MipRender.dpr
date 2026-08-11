program MipRender;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  MipRenderApp in 'MipRenderApp.pas';

begin
  RunApp(TMipRenderApp);
end.

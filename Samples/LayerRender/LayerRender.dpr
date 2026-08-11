program LayerRender;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  LayerRenderApp in 'LayerRenderApp.pas';

begin
  RunApp(TLayerRenderApp);
end.

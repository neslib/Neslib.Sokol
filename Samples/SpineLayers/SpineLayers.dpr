program SpineLayers;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  SpineLayersApp in 'SpineLayersApp.pas';

begin
  RunApp(TSpineLayersApp);
end.

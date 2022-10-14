program DynTex;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  DynTexApp in 'DynTexApp.pas';

begin
  RunApp(TDynTexApp);
end.

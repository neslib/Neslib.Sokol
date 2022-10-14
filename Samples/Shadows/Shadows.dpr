program Shadows;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  ShadowsApp in 'ShadowsApp.pas';

begin
  RunApp(TShadowsApp);
end.

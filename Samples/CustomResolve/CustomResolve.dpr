program CustomResolve;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  CustomResolveApp in 'CustomResolveApp.pas';

begin
  RunApp(TCustomResolveApp);
end.

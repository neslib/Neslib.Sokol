program InstancingCompute;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  InstancingComputeApp in 'InstancingComputeApp.pas';

begin
  RunApp(TInstancingComputeApp);
end.

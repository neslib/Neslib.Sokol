program ComputeBoids;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  ComputeBoidsApp in 'ComputeBoidsApp.pas';

begin
  RunApp(TComputeBoidsApp);
end.

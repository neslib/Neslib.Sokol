program BasisU;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  BasisUApp in 'BasisUApp.pas',
  BasisUAssets in 'BasisUAssets.pas';

begin
  RunApp(TBasisUApp);
end.

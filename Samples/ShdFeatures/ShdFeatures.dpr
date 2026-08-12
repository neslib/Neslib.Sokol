program ShdFeatures;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  ShdFeaturesApp in 'ShdFeaturesApp.pas',
  OzzUtil in '..\Shared\OzzUtil.pas';

begin
  RunApp(TShdFeaturesApp);
end.

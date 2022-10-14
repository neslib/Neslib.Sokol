program glTF;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  glTFApp in 'glTFApp.pas',
  Camera in '..\Shared\Camera.pas';

begin
  RunApp(TglTFApp);
end.

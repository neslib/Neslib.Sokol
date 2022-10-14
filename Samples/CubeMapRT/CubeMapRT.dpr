program CubeMapRT;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  CubeMapRTApp in 'CubeMapRTApp.pas';

begin
  RunApp(TCubeMapRTApp);
end.

program CubeMapJpeg;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  CubeMapJpegApp in 'CubeMapJpegApp.pas';

begin
  RunApp(TCubeMapJpegApp);
end.

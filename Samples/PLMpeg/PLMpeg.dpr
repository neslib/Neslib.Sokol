program PLMpeg;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  PLMpegApp in 'PLMpegApp.pas';

begin
  RunApp(TPLMpegApp);
end.

program MrtPixelFormats;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  MrtPixelFormatsApp in 'MrtPixelFormatsApp.pas';

begin
  RunApp(TMrtPixelFormatsApp);
end.

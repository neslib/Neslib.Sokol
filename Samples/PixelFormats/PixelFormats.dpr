program PixelFormats;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  PixelFormatsApp in 'PixelFormatsApp.pas';

begin
  RunApp(TPixelFormatsApp);
end.

program ImageBlur;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  ImageBlurApp in 'ImageBlurApp.pas';

begin
  RunApp(TImageBlurApp);
end.

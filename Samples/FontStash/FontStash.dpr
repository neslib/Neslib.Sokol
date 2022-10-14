program FontStash;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  FontStashApp in 'FontStashApp.pas',
  Neslib.FontStash in '..\..\Neslib.FontStash.pas',
  Neslib.Sokol.FontStash in '..\..\Neslib.Sokol.FontStash.pas';

begin
  RunApp(TFontStashApp);
end.

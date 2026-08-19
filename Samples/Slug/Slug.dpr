program Slug;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  SlugApp in 'SlugApp.pas',
  Neslib.Stb.TrueType in '..\..\Neslib.Stb.TrueType.pas';

begin
  RunApp(TSlugApp);
end.

program Slug;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  SlugApp in 'SlugApp.pas';

begin
  RunApp(TSlugApp);
end.

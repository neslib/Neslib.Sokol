program ModPlay;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  ModPlayApp in 'ModPlayApp.pas',
  Mods in 'Mods.pas';

begin
  RunApp(TModPlayApp);
end.

program Blend;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  BlendApp in 'BlendApp.pas';

begin
  RunApp(TBlendApp);
end.

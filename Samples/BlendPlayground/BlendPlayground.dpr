program BlendPlayground;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  BlendPlaygroundApp in 'BlendPlaygroundApp.pas';

begin
  RunApp(TBlendPlaygroundApp);
end.

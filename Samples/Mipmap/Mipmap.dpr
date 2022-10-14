program Mipmap;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  MipmapApp in 'MipmapApp.pas';

begin
  RunApp(TMipmapApp);
end.

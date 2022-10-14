program Drop;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  DropApp in 'DropApp.pas';

begin
  RunApp(TDropApp);
end.

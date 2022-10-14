program Clear;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  ClearApp in 'ClearApp.pas';

begin
  RunApp(TClearApp);
end.

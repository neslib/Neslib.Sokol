program Clear;

{$R *.res}

uses
  ClearApp in 'ClearApp.pas',
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas';

begin
  RunApp(TClearApp);
end.

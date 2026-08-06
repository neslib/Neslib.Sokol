program SpineInspector;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  SpineInspectorApp in 'SpineInspectorApp.pas';

begin
  RunApp(TSpineInspectorApp);
end.

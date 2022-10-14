program Events;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  EventsApp in 'EventsApp.pas';

begin
  RunApp(TEventsApp);
end.

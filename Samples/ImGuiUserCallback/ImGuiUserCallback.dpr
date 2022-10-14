program ImGuiUserCallback;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  ImGuiUserCallbackApp in 'ImGuiUserCallbackApp.pas';

begin
  RunApp(TImGuiUserCallbackApp);
end.

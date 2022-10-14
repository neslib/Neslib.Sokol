program ImGuiHighDpi;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  ImGuiHighDpiApp in 'ImGuiHighDpiApp.pas',
  ImGuiFont in '..\Shared\ImGuiFont.pas';

begin
  RunApp(TImGuiHighDpiApp);
end.

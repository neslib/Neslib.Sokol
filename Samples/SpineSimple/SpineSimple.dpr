program SpineSimple;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  SpineSimpleApp in 'SpineSimpleApp.pas';

begin
  RunApp(TSpineSimpleApp);
end.

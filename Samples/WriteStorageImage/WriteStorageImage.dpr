program WriteStorageImage;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  WriteStorageImageApp in 'WriteStorageImageApp.pas';

begin
  RunApp(TWriteStorageImageApp);
end.

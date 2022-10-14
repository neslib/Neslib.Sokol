program BufferOffsets;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  BufferOffsetsApp in 'BufferOffsetsApp.pas';

begin
  RunApp(TBufferOffsetsApp);
end.

program FrameBuffer;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  FrameBufferApp in 'FrameBufferApp.pas';

begin
  RunApp(TFrameBufferApp);
end.

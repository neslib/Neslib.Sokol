program VertexIndexBuffer;

{$R *.res}

uses
  Neslib.Sokol.App in '..\..\Neslib.Sokol.App.pas',
  VertexIndexBufferApp in 'VertexIndexBufferApp.pas';

begin
  RunApp(TVertexIndexBufferApp);
end.

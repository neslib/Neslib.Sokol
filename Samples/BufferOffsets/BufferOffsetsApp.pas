unit BufferOffsetsApp;
{ Render separate geometries in vertex- and index-buffers with buffer offsets. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  SampleApp;

type
  TBufferOffsetsApp = class(TSampleApp)
  private
    FVBuf: TBuffer;
    FIBuf: TBuffer;
    FPassAction: TPassAction;
    FShader: TShader;
    FPip: TPipeline;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue,
  BufferOffsetsShader;

type
  TVertex = record
    X, Y: Single;
    R, G, B: Single;
  end;

const
  { A 2D triangle and quad in 1 vertex buffer and 1 index buffer }
  VERTICES: array [0..6] of TVertex = (
    { Triangle }
    (X:  0.00; Y:  0.55; R:  1.0; G: 0.0; B: 0.0),
    (X:  0.25; Y:  0.05; R:  0.0; G: 1.0; B: 0.0),
    (X: -0.25; Y:  0.05; R:  0.0; G: 0.0; B: 1.0),

    { Quad }
    (X: -0.25; Y: -0.05; R:  0.0; G: 0.0; B: 1.0),
    (X:  0.25; Y: -0.05; R:  0.0; G: 1.0; B: 0.0),
    (X:  0.25; Y: -0.55; R:  1.0; G: 0.0; B: 0.0),
    (X: -0.25; Y: -0.55; R:  1.0; G: 1.0; B: 0.0));

const
  INDICES: array [0..8] of UInt16 = (
    0, 1, 2,
    0, 1, 2, 0, 2, 3);

{ TBufferOffsetsApp }

procedure TBufferOffsetsApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.WindowTitle := 'Buffer Offsets';
end;

procedure TBufferOffsetsApp.Init;
begin
  inherited;
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0.5, 0.5, 1.0, 1.0);

  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'VertexBuffer';
  FVBuf := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.Usage.IndexBuffer := True;
  BufferDesc.Data := TRange.Create(INDICES);
  BufferDesc.TraceLabel := 'IndexBuffer';
  FIBuf := TBuffer.Create(BufferDesc);

  FShader := TShader.Create(BufferOffsetsShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := FShader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.Layout.Attrs[ATTR_BUFFEROFFSETS_POSITION].Format := TVertexFormat.Float2;
  PipDesc.Layout.Attrs[ATTR_BUFFEROFFSETS_COLOR0].Format := TVertexFormat.Float3;
  FPip := TPipeline.Create(PipDesc);
end;

procedure TBufferOffsetsApp.Frame;
begin
  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FPip);

  { Render the triangle (located at start of vertex- and index-buffer) }
  var Bindings := TBindings.Create;
  Bindings.VertexBuffers[0] := FVBuf;
  Bindings.IndexBuffer := FIBuf;
  TGfx.ApplyBindings(Bindings);
  TGfx.Draw(0, 3, 1);

  { Render the quad (located after triangle data in vertex- and index-buffer) }
  Bindings.VertexBufferOffsets[0] := 3 * SizeOf(TVertex);
  Bindings.IndexBufferOffset := 3 * SizeOf(UInt16);
  TGfx.ApplyBindings(Bindings);
  TGfx.Draw(0, 6, 1);

  DebugFrame;

  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TBufferOffsetsApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

end.

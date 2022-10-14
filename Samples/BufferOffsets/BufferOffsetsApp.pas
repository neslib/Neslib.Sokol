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
    FPassAction: TPassAction;
    FShader: TShader;
    FPip: TPipeline;
    FBind: TBindings;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api,
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

procedure TBufferOffsetsApp.Cleanup;
begin
  FPip.Free;
  FShader.Free;
  FBind.IndexBuffer.Free;
  FBind.VertexBuffers[0].Free;
  inherited;
end;

procedure TBufferOffsetsApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.WindowTitle := 'Buffer Offsets';
end;

procedure TBufferOffsetsApp.Frame;
begin
  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  TGfx.ApplyPipeline(FPip);

  { Render the triangle }
  FBind.VertexBufferOffsets[0] := 0;
  FBind.IndexBufferOffset := 0;
  TGfx.ApplyBindings(FBind);
  TGfx.Draw(0, 3, 1);

  { Render the quad }
  FBind.VertexBufferOffsets[0] := 3 * SizeOf(TVertex);
  FBind.IndexBufferOffset := 3 * SizeOf(UInt16);
  TGfx.ApplyBindings(FBind);
  TGfx.Draw(0, 6, 1);

  DebugFrame;

  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TBufferOffsetsApp.Init;
begin
  inherited;
  FPassAction.Colors[0].Init(TAction.Clear, 0.5, 0.5, 1.0, 1.0);

  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  FBind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.BufferType := TBufferType.IndexBuffer;
  BufferDesc.Data := TRange.Create(INDICES);
  FBind.IndexBuffer := TBuffer.Create(BufferDesc);

  FShader := TShader.Create(BufferOffsetsShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := FShader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.Layout.Attrs[ATTR_VS_POSITION].Format := TVertexFormat.Float2;
  PipDesc.Layout.Attrs[ATTR_VS_COLOR0].Format := TVertexFormat.Float3;
  FPip := TPipeline.Create(PipDesc);
end;

end.

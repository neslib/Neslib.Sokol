unit QuadApp;
{ Simple 2D rendering with vertex- and index-buffer. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  SampleApp;

type
  TQuadApp = class(TSampleApp)
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
  QuadShader;

const
  { A vertex buffer }
  VERTICES: array [0..27] of Single = (
  { Positions            Colors }
    -0.5,  0.5, 0.5,     1.0, 0.0, 0.0, 1.0,
     0.5,  0.5, 0.5,     0.0, 1.0, 0.0, 1.0,
     0.5, -0.5, 0.5,     0.0, 0.0, 1.0, 1.0,
    -0.5, -0.5, 0.5,     1.0, 1.0, 0.0, 1.0);

const
  { An index buffer with 2 triangles }
  INDICES: array [0..5] of UInt16 = (
    0, 1, 2,   0, 2, 3);

{ TQuadApp }

procedure TQuadApp.Cleanup;
begin
  FPip.Free;
  FBind.VertexBuffers[0].Free;
  FBind.IndexBuffer.Free;
  FShader.Free;
  inherited;
end;

procedure TQuadApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.WindowTitle := 'Quad';
  AConfig.Width := 800;
  AConfig.Height := 600;
end;

procedure TQuadApp.Frame;
begin
  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyBindings(FBind);

  TGfx.Draw(0, 6, 1);
  DebugFrame;

  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TQuadApp.Init;
begin
  inherited;
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Size := SizeOf(VERTICES);
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'QuadVertices';
  FBind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.Size := SizeOf(INDICES);
  BufferDesc.BufferType := TBufferType.IndexBuffer;
  BufferDesc.Data := TRange.Create(INDICES);
  BufferDesc.TraceLabel := 'QuadIndices';
  FBind.IndexBuffer := TBuffer.Create(BufferDesc);

  FShader := TShader.Create(QuadShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := FShader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.Layout.Attrs[ATTR_VS_POSITION].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_VS_COLOR0].Format := TVertexFormat.Float4;
  PipDesc.TraceLabel := 'QuadPipeline';
  FPip := TPipeline.Create(PipDesc);

  FPassAction.Colors[0].Init(TAction.Clear, 0, 0, 0, 1);
end;

end.

unit TriangleApp;
{ Simple 2D rendering from vertex buffer. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  SampleApp;

type
  TTriangleApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
    FVB: TBuffer;
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
  TriangleShader;

const
  { A vertex buffer with 3 vertices }
  VERTICES: array [0..20] of Single = (
  { Positions            Colors }
     0.0,  0.5, 0.5,     1.0, 0.0, 0.0, 1.0,
     0.5, -0.5, 0.5,     0.0, 1.0, 0.0, 1.0,
    -0.5, -0.5, 0.5,     0.0, 0.0, 1.0, 1.0);

{ TTriangleApp }

procedure TTriangleApp.Cleanup;
begin
  FPip.Free;
  FShader.Free;
  FVB.Free;
  inherited;
end;

procedure TTriangleApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.WindowTitle := 'Triangle';
  AConfig.Width := 640;
  AConfig.Height := 480;
end;

procedure TTriangleApp.Frame;
begin
  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyBindings(FBind);

  TGfx.Draw(0, 3, 1);
  DebugFrame;

  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TTriangleApp.Init;
begin
  inherited;
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Size := SizeOf(VERTICES);
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'TriangleVertices';
  FVB := TBuffer.Create(BufferDesc);
  FBind.VertexBuffers[0] := FVB;

  FShader := TShader.Create(TriangleShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := FShader;
  PipDesc.Layout.Attrs[ATTR_VS_POSITION].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_VS_COLOR0].Format := TVertexFormat.Float4;
  PipDesc.TraceLabel := 'TrianglePipeline';
  FPip := TPipeline.Create(PipDesc);

  FPassAction.Colors[0].Init(TAction.Clear, 0, 0, 0, 1);
end;

end.

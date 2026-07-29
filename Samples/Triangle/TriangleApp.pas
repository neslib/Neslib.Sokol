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
  Neslib.Sokol.Glue,
  TriangleShader;

const
  { A vertex buffer with 3 vertices }
  VERTICES: array [0..20] of Single = (
  { Positions            Colors }
     0.0,  0.5, 0.5,     1.0, 0.0, 0.0, 1.0,
     0.5, -0.5, 0.5,     0.0, 1.0, 0.0, 1.0,
    -0.5, -0.5, 0.5,     0.0, 0.0, 1.0, 1.0);

{ TTriangleApp }

procedure TTriangleApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.WindowTitle := 'Triangle';
  AConfig.Width := 640;
  AConfig.Height := 480;
end;

procedure TTriangleApp.Init;
begin
  inherited;
  { Create view for binding vertex buffer }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'VertexBuffer';
  FVB := TBuffer.Create(BufferDesc);
  FBind.VertexBuffers[0] := FVB;

  { Create shader from code-generated shader desc}
  FShader := TShader.Create(TriangleShaderDesc);

  { Create a pipeline object (default render states are fine for triangle).
    If the vertex layout doesn't have gaps, don't need to provide strides and
    offsets }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := FShader;
  PipDesc.Layout.Attrs[ATTR_TRIANGLE_POSITION].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_TRIANGLE_COLOR0].Format := TVertexFormat.Float4;
  PipDesc.TraceLabel := 'TrianglePipeline';
  FPip := TPipeline.Create(PipDesc);

  { A pass action to clear framebuffer to black }
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0, 0, 0, 1);
end;

procedure TTriangleApp.Frame;
begin
  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyBindings(FBind);

  TGfx.Draw(0, 3, 1);
  DebugFrame;

  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TTriangleApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

end.

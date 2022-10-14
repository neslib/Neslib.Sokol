unit SdfApp;
{ Signed-distance-field rendering demo to test the shader code generate with
  some non-trivial code.

  https://www.iquilezles.org/www/articles/mandelbulb/mandelbulb.htm
  https://www.shadertoy.com/view/ltfSWn }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  SampleApp,
  SdfShader;

type
  TSdfApp = class(TSampleApp)
  private
    FPip: TPipeline;
    FBind: TBindings;
    FPassAction: TPassAction;
    FShader: TShader;
    FVSParams: TVSParams;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api;

const
  { A vertex buffer to render a 'fullscreen triangle' }
  VERTICES: array [0..5] of Single = (
    -1.0, -3.0,
     3.0,  1.0,
    -1.0,  1.0);

{ TSdfApp }

procedure TSdfApp.Cleanup;
begin
  FPip.Free;
  FShader.Free;
  FBind.VertexBuffers[0].Free;
  inherited;
end;

procedure TSdfApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.WindowTitle := 'SDF Rendering';
  AConfig.Width := 512;
  AConfig.Height := 512;
end;

procedure TSdfApp.Frame;
begin
  var W := FramebufferWidth;
  var H := FramebufferHeight;
  FVSParams.Time := FVSParams.Time + FrameDuration;
  FVSParams.Aspect := W / H;
  TGfx.BeginDefaultPass(FPassAction, W, H);
  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyBindings(FBind);
  TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_PARAMS, TRange.Create(FVSParams));

  TGfx.Draw(0, 3);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TSdfApp.Init;
begin
  inherited;
  { A vertex buffer to render a 'fullscreen triangle' }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'Fsq Vertices';
  FBind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  { Shader and pipeline object for rendering a fullscreen quad }
  FShader := TShader.Create(SdfShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Attrs[ATTR_VS_POSITION].Format := TVertexFormat.Float2;
  PipDesc.Shader := FShader;
  FPip := TPipeline.Create(PipDesc);

  { Don't need to clear since the whole framebuffer is overwritten }
  FPassAction.Colors[0].Action := TAction.DontCare;
end;

end.

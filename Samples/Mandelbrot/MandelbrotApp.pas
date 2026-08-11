unit MandelbrotApp;
{ Render Mandelbrot fractal in pixel shader. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  SampleApp;

type
  TMandelbrotApp = class(TSampleApp)
  private
    FPip: TPipeline;
    FTime: Single;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  System.Math,
  Neslib.FastMath,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue,
  MandelbrotShader;

{ TMandelbrotApp }

procedure TMandelbrotApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.WindowTitle := 'Mandelbrot';
  AConfig.Width := 512;
  AConfig.Height := 512;
  AConfig.DepthFormat := TAppPixelFormat.None;
end;

procedure TMandelbrotApp.Init;
begin
  inherited;
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(MandelbrotShaderDesc);
  FPip := TPipeline.Create(PipDesc);
end;

procedure TMandelbrotApp.Frame;
begin
  { Loop time to prevent a too deep Mandelbrot zoom }
  FTime := FMod(FTime + FrameDuration, 20);
  var Aspect: Single := FramebufferWidth / FramebufferHeight;

  { Number of iterations grows with zoom level. Max 256 }
  var Width: SIngle := 4 * Power(0.6, FTime);
  var IterMax := 64 + Trunc(Log2(4 / Width) * 32);
  if (IterMax > 256) then
    IterMax := 256;

  var FSParams: TFSParams;
  FSParams.Time := FTime;
  FSParams.Width := Width;
  FSParams.IterMax := IterMax;

  if (Aspect >= 1) then
    FSParams.Aspect := Vector2(Aspect, 1)
  else
    FSParams.Aspect := Vector2(1, 1 / Aspect);

  { Rendering happens via a 'fullscreen triangle' synthesized in the vertex
    shader }
  var Pass := TPass.Create;
  Pass.Action.Colors[0].LoadAction := TLoadAction.DontCare;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyUniforms(UB_FS_PARAMS, TRange.Create(FSParams));

  TGfx.Draw(0, 3, 1);
  DebugFrame;

  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TMandelbrotApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

end.

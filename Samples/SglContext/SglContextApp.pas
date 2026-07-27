unit SglContextApp;
{ Demonstrates how to render in different render passes with Neslib.Sokol.GL
  using Sokol GL contexts. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.GL,
  SampleApp;

const
  OFFSCREEN_PIXELFORMAT = TPixelFormat.Rgba8;
  OFFSCREEN_SAMPLECOUNT = 1;
  OFFSCREEN_WIDTH       = 32;
  OFFSCREEN_HEIGHT      = 32;

type
  TOffscreen = record
  public
    TexView: TView;
    Pass: TPass;
    GLCtx: TGLContext;
  public
    procedure Init;
  end;

type
  TDisplay = record
  public
    PassAction: TPassAction;
    Sampler: TSampler;
    GLPip: TGLPipeline;
  public
    procedure Init;
  end;

type
  TSglContextApp = class(TSampleApp)
  private
    FOffscreen: TOffscreen;
    FDisplay: TDisplay;
    FAngleDeg: Double;
  private
    class procedure DrawQuad; static;
    class procedure DrawCube; static;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue;

{ TSglContextApp }

procedure TSglContextApp.Cleanup;
begin
  sglShutdown;
  inherited;
end;

procedure TSglContextApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Neslib.Sokol.GL Contexts';
end;

class procedure TSglContextApp.DrawCube;
begin
  sglBeginQuads;
  sglV3F_T2F(-1,  1, -1, 0, 1);
  sglV3F_T2F( 1,  1, -1, 1, 1);
  sglV3F_T2F( 1, -1, -1, 1, 0);
  sglV3F_T2F(-1, -1, -1, 0, 0);
  sglV3F_T2F(-1, -1,  1, 0, 1);
  sglV3F_T2F( 1, -1,  1, 1, 1);
  sglV3F_T2F( 1,  1,  1, 1, 0);
  sglV3F_T2F(-1,  1,  1, 0, 0);
  sglV3F_T2F(-1, -1,  1, 0, 1);
  sglV3F_T2F(-1,  1,  1, 1, 1);
  sglV3F_T2F(-1,  1, -1, 1, 0);
  sglV3F_T2F(-1, -1, -1, 0, 0);
  sglV3F_T2F( 1, -1,  1, 0, 1);
  sglV3F_T2F( 1, -1, -1, 1, 1);
  sglV3F_T2F( 1,  1, -1, 1, 0);
  sglV3F_T2F( 1,  1,  1, 0, 0);
  sglV3F_T2F( 1, -1, -1, 0, 1);
  sglV3F_T2F( 1, -1,  1, 1, 1);
  sglV3F_T2F(-1, -1,  1, 1, 0);
  sglV3F_T2F(-1, -1, -1, 0, 0);
  sglV3F_T2F(-1,  1, -1, 0, 1);
  sglV3F_T2F(-1,  1,  1, 1, 1);
  sglV3F_T2F( 1,  1,  1, 1, 0);
  sglV3F_T2F( 1,  1, -1, 0, 0);
  sglEnd;
end;

class procedure TSglContextApp.DrawQuad;
begin
  sglBeginQuads;
  sglV2F_C3B( 0, -1, 255,   0,   0);
  sglV2F_C3B( 1,  0,   0,   0, 255);
  sglV2F_C3B( 0,  1,   0, 255, 255);
  sglV2F_C3B(-1,  0,   0, 255,   0);
  sglEnd;
end;

procedure TSglContextApp.Frame;
begin
  FAngleDeg := FAngleDeg + (FrameDuration * 60);
  var A: Single := sglRad(FAngleDeg);

  { Draw a rotating quad into the offscreen render target texture }
  sglSetContext(FOffscreen.GLCtx);
  sglDefaults;
  sglMatrixModeModelview;
  sglRotate(A, 0, 0, 1);
  DrawQuad;

  { Draw a rotating 3D cube, using the offscreen render target as texture }
  sglSetDefaultContext;
  sglDefaults;
  sglEnableTexture;
  sglTexture(FOffscreen.TexView, FDisplay.Sampler);
  sglLoadPipeline(FDisplay.GLPip);
  sglMatrixModeProjection;
  sglPerspective(sglRad(45), FramebufferWidth / FramebufferHeight, 0.1, 100);
  sglMatrixModeModelview;
  sglLookAt(Sin(A) * 6, Sin(A) * 3, Cos(A) * 6, 0, 0, 0, 0, 1, 0);
  DrawCube;

  { Do the actual offscreen and display rendering in Sokol Gfx passes }
  TGfx.BeginPass(FOffscreen.Pass);
  FOffscreen.GLCtx.Draw;
  TGfx.EndPass;

  var Pass := TPass.Create;
  Pass.Action^ := FDisplay.PassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGLContext.Default.Draw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TSglContextApp.Init;
begin
  inherited;
  { Setup Neslib.Sokol.GL with the default context compatible with the default
    render pass }
  var GLDesc := TGLDesc.Create;
  GLDesc.MaxVertices := 64;
  GLDesc.MaxCommands := 16;
  GLDesc.UseDelphiMemoryManager := True;
  GLDesc.Logger := GLDesc.DefaultLogger;
  sglSetup(GLDesc);

  FDisplay.Init;
  FOffscreen.Init;
end;

{ TOffscreen }

procedure TOffscreen.Init;
begin
  { Create a Neslib.Sokol.GL context compatible with the offscreen render pass
    (specific color pixel format, no depth-stencil-surface, no MSAA) }
  var CtxDesc := TGLContextDesc.Create;
  CtxDesc.MaxVertices := 8;
  CtxDesc.MaxCommands := 4;
  CtxDesc.ColorFormat := OFFSCREEN_PIXELFORMAT;
  CtxDesc.DepthFormat := TPixelFormat.None;
  CtxDesc.SampleCount := OFFSCREEN_SAMPLECOUNT;
  GLCtx := TGLContext.Create(CtxDesc);

  { Create an offscreen render target image, texture, pass, and attachment views }
  var ImgDesc := TImageDesc.Create;
  ImgDesc.Usage.ColorAttachment := True;
  ImgDesc.Width := OFFSCREEN_WIDTH;
  ImgDesc.Height := OFFSCREEN_HEIGHT;
  ImgDesc.PixelFormat := OFFSCREEN_PIXELFORMAT;
  ImgDesc.SampleCount := OFFSCREEN_SAMPLECOUNT;
  var Img := TImage.Create(ImgDesc);

  var ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := Img;
  TexView := TView.Create(ViewDesc);

  ViewDesc.Init;
  ViewDesc.ColorAttachment.Image := Img;

  Pass := TPass.Create;
  Pass.Action.Colors[0].Init(TLoadAction.Clear, 0, 0, 0, 1);
  Pass.Attachments.Colors[0] := TView.Create(ViewDesc);
end;

{ TDisplay }

procedure TDisplay.Init;
begin
  { Pass action and pipeline for the default render pass }
  PassAction.Colors[0].Init(TLoadAction.Clear, 0.5, 0.7, 1, 1);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  GLPip := TGLPipeline.Create(PipDesc);

  { A sampler for sampling the offscreen render target }
  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.WrapU := TWrap.ClampToEdge;
  SamplerDesc.WrapV := TWrap.ClampToEdge;
  SamplerDesc.MinFilter := TFilter.Nearest;
  SamplerDesc.MagFilter := TFilter.Nearest;
  Sampler := TSampler.Create(SamplerDesc);
end;

end.

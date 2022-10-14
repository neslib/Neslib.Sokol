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
    PassAction: TPassAction;
    Pass: TPass;
    Img: TImage;
    GLCtx: TGLContext;
  public
    procedure Init;
    procedure Free;
  end;

type
  TDisplay = record
  public
    PassAction: TPassAction;
    GLPip: TGLPipeline;
  public
    procedure Init;
    procedure Free;
  end;

type
  TSglContextApp = class(TSampleApp)
  private
    FOffscreen: TOffscreen;
    FDisplay: TDisplay;
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
  Neslib.Sokol.Api;

{ TSglContextApp }

procedure TSglContextApp.Cleanup;
begin
  FOffscreen.Free;
  FDisplay.Free;
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
  var T: Single := FrameDuration * 60;
  var A: Single := sglRad(FrameCount * T);

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
  sglTexture(FOffscreen.Img);
  sglLoadPipeline(FDisplay.GLPip);
  sglMatrixModeProjection;
  sglPerspective(sglRad(45), FramebufferWidth / FramebufferHeight, 0.1, 100);
  sglMatrixModeModelview;
  sglLookAt(Sin(A) * 6, Sin(A) * 3, Cos(A) * 6, 0, 0, 0, 0, 1, 0);
  DrawCube;

  { Do the actual offscreen and display rendering in Sokol Gfx passes }
  TGfx.BeginPass(FOffscreen.Pass, FOffscreen.PassAction);
  sglDraw(FOffscreen.GLCtx);
  TGfx.EndPass;

  TGfx.BeginDefaultPass(FDisplay.PassAction, FramebufferWidth, FramebufferHeight);
  sglDraw(TGLContext.Default);
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
  sglSetup(GLDesc);

  FDisplay.Init;
  FOffscreen.Init;
end;

{ TOffscreen }

procedure TOffscreen.Free;
begin
  Pass.Free;
  Img.Free;
  GLCtx.Free;
end;

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

  { Create an offscreen render target texture, pass, and pass action }
  var ImgDesc := TImageDesc.Create;
  ImgDesc.RenderTarget := True;
  ImgDesc.Width := OFFSCREEN_WIDTH;
  ImgDesc.Height := OFFSCREEN_HEIGHT;
  ImgDesc.PixelFormat := OFFSCREEN_PIXELFORMAT;
  ImgDesc.SampleCount := OFFSCREEN_SAMPLECOUNT;
  ImgDesc.WrapU := TWrap.ClampToEdge;
  ImgDesc.WrapV := TWrap.ClampToEdge;
  ImgDesc.MinFilter := TFilter.Nearest;
  ImgDesc.MagFilter := TFilter.Nearest;
  Img := TImage.Create(ImgDesc);

  var PassDesc := TPassDesc.Create;
  PassDesc.ColorAttachments[0].Image := Img;
  Pass := TPass.Create(PassDesc);

  PassAction.Colors[0].Init(TAction.Clear, 0, 0, 0, 1);
end;

{ TDisplay }

procedure TDisplay.Free;
begin
  GLPip.Free;
end;

procedure TDisplay.Init;
begin
  { Pass action and pipeline for the default render pass }
  PassAction.Colors[0].Init(TAction.Clear, 0.5, 0.7, 1, 1);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  GLPip := TGLPipeline.Create(PipDesc);
end;

end.

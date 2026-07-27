unit BasisUApp;
{ This is mainly a regression test for compressed texture format support in
  Neslib.Sokol.Gfx, but it's also a simple demo of how to use Basis Universal
  textures. Basis Univsersal compressed textures are embedded as Delphi arrays
  so that texture data doesn't need to be loaded (for instance via
  Neslib.Sokol.Fetch)

  Texture credits: Paul Vera-Broadbent (twitter: @PVBroadz)

  And some useful info from Carl Woffenden (twitter: @monsieurwoof):

  "The testcard image, BTW, was specifically crafted to compress well with
  ETC1S. The regions fit into 4x4 bounds, with flat areas having only two
  colours (and gradients designed to work across the endpoints in a block).
  @PVBroadz created it when we were experimenting with BasisU." }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.GL,
  Neslib.Sokol.DebugText,
  Neslib.Sokol.BasisU,
  Neslib.FastMath,
  SampleApp;

type
  TQuadParams = record
  public
    Pos: TVector2;
    Scale: TVector2;
    Rotation: Single;
    View: TView;
    Pipeline: TGLPipeline;
  end;

type
  TBasisUApp = class(TSampleApp)
  private
    FPassaction: TPassAction;
    FAlphaPip: TGLPipeline;
    FOpaqueView: TView;
    FAlphaView: TView;
    FSampler: TSampler;
    FAngleDeg: Double;
  private
    procedure DrawQuad(const AParams: TQuadParams);
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
  BasisUAssets;

function PixelFormatToString(const AFormat: TPixelFormat): String;
begin
  case AFormat of
    TPixelFormat.Bc3Rgba      : Result := 'BC3 RGBA';
    TPixelFormat.Bc1Rgba      : Result := 'BC1 RGBA';
    TPixelFormat.Etc2Rgba8    : Result := 'ETC2 RGBA8';
    TPixelFormat.Etc2Rgb8     : Result := 'ETC2 RGB8';
  else
    Result := '???';
  end;
end;

{ TBasisUApp }

procedure TBasisUApp.Cleanup;
begin
  TDbgText.Shutdown;
  TBasisU.Shutdown;
  sglShutdown;
  inherited;
end;

procedure TBasisUApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'BasisU';
end;

procedure TBasisUApp.DrawQuad(const AParams: TQuadParams);
begin
  sglTexture(AParams.View, FSampler);
  if (AParams.Pipeline.Id <> 0) then
    sglLoadPipeline(AParams.Pipeline)
  else
    sglLoadDefaultPipeline;

  sglPushMatrix;
  sglTranslate(AParams.Pos.X, AParams.Pos.Y, 0);
  sglScale(AParams.Scale.X, AParams.Scale.Y, 0);
  sglRotate(AParams.Rotation, 0, 0, 1);
  sglBeginQuads;
  sglV2F_T2F(-1, -1, 0, 0);
  sglV2F_T2F( 1, -1, 1, 0);
  sglV2F_T2F( 1,  1, 1, 1);
  sglV2F_T2F(-1,  1, 0, 1);
  sglEnd;
  sglPopMatrix;
end;

procedure TBasisUApp.Frame;
begin
  { Info text }
  TDbgText.Canvas(FramebufferWidth * 0.5, FramebufferHeight * 0.5);
  TDbgText.Origin(0.5, 2);
  TDbgText.WriteLn('Opaque format: %s', [PixelFormatToString(TBasisU.PixelFormat(False))]);
  TDbgText.NewLine;
  TDbgText.Write('Alpha format: %s', [PixelFormatToString(TBasisU.PixelFormat(True))]);

  { Draw some textured quads via Sokol GL }
  sglDefaults;
  sglEnableTexture;

  var Aspect: Single := FramebufferHeight / FramebufferWidth;
  sglMatrixModeProjection;
  sglOrtho(-1, 1, Aspect, -Aspect, -1, 1);

  sglMatrixModeModelview;
  FAngleDeg := FAngleDeg + (FrameDuration * 60);

  var Params: TQuadParams;
  FillChar(Params, SizeOf(Params), 0);
  Params.Pos.Init(-0.425, 0);
  Params.Scale.Init(0.4, 0.4);
  Params.Rotation := sglRad(FAngleDeg);
  Params.View := FOpaqueView;
  DrawQuad(Params);

  Params.Pos.Init(0.425, 0);
  Params.Rotation := -sglRad(FAngleDeg);
  Params.View := FAlphaView;
  Params.Pipeline := FAlphaPip;
  DrawQuad(Params);

  { ...and the actual rendering }
  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  sglDraw;
  TDbgText.Draw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TBasisUApp.Init;
begin
  inherited;
  FPassaction.Colors[0].Init(TLoadAction.Clear, 0.25, 0.25, 1, 1);

  { Setup debug text }
  var DbgTextDesc := TDbgTextDesc.Create;
  DbgTextDesc.Fonts[0] := TDbgTextFont.Oric;
  DbgTextDesc.UseDelphiMemoryManager := True;
  DbgTextDesc.Logger := DbgTextDesc.DefaultLogger;
  TDbgText.Setup(DbgTextDesc);

  { Setup Sokol GL }
  var GLDesc := TGLDesc.Create;
  GLDesc.UseDelphiMemoryManager := True;
  GLDesc.Logger := GLDesc.DefaultLogger;
  sglSetup(GLDesc);

  { Setup Basis Universal via our own minimal wrapper code }
  TBasisU.Setup;

  { Create Sokol Gfx textures from the embedded Basis Universal textures }
  var ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := TBasisU.CreateImage(TRange.Create(EMBED_TESTCARD_BASIS));
  FOpaqueView := TView.Create(ViewDesc);
  ViewDesc.Texture.Image := TBasisU.CreateImage(TRange.Create(EMBED_TESTCARD_RGBA_BASIS));
  FAlphaView := TView.Create(ViewDesc);

  { Create a sampler object }
  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Linear;
  SamplerDesc.MagFilter := TFilter.Linear;
  SamplerDesc.MipmapFilter := TFilter.Linear;
  SamplerDesc.MaxAnisotropy := 8;
  FSampler := TSampler.Create(SamplerDesc);

  { A Sokol GL pipeline object for alpha-blended rendering }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Colors[0].WriteMask := TColorMask.Rgb;
  PipDesc.Colors[0].Blend.Enabled := True;
  PipDesc.Colors[0].Blend.SrcFactorRgb := TBlendFactor.SrcAlpha;
  PipDesc.Colors[0].Blend.DstFactorRgb := TBlendFactor.OneMinusSrcAlpha;
  FAlphaPip := TGLPipeline.Create(PipDesc);
end;

end.

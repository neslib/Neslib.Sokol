unit RestartApp;
{ Test whether 'restarting' works for various Sokol libraries (calling the
  shutdown methods, followed by initialization and continuing). There should be
  no crashes or memory leaks.

  This sample defines SOKOL_MEM_TRACK and uses the Neslib.Sokol.MemTrack unit
  to track memory allocations in the Sokol libraries. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.GL,
  Neslib.Sokol.Fetch,
  Neslib.Sokol.Audio,
  Neslib.Sokol.MemTrack,
  Neslib.Sokol.DebugText,
  Neslib.FastMath,
  Neslib.ModPlug,
  SampleApp,
  RestartShader;

const
  MOD_NUM_CHANNELS = 2;
  MOD_SRCBUF_SAMPLES = 16 * 1024;

type
  TScene = record
  public
    RX: Single;
    RY: Single;
    PassAction: TPassAction;
    Img: TImage;
    Pip: TPipeline;
    Bind: TBindings;
  public
    procedure Init;
    procedure Frame(const AWidth, AHeight: Integer);
  end;

type
  TMod = record
  public
    ModFile: TModPlugFile;
    IntBuf: array [0..MOD_SRCBUF_SAMPLES - 1] of Integer;
    FltBuf: array [0..MOD_SRCBUF_SAMPLES - 1] of Single;
  public
    procedure Init;
    procedure Free;
    procedure Frame;
  end;

type
  TIO = record
  public
    ImgBuffer: array [0..(256 * 1024) - 1] of Byte;
    ModBuffer: array [0..(512 * 1024) - 1] of Byte;
  private
    procedure FetchImageCallback(const AResponse: TFetchResponse);
    procedure FetchModCallback(const AResponse: TFetchResponse);
  public
    procedure Init;
  end;

type
  TRestartApp = class(TSampleApp)
  private
    FScene: TScene;
    FMod: TMod;
    FIO: TIO;
    FReset: Boolean;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure ConfigureGfx(var ADesc: TGfxDesc); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure KeyDown(const AKey: TKeyCode; const AModifiers: TModifiers;
      const AKeyRepeat: Boolean); override;
    procedure TouchesBegan(const ATouches: TTouches); override;
  end;

implementation

uses
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue,
  Neslib.ModPlug.Api,
  Neslib.Stb.Image;

type
  TVertex = record
  public
    X, Y, Z: Single;
    U, V: Int16;
  end;

const
  { Cube vertex buffer }
  CUBE_VERTICES: array [0..23] of TVertex = (
  // Pos                        UVs
    (X: -1.0; Y: -1.0; Z: -1.0; U:      0; V:     0),
    (X:  1.0; Y: -1.0; Z: -1.0; U:  32767; V:     0),
    (X:  1.0; Y:  1.0; Z: -1.0; U:  32767; V: 32767),
    (X: -1.0; Y:  1.0; Z: -1.0; U:      0; V: 32767),

    (X: -1.0; Y: -1.0; Z:  1.0; U:      0; V:     0),
    (X:  1.0; Y: -1.0; Z:  1.0; U:  32767; V:     0),
    (X:  1.0; Y:  1.0; Z:  1.0; U:  32767; V: 32767),
    (X: -1.0; Y:  1.0; Z:  1.0; U:      0; V: 32767),

    (X: -1.0; Y: -1.0; Z: -1.0; U:      0; V:     0),
    (X: -1.0; Y:  1.0; Z: -1.0; U:  32767; V:     0),
    (X: -1.0; Y:  1.0; Z:  1.0; U:  32767; V: 32767),
    (X: -1.0; Y: -1.0; Z:  1.0; U:      0; V: 32767),

    (X:  1.0; Y: -1.0; Z: -1.0; U:      0; V:     0),
    (X:  1.0; Y:  1.0; Z: -1.0; U:  32767; V:     0),
    (X:  1.0; Y:  1.0; Z:  1.0; U:  32767; V: 32767),
    (X:  1.0; Y: -1.0; Z:  1.0; U:      0; V: 32767),

    (X: -1.0; Y: -1.0; Z: -1.0; U:      0; V:     0),
    (X: -1.0; Y: -1.0; Z:  1.0; U:  32767; V:     0),
    (X:  1.0; Y: -1.0; Z:  1.0; U:  32767; V: 32767),
    (X:  1.0; Y: -1.0; Z: -1.0; U:      0; V: 32767),

    (X: -1.0; Y:  1.0; Z: -1.0; U:      0; V:     0),
    (X: -1.0; Y:  1.0; Z:  1.0; U:  32767; V:     0),
    (X:  1.0; Y:  1.0; Z:  1.0; U:  32767; V: 32767),
    (X:  1.0; Y:  1.0; Z: -1.0; U:      0; V: 32767));

const
  { Index buffer for the cube }
  CUBE_INDICES: array [0..35] of UInt16 = (
     0,  1,  2,   0,  2,  3,
     6,  5,  4,   7,  6,  4,
     8,  9, 10,   8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20);

var
  GX: Cardinal = $12345678;

function XorShift32: Cardinal;
begin
  Result := GX;

  Result := Result xor (Result shl 13);
  Result := Result xor (Result shr 17);
  Result := Result xor (Result shl 5);

  GX := Result;
end;

{ TRestartApp }

procedure TRestartApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'Restart Sokol Libs';
end;

procedure TRestartApp.Init;
begin
  inherited;
  { Setup Sokol libraries. Tweak setup params to reduce memory usage }
  var FetchDesc := TFetchDesc.Create;
  FetchDesc.MaxRequests := 2;
  FetchDesc.NumChannels := 2;
  FetchDesc.NumLanes := 1;
  FetchDesc.Logger := FetchDesc.DefaultLogger;
  FetchDesc.BaseDirectory := 'Data';
  TFetch.Setup(FetchDesc);

  var GLDesc := TGLDesc.Create;
  GLDesc.PipelinePoolSize := 1;
  GLDesc.MaxVertices := 16;
  GLDesc.MaxCommands := 16;
  GLDesc.UseDelphiMemoryManager := True;
  GLDesc.Logger := GLDesc.DefaultLogger;
  sglSetup(GLDesc);

  var DbgTextDesc := TDbgTextDesc.Create;
  DbgTextDesc.ContextPoolSize := 1;
  DbgTextDesc.Fonts[0] := TDbgTextFont.CPC;
  DbgTextDesc.Context.CharBufSize := 128;
  DbgTextDesc.UseDelphiMemoryManager := True;
  DbgTextDesc.Logger := DbgTextDesc.DefaultLogger;
  TDbgText.Setup(DbgTextDesc);

  var AudioDesc := TAudioDesc.Create;
  AudioDesc.NumChannels := MOD_NUM_CHANNELS;
  AudioDesc.UseDelphiMemoryManager := True;
  AudioDesc.Logger := AudioDesc.DefaultLogger;
  TAudio.Setup(AudioDesc);

  { Setup rendering resources }
  FScene.Init;
  FMod.Init;

  { Start loading files }
  FIO.Init;
end;

procedure TRestartApp.Frame;
begin
  if (FReset) then
  begin
    FReset := False;
    Cleanup;
    TGfx.Shutdown;
    Init;
  end;

  var W := FramebufferWidth;
  var H := FramebufferHeight;

  { Pump the Sokol Fetch message queues, and invoke response callbacks }
  TFetch.DoWork;

  { Print current memtracker state }
  var Allocations := TMemTrack.GetAllocations;
  TDbgText.Canvas(W * 0.5, H * 0.5);
  TDbgText.Origin(1, 2);
  {$IF Defined(IOS) or Defined(ANDROID)}
  TDbgText.WriteAnsiLn('TAP SCREEN TO RESTART!');
  {$ELSE}
  TDbgText.WriteAnsiLn('PRESS ''SPACE'' TO RESTART!');
  {$ENDIF}
  TDbgText.NewLine;
  TDbgText.WriteAnsiLn('Sokol Library Allocations:');
  TDbgText.NewLine;
  TDbgText.WriteLn('  Num:  %d', [Allocations.NumAllocations]);
  TDbgText.WriteLn('  Size: %d bytes', [Allocations.NumBytes]);
  TDbgText.NewLine;
  TDbgText.WriteAnsi('MOD: Combat Signal by ???');

  { Play audio }
  FMod.Frame;

  { Render scene }
  FScene.Frame(W, H);

  sglDraw;
  TDbgText.Draw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TRestartApp.Cleanup;
begin
  FMod.Free;
  TAudio.Shutdown;
  TDbgText.Shutdown;
  sglShutdown;
  TFetch.Shutdown;
  inherited;
end;

procedure TRestartApp.ConfigureGfx(var ADesc: TGfxDesc);
begin
  inherited;
  { Tweak setup params to reduce memory usage }
  ADesc.BufferPoolSize := 8;
  {$IFNDEF USE_DBG_UI}
  ADesc.ImagePoolSize := 4;
  ADesc.ShaderPoolSize := 4;
  ADesc.PipelinePoolSize := 8;
  ADesc.ViewPoolSize := 16;
  {$ENDIF}
end;

procedure TRestartApp.KeyDown(const AKey: TKeyCode;
  const AModifiers: TModifiers; const AKeyRepeat: Boolean);
begin
  inherited;
  if (AKey = TKeyCode.Space) then
    FReset := True;
end;

procedure TRestartApp.TouchesBegan(const ATouches: TTouches);
begin
  inherited;
  if (ATouches.Count = 1) then
    FReset := True;
end;

{ TScene }

procedure TScene.Frame(const AWidth, AHeight: Integer);
begin
  { Do some GL rendering }
  sglDefaults;
  sglViewport((AWidth - AHeight) div 2, 0, AHeight, AHeight, True);
  sglMatrixModeModelview;
  sglTranslate(FastSin(RX * 0.05) * 0.5, FastCos(RX * 0.1) * 0.5, 0);
  sglScale(0.5, 0.5, 1);
  sglBeginTriangles;
  sglV2F_C3B( 0.0,  0.5, 255, 0, 0);
  sglV2F_C3B(-0.5, -0.5, 0, 0, 255);
  sglV2F_C3B( 0.5, -0.5, 0, 255, 0);
  sglEnd;
  sglViewport(0, 0, AWidth, AHeight, True);

  { Compute model-view-projection matrix for the 3D scene }
  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), AWidth / AHeight, 0.01, 10.0);
  View.InitLookAtRH(Vector3(0, 1.5, 4), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  var VSParams: TVSParams;
  var T: Single := TApplication.Instance.FrameDuration * 60;
  RX := RX + (1 * T);
  RY := RY + (2 * T);
  var RXM, RYM: TMatrix4;
  RXM.InitRotationX(Radians(RX));
  RYM.InitRotationY(Radians(RY));
  var Model := RXM * RYM;
  VSParams.Mvp := ViewProj * Model;

  var Pass := TPass.Create;
  Pass.Action^ := PassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(Pip);
  TGfx.ApplyBindings(Bind);
  TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(0, 36);

  { NOTE: TGdx.EndPass is called later when other parts have been rendered. }
end;

procedure TScene.Init;
begin
  Img.Allocate;
  var View: TView;
  View.Allocate;
  Bind.Views[VIEW_TEX] := View;

  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(CUBE_VERTICES);
  BufferDesc.TraceLabel := 'cube-vertices';
  Bind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc := TBufferDesc.Create;
  BufferDesc.Usage.IndexBuffer := True;
  BufferDesc.Data := TRange.Create(CUBE_INDICES);
  BufferDesc.TraceLabel := 'cube-indices';
  Bind.IndexBuffer := TBuffer.Create(BufferDesc);

  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Linear;
  SamplerDesc.MagFilter := TFilter.Linear;
  Bind.Samplers[SMP_SMP] := TSampler.Create(SamplerDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(RestartShaderDesc);
  PipDesc.Layout.Attrs[ATTR_RESTART_POS].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_RESTART_TEXCOORD0].Format := TVertexFormat.Short2N;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.TraceLabel := 'cube-pipeline';
  Pip := TPipeline.Create(PipDesc);

  { Set a pseudo-random background color on each restart }
  var R: Single := ((XorShift32 and $3F) shl 2) / 255;
  var G: Single := ((XorShift32 and $3F) shl 2) / 255;
  var B: Single := ((XorShift32 and $3F) shl 2) / 255;
  PassAction.Colors[0].Init(TLoadAction.Clear, R, G, B);
end;

{ TMod }

procedure TMod.Frame;
begin
  { Play audio }
  var NumFrames := TAudio.Expect;
  if (NumFrames > 0) then
  begin
    var NumSamples := NumFrames * TAudio.NumChannels;
    if (NumSamples > MOD_SRCBUF_SAMPLES) then
      NumSamples := MOD_SRCBUF_SAMPLES;

    if (ModFile <> nil) then
    begin
      { NOTE: for multi-channel playback, the samples are interleaved
               (e.g. left/right/left/right/...) }
      var Res := ModFile.Read(IntBuf, SizeOf(Integer) * NumSamples);
      var NumSamplesInBuffer := Res div SizeOf(Integer);
      var I := 0;
      while (I < NumSamplesInBuffer) do
      begin
        FltBuf[I] := IntBuf[I] / $7FFFFFFF;
        Inc(I);
      end;
      while (I < NumSamples) do
      begin
        FltBuf[I] := 0;
        Inc(I);
      end;
    end
    else
    begin
      { If file wasn't loaded, fill the output buffer with silence }
      FillChar(FltBuf, NumSamples * SizeOf(Single), 0);
    end;
    TAudio.Push(@FltBuf, NumFrames);
  end;
end;

procedure TMod.Free;
begin
  ModFile.Free;
  ModFile := nil;
end;

procedure TMod.Init;
begin
  var Settings := TModPlug.Settings;
  Settings.Channels := TAudio.NumChannels;
  Settings.Bits := 32;
  Settings.Frequency := TAudio.SampleRate;
  Settings.ResamplingMode := TModPlugResamplingMode.Linear;
  Settings.MaxMixChannels := 64;
  Settings.LoopCount := -1;
  Settings.Flags := [TModPlugFlag.Oversampling];
  TModPlug.Settings := Settings;
end;

{ TIO }

procedure TIO.FetchImageCallback(const AResponse: TFetchResponse);
begin
  var App := TApplication.Instance as TRestartApp;
  if (AResponse.Fetched) then
  begin
    var StbImage := TStbImage.Create;
    try
      if (StbImage.Load(AResponse.Data.Ptr, AResponse.Data.Size, 4)) then
      begin
        var Image := App.FScene.Img;
        var ImageDesc := TImageDesc.Create;
        ImageDesc.Width := StbImage.Width;
        ImageDesc.Height := StbImage.Height;
        ImageDesc.PixelFormat := TPixelFormat.Rgba8;
        ImageDesc.Data.MipLevels[0] := TRange.Create(StbImage.Data,
          StbImage.Width * StbImage.Height * 4);
        Image.Setup(ImageDesc);

        var ViewDesc := TViewDesc.Create;
        ViewDesc.Texture.Image := Image;
        var View := App.FScene.Bind.Views[VIEW_TEX];
        View.Setup(ViewDesc);
      end;

    finally
      StbImage.Free;
    end;
  end
  else if (AResponse.Failed) then
  begin
    { If loading the file failed, set clear color to red }
    App.FScene.PassAction.Colors[0].Init(TLoadAction.Clear, 1, 0, 0);
  end;
end;

procedure TIO.FetchModCallback(const AResponse: TFetchResponse);
begin
  var App := TApplication.Instance as TRestartApp;
  if (AResponse.Fetched) then
  begin
    App.FMod.ModFile := TModPlugFile.Create;
    App.FMod.ModFile.Load(AResponse.Data.Ptr, AResponse.Data.Size);
  end
  else if (AResponse.Failed) then
  begin
    { If loading the file failed, set clear color to red }
    App.FScene.PassAction.Colors[0].Init(TLoadAction.Clear, 1, 0, 0);
  end;
end;

procedure TIO.Init;
begin
  { Start loading files }
  var Request := TFetchRequest.Create('baboon.png', FetchImageCallback,
    TFetchRange.Create(ImgBuffer));
  Request.Send;

  Request := TFetchRequest.Create('comsi.s3m', FetchModCallback,
    TFetchRange.Create(ModBuffer));
  Request.Send;
end;

end.

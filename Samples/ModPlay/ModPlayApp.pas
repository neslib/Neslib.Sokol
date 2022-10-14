unit ModPlayApp;
{ Neslib.Sokol.App + Neslib.Sokol.Audio + Neslib.LibModPlug }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Audio,
  Neslib.ModPlug,
  SampleApp;

{ Define to use push-from-mainthread model.
  Otherwise, a stream callback (pull) model is used. }
{.$DEFINE USE_PUSH}

const
  { Select between mono (1) and stereo (2) }
  NUM_CHANNELS = 2;

  { Big enough for PacketSize * NumPackets * NumChannels }
  SRC_BUF_SAMPLES = 16 * 1024;

type
  TModPlayApp = class(TSampleApp)
  private
    FModPlugFile: TModPlugFile;
    FIntBuf: array [0..SRC_BUF_SAMPLES - 1] of Integer;
    {$IFDEF USE_PUSH}
    FFltBuf: array [0..SRC_BUF_SAMPLES - 1] of Single;
    {$ENDIF}
  private
    {$IFNDEF USE_PUSH}
    procedure StreamCallback(const ABuffer: PAudioSample; const ANumFrames,
      ANumChannels: Integer);
    {$ENDIF}
    procedure ReadSamples(const ABuffer: PAudioSample;
      const ANumSamples: Integer);
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  System.SysUtils,
  Neslib.Sokol.Api,
  Neslib.ModPlug.Api,
  Mods;

{ TModPlayApp }

procedure TModPlayApp.Cleanup;
begin
  inherited;
  TAudio.Shutdown;
  FModPlugFile.Free;
end;

procedure TModPlayApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 400;
  AConfig.Height := 300;
  AConfig.AndroidForceGles2 := True;
  AConfig.WindowTitle := 'Sokol Audio + LibModPlug';
end;

procedure TModPlayApp.Frame;
begin
  {$IFDEF USE_PUSH}
  { Alternative way to get audio data into Sokol Audio: push the data from the
    main thread. This appends the sample data to a ring buffer where the audio
    thread will pull from.

    NOTE: if your application generates new samples at the same rate they are
    consumed (e.g. a steady 44100 frames per second, you don't need the call
    to TAudio.Expect. Instead just call TAudio.Push as new sample data gets
    generated. }
  var NumFrames := TAudio.Expect;
  if (NumFrames > 0) then
  begin
    var NumSamples := NumFrames * TAudio.NumChannels;
    ReadSamples(@FFltBuf, NumSamples);
    TAudio.Push(@FFltBuf, NumFrames);
  end;
  {$ENDIF}

  var PassAction := TPassAction.Create;
  PassAction.Colors[0].Init(TAction.Clear, 0.4, 0.7, 1);

  TGfx.BeginDefaultPass(PassAction, FramebufferWidth, FramebufferHeight);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TModPlayApp.Init;
begin
  inherited;
  { Setup Sokol Audio (default sample rate is 44100Hz) }
  var AudioDesc := TAudioDesc.Create;
  AudioDesc.NumChannels := NUM_CHANNELS;
  {$IFNDEF USE_PUSH}
  AudioDesc.OnStream := StreamCallback;
  {$ENDIF}
  TAudio.Setup(AudioDesc);

  { Setup libmodplug and load mod from embedded array }
  var MPSettings := TModPlug.Settings;
  MPSettings.Channels := TAudio.NumChannels;
  MPSettings.Bits := 32;
  MPSettings.Frequency := TAudio.SampleRate;
  MPSettings.ResamplingMode := TModPlugResamplingMode.Linear;
  MPSettings.MaxMixChannels := 64;
  MPSettings.LoopCount := -1; { loop play seems to be disabled in current libmodplug }
  MPSettings.Flags := [TModPlugFlag.Oversampling];
  TModPlug.Settings := MPSettings;

  FModPlugFile := TModPlugFile.Create;
  if (not FModPlugFile.Load(@EMBED_DISCO_FEVA_BABY_S3M, Length(EMBED_DISCO_FEVA_BABY_S3M))) then
    FreeAndNil(FModPlugFile);
end;

procedure TModPlayApp.ReadSamples(const ABuffer: PAudioSample;
  const ANumSamples: Integer);
{ Common method to read sample stream from libmodplug and convert to float }
begin
  Assert(ANumSamples <= SRC_BUF_SAMPLES);
  if Assigned(FModPlugFile) then
  begin
    { NOTE: for multi-channel playback, the samples are interleaved (e.g.
      left/right/left/right/...) }
    var Res := FModPlugFile.Read(FIntBuf, ANumSamples * SizeOf(Integer));
    var SamplesInBuffer := Res div SizeOf(Integer);
    var I := 0;
    while (I < SamplesInBuffer) do
    begin
      ABuffer[I] := FIntBuf[I] / $7FFFFFFF;
      Inc(I);
    end;
    while (I < ANumSamples) do
    begin
      ABuffer[I] := 0;
      Inc(I);
    end;
  end
  else
  begin
    { If file wasn't loaded, fill the output buffer with silence }
    FillChar(ABuffer^, ANumSamples * SizeOf(Single), 0);
  end;
end;

{$IFNDEF USE_PUSH}
procedure TModPlayApp.StreamCallback(const ABuffer: PAudioSample;
  const ANumFrames, ANumChannels: Integer);
{ Called by Sokol Audio when new samples are needed.
  This runs on a separate thread. }
begin
  var NumSamples := ANumFrames * ANumChannels;
  ReadSamples(ABuffer, NumSamples);
end;
{$ENDIF}

end.

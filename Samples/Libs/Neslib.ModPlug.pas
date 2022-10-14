unit Neslib.ModPlug;
{ Delphi wrapper for libmodplug (https://github.com/Konstanty/libmodplug) }

interface

uses
  System.SysUtils,
  Neslib.ModPlug.Api;

type
  { Type of module }
  TModType = (
    None = $00,
    &MOD = $01,
    S3M  = $02,
    XM   = $04,
    MED  = $08,
    MTM  = $10,
    IT   = $20,
    _669 = $40,
    ULT  = $80,
    STM  = $100,
    &FAR = $200,
    WAV  = $400,
    AMF  = $800,
    AMS  = $1000,
    DSM  = $2000,
    MDL  = $4000,
    OKT  = $8000,
    MID  = $10000,
    DMF  = $20000,
    PTM  = $40000,
    DBM  = $80000,
    MT2  = $100000,
    AMF0 = $200000,
    PSM  = $400000,
    J2B  = $800000,
    ABC  = $1000000,
    PAT  = $2000000);

type
  TModPlugFlag = (
    { Enable oversampling (*highly* recommended) }
    Oversampling,

    { Enable noise reduction }
    NoiseReduction,

    { Enable reverb }
    Reverb,

    { Enable megabass }
    Megabass,

    { Enable surround sound }
    Surround);
  TModPlugFlags = set of TModPlugFlag;

type
  TModPlugResamplingMode = (
    { No interpolation (very fast, extremely bad sound quality) }
    Nearest,

    { Linear interpolation (fast, good quality) }
    Linear,

    { Cubic spline interpolation (high quality) }
    Spline,

    { 8-tap fir filter (extremely high quality) }
    Fir);

type
  { Note that ModPlug always decodes sound at 44100kHz, 32 bit, stereo and then
    down-mixes to the settings you choose. }
  TModPlugSettings = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _ModPlug_Settings;
    function GetFlags: TModPlugFlags; inline;
    function GetResamplingMode: TModPlugResamplingMode; inline;
    procedure SetFlags(const AValue: TModPlugFlags); inline;
    procedure SetResamplingMode(const AValue: TModPlugResamplingMode); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Various flags }
    property Flags: TModPlugFlags read GetFlags write SetFlags;

    { Number of channels (1 for mono or 2 for stereo) }
    property Channels: Integer read FHandle.mChannels write FHandle.mChannels;

    { Bits per sample (8, 16, or 32) }
    property Bits: Integer read FHandle.mBits write FHandle.mBits;

    { Sampling rate (11025, 22050, or 44100) }
    property Frequency: Integer read FHandle.mFrequency write FHandle.mFrequency;

    { Resampling mode (speed vs. quality) }
    property ResamplingMode: TModPlugResamplingMode read GetResamplingMode write SetResamplingMode;

    { Stereo separation (1 - 256) }
    property StereoSeparation: Integer read FHandle.mStereoSeparation write FHandle.mStereoSeparation;

    { Maximum number of mixing channels (polyphony, 32 - 256) }
    property MaxMixChannels: Integer read FHandle.mMaxMixChannels write FHandle.mMaxMixChannels;

    { Reverb level (0 (quiet) - 100 (loud)) }
    property ReverbDepth: Integer read FHandle.mReverbDepth write FHandle.mReverbDepth;

    { Reverb delay in ms (usually 40-200ms) }
    property ReverbDelay: Integer read FHandle.mReverbDelay write FHandle.mReverbDelay;

    { XBass level (0 (quiet) - 100 (loud)) }
    property BassAmount: Integer read FHandle.mBassAmount write FHandle.mBassAmount;

    { XBass cutoff in Hz (10-100) }
    property BassRange: Integer read FHandle.mBassRange write FHandle.mBassRange;

    { Surround level (0 (quiet) - 100 (heavy)) }
    property SurroundDepth: Integer read FHandle.mSurroundDepth write FHandle.mSurroundDepth;

    { Surround delay in ms (usually 5-40ms) }
    property SurroundDelay: Integer read FHandle.mSurroundDelay write FHandle.mSurroundDelay;

    { Number of times to loop. 0 prevents looping. -1 loops forever. }
    property LoopCount: Integer read FHandle.mLoopCount write FHandle.mLoopCount;
  end;

type
  TModPlugNote = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _ModPlugNote;
  {$ENDREGION 'Internal Declarations'}
  public
    property Note: Byte read FHandle.Note;
    property Instrument: Byte read FHandle.Instrument;
    property VolumeEffect: Byte read FHandle.VolumeEffect;
    property Effect: Byte read FHandle.Effect;
    property Volume: Byte read FHandle.Volume;
    property Parameter: Byte read FHandle.Parameter;
  end;
  PModPlugNote = ^TModPlugNote;

type
  { Mixer callback.

    Parameters:
      ABuffer: buffer of mixed samples (signed 32-bit integers).
      ANumChannels: number of channels in the buffer.
      ANumSamples: number of samples in the buffer (without taking case of
        ANumChannels) }
  TModPlugMixerCallback = procedure(ABuffer: PInteger; ANumChannels, ANumSamples: Integer); cdecl;

type
  TModPlugFile = class
  {$REGION 'Internal Declarations'}
  private
    FHandle: _PModPlugFile;
    FName: String;
    FDurationMs: Integer;
    function GetMasterVolume: Integer; inline;
    procedure SetMasterVolume(const AValue: Integer); inline;
    function GetCurrentOrder: Integer; inline;
    procedure SetCurrentOrder(const AValue: Integer); inline;
    function GetCurrentPattern: Integer; inline;
    function GetCurrentRow: Integer; inline;
    function GetCurrentSpeed: Integer; inline;
    function GetCurrentTempo: Integer; inline;
    function GetPlayingChannels: Integer; inline;
    function GetModuleType: TModType; inline;
    function GetMessage: String; inline;
    function GetNumInstruments: Integer; inline;
    function GetInstrumentName(const AInstrument: Integer): String; inline;
    function GetNumSamples: Integer; inline;
    function GetSampleName(const ASample: Integer): String; inline;
    function GetNumPatterns: Integer; inline;
    function GetPattern(const APattern: Integer): PModPlugNote; overload; inline;
    function GetNumChannels: Integer; inline;
  private
    procedure Clear;
  {$ENDREGION 'Internal Declarations'}
  public
    destructor Destroy; override;

    { Load a mod file.
      Returns True on success, or False on failure.
      All other methods don't do anything if Load returned False. }
    function Load(const AData: TBytes): Boolean; overload;
    function Load(const AData: Pointer; const ASize: Integer): Boolean; overload;

    { Read sample data into the buffer. Returns the number of bytes read. If the
      end of the mod has been reached, zero is returned. }
    function Read(var ABuffer; const ASize: Integer): Integer; inline;

    { Seek to a particular position in the song. Note that seeking and MODs
      don't mix very well. Some mods will be missing instruments for a short
      time after a seek, as ModPlug does not scan the sequence backwards to find
      out which instruments were supposed to be playing at that time. (Doing so
      would be difficult and not very reliable.) Also, note that seeking is not
      very exact in some mods -- especially those for which DurationMs does not
      report the full length. }
    procedure Seek(const APositionMs: Integer); inline;

    { Retrieve pattern note data }
    function GetPattern(const APattern: Integer; out ANumRows: Integer): PModPlugNote; overload; inline;

    { Use this callback if you want to 'modify' the mixed data of LibModPlug }
    procedure SetMixerCallback(const ACallback: TModPlugMixerCallback);

    { The name of the mod }
    property Name: String read FName;

    { The duration of the mod, in milliseconds. Note that this value is not
      always accurate, especially in the case of mods with loops. }
    property DurationMs: Integer read FDurationMs;

    { Master Volume (1-512) }
    property MasterVolume: Integer read GetMasterVolume write SetMasterVolume;

    property CurrentSpeed: Integer read GetCurrentSpeed;
    property CurrentTempo: Integer read GetCurrentTempo;
    property CurrentOrder: Integer read GetCurrentOrder write SetCurrentOrder;
    property CurrentPattern: Integer read GetCurrentPattern;
    property CurrentRow: Integer read GetCurrentRow;
    property PlayingChannels: Integer read GetPlayingChannels;
    property ModuleType: TModType read GetModuleType;
    property Message: String read GetMessage;
    property NumInstruments: Integer read GetNumInstruments;
    property InstrumentNames[const AInstrument: Integer]: String read GetInstrumentName;
    property NumSamples: Integer read GetNumSamples;
    property SampleNames[const ASample: Integer]: String read GetSampleName;
    property NumPatterns: Integer read GetNumPatterns;
    property Patterns[const APattern: Integer]: PModPlugNote read GetPattern;
    property NumChannels: Integer read GetNumChannels;
  end;

type
  { ModPlug globals }
  TModPlug = record
  {$REGION 'Internal Declarations'}
  private
    class function GetSettings: TModPlugSettings; static;
    class procedure SetSettings(const AValue: TModPlugSettings); static;
  {$ENDREGION 'Internal Declarations'}
  public
    { Global mod decoder settings. All options, except for channels,
      bits-per-sample, sampling rate, and loop count, will take effect
      immediately. Those options which don't take effect immediately will take
      effect the next time you load a mod. }
    class property Settings: TModPlugSettings read GetSettings write SetSettings;
  end;

implementation

{ TModPlugSettings }

function TModPlugSettings.GetFlags: TModPlugFlags;
begin
  Byte(Result) := FHandle.mFlags;
end;

function TModPlugSettings.GetResamplingMode: TModPlugResamplingMode;
begin
  Result := TModPlugResamplingMode(FHandle.mResamplingMode);
end;

procedure TModPlugSettings.SetFlags(const AValue: TModPlugFlags);
begin
  FHandle.mFlags := Byte(AValue);
end;

procedure TModPlugSettings.SetResamplingMode(
  const AValue: TModPlugResamplingMode);
begin
  FHandle.mResamplingMode := Ord(AValue);
end;

{ TModPlugFile }

procedure TModPlugFile.Clear;
begin
  if (FHandle <> nil) then
  begin
    _ModPlug_Unload(FHandle);
    FHandle := nil;
  end;
  FName := '';
  FDurationMs := 0;
end;

destructor TModPlugFile.Destroy;
begin
  Clear;
  inherited;
end;

function TModPlugFile.GetCurrentOrder: Integer;
begin
  if (FHandle = nil) then
    Result := 0
  else
    Result := _ModPlug_GetCurrentOrder(FHandle);
end;

function TModPlugFile.GetCurrentPattern: Integer;
begin
  if (FHandle = nil) then
    Result := 0
  else
    Result := _ModPlug_GetCurrentPattern(FHandle);
end;

function TModPlugFile.GetCurrentRow: Integer;
begin
  if (FHandle = nil) then
    Result := 0
  else
    Result := _ModPlug_GetCurrentRow(FHandle);
end;

function TModPlugFile.GetCurrentSpeed: Integer;
begin
  if (FHandle = nil) then
    Result := 0
  else
    Result := _ModPlug_GetCurrentSpeed(FHandle);
end;

function TModPlugFile.GetCurrentTempo: Integer;
begin
  if (FHandle = nil) then
    Result := 0
  else
    Result := _ModPlug_GetCurrentTempo(FHandle);
end;

function TModPlugFile.GetInstrumentName(const AInstrument: Integer): String;
var
  Buf: array [0..40] of AnsiChar;
begin
  if (FHandle = nil) then
    Result := ''
  else
  begin
    var Len := _ModPlug_InstrumentName(FHandle, AInstrument, @Buf);
    var S: AnsiString;
    SetString(S, PAnsiChar(@Buf), Len);
    Result := String(S);
  end;
end;

function TModPlugFile.GetMasterVolume: Integer;
begin
  if (FHandle = nil) then
    Result := 0
  else
    Result := _ModPlug_GetMasterVolume(FHandle);
end;

function TModPlugFile.GetMessage: String;
begin
  if (FHandle = nil) then
    Result := ''
  else
    Result := String(AnsiString(_ModPlug_GetMessage(FHandle)));
end;

function TModPlugFile.GetModuleType: TModType;
begin
  if (FHandle = nil) then
    Result := TModType.None
  else
    Result := TModType(_ModPlug_GetModuleType(FHandle));
end;

function TModPlugFile.GetNumChannels: Integer;
begin
  if (FHandle = nil) then
    Result := 0
  else
    Result := _ModPlug_NumChannels(FHandle);
end;

function TModPlugFile.GetNumInstruments: Integer;
begin
  if (FHandle = nil) then
    Result := 0
  else
    Result := _ModPlug_NumInstruments(FHandle);
end;

function TModPlugFile.GetNumPatterns: Integer;
begin
  if (FHandle = nil) then
    Result := 0
  else
    Result := _ModPlug_NumPatterns(FHandle);
end;

function TModPlugFile.GetNumSamples: Integer;
begin
  if (FHandle = nil) then
    Result := 0
  else
    Result := _ModPlug_NumSamples(FHandle);
end;

function TModPlugFile.GetPattern(const APattern: Integer): PModPlugNote;
begin
  if (FHandle = nil) then
    Result := nil
  else
    Result := PModPlugNote(_ModPlug_GetPattern(FHandle, APattern, nil));
end;

function TModPlugFile.GetPattern(const APattern: Integer;
  out ANumRows: Integer): PModPlugNote;
begin
  if (FHandle = nil) then
    Result := nil
  else
    Result := PModPlugNote(_ModPlug_GetPattern(FHandle, APattern, @ANumRows));
end;

function TModPlugFile.GetPlayingChannels: Integer;
begin
  if (FHandle = nil) then
    Result := 0
  else
    Result := _ModPlug_GetPlayingChannels(FHandle);
end;

function TModPlugFile.GetSampleName(const ASample: Integer): String;
var
  Buf: array [0..40] of AnsiChar;
begin
  if (FHandle = nil) then
    Result := ''
  else
  begin
    var Len := _ModPlug_SampleName(FHandle, ASample, @Buf);
    var S: AnsiString;
    SetString(S, PAnsiChar(@Buf), Len);
    Result := String(S);
  end;
end;

function TModPlugFile.Load(const AData: Pointer; const ASize: Integer): Boolean;
begin
  Clear;
  FHandle := _ModPlug_Load(AData, ASize);
  Result := (FHandle <> nil);

  if (Result) then
  begin
    FName := String(AnsiString(_ModPlug_GetName(FHandle)));
    FDurationMs := _ModPlug_GetLength(FHandle);
  end;
end;

function TModPlugFile.Read(var ABuffer; const ASize: Integer): Integer;
begin
  if (FHandle = nil) then
    Result := 0
  else
    Result := _ModPlug_Read(FHandle, @ABuffer, ASize);
end;

procedure TModPlugFile.Seek(const APositionMs: Integer);
begin
  if (FHandle <> nil) then
    _ModPlug_Seek(FHandle, APositionMs);
end;

procedure TModPlugFile.SetCurrentOrder(const AValue: Integer);
begin
  if (FHandle <> nil) then
    _ModPlug_SeekOrder(FHandle, AValue);
end;

procedure TModPlugFile.SetMasterVolume(const AValue: Integer);
begin
  if (FHandle <> nil) then
    _ModPlug_SetMasterVolume(FHandle, AValue);
end;

procedure TModPlugFile.SetMixerCallback(const ACallback: TModPlugMixerCallback);
var
  MixerProc: _ModPlugMixerProc absolute ACallback;
begin
  if Assigned(FHandle) then
  begin
    if Assigned(ACallback) then
      _ModPlug_InitMixerCallback(FHandle, MixerProc)
    else
      _ModPlug_UnloadMixerCallback(FHandle);
  end;
end;

function TModPlugFile.Load(const AData: TBytes): Boolean;
begin
  Result := Load(Pointer(AData), Length(AData));
end;

{ TModPlug }

class function TModPlug.GetSettings: TModPlugSettings;
begin
  _ModPlug_GetSettings(@Result.FHandle);
end;

class procedure TModPlug.SetSettings(const AValue: TModPlugSettings);
begin
  _ModPlug_SetSettings(@AValue.FHandle);
end;

end.

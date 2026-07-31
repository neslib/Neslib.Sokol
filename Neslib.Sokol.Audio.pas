unit Neslib.Sokol.Audio;
{ Cross-platform audio-streaming API.

  For a user guide, check out the Neslib.Sokol.Audio.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.Audio.md }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.Sokol.Api,
  Neslib.Sokol.Types;

type
  {$POINTERMATH ON}
  TAudioSample = type Single;
  PAudioSample = ^TAudioSample;
  {$POINTERMATH OFF}

type
  { An enum with a unique item for each log message, warning, error and
    validation layer message. Note that these messages are only visible when a
    logger function is installed in the SokolImGui.Setup call. }
  TAudioLogItem = (
    Ok,
    MallocFailed,
    AlsaSndPcmOpenFailed,
    AlsaFloatSamplesNotSupported,
    AlsaRequestedBufferSizeNotSupported,
    AlsaRequestedChannelCountNotSupported,
    AlsaSndPcmHwParamsSetRateNearFailed,
    AlsaSndPcmHwParamsFailed,
    AlsaPthreadCreateFailed,
    WasapiCreateEventFailed,
    WasapiCreateDeviceEnumeratorFailed,
    WasapiGetDefaultAudioEndpointFailed,
    WasapiDeviceActivateFailed,
    WasapiAudioClientInitializeFailed,
    WasapiAudioClientGetBufferSizeFailed,
    WasapiAudioClientGetServiceFailed,
    WasapiAudioClientSetEventHandleFailed,
    WasapiCreateThreadFailed,
    AAudioStreambuilderOpenStreamFailed,
    AAudioPthreadCreateFailed,
    AAudioRestartingStreamAfterError,
    UsingAAudioBackend,
    AAudioCreateStreambuilderFailed,
    CoreAudioNewOutputFailed,
    CoreAudioAllocateBufferFailed,
    CoreAudioStartFailed,
    BackendBufferSizeIsntMultipleOfPacketSize,
    VitaSceaudioOpenFailed,
    VitaPthreadCreateFailed,
    N3DsNdspOpenFailed);

type
  _TAudioLogItemHelper = record helper for TAudioLogItem
  public
    function ToString: String;
  end;

type
  { Used in TAudioDesc to provide a logging function. Please be aware that
    without logging function, Neslib.Sokol.Audio will be completely silent, e.g.
    it will not report errors and warnings. For maximum error verbosity, compile
    in debug mode and provide a compatible logger function in the TAudio.Setup
    call (for instance the standard logging function TAudioDesc.DefaultLogger).

    Parameters:
    * ALevel: log level
    * AItem: log item
    * AMessage: the log message corresponding to AItem.
    * ALineNr: line number in original sokol_audio.h file. }
  TAudioLogger = procedure(const ALevel: TLogLevel; const AItem: TAudioLogItem;
    const AMessage: String; const ALineNr: Integer) of object;

type
  { Streaming callback event }
  TAudioStreamEvent = procedure(const ABuffer: PAudioSample; const ANumFrames,
    ANumChannels: Integer) of object;

type
  TAudioWin32Desc = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _saudio_win32_desc;
  {$ENDREGION 'Internal Declarations'}
  public
    { When True sokol-audio will not call CoInitializeEx/CoUninitialze }
    property SkipCoinitialize: Boolean read FHandle.skip_coinitialize write FHandle.skip_coinitialize;
  end;

type
  { Audio session settings }
  TAudioDesc = record
  {$REGION 'Internal Declarations'}
  private class var
    GLogger: TAudioLogger;
  private
    procedure Convert(out ADst: _saudio_desc);
  private
    class procedure LogCallback(const ATag: PUTF8Char; ALogLevel,
      ALogItemId: UInt32; const AMessageOrNull: PUTF8Char; ALineNr: UInt32;
      const AFilenameOrNull: PUTF8Char; AUserData: Pointer); cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    { Requested sample rate }
    SampleRate: Integer;

    { Number of channels. Default: 1 (mono) }
    NumChannels: Integer;

    { Number of frames in streaming buffer }
    BufferFrames: Integer;

    { Number of frames in a packet }
    PacketFrames: Integer;

    { Number of packets in packet queue }
    NumPackets: Integer;

    { Optional streaming callback event }
    OnStream: TAudioStreamEvent;

    { Optional config options for windows }
    Win32: TAudioWin32Desc;

    { Whether to use Delphi's memory manager instead of Sokol's internal one.
      When SOKOL_MEM_TRACK is defined, it always uses Delphi's memory manager.
      Default: False }
    UseDelphiMemoryManager: Boolean;

    { Optional log function override }
    Logger: TAudioLogger;
  public
    { Initialize with default values }
    class function Create: TAudioDesc; static;
    procedure Init; inline;

    { A default log function you can assign to the Logger field. }
    procedure DefaultLogger(const ALevel: TLogLevel; const AItem: TAudioLogItem;
      const AMessage: String; const ALineNr: Integer);
  end;
  PAudioDesc = ^TAudioDesc;

type
  { Main entry point for audio streaming }
  TAudio = record // static
  {$REGION 'Internal Declarations'}
  private class var
    FOnStream: TAudioStreamEvent;
  private
    class function GetIsValid: Boolean; inline; static;
    class function GetSampleRate: Integer; inline; static;
    class function GetBufferFrames: Integer; inline; static;
    class function GetNumChannels: Integer; inline; static;
  private
    class procedure StreamCallback(Buffer: PSingle; NumFrames,
      NumChannels: Integer); cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    { Setup Sokol Audio }
    class procedure Setup(const ADesc: TAudioDesc); static;

    { Shutdown Sokol Audio }
    class procedure Shutdown; static;

    { Current number of frames to fill packet queue }
    class function Expect: Integer; inline; static;

    { Push sample frames from main thread.
      Returns number of frames actually pushed. }
    class function Push(const AFrames: PAudioSample;
      const ANumFrames: Integer): Integer; overload; inline; static;
    class function Push(const AFrames: TArray<TAudioSample>): Integer; overload; inline; static;

    { True after Setup if audio backend was successfully initialized }
    class property IsValid: Boolean read GetIsValid;

    { Actual sample rate }
    class property SampleRate: Integer read GetSampleRate;

    { Actual backend buffer size in number of frames }
    class property BufferFrames: Integer read GetBufferFrames;

    { Actual number of channels }
    class property NumChannels: Integer read GetNumChannels;
  end;

implementation

uses
  {$IF Defined(ANDROID)}
  Androidapi.OpenSles,
  {$ENDIF}
  {$IFDEF SOKOL_MEM_TRACK}
  Neslib.Sokol.MemTrack,
  {$ENDIF}
  Neslib.Sokol.Utils;

{$IF Defined(MACOS_ONLY)}
{ Link AudioToolbox framework }

const
  libAudioToolbox = '/System/Library/Frameworks/AudioToolbox.framework/AudioToolbox';

procedure AudioToolboxDummy; external libAudioToolbox name 'AudioQueueStart';
{$ENDIF}

{ _TAudioLogItemHelper }

function _TAudioLogItemHelper.ToString: String;
const
  STRINGS: array [TAudioLogItem] of String = (
    'Ok',
    'memory allocation failed',
    'snd_pcm_open() failed',
    'floating point sample format not supported',
    'requested buffer size not supported',
    'requested channel count not supported',
    'snd_pcm_hw_params_set_rate_near() failed',
    'snd_pcm_hw_params() failed',
    'pthread_create() failed',
    'CreateEvent() failed',
    'CoCreateInstance() for IMMDeviceEnumerator failed',
    'IMMDeviceEnumerator.GetDefaultAudioEndpoint() failed',
    'IMMDevice.Activate() failed',
    'IAudioClient.Initialize() failed',
    'IAudioClient.GetBufferSize() failed',
    'IAudioClient.GetService() failed',
    'IAudioClient.SetEventHandle() failed',
    'CreateThread() failed',
    'AAudioStreamBuilder_openStream() failed',
    'pthread_create() failed after AAUDIO_ERROR_DISCONNECTED',
    'restarting AAudio stream after error',
    'using AAudio backend',
    'AAudio_createStreamBuilder() failed',
    'AudioQueueNewOutput() failed',
    'AudioQueueAllocateBuffer() failed',
    'AudioQueueStart() failed',
    'backend buffer size isn''t multiple of packet size',
    'sceAudioOutOpenPort() failed',
    'pthread_create() failed',
    'ndspInit() failed');
begin
  Result := STRINGS[Self];
end;

{ TAudioDesc }

procedure TAudioDesc.Convert(out ADst: _saudio_desc);
begin
  FillChar(ADst, SizeOf(ADst), 0);
  ADst.sample_rate := SampleRate;
  ADst.num_channels := NumChannels;
  ADst.buffer_frames := BufferFrames;
  ADst.packet_frames := PacketFrames;
  ADst.num_packets := NumPackets;

  if Assigned(OnStream) then
  begin
    TAudio.FOnStream := OnStream;
    ADst.stream_cb := TAudio.StreamCallback;
  end;

  ADst.win32.skip_coinitialize := Win32.SkipCoinitialize;

  {$IFDEF SOKOL_MEM_TRACK}
  ADst.allocator.alloc_fn := _MemTrackAlloc;
  ADst.allocator.free_fn := _MemTrackFree;
  {$ELSE}
  if (UseDelphiMemoryManager) then
  begin
    ADst.allocator.alloc_fn := _AllocCallback;
    ADst.allocator.free_fn := _FreeCallback;
  end;
  {$ENDIF}

  if Assigned(Logger) then
  begin
    GLogger := Logger;
    ADst.logger.func := LogCallback;
  end
end;

class function TAudioDesc.Create: TAudioDesc;
begin
  Result.Init;
end;

procedure TAudioDesc.DefaultLogger(const ALevel: TLogLevel;
  const AItem: TAudioLogItem; const AMessage: String; const ALineNr: Integer);
begin
  _LogDefault(ALevel, Ord(AItem), AMessage, ALineNr);
end;

procedure TAudioDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

class procedure TAudioDesc.LogCallback(const ATag: PUTF8Char; ALogLevel,
  ALogItemId: UInt32; const AMessageOrNull: PUTF8Char; ALineNr: UInt32;
  const AFilenameOrNull: PUTF8Char; AUserData: Pointer);
begin
  Assert(Assigned(GLogger));
  var Msg: String;
  if (ALogItemId <= Cardinal(Ord(High(TAudioLogItem)))) then
    Msg := TAudioLogItem(ALogItemId).ToString
  else
    Msg := String(UTF8String(AMessageOrNull));

  GLogger(TLogLevel(ALogLevel), TAudioLogItem(ALogItemId), Msg, ALineNr);
end;

{ TAudio }

class function TAudio.Expect: Integer;
begin
  Result := _saudio_expect;
end;

class function TAudio.GetBufferFrames: Integer;
begin
  Result := _saudio_buffer_frames;
end;

class function TAudio.GetIsValid: Boolean;
begin
  Result := _saudio_isvalid;
end;

class function TAudio.GetNumChannels: Integer;
begin
  Result := _saudio_channels;
end;

class function TAudio.GetSampleRate: Integer;
begin
  Result := _saudio_sample_rate;
end;

class function TAudio.Push(const AFrames: TArray<TAudioSample>): Integer;
begin
  Result := _saudio_push(Pointer(AFrames), Length(AFrames));
end;

class function TAudio.Push(const AFrames: PAudioSample;
  const ANumFrames: Integer): Integer;
begin
  Result := _saudio_push(Pointer(AFrames), ANumFrames);
end;

class procedure TAudio.Setup(const ADesc: TAudioDesc);
begin
  var Desc: _saudio_desc;
  ADesc.Convert(Desc);
  _saudio_setup(@Desc);
end;

class procedure TAudio.Shutdown;
begin
  _saudio_shutdown;
end;

class procedure TAudio.StreamCallback(Buffer: PSingle; NumFrames,
  NumChannels: Integer);
begin
  Assert(Assigned(FOnStream));
  FOnStream(PAudioSample(Buffer), NumFrames, NumChannels);
end;

end.

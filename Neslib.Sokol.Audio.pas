unit Neslib.Sokol.Audio;
{ Cross-platform audio-streaming API.

  For a user guide, check out the Neslib.Sokol.Audio.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.Audio.md }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.Sokol.Api;

type
  {$POINTERMATH ON}
  TAudioSample = type Single;
  PAudioSample = ^TAudioSample;
  {$POINTERMATH OFF}

type
  { Streaming callback event }
  TAudioStreamEvent = procedure(const ABuffer: PAudioSample; const ANumFrames,
    ANumChannels: Integer) of object;

type
  { Audio session settings }
  TAudioDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _saudio_desc);
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

    { Whether to use Delphi's memory manager instead of Sokol's internal one.
      When SOKOL_MEM_TRACK is defined, it always uses Delphi's memory manager.
      Default: False }
    UseDelphiMemoryManager: Boolean;
  public
    { Initialize with default values }
    class function Create: TAudioDesc; static;
    procedure Init; inline;
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
  Neslib.Sokol.MemTrack;
  {$ELSE}
  Neslib.Sokol.Utils;
  {$ENDIF}

{$IF Defined(MACOS_ONLY)}
{ Link AudioToolbox framework }

const
  libAudioToolbox = '/System/Library/Frameworks/AudioToolbox.framework/AudioToolbox';

procedure AudioToolboxDummy; external libAudioToolbox name 'AudioQueueStart';
{$ENDIF}

{ TAudioDesc }

procedure TAudioDesc.Convert(out ADst: _saudio_desc);
begin
  ADst.sample_rate := SampleRate;
  ADst.num_channels := NumChannels;
  ADst.buffer_frames := BufferFrames;
  ADst.packet_frames := PacketFrames;
  ADst.num_packets := NumPackets;

  if Assigned(OnStream) then
  begin
    TAudio.FOnStream := OnStream;
    ADst.stream_cb := TAudio.StreamCallback;
  end
  else
  begin
    TAudio.FOnStream := nil;
    ADst.stream_cb := nil;
  end;

  ADst.stream_userdata_cb := nil;
  ADst.user_data := nil;

  {$IFDEF SOKOL_MEM_TRACK}
  ADst.allocator.alloc := _MemTrackAlloc;
  ADst.allocator.free := _MemTrackFree;
  {$ELSE}
  if (UseDelphiMemoryManager) then
  begin
    ADst.allocator.alloc := _AllocCallback;
    ADst.allocator.free := _FreeCallback;
  end
  else
  begin
    ADst.allocator.alloc := nil;
    ADst.allocator.free := nil;
  end;
  {$ENDIF}
  ADst.allocator.user_data := nil;
end;

class function TAudioDesc.Create: TAudioDesc;
begin
  Result.Init;
end;

procedure TAudioDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
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

unit Neslib.PLMpeg;
{ Delphi wrapper for PL_MPEG (https://github.com/phoboslab/pl_mpeg)

  Synopsis
  --------

    // This method gets called for each decoded video frame
    procedure TMyApp.VideoCallback(const AMpeg: TMpeg; const AFrame: TMpegFrame);
    begin
      // Do something with AFrame.Y.Data, AFrame.Cr.Data and AFrame.Cb.Data
    end;

    // This method gets called for each decoded audio frame
    procedure TMyApp.AudioCallback(const AMpeg: TMpeg; const ASamples: TMpegSamples);
    begin
      // Do something with ASamples.Interleaved
    end;

    // Load a .mpg (MPEG Program Stream) file from memory
    var Mpeg := TMpeg.Create;
    if (Mpeg.Load(SomeBuffer)) then
    begin
      // Install the video & audio decode callbacks
      Mpeg.OnVideoDecode := VideoCallback;
      Mpeg.OnAudioDecode := AudioCallback;

      // Decode
      repeat
        Mpeg.Decode(TimeSinceLastCall);
      until Mpeg.HasEnded;
    end;

    // All done
    Mpeg.Free;

  Documentation
  -------------

  This library provides several interfaces to load, demux and decode MPEG video
  and audio data. A high-level API combines the demuxer, video & audio decoders
  in an easy to use wrapper.

  Lower-level APIs for accessing the demuxer, video decoder and audio decoder,
  as well as providing different data sources are also available.

  * TMpeg: the high-level interface, combining demuxer and decoders
  * TMpegBuffer: the data source used by all interfaces
  * TMpegDemux: the MPEG-PS demuxer
  * TMpegVideo: the MPEG1 Video ("mpeg1") decoder
  * TMpegAudio: the MPEG1 Audio Layer II ("mp2") decoder

  With the high-level interface you have two options to decode video & audio:

  1) Use TMpeg.Decode and just hand over the delta time since the last call.
     It will decode everything needed and call your callbacks (specified through
     OnVideoDecode and OnAudioDevoce) any number of times.

  2) Use TMpeg.DecodeVideo and TMpeg.DecodeAudio to decode exactly one frame of
     video or audio data at a time. How you handle the synchronization of both
     streams is up to you.

  If you only want to decode video *or* audio through these functions, you
  should disable the other stream (TMpeg.VideoEnabled and TMpeg.AudioEnabled).

  Video data is decoded into a record with all 3 planes (Y, Cr, Cb) stored in
  separate buffers. You can either convert this to RGB on the CPU (slow) via the
  TMpegFrame.ToRgb method or do it on the GPU with the following matrix:

    mat4 rec601 = mat4(
      1.16438,  0.00000,  1.59603, -0.87079,
      1.16438, -0.39176, -0.81297,  0.52959,
      1.16438,  2.01723,  0.00000, -1.08139,
      0, 0, 0, 1);
    gl_FragColor = vec4(y, cb, cr, 1.0) * rec601;

  Audio data is decoded into a record with one single float array with the
  samples for the left and right channel interleaved. }

interface

uses
  System.SysUtils,
  Neslib.PLMpeg.Api;

type
  { Decoded Video Plane
    The byte length of the data is Width * Height. Note that different planes
    have different sizes: the Luma plane (Y) is double the size of each of
    the two Chroma planes (Cr, Cb) - i.e. 4 times the byte length.
    Also note that the size of the plane does *not* denote the size of the
    displayed frame. The sizes of planes are always rounded up to the nearest
    macroblock (16px). }
  TMpegPlane = record
  public
    Width: Integer;
    Height: Integer;
    Data: Pointer;
  end;
  PMpegPlane = ^TMpegPlane;

type
  { Decoded Video Frame.
    Width and Height denote the desired display size of the frame. This may be
    different from the internal size of the 3 planes. }
  TMpegFrame = record
  public
    Time: Double;
    Width: Integer;
    Height: Integer;
    Y: TMpegPlane;
    Cr: TMpegPlane;
    Cb: TMpegPlane;
  public
    { Convert the YCrCb data of this frame into an interleaved RGB buffer. The
      buffer pointed to by ARgb must have a size of at least Width * Height * 3
      bytes. }
    procedure ToRgb(const ARgb: Pointer); inline;
  end;
  PMpegFrame = ^TMpegFrame;

const
  MPEG_AUDIO_SAMPLES_PER_FRAME = _PLM_AUDIO_SAMPLES_PER_FRAME;

type
  { Decoded Audio Samples
    Samples are stored as interleaved normalized (-1, 1) floats.
    Count is always MPEG_AUDIO_SAMPLES_PER_FRAME and just there for
    convenience. }
  TMpegSamples = record
  public
    Time: Double;
    Count: Integer;
    Samples: array [0..MPEG_AUDIO_SAMPLES_PER_FRAME - 1, 0..1] of Single;
  end;
  PMpegSamples = ^TMpegSamples;

type
  TMpegBuffer = class;

  { Event type for when TMpegBuffer needs more data }
  TMpegBufferLoadEvent = procedure(const ABuffer: TMpegBuffer) of object;

  { Buffer API. Provides the data source for TMpeg }
  TMpegBuffer = class
  {$REGION 'Internal Declarations'}
  private
    FHandle: _Pplm_buffer_t;
    FOnLoad: TMpegBufferLoadEvent;
    procedure SetOnLoad(const AValue: TMpegBufferLoadEvent);
  private
    class procedure LoadCallback(Self: _Pplm_buffer_t; User: Pointer); cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    { Create a buffer instance with memory as source. This assumes the whole
      file is in memory.
      The buffer *must* stay alive for the duration of this object. }
    constructor Create(const ABuffer: TBytes); overload;
    constructor Create(const ABuffer: Pointer; const ASize: NativeInt); overload;

    { Create an empty buffer with an initial capacity. The buffer will grow
      as needed. }
    constructor Create(const ACapacity: NativeInt); overload;

    { Free the buffer }
    destructor Destroy; override;

    { Rewind the buffer back to the beginning. }
    procedure Rewind; inline;

    { Copy data into the buffer. If the data to be written is larger than the
      available space, the buffer will grow.
      Returns the number of bytes written. This will always be the same as the
      passed in ACount, except when the buffer was created with an existing
      memory buffer, for which Write is forbidden. }
    function Write(const AData; const ACount: NativeInt): NativeInt; inline;

    { Event that is fired when the buffer needs more data }
    property OnLoad: TMpegBufferLoadEvent read FOnLoad write SetOnLoad;
  end;

type
  TMpeg = class;

  { Event type for decoded video frames used by the high-level TMpeg API }
  TMpegVideoDecodeEvent = procedure(const AMpeg: TMpeg; const AFrame: TMpegFrame) of object;

  { Event type for decoded audio samples used by the high-level TMpeg API }
  TMpegAudioDecodeEvent = procedure(const AMpeg: TMpeg; const ASamples: TMpegSamples) of object;

  { High-Level API for loading/demuxing/decoding MPEG-PS data }
  TMpeg = class
  {$REGION 'Internal Declarations'}
  private
    FHandle: _Pplm_t;
    FAudioStreamIndex: Integer;
    FOnVideoDecode: TMpegVideoDecodeEvent;
    FOnAudioDecode: TMpegAudioDecodeEvent;
    function GetVideoEnabled: Boolean; inline;
    procedure SetVideoEnabled(const AValue: Boolean); inline;
    function GetAudioEnabled: Boolean; inline;
    procedure SetAudioEnabled(const AValue: Boolean); inline;
    procedure SetAudioStreamIndex(const AValue: Integer); inline;
    function GetWidth: Integer; inline;
    function GetHeight: Integer; inline;
    function GetFrameRate: Double; inline;
    function GetNumberOfAudioStreams: Integer; inline;
    function GetSampleRate: Integer; inline;
    function GetAudioLeadTime: Double; inline;
    procedure SetAudioLeadTime(const AValue: Double); inline;
    function GetTime: Double; inline;
    function GetLooping: Boolean; inline;
    procedure SetLooping(const AValue: Boolean); inline;
    function GetHasEnded: Boolean; inline;
    procedure SetOnVideoDecode(const AValue: TMpegVideoDecodeEvent);
    procedure SetOnAudioDecode(const AValue: TMpegAudioDecodeEvent);
  private
    class procedure AudioDecodeCallback(Self: _Pplm_t; Samples: _Pplm_samples_t;
      User: Pointer); cdecl; static;
    class procedure VideoDecodeCallback(Self: _Pplm_t; Frame: _Pplm_frame_t;
      User: Pointer); cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    { Create a TMpeg instance with memory as source. This assumes the whole file
      is in memory.
      The buffer *must* stay alive for the duration of this object. }
    constructor Create(const ABuffer: TBytes); overload;
    constructor Create(const ABuffer: Pointer; const ASize: NativeInt); overload;

    { Create a TMpeg instance with a TMpegBuffer as source.
      The buffer *must* stay alive for the duration of this object. }
    constructor Create(const ABuffer: TMpegBuffer); overload;

    { Free this instance }
    destructor Destroy; override;

    { Rewind all buffers back to the beginning. }
    procedure Rewind; inline;

    { Advance the internal timer by ASeconds and decode video/audio up to this
      time. Returns whether anything was decoded. }
    function Decode(const ASeconds: Double): Boolean; inline;

    { Decode and return one video frame. Returns nil if no frame could be
      decoded (either because the source ended or data is corrupt). If you only
      want to decode video, you should disable audio via the AudioEnabled
      property. The returned frame is valid until the next call to DecodeVideo
      or until this object is destroyed. }
    function DecodeVideo: PMpegFrame; inline;

    { Decode and return one audio frame. Returns nil if no frame could be
      decoded (either because the source ended or data is corrupt). If you only
      want to decode audio, you should disable video via the VideoEnabled
      property. The returned samples are  valid until the next call to
      DecodeAudio or until this object is destroyed. }
    function DecodeAudio: PMpegSamples; inline;

    { Whether video decoding is enabled. }
    property VideoEnabled: Boolean read GetVideoEnabled write SetVideoEnabled;

    { Whether audio decoding is enabled. When enabling, you can set the desired
      audio stream (0-3) to decode (see AudioStreamIndex). }
    property AudioEnabled: Boolean read GetAudioEnabled write SetAudioEnabled;

    { The desired audio stream (0-3) to decode when AudioEnabled is True. }
    property AudioStreamIndex: Integer read FAudioStreamIndex write SetAudioStreamIndex;

    { The display width/height of the video stream }
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;

    { The framerate of the video stream in frames per second }
    property FrameRate: Double read GetFrameRate;

    { The number of available audio streams in the file }
    property NumberOfAudioStreams: Integer read GetNumberOfAudioStreams;

    { The samplerate of the audio stream in samples per second }
    property SampleRate: Integer read GetSampleRate;

    { The audio lead time in seconds - the time in which audio samples are
      decoded in advance (or behind) the video decode time. Default 0. }
    property AudioLeadTime: Double read GetAudioLeadTime write SetAudioLeadTime;

    { The current internal time in seconds }
    property Time: Double read GetTime;

    { Looping mode. Default False. }
    property Looping: Boolean read GetLooping write SetLooping;

    { Whether the file has ended. If looping is enabled, this will always return
      False. }
    property HasEnded: Boolean read GetHasEnded;

    { Event that is fired when a video frame has been decoded. If no event is
      set, video data will be ignored and not be decoded. }
    property OnVideoDecode: TMpegVideoDecodeEvent read FOnVideoDecode write SetOnVideoDecode;

    { Event that is fired when audio samples have been decoded. If no event is
      set, audio data will be ignored and not be decoded. }
    property OnAudioDecode: TMpegAudioDecodeEvent read FOnAudioDecode write SetOnAudioDecode;
  end;

const
  MPEG_PACKET_TYPE_PRIVATE = $BD;
  MPEG_PACKET_TYPE_AUDIO1  = $C0;
  MPEG_PACKET_TYPE_AUDIO2  = $C1;
  MPEG_PACKET_TYPE_AUDIO3  = $C2;
  MPEG_PACKET_TYPE_AUDIO4  = $C3;
  MPEG_PACKET_TYPE_VIDEO1  = $E0;

type
  { Demuxed MPEG PS packet
    The PacketType maps directly to the various MPEG-PS start codes (see some of
    the MPEG_PACKET_TYPE_* constants above).
    PresentationTimeStamp is the presentation time stamp of the packet in
    seconds. Not all packets have a PresentationTimeStamp value. }
  TMpegPacket = record
  public
    PacketType: Integer;
    PresentationTimeStamp: Double;
    Size: NativeInt;
    Data: Pointer;
  end;
  PMpegPacket = ^TMpegPacket;

type
  { Demux an MPEG Program Stream (PS) data into separate packages }
  TMpegDemux = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _Pplm_demux_t;
    function GetNumberOfVideoStreams: Integer; inline;
    function GetNumberOfAudioStreams: Integer; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Create a demuxer with a plm_buffer as source.
      The buffer *must* stay alive for the duration of this object. }
    constructor Create(const ABuffer: TMpegBuffer);

    { Free the demuxer }
    procedure Free;

    { Rewinds the internal buffer. }
    procedure Rewind; inline;

    { Decode and return the next packet. The returned packet is valid until the
      next call to Decode or until the demuxer is destroyed. }
    function Decode: PMpegPacket; inline;

    { The number of video streams found in the system header. }
    property NumberOfVideoStreams: Integer read GetNumberOfVideoStreams;

    { The number of audio streams found in the system header. }
    property NumberOfAudioStreams: Integer read GetNumberOfAudioStreams;
  end;

type
  { Decode MPEG1 Video ("mpeg1") data into raw YCrCb frames }
  TMpegVideo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _Pplm_video_t;
    function GetFrameRate: Double; inline;
    function GetWidth: Integer; inline;
    function GetHeight: Integer; inline;
    procedure SetNoDelay(const AValue: Boolean); inline;
    function GetTime: Double; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Create a video decoder with a TMpegBuffer as source.
      The buffer *must* stay alive for the duration of this object. }
    constructor Create(const ABuffer: TMpegBuffer);

    { Free the video decoder. }
    procedure Free;

    { Rewinds the internal buffer. }
    procedure Rewind; inline;

    { Decode and return one frame of video and advance the internal time by
      1/FrameRate seconds. The returned frame is valid until the next call of
      Decode or until the video decoder is destroyed. }
    function Decode: PMpegFrame; inline;

    { The framerate in frames per second }
    property FrameRate: Double read GetFrameRate;

    { The display width/height }
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;

    { "No delay" mode. When enabled, the decoder assumes that the video does
      *not* contain any B-Frames. This is useful for reducing lag when
      streaming. }
    property NoDelay: Boolean write SetNoDelay;

    { The current internal time in seconds }
    property Time: Double read GetTime;
  end;

type
  { Decode MPEG-1 Audio Layer II ("mp2") data into raw samples }
  TMpegAudio = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _Pplm_video_t;
    function GetSampleRate: Integer; inline;
    function GetTime: Double; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Create an audio decoder with a TMpegBuffer as source.
      The buffer *must* stay alive for the duration of this object. }
    constructor Create(const ABuffer: TMpegBuffer);

    { Free the audio decoder. }
    procedure Free;

    { Rewinds the internal buffer. }
    procedure Rewind; inline;

    { Decode and return one "frame" of audio and advance the internal time by
      (MPEG_AUDIO_SAMPLES_PER_FRAME/SampleRate) seconds. The returned samples
      are valid until the next call of Decode or until the audio decoder is
      destroyed. }
    function Decode: PMpegSamples; inline;

    { The samplerate in samples per second. }
    property SampleRate: Integer read GetSampleRate;

    { The current internal time in seconds }
    property Time: Double read GetTime;
  end;

implementation

{ TMpeg }

class procedure TMpeg.AudioDecodeCallback(Self: _Pplm_t;
  Samples: _Pplm_samples_t; User: Pointer);
var
  Mpeg: TMpeg absolute User;
begin
  Assert(Assigned(Mpeg) and Assigned(Mpeg.FOnAudioDecode));
  Mpeg.FOnAudioDecode(Mpeg, PMpegSamples(Samples)^);
end;

constructor TMpeg.Create(const ABuffer: Pointer; const ASize: NativeInt);
begin
  inherited Create;
  FHandle := _plm_create_with_memory(ABuffer, ASize, 0);
end;

constructor TMpeg.Create(const ABuffer: TBytes);
begin
  Create(Pointer(ABuffer), Length(ABuffer));
end;

constructor TMpeg.Create(const ABuffer: TMpegBuffer);
begin
  inherited Create;
  FHandle := _plm_create_with_buffer(ABuffer.FHandle, 0);
end;

function TMpeg.Decode(const ASeconds: Double): Boolean;
begin
  Result := (_plm_decode(FHandle, ASeconds) <> 0);
end;

function TMpeg.DecodeAudio: PMpegSamples;
begin
  Result := Pointer(_plm_decode_audio(FHandle));
end;

function TMpeg.DecodeVideo: PMpegFrame;
begin
  Result := Pointer(_plm_decode_video(FHandle));
end;

destructor TMpeg.Destroy;
begin
  if (FHandle <> nil) then
    _plm_destroy(FHandle);
  inherited;
end;

function TMpeg.GetAudioEnabled: Boolean;
begin
  Result := (_plm_get_audio_enabled(FHandle) <> 0);
end;

function TMpeg.GetAudioLeadTime: Double;
begin
  Result := _plm_get_audio_lead_time(FHandle);
end;

function TMpeg.GetFrameRate: Double;
begin
  Result := _plm_get_framerate(FHandle);
end;

function TMpeg.GetHasEnded: Boolean;
begin
  Result := (_plm_has_ended(FHandle) <> 0);
end;

function TMpeg.GetHeight: Integer;
begin
  Result := _plm_get_height(FHandle);
end;

function TMpeg.GetLooping: Boolean;
begin
  Result := (_plm_get_loop(FHandle) <> 0);
end;

function TMpeg.GetNumberOfAudioStreams: Integer;
begin
  Result := _plm_get_num_audio_streams(FHandle);
end;

function TMpeg.GetSampleRate: Integer;
begin
  Result := _plm_get_samplerate(FHandle);
end;

function TMpeg.GetTime: Double;
begin
  Result := _plm_get_time(FHandle);
end;

function TMpeg.GetVideoEnabled: Boolean;
begin
  Result := (_plm_get_video_enabled(FHandle) <> 0);
end;

function TMpeg.GetWidth: Integer;
begin
  Result := _plm_get_width(FHandle);
end;

procedure TMpeg.Rewind;
begin
  _plm_rewind(FHandle);
end;

procedure TMpeg.SetAudioEnabled(const AValue: Boolean);
begin
  _plm_set_audio_enabled(FHandle, Ord(AValue), FAudioStreamIndex);
end;

procedure TMpeg.SetAudioLeadTime(const AValue: Double);
begin
  _plm_set_audio_lead_time(FHandle, AValue);
end;

procedure TMpeg.SetAudioStreamIndex(const AValue: Integer);
begin
  FAudioStreamIndex := AValue;
  if (GetAudioEnabled) then
    _plm_set_audio_enabled(FHandle, 1, FAudioStreamIndex);
end;

procedure TMpeg.SetLooping(const AValue: Boolean);
begin
  _plm_set_loop(FHandle, Ord(AValue));
end;

procedure TMpeg.SetOnAudioDecode(const AValue: TMpegAudioDecodeEvent);
begin
  FOnAudioDecode := AValue;
  if Assigned(AValue) then
    _plm_set_audio_decode_callback(FHandle, AudioDecodeCallback, Self)
  else
    _plm_set_audio_decode_callback(FHandle, nil, nil);
end;

procedure TMpeg.SetOnVideoDecode(const AValue: TMpegVideoDecodeEvent);
begin
  FOnVideoDecode := AValue;
  if Assigned(AValue) then
    _plm_set_video_decode_callback(FHandle, VideoDecodeCallback, Self)
  else
    _plm_set_video_decode_callback(FHandle, nil, nil);
end;

procedure TMpeg.SetVideoEnabled(const AValue: Boolean);
begin
  _plm_set_video_enabled(FHandle, Ord(AValue));
end;

class procedure TMpeg.VideoDecodeCallback(Self: _Pplm_t; Frame: _Pplm_frame_t;
  User: Pointer);
var
  Mpeg: TMpeg absolute User;
begin
  Assert(Assigned(Mpeg) and Assigned(Mpeg.FOnVideoDecode));
  Mpeg.FOnVideoDecode(Mpeg, PMpegFrame(Frame)^);
end;

{ TMpegBuffer }

constructor TMpegBuffer.Create(const ABuffer: TBytes);
begin
  Create(Pointer(ABuffer), Length(ABuffer));
end;

constructor TMpegBuffer.Create(const ABuffer: Pointer; const ASize: NativeInt);
begin
  inherited Create;
  FHandle := _plm_buffer_create_with_memory(ABuffer, ASize, 0);
end;

constructor TMpegBuffer.Create(const ACapacity: NativeInt);
begin
  inherited Create;
  FHandle := _plm_buffer_create_with_capacity(ACapacity);
end;

destructor TMpegBuffer.Destroy;
begin
  if (FHandle <> nil) then
    _plm_buffer_destroy(FHandle);
  inherited;
end;

class procedure TMpegBuffer.LoadCallback(Self: _Pplm_buffer_t; User: Pointer);
var
  Buffer: TMpegBuffer absolute User;
begin
  Assert(Assigned(Buffer) and Assigned(Buffer.FOnLoad));
  Buffer.FOnLoad(Buffer);
end;

procedure TMpegBuffer.Rewind;
begin
  _plm_buffer_rewind(FHandle);
end;

procedure TMpegBuffer.SetOnLoad(const AValue: TMpegBufferLoadEvent);
begin
  FOnLoad := AValue;
  if Assigned(AValue) then
    _plm_buffer_set_load_callback(FHandle, LoadCallback, Self)
  else
    _plm_buffer_set_load_callback(FHandle, nil, nil);
end;

function TMpegBuffer.Write(const AData; const ACount: NativeInt): NativeInt;
begin
  Result := _plm_buffer_write(FHandle, @AData, ACount);
end;

{ TMpegDemux }

constructor TMpegDemux.Create(const ABuffer: TMpegBuffer);
begin
  FHandle := _plm_demux_create(ABuffer.FHandle, 0);
end;

function TMpegDemux.Decode: PMpegPacket;
begin
  Result := Pointer(_plm_demux_decode(FHandle));
end;

procedure TMpegDemux.Free;
begin
  if (FHandle <> nil) then
  begin
    _plm_demux_destroy(FHandle);
    FHandle := nil;
  end;
end;

function TMpegDemux.GetNumberOfAudioStreams: Integer;
begin
  Result := _plm_demux_get_num_audio_streams(FHandle);
end;

function TMpegDemux.GetNumberOfVideoStreams: Integer;
begin
  Result := _plm_demux_get_num_video_streams(FHandle);
end;

procedure TMpegDemux.Rewind;
begin
  _plm_demux_rewind(FHandle);
end;

{ TMpegFrame }

procedure TMpegFrame.ToRgb(const ARgb: Pointer);
begin
  _plm_frame_to_rgb(@Self, ARgb);
end;

{ TMpegVideo }

constructor TMpegVideo.Create(const ABuffer: TMpegBuffer);
begin
  FHandle := _plm_video_create_with_buffer(ABuffer.FHandle, 0);
end;

function TMpegVideo.Decode: PMpegFrame;
begin
  Result := Pointer(_plm_video_decode(FHandle));
end;

procedure TMpegVideo.Free;
begin
  if (FHandle <> nil) then
  begin
    _plm_video_destroy(FHandle);
    FHandle := nil;
  end;
end;

function TMpegVideo.GetFrameRate: Double;
begin
  Result := _plm_video_get_framerate(FHandle);
end;

function TMpegVideo.GetHeight: Integer;
begin
  Result := _plm_video_get_height(FHandle);
end;

function TMpegVideo.GetTime: Double;
begin
  Result := _plm_video_get_time(FHandle);
end;

function TMpegVideo.GetWidth: Integer;
begin
  Result := _plm_video_get_width(FHandle);
end;

procedure TMpegVideo.Rewind;
begin
  _plm_video_rewind(FHandle);
end;

procedure TMpegVideo.SetNoDelay(const AValue: Boolean);
begin
  _plm_video_set_no_delay(FHandle, Ord(AValue));
end;

{ TMpegAudio }

constructor TMpegAudio.Create(const ABuffer: TMpegBuffer);
begin
  FHandle := _plm_audio_create_with_buffer(ABuffer.FHandle, 0);
end;

function TMpegAudio.Decode: PMpegSamples;
begin
  Result := Pointer(_plm_audio_decode(FHandle));
end;

procedure TMpegAudio.Free;
begin
  if (FHandle <> nil) then
  begin
    _plm_audio_destroy(FHandle);
    FHandle := nil;
  end;
end;

function TMpegAudio.GetSampleRate: Integer;
begin
  Result := _plm_audio_get_samplerate(FHandle);
end;

function TMpegAudio.GetTime: Double;
begin
  Result := _plm_audio_get_time(FHandle);
end;

procedure TMpegAudio.Rewind;
begin
  _plm_audio_rewind(FHandle);
end;

initialization
  Assert(SizeOf(TMpegFrame) = SizeOf(_plm_frame_t));
  Assert(SizeOf(TMpegSamples) = SizeOf(_plm_samples_t));
  Assert(SizeOf(TMpegPacket) = SizeOf(_plm_packet_t));

end.

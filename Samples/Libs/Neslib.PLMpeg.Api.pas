unit Neslib.PLMpeg.Api;
{ This unit is automatically generated by Chet:
  https://github.com/neslib/Chet }

{$MINENUMSIZE 4}

interface

const
  {$IF Defined(WIN32)}
  _LIB_PL_MPEG = 'pl_mpeg32.dll';
  _PU = '';
  {$ELSEIF Defined(WIN64)}
  _LIB_PL_MPEG = 'pl_mpeg64.dll';
  _PU = '';
  {$ELSEIF Defined(MACOS64) and Defined(CPUX64) and not Defined(IOS)}
  _LIB_PL_MPEG = 'libpl_mpeg_macos_intel.a';
  _PU = '';
  {$ELSEIF Defined(IOS)}
  _LIB_PL_MPEG = 'libpl_mpeg_ios.a';
  _PU = '';
  {$ELSEIF Defined(ANDROID32)}
  _LIB_PL_MPEG = 'libpl_mpeg_android32.a';
  _PU = '';
  {$ELSEIF Defined(ANDROID64)}
  _LIB_PL_MPEG = 'libpl_mpeg_android64.a';
  _PU = '';
  {$ELSE}
    {$MESSAGE Error 'Unsupported platform'}
  {$ENDIF}

const
  _PLM_AUDIO_SAMPLES_PER_FRAME = 1152;
  _PLM_BUFFER_DEFAULT_SIZE = (128*1024);

type
  // Forward declarations
  PUInt8 = ^UInt8;
  PPointer = ^Pointer;
  _Pplm_packet_t = ^_plm_packet_t;
  _Pplm_plane_t = ^_plm_plane_t;
  _Pplm_frame_t = ^_plm_frame_t;
  _Pplm_samples_t = ^_plm_samples_t;

  _Pplm_t = Pointer;
  _PPplm_t = ^_Pplm_t;
  _Pplm_buffer_t = Pointer;
  _PPplm_buffer_t = ^_Pplm_buffer_t;
  _Pplm_demux_t = Pointer;
  _PPplm_demux_t = ^_Pplm_demux_t;
  _Pplm_video_t = Pointer;
  _PPplm_video_t = ^_Pplm_video_t;
  _Pplm_audio_t = Pointer;
  _PPplm_audio_t = ^_Pplm_audio_t;

  _plm_packet_t = record
    &type: Integer;
    pts: Double;
    length: NativeUInt;
    data: PUInt8;
  end;

  _plm_plane_t = record
    width: Cardinal;
    height: Cardinal;
    data: PUInt8;
  end;

  _plm_frame_t = record
    time: Double;
    width: Cardinal;
    height: Cardinal;
    y: _plm_plane_t;
    cr: _plm_plane_t;
    cb: _plm_plane_t;
  end;

  _plm_video_decode_callback = procedure(self: _Pplm_t; frame: _Pplm_frame_t; user: Pointer); cdecl;

  _plm_samples_t = record
    time: Double;
    count: Cardinal;
    interleaved: array [0..2303] of Single;
  end;

  _plm_audio_decode_callback = procedure(self: _Pplm_t; samples: _Pplm_samples_t; user: Pointer); cdecl;

  _plm_buffer_load_callback = procedure(self: _Pplm_buffer_t; user: Pointer); cdecl;

const
  _PLM_DEMUX_PACKET_PRIVATE : Integer = $BD;
  _PLM_DEMUX_PACKET_AUDIO_1 : Integer = $C0;
  _PLM_DEMUX_PACKET_AUDIO_2 : Integer = $C1;
  _PLM_DEMUX_PACKET_AUDIO_3 : Integer = $C2;
  _PLM_DEMUX_PACKET_AUDIO_4 : Integer = $C2;
  _PLM_DEMUX_PACKET_VIDEO_1 : Integer = $E0;

function _plm_create_with_file(fh: PPointer; close_when_done: Integer): _Pplm_t; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_create_with_file';

function _plm_create_with_memory(bytes: PUInt8; length: NativeUInt; free_when_done: Integer): _Pplm_t; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_create_with_memory';

function _plm_create_with_buffer(buffer: _Pplm_buffer_t; destroy_when_done: Integer): _Pplm_t; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_create_with_buffer';

procedure _plm_destroy(self: _Pplm_t); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_destroy';

function _plm_get_video_enabled(self: _Pplm_t): Integer; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_get_video_enabled';

procedure _plm_set_video_enabled(self: _Pplm_t; enabled: Integer); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_set_video_enabled';

function _plm_get_audio_enabled(self: _Pplm_t): Integer; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_get_audio_enabled';

procedure _plm_set_audio_enabled(self: _Pplm_t; enabled: Integer; stream_index: Integer); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_set_audio_enabled';

function _plm_get_width(self: _Pplm_t): Integer; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_get_width';

function _plm_get_height(self: _Pplm_t): Integer; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_get_height';

function _plm_get_framerate(self: _Pplm_t): Double; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_get_framerate';

function _plm_get_num_audio_streams(self: _Pplm_t): Integer; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_get_num_audio_streams';

function _plm_get_samplerate(self: _Pplm_t): Integer; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_get_samplerate';

function _plm_get_audio_lead_time(self: _Pplm_t): Double; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_get_audio_lead_time';

procedure _plm_set_audio_lead_time(self: _Pplm_t; lead_time: Double); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_set_audio_lead_time';

function _plm_get_time(self: _Pplm_t): Double; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_get_time';

procedure _plm_rewind(self: _Pplm_t); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_rewind';

function _plm_get_loop(self: _Pplm_t): Integer; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_get_loop';

procedure _plm_set_loop(self: _Pplm_t; loop: Integer); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_set_loop';

function _plm_has_ended(self: _Pplm_t): Integer; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_has_ended';

procedure _plm_set_video_decode_callback(self: _Pplm_t; fp: _plm_video_decode_callback; user: Pointer); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_set_video_decode_callback';

procedure _plm_set_audio_decode_callback(self: _Pplm_t; fp: _plm_audio_decode_callback; user: Pointer); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_set_audio_decode_callback';

function _plm_decode(self: _Pplm_t; seconds: Double): Integer; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_decode';

function _plm_decode_video(self: _Pplm_t): _Pplm_frame_t; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_decode_video';

function _plm_decode_audio(self: _Pplm_t): _Pplm_samples_t; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_decode_audio';

function _plm_buffer_create_with_file(fh: PPointer; close_when_done: Integer): _Pplm_buffer_t; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_buffer_create_with_file';

function _plm_buffer_create_with_memory(bytes: PUInt8; length: NativeUInt; free_when_done: Integer): _Pplm_buffer_t; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_buffer_create_with_memory';

function _plm_buffer_create_with_capacity(capacity: NativeUInt): _Pplm_buffer_t; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_buffer_create_with_capacity';

procedure _plm_buffer_destroy(self: _Pplm_buffer_t); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_buffer_destroy';

function _plm_buffer_write(self: _Pplm_buffer_t; bytes: PUInt8; length: NativeUInt): NativeUInt; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_buffer_write';

procedure _plm_buffer_set_load_callback(self: _Pplm_buffer_t; fp: _plm_buffer_load_callback; user: Pointer); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_buffer_set_load_callback';

procedure _plm_buffer_rewind(self: _Pplm_buffer_t); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_buffer_rewind';

function _plm_demux_create(buffer: _Pplm_buffer_t; destroy_when_done: Integer): _Pplm_demux_t; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_demux_create';

procedure _plm_demux_destroy(self: _Pplm_demux_t); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_demux_destroy';

function _plm_demux_get_num_video_streams(self: _Pplm_demux_t): Integer; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_demux_get_num_video_streams';

function _plm_demux_get_num_audio_streams(self: _Pplm_demux_t): Integer; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_demux_get_num_audio_streams';

procedure _plm_demux_rewind(self: _Pplm_demux_t); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_demux_rewind';

function _plm_demux_decode(self: _Pplm_demux_t): _Pplm_packet_t; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_demux_decode';

function _plm_video_create_with_buffer(buffer: _Pplm_buffer_t; destroy_when_done: Integer): _Pplm_video_t; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_video_create_with_buffer';

procedure _plm_video_destroy(self: _Pplm_video_t); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_video_destroy';

function _plm_video_get_framerate(self: _Pplm_video_t): Double; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_video_get_framerate';

function _plm_video_get_width(self: _Pplm_video_t): Integer; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_video_get_width';

function _plm_video_get_height(self: _Pplm_video_t): Integer; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_video_get_height';

procedure _plm_video_set_no_delay(self: _Pplm_video_t; no_delay: Integer); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_video_set_no_delay';

function _plm_video_get_time(self: _Pplm_video_t): Double; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_video_get_time';

procedure _plm_video_rewind(self: _Pplm_video_t); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_video_rewind';

function _plm_video_decode(self: _Pplm_video_t): _Pplm_frame_t; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_video_decode';

procedure _plm_frame_to_rgb(frame: _Pplm_frame_t; rgb: PUInt8); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_frame_to_rgb';

function _plm_audio_create_with_buffer(buffer: _Pplm_buffer_t; destroy_when_done: Integer): _Pplm_audio_t; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_audio_create_with_buffer';

procedure _plm_audio_destroy(self: _Pplm_audio_t); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_audio_destroy';

function _plm_audio_get_samplerate(self: _Pplm_audio_t): Integer; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_audio_get_samplerate';

function _plm_audio_get_time(self: _Pplm_audio_t): Double; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_audio_get_time';

procedure _plm_audio_rewind(self: _Pplm_audio_t); cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_audio_rewind';

function _plm_audio_decode(self: _Pplm_audio_t): _Pplm_samples_t; cdecl;
  external _LIB_PL_MPEG name _PU + 'plm_audio_decode';

implementation

end.
unit Neslib.ModPlug.Api;
{ This unit is automatically generated by Chet:
  https://github.com/neslib/Chet }

{$MINENUMSIZE 4}

interface

const
  {$IF Defined(WIN32)}
  _LIB_MODPLUG = 'modplug32.dll';
  _PU = '';
  {$ELSEIF Defined(WIN64)}
  _LIB_MODPLUG = 'modplug64.dll';
  _PU = '';
  {$ELSEIF Defined(MACOS64) and Defined(CPUX64) and not Defined(IOS)}
  _LIB_MODPLUG = 'libmodplug_macos_intel.a';
  _PU = '';
  {$ELSEIF Defined(IOS)}
  _LIB_MODPLUG = 'libmodplug_ios.a';
  _PU = '';
  {$ELSEIF Defined(ANDROID32)}
  _LIB_MODPLUG = 'libmodplug_android32.a';
  _PU = '';
  {$ELSEIF Defined(ANDROID64)}
  _LIB_MODPLUG = 'libmodplug_android64.a';
  _PU = '';
  {$ELSE}
    {$MESSAGE Error 'Unsupported platform'}
  {$ENDIF}

type
  __ModPlug_Flags = Integer;
  _P_ModPlug_Flags = ^__ModPlug_Flags;

const
  _MODPLUG_ENABLE_OVERSAMPLING = 1;
  _MODPLUG_ENABLE_NOISE_REDUCTION = 2;
  _MODPLUG_ENABLE_REVERB = 4;
  _MODPLUG_ENABLE_MEGABASS = 8;
  _MODPLUG_ENABLE_SURROUND = 16;

type
  __ModPlug_ResamplingMode = Integer;
  _P_ModPlug_ResamplingMode = ^__ModPlug_ResamplingMode;

const
  _MODPLUG_RESAMPLE_NEAREST = 0;
  _MODPLUG_RESAMPLE_LINEAR = 1;
  _MODPLUG_RESAMPLE_SPLINE = 2;
  _MODPLUG_RESAMPLE_FIR = 3;

type
  // Forward declarations
  _P_ModPlugFile = Pointer;
  _PP_ModPlugFile = ^_P_ModPlugFile;
  _P_ModPlugNote = ^__ModPlugNote;
  _P_ModPlug_Settings = ^__ModPlug_Settings;

  _PModPlugFile = Pointer;
  _PPModPlugFile = ^_PModPlugFile;

  __ModPlugNote = record
    Note: Byte;
    Instrument: Byte;
    VolumeEffect: Byte;
    Effect: Byte;
    Volume: Byte;
    Parameter: Byte;
  end;

  _ModPlugNote = __ModPlugNote;
  _PModPlugNote = ^_ModPlugNote;

  _ModPlugMixerProc = procedure(p1: PInteger; p2: Cardinal; p3: Cardinal); cdecl;

  __ModPlug_Settings = record
    mFlags: Integer;
    mChannels: Integer;
    mBits: Integer;
    mFrequency: Integer;
    mResamplingMode: Integer;
    mStereoSeparation: Integer;
    mMaxMixChannels: Integer;
    mReverbDepth: Integer;
    mReverbDelay: Integer;
    mBassAmount: Integer;
    mBassRange: Integer;
    mSurroundDepth: Integer;
    mSurroundDelay: Integer;
    mLoopCount: Integer;
  end;

  _ModPlug_Settings = __ModPlug_Settings;
  _PModPlug_Settings = ^_ModPlug_Settings;

function _ModPlug_Load(const data: Pointer; size: Integer): _PModPlugFile; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_Load';

procedure _ModPlug_Unload(&file: _PModPlugFile); cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_Unload';

function _ModPlug_Read(&file: _PModPlugFile; buffer: Pointer; size: Integer): Integer; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_Read';

function _ModPlug_GetName(&file: _PModPlugFile): PUTF8Char; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_GetName';

function _ModPlug_GetLength(&file: _PModPlugFile): Integer; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_GetLength';

procedure _ModPlug_Seek(&file: _PModPlugFile; millisecond: Integer); cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_Seek';

procedure _ModPlug_GetSettings(settings: _PModPlug_Settings); cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_GetSettings';

procedure _ModPlug_SetSettings(const settings: _PModPlug_Settings); cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_SetSettings';

function _ModPlug_GetMasterVolume(&file: _PModPlugFile): Cardinal; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_GetMasterVolume';

procedure _ModPlug_SetMasterVolume(&file: _PModPlugFile; cvol: Cardinal); cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_SetMasterVolume';

function _ModPlug_GetCurrentSpeed(&file: _PModPlugFile): Integer; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_GetCurrentSpeed';

function _ModPlug_GetCurrentTempo(&file: _PModPlugFile): Integer; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_GetCurrentTempo';

function _ModPlug_GetCurrentOrder(&file: _PModPlugFile): Integer; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_GetCurrentOrder';

function _ModPlug_GetCurrentPattern(&file: _PModPlugFile): Integer; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_GetCurrentPattern';

function _ModPlug_GetCurrentRow(&file: _PModPlugFile): Integer; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_GetCurrentRow';

function _ModPlug_GetPlayingChannels(&file: _PModPlugFile): Integer; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_GetPlayingChannels';

procedure _ModPlug_SeekOrder(&file: _PModPlugFile; order: Integer); cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_SeekOrder';

function _ModPlug_GetModuleType(&file: _PModPlugFile): Integer; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_GetModuleType';

function _ModPlug_GetMessage(&file: _PModPlugFile): PUTF8Char; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_GetMessage';

function _ModPlug_NumInstruments(&file: _PModPlugFile): Cardinal; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_NumInstruments';

function _ModPlug_NumSamples(&file: _PModPlugFile): Cardinal; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_NumSamples';

function _ModPlug_NumPatterns(&file: _PModPlugFile): Cardinal; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_NumPatterns';

function _ModPlug_NumChannels(&file: _PModPlugFile): Cardinal; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_NumChannels';

function _ModPlug_SampleName(&file: _PModPlugFile; qual: Cardinal; buff: PUTF8Char): Cardinal; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_SampleName';

function _ModPlug_InstrumentName(&file: _PModPlugFile; qual: Cardinal; buff: PUTF8Char): Cardinal; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_InstrumentName';

function _ModPlug_GetPattern(&file: _PModPlugFile; pattern: Integer; numrows: PCardinal): _PModPlugNote; cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_GetPattern';

procedure _ModPlug_InitMixerCallback(&file: _PModPlugFile; proc: _ModPlugMixerProc); cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_InitMixerCallback';

procedure _ModPlug_UnloadMixerCallback(&file: _PModPlugFile); cdecl;
  external _LIB_MODPLUG name _PU + 'ModPlug_UnloadMixerCallback';

implementation

end.
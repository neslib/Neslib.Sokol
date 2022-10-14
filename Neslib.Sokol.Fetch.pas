unit Neslib.Sokol.Fetch;
{ Asynchronous data loading/streaming.

  For a user guide, check out the Neslib.Sokol.Fetch.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.Fetch.md }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

const
  FETCH_MAX_USERDATA_UINT64 = 16;
  FETCH_MAX_CHANNELS        = 16;

type
  { Error codes }
  TFetchError = (
    NoError,
    FileNotFound,
    NoBuffer,
    BufferTooSmall,
    UnexpectedEof,
    Cancelled);

type
  { Configuration values for TFetch.Setup }
  TFetchDesc = record
  {$REGION 'Internal Declarations'}
  private
    function Defaults: TFetchDesc;
  {$ENDREGION 'Internal Declarations'}
  public
    { Max number of active requests across all channels (default: 128) }
    MaxRequests: Integer;

    { Number of channels to fetch requests in parallel (default: 1) }
    NumChannels: Integer;

    { Max number of requests active on the same channel (default: 1) }
    NumLanes: Integer;

    { The base directory to use when filenames are relative.
      If then directory is relative or empty (default), it will be appended to:
      * Windows: the application directory.
      * macOS: the "Contents\Resources\" subdirectory in the bundle.
      * iOS: the ".\" subdirectory in the bundle.
      * Android: the "assets\internal\" subdirectory in the APK.

      For example, if you set BaseDirectory to 'Data', then you should deploy
      your files as follows:
      * Windows: in a "Data" subdirectory of your application directory.
      * Other platforms: use Delphi's Deployment Manager and set the Remote Path
        accordingly, eg:
        * macOS: "Contents\Resources\Data\"
        * iOS: ".\Data\"
        * Android: "assets\internal\Data\"

      The base directory can use both '/' and '\' as directory separators. }
    BaseDirectory: String;
  public
    class function Create: TFetchDesc; static;
    procedure Init; inline;
  end;
  PFetchDesc = ^TFetchDesc;

type
  { A request handle to identify an active fetch request.
    Returned by TFetchRequest.Send }
  TFetchHandle = record
  {$REGION 'Internal Declarations'}
  private
    FId: Cardinal;
  private
    function GetValid: Boolean;
  {$ENDREGION 'Internal Declarations'}
  public
    { Bind a data buffer to a request.
      Request must not currently have a buffer bound.
      Must be called from response callback. }
    procedure BindBuffer(const ABufferPtr: Pointer; const ABufferSize: Integer);

    { Clear the 'buffer binding' of a request.
      Returns previous buffer pointer (can be nil).
      Must be called from response callback. }
    function UnbindBuffer: Pointer;

    { Cancel a request that's in flight.
      Will call response callback with .Cancelled + .Finished. }
    procedure Cancel;

    { Pause a request.
      Will call response callback each frame with .Paused. }
    procedure Pause;

    { Continue the paused request }
    procedure Continue;

    { True if a handle is valid *and* the request is alive }
    property Valid: Boolean read GetValid;
 end;

type
  { The response record passed to the response callback }
  TFetchResponse = record
  {$REGION 'Internal Declarations'}
  private
    FPath: String;
    FHandle: TFetchHandle;
    FBufferPtr: Pointer;
    FUserData: Pointer;
    FChannel: Integer;
    FLane: Integer;
    FFetchedOffset: Integer;
    FFetchedSize: Integer;
    FBufferSize: Integer;
    FDispatched: Boolean;
    FFetched: Boolean;
    FPaused: Boolean;
    FFinished: Boolean;
    FFailed: Boolean;
    FCancelled: Boolean;
    FErrorCode: TFetchError;
  {$ENDREGION 'Internal Declarations'}
  public
    { Request handle this response belongs to }
    property Handle: TFetchHandle read FHandle;

    { True when request is in TFetchState.Dispatched state (lane has been
      assigned) }
    property Dispatched: Boolean read FDispatched;

    { True when request is in TFetchState.Fetched state (fetched data is
      available) }
    property Fetched: Boolean read FFetched;

    { Request is currently in TFetchState.Paused state }
    property Paused: Boolean read FPaused;

    { This is the last response for this request }
    property Finished: Boolean read FFinished;

    { Request has failed (always set together with Finished) }
    property Failed: Boolean read FFailed;

    { Request was cancelled (always set together with Finished) }
    property Cancelled: Boolean read FCancelled;

    { More detailed error code when Failed is True }
    property ErrorCode: TFetchError read FErrorCode;

    { The channel which processes this request }
    property Channel: Integer read FChannel;

    { The lane this request occupies on its channel }
    property Lane: Integer read FLane;

    { The original filesystem path of the request }
    property Path: String read FPath;

    { Current offset of fetched data chunk in file data }
    property FetchedOffset: Integer read FFetchedOffset;

    { Size of fetched data chunk in number of bytes }
    property FetchedSize: Integer read FFetchedSize;

    { Pointer to buffer with fetched data }
    property BufferPtr: Pointer read FBufferPtr;

    { Overall buffer size (may be >= FetchedSize!) }
    property BufferSize: Integer read FBufferSize;

    { The user data passed to the fetch request }
    property UserData: Pointer read FUserData;
  end;
  PFetchResponse = ^TFetchResponse;

type
  { Response callback function signatures }
  TFetchCallback = procedure(const AResponse: TFetchResponse) of object;
  TFetchCallbackProc = procedure(const AResponse: TFetchResponse);

type
  { A fetch request }
  TFetchRequest = record
  {$REGION 'Internal Declarations'}
  private
    function Validate: Boolean;
  {$ENDREGION 'Internal Declarations'}
  public
    { Index of channel this request is assigned to (default: 0) }
    Channel: Integer;

    { Filesystem path (required) }
    Path: String;

    { Response callback (one and only one of these two versions is required;
      if both are set, only Callback is used) }
    Callback: TFetchCallback;
    CallbackProc: TFetchCallbackProc;

    { Buffer pointer where data will be loaded into (optional) }
    BufferPtr: Pointer;

    { Buffer size in number of bytes (optional) }
    BufferSize: Integer;

    { Number of bytes to load per stream-block (optional) }
    ChunkSize: Integer;

    { Optional POD (plain-old-data) associated with the request, which will be
      copied(!) into an internal memory block. The maximum size of this memory
      block is 128 bytes. Since this block is copied, you must *not* put any
      managed data in here (like strings or object interfaces) }
    UserData: Pointer;
    UserDataSize: Integer;
  public
    { Initialization }
    class function Create: TFetchRequest; overload; static;
    constructor Create(const APath: String; const ACallback: TFetchCallback;
      const ABuffer: Pointer = nil; const ABufferSize: Integer = 0); overload;
    constructor Create(const APath: String; const ACallback: TFetchCallbackProc;
      const ABuffer: Pointer = nil; const ABufferSize: Integer = 0); overload;
    procedure Init; overload; inline;
    procedure Init(const APath: String; const ACallback: TFetchCallback;
      const ABuffer: Pointer = nil; const ABufferSize: Integer = 0); overload; inline;
    procedure Init(const APath: String; const ACallback: TFetchCallbackProc;
      const ABuffer: Pointer = nil; const ABufferSize: Integer = 0); overload; inline;

    { Send the fetch-request. Get handle to request back. }
    function Send: TFetchHandle;
  end;
  PFetchRequest = ^TFetchRequest;

type
  { Main Sokol Fetch entry point }
  TFetch = record // static
  {$REGION 'Internal Declarations'}
  private
    class function GetValid: Boolean; static;
    class function GetDesc: TFetchDesc; static;
  {$ENDREGION 'Internal Declarations'}
  public
    { Setup Sokol Fetch (can be called on multiple threads) }
    class procedure Setup(const ADesc: TFetchDesc); static;

    { Discaed a Sokol Fetch context }
    class procedure Shutdown; static;

    { Do per-frame work, moves requests into and out of IO threads, and invokes
      response-callbacks }
    class procedure DoWork; static;

    { True if Sokol Ftch has been setup }
    class property Valid: Boolean read GetValid;

    { The desc record that was passed to Setup, with zero values replaced
      with defaults. }
    class property Desc: TFetchDesc read GetDesc;
  end;

implementation

{ NOTE: This unit is a Delphi port and *not* a language binding. Reasons for
  these include:
  * Added support for the TFetchDesc.BaseDirectory field (although we could do
    this for a language binding as well).
  * Support for the Asset Manager on Android, so we don't have to copy any asset
    files on startup (as the System.StartUpCopy unit would do).
  * sokol_fetch.h uses a thread variable for the global fetch instance, so every
    thread has its own version. However, thread variables don't work well using
    C on Android (since it is emulated and not natively supported). This results
    in undefined references to "__emutls_get_address" when linking
    sokol_fetch.h. And this cannot be resolved by manually linking against a
    library like c++_static.a or c++abi.a, since it is part of the compiler
    runtime. Although we probably work around that as well by defining the
    thread variable on the Delphi side and exporting a function that returns the
    address of that variable. Then, we could modify sokol_fetch.h to use that
    function to get the thread-local variable (for Android only).

  So, if in the future, sokol_fetch.h adds support for the Asset Manager on
  Android, then we may go back to using a language binding instead. }

{$POINTERMATH ON}

uses
  {$IF Defined(MSWINDOWS)}
  Winapi.Windows,
  {$ELSEIF Defined(IOS)}
  Posix.Unistd,
  iOSapi.Foundation,
  {$ELSEIF Defined(MACOS)}
  Posix.Unistd,
  Macapi.Foundation,
  {$ELSEIF Defined(ANDROID)}
  Androidapi.NativeActivity,
  Androidapi.AssetManager,
  {$ENDIF}
  {$IFDEF SOKOL_MEM_TRACK}
  Neslib.Sokol.MemTrack,
  {$ENDIF}
  System.Math,
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  System.SyncObjs;

const
  FETCH_INVALID_LANE = -1;
  FETCH_INVALID_FILE_HANDLE = INVALID_HANDLE_VALUE;

type
  { A request goes through the following states, ping-ponging between IO and
    user thread }
  TFetchState = (
    { Internal: request has just been initialized }
    Initial,

    { Internal: request has been allocated from internal pool }
    Allocated,

    { User thread: request has been dispatched to its IO channel }
    Dispatched,

    { IO thread: waiting for data to be fetched }
    Fetching,

    { User thread: fetched data available }
    Fetched,

    { User thread: request has been paused via TFetchHandle.Pause }
    Paused,

    { User thread: follow state or Fetching if something went wrong }
    Failed);

type
  TFetchFileHandle = THandle;

type
  TFetchBuffer = record
  public
    Ptr: PByte;
    Size: Integer;
  end;
  PFetchBuffer = ^TFetchBuffer;

type
  { User-side per-request state }
  TFetchItemUser = record
  public
    { Switch item to Paused state if True }
    Pause: Boolean;

    { Switch item to Fetching state if True }
    Cont: Boolean;

    { Cancel the request, switch into Failed state }
    Cancel: Boolean;

    { Transfer IO => user thread }
    { Number of bytes fetched so far }
    FetchedOffset: Integer;

    { Size of last fetched chunk }
    FetchedSize: Integer;
    ErrorCode: TFetchError;
    Finished: Boolean;

    { User thread only }
    UserDataSize: Integer;
    UserData: array [0..FETCH_MAX_USERDATA_UINT64 - 1] of UInt64;
  end;
  PFetchItemUser = ^TFetchItemUser;

type
  PFetchItem = ^TFetchItem;

  { Thread-side per-request state }
  TFetchItemThread = record
  private
    { Transfer IO => user thread }
    FFetchedOffset: Integer;
    FFetchedSize: Integer;
    FErrorCode: TFetchError;
    FFailed: Boolean;
    FFinished: Boolean;

    { IO thread only }
    FFileHandle: TFetchFileHandle;
    FContentSize: Integer;
  public
    procedure RequestHandler(const AItem: PFetchItem;
      const ABaseDirectory: String);
  end;
  PFetchItemThread = ^TFetchItemThread;

  { An internal request item }
  TFetchItem = record
  private
    FPath: String;

    FHandle: TFetchHandle;
    FState: TFetchState;
    FChannel: Integer;
    FLane: Integer;
    FChunkSize: Integer;
    FCallback: TFetchCallback;
    FCallbackProc: TFetchCallbackProc;
    FBuffer: TFetchBuffer;

    { Updated by IO-thread, off-limits to user thread }
    FThread: TFetchItemThread;

    { Accessible by user-thread, off-limits to IO thread }
    FUser: TFetchItemUser;
  public
    procedure Init(const ASlotId: Cardinal; const ARequest: TFetchRequest);
    procedure Discard;
    procedure InvokeResponseCallback;
  end;

type
  { A pool of internal per-request items }
  TFetchPool = record
  private
    FSize: Integer;
    FFreeTop: Integer;
    FItems: PFetchItem;
    FFreeSlots: PInteger;
    FGenerationCounters: PInteger;
    FValid: Boolean;
  public
    function Init(const ANumItems: Integer): Boolean;
    procedure Discard;
    function ItemAlloc(const ARequest: TFetchRequest): Cardinal;
    procedure ItemFree(const ASlotId: Cardinal);
    function ItemLookup(const ASlotId: Cardinal): PFetchItem;
    function ItemAt(const ASlotId: Cardinal): PFetchItem;
  end;
  PFetchPool = ^TFetchPool;

type
  { A ringbuffer for pool-slot ids }
  TFetchRing = record
  private
    FHead: Integer;
    FTail: Integer;
    FNum: Integer;
    FBuf: PCardinal;
  private
    function GetCount: Integer;
  private
    function IsFull: Boolean;
    function IsEmpty: Boolean; inline;
    function Wrap(const AValue: Integer): Integer; inline;
  public
    function Init(const ANumSlots: Integer): Boolean;
    procedure Discard;
    procedure Enqueue(const ASlotId: Cardinal);
    function Dequeue: Cardinal;
    function Peek(const AIndex: Integer): Cardinal;

    property Count: Integer read GetCount;
  end;
  PFetchRing = ^TFetchRing;

type
  TFetchInstance = class;
  PFetchChannel = ^TFetchChannel;

  TFetchThread = class(TThread)
  private
    FChannel: PFetchChannel;
    FIncomingEvent: TEvent;
    FIncomingCritSect: TCriticalSection;
    FOutgoingCritSect: TCriticalSection;
    FRunningCritSect: TCriticalSection;
    FStopCritSect: TCriticalSection;
    FStopRequested: Boolean;
    FValid: Boolean;
  private
    procedure ThreadEntered;
    procedure ThreadLeaving;
    function StopRequested: Boolean;
    procedure RequestStop;
    procedure EnqueueOutgoing(const AOutgoing: TFetchRing; const AItem: Cardinal);
    procedure EnqueueIncoming(const AIncoming, ASrc: TFetchRing);
    function DequeueIncoming(const AIncoming: TFetchRing): Cardinal;
    procedure DequeueOutgoing(const AOutgoing, ADst: TFetchRing);
  protected
    procedure Execute; override;
  public
    constructor Create(const AChannel: PFetchChannel);
    destructor Destroy; override;
    procedure Join;
  end;

  TFetchChannel = record
  public type
    TRequestHandler = procedure(const ASlotId: Cardinal) of object;
  public
    { Back-pointer to thread-local GFetch state, since this isn't accessible
      from the IO threads }
    FContext: TFetchInstance;
    FFreeLanes: TFetchRing;
    FUserSent: TFetchRing;
    FUserIncoming: TFetchRing;
    FUserOutgoing: TFetchRing;
    FThreadIncoming: TFetchRing;
    FThreadOutgoing: TFetchRing;
    FThread: TFetchThread;
    FRequestHandler: TRequestHandler;
    FValid: Boolean;
  public
    function Init(const AContext: TFetchInstance; const ANumItems,
      ANumLanes: Integer; const ARequestHandler: TRequestHandler): Boolean;
    procedure Discard;
    function Send(const ASlotId: Cardinal): Boolean;
    procedure DoWork(const APool: TFetchPool);
  end;

  { The global state }
  TFetchInstance = class
  private
    FBaseDirectory: String;
    FDesc: TFetchDesc;
    FPool: TFetchPool;
    FChannels: array [0..FETCH_MAX_CHANNELS - 1] of TFetchChannel;
    FSetup: Boolean;
    FValid: Boolean;
    FInCallback: Boolean;
  private
    procedure RequestHandler(const ASlotId: Cardinal);
  public
    constructor Create(const ADesc: TFetchDesc);
    destructor Destroy; override;
    function Send(const ARequest: TFetchRequest): TFetchHandle;
    procedure DoWork;
  end;

threadvar
  GFetch: TFetchInstance;

function MakeId(const AIndex, AGenerationCounter: Cardinal): Cardinal; inline;
begin
  Result := (AGenerationCounter shl 16) or (AIndex and $FFFF);
end;

function SlotIndex(const ASlotId: Cardinal): Integer; inline;
begin
  Result := (ASlotId and $FFFF);
end;

{$IF Defined(MSWINDOWS)}
function FileOpen(const APath: String): THandle;
begin
  Result := CreateFile(PChar(APath), GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN, 0);
end;

function FileSize(const AHandle: THandle): Integer;
begin
  Result := GetFileSize(AHandle, nil);
end;

function FileRead(const AHandle: THandle; const AOffset, ANumBytes: Integer;
  const APtr: Pointer): Boolean;
begin
  Result := SetFilePointerEx(AHandle, AOffset, nil, FILE_BEGIN);
  if (Result) then
  begin
    var BytesRead: DWORD := 0;
    Result := (ReadFile(AHandle, APtr^, ANumBytes, BytesRead, nil))
      and (Integer(BytesRead) = ANumBytes);
  end;
end;

procedure FileClose(const AHandle: THandle);
begin
  CloseHandle(AHandle);
end;
{$ELSEIF Defined(ANDROID)}
var
  GAssetManager: PAAssetManager = nil;

function FileOpen(const APath: String): THandle;
begin
  if (GAssetManager = nil) then
  begin
    GAssetManager := ANativeActivity(System.DelphiActivity^).assetManager;
    if (GAssetManager = nil) then
      Exit(FETCH_INVALID_FILE_HANDLE);
  end;

  var Path := TPath.Combine('internal', APath);

  var Asset := AAssetManager_open(GAssetManager, PUTF8Char(UTF8String(Path)), AASSET_MODE_RANDOM);
  if (Asset = nil) then
    Exit(FETCH_INVALID_FILE_HANDLE);

  Result := THandle(Asset);
end;

function FileSize(const AHandle: THandle): Integer;
var
  Asset: PAAsset absolute AHandle;
begin
  Result := AAsset_getLength(Asset);
end;

function FileRead(const AHandle: THandle; const AOffset, ANumBytes: Integer;
  const APtr: Pointer): Boolean;
var
  Asset: PAAsset absolute AHandle;
begin
  Result := (AAsset_seek(Asset, AOffset, soFromBeginning) = AOffset);
  if (Result) then
    Result := (AAsset_read(Asset, APtr, ANumBytes) = ANumBytes);
end;

procedure FileClose(const AHandle: THandle);
var
  Asset: PAAsset absolute AHandle;
begin
  AAsset_close(Asset);
end;
{$ELSEIF Defined(POSIX)}
function FileOpen(const APath: String): THandle;
begin
  Result := System.SysUtils.FileOpen(APath, fmOpenRead or fmShareDenyWrite);
end;

function FileSize(const AHandle: THandle): Integer;
begin
  Result := FileSeek(AHandle, 0, soFromEnd);
end;

function FileRead(const AHandle: THandle; const AOffset, ANumBytes: Integer;
  const APtr: Pointer): Boolean;
begin
  Result := (FileSeek(AHandle, AOffset, soFromBeginning) = AOffset);
  if (Result) then
    Result := (System.SysUtils.FileRead(AHandle, APtr^, ANumBytes) = ANumBytes);
end;

procedure FileClose(const AHandle: THandle);
begin
  System.SysUtils.FileClose(AHandle);
end;
{$ENDIF}

{ TFetchDesc }

class function TFetchDesc.Create: TFetchDesc;
begin
  Result.Init;
end;

function TFetchDesc.Defaults: TFetchDesc;
begin
  Result := Self;
  if (MaxRequests = 0) then
    Result.MaxRequests := 128;
  if (NumChannels = 0) then
    Result.NumChannels := 1;
  if (NumLanes = 0) then
    Result.NumLanes := 1;
end;

procedure TFetchDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TFetchHandle }

procedure TFetchHandle.BindBuffer(const ABufferPtr: Pointer;
  const ABufferSize: Integer);
begin
  var Context := GFetch;
  Assert(Assigned(Context) and (Context.FValid));
  Assert(Context.FInCallback);
  var Item := Context.FPool.ItemLookup(FId);
  if (Item <> nil) then
  begin
    Assert((Item.FBuffer.Ptr = nil) and (Item.FBuffer.Size = 0));
    Item.FBuffer.Ptr := ABufferPtr;
    Item.FBuffer.Size := ABufferSize;
  end;
end;

procedure TFetchHandle.Cancel;
begin
  var Context := GFetch;
  Assert((Context <> nil) and (Context.FValid));
  var Item := Context.FPool.ItemLookup(FId);
  if (Item <> nil) then
  begin
    Item.FUser.Cont := False;
    Item.FUser.Pause := False;
    Item.FUser.Cancel := True;
  end;
end;

procedure TFetchHandle.Continue;
begin
  var Context := GFetch;
  Assert((Context <> nil) and (Context.FValid));
  var Item := Context.FPool.ItemLookup(FId);
  if (Item <> nil) then
  begin
    Item.FUser.Cont := True;
    Item.FUser.Pause := False;
  end;
end;

function TFetchHandle.GetValid: Boolean;
begin
  if (FId = 0) then
    Exit(False);

  var Context := GFetch;
  Assert((Context <> nil) and (Context.FValid));
  Result := (Context.FPool.ItemLookup(FId) <> nil);
end;

procedure TFetchHandle.Pause;
begin
  var Context := GFetch;
  Assert((Context <> nil) and (Context.FValid));
  var Item := Context.FPool.ItemLookup(FId);
  if (Item <> nil) then
  begin
    Item.FUser.Pause := True;
    Item.FUser.Cont := False;
  end;
end;

function TFetchHandle.UnbindBuffer: Pointer;
begin
  var Context := GFetch;
  Assert((Context <> nil) and (Context.FValid));
  Assert(Context.FInCallback);
  var Item := Context.FPool.ItemLookup(FId);
  if (Item <> nil) then
  begin
    Result := Item.FBuffer.Ptr;
    Item.FBuffer.Ptr := nil;
    Item.FBuffer.Size := 0;
  end
  else
    Result := nil;
end;

{ TFetchRequest }

class function TFetchRequest.Create: TFetchRequest;
begin
  Result.Init;
end;

constructor TFetchRequest.Create(const APath: String;
  const ACallback: TFetchCallback; const ABuffer: Pointer;
  const ABufferSize: Integer);
begin
  Init(APath, ACallback, ABuffer, ABufferSize);
end;

constructor TFetchRequest.Create(const APath: String;
  const ACallback: TFetchCallbackProc; const ABuffer: Pointer;
  const ABufferSize: Integer);
begin
  Init(APath, ACallback, ABuffer, ABufferSize);
end;

procedure TFetchRequest.Init(const APath: String;
  const ACallback: TFetchCallbackProc; const ABuffer: Pointer;
  const ABufferSize: Integer);
begin
  Init;
  Path := APath;
  CallbackProc := ACallback;
  BufferPtr := ABuffer;
  BufferSize := ABufferSize;
end;

procedure TFetchRequest.Init(const APath: String;
  const ACallback: TFetchCallback; const ABuffer: Pointer;
  const ABufferSize: Integer);
begin
  Init;
  Path := APath;
  Callback := ACallback;
  BufferPtr := ABuffer;
  BufferSize := ABufferSize;
end;

procedure TFetchRequest.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

function TFetchRequest.Send: TFetchHandle;
begin
  var Context := GFetch;
  Assert(Context <> nil);
  Result := Context.Send(Self);
end;

function TFetchRequest.Validate: Boolean;
begin
  {$IFDEF DEBUG}
  var Ctx := GFetch;
  Assert(Ctx <> nil);
  if (Channel >= Ctx.FDesc.NumChannels) then
  begin
    Assert(False, 'TFetchRequest.Validate: Channel too big!');
    Exit(False);
  end;

  if (Path.Trim = '') then
  begin
    Assert(False, 'TFetchRequest.Validate: Path is empty!');
    Exit(False);
  end;

  if (not Assigned(Callback)) and (not Assigned(CallbackProc)) then
  begin
    Assert(False, 'TFetchRequest.Validate: Callback missing!');
    Exit(False);
  end;

  if (ChunkSize > BufferSize) then
  begin
    Assert(False, 'TFetchRequest.Validate: ChunkSize is greater than BufferSize!');
    Exit(False);
  end;

  if (UserData <> nil) and (UserDataSize = 0) then
  begin
    Assert(False, 'TFetchRequest.Validate: UserData is set, but UserDataSize is 0!');
    Exit(False);
  end;

  if (UserData = nil) and (UserDataSize > 0) then
  begin
    Assert(False, 'TFetchRequest.Validate: UserData is nil, but UserDataSize is not 0!');
    Exit(False);
  end;

  if (UserDataSize > (FETCH_MAX_USERDATA_UINT64 * SizeOf(UInt64))) then
  begin
    Assert(False, 'TFetchRequest.Validate: UserDataSize is too big!');
    Exit(False);
  end;
  {$ENDIF}
  Result := True;
end;

{ TFetch }

class procedure TFetch.DoWork;
begin
  var Context := GFetch;
  Assert(Context <> nil);
  Context.DoWork;
end;

class function TFetch.GetDesc: TFetchDesc;
begin
  var Context := GFetch;
  Assert((Context <> nil) and (Context.FValid));
  Result := Context.FDesc;
end;

class function TFetch.GetValid: Boolean;
begin
  var Context := GFetch;
  Assert(Context <> nil);
  Result := Context.FValid;
end;

class procedure TFetch.Setup(const ADesc: TFetchDesc);
begin
  var Desc := ADesc.Defaults;
  GFetch := TFetchInstance.Create(Desc);
end;

class procedure TFetch.Shutdown;
begin
  var Context := GFetch;
  Assert(Context <> nil);
  Context.Free;
  GFetch := nil;
end;

{ TFetchItemThread }

procedure TFetchItemThread.RequestHandler(const AItem: PFetchItem;
  const ABaseDirectory: String);
begin
  var State := AItem.FState;
  Assert(State in [TFetchState.Fetching, TFetchState.Paused, TFetchState.Failed]);
  var Path := AItem.FPath;
  var Buffer := PFetchBuffer(@AItem.FBuffer);
  var ChunkSize := AItem.FChunkSize;

  if (FFailed) then
    Exit;

  if (State = TFetchState.Fetching) then
  begin
    if (Buffer.Ptr = nil) or (Buffer.Size = 0) then
    begin
      FErrorCode := TFetchError.NoBuffer;
      FFailed := True;
    end
    else
    begin
      { Open file if not happened yet }
      if (FFileHandle = FETCH_INVALID_FILE_HANDLE) then
      begin
        if (IsRelativePath(Path)) then
          Path := TPath.Combine(ABaseDirectory, Path);

        Assert(Path <> '');
        Assert(FFetchedOffset = 0);
        Assert(FFetchedSize = 0);
        FFileHandle := FileOpen(Path);
        if (FFileHandle <> FETCH_INVALID_FILE_HANDLE) then
          FContentSize := FileSize(FFileHandle);
      end;

      if (not FFailed) then
      begin
        var ReadOffset := 0;
        var BytesToRead := 0;
        if (ChunkSize = 0) then
        begin
          { Load entire file }
          if (FContentSize <= Buffer.Size) then
            BytesToRead := FContentSize
          else
          begin
            { Provided buffer too small to fit entire file }
            FErrorCode := TFetchError.BufferTooSmall;
            FFailed := True;
          end;
        end
        else
        begin
          if (ChunkSize <= Buffer.Size) then
          begin
            BytesToRead := ChunkSize;
            ReadOffset := FFetchedOffset;
            if ((ReadOffset + BytesToRead) > FContentSize) then
              BytesToRead := FContentSize - ReadOffset;
          end
          else
          begin
            { Provided buffer too small to fit next chunk }
            FErrorCode := TFetchError.BufferTooSmall;
            FFailed := True;
          end;
        end;

        if (not FFailed) then
        begin
          if (FileRead(FFileHandle, ReadOffset, BytesToRead, Buffer.Ptr)) then
          begin
            FFetchedSize := BytesToRead;
            Inc(FFetchedOffset, BytesToRead);
          end
          else
          begin
            FErrorCode := TFetchError.UnexpectedEof;
            FFailed := True;
          end;
        end;
      end;
    end;

    Assert(FFetchedOffset <= FContentSize);
    if (FFailed) or (FFetchedOffset = FContentSize) then
    begin
      if (FFileHandle <> FETCH_INVALID_FILE_HANDLE) then
      begin
        FileClose(FFileHandle);
        FFileHandle := FETCH_INVALID_FILE_HANDLE;
      end;
      FFinished := True;
    end;
  end;
  { Ignore items in Paused and FFailed state }
end;

{ TFetchItem }

procedure TFetchItem.Discard;
begin
  Assert(FHandle.FId <> 0);
  FPath := '';
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TFetchItem.Init(const ASlotId: Cardinal;
  const ARequest: TFetchRequest);
begin
  Assert(FHandle.FId = 0);
  FPath := '';
  FillChar(Self, SizeOf(Self), 0);

  FHandle.FId := ASlotId;
  FState := TFetchState.Initial;
  FChannel := ARequest.Channel;
  FChunkSize := ARequest.ChunkSize;
  FLane := FETCH_INVALID_LANE;
  FCallback := ARequest.Callback;
  FCallbackProc := ARequest.CallbackProc;
  FBuffer.Ptr := ARequest.BufferPtr;
  FBuffer.Size := ARequest.BufferSize;

  FPath := ARequest.Path;
  FThread.FFileHandle := FETCH_INVALID_FILE_HANDLE;

  if (ARequest.UserData <> nil) and (ARequest.UserDataSize > 0)
    and (ARequest.UserDataSize < (FETCH_MAX_USERDATA_UINT64 * SizeOf(UInt64))) then
  begin
    FUser.UserDataSize := ARequest.UserDataSize;
    Move(ARequest.UserData^, FUser.UserData[0], ARequest.UserDataSize);
  end;
end;

procedure TFetchItem.InvokeResponseCallback;
begin
  var Response: TFetchResponse;
  FillChar(Response, SizeOf(Response), 0);
  Response.FHandle := FHandle;
  Response.FDispatched := (FState = TFetchState.Dispatched);
  Response.FFetched := (FState = TFetchState.Fetched);
  Response.FPaused := (FState = TFetchState.Paused);
  Response.FFinished := FUser.Finished;
  Response.FFailed := (FState = TFetchState.Failed);
  Response.FCancelled := FUser.Cancel;
  Response.FErrorCode := FUser.ErrorCode;
  Response.FChannel := FChannel;
  Response.FLane := FLane;
  Response.FPath := FPath;
  Response.FUserData := @FUser.UserData;
  Response.FFetchedOffset := FUser.FetchedOffset - FUser.FetchedSize;
  Response.FFetchedSize := FUser.FetchedSize;
  Response.FBufferPtr := FBuffer.Ptr;
  Response.FBufferSize := FBuffer.Size;
  if Assigned(FCallback) then
    FCallback(Response)
  else
  begin
    Assert(Assigned(FCallbackProc));
    FCallbackProc(Response);
  end;
end;

{ TFetchPool }

procedure TFetchPool.Discard;
begin
  {$IFDEF SOKOL_MEM_TRACK}
  _MemTrackFree(FFreeSlots, nil);
  _MemTrackFree(FGenerationCounters, nil);
  {$ELSE}
  FreeMem(FFreeSlots);
  FreeMem(FGenerationCounters);
  {$ENDIF}
  FFreeSlots := nil;
  FGenerationCounters := nil;

  if (FItems <> nil) then
  begin
    for var I := 0 to FSize - 1 do
      FItems[I].FPath := '';

    {$IFDEF SOKOL_MEM_TRACK}
    _MemTrackFree(FItems, nil);
    {$ELSE}
    FreeMem(FItems);
    {$ENDIF}
    FItems := nil;
  end;

  FSize := 0;
  FFreeTop := 0;
  FValid := False;
end;

function TFetchPool.Init(const ANumItems: Integer): Boolean;
begin
  Assert((ANumItems > 0) and (ANumItems < ((1 shl 16) - 1)));
  Assert(FItems = nil);

  { NOTE: item slot 0 is reserved for the special "invalid" item index 0 }
  FSize := ANumItems + 1;
  var ItemsSize := FSize * SizeOf(TFetchItem);
  {$IFDEF SOKOL_MEM_TRACK}
  FItems := _MemTrackAlloc(ItemsSize, nil);
  {$ELSE}
  GetMem(FItems, ItemsSize);
  {$ENDIF}
  FillChar(FItems^, ItemsSize, 0);

  { Generation counters indexable by pool slot index, slot 0 is reserved }
  var GenerationCountersSize := SizeOf(Cardinal) * FSize;
  {$IFDEF SOKOL_MEM_TRACK}
  FGenerationCounters := _MemTrackAlloc(GenerationCountersSize, nil);
  {$ELSE}
  GetMem(FGenerationCounters, GenerationCountersSize);
  {$ENDIF}
  FillChar(FGenerationCounters^, GenerationCountersSize, 0);

  { NOTE: it's not a bug to only reserve ANumItems here }
  var FreeSlotsSize := ANumItems * SizeOf(Integer);
  {$IFDEF SOKOL_MEM_TRACK}
  FFreeSlots := _MemTrackAlloc(FreeSlotsSize, nil);
  {$ELSE}
  GetMem(FFreeSlots, FreeSlotsSize);
  {$ENDIF}
  FillChar(FFreeSlots^, FreeSlotsSize, 0);

  { Never allocate the 0-th item, this is the reserved 'invalid item' }
  for var I := FSize - 1 downto 1 do
  begin
    FFreeSlots[FFreeTop] := I;
    Inc(FFreeTop);
  end;
  FValid := True;
  Result := True;
end;

function TFetchPool.ItemAlloc(const ARequest: TFetchRequest): Cardinal;
begin
  Assert(FValid);
  if (FFreeTop > 0) then
  begin
    Dec(FFreeTop);
    var SlotIndex := FFreeSlots[FFreeTop];
    Assert((SlotIndex > 0) and (SlotIndex < FSize));
    Inc(FGenerationCounters[SlotIndex]);
    Result := MakeId(SlotIndex, FGenerationCounters[SlotIndex]);
    FItems[SlotIndex].Init(Result, ARequest);
    FItems[SlotIndex].FState := TFetchState.Allocated;
  end
  else
    { Pool exhausted }
    Result := MakeId(0, 0);
end;

function TFetchPool.ItemAt(const ASlotId: Cardinal): PFetchItem;
{ Return pointer to item by handle without matching id check }
begin
  Assert(FValid);
  var SlotIndex := SlotIndex(ASlotId);
  Assert((SlotIndex > 0) and (SlotIndex < FSize));
  Result := @FItems[SlotIndex];
end;

procedure TFetchPool.ItemFree(const ASlotId: Cardinal);
begin
  Assert(FValid);
  var SlotIndex := SlotIndex(ASlotId);
  Assert((SlotIndex > 0) and (SlotIndex < FSize));
  Assert(FItems[SlotIndex].FHandle.FId = ASlotId);
  {$IFOPT C+}
  for var I := 0 to FFreeTop - 1 do
    Assert(FFreeSlots[I] <> SlotIndex);
  {$ENDIF}
  FItems[SlotIndex].Discard;
  FFreeSlots[FFreeTop] := SlotIndex;
  Inc(FFreeTop);
  Assert(FFreeTop <= (FSize - 1));
end;

function TFetchPool.ItemLookup(const ASlotId: Cardinal): PFetchItem;
{ Return pointer to item by handle with matching Id check }
begin
  Assert(FValid);
  if (ASlotId <> 0) then
  begin
    Result := ItemAt(ASlotId);
    if (Result.FHandle.FId = ASlotId) then
      Exit;
  end;
  Result := nil;
end;

{ TFetchRing }

function TFetchRing.Dequeue: Cardinal;
begin
  Assert(FBuf <> nil);
  Assert(not IsEmpty);
  Assert(FTail < FNum);
  Result := FBuf[FTail];
  FTail := Wrap(FTail + 1);
end;

procedure TFetchRing.Discard;
begin
  {$IFDEF SOKOL_MEM_TRACK}
  _MemTrackFree(FBuf, nil);
  {$ELSE}
  FreeMem(FBuf);
  {$ENDIF}
  FBuf := nil;
  FHead := 0;
  FTail := 0;
  FNum := 0;
end;

procedure TFetchRing.Enqueue(const ASlotId: Cardinal);
begin
  Assert(FBuf <> nil);
  Assert(not IsFull);
  Assert(FHead < FNum);
  FBuf[FHead] := ASlotId;
  FHead := Wrap(FHead + 1);
end;

function TFetchRing.GetCount: Integer;
begin
  Assert(Assigned(FBuf));
  if (FHead >= FTail) then
    Result := FHead - FTail
  else
    Result := (FHead + FNum) - FTail;
  Assert(Result < FNum);
end;

function TFetchRing.Init(const ANumSlots: Integer): Boolean;
begin
  Assert(ANumSlots > 0);
  Assert(FBuf = nil);
  FHead := 0;
  FTail := 0;

  { One slot reserved to detect full vs empty }
  FNum := ANumSlots + 1;
  var QueueSize := FNum * SizeOf(Cardinal);
  {$IFDEF SOKOL_MEM_TRACK}
  FBuf := _MemTrackAlloc(QueueSize, nil);
  {$ELSE}
  GetMem(FBuf, QueueSize);
  {$ENDIF}
  FillChar(FBuf^, QueueSize, 0);
  Result := True;
end;

function TFetchRing.IsEmpty: Boolean;
begin
  Result := (FHead = FTail);
end;

function TFetchRing.IsFull: Boolean;
begin
  Assert(FBuf <> nil);
  Result := (Wrap(FHead + 1) = FTail);
end;

function TFetchRing.Peek(const AIndex: Integer): Cardinal;
begin
  Assert(FBuf <> nil);
  Assert(not IsEmpty);
  Assert(AIndex < Count);
  var Index := Wrap(FTail + AIndex);
  Result := FBuf[Index];
end;

function TFetchRing.Wrap(const AValue: Integer): Integer;
begin
  Result := (AValue mod FNum);
end;

{ TFetchThread }

constructor TFetchThread.Create(const AChannel: PFetchChannel);
begin
  inherited Create(False);
  FChannel := AChannel;
  FIncomingEvent := TEvent.Create(nil, False, False, '');
  FIncomingCritSect := TCriticalSection.Create;
  FOutgoingCritSect := TCriticalSection.Create;
  FRunningCritSect := TCriticalSection.Create;
  FStopCritSect := TCriticalSection.Create;
  FValid := True;
end;

function TFetchThread.DequeueIncoming(const AIncoming: TFetchRing): Cardinal;
{ Called from the fetch thread }
begin
  Assert(FValid);
  Assert(AIncoming.FBuf <> nil);
  FIncomingCritSect.Acquire;
  try
    while (AIncoming.IsEmpty) and (not FStopRequested) do
    begin
      FIncomingCritSect.Release;
      try
        FIncomingEvent.WaitFor;
      finally
        FIncomingCritSect.Acquire;
      end;
    end;
    if (FStopRequested) then
      Result := 0
    else
      Result := AIncoming.Dequeue;
  finally
    FIncomingCritSect.Release;
  end;
end;

procedure TFetchThread.DequeueOutgoing(const AOutgoing, ADst: TFetchRing);
{ Called from user thread }
begin
  Assert(FValid);
  Assert(AOutgoing.FBuf <> nil);
  Assert(ADst.FBuf <> nil);
  FOutgoingCritSect.Acquire;
  try
    while (not ADst.IsFull) and (not AOutgoing.IsEmpty) do
      ADst.Enqueue(AOutgoing.Dequeue);
  finally
    FOutgoingCritSect.Release;
  end;
end;

destructor TFetchThread.Destroy;
begin
  inherited;
  FStopCritSect.Free;
  FRunningCritSect.Free;
  FOutgoingCritSect.Free;
  FIncomingCritSect.Free;
  FIncomingEvent.Free;
end;

procedure TFetchThread.EnqueueIncoming(const AIncoming, ASrc: TFetchRing);
{ Called from the user thread }
begin
  Assert(FValid);
  Assert(AIncoming.FBuf <> nil);
  Assert(ASrc.FBuf <> nil);
  if (not ASrc.IsEmpty) then
  begin
    FIncomingCritSect.Acquire;
    try
      while (not AIncoming.IsFull) and (not ASrc.IsEmpty) do
        AIncoming.Enqueue(ASrc.Dequeue);
    finally
      FIncomingCritSect.Release;
    end;
    FIncomingEvent.SetEvent;
  end;
end;

procedure TFetchThread.EnqueueOutgoing(const AOutgoing: TFetchRing;
  const AItem: Cardinal);
{ Called from the fetch thread }
begin
  Assert(FValid);
  Assert(AOutgoing.FBuf <> nil);
  FOutgoingCritSect.Acquire;
  try
    if (not AOutgoing.IsFull) then
      AOutgoing.Enqueue(AItem);
  finally
    FOutgoingCritSect.Release;
  end;
end;

procedure TFetchThread.Execute;
begin
  ThreadEntered;
  try
    while (not StopRequested) do
    begin
      { Block until work arrives }
      var SlotId := DequeueIncoming(FChannel.FThreadIncoming);

      { SlotId will be invalid if the thread was woken up to join }
      if (not FStopRequested) then
      begin
        Assert(SlotId <> 0);
        FChannel.FRequestHandler(SlotId);
        Assert(not FChannel.FThreadOutgoing.IsFull);
        EnqueueOutgoing(FChannel.FThreadOutgoing, SlotId);
      end;
    end;
  finally
    ThreadLeaving;
  end;
end;

procedure TFetchThread.Join;
begin
  if (FValid) then
  begin
    FIncomingCritSect.Acquire;
    try
      RequestStop;
      FIncomingEvent.SetEvent;
    finally
      FIncomingCritSect.Release;
    end;
    WaitFor;
    FValid := False;
  end;
  Destroy;
end;

procedure TFetchThread.RequestStop;
begin
  FStopCritSect.Acquire;
  try
    FStopRequested := True;
  finally
    FStopCritSect.Release;
  end;
end;

function TFetchThread.StopRequested: Boolean;
begin
  FStopCritSect.Acquire;
  try
    Result := FStopRequested;
  finally
    FStopCritSect.Release;
  end;
end;

procedure TFetchThread.ThreadEntered;
begin
  FRunningCritSect.Acquire;
end;

procedure TFetchThread.ThreadLeaving;
begin
  FRunningCritSect.Release;
end;

{ TFetchChannel }

procedure TFetchChannel.Discard;
begin
  if Assigned(FThread) then
    FThread.Join;
  FThreadIncoming.Discard;
  FThreadOutgoing.Discard;
  FFreeLanes.Discard;
  FUserSent.Discard;
  FUserIncoming.Discard;
  FUserOutgoing.Discard;
  FFreeLanes.Discard;
  FValid := False;
end;

procedure TFetchChannel.DoWork(const APool: TFetchPool);
{ Per-frame channel stuff: move requests in and out of the IO threads,
  call response callbacks }
begin
  { Move items from sent- to incoming-queue permitting free lanes }
  var NumSent := FUserSent.Count;
  var AvailLanes := FFreeLanes.Count;
  var NumMove := NumSent;
  if (NumSent >= AvailLanes) then
    NumMove := AvailLanes;

  var I: Integer;
  var SlotId: Cardinal;
  var Item: PFetchItem;

  for I := 0 to NumMove - 1 do
  begin
    SlotId := FUserSent.Dequeue;
    Item := APool.ItemLookup(SlotId);
    Assert(Assigned(Item));
    Assert(Item.FState = TFetchState.Allocated);
    Item.FState := TFetchState.Dispatched;
    Item.FLane := FFreeLanes.Dequeue;

    { If no buffer provided yet, invoke response callback to do so }
    if (Item.FBuffer.Ptr = nil) then
      Item.InvokeResponseCallback;

    FUserIncoming.Enqueue(SlotId);
  end;

  { Prepare incoming items for being moved into the IO thread }
  var NumIncoming := FUserIncoming.Count;
  for I := 0 to NumIncoming - 1 do
  begin
    SlotId := FUserIncoming.Peek(I);
    Item := APool.ItemLookup(SlotId);
    Assert(Item <> nil);
    Assert(Item.FState <> TFetchState.Initial);
    Assert(Item.FState <> TFetchState.Fetching);

    { Transfer input params from user- to thread-data }
    if (Item.FUser.Pause) then
    begin
      Item.FState := TFetchState.Paused;
      Item.FUser.Pause := False;
    end;

    if (Item.FUser.Cont) then
    begin
      if (Item.FState = TFetchState.Paused) then
        Item.FState := TFetchState.Fetched;
      Item.FUser.Cont := False;
    end;

    if (Item.FUser.Cancel) then
    begin
      Item.FState := TFetchState.Failed;
      Item.FUser.Finished := True;
    end;

    if (Item.FState in [TFetchState.Dispatched, TFetchState.Fetched]) then
      Item.FState := TFetchState.Fetching;
  end;

  { Move new items into the IO threads and processed items out of IO threads }
  FThread.EnqueueIncoming(FThreadIncoming, FUserIncoming);
  FThread.DequeueOutgoing(FThreadOutgoing, FUserOutgoing);

  { Drain the outgoing queue, prepare items for invoking the response callback,
    and finally call the response callback, free finished items }
  while (not FUserOutgoing.IsEmpty) do
  begin
    SlotId := FUserOutgoing.Dequeue;
    Assert(SlotId <> 0);
    Item := APool.ItemLookup(SlotId);
    Assert(Item <> nil);
    Assert(not (Item.FState in [TFetchState.Initial, TFetchState.Allocated,
      TFetchState.Dispatched, TFetchState.Fetched]));

    { Transfer output params from thread- to user-data }
    Item.FUser.FetchedOffset := Item.FThread.FFetchedOffset;
    Item.FUser.FetchedSize := Item.FThread.FFetchedSize;

    if (Item.FUser.Cancel) then
      Item.FUser.ErrorCode := TFetchError.Cancelled
    else
      Item.FUser.ErrorCode := Item.FThread.FErrorCode;

    if (Item.FThread.FFinished) then
      Item.FUser.Finished := True;

    { State transition }
    if (Item.FThread.FFailed) then
      Item.FState := TFetchState.Failed
    else if (Item.FState = TFetchState.Fetching) then
      Item.FState := TFetchState.Fetched;

    Item.InvokeResponseCallback;

    { When the request is finish, free the lane for another request, otherwise
      feed it back into the incoming queue }
    if (Item.FUser.Finished) then
    begin
      FFreeLanes.Enqueue(Item.FLane);
      APool.ItemFree(SlotId);
    end
    else
      FUserIncoming.Enqueue(SlotId);
  end;
end;

function TFetchChannel.Init(const AContext: TFetchInstance; const ANumItems,
  ANumLanes: Integer; const ARequestHandler: TRequestHandler): Boolean;
begin
  Assert((ANumItems > 0) and Assigned(ARequestHandler));
  FRequestHandler := ARequestHandler;
  FContext := AContext;
  Result := FFreeLanes.Init(ANumLanes);
  for var Lane := 0 to ANumLanes - 1 do
    FFreeLanes.Enqueue(Lane);

  Result := Result and FUserSent.Init(ANumItems);
  Result := Result and FUserIncoming.Init(ANumLanes);
  Result := Result and FUserOutgoing.Init(ANumLanes);
  Result := Result and FThreadIncoming.Init(ANumLanes);
  Result := Result and FThreadOutgoing.Init(ANumLanes);

  FValid := Result;
  if (FValid) then
    FThread := TFetchThread.Create(@Self)
  else
    Discard;
end;

function TFetchChannel.Send(const ASlotId: Cardinal): Boolean;
{ Put a request into the channels sent-queue. This is where all new requests
  are stored until a lane becomes free. }
begin
  Assert(FValid);
  Result := (not FUserSent.IsFull);
  if (Result) then
    FUserSent.Enqueue(ASlotId);
end;

{ TFetchInstance }

constructor TFetchInstance.Create(const ADesc: TFetchDesc);
begin
  inherited Create;
  FDesc := ADesc;
  FSetup := True;

  FDesc.NumChannels := Min(FDesc.NumChannels, FETCH_MAX_CHANNELS);

  FBaseDirectory := FDesc.BaseDirectory;
  if (PathDelim = '\') then
    FBaseDirectory := FBaseDirectory.Replace('/', PathDelim)
  else
    FBaseDirectory := FBaseDirectory.Replace('\', PathDelim);

  if (TDirectory.IsRelativePath(FBaseDirectory)) then
  begin
    {$IF Defined(MSWINDOWS)}
    var AbsoluteDirectory := ExtractFilePath(ParamStr(0));
    {$ELSEIF Defined(MACOS)}
    var Bundle := TNSBundle.Wrap(TNSBundle.OCClass.mainBundle);
    var AbsoluteDirectory := UTF8ToString(Bundle.resourcePath.UTF8String);
    {$ELSEIF Defined(ANDROID)}
    var AbsoluteDirectory := '';
    {$ENDIF}
    FBaseDirectory := TPath.Combine(AbsoluteDirectory, FBaseDirectory);
  end;

  { Setup the global request item pool }
  FValid := FPool.Init(FDesc.MaxRequests);

  { Setup IO channels (one thread per channel) }
  for var I := 0 to FDesc.NumChannels - 1 do
  begin
    FValid := FValid and FChannels[I].Init(Self, FDesc.MaxRequests,
      FDesc.NumLanes, RequestHandler);
  end;
end;

destructor TFetchInstance.Destroy;
begin
  { IO threads must be shutdown first }
  for var I := 0 to FDesc.NumChannels - 1 do
  begin
    if (FChannels[I].FValid) then
      FChannels[I].Discard;
  end;
  FPool.Discard;
  inherited;
end;

procedure TFetchInstance.DoWork;
begin
  Assert(FSetup);
  if (not FValid) then
    Exit;

  { We're pumping each channel 2x so that unfinished request items coming out
    the IO threads can be moved back into the IO-thread immediately without
    having to wait a frame }
  FInCallback := True;
  try
    for var Pass := 0 to 1 do
    begin
      for var ChannelIndex := 0 to FDesc.NumChannels - 1 do
        FChannels[ChannelIndex].DoWork(FPool);
    end;
  finally
    FInCallback := False;
  end;
end;

procedure TFetchInstance.RequestHandler(const ASlotId: Cardinal);
begin
  var Item := FPool.ItemLookup(ASlotId);
  if (Item <> nil) then
    Item.FThread.RequestHandler(Item, FBaseDirectory);
end;

function TFetchInstance.Send(const ARequest: TFetchRequest): TFetchHandle;
begin
  Assert(FSetup);
  Result.FId := 0;

  if (not FValid) then
    Exit;

  if (not ARequest.Validate) then
    Exit;

  Assert(ARequest.Channel < FDesc.NumChannels);
  var SlotId := FPool.ItemAlloc(ARequest);
  if (SlotId = 0) then
    Exit;

  if (not FChannels[ARequest.Channel].Send(SlotId)) then
  begin
    { Send failed because the channels sent-queue overflowed }
    FPool.ItemFree(SlotId);
    Exit;
  end;

  Result.FId := SlotId;
end;

end.

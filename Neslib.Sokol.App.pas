unit Neslib.Sokol.App;
{ A minimal cross-platform application wrapper.

  For a user guide, check out the Neslib.Sokol.App.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.App.md }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Neslib.Sokol.Api;

type
  { Defines the pixel format for swapchain surfaces.

    NOTE: DO NOT directly cast this enum to Neslib.Sokol.Gfx's TPixelFormat;
    The enum values are totally different! }
  TAppPixelFormat = (
    Default      = __SAPP_PIXELFORMAT_DEFAULT,
    None         = _SAPP_PIXELFORMAT_NONE,

    { 8-bit color channels in RGBA order.
      Used for OpenGL (Android) backends. }
    RGBA8        = _SAPP_PIXELFORMAT_RGBA8,
    SRGB8A8      = _SAPP_PIXELFORMAT_SRGB8A8,

    { 8-bit color channels in BGRA order.
      Used for DirectX (Windows) and Metal (iOS/macOS) backends. }
    BGRA8        = _SAPP_PIXELFORMAT_BGRA8,
    SBGR8A8      = _SAPP_PIXELFORMAT_SBGR8A8,

    RGBA16F      = _SAPP_PIXELFORMAT_RGBA16F,
    Depth        = _SAPP_PIXELFORMAT_DEPTH,
    DepthStencil = _SAPP_PIXELFORMAT_DEPTH_STENCIL);

type
  { Predefined cursor image definitions. }
  TMouseCursor = (
    { The system default cursor }
    Default      = _SAPP_MOUSECURSOR_DEFAULT,
    Arrow        = _SAPP_MOUSECURSOR_ARROW,
    IBeam        = _SAPP_MOUSECURSOR_IBEAM,
    Crosshair    = _SAPP_MOUSECURSOR_CROSSHAIR,
    PointingHand = _SAPP_MOUSECURSOR_POINTING_HAND,
    ResizeEW     = _SAPP_MOUSECURSOR_RESIZE_EW,
    ResizeNS     = _SAPP_MOUSECURSOR_RESIZE_NS,
    ResizeNWSE   = _SAPP_MOUSECURSOR_RESIZE_NWSE,
    ResizeNESW   = _SAPP_MOUSECURSOR_RESIZE_NESW,
    ResizeAll    = _SAPP_MOUSECURSOR_RESIZE_ALL,
    NotAllowed   = _SAPP_MOUSECURSOR_NOT_ALLOWED,
    Custom0      = _SAPP_MOUSECURSOR_CUSTOM_0,
    Custom1      = _SAPP_MOUSECURSOR_CUSTOM_1,
    Custom2      = _SAPP_MOUSECURSOR_CUSTOM_2,
    Custom3      = _SAPP_MOUSECURSOR_CUSTOM_3,
    Custom4      = _SAPP_MOUSECURSOR_CUSTOM_4,
    Custom5      = _SAPP_MOUSECURSOR_CUSTOM_5,
    Custom6      = _SAPP_MOUSECURSOR_CUSTOM_6,
    Custom7      = _SAPP_MOUSECURSOR_CUSTOM_7,
    Custom8      = _SAPP_MOUSECURSOR_CUSTOM_8,
    Custom9      = _SAPP_MOUSECURSOR_CUSTOM_9,
    Custom10     = _SAPP_MOUSECURSOR_CUSTOM_10,
    Custom11     = _SAPP_MOUSECURSOR_CUSTOM_11,
    Custom12     = _SAPP_MOUSECURSOR_CUSTOM_12,
    Custom13     = _SAPP_MOUSECURSOR_CUSTOM_13,
    Custom14     = _SAPP_MOUSECURSOR_CUSTOM_14,
    Custom15     = _SAPP_MOUSECURSOR_CUSTOM_15);

type
  { Mouse buttons }
  TMouseButton = (
    { Left mouse button }
    Left    = _SAPP_MOUSEBUTTON_LEFT,

    { Right mouse button }
    Right   = _SAPP_MOUSEBUTTON_RIGHT,

    { Middle mouse button }
    Middle  = _SAPP_MOUSEBUTTON_MIDDLE,

    { Invalid or not applicable }
    Invalid = _SAPP_MOUSEBUTTON_INVALID);

type
  { Android specific 'tool type' enum for touch events. This lets the
    application check what type of input device was used for touch events.

    See https://developer.android.com/reference/android/view/MotionEvent#TOOL_TYPE_UNKNOWN }
  TAndroidToolType = (
    { Unknown }
    Unknown = _SAPP_ANDROIDTOOLTYPE_UNKNOWN,

    { Finger }
    Finger  = _SAPP_ANDROIDTOOLTYPE_FINGER,

    { Stylus }
    Stylus  = _SAPP_ANDROIDTOOLTYPE_STYLUS,

    { Mouse }
    Mouse   = _SAPP_ANDROIDTOOLTYPE_MOUSE);

type
  { A single finger touch point on a touch device }
  TTouchPoint = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sapp_touchpoint;
    function GetToolType: TAndroidToolType; inline;
    procedure SetToolType(const AValue: TAndroidToolType); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Finger identifier }
    property Identifier: UIntPtr read FHandle.identifier write FHandle.identifier;

    { X position in logical units }
    property X: Single read FHandle.pos_x write FHandle.pos_x;

    { Y position in logical units }
    property Y: Single read FHandle.pos_x write FHandle.pos_y;

    { Tool type. Only valid on Android. }
    property ToolType: TAndroidToolType read GetToolType write SetToolType;

    { Whether touch point has changed }
    property Changed: Boolean read FHandle.changed write FHandle.changed;
  end;
  PTouchPoint = ^TTouchPoint;

type
  { All current touches on a touch device }
  TTouches = record
  public const
    { Maximum number of simultaneous touches }
    MAX_TOUCHES = _SAPP_MAX_TOUCHPOINTS;
  public
    { Number of touches }
    Count: Integer;

    { The touches }
    Touches: array [0..MAX_TOUCHES - 1] of TTouchPoint;
  end;
  PTouches = ^TTouches;

type
  { Mouse and key modifiers }
  TModifier = (
    { Left or right Shift key }
    Shift             = 0,

    { Left or right Control key }
    Ctrl              = 1,

    { Left or right Alt key }
    Alt               = 2,

    { Super key (Win key or Apple key) }
    Super             = 3,

    { Left mouse button }
    LeftMouseButton   = 8,

    { Right mouse button }
    RightMouseButton  = 9,

    { Middle mouse button }
    MiddleMouseButton = 10);
  TModifiers = set of TModifier;

type
  { Key codes }
  TKeyCode = (
    Invalid          = 0,
    Space            = 32,
    Apostrophe       = 39,  // '
    Comma            = 44,  // ,
    Minus            = 45,  // -
    Period           = 46,  // .
    Slash            = 47,  // /
    _0               = 48,
    _1               = 49,
    _2               = 50,
    _3               = 51,
    _4               = 52,
    _5               = 53,
    _6               = 54,
    _7               = 55,
    _8               = 56,
    _9               = 57,
    Semicolon        = 59,  // ;
    Equal            = 61,  // =
    A                = 65,
    B                = 66,
    C                = 67,
    D                = 68,
    E                = 69,
    F                = 70,
    G                = 71,
    H                = 72,
    I                = 73,
    J                = 74,
    K                = 75,
    L                = 76,
    M                = 77,
    N                = 78,
    O                = 79,
    P                = 80,
    Q                = 81,
    R                = 82,
    S                = 83,
    T                = 84,
    U                = 85,
    V                = 86,
    W                = 87,
    X                = 88,
    Y                = 89,
    Z                = 90,
    LeftBracket      = 91,  // [
    BackSlash        = 92,  // \
    RightBracket     = 93,  // ]
    GraveAccent      = 96,  // `
    World1           = 161, // non-US #1
    World2           = 162, // non-US #2
    Escape           = 256,
    Enter            = 257,
    Tab              = 258,
    Backspace        = 259,
    Insert           = 260,
    Delete           = 261,
    Right            = 262,
    Left             = 263,
    Down             = 264,
    Up               = 265,
    PageUp           = 266,
    PageDown         = 267,
    Home             = 268,
    &End             = 269,
    CapsLock         = 280,
    ScrollLock       = 281,
    NumLock          = 282,
    PrintScreen      = 283,
    Pause            = 284,
    F1               = 290,
    F2               = 291,
    F3               = 292,
    F4               = 293,
    F5               = 294,
    F6               = 295,
    F7               = 296,
    F8               = 297,
    F9               = 298,
    F10              = 299,
    F11              = 300,
    F12              = 301,
    F13              = 302,
    F14              = 303,
    F15              = 304,
    F16              = 305,
    F17              = 306,
    F18              = 307,
    F19              = 308,
    F20              = 309,
    F21              = 310,
    F22              = 311,
    F23              = 312,
    F24              = 313,
    F25              = 314,
    KP0              = 320,
    KP1              = 321,
    KP2              = 322,
    KP3              = 323,
    KP4              = 324,
    KP5              = 325,
    KP6              = 326,
    KP7              = 327,
    KP8              = 328,
    KP9              = 329,
    KPDecimal        = 330,
    KPDivide         = 331,
    KPMultiply       = 332,
    KPSubtract       = 333,
    KPAdd            = 334,
    KPEnter          = 335,
    KPEqual          = 336,
    LeftShift        = 340,
    LeftControl      = 341,
    LeftAlt          = 342,
    LeftSuper        = 343,
    RightShift       = 344,
    RightControl     = 345,
    RightAlt         = 346,
    RightSuper       = 347,
    Menu             = 348);

type
  { Log levels }
  TLogLevel = (Panic, Error, Warning, Info);

type
  { Log items }
  TLogItem = (
    Ok,
    MallocFailed,
    SwapchainDepthformatInvalid,
    MacosInvalidNsopenglProfile,
    MetalCreateSwapchainDepthTextureFailed,
    MetalCreateSwapchainMsaaTextureFailed,
    Win32LoadOpengl32DllFailed,
    Win32CreateHelperWindowFailed,
    Win32HelperWindowGetdcFailed,
    Win32DummyContextSetPixelformatFailed,
    Win32CreateDummyContextFailed,
    Win32DummyContextMakeCurrentFailed,
    Win32GetPixelformatAttribFailed,
    Win32WglFindPixelformatFailed,
    Win32WglDescribePixelformatFailed,
    Win32WglSetPixelformatFailed,
    Win32WglArbCreateContextRequired,
    Win32WglArbCreateContextProfileRequired,
    Win32WglOpenglVersionNotSupported,
    Win32WglOpenglProfileNotSupported,
    Win32WglIncompatibleDeviceContext,
    Win32WglCreateContextAttribsFailedOther,
    Win32D3d11CreateDeviceAndSwapchainWithDebugFailed,
    Win32D3d11GetIdxgifactoryFailed,
    Win32D3d11GetIdxgiadapterFailed,
    Win32D3d11QueryInterfaceIdxgidevice1Failed,
    Win32RegisterRawInputDevicesFailedMouseLock,
    Win32RegisterRawInputDevicesFailedMouseUnlock,
    Win32GetRawInputDataFailed,
    Win32DestroyiconForCursorFailed,
    LinuxGlxLoadLibglFailed,
    LinuxGlxLoadEntryPointsFailed,
    LinuxGlxExtensionNotFound,
    LinuxGlxQueryVersionFailed,
    LinuxGlxVersionTooLow,
    LinuxGlxNoGlxfbconfigs,
    LinuxGlxNoSuitableGlxfbconfig,
    LinuxGlxGetVisualFromFbconfigFailed,
    LinuxGlxRequiredExtensionsMissing,
    LinuxGlxCreateContextFailed,
    LinuxGlxCreateWindowFailed,
    LinuxX11CreateWindowFailed,
    LinuxEglBindOpenglApiFailed,
    LinuxEglBindOpenglEsApiFailed,
    LinuxEglGetDisplayFailed,
    LinuxEglInitializeFailed,
    LinuxEglNoConfigs,
    LinuxEglNoNativeVisual,
    LinuxEglGetVisualInfoFailed,
    LinuxEglCreateWindowSurfaceFailed,
    LinuxEglCreateContextFailed,
    LinuxEglMakeCurrentFailed,
    LinuxX11OpenDisplayFailed,
    LinuxX11QuerySystemDpiFailed,
    LinuxX11DroppedFileUriWrongScheme,
    LinuxX11FailedToBecomeOwnerOfClipboard,
    AndroidUnsupportedInputEventInputCb,
    AndroidUnsupportedInputEventMainCb,
    AndroidReadMsgFailed,
    AndroidWriteMsgFailed,
    AndroidMsgCreate,
    AndroidMsgResume,
    AndroidMsgPause,
    AndroidMsgFocus,
    AndroidMsgNoFocus,
    AndroidMsgSetNativeWindow,
    AndroidMsgSetInputQueue,
    AndroidMsgDestroy,
    AndroidUnknownMsg,
    AndroidLoopThreadStarted,
    AndroidLoopThreadDone,
    AndroidNativeActivityOnstart,
    AndroidNativeActivityOnresume,
    AndroidNativeActivityOnsaveinstancestate,
    AndroidNativeActivityOnwindowfocuschanged,
    AndroidNativeActivityOnpause,
    AndroidNativeActivityOnstop,
    AndroidNativeActivityOnnativewindowcreated,
    AndroidNativeActivityOnnativewindowdestroyed,
    AndroidNativeActivityOninputqueuecreated,
    AndroidNativeActivityOninputqueuedestroyed,
    AndroidNativeActivityOnconfigurationchanged,
    AndroidNativeActivityOnlowmemory,
    AndroidNativeActivityOndestroy,
    AndroidNativeActivityDone,
    AndroidNativeActivityOncreate,
    AndroidCreateThreadPipeFailed,
    AndroidNativeActivityCreateSuccess,
    AndroidChoreographerEnabled,
    AndroidChoreographerUnavailable,
    WgpuDeviceLost,
    WgpuDeviceLog,
    WgpuDeviceUncapturedError,
    WgpuSwapchainCreateSurfaceFailed,
    WgpuSwapchainSurfaceGetCapabilitiesFailed,
    WgpuSwapchainCreateDepthStencilTextureFailed,
    WgpuSwapchainCreateDepthStencilViewFailed,
    WgpuSwapchainCreateMsaaTextureFailed,
    WgpuSwapchainCreateMsaaViewFailed,
    WgpuSwapchainGetcurrenttextureFailed,
    WgpuRequestDeviceStatusError,
    WgpuRequestDeviceStatusUnknown,
    WgpuRequestAdapterStatusUnavailable,
    WgpuRequestAdapterStatusError,
    WgpuRequestAdapterStatusUnknown,
    WgpuCreateInstanceFailed,
    VulkanRequiredInstanceExtensionFunctionMissing,
    VulkanAllocDeviceMemoryNoSuitableMemoryType,
    VulkanAllocateMemoryFailed,
    VulkanCreateInstanceFailed,
    VulkanEnumeratePhysicalDevicesFailed,
    VulkanNoPhysicalDevicesFound,
    VulkanNoSuitablePhysicalDeviceFound,
    VulkanCreateDeviceFailedExtensionNotPresent,
    VulkanCreateDeviceFailedFeatureNotPresent,
    VulkanCreateDeviceFailedInitializationFailed,
    VulkanCreateDeviceFailedOther,
    VulkanCreateSurfaceFailed,
    VulkanCreateSwapchainFailed,
    VulkanSwapchainCreateImageViewFailed,
    VulkanSwapchainCreateImageFailed,
    VulkanSwapchainAllocImageDeviceMemoryFailed,
    VulkanSwapchainBindImageMemoryFailed,
    VulkanAcquireNextImageFailed,
    VulkanQueuePresentFailed,
    ImageDataSizeMismatch,
    DroppedFilePathTooLong,
    ClipboardStringTooBig);

type
  _TLogItemHelper = record helper for TLogItem
  public
    function ToString: String;
  end;

type
  { This is used to describe image data (window icons and cursor images).

    The pixel format is RGBA8.

    CursorHotspotX and Y are used only for cursors, to define which pixel
    of the image should be aligned with the mouse position. }
  TImageDesc = record
  public
    Width: Integer;
    Height: Integer;
    CursorHotspotX: Integer;
    CursorHotspotY: Integer;
    Data: Pointer;
    Size: Integer;
  public
    constructor Create(const AWidth, AHeight: Integer;
      const AData: Pointer; const ASize: Integer;
      const ACursorHotspotX: Integer = 0;
      const ACursorHotspotY: Integer = 0); overload;
    constructor Create(const AWidth, AHeight: Integer;
      const APixels: TBytes; const ACursorHotspotX: Integer = 0;
      const ACursorHotspotY: Integer = 0); overload;
    procedure Init(const AWidth, AHeight: Integer;
      const AData: Pointer; const ASize: Integer;
      const ACursorHotspotX: Integer = 0;
      const ACursorHotspotY: Integer = 0); overload;
    procedure Init(const AWidth, AHeight: Integer;
      const APixels: TBytes; const ACursorHotspotX: Integer = 0;
      const ACursorHotspotY: Integer = 0); overload;
  end;
  PImageDesc = ^TImageDesc;

type
  { An icon description structure for use in TAppConfig.Icon and
    TApplication.Icon.

    When setting a custom image, the application can provide a number of
    candidates differing in size, and the application will pick the image(s)
    closest to the size expected by the platform's window system.

    To set the application's default icon, set UseDefault to True.

    Otherwise provide candidate images of different sizes in the Images array. }
  TIconDesc = record
  public const
    MAX_IMAGES = _SAPP_MAX_ICONIMAGES;
  public
    UseDefault: Boolean;
    Images: array [0..MAX_IMAGES - 1] of TImageDesc;
  public
    { Intializes with default values }
    class function Create: TIconDesc; static;
    procedure Init; inline;
  end;
  PIconDesc = ^TIconDesc;

type
  TAppEnvironmentDefaults = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sapp_environment_defaults;
    function GetColorFormat: TAppPixelFormat; inline;
    function GetDepthFormat: TAppPixelFormat; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property ColorFormat: TAppPixelFormat read GetColorFormat;
    property DepthFormat: TAppPixelFormat read GetDepthFormat;
    property SampleCount: Integer read FHandle.sample_count;
  end;
  PAppEnvironmentDefaults = ^TAppEnvironmentDefaults;

type
  TAppMetalEnvironment = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sapp_metal_environment;
  {$ENDREGION 'Internal Declarations'}
  public
    { For iOS and macOS, the Object ID of the Metal device object.
      Returns nil when Metal is not supported or not used. }
    property Device: Pointer read FHandle.device;
  end;
  PAppMetalEnvironment = ^TAppMetalEnvironment;

type
  TAppD3D11Environment = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sapp_d3d11_environment;
    function GetDevice: IInterface; inline;
    function GetDeviceContext: IInterface; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { For Windows, returns the ID3D11Device object.
      Returns nil when Direct3D11 is not supported or not used. }
    property Device: IInterface read GetDevice;

    { For Windows, returns the ID3D11DeviceContext object.
      Returns nil when Direct3D11 is not supported or not used. }
    property DeviceContext: IInterface read GetDeviceContext;
  end;
  PAppD3D11Environment = ^TAppD3D11Environment;

type
  TAppVulkanEnvironment = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sapp_vulkan_environment;
  {$ENDREGION 'Internal Declarations'}
  public
    property Instance: Pointer read FHandle.instance;
    property PhysicalDevice: Pointer read FHandle.physical_device;
    property Device: Pointer read FHandle.device;
    property Queue: Pointer read FHandle.queue;
    property QueueFamilyIndex: Cardinal read FHandle.queue_family_index;
  end;
  PAppVulkanEnvironment = ^TAppVulkanEnvironment;

type
  { Used to provide runtime environment information to the outside world (like
    default pixel formats and the backend 3D API device pointer) via a call to
    TApplication.Environment.

    NOTE: when using Neslib.Sokol.Gfx, don't assume that TAppEnvironment is
    binary compatible with TAppEnvironment! Always use a translation function
    like TEnvironment.FromAppEnvironment (from the Neslib.Sokol.Glue unit)! }
  TAppEnvironment = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sapp_environment;
    function GetDefaults: PAppEnvironmentDefaults; inline;
    function GetMetal: PAppMetalEnvironment; inline;
    function GetD3D11: PAppD3D11Environment; inline;
    function GetVulkan: PAppVulkanEnvironment; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Defaults: PAppEnvironmentDefaults read GetDefaults;
    property Metal: PAppMetalEnvironment read GetMetal;
    property D3D11: PAppD3D11Environment read GetD3D11;
    property Vulkan: PAppVulkanEnvironment read GetVulkan;
  end;

type
  TAppMetalSwapchain = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sapp_metal_swapchain;
  {$ENDREGION 'Internal Declarations'}
  public
    { For iOS and macOS, the Object ID of the current Metal drawable
      (CAMetalDrawable, *not* MTLDrawable). }
    property CurrentDrawable: Pointer read FHandle.current_drawable;

    { For iOS and macOS, the Object ID of the current Metal depth stencil
      texture (MTLTexture). }
    property DepthStencilTexture: Pointer read FHandle.depth_stencil_texture;

    { For iOS and macOS, the Object ID of the current Metal MSAA color
      texture (MTLTexture). }
    property MsaaColorTexture: Pointer read FHandle.msaa_color_texture;
  end;
  PAppMetalSwapchain = ^TAppMetalSwapchain;

type
  TAppD3D11Swapchain = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sapp_d3d11_swapchain;
    function GetDepthStencilView: IInterface; inline;
    function GetRenderView: IInterface; inline;
    function GetResolveView: IInterface; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { ID3D11RenderTargetView }
    property RenderView: IInterface read GetRenderView;

    { ID3D11RenderTargetView }
    property ResolveView: IInterface read GetResolveView;

    { ID3D11DepthStencilView }
    property DepthStencilView: IInterface read GetDepthStencilView;
  end;
  PAppD3D11Swapchain = ^TAppD3D11Swapchain;

type
  TAppVulkanSwapchain = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sapp_vulkan_swapchain;
  {$ENDREGION 'Internal Declarations'}
  public
    { vkImage }
    property RenderImage: Pointer read FHandle.render_image;

    { vkImageView }
    property RenderView: Pointer read FHandle.render_view;

    { vkImage }
    property ResolveImage: Pointer read FHandle.resolve_image;

    { vkImageView }
    property ResolveView: Pointer read FHandle.resolve_view;

    { vkImage }
    property DepthStencilImage: Pointer read FHandle.depth_stencil_image;

    { vkImageView }
    property DepthStencilView: Pointer read FHandle.depth_stencil_view;

    { vkSemaphore }
    property RenderFinishedSemaphore: Pointer read FHandle.render_finished_semaphore;

    { vkSemaphore }
    property PresentCompleteSemaphore: Pointer read FHandle.present_complete_semaphore;
  end;
  PAppVulkanSwapchain = ^TAppVulkanSwapchain;

type
  TAppGLSwapchain = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sapp_gl_swapchain;
  {$ENDREGION 'Internal Declarations'}
  public
    { GL framebuffer object }
    property FrameBuffer: Cardinal read FHandle.framebuffer;
  end;
  PAppGLSwapchain = ^TAppGLSwapchain;

type
  { Provides swapchain information for the next swapchain render pass,
    result of TApplication.AcquireSwapchain.

    NOTE: TApplication.AcquireSwapchainmust be called exactly once per frame,
    and ideally right before the swapchain render pass (e.g. not earlier
    in the frame).

    NOTE: when using Neslib.Sokol.Gfx, don't assume that the TAppSwapchain
    record has the same memory layout as TSwapchain! Use
    TSwapchain.FromAppSwapchain (in the Neslib.Sokol.Glue unit) to convert. }
  TAppSwapchain = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sapp_swapchain;
    function GetColorFormat: TAppPixelFormat; inline;
    function GetDepthFormat: TAppPixelFormat; inline;
    function GetMetal: PAppMetalSwapchain; inline;
    function GetD3D11: PAppD3D11Swapchain; inline;
    function GetVulkan: PAppVulkanSwapchain; inline;
    function GetGL: PAppGLSwapchain; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Invalid: Boolean read FHandle.invalid;
    property Width: Integer read FHandle.width;
    property Height: Integer read FHandle.height;
    property SampleCount: Integer read FHandle.sample_count;
    property ColorFormat: TAppPixelFormat read GetColorFormat;
    property DepthFormat: TAppPixelFormat read GetDepthFormat;
    property Metal: PAppMetalSwapchain read GetMetal;
    property D3D11: PAppD3D11Swapchain read GetD3D11;
    property Vulkan: PAppVulkanSwapchain read GetVulkan;
    property GL: PAppGLSwapchain read GetGL;
  end;

type
  { Custom log function.
    * ATag: always 'sapp'
    * ALevel: log level
    * AItem: log item
    * AMessage: log message. May be empty in Release mode.
    * ALineNr: line number in original sokol_app.h file.
    * AFilename: source filename. May be empty in Release mode. }
  TLogFunc = procedure(const ATag: String; const ALevel: TLogLevel;
      const AItem: TLogItem; const AMessage: String; const ALineNr: Integer;
      const AFilename: String) of object;

type
  { Used in TAppConfig to provide a logging function. Please be aware that
    without logging function, Neslib.Sokol.App will be completely silent, e.g.
    it will not report errors or warnings. For maximum error verbosity, compile
    in debug mode and install a logger (for instance the standard logging
    function from Neslib.Sokol.Log). }
  TAppLogger = record
  public
    Func: TLogFunc;
  end;

type
  TAppGLDesc = record
  public
    { Override GL/GLES major and minor version (defaults: GL4.1 (macOS) or
      GL4.3, GLES3.1 (Android) or GLES3.0 }
    MajorVersion: Integer;
    MinorVersion: Integer;
  end;

type
  TAppWin32Desc = record
  public
    { If True, set the output console codepage to UTF-8 }
    ConsoleUtf8: Boolean;

    { If True, attach stdout/stderr to a new console window }
    ConsoleCreate: Boolean;

    { If True, attach stdout/stderr to parent process }
    ConsoleAttach: Boolean;
  end;

type
  TAppIOSDesc = record
  public
    { If True, showing the iOS keyboard shrinks the canvas }
    KeyboardResizesCanvas: Boolean;
  end;

type
  TAppMetalDesc = record
  public
    { Feeds into CAMetalLayer.displaySyncEnabled }
    DisableDisplaySync: Boolean;
  end;

type
  { Application configuration. You can override the TApplication.Configure
    method to customize this configuration. }
  TAppConfig = record
  public
    { Application window title.
      Default: 'Neslib.Sokol Application' }
    WindowTitle: String;

    { Preferred window width in logical units. Use 0 to use a default width
      depending on platform.
      Default: 0 }
    Width: Integer;

    { Preferred window height in logical units. Use 0 to use a default height
      depending on platform.
      Default: 0 }
    Height: Integer;

    { TAppPixelFormat.None, .Depth or .DepthStencil.
      Default: TAppPixelFormat.Depth }
    DepthFormat: TAppPixelFormat;

    { MSAA sample count.
      Default: 1 }
    SampleCount: Integer;

    { Preferred swap interval (if supported by platform).
      Default: 1 }
    SwapInterval: Integer;

    { Request sRGB framebuffer }
    sRgb: Boolean;

    { Request HDR framebuffer (highly experimental, only supported on
      macOS+Metal) }
    Hdr: Boolean;

    { Optional and with differing behaviour, consider this a debugging feature! }
    DisableVSync: Boolean;

    { Whether the rendering canvas is full-resolution on High-DPI displays.
      See the documentation of TApplication for more information about
      supporting High-DPI displays.
      Default: False }
    HighDpi: Boolean;

    { Whether the window should be created in fullscreen mode.
      Default: False }
    FullScreen: Boolean;

    { Enable clipboard access.
      Default: False }
    EnableClipboard: Boolean;

    { Max size of clipboard content in bytes.
      Default: 8192 bytes }
    MaxClipboardSize: Integer;

    { Enable file dropping (drag'n'drop).
      Default: False }
    EnableDragDrop: Boolean;

    { Max number of dropped files to process.
      Default: 1 }
    MaxDroppedFiles: Integer;

    { Max length in bytes of a dropped UTF-8 file path.
      Default: 2048 }
    MaxDroppedFilePathLength: Integer;

    { The initial window icon to set.
      See TApplication.SetIcon for more details.
      Default: the default icon }
    Icon: TIconDesc;

    { Whether to use Delphi's memory manager instead of the default memory
      manager used by the Sokol library.
      When SOKOL_MEM_TRACK is defined, it always uses Delphi's memory manager.
      Default: False }
    UseDelphiMemoryManager: Boolean;

    { Logging callback override (default: NO LOGGING!) }
    Logger: TAppLogger;

    (******************************************)
    (* Backend- and platform-specific options *)
    (******************************************)

    GL: TAppGLDesc;
    Metal: TAppMetalDesc;
    Win32: TAppWin32Desc;
    iOS: TAppIOSDesc;
  public
    { Intializes with default values }
    procedure Init;
  end;

type
  { Kinds of events in the TEvent record.
    These are not just "traditional" input events, but also notify the
    application about state changes or other user-invoked actions. }
  TEventKind = (
    { A key is pressed }
    KeyDown          = _SAPP_EVENTTYPE_KEY_DOWN,

    { A key is released }
    KeyUp            = _SAPP_EVENTTYPE_KEY_UP,

    { A (printable) character key is pressed }
    Char             = _SAPP_EVENTTYPE_CHAR,

    { A mouse button is pressed }
    MouseDown        = _SAPP_EVENTTYPE_MOUSE_DOWN,

    { A mouse button is released }
    MouseUp          = _SAPP_EVENTTYPE_MOUSE_UP,

    { The mouse wheel is scrolled }
    MouseScroll      = _SAPP_EVENTTYPE_MOUSE_SCROLL,

    { The mouse is moved }
    MouseMove        = _SAPP_EVENTTYPE_MOUSE_MOVE,

    { The mouse entered the application window }
    MouseEnter       = _SAPP_EVENTTYPE_MOUSE_ENTER,

    { The mouse left the application window }
    MouseLeave       = _SAPP_EVENTTYPE_MOUSE_LEAVE,

    { One or more touches occurred on the screen }
    TouchesBegan     = _SAPP_EVENTTYPE_TOUCHES_BEGAN,

    { One or more touches moved on the screen }
    TouchesMoved     = _SAPP_EVENTTYPE_TOUCHES_MOVED,

    { One or more touches is raised from the screen }
    TouchesEnded     = _SAPP_EVENTTYPE_TOUCHES_ENDED,

    { Another event cancelled the touch sequence }
    TouchesCancelled = _SAPP_EVENTTYPE_TOUCHES_CANCELLED,

    { The application window has resized }
    Resized          = _SAPP_EVENTTYPE_RESIZED,

    { The application has been minimized }
    Iconified        = _SAPP_EVENTTYPE_ICONIFIED,

    { The application has been restored (from a minimized state) }
    Restored         = _SAPP_EVENTTYPE_RESTORED,

    { The application has gained focus }
    Focused          = _SAPP_EVENTTYPE_FOCUSED,

    { The application has lost focus }
    Unfocused        = _SAPP_EVENTTYPE_UNFOCUSED,

    { The application has been suspended }
    Suspended        = _SAPP_EVENTTYPE_SUSPENDED,

    { The application has resumed }
    Resumed          = _SAPP_EVENTTYPE_RESUMED,

    { The user has requested to quit the application (eg. by pressing the X
      button on the caption bar) }
    QuitRequested    = _SAPP_EVENTTYPE_QUIT_REQUESTED,

    { The clipboard is enabled and a string should be pasted from the
      clipboard }
    ClipboardPasted  = _SAPP_EVENTTYPE_CLIPBOARD_PASTED,

    { Drag-and-drop is enabled and one or more files are dropped onto the
      application window }
    FilesDropped     = _SAPP_EVENTTYPE_FILES_DROPPED);

type
  { Event type for TEventHandler.
    Note that it depends on the event Kind what record fields actually contain
    useful values. So you should first check the event Kind before reading other
    record fields. }
  TEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sapp_event;
    function GetFrameCount: Int64; inline;
    function GetKind: TEventKind; inline;
    function GetKeyCode: TKeyCode; inline;
    function GetModifiers: TModifiers; inline;
    function GetMouseButton: TMouseButton; inline;
    function GetTouch(const AIndex: Integer): PTouchPoint; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Current frame counter. Always valid. Useful for checking if two events
      were issued in the same frame. }
    property FrameCount: Int64 read GetFrameCount;

    { The event kind. Always valid. }
    property Kind: TEventKind read GetKind;

    { The virtual key code, only valid for KeyUp and KeyDown events. }
    property KeyCode: TKeyCode read GetKeyCode;

    { The UTF-32 character code. Only valid for Char events }
    property CharCode: UCS4Char read FHandle.char_code;

    { True if this is a key-repeat event. Valid for KeyUp, KeyDown and Char
      events. }
    property KeyRepeat: Boolean read FHandle.key_repeat;

    { Current modifier keys. Valid for all key-, char- and mouse-events. }
    property Modifiers: TModifiers read GetModifiers;

    { Mouse button that was pressed or released. Valid for MouseDown and MouseUp
      events. }
    property MouseButton: TMouseButton read GetMouseButton;

    { Current horizontal mouse position in pixels. Always valid except during
      mouse lock. }
    property MouseX: Single read FHandle.mouse_x;

    { Current vertical mouse position in pixels. Always valid except during
      mouse lock. }
    property MouseY: Single read FHandle.mouse_y;

    { Relative horizontal mouse movement since last frame. Always valid. }
    property MouseDX: Single read FHandle.mouse_dx;

    { Relative vertical mouse movement since last frame. Always valid. }
    property MouseDY: Single read FHandle.mouse_dy;

    { Horizontal mouse wheel scroll distance. Valid for MouseScroll events. }
    property ScrollX: Single read FHandle.scroll_x;

    { Vertical mouse wheel scroll distance. Valid for MouseScroll events. }
    property ScrollY: Single read FHandle.scroll_y;

    { Number of valid items in the Touches[] property }
    property TouchCount: Integer read FHandle.num_touches;

    { Current touch points. Valid in TouchesBegan, TouchesMoved and TouchesEnded
      events. }
    property Touches[const AIndex: Integer]: PTouchPoint read GetTouch;

    { Current window- and framebuffer sizes in pixels. Always valid. }
    property WindowWidth: Integer read FHandle.window_width;
    property WindowHeight: Integer read FHandle.window_height;
    property FramebufferWidth: Integer read FHandle.framebuffer_width;
    property FramebufferHeight: Integer read FHandle.framebuffer_height;
  end;
  PEvent = ^TEvent;

type
  { An event handler as used by TApplication.AddEventHandler.

    Parameters:
      AEvent: the event to handle.

    Returns:
      True if the event was handled and shouldn't be processed further.
      False otherwise.  }
  TEventHandler = function (const AEvent: TEvent): Boolean of object;

type
  { Main application entrypoint.
    You *must* subclass this class, and pass your class to the global RunApp
    procedure. }
  TApplication = class abstract
  {$REGION 'Internal Declarations'}
  private class var
    GInstance: TApplication;
    GDesc: _sapp_desc;
    GLogFunc: TLogFunc;
    GEventHandlers: TList<TEventHandler>;
  private
    FConfig: TAppConfig;
    FWindowTitle: UTF8String;
    class function GetIsValid: Boolean; inline; static;
    class function GetFramebufferHeight: Integer; inline; static;
    class function GetFramebufferWidth: Integer; inline; static;
    class function GetFrameDuration: Double; inline; static;
    class function GetFrameDurationUnfiltered: Double; inline; static;
    class function GetColorFormat: TAppPixelFormat; inline; static;
    class function GetDepthFormat: TAppPixelFormat; inline; static;
    class function GetSampleCount: Integer; inline; static;
    class function GetEglContext: Pointer; inline; static;
    class function GetEglDisplay: Pointer; inline; static;
    class function GetNativeWindow: THandle; inline; static;
    class function GetD3D11SwapChain: IInterface; inline; static;
    class function GetGLMajorVersion: Integer; inline; static;
    class function GetGLMinorVersion: Integer; inline; static;
    class function GetGLIsGLES: Boolean; inline; static;
    class function GetAndroidNativeActivity: THandle; inline; static;
    class function GetAndroidNativeWindow: THandle; inline; static;
    class function GetKeyboardVisible: Boolean; inline; static;
    class procedure SetKeyboardVisible(const AValue: Boolean); inline; static;
    class function GetMouseCursorVisible: Boolean; inline; static;
    class procedure SetMouseCursorVisible(const AValue: Boolean); inline; static;
    class function GetMouseCursor: TMouseCursor; inline; static;
    class procedure SetMouseCursor(const AValue: TMouseCursor); inline; static;
    class function GetMouseLocked: Boolean; inline; static;
    class procedure SetMouseLocked(const AValue: Boolean); inline; static;
    class function GetClipboardString: String; inline; static;
    class procedure SetClipboardString(const AValue: String); inline; static;
    class function GetHighDpi: Boolean; inline; static;
    class function GetDpiScale: Single; inline; static;
    class function GetFullScreen: Boolean; inline; static;
    class procedure SetFullScreen(const AValue: Boolean); inline; static;
    class function GetFrameCount: Int64; inline; static;
    class function GetEnvironment: TAppEnvironment; inline; static;
    procedure SetWindowTitle(const AValue: String); inline;
  private
    { Sokol callbacks }
    class procedure InitCallback(AUserData: Pointer); cdecl; static;
    class procedure FrameCallback(AUserData: Pointer); cdecl; static;
    class procedure CleanupCallback(AUserData: Pointer); cdecl; static;
    class procedure EventCallback(const AEvent: _Psapp_event;
      AUserData: Pointer); cdecl; static;
    class procedure LogCallback(const ATag: PUTF8Char; ALogLevel,
      ALogItemId: UInt32; const AMessageOrNull: PUTF8Char; ALineNr: UInt32;
      const AFilenameOrNull: PUTF8Char; AUserData: Pointer); cdecl; static;
  private
    class var FInstance: TApplication;
    procedure HandleEvent(const AEvent: _Psapp_event);
    procedure HandleClipboardPasted;
    procedure HandleFilesDropped(const AX, AY: Single);
    class procedure FailCallback(const AMsg: PUTF8Char; AUserData: Pointer); static;
    procedure FatalError(const AMsg: String);
  protected
    procedure Run;
  public
    class constructor Create;
    class destructor Destroy;
  {$ENDREGION 'Internal Declarations'}
  protected
    { Override this method to customize the application configuration.
      This method is called at the very start, before the application window
      is created.
      Does nothing by default. }
    procedure Configure(var AConfig: TAppConfig); virtual;

    { Initializes the application.
      This method is called after the window and graphics context (if requested)
      have been created. You usually create your (graphics) resources in this
      method.

      Does nothing by default. }
    procedure Init; virtual;

    { This method is called for every frame (usually 60 times per second). You
      usually update your per-frame application logic in this method and render
      the frame.

      Note that the size of the rendering framebuffer might have changed since
      the frame callback was called last. Use the properties FramebufferWidth
      and FramebufferHeight each frame to get the current size.

      Does nothing by default. }
    procedure Frame; virtual;

    { This method is called to clean your application, just before the window
      and graphics context (if any) are destroyed.
      You should release any resources here that have been created by the Init
      method.
      Does nothing by default. }
    procedure Cleanup; virtual;
  protected
    (************************************************************************)
    (* Events.                                                              *)
    (* NOTE: Do *not* call any 3D API rendering functions in these events,  *)
    (* since the 3D API context may not be active when the event is called. *)
    (************************************************************************)

    { Is called when a key is pressed.

      Parameters:
        AKey: the key that is pressed.
        AModifiers: any modifier keys that are currently down.
        AKeyRepeat: whether this is a repeating key.

      Does nothing by default. }
    procedure KeyDown(const AKey: TKeyCode; const AModifiers: TModifiers;
      const AKeyRepeat: Boolean); virtual;

    { Is called when a key is released.

      Parameters:
        AKey: the key that is released.
        AModifiers: any modifier keys that are currently down.
        AKeyRepeat: whether this is a repeating key.

      Does nothing by default. }
    procedure KeyUp(const AKey: TKeyCode; const AModifiers: TModifiers;
      const AKeyRepeat: Boolean); virtual;

    { Is called when a (printable) character key is pressed.

      Parameters:
        AChar: the UTF-32 character key.
        AModifiers: any modifier keys that are currently down.
        AKeyRepeat: whether this is a repeating key.

      This method gets called in addition to the KeyDown method if a Unicode
      character key is pressed.

      Does nothing by default. }
    procedure KeyChar(const AChar: UCS4Char; const AModifiers: TModifiers;
      const AKeyRepeat: Boolean); virtual;

    { Is called when a mouse button is pressed.

      Parameters:
        AButton: the mouse button.
        AX: X-coordinate in logical units.
        AY: Y-coordinate in logical units.
        AModifiers: any modifier keys that are currently down.

      Does nothing by default. }
    procedure MouseDown(const AButton: TMouseButton; const AX, AY: Single;
      const AModifiers: TModifiers); virtual;

    { Is called when a mouse button is released.

      Parameters:
        AButton: the mouse button.
        AX: X-coordinate in logical units.
        AY: Y-coordinate in logical units.
        AModifiers: any modifier keys that are currently down.

      Does nothing by default. }
    procedure MouseUp(const AButton: TMouseButton; const AX, AY: Single;
      const AModifiers: TModifiers); virtual;

    { Is called when the mouse wheel is scrolled.

      Parameters:
        AWheelDeltaX: relative horizontal movement (when the mousewheel is
          tilted left or right).
        AWheelDeltaX: relative vertical movement (when the mousewheel is rotated
          up or down).
        AModifiers: any modifier keys that are currently down.

      Does nothing by default. }
    procedure MouseScroll(const AWheelDeltaX, AWheelDeltaY: Single;
      const AModifiers: TModifiers); virtual;

    { Is called when the mouse is moved.

      Parameters:
        AX: X-coordinate in logical units.
        AY: Y-coordinate in logical units.
        ADX: relative horizontal mouse movement since last frame
        ADY: relative vertical mouse movement since last frame
        AModifiers: any modifier keys that are currently down.

      Does nothing by default. }
    procedure MouseMove(const AX, AY, ADX, ADY: Single;
      const AModifiers: TModifiers); virtual;

    { Is called when the mouse enters the application window.

      Parameters:
        AX: X-coordinate in logical units.
        AY: Y-coordinate in logical units.
        AModifiers: any modifier keys that are currently down.

      Does nothing by default. }
    procedure MouseEnter(const AX, AY: Single;
      const AModifiers: TModifiers); virtual;

    { Is called when the mouse leaves the application window.

      Parameters:
        AX: X-coordinate in logical units.
        AY: Y-coordinate in logical units.
        AModifiers: any modifier keys that are currently down.

      Does nothing by default. }
    procedure MouseLeave(const AX, AY: Single;
      const AModifiers: TModifiers); virtual;

    { Is called when one or more new touches occurred on the screen.

      Parameters:
        ATouches: information about the current touches.

      Does nothing by default. }
    procedure TouchesBegan(const ATouches: TTouches); virtual;

    { Is called when one or more touches have moved on the screen.

      Parameters:
        ATouches: information about the current touches.

      Does nothing by default. }
    procedure TouchesMoved(const ATouches: TTouches); virtual;

    { Is called when one or more fingers are raised from the screen.

      Parameters:
        ATouches: information about the current touches.

      Does nothing by default. }
    procedure TouchesEnded(const ATouches: TTouches); virtual;

    { Is called when a system event (such as a popup window) cancels a touch
      sequence.

      Parameters:
        ATouches: information about the current touches.

      Does nothing by default. }
    procedure TouchesCancelled(const ATouches: TTouches); virtual;

    { Is called when the application window has resized.

      Parameters:
        AWindowWidth: window width in logical units.
        AWindowHeight: window height in logical units.
        AFramebufferWidth: framebuffer width in physical units.
        AFramebufferHeight: framebuffer height in physical units.

      Does nothing by default. }
    procedure Resized(const AWindowWidth, AWindowHeight, AFramebufferWidth,
      AFramebufferHeight: Integer); virtual;

    { Is called when the application has been minimized.
      Does nothing by default. }
    procedure Iconified; virtual;

    { Is called when the application has been restored (from a minimized
      state).
      Does nothing by default. }
    procedure Restored; virtual;

    { Is called when the application has gained focus.
      Does nothing by default. }
    procedure Focused; virtual;

    { Is called when the application has lost focus.
      Does nothing by default. }
    procedure Unfocused; virtual;

    { Is called when the application has been suspended.
      Does nothing by default. }
    procedure Suspended; virtual;

    { Is called when the application has resumed.
      Does nothing by default. }
    procedure Resumed; virtual;

    { Is called when the user has requested to quit the application (eg. by
      pressing the X button on the caption bar).

      Parameters:
        ACanQuit: whether the application is allowed to quit. Defaults to True.

      To prevent application shutdown, set the ACanQuit parameter to False.
      Does nothing by default. }
    procedure QuitRequested(var ACanQuit: Boolean); virtual;

    { Is called when the clipboard is enabled (see TAppConfig.EnableClipboard)
      and a string should be pasted from the clipboard.

      Parameters:
        AClipboardString: the string on the clipboard.

      See the ClipboardString property for more details.
      Does nothing by default. }
    procedure ClipboardPasted(const AClipboardString: String); virtual;

    { Is called when drag-and-drop is enabled (see TAppConfig.EnableDragDrop)
      and one or more files are dropped onto the application window.

      Parameters:
        AX: X-coordinate of drop location in logical units.
        AY: Y-coordinate of drop location in logical units.
        AFilePaths: array of file paths dropped onto the window.

      Does nothing by default. }
    procedure FilesDropped(const AX, AY: Single;
      const AFilePaths: TArray<String>); virtual;
  public
    { Constructor }
    constructor Create; virtual;

    { Destructor }
    destructor Destroy; override;

    { Acquire swapchain info for the next swapchain render pass, call exactly
      once per frame }
    class function AcquireSwapchain: TAppSwapchain; inline; static;

    { Logs a message to debug output.

      Parameters:
        AMsg: the message to log.
        AArgs: (optional) formatting arguments.

      The debug output depends on the platform:
      * Windows: logs to the Delphi output window.
      * macOS: logs to the PAServer window.
      * iOS: logs to the (Xcode) device console window.
      * Android: logs to LogCat }
    class procedure Log(const AMsg: String); overload; static;
    class procedure Log(const AMsg: String; const AArgs: array of const); overload; static;

    { Toggles fullscreen mode.
      See the Fullscreen property for more details. }
    class procedure ToggleFullscreen; inline; static;

    { On Windows and macOS, you can change the window icon programmatically.
      Note that it is not possible to set the actual application icon which is
      displayed by the operating system on the desktop or 'home screen'. Those
      icons must be provided using the Project Options in Delphi (under
      Application | Icons).

      There are two ways to set the window icon:

        - at application start by setting the TAppConfig.Icon field
        - or later by calling the SetIcon method

      As a convenient shortcut, Sokol apps come with a builtin default-icon
      (a rainbow-colored 'S', which at least looks a bit better than the Windows
      default icon for applications), which can be activated by setting
      TAppConfig.Icon.UseDefault to True.

      Or later by calling SetIcon with the AIcon.UseDefault field set to True.

      Note that a completely zero-initialized TIconDesc record will not update
      the window icon in any way. This is an 'escape hatch' so that you can
      handle the window icon update yourself.

      Providing your own icon images works exactly like in GLFW (down to the
      data format):

      You provide one or more 'candidate images' in different sizes, and the
      platform backend picks the best match for the specific backend and icon
      type.

      For each candidate image, you need to provide:

        - the width in pixels
        - the height in pixels
        - and the actual pixel data in RGBA8 pixel format (e.g. 0xFFCC8844
          on a little-endian CPU means: alpha=$FF, blue=$CC, green=$88, red=$44)

      For an example and test of the window icon feature, check out the Icon
      sample application. }
    class procedure SetAppIcon(const AIcon: TIconDesc); inline; static;

    { Associate a custom mouse cursor image to a TMouseCursor enum entry }
    class function BindMouseCursorImage(const ACursor: TMouseCursor;
      const ADesc: TImageDesc): TMouseCursor; static;

    { Restore the TMouseCursor enum entry to it's default system appearance }
    class procedure UnbindMouseCursorImage(const ACursor: TMouseCursor); inline; static;

    { Without special quit handling, an application will quit 'gracefully' when
      the user clicks the window close-button unless a platform's application
      model prevents this (e.g. on web or mobile).
      'Graceful exit' means that Cleanup method will be called before the
      application quits.

      Native desktop platforms provide more control over the application-quit-
      process. It's possible to initiate a 'programmatic quit' from the
      application code, and a quit initiated by the application user can be
      intercepted (for instance to show a custom dialog box).

      This 'programmatic quit protocol' is implemented through 2 methods:
        - Quit: This method simply quits the application without giving the user
          a chance to intervene. Usually this might be called when the user
          clicks the 'Ok' button in a 'Really Quit?' dialog box.
        - RequestQuit: This method fires the QuitRequested event, giving the
          user code a chance to intervene and cancel the pending quit process
          (for instance to show a 'Really Quit?' dialog box). If the event
          leaves the ACanQuit parameter to True, the application will be quit as
          usual. To prevent this, sete ACanQuit to False.

      The Dear ImGui HighDPI sample contains example code of how to implement a
      'Really Quit?' dialog box with Dear ImGui (native desktop platforms
      only). }
    class procedure RequestQuit; inline; static;
    class procedure Quit; inline; static;

    { Adds an event handler.

      Whenever an event occurs, the application will first call any event
      handlers (in order of adding). When any of these handlers returns True, it
      means that the handler consumed the event and the event will not be
      processed any further (no other event handlers will be called, and the
      TApplication events will not be called either).

      If there are no event handlers, or they all return False, then the
      corresponsing TApplication event will be called (MouseDown, KeyUp etc.).

      For an example, see the Neslib.Sokol.ImGui unit, which uses an event
      handler to interact the the user interface. }
    class procedure AddEventHandler(const AHandler: TEventHandler); static;

    { Removes an event handler previously added with AddEventHandler }
    class procedure RemoveEventHandler(const AHandler: TEventHandler); static;

    { Returns an array of currently installed event handlers }
    class function GetEventHandlers: TArray<TEventHandler>; static;

    { True after the app has fully initialized. }
    class property IsValid: Boolean read GetIsValid;

    { Get runtime environment information }
    class property Environment: TAppEnvironment read GetEnvironment;

    { The current window title (desktop platforms only) }
    property WindowTitle: String read FConfig.WindowTitle write SetWindowTitle;

    { Current framebuffer width in physical units (pixels) }
    class property FramebufferWidth: Integer read GetFramebufferWidth;

    { Current framebuffer height in physical units (pixels) }
    class property FramebufferHeight: Integer read GetFramebufferHeight;

    { The color pixelformat of the default framebuffer }
    class property ColorFormat: TAppPixelFormat read GetColorFormat;

    { The depth pixelformat of the default framebuffer }
    class property DepthFormat: TAppPixelFormat read GetDepthFormat;

    { True when high-DPI was requested and actually running in a high-DPI
      scenario. }
    class property IsHighDpi: Boolean read GetHighDpi;

    { Returns the DPI scaling factor (window pixels to framebuffer pixels,
      eg. 2.0 for retina displays).
      Returns 1.0 when high-DPI is not available or has not been requested.

      Note that on some platforms the DPI scaling factor may change at any time
      (for instance when a window is moved from a high-dpi display to a low-dpi
      display).

      Currently there is no event associated with a DPI change, but a Resized
      event will be fired as a side effect of the framebuffer size changing.

      Per-monitor DPI is currently supported on macOS and Windows. }
    class property DpiScale: Single read GetDpiScale;

    { The configuration used to initialize the app. }
    property Config: TAppConfig read FConfig;

    { The actual MSAA sample count of the default framebuffer.
      May be different than the one requested in Config. }
    class property SampleCount: Integer read GetSampleCount;

    { The current frame counter }
    class property FrameCount: Int64 read GetFrameCount;

    { The averaged/smoothed frame duration in seconds. }
    class property FrameDuration: Double read GetFrameDuration;

    { 'Raw' unfiltered frame duration in seconds }
    class property FrameDurationUnfiltered: Double read GetFrameDurationUnfiltered;

    { Whether the onscreen keyboard is visible (on mobile devices). }
    class property KeyboardVisible: Boolean read GetKeyboardVisible write SetKeyboardVisible;

    { Whether the mouse cursor is visibile.
      Note that hiding the mouse cursor is different and independent from the
      mouse locking feature which will also hide the mouse pointer when active
      (see MouseLocked). }
    class property MouseCursorVisible: Boolean read GetMouseCursorVisible write SetMouseCursorVisible;

    { The current mouse cursor }
    class property MouseCursor: TMouseCursor read GetMouseCursor write SetMouseCursor;

    { Whether the mouse cursor is locked (aka captured).
      In normal mouse mode, no mouse movement events are reported when the mouse
      leaves the windows client area or hits the screen border (whether it's one
      or the other depends on the platform).

      To get continuous mouse movement (also when the mouse leaves the window
      client area or hits the screen border), activate mouse-lock mode by
      setting this property to True.

      When mouse lock is activated, the mouse pointer is hidden, the reported
      absolute mouse position appears frozen, and the relative mouse movement
      no longer has a direct relation to framebuffer pixels but instead uses
      "raw mouse input" (what "raw mouse input" exactly means also differs by
      platform).

      To deactivate mouse lock and return to normal mouse mode, set this
      property to False. }
    class property MouseLocked: Boolean read GetMouseLocked write SetMouseLocked;

    { Gets or sets a string on the clipboard.
      By default, clipboard support is disabled and must be enabled at startup
      via the following TAppConfig fields:

        TAppConfig.EnableClipboard  - set to True to enable clipboard support
        TAppConfig.MaxClipboardSize - size of the internal clipboard buffer in bytes

      Enabling the clipboard will dynamically allocate a clipboard buffer for
      UTF-8 encoded text data of the requested size in bytes, the default size
      is 8 KBytes. Strings that don't fit into the clipboard buffer (including
      the terminating zero) will be silently clipped, so it's important that you
      provide a big enough clipboard size for your use case.

      The ClipboardPasted event is fired when the user pastes from the clipboard
      using these keyboard shortcuts:
        - on macOS: when the Cmd+V key is pressed down
        - on all other platforms: when the Ctrl+V key is pressed down }
    class property ClipboardString: String read GetClipboardString write SetClipboardString;

    { Gets or sets the full screen mode.

      If the TAppConfig.Fullscreen flag is True, the app will try to create a
      fullscreen window on platforms with a 'proper' window system (mobile
      devices will always use fullscreen). The implementation details depend on
      the target platform. In general the app will use a 'soft approach' which
      doesn't interfere too much with the platform's window system (for instance
      borderless fullscreen window instead of a 'real' fullscreen mode). Such
      details might change over time as this library is adapted for different
      needs.

      The most important effect of fullscreen mode to keep in mind is that the
      requested canvas width and height will be ignored for the initial window
      size. FramebufferWidth and FramebufferHeight will instead return the
      resolution of the fullscreen canvas (however the provided size might still
      be used for the non-fullscreen window, in case the user can switch back
      from fullscreen- to windowed-mode).

      To toggle fullscreen mode, call ToggleFullscreen. }
    class property FullScreen: Boolean read GetFullScreen write SetFullScreen;

    { The EGLDisplay object on EGL backends }
    class property EglDisplay: Pointer read GetEglDisplay;

    { The EGLContext object on EGL backends }
    class property EglContext: Pointer read GetEglContext;

    { Handle of the native window. This value depends on the platform:
      * Windows: returns a HWND.
      * macOS: returns the Object ID of the NSWindow.
      * iOS: returns the Object ID of the UIWindow.
      * Android: returns 0 }
    class property NativeWindow: THandle read GetNativeWindow;

    { For Windows, the ID3D11SwapChain object.
      Returns nil when Direct3D11 is not supported or not used. }
    class property D3D11SwapChain: IInterface read GetD3D11SwapChain;

    { GL major version }
    class property GLMajorVersion: Integer read GetGLMajorVersion;

    { GL minor version }
    class property GLMinorVersion: Integer read GetGLMinorVersion;

    { Whether the context is GLES }
    class property GLIsGLES: Boolean read GetGLIsGLES;

    { For Android, get the native activity pointer (PANativeActivity).
      Returns 0 otherwise }
    class property AndroidNativeActivity: THandle read GetAndroidNativeActivity;

    { For Android, get the native window handle (PANativeWindow).
      Returns 0 otherwise }
    class property AndroidNativeWindow: THandle read GetAndroidNativeWindow;

    { Global application instance }
    class property Instance: TApplication read FInstance;
  end;
  TApplicationClass = class of TApplication;

procedure RunApp(const AAppClass: TApplicationClass);

implementation

uses
  {$IF Defined(MSWINDOWS)}
  Winapi.Windows,
  {$ELSEIF Defined(IOS)}
  iOSapi.Foundation,
  iOSapi.AVFoundation,
  iOSapi.UIKit,
  Macapi.Helpers,
  Macapi.ObjectiveC,
  Macapi.Metal,
  Macapi.MetalKit,
  {$ELSEIF Defined(MACOS)}
  Macapi.Foundation,
  Macapi.Helpers,
  Macapi.ObjectiveC,
  Macapi.CoreGraphics,
  Macapi.AppKit,
  Macapi.Metal,
  Macapi.MetalKit,
  {$ELSEIF Defined(ANDROID)}
  Androidapi.Log,
  Androidapi.Egl,
  Androidapi.Gles2,
  Androidapi.NativeActivity,
  Posix.Dlfcn,
  {$ENDIF}
  {$IFDEF SOKOL_MEM_TRACK}
  Neslib.Sokol.MemTrack,
  {$ELSE}
  Neslib.Sokol.Utils,
  {$ENDIF}
  System.Math;

{$IF Defined(IOS)}
const
  libAudioToolbox = '/System/Library/Frameworks/AudioToolbox.framework/AudioToolbox';

{ sokol_audio.h uses AudioToolbox }
procedure _AudioToolboxDummy cdecl; external libAudioToolbox name 'AudioQueuePause';
{$ELSEIF Defined(MACOS)}
const
  AppKitFwk = '/System/Library/Frameworks/AppKit.framework/AppKit';

{ sokol_app.h uses global NSApp variable }
procedure NSApp; cdecl; external AppKitFwk;

const
  QuartzCoreFwk = '/System/Library/Frameworks/QuartzCore.framework/QuartzCore';

{ sokol_app.h uses global kCAFilterNearest variable }
procedure kCAFilterNearest; cdecl; external QuartzCoreFwk;

{ sokol_app.h uses the @available() macro a couple of times.
  This translates to a call to __isPlatformVersionAtLeast inside compiler-rt.
  However, this library is (currently) not linked by Delphi and I don't want
  to deploy this library manually (since it is tied to a specific macOS
  version).

  So instead, we implement this function ourselves.
  The code is based on the LLVM compiler-rt project:
  * https://github.com/llvm-mirror/compiler-rt
  In the file lib\builtins\os_version_check.c

  NOTE: The code is based on __isOSVersionAtLeast in that source file, but I
  assume (hope) it works the same for __isPlatformVersionAtLeast. }

function __isPlatformVersionAtLeast(Major, Minor, Subminor: Int32): Int32; cdecl;
begin
  Result := Ord(TOSVersion.Check(Major, Minor));
end;

exports
  __isPlatformVersionAtLeast;
{$ELSEIF Defined(ANDROID)}
const
  AndroidGles3Lib = '/usr/lib/libGLESv3.so';

procedure ANativeActivity_onCreate(activity: PANativeActivity;
  saved_state: Pointer; saved_state_size: NativeInt); cdecl;
  external _LIB_SOKOL name 'ANativeActivity_onCreate'
  dependency LibCPP_ABI;

{ Link in GLES-3 library }
procedure _Gles3Dummy; cdecl; external AndroidGles3Lib name 'glGetStringi';

function sokol_main(argc: Integer; argv: PPAnsiChar): _sapp_desc;
type
  TMainFunction = procedure;
begin
  var Activity: PANativeActivity := _sapp_android_get_native_activity;
  Assert(Activity <> nil);
  DelphiActivity := Activity;
  JavaMachine := Activity^.vm;
  JavaContext := Activity^.clazz;

  var Info: dl_info;
  if (dladdr(NativeUInt(@RunApp), Info) <> 0) then
  begin
    var Lib := dlopen(Info.dli_fname, RTLD_LAZY);
    if (Lib <> 0) then
    begin
      var Sym := dlsym(Lib, '_NativeMain');
      dlclose(Lib);

      if (Sym <> nil) then
      begin
        var EntryPoint := TMainFunction(Sym);
        EntryPoint();

        Result := TApplication.FDesc;
      end;
    end;
  end;
end;

exports
  ANativeActivity_onCreate,
  sokol_main;

var
  glVertexAttribDivisor: procedure(index: GLuint; divisor: GLuint); cdecl = nil;
  glDrawArraysInstanced: procedure(mode: GLenum; first: GLint; count: GLsizei;
    instancecount: GLsizei); cdecl = nil;
  glDrawElementsInstanced: procedure(mode: GLenum; count: GLsizei;
    type_: GLenum; const indices: Pointer; instancecount: GLsizei); cdecl = nil;

procedure glVertexAttribDivisorANGLE(index: GLuint; divisor: GLuint); cdecl;
begin
  if Assigned(glVertexAttribDivisor) then
    glVertexAttribDivisor(index, divisor);
end;

procedure glDrawArraysInstancedANGLE(mode: GLenum; first: GLint; count: GLsizei;
  instancecount: GLsizei); cdecl;
begin
  if Assigned(glDrawArraysInstanced) then
    glDrawArraysInstanced(mode, first, count, instancecount);
end;

procedure glDrawElementsInstancedANGLE(mode: GLenum; count: GLsizei;
  type_: GLenum; const indices: Pointer; instancecount: GLsizei); cdecl;
begin
  if Assigned(glDrawElementsInstanced) then
    glDrawElementsInstanced(mode, count, type_, indices, instancecount);
end;

procedure InitGles2Angle;
begin
  var Lib := dlopen(
    {$IFDEF ANDROID64}
    '/system/lib64/libGLESv2.so',
    {$ELSE}
    '/system/lib/libGLESv2.so',
    {$ENDIF}
    RTLD_LAZY);
  Assert(Lib <> 0);
  if (Lib = 0) then
    Exit;

  @glVertexAttribDivisor := dlsym(Lib, 'glVertexAttribDivisorANGLE');
  if (not Assigned(glVertexAttribDivisor)) then
    @glVertexAttribDivisor := dlsym(Lib, 'glVertexAttribDivisorEXT');

  @glDrawArraysInstanced := dlsym(Lib, 'glDrawArraysInstancedANGLE');
  if (not Assigned(glDrawArraysInstanced)) then
    @glDrawArraysInstanced := dlsym(Lib, 'glDrawArraysInstancedEXT');

  @glDrawElementsInstanced := dlsym(Lib, 'glDrawElementsInstancedANGLE');
  if (not Assigned(glDrawElementsInstanced)) then
    @glDrawElementsInstanced := dlsym(Lib, 'glDrawElementsInstancedEXT');

  dlclose(Lib);
end;

exports
  glVertexAttribDivisorANGLE,
  glDrawArraysInstancedANGLE,
  glDrawElementsInstancedANGLE;
{$ENDIF}

procedure RunApp(const AAppClass: TApplicationClass);
begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  Assert(TApplication.FInstance = nil);
  TApplication.FInstance := AAppClass.Create;

  { On Android, the application loop is handled by the native activity
    callback, so we should not run it here or destroy the app. }
  {$IFNDEF ANDROID}
  try
    TApplication.FInstance.Run;
  finally
    { On Android, TApplication.FInstance.Run returns immediately and passes
      control to Sokols native code, so we cannot destroy the app here. }
    TApplication.FInstance.Free;
    TApplication.FInstance := nil;
  end;
  {$ENDIF}
end;

{ _TLogItemHelper }

function _TLogItemHelper.ToString: String;
const
  STRINGS: array [TLogItem] of String = (
    'Ok',
    'memory allocation failed',
    'TAppConfig.Swapchain.DepthFormat must be TAppPixelFormat.Default, TAppPixelFormat.None, TAppPixelFormat.Depth or TAppPixelFormat.DepthSencil',
    'macos: invalid NSOpenGLProfile (valid choices are 1.0 and 4.1)',
    'metal: failed to create swapchain depth-buffer texture',
    'metal: failed to create swapchain msaa texture',
    'failed loading opengl32.dll',
    'failed to create helper window',
    'failed to get helper window DC',
    'failed to set pixel format for dummy GL context',
    'failed to create dummy GL context',
    'failed to make dummy GL context current',
    'failed to get WGL pixel format attribute',
    'failed to find matching WGL pixel format',
    'failed to get pixel format descriptor',
    'failed to set selected pixel format',
    'ARB_create_context required',
    'ARB_create_context_profile required',
    'requested OpenGL version not supported by GL driver (ERROR_INVALID_VERSION_ARB)',
    'requested OpenGL profile not support by GL driver (ERROR_INVALID_PROFILE_ARB)',
    'CreateContextAttribsARB failed with ERROR_INCOMPATIBLE_DEVICE_CONTEXTS_ARB',
    'CreateContextAttribsARB failed for other reason',
    'D3D11CreateDeviceAndSwapChain() with D3D11_CREATE_DEVICE_DEBUG failed, retrying without debug flag.',
    'could not obtain IDXGIFactory object',
    'could not obtain IDXGIAdapter object',
    'could not obtain IDXGIDevice1 interface',
    'RegisterRawInputDevices() failed (on mouse lock)',
    'RegisterRawInputDevices() failed (on mouse unlock)',
    'GetRawInputData() failed',
    'DestroyIcon() for a cursor image failed',
    'failed to load libGL',
    'failed to load GLX entry points',
    'GLX extension not found',
    'failed to query GLX version',
    'GLX version too low (need at least 1.3)',
    'glXGetFBConfigs() returned no configs',
    'failed to find a suitable GLXFBConfig',
    'glXGetVisualFromFBConfig failed',
    'GLX extensions ARB_create_context and ARB_create_context_profile missing',
    'Failed to create GL context via glXCreateContextAttribsARB',
    'glXCreateWindow() failed',
    'XCreateWindow() failed',
    'eglBindAPI(EGL_OPENGL_API) failed',
    'eglBindAPI(EGL_OPENGL_ES_API) failed',
    'eglGetDisplay() failed',
    'eglInitialize() failed',
    'eglChooseConfig() returned no configs',
    'eglGetConfigAttrib() for EGL_NATIVE_VISUAL_ID failed',
    'XGetVisualInfo() failed',
    'eglCreateWindowSurface() failed',
    'eglCreateContext() failed',
    'eglMakeCurrent() failed',
    'XOpenDisplay() failed',
    'failed to query system dpi value, assuming default 96.0',
    'dropped file URL doesn''t start with ''file://''',
    'X11: Failed to become owner of clipboard selection',
    'unsupported input event encountered in _sapp_android_input_cb()',
    'unsupported input event encountered in _sapp_android_main_cb()',
    'failed to read message in _sapp_android_main_cb()',
    'failed to write message in _sapp_android_msg',
    'MSG_CREATE',
    'MSG_RESUME',
    'MSG_PAUSE',
    'MSG_FOCUS',
    'MSG_NO_FOCUS',
    'MSG_SET_NATIVE_WINDOW',
    'MSG_SET_INPUT_QUEUE',
    'MSG_DESTROY',
    'unknown msg type received',
    'loop thread started',
    'loop thread done',
    'NativeActivity onStart()',
    'NativeActivity onResume',
    'NativeActivity onSaveInstanceState',
    'NativeActivity onWindowFocusChanged',
    'NativeActivity onPause',
    'NativeActivity onStop()',
    'NativeActivity onNativeWindowCreated',
    'NativeActivity onNativeWindowDestroyed',
    'NativeActivity onInputQueueCreated',
    'NativeActivity onInputQueueDestroyed',
    'NativeActivity onConfigurationChanged',
    'NativeActivity onLowMemory',
    'NativeActivity onDestroy',
    'NativeActivity done',
    'NativeActivity onCreate',
    'failed to create thread pipe',
    'NativeActivity successfully created',
    'Choreographer frame loop enabled',
    'Choreographer unavailable, using poll loop',
    'wgpu: device lost',
    'wgpu: device log',
    'wgpu: uncaptured error',
    'wgpu: failed to create surface for swapchain',
    'wgpu: wgpuSurfaceGetCapabilities failed',
    'wgpu: failed to create depth-stencil texture for swapchain',
    'wgpu: failed to create view object for swapchain depth-stencil texture',
    'wgpu: failed to create msaa texture for swapchain',
    'wgpu: failed to create view object for swapchain msaa texture',
    'wgpu: wgpuSurfaceGetCurrentTexture() failed',
    'wgpu: requesting device failed with status ''error''',
    'wgpu: requesting device failed with status ''unknown''',
    'wgpu: requesting adapter failed with ''unavailable''',
    'wgpu: requesting adapter failed with status ''error''',
    'wgpu: requesting adapter failed with status ''unknown''',
    'wgpu: failed to create instance',
    'vulkan: could not lookup a required instance extension function pointer',
    'vulkan: could not find suitable memory type',
    'vulkan: vkAllocateMemory() failed!',
    'vulkan: vkCreateInstance failed',
    'vulkan: vkEnumeratePhysicalDevices failed',
    'vulkan: vkEnumeratePhysicalDevices return no devices',
    'vulkan: no suitable physical device found',
    'vulkan: vkCreateDevice failed (extension not present)',
    'vulkan: vkCreateDevice failed (feature not present)',
    'vulkan: vkCreateDevice failed (initialization failed)',
    'vulkan: vkCreateDevice failed (other)',
    'vulkan: vkCreate*SurfaceKHR failed',
    'vulkan: vkCreateSwapchainKHR failed',
    'vulkan: vkCreateImageView for swapchain image failed',
    'vulkan: vkCreateImage for depth-stencil image failed',
    'vulkan: failed to allocate device memory for depth-stencil image',
    'vulkan: vkBindImageMemory() for depth-stencil image failed',
    'vulkan: vkAcquireNextImageKHR failed',
    'vulkan: vkQueuePresentKHR failed',
    'image data size mismatch (must be width*height*4 bytes)',
    'dropped file path too long (sapp_desc.max_dropped_filed_path_length)',
    'clipboard string didn''t fit into clipboard buffer');
begin
  Result := STRINGS[Self];
end;

{ TTouchPoint }

function TTouchPoint.GetToolType: TAndroidToolType;
begin
  Result := TAndroidToolType(FHandle.android_tooltype);
end;

procedure TTouchPoint.SetToolType(const AValue: TAndroidToolType);
begin
  FHandle.android_tooltype := Ord(AValue);
end;

{ TImageDesc }

constructor TImageDesc.Create(const AWidth, AHeight: Integer;
  const AData: Pointer; const ASize, ACursorHotspotX, ACursorHotspotY: Integer);
begin
  Init(AWidth, AHeight, AData, ASize, ACursorHotspotX, ACursorHotspotY);
end;

constructor TImageDesc.Create(const AWidth, AHeight: Integer;
  const APixels: TBytes; const ACursorHotspotX, ACursorHotspotY: Integer);
begin
  Init(AWidth, AHeight, Pointer(APixels), Length(APixels), ACursorHotspotX,
    ACursorHotspotY);
end;

procedure TImageDesc.Init(const AWidth, AHeight: Integer; const AData: Pointer;
  const ASize, ACursorHotspotX, ACursorHotspotY: Integer);
begin
  Width := AWidth;
  Height := AHeight;
  CursorHotspotX := ACursorHotspotX;
  CursorHotspotY := ACursorHotspotY;
  Data := AData;
  Size := ASize;
end;

procedure TImageDesc.Init(const AWidth, AHeight: Integer;
  const APixels: TBytes; const ACursorHotspotX, ACursorHotspotY: Integer);
begin
  Init(AWidth, AHeight, Pointer(APixels), Length(APixels), ACursorHotspotX,
    ACursorHotspotY);
end;

{ TIconDesc }

class function TIconDesc.Create: TIconDesc;
begin
  Result.Init;
end;

procedure TIconDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TAppEnvironmentDefaults }

function TAppEnvironmentDefaults.GetColorFormat: TAppPixelFormat;
begin
  Result := TAppPixelFormat(FHandle.color_format);
end;

function TAppEnvironmentDefaults.GetDepthFormat: TAppPixelFormat;
begin
  Result := TAppPixelFormat(FHandle.depth_format);
end;

{ TAppD3D11Environment }

function TAppD3D11Environment.GetDevice: IInterface;
begin
  Result := IInterface(FHandle.device);
end;

function TAppD3D11Environment.GetDeviceContext: IInterface;
begin
  Result := IInterface(FHandle.device_context);
end;

{ TAppEnvironment }

function TAppEnvironment.GetD3D11: PAppD3D11Environment;
begin
  Result := @FHandle.d3d11;
end;

function TAppEnvironment.GetDefaults: PAppEnvironmentDefaults;
begin
  Result := @FHandle.defaults;
end;

function TAppEnvironment.GetMetal: PAppMetalEnvironment;
begin
  Result := @FHandle.metal;
end;

function TAppEnvironment.GetVulkan: PAppVulkanEnvironment;
begin
  Result := @FHandle.vulkan;
end;

{ TAppD3D11Swapchain }

function TAppD3D11Swapchain.GetDepthStencilView: IInterface;
begin
  Result := IInterface(FHandle.depth_stencil_view);
end;

function TAppD3D11Swapchain.GetRenderView: IInterface;
begin
  Result := IInterface(FHandle.render_view);
end;

function TAppD3D11Swapchain.GetResolveView: IInterface;
begin
  Result := IInterface(FHandle.resolve_view);
end;

{ TAppSwapchain }

function TAppSwapchain.GetColorFormat: TAppPixelFormat;
begin
  Result := TAppPixelFormat(FHandle.color_format);
end;

function TAppSwapchain.GetD3D11: PAppD3D11Swapchain;
begin
  Result := @FHandle.d3d11;
end;

function TAppSwapchain.GetDepthFormat: TAppPixelFormat;
begin
  Result := TAppPixelFormat(FHandle.depth_format);
end;

function TAppSwapchain.GetGL: PAppGLSwapchain;
begin
  Result := @FHandle.gl;
end;

function TAppSwapchain.GetMetal: PAppMetalSwapchain;
begin
  Result := @FHandle.metal;
end;

function TAppSwapchain.GetVulkan: PAppVulkanSwapchain;
begin
  Result := @FHandle.vulkan;
end;

{ TAppConfig }

procedure TAppConfig.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
  WindowTitle := 'Neslib.Sokol Application';
  SampleCount := 1;
  SwapInterval := 1;
  MaxClipboardSize := 8192;
  MaxDroppedFiles := 1;
  MaxDroppedFilePathLength := 2048;
  Icon.UseDefault := True;
end;

{ TEvent }

function TEvent.GetFrameCount: Int64;
begin
  Result := FHandle.frame_count;
end;

function TEvent.GetKeyCode: TKeyCode;
begin
  Result := TKeyCode(FHandle.key_code);
end;

function TEvent.GetKind: TEventKind;
begin
  Result := TEventKind(FHandle.&type);
end;

function TEvent.GetModifiers: TModifiers;
begin
  Result := TModifiers(Word(FHandle.modifiers));
end;

function TEvent.GetMouseButton: TMouseButton;
begin
  Result := TMouseButton(FHandle.mouse_button);
end;

function TEvent.GetTouch(const AIndex: Integer): PTouchPoint;
begin
  Assert(Cardinal(AIndex) < Cardinal(Length(FHandle.touches)));
  Result := @FHandle.touches[AIndex];
end;

{ TApplication }

class function TApplication.AcquireSwapchain: TAppSwapchain;
begin
  Result.FHandle := _sapp_acquire_swapchain;
end;

class procedure TApplication.AddEventHandler(
  const AHandler: TEventHandler);
begin
  if (not GEventHandlers.Contains(AHandler)) then
    GEventHandlers.Add(AHandler);
end;

class function TApplication.BindMouseCursorImage(const ACursor: TMouseCursor;
  const ADesc: TImageDesc): TMouseCursor;
begin
  var Desc: _sapp_image_desc;
  Desc.width := ADesc.Width;
  Desc.height := ADesc.Height;
  Desc.cursor_hotspot_x := ADesc.CursorHotspotX;
  Desc.cursor_hotspot_y := ADesc.CursorHotspotY;
  Desc.pixels.ptr := ADesc.Data;
  Desc.pixels.size := ADesc.Size;
  Result := TMouseCursor(_sapp_bind_mouse_cursor_image(Ord(ACursor), @Desc));
end;

procedure TApplication.Cleanup;
begin
  { No default implementation }
end;

class procedure TApplication.CleanupCallback(AUserData: Pointer);
var
  App: TApplication absolute AUserData;
begin
  Assert(Assigned(AUserData));
  if Assigned(AUserData) then
    App.Cleanup;
end;

procedure TApplication.ClipboardPasted(const AClipboardString: String);
begin
  { No default implementation }
end;

procedure TApplication.Configure(var AConfig: TAppConfig);
begin
  { No default implementation }
end;

class constructor TApplication.Create;
begin
  GEventHandlers := TList<TEventHandler>.Create;
end;

constructor TApplication.Create;
var
  LogFunc: TLogFunc;
  LogMethod: TMethod absolute LogFunc;
begin
  inherited Create;
  FConfig.Init;
  Configure(FConfig);

  FWindowTitle := UTF8String(FConfig.WindowTitle);

  GDesc.user_data := Self;
  GDesc.init_userdata_cb := InitCallback;
  GDesc.frame_userdata_cb := FrameCallback;
  GDesc.cleanup_userdata_cb := CleanupCallback;
  GDesc.event_userdata_cb := EventCallback;

  GDesc.width := Max(FConfig.Width, 0);
  GDesc.height := Max(FConfig.Height, 0);
  GDesc.depth_format := Ord(FConfig.DepthFormat);
  GDesc.sample_count := Max(FConfig.SampleCount, 1);
  GDesc.swap_interval := Max(FConfig.SwapInterval, 1);
  GDesc.srgb := FConfig.sRgb;
  GDesc.hdr := FConfig.Hdr;
  GDesc.disable_vsync := FConfig.DisableVSync;
  GDesc.high_dpi := FConfig.HighDpi;
  GDesc.fullscreen := FConfig.FullScreen;
  GDesc.window_title := PUTF8Char(FWindowTitle);
  GDesc.enable_clipboard := FConfig.EnableClipboard;
  GDesc.clipboard_size := FConfig.MaxClipboardSize;
  GDesc.enable_dragndrop := FConfig.EnableDragDrop;
  GDesc.max_dropped_files := FConfig.MaxDroppedFiles;
  GDesc.max_dropped_file_path_length := FConfig.MaxDroppedFilePathLength;
  if Assigned(FConfig.Logger.Func) then
  begin
    LogFunc := FConfig.Logger.Func;
    GDesc.logger.func := LogCallback;
    GDesc.logger.user_data := LogMethod.Data;
  end;

  GDesc.gl.major_version := FConfig.GL.MajorVersion;
  GDesc.gl.minor_version := FConfig.GL.MinorVersion;

  GDesc.metal.disable_display_sync := FConfig.Metal.DisableDisplaySync;

  GDesc.win32.console_utf8 := FConfig.Win32.ConsoleUtf8;
  GDesc.win32.console_create := FConfig.Win32.ConsoleCreate;
  GDesc.win32.console_attach := FConfig.Win32.ConsoleAttach;

  GDesc.ios.keyboard_resizes_canvas := FConfig.iOS.KeyboardResizesCanvas;

  GDesc.icon.sokol_default := FConfig.Icon.UseDefault;
  if (not FConfig.Icon.UseDefault) then
  begin
    for var I := 0 to TIconDesc.MAX_IMAGES - 1 do
    begin
      GDesc.icon.images[I].width := FConfig.Icon.Images[I].Width;
      GDesc.icon.images[I].height := FConfig.Icon.Images[I].Height;
      GDesc.icon.images[I].pixels.ptr := FConfig.Icon.Images[I].Data;
      GDesc.icon.images[I].pixels.size := FConfig.Icon.Images[I].Size;
    end;
  end;

  {$IFDEF SOKOL_MEM_TRACK}
  GDesc.allocator.alloc := _MemTrackAlloc;
  GDesc.allocator.free := _MemTrackFree;
  {$ELSE}
  if (FConfig.UseDelphiMemoryManager) then
  begin
    GDesc.allocator.alloc_fn := _AllocCallback;
    GDesc.allocator.free_fn := _FreeCallback;
  end;
  {$ENDIF}
end;

class destructor TApplication.Destroy;
begin
  FreeAndNil(GEventHandlers);
end;

destructor TApplication.Destroy;
begin
  inherited;
end;

class procedure TApplication.EventCallback(const AEvent: _Psapp_event;
  AUserData: Pointer);
var
  App: TApplication absolute AUserData;
begin
  Assert(Assigned(AUserData));
  if Assigned(AUserData) then
    App.HandleEvent(AEvent);
end;

class procedure TApplication.FailCallback(const AMsg: PUTF8Char;
  AUserData: Pointer);
var
  App: TApplication absolute AUserData;
begin
  Assert(Assigned(AUserData));
  if Assigned(AUserData) then
    App.FatalError(String(UTF8String(AMsg)));
end;

procedure TApplication.FatalError(const AMsg: String);
begin
  Log(AMsg);
end;

procedure TApplication.FilesDropped(const AX, AY: Single;
  const AFilePaths: TArray<String>);
begin
  { No default implementation }
end;

class function TApplication.GetAndroidNativeActivity: THandle;
begin
  Result := THandle(_sapp_android_get_native_activity);
end;

class function TApplication.GetAndroidNativeWindow: THandle;
begin
  Result := THandle(_sapp_android_get_native_window);
end;

class function TApplication.GetClipboardString: String;
begin
  Result := String(UTF8String(_sapp_get_clipboard_string));
end;

class function TApplication.GetColorFormat: TAppPixelFormat;
begin
  Result := TAppPixelFormat(_sapp_color_format);
end;

class function TApplication.GetD3D11SwapChain: IInterface;
begin
  Result := IInterface(_sapp_d3d11_get_swap_chain);
end;

class function TApplication.GetDepthFormat: TAppPixelFormat;
begin
  Result := TAppPixelFormat(_sapp_depth_format);
end;

class function TApplication.GetDpiScale: Single;
begin
  Result := _sapp_dpi_scale;
end;

class function TApplication.GetEglContext: Pointer;
begin
  Result := _sapp_egl_get_context;
end;

class function TApplication.GetEglDisplay: Pointer;
begin
  Result := _sapp_egl_get_display;
end;

class function TApplication.GetEnvironment: TAppEnvironment;
begin
  Result.FHandle := _sapp_get_environment;
end;

class function TApplication.GetEventHandlers: TArray<TEventHandler>;
begin
  Result := GEventHandlers.ToArray;
end;

class function TApplication.GetFramebufferHeight: Integer;
begin
  Result := _sapp_height;
end;

class function TApplication.GetFramebufferWidth: Integer;
begin
  Result := _sapp_width;
end;

class function TApplication.GetFrameCount: Int64;
begin
  Result := _sapp_frame_count;
end;

class function TApplication.GetFrameDuration: Double;
begin
  Result := _sapp_frame_duration;
end;

class function TApplication.GetFrameDurationUnfiltered: Double;
begin
  Result := _sapp_frame_duration_unfiltered;
end;

class function TApplication.GetFullScreen: Boolean;
begin
  Result := _sapp_is_fullscreen;
end;

class function TApplication.GetGLIsGLES: Boolean;
begin
  Result := _sapp_gl_is_gles;
end;

class function TApplication.GetGLMajorVersion: Integer;
begin
  Result := _sapp_gl_get_major_version;
end;

class function TApplication.GetGLMinorVersion: Integer;
begin
  Result := _sapp_gl_get_minor_version;
end;

class function TApplication.GetHighDpi: Boolean;
begin
  Result := _sapp_high_dpi;
end;

class function TApplication.GetIsValid: Boolean;
begin
  Result := _sapp_isvalid;
end;

class function TApplication.GetKeyboardVisible: Boolean;
begin
  Result := _sapp_keyboard_shown;
end;

class function TApplication.GetMouseCursor: TMouseCursor;
begin
  Result := TMouseCursor(_sapp_get_mouse_cursor);
end;

class function TApplication.GetMouseCursorVisible: Boolean;
begin
  Result := _sapp_mouse_shown;
end;

class function TApplication.GetMouseLocked: Boolean;
begin
  Result := _sapp_mouse_locked;
end;

class function TApplication.GetNativeWindow: THandle;
begin
  {$IF Defined(MSWINDOWS)}
  Result := THandle(_sapp_win32_get_hwnd);
  {$ELSEIF Defined(IOS)}
  Result := THandle(_sapp_ios_get_window);
  {$ELSEIF Defined(MACOS)}
  Result := THandle(_sapp_macos_get_window);
  {$ELSE}
  Result := 0;
  {$ENDIF}
end;

class function TApplication.GetSampleCount: Integer;
begin
  Result := _sapp_sample_count;
end;

procedure TApplication.HandleClipboardPasted;
begin
  ClipboardPasted(String(UTF8String(_sapp_get_clipboard_string)));
end;

procedure TApplication.HandleEvent(const AEvent: _Psapp_event);
var
  Touches: TTouches;
begin
  for var Handler in GEventHandlers do
  begin
    if Handler(PEvent(AEvent)^) then
      Exit;
  end;

  case AEvent.&type of
    _SAPP_EVENTTYPE_KEY_DOWN:
      KeyDown(TKeyCode(AEvent.key_code), TModifiers(Word(AEvent.modifiers)), AEvent.key_repeat);

    _SAPP_EVENTTYPE_KEY_UP:
      KeyUp(TKeyCode(AEvent.key_code), TModifiers(Word(AEvent.modifiers)), AEvent.key_repeat);

    _SAPP_EVENTTYPE_CHAR:
      KeyChar(AEvent.char_code, TModifiers(Word(AEvent.modifiers)), AEvent.key_repeat);

    _SAPP_EVENTTYPE_MOUSE_DOWN:
      MouseDown(TMouseButton(AEvent.mouse_button), AEvent.mouse_x, AEvent.mouse_y, TModifiers(Word(AEvent.modifiers)));

    _SAPP_EVENTTYPE_MOUSE_UP:
      MouseUp(TMouseButton(AEvent.mouse_button), AEvent.mouse_x, AEvent.mouse_y, TModifiers(Word(AEvent.modifiers)));

    _SAPP_EVENTTYPE_MOUSE_SCROLL:
      MouseScroll(AEvent.scroll_x, AEvent.scroll_y, TModifiers(Word(AEvent.modifiers)));

    _SAPP_EVENTTYPE_MOUSE_MOVE:
      MouseMove(AEvent.mouse_x, AEvent.mouse_y, AEvent.mouse_dx, AEvent.mouse_dy, TModifiers(Word(AEvent.modifiers)));

    _SAPP_EVENTTYPE_MOUSE_ENTER:
      MouseEnter(AEvent.mouse_x, AEvent.mouse_y, TModifiers(Word(AEvent.modifiers)));

    _SAPP_EVENTTYPE_MOUSE_LEAVE:
      MouseLeave(AEvent.mouse_x, AEvent.mouse_y, TModifiers(Word(AEvent.modifiers)));

    _SAPP_EVENTTYPE_TOUCHES_BEGAN:
      begin
        Touches.Count := AEvent.num_touches;
        Move(AEvent.touches, Touches.Touches, AEvent.num_touches * SizeOf(_sapp_touchpoint));
        TouchesBegan(Touches);
      end;

    _SAPP_EVENTTYPE_TOUCHES_MOVED:
      begin
        Touches.Count := AEvent.num_touches;
        Move(AEvent.touches, Touches.Touches, AEvent.num_touches * SizeOf(_sapp_touchpoint));
        TouchesMoved(Touches);
      end;

    _SAPP_EVENTTYPE_TOUCHES_ENDED:
      begin
        Touches.Count := AEvent.num_touches;
        Move(AEvent.touches, Touches.Touches, AEvent.num_touches * SizeOf(_sapp_touchpoint));
        TouchesEnded(Touches);
      end;

    _SAPP_EVENTTYPE_TOUCHES_CANCELLED:
      begin
        Touches.Count := AEvent.num_touches;
        Move(AEvent.touches, Touches.Touches, AEvent.num_touches * SizeOf(_sapp_touchpoint));
        TouchesCancelled(Touches);
      end;

    _SAPP_EVENTTYPE_RESIZED:
      Resized(AEvent.window_width, AEvent.window_height, AEvent.framebuffer_width, AEvent.framebuffer_height);

    _SAPP_EVENTTYPE_ICONIFIED:
      Iconified;

    _SAPP_EVENTTYPE_RESTORED:
      Restored;

    _SAPP_EVENTTYPE_FOCUSED:
      Focused;

    _SAPP_EVENTTYPE_UNFOCUSED:
      Unfocused;

    _SAPP_EVENTTYPE_SUSPENDED:
      Suspended;

    _SAPP_EVENTTYPE_RESUMED:
      Resumed;

    _SAPP_EVENTTYPE_QUIT_REQUESTED:
      begin
        var CanQuit := True;
        QuitRequested(CanQuit);
        if (not CanQuit) then
          _sapp_cancel_quit;
      end;

    _SAPP_EVENTTYPE_CLIPBOARD_PASTED:
      { Use separate method to avoid managed string type here }
      HandleClipboardPasted;

    _SAPP_EVENTTYPE_FILES_DROPPED:
      { Use separate method to avoid managed dynarray type here }
      HandleFilesDropped(AEvent.mouse_x, AEvent.mouse_y);
  end;
end;

procedure TApplication.HandleFilesDropped(const AX, AY: Single);
begin
  var FilePaths: TArray<String>;
  SetLength(FilePaths, _sapp_get_num_dropped_files);
  if (FilePaths = nil) then
    Exit;

  for var I := 0 to Length(FilePaths) - 1 do
    FilePaths[I] := String(UTF8String(_sapp_get_dropped_file_path(I)));

  FilesDropped(AX, AY, FilePaths);
end;

procedure TApplication.Focused;
begin
  { No default implementation }
end;

procedure TApplication.Frame;
begin
  { No default implementation }
end;

class procedure TApplication.FrameCallback(AUserData: Pointer);
var
  App: TApplication absolute AUserData;
begin
  Assert(Assigned(AUserData));
  if Assigned(AUserData) then
    App.Frame;
end;

procedure TApplication.Iconified;
begin
  { No default implementation }
end;

procedure TApplication.Init;
begin
  { No default implementation }
end;

class procedure TApplication.InitCallback(AUserData: Pointer);
var
  App: TApplication absolute AUserData;
begin
  Assert(Assigned(AUserData));
  if Assigned(AUserData) then
    App.Init;
end;

class procedure TApplication.Log(const AMsg: String);
begin
  {$IF Defined(MSWINDOWS)}
  OutputDebugString(PChar(AMsg));
  {$ELSEIF Defined(MACOS)}
  NSLog((StrToNSStr(AMsg) as ILocalObject).GetObjectID);
  {$ELSEIF Defined(ANDROID)}
  LOGI(PUTF8Char(UTF8String(AMsg)));
  {$ELSE}
    {$MESSAGE Error 'Unsupported platform'}
  {$ENDIF}
end;

class procedure TApplication.Log(const AMsg: String;
  const AArgs: array of const);
begin
  Log(Format(AMsg, AArgs));
end;

class procedure TApplication.LogCallback(const ATag: PUTF8Char; ALogLevel,
  ALogItemId: UInt32; const AMessageOrNull: PUTF8Char; ALineNr: UInt32;
  const AFilenameOrNull: PUTF8Char; AUserData: Pointer);
var
  LogFunc: TLogFunc;
  LogMethod: TMethod absolute LogFunc;
begin
  Assert(Assigned(GLogFunc));
  LogFunc := GLogFunc;
  LogMethod.Data := AUserData;
  LogFunc(String(UTF8String(ATag)), TLogLevel(ALogLevel), TLogItem(ALogItemId),
    String(UTF8String(AMessageOrNull)), ALineNr,
    String(UTF8String(AFilenameOrNull)));
end;

procedure TApplication.KeyChar(const AChar: UCS4Char;
  const AModifiers: TModifiers; const AKeyRepeat: Boolean);
begin
  { No default implementation }
end;

procedure TApplication.KeyDown(const AKey: TKeyCode;
  const AModifiers: TModifiers; const AKeyRepeat: Boolean);
begin
  { No default implementation }
end;

procedure TApplication.KeyUp(const AKey: TKeyCode;
  const AModifiers: TModifiers; const AKeyRepeat: Boolean);
begin
  { No default implementation }
end;

procedure TApplication.MouseDown(const AButton: TMouseButton; const AX,
  AY: Single; const AModifiers: TModifiers);
begin
  { No default implementation }
end;

procedure TApplication.MouseEnter(const AX, AY: Single;
  const AModifiers: TModifiers);
begin
  { No default implementation }
end;

procedure TApplication.MouseLeave(const AX, AY: Single;
  const AModifiers: TModifiers);
begin
  { No default implementation }
end;

procedure TApplication.MouseMove(const AX, AY, ADX, ADY: Single;
  const AModifiers: TModifiers);
begin
  { No default implementation }
end;

procedure TApplication.MouseScroll(const AWheelDeltaX, AWheelDeltaY: Single;
  const AModifiers: TModifiers);
begin
  { No default implementation }
end;

procedure TApplication.MouseUp(const AButton: TMouseButton; const AX,
  AY: Single; const AModifiers: TModifiers);
begin
  { No default implementation }
end;

class procedure TApplication.Quit;
begin
  _sapp_quit;
end;

procedure TApplication.QuitRequested(var ACanQuit: Boolean);
begin
  { No default implementation }
end;

class procedure TApplication.RemoveEventHandler(
  const AHandler: TEventHandler);
begin
  GEventHandlers.Remove(AHandler);
end;

class procedure TApplication.RequestQuit;
begin
  _sapp_request_quit;
end;

procedure TApplication.Resized(const AWindowWidth, AWindowHeight,
  AFramebufferWidth, AFramebufferHeight: Integer);
begin
  { No default implementation }
end;

procedure TApplication.Restored;
begin
  { No default implementation }
end;

procedure TApplication.Resumed;
begin
  { No default implementation }
end;

procedure TApplication.Run;
begin
  { On Android, the application loop is handled by the native activity
    callback. }
  {$IFNDEF ANDROID}
  _sapp_run(@GDesc);
  {$ENDIF}
end;

class procedure TApplication.SetAppIcon(const AIcon: TIconDesc);
begin
  var Desc: _sapp_icon_desc;
  Desc.sokol_default := AIcon.UseDefault;
  for var I := 0 to _SAPP_MAX_ICONIMAGES - 1 do
  begin
    Desc.images[I].width := AIcon.Images[I].Width;
    Desc.images[I].height := AIcon.Images[I].Height;
    Desc.images[I].pixels.ptr := AIcon.Images[I].Data;
    Desc.images[I].pixels.size := AIcon.Images[I].Size;
  end;
  _sapp_set_icon(@Desc);
end;

class procedure TApplication.SetClipboardString(const AValue: String);
begin
  _sapp_set_clipboard_string(PUTF8Char(UTF8String(AValue)));
end;

class procedure TApplication.SetFullScreen(const AValue: Boolean);
begin
  if (_sapp_is_fullscreen <> AValue) then
    _sapp_toggle_fullscreen;
end;

class procedure TApplication.SetKeyboardVisible(const AValue: Boolean);
begin
  _sapp_show_keyboard(AValue);
end;

class procedure TApplication.SetMouseCursor(const AValue: TMouseCursor);
begin
  _sapp_set_mouse_cursor(Ord(AValue));
end;

class procedure TApplication.SetMouseCursorVisible(const AValue: Boolean);
begin
  _sapp_show_mouse(AValue);
end;

class procedure TApplication.SetMouseLocked(const AValue: Boolean);
begin
  _sapp_lock_mouse(AValue);
end;

procedure TApplication.SetWindowTitle(const AValue: String);
begin
  FConfig.WindowTitle := AValue;
  FWindowTitle := UTF8String(AValue);
  _sapp_set_window_title(PUTF8Char(FWindowTitle));
end;

procedure TApplication.Suspended;
begin
  { No default implementation }
end;

class procedure TApplication.ToggleFullscreen;
begin
  _sapp_toggle_fullscreen;
end;

procedure TApplication.TouchesBegan(const ATouches: TTouches);
begin
  { No default implementation }
end;

procedure TApplication.TouchesCancelled(const ATouches: TTouches);
begin
  { No default implementation }
end;

procedure TApplication.TouchesEnded(const ATouches: TTouches);
begin
  { No default implementation }
end;

procedure TApplication.TouchesMoved(const ATouches: TTouches);
begin
  { No default implementation }
end;

class procedure TApplication.UnbindMouseCursorImage(
  const ACursor: TMouseCursor);
begin
  _sapp_unbind_mouse_cursor_image(Ord(ACursor));
end;

procedure TApplication.Unfocused;
begin
  { No default implementation }
end;

initialization
  {$IFDEF ANDROID}
  InitGles2Angle;
  {$ENDIF}

end.

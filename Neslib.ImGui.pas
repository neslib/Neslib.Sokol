unit Neslib.ImGui;
{ This unit is automatically generated. Do not modify. 

  For a user guide, check out the Neslib.ImGui.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.ImGui.md }

{$ALIGN 8}
{$MINENUMSIZE 4}
{$SCOPEDENUMS ON}
{$POINTERMATH ON}

interface

uses
  System.Math,
  System.Types,
  System.UITypes,
  Neslib.FastMath,
  Neslib.Sokol.Api;

type
  PPUTF8Char = ^PUTF8Char;
  TImTextureID = Pointer;
  TImDrawIdx = Word;
  PImDrawIdx = ^TImDrawIdx;
  TImGuiTableColumnIdx = Shortint;
  TImGuiTableDrawChannelIdx = Byte;
  TImGuiID = Cardinal;
  PImGuiID = ^TImGuiID;
  TImGuiDockRequest = THandle;
  TImGuiDockNodeSettings = THandle;
  TImFileHandle = THandle;
  PImGuiContext = Pointer;
  PImGuiWindow = Pointer;
  PImDrawListSharedData = Pointer;
  PImFontBuilderIO = Pointer;

type
  TImDrawFlag = (
    Closed = 0,
    RoundCornersTopLeft = 4,
    RoundCornersTopRight = 5,
    RoundCornersBottomLeft = 6,
    RoundCornersBottomRight = 7,
    RoundCornersNone = 8,
    _ = 31);
  TImDrawFlags = set of TImDrawFlag;

  _TImDrawFlagsHelper = record helper for TImDrawFlags
  public const
    None = [];
    RoundCornersTop = [TImDrawFlag.RoundCornersTopLeft, TImDrawFlag.RoundCornersTopRight];
    RoundCornersBottom = [TImDrawFlag.RoundCornersBottomLeft, TImDrawFlag.RoundCornersBottomRight];
    RoundCornersLeft = [TImDrawFlag.RoundCornersBottomLeft, TImDrawFlag.RoundCornersTopLeft];
    RoundCornersRight = [TImDrawFlag.RoundCornersBottomRight, TImDrawFlag.RoundCornersTopRight];
    RoundCornersAll = [TImDrawFlag.Closed, TImDrawFlag.RoundCornersTopLeft, TImDrawFlag.RoundCornersTopRight, TImDrawFlag.RoundCornersBottomLeft, TImDrawFlag.RoundCornersBottomRight, TImDrawFlag.RoundCornersNone];
  end;

type
  TImDrawListFlag = (
    AntiAliasedLines = 0,
    AntiAliasedLinesUseTex = 1,
    AntiAliasedFill = 2,
    AllowVtxOffset = 3,
    _ = 31);
  TImDrawListFlags = set of TImDrawListFlag;

  _TImDrawListFlagsHelper = record helper for TImDrawListFlags
  public const
    None = [];
  end;

type
  TImFontAtlasFlag = (
    NoPowerOfTwoHeight = 0,
    NoMouseCursors = 1,
    NoBakedLines = 2,
    _ = 31);
  TImFontAtlasFlags = set of TImFontAtlasFlag;

  _TImFontAtlasFlagsHelper = record helper for TImFontAtlasFlags
  public const
    None = [];
  end;

type
  TImGuiActivateFlag = (
    PreferInput = 0,
    PreferTweak = 1,
    TryToPreserveState = 2,
    _ = 31);
  TImGuiActivateFlags = set of TImGuiActivateFlag;

  _TImGuiActivateFlagsHelper = record helper for TImGuiActivateFlags
  public const
    None = [];
  end;

type
  TImGuiAxis = (
    None = -1,
    X = 0,
    Y = 1);
  PImGuiAxis = ^TImGuiAxis;

type
  TImGuiBackendFlag = (
    HasGamepad = 0,
    HasMouseCursors = 1,
    HasSetMousePos = 2,
    RendererHasVtxOffset = 3,
    PlatformHasViewports = 10,
    HasMouseHoveredViewport = 11,
    RendererHasViewports = 12,
    _ = 31);
  TImGuiBackendFlags = set of TImGuiBackendFlag;

  _TImGuiBackendFlagsHelper = record helper for TImGuiBackendFlags
  public const
    None = [];
  end;

type
  TImGuiButtonFlagPrivate = (
    PressedOnClick = 4,
    PressedOnClickRelease = 5,
    PressedOnClickReleaseAnywhere = 6,
    PressedOnRelease = 7,
    PressedOnDoubleClick = 8,
    PressedOnDragDropHold = 9,
    &Repeat = 10,
    FlattenChildren = 11,
    AllowItemOverlap = 12,
    DontClosePopups = 13,
    AlignTextBaseLine = 15,
    NoKeyModifiers = 16,
    NoHoldingActiveId = 17,
    NoNavFocus = 18,
    NoHoveredOnFocus = 19,
    _ = 31);
  TImGuiButtonFlagsPrivate = set of TImGuiButtonFlagPrivate;

type
  TImGuiButtonFlag = (
    MouseButtonLeft = 0,
    MouseButtonRight = 1,
    MouseButtonMiddle = 2,
    _ = 31);
  TImGuiButtonFlags = set of TImGuiButtonFlag;

  _TImGuiButtonFlagsHelper = record helper for TImGuiButtonFlags
  public const
    None = [];
  end;

type
  TImGuiCol = (
    Text = 0,
    TextDisabled = 1,
    WindowBg = 2,
    ChildBg = 3,
    PopupBg = 4,
    Border = 5,
    BorderShadow = 6,
    FrameBg = 7,
    FrameBgHovered = 8,
    FrameBgActive = 9,
    TitleBg = 10,
    TitleBgActive = 11,
    TitleBgCollapsed = 12,
    MenuBarBg = 13,
    ScrollbarBg = 14,
    ScrollbarGrab = 15,
    ScrollbarGrabHovered = 16,
    ScrollbarGrabActive = 17,
    CheckMark = 18,
    SliderGrab = 19,
    SliderGrabActive = 20,
    Button = 21,
    ButtonHovered = 22,
    ButtonActive = 23,
    Header = 24,
    HeaderHovered = 25,
    HeaderActive = 26,
    Separator = 27,
    SeparatorHovered = 28,
    SeparatorActive = 29,
    ResizeGrip = 30,
    ResizeGripHovered = 31,
    ResizeGripActive = 32,
    Tab = 33,
    TabHovered = 34,
    TabActive = 35,
    TabUnfocused = 36,
    TabUnfocusedActive = 37,
    DockingPreview = 38,
    DockingEmptyBg = 39,
    PlotLines = 40,
    PlotLinesHovered = 41,
    PlotHistogram = 42,
    PlotHistogramHovered = 43,
    TableHeaderBg = 44,
    TableBorderStrong = 45,
    TableBorderLight = 46,
    TableRowBg = 47,
    TableRowBgAlt = 48,
    TextSelectedBg = 49,
    DragDropTarget = 50,
    NavHighlight = 51,
    NavWindowingHighlight = 52,
    NavWindowingDimBg = 53,
    ModalWindowDimBg = 54);
  PImGuiCol = ^TImGuiCol;

type
  TImGuiColorEditFlag = (
    NoAlpha = 1,
    NoPicker = 2,
    NoOptions = 3,
    NoSmallPreview = 4,
    NoInputs = 5,
    NoTooltip = 6,
    NoLabel = 7,
    NoSidePreview = 8,
    NoDragDrop = 9,
    NoBorder = 10,
    AlphaBar = 16,
    AlphaPreview = 17,
    AlphaPreviewHalf = 18,
    HDR = 19,
    DisplayRGB = 20,
    DisplayHSV = 21,
    DisplayHex = 22,
    Uint8 = 23,
    Float = 24,
    PickerHueBar = 25,
    PickerHueWheel = 26,
    InputRGB = 27,
    InputHSV = 28);
  TImGuiColorEditFlags = set of TImGuiColorEditFlag;

  _TImGuiColorEditFlagsHelper = record helper for TImGuiColorEditFlags
  public const
    None = [];
  end;

type
  TImGuiComboFlagPrivate = (
    CustomPreview = 20,
    _ = 31);
  TImGuiComboFlagsPrivate = set of TImGuiComboFlagPrivate;

type
  TImGuiComboFlag = (
    PopupAlignLeft = 0,
    HeightSmall = 1,
    HeightRegular = 2,
    HeightLarge = 3,
    HeightLargest = 4,
    NoArrowButton = 5,
    NoPreview = 6,
    _ = 31);
  TImGuiComboFlags = set of TImGuiComboFlag;

  _TImGuiComboFlagsHelper = record helper for TImGuiComboFlags
  public const
    None = [];
  end;

type
  TImGuiCond = (
    None = 0,
    Always = 1,
    Once = 2,
    FirstUseEver = 4,
    Appearing = 8);
  PImGuiCond = ^TImGuiCond;

type
  TImGuiConfigFlag = (
    NavEnableKeyboard = 0,
    NavEnableGamepad = 1,
    NavEnableSetMousePos = 2,
    NavNoCaptureKeyboard = 3,
    NoMouse = 4,
    NoMouseCursorChange = 5,
    DockingEnable = 6,
    ViewportsEnable = 10,
    DpiEnableScaleViewports = 14,
    DpiEnableScaleFonts = 15,
    IsSRGB = 20,
    IsTouchScreen = 21,
    _ = 31);
  TImGuiConfigFlags = set of TImGuiConfigFlag;

  _TImGuiConfigFlagsHelper = record helper for TImGuiConfigFlags
  public const
    None = [];
  end;

type
  TImGuiContextHookType = (
    NewFramePre = 0,
    NewFramePost = 1,
    EndFramePre = 2,
    EndFramePost = 3,
    RenderPre = 4,
    RenderPost = 5,
    Shutdown = 6,
    PendingRemoval = 7);
  PImGuiContextHookType = ^TImGuiContextHookType;

type
  TImGuiDataAuthority = (
    Auto = 0,
    DockNode = 1,
    Window = 2);
  PImGuiDataAuthority = ^TImGuiDataAuthority;

type
  TImGuiDataTypePrivate = (
    &String = 11,
    Pointer = 12,
    ID = 13);
  PImGuiDataTypePrivate = ^TImGuiDataTypePrivate;

type
  TImGuiDataType = (
    S8 = 0,
    U8 = 1,
    S16 = 2,
    U16 = 3,
    S32 = 4,
    U32 = 5,
    S64 = 6,
    U64 = 7,
    Float = 8,
    Double = 9);
  PImGuiDataType = ^TImGuiDataType;

type
  TImGuiDebugLogFlag = (
    EventActiveId = 0,
    EventFocus = 1,
    EventPopup = 2,
    EventNav = 3,
    EventIO = 4,
    EventDocking = 5,
    EventViewport = 6,
    OutputToTTY = 10,
    _ = 31);
  TImGuiDebugLogFlags = set of TImGuiDebugLogFlag;

  _TImGuiDebugLogFlagsHelper = record helper for TImGuiDebugLogFlags
  public const
    None = [];
  end;

type
  TImGuiDir = (
    None = -1,
    Left = 0,
    Right = 1,
    Up = 2,
    Down = 3);
  PImGuiDir = ^TImGuiDir;

type
  TImGuiDockNodeFlagPrivate = (
    DockSpace = 10,
    CentralNode = 11,
    NoTabBar = 12,
    HiddenTabBar = 13,
    NoWindowMenuButton = 14,
    NoCloseButton = 15,
    NoDocking = 16,
    NoDockingSplitMe = 17,
    NoDockingSplitOther = 18,
    NoDockingOverMe = 19,
    NoDockingOverOther = 20,
    NoDockingOverEmpty = 21,
    NoResizeX = 22,
    NoResizeY = 23,
    _ = 31);
  TImGuiDockNodeFlagsPrivate = set of TImGuiDockNodeFlagPrivate;

type
  TImGuiDockNodeFlag = (
    KeepAliveOnly = 0,
    NoDockingInCentralNode = 2,
    PassthruCentralNode = 3,
    NoSplit = 4,
    NoResize = 5,
    AutoHideTabBar = 6,
    _ = 31);
  TImGuiDockNodeFlags = set of TImGuiDockNodeFlag;

  _TImGuiDockNodeFlagsHelper = record helper for TImGuiDockNodeFlags
  public const
    None = [];
  end;

type
  TImGuiDockNodeState = (
    Unknown = 0,
    HostWindowHiddenBecauseSingleWindow = 1,
    HostWindowHiddenBecauseWindowsAreResizing = 2,
    HostWindowVisible = 3);
  PImGuiDockNodeState = ^TImGuiDockNodeState;

type
  TImGuiDragDropFlag = (
    SourceNoPreviewTooltip = 0,
    SourceNoDisableHover = 1,
    SourceNoHoldToOpenOthers = 2,
    SourceAllowNullID = 3,
    SourceExtern = 4,
    SourceAutoExpirePayload = 5,
    AcceptBeforeDelivery = 10,
    AcceptNoDrawDefaultRect = 11,
    AcceptNoPreviewTooltip = 12,
    _ = 31);
  TImGuiDragDropFlags = set of TImGuiDragDropFlag;

  _TImGuiDragDropFlagsHelper = record helper for TImGuiDragDropFlags
  public const
    None = [];
    AcceptPeekOnly = [TImGuiDragDropFlag.AcceptBeforeDelivery, TImGuiDragDropFlag.AcceptNoDrawDefaultRect];
  end;

type
  TImGuiFocusedFlag = (
    ChildWindows = 0,
    RootWindow = 1,
    AnyWindow = 2,
    NoPopupHierarchy = 3,
    DockHierarchy = 4,
    _ = 31);
  TImGuiFocusedFlags = set of TImGuiFocusedFlag;

  _TImGuiFocusedFlagsHelper = record helper for TImGuiFocusedFlags
  public const
    None = [];
    RootAndChildWindows = [TImGuiFocusedFlag.RootWindow, TImGuiFocusedFlag.ChildWindows];
  end;

type
  TImGuiHoveredFlag = (
    ChildWindows = 0,
    RootWindow = 1,
    AnyWindow = 2,
    NoPopupHierarchy = 3,
    DockHierarchy = 4,
    AllowWhenBlockedByPopup = 5,
    AllowWhenBlockedByActiveItem = 7,
    AllowWhenOverlapped = 8,
    AllowWhenDisabled = 9,
    NoNavOverride = 10,
    _ = 31);
  TImGuiHoveredFlags = set of TImGuiHoveredFlag;

  _TImGuiHoveredFlagsHelper = record helper for TImGuiHoveredFlags
  public const
    None = [];
    RectOnly = [TImGuiHoveredFlag.AllowWhenBlockedByPopup, TImGuiHoveredFlag.AllowWhenBlockedByActiveItem, TImGuiHoveredFlag.AllowWhenOverlapped];
    RootAndChildWindows = [TImGuiHoveredFlag.RootWindow, TImGuiHoveredFlag.ChildWindows];
  end;

type
  TImGuiInputEventType = (
    None = 0,
    MousePos = 1,
    MouseWheel = 2,
    MouseButton = 3,
    MouseViewport = 4,
    Key = 5,
    Text = 6,
    Focus = 7);
  PImGuiInputEventType = ^TImGuiInputEventType;

type
  TImGuiInputSource = (
    None = 0,
    Mouse = 1,
    Keyboard = 2,
    Gamepad = 3,
    Clipboard = 4,
    Nav = 5);
  PImGuiInputSource = ^TImGuiInputSource;

type
  TImGuiInputTextFlagPrivate = (
    Multiline = 26,
    NoMarkEdited = 27,
    MergedItem = 28);
  TImGuiInputTextFlagsPrivate = set of TImGuiInputTextFlagPrivate;

type
  TImGuiInputTextFlag = (
    CharsDecimal = 0,
    CharsHexadecimal = 1,
    CharsUppercase = 2,
    CharsNoBlank = 3,
    AutoSelectAll = 4,
    EnterReturnsTrue = 5,
    AllowTabInput = 10,
    CtrlEnterForNewLine = 11,
    NoHorizontalScroll = 12,
    AlwaysOverwrite = 13,
    ReadOnly = 14,
    Password = 15,
    NoUndoRedo = 16,
    CharsScientific = 17,
    _ = 31);
  TImGuiInputTextFlags = set of TImGuiInputTextFlag;

  _TImGuiInputTextFlagsHelper = record helper for TImGuiInputTextFlags
  public const
    None = [];
  end;

type
  TImGuiItemFlag = (
    NoTabStop = 0,
    ButtonRepeat = 1,
    Disabled = 2,
    NoNav = 3,
    NoNavDefaultFocus = 4,
    SelectableDontClosePopup = 5,
    MixedValue = 6,
    ReadOnly = 7,
    Inputable = 8,
    _ = 31);
  TImGuiItemFlags = set of TImGuiItemFlag;

  _TImGuiItemFlagsHelper = record helper for TImGuiItemFlags
  public const
    None = [];
  end;

type
  TImGuiItemStatusFlag = (
    HoveredRect = 0,
    HasDisplayRect = 1,
    Edited = 2,
    ToggledSelection = 3,
    ToggledOpen = 4,
    HasDeactivated = 5,
    Deactivated = 6,
    HoveredWindow = 7,
    FocusedByTabbing = 8,
    _ = 31);
  TImGuiItemStatusFlags = set of TImGuiItemStatusFlag;

  _TImGuiItemStatusFlagsHelper = record helper for TImGuiItemStatusFlags
  public const
    None = [];
  end;

type
  TImGuiKeyPrivate = (
    LegacyNativeKeyBEGIN = 0,
    LegacyNativeKeyEND = 512,
    GamepadBEGIN = 617,
    GamepadEND = 641);
  PImGuiKeyPrivate = ^TImGuiKeyPrivate;

type
  TImGuiKey = (
    None = 0,
    Tab = 512,
    LeftArrow = 513,
    RightArrow = 514,
    UpArrow = 515,
    DownArrow = 516,
    PageUp = 517,
    PageDown = 518,
    Home = 519,
    &End = 520,
    Insert = 521,
    Delete = 522,
    Backspace = 523,
    Space = 524,
    Enter = 525,
    Escape = 526,
    LeftCtrl = 527,
    LeftShift = 528,
    LeftAlt = 529,
    LeftSuper = 530,
    RightCtrl = 531,
    RightShift = 532,
    RightAlt = 533,
    RightSuper = 534,
    Menu = 535,
    _0 = 536,
    _1 = 537,
    _2 = 538,
    _3 = 539,
    _4 = 540,
    _5 = 541,
    _6 = 542,
    _7 = 543,
    _8 = 544,
    _9 = 545,
    A = 546,
    B = 547,
    C = 548,
    D = 549,
    E = 550,
    F = 551,
    G = 552,
    H = 553,
    I = 554,
    J = 555,
    K = 556,
    L = 557,
    M = 558,
    N = 559,
    O = 560,
    P = 561,
    Q = 562,
    R = 563,
    S = 564,
    T = 565,
    U = 566,
    V = 567,
    W = 568,
    X = 569,
    Y = 570,
    Z = 571,
    F1 = 572,
    F2 = 573,
    F3 = 574,
    F4 = 575,
    F5 = 576,
    F6 = 577,
    F7 = 578,
    F8 = 579,
    F9 = 580,
    F10 = 581,
    F11 = 582,
    F12 = 583,
    Apostrophe = 584,
    Comma = 585,
    Minus = 586,
    Period = 587,
    Slash = 588,
    Semicolon = 589,
    Equal = 590,
    LeftBracket = 591,
    Backslash = 592,
    RightBracket = 593,
    GraveAccent = 594,
    CapsLock = 595,
    ScrollLock = 596,
    NumLock = 597,
    PrintScreen = 598,
    Pause = 599,
    Keypad0 = 600,
    Keypad1 = 601,
    Keypad2 = 602,
    Keypad3 = 603,
    Keypad4 = 604,
    Keypad5 = 605,
    Keypad6 = 606,
    Keypad7 = 607,
    Keypad8 = 608,
    Keypad9 = 609,
    KeypadDecimal = 610,
    KeypadDivide = 611,
    KeypadMultiply = 612,
    KeypadSubtract = 613,
    KeypadAdd = 614,
    KeypadEnter = 615,
    KeypadEqual = 616,
    GamepadStart = 617,
    GamepadBack = 618,
    GamepadFaceUp = 619,
    GamepadFaceDown = 620,
    GamepadFaceLeft = 621,
    GamepadFaceRight = 622,
    GamepadDpadUp = 623,
    GamepadDpadDown = 624,
    GamepadDpadLeft = 625,
    GamepadDpadRight = 626,
    GamepadL1 = 627,
    GamepadR1 = 628,
    GamepadL2 = 629,
    GamepadR2 = 630,
    GamepadL3 = 631,
    GamepadR3 = 632,
    GamepadLStickUp = 633,
    GamepadLStickDown = 634,
    GamepadLStickLeft = 635,
    GamepadLStickRight = 636,
    GamepadRStickUp = 637,
    GamepadRStickDown = 638,
    GamepadRStickLeft = 639,
    GamepadRStickRight = 640,
    ModCtrl = 641,
    ModShift = 642,
    ModAlt = 643,
    ModSuper = 644,
    NamedKeyBEGIN = 512,
    NamedKeyEND = 645,
    NamedKeyCOUNT = 133,
    KeysDataSIZE = 645,
    KeysDataOFFSET = 0);
  PImGuiKey = ^TImGuiKey;

type
  TImGuiLayoutType = (
    Horizontal = 0,
    Vertical = 1);
  PImGuiLayoutType = ^TImGuiLayoutType;

type
  TImGuiLogType = (
    None = 0,
    TTY = 1,
    &File = 2,
    Buffer = 3,
    Clipboard = 4);
  PImGuiLogType = ^TImGuiLogType;

type
  TImGuiModFlag = (
    Ctrl = 0,
    Shift = 1,
    Alt = 2,
    Super = 3,
    _ = 31);
  TImGuiModFlags = set of TImGuiModFlag;

  _TImGuiModFlagsHelper = record helper for TImGuiModFlags
  public const
    None = [];
  end;

type
  TImGuiMouseButton = (
    Left = 0,
    Right = 1,
    Middle = 2);
  PImGuiMouseButton = ^TImGuiMouseButton;

type
  TImGuiMouseCursor = (
    None = -1,
    Arrow = 0,
    TextInput = 1,
    ResizeAll = 2,
    ResizeNS = 3,
    ResizeEW = 4,
    ResizeNESW = 5,
    ResizeNWSE = 6,
    Hand = 7,
    NotAllowed = 8);
  PImGuiMouseCursor = ^TImGuiMouseCursor;

type
  TImGuiNavDirSourceFlag = (
    RawKeyboard = 0,
    Keyboard = 1,
    PadDPad = 2,
    PadLStick = 3,
    _ = 31);
  TImGuiNavDirSourceFlags = set of TImGuiNavDirSourceFlag;

  _TImGuiNavDirSourceFlagsHelper = record helper for TImGuiNavDirSourceFlags
  public const
    None = [];
  end;

type
  TImGuiNavHighlightFlag = (
    TypeDefault = 0,
    TypeThin = 1,
    AlwaysDraw = 2,
    NoRounding = 3,
    _ = 31);
  TImGuiNavHighlightFlags = set of TImGuiNavHighlightFlag;

  _TImGuiNavHighlightFlagsHelper = record helper for TImGuiNavHighlightFlags
  public const
    None = [];
  end;

type
  TImGuiNavInput = (
    Activate = 0,
    Cancel = 1,
    Input = 2,
    Menu = 3,
    DpadLeft = 4,
    DpadRight = 5,
    DpadUp = 6,
    DpadDown = 7,
    LStickLeft = 8,
    LStickRight = 9,
    LStickUp = 10,
    LStickDown = 11,
    FocusPrev = 12,
    FocusNext = 13,
    TweakSlow = 14,
    TweakFast = 15,
    KeyLeft = 16,
    KeyRight = 17,
    KeyUp = 18,
    KeyDown = 19);
  PImGuiNavInput = ^TImGuiNavInput;

type
  TImGuiNavLayer = (
    Main = 0,
    Menu = 1);
  PImGuiNavLayer = ^TImGuiNavLayer;

type
  TImGuiNavMoveFlag = (
    LoopX = 0,
    LoopY = 1,
    WrapX = 2,
    WrapY = 3,
    AllowCurrentNavId = 4,
    AlsoScoreVisibleSet = 5,
    ScrollToEdgeY = 6,
    Forwarded = 7,
    DebugNoResult = 8,
    FocusApi = 9,
    Tabbing = 10,
    Activate = 11,
    DontSetNavHighlight = 12,
    _ = 31);
  TImGuiNavMoveFlags = set of TImGuiNavMoveFlag;

  _TImGuiNavMoveFlagsHelper = record helper for TImGuiNavMoveFlags
  public const
    None = [];
  end;

type
  TImGuiNavReadMode = (
    Down = 0,
    Pressed = 1,
    Released = 2,
    &Repeat = 3,
    RepeatSlow = 4,
    RepeatFast = 5);
  PImGuiNavReadMode = ^TImGuiNavReadMode;

type
  TImGuiNextItemDataFlag = (
    HasWidth = 0,
    HasOpen = 1,
    _ = 31);
  TImGuiNextItemDataFlags = set of TImGuiNextItemDataFlag;

  _TImGuiNextItemDataFlagsHelper = record helper for TImGuiNextItemDataFlags
  public const
    None = [];
  end;

type
  TImGuiNextWindowDataFlag = (
    HasPos = 0,
    HasSize = 1,
    HasContentSize = 2,
    HasCollapsed = 3,
    HasSizeConstraint = 4,
    HasFocus = 5,
    HasBgAlpha = 6,
    HasScroll = 7,
    HasViewport = 8,
    HasDock = 9,
    HasWindowClass = 10,
    _ = 31);
  TImGuiNextWindowDataFlags = set of TImGuiNextWindowDataFlag;

  _TImGuiNextWindowDataFlagsHelper = record helper for TImGuiNextWindowDataFlags
  public const
    None = [];
  end;

type
  TImGuiOldColumnFlag = (
    NoBorder = 0,
    NoResize = 1,
    NoPreserveWidths = 2,
    NoForceWithinWindow = 3,
    GrowParentContentsSize = 4,
    _ = 31);
  TImGuiOldColumnFlags = set of TImGuiOldColumnFlag;

  _TImGuiOldColumnFlagsHelper = record helper for TImGuiOldColumnFlags
  public const
    None = [];
  end;

type
  TImGuiPlotType = (
    Lines = 0,
    Histogram = 1);
  PImGuiPlotType = ^TImGuiPlotType;

type
  TImGuiPopupFlag = (
    MouseButtonRight = 0,
    MouseButtonMiddle = 1,
    NoOpenOverExistingPopup = 5,
    NoOpenOverItems = 6,
    AnyPopupId = 7,
    AnyPopupLevel = 8,
    _ = 31);
  TImGuiPopupFlags = set of TImGuiPopupFlag;

  _TImGuiPopupFlagsHelper = record helper for TImGuiPopupFlags
  public const
    None = [];
    MouseButtonLeft = [];
    AnyPopup = [TImGuiPopupFlag.AnyPopupId, TImGuiPopupFlag.AnyPopupLevel];
  end;

type
  TImGuiPopupPositionPolicy = (
    Default = 0,
    ComboBox = 1,
    Tooltip = 2);
  PImGuiPopupPositionPolicy = ^TImGuiPopupPositionPolicy;

type
  TImGuiScrollFlag = (
    KeepVisibleEdgeX = 0,
    KeepVisibleEdgeY = 1,
    KeepVisibleCenterX = 2,
    KeepVisibleCenterY = 3,
    AlwaysCenterX = 4,
    AlwaysCenterY = 5,
    NoScrollParent = 6,
    _ = 31);
  TImGuiScrollFlags = set of TImGuiScrollFlag;

  _TImGuiScrollFlagsHelper = record helper for TImGuiScrollFlags
  public const
    None = [];
  end;

type
  TImGuiSelectableFlagPrivate = (
    NoHoldingActiveID = 20,
    SelectOnNav = 21,
    SelectOnClick = 22,
    SelectOnRelease = 23,
    SpanAvailWidth = 24,
    DrawHoveredWhenHeld = 25,
    SetNavIdOnHover = 26,
    NoPadWithHalfSpacing = 27);
  TImGuiSelectableFlagsPrivate = set of TImGuiSelectableFlagPrivate;

type
  TImGuiSelectableFlag = (
    DontClosePopups = 0,
    SpanAllColumns = 1,
    AllowDoubleClick = 2,
    Disabled = 3,
    AllowItemOverlap = 4,
    _ = 31);
  TImGuiSelectableFlags = set of TImGuiSelectableFlag;

  _TImGuiSelectableFlagsHelper = record helper for TImGuiSelectableFlags
  public const
    None = [];
  end;

type
  TImGuiSeparatorFlag = (
    Horizontal = 0,
    Vertical = 1,
    SpanAllColumns = 2,
    _ = 31);
  TImGuiSeparatorFlags = set of TImGuiSeparatorFlag;

  _TImGuiSeparatorFlagsHelper = record helper for TImGuiSeparatorFlags
  public const
    None = [];
  end;

type
  TImGuiSliderFlagPrivate = (
    Vertical = 20,
    ReadOnly = 21,
    _ = 31);
  TImGuiSliderFlagsPrivate = set of TImGuiSliderFlagPrivate;

type
  TImGuiSliderFlag = (
    AlwaysClamp = 4,
    Logarithmic = 5,
    NoRoundToFormat = 6,
    NoInput = 7,
    _ = 31);
  TImGuiSliderFlags = set of TImGuiSliderFlag;

  _TImGuiSliderFlagsHelper = record helper for TImGuiSliderFlags
  public const
    None = [];
  end;

type
  TImGuiSortDirection = (
    None = 0,
    Ascending = 1,
    Descending = 2);
  PImGuiSortDirection = ^TImGuiSortDirection;

type
  TImGuiStyleVar = (
    Alpha = 0,
    DisabledAlpha = 1,
    WindowPadding = 2,
    WindowRounding = 3,
    WindowBorderSize = 4,
    WindowMinSize = 5,
    WindowTitleAlign = 6,
    ChildRounding = 7,
    ChildBorderSize = 8,
    PopupRounding = 9,
    PopupBorderSize = 10,
    FramePadding = 11,
    FrameRounding = 12,
    FrameBorderSize = 13,
    ItemSpacing = 14,
    ItemInnerSpacing = 15,
    IndentSpacing = 16,
    CellPadding = 17,
    ScrollbarSize = 18,
    ScrollbarRounding = 19,
    GrabMinSize = 20,
    GrabRounding = 21,
    TabRounding = 22,
    ButtonTextAlign = 23,
    SelectableTextAlign = 24);
  PImGuiStyleVar = ^TImGuiStyleVar;

type
  TImGuiTabBarFlagPrivate = (
    DockNode = 20,
    IsFocused = 21,
    SaveSettings = 22,
    _ = 31);
  TImGuiTabBarFlagsPrivate = set of TImGuiTabBarFlagPrivate;

type
  TImGuiTabBarFlag = (
    Reorderable = 0,
    AutoSelectNewTabs = 1,
    TabListPopupButton = 2,
    NoCloseWithMiddleMouseButton = 3,
    NoTabListScrollingButtons = 4,
    NoTooltip = 5,
    FittingPolicyResizeDown = 6,
    FittingPolicyScroll = 7,
    _ = 31);
  TImGuiTabBarFlags = set of TImGuiTabBarFlag;

  _TImGuiTabBarFlagsHelper = record helper for TImGuiTabBarFlags
  public const
    None = [];
  end;

type
  TImGuiTabItemFlagPrivate = (
    NoCloseButton = 20,
    Button = 21,
    Unsorted = 22,
    Preview = 23,
    _ = 31);
  TImGuiTabItemFlagsPrivate = set of TImGuiTabItemFlagPrivate;

type
  TImGuiTabItemFlag = (
    UnsavedDocument = 0,
    SetSelected = 1,
    NoCloseWithMiddleMouseButton = 2,
    NoPushId = 3,
    NoTooltip = 4,
    NoReorder = 5,
    Leading = 6,
    Trailing = 7,
    _ = 31);
  TImGuiTabItemFlags = set of TImGuiTabItemFlag;

  _TImGuiTabItemFlagsHelper = record helper for TImGuiTabItemFlags
  public const
    None = [];
  end;

type
  TImGuiTableBgTarget = (
    None = 0,
    RowBg0 = 1,
    RowBg1 = 2,
    CellBg = 3);
  PImGuiTableBgTarget = ^TImGuiTableBgTarget;

type
  TImGuiTableColumnFlag = (
    Disabled = 0,
    DefaultHide = 1,
    DefaultSort = 2,
    WidthStretch = 3,
    WidthFixed = 4,
    NoResize = 5,
    NoReorder = 6,
    NoHide = 7,
    NoClip = 8,
    NoSort = 9,
    NoSortAscending = 10,
    NoSortDescending = 11,
    NoHeaderLabel = 12,
    NoHeaderWidth = 13,
    PreferSortAscending = 14,
    PreferSortDescending = 15,
    IndentEnable = 16,
    IndentDisable = 17,
    IsEnabled = 24,
    IsVisible = 25,
    IsSorted = 26,
    IsHovered = 27);
  TImGuiTableColumnFlags = set of TImGuiTableColumnFlag;

  _TImGuiTableColumnFlagsHelper = record helper for TImGuiTableColumnFlags
  public const
    None = [];
  end;

type
  TImGuiTableFlag = (
    Resizable = 0,
    Reorderable = 1,
    Hideable = 2,
    Sortable = 3,
    NoSavedSettings = 4,
    ContextMenuInBody = 5,
    RowBg = 6,
    BordersInnerH = 7,
    BordersOuterH = 8,
    BordersInnerV = 9,
    BordersOuterV = 10,
    NoBordersInBody = 11,
    NoBordersInBodyUntilResize = 12,
    SizingFixedFit = 13,
    SizingFixedSame = 14,
    SizingStretchSame = 15,
    NoHostExtendX = 16,
    NoHostExtendY = 17,
    NoKeepColumnsVisible = 18,
    PreciseWidths = 19,
    NoClip = 20,
    PadOuterX = 21,
    NoPadOuterX = 22,
    NoPadInnerX = 23,
    ScrollX = 24,
    ScrollY = 25,
    SortMulti = 26,
    SortTristate = 27);
  TImGuiTableFlags = set of TImGuiTableFlag;

  _TImGuiTableFlagsHelper = record helper for TImGuiTableFlags
  public const
    None = [];
    BordersH = [TImGuiTableFlag.BordersInnerH, TImGuiTableFlag.BordersOuterH];
    BordersV = [TImGuiTableFlag.BordersInnerV, TImGuiTableFlag.BordersOuterV];
    BordersInner = [TImGuiTableFlag.BordersInnerV, TImGuiTableFlag.BordersInnerH];
    BordersOuter = [TImGuiTableFlag.BordersOuterV, TImGuiTableFlag.BordersOuterH];
    Borders = BordersInner + BordersOuter;
    SizingStretchProp = [TImGuiTableFlag.SizingFixedFit, TImGuiTableFlag.SizingFixedSame];
  end;

type
  TImGuiTableRowFlag = (
    Headers = 0,
    _ = 31);
  TImGuiTableRowFlags = set of TImGuiTableRowFlag;

  _TImGuiTableRowFlagsHelper = record helper for TImGuiTableRowFlags
  public const
    None = [];
  end;

type
  TImGuiTextFlag = (
    NoWidthForLargeClippedText = 0,
    _ = 31);
  TImGuiTextFlags = set of TImGuiTextFlag;

  _TImGuiTextFlagsHelper = record helper for TImGuiTextFlags
  public const
    None = [];
  end;

type
  TImGuiTooltipFlag = (
    OverridePreviousTooltip = 0,
    _ = 31);
  TImGuiTooltipFlags = set of TImGuiTooltipFlag;

  _TImGuiTooltipFlagsHelper = record helper for TImGuiTooltipFlags
  public const
    None = [];
  end;

type
  TImGuiTreeNodeFlagPrivate = (
    ClipLabelForTrailingButton = 20,
    _ = 31);
  TImGuiTreeNodeFlagsPrivate = set of TImGuiTreeNodeFlagPrivate;

type
  TImGuiTreeNodeFlag = (
    Selected = 0,
    Framed = 1,
    AllowItemOverlap = 2,
    NoTreePushOnOpen = 3,
    NoAutoOpenOnLog = 4,
    DefaultOpen = 5,
    OpenOnDoubleClick = 6,
    OpenOnArrow = 7,
    Leaf = 8,
    Bullet = 9,
    FramePadding = 10,
    SpanAvailWidth = 11,
    SpanFullWidth = 12,
    NavLeftJumpsBackHere = 13,
    _ = 31);
  TImGuiTreeNodeFlags = set of TImGuiTreeNodeFlag;

  _TImGuiTreeNodeFlagsHelper = record helper for TImGuiTreeNodeFlags
  public const
    None = [];
    CollapsingHeader = [TImGuiTreeNodeFlag.Framed, TImGuiTreeNodeFlag.NoTreePushOnOpen, TImGuiTreeNodeFlag.NoAutoOpenOnLog];
  end;

type
  TImGuiViewportFlag = (
    IsPlatformWindow = 0,
    IsPlatformMonitor = 1,
    OwnedByApp = 2,
    NoDecoration = 3,
    NoTaskBarIcon = 4,
    NoFocusOnAppearing = 5,
    NoFocusOnClick = 6,
    NoInputs = 7,
    NoRendererClear = 8,
    TopMost = 9,
    Minimized = 10,
    NoAutoMerge = 11,
    CanHostOtherWindows = 12,
    _ = 31);
  TImGuiViewportFlags = set of TImGuiViewportFlag;

  _TImGuiViewportFlagsHelper = record helper for TImGuiViewportFlags
  public const
    None = [];
  end;

type
  TImGuiWindowDockStyleCol = (
    Text = 0,
    Tab = 1,
    TabHovered = 2,
    TabActive = 3,
    TabUnfocused = 4,
    TabUnfocusedActive = 5);
  PImGuiWindowDockStyleCol = ^TImGuiWindowDockStyleCol;

type
  TImGuiWindowFlag = (
    NoTitleBar = 0,
    NoResize = 1,
    NoMove = 2,
    NoScrollbar = 3,
    NoScrollWithMouse = 4,
    NoCollapse = 5,
    AlwaysAutoResize = 6,
    NoBackground = 7,
    NoSavedSettings = 8,
    NoMouseInputs = 9,
    MenuBar = 10,
    HorizontalScrollbar = 11,
    NoFocusOnAppearing = 12,
    NoBringToFrontOnFocus = 13,
    AlwaysVerticalScrollbar = 14,
    AlwaysHorizontalScrollbar = 15,
    AlwaysUseWindowPadding = 16,
    NoNavInputs = 18,
    NoNavFocus = 19,
    UnsavedDocument = 20,
    NoDocking = 21,
    NavFlattened = 23,
    ChildWindow = 24,
    Tooltip = 25,
    Popup = 26,
    Modal = 27,
    ChildMenu = 28,
    DockNodeHost = 29);
  TImGuiWindowFlags = set of TImGuiWindowFlag;

  _TImGuiWindowFlagsHelper = record helper for TImGuiWindowFlags
  public const
    None = [];
    NoNav = [TImGuiWindowFlag.NoNavInputs, TImGuiWindowFlag.NoNavFocus];
    NoDecoration = [TImGuiWindowFlag.NoTitleBar, TImGuiWindowFlag.NoResize, TImGuiWindowFlag.NoScrollbar, TImGuiWindowFlag.NoCollapse];
    NoInputs = [TImGuiWindowFlag.NoMouseInputs, TImGuiWindowFlag.NoNavInputs, TImGuiWindowFlag.NoNavFocus];
  end;

type
  TImVector = record
  public
    Size: Integer;
    Capacity: Integer;
    Data: Pointer;
  end;

type
  TImVector<T> = record
  {$REGION 'Internal Declarations'}
  private type
    P = ^T;
  private
    FSize: Integer;
    FCapacity: Integer;
    FData: Pointer;
    function GetItem(const AIndex: Integer): T; inline;
    function GetItemPtr(const AIndex: Integer): Pointer; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Count: Integer read FSize;
    property Capacity: Integer read FCapacity;
    property Items[const AIndex: Integer]: T read GetItem; default;
    property ItemPtrs[const AIndex: Integer]: Pointer read GetItemPtr;
    property Data: Pointer read FData;
  end;

type
  TImPoolIdx = Integer;

type
  TImPool<T> = record
  public
    Buf: TImVector<T>;
    Map: TImVector; // TImGuiStorage
    FreeIdx: TImPoolIdx;
    AliveCount: TImPoolIdx;
  end;

type
  TImSpan<T> = record
  public
    Data: Pointer;
    DataEnd: Pointer;
  end;

type
  TImChunkStream<T> = record
  public
    Buf: TImVector<T>;
  end;

type
  TImBitArrayForNamedKeys = record
  public const
    BITCOUNT = Ord(TImGuiKey.NamedKeyCOUNT);
  public
    Storage: array [0..((BITCOUNT + 31) shr 5) - 1] of UInt32;
  end;

type  
  TImChunkStream_ImGuiWindowSettings = record
  public  
    Buf: TImVector<Byte>;
  end;

type  
  TImChunkStream_ImGuiTableSettings = record
  public  
    Buf: TImVector<Byte>;
  end;
  
type
  TImGuiText = record
  {$REGION 'Internal Declarations'}
  private const
    WORK_AREA = 10;
  private
    FBuffer: TArray<UTF8Char>;
  private
    procedure Validate;
    procedure Update(const AData: _PImGuiInputTextCallbackData);
  {$ENDREGION 'Internal Declarations'}
  public
    procedure Init(const AText: String);
    function ToString: String; inline;
    function ToUTF8String: UTF8String; inline;
    function ToPUTF8Char: PUTF8Char; inline;

    class operator Implicit(const AText: String): TImGuiText; inline; static;
    class operator Implicit(const AText: TImGuiText): String; inline; static;
  end;
  PImGuiText = ^TImGuiText;
  
type
  // Forward declarations
  PImDrawCmd = ^TImDrawCmd;
  PPImDrawCmd = ^PImDrawCmd;
  PImDrawChannel = ^TImDrawChannel;
  PPImDrawChannel = ^PImDrawChannel;
  PImDrawCmdHeader = ^TImDrawCmdHeader;
  PPImDrawCmdHeader = ^PImDrawCmdHeader;
  PImDrawData = ^TImDrawData;
  PPImDrawData = ^PImDrawData;
  PImDrawListSplitter = ^TImDrawListSplitter;
  PPImDrawListSplitter = ^PImDrawListSplitter;
  PImDrawVert = ^TImDrawVert;
  PPImDrawVert = ^PImDrawVert;
  PImDrawList = ^TImDrawList;
  PPImDrawList = ^PImDrawList;
  PImFontGlyph = ^TImFontGlyph;
  PPImFontGlyph = ^PImFontGlyph;
  PImFont = ^TImFont;
  PPImFont = ^PImFont;
  PImFontConfig = ^TImFontConfig;
  PPImFontConfig = ^PImFontConfig;
  PImFontAtlasCustomRect = ^TImFontAtlasCustomRect;
  PPImFontAtlasCustomRect = ^PImFontAtlasCustomRect;
  PImFontAtlas = ^TImFontAtlas;
  PPImFontAtlas = ^PImFontAtlas;
  PImFontGlyphRangesBuilder = ^TImFontGlyphRangesBuilder;
  PPImFontGlyphRangesBuilder = ^PImFontGlyphRangesBuilder;
  PImGuiTextBuffer = ^TImGuiTextBuffer;
  PPImGuiTextBuffer = ^PImGuiTextBuffer;
  PImGuiStoragePair = ^TImGuiStoragePair;
  PPImGuiStoragePair = ^PImGuiStoragePair;
  PImGuiStorage = ^TImGuiStorage;
  PPImGuiStorage = ^PImGuiStorage;
  PImGuiPlatformImeData = ^TImGuiPlatformImeData;
  PPImGuiPlatformImeData = ^PImGuiPlatformImeData;
  PImGuiTableSortSpecs = ^TImGuiTableSortSpecs;
  PPImGuiTableSortSpecs = ^PImGuiTableSortSpecs;
  PImGuiTableColumnSortSpecs = ^TImGuiTableColumnSortSpecs;
  PPImGuiTableColumnSortSpecs = ^PImGuiTableColumnSortSpecs;
  PImGuiPayload = ^TImGuiPayload;
  PPImGuiPayload = ^PImGuiPayload;
  PImGuiPlatformMonitor = ^TImGuiPlatformMonitor;
  PPImGuiPlatformMonitor = ^PImGuiPlatformMonitor;
  PImGuiWindowClass = ^TImGuiWindowClass;
  PPImGuiWindowClass = ^PImGuiWindowClass;
  PImGuiStyle = ^TImGuiStyle;
  PPImGuiStyle = ^PImGuiStyle;
  PImGuiPlatformIO = ^TImGuiPlatformIO;
  PPImGuiPlatformIO = ^PImGuiPlatformIO;
  PImGuiKeyData = ^TImGuiKeyData;
  PPImGuiKeyData = ^PImGuiKeyData;
  PImGuiIO = ^TImGuiIO;
  PPImGuiIO = ^PImGuiIO;
  PImGuiInputTextCallbackData = ^TImGuiInputTextCallbackData;
  PPImGuiInputTextCallbackData = ^PImGuiInputTextCallbackData;
  PImGuiListClipper = ^TImGuiListClipper;
  PPImGuiListClipper = ^PImGuiListClipper;
  PImGuiOnceUponAFrame = ^TImGuiOnceUponAFrame;
  PPImGuiOnceUponAFrame = ^PImGuiOnceUponAFrame;
  PImGuiSizeCallbackData = ^TImGuiSizeCallbackData;
  PPImGuiSizeCallbackData = ^PImGuiSizeCallbackData;
  PImGuiTextRange = ^TImGuiTextRange;
  PPImGuiTextRange = ^PImGuiTextRange;
  PImGuiTextFilter = ^TImGuiTextFilter;
  PPImGuiTextFilter = ^PImGuiTextFilter;
  PImGuiViewport = ^TImGuiViewport;
  PPImGuiViewport = ^PImGuiViewport;

  TImDrawCallback = procedure(const AParentList: PImDrawList; const ACmd: PImDrawCmd); cdecl;
  TImGuiErrorLogCallback = procedure(const AUserData: Pointer; const AError: PUTF8Char) varargs; cdecl;
  TImGuiMemAllocFunc = function(const ASize: NativeUInt; const AUserData: Pointer): Pointer; cdecl;
  PImGuiMemAllocFunc = ^TImGuiMemAllocFunc;
  TImGuiMemFreeFunc = procedure(const APtr, AUserData: Pointer); cdecl;
  PImGuiMemFreeFunc = ^TImGuiMemFreeFunc;
  TImGuiInputTextCallback = function(const AData: PImGuiInputTextCallbackData): Integer; cdecl;
  TImGuiSizeCallback = procedure(const AData: PImGuiSizeCallbackData); cdecl;

  TImDrawCmd = record
  public
    ClipRect: TRectF;
    TextureId: TImTextureID;
    VtxOffset: Cardinal;
    IdxOffset: Cardinal;
    ElemCount: Cardinal;
    UserCallback: TImDrawCallback;
    UserCallbackData: Pointer;
  public
    class function Create: PImDrawCmd; static; inline;
    procedure Free; inline;
    function GetTexID: TImTextureID; inline;
  end;

  TImDrawChannel = record
  public
    CmdBuffer: TImVector<TImDrawCmd>;
    IdxBuffer: TImVector<TImDrawIdx>;
  end;

  TImDrawCmdHeader = record
  public
    ClipRect: TRectF;
    TextureId: TImTextureID;
    VtxOffset: Cardinal;
  end;

  TImDrawData = record
  public
    Valid: Boolean;
    CmdListsCount: Integer;
    TotalIdxCount: Integer;
    TotalVtxCount: Integer;
    CmdLists: PPImDrawList;
    DisplayPos: TVector2;
    DisplaySize: TVector2;
    FramebufferScale: TVector2;
    OwnerViewport: PImGuiViewport;
  public
    class function Create: PImDrawData; static; inline;
    procedure Free; inline;
    procedure Clear; inline;
    procedure DeIndexAllBuffers; inline;
    procedure ScaleClipRects(const AFbScale: TVector2); inline;
  end;

  TImDrawListSplitter = record
  public
    Current: Integer;
    Count: Integer;
    Channels: TImVector<TImDrawChannel>;
  public
    class function Create: PImDrawListSplitter; static; inline;
    procedure Free; inline;
    procedure Clear; inline;
    procedure ClearFreeMemory; inline;
    procedure Merge(const ADrawList: PImDrawList); inline;
    procedure SetCurrentChannel(const ADrawList: PImDrawList; const AChannelIdx: Integer); inline;
    procedure Split(const ADrawList: PImDrawList; const ACount: Integer); inline;
  end;

  TImDrawVert = record
  public
    Pos: TVector2;
    Uv: TVector2;
    Col: UInt32;
  end;

  TImDrawList = record
  public
    CmdBuffer: TImVector<TImDrawCmd>;
    IdxBuffer: TImVector<TImDrawIdx>;
    VtxBuffer: TImVector<TImDrawVert>;
    Flags: TImDrawListFlags;
    VtxCurrentIdx: Cardinal;
    Data: PImDrawListSharedData;
    OwnerName: PUTF8Char;
    VtxWritePtr: PImDrawVert;
    IdxWritePtr: PImDrawIdx;
    ClipRectStack: TImVector<TRectF>;
    TextureIdStack: TImVector<TImTextureID>;
    Path: TImVector<TVector2>;
    CmdHeader: TImDrawCmdHeader;
    Splitter: TImDrawListSplitter;
    FringeScale: Single;
  public
    class function Create(const ASharedData: PImDrawListSharedData): PImDrawList; static; inline;
    procedure Free; inline;
    procedure AddBezierCubic(const AP1: TVector2; const AP2: TVector2; const AP3: TVector2; const AP4: TVector2; const ACol: UInt32; const AThickness: Single; const ANumSegments: Integer = 0); inline;
    procedure AddBezierQuadratic(const AP1: TVector2; const AP2: TVector2; const AP3: TVector2; const ACol: UInt32; const AThickness: Single; const ANumSegments: Integer = 0); inline;
    procedure AddCallback(const ACallback: TImDrawCallback; const ACallbackData: Pointer); inline;
    procedure AddCircle(const ACenter: TVector2; const ARadius: Single; const ACol: UInt32; const ANumSegments: Integer = 0; const AThickness: Single = 1.0); inline;
    procedure AddCircleFilled(const ACenter: TVector2; const ARadius: Single; const ACol: UInt32; const ANumSegments: Integer = 0); inline;
    procedure AddConvexPolyFilled(const APoints: PVector2; const ANumPoints: Integer; const ACol: UInt32); inline;
    procedure AddDrawCmd; inline;
    procedure AddImage(const AUserTextureId: TImTextureID; const APMin: TVector2; const APMax: TVector2; const AUvMin: TVector2; const AUvMax: TVector2; const ACol: UInt32 = 4294967295); overload; inline;
    procedure AddImage(const AUserTextureId: TImTextureID; const APMin: TVector2; const APMax: TVector2; const ACol: UInt32 = 4294967295); overload; inline;
    procedure AddImageQuad(const AUserTextureId: TImTextureID; const AP1: TVector2; const AP2: TVector2; const AP3: TVector2; const AP4: TVector2; const AUv1: TVector2; const AUv2: TVector2; const AUv3: TVector2; const AUv4: TVector2; const ACol: UInt32 = 4294967295); overload; inline;
    procedure AddImageQuad(const AUserTextureId: TImTextureID; const AP1: TVector2; const AP2: TVector2; const AP3: TVector2; const AP4: TVector2; const ACol: UInt32 = 4294967295); overload; inline;
    procedure AddImageRounded(const AUserTextureId: TImTextureID; const APMin: TVector2; const APMax: TVector2; const AUvMin: TVector2; const AUvMax: TVector2; const ACol: UInt32; const ARounding: Single; const AFlags: TImDrawFlags = []); inline;
    procedure AddLine(const AP1: TVector2; const AP2: TVector2; const ACol: UInt32; const AThickness: Single = 1.0); inline;
    procedure AddNgon(const ACenter: TVector2; const ARadius: Single; const ACol: UInt32; const ANumSegments: Integer; const AThickness: Single = 1.0); inline;
    procedure AddNgonFilled(const ACenter: TVector2; const ARadius: Single; const ACol: UInt32; const ANumSegments: Integer); inline;
    procedure AddPolyline(const APoints: PVector2; const ANumPoints: Integer; const ACol: UInt32; const AFlags: TImDrawFlags; const AThickness: Single); inline;
    procedure AddQuad(const AP1: TVector2; const AP2: TVector2; const AP3: TVector2; const AP4: TVector2; const ACol: UInt32; const AThickness: Single = 1.0); inline;
    procedure AddQuadFilled(const AP1: TVector2; const AP2: TVector2; const AP3: TVector2; const AP4: TVector2; const ACol: UInt32); inline;
    procedure AddRect(const APMin: TVector2; const APMax: TVector2; const ACol: UInt32; const ARounding: Single = 0.0; const AFlags: TImDrawFlags = []; const AThickness: Single = 1.0); inline;
    procedure AddRectFilled(const APMin: TVector2; const APMax: TVector2; const ACol: UInt32; const ARounding: Single = 0.0; const AFlags: TImDrawFlags = []); inline;
    procedure AddRectFilledMultiColor(const APMin: TVector2; const APMax: TVector2; const AColUprLeft: UInt32; const AColUprRight: UInt32; const AColBotRight: UInt32; const AColBotLeft: UInt32); inline;
    procedure AddText(const APos: TVector2; const ACol: UInt32; const ATextBegin: PUTF8Char; const ATextEnd: PUTF8Char = nil); overload; inline;
    procedure AddText(const AFont: PImFont; const AFontSize: Single; const APos: TVector2; const ACol: UInt32; const ATextBegin: PUTF8Char; const ATextEnd: PUTF8Char = nil; const AWrapWidth: Single = 0.0; const ACpuFineClipRect: PRectF = nil); overload; inline;
    procedure AddTriangle(const AP1: TVector2; const AP2: TVector2; const AP3: TVector2; const ACol: UInt32; const AThickness: Single = 1.0); inline;
    procedure AddTriangleFilled(const AP1: TVector2; const AP2: TVector2; const AP3: TVector2; const ACol: UInt32); inline;
    procedure ChannelsMerge; inline;
    procedure ChannelsSetCurrent(const AN: Integer); inline;
    procedure ChannelsSplit(const ACount: Integer); inline;
    function CloneOutput: PImDrawList; inline;
    function GetClipRectMax: TVector2; inline;
    function GetClipRectMin: TVector2; inline;
    procedure PathArcTo(const ACenter: TVector2; const ARadius: Single; const AAMin: Single; const AAMax: Single; const ANumSegments: Integer = 0); inline;
    procedure PathArcToFast(const ACenter: TVector2; const ARadius: Single; const AAMinOf12: Integer; const AAMaxOf12: Integer); inline;
    procedure PathBezierCubicCurveTo(const AP2: TVector2; const AP3: TVector2; const AP4: TVector2; const ANumSegments: Integer = 0); inline;
    procedure PathBezierQuadraticCurveTo(const AP2: TVector2; const AP3: TVector2; const ANumSegments: Integer = 0); inline;
    procedure PathClear; inline;
    procedure PathFillConvex(const ACol: UInt32); inline;
    procedure PathLineTo(const APos: TVector2); inline;
    procedure PathLineToMergeDuplicate(const APos: TVector2); inline;
    procedure PathRect(const ARectMin: TVector2; const ARectMax: TVector2; const ARounding: Single = 0.0; const AFlags: TImDrawFlags = []); inline;
    procedure PathStroke(const ACol: UInt32; const AFlags: TImDrawFlags = []; const AThickness: Single = 1.0); inline;
    procedure PopClipRect; inline;
    procedure PopTextureID; inline;
    procedure PrimQuadUV(const AA: TVector2; const AB: TVector2; const AC: TVector2; const AD: TVector2; const AUvA: TVector2; const AUvB: TVector2; const AUvC: TVector2; const AUvD: TVector2; const ACol: UInt32); inline;
    procedure PrimRect(const AA: TVector2; const AB: TVector2; const ACol: UInt32); inline;
    procedure PrimRectUV(const AA: TVector2; const AB: TVector2; const AUvA: TVector2; const AUvB: TVector2; const ACol: UInt32); inline;
    procedure PrimReserve(const AIdxCount: Integer; const AVtxCount: Integer); inline;
    procedure PrimUnreserve(const AIdxCount: Integer; const AVtxCount: Integer); inline;
    procedure PrimVtx(const APos: TVector2; const AUv: TVector2; const ACol: UInt32); inline;
    procedure PrimWriteIdx(const AIdx: TImDrawIdx); inline;
    procedure PrimWriteVtx(const APos: TVector2; const AUv: TVector2; const ACol: UInt32); inline;
    procedure PushClipRect(const AClipRectMin: TVector2; const AClipRectMax: TVector2; const AIntersectWithCurrentClipRect: Boolean = False); inline;
    procedure PushClipRectFullScreen; inline;
    procedure PushTextureID(const ATextureId: TImTextureID); inline;
    function CalcCircleAutoSegmentCount(const ARadius: Single): Integer; inline;
    procedure ClearFreeMemory; inline;
    procedure OnChangedClipRect; inline;
    procedure OnChangedTextureID; inline;
    procedure OnChangedVtxOffset; inline;
    procedure PathArcToFastEx(const ACenter: TVector2; const ARadius: Single; const AAMinSample: Integer; const AAMaxSample: Integer; const AAStep: Integer); inline;
    procedure PathArcToN(const ACenter: TVector2; const ARadius: Single; const AAMin: Single; const AAMax: Single; const ANumSegments: Integer); inline;
    procedure PopUnusedDrawCmd; inline;
    procedure ResetForNewFrame; inline;
    procedure TryMergeDrawCmds; inline;
  end;

  TImFontGlyph = record
  public
    Colored: Cardinal;
    Visible: Cardinal;
    Codepoint: Cardinal;
    AdvanceX: Single;
    X0: Single;
    Y0: Single;
    X1: Single;
    Y1: Single;
    U0: Single;
    V0: Single;
    U1: Single;
    V1: Single;
  end;

  TImFont = record
  public
    IndexAdvanceX: TImVector<Single>;
    FallbackAdvanceX: Single;
    FontSize: Single;
    IndexLookup: TImVector<WideChar>;
    Glyphs: TImVector<TImFontGlyph>;
    FallbackGlyph: PImFontGlyph;
    ContainerAtlas: PImFontAtlas;
    ConfigData: PImFontConfig;
    ConfigDataCount: Smallint;
    FallbackChar: WideChar;
    EllipsisChar: WideChar;
    DotChar: WideChar;
    DirtyLookupTables: Boolean;
    Scale: Single;
    Ascent: Single;
    Descent: Single;
    MetricsTotalSurface: Integer;
    Used4kPagesMap: array [0..1] of UInt8;
  public
    class function Create: PImFont; static; inline;
    procedure Free; inline;
    procedure AddGlyph(const ASrcCfg: PImFontConfig; const AC: WideChar; const AX0: Single; const AY0: Single; const AX1: Single; const AY1: Single; const AU0: Single; const AV0: Single; const AU1: Single; const AV1: Single; const AAdvanceX: Single); inline;
    procedure AddRemapChar(const ADst: WideChar; const ASrc: WideChar; const AOverwriteDst: Boolean = True); inline;
    procedure BuildLookupTable; inline;
    function CalcTextSizeA(const ASize: Single; const AMaxWidth: Single; const AWrapWidth: Single; const ATextBegin: PUTF8Char; const ATextEnd: PUTF8Char = nil; const ARemaining: PPUTF8Char = nil): TVector2; inline;
    function CalcWordWrapPositionA(const AScale: Single; const AText: PUTF8Char; const ATextEnd: PUTF8Char; const AWrapWidth: Single): PUTF8Char; inline;
    procedure ClearOutputData; inline;
    function FindGlyph(const AC: WideChar): PImFontGlyph; inline;
    function FindGlyphNoFallback(const AC: WideChar): PImFontGlyph; inline;
    function GetCharAdvance(const AC: WideChar): Single; inline;
    function GetDebugName: PUTF8Char; inline;
    procedure GrowIndex(const ANewSize: Integer); inline;
    function IsGlyphRangeUnused(const ACBegin: Cardinal; const ACLast: Cardinal): Boolean; inline;
    function IsLoaded: Boolean; inline;
    procedure RenderChar(const ADrawList: PImDrawList; const ASize: Single; const APos: TVector2; const ACol: UInt32; const AC: WideChar); inline;
    procedure RenderText(const ADrawList: PImDrawList; const ASize: Single; const APos: TVector2; const ACol: UInt32; const AClipRect: TRectF; const ATextBegin: PUTF8Char; const ATextEnd: PUTF8Char; const AWrapWidth: Single = 0.0; const ACpuFineClip: Boolean = False); inline;
    procedure SetGlyphVisible(const AC: WideChar; const AVisible: Boolean); inline;
  end;

  TImFontConfig = record
  public
    FontData: Pointer;
    FontDataSize: Integer;
    FontDataOwnedByAtlas: Boolean;
    FontNo: Integer;
    SizePixels: Single;
    OversampleH: Integer;
    OversampleV: Integer;
    PixelSnapH: Boolean;
    GlyphExtraSpacing: TVector2;
    GlyphOffset: TVector2;
    GlyphRanges: PWideChar;
    GlyphMinAdvanceX: Single;
    GlyphMaxAdvanceX: Single;
    MergeMode: Boolean;
    FontBuilderFlags: Cardinal;
    RasterizerMultiply: Single;
    EllipsisChar: WideChar;
    Name: array [0..39] of UTF8Char;
    DstFont: PImFont;
  public
    class function Create: PImFontConfig; static; inline;
    procedure Free; inline;
  end;

  TImFontAtlasCustomRect = record
  public
    Width: Word;
    Height: Word;
    X: Word;
    Y: Word;
    GlyphID: Cardinal;
    GlyphAdvanceX: Single;
    GlyphOffset: TVector2;
    Font: PImFont;
  public
    class function Create: PImFontAtlasCustomRect; static; inline;
    procedure Free; inline;
    function IsPacked: Boolean; inline;
  end;

  TImFontAtlas = record
  public
    Flags: TImFontAtlasFlags;
    TexID: TImTextureID;
    TexDesiredWidth: Integer;
    TexGlyphPadding: Integer;
    Locked: Boolean;
    TexReady: Boolean;
    TexPixelsUseColors: Boolean;
    TexPixelsAlpha8: PByte;
    TexPixelsRGBA32: PCardinal;
    TexWidth: Integer;
    TexHeight: Integer;
    TexUvScale: TVector2;
    TexUvWhitePixel: TVector2;
    Fonts: TImVector<PImFont>;
    CustomRects: TImVector<TImFontAtlasCustomRect>;
    ConfigData: TImVector<TImFontConfig>;
    TexUvLines: array [0..63] of TVector4;
    FontBuilderIO: PImFontBuilderIO;
    FontBuilderFlags: Cardinal;
    PackIdMouseCursors: Integer;
    PackIdLines: Integer;
  public
    class function Create: PImFontAtlas; static; inline;
    procedure Free; inline;
    function AddCustomRectFontGlyph(const AFont: PImFont; const AId: WideChar; const AWidth: Integer; const AHeight: Integer; const AAdvanceX: Single; const AOffset: TVector2): Integer; overload; inline;
    function AddCustomRectFontGlyph(const AFont: PImFont; const AId: WideChar; const AWidth: Integer; const AHeight: Integer; const AAdvanceX: Single): Integer; overload; inline;
    function AddCustomRectRegular(const AWidth: Integer; const AHeight: Integer): Integer; inline;
    function AddFont(const AFontCfg: PImFontConfig): PImFont; inline;
    function AddFontDefault(const AFontCfg: PImFontConfig = nil): PImFont; inline;
    function AddFontFromFileTTF(const AFilename: PUTF8Char; const ASizePixels: Single; const AFontCfg: PImFontConfig = nil; const AGlyphRanges: PWideChar = nil): PImFont; inline;
    function AddFontFromMemoryCompressedBase85TTF(const ACompressedFontDataBase85: PUTF8Char; const ASizePixels: Single; const AFontCfg: PImFontConfig = nil; const AGlyphRanges: PWideChar = nil): PImFont; inline;
    function AddFontFromMemoryCompressedTTF(const ACompressedFontData: Pointer; const ACompressedFontSize: Integer; const ASizePixels: Single; const AFontCfg: PImFontConfig = nil; const AGlyphRanges: PWideChar = nil): PImFont; inline;
    function AddFontFromMemoryTTF(const AFontData: Pointer; const AFontSize: Integer; const ASizePixels: Single; const AFontCfg: PImFontConfig = nil; const AGlyphRanges: PWideChar = nil): PImFont; inline;
    function Build: Boolean; inline;
    procedure CalcCustomRectUV(const ARect: PImFontAtlasCustomRect; const AOutUvMin: PVector2; const AOutUvMax: PVector2); inline;
    procedure Clear; inline;
    procedure ClearFonts; inline;
    procedure ClearInputData; inline;
    procedure ClearTexData; inline;
    function GetCustomRectByIndex(const AIndex: Integer): PImFontAtlasCustomRect; inline;
    function GetGlyphRangesChineseFull: PWideChar; inline;
    function GetGlyphRangesChineseSimplifiedCommon: PWideChar; inline;
    function GetGlyphRangesCyrillic: PWideChar; inline;
    function GetGlyphRangesDefault: PWideChar; inline;
    function GetGlyphRangesJapanese: PWideChar; inline;
    function GetGlyphRangesKorean: PWideChar; inline;
    function GetGlyphRangesThai: PWideChar; inline;
    function GetGlyphRangesVietnamese: PWideChar; inline;
    function GetMouseCursorTexData(const ACursor: TImGuiMouseCursor; const AOutOffset: PVector2; const AOutSize: PVector2; const AOutUvBorder: PVector2; const AOutUvFill: PVector2): Boolean; inline;
    procedure GetTexDataAsAlpha8(out AOutPixels: PByte; out AOutWidth: Integer; out AOutHeight: Integer; const AOutBytesPerPixel: PInteger = nil); inline;
    procedure GetTexDataAsRGBA32(out AOutPixels: PByte; out AOutWidth: Integer; out AOutHeight: Integer; const AOutBytesPerPixel: PInteger = nil); inline;
    function IsBuilt: Boolean; inline;
    procedure SetTexID(const AId: TImTextureID); inline;
  end;

  TImFontGlyphRangesBuilder = record
  public
    UsedChars: TImVector<UInt32>;
  public
    class function Create: PImFontGlyphRangesBuilder; static; inline;
    procedure Free; inline;
    procedure AddChar(const AC: WideChar); inline;
    procedure AddRanges(const ARanges: PWideChar); inline;
    procedure AddText(const AText: PUTF8Char; const ATextEnd: PUTF8Char = nil); inline;
    procedure BuildRanges(out AOutRanges: TImVector<WideChar>); inline;
    procedure Clear; inline;
    function GetBit(const AN: NativeUInt): Boolean; inline;
    procedure SetBit(const AN: NativeUInt); inline;
  end;

  TImGuiTextBuffer = record
  public
    Buf: TImVector<UTF8Char>;
  public
    class function Create: PImGuiTextBuffer; static; inline;
    procedure Free; inline;
    procedure Append(const AStr: PUTF8Char; const AStrEnd: PUTF8Char = nil); inline;
    function &Begin: PUTF8Char; inline;
    function CStr: PUTF8Char; overload; inline;
    function ToString: String; inline;
    function ToUTF8String: UTF8String; inline;
    procedure Clear; inline;
    function Empty: Boolean; inline;
    function &End: PUTF8Char; inline;
    procedure Reserve(const ACapacity: Integer); inline;
    function Size: Integer; inline;
  end;

  TImGuiStoragePair = record
  public
    Key: TImGuiID;
    Value: record case byte of 0: (ValI: Integer); 1: (ValF: Single); 2: (ValP: Pointer); end;
  public
    class function Create(const AKey: TImGuiID; const AValI: Integer): PImGuiStoragePair; overload; static; inline;
    class function Create(const AKey: TImGuiID; const AValF: Single): PImGuiStoragePair; overload; static; inline;
    class function Create(const AKey: TImGuiID; const AValP: Pointer): PImGuiStoragePair; overload; static; inline;
    procedure Free; inline;
  end;

  TImGuiStorage = record
  public
    Data: TImVector<TImGuiStoragePair>;
  public
    procedure BuildSortByKey; inline;
    procedure Clear; inline;
    function GetBool(const AKey: TImGuiID; const ADefaultVal: Boolean = False): Boolean; inline;
    function GetBoolRef(const AKey: TImGuiID; const ADefaultVal: Boolean = False): PBoolean; inline;
    function GetFloat(const AKey: TImGuiID; const ADefaultVal: Single = 0.0): Single; inline;
    function GetFloatRef(const AKey: TImGuiID; const ADefaultVal: Single = 0.0): PSingle; inline;
    function GetInt(const AKey: TImGuiID; const ADefaultVal: Integer = 0): Integer; inline;
    function GetIntRef(const AKey: TImGuiID; const ADefaultVal: Integer = 0): PInteger; inline;
    function GetVoidPtr(const AKey: TImGuiID): Pointer; inline;
    function GetVoidPtrRef(const AKey: TImGuiID; const ADefaultVal: Pointer = nil): PPointer; inline;
    procedure SetAllInt(const AVal: Integer); inline;
    procedure SetBool(const AKey: TImGuiID; const AVal: Boolean); inline;
    procedure SetFloat(const AKey: TImGuiID; const AVal: Single); inline;
    procedure SetInt(const AKey: TImGuiID; const AVal: Integer); inline;
    procedure SetVoidPtr(const AKey: TImGuiID; const AVal: Pointer); inline;
  end;

  TImGuiPlatformImeData = record
  public
    WantVisible: Boolean;
    InputPos: TVector2;
    InputLineHeight: Single;
  public
    class function Create: PImGuiPlatformImeData; static; inline;
    procedure Free; inline;
  end;

  TImGuiTableSortSpecs = record
  public
    Specs: PImGuiTableColumnSortSpecs;
    SpecsCount: Integer;
    SpecsDirty: Boolean;
  public
    class function Create: PImGuiTableSortSpecs; static; inline;
    procedure Free; inline;
  end;

  TImGuiTableColumnSortSpecs = record
  public
    ColumnUserID: TImGuiID;
    ColumnIndex: Int16;
    SortOrder: Int16;
    SortDirection: TImGuiSortDirection;
  public
    class function Create: PImGuiTableColumnSortSpecs; static; inline;
    procedure Free; inline;
  end;

  TImGuiPayload = record
  public
    Data: Pointer;
    DataSize: Integer;
    SourceId: TImGuiID;
    SourceParentId: TImGuiID;
    DataFrameCount: Integer;
    DataType: array [0..32] of UTF8Char;
    Preview: Boolean;
    Delivery: Boolean;
  public
    class function Create: PImGuiPayload; static; inline;
    procedure Free; inline;
    procedure Clear; inline;
    function IsDataType(const AType: PUTF8Char): Boolean; inline;
    function IsDelivery: Boolean; inline;
    function IsPreview: Boolean; inline;
  end;

  TImGuiPlatformMonitor = record
  public
    MainPos: TVector2;
    MainSize: TVector2;
    WorkPos: TVector2;
    WorkSize: TVector2;
    DpiScale: Single;
  public
    class function Create: PImGuiPlatformMonitor; static; inline;
    procedure Free; inline;
  end;

  TImGuiWindowClass = record
  public
    ClassId: TImGuiID;
    ParentViewportId: TImGuiID;
    ViewportFlagsOverrideSet: TImGuiViewportFlags;
    ViewportFlagsOverrideClear: TImGuiViewportFlags;
    TabItemFlagsOverrideSet: TImGuiTabItemFlags;
    DockNodeFlagsOverrideSet: TImGuiDockNodeFlags;
    DockingAlwaysTabBar: Boolean;
    DockingAllowUnclassed: Boolean;
  public
    class function Create: PImGuiWindowClass; static; inline;
    procedure Free; inline;
  end;

  TImGuiStyle = record
  public
    Alpha: Single;
    DisabledAlpha: Single;
    WindowPadding: TVector2;
    WindowRounding: Single;
    WindowBorderSize: Single;
    WindowMinSize: TVector2;
    WindowTitleAlign: TVector2;
    WindowMenuButtonPosition: TImGuiDir;
    ChildRounding: Single;
    ChildBorderSize: Single;
    PopupRounding: Single;
    PopupBorderSize: Single;
    FramePadding: TVector2;
    FrameRounding: Single;
    FrameBorderSize: Single;
    ItemSpacing: TVector2;
    ItemInnerSpacing: TVector2;
    CellPadding: TVector2;
    TouchExtraPadding: TVector2;
    IndentSpacing: Single;
    ColumnsMinSpacing: Single;
    ScrollbarSize: Single;
    ScrollbarRounding: Single;
    GrabMinSize: Single;
    GrabRounding: Single;
    LogSliderDeadzone: Single;
    TabRounding: Single;
    TabBorderSize: Single;
    TabMinWidthForCloseButton: Single;
    ColorButtonPosition: TImGuiDir;
    ButtonTextAlign: TVector2;
    SelectableTextAlign: TVector2;
    DisplayWindowPadding: TVector2;
    DisplaySafeAreaPadding: TVector2;
    MouseCursorScale: Single;
    AntiAliasedLines: Boolean;
    AntiAliasedLinesUseTex: Boolean;
    AntiAliasedFill: Boolean;
    CurveTessellationTol: Single;
    CircleTessellationMaxError: Single;
    Colors: array [0..54] of TAlphaColorF;
  public
    class function Create: PImGuiStyle; static; inline;
    procedure Free; inline;
    procedure ScaleAllSizes(const AScaleFactor: Single); inline;
  end;

  TImGuiPlatformIO = record
  public
    PlatformCreateWindow: procedure(const AVP: PImGuiViewport); cdecl;
    PlatformDestroyWindow: procedure(const AVP: PImGuiViewport); cdecl;
    PlatformShowWindow: procedure(const AVP: PImGuiViewport); cdecl;
    PlatformSetWindowPos: procedure(const AVP: PImGuiViewport; const APos: TVector2); cdecl;
    PlatformGetWindowPos: function(const AVP: PImGuiViewport): TVector2; cdecl;
    PlatformSetWindowSize: procedure(const AVP: PImGuiViewport; const ASize: TVector2); cdecl;
    PlatformGetWindowSize: function(const AVP: PImGuiViewport): TVector2; cdecl;
    PlatformSetWindowFocus: procedure(const AVP: PImGuiViewport); cdecl;
    PlatformGetWindowFocus: function(const AVP: PImGuiViewport): Boolean; cdecl;
    PlatformGetWindowMinimized: function(const AVP: PImGuiViewport): Boolean; cdecl;
    PlatformSetWindowTitle: procedure(const AVP: PImGuiViewport; const AStr: PUTF8Char); cdecl;
    PlatformSetWindowAlpha: procedure(const AVP: PImGuiViewport; const AAlpha: Single); cdecl;
    PlatformUpdateWindow: procedure(const AVP: PImGuiViewport); cdecl;
    PlatformRenderWindow: procedure(const AVP: PImGuiViewport; const ARenderArg: Pointer); cdecl;
    PlatformSwapBuffers: procedure(const AVP: PImGuiViewport; const ARenderArg: Pointer); cdecl;
    PlatformGetWindowDpiScale: function(const AVP: PImGuiViewport): Single; cdecl;
    PlatformOnChangedViewport: procedure(const AVP: PImGuiViewport); cdecl;
    PlatformCreateVkSurface: function(const AVP: PImGuiViewport; const AVKInst: UInt64; const AVKAllocators: Pointer; const AOutVKSurface: PUInt64): Single; cdecl;
    RendererCreateWindow: procedure(const AVP: PImGuiViewport); cdecl;
    RendererDestroyWindow: procedure(const AVP: PImGuiViewport); cdecl;
    RendererSetWindowSize: procedure(const AVP: PImGuiViewport; const ASize: TVector2); cdecl;
    RendererRenderWindow: procedure(const AVP: PImGuiViewport; const ARenderArg: Pointer); cdecl;
    RendererSwapBuffers: procedure(const AVP: PImGuiViewport; const ARenderArg: Pointer); cdecl;
    Monitors: TImVector<TImGuiPlatformMonitor>;
    Viewports: TImVector<PImGuiViewport>;
  public
    class function Create: PImGuiPlatformIO; static; inline;
    procedure Free; inline;
  end;

  TImGuiKeyData = record
  public
    Down: Boolean;
    DownDuration: Single;
    DownDurationPrev: Single;
    AnalogValue: Single;
  end;

  TImGuiIO = record
  public
    ConfigFlags: TImGuiConfigFlags;
    BackendFlags: TImGuiBackendFlags;
    DisplaySize: TVector2;
    DeltaTime: Single;
    IniSavingRate: Single;
    IniFilename: PUTF8Char;
    LogFilename: PUTF8Char;
    MouseDoubleClickTime: Single;
    MouseDoubleClickMaxDist: Single;
    MouseDragThreshold: Single;
    KeyRepeatDelay: Single;
    KeyRepeatRate: Single;
    UserData: Pointer;
    Fonts: PImFontAtlas;
    FontGlobalScale: Single;
    FontAllowUserScaling: Boolean;
    FontDefault: PImFont;
    DisplayFramebufferScale: TVector2;
    ConfigDockingNoSplit: Boolean;
    ConfigDockingWithShift: Boolean;
    ConfigDockingAlwaysTabBar: Boolean;
    ConfigDockingTransparentPayload: Boolean;
    ConfigViewportsNoAutoMerge: Boolean;
    ConfigViewportsNoTaskBarIcon: Boolean;
    ConfigViewportsNoDecoration: Boolean;
    ConfigViewportsNoDefaultParent: Boolean;
    MouseDrawCursor: Boolean;
    ConfigMacOSXBehaviors: Boolean;
    ConfigInputTrickleEventQueue: Boolean;
    ConfigInputTextCursorBlink: Boolean;
    ConfigDragClickToInputText: Boolean;
    ConfigWindowsResizeFromEdges: Boolean;
    ConfigWindowsMoveFromTitleBarOnly: Boolean;
    ConfigMemoryCompactTimer: Single;
    BackendPlatformName: PUTF8Char;
    BackendRendererName: PUTF8Char;
    BackendPlatformUserData: Pointer;
    BackendRendererUserData: Pointer;
    BackendLanguageUserData: Pointer;
    GetClipboardTextFn: function(const AUserData: Pointer): PUTF8Char; cdecl;
    SetClipboardTextFn: procedure(const AUserData: Pointer; const AText: PUTF8Char); cdecl;
    ClipboardUserData: Pointer;
    SetPlatformImeDataFn: procedure(const AViewport: PImGuiViewport; const AData: PImGuiPlatformImeData); cdecl;
    UnusedPadding: Pointer;
    WantCaptureMouse: Boolean;
    WantCaptureKeyboard: Boolean;
    WantTextInput: Boolean;
    WantSetMousePos: Boolean;
    WantSaveIniSettings: Boolean;
    NavActive: Boolean;
    NavVisible: Boolean;
    Framerate: Single;
    MetricsRenderVertices: Integer;
    MetricsRenderIndices: Integer;
    MetricsRenderWindows: Integer;
    MetricsActiveWindows: Integer;
    MetricsActiveAllocations: Integer;
    MouseDelta: TVector2;
    KeyMap: array [0..644] of Integer;
    KeysDown: array [0..644] of Boolean;
    MousePos: TVector2;
    MouseDown: array [0..4] of Boolean;
    MouseWheel: Single;
    MouseWheelH: Single;
    MouseHoveredViewport: TImGuiID;
    KeyCtrl: Boolean;
    KeyShift: Boolean;
    KeyAlt: Boolean;
    KeySuper: Boolean;
    NavInputs: array [0..19] of Single;
    KeyMods: TImGuiModFlags;
    KeysData: array [0..644] of TImGuiKeyData;
    WantCaptureMouseUnlessPopupClose: Boolean;
    MousePosPrev: TVector2;
    MouseClickedPos: array [0..4] of TVector2;
    MouseClickedTime: array [0..4] of Double;
    MouseClicked: array [0..4] of Boolean;
    MouseDoubleClicked: array [0..4] of Boolean;
    MouseClickedCount: array [0..4] of UInt16;
    MouseClickedLastCount: array [0..4] of UInt16;
    MouseReleased: array [0..4] of Boolean;
    MouseDownOwned: array [0..4] of Boolean;
    MouseDownOwnedUnlessPopupClose: array [0..4] of Boolean;
    MouseDownDuration: array [0..4] of Single;
    MouseDownDurationPrev: array [0..4] of Single;
    MouseDragMaxDistanceAbs: array [0..4] of TVector2;
    MouseDragMaxDistanceSqr: array [0..4] of Single;
    NavInputsDownDuration: array [0..19] of Single;
    NavInputsDownDurationPrev: array [0..19] of Single;
    PenPressure: Single;
    AppFocusLost: Boolean;
    AppAcceptingEvents: Boolean;
    BackendUsingLegacyKeyArrays: Int8;
    BackendUsingLegacyNavInputArray: Boolean;
    InputQueueSurrogate: WideChar;
    InputQueueCharacters: TImVector<WideChar>;
  public
    class function Create: PImGuiIO; static; inline;
    procedure Free; inline;
    procedure AddFocusEvent(const AFocused: Boolean); inline;
    procedure AddInputCharacter(const AC: Cardinal); inline;
    procedure AddInputCharacterUTF16(const AC: WideChar); inline;
    procedure AddInputCharactersUTF8(const AStr: PUTF8Char); inline;
    procedure AddKeyAnalogEvent(const AKey: TImGuiKey; const ADown: Boolean; const AV: Single); inline;
    procedure AddKeyEvent(const AKey: TImGuiKey; const ADown: Boolean); inline;
    procedure AddMouseButtonEvent(const AButton: Integer; const ADown: Boolean); inline;
    procedure AddMousePosEvent(const AX: Single; const AY: Single); inline;
    procedure AddMouseViewportEvent(const AId: TImGuiID); inline;
    procedure AddMouseWheelEvent(const AWhX: Single; const AWhY: Single); inline;
    procedure ClearInputCharacters; inline;
    procedure ClearInputKeys; inline;
    procedure SetAppAcceptingEvents(const AAcceptingEvents: Boolean); inline;
    procedure SetKeyEventNativeData(const AKey: TImGuiKey; const ANativeKeycode: Integer; const ANativeScancode: Integer; const ANativeLegacyIndex: Integer = -1); inline;
  end;

  TImGuiInputTextCallbackData = record
  public
    EventFlag: TImGuiInputTextFlags;
    Flags: TImGuiInputTextFlags;
    UserData: Pointer;
    EventChar: WideChar;
    EventKey: TImGuiKey;
    Buf: PUTF8Char;
    BufTextLen: Integer;
    BufSize: Integer;
    BufDirty: Boolean;
    CursorPos: Integer;
    SelectionStart: Integer;
    SelectionEnd: Integer;
  public
    class function Create: PImGuiInputTextCallbackData; static; inline;
    procedure Free; inline;
    procedure ClearSelection; inline;
    procedure DeleteChars(const APos: Integer; const ABytesCount: Integer); inline;
    function HasSelection: Boolean; inline;
    procedure InsertChars(const APos: Integer; const AText: PUTF8Char; const ATextEnd: PUTF8Char = nil); inline;
    procedure SelectAll; inline;
  end;

  TImGuiListClipper = record
  public
    DisplayStart: Integer;
    DisplayEnd: Integer;
    ItemsCount: Integer;
    ItemsHeight: Single;
    StartPosY: Single;
    TempData: Pointer;
  public
    class function Create: PImGuiListClipper; static; inline;
    procedure Free; inline;
    procedure &Begin(const AItemsCount: Integer; const AItemsHeight: Single = -1.0); inline;
    procedure &End; inline;
    procedure ForceDisplayRangeByIndices(const AItemMin: Integer; const AItemMax: Integer); inline;
    function Step: Boolean; inline;
  end;

  TImGuiOnceUponAFrame = record
  public
    RefFrame: Integer;
  public
    class function Create: PImGuiOnceUponAFrame; static; inline;
    procedure Free; inline;
  end;

  TImGuiSizeCallbackData = record
  public
    UserData: Pointer;
    Pos: TVector2;
    CurrentSize: TVector2;
    DesiredSize: TVector2;
  end;

  TImGuiTextRange = record
  public
    B: PUTF8Char;
    E: PUTF8Char;
  public
    class function Create: PImGuiTextRange; overload; static; inline;
    class function Create(const AB: PUTF8Char; const AE: PUTF8Char): PImGuiTextRange; overload; static; inline;
    procedure Free; inline;
    function Empty: Boolean; inline;
    procedure Split(const ASeparator: UTF8Char; out AOut: TImVector<TImGuiTextRange>); inline;
  end;

  TImGuiTextFilter = record
  public
    InputBuf: array [0..255] of UTF8Char;
    Filters: TImVector<TImGuiTextRange>;
    CountGrep: Integer;
  public
    class function Create(const ADefaultFilter: PUTF8Char = nil): PImGuiTextFilter; static; inline;
    procedure Free; inline;
    procedure Build; inline;
    procedure Clear; inline;
    function Draw(const ALabel: PUTF8Char = nil; const AWidth: Single = 0.0): Boolean; inline;
    function IsActive: Boolean; inline;
    function PassFilter(const AText: PUTF8Char; const ATextEnd: PUTF8Char = nil): Boolean; inline;
  end;

  TImGuiViewport = record
  public
    ID: TImGuiID;
    Flags: TImGuiViewportFlags;
    Pos: TVector2;
    Size: TVector2;
    WorkPos: TVector2;
    WorkSize: TVector2;
    DpiScale: Single;
    ParentViewportId: TImGuiID;
    DrawData: PImDrawData;
    RendererUserData: Pointer;
    PlatformUserData: Pointer;
    PlatformHandle: Pointer;
    PlatformHandleRaw: Pointer;
    PlatformRequestMove: Boolean;
    PlatformRequestResize: Boolean;
    PlatformRequestClose: Boolean;
  public
    class function Create: PImGuiViewport; static; inline;
    procedure Free; inline;
    function GetCenter: TVector2; inline;
    function GetWorkCenter: TVector2; inline;
  end;

  TImGuiWindowPtr = PImGuiWindow;
  TImVectorPChar = TImVector<PChar>;
  _ImGuiItemsGetter = _igCombo_FnBoolPtr__items_getter;
  _ImGuiCompareFunc = _igImQsort__compare_func;
  _ImGuiValuesGetter = _igPlotEx__values_getter;
  TImGuiItemsGetter = function(const AData: Pointer; const AIdx: Integer; out AOutText: PUTF8Char): Boolean; cdecl;
  PImVectorPChar = ^TImVectorPChar;
  TImGuiCompareFunc = function(const ALeft, ARight: Pointer): Integer; cdecl;
  TImGuiValuesGetter = function(const AData: Pointer; const AIdx: Integer): Pointer; cdecl;

  ImGui = record
  public
    class function AcceptDragDropPayload(const AType: PUTF8Char; const AFlags: TImGuiDragDropFlags = []): PImGuiPayload; static; inline;
    class procedure AlignTextToFramePadding; static; inline;
    class function ArrowButton(const AStrId: PUTF8Char; const ADir: TImGuiDir): Boolean; static; inline;
    class function &Begin(const AName: PUTF8Char; const APOpen: PBoolean = nil; const AFlags: TImGuiWindowFlags = []): Boolean; static; inline;
    class function BeginChild(const AStrId: PUTF8Char; const ASize: TVector2; const ABorder: Boolean = False; const AFlags: TImGuiWindowFlags = []): Boolean; overload; static; inline;
    class function BeginChild(const AStrId: PUTF8Char; const ABorder: Boolean = False; const AFlags: TImGuiWindowFlags = []): Boolean; overload; static; inline;
    class function BeginChild(const AId: TImGuiID; const ASize: TVector2; const ABorder: Boolean = False; const AFlags: TImGuiWindowFlags = []): Boolean; overload; static; inline;
    class function BeginChild(const AId: TImGuiID; const ABorder: Boolean = False; const AFlags: TImGuiWindowFlags = []): Boolean; overload; static; inline;
    class function BeginChildFrame(const AId: TImGuiID; const ASize: TVector2; const AFlags: TImGuiWindowFlags = []): Boolean; static; inline;
    class function BeginCombo(const ALabel: PUTF8Char; const APreviewValue: PUTF8Char; const AFlags: TImGuiComboFlags = []): Boolean; static; inline;
    class procedure BeginDisabled(const ADisabled: Boolean = True); static; inline;
    class function BeginDragDropSource(const AFlags: TImGuiDragDropFlags = []): Boolean; static; inline;
    class function BeginDragDropTarget: Boolean; static; inline;
    class procedure BeginGroup; static; inline;
    class function BeginListBox(const ALabel: PUTF8Char; const ASize: TVector2): Boolean; overload; static; inline;
    class function BeginListBox(const ALabel: PUTF8Char): Boolean; overload; static; inline;
    class function BeginMainMenuBar: Boolean; static; inline;
    class function BeginMenu(const ALabel: PUTF8Char; const AEnabled: Boolean = True): Boolean; static; inline;
    class function BeginMenuBar: Boolean; static; inline;
    class function BeginPopup(const AStrId: PUTF8Char; const AFlags: TImGuiWindowFlags = []): Boolean; static; inline;
    class function BeginPopupContextItem(const AStrId: PUTF8Char = nil; const APopupFlags: TImGuiPopupFlags = [TImGuiPopupFlag.MouseButtonRight]): Boolean; static; inline;
    class function BeginPopupContextVoid(const AStrId: PUTF8Char = nil; const APopupFlags: TImGuiPopupFlags = [TImGuiPopupFlag.MouseButtonRight]): Boolean; static; inline;
    class function BeginPopupContextWindow(const AStrId: PUTF8Char = nil; const APopupFlags: TImGuiPopupFlags = [TImGuiPopupFlag.MouseButtonRight]): Boolean; static; inline;
    class function BeginPopupModal(const AName: PUTF8Char; const APOpen: PBoolean = nil; const AFlags: TImGuiWindowFlags = []): Boolean; static; inline;
    class function BeginTabBar(const AStrId: PUTF8Char; const AFlags: TImGuiTabBarFlags = []): Boolean; static; inline;
    class function BeginTabItem(const ALabel: PUTF8Char; const APOpen: PBoolean = nil; const AFlags: TImGuiTabItemFlags = []): Boolean; static; inline;
    class function BeginTable(const AStrId: PUTF8Char; const AColumn: Integer; const AFlags: TImGuiTableFlags; const AOuterSize: TVector2; const AInnerWidth: Single = 0.0): Boolean; overload; static; inline;
    class function BeginTable(const AStrId: PUTF8Char; const AColumn: Integer; const AFlags: TImGuiTableFlags = []; const AInnerWidth: Single = 0.0): Boolean; overload; static; inline;
    class function BeginTable(const AStrId: PUTF8Char; const AColumn: Integer; const AOuterSize: TVector2; const AFlags: TImGuiTableFlags = []; const AInnerWidth: Single = 0.0): Boolean; overload; static; inline;
    class procedure BeginTooltip; static; inline;
    class procedure Bullet; static; inline;
    class procedure BulletText(const AText: PUTF8Char); static; inline;
    class function Button(const ALabel: PUTF8Char; const ASize: TVector2): Boolean; overload; static; inline;
    class function Button(const ALabel: PUTF8Char): Boolean; overload; static; inline;
    class function CalcItemWidth: Single; static; inline;
    class function CalcTextSize(const AText: PUTF8Char; const ATextEnd: PUTF8Char = nil; const AHideTextAfterDoubleHash: Boolean = False; const AWrapWidth: Single = -1.0): TVector2; static; inline;
    class function Checkbox(const ALabel: PUTF8Char; const AV: PBoolean): Boolean; static; inline;
    class procedure CloseCurrentPopup; static; inline;
    class function CollapsingHeader(const ALabel: PUTF8Char; const AFlags: TImGuiTreeNodeFlags = []): Boolean; overload; static; inline;
    class function CollapsingHeader(const ALabel: PUTF8Char; const APVisible: PBoolean; const AFlags: TImGuiTreeNodeFlags = []): Boolean; overload; static; inline;
    class function ColorButton(const ADescId: PUTF8Char; const ACol: TAlphaColorF; const AFlags: TImGuiColorEditFlags; const ASize: TVector2): Boolean; overload; static; inline;
    class function ColorButton(const ADescId: PUTF8Char; const ACol: TAlphaColorF; const AFlags: TImGuiColorEditFlags = []): Boolean; overload; static; inline;
    class function ColorConvertToU32(const AIn: TAlphaColorF): UInt32; static; inline;
    class procedure ColorConvertHSVtoRGB(const AH: Single; const &AS: Single; const AV: Single; out AOutR: Single; out AOutG: Single; out AOutB: Single); static; inline;
    class procedure ColorConvertRGBtoHSV(const AR: Single; const AG: Single; const AB: Single; out AOutH: Single; out AOutS: Single; out AOutV: Single); static; inline;
    class function ColorConvertFromU32(const AIn: UInt32): TAlphaColorF; static; inline;
    class function ColorEdit3(const ALabel: PUTF8Char; var AColor: TAlphaColorF; const AFlags: TImGuiColorEditFlags = []): Boolean; static; inline;
    class function ColorEdit4(const ALabel: PUTF8Char; var AColor: TAlphaColorF; const AFlags: TImGuiColorEditFlags = []): Boolean; static; inline;
    class function ColorPicker3(const ALabel: PUTF8Char; var AColor: TAlphaColorF; const AFlags: TImGuiColorEditFlags = []): Boolean; static; inline;
    class function ColorPicker4(const ALabel: PUTF8Char; var AColor: TAlphaColorF; const AFlags: TImGuiColorEditFlags = []; const ARefCol: PAlphaColorF = nil): Boolean; static; inline;
    class procedure Columns(const ACount: Integer = 1; const AId: PUTF8Char = nil; const ABorder: Boolean = True); static; inline;
    class function Combo(const ALabel: PUTF8Char; var ACurrentItem: Integer; const AItems: PPUTF8Char; const AItemsCount: Integer; const APopupMaxHeightInItems: Integer = -1): Boolean; overload; static; inline;
    class function Combo(const ALabel: PUTF8Char; var ACurrentItem: Integer; const AItemsSeparatedByZeros: PUTF8Char; const APopupMaxHeightInItems: Integer = -1): Boolean; overload; static; inline;
    class function Combo(const ALabel: PUTF8Char; var ACurrentItem: Integer; const AItemsGetter: TImGuiItemsGetter; const AData: Pointer; const AItemsCount: Integer; const APopupMaxHeightInItems: Integer = -1): Boolean; overload; static; inline;
    class function CreateContext(const ASharedFontAtlas: PImFontAtlas = nil): PImGuiContext; static; inline;
    class function DebugCheckVersionAndDataLayout(const AVersionStr: PUTF8Char; const ASzIo: NativeUInt; const ASzStyle: NativeUInt; const ASzVec2: NativeUInt; const ASzVec4: NativeUInt; const ASzDrawvert: NativeUInt; const ASzDrawidx: NativeUInt): Boolean; static; inline;
    class procedure DebugTextEncoding(const AText: PUTF8Char); static; inline;
    class procedure DestroyContext(const ACtx: PImGuiContext = nil); static; inline;
    class procedure DestroyPlatformWindows; static; inline;
    class function DockSpace(const AId: TImGuiID; const ASize: TVector2; const AFlags: TImGuiDockNodeFlags = []; const AWindowClass: PImGuiWindowClass = nil): TImGuiID; overload; static; inline;
    class function DockSpace(const AId: TImGuiID; const AFlags: TImGuiDockNodeFlags = []; const AWindowClass: PImGuiWindowClass = nil): TImGuiID; overload; static; inline;
    class function DockSpaceOverViewport(const AViewport: PImGuiViewport = nil; const AFlags: TImGuiDockNodeFlags = []; const AWindowClass: PImGuiWindowClass = nil): TImGuiID; static; inline;
    class function DragFloat(const ALabel: PUTF8Char; var AV: Single; const AVSpeed: Single = 1.0; const AVMin: Single = 0.0; const AVMax: Single = 0.0; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function DragFloat2(const ALabel: PUTF8Char; var AV: Single; const AVSpeed: Single = 1.0; const AVMin: Single = 0.0; const AVMax: Single = 0.0; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function DragFloat3(const ALabel: PUTF8Char; var AV: Single; const AVSpeed: Single = 1.0; const AVMin: Single = 0.0; const AVMax: Single = 0.0; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function DragFloat4(const ALabel: PUTF8Char; var AV: Single; const AVSpeed: Single = 1.0; const AVMin: Single = 0.0; const AVMax: Single = 0.0; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function DragFloatRange2(const ALabel: PUTF8Char; var AVCurrentMin: Single; var AVCurrentMax: Single; const AVSpeed: Single = 1.0; const AVMin: Single = 0.0; const AVMax: Single = 0.0; const AFormat: PUTF8Char = nil; const AFormatMax: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function DragInt(const ALabel: PUTF8Char; var AV: Integer; const AVSpeed: Single = 1.0; const AVMin: Integer = 0; const AVMax: Integer = 0; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function DragInt2(const ALabel: PUTF8Char; var AV: Integer; const AVSpeed: Single = 1.0; const AVMin: Integer = 0; const AVMax: Integer = 0; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function DragInt3(const ALabel: PUTF8Char; var AV: Integer; const AVSpeed: Single = 1.0; const AVMin: Integer = 0; const AVMax: Integer = 0; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function DragInt4(const ALabel: PUTF8Char; var AV: Integer; const AVSpeed: Single = 1.0; const AVMin: Integer = 0; const AVMax: Integer = 0; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function DragIntRange2(const ALabel: PUTF8Char; var AVCurrentMin: Integer; var AVCurrentMax: Integer; const AVSpeed: Single = 1.0; const AVMin: Integer = 0; const AVMax: Integer = 0; const AFormat: PUTF8Char = nil; const AFormatMax: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function DragScalar(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; const APData: Pointer; const AVSpeed: Single = 1.0; const APMin: Pointer = nil; const APMax: Pointer = nil; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function DragScalarN(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; const APData: Pointer; const AComponents: Integer; const AVSpeed: Single = 1.0; const APMin: Pointer = nil; const APMax: Pointer = nil; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class procedure Dummy(const ASize: TVector2); static; inline;
    class procedure &End; static; inline;
    class procedure EndChild; static; inline;
    class procedure EndChildFrame; static; inline;
    class procedure EndCombo; static; inline;
    class procedure EndDisabled; static; inline;
    class procedure EndDragDropSource; static; inline;
    class procedure EndDragDropTarget; static; inline;
    class procedure EndFrame; static; inline;
    class procedure EndGroup; static; inline;
    class procedure EndListBox; static; inline;
    class procedure EndMainMenuBar; static; inline;
    class procedure EndMenu; static; inline;
    class procedure EndMenuBar; static; inline;
    class procedure EndPopup; static; inline;
    class procedure EndTabBar; static; inline;
    class procedure EndTabItem; static; inline;
    class procedure EndTable; static; inline;
    class procedure EndTooltip; static; inline;
    class function FindViewportByID(const AId: TImGuiID): PImGuiViewport; static; inline;
    class function FindViewportByPlatformHandle(const APlatformHandle: Pointer): PImGuiViewport; static; inline;
    class procedure GetAllocatorFunctions(const APAllocFunc: PImGuiMemAllocFunc; const APFreeFunc: PImGuiMemFreeFunc; const APUserData: PPointer); static; inline;
    class function GetBackgroundDrawList: PImDrawList; overload; static; inline;
    class function GetBackgroundDrawList(const AViewport: PImGuiViewport): PImDrawList; overload; static; inline;
    class function GetClipboardText: String; static; inline;
    class function GetColorU32(const AIdx: TImGuiCol; const AAlphaMul: Single = 1.0): UInt32; overload; static; inline;
    class function GetColorU32(const ACol: TAlphaColorF): UInt32; overload; static; inline;
    class function GetColorU32(const ACol: UInt32): UInt32; overload; static; inline;
    class function GetColumnIndex: Integer; static; inline;
    class function GetColumnOffset(const AColumnIndex: Integer = -1): Single; static; inline;
    class function GetColumnWidth(const AColumnIndex: Integer = -1): Single; static; inline;
    class function GetColumnsCount: Integer; static; inline;
    class function GetContentRegionAvail: TVector2; static; inline;
    class function GetContentRegionMax: TVector2; static; inline;
    class function GetCurrentContext: PImGuiContext; static; inline;
    class function GetCursorPos: TVector2; static; inline;
    class function GetCursorPosX: Single; static; inline;
    class function GetCursorPosY: Single; static; inline;
    class function GetCursorScreenPos: TVector2; static; inline;
    class function GetCursorStartPos: TVector2; static; inline;
    class function GetDragDropPayload: PImGuiPayload; static; inline;
    class function GetDrawData: PImDrawData; static; inline;
    class function GetDrawListSharedData: PImDrawListSharedData; static; inline;
    class function GetFont: PImFont; static; inline;
    class function GetFontSize: Single; static; inline;
    class function GetFontTexUvWhitePixel: TVector2; static; inline;
    class function GetFrameCount: Integer; static; inline;
    class function GetFrameHeight: Single; static; inline;
    class function GetFrameHeightWithSpacing: Single; static; inline;
    class function GetID(const AStrId: PUTF8Char): TImGuiID; overload; static; inline;
    class function GetID(const AStrIdBegin: PUTF8Char; const AStrIdEnd: PUTF8Char): TImGuiID; overload; static; inline;
    class function GetID(const APtrId: Pointer): TImGuiID; overload; static; inline;
    class function GetIO: PImGuiIO; static; inline;
    class function GetItemRectMax: TVector2; static; inline;
    class function GetItemRectMin: TVector2; static; inline;
    class function GetItemRectSize: TVector2; static; inline;
    class function GetKeyIndex(const AKey: TImGuiKey): Integer; static; inline;
    class function GetKeyName(const AKey: TImGuiKey): String; static; inline;
    class function GetKeyPressedAmount(const AKey: TImGuiKey; const ARepeatDelay: Single; const ARate: Single): Integer; static; inline;
    class function GetMainViewport: PImGuiViewport; static; inline;
    class function GetMouseClickedCount(const AButton: TImGuiMouseButton): Integer; static; inline;
    class function GetMouseCursor: TImGuiMouseCursor; static; inline;
    class function GetMouseDragDelta(const AButton: TImGuiMouseButton = TImGuiMouseButton(0); const ALockThreshold: Single = -1.0): TVector2; static; inline;
    class function GetMousePos: TVector2; static; inline;
    class function GetMousePosOnOpeningCurrentPopup: TVector2; static; inline;
    class function GetPlatformIO: PImGuiPlatformIO; static; inline;
    class function GetScrollMaxX: Single; static; inline;
    class function GetScrollMaxY: Single; static; inline;
    class function GetScrollX: Single; static; inline;
    class function GetScrollY: Single; static; inline;
    class function GetStateStorage: PImGuiStorage; static; inline;
    class function GetStyle: PImGuiStyle; static; inline;
    class function GetStyleColorName(const AIdx: TImGuiCol): String; static; inline;
    class function GetStyleColor(const AIdx: TImGuiCol): PAlphaColorF; static; inline;
    class function GetTextLineHeight: Single; static; inline;
    class function GetTextLineHeightWithSpacing: Single; static; inline;
    class function GetTime: Double; static; inline;
    class function GetTreeNodeToLabelSpacing: Single; static; inline;
    class function GetVersion: String; static; inline;
    class function GetWindowContentRegionMax: TVector2; static; inline;
    class function GetWindowContentRegionMin: TVector2; static; inline;
    class function GetWindowDockID: TImGuiID; static; inline;
    class function GetWindowDpiScale: Single; static; inline;
    class function GetWindowDrawList: PImDrawList; static; inline;
    class function GetWindowHeight: Single; static; inline;
    class function GetWindowPos: TVector2; static; inline;
    class function GetWindowSize: TVector2; static; inline;
    class function GetWindowViewport: PImGuiViewport; static; inline;
    class function GetWindowWidth: Single; static; inline;
    class procedure Image(const AUserTextureId: TImTextureID; const ASize: TVector2; const AUv0: TVector2; const AUv1: TVector2; const ATintCol: TAlphaColorF; const ABorderCol: TAlphaColorF); overload; static; inline;
    class procedure Image(const AUserTextureId: TImTextureID; const ASize: TVector2; const AUv0: TVector2; const AUv1: TVector2); overload; static; inline;
    class procedure Image(const AUserTextureId: TImTextureID; const ASize: TVector2; const ATintCol: TAlphaColorF; const ABorderCol: TAlphaColorF); overload; static; inline;
    class procedure Image(const AUserTextureId: TImTextureID; const ASize: TVector2); overload; static; inline;
    class function ImageButton(const AUserTextureId: TImTextureID; const ASize: TVector2; const AUv0: TVector2; const AUv1: TVector2; const AFramePadding: Integer; const ABgCol: TAlphaColorF; const ATintCol: TAlphaColorF): Boolean; overload; static; inline;
    class function ImageButton(const AUserTextureId: TImTextureID; const ASize: TVector2; const AUv0: TVector2; const AUv1: TVector2; const AFramePadding: Integer = -1): Boolean; overload; static; inline;
    class function ImageButton(const AUserTextureId: TImTextureID; const ASize: TVector2; const ABgCol: TAlphaColorF; const ATintCol: TAlphaColorF; const AFramePadding: Integer = -1): Boolean; overload; static; inline;
    class function ImageButton(const AUserTextureId: TImTextureID; const ASize: TVector2; const AFramePadding: Integer = -1): Boolean; overload; static; inline;
    class procedure Indent(const AIndentW: Single = 0.0); static; inline;
    class function InputDouble(const ALabel: PUTF8Char; var AV: Double; const AStep: Double = 0.0; const AStepFast: Double = 0.0; const AFormat: PUTF8Char = nil; const AFlags: TImGuiInputTextFlags = []): Boolean; static; inline;
    class function InputFloat(const ALabel: PUTF8Char; var AV: Single; const AStep: Single = 0.0; const AStepFast: Single = 0.0; const AFormat: PUTF8Char = nil; const AFlags: TImGuiInputTextFlags = []): Boolean; static; inline;
    class function InputFloat2(const ALabel: PUTF8Char; var AV: Single; const AFormat: PUTF8Char = nil; const AFlags: TImGuiInputTextFlags = []): Boolean; static; inline;
    class function InputFloat3(const ALabel: PUTF8Char; var AV: Single; const AFormat: PUTF8Char = nil; const AFlags: TImGuiInputTextFlags = []): Boolean; static; inline;
    class function InputFloat4(const ALabel: PUTF8Char; var AV: Single; const AFormat: PUTF8Char = nil; const AFlags: TImGuiInputTextFlags = []): Boolean; static; inline;
    class function InputInt(const ALabel: PUTF8Char; var AV: Integer; const AStep: Integer = 1; const AStepFast: Integer = 100; const AFlags: TImGuiInputTextFlags = []): Boolean; static; inline;
    class function InputInt2(const ALabel: PUTF8Char; var AV: Integer; const AFlags: TImGuiInputTextFlags = []): Boolean; static; inline;
    class function InputInt3(const ALabel: PUTF8Char; var AV: Integer; const AFlags: TImGuiInputTextFlags = []): Boolean; static; inline;
    class function InputInt4(const ALabel: PUTF8Char; var AV: Integer; const AFlags: TImGuiInputTextFlags = []): Boolean; static; inline;
    class function InputScalar(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; const APData: Pointer; const APStep: Pointer = nil; const APStepFast: Pointer = nil; const AFormat: PUTF8Char = nil; const AFlags: TImGuiInputTextFlags = []): Boolean; static; inline;
    class function InputScalarN(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; const APData: Pointer; const AComponents: Integer; const APStep: Pointer = nil; const APStepFast: Pointer = nil; const AFormat: PUTF8Char = nil; const AFlags: TImGuiInputTextFlags = []): Boolean; static; inline;
    class function InputText(const ALabel: PUTF8Char; const AText: TImGuiText; const AFlags: TImGuiInputTextFlags = []): Boolean; static; inline;
    class function InputTextMultiline(const ALabel: PUTF8Char; const AText: TImGuiText; const ASize: TVector2; const AFlags: TImGuiInputTextFlags = []): Boolean; overload; static; inline;
    class function InputTextMultiline(const ALabel: PUTF8Char; const AText: TImGuiText; const AFlags: TImGuiInputTextFlags = []): Boolean; overload; static; inline;
    class function InputTextWithHint(const ALabel: PUTF8Char; const AHint: PUTF8Char; const AText: TImGuiText; const AFlags: TImGuiInputTextFlags = []): Boolean; static; inline;
    class function InvisibleButton(const AStrId: PUTF8Char; const ASize: TVector2; const AFlags: TImGuiButtonFlags = []): Boolean; static; inline;
    class function IsAnyItemActive: Boolean; static; inline;
    class function IsAnyItemFocused: Boolean; static; inline;
    class function IsAnyItemHovered: Boolean; static; inline;
    class function IsAnyMouseDown: Boolean; static; inline;
    class function IsItemActivated: Boolean; static; inline;
    class function IsItemActive: Boolean; static; inline;
    class function IsItemClicked(const AMouseButton: TImGuiMouseButton = TImGuiMouseButton(0)): Boolean; static; inline;
    class function IsItemDeactivated: Boolean; static; inline;
    class function IsItemDeactivatedAfterEdit: Boolean; static; inline;
    class function IsItemEdited: Boolean; static; inline;
    class function IsItemFocused: Boolean; static; inline;
    class function IsItemHovered(const AFlags: TImGuiHoveredFlags = []): Boolean; static; inline;
    class function IsItemToggledOpen: Boolean; static; inline;
    class function IsItemVisible: Boolean; static; inline;
    class function IsKeyDown(const AKey: TImGuiKey): Boolean; static; inline;
    class function IsKeyPressed(const AKey: TImGuiKey; const ARepeat: Boolean = True): Boolean; static; inline;
    class function IsKeyReleased(const AKey: TImGuiKey): Boolean; static; inline;
    class function IsMouseClicked(const AButton: TImGuiMouseButton; const ARepeat: Boolean = False): Boolean; static; inline;
    class function IsMouseDoubleClicked(const AButton: TImGuiMouseButton): Boolean; static; inline;
    class function IsMouseDown(const AButton: TImGuiMouseButton): Boolean; static; inline;
    class function IsMouseDragging(const AButton: TImGuiMouseButton; const ALockThreshold: Single = -1.0): Boolean; static; inline;
    class function IsMouseHoveringRect(const ARMin: TVector2; const ARMax: TVector2; const AClip: Boolean = True): Boolean; static; inline;
    class function IsMousePosValid(const AMousePos: PVector2 = nil): Boolean; static; inline;
    class function IsMouseReleased(const AButton: TImGuiMouseButton): Boolean; static; inline;
    class function IsRectVisible(const ASize: TVector2): Boolean; overload; static; inline;
    class function IsRectVisible(const ARectMin: TVector2; const ARectMax: TVector2): Boolean; overload; static; inline;
    class function IsWindowAppearing: Boolean; static; inline;
    class function IsWindowCollapsed: Boolean; static; inline;
    class function IsWindowDocked: Boolean; static; inline;
    class function IsWindowFocused(const AFlags: TImGuiFocusedFlags = []): Boolean; static; inline;
    class function IsWindowHovered(const AFlags: TImGuiHoveredFlags = []): Boolean; static; inline;
    class procedure LabelText(const ALabel: PUTF8Char; const AText: PUTF8Char); static; inline;
    class function ListBox(const ALabel: PUTF8Char; var ACurrentItem: Integer; const AItems: PPUTF8Char; const AItemsCount: Integer; const AHeightInItems: Integer = -1): Boolean; overload; static; inline;
    class function ListBox(const ALabel: PUTF8Char; var ACurrentItem: Integer; const AItemsGetter: TImGuiItemsGetter; const AData: Pointer; const AItemsCount: Integer; const AHeightInItems: Integer = -1): Boolean; overload; static; inline;
    class procedure LoadIniSettingsFromDisk(const AIniFilename: PUTF8Char); static; inline;
    class procedure LoadIniSettingsFromMemory(const AIniData: PUTF8Char; const AIniSize: NativeUInt = 0); static; inline;
    class procedure LogButtons; static; inline;
    class procedure LogFinish; static; inline;
    class procedure LogText(const AText: PUTF8Char); static; inline;
    class procedure LogToClipboard(const AAutoOpenDepth: Integer = -1); static; inline;
    class procedure LogToFile(const AAutoOpenDepth: Integer = -1; const AFilename: PUTF8Char = nil); static; inline;
    class procedure LogToTTY(const AAutoOpenDepth: Integer = -1); static; inline;
    class function MemAlloc(const ASize: NativeUInt): Pointer; static; inline;
    class procedure MemFree(const APtr: Pointer); static; inline;
    class function MenuItem(const ALabel: PUTF8Char; const AShortcut: PUTF8Char = nil; const ASelected: Boolean = False; const AEnabled: Boolean = True): Boolean; overload; static; inline;
    class function MenuItem(const ALabel: PUTF8Char; const AShortcut: PUTF8Char; const APSelected: PBoolean; const AEnabled: Boolean = True): Boolean; overload; static; inline;
    class procedure NewFrame; static; inline;
    class procedure NewLine; static; inline;
    class procedure NextColumn; static; inline;
    class procedure OpenPopup(const AStrId: PUTF8Char; const APopupFlags: TImGuiPopupFlags = []); overload; static; inline;
    class procedure OpenPopup(const AId: TImGuiID; const APopupFlags: TImGuiPopupFlags = []); overload; static; inline;
    class procedure OpenPopupOnItemClick(const AStrId: PUTF8Char = nil; const APopupFlags: TImGuiPopupFlags = [TImGuiPopupFlag.MouseButtonRight]); static; inline;
    class procedure PlotHistogram(const ALabel: PUTF8Char; const AValues: PSingle; const AValuesCount: Integer; const AValuesOffset: Integer; const AOverlayText: PUTF8Char; const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2; const AStride: Integer = SizeOf(Single)); overload; static; inline;
    class procedure PlotHistogram(const ALabel: PUTF8Char; const AValues: PSingle; const AValuesCount: Integer; const AValuesOffset: Integer = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle; const AStride: Integer = SizeOf(Single)); overload; static; inline;
    class procedure PlotHistogram(const ALabel: PUTF8Char; const AValues: TArray<Single>; const AValuesOffset: Integer; const AOverlayText: PUTF8Char; const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2; const AStride: Integer = SizeOf(Single)); overload; static; inline;
    class procedure PlotHistogram(const ALabel: PUTF8Char; const AValues: TArray<Single>; const AValuesOffset: Integer = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle; const AStride: Integer = SizeOf(Single)); overload; static; inline;
    class procedure PlotHistogram(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValuesGetter; const AData: Pointer; const AValuesCount: Integer; const AValuesOffset: Integer; const AOverlayText: PUTF8Char; const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2); overload; static; inline;
    class procedure PlotHistogram(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValuesGetter; const AData: Pointer; const AValuesCount: Integer; const AValuesOffset: Integer = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle); overload; static; inline;
    class procedure PlotLines(const ALabel: PUTF8Char; const AValues: PSingle; const AValuesCount: Integer; const AValuesOffset: Integer; const AOverlayText: PUTF8Char; const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2; const AStride: Integer = SizeOf(Single)); overload; static; inline;
    class procedure PlotLines(const ALabel: PUTF8Char; const AValues: PSingle; const AValuesCount: Integer; const AValuesOffset: Integer = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle; const AStride: Integer = SizeOf(Single)); overload; static; inline;
    class procedure PlotLines(const ALabel: PUTF8Char; const AValues: TArray<Single>; const AValuesOffset: Integer; const AOverlayText: PUTF8Char; const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2; const AStride: Integer = SizeOf(Single)); overload; static; inline;
    class procedure PlotLines(const ALabel: PUTF8Char; const AValues: TArray<Single>; const AValuesOffset: Integer = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle; const AStride: Integer = SizeOf(Single)); overload; static; inline;
    class procedure PlotLines(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValuesGetter; const AData: Pointer; const AValuesCount: Integer; const AValuesOffset: Integer; const AOverlayText: PUTF8Char; const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2); overload; static; inline;
    class procedure PlotLines(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValuesGetter; const AData: Pointer; const AValuesCount: Integer; const AValuesOffset: Integer = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle); overload; static; inline;
    class procedure PopAllowKeyboardFocus; static; inline;
    class procedure PopButtonRepeat; static; inline;
    class procedure PopClipRect; static; inline;
    class procedure PopFont; static; inline;
    class procedure PopID; static; inline;
    class procedure PopItemWidth; static; inline;
    class procedure PopStyleColor(const ACount: Integer = 1); static; inline;
    class procedure PopStyleVar(const ACount: Integer = 1); static; inline;
    class procedure PopTextWrapPos; static; inline;
    class procedure ProgressBar(const AFraction: Single; const ASizeArg: TVector2; const AOverlay: PUTF8Char = nil); overload; static; inline;
    class procedure ProgressBar(const AFraction: Single; const AOverlay: PUTF8Char = nil); overload; static; inline;
    class procedure PushAllowKeyboardFocus(const AAllowKeyboardFocus: Boolean); static; inline;
    class procedure PushButtonRepeat(const ARepeat: Boolean); static; inline;
    class procedure PushClipRect(const AClipRectMin: TVector2; const AClipRectMax: TVector2; const AIntersectWithCurrentClipRect: Boolean); static; inline;
    class procedure PushFont(const AFont: PImFont); static; inline;
    class procedure PushID(const AStrId: PUTF8Char); overload; static; inline;
    class procedure PushID(const AStrIdBegin: PUTF8Char; const AStrIdEnd: PUTF8Char); overload; static; inline;
    class procedure PushID(const APtrId: Pointer); overload; static; inline;
    class procedure PushID(const AIntId: Integer); overload; static; inline;
    class procedure PushItemWidth(const AItemWidth: Single); static; inline;
    class procedure PushStyleColor(const AIdx: TImGuiCol; const ACol: UInt32); overload; static; inline;
    class procedure PushStyleColor(const AIdx: TImGuiCol; const ACol: TAlphaColorF); overload; static; inline;
    class procedure PushStyleVar(const AIdx: TImGuiStyleVar; const AVal: Single); overload; static; inline;
    class procedure PushStyleVar(const AIdx: TImGuiStyleVar; const AVal: TVector2); overload; static; inline;
    class procedure PushTextWrapPos(const AWrapLocalPosX: Single = 0.0); static; inline;
    class function RadioButton(const ALabel: PUTF8Char; const AActive: Boolean): Boolean; overload; static; inline;
    class function RadioButton(const ALabel: PUTF8Char; var AV: Integer; const AVButton: Integer): Boolean; overload; static; inline;
    class procedure Render; static; inline;
    class procedure RenderPlatformWindowsDefault(const APlatformRenderArg: Pointer = nil; const ARendererRenderArg: Pointer = nil); static; inline;
    class procedure ResetMouseDragDelta(const AButton: TImGuiMouseButton = TImGuiMouseButton(0)); static; inline;
    class procedure SameLine(const AOffsetFromStartX: Single = 0.0; const ASpacing: Single = -1.0); static; inline;
    class procedure SaveIniSettingsToDisk(const AIniFilename: PUTF8Char); static; inline;
    class function SaveIniSettingsToMemory(const AOutIniSize: PNativeUInt = nil): String; static; inline;
    class function Selectable(const ALabel: PUTF8Char; const ASelected: Boolean; const AFlags: TImGuiSelectableFlags; const ASize: TVector2): Boolean; overload; static; inline;
    class function Selectable(const ALabel: PUTF8Char; const ASelected: Boolean = False; const AFlags: TImGuiSelectableFlags = []): Boolean; overload; static; inline;
    class function Selectable(const ALabel: PUTF8Char; const APSelected: PBoolean; const AFlags: TImGuiSelectableFlags; const ASize: TVector2): Boolean; overload; static; inline;
    class function Selectable(const ALabel: PUTF8Char; const APSelected: PBoolean; const AFlags: TImGuiSelectableFlags = []): Boolean; overload; static; inline;
    class procedure Separator; static; inline;
    class procedure SetAllocatorFunctions(const AAllocFunc: TImGuiMemAllocFunc; const AFreeFunc: TImGuiMemFreeFunc; const AUserData: Pointer = nil); static; inline;
    class procedure SetClipboardText(const AText: PUTF8Char); static; inline;
    class procedure SetColorEditOptions(const AFlags: TImGuiColorEditFlags); static; inline;
    class procedure SetColumnOffset(const AColumnIndex: Integer; const AOffsetX: Single); static; inline;
    class procedure SetColumnWidth(const AColumnIndex: Integer; const AWidth: Single); static; inline;
    class procedure SetCurrentContext(const ACtx: PImGuiContext); static; inline;
    class procedure SetCursorPos(const ALocalPos: TVector2); static; inline;
    class procedure SetCursorPosX(const ALocalX: Single); static; inline;
    class procedure SetCursorPosY(const ALocalY: Single); static; inline;
    class procedure SetCursorScreenPos(const APos: TVector2); static; inline;
    class function SetDragDropPayload(const AType: PUTF8Char; const AData: Pointer; const ASz: NativeUInt; const ACond: TImGuiCond = TImGuiCond(0)): Boolean; static; inline;
    class procedure SetItemAllowOverlap; static; inline;
    class procedure SetItemDefaultFocus; static; inline;
    class procedure SetKeyboardFocusHere(const AOffset: Integer = 0); static; inline;
    class procedure SetMouseCursor(const ACursorType: TImGuiMouseCursor); static; inline;
    class procedure SetNextFrameWantCaptureKeyboard(const AWantCaptureKeyboard: Boolean); static; inline;
    class procedure SetNextFrameWantCaptureMouse(const AWantCaptureMouse: Boolean); static; inline;
    class procedure SetNextItemOpen(const AIsOpen: Boolean; const ACond: TImGuiCond = TImGuiCond(0)); static; inline;
    class procedure SetNextItemWidth(const AItemWidth: Single); static; inline;
    class procedure SetNextWindowBgAlpha(const AAlpha: Single); static; inline;
    class procedure SetNextWindowClass(const AWindowClass: PImGuiWindowClass); static; inline;
    class procedure SetNextWindowCollapsed(const ACollapsed: Boolean; const ACond: TImGuiCond = TImGuiCond(0)); static; inline;
    class procedure SetNextWindowContentSize(const ASize: TVector2); static; inline;
    class procedure SetNextWindowDockID(const ADockId: TImGuiID; const ACond: TImGuiCond = TImGuiCond(0)); static; inline;
    class procedure SetNextWindowFocus; static; inline;
    class procedure SetNextWindowPos(const APos: TVector2; const ACond: TImGuiCond; const APivot: TVector2); overload; static; inline;
    class procedure SetNextWindowPos(const APos: TVector2; const ACond: TImGuiCond = TImGuiCond.None); overload; static; inline;
    class procedure SetNextWindowSize(const ASize: TVector2; const ACond: TImGuiCond = TImGuiCond(0)); static; inline;
    class procedure SetNextWindowSizeConstraints(const ASizeMin: TVector2; const ASizeMax: TVector2; const ACustomCallback: TImGuiSizeCallback = nil; const ACustomCallbackData: Pointer = nil); static; inline;
    class procedure SetNextWindowViewport(const AViewportId: TImGuiID); static; inline;
    class procedure SetScrollHereX(const ACenterXRatio: Single = 0.5); static; inline;
    class procedure SetScrollHereY(const ACenterYRatio: Single = 0.5); static; inline;
    class procedure SetStateStorage(const AStorage: PImGuiStorage); static; inline;
    class procedure SetTabItemClosed(const ATabOrDockedWindowLabel: PUTF8Char); static; inline;
    class procedure SetTooltip(const AText: PUTF8Char); static; inline;
    class procedure SetTooltipV(const AText: PUTF8Char; const AArgs: Pointer); static; inline;
    class procedure SetWindowFocus; overload; static; inline;
    class procedure SetWindowFocus(const AName: PUTF8Char); overload; static; inline;
    class procedure SetWindowFontScale(const AScale: Single); static; inline;
    class procedure ShowAboutWindow(const APOpen: PBoolean = nil); static; inline;
    class procedure ShowDebugLogWindow(const APOpen: PBoolean = nil); static; inline;
    class procedure ShowDemoWindow(const APOpen: PBoolean = nil); static; inline;
    class procedure ShowFontSelector(const ALabel: PUTF8Char); static; inline;
    class procedure ShowMetricsWindow(const APOpen: PBoolean = nil); static; inline;
    class procedure ShowStackToolWindow(const APOpen: PBoolean = nil); static; inline;
    class procedure ShowStyleEditor(const ARef: PImGuiStyle = nil); static; inline;
    class function ShowStyleSelector(const ALabel: PUTF8Char): Boolean; static; inline;
    class procedure ShowUserGuide; static; inline;
    class function SliderAngle(const ALabel: PUTF8Char; var AVRad: Single; const AVDegreesMin: Single = -360.0; const AVDegreesMax: Single = +360.0; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function SliderFloat(const ALabel: PUTF8Char; var AV: Single; const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function SliderFloat2(const ALabel: PUTF8Char; var AV: Single; const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function SliderFloat3(const ALabel: PUTF8Char; var AV: Single; const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function SliderFloat4(const ALabel: PUTF8Char; var AV: Single; const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function SliderInt(const ALabel: PUTF8Char; var AV: Integer; const AVMin: Integer; const AVMax: Integer; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function SliderInt2(const ALabel: PUTF8Char; var AV: Integer; const AVMin: Integer; const AVMax: Integer; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function SliderInt3(const ALabel: PUTF8Char; var AV: Integer; const AVMin: Integer; const AVMax: Integer; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function SliderInt4(const ALabel: PUTF8Char; var AV: Integer; const AVMin: Integer; const AVMax: Integer; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function SliderScalar(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; const APData: Pointer; const APMin: Pointer; const APMax: Pointer; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function SliderScalarN(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; const APData: Pointer; const AComponents: Integer; const APMin: Pointer; const APMax: Pointer; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function SmallButton(const ALabel: PUTF8Char): Boolean; static; inline;
    class procedure Spacing; static; inline;
    class procedure StyleColorsClassic(const ADst: PImGuiStyle = nil); static; inline;
    class procedure StyleColorsDark(const ADst: PImGuiStyle = nil); static; inline;
    class procedure StyleColorsLight(const ADst: PImGuiStyle = nil); static; inline;
    class function TabItemButton(const ALabel: PUTF8Char; const AFlags: TImGuiTabItemFlags = []): Boolean; static; inline;
    class function TableGetColumnCount: Integer; static; inline;
    class function TableGetColumnFlags(const AColumnN: Integer = -1): TImGuiTableColumnFlags; static; inline;
    class function TableGetColumnIndex: Integer; static; inline;
    class function TableGetRowIndex: Integer; static; inline;
    class function TableGetSortSpecs: PImGuiTableSortSpecs; static; inline;
    class procedure TableHeader(const ALabel: PUTF8Char); static; inline;
    class procedure TableHeadersRow; static; inline;
    class function TableNextColumn: Boolean; static; inline;
    class procedure TableNextRow(const ARowFlags: TImGuiTableRowFlags = []; const AMinRowHeight: Single = 0.0); static; inline;
    class procedure TableSetBgColor(const ATarget: TImGuiTableBgTarget; const AColor: UInt32; const AColumnN: Integer = -1); static; inline;
    class procedure TableSetColumnEnabled(const AColumnN: Integer; const AV: Boolean); static; inline;
    class function TableSetColumnIndex(const AColumnN: Integer): Boolean; static; inline;
    class procedure TableSetupColumn(const ALabel: PUTF8Char; const AFlags: TImGuiTableColumnFlags = []; const AInitWidthOrWeight: Single = 0.0; const AUserId: TImGuiID = TImGuiID(0)); static; inline;
    class procedure TableSetupScrollFreeze(const ACols: Integer; const ARows: Integer); static; inline;
    class procedure Text(const AText: PUTF8Char); static; inline;
    class procedure TextColored(const ACol: TAlphaColorF; const AText: PUTF8Char); static; inline;
    class procedure TextColoredV(const ACol: TAlphaColorF; const AText: PUTF8Char; const AArgs: Pointer); static; inline;
    class procedure TextDisabled(const AText: PUTF8Char); static; inline;
    class procedure TextDisabledV(const AText: PUTF8Char; const AArgs: Pointer); static; inline;
    class procedure TextUnformatted(const AText: PUTF8Char; const ATextEnd: PUTF8Char = nil); static; inline;
    class procedure TextWrapped(const AText: PUTF8Char); static; inline;
    class function TreeNode(const ALabel: PUTF8Char): Boolean; overload; static; inline;
    class function TreeNode(const AStrId: PUTF8Char; const AText: PUTF8Char): Boolean; overload; static; inline;
    class function TreeNode(const APtrId: Pointer; const AText: PUTF8Char): Boolean; overload; static; inline;
    class function TreeNodeEx(const ALabel: PUTF8Char; const AFlags: TImGuiTreeNodeFlags = []): Boolean; overload; static; inline;
    class function TreeNodeEx(const AStrId: PUTF8Char; const AFlags: TImGuiTreeNodeFlags; const AText: PUTF8Char): Boolean; overload; static; inline;
    class function TreeNodeEx(const APtrId: Pointer; const AFlags: TImGuiTreeNodeFlags; const AText: PUTF8Char): Boolean; overload; static; inline;
    class function TreeNodeExV(const AStrId: PUTF8Char; const AFlags: TImGuiTreeNodeFlags; const AText: PUTF8Char; const AArgs: Pointer): Boolean; overload; static; inline;
    class function TreeNodeExV(const APtrId: Pointer; const AFlags: TImGuiTreeNodeFlags; const AText: PUTF8Char; const AArgs: Pointer): Boolean; overload; static; inline;
    class function TreeNodeV(const AStrId: PUTF8Char; const AText: PUTF8Char; const AArgs: Pointer): Boolean; overload; static; inline;
    class function TreeNodeV(const APtrId: Pointer; const AText: PUTF8Char; const AArgs: Pointer): Boolean; overload; static; inline;
    class procedure TreePop; static; inline;
    class procedure TreePush(const AStrId: PUTF8Char); overload; static; inline;
    class procedure TreePush(const APtrId: Pointer = nil); overload; static; inline;
    class procedure Unindent(const AIndentW: Single = 0.0); static; inline;
    class procedure UpdatePlatformWindows; static; inline;
    class function VSliderFloat(const ALabel: PUTF8Char; const ASize: TVector2; var AV: Single; const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function VSliderInt(const ALabel: PUTF8Char; const ASize: TVector2; var AV: Integer; const AVMin: Integer; const AVMax: Integer; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class function VSliderScalar(const ALabel: PUTF8Char; const ASize: TVector2; const ADataType: TImGuiDataType; const APData: Pointer; const APMin: Pointer; const APMax: Pointer; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; static; inline;
    class procedure Value(const APrefix: PUTF8Char; const AB: Boolean); overload; static; inline;
    class procedure Value(const APrefix: PUTF8Char; const AV: Integer); overload; static; inline;
    class procedure Value(const APrefix: PUTF8Char; const AV: Cardinal); overload; static; inline;
    class procedure Value(const APrefix: PUTF8Char; const AV: Single; const AFloatFormat: PUTF8Char = nil); overload; static; inline;
  end;

type
  { Shorter alias for the ImGui "namespace" }
  ig = ImGui;

type
  { Helper for fast conversion from Delphi Unicode Strings to PUTF8Char. 
    This is *not* thread-safe! }
  _ImGuiHelper = record helper for ImGui
  private class var
    FUtf8Buf: TArray<UTF8Char>;
  public
    class function ToUtf8(const AStr: String): PUTF8Char; static;
    class function Format(const AFmt: String; const AArgs: array of const): PUTF8Char; static;
  end;
  
function __ImGuiInputTextCallback(AData: _PImGuiInputTextCallbackData): Integer; cdecl;

implementation

uses 
  System.SysUtils;

{ TImVector<T> }

function TImVector<T>.GetItem(const AIndex: Integer): T;
begin
  Assert((AIndex >= 0) and (AIndex < FSize));
  Result := P(FData)[AIndex];
end;

function TImVector<T>.GetItemPtr(const AIndex: Integer): Pointer;
begin
  Assert((AIndex >= 0) and (AIndex < FSize));
  Result := @P(FData)[AIndex];
end;

{ _ImGuiHelper }

class function _ImGuiHelper.Format(const AFmt: String;
  const AArgs: array of const): PUTF8Char;
begin
  Result := ToUtf8(System.SysUtils.Format(AFmt, AArgs));
end;

class function _ImGuiHelper.ToUtf8(const AStr: String): PUTF8Char;
begin
  {$POINTERMATH ON}
  var SrcLength := Length(AStr);
  var BufSize := (SrcLength + 1) * 3;
  if (BufSize > Length(FUtf8Buf)) then
    SetLength(FUtf8Buf, BufSize);

  var S := PWord(AStr);
  var D := PByte(FUtf8Buf);
  var Codepoint: UInt32;

  { Try to convert 2 wide characters at a time if possible. This speeds up the
    process if those 2 characters are both ASCII characters (U+0..U+7F). }
  while (SrcLength >= 2) do
  begin
    if ((PCardinal(S)^ and $FF80FF80) = 0) then
    begin
      { Common case: 2 ASCII characters in a row.
        00000000 0yyyyyyy 00000000 0xxxxxxx => 0yyyyyyy 0xxxxxxx }
      D[0] := S[0]; // 00000000 0yyyyyyy => 0yyyyyyy
      D[1] := S[1]; // 00000000 0xxxxxxx => 0xxxxxxx
      Inc(S, 2);
      Inc(D, 2);
      Dec(SrcLength, 2);
    end
    else
    begin
      Codepoint := S^;
      Inc(S);
      Dec(SrcLength);

      if (Codepoint < $80) then
      begin
        { ASCI character (U+0..U+7F).
          00000000 0xxxxxxx => 0xxxxxxx }
        D^ := Codepoint;
        Inc(D);
      end
      else if (Codepoint < $800) then
      begin
        { 2-byte sequence (U+80..U+7FF)
          00000yyy yyxxxxxx => 110yyyyy 10xxxxxx }
        D^ := (Codepoint shr 6) or $C0;   // 00000yyy yyxxxxxx => 110yyyyy
        Inc(D);
        D^ := (Codepoint and $3F) or $80; // 00000yyy yyxxxxxx => 10xxxxxx
        Inc(D);
      end
      else if (Codepoint >= $D800) and (Codepoint <= $DBFF) then
      begin
        { The codepoint is part of a UTF-16 surrogate pair:
            S[0]: 110110yy yyyyyyyy ($D800-$DBFF, high-surrogate)
            S[1]: 110111xx xxxxxxxx ($DC00-$DFFF, low-surrogate)

          Where the UCS4 codepoint value is:
            0000yyyy yyyyyyxx xxxxxxxx + $00010000 (U+10000..U+10FFFF)

          This can be calculated using:
            (((S[0] and $03FF) shl 10) or (S[1] and $03FF)) + $00010000

          However it can be calculated faster using:
            (S[0] shl 10) + S[1] - $035FDC00

          because:
            * S[0] shl 10: also shifts the leading 110110 to the left, making
              the result $D800 shl 10 = $03600000 too large
            * S[1] is                   $0000DC00 too large
            * So we need to subract     $0360DC00 (sum of the above)
            * But we need to add        $00010000
            * So in total, we subtract  $035FDC00 (difference of the above) }

        Codepoint := (Codepoint shl 10) + S^ - $035FDC00;
        Inc(S);
        Dec(SrcLength);

        { The resulting codepoint is encoded as a 4-byte UTF-8 sequence:

          000uuuuu zzzzyyyy yyxxxxxx => 11110uuu 10uuzzzz 10yyyyyy 10xxxxxx }

        Assert(Codepoint > $FFFF);
        D^ := (Codepoint shr 18) or $F0;           // 000uuuuu zzzzyyyy yyxxxxxx => 11110uuu
        Inc(D);
        D^ := ((Codepoint shr 12) and $3F) or $80; // 000uuuuu zzzzyyyy yyxxxxxx => 10uuzzzz
        Inc(D);
        D^ := ((Codepoint shr 6) and $3F) or $80;  // 000uuuuu zzzzyyyy yyxxxxxx => 10yyyyyy
        Inc(D);
        D^ := (Codepoint and $3F) or $80;          // 000uuuuu zzzzyyyy yyxxxxxx => 10xxxxxx
        Inc(D);
      end
      else
      begin
        { 3-byte sequence (U+800..U+FFFF, excluding U+D800..U+DFFF).
          zzzzyyyy yyxxxxxx => 1110zzzz 10yyyyyy 10xxxxxx }
        D^ := (Codepoint shr 12) or $E0;           // zzzzyyyy yyxxxxxx => 1110zzzz
        Inc(D);
        D^ := ((Codepoint shr 6) and $3F) or $80;  // zzzzyyyy yyxxxxxx => 10yyyyyy
        Inc(D);
        D^ := (Codepoint and $3F) or $80;          // zzzzyyyy yyxxxxxx => 10xxxxxx
        Inc(D);
      end;
    end;
  end;

  { We may have 1 wide character left to encode.
    Use the same process as above. }
  if (SrcLength <> 0) then
  begin
    Codepoint := S^;
    Inc(S);

    if (Codepoint < $80) then
    begin
      D^ := Codepoint;
      Inc(D);
    end
    else if (Codepoint < $800) then
    begin
      D^ := (Codepoint shr 6) or $C0;
      Inc(D);
      D^ := (Codepoint and $3F) or $80;
      Inc(D);
    end
    else if (Codepoint >= $D800) and (Codepoint <= $DBFF) then
    begin
      Codepoint := (Codepoint shl 10) + S^ - $35FDC00;

      Assert(Codepoint > $FFFF);
      D^ := (Codepoint shr 18) or $F0;
      Inc(D);
      D^ := ((Codepoint shr 12) and $3F) or $80;
      Inc(D);
      D^ := ((Codepoint shr 6) and $3F) or $80;
      Inc(D);
      D^ := (Codepoint and $3F) or $80;
      Inc(D);
    end
    else
    begin
      D^ := (Codepoint shr 12) or $E0;
      Inc(D);
      D^ := ((Codepoint shr 6) and $3F) or $80;
      Inc(D);
      D^ := (Codepoint and $3F) or $80;
      Inc(D);
    end;
  end;

  { Final null-terminator }
  D^ := 0;
  {$POINTERMATH OFF}

  Result := PUTF8Char(FUtf8Buf);
end;

{ TImGuiText }

function __ImGuiInputTextCallback(AData: _PImGuiInputTextCallbackData): Integer; cdecl;
begin
  if Assigned(AData) and Assigned(AData.UserData) then
    PImGuiText(AData.UserData).Update(AData);
    
  Result := 0;
end;

class operator TImGuiText.Implicit(const AText: TImGuiText): String;
begin
  Result := AText.ToString;
end;

procedure TImGuiText.Init(const AText: String);
begin
  var S := UTF8String(AText);
  var Len := Length(S);
  SetLength(FBuffer, Len + WORK_AREA);
  if (Len > 0) then
    Move(S[Low(UTF8String)], FBuffer[0], Len);
  FBuffer[Len] := #0;
end;

function TImGuiText.ToPUTF8Char: PUTF8Char;
begin
  Result := PUTF8Char(FBuffer);
end;

function TImGuiText.ToString: String;
begin
  Result := String(UTF8String(PUTF8Char(FBuffer)));
end;

function TImGuiText.ToUTF8String: UTF8String;
begin
  Result := UTF8String(FBuffer);
end;

procedure TImGuiText.Update(const AData: _PImGuiInputTextCallbackData);
begin
  if (AData.EventFlag = _ImGuiInputTextFlags_CallbackResize)
    and ((AData.BufTextLen + 2) > AData.BufSize) then
  begin
    SetLength(FBuffer, GrowCollection(Length(FBuffer), AData.BufTextLen + 1));
    AData.Buf := Pointer(FBuffer);
  end;
end;

procedure TImGuiText.Validate;
begin
  if (FBuffer = nil) then
    SetLength(FBuffer, WORK_AREA);
end;

class operator TImGuiText.Implicit(const AText: String): TImGuiText;
begin
  Result.Init(AText);
end;

{ TImDrawCmd }

class function TImDrawCmd.Create: PImDrawCmd;
begin
  Result := PImDrawCmd(_ImDrawCmd_ImDrawCmd());
end;

procedure TImDrawCmd.Free;
begin
  _ImDrawCmd_destroy(@Self);
end;

function TImDrawCmd.GetTexID: TImTextureID;
begin
  Result := TImTextureID(_ImDrawCmd_GetTexID(@Self));
end;

{ TImDrawData }

class function TImDrawData.Create: PImDrawData;
begin
  Result := PImDrawData(_ImDrawData_ImDrawData());
end;

procedure TImDrawData.Free;
begin
  _ImDrawData_destroy(@Self);
end;

procedure TImDrawData.Clear;
begin
  _ImDrawData_Clear(@Self);
end;

procedure TImDrawData.DeIndexAllBuffers;
begin
  _ImDrawData_DeIndexAllBuffers(@Self);
end;

procedure TImDrawData.ScaleClipRects(const AFbScale: TVector2);
begin
  _ImDrawData_ScaleClipRects(@Self, _ImVec2(AFbScale));
end;

{ TImDrawListSplitter }

class function TImDrawListSplitter.Create: PImDrawListSplitter;
begin
  Result := PImDrawListSplitter(_ImDrawListSplitter_ImDrawListSplitter());
end;

procedure TImDrawListSplitter.Free;
begin
  _ImDrawListSplitter_destroy(@Self);
end;

procedure TImDrawListSplitter.Clear;
begin
  _ImDrawListSplitter_Clear(@Self);
end;

procedure TImDrawListSplitter.ClearFreeMemory;
begin
  _ImDrawListSplitter_ClearFreeMemory(@Self);
end;

procedure TImDrawListSplitter.Merge(const ADrawList: PImDrawList);
begin
  _ImDrawListSplitter_Merge(@Self, Pointer(ADrawList));
end;

procedure TImDrawListSplitter.SetCurrentChannel(const ADrawList: PImDrawList; const AChannelIdx: Integer);
begin
  _ImDrawListSplitter_SetCurrentChannel(@Self, Pointer(ADrawList), AChannelIdx);
end;

procedure TImDrawListSplitter.Split(const ADrawList: PImDrawList; const ACount: Integer);
begin
  _ImDrawListSplitter_Split(@Self, Pointer(ADrawList), ACount);
end;

{ TImDrawList }

class function TImDrawList.Create(const ASharedData: PImDrawListSharedData): PImDrawList;
begin
  Result := PImDrawList(_ImDrawList_ImDrawList(Pointer(ASharedData)));
end;

procedure TImDrawList.Free;
begin
  _ImDrawList_destroy(@Self);
end;

procedure TImDrawList.AddBezierCubic(const AP1: TVector2; const AP2: TVector2; const AP3: TVector2; const AP4: TVector2; const ACol: UInt32; const AThickness: Single; const ANumSegments: Integer);
begin
  _ImDrawList_AddBezierCubic(@Self, _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImVec2(AP4), ACol, AThickness, ANumSegments);
end;

procedure TImDrawList.AddBezierQuadratic(const AP1: TVector2; const AP2: TVector2; const AP3: TVector2; const ACol: UInt32; const AThickness: Single; const ANumSegments: Integer);
begin
  _ImDrawList_AddBezierQuadratic(@Self, _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), ACol, AThickness, ANumSegments);
end;

procedure TImDrawList.AddCallback(const ACallback: TImDrawCallback; const ACallbackData: Pointer);
begin
  _ImDrawList_AddCallback(@Self, _ImDrawCallback(ACallback), Pointer(ACallbackData));
end;

procedure TImDrawList.AddCircle(const ACenter: TVector2; const ARadius: Single; const ACol: UInt32; const ANumSegments: Integer; const AThickness: Single);
begin
  _ImDrawList_AddCircle(@Self, _ImVec2(ACenter), ARadius, ACol, ANumSegments, AThickness);
end;

procedure TImDrawList.AddCircleFilled(const ACenter: TVector2; const ARadius: Single; const ACol: UInt32; const ANumSegments: Integer);
begin
  _ImDrawList_AddCircleFilled(@Self, _ImVec2(ACenter), ARadius, ACol, ANumSegments);
end;

procedure TImDrawList.AddConvexPolyFilled(const APoints: PVector2; const ANumPoints: Integer; const ACol: UInt32);
begin
  _ImDrawList_AddConvexPolyFilled(@Self, Pointer(APoints), ANumPoints, ACol);
end;

procedure TImDrawList.AddDrawCmd;
begin
  _ImDrawList_AddDrawCmd(@Self);
end;

procedure TImDrawList.AddImage(const AUserTextureId: TImTextureID; const APMin: TVector2; const APMax: TVector2; const AUvMin: TVector2; const AUvMax: TVector2; const ACol: UInt32);
begin
  _ImDrawList_AddImage(@Self, _ImTextureID(AUserTextureId), _ImVec2(APMin), _ImVec2(APMax), _ImVec2(AUvMin), _ImVec2(AUvMax), ACol);
end;

procedure TImDrawList.AddImage(const AUserTextureId: TImTextureID; const APMin: TVector2; const APMax: TVector2; const ACol: UInt32 = 4294967295);
begin
  _ImDrawList_AddImage(@Self, _ImTextureID(AUserTextureId), _ImVec2(APMin), _ImVec2(APMax), _ImVec2(TVector2.Zero), _ImVec2(TVector2.One), ACol);
end;

procedure TImDrawList.AddImageQuad(const AUserTextureId: TImTextureID; const AP1: TVector2; const AP2: TVector2; const AP3: TVector2; const AP4: TVector2; const AUv1: TVector2; const AUv2: TVector2; const AUv3: TVector2; const AUv4: TVector2; const ACol: UInt32);
begin
  _ImDrawList_AddImageQuad(@Self, _ImTextureID(AUserTextureId), _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImVec2(AP4), _ImVec2(AUv1), _ImVec2(AUv2), _ImVec2(AUv3), _ImVec2(AUv4), ACol);
end;

procedure TImDrawList.AddImageQuad(const AUserTextureId: TImTextureID; const AP1: TVector2; const AP2: TVector2; const AP3: TVector2; const AP4: TVector2; const ACol: UInt32 = 4294967295);
begin
  _ImDrawList_AddImageQuad(@Self, _ImTextureID(AUserTextureId), _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImVec2(AP4), _ImVec2(TVector2.Zero), _ImVec2(TVector2.UnitX), _ImVec2(TVector2.One), _ImVec2(TVector2.UnitY), ACol);
end;

procedure TImDrawList.AddImageRounded(const AUserTextureId: TImTextureID; const APMin: TVector2; const APMax: TVector2; const AUvMin: TVector2; const AUvMax: TVector2; const ACol: UInt32; const ARounding: Single; const AFlags: TImDrawFlags);
begin
  _ImDrawList_AddImageRounded(@Self, _ImTextureID(AUserTextureId), _ImVec2(APMin), _ImVec2(APMax), _ImVec2(AUvMin), _ImVec2(AUvMax), ACol, ARounding, Cardinal(AFlags));
end;

procedure TImDrawList.AddLine(const AP1: TVector2; const AP2: TVector2; const ACol: UInt32; const AThickness: Single);
begin
  _ImDrawList_AddLine(@Self, _ImVec2(AP1), _ImVec2(AP2), ACol, AThickness);
end;

procedure TImDrawList.AddNgon(const ACenter: TVector2; const ARadius: Single; const ACol: UInt32; const ANumSegments: Integer; const AThickness: Single);
begin
  _ImDrawList_AddNgon(@Self, _ImVec2(ACenter), ARadius, ACol, ANumSegments, AThickness);
end;

procedure TImDrawList.AddNgonFilled(const ACenter: TVector2; const ARadius: Single; const ACol: UInt32; const ANumSegments: Integer);
begin
  _ImDrawList_AddNgonFilled(@Self, _ImVec2(ACenter), ARadius, ACol, ANumSegments);
end;

procedure TImDrawList.AddPolyline(const APoints: PVector2; const ANumPoints: Integer; const ACol: UInt32; const AFlags: TImDrawFlags; const AThickness: Single);
begin
  _ImDrawList_AddPolyline(@Self, Pointer(APoints), ANumPoints, ACol, Cardinal(AFlags), AThickness);
end;

procedure TImDrawList.AddQuad(const AP1: TVector2; const AP2: TVector2; const AP3: TVector2; const AP4: TVector2; const ACol: UInt32; const AThickness: Single);
begin
  _ImDrawList_AddQuad(@Self, _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImVec2(AP4), ACol, AThickness);
end;

procedure TImDrawList.AddQuadFilled(const AP1: TVector2; const AP2: TVector2; const AP3: TVector2; const AP4: TVector2; const ACol: UInt32);
begin
  _ImDrawList_AddQuadFilled(@Self, _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImVec2(AP4), ACol);
end;

procedure TImDrawList.AddRect(const APMin: TVector2; const APMax: TVector2; const ACol: UInt32; const ARounding: Single; const AFlags: TImDrawFlags; const AThickness: Single);
begin
  _ImDrawList_AddRect(@Self, _ImVec2(APMin), _ImVec2(APMax), ACol, ARounding, Cardinal(AFlags), AThickness);
end;

procedure TImDrawList.AddRectFilled(const APMin: TVector2; const APMax: TVector2; const ACol: UInt32; const ARounding: Single; const AFlags: TImDrawFlags);
begin
  _ImDrawList_AddRectFilled(@Self, _ImVec2(APMin), _ImVec2(APMax), ACol, ARounding, Cardinal(AFlags));
end;

procedure TImDrawList.AddRectFilledMultiColor(const APMin: TVector2; const APMax: TVector2; const AColUprLeft: UInt32; const AColUprRight: UInt32; const AColBotRight: UInt32; const AColBotLeft: UInt32);
begin
  _ImDrawList_AddRectFilledMultiColor(@Self, _ImVec2(APMin), _ImVec2(APMax), AColUprLeft, AColUprRight, AColBotRight, AColBotLeft);
end;

procedure TImDrawList.AddText(const APos: TVector2; const ACol: UInt32; const ATextBegin: PUTF8Char; const ATextEnd: PUTF8Char);
begin
  _ImDrawList_AddText_Vec2(@Self, _ImVec2(APos), ACol, Pointer(ATextBegin), Pointer(ATextEnd));
end;

procedure TImDrawList.AddText(const AFont: PImFont; const AFontSize: Single; const APos: TVector2; const ACol: UInt32; const ATextBegin: PUTF8Char; const ATextEnd: PUTF8Char; const AWrapWidth: Single; const ACpuFineClipRect: PRectF);
begin
  _ImDrawList_AddText_FontPtr(@Self, Pointer(AFont), AFontSize, _ImVec2(APos), ACol, Pointer(ATextBegin), Pointer(ATextEnd), AWrapWidth, Pointer(ACpuFineClipRect));
end;

procedure TImDrawList.AddTriangle(const AP1: TVector2; const AP2: TVector2; const AP3: TVector2; const ACol: UInt32; const AThickness: Single);
begin
  _ImDrawList_AddTriangle(@Self, _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), ACol, AThickness);
end;

procedure TImDrawList.AddTriangleFilled(const AP1: TVector2; const AP2: TVector2; const AP3: TVector2; const ACol: UInt32);
begin
  _ImDrawList_AddTriangleFilled(@Self, _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), ACol);
end;

procedure TImDrawList.ChannelsMerge;
begin
  _ImDrawList_ChannelsMerge(@Self);
end;

procedure TImDrawList.ChannelsSetCurrent(const AN: Integer);
begin
  _ImDrawList_ChannelsSetCurrent(@Self, AN);
end;

procedure TImDrawList.ChannelsSplit(const ACount: Integer);
begin
  _ImDrawList_ChannelsSplit(@Self, ACount);
end;

function TImDrawList.CloneOutput: PImDrawList;
begin
  Result := Pointer(_ImDrawList_CloneOutput(@Self));
end;

function TImDrawList.GetClipRectMax: TVector2;
begin
  _ImDrawList_GetClipRectMax(@Result, @Self);
end;

function TImDrawList.GetClipRectMin: TVector2;
begin
  _ImDrawList_GetClipRectMin(@Result, @Self);
end;

procedure TImDrawList.PathArcTo(const ACenter: TVector2; const ARadius: Single; const AAMin: Single; const AAMax: Single; const ANumSegments: Integer);
begin
  _ImDrawList_PathArcTo(@Self, _ImVec2(ACenter), ARadius, AAMin, AAMax, ANumSegments);
end;

procedure TImDrawList.PathArcToFast(const ACenter: TVector2; const ARadius: Single; const AAMinOf12: Integer; const AAMaxOf12: Integer);
begin
  _ImDrawList_PathArcToFast(@Self, _ImVec2(ACenter), ARadius, AAMinOf12, AAMaxOf12);
end;

procedure TImDrawList.PathBezierCubicCurveTo(const AP2: TVector2; const AP3: TVector2; const AP4: TVector2; const ANumSegments: Integer);
begin
  _ImDrawList_PathBezierCubicCurveTo(@Self, _ImVec2(AP2), _ImVec2(AP3), _ImVec2(AP4), ANumSegments);
end;

procedure TImDrawList.PathBezierQuadraticCurveTo(const AP2: TVector2; const AP3: TVector2; const ANumSegments: Integer);
begin
  _ImDrawList_PathBezierQuadraticCurveTo(@Self, _ImVec2(AP2), _ImVec2(AP3), ANumSegments);
end;

procedure TImDrawList.PathClear;
begin
  _ImDrawList_PathClear(@Self);
end;

procedure TImDrawList.PathFillConvex(const ACol: UInt32);
begin
  _ImDrawList_PathFillConvex(@Self, ACol);
end;

procedure TImDrawList.PathLineTo(const APos: TVector2);
begin
  _ImDrawList_PathLineTo(@Self, _ImVec2(APos));
end;

procedure TImDrawList.PathLineToMergeDuplicate(const APos: TVector2);
begin
  _ImDrawList_PathLineToMergeDuplicate(@Self, _ImVec2(APos));
end;

procedure TImDrawList.PathRect(const ARectMin: TVector2; const ARectMax: TVector2; const ARounding: Single; const AFlags: TImDrawFlags);
begin
  _ImDrawList_PathRect(@Self, _ImVec2(ARectMin), _ImVec2(ARectMax), ARounding, Cardinal(AFlags));
end;

procedure TImDrawList.PathStroke(const ACol: UInt32; const AFlags: TImDrawFlags; const AThickness: Single);
begin
  _ImDrawList_PathStroke(@Self, ACol, Cardinal(AFlags), AThickness);
end;

procedure TImDrawList.PopClipRect;
begin
  _ImDrawList_PopClipRect(@Self);
end;

procedure TImDrawList.PopTextureID;
begin
  _ImDrawList_PopTextureID(@Self);
end;

procedure TImDrawList.PrimQuadUV(const AA: TVector2; const AB: TVector2; const AC: TVector2; const AD: TVector2; const AUvA: TVector2; const AUvB: TVector2; const AUvC: TVector2; const AUvD: TVector2; const ACol: UInt32);
begin
  _ImDrawList_PrimQuadUV(@Self, _ImVec2(AA), _ImVec2(AB), _ImVec2(AC), _ImVec2(AD), _ImVec2(AUvA), _ImVec2(AUvB), _ImVec2(AUvC), _ImVec2(AUvD), ACol);
end;

procedure TImDrawList.PrimRect(const AA: TVector2; const AB: TVector2; const ACol: UInt32);
begin
  _ImDrawList_PrimRect(@Self, _ImVec2(AA), _ImVec2(AB), ACol);
end;

procedure TImDrawList.PrimRectUV(const AA: TVector2; const AB: TVector2; const AUvA: TVector2; const AUvB: TVector2; const ACol: UInt32);
begin
  _ImDrawList_PrimRectUV(@Self, _ImVec2(AA), _ImVec2(AB), _ImVec2(AUvA), _ImVec2(AUvB), ACol);
end;

procedure TImDrawList.PrimReserve(const AIdxCount: Integer; const AVtxCount: Integer);
begin
  _ImDrawList_PrimReserve(@Self, AIdxCount, AVtxCount);
end;

procedure TImDrawList.PrimUnreserve(const AIdxCount: Integer; const AVtxCount: Integer);
begin
  _ImDrawList_PrimUnreserve(@Self, AIdxCount, AVtxCount);
end;

procedure TImDrawList.PrimVtx(const APos: TVector2; const AUv: TVector2; const ACol: UInt32);
begin
  _ImDrawList_PrimVtx(@Self, _ImVec2(APos), _ImVec2(AUv), ACol);
end;

procedure TImDrawList.PrimWriteIdx(const AIdx: TImDrawIdx);
begin
  _ImDrawList_PrimWriteIdx(@Self, _ImDrawIdx(AIdx));
end;

procedure TImDrawList.PrimWriteVtx(const APos: TVector2; const AUv: TVector2; const ACol: UInt32);
begin
  _ImDrawList_PrimWriteVtx(@Self, _ImVec2(APos), _ImVec2(AUv), ACol);
end;

procedure TImDrawList.PushClipRect(const AClipRectMin: TVector2; const AClipRectMax: TVector2; const AIntersectWithCurrentClipRect: Boolean);
begin
  _ImDrawList_PushClipRect(@Self, _ImVec2(AClipRectMin), _ImVec2(AClipRectMax), AIntersectWithCurrentClipRect);
end;

procedure TImDrawList.PushClipRectFullScreen;
begin
  _ImDrawList_PushClipRectFullScreen(@Self);
end;

procedure TImDrawList.PushTextureID(const ATextureId: TImTextureID);
begin
  _ImDrawList_PushTextureID(@Self, _ImTextureID(ATextureId));
end;

function TImDrawList.CalcCircleAutoSegmentCount(const ARadius: Single): Integer;
begin
  Result := _ImDrawList__CalcCircleAutoSegmentCount(@Self, ARadius);
end;

procedure TImDrawList.ClearFreeMemory;
begin
  _ImDrawList__ClearFreeMemory(@Self);
end;

procedure TImDrawList.OnChangedClipRect;
begin
  _ImDrawList__OnChangedClipRect(@Self);
end;

procedure TImDrawList.OnChangedTextureID;
begin
  _ImDrawList__OnChangedTextureID(@Self);
end;

procedure TImDrawList.OnChangedVtxOffset;
begin
  _ImDrawList__OnChangedVtxOffset(@Self);
end;

procedure TImDrawList.PathArcToFastEx(const ACenter: TVector2; const ARadius: Single; const AAMinSample: Integer; const AAMaxSample: Integer; const AAStep: Integer);
begin
  _ImDrawList__PathArcToFastEx(@Self, _ImVec2(ACenter), ARadius, AAMinSample, AAMaxSample, AAStep);
end;

procedure TImDrawList.PathArcToN(const ACenter: TVector2; const ARadius: Single; const AAMin: Single; const AAMax: Single; const ANumSegments: Integer);
begin
  _ImDrawList__PathArcToN(@Self, _ImVec2(ACenter), ARadius, AAMin, AAMax, ANumSegments);
end;

procedure TImDrawList.PopUnusedDrawCmd;
begin
  _ImDrawList__PopUnusedDrawCmd(@Self);
end;

procedure TImDrawList.ResetForNewFrame;
begin
  _ImDrawList__ResetForNewFrame(@Self);
end;

procedure TImDrawList.TryMergeDrawCmds;
begin
  _ImDrawList__TryMergeDrawCmds(@Self);
end;

{ TImFont }

class function TImFont.Create: PImFont;
begin
  Result := PImFont(_ImFont_ImFont());
end;

procedure TImFont.Free;
begin
  _ImFont_destroy(@Self);
end;

procedure TImFont.AddGlyph(const ASrcCfg: PImFontConfig; const AC: WideChar; const AX0: Single; const AY0: Single; const AX1: Single; const AY1: Single; const AU0: Single; const AV0: Single; const AU1: Single; const AV1: Single; const AAdvanceX: Single);
begin
  _ImFont_AddGlyph(@Self, Pointer(ASrcCfg), Word(AC), AX0, AY0, AX1, AY1, AU0, AV0, AU1, AV1, AAdvanceX);
end;

procedure TImFont.AddRemapChar(const ADst: WideChar; const ASrc: WideChar; const AOverwriteDst: Boolean);
begin
  _ImFont_AddRemapChar(@Self, Word(ADst), Word(ASrc), AOverwriteDst);
end;

procedure TImFont.BuildLookupTable;
begin
  _ImFont_BuildLookupTable(@Self);
end;

function TImFont.CalcTextSizeA(const ASize: Single; const AMaxWidth: Single; const AWrapWidth: Single; const ATextBegin: PUTF8Char; const ATextEnd: PUTF8Char; const ARemaining: PPUTF8Char): TVector2;
begin
  _ImFont_CalcTextSizeA(@Result, @Self, ASize, AMaxWidth, AWrapWidth, Pointer(ATextBegin), Pointer(ATextEnd), Pointer(ARemaining));
end;

function TImFont.CalcWordWrapPositionA(const AScale: Single; const AText: PUTF8Char; const ATextEnd: PUTF8Char; const AWrapWidth: Single): PUTF8Char;
begin
  Result := Pointer(_ImFont_CalcWordWrapPositionA(@Self, AScale, Pointer(AText), Pointer(ATextEnd), AWrapWidth));
end;

procedure TImFont.ClearOutputData;
begin
  _ImFont_ClearOutputData(@Self);
end;

function TImFont.FindGlyph(const AC: WideChar): PImFontGlyph;
begin
  Result := Pointer(_ImFont_FindGlyph(@Self, Word(AC)));
end;

function TImFont.FindGlyphNoFallback(const AC: WideChar): PImFontGlyph;
begin
  Result := Pointer(_ImFont_FindGlyphNoFallback(@Self, Word(AC)));
end;

function TImFont.GetCharAdvance(const AC: WideChar): Single;
begin
  Result := _ImFont_GetCharAdvance(@Self, Word(AC));
end;

function TImFont.GetDebugName: PUTF8Char;
begin
  Result := Pointer(_ImFont_GetDebugName(@Self));
end;

procedure TImFont.GrowIndex(const ANewSize: Integer);
begin
  _ImFont_GrowIndex(@Self, ANewSize);
end;

function TImFont.IsGlyphRangeUnused(const ACBegin: Cardinal; const ACLast: Cardinal): Boolean;
begin
  Result := _ImFont_IsGlyphRangeUnused(@Self, ACBegin, ACLast);
end;

function TImFont.IsLoaded: Boolean;
begin
  Result := _ImFont_IsLoaded(@Self);
end;

procedure TImFont.RenderChar(const ADrawList: PImDrawList; const ASize: Single; const APos: TVector2; const ACol: UInt32; const AC: WideChar);
begin
  _ImFont_RenderChar(@Self, Pointer(ADrawList), ASize, _ImVec2(APos), ACol, Word(AC));
end;

procedure TImFont.RenderText(const ADrawList: PImDrawList; const ASize: Single; const APos: TVector2; const ACol: UInt32; const AClipRect: TRectF; const ATextBegin: PUTF8Char; const ATextEnd: PUTF8Char; const AWrapWidth: Single; const ACpuFineClip: Boolean);
begin
  _ImFont_RenderText(@Self, Pointer(ADrawList), ASize, _ImVec2(APos), ACol, _ImVec4(AClipRect), Pointer(ATextBegin), Pointer(ATextEnd), AWrapWidth, ACpuFineClip);
end;

procedure TImFont.SetGlyphVisible(const AC: WideChar; const AVisible: Boolean);
begin
  _ImFont_SetGlyphVisible(@Self, Word(AC), AVisible);
end;

{ TImFontConfig }

class function TImFontConfig.Create: PImFontConfig;
begin
  Result := PImFontConfig(_ImFontConfig_ImFontConfig());
end;

procedure TImFontConfig.Free;
begin
  _ImFontConfig_destroy(@Self);
end;

{ TImFontAtlasCustomRect }

class function TImFontAtlasCustomRect.Create: PImFontAtlasCustomRect;
begin
  Result := PImFontAtlasCustomRect(_ImFontAtlasCustomRect_ImFontAtlasCustomRect());
end;

procedure TImFontAtlasCustomRect.Free;
begin
  _ImFontAtlasCustomRect_destroy(@Self);
end;

function TImFontAtlasCustomRect.IsPacked: Boolean;
begin
  Result := _ImFontAtlasCustomRect_IsPacked(@Self);
end;

{ TImFontAtlas }

class function TImFontAtlas.Create: PImFontAtlas;
begin
  Result := PImFontAtlas(_ImFontAtlas_ImFontAtlas());
end;

procedure TImFontAtlas.Free;
begin
  _ImFontAtlas_destroy(@Self);
end;

function TImFontAtlas.AddCustomRectFontGlyph(const AFont: PImFont; const AId: WideChar; const AWidth: Integer; const AHeight: Integer; const AAdvanceX: Single; const AOffset: TVector2): Integer;
begin
  Result := _ImFontAtlas_AddCustomRectFontGlyph(@Self, Pointer(AFont), Word(AId), AWidth, AHeight, AAdvanceX, _ImVec2(AOffset));
end;

function TImFontAtlas.AddCustomRectFontGlyph(const AFont: PImFont; const AId: WideChar; const AWidth: Integer; const AHeight: Integer; const AAdvanceX: Single): Integer;
begin
  Result := _ImFontAtlas_AddCustomRectFontGlyph(@Self, Pointer(AFont), Word(AId), AWidth, AHeight, AAdvanceX, _ImVec2(TVector2.Zero));
end;

function TImFontAtlas.AddCustomRectRegular(const AWidth: Integer; const AHeight: Integer): Integer;
begin
  Result := _ImFontAtlas_AddCustomRectRegular(@Self, AWidth, AHeight);
end;

function TImFontAtlas.AddFont(const AFontCfg: PImFontConfig): PImFont;
begin
  Result := Pointer(_ImFontAtlas_AddFont(@Self, Pointer(AFontCfg)));
end;

function TImFontAtlas.AddFontDefault(const AFontCfg: PImFontConfig): PImFont;
begin
  Result := Pointer(_ImFontAtlas_AddFontDefault(@Self, Pointer(AFontCfg)));
end;

function TImFontAtlas.AddFontFromFileTTF(const AFilename: PUTF8Char; const ASizePixels: Single; const AFontCfg: PImFontConfig; const AGlyphRanges: PWideChar): PImFont;
begin
  Result := Pointer(_ImFontAtlas_AddFontFromFileTTF(@Self, Pointer(AFilename), ASizePixels, Pointer(AFontCfg), Pointer(AGlyphRanges)));
end;

function TImFontAtlas.AddFontFromMemoryCompressedBase85TTF(const ACompressedFontDataBase85: PUTF8Char; const ASizePixels: Single; const AFontCfg: PImFontConfig; const AGlyphRanges: PWideChar): PImFont;
begin
  Result := Pointer(_ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(@Self, Pointer(ACompressedFontDataBase85), ASizePixels, Pointer(AFontCfg), Pointer(AGlyphRanges)));
end;

function TImFontAtlas.AddFontFromMemoryCompressedTTF(const ACompressedFontData: Pointer; const ACompressedFontSize: Integer; const ASizePixels: Single; const AFontCfg: PImFontConfig; const AGlyphRanges: PWideChar): PImFont;
begin
  Result := Pointer(_ImFontAtlas_AddFontFromMemoryCompressedTTF(@Self, Pointer(ACompressedFontData), ACompressedFontSize, ASizePixels, Pointer(AFontCfg), Pointer(AGlyphRanges)));
end;

function TImFontAtlas.AddFontFromMemoryTTF(const AFontData: Pointer; const AFontSize: Integer; const ASizePixels: Single; const AFontCfg: PImFontConfig; const AGlyphRanges: PWideChar): PImFont;
begin
  Result := Pointer(_ImFontAtlas_AddFontFromMemoryTTF(@Self, Pointer(AFontData), AFontSize, ASizePixels, Pointer(AFontCfg), Pointer(AGlyphRanges)));
end;

function TImFontAtlas.Build: Boolean;
begin
  Result := _ImFontAtlas_Build(@Self);
end;

procedure TImFontAtlas.CalcCustomRectUV(const ARect: PImFontAtlasCustomRect; const AOutUvMin: PVector2; const AOutUvMax: PVector2);
begin
  _ImFontAtlas_CalcCustomRectUV(@Self, Pointer(ARect), Pointer(AOutUvMin), Pointer(AOutUvMax));
end;

procedure TImFontAtlas.Clear;
begin
  _ImFontAtlas_Clear(@Self);
end;

procedure TImFontAtlas.ClearFonts;
begin
  _ImFontAtlas_ClearFonts(@Self);
end;

procedure TImFontAtlas.ClearInputData;
begin
  _ImFontAtlas_ClearInputData(@Self);
end;

procedure TImFontAtlas.ClearTexData;
begin
  _ImFontAtlas_ClearTexData(@Self);
end;

function TImFontAtlas.GetCustomRectByIndex(const AIndex: Integer): PImFontAtlasCustomRect;
begin
  Result := Pointer(_ImFontAtlas_GetCustomRectByIndex(@Self, AIndex));
end;

function TImFontAtlas.GetGlyphRangesChineseFull: PWideChar;
begin
  Result := Pointer(_ImFontAtlas_GetGlyphRangesChineseFull(@Self));
end;

function TImFontAtlas.GetGlyphRangesChineseSimplifiedCommon: PWideChar;
begin
  Result := Pointer(_ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon(@Self));
end;

function TImFontAtlas.GetGlyphRangesCyrillic: PWideChar;
begin
  Result := Pointer(_ImFontAtlas_GetGlyphRangesCyrillic(@Self));
end;

function TImFontAtlas.GetGlyphRangesDefault: PWideChar;
begin
  Result := Pointer(_ImFontAtlas_GetGlyphRangesDefault(@Self));
end;

function TImFontAtlas.GetGlyphRangesJapanese: PWideChar;
begin
  Result := Pointer(_ImFontAtlas_GetGlyphRangesJapanese(@Self));
end;

function TImFontAtlas.GetGlyphRangesKorean: PWideChar;
begin
  Result := Pointer(_ImFontAtlas_GetGlyphRangesKorean(@Self));
end;

function TImFontAtlas.GetGlyphRangesThai: PWideChar;
begin
  Result := Pointer(_ImFontAtlas_GetGlyphRangesThai(@Self));
end;

function TImFontAtlas.GetGlyphRangesVietnamese: PWideChar;
begin
  Result := Pointer(_ImFontAtlas_GetGlyphRangesVietnamese(@Self));
end;

function TImFontAtlas.GetMouseCursorTexData(const ACursor: TImGuiMouseCursor; const AOutOffset: PVector2; const AOutSize: PVector2; const AOutUvBorder: PVector2; const AOutUvFill: PVector2): Boolean;
begin
  Result := _ImFontAtlas_GetMouseCursorTexData(@Self, _ImGuiMouseCursor(ACursor), Pointer(AOutOffset), Pointer(AOutSize), Pointer(AOutUvBorder), Pointer(AOutUvFill));
end;

procedure TImFontAtlas.GetTexDataAsAlpha8(out AOutPixels: PByte; out AOutWidth: Integer; out AOutHeight: Integer; const AOutBytesPerPixel: PInteger);
begin
  _ImFontAtlas_GetTexDataAsAlpha8(@Self, @AOutPixels, @AOutWidth, @AOutHeight, Pointer(AOutBytesPerPixel));
end;

procedure TImFontAtlas.GetTexDataAsRGBA32(out AOutPixels: PByte; out AOutWidth: Integer; out AOutHeight: Integer; const AOutBytesPerPixel: PInteger);
begin
  _ImFontAtlas_GetTexDataAsRGBA32(@Self, @AOutPixels, @AOutWidth, @AOutHeight, Pointer(AOutBytesPerPixel));
end;

function TImFontAtlas.IsBuilt: Boolean;
begin
  Result := _ImFontAtlas_IsBuilt(@Self);
end;

procedure TImFontAtlas.SetTexID(const AId: TImTextureID);
begin
  _ImFontAtlas_SetTexID(@Self, _ImTextureID(AId));
end;

{ TImFontGlyphRangesBuilder }

class function TImFontGlyphRangesBuilder.Create: PImFontGlyphRangesBuilder;
begin
  Result := PImFontGlyphRangesBuilder(_ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder());
end;

procedure TImFontGlyphRangesBuilder.Free;
begin
  _ImFontGlyphRangesBuilder_destroy(@Self);
end;

procedure TImFontGlyphRangesBuilder.AddChar(const AC: WideChar);
begin
  _ImFontGlyphRangesBuilder_AddChar(@Self, Word(AC));
end;

procedure TImFontGlyphRangesBuilder.AddRanges(const ARanges: PWideChar);
begin
  _ImFontGlyphRangesBuilder_AddRanges(@Self, Pointer(ARanges));
end;

procedure TImFontGlyphRangesBuilder.AddText(const AText: PUTF8Char; const ATextEnd: PUTF8Char);
begin
  _ImFontGlyphRangesBuilder_AddText(@Self, Pointer(AText), Pointer(ATextEnd));
end;

procedure TImFontGlyphRangesBuilder.BuildRanges(out AOutRanges: TImVector<WideChar>);
begin
  _ImFontGlyphRangesBuilder_BuildRanges(@Self, @AOutRanges);
end;

procedure TImFontGlyphRangesBuilder.Clear;
begin
  _ImFontGlyphRangesBuilder_Clear(@Self);
end;

function TImFontGlyphRangesBuilder.GetBit(const AN: NativeUInt): Boolean;
begin
  Result := _ImFontGlyphRangesBuilder_GetBit(@Self, AN);
end;

procedure TImFontGlyphRangesBuilder.SetBit(const AN: NativeUInt);
begin
  _ImFontGlyphRangesBuilder_SetBit(@Self, AN);
end;

{ TImGuiTextBuffer }

class function TImGuiTextBuffer.Create: PImGuiTextBuffer;
begin
  Result := PImGuiTextBuffer(_ImGuiTextBuffer_ImGuiTextBuffer());
end;

procedure TImGuiTextBuffer.Free;
begin
  _ImGuiTextBuffer_destroy(@Self);
end;

procedure TImGuiTextBuffer.Append(const AStr: PUTF8Char; const AStrEnd: PUTF8Char);
begin
  _ImGuiTextBuffer_append(@Self, Pointer(AStr), Pointer(AStrEnd));
end;

function TImGuiTextBuffer.&Begin: PUTF8Char;
begin
  Result := Pointer(_ImGuiTextBuffer_begin(@Self));
end;

function TImGuiTextBuffer.CStr: PUTF8Char;
begin
  Result := Pointer(_ImGuiTextBuffer_c_str(@Self));
end;

function TImGuiTextBuffer.ToString: String;
begin
  Result := String(UTF8String(_ImGuiTextBuffer_c_str(@Self)));
end;

function TImGuiTextBuffer.ToUTF8String: UTF8String;
begin
  Result := UTF8String(_ImGuiTextBuffer_c_str(@Self));
end;

procedure TImGuiTextBuffer.Clear;
begin
  _ImGuiTextBuffer_clear(@Self);
end;

function TImGuiTextBuffer.Empty: Boolean;
begin
  Result := _ImGuiTextBuffer_empty(@Self);
end;

function TImGuiTextBuffer.&End: PUTF8Char;
begin
  Result := Pointer(_ImGuiTextBuffer_end(@Self));
end;

procedure TImGuiTextBuffer.Reserve(const ACapacity: Integer);
begin
  _ImGuiTextBuffer_reserve(@Self, ACapacity);
end;

function TImGuiTextBuffer.Size: Integer;
begin
  Result := _ImGuiTextBuffer_size(@Self);
end;

{ TImGuiStoragePair }

class function TImGuiStoragePair.Create(const AKey: TImGuiID; const AValI: Integer): PImGuiStoragePair;
begin
  Result := PImGuiStoragePair(_ImGuiStoragePair_ImGuiStoragePair_Int(_ImGuiID(AKey), AValI));
end;

class function TImGuiStoragePair.Create(const AKey: TImGuiID; const AValF: Single): PImGuiStoragePair;
begin
  Result := PImGuiStoragePair(_ImGuiStoragePair_ImGuiStoragePair_Float(_ImGuiID(AKey), AValF));
end;

class function TImGuiStoragePair.Create(const AKey: TImGuiID; const AValP: Pointer): PImGuiStoragePair;
begin
  Result := PImGuiStoragePair(_ImGuiStoragePair_ImGuiStoragePair_Ptr(_ImGuiID(AKey), Pointer(AValP)));
end;

procedure TImGuiStoragePair.Free;
begin
  _ImGuiStoragePair_destroy(@Self);
end;

{ TImGuiStorage }

procedure TImGuiStorage.BuildSortByKey;
begin
  _ImGuiStorage_BuildSortByKey(@Self);
end;

procedure TImGuiStorage.Clear;
begin
  _ImGuiStorage_Clear(@Self);
end;

function TImGuiStorage.GetBool(const AKey: TImGuiID; const ADefaultVal: Boolean): Boolean;
begin
  Result := _ImGuiStorage_GetBool(@Self, _ImGuiID(AKey), ADefaultVal);
end;

function TImGuiStorage.GetBoolRef(const AKey: TImGuiID; const ADefaultVal: Boolean): PBoolean;
begin
  Result := Pointer(_ImGuiStorage_GetBoolRef(@Self, _ImGuiID(AKey), ADefaultVal));
end;

function TImGuiStorage.GetFloat(const AKey: TImGuiID; const ADefaultVal: Single): Single;
begin
  Result := _ImGuiStorage_GetFloat(@Self, _ImGuiID(AKey), ADefaultVal);
end;

function TImGuiStorage.GetFloatRef(const AKey: TImGuiID; const ADefaultVal: Single): PSingle;
begin
  Result := Pointer(_ImGuiStorage_GetFloatRef(@Self, _ImGuiID(AKey), ADefaultVal));
end;

function TImGuiStorage.GetInt(const AKey: TImGuiID; const ADefaultVal: Integer): Integer;
begin
  Result := _ImGuiStorage_GetInt(@Self, _ImGuiID(AKey), ADefaultVal);
end;

function TImGuiStorage.GetIntRef(const AKey: TImGuiID; const ADefaultVal: Integer): PInteger;
begin
  Result := Pointer(_ImGuiStorage_GetIntRef(@Self, _ImGuiID(AKey), ADefaultVal));
end;

function TImGuiStorage.GetVoidPtr(const AKey: TImGuiID): Pointer;
begin
  Result := Pointer(_ImGuiStorage_GetVoidPtr(@Self, _ImGuiID(AKey)));
end;

function TImGuiStorage.GetVoidPtrRef(const AKey: TImGuiID; const ADefaultVal: Pointer): PPointer;
begin
  Result := Pointer(_ImGuiStorage_GetVoidPtrRef(@Self, _ImGuiID(AKey), Pointer(ADefaultVal)));
end;

procedure TImGuiStorage.SetAllInt(const AVal: Integer);
begin
  _ImGuiStorage_SetAllInt(@Self, AVal);
end;

procedure TImGuiStorage.SetBool(const AKey: TImGuiID; const AVal: Boolean);
begin
  _ImGuiStorage_SetBool(@Self, _ImGuiID(AKey), AVal);
end;

procedure TImGuiStorage.SetFloat(const AKey: TImGuiID; const AVal: Single);
begin
  _ImGuiStorage_SetFloat(@Self, _ImGuiID(AKey), AVal);
end;

procedure TImGuiStorage.SetInt(const AKey: TImGuiID; const AVal: Integer);
begin
  _ImGuiStorage_SetInt(@Self, _ImGuiID(AKey), AVal);
end;

procedure TImGuiStorage.SetVoidPtr(const AKey: TImGuiID; const AVal: Pointer);
begin
  _ImGuiStorage_SetVoidPtr(@Self, _ImGuiID(AKey), Pointer(AVal));
end;

{ TImGuiPlatformImeData }

class function TImGuiPlatformImeData.Create: PImGuiPlatformImeData;
begin
  Result := PImGuiPlatformImeData(_ImGuiPlatformImeData_ImGuiPlatformImeData());
end;

procedure TImGuiPlatformImeData.Free;
begin
  _ImGuiPlatformImeData_destroy(@Self);
end;

{ TImGuiTableSortSpecs }

class function TImGuiTableSortSpecs.Create: PImGuiTableSortSpecs;
begin
  Result := PImGuiTableSortSpecs(_ImGuiTableSortSpecs_ImGuiTableSortSpecs());
end;

procedure TImGuiTableSortSpecs.Free;
begin
  _ImGuiTableSortSpecs_destroy(@Self);
end;

{ TImGuiTableColumnSortSpecs }

class function TImGuiTableColumnSortSpecs.Create: PImGuiTableColumnSortSpecs;
begin
  Result := PImGuiTableColumnSortSpecs(_ImGuiTableColumnSortSpecs_ImGuiTableColumnSortSpecs());
end;

procedure TImGuiTableColumnSortSpecs.Free;
begin
  _ImGuiTableColumnSortSpecs_destroy(@Self);
end;

{ TImGuiPayload }

class function TImGuiPayload.Create: PImGuiPayload;
begin
  Result := PImGuiPayload(_ImGuiPayload_ImGuiPayload());
end;

procedure TImGuiPayload.Free;
begin
  _ImGuiPayload_destroy(@Self);
end;

procedure TImGuiPayload.Clear;
begin
  _ImGuiPayload_Clear(@Self);
end;

function TImGuiPayload.IsDataType(const AType: PUTF8Char): Boolean;
begin
  Result := _ImGuiPayload_IsDataType(@Self, Pointer(AType));
end;

function TImGuiPayload.IsDelivery: Boolean;
begin
  Result := _ImGuiPayload_IsDelivery(@Self);
end;

function TImGuiPayload.IsPreview: Boolean;
begin
  Result := _ImGuiPayload_IsPreview(@Self);
end;

{ TImGuiPlatformMonitor }

class function TImGuiPlatformMonitor.Create: PImGuiPlatformMonitor;
begin
  Result := PImGuiPlatformMonitor(_ImGuiPlatformMonitor_ImGuiPlatformMonitor());
end;

procedure TImGuiPlatformMonitor.Free;
begin
  _ImGuiPlatformMonitor_destroy(@Self);
end;

{ TImGuiWindowClass }

class function TImGuiWindowClass.Create: PImGuiWindowClass;
begin
  Result := PImGuiWindowClass(_ImGuiWindowClass_ImGuiWindowClass());
end;

procedure TImGuiWindowClass.Free;
begin
  _ImGuiWindowClass_destroy(@Self);
end;

{ TImGuiStyle }

class function TImGuiStyle.Create: PImGuiStyle;
begin
  Result := PImGuiStyle(_ImGuiStyle_ImGuiStyle());
end;

procedure TImGuiStyle.Free;
begin
  _ImGuiStyle_destroy(@Self);
end;

procedure TImGuiStyle.ScaleAllSizes(const AScaleFactor: Single);
begin
  _ImGuiStyle_ScaleAllSizes(@Self, AScaleFactor);
end;

{ TImGuiPlatformIO }

class function TImGuiPlatformIO.Create: PImGuiPlatformIO;
begin
  Result := PImGuiPlatformIO(_ImGuiPlatformIO_ImGuiPlatformIO());
end;

procedure TImGuiPlatformIO.Free;
begin
  _ImGuiPlatformIO_destroy(@Self);
end;

{ TImGuiIO }

class function TImGuiIO.Create: PImGuiIO;
begin
  Result := PImGuiIO(_ImGuiIO_ImGuiIO());
end;

procedure TImGuiIO.Free;
begin
  _ImGuiIO_destroy(@Self);
end;

procedure TImGuiIO.AddFocusEvent(const AFocused: Boolean);
begin
  _ImGuiIO_AddFocusEvent(@Self, AFocused);
end;

procedure TImGuiIO.AddInputCharacter(const AC: Cardinal);
begin
  _ImGuiIO_AddInputCharacter(@Self, AC);
end;

procedure TImGuiIO.AddInputCharacterUTF16(const AC: WideChar);
begin
  _ImGuiIO_AddInputCharacterUTF16(@Self, Word(AC));
end;

procedure TImGuiIO.AddInputCharactersUTF8(const AStr: PUTF8Char);
begin
  _ImGuiIO_AddInputCharactersUTF8(@Self, Pointer(AStr));
end;

procedure TImGuiIO.AddKeyAnalogEvent(const AKey: TImGuiKey; const ADown: Boolean; const AV: Single);
begin
  _ImGuiIO_AddKeyAnalogEvent(@Self, _ImGuiKey(AKey), ADown, AV);
end;

procedure TImGuiIO.AddKeyEvent(const AKey: TImGuiKey; const ADown: Boolean);
begin
  _ImGuiIO_AddKeyEvent(@Self, _ImGuiKey(AKey), ADown);
end;

procedure TImGuiIO.AddMouseButtonEvent(const AButton: Integer; const ADown: Boolean);
begin
  _ImGuiIO_AddMouseButtonEvent(@Self, AButton, ADown);
end;

procedure TImGuiIO.AddMousePosEvent(const AX: Single; const AY: Single);
begin
  _ImGuiIO_AddMousePosEvent(@Self, AX, AY);
end;

procedure TImGuiIO.AddMouseViewportEvent(const AId: TImGuiID);
begin
  _ImGuiIO_AddMouseViewportEvent(@Self, _ImGuiID(AId));
end;

procedure TImGuiIO.AddMouseWheelEvent(const AWhX: Single; const AWhY: Single);
begin
  _ImGuiIO_AddMouseWheelEvent(@Self, AWhX, AWhY);
end;

procedure TImGuiIO.ClearInputCharacters;
begin
  _ImGuiIO_ClearInputCharacters(@Self);
end;

procedure TImGuiIO.ClearInputKeys;
begin
  _ImGuiIO_ClearInputKeys(@Self);
end;

procedure TImGuiIO.SetAppAcceptingEvents(const AAcceptingEvents: Boolean);
begin
  _ImGuiIO_SetAppAcceptingEvents(@Self, AAcceptingEvents);
end;

procedure TImGuiIO.SetKeyEventNativeData(const AKey: TImGuiKey; const ANativeKeycode: Integer; const ANativeScancode: Integer; const ANativeLegacyIndex: Integer);
begin
  _ImGuiIO_SetKeyEventNativeData(@Self, _ImGuiKey(AKey), ANativeKeycode, ANativeScancode, ANativeLegacyIndex);
end;

{ TImGuiInputTextCallbackData }

class function TImGuiInputTextCallbackData.Create: PImGuiInputTextCallbackData;
begin
  Result := PImGuiInputTextCallbackData(_ImGuiInputTextCallbackData_ImGuiInputTextCallbackData());
end;

procedure TImGuiInputTextCallbackData.Free;
begin
  _ImGuiInputTextCallbackData_destroy(@Self);
end;

procedure TImGuiInputTextCallbackData.ClearSelection;
begin
  _ImGuiInputTextCallbackData_ClearSelection(@Self);
end;

procedure TImGuiInputTextCallbackData.DeleteChars(const APos: Integer; const ABytesCount: Integer);
begin
  _ImGuiInputTextCallbackData_DeleteChars(@Self, APos, ABytesCount);
end;

function TImGuiInputTextCallbackData.HasSelection: Boolean;
begin
  Result := _ImGuiInputTextCallbackData_HasSelection(@Self);
end;

procedure TImGuiInputTextCallbackData.InsertChars(const APos: Integer; const AText: PUTF8Char; const ATextEnd: PUTF8Char);
begin
  _ImGuiInputTextCallbackData_InsertChars(@Self, APos, Pointer(AText), Pointer(ATextEnd));
end;

procedure TImGuiInputTextCallbackData.SelectAll;
begin
  _ImGuiInputTextCallbackData_SelectAll(@Self);
end;

{ TImGuiListClipper }

class function TImGuiListClipper.Create: PImGuiListClipper;
begin
  Result := PImGuiListClipper(_ImGuiListClipper_ImGuiListClipper());
end;

procedure TImGuiListClipper.Free;
begin
  _ImGuiListClipper_destroy(@Self);
end;

procedure TImGuiListClipper.&Begin(const AItemsCount: Integer; const AItemsHeight: Single);
begin
  _ImGuiListClipper_Begin(@Self, AItemsCount, AItemsHeight);
end;

procedure TImGuiListClipper.&End;
begin
  _ImGuiListClipper_End(@Self);
end;

procedure TImGuiListClipper.ForceDisplayRangeByIndices(const AItemMin: Integer; const AItemMax: Integer);
begin
  _ImGuiListClipper_ForceDisplayRangeByIndices(@Self, AItemMin, AItemMax);
end;

function TImGuiListClipper.Step: Boolean;
begin
  Result := _ImGuiListClipper_Step(@Self);
end;

{ TImGuiOnceUponAFrame }

class function TImGuiOnceUponAFrame.Create: PImGuiOnceUponAFrame;
begin
  Result := PImGuiOnceUponAFrame(_ImGuiOnceUponAFrame_ImGuiOnceUponAFrame());
end;

procedure TImGuiOnceUponAFrame.Free;
begin
  _ImGuiOnceUponAFrame_destroy(@Self);
end;

{ TImGuiTextRange }

class function TImGuiTextRange.Create: PImGuiTextRange;
begin
  Result := PImGuiTextRange(_ImGuiTextRange_ImGuiTextRange_Nil());
end;

class function TImGuiTextRange.Create(const AB: PUTF8Char; const AE: PUTF8Char): PImGuiTextRange;
begin
  Result := PImGuiTextRange(_ImGuiTextRange_ImGuiTextRange_Str(Pointer(AB), Pointer(AE)));
end;

procedure TImGuiTextRange.Free;
begin
  _ImGuiTextRange_destroy(@Self);
end;

function TImGuiTextRange.Empty: Boolean;
begin
  Result := _ImGuiTextRange_empty(@Self);
end;

procedure TImGuiTextRange.Split(const ASeparator: UTF8Char; out AOut: TImVector<TImGuiTextRange>);
begin
  _ImGuiTextRange_split(@Self, ASeparator, @AOut);
end;

{ TImGuiTextFilter }

class function TImGuiTextFilter.Create(const ADefaultFilter: PUTF8Char): PImGuiTextFilter;
begin
  Result := PImGuiTextFilter(_ImGuiTextFilter_ImGuiTextFilter(Pointer(ADefaultFilter)));
end;

procedure TImGuiTextFilter.Free;
begin
  _ImGuiTextFilter_destroy(@Self);
end;

procedure TImGuiTextFilter.Build;
begin
  _ImGuiTextFilter_Build(@Self);
end;

procedure TImGuiTextFilter.Clear;
begin
  _ImGuiTextFilter_Clear(@Self);
end;

function TImGuiTextFilter.Draw(const ALabel: PUTF8Char; const AWidth: Single): Boolean;
begin
  Result := _ImGuiTextFilter_Draw(@Self, Pointer(ALabel), AWidth);
end;

function TImGuiTextFilter.IsActive: Boolean;
begin
  Result := _ImGuiTextFilter_IsActive(@Self);
end;

function TImGuiTextFilter.PassFilter(const AText: PUTF8Char; const ATextEnd: PUTF8Char): Boolean;
begin
  Result := _ImGuiTextFilter_PassFilter(@Self, Pointer(AText), Pointer(ATextEnd));
end;

{ TImGuiViewport }

class function TImGuiViewport.Create: PImGuiViewport;
begin
  Result := PImGuiViewport(_ImGuiViewport_ImGuiViewport());
end;

procedure TImGuiViewport.Free;
begin
  _ImGuiViewport_destroy(@Self);
end;

function TImGuiViewport.GetCenter: TVector2;
begin
  _ImGuiViewport_GetCenter(@Result, @Self);
end;

function TImGuiViewport.GetWorkCenter: TVector2;
begin
  _ImGuiViewport_GetWorkCenter(@Result, @Self);
end;

{ ImGui }

class function ImGui.AcceptDragDropPayload(const AType: PUTF8Char; const AFlags: TImGuiDragDropFlags): PImGuiPayload;
begin
  Result := Pointer(_igAcceptDragDropPayload(Pointer(AType), Cardinal(AFlags)));
end;

class procedure ImGui.AlignTextToFramePadding;
begin
  _igAlignTextToFramePadding();
end;

class function ImGui.ArrowButton(const AStrId: PUTF8Char; const ADir: TImGuiDir): Boolean;
begin
  Result := _igArrowButton(Pointer(AStrId), _ImGuiDir(ADir));
end;

class function ImGui.&Begin(const AName: PUTF8Char; const APOpen: PBoolean; const AFlags: TImGuiWindowFlags): Boolean;
begin
  Result := _igBegin(Pointer(AName), Pointer(APOpen), Cardinal(AFlags));
end;

class function ImGui.BeginChild(const AStrId: PUTF8Char; const ASize: TVector2; const ABorder: Boolean; const AFlags: TImGuiWindowFlags): Boolean;
begin
  Result := _igBeginChild_Str(Pointer(AStrId), _ImVec2(ASize), ABorder, Cardinal(AFlags));
end;

class function ImGui.BeginChild(const AStrId: PUTF8Char; const ABorder: Boolean = False; const AFlags: TImGuiWindowFlags = []): Boolean;
begin
  Result := _igBeginChild_Str(Pointer(AStrId), _ImVec2(TVector2.Zero), ABorder, Cardinal(AFlags));
end;

class function ImGui.BeginChild(const AId: TImGuiID; const ASize: TVector2; const ABorder: Boolean; const AFlags: TImGuiWindowFlags): Boolean;
begin
  Result := _igBeginChild_ID(_ImGuiID(AId), _ImVec2(ASize), ABorder, Cardinal(AFlags));
end;

class function ImGui.BeginChild(const AId: TImGuiID; const ABorder: Boolean = False; const AFlags: TImGuiWindowFlags = []): Boolean;
begin
  Result := _igBeginChild_ID(_ImGuiID(AId), _ImVec2(TVector2.Zero), ABorder, Cardinal(AFlags));
end;

class function ImGui.BeginChildFrame(const AId: TImGuiID; const ASize: TVector2; const AFlags: TImGuiWindowFlags): Boolean;
begin
  Result := _igBeginChildFrame(_ImGuiID(AId), _ImVec2(ASize), Cardinal(AFlags));
end;

class function ImGui.BeginCombo(const ALabel: PUTF8Char; const APreviewValue: PUTF8Char; const AFlags: TImGuiComboFlags): Boolean;
begin
  Result := _igBeginCombo(Pointer(ALabel), Pointer(APreviewValue), Cardinal(AFlags));
end;

class procedure ImGui.BeginDisabled(const ADisabled: Boolean);
begin
  _igBeginDisabled(ADisabled);
end;

class function ImGui.BeginDragDropSource(const AFlags: TImGuiDragDropFlags): Boolean;
begin
  Result := _igBeginDragDropSource(Cardinal(AFlags));
end;

class function ImGui.BeginDragDropTarget: Boolean;
begin
  Result := _igBeginDragDropTarget();
end;

class procedure ImGui.BeginGroup;
begin
  _igBeginGroup();
end;

class function ImGui.BeginListBox(const ALabel: PUTF8Char; const ASize: TVector2): Boolean;
begin
  Result := _igBeginListBox(Pointer(ALabel), _ImVec2(ASize));
end;

class function ImGui.BeginListBox(const ALabel: PUTF8Char): Boolean;
begin
  Result := _igBeginListBox(Pointer(ALabel), _ImVec2(TVector2.Zero));
end;

class function ImGui.BeginMainMenuBar: Boolean;
begin
  Result := _igBeginMainMenuBar();
end;

class function ImGui.BeginMenu(const ALabel: PUTF8Char; const AEnabled: Boolean): Boolean;
begin
  Result := _igBeginMenu(Pointer(ALabel), AEnabled);
end;

class function ImGui.BeginMenuBar: Boolean;
begin
  Result := _igBeginMenuBar();
end;

class function ImGui.BeginPopup(const AStrId: PUTF8Char; const AFlags: TImGuiWindowFlags): Boolean;
begin
  Result := _igBeginPopup(Pointer(AStrId), Cardinal(AFlags));
end;

class function ImGui.BeginPopupContextItem(const AStrId: PUTF8Char; const APopupFlags: TImGuiPopupFlags): Boolean;
begin
  Result := _igBeginPopupContextItem(Pointer(AStrId), Cardinal(APopupFlags));
end;

class function ImGui.BeginPopupContextVoid(const AStrId: PUTF8Char; const APopupFlags: TImGuiPopupFlags): Boolean;
begin
  Result := _igBeginPopupContextVoid(Pointer(AStrId), Cardinal(APopupFlags));
end;

class function ImGui.BeginPopupContextWindow(const AStrId: PUTF8Char; const APopupFlags: TImGuiPopupFlags): Boolean;
begin
  Result := _igBeginPopupContextWindow(Pointer(AStrId), Cardinal(APopupFlags));
end;

class function ImGui.BeginPopupModal(const AName: PUTF8Char; const APOpen: PBoolean; const AFlags: TImGuiWindowFlags): Boolean;
begin
  Result := _igBeginPopupModal(Pointer(AName), Pointer(APOpen), Cardinal(AFlags));
end;

class function ImGui.BeginTabBar(const AStrId: PUTF8Char; const AFlags: TImGuiTabBarFlags): Boolean;
begin
  Result := _igBeginTabBar(Pointer(AStrId), Cardinal(AFlags));
end;

class function ImGui.BeginTabItem(const ALabel: PUTF8Char; const APOpen: PBoolean; const AFlags: TImGuiTabItemFlags): Boolean;
begin
  Result := _igBeginTabItem(Pointer(ALabel), Pointer(APOpen), Cardinal(AFlags));
end;

class function ImGui.BeginTable(const AStrId: PUTF8Char; const AColumn: Integer; const AFlags: TImGuiTableFlags; const AOuterSize: TVector2; const AInnerWidth: Single): Boolean;
begin
  Result := _igBeginTable(Pointer(AStrId), AColumn, Cardinal(AFlags), _ImVec2(AOuterSize), AInnerWidth);
end;

class function ImGui.BeginTable(const AStrId: PUTF8Char; const AColumn: Integer; const AFlags: TImGuiTableFlags = []; const AInnerWidth: Single = 0.0): Boolean;
begin
  Result := _igBeginTable(Pointer(AStrId), AColumn, Cardinal(AFlags), _ImVec2(TVector2.Zero), AInnerWidth);
end;

class function ImGui.BeginTable(const AStrId: PUTF8Char; const AColumn: Integer; const AOuterSize: TVector2; const AFlags: TImGuiTableFlags = []; const AInnerWidth: Single = 0.0): Boolean;
begin
  Result := _igBeginTable(Pointer(AStrId), AColumn, Cardinal(AFlags), _ImVec2(AOuterSize), AInnerWidth);
end;

class procedure ImGui.BeginTooltip;
begin
  _igBeginTooltip();
end;

class procedure ImGui.Bullet;
begin
  _igBullet();
end;

class procedure ImGui.BulletText(const AText: PUTF8Char);
begin
  _igBulletText(Pointer(AText));
end;

class function ImGui.Button(const ALabel: PUTF8Char; const ASize: TVector2): Boolean;
begin
  Result := _igButton(Pointer(ALabel), _ImVec2(ASize));
end;

class function ImGui.Button(const ALabel: PUTF8Char): Boolean;
begin
  Result := _igButton(Pointer(ALabel), _ImVec2(TVector2.Zero));
end;

class function ImGui.CalcItemWidth: Single;
begin
  Result := _igCalcItemWidth();
end;

class function ImGui.CalcTextSize(const AText: PUTF8Char; const ATextEnd: PUTF8Char; const AHideTextAfterDoubleHash: Boolean; const AWrapWidth: Single): TVector2;
begin
  _igCalcTextSize(@Result, Pointer(AText), Pointer(ATextEnd), AHideTextAfterDoubleHash, AWrapWidth);
end;

class function ImGui.Checkbox(const ALabel: PUTF8Char; const AV: PBoolean): Boolean;
begin
  Result := _igCheckbox(Pointer(ALabel), Pointer(AV));
end;

class procedure ImGui.CloseCurrentPopup;
begin
  _igCloseCurrentPopup();
end;

class function ImGui.CollapsingHeader(const ALabel: PUTF8Char; const AFlags: TImGuiTreeNodeFlags): Boolean;
begin
  Result := _igCollapsingHeader_TreeNodeFlags(Pointer(ALabel), Cardinal(AFlags));
end;

class function ImGui.CollapsingHeader(const ALabel: PUTF8Char; const APVisible: PBoolean; const AFlags: TImGuiTreeNodeFlags): Boolean;
begin
  Result := _igCollapsingHeader_BoolPtr(Pointer(ALabel), Pointer(APVisible), Cardinal(AFlags));
end;

class function ImGui.ColorButton(const ADescId: PUTF8Char; const ACol: TAlphaColorF; const AFlags: TImGuiColorEditFlags; const ASize: TVector2): Boolean;
begin
  Result := _igColorButton(Pointer(ADescId), _ImVec4(ACol), Cardinal(AFlags), _ImVec2(ASize));
end;

class function ImGui.ColorButton(const ADescId: PUTF8Char; const ACol: TAlphaColorF; const AFlags: TImGuiColorEditFlags = []): Boolean;
begin
  Result := _igColorButton(Pointer(ADescId), _ImVec4(ACol), Cardinal(AFlags), _ImVec2(TVector2.Zero));
end;

class function ImGui.ColorConvertToU32(const AIn: TAlphaColorF): UInt32;
begin
  Result := _igColorConvertFloat4ToU32(_ImVec4(AIn));
end;

class procedure ImGui.ColorConvertHSVtoRGB(const AH: Single; const &AS: Single; const AV: Single; out AOutR: Single; out AOutG: Single; out AOutB: Single);
begin
  _igColorConvertHSVtoRGB(AH, &AS, AV, @AOutR, @AOutG, @AOutB);
end;

class procedure ImGui.ColorConvertRGBtoHSV(const AR: Single; const AG: Single; const AB: Single; out AOutH: Single; out AOutS: Single; out AOutV: Single);
begin
  _igColorConvertRGBtoHSV(AR, AG, AB, @AOutH, @AOutS, @AOutV);
end;

class function ImGui.ColorConvertFromU32(const AIn: UInt32): TAlphaColorF;
begin
  _igColorConvertU32ToFloat4(@Result, AIn);
end;

class function ImGui.ColorEdit3(const ALabel: PUTF8Char; var AColor: TAlphaColorF; const AFlags: TImGuiColorEditFlags = []): Boolean;
begin
  Result := _igColorEdit3(Pointer(ALabel), @AColor, Cardinal(AFlags));
end;

class function ImGui.ColorEdit4(const ALabel: PUTF8Char; var AColor: TAlphaColorF; const AFlags: TImGuiColorEditFlags = []): Boolean;
begin
  Result := _igColorEdit4(Pointer(ALabel), @AColor, Cardinal(AFlags));
end;

class function ImGui.ColorPicker3(const ALabel: PUTF8Char; var AColor: TAlphaColorF; const AFlags: TImGuiColorEditFlags = []): Boolean;
begin
  Result := _igColorPicker3(Pointer(ALabel), @AColor, Cardinal(AFlags));
end;

class function ImGui.ColorPicker4(const ALabel: PUTF8Char; var AColor: TAlphaColorF; const AFlags: TImGuiColorEditFlags = []; const ARefCol: PAlphaColorF = nil): Boolean;
begin
  Result := _igColorPicker4(Pointer(ALabel), @AColor, Cardinal(AFlags), Pointer(ARefCol));
end;

class procedure ImGui.Columns(const ACount: Integer; const AId: PUTF8Char; const ABorder: Boolean);
begin
  _igColumns(ACount, Pointer(AId), ABorder);
end;

class function ImGui.Combo(const ALabel: PUTF8Char; var ACurrentItem: Integer; const AItems: PPUTF8Char; const AItemsCount: Integer; const APopupMaxHeightInItems: Integer): Boolean;
begin
  Result := _igCombo_Str_arr(Pointer(ALabel), @ACurrentItem, Pointer(AItems), AItemsCount, APopupMaxHeightInItems);
end;

class function ImGui.Combo(const ALabel: PUTF8Char; var ACurrentItem: Integer; const AItemsSeparatedByZeros: PUTF8Char; const APopupMaxHeightInItems: Integer): Boolean;
begin
  Result := _igCombo_Str(Pointer(ALabel), @ACurrentItem, Pointer(AItemsSeparatedByZeros), APopupMaxHeightInItems);
end;

class function ImGui.Combo(const ALabel: PUTF8Char; var ACurrentItem: Integer; const AItemsGetter: TImGuiItemsGetter; const AData: Pointer; const AItemsCount: Integer; const APopupMaxHeightInItems: Integer): Boolean;
begin
  Result := _igCombo_FnBoolPtr(Pointer(ALabel), @ACurrentItem, _ImGuiItemsGetter(AItemsGetter), Pointer(AData), AItemsCount, APopupMaxHeightInItems);
end;

class function ImGui.CreateContext(const ASharedFontAtlas: PImFontAtlas): PImGuiContext;
begin
  Result := Pointer(_igCreateContext(Pointer(ASharedFontAtlas)));
end;

class function ImGui.DebugCheckVersionAndDataLayout(const AVersionStr: PUTF8Char; const ASzIo: NativeUInt; const ASzStyle: NativeUInt; const ASzVec2: NativeUInt; const ASzVec4: NativeUInt; const ASzDrawvert: NativeUInt; const ASzDrawidx: NativeUInt): Boolean;
begin
  Result := _igDebugCheckVersionAndDataLayout(Pointer(AVersionStr), ASzIo, ASzStyle, ASzVec2, ASzVec4, ASzDrawvert, ASzDrawidx);
end;

class procedure ImGui.DebugTextEncoding(const AText: PUTF8Char);
begin
  _igDebugTextEncoding(Pointer(AText));
end;

class procedure ImGui.DestroyContext(const ACtx: PImGuiContext);
begin
  _igDestroyContext(Pointer(ACtx));
end;

class procedure ImGui.DestroyPlatformWindows;
begin
  _igDestroyPlatformWindows();
end;

class function ImGui.DockSpace(const AId: TImGuiID; const ASize: TVector2; const AFlags: TImGuiDockNodeFlags; const AWindowClass: PImGuiWindowClass): TImGuiID;
begin
  Result := TImGuiID(_igDockSpace(_ImGuiID(AId), _ImVec2(ASize), Cardinal(AFlags), Pointer(AWindowClass)));
end;

class function ImGui.DockSpace(const AId: TImGuiID; const AFlags: TImGuiDockNodeFlags = []; const AWindowClass: PImGuiWindowClass = nil): TImGuiID;
begin
  Result := TImGuiID(_igDockSpace(_ImGuiID(AId), _ImVec2(TVector2.Zero), Cardinal(AFlags), Pointer(AWindowClass)));
end;

class function ImGui.DockSpaceOverViewport(const AViewport: PImGuiViewport; const AFlags: TImGuiDockNodeFlags; const AWindowClass: PImGuiWindowClass): TImGuiID;
begin
  Result := TImGuiID(_igDockSpaceOverViewport(Pointer(AViewport), Cardinal(AFlags), Pointer(AWindowClass)));
end;

class function ImGui.DragFloat(const ALabel: PUTF8Char; var AV: Single; const AVSpeed: Single; const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragFloat(Pointer(ALabel), @AV, AVSpeed, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.DragFloat2(const ALabel: PUTF8Char; var AV: Single; const AVSpeed: Single; const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragFloat2(Pointer(ALabel), @AV, AVSpeed, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.DragFloat3(const ALabel: PUTF8Char; var AV: Single; const AVSpeed: Single; const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragFloat3(Pointer(ALabel), @AV, AVSpeed, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.DragFloat4(const ALabel: PUTF8Char; var AV: Single; const AVSpeed: Single; const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragFloat4(Pointer(ALabel), @AV, AVSpeed, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.DragFloatRange2(const ALabel: PUTF8Char; var AVCurrentMin: Single; var AVCurrentMax: Single; const AVSpeed: Single; const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFormatMax: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragFloatRange2(Pointer(ALabel), @AVCurrentMin, @AVCurrentMax, AVSpeed, AVMin, AVMax, Pointer(AFormat), Pointer(AFormatMax), Cardinal(AFlags));
end;

class function ImGui.DragInt(const ALabel: PUTF8Char; var AV: Integer; const AVSpeed: Single; const AVMin: Integer; const AVMax: Integer; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragInt(Pointer(ALabel), @AV, AVSpeed, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.DragInt2(const ALabel: PUTF8Char; var AV: Integer; const AVSpeed: Single; const AVMin: Integer; const AVMax: Integer; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragInt2(Pointer(ALabel), @AV, AVSpeed, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.DragInt3(const ALabel: PUTF8Char; var AV: Integer; const AVSpeed: Single; const AVMin: Integer; const AVMax: Integer; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragInt3(Pointer(ALabel), @AV, AVSpeed, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.DragInt4(const ALabel: PUTF8Char; var AV: Integer; const AVSpeed: Single; const AVMin: Integer; const AVMax: Integer; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragInt4(Pointer(ALabel), @AV, AVSpeed, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.DragIntRange2(const ALabel: PUTF8Char; var AVCurrentMin: Integer; var AVCurrentMax: Integer; const AVSpeed: Single; const AVMin: Integer; const AVMax: Integer; const AFormat: PUTF8Char; const AFormatMax: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragIntRange2(Pointer(ALabel), @AVCurrentMin, @AVCurrentMax, AVSpeed, AVMin, AVMax, Pointer(AFormat), Pointer(AFormatMax), Cardinal(AFlags));
end;

class function ImGui.DragScalar(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; const APData: Pointer; const AVSpeed: Single; const APMin: Pointer; const APMax: Pointer; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragScalar(Pointer(ALabel), _ImGuiDataType(ADataType), Pointer(APData), AVSpeed, Pointer(APMin), Pointer(APMax), Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.DragScalarN(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; const APData: Pointer; const AComponents: Integer; const AVSpeed: Single; const APMin: Pointer; const APMax: Pointer; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragScalarN(Pointer(ALabel), _ImGuiDataType(ADataType), Pointer(APData), AComponents, AVSpeed, Pointer(APMin), Pointer(APMax), Pointer(AFormat), Cardinal(AFlags));
end;

class procedure ImGui.Dummy(const ASize: TVector2);
begin
  _igDummy(_ImVec2(ASize));
end;

class procedure ImGui.&End;
begin
  _igEnd();
end;

class procedure ImGui.EndChild;
begin
  _igEndChild();
end;

class procedure ImGui.EndChildFrame;
begin
  _igEndChildFrame();
end;

class procedure ImGui.EndCombo;
begin
  _igEndCombo();
end;

class procedure ImGui.EndDisabled;
begin
  _igEndDisabled();
end;

class procedure ImGui.EndDragDropSource;
begin
  _igEndDragDropSource();
end;

class procedure ImGui.EndDragDropTarget;
begin
  _igEndDragDropTarget();
end;

class procedure ImGui.EndFrame;
begin
  _igEndFrame();
end;

class procedure ImGui.EndGroup;
begin
  _igEndGroup();
end;

class procedure ImGui.EndListBox;
begin
  _igEndListBox();
end;

class procedure ImGui.EndMainMenuBar;
begin
  _igEndMainMenuBar();
end;

class procedure ImGui.EndMenu;
begin
  _igEndMenu();
end;

class procedure ImGui.EndMenuBar;
begin
  _igEndMenuBar();
end;

class procedure ImGui.EndPopup;
begin
  _igEndPopup();
end;

class procedure ImGui.EndTabBar;
begin
  _igEndTabBar();
end;

class procedure ImGui.EndTabItem;
begin
  _igEndTabItem();
end;

class procedure ImGui.EndTable;
begin
  _igEndTable();
end;

class procedure ImGui.EndTooltip;
begin
  _igEndTooltip();
end;

class function ImGui.FindViewportByID(const AId: TImGuiID): PImGuiViewport;
begin
  Result := Pointer(_igFindViewportByID(_ImGuiID(AId)));
end;

class function ImGui.FindViewportByPlatformHandle(const APlatformHandle: Pointer): PImGuiViewport;
begin
  Result := Pointer(_igFindViewportByPlatformHandle(Pointer(APlatformHandle)));
end;

class procedure ImGui.GetAllocatorFunctions(const APAllocFunc: PImGuiMemAllocFunc; const APFreeFunc: PImGuiMemFreeFunc; const APUserData: PPointer);
begin
  _igGetAllocatorFunctions(Pointer(APAllocFunc), Pointer(APFreeFunc), Pointer(APUserData));
end;

class function ImGui.GetBackgroundDrawList: PImDrawList;
begin
  Result := Pointer(_igGetBackgroundDrawList_Nil());
end;

class function ImGui.GetBackgroundDrawList(const AViewport: PImGuiViewport): PImDrawList;
begin
  Result := Pointer(_igGetBackgroundDrawList_ViewportPtr(Pointer(AViewport)));
end;

class function ImGui.GetClipboardText: String;
begin
  Result := String(UTF8String(_igGetClipboardText()));
end;

class function ImGui.GetColorU32(const AIdx: TImGuiCol; const AAlphaMul: Single): UInt32;
begin
  Result := _igGetColorU32_Col(_ImGuiCol(AIdx), AAlphaMul);
end;

class function ImGui.GetColorU32(const ACol: TAlphaColorF): UInt32;
begin
  Result := _igGetColorU32_Vec4(_ImVec4(ACol));
end;

class function ImGui.GetColorU32(const ACol: UInt32): UInt32;
begin
  Result := _igGetColorU32_U32(ACol);
end;

class function ImGui.GetColumnIndex: Integer;
begin
  Result := _igGetColumnIndex();
end;

class function ImGui.GetColumnOffset(const AColumnIndex: Integer): Single;
begin
  Result := _igGetColumnOffset(AColumnIndex);
end;

class function ImGui.GetColumnWidth(const AColumnIndex: Integer): Single;
begin
  Result := _igGetColumnWidth(AColumnIndex);
end;

class function ImGui.GetColumnsCount: Integer;
begin
  Result := _igGetColumnsCount();
end;

class function ImGui.GetContentRegionAvail: TVector2;
begin
  _igGetContentRegionAvail(@Result);
end;

class function ImGui.GetContentRegionMax: TVector2;
begin
  _igGetContentRegionMax(@Result);
end;

class function ImGui.GetCurrentContext: PImGuiContext;
begin
  Result := Pointer(_igGetCurrentContext());
end;

class function ImGui.GetCursorPos: TVector2;
begin
  _igGetCursorPos(@Result);
end;

class function ImGui.GetCursorPosX: Single;
begin
  Result := _igGetCursorPosX();
end;

class function ImGui.GetCursorPosY: Single;
begin
  Result := _igGetCursorPosY();
end;

class function ImGui.GetCursorScreenPos: TVector2;
begin
  _igGetCursorScreenPos(@Result);
end;

class function ImGui.GetCursorStartPos: TVector2;
begin
  _igGetCursorStartPos(@Result);
end;

class function ImGui.GetDragDropPayload: PImGuiPayload;
begin
  Result := Pointer(_igGetDragDropPayload());
end;

class function ImGui.GetDrawData: PImDrawData;
begin
  Result := Pointer(_igGetDrawData());
end;

class function ImGui.GetDrawListSharedData: PImDrawListSharedData;
begin
  Result := Pointer(_igGetDrawListSharedData());
end;

class function ImGui.GetFont: PImFont;
begin
  Result := Pointer(_igGetFont());
end;

class function ImGui.GetFontSize: Single;
begin
  Result := _igGetFontSize();
end;

class function ImGui.GetFontTexUvWhitePixel: TVector2;
begin
  _igGetFontTexUvWhitePixel(@Result);
end;

class function ImGui.GetFrameCount: Integer;
begin
  Result := _igGetFrameCount();
end;

class function ImGui.GetFrameHeight: Single;
begin
  Result := _igGetFrameHeight();
end;

class function ImGui.GetFrameHeightWithSpacing: Single;
begin
  Result := _igGetFrameHeightWithSpacing();
end;

class function ImGui.GetID(const AStrId: PUTF8Char): TImGuiID;
begin
  Result := TImGuiID(_igGetID_Str(Pointer(AStrId)));
end;

class function ImGui.GetID(const AStrIdBegin: PUTF8Char; const AStrIdEnd: PUTF8Char): TImGuiID;
begin
  Result := TImGuiID(_igGetID_StrStr(Pointer(AStrIdBegin), Pointer(AStrIdEnd)));
end;

class function ImGui.GetID(const APtrId: Pointer): TImGuiID;
begin
  Result := TImGuiID(_igGetID_Ptr(Pointer(APtrId)));
end;

class function ImGui.GetIO: PImGuiIO;
begin
  Result := Pointer(_igGetIO());
end;

class function ImGui.GetItemRectMax: TVector2;
begin
  _igGetItemRectMax(@Result);
end;

class function ImGui.GetItemRectMin: TVector2;
begin
  _igGetItemRectMin(@Result);
end;

class function ImGui.GetItemRectSize: TVector2;
begin
  _igGetItemRectSize(@Result);
end;

class function ImGui.GetKeyIndex(const AKey: TImGuiKey): Integer;
begin
  Result := _igGetKeyIndex(_ImGuiKey(AKey));
end;

class function ImGui.GetKeyName(const AKey: TImGuiKey): String;
begin
  Result := String(UTF8String(_igGetKeyName(_ImGuiKey(AKey))));
end;

class function ImGui.GetKeyPressedAmount(const AKey: TImGuiKey; const ARepeatDelay: Single; const ARate: Single): Integer;
begin
  Result := _igGetKeyPressedAmount(_ImGuiKey(AKey), ARepeatDelay, ARate);
end;

class function ImGui.GetMainViewport: PImGuiViewport;
begin
  Result := Pointer(_igGetMainViewport());
end;

class function ImGui.GetMouseClickedCount(const AButton: TImGuiMouseButton): Integer;
begin
  Result := _igGetMouseClickedCount(_ImGuiMouseButton(AButton));
end;

class function ImGui.GetMouseCursor: TImGuiMouseCursor;
begin
  Result := TImGuiMouseCursor(_igGetMouseCursor());
end;

class function ImGui.GetMouseDragDelta(const AButton: TImGuiMouseButton; const ALockThreshold: Single): TVector2;
begin
  _igGetMouseDragDelta(@Result, _ImGuiMouseButton(AButton), ALockThreshold);
end;

class function ImGui.GetMousePos: TVector2;
begin
  _igGetMousePos(@Result);
end;

class function ImGui.GetMousePosOnOpeningCurrentPopup: TVector2;
begin
  _igGetMousePosOnOpeningCurrentPopup(@Result);
end;

class function ImGui.GetPlatformIO: PImGuiPlatformIO;
begin
  Result := Pointer(_igGetPlatformIO());
end;

class function ImGui.GetScrollMaxX: Single;
begin
  Result := _igGetScrollMaxX();
end;

class function ImGui.GetScrollMaxY: Single;
begin
  Result := _igGetScrollMaxY();
end;

class function ImGui.GetScrollX: Single;
begin
  Result := _igGetScrollX();
end;

class function ImGui.GetScrollY: Single;
begin
  Result := _igGetScrollY();
end;

class function ImGui.GetStateStorage: PImGuiStorage;
begin
  Result := Pointer(_igGetStateStorage());
end;

class function ImGui.GetStyle: PImGuiStyle;
begin
  Result := Pointer(_igGetStyle());
end;

class function ImGui.GetStyleColorName(const AIdx: TImGuiCol): String;
begin
  Result := String(UTF8String(_igGetStyleColorName(_ImGuiCol(AIdx))));
end;

class function ImGui.GetStyleColor(const AIdx: TImGuiCol): PAlphaColorF;
begin
  Result := Pointer(_igGetStyleColorVec4(_ImGuiCol(AIdx)));
end;

class function ImGui.GetTextLineHeight: Single;
begin
  Result := _igGetTextLineHeight();
end;

class function ImGui.GetTextLineHeightWithSpacing: Single;
begin
  Result := _igGetTextLineHeightWithSpacing();
end;

class function ImGui.GetTime: Double;
begin
  Result := _igGetTime();
end;

class function ImGui.GetTreeNodeToLabelSpacing: Single;
begin
  Result := _igGetTreeNodeToLabelSpacing();
end;

class function ImGui.GetVersion: String;
begin
  Result := String(UTF8String(_igGetVersion()));
end;

class function ImGui.GetWindowContentRegionMax: TVector2;
begin
  _igGetWindowContentRegionMax(@Result);
end;

class function ImGui.GetWindowContentRegionMin: TVector2;
begin
  _igGetWindowContentRegionMin(@Result);
end;

class function ImGui.GetWindowDockID: TImGuiID;
begin
  Result := TImGuiID(_igGetWindowDockID());
end;

class function ImGui.GetWindowDpiScale: Single;
begin
  Result := _igGetWindowDpiScale();
end;

class function ImGui.GetWindowDrawList: PImDrawList;
begin
  Result := Pointer(_igGetWindowDrawList());
end;

class function ImGui.GetWindowHeight: Single;
begin
  Result := _igGetWindowHeight();
end;

class function ImGui.GetWindowPos: TVector2;
begin
  _igGetWindowPos(@Result);
end;

class function ImGui.GetWindowSize: TVector2;
begin
  _igGetWindowSize(@Result);
end;

class function ImGui.GetWindowViewport: PImGuiViewport;
begin
  Result := Pointer(_igGetWindowViewport());
end;

class function ImGui.GetWindowWidth: Single;
begin
  Result := _igGetWindowWidth();
end;

class procedure ImGui.Image(const AUserTextureId: TImTextureID; const ASize: TVector2; const AUv0: TVector2; const AUv1: TVector2; const ATintCol: TAlphaColorF; const ABorderCol: TAlphaColorF);
begin
  _igImage(_ImTextureID(AUserTextureId), _ImVec2(ASize), _ImVec2(AUv0), _ImVec2(AUv1), _ImVec4(ATintCol), _ImVec4(ABorderCol));
end;

class procedure ImGui.Image(const AUserTextureId: TImTextureID; const ASize: TVector2; const AUv0: TVector2; const AUv1: TVector2);
begin
  _igImage(_ImTextureID(AUserTextureId), _ImVec2(ASize), _ImVec2(AUv0), _ImVec2(AUv1), _ImVec4(TVector4.One), _ImVec4(TVector4.Zero));
end;

class procedure ImGui.Image(const AUserTextureId: TImTextureID; const ASize: TVector2; const ATintCol: TAlphaColorF; const ABorderCol: TAlphaColorF);
begin
  _igImage(_ImTextureID(AUserTextureId), _ImVec2(ASize), _ImVec2(TVector2.Zero), _ImVec2(TVector2.One), _ImVec4(ATintCol), _ImVec4(ABorderCol));
end;

class procedure ImGui.Image(const AUserTextureId: TImTextureID; const ASize: TVector2);
begin
  _igImage(_ImTextureID(AUserTextureId), _ImVec2(ASize), _ImVec2(TVector2.Zero), _ImVec2(TVector2.One), _ImVec4(TVector4.One), _ImVec4(TVector4.Zero));
end;

class function ImGui.ImageButton(const AUserTextureId: TImTextureID; const ASize: TVector2; const AUv0: TVector2; const AUv1: TVector2; const AFramePadding: Integer; const ABgCol: TAlphaColorF; const ATintCol: TAlphaColorF): Boolean;
begin
  Result := _igImageButton(_ImTextureID(AUserTextureId), _ImVec2(ASize), _ImVec2(AUv0), _ImVec2(AUv1), AFramePadding, _ImVec4(ABgCol), _ImVec4(ATintCol));
end;

class function ImGui.ImageButton(const AUserTextureId: TImTextureID; const ASize: TVector2; const AUv0: TVector2; const AUv1: TVector2; const AFramePadding: Integer = -1): Boolean;
begin
  Result := _igImageButton(_ImTextureID(AUserTextureId), _ImVec2(ASize), _ImVec2(AUv0), _ImVec2(AUv1), AFramePadding, _ImVec4(TVector4.Zero), _ImVec4(TVector4.One));
end;

class function ImGui.ImageButton(const AUserTextureId: TImTextureID; const ASize: TVector2; const ABgCol: TAlphaColorF; const ATintCol: TAlphaColorF; const AFramePadding: Integer = -1): Boolean;
begin
  Result := _igImageButton(_ImTextureID(AUserTextureId), _ImVec2(ASize), _ImVec2(TVector2.Zero), _ImVec2(TVector2.One), AFramePadding, _ImVec4(ABgCol), _ImVec4(ATintCol));
end;

class function ImGui.ImageButton(const AUserTextureId: TImTextureID; const ASize: TVector2; const AFramePadding: Integer = -1): Boolean;
begin
  Result := _igImageButton(_ImTextureID(AUserTextureId), _ImVec2(ASize), _ImVec2(TVector2.Zero), _ImVec2(TVector2.One), AFramePadding, _ImVec4(TVector4.Zero), _ImVec4(TVector4.One));
end;

class procedure ImGui.Indent(const AIndentW: Single);
begin
  _igIndent(AIndentW);
end;

class function ImGui.InputDouble(const ALabel: PUTF8Char; var AV: Double; const AStep: Double; const AStepFast: Double; const AFormat: PUTF8Char; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputDouble(Pointer(ALabel), @AV, AStep, AStepFast, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.InputFloat(const ALabel: PUTF8Char; var AV: Single; const AStep: Single; const AStepFast: Single; const AFormat: PUTF8Char; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputFloat(Pointer(ALabel), @AV, AStep, AStepFast, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.InputFloat2(const ALabel: PUTF8Char; var AV: Single; const AFormat: PUTF8Char; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputFloat2(Pointer(ALabel), @AV, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.InputFloat3(const ALabel: PUTF8Char; var AV: Single; const AFormat: PUTF8Char; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputFloat3(Pointer(ALabel), @AV, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.InputFloat4(const ALabel: PUTF8Char; var AV: Single; const AFormat: PUTF8Char; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputFloat4(Pointer(ALabel), @AV, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.InputInt(const ALabel: PUTF8Char; var AV: Integer; const AStep: Integer; const AStepFast: Integer; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputInt(Pointer(ALabel), @AV, AStep, AStepFast, Cardinal(AFlags));
end;

class function ImGui.InputInt2(const ALabel: PUTF8Char; var AV: Integer; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputInt2(Pointer(ALabel), @AV, Cardinal(AFlags));
end;

class function ImGui.InputInt3(const ALabel: PUTF8Char; var AV: Integer; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputInt3(Pointer(ALabel), @AV, Cardinal(AFlags));
end;

class function ImGui.InputInt4(const ALabel: PUTF8Char; var AV: Integer; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputInt4(Pointer(ALabel), @AV, Cardinal(AFlags));
end;

class function ImGui.InputScalar(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; const APData: Pointer; const APStep: Pointer; const APStepFast: Pointer; const AFormat: PUTF8Char; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputScalar(Pointer(ALabel), _ImGuiDataType(ADataType), Pointer(APData), Pointer(APStep), Pointer(APStepFast), Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.InputScalarN(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; const APData: Pointer; const AComponents: Integer; const APStep: Pointer; const APStepFast: Pointer; const AFormat: PUTF8Char; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputScalarN(Pointer(ALabel), _ImGuiDataType(ADataType), Pointer(APData), AComponents, Pointer(APStep), Pointer(APStepFast), Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.InputText(const ALabel: PUTF8Char; const AText: TImGuiText; const AFlags: TImGuiInputTextFlags = []): Boolean;
begin
  AText.Validate;
  Result := _igInputText(Pointer(ALabel), Pointer(AText.FBuffer), Length(AText.FBuffer), Cardinal(AFlags) or _ImGuiInputTextFlags_CallbackResize, __ImGuiInputTextCallback, @AText);
end;

class function ImGui.InputTextMultiline(const ALabel: PUTF8Char; const AText: TImGuiText; const ASize: TVector2; const AFlags: TImGuiInputTextFlags = []): Boolean;
begin
  AText.Validate;
  Result := _igInputTextMultiline(Pointer(ALabel), Pointer(AText.FBuffer), Length(AText.FBuffer), _ImVec2(ASize), Cardinal(AFlags) or _ImGuiInputTextFlags_CallbackResize, __ImGuiInputTextCallback, @AText);
end;

class function ImGui.InputTextMultiline(const ALabel: PUTF8Char; const AText: TImGuiText; const AFlags: TImGuiInputTextFlags = []): Boolean;
begin
  AText.Validate;
  Result := _igInputTextMultiline(Pointer(ALabel), Pointer(AText.FBuffer), Length(AText.FBuffer), _ImVec2(TVector2.Zero), Cardinal(AFlags) or _ImGuiInputTextFlags_CallbackResize, __ImGuiInputTextCallback, @AText);
end;

class function ImGui.InputTextWithHint(const ALabel: PUTF8Char; const AHint: PUTF8Char; const AText: TImGuiText; const AFlags: TImGuiInputTextFlags = []): Boolean;
begin
  AText.Validate;
  Result := _igInputTextWithHint(Pointer(ALabel), Pointer(AHint), Pointer(AText.FBuffer), Length(AText.FBuffer), Cardinal(AFlags) or _ImGuiInputTextFlags_CallbackResize, __ImGuiInputTextCallback, @AText);
end;

class function ImGui.InvisibleButton(const AStrId: PUTF8Char; const ASize: TVector2; const AFlags: TImGuiButtonFlags): Boolean;
begin
  Result := _igInvisibleButton(Pointer(AStrId), _ImVec2(ASize), Cardinal(AFlags));
end;

class function ImGui.IsAnyItemActive: Boolean;
begin
  Result := _igIsAnyItemActive();
end;

class function ImGui.IsAnyItemFocused: Boolean;
begin
  Result := _igIsAnyItemFocused();
end;

class function ImGui.IsAnyItemHovered: Boolean;
begin
  Result := _igIsAnyItemHovered();
end;

class function ImGui.IsAnyMouseDown: Boolean;
begin
  Result := _igIsAnyMouseDown();
end;

class function ImGui.IsItemActivated: Boolean;
begin
  Result := _igIsItemActivated();
end;

class function ImGui.IsItemActive: Boolean;
begin
  Result := _igIsItemActive();
end;

class function ImGui.IsItemClicked(const AMouseButton: TImGuiMouseButton): Boolean;
begin
  Result := _igIsItemClicked(_ImGuiMouseButton(AMouseButton));
end;

class function ImGui.IsItemDeactivated: Boolean;
begin
  Result := _igIsItemDeactivated();
end;

class function ImGui.IsItemDeactivatedAfterEdit: Boolean;
begin
  Result := _igIsItemDeactivatedAfterEdit();
end;

class function ImGui.IsItemEdited: Boolean;
begin
  Result := _igIsItemEdited();
end;

class function ImGui.IsItemFocused: Boolean;
begin
  Result := _igIsItemFocused();
end;

class function ImGui.IsItemHovered(const AFlags: TImGuiHoveredFlags): Boolean;
begin
  Result := _igIsItemHovered(Cardinal(AFlags));
end;

class function ImGui.IsItemToggledOpen: Boolean;
begin
  Result := _igIsItemToggledOpen();
end;

class function ImGui.IsItemVisible: Boolean;
begin
  Result := _igIsItemVisible();
end;

class function ImGui.IsKeyDown(const AKey: TImGuiKey): Boolean;
begin
  Result := _igIsKeyDown(_ImGuiKey(AKey));
end;

class function ImGui.IsKeyPressed(const AKey: TImGuiKey; const ARepeat: Boolean): Boolean;
begin
  Result := _igIsKeyPressed(_ImGuiKey(AKey), ARepeat);
end;

class function ImGui.IsKeyReleased(const AKey: TImGuiKey): Boolean;
begin
  Result := _igIsKeyReleased(_ImGuiKey(AKey));
end;

class function ImGui.IsMouseClicked(const AButton: TImGuiMouseButton; const ARepeat: Boolean): Boolean;
begin
  Result := _igIsMouseClicked(_ImGuiMouseButton(AButton), ARepeat);
end;

class function ImGui.IsMouseDoubleClicked(const AButton: TImGuiMouseButton): Boolean;
begin
  Result := _igIsMouseDoubleClicked(_ImGuiMouseButton(AButton));
end;

class function ImGui.IsMouseDown(const AButton: TImGuiMouseButton): Boolean;
begin
  Result := _igIsMouseDown(_ImGuiMouseButton(AButton));
end;

class function ImGui.IsMouseDragging(const AButton: TImGuiMouseButton; const ALockThreshold: Single): Boolean;
begin
  Result := _igIsMouseDragging(_ImGuiMouseButton(AButton), ALockThreshold);
end;

class function ImGui.IsMouseHoveringRect(const ARMin: TVector2; const ARMax: TVector2; const AClip: Boolean): Boolean;
begin
  Result := _igIsMouseHoveringRect(_ImVec2(ARMin), _ImVec2(ARMax), AClip);
end;

class function ImGui.IsMousePosValid(const AMousePos: PVector2): Boolean;
begin
  Result := _igIsMousePosValid(Pointer(AMousePos));
end;

class function ImGui.IsMouseReleased(const AButton: TImGuiMouseButton): Boolean;
begin
  Result := _igIsMouseReleased(_ImGuiMouseButton(AButton));
end;

class function ImGui.IsRectVisible(const ASize: TVector2): Boolean;
begin
  Result := _igIsRectVisible_Nil(_ImVec2(ASize));
end;

class function ImGui.IsRectVisible(const ARectMin: TVector2; const ARectMax: TVector2): Boolean;
begin
  Result := _igIsRectVisible_Vec2(_ImVec2(ARectMin), _ImVec2(ARectMax));
end;

class function ImGui.IsWindowAppearing: Boolean;
begin
  Result := _igIsWindowAppearing();
end;

class function ImGui.IsWindowCollapsed: Boolean;
begin
  Result := _igIsWindowCollapsed();
end;

class function ImGui.IsWindowDocked: Boolean;
begin
  Result := _igIsWindowDocked();
end;

class function ImGui.IsWindowFocused(const AFlags: TImGuiFocusedFlags): Boolean;
begin
  Result := _igIsWindowFocused(Cardinal(AFlags));
end;

class function ImGui.IsWindowHovered(const AFlags: TImGuiHoveredFlags): Boolean;
begin
  Result := _igIsWindowHovered(Cardinal(AFlags));
end;

class procedure ImGui.LabelText(const ALabel: PUTF8Char; const AText: PUTF8Char);
begin
  _igLabelText(Pointer(ALabel), Pointer(AText));
end;

class function ImGui.ListBox(const ALabel: PUTF8Char; var ACurrentItem: Integer; const AItems: PPUTF8Char; const AItemsCount: Integer; const AHeightInItems: Integer): Boolean;
begin
  Result := _igListBox_Str_arr(Pointer(ALabel), @ACurrentItem, Pointer(AItems), AItemsCount, AHeightInItems);
end;

class function ImGui.ListBox(const ALabel: PUTF8Char; var ACurrentItem: Integer; const AItemsGetter: TImGuiItemsGetter; const AData: Pointer; const AItemsCount: Integer; const AHeightInItems: Integer): Boolean;
begin
  Result := _igListBox_FnBoolPtr(Pointer(ALabel), @ACurrentItem, _ImGuiItemsGetter(AItemsGetter), Pointer(AData), AItemsCount, AHeightInItems);
end;

class procedure ImGui.LoadIniSettingsFromDisk(const AIniFilename: PUTF8Char);
begin
  _igLoadIniSettingsFromDisk(Pointer(AIniFilename));
end;

class procedure ImGui.LoadIniSettingsFromMemory(const AIniData: PUTF8Char; const AIniSize: NativeUInt);
begin
  _igLoadIniSettingsFromMemory(Pointer(AIniData), AIniSize);
end;

class procedure ImGui.LogButtons;
begin
  _igLogButtons();
end;

class procedure ImGui.LogFinish;
begin
  _igLogFinish();
end;

class procedure ImGui.LogText(const AText: PUTF8Char);
begin
  _igLogText(Pointer(AText));
end;

class procedure ImGui.LogToClipboard(const AAutoOpenDepth: Integer);
begin
  _igLogToClipboard(AAutoOpenDepth);
end;

class procedure ImGui.LogToFile(const AAutoOpenDepth: Integer; const AFilename: PUTF8Char);
begin
  _igLogToFile(AAutoOpenDepth, Pointer(AFilename));
end;

class procedure ImGui.LogToTTY(const AAutoOpenDepth: Integer);
begin
  _igLogToTTY(AAutoOpenDepth);
end;

class function ImGui.MemAlloc(const ASize: NativeUInt): Pointer;
begin
  Result := Pointer(_igMemAlloc(ASize));
end;

class procedure ImGui.MemFree(const APtr: Pointer);
begin
  _igMemFree(Pointer(APtr));
end;

class function ImGui.MenuItem(const ALabel: PUTF8Char; const AShortcut: PUTF8Char; const ASelected: Boolean; const AEnabled: Boolean): Boolean;
begin
  Result := _igMenuItem_Bool(Pointer(ALabel), Pointer(AShortcut), ASelected, AEnabled);
end;

class function ImGui.MenuItem(const ALabel: PUTF8Char; const AShortcut: PUTF8Char; const APSelected: PBoolean; const AEnabled: Boolean): Boolean;
begin
  Result := _igMenuItem_BoolPtr(Pointer(ALabel), Pointer(AShortcut), Pointer(APSelected), AEnabled);
end;

class procedure ImGui.NewFrame;
begin
  _igNewFrame();
end;

class procedure ImGui.NewLine;
begin
  _igNewLine();
end;

class procedure ImGui.NextColumn;
begin
  _igNextColumn();
end;

class procedure ImGui.OpenPopup(const AStrId: PUTF8Char; const APopupFlags: TImGuiPopupFlags);
begin
  _igOpenPopup_Str(Pointer(AStrId), Cardinal(APopupFlags));
end;

class procedure ImGui.OpenPopup(const AId: TImGuiID; const APopupFlags: TImGuiPopupFlags);
begin
  _igOpenPopup_ID(_ImGuiID(AId), Cardinal(APopupFlags));
end;

class procedure ImGui.OpenPopupOnItemClick(const AStrId: PUTF8Char; const APopupFlags: TImGuiPopupFlags);
begin
  _igOpenPopupOnItemClick(Pointer(AStrId), Cardinal(APopupFlags));
end;

class procedure ImGui.PlotHistogram(const ALabel: PUTF8Char; const AValues: PSingle; const AValuesCount: Integer; const AValuesOffset: Integer; const AOverlayText: PUTF8Char; const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2; const AStride: Integer = SizeOf(Single));
begin
  _igPlotHistogram_FloatPtr(Pointer(ALabel), Pointer(AValues), AValuesCount, AValuesOffset, Pointer(AOverlayText), AScaleMin, AScaleMax, _ImVec2(AGraphSize), AStride);
end;

class procedure ImGui.PlotHistogram(const ALabel: PUTF8Char; const AValues: PSingle; const AValuesCount: Integer; const AValuesOffset: Integer = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle; const AStride: Integer = SizeOf(Single));
begin
  _igPlotHistogram_FloatPtr(Pointer(ALabel), Pointer(AValues), AValuesCount, AValuesOffset, Pointer(AOverlayText), AScaleMin, AScaleMax, _ImVec2(TVector2.Zero), AStride);
end;

class procedure ImGui.PlotHistogram(const ALabel: PUTF8Char; const AValues: TArray<Single>; const AValuesOffset: Integer; const AOverlayText: PUTF8Char; const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2; const AStride: Integer = SizeOf(Single));
begin
  _igPlotHistogram_FloatPtr(Pointer(ALabel), Pointer(AValues), Length(AValues), AValuesOffset, Pointer(AOverlayText), AScaleMin, AScaleMax, _ImVec2(AGraphSize), AStride);
end;

class procedure ImGui.PlotHistogram(const ALabel: PUTF8Char; const AValues: TArray<Single>; const AValuesOffset: Integer = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle; const AStride: Integer = SizeOf(Single));
begin
  _igPlotHistogram_FloatPtr(Pointer(ALabel), Pointer(AValues), Length(AValues), AValuesOffset, Pointer(AOverlayText), AScaleMin, AScaleMax, _ImVec2(TVector2.Zero), AStride);
end;

class procedure ImGui.PlotHistogram(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValuesGetter; const AData: Pointer; const AValuesCount: Integer; const AValuesOffset: Integer; const AOverlayText: PUTF8Char; const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2);
begin
  _igPlotHistogram_FnFloatPtr(Pointer(ALabel), _ImGuiValuesGetter(AValuesGetter), Pointer(AData), AValuesCount, AValuesOffset, Pointer(AOverlayText), AScaleMin, AScaleMax, _ImVec2(AGraphSize));
end;

class procedure ImGui.PlotHistogram(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValuesGetter; const AData: Pointer; const AValuesCount: Integer; const AValuesOffset: Integer = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle);
begin
  _igPlotHistogram_FnFloatPtr(Pointer(ALabel), _ImGuiValuesGetter(AValuesGetter), Pointer(AData), AValuesCount, AValuesOffset, Pointer(AOverlayText), AScaleMin, AScaleMax, _ImVec2(TVector2.Zero));
end;

class procedure ImGui.PlotLines(const ALabel: PUTF8Char; const AValues: PSingle; const AValuesCount: Integer; const AValuesOffset: Integer; const AOverlayText: PUTF8Char; const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2; const AStride: Integer = SizeOf(Single));
begin
  _igPlotLines_FloatPtr(Pointer(ALabel), Pointer(AValues), AValuesCount, AValuesOffset, Pointer(AOverlayText), AScaleMin, AScaleMax, _ImVec2(AGraphSize), AStride);
end;

class procedure ImGui.PlotLines(const ALabel: PUTF8Char; const AValues: PSingle; const AValuesCount: Integer; const AValuesOffset: Integer = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle; const AStride: Integer = SizeOf(Single));
begin
  _igPlotLines_FloatPtr(Pointer(ALabel), Pointer(AValues), AValuesCount, AValuesOffset, Pointer(AOverlayText), AScaleMin, AScaleMax, _ImVec2(TVector2.Zero), AStride);
end;

class procedure ImGui.PlotLines(const ALabel: PUTF8Char; const AValues: TArray<Single>; const AValuesOffset: Integer; const AOverlayText: PUTF8Char; const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2; const AStride: Integer = SizeOf(Single));
begin
  _igPlotLines_FloatPtr(Pointer(ALabel), Pointer(AValues), Length(AValues), AValuesOffset, Pointer(AOverlayText), AScaleMin, AScaleMax, _ImVec2(AGraphSize), AStride);
end;

class procedure ImGui.PlotLines(const ALabel: PUTF8Char; const AValues: TArray<Single>; const AValuesOffset: Integer = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle; const AStride: Integer = SizeOf(Single));
begin
  _igPlotLines_FloatPtr(Pointer(ALabel), Pointer(AValues), Length(AValues), AValuesOffset, Pointer(AOverlayText), AScaleMin, AScaleMax, _ImVec2(TVector2.Zero), AStride);
end;

class procedure ImGui.PlotLines(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValuesGetter; const AData: Pointer; const AValuesCount: Integer; const AValuesOffset: Integer; const AOverlayText: PUTF8Char; const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2);
begin
  _igPlotLines_FnFloatPtr(Pointer(ALabel), _ImGuiValuesGetter(AValuesGetter), Pointer(AData), AValuesCount, AValuesOffset, Pointer(AOverlayText), AScaleMin, AScaleMax, _ImVec2(AGraphSize));
end;

class procedure ImGui.PlotLines(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValuesGetter; const AData: Pointer; const AValuesCount: Integer; const AValuesOffset: Integer = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle);
begin
  _igPlotLines_FnFloatPtr(Pointer(ALabel), _ImGuiValuesGetter(AValuesGetter), Pointer(AData), AValuesCount, AValuesOffset, Pointer(AOverlayText), AScaleMin, AScaleMax, _ImVec2(TVector2.Zero));
end;

class procedure ImGui.PopAllowKeyboardFocus;
begin
  _igPopAllowKeyboardFocus();
end;

class procedure ImGui.PopButtonRepeat;
begin
  _igPopButtonRepeat();
end;

class procedure ImGui.PopClipRect;
begin
  _igPopClipRect();
end;

class procedure ImGui.PopFont;
begin
  _igPopFont();
end;

class procedure ImGui.PopID;
begin
  _igPopID();
end;

class procedure ImGui.PopItemWidth;
begin
  _igPopItemWidth();
end;

class procedure ImGui.PopStyleColor(const ACount: Integer);
begin
  _igPopStyleColor(ACount);
end;

class procedure ImGui.PopStyleVar(const ACount: Integer);
begin
  _igPopStyleVar(ACount);
end;

class procedure ImGui.PopTextWrapPos;
begin
  _igPopTextWrapPos();
end;

class procedure ImGui.ProgressBar(const AFraction: Single; const ASizeArg: TVector2; const AOverlay: PUTF8Char);
begin
  _igProgressBar(AFraction, _ImVec2(ASizeArg), Pointer(AOverlay));
end;

class procedure ImGui.ProgressBar(const AFraction: Single; const AOverlay: PUTF8Char = nil);
begin
  _igProgressBar(AFraction, _ImVec2(Vector2(-MinSingle, 0)), Pointer(AOverlay));
end;

class procedure ImGui.PushAllowKeyboardFocus(const AAllowKeyboardFocus: Boolean);
begin
  _igPushAllowKeyboardFocus(AAllowKeyboardFocus);
end;

class procedure ImGui.PushButtonRepeat(const ARepeat: Boolean);
begin
  _igPushButtonRepeat(ARepeat);
end;

class procedure ImGui.PushClipRect(const AClipRectMin: TVector2; const AClipRectMax: TVector2; const AIntersectWithCurrentClipRect: Boolean);
begin
  _igPushClipRect(_ImVec2(AClipRectMin), _ImVec2(AClipRectMax), AIntersectWithCurrentClipRect);
end;

class procedure ImGui.PushFont(const AFont: PImFont);
begin
  _igPushFont(Pointer(AFont));
end;

class procedure ImGui.PushID(const AStrId: PUTF8Char);
begin
  _igPushID_Str(Pointer(AStrId));
end;

class procedure ImGui.PushID(const AStrIdBegin: PUTF8Char; const AStrIdEnd: PUTF8Char);
begin
  _igPushID_StrStr(Pointer(AStrIdBegin), Pointer(AStrIdEnd));
end;

class procedure ImGui.PushID(const APtrId: Pointer);
begin
  _igPushID_Ptr(Pointer(APtrId));
end;

class procedure ImGui.PushID(const AIntId: Integer);
begin
  _igPushID_Int(AIntId);
end;

class procedure ImGui.PushItemWidth(const AItemWidth: Single);
begin
  _igPushItemWidth(AItemWidth);
end;

class procedure ImGui.PushStyleColor(const AIdx: TImGuiCol; const ACol: UInt32);
begin
  _igPushStyleColor_U32(_ImGuiCol(AIdx), ACol);
end;

class procedure ImGui.PushStyleColor(const AIdx: TImGuiCol; const ACol: TAlphaColorF);
begin
  _igPushStyleColor_Vec4(_ImGuiCol(AIdx), _ImVec4(ACol));
end;

class procedure ImGui.PushStyleVar(const AIdx: TImGuiStyleVar; const AVal: Single);
begin
  _igPushStyleVar_Float(_ImGuiStyleVar(AIdx), AVal);
end;

class procedure ImGui.PushStyleVar(const AIdx: TImGuiStyleVar; const AVal: TVector2);
begin
  _igPushStyleVar_Vec2(_ImGuiStyleVar(AIdx), _ImVec2(AVal));
end;

class procedure ImGui.PushTextWrapPos(const AWrapLocalPosX: Single);
begin
  _igPushTextWrapPos(AWrapLocalPosX);
end;

class function ImGui.RadioButton(const ALabel: PUTF8Char; const AActive: Boolean): Boolean;
begin
  Result := _igRadioButton_Bool(Pointer(ALabel), AActive);
end;

class function ImGui.RadioButton(const ALabel: PUTF8Char; var AV: Integer; const AVButton: Integer): Boolean;
begin
  Result := _igRadioButton_IntPtr(Pointer(ALabel), @AV, AVButton);
end;

class procedure ImGui.Render;
begin
  _igRender();
end;

class procedure ImGui.RenderPlatformWindowsDefault(const APlatformRenderArg: Pointer; const ARendererRenderArg: Pointer);
begin
  _igRenderPlatformWindowsDefault(Pointer(APlatformRenderArg), Pointer(ARendererRenderArg));
end;

class procedure ImGui.ResetMouseDragDelta(const AButton: TImGuiMouseButton);
begin
  _igResetMouseDragDelta(_ImGuiMouseButton(AButton));
end;

class procedure ImGui.SameLine(const AOffsetFromStartX: Single; const ASpacing: Single);
begin
  _igSameLine(AOffsetFromStartX, ASpacing);
end;

class procedure ImGui.SaveIniSettingsToDisk(const AIniFilename: PUTF8Char);
begin
  _igSaveIniSettingsToDisk(Pointer(AIniFilename));
end;

class function ImGui.SaveIniSettingsToMemory(const AOutIniSize: PNativeUInt = nil): String;
begin
  Result := String(UTF8String(_igSaveIniSettingsToMemory(Pointer(AOutIniSize))));
end;

class function ImGui.Selectable(const ALabel: PUTF8Char; const ASelected: Boolean; const AFlags: TImGuiSelectableFlags; const ASize: TVector2): Boolean;
begin
  Result := _igSelectable_Bool(Pointer(ALabel), ASelected, Cardinal(AFlags), _ImVec2(ASize));
end;

class function ImGui.Selectable(const ALabel: PUTF8Char; const ASelected: Boolean = False; const AFlags: TImGuiSelectableFlags = []): Boolean;
begin
  Result := _igSelectable_Bool(Pointer(ALabel), ASelected, Cardinal(AFlags), _ImVec2(TVector2.Zero));
end;

class function ImGui.Selectable(const ALabel: PUTF8Char; const APSelected: PBoolean; const AFlags: TImGuiSelectableFlags; const ASize: TVector2): Boolean;
begin
  Result := _igSelectable_BoolPtr(Pointer(ALabel), Pointer(APSelected), Cardinal(AFlags), _ImVec2(ASize));
end;

class function ImGui.Selectable(const ALabel: PUTF8Char; const APSelected: PBoolean; const AFlags: TImGuiSelectableFlags = []): Boolean;
begin
  Result := _igSelectable_BoolPtr(Pointer(ALabel), Pointer(APSelected), Cardinal(AFlags), _ImVec2(TVector2.Zero));
end;

class procedure ImGui.Separator;
begin
  _igSeparator();
end;

class procedure ImGui.SetAllocatorFunctions(const AAllocFunc: TImGuiMemAllocFunc; const AFreeFunc: TImGuiMemFreeFunc; const AUserData: Pointer);
begin
  _igSetAllocatorFunctions(_ImGuiMemAllocFunc(AAllocFunc), _ImGuiMemFreeFunc(AFreeFunc), Pointer(AUserData));
end;

class procedure ImGui.SetClipboardText(const AText: PUTF8Char);
begin
  _igSetClipboardText(Pointer(AText));
end;

class procedure ImGui.SetColorEditOptions(const AFlags: TImGuiColorEditFlags);
begin
  _igSetColorEditOptions(Cardinal(AFlags));
end;

class procedure ImGui.SetColumnOffset(const AColumnIndex: Integer; const AOffsetX: Single);
begin
  _igSetColumnOffset(AColumnIndex, AOffsetX);
end;

class procedure ImGui.SetColumnWidth(const AColumnIndex: Integer; const AWidth: Single);
begin
  _igSetColumnWidth(AColumnIndex, AWidth);
end;

class procedure ImGui.SetCurrentContext(const ACtx: PImGuiContext);
begin
  _igSetCurrentContext(Pointer(ACtx));
end;

class procedure ImGui.SetCursorPos(const ALocalPos: TVector2);
begin
  _igSetCursorPos(_ImVec2(ALocalPos));
end;

class procedure ImGui.SetCursorPosX(const ALocalX: Single);
begin
  _igSetCursorPosX(ALocalX);
end;

class procedure ImGui.SetCursorPosY(const ALocalY: Single);
begin
  _igSetCursorPosY(ALocalY);
end;

class procedure ImGui.SetCursorScreenPos(const APos: TVector2);
begin
  _igSetCursorScreenPos(_ImVec2(APos));
end;

class function ImGui.SetDragDropPayload(const AType: PUTF8Char; const AData: Pointer; const ASz: NativeUInt; const ACond: TImGuiCond): Boolean;
begin
  Result := _igSetDragDropPayload(Pointer(AType), Pointer(AData), ASz, _ImGuiCond(ACond));
end;

class procedure ImGui.SetItemAllowOverlap;
begin
  _igSetItemAllowOverlap();
end;

class procedure ImGui.SetItemDefaultFocus;
begin
  _igSetItemDefaultFocus();
end;

class procedure ImGui.SetKeyboardFocusHere(const AOffset: Integer);
begin
  _igSetKeyboardFocusHere(AOffset);
end;

class procedure ImGui.SetMouseCursor(const ACursorType: TImGuiMouseCursor);
begin
  _igSetMouseCursor(_ImGuiMouseCursor(ACursorType));
end;

class procedure ImGui.SetNextFrameWantCaptureKeyboard(const AWantCaptureKeyboard: Boolean);
begin
  _igSetNextFrameWantCaptureKeyboard(AWantCaptureKeyboard);
end;

class procedure ImGui.SetNextFrameWantCaptureMouse(const AWantCaptureMouse: Boolean);
begin
  _igSetNextFrameWantCaptureMouse(AWantCaptureMouse);
end;

class procedure ImGui.SetNextItemOpen(const AIsOpen: Boolean; const ACond: TImGuiCond);
begin
  _igSetNextItemOpen(AIsOpen, _ImGuiCond(ACond));
end;

class procedure ImGui.SetNextItemWidth(const AItemWidth: Single);
begin
  _igSetNextItemWidth(AItemWidth);
end;

class procedure ImGui.SetNextWindowBgAlpha(const AAlpha: Single);
begin
  _igSetNextWindowBgAlpha(AAlpha);
end;

class procedure ImGui.SetNextWindowClass(const AWindowClass: PImGuiWindowClass);
begin
  _igSetNextWindowClass(Pointer(AWindowClass));
end;

class procedure ImGui.SetNextWindowCollapsed(const ACollapsed: Boolean; const ACond: TImGuiCond);
begin
  _igSetNextWindowCollapsed(ACollapsed, _ImGuiCond(ACond));
end;

class procedure ImGui.SetNextWindowContentSize(const ASize: TVector2);
begin
  _igSetNextWindowContentSize(_ImVec2(ASize));
end;

class procedure ImGui.SetNextWindowDockID(const ADockId: TImGuiID; const ACond: TImGuiCond);
begin
  _igSetNextWindowDockID(_ImGuiID(ADockId), _ImGuiCond(ACond));
end;

class procedure ImGui.SetNextWindowFocus;
begin
  _igSetNextWindowFocus();
end;

class procedure ImGui.SetNextWindowPos(const APos: TVector2; const ACond: TImGuiCond; const APivot: TVector2);
begin
  _igSetNextWindowPos(_ImVec2(APos), _ImGuiCond(ACond), _ImVec2(APivot));
end;

class procedure ImGui.SetNextWindowPos(const APos: TVector2; const ACond: TImGuiCond = TImGuiCond.None);
begin
  _igSetNextWindowPos(_ImVec2(APos), _ImGuiCond(ACond), _ImVec2(TVector2.Zero));
end;

class procedure ImGui.SetNextWindowSize(const ASize: TVector2; const ACond: TImGuiCond);
begin
  _igSetNextWindowSize(_ImVec2(ASize), _ImGuiCond(ACond));
end;

class procedure ImGui.SetNextWindowSizeConstraints(const ASizeMin: TVector2; const ASizeMax: TVector2; const ACustomCallback: TImGuiSizeCallback; const ACustomCallbackData: Pointer);
begin
  _igSetNextWindowSizeConstraints(_ImVec2(ASizeMin), _ImVec2(ASizeMax), _ImGuiSizeCallback(ACustomCallback), Pointer(ACustomCallbackData));
end;

class procedure ImGui.SetNextWindowViewport(const AViewportId: TImGuiID);
begin
  _igSetNextWindowViewport(_ImGuiID(AViewportId));
end;

class procedure ImGui.SetScrollHereX(const ACenterXRatio: Single);
begin
  _igSetScrollHereX(ACenterXRatio);
end;

class procedure ImGui.SetScrollHereY(const ACenterYRatio: Single);
begin
  _igSetScrollHereY(ACenterYRatio);
end;

class procedure ImGui.SetStateStorage(const AStorage: PImGuiStorage);
begin
  _igSetStateStorage(Pointer(AStorage));
end;

class procedure ImGui.SetTabItemClosed(const ATabOrDockedWindowLabel: PUTF8Char);
begin
  _igSetTabItemClosed(Pointer(ATabOrDockedWindowLabel));
end;

class procedure ImGui.SetTooltip(const AText: PUTF8Char);
begin
  _igSetTooltip(Pointer(AText));
end;

class procedure ImGui.SetTooltipV(const AText: PUTF8Char; const AArgs: Pointer);
begin
  _igSetTooltipV(Pointer(AText), Pointer(AArgs));
end;

class procedure ImGui.SetWindowFocus;
begin
  _igSetWindowFocus_Nil();
end;

class procedure ImGui.SetWindowFocus(const AName: PUTF8Char);
begin
  _igSetWindowFocus_Str(Pointer(AName));
end;

class procedure ImGui.SetWindowFontScale(const AScale: Single);
begin
  _igSetWindowFontScale(AScale);
end;

class procedure ImGui.ShowAboutWindow(const APOpen: PBoolean);
begin
  _igShowAboutWindow(Pointer(APOpen));
end;

class procedure ImGui.ShowDebugLogWindow(const APOpen: PBoolean);
begin
  _igShowDebugLogWindow(Pointer(APOpen));
end;

class procedure ImGui.ShowDemoWindow(const APOpen: PBoolean);
begin
  _igShowDemoWindow(Pointer(APOpen));
end;

class procedure ImGui.ShowFontSelector(const ALabel: PUTF8Char);
begin
  _igShowFontSelector(Pointer(ALabel));
end;

class procedure ImGui.ShowMetricsWindow(const APOpen: PBoolean);
begin
  _igShowMetricsWindow(Pointer(APOpen));
end;

class procedure ImGui.ShowStackToolWindow(const APOpen: PBoolean);
begin
  _igShowStackToolWindow(Pointer(APOpen));
end;

class procedure ImGui.ShowStyleEditor(const ARef: PImGuiStyle);
begin
  _igShowStyleEditor(Pointer(ARef));
end;

class function ImGui.ShowStyleSelector(const ALabel: PUTF8Char): Boolean;
begin
  Result := _igShowStyleSelector(Pointer(ALabel));
end;

class procedure ImGui.ShowUserGuide;
begin
  _igShowUserGuide();
end;

class function ImGui.SliderAngle(const ALabel: PUTF8Char; var AVRad: Single; const AVDegreesMin: Single; const AVDegreesMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderAngle(Pointer(ALabel), @AVRad, AVDegreesMin, AVDegreesMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.SliderFloat(const ALabel: PUTF8Char; var AV: Single; const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderFloat(Pointer(ALabel), @AV, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.SliderFloat2(const ALabel: PUTF8Char; var AV: Single; const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderFloat2(Pointer(ALabel), @AV, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.SliderFloat3(const ALabel: PUTF8Char; var AV: Single; const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderFloat3(Pointer(ALabel), @AV, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.SliderFloat4(const ALabel: PUTF8Char; var AV: Single; const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderFloat4(Pointer(ALabel), @AV, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.SliderInt(const ALabel: PUTF8Char; var AV: Integer; const AVMin: Integer; const AVMax: Integer; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderInt(Pointer(ALabel), @AV, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.SliderInt2(const ALabel: PUTF8Char; var AV: Integer; const AVMin: Integer; const AVMax: Integer; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderInt2(Pointer(ALabel), @AV, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.SliderInt3(const ALabel: PUTF8Char; var AV: Integer; const AVMin: Integer; const AVMax: Integer; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderInt3(Pointer(ALabel), @AV, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.SliderInt4(const ALabel: PUTF8Char; var AV: Integer; const AVMin: Integer; const AVMax: Integer; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderInt4(Pointer(ALabel), @AV, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.SliderScalar(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; const APData: Pointer; const APMin: Pointer; const APMax: Pointer; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderScalar(Pointer(ALabel), _ImGuiDataType(ADataType), Pointer(APData), Pointer(APMin), Pointer(APMax), Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.SliderScalarN(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; const APData: Pointer; const AComponents: Integer; const APMin: Pointer; const APMax: Pointer; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderScalarN(Pointer(ALabel), _ImGuiDataType(ADataType), Pointer(APData), AComponents, Pointer(APMin), Pointer(APMax), Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.SmallButton(const ALabel: PUTF8Char): Boolean;
begin
  Result := _igSmallButton(Pointer(ALabel));
end;

class procedure ImGui.Spacing;
begin
  _igSpacing();
end;

class procedure ImGui.StyleColorsClassic(const ADst: PImGuiStyle);
begin
  _igStyleColorsClassic(Pointer(ADst));
end;

class procedure ImGui.StyleColorsDark(const ADst: PImGuiStyle);
begin
  _igStyleColorsDark(Pointer(ADst));
end;

class procedure ImGui.StyleColorsLight(const ADst: PImGuiStyle);
begin
  _igStyleColorsLight(Pointer(ADst));
end;

class function ImGui.TabItemButton(const ALabel: PUTF8Char; const AFlags: TImGuiTabItemFlags): Boolean;
begin
  Result := _igTabItemButton(Pointer(ALabel), Cardinal(AFlags));
end;

class function ImGui.TableGetColumnCount: Integer;
begin
  Result := _igTableGetColumnCount();
end;

class function ImGui.TableGetColumnFlags(const AColumnN: Integer): TImGuiTableColumnFlags;
begin
  Cardinal(Result) := _igTableGetColumnFlags(AColumnN);
end;

class function ImGui.TableGetColumnIndex: Integer;
begin
  Result := _igTableGetColumnIndex();
end;

class function ImGui.TableGetRowIndex: Integer;
begin
  Result := _igTableGetRowIndex();
end;

class function ImGui.TableGetSortSpecs: PImGuiTableSortSpecs;
begin
  Result := Pointer(_igTableGetSortSpecs());
end;

class procedure ImGui.TableHeader(const ALabel: PUTF8Char);
begin
  _igTableHeader(Pointer(ALabel));
end;

class procedure ImGui.TableHeadersRow;
begin
  _igTableHeadersRow();
end;

class function ImGui.TableNextColumn: Boolean;
begin
  Result := _igTableNextColumn();
end;

class procedure ImGui.TableNextRow(const ARowFlags: TImGuiTableRowFlags; const AMinRowHeight: Single);
begin
  _igTableNextRow(Cardinal(ARowFlags), AMinRowHeight);
end;

class procedure ImGui.TableSetBgColor(const ATarget: TImGuiTableBgTarget; const AColor: UInt32; const AColumnN: Integer);
begin
  _igTableSetBgColor(_ImGuiTableBgTarget(ATarget), AColor, AColumnN);
end;

class procedure ImGui.TableSetColumnEnabled(const AColumnN: Integer; const AV: Boolean);
begin
  _igTableSetColumnEnabled(AColumnN, AV);
end;

class function ImGui.TableSetColumnIndex(const AColumnN: Integer): Boolean;
begin
  Result := _igTableSetColumnIndex(AColumnN);
end;

class procedure ImGui.TableSetupColumn(const ALabel: PUTF8Char; const AFlags: TImGuiTableColumnFlags; const AInitWidthOrWeight: Single; const AUserId: TImGuiID);
begin
  _igTableSetupColumn(Pointer(ALabel), Cardinal(AFlags), AInitWidthOrWeight, _ImGuiID(AUserId));
end;

class procedure ImGui.TableSetupScrollFreeze(const ACols: Integer; const ARows: Integer);
begin
  _igTableSetupScrollFreeze(ACols, ARows);
end;

class procedure ImGui.Text(const AText: PUTF8Char);
begin
  _igText(Pointer(AText));
end;

class procedure ImGui.TextColored(const ACol: TAlphaColorF; const AText: PUTF8Char);
begin
  _igTextColored(_ImVec4(ACol), Pointer(AText));
end;

class procedure ImGui.TextColoredV(const ACol: TAlphaColorF; const AText: PUTF8Char; const AArgs: Pointer);
begin
  _igTextColoredV(_ImVec4(ACol), Pointer(AText), Pointer(AArgs));
end;

class procedure ImGui.TextDisabled(const AText: PUTF8Char);
begin
  _igTextDisabled(Pointer(AText));
end;

class procedure ImGui.TextDisabledV(const AText: PUTF8Char; const AArgs: Pointer);
begin
  _igTextDisabledV(Pointer(AText), Pointer(AArgs));
end;

class procedure ImGui.TextUnformatted(const AText: PUTF8Char; const ATextEnd: PUTF8Char);
begin
  _igTextUnformatted(Pointer(AText), Pointer(ATextEnd));
end;

class procedure ImGui.TextWrapped(const AText: PUTF8Char);
begin
  _igTextWrapped(Pointer(AText));
end;

class function ImGui.TreeNode(const ALabel: PUTF8Char): Boolean;
begin
  Result := _igTreeNode_Str(Pointer(ALabel));
end;

class function ImGui.TreeNode(const AStrId: PUTF8Char; const AText: PUTF8Char): Boolean;
begin
  Result := _igTreeNode_StrStr(Pointer(AStrId), Pointer(AText));
end;

class function ImGui.TreeNode(const APtrId: Pointer; const AText: PUTF8Char): Boolean;
begin
  Result := _igTreeNode_Ptr(Pointer(APtrId), Pointer(AText));
end;

class function ImGui.TreeNodeEx(const ALabel: PUTF8Char; const AFlags: TImGuiTreeNodeFlags): Boolean;
begin
  Result := _igTreeNodeEx_Str(Pointer(ALabel), Cardinal(AFlags));
end;

class function ImGui.TreeNodeEx(const AStrId: PUTF8Char; const AFlags: TImGuiTreeNodeFlags; const AText: PUTF8Char): Boolean;
begin
  Result := _igTreeNodeEx_StrStr(Pointer(AStrId), Cardinal(AFlags), Pointer(AText));
end;

class function ImGui.TreeNodeEx(const APtrId: Pointer; const AFlags: TImGuiTreeNodeFlags; const AText: PUTF8Char): Boolean;
begin
  Result := _igTreeNodeEx_Ptr(Pointer(APtrId), Cardinal(AFlags), Pointer(AText));
end;

class function ImGui.TreeNodeExV(const AStrId: PUTF8Char; const AFlags: TImGuiTreeNodeFlags; const AText: PUTF8Char; const AArgs: Pointer): Boolean;
begin
  Result := _igTreeNodeExV_Str(Pointer(AStrId), Cardinal(AFlags), Pointer(AText), Pointer(AArgs));
end;

class function ImGui.TreeNodeExV(const APtrId: Pointer; const AFlags: TImGuiTreeNodeFlags; const AText: PUTF8Char; const AArgs: Pointer): Boolean;
begin
  Result := _igTreeNodeExV_Ptr(Pointer(APtrId), Cardinal(AFlags), Pointer(AText), Pointer(AArgs));
end;

class function ImGui.TreeNodeV(const AStrId: PUTF8Char; const AText: PUTF8Char; const AArgs: Pointer): Boolean;
begin
  Result := _igTreeNodeV_Str(Pointer(AStrId), Pointer(AText), Pointer(AArgs));
end;

class function ImGui.TreeNodeV(const APtrId: Pointer; const AText: PUTF8Char; const AArgs: Pointer): Boolean;
begin
  Result := _igTreeNodeV_Ptr(Pointer(APtrId), Pointer(AText), Pointer(AArgs));
end;

class procedure ImGui.TreePop;
begin
  _igTreePop();
end;

class procedure ImGui.TreePush(const AStrId: PUTF8Char);
begin
  _igTreePush_Str(Pointer(AStrId));
end;

class procedure ImGui.TreePush(const APtrId: Pointer);
begin
  _igTreePush_Ptr(Pointer(APtrId));
end;

class procedure ImGui.Unindent(const AIndentW: Single);
begin
  _igUnindent(AIndentW);
end;

class procedure ImGui.UpdatePlatformWindows;
begin
  _igUpdatePlatformWindows();
end;

class function ImGui.VSliderFloat(const ALabel: PUTF8Char; const ASize: TVector2; var AV: Single; const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igVSliderFloat(Pointer(ALabel), _ImVec2(ASize), @AV, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.VSliderInt(const ALabel: PUTF8Char; const ASize: TVector2; var AV: Integer; const AVMin: Integer; const AVMax: Integer; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igVSliderInt(Pointer(ALabel), _ImVec2(ASize), @AV, AVMin, AVMax, Pointer(AFormat), Cardinal(AFlags));
end;

class function ImGui.VSliderScalar(const ALabel: PUTF8Char; const ASize: TVector2; const ADataType: TImGuiDataType; const APData: Pointer; const APMin: Pointer; const APMax: Pointer; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igVSliderScalar(Pointer(ALabel), _ImVec2(ASize), _ImGuiDataType(ADataType), Pointer(APData), Pointer(APMin), Pointer(APMax), Pointer(AFormat), Cardinal(AFlags));
end;

class procedure ImGui.Value(const APrefix: PUTF8Char; const AB: Boolean);
begin
  _igValue_Bool(Pointer(APrefix), AB);
end;

class procedure ImGui.Value(const APrefix: PUTF8Char; const AV: Integer);
begin
  _igValue_Int(Pointer(APrefix), AV);
end;

class procedure ImGui.Value(const APrefix: PUTF8Char; const AV: Cardinal);
begin
  _igValue_Uint(Pointer(APrefix), AV);
end;

class procedure ImGui.Value(const APrefix: PUTF8Char; const AV: Single; const AFloatFormat: PUTF8Char);
begin
  _igValue_Float(Pointer(APrefix), AV, Pointer(AFloatFormat));
end;

initialization
  Assert(SizeOf(TImDrawCmd) = SizeOf(_ImDrawCmd));
  Assert(SizeOf(TImDrawChannel) = SizeOf(_ImDrawChannel));
  Assert(SizeOf(TImDrawCmdHeader) = SizeOf(_ImDrawCmdHeader));
  Assert(SizeOf(TImDrawData) = SizeOf(_ImDrawData));
  Assert(SizeOf(TImDrawListSplitter) = SizeOf(_ImDrawListSplitter));
  Assert(SizeOf(TImDrawVert) = SizeOf(_ImDrawVert));
  Assert(SizeOf(TImDrawList) = SizeOf(_ImDrawList));
  Assert(SizeOf(TImFontGlyph) = SizeOf(_ImFontGlyph));
  Assert(SizeOf(TImFont) = SizeOf(_ImFont));
  Assert(SizeOf(TImFontConfig) = SizeOf(_ImFontConfig));
  Assert(SizeOf(TImFontAtlasCustomRect) = SizeOf(_ImFontAtlasCustomRect));
  Assert(SizeOf(TImFontAtlas) = SizeOf(_ImFontAtlas));
  Assert(SizeOf(TImFontGlyphRangesBuilder) = SizeOf(_ImFontGlyphRangesBuilder));
  Assert(SizeOf(TImGuiTextBuffer) = SizeOf(_ImGuiTextBuffer));
  Assert(SizeOf(TImGuiStoragePair) = SizeOf(_ImGuiStoragePair));
  Assert(SizeOf(TImGuiStorage) = SizeOf(_ImGuiStorage));
  Assert(SizeOf(TImGuiPlatformImeData) = SizeOf(_ImGuiPlatformImeData));
  Assert(SizeOf(TImGuiTableSortSpecs) = SizeOf(_ImGuiTableSortSpecs));
  Assert(SizeOf(TImGuiTableColumnSortSpecs) = SizeOf(_ImGuiTableColumnSortSpecs));
  Assert(SizeOf(TImGuiPayload) = SizeOf(_ImGuiPayload));
  Assert(SizeOf(TImGuiPlatformMonitor) = SizeOf(_ImGuiPlatformMonitor));
  Assert(SizeOf(TImGuiWindowClass) = SizeOf(_ImGuiWindowClass));
  Assert(SizeOf(TImGuiStyle) = SizeOf(_ImGuiStyle));
  Assert(SizeOf(TImGuiPlatformIO) = SizeOf(_ImGuiPlatformIO));
  Assert(SizeOf(TImGuiKeyData) = SizeOf(_ImGuiKeyData));
  Assert(SizeOf(TImGuiIO) = SizeOf(_ImGuiIO));
  Assert(SizeOf(TImGuiInputTextCallbackData) = SizeOf(_ImGuiInputTextCallbackData));
  Assert(SizeOf(TImGuiListClipper) = SizeOf(_ImGuiListClipper));
  Assert(SizeOf(TImGuiOnceUponAFrame) = SizeOf(_ImGuiOnceUponAFrame));
  Assert(SizeOf(TImGuiSizeCallbackData) = SizeOf(_ImGuiSizeCallbackData));
  Assert(SizeOf(TImGuiTextRange) = SizeOf(_ImGuiTextRange));
  Assert(SizeOf(TImGuiTextFilter) = SizeOf(_ImGuiTextFilter));
  Assert(SizeOf(TImGuiViewport) = SizeOf(_ImGuiViewport));

end.

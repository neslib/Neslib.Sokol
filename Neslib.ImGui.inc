type
  // Typedefs
  _size_t = NativeUInt;
  _ImDrawIdx = UInt16;
  _ImGuiID = UInt32;
  _ImS8 = UTF8Char;
  _ImU8 = UInt8;
  _ImS16 = Int16;
  _ImU16 = UInt16;
  _ImS32 = Int32;
  _ImU32 = UInt32;
  _ImS64 = Int64;
  _ImU64 = UInt64;
  _ImDrawTextFlags = Int32;
  _ImGuiKeyChord = Int32;
  _ImWchar32 = UInt32;
  _ImWchar16 = UInt16;
  _ImWchar = _ImWchar16;
  _ImGuiSelectionUserData = _ImS64;
  _ImGuiInputTextCallback = function(data: Pointer): Int32; cdecl;
  _ImGuiSizeCallback = procedure(data: Pointer); cdecl;
  _ImGuiMemAllocFunc = function(sz: NativeUInt; user_data: Pointer): Pointer; cdecl;
  _ImGuiMemFreeFunc = procedure(ptr: Pointer; user_data: Pointer); cdecl;
  _ImTextureID = _ImU64;
  _ImDrawCallback = procedure(parent_list: Pointer; cmd: Pointer); cdecl;
  _ImFontAtlasRectId = Int32;

type
  // Enums
  _ImGuiWindowFlags = Integer;
  _ImGuiChildFlags = Integer;
  _ImGuiItemFlags = Integer;
  _ImGuiInputTextFlags = Integer;
  _ImGuiTreeNodeFlags = Integer;
  _ImGuiPopupFlags = Integer;
  _ImGuiSelectableFlags = Integer;
  _ImGuiComboFlags = Integer;
  _ImGuiTabBarFlags = Integer;
  _ImGuiTabItemFlags = Integer;
  _ImGuiFocusedFlags = Integer;
  _ImGuiHoveredFlags = Integer;
  _ImGuiDockNodeFlags = Integer;
  _ImGuiDragDropFlags = Integer;
  _ImGuiDataType = Integer;
  _ImGuiDir = Integer;
  _ImGuiSortDirection = Integer;
  _ImGuiKey = Integer;
  _ImGuiInputFlags = Integer;
  _ImGuiConfigFlags = Integer;
  _ImGuiBackendFlags = Integer;
  _ImGuiCol = Integer;
  _ImGuiStyleVar = Integer;
  _ImGuiButtonFlags = Integer;
  _ImGuiColorEditFlags = Integer;
  _ImGuiSliderFlags = Integer;
  _ImGuiMouseButton = Integer;
  _ImGuiMouseCursor = Integer;
  _ImGuiMouseSource = Integer;
  _ImGuiCond = Integer;
  _ImGuiTableFlags = Integer;
  _ImGuiTableColumnFlags = Integer;
  _ImGuiTableRowFlags = Integer;
  _ImGuiTableBgTarget = Integer;
  _ImGuiListClipperFlags = Integer;
  _ImGuiMultiSelectFlags = Integer;
  _ImGuiSelectionRequestType = Integer;
  _ImDrawFlags = Integer;
  _ImDrawListFlags = Integer;
  _ImTextureFormat = Integer;
  _ImTextureStatus = Integer;
  _ImFontAtlasFlags = Integer;
  _ImFontFlags = Integer;
  _ImGuiViewportFlags = Integer;

const
  // Enum counts
  _ImGuiDataType_COUNT = 12;
  _ImGuiDir_COUNT = 4;
  _ImGuiKey_NamedKey_COUNT = 155;
  _ImGuiCol_COUNT = 63;
  _ImGuiStyleVar_COUNT = 43;
  _ImGuiMouseButton_COUNT = 5;
  _ImGuiMouseCursor_COUNT = 11;
  _ImGuiMouseSource_COUNT = 3;

const
  // Defines
  _IMGUI_VERSION = '1.92.8';
  _IMGUI_VERSION_NUM = 19280;
  _IMGUI_PAYLOAD_TYPE_COLOR_3F = '_COL3F';
  _IMGUI_PAYLOAD_TYPE_COLOR_4F = '_COL4F';
  _IM_UNICODE_CODEPOINT_INVALID = $FFFD;
  _IM_UNICODE_CODEPOINT_MAX = $FFFF;
  _IM_COL32_R_SHIFT = 0;
  _IM_COL32_G_SHIFT = 8;
  _IM_COL32_B_SHIFT = 16;
  _IM_COL32_A_SHIFT = 24;
  _IM_COL32_A_MASK = $FF000000;
  _IM_DRAWLIST_TEX_LINES_WIDTH_MAX = 32;
  _ImFontAtlasRectId_Invalid = -1;

type
  // Structs
  _ImDrawListSharedData = record
  end;

  _ImFontAtlasBuilder = record
  end;

  _ImFontLoader = record
  end;

  _ImGuiContext = record
  end;

  _ImVec2 = record
    _x: Single;
    _y: Single;
  end;

  _ImVec4 = record
    _x: Single;
    _y: Single;
    _z: Single;
    _w: Single;
  end;

  _ImTextureRef = record
    __TexData: Pointer;
    __TexID: _ImTextureID;
  end;

  _ImGuiTableSortSpecs = record
    _Specs: Pointer;
    _SpecsCount: Int32;
    _SpecsDirty: Boolean;
  end;

  _ImGuiTableColumnSortSpecs = record
    _ColumnUserID: _ImGuiID;
    _ColumnIndex: _ImS16;
    _SortOrder: _ImS16;
    _SortDirection: _ImGuiSortDirection;
  end;

  _ImVector_ImGuiTextRange = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_char = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImGuiStoragePair = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImGuiSelectionRequest = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImDrawChannel = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImDrawCmd = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImDrawIdx = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImDrawVert = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImVec2 = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImVec4 = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImTextureRef = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImU8 = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImDrawListPtr = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImTextureRect = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImU32 = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImWchar = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImFontPtr = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImFontConfig = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImDrawListSharedDataPtr = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_float = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImU16 = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImFontGlyph = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImFontConfigPtr = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImGuiPlatformMonitor = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImTextureDataPtr = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImVector_ImGuiViewportPtr = record
    _Size: Int32;
    _Capacity: Int32;
    _Data: Pointer;
  end;

  _ImGuiStyle = record
    _FontSizeBase: Single;
    _FontScaleMain: Single;
    _FontScaleDpi: Single;
    _Alpha: Single;
    _DisabledAlpha: Single;
    _WindowPadding: _ImVec2;
    _WindowRounding: Single;
    _WindowBorderSize: Single;
    _WindowBorderHoverPadding: Single;
    _WindowMinSize: _ImVec2;
    _WindowTitleAlign: _ImVec2;
    _WindowMenuButtonPosition: _ImGuiDir;
    _ChildRounding: Single;
    _ChildBorderSize: Single;
    _PopupRounding: Single;
    _PopupBorderSize: Single;
    _FramePadding: _ImVec2;
    _FrameRounding: Single;
    _FrameBorderSize: Single;
    _ItemSpacing: _ImVec2;
    _ItemInnerSpacing: _ImVec2;
    _CellPadding: _ImVec2;
    _TouchExtraPadding: _ImVec2;
    _IndentSpacing: Single;
    _ColumnsMinSpacing: Single;
    _ScrollbarSize: Single;
    _ScrollbarRounding: Single;
    _ScrollbarPadding: Single;
    _GrabMinSize: Single;
    _GrabRounding: Single;
    _LogSliderDeadzone: Single;
    _ImageRounding: Single;
    _ImageBorderSize: Single;
    _TabRounding: Single;
    _TabBorderSize: Single;
    _TabMinWidthBase: Single;
    _TabMinWidthShrink: Single;
    _TabCloseButtonMinWidthSelected: Single;
    _TabCloseButtonMinWidthUnselected: Single;
    _TabBarBorderSize: Single;
    _TabBarOverlineSize: Single;
    _TableAngledHeadersAngle: Single;
    _TableAngledHeadersTextAlign: _ImVec2;
    _TreeLinesFlags: _ImGuiTreeNodeFlags;
    _TreeLinesSize: Single;
    _TreeLinesRounding: Single;
    _DragDropTargetRounding: Single;
    _DragDropTargetBorderSize: Single;
    _DragDropTargetPadding: Single;
    _ColorMarkerSize: Single;
    _ColorButtonPosition: _ImGuiDir;
    _ButtonTextAlign: _ImVec2;
    _SelectableTextAlign: _ImVec2;
    _SeparatorSize: Single;
    _SeparatorTextBorderSize: Single;
    _SeparatorTextAlign: _ImVec2;
    _SeparatorTextPadding: _ImVec2;
    _DisplayWindowPadding: _ImVec2;
    _DisplaySafeAreaPadding: _ImVec2;
    _DockingNodeHasCloseButton: Boolean;
    _DockingSeparatorSize: Single;
    _MouseCursorScale: Single;
    _AntiAliasedLines: Boolean;
    _AntiAliasedLinesUseTex: Boolean;
    _AntiAliasedFill: Boolean;
    _CurveTessellationTol: Single;
    _CircleTessellationMaxError: Single;
    _Colors: array [0.._ImGuiCol_COUNT - 1] of _ImVec4;
    _HoverStationaryDelay: Single;
    _HoverDelayShort: Single;
    _HoverDelayNormal: Single;
    _HoverFlagsForTooltipMouse: _ImGuiHoveredFlags;
    _HoverFlagsForTooltipNav: _ImGuiHoveredFlags;
    __MainScale: Single;
    __NextFrameFontSizeBase: Single;
  end;

  _ImGuiKeyData = record
    _Down: Boolean;
    _DownDuration: Single;
    _DownDurationPrev: Single;
    _AnalogValue: Single;
  end;

  _ImGuiIO = record
    _ConfigFlags: _ImGuiConfigFlags;
    _BackendFlags: _ImGuiBackendFlags;
    _DisplaySize: _ImVec2;
    _DisplayFramebufferScale: _ImVec2;
    _DeltaTime: Single;
    _IniSavingRate: Single;
    _IniFilename: Pointer;
    _LogFilename: Pointer;
    _UserData: Pointer;
    _Fonts: Pointer;
    _FontDefault: Pointer;
    _FontAllowUserScaling: Boolean;
    _ConfigNavSwapGamepadButtons: Boolean;
    _ConfigNavMoveSetMousePos: Boolean;
    _ConfigNavCaptureKeyboard: Boolean;
    _ConfigNavEscapeClearFocusItem: Boolean;
    _ConfigNavEscapeClearFocusWindow: Boolean;
    _ConfigNavCursorVisibleAuto: Boolean;
    _ConfigNavCursorVisibleAlways: Boolean;
    _ConfigDockingNoSplit: Boolean;
    _ConfigDockingNoDockingOver: Boolean;
    _ConfigDockingWithShift: Boolean;
    _ConfigDockingAlwaysTabBar: Boolean;
    _ConfigDockingTransparentPayload: Boolean;
    _ConfigViewportsNoAutoMerge: Boolean;
    _ConfigViewportsNoTaskBarIcon: Boolean;
    _ConfigViewportsNoDecoration: Boolean;
    _ConfigViewportsNoDefaultParent: Boolean;
    _ConfigViewportsPlatformFocusSetsImGuiFocus: Boolean;
    _ConfigDpiScaleFonts: Boolean;
    _ConfigDpiScaleViewports: Boolean;
    _MouseDrawCursor: Boolean;
    _ConfigMacOSXBehaviors: Boolean;
    _ConfigInputTrickleEventQueue: Boolean;
    _ConfigInputTextCursorBlink: Boolean;
    _ConfigInputTextEnterKeepActive: Boolean;
    _ConfigDragClickToInputText: Boolean;
    _ConfigWindowsResizeFromEdges: Boolean;
    _ConfigWindowsMoveFromTitleBarOnly: Boolean;
    _ConfigWindowsCopyContentsWithCtrlC: Boolean;
    _ConfigScrollbarScrollByPage: Boolean;
    _ConfigMemoryCompactTimer: Single;
    _MouseDoubleClickTime: Single;
    _MouseDoubleClickMaxDist: Single;
    _MouseDragThreshold: Single;
    _KeyRepeatDelay: Single;
    _KeyRepeatRate: Single;
    _ConfigErrorRecovery: Boolean;
    _ConfigErrorRecoveryEnableAssert: Boolean;
    _ConfigErrorRecoveryEnableDebugLog: Boolean;
    _ConfigErrorRecoveryEnableTooltip: Boolean;
    _ConfigDebugIsDebuggerPresent: Boolean;
    _ConfigDebugHighlightIdConflicts: Boolean;
    _ConfigDebugHighlightIdConflictsShowItemPicker: Boolean;
    _ConfigDebugBeginReturnValueOnce: Boolean;
    _ConfigDebugBeginReturnValueLoop: Boolean;
    _ConfigDebugIgnoreFocusLoss: Boolean;
    _ConfigDebugIniSettings: Boolean;
    _BackendPlatformName: Pointer;
    _BackendRendererName: Pointer;
    _BackendPlatformUserData: Pointer;
    _BackendRendererUserData: Pointer;
    _BackendLanguageUserData: Pointer;
    _WantCaptureMouse: Boolean;
    _WantCaptureKeyboard: Boolean;
    _WantTextInput: Boolean;
    _WantSetMousePos: Boolean;
    _WantSaveIniSettings: Boolean;
    _NavActive: Boolean;
    _NavVisible: Boolean;
    _Framerate: Single;
    _MetricsRenderVertices: Int32;
    _MetricsRenderIndices: Int32;
    _MetricsRenderWindows: Int32;
    _MetricsActiveWindows: Int32;
    _MouseDelta: _ImVec2;
    _Ctx: Pointer;
    _MousePos: _ImVec2;
    _MouseDown: array [0..4] of Boolean;
    _MouseWheel: Single;
    _MouseWheelH: Single;
    _MouseSource: _ImGuiMouseSource;
    _MouseHoveredViewport: _ImGuiID;
    _KeyCtrl: Boolean;
    _KeyShift: Boolean;
    _KeyAlt: Boolean;
    _KeySuper: Boolean;
    _KeyMods: _ImGuiKeyChord;
    _KeysData: array [0.._ImGuiKey_NamedKey_COUNT - 1] of _ImGuiKeyData;
    _WantCaptureMouseUnlessPopupClose: Boolean;
    _MousePosPrev: _ImVec2;
    _MouseClickedPos: array [0..4] of _ImVec2;
    _MouseClickedTime: array [0..4] of Double;
    _MouseClicked: array [0..4] of Boolean;
    _MouseDoubleClicked: array [0..4] of Boolean;
    _MouseClickedCount: array [0..4] of _ImU16;
    _MouseClickedLastCount: array [0..4] of _ImU16;
    _MouseReleased: array [0..4] of Boolean;
    _MouseReleasedTime: array [0..4] of Double;
    _MouseDownOwned: array [0..4] of Boolean;
    _MouseDownOwnedUnlessPopupClose: array [0..4] of Boolean;
    _MouseWheelRequestAxisSwap: Boolean;
    _MouseCtrlLeftAsRightClick: Boolean;
    _MouseDownDuration: array [0..4] of Single;
    _MouseDownDurationPrev: array [0..4] of Single;
    _MouseDragMaxDistanceAbs: array [0..4] of _ImVec2;
    _MouseDragMaxDistanceSqr: array [0..4] of Single;
    _PenPressure: Single;
    _AppFocusLost: Boolean;
    _AppAcceptingEvents: Boolean;
    _InputQueueSurrogate: _ImWchar16;
    _InputQueueCharacters: _ImVector_ImWchar;
  end;

  _ImGuiInputTextCallbackData = record
    _Ctx: Pointer;
    _EventFlag: _ImGuiInputTextFlags;
    _Flags: _ImGuiInputTextFlags;
    _UserData: Pointer;
    _ID: _ImGuiID;
    _EventKey: _ImGuiKey;
    _EventChar: _ImWchar;
    _EventActivated: Boolean;
    _BufDirty: Boolean;
    _Buf: Pointer;
    _BufTextLen: Int32;
    _BufSize: Int32;
    _CursorPos: Int32;
    _SelectionStart: Int32;
    _SelectionEnd: Int32;
  end;

  _ImGuiSizeCallbackData = record
    _UserData: Pointer;
    _Pos: _ImVec2;
    _CurrentSize: _ImVec2;
    _DesiredSize: _ImVec2;
  end;

  _ImGuiWindowClass = record
    _ClassId: _ImGuiID;
    _ParentViewportId: _ImGuiID;
    _FocusRouteParentWindowId: _ImGuiID;
    _ViewportFlagsOverrideSet: _ImGuiViewportFlags;
    _ViewportFlagsOverrideClear: _ImGuiViewportFlags;
    _TabItemFlagsOverrideSet: _ImGuiTabItemFlags;
    _DockNodeFlagsOverrideSet: _ImGuiDockNodeFlags;
    _DockingAlwaysTabBar: Boolean;
    _DockingAllowUnclassed: Boolean;
    _PlatformIconData: Pointer;
  end;

  _ImGuiPayload = record
    _Data: Pointer;
    _DataSize: Int32;
    _SourceId: _ImGuiID;
    _SourceParentId: _ImGuiID;
    _DataFrameCount: Int32;
    _DataType: array [0..32+1 - 1] of UTF8Char;
    _Preview: Boolean;
    _Delivery: Boolean;
  end;

  _ImGuiTextRange = record
    _b: Pointer;
    _e: Pointer;
  end;

  _ImGuiTextFilter = record
    _InputBuf: array [0..255] of UTF8Char;
    _Filters: _ImVector_ImGuiTextRange;
    _CountGrep: Int32;
  end;

  _ImGuiTextBuffer = record
    _Buf: _ImVector_char;
  end;

  ___anonymous_type0 = record
  case Byte of
    0: (_val_i: Int32);
    1: (_val_f: Single);
    2: (_val_p: Pointer);
  end;

  _ImGuiStoragePair = record
    _key: _ImGuiID;
    ___anonymous_type0: ___anonymous_type0;
  end;

  _ImGuiStorage = record
    _Data: _ImVector_ImGuiStoragePair;
  end;

  _ImGuiListClipper = record
    _DisplayStart: Int32;
    _DisplayEnd: Int32;
    _UserIndex: Int32;
    _ItemsCount: Int32;
    _ItemsHeight: Single;
    _Flags: _ImGuiListClipperFlags;
    _StartPosY: Double;
    _StartSeekOffsetY: Double;
    _Ctx: Pointer;
    _TempData: Pointer;
  end;

  _ImColor = record
    _Value: _ImVec4;
  end;

  _ImGuiSelectionRequest = record
    _Type: _ImGuiSelectionRequestType;
    _Selected: Boolean;
    _RangeDirection: _ImS8;
    _RangeFirstItem: _ImGuiSelectionUserData;
    _RangeLastItem: _ImGuiSelectionUserData;
  end;

  _ImGuiMultiSelectIO = record
    _Requests: _ImVector_ImGuiSelectionRequest;
    _RangeSrcItem: _ImGuiSelectionUserData;
    _NavIdItem: _ImGuiSelectionUserData;
    _NavIdSelected: Boolean;
    _RangeSrcReset: Boolean;
    _ItemsCount: Int32;
  end;

  _ImGuiSelectionBasicStorage = record
    _Size: Int32;
    _PreserveOrder: Boolean;
    _UserData: Pointer;
    _AdapterIndexToStorageId: function(self: Pointer; idx: Int32): _ImGuiID; cdecl;
    __SelectionOrder: Int32;
    __Storage: _ImGuiStorage;
  end;

  _ImGuiSelectionExternalStorage = record
    _UserData: Pointer;
    _AdapterSetItemSelected: procedure(self: Pointer; idx: Int32; selected: Boolean); cdecl;
  end;

  _ImDrawCmd = record
    _ClipRect: _ImVec4;
    _TexRef: _ImTextureRef;
    _VtxOffset: UInt32;
    _IdxOffset: UInt32;
    _ElemCount: UInt32;
    _UserCallback: _ImDrawCallback;
    _UserCallbackData: Pointer;
    _UserCallbackDataSize: Int32;
    _UserCallbackDataOffset: Int32;
  end;

  _ImDrawVert = record
    _pos: _ImVec2;
    _uv: _ImVec2;
    _col: _ImU32;
  end;

  _ImDrawCmdHeader = record
    _ClipRect: _ImVec4;
    _TexRef: _ImTextureRef;
    _VtxOffset: UInt32;
  end;

  _ImDrawChannel = record
    __CmdBuffer: _ImVector_ImDrawCmd;
    __IdxBuffer: _ImVector_ImDrawIdx;
  end;

  _ImDrawListSplitter = record
    __Current: Int32;
    __Count: Int32;
    __Channels: _ImVector_ImDrawChannel;
  end;

  _ImDrawList = record
    _CmdBuffer: _ImVector_ImDrawCmd;
    _IdxBuffer: _ImVector_ImDrawIdx;
    _VtxBuffer: _ImVector_ImDrawVert;
    _Flags: _ImDrawListFlags;
    __VtxCurrentIdx: UInt32;
    __Data: Pointer;
    __VtxWritePtr: Pointer;
    __IdxWritePtr: Pointer;
    __Path: _ImVector_ImVec2;
    __CmdHeader: _ImDrawCmdHeader;
    __Splitter: _ImDrawListSplitter;
    __ClipRectStack: _ImVector_ImVec4;
    __TextureStack: _ImVector_ImTextureRef;
    __CallbacksDataBuf: _ImVector_ImU8;
    __FringeScale: Single;
    __OwnerName: Pointer;
  end;

  _ImDrawData = record
    _Valid: Boolean;
    _CmdListsCount: Int32;
    _TotalIdxCount: Int32;
    _TotalVtxCount: Int32;
    _CmdLists: _ImVector_ImDrawListPtr;
    _DisplayPos: _ImVec2;
    _DisplaySize: _ImVec2;
    _FramebufferScale: _ImVec2;
    _OwnerViewport: Pointer;
    _Textures: Pointer;
  end;

  _ImTextureRect = record
    _x: UInt16;
    _y: UInt16;
    _w: UInt16;
    _h: UInt16;
  end;

  _ImTextureData = record
    _UniqueID: Int32;
    _Status: _ImTextureStatus;
    _BackendUserData: Pointer;
    _TexID: _ImTextureID;
    _Format: _ImTextureFormat;
    _Width: Int32;
    _Height: Int32;
    _BytesPerPixel: Int32;
    _Pixels: Pointer;
    _UsedRect: _ImTextureRect;
    _UpdateRect: _ImTextureRect;
    _Updates: _ImVector_ImTextureRect;
    _UnusedFrames: Int32;
    _RefCount: UInt16;
    _UseColors: Boolean;
    _WantDestroyNextFrame: Boolean;
  end;

  _ImFontConfig = record
    _Name: array [0..39] of UTF8Char;
    _FontData: Pointer;
    _FontDataSize: Int32;
    _FontDataOwnedByAtlas: Boolean;
    _MergeMode: Boolean;
    _PixelSnapH: Boolean;
    _OversampleH: _ImS8;
    _OversampleV: _ImS8;
    _EllipsisChar: _ImWchar;
    _SizePixels: Single;
    _GlyphRanges: Pointer;
    _GlyphExcludeRanges: Pointer;
    _GlyphOffset: _ImVec2;
    _GlyphMinAdvanceX: Single;
    _GlyphMaxAdvanceX: Single;
    _GlyphExtraAdvanceX: Single;
    _FontNo: _ImU32;
    _FontLoaderFlags: UInt32;
    _RasterizerMultiply: Single;
    _RasterizerDensity: Single;
    _ExtraSizeScale: Single;
    _Flags: _ImFontFlags;
    _DstFont: Pointer;
    _FontLoader: Pointer;
    _FontLoaderData: Pointer;
  end;

  _ImFontGlyph = record
    _flags0: UInt32;
    _AdvanceX: Single;
    _X0: Single;
    _Y0: Single;
    _X1: Single;
    _Y1: Single;
    _U0: Single;
    _V0: Single;
    _U1: Single;
    _V1: Single;
    _PackId: Int32;
  end;

  _ImFontGlyphRangesBuilder = record
    _UsedChars: _ImVector_ImU32;
  end;

  _ImFontAtlasRect = record
    _x: UInt16;
    _y: UInt16;
    _w: UInt16;
    _h: UInt16;
    _uv0: _ImVec2;
    _uv1: _ImVec2;
  end;

  _ImFontAtlas = record
    _Flags: _ImFontAtlasFlags;
    _TexDesiredFormat: _ImTextureFormat;
    _TexGlyphPadding: Int32;
    _TexMinWidth: Int32;
    _TexMinHeight: Int32;
    _TexMaxWidth: Int32;
    _TexMaxHeight: Int32;
    _UserData: Pointer;
    _TexRef: _ImTextureRef;
    _TexData: Pointer;
    _TexList: _ImVector_ImTextureDataPtr;
    _Locked: Boolean;
    _RendererHasTextures: Boolean;
    _TexIsBuilt: Boolean;
    _TexPixelsUseColors: Boolean;
    _TexUvScale: _ImVec2;
    _TexUvWhitePixel: _ImVec2;
    _Fonts: _ImVector_ImFontPtr;
    _Sources: _ImVector_ImFontConfig;
    _TexUvLines: array [0.._IM_DRAWLIST_TEX_LINES_WIDTH_MAX+1 - 1] of _ImVec4;
    _TexNextUniqueID: Int32;
    _FontNextUniqueID: Int32;
    _DrawListSharedDatas: _ImVector_ImDrawListSharedDataPtr;
    _Builder: Pointer;
    _FontLoader: Pointer;
    _FontLoaderName: Pointer;
    _FontLoaderData: Pointer;
    _FontLoaderFlags: UInt32;
    _RefCount: Int32;
    _OwnerContext: Pointer;
  end;

  _ImFontBaked = record
    _IndexAdvanceX: _ImVector_float;
    _FallbackAdvanceX: Single;
    _Size: Single;
    _RasterizerDensity: Single;
    _IndexLookup: _ImVector_ImU16;
    _Glyphs: _ImVector_ImFontGlyph;
    _FallbackGlyphIndex: Int32;
    _Ascent: Single;
    _Descent: Single;
    _flags9: UInt32;
    _LastUsedFrame: Int32;
    _BakedId: _ImGuiID;
    _OwnerFont: Pointer;
    _FontLoaderDatas: Pointer;
  end;

  _ImFont = record
    _LastBaked: Pointer;
    _OwnerAtlas: Pointer;
    _Flags: _ImFontFlags;
    _CurrentRasterizerDensity: Single;
    _FontId: _ImGuiID;
    _LegacySize: Single;
    _Sources: _ImVector_ImFontConfigPtr;
    _EllipsisChar: _ImWchar;
    _FallbackChar: _ImWchar;
    _Used8kPagesMap: array [0..(_IM_UNICODE_CODEPOINT_MAX +1) div 8192 div 8 - 1] of _ImU8;
    _EllipsisAutoBake: Boolean;
    _RemapPairs: _ImGuiStorage;
  end;

  _ImGuiViewport = record
    _ID: _ImGuiID;
    _Flags: _ImGuiViewportFlags;
    _Pos: _ImVec2;
    _Size: _ImVec2;
    _FramebufferScale: _ImVec2;
    _WorkPos: _ImVec2;
    _WorkSize: _ImVec2;
    _DpiScale: Single;
    _ParentViewportId: _ImGuiID;
    _ParentViewport: Pointer;
    _DrawData: Pointer;
    _RendererUserData: Pointer;
    _PlatformUserData: Pointer;
    _PlatformIconData: Pointer;
    _PlatformHandle: Pointer;
    _PlatformHandleRaw: Pointer;
    _PlatformWindowCreated: Boolean;
    _PlatformRequestMove: Boolean;
    _PlatformRequestResize: Boolean;
    _PlatformRequestClose: Boolean;
  end;

  _ImGuiPlatformMonitor = record
    _MainPos: _ImVec2;
    _MainSize: _ImVec2;
    _WorkPos: _ImVec2;
    _WorkSize: _ImVec2;
    _DpiScale: Single;
    _PlatformHandle: Pointer;
  end;

  _ImGuiPlatformIO = record
    _Platform_GetClipboardTextFn: function(ctx: Pointer): Pointer; cdecl;
    _Platform_SetClipboardTextFn: procedure(ctx: Pointer; text: Pointer); cdecl;
    _Platform_ClipboardUserData: Pointer;
    _Platform_OpenInShellFn: function(ctx: Pointer; path: Pointer): Boolean; cdecl;
    _Platform_OpenInShellUserData: Pointer;
    _Platform_SetImeDataFn: procedure(ctx: Pointer; viewport: Pointer; data: Pointer); cdecl;
    _Platform_ImeUserData: Pointer;
    _Platform_LocaleDecimalPoint: _ImWchar;
    _Renderer_TextureMaxWidth: Int32;
    _Renderer_TextureMaxHeight: Int32;
    _Renderer_RenderState: Pointer;
    _DrawCallback_ResetRenderState: _ImDrawCallback;
    _DrawCallback_SetSamplerLinear: _ImDrawCallback;
    _DrawCallback_SetSamplerNearest: _ImDrawCallback;
    _Platform_CreateWindow: procedure(vp: Pointer); cdecl;
    _Platform_DestroyWindow: procedure(vp: Pointer); cdecl;
    _Platform_ShowWindow: procedure(vp: Pointer); cdecl;
    _Platform_SetWindowPos: procedure(vp: Pointer; pos: _ImVec2); cdecl;
    _Platform_GetWindowPos: function(vp: Pointer): _ImVec2; cdecl;
    _Platform_SetWindowSize: procedure(vp: Pointer; size: _ImVec2); cdecl;
    _Platform_GetWindowSize: function(vp: Pointer): _ImVec2; cdecl;
    _Platform_GetWindowFramebufferScale: function(vp: Pointer): _ImVec2; cdecl;
    _Platform_SetWindowFocus: procedure(vp: Pointer); cdecl;
    _Platform_GetWindowFocus: function(vp: Pointer): Boolean; cdecl;
    _Platform_GetWindowMinimized: function(vp: Pointer): Boolean; cdecl;
    _Platform_SetWindowTitle: procedure(vp: Pointer; str: Pointer); cdecl;
    _Platform_SetWindowAlpha: procedure(vp: Pointer; alpha: Single); cdecl;
    _Platform_UpdateWindow: procedure(vp: Pointer); cdecl;
    _Platform_RenderWindow: procedure(vp: Pointer; render_arg: Pointer); cdecl;
    _Platform_SwapBuffers: procedure(vp: Pointer; render_arg: Pointer); cdecl;
    _Platform_GetWindowDpiScale: function(vp: Pointer): Single; cdecl;
    _Platform_OnChangedViewport: procedure(vp: Pointer); cdecl;
    _Platform_GetWindowWorkAreaInsets: function(vp: Pointer): _ImVec4; cdecl;
    _Platform_CreateVkSurface: function(vp: Pointer; vk_inst: _ImU64; vk_allocators: Pointer; out_vk_surface: Pointer): Int32; cdecl;
    _Renderer_CreateWindow: procedure(vp: Pointer); cdecl;
    _Renderer_DestroyWindow: procedure(vp: Pointer); cdecl;
    _Renderer_SetWindowSize: procedure(vp: Pointer; size: _ImVec2); cdecl;
    _Renderer_RenderWindow: procedure(vp: Pointer; render_arg: Pointer); cdecl;
    _Renderer_SwapBuffers: procedure(vp: Pointer; render_arg: Pointer); cdecl;
    _Monitors: _ImVector_ImGuiPlatformMonitor;
    _Textures: _ImVector_ImTextureDataPtr;
    _Viewports: _ImVector_ImGuiViewportPtr;
  end;

  _ImGuiPlatformImeData = record
    _WantVisible: Boolean;
    _WantTextInput: Boolean;
    _InputPos: _ImVec2;
    _InputLineHeight: Single;
    _ViewportId: _ImGuiID;
  end;

// APIs
function _ImTextureRef_GetTexID(_self: Pointer): _ImTextureID; cdecl;
  external _LIB_SOKOL name _PU + 'ImTextureRef_GetTexID';

function _igCreateContext(_shared_font_atlas: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igCreateContext';

procedure _igDestroyContext(_ctx: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igDestroyContext';

function _igGetCurrentContext(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetCurrentContext';

procedure _igSetCurrentContext(_ctx: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igSetCurrentContext';

function _igGetIO(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetIO';

function _igGetPlatformIO(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetPlatformIO';

function _igGetStyle(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetStyle';

procedure _igNewFrame(); cdecl;
  external _LIB_SOKOL name _PU + 'igNewFrame';

procedure _igEndFrame(); cdecl;
  external _LIB_SOKOL name _PU + 'igEndFrame';

procedure _igRender(); cdecl;
  external _LIB_SOKOL name _PU + 'igRender';

function _igGetDrawData(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetDrawData';

procedure _igShowDemoWindow(_p_open: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igShowDemoWindow';

procedure _igShowMetricsWindow(_p_open: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igShowMetricsWindow';

procedure _igShowDebugLogWindow(_p_open: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igShowDebugLogWindow';

procedure _igShowIDStackToolWindow(); cdecl;
  external _LIB_SOKOL name _PU + 'igShowIDStackToolWindow';

procedure _igShowIDStackToolWindowEx(_p_open: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igShowIDStackToolWindowEx';

procedure _igShowAboutWindow(_p_open: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igShowAboutWindow';

procedure _igShowStyleEditor(_ref: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igShowStyleEditor';

function _igShowStyleSelector(_label: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igShowStyleSelector';

procedure _igShowFontSelector(_label: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igShowFontSelector';

procedure _igShowUserGuide(); cdecl;
  external _LIB_SOKOL name _PU + 'igShowUserGuide';

function _igGetVersion(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetVersion';

procedure _igStyleColorsDark(_dst: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igStyleColorsDark';

procedure _igStyleColorsLight(_dst: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igStyleColorsLight';

procedure _igStyleColorsClassic(_dst: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igStyleColorsClassic';

function _igBegin(_name: Pointer; _p_open: Pointer; _flags: _ImGuiWindowFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBegin';

procedure _igEnd(); cdecl;
  external _LIB_SOKOL name _PU + 'igEnd';

function _igBeginChild(_str_id: Pointer; _size: _ImVec2; _child_flags: _ImGuiChildFlags; _window_flags: _ImGuiWindowFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginChild';

function _igBeginChildID(_id: _ImGuiID; _size: _ImVec2; _child_flags: _ImGuiChildFlags; _window_flags: _ImGuiWindowFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginChildID';

procedure _igEndChild(); cdecl;
  external _LIB_SOKOL name _PU + 'igEndChild';

function _igIsWindowAppearing(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsWindowAppearing';

function _igIsWindowCollapsed(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsWindowCollapsed';

function _igIsWindowFocused(_flags: _ImGuiFocusedFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsWindowFocused';

function _igIsWindowHovered(_flags: _ImGuiHoveredFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsWindowHovered';

function _igGetWindowDrawList(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetWindowDrawList';

function _igGetWindowDpiScale(): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetWindowDpiScale';

function _igGetWindowPos(): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'igGetWindowPos';

function _igGetWindowSize(): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'igGetWindowSize';

function _igGetWindowWidth(): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetWindowWidth';

function _igGetWindowHeight(): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetWindowHeight';

function _igGetWindowViewport(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetWindowViewport';

procedure _igSetNextWindowPos(_pos: _ImVec2; _cond: _ImGuiCond); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextWindowPos';

procedure _igSetNextWindowPosEx(_pos: _ImVec2; _cond: _ImGuiCond; _pivot: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextWindowPosEx';

procedure _igSetNextWindowSize(_size: _ImVec2; _cond: _ImGuiCond); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextWindowSize';

procedure _igSetNextWindowSizeConstraints(_size_min, _size_max: _ImVec2; _custom_callback: _ImGuiSizeCallback; _custom_callback_data: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextWindowSizeConstraints';

procedure _igSetNextWindowContentSize(_size: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextWindowContentSize';

procedure _igSetNextWindowCollapsed(_collapsed: Boolean; _cond: _ImGuiCond); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextWindowCollapsed';

procedure _igSetNextWindowFocus(); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextWindowFocus';

procedure _igSetNextWindowScroll(_scroll: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextWindowScroll';

procedure _igSetNextWindowBgAlpha(_alpha: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextWindowBgAlpha';

procedure _igSetNextWindowViewport(_viewport_id: _ImGuiID); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextWindowViewport';

procedure _igSetWindowPos(_pos: _ImVec2; _cond: _ImGuiCond); cdecl;
  external _LIB_SOKOL name _PU + 'igSetWindowPos';

procedure _igSetWindowSize(_size: _ImVec2; _cond: _ImGuiCond); cdecl;
  external _LIB_SOKOL name _PU + 'igSetWindowSize';

procedure _igSetWindowCollapsed(_collapsed: Boolean; _cond: _ImGuiCond); cdecl;
  external _LIB_SOKOL name _PU + 'igSetWindowCollapsed';

procedure _igSetWindowFocus(); cdecl;
  external _LIB_SOKOL name _PU + 'igSetWindowFocus';

procedure _igSetWindowPosStr(_name: Pointer; _pos: _ImVec2; _cond: _ImGuiCond); cdecl;
  external _LIB_SOKOL name _PU + 'igSetWindowPosStr';

procedure _igSetWindowSizeStr(_name: Pointer; _size: _ImVec2; _cond: _ImGuiCond); cdecl;
  external _LIB_SOKOL name _PU + 'igSetWindowSizeStr';

procedure _igSetWindowCollapsedStr(_name: Pointer; _collapsed: Boolean; _cond: _ImGuiCond); cdecl;
  external _LIB_SOKOL name _PU + 'igSetWindowCollapsedStr';

procedure _igSetWindowFocusStr(_name: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igSetWindowFocusStr';

function _igGetScrollX(): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetScrollX';

function _igGetScrollY(): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetScrollY';

procedure _igSetScrollX(_scroll_x: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igSetScrollX';

procedure _igSetScrollY(_scroll_y: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igSetScrollY';

function _igGetScrollMaxX(): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetScrollMaxX';

function _igGetScrollMaxY(): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetScrollMaxY';

procedure _igSetScrollHereX(_center_x_ratio: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igSetScrollHereX';

procedure _igSetScrollHereY(_center_y_ratio: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igSetScrollHereY';

procedure _igSetScrollFromPosX(_local_x: Single; _center_x_ratio: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igSetScrollFromPosX';

procedure _igSetScrollFromPosY(_local_y: Single; _center_y_ratio: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igSetScrollFromPosY';

procedure _igPushFontFloat(_font: Pointer; _font_size_base_unscaled: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igPushFontFloat';

procedure _igPopFont(); cdecl;
  external _LIB_SOKOL name _PU + 'igPopFont';

function _igGetFont(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetFont';

function _igGetFontSize(): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetFontSize';

function _igGetFontBaked(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetFontBaked';

procedure _igPushStyleColor(_idx: _ImGuiCol; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'igPushStyleColor';

procedure _igPushStyleColorImVec4(_idx: _ImGuiCol; _col: _ImVec4); cdecl;
  external _LIB_SOKOL name _PU + 'igPushStyleColorImVec4';

procedure _igPopStyleColor(); cdecl;
  external _LIB_SOKOL name _PU + 'igPopStyleColor';

procedure _igPopStyleColorEx(_count: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'igPopStyleColorEx';

procedure _igPushStyleVar(_idx: _ImGuiStyleVar; _val: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igPushStyleVar';

procedure _igPushStyleVarImVec2(_idx: _ImGuiStyleVar; _val: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'igPushStyleVarImVec2';

procedure _igPushStyleVarX(_idx: _ImGuiStyleVar; _val_x: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igPushStyleVarX';

procedure _igPushStyleVarY(_idx: _ImGuiStyleVar; _val_y: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igPushStyleVarY';

procedure _igPopStyleVar(); cdecl;
  external _LIB_SOKOL name _PU + 'igPopStyleVar';

procedure _igPopStyleVarEx(_count: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'igPopStyleVarEx';

procedure _igPushItemFlag(_option: _ImGuiItemFlags; _enabled: Boolean); cdecl;
  external _LIB_SOKOL name _PU + 'igPushItemFlag';

procedure _igPopItemFlag(); cdecl;
  external _LIB_SOKOL name _PU + 'igPopItemFlag';

procedure _igPushItemWidth(_item_width: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igPushItemWidth';

procedure _igPopItemWidth(); cdecl;
  external _LIB_SOKOL name _PU + 'igPopItemWidth';

procedure _igSetNextItemWidth(_item_width: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextItemWidth';

function _igCalcItemWidth(): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igCalcItemWidth';

procedure _igPushTextWrapPos(_wrap_local_pos_x: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igPushTextWrapPos';

procedure _igPopTextWrapPos(); cdecl;
  external _LIB_SOKOL name _PU + 'igPopTextWrapPos';

function _igGetFontTexUvWhitePixel(): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'igGetFontTexUvWhitePixel';

function _igGetColorU32(_idx: _ImGuiCol): _ImU32; cdecl;
  external _LIB_SOKOL name _PU + 'igGetColorU32';

function _igGetColorU32Ex(_idx: _ImGuiCol; _alpha_mul: Single): _ImU32; cdecl;
  external _LIB_SOKOL name _PU + 'igGetColorU32Ex';

function _igGetColorU32ImVec4(_col: _ImVec4): _ImU32; cdecl;
  external _LIB_SOKOL name _PU + 'igGetColorU32ImVec4';

function _igGetColorU32ImU32(_col: _ImU32): _ImU32; cdecl;
  external _LIB_SOKOL name _PU + 'igGetColorU32ImU32';

function _igGetColorU32ImU32Ex(_col: _ImU32; _alpha_mul: Single): _ImU32; cdecl;
  external _LIB_SOKOL name _PU + 'igGetColorU32ImU32Ex';

function _igGetStyleColorVec4(_idx: _ImGuiCol): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetStyleColorVec4';

function _igGetCursorScreenPos(): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'igGetCursorScreenPos';

procedure _igSetCursorScreenPos(_pos: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'igSetCursorScreenPos';

function _igGetContentRegionAvail(): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'igGetContentRegionAvail';

function _igGetCursorPos(): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'igGetCursorPos';

function _igGetCursorPosX(): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetCursorPosX';

function _igGetCursorPosY(): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetCursorPosY';

procedure _igSetCursorPos(_local_pos: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'igSetCursorPos';

procedure _igSetCursorPosX(_local_x: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igSetCursorPosX';

procedure _igSetCursorPosY(_local_y: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igSetCursorPosY';

function _igGetCursorStartPos(): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'igGetCursorStartPos';

procedure _igSeparator(); cdecl;
  external _LIB_SOKOL name _PU + 'igSeparator';

procedure _igSameLine(); cdecl;
  external _LIB_SOKOL name _PU + 'igSameLine';

procedure _igSameLineEx(_offset_from_start_x: Single; _spacing: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igSameLineEx';

procedure _igNewLine(); cdecl;
  external _LIB_SOKOL name _PU + 'igNewLine';

procedure _igSpacing(); cdecl;
  external _LIB_SOKOL name _PU + 'igSpacing';

procedure _igDummy(_size: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'igDummy';

procedure _igIndent(); cdecl;
  external _LIB_SOKOL name _PU + 'igIndent';

procedure _igIndentEx(_indent_w: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igIndentEx';

procedure _igUnindent(); cdecl;
  external _LIB_SOKOL name _PU + 'igUnindent';

procedure _igUnindentEx(_indent_w: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igUnindentEx';

procedure _igBeginGroup(); cdecl;
  external _LIB_SOKOL name _PU + 'igBeginGroup';

procedure _igEndGroup(); cdecl;
  external _LIB_SOKOL name _PU + 'igEndGroup';

procedure _igAlignTextToFramePadding(); cdecl;
  external _LIB_SOKOL name _PU + 'igAlignTextToFramePadding';

function _igGetTextLineHeight(): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetTextLineHeight';

function _igGetTextLineHeightWithSpacing(): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetTextLineHeightWithSpacing';

function _igGetFrameHeight(): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetFrameHeight';

function _igGetFrameHeightWithSpacing(): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetFrameHeightWithSpacing';

procedure _igPushID(_str_id: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igPushID';

procedure _igPushIDStr(_str_id_begin, _str_id_end: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igPushIDStr';

procedure _igPushIDPtr(_ptr_id: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igPushIDPtr';

procedure _igPushIDInt(_int_id: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'igPushIDInt';

procedure _igPopID(); cdecl;
  external _LIB_SOKOL name _PU + 'igPopID';

function _igGetID(_str_id: Pointer): _ImGuiID; cdecl;
  external _LIB_SOKOL name _PU + 'igGetID';

function _igGetIDStr(_str_id_begin, _str_id_end: Pointer): _ImGuiID; cdecl;
  external _LIB_SOKOL name _PU + 'igGetIDStr';

function _igGetIDPtr(_ptr_id: Pointer): _ImGuiID; cdecl;
  external _LIB_SOKOL name _PU + 'igGetIDPtr';

function _igGetIDInt(_int_id: Int32): _ImGuiID; cdecl;
  external _LIB_SOKOL name _PU + 'igGetIDInt';

procedure _igTextUnformatted(_text: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igTextUnformatted';

procedure _igTextUnformattedEx(_text: Pointer; _text_end: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igTextUnformattedEx';

procedure _igText(_fmt: Pointer); varargs; cdecl;
  external _LIB_SOKOL name _PU + 'igText';

procedure _igTextColored(_col: _ImVec4; _fmt: Pointer); varargs; cdecl;
  external _LIB_SOKOL name _PU + 'igTextColored';

procedure _igTextDisabled(_fmt: Pointer); varargs; cdecl;
  external _LIB_SOKOL name _PU + 'igTextDisabled';

procedure _igTextWrapped(_fmt: Pointer); varargs; cdecl;
  external _LIB_SOKOL name _PU + 'igTextWrapped';

procedure _igLabelText(_label, _fmt: Pointer); varargs; cdecl;
  external _LIB_SOKOL name _PU + 'igLabelText';

procedure _igBulletText(_fmt: Pointer); varargs; cdecl;
  external _LIB_SOKOL name _PU + 'igBulletText';

procedure _igSeparatorText(_label: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igSeparatorText';

function _igButton(_label: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igButton';

function _igButtonEx(_label: Pointer; _size: _ImVec2): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igButtonEx';

function _igSmallButton(_label: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSmallButton';

function _igInvisibleButton(_str_id: Pointer; _size: _ImVec2; _flags: _ImGuiButtonFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInvisibleButton';

function _igArrowButton(_str_id: Pointer; _dir: _ImGuiDir): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igArrowButton';

function _igCheckbox(_label: Pointer; _v: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igCheckbox';

function _igCheckboxFlagsIntPtr(_label: Pointer; _flags: Pointer; _flags_value: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igCheckboxFlagsIntPtr';

function _igCheckboxFlagsUintPtr(_label: Pointer; _flags: Pointer; _flags_value: UInt32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igCheckboxFlagsUintPtr';

function _igRadioButton(_label: Pointer; _active: Boolean): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igRadioButton';

function _igRadioButtonIntPtr(_label: Pointer; _v: Pointer; _v_button: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igRadioButtonIntPtr';

procedure _igProgressBar(_fraction: Single; _size_arg: _ImVec2; _overlay: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igProgressBar';

procedure _igBullet(); cdecl;
  external _LIB_SOKOL name _PU + 'igBullet';

function _igTextLink(_label: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igTextLink';

function _igTextLinkOpenURL(_label: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igTextLinkOpenURL';

function _igTextLinkOpenURLEx(_label: Pointer; _url: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igTextLinkOpenURLEx';

procedure _igImage(_tex_ref: _ImTextureRef; _image_size: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'igImage';

procedure _igImageEx(_tex_ref: _ImTextureRef; _image_size, _uv0, _uv1: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'igImageEx';

procedure _igImageWithBg(_tex_ref: _ImTextureRef; _image_size: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'igImageWithBg';

procedure _igImageWithBgEx(_tex_ref: _ImTextureRef; _image_size, _uv0, _uv1: _ImVec2; _bg_col, _tint_col: _ImVec4); cdecl;
  external _LIB_SOKOL name _PU + 'igImageWithBgEx';

function _igImageButton(_str_id: Pointer; _tex_ref: _ImTextureRef; _image_size: _ImVec2): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igImageButton';

function _igImageButtonEx(_str_id: Pointer; _tex_ref: _ImTextureRef; _image_size, _uv0, _uv1: _ImVec2; _bg_col, _tint_col: _ImVec4): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igImageButtonEx';

function _igBeginCombo(_label, _preview_value: Pointer; _flags: _ImGuiComboFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginCombo';

procedure _igEndCombo(); cdecl;
  external _LIB_SOKOL name _PU + 'igEndCombo';

function _igComboChar(_label: Pointer; _current_item: Pointer; _items: Pointer; _items_count: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igComboChar';

function _igComboCharEx(_label: Pointer; _current_item: Pointer; _items: Pointer; _items_count: Int32; _popup_max_height_in_items: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igComboCharEx';

function _igCombo(_label: Pointer; _current_item: Pointer; _items_separated_by_zeros: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igCombo';

function _igComboEx(_label: Pointer; _current_item: Pointer; _items_separated_by_zeros: Pointer; _popup_max_height_in_items: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igComboEx';

function _igComboCallback(_label: Pointer; _current_item: Pointer; _getter: Pointer; _user_data: Pointer; _items_count: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igComboCallback';

function _igComboCallbackEx(_label: Pointer; _current_item: Pointer; _getter: Pointer; _user_data: Pointer; _items_count: Int32; _popup_max_height_in_items: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igComboCallbackEx';

function _igDragFloat(_label: Pointer; _v: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragFloat';

function _igDragFloatEx(_label: Pointer; _v: Pointer; _v_speed: Single; _v_min: Single; _v_max: Single; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragFloatEx';

function _igDragFloat2(_label: Pointer; _v: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragFloat2';

function _igDragFloat2Ex(_label: Pointer; _v: Pointer; _v_speed: Single; _v_min: Single; _v_max: Single; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragFloat2Ex';

function _igDragFloat3(_label: Pointer; _v: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragFloat3';

function _igDragFloat3Ex(_label: Pointer; _v: Pointer; _v_speed: Single; _v_min: Single; _v_max: Single; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragFloat3Ex';

function _igDragFloat4(_label: Pointer; _v: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragFloat4';

function _igDragFloat4Ex(_label: Pointer; _v: Pointer; _v_speed: Single; _v_min: Single; _v_max: Single; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragFloat4Ex';

function _igDragFloatRange2(_label: Pointer; _v_current_min, _v_current_max: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragFloatRange2';

function _igDragFloatRange2Ex(_label: Pointer; _v_current_min, _v_current_max: Pointer; _v_speed: Single; _v_min: Single; _v_max: Single; _format: Pointer; _format_max: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragFloatRange2Ex';

function _igDragInt(_label: Pointer; _v: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragInt';

function _igDragIntEx(_label: Pointer; _v: Pointer; _v_speed: Single; _v_min: Int32; _v_max: Int32; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragIntEx';

function _igDragInt2(_label: Pointer; _v: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragInt2';

function _igDragInt2Ex(_label: Pointer; _v: Pointer; _v_speed: Single; _v_min: Int32; _v_max: Int32; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragInt2Ex';

function _igDragInt3(_label: Pointer; _v: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragInt3';

function _igDragInt3Ex(_label: Pointer; _v: Pointer; _v_speed: Single; _v_min: Int32; _v_max: Int32; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragInt3Ex';

function _igDragInt4(_label: Pointer; _v: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragInt4';

function _igDragInt4Ex(_label: Pointer; _v: Pointer; _v_speed: Single; _v_min: Int32; _v_max: Int32; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragInt4Ex';

function _igDragIntRange2(_label: Pointer; _v_current_min, _v_current_max: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragIntRange2';

function _igDragIntRange2Ex(_label: Pointer; _v_current_min, _v_current_max: Pointer; _v_speed: Single; _v_min: Int32; _v_max: Int32; _format: Pointer; _format_max: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragIntRange2Ex';

function _igDragScalar(_label: Pointer; _data_type: _ImGuiDataType; _p_data: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragScalar';

function _igDragScalarEx(_label: Pointer; _data_type: _ImGuiDataType; _p_data: Pointer; _v_speed: Single; _p_min: Pointer; _p_max: Pointer; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragScalarEx';

function _igDragScalarN(_label: Pointer; _data_type: _ImGuiDataType; _p_data: Pointer; _components: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragScalarN';

function _igDragScalarNEx(_label: Pointer; _data_type: _ImGuiDataType; _p_data: Pointer; _components: Int32; _v_speed: Single; _p_min: Pointer; _p_max: Pointer; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDragScalarNEx';

function _igSliderFloat(_label: Pointer; _v: Pointer; _v_min, _v_max: Single): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderFloat';

function _igSliderFloatEx(_label: Pointer; _v: Pointer; _v_min, _v_max: Single; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderFloatEx';

function _igSliderFloat2(_label: Pointer; _v: Pointer; _v_min, _v_max: Single): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderFloat2';

function _igSliderFloat2Ex(_label: Pointer; _v: Pointer; _v_min, _v_max: Single; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderFloat2Ex';

function _igSliderFloat3(_label: Pointer; _v: Pointer; _v_min, _v_max: Single): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderFloat3';

function _igSliderFloat3Ex(_label: Pointer; _v: Pointer; _v_min, _v_max: Single; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderFloat3Ex';

function _igSliderFloat4(_label: Pointer; _v: Pointer; _v_min, _v_max: Single): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderFloat4';

function _igSliderFloat4Ex(_label: Pointer; _v: Pointer; _v_min, _v_max: Single; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderFloat4Ex';

function _igSliderAngle(_label: Pointer; _v_rad: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderAngle';

function _igSliderAngleEx(_label: Pointer; _v_rad: Pointer; _v_degrees_min: Single; _v_degrees_max: Single; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderAngleEx';

function _igSliderInt(_label: Pointer; _v: Pointer; _v_min, _v_max: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderInt';

function _igSliderIntEx(_label: Pointer; _v: Pointer; _v_min, _v_max: Int32; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderIntEx';

function _igSliderInt2(_label: Pointer; _v: Pointer; _v_min, _v_max: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderInt2';

function _igSliderInt2Ex(_label: Pointer; _v: Pointer; _v_min, _v_max: Int32; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderInt2Ex';

function _igSliderInt3(_label: Pointer; _v: Pointer; _v_min, _v_max: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderInt3';

function _igSliderInt3Ex(_label: Pointer; _v: Pointer; _v_min, _v_max: Int32; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderInt3Ex';

function _igSliderInt4(_label: Pointer; _v: Pointer; _v_min, _v_max: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderInt4';

function _igSliderInt4Ex(_label: Pointer; _v: Pointer; _v_min, _v_max: Int32; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderInt4Ex';

function _igSliderScalar(_label: Pointer; _data_type: _ImGuiDataType; _p_data: Pointer; _p_min, _p_max: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderScalar';

function _igSliderScalarEx(_label: Pointer; _data_type: _ImGuiDataType; _p_data: Pointer; _p_min, _p_max: Pointer; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderScalarEx';

function _igSliderScalarN(_label: Pointer; _data_type: _ImGuiDataType; _p_data: Pointer; _components: Int32; _p_min, _p_max: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderScalarN';

function _igSliderScalarNEx(_label: Pointer; _data_type: _ImGuiDataType; _p_data: Pointer; _components: Int32; _p_min, _p_max: Pointer; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSliderScalarNEx';

function _igVSliderFloat(_label: Pointer; _size: _ImVec2; _v: Pointer; _v_min, _v_max: Single): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igVSliderFloat';

function _igVSliderFloatEx(_label: Pointer; _size: _ImVec2; _v: Pointer; _v_min, _v_max: Single; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igVSliderFloatEx';

function _igVSliderInt(_label: Pointer; _size: _ImVec2; _v: Pointer; _v_min, _v_max: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igVSliderInt';

function _igVSliderIntEx(_label: Pointer; _size: _ImVec2; _v: Pointer; _v_min, _v_max: Int32; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igVSliderIntEx';

function _igVSliderScalar(_label: Pointer; _size: _ImVec2; _data_type: _ImGuiDataType; _p_data: Pointer; _p_min, _p_max: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igVSliderScalar';

function _igVSliderScalarEx(_label: Pointer; _size: _ImVec2; _data_type: _ImGuiDataType; _p_data: Pointer; _p_min, _p_max: Pointer; _format: Pointer; _flags: _ImGuiSliderFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igVSliderScalarEx';

function _igInputText(_label: Pointer; _buf: Pointer; _buf_size: NativeUInt; _flags: _ImGuiInputTextFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputText';

function _igInputTextEx(_label: Pointer; _buf: Pointer; _buf_size: NativeUInt; _flags: _ImGuiInputTextFlags; _callback: _ImGuiInputTextCallback; _user_data: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputTextEx';

function _igInputTextMultiline(_label: Pointer; _buf: Pointer; _buf_size: NativeUInt): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputTextMultiline';

function _igInputTextMultilineEx(_label: Pointer; _buf: Pointer; _buf_size: NativeUInt; _size: _ImVec2; _flags: _ImGuiInputTextFlags; _callback: _ImGuiInputTextCallback; _user_data: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputTextMultilineEx';

function _igInputTextWithHint(_label, _hint: Pointer; _buf: Pointer; _buf_size: NativeUInt; _flags: _ImGuiInputTextFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputTextWithHint';

function _igInputTextWithHintEx(_label, _hint: Pointer; _buf: Pointer; _buf_size: NativeUInt; _flags: _ImGuiInputTextFlags; _callback: _ImGuiInputTextCallback; _user_data: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputTextWithHintEx';

function _igInputFloat(_label: Pointer; _v: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputFloat';

function _igInputFloatEx(_label: Pointer; _v: Pointer; _step: Single; _step_fast: Single; _format: Pointer; _flags: _ImGuiInputTextFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputFloatEx';

function _igInputFloat2(_label: Pointer; _v: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputFloat2';

function _igInputFloat2Ex(_label: Pointer; _v: Pointer; _format: Pointer; _flags: _ImGuiInputTextFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputFloat2Ex';

function _igInputFloat3(_label: Pointer; _v: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputFloat3';

function _igInputFloat3Ex(_label: Pointer; _v: Pointer; _format: Pointer; _flags: _ImGuiInputTextFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputFloat3Ex';

function _igInputFloat4(_label: Pointer; _v: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputFloat4';

function _igInputFloat4Ex(_label: Pointer; _v: Pointer; _format: Pointer; _flags: _ImGuiInputTextFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputFloat4Ex';

function _igInputInt(_label: Pointer; _v: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputInt';

function _igInputIntEx(_label: Pointer; _v: Pointer; _step: Int32; _step_fast: Int32; _flags: _ImGuiInputTextFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputIntEx';

function _igInputInt2(_label: Pointer; _v: Pointer; _flags: _ImGuiInputTextFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputInt2';

function _igInputInt3(_label: Pointer; _v: Pointer; _flags: _ImGuiInputTextFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputInt3';

function _igInputInt4(_label: Pointer; _v: Pointer; _flags: _ImGuiInputTextFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputInt4';

function _igInputDouble(_label: Pointer; _v: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputDouble';

function _igInputDoubleEx(_label: Pointer; _v: Pointer; _step: Double; _step_fast: Double; _format: Pointer; _flags: _ImGuiInputTextFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputDoubleEx';

function _igInputScalar(_label: Pointer; _data_type: _ImGuiDataType; _p_data: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputScalar';

function _igInputScalarEx(_label: Pointer; _data_type: _ImGuiDataType; _p_data: Pointer; _p_step: Pointer; _p_step_fast: Pointer; _format: Pointer; _flags: _ImGuiInputTextFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputScalarEx';

function _igInputScalarN(_label: Pointer; _data_type: _ImGuiDataType; _p_data: Pointer; _components: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputScalarN';

function _igInputScalarNEx(_label: Pointer; _data_type: _ImGuiDataType; _p_data: Pointer; _components: Int32; _p_step: Pointer; _p_step_fast: Pointer; _format: Pointer; _flags: _ImGuiInputTextFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igInputScalarNEx';

function _igColorEdit3(_label: Pointer; _col: Pointer; _flags: _ImGuiColorEditFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igColorEdit3';

function _igColorEdit4(_label: Pointer; _col: Pointer; _flags: _ImGuiColorEditFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igColorEdit4';

function _igColorPicker3(_label: Pointer; _col: Pointer; _flags: _ImGuiColorEditFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igColorPicker3';

function _igColorPicker4(_label: Pointer; _col: Pointer; _flags: _ImGuiColorEditFlags; _ref_col: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igColorPicker4';

function _igColorButton(_desc_id: Pointer; _col: _ImVec4; _flags: _ImGuiColorEditFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igColorButton';

function _igColorButtonEx(_desc_id: Pointer; _col: _ImVec4; _flags: _ImGuiColorEditFlags; _size: _ImVec2): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igColorButtonEx';

procedure _igSetColorEditOptions(_flags: _ImGuiColorEditFlags); cdecl;
  external _LIB_SOKOL name _PU + 'igSetColorEditOptions';

function _igTreeNode(_label: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igTreeNode';

function _igTreeNodeStr(_str_id, _fmt: Pointer): Boolean; varargs; cdecl;
  external _LIB_SOKOL name _PU + 'igTreeNodeStr';

function _igTreeNodePtr(_ptr_id: Pointer; _fmt: Pointer): Boolean; varargs; cdecl;
  external _LIB_SOKOL name _PU + 'igTreeNodePtr';

function _igTreeNodeEx(_label: Pointer; _flags: _ImGuiTreeNodeFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igTreeNodeEx';

function _igTreeNodeExStr(_str_id: Pointer; _flags: _ImGuiTreeNodeFlags; _fmt: Pointer): Boolean; varargs; cdecl;
  external _LIB_SOKOL name _PU + 'igTreeNodeExStr';

function _igTreeNodeExPtr(_ptr_id: Pointer; _flags: _ImGuiTreeNodeFlags; _fmt: Pointer): Boolean; varargs; cdecl;
  external _LIB_SOKOL name _PU + 'igTreeNodeExPtr';

procedure _igTreePush(_str_id: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igTreePush';

procedure _igTreePushPtr(_ptr_id: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igTreePushPtr';

procedure _igTreePop(); cdecl;
  external _LIB_SOKOL name _PU + 'igTreePop';

function _igGetTreeNodeToLabelSpacing(): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetTreeNodeToLabelSpacing';

function _igCollapsingHeader(_label: Pointer; _flags: _ImGuiTreeNodeFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igCollapsingHeader';

function _igCollapsingHeaderBoolPtr(_label: Pointer; _p_visible: Pointer; _flags: _ImGuiTreeNodeFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igCollapsingHeaderBoolPtr';

procedure _igSetNextItemOpen(_is_open: Boolean; _cond: _ImGuiCond); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextItemOpen';

procedure _igSetNextItemStorageID(_storage_id: _ImGuiID); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextItemStorageID';

function _igTreeNodeGetOpen(_storage_id: _ImGuiID): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igTreeNodeGetOpen';

function _igSelectable(_label: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSelectable';

function _igSelectableEx(_label: Pointer; _selected: Boolean; _flags: _ImGuiSelectableFlags; _size: _ImVec2): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSelectableEx';

function _igSelectableBoolPtr(_label: Pointer; _p_selected: Pointer; _flags: _ImGuiSelectableFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSelectableBoolPtr';

function _igSelectableBoolPtrEx(_label: Pointer; _p_selected: Pointer; _flags: _ImGuiSelectableFlags; _size: _ImVec2): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSelectableBoolPtrEx';

function _igBeginMultiSelect(_flags: _ImGuiMultiSelectFlags): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginMultiSelect';

function _igBeginMultiSelectEx(_flags: _ImGuiMultiSelectFlags; _selection_size: Int32; _items_count: Int32): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginMultiSelectEx';

function _igEndMultiSelect(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igEndMultiSelect';

procedure _igSetNextItemSelectionUserData(_selection_user_data: _ImGuiSelectionUserData); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextItemSelectionUserData';

function _igIsItemToggledSelection(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsItemToggledSelection';

function _igBeginListBox(_label: Pointer; _size: _ImVec2): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginListBox';

procedure _igEndListBox(); cdecl;
  external _LIB_SOKOL name _PU + 'igEndListBox';

function _igListBox(_label: Pointer; _current_item: Pointer; _items: Pointer; _items_count: Int32; _height_in_items: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igListBox';

function _igListBoxCallback(_label: Pointer; _current_item: Pointer; _getter: Pointer; _user_data: Pointer; _items_count: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igListBoxCallback';

function _igListBoxCallbackEx(_label: Pointer; _current_item: Pointer; _getter: Pointer; _user_data: Pointer; _items_count: Int32; _height_in_items: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igListBoxCallbackEx';

procedure _igPlotLines(_label: Pointer; _values: Pointer; _values_count: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'igPlotLines';

procedure _igPlotLinesEx(_label: Pointer; _values: Pointer; _values_count: Int32; _values_offset: Int32; _overlay_text: Pointer; _scale_min: Single; _scale_max: Single; _graph_size: _ImVec2; _stride: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'igPlotLinesEx';

procedure _igPlotLinesCallback(_label: Pointer; _values_getter: Pointer; _data: Pointer; _values_count: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'igPlotLinesCallback';

procedure _igPlotLinesCallbackEx(_label: Pointer; _values_getter: Pointer; _data: Pointer; _values_count: Int32; _values_offset: Int32; _overlay_text: Pointer; _scale_min: Single; _scale_max: Single; _graph_size: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'igPlotLinesCallbackEx';

procedure _igPlotHistogram(_label: Pointer; _values: Pointer; _values_count: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'igPlotHistogram';

procedure _igPlotHistogramEx(_label: Pointer; _values: Pointer; _values_count: Int32; _values_offset: Int32; _overlay_text: Pointer; _scale_min: Single; _scale_max: Single; _graph_size: _ImVec2; _stride: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'igPlotHistogramEx';

procedure _igPlotHistogramCallback(_label: Pointer; _values_getter: Pointer; _data: Pointer; _values_count: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'igPlotHistogramCallback';

procedure _igPlotHistogramCallbackEx(_label: Pointer; _values_getter: Pointer; _data: Pointer; _values_count: Int32; _values_offset: Int32; _overlay_text: Pointer; _scale_min: Single; _scale_max: Single; _graph_size: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'igPlotHistogramCallbackEx';

function _igBeginMenuBar(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginMenuBar';

procedure _igEndMenuBar(); cdecl;
  external _LIB_SOKOL name _PU + 'igEndMenuBar';

function _igBeginMainMenuBar(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginMainMenuBar';

procedure _igEndMainMenuBar(); cdecl;
  external _LIB_SOKOL name _PU + 'igEndMainMenuBar';

function _igBeginMenu(_label: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginMenu';

function _igBeginMenuEx(_label: Pointer; _enabled: Boolean): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginMenuEx';

procedure _igEndMenu(); cdecl;
  external _LIB_SOKOL name _PU + 'igEndMenu';

function _igMenuItem(_label: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igMenuItem';

function _igMenuItemEx(_label: Pointer; _shortcut: Pointer; _selected: Boolean; _enabled: Boolean): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igMenuItemEx';

function _igMenuItemBoolPtr(_label, _shortcut: Pointer; _p_selected: Pointer; _enabled: Boolean): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igMenuItemBoolPtr';

function _igBeginTooltip(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginTooltip';

procedure _igEndTooltip(); cdecl;
  external _LIB_SOKOL name _PU + 'igEndTooltip';

procedure _igSetTooltip(_fmt: Pointer); varargs; cdecl;
  external _LIB_SOKOL name _PU + 'igSetTooltip';

function _igBeginItemTooltip(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginItemTooltip';

procedure _igSetItemTooltip(_fmt: Pointer); varargs; cdecl;
  external _LIB_SOKOL name _PU + 'igSetItemTooltip';

function _igBeginPopup(_str_id: Pointer; _flags: _ImGuiWindowFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginPopup';

function _igBeginPopupModal(_name: Pointer; _p_open: Pointer; _flags: _ImGuiWindowFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginPopupModal';

procedure _igEndPopup(); cdecl;
  external _LIB_SOKOL name _PU + 'igEndPopup';

procedure _igOpenPopup(_str_id: Pointer; _popup_flags: _ImGuiPopupFlags); cdecl;
  external _LIB_SOKOL name _PU + 'igOpenPopup';

procedure _igOpenPopupID(_id: _ImGuiID; _popup_flags: _ImGuiPopupFlags); cdecl;
  external _LIB_SOKOL name _PU + 'igOpenPopupID';

procedure _igOpenPopupOnItemClick(_str_id: Pointer; _popup_flags: _ImGuiPopupFlags); cdecl;
  external _LIB_SOKOL name _PU + 'igOpenPopupOnItemClick';

procedure _igCloseCurrentPopup(); cdecl;
  external _LIB_SOKOL name _PU + 'igCloseCurrentPopup';

function _igBeginPopupContextItem(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginPopupContextItem';

function _igBeginPopupContextItemEx(_str_id: Pointer; _popup_flags: _ImGuiPopupFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginPopupContextItemEx';

function _igBeginPopupContextWindow(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginPopupContextWindow';

function _igBeginPopupContextWindowEx(_str_id: Pointer; _popup_flags: _ImGuiPopupFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginPopupContextWindowEx';

function _igBeginPopupContextVoid(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginPopupContextVoid';

function _igBeginPopupContextVoidEx(_str_id: Pointer; _popup_flags: _ImGuiPopupFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginPopupContextVoidEx';

function _igIsPopupOpen(_str_id: Pointer; _flags: _ImGuiPopupFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsPopupOpen';

function _igBeginTable(_str_id: Pointer; _columns: Int32; _flags: _ImGuiTableFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginTable';

function _igBeginTableEx(_str_id: Pointer; _columns: Int32; _flags: _ImGuiTableFlags; _outer_size: _ImVec2; _inner_width: Single): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginTableEx';

procedure _igEndTable(); cdecl;
  external _LIB_SOKOL name _PU + 'igEndTable';

procedure _igTableNextRow(); cdecl;
  external _LIB_SOKOL name _PU + 'igTableNextRow';

procedure _igTableNextRowEx(_row_flags: _ImGuiTableRowFlags; _min_row_height: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igTableNextRowEx';

function _igTableNextColumn(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igTableNextColumn';

function _igTableSetColumnIndex(_column_n: Int32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igTableSetColumnIndex';

procedure _igTableSetupColumn(_label: Pointer; _flags: _ImGuiTableColumnFlags); cdecl;
  external _LIB_SOKOL name _PU + 'igTableSetupColumn';

procedure _igTableSetupColumnEx(_label: Pointer; _flags: _ImGuiTableColumnFlags; _init_width_or_weight: Single; _user_id: _ImGuiID); cdecl;
  external _LIB_SOKOL name _PU + 'igTableSetupColumnEx';

procedure _igTableSetupScrollFreeze(_cols, _rows: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'igTableSetupScrollFreeze';

procedure _igTableHeader(_label: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igTableHeader';

procedure _igTableHeadersRow(); cdecl;
  external _LIB_SOKOL name _PU + 'igTableHeadersRow';

procedure _igTableAngledHeadersRow(); cdecl;
  external _LIB_SOKOL name _PU + 'igTableAngledHeadersRow';

function _igTableGetSortSpecs(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igTableGetSortSpecs';

function _igTableGetColumnCount(): Int32; cdecl;
  external _LIB_SOKOL name _PU + 'igTableGetColumnCount';

function _igTableGetColumnIndex(): Int32; cdecl;
  external _LIB_SOKOL name _PU + 'igTableGetColumnIndex';

function _igTableGetRowIndex(): Int32; cdecl;
  external _LIB_SOKOL name _PU + 'igTableGetRowIndex';

function _igTableGetColumnName(_column_n: Int32): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igTableGetColumnName';

function _igTableGetColumnFlags(_column_n: Int32): _ImGuiTableColumnFlags; cdecl;
  external _LIB_SOKOL name _PU + 'igTableGetColumnFlags';

procedure _igTableSetColumnEnabled(_column_n: Int32; _v: Boolean); cdecl;
  external _LIB_SOKOL name _PU + 'igTableSetColumnEnabled';

function _igTableGetHoveredColumn(): Int32; cdecl;
  external _LIB_SOKOL name _PU + 'igTableGetHoveredColumn';

procedure _igTableSetBgColor(_target: _ImGuiTableBgTarget; _color: _ImU32; _column_n: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'igTableSetBgColor';

procedure _igColumns(); cdecl;
  external _LIB_SOKOL name _PU + 'igColumns';

procedure _igColumnsEx(_count: Int32; _id: Pointer; _borders: Boolean); cdecl;
  external _LIB_SOKOL name _PU + 'igColumnsEx';

procedure _igNextColumn(); cdecl;
  external _LIB_SOKOL name _PU + 'igNextColumn';

function _igGetColumnIndex(): Int32; cdecl;
  external _LIB_SOKOL name _PU + 'igGetColumnIndex';

function _igGetColumnWidth(_column_index: Int32): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetColumnWidth';

procedure _igSetColumnWidth(_column_index: Int32; _width: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igSetColumnWidth';

function _igGetColumnOffset(_column_index: Int32): Single; cdecl;
  external _LIB_SOKOL name _PU + 'igGetColumnOffset';

procedure _igSetColumnOffset(_column_index: Int32; _offset_x: Single); cdecl;
  external _LIB_SOKOL name _PU + 'igSetColumnOffset';

function _igGetColumnsCount(): Int32; cdecl;
  external _LIB_SOKOL name _PU + 'igGetColumnsCount';

function _igBeginTabBar(_str_id: Pointer; _flags: _ImGuiTabBarFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginTabBar';

procedure _igEndTabBar(); cdecl;
  external _LIB_SOKOL name _PU + 'igEndTabBar';

function _igBeginTabItem(_label: Pointer; _p_open: Pointer; _flags: _ImGuiTabItemFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginTabItem';

procedure _igEndTabItem(); cdecl;
  external _LIB_SOKOL name _PU + 'igEndTabItem';

function _igTabItemButton(_label: Pointer; _flags: _ImGuiTabItemFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igTabItemButton';

procedure _igSetTabItemClosed(_tab_or_docked_window_label: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igSetTabItemClosed';

function _igDockSpace(_dockspace_id: _ImGuiID): _ImGuiID; cdecl;
  external _LIB_SOKOL name _PU + 'igDockSpace';

function _igDockSpaceEx(_dockspace_id: _ImGuiID; _size: _ImVec2; _flags: _ImGuiDockNodeFlags; _window_class: Pointer): _ImGuiID; cdecl;
  external _LIB_SOKOL name _PU + 'igDockSpaceEx';

function _igDockSpaceOverViewport(): _ImGuiID; cdecl;
  external _LIB_SOKOL name _PU + 'igDockSpaceOverViewport';

function _igDockSpaceOverViewportEx(_dockspace_id: _ImGuiID; _viewport: Pointer; _flags: _ImGuiDockNodeFlags; _window_class: Pointer): _ImGuiID; cdecl;
  external _LIB_SOKOL name _PU + 'igDockSpaceOverViewportEx';

procedure _igSetNextWindowDockID(_dock_id: _ImGuiID; _cond: _ImGuiCond); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextWindowDockID';

procedure _igSetNextWindowClass(_window_class: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextWindowClass';

function _igGetWindowDockID(): _ImGuiID; cdecl;
  external _LIB_SOKOL name _PU + 'igGetWindowDockID';

function _igIsWindowDocked(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsWindowDocked';

procedure _igLogToTTY(_auto_open_depth: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'igLogToTTY';

procedure _igLogToFile(_auto_open_depth: Int32; _filename: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igLogToFile';

procedure _igLogToClipboard(_auto_open_depth: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'igLogToClipboard';

procedure _igLogFinish(); cdecl;
  external _LIB_SOKOL name _PU + 'igLogFinish';

procedure _igLogButtons(); cdecl;
  external _LIB_SOKOL name _PU + 'igLogButtons';

procedure _igLogText(_fmt: Pointer); varargs; cdecl;
  external _LIB_SOKOL name _PU + 'igLogText';

function _igBeginDragDropSource(_flags: _ImGuiDragDropFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginDragDropSource';

function _igSetDragDropPayload(_type: Pointer; _data: Pointer; _sz: NativeUInt; _cond: _ImGuiCond): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSetDragDropPayload';

procedure _igEndDragDropSource(); cdecl;
  external _LIB_SOKOL name _PU + 'igEndDragDropSource';

function _igBeginDragDropTarget(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igBeginDragDropTarget';

function _igAcceptDragDropPayload(_type: Pointer; _flags: _ImGuiDragDropFlags): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igAcceptDragDropPayload';

procedure _igEndDragDropTarget(); cdecl;
  external _LIB_SOKOL name _PU + 'igEndDragDropTarget';

function _igGetDragDropPayload(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetDragDropPayload';

procedure _igBeginDisabled(_disabled: Boolean); cdecl;
  external _LIB_SOKOL name _PU + 'igBeginDisabled';

procedure _igEndDisabled(); cdecl;
  external _LIB_SOKOL name _PU + 'igEndDisabled';

procedure _igPushClipRect(_clip_rect_min, _clip_rect_max: _ImVec2; _intersect_with_current_clip_rect: Boolean); cdecl;
  external _LIB_SOKOL name _PU + 'igPushClipRect';

procedure _igPopClipRect(); cdecl;
  external _LIB_SOKOL name _PU + 'igPopClipRect';

procedure _igSetItemDefaultFocus(); cdecl;
  external _LIB_SOKOL name _PU + 'igSetItemDefaultFocus';

procedure _igSetKeyboardFocusHere(); cdecl;
  external _LIB_SOKOL name _PU + 'igSetKeyboardFocusHere';

procedure _igSetKeyboardFocusHereEx(_offset: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'igSetKeyboardFocusHereEx';

procedure _igSetNavCursorVisible(_visible: Boolean); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNavCursorVisible';

procedure _igSetNextItemAllowOverlap(); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextItemAllowOverlap';

function _igIsItemHovered(_flags: _ImGuiHoveredFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsItemHovered';

function _igIsItemActive(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsItemActive';

function _igIsItemFocused(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsItemFocused';

function _igIsItemClicked(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsItemClicked';

function _igIsItemClickedEx(_mouse_button: _ImGuiMouseButton): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsItemClickedEx';

function _igIsItemVisible(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsItemVisible';

function _igIsItemEdited(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsItemEdited';

function _igIsItemActivated(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsItemActivated';

function _igIsItemDeactivated(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsItemDeactivated';

function _igIsItemDeactivatedAfterEdit(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsItemDeactivatedAfterEdit';

function _igIsItemToggledOpen(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsItemToggledOpen';

function _igIsAnyItemHovered(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsAnyItemHovered';

function _igIsAnyItemActive(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsAnyItemActive';

function _igIsAnyItemFocused(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsAnyItemFocused';

function _igGetItemID(): _ImGuiID; cdecl;
  external _LIB_SOKOL name _PU + 'igGetItemID';

function _igGetItemRectMin(): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'igGetItemRectMin';

function _igGetItemRectMax(): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'igGetItemRectMax';

function _igGetItemRectSize(): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'igGetItemRectSize';

function _igGetItemFlags(): _ImGuiItemFlags; cdecl;
  external _LIB_SOKOL name _PU + 'igGetItemFlags';

function _igGetMainViewport(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetMainViewport';

function _igGetBackgroundDrawList(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetBackgroundDrawList';

function _igGetBackgroundDrawListEx(_viewport: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetBackgroundDrawListEx';

function _igGetForegroundDrawList(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetForegroundDrawList';

function _igGetForegroundDrawListEx(_viewport: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetForegroundDrawListEx';

function _igIsRectVisibleBySize(_size: _ImVec2): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsRectVisibleBySize';

function _igIsRectVisible(_rect_min, _rect_max: _ImVec2): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsRectVisible';

function _igGetTime(): Double; cdecl;
  external _LIB_SOKOL name _PU + 'igGetTime';

function _igGetFrameCount(): Int32; cdecl;
  external _LIB_SOKOL name _PU + 'igGetFrameCount';

function _igGetDrawListSharedData(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetDrawListSharedData';

function _igGetStyleColorName(_idx: _ImGuiCol): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetStyleColorName';

procedure _igSetStateStorage(_storage: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igSetStateStorage';

function _igGetStateStorage(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetStateStorage';

function _igCalcTextSize(_text: Pointer): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'igCalcTextSize';

function _igCalcTextSizeEx(_text: Pointer; _text_end: Pointer; _hide_text_after_double_hash: Boolean; _wrap_width: Single): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'igCalcTextSizeEx';

function _igColorConvertU32ToFloat4(_in: _ImU32): _ImVec4; cdecl;
  external _LIB_SOKOL name _PU + 'igColorConvertU32ToFloat4';

function _igColorConvertFloat4ToU32(_in: _ImVec4): _ImU32; cdecl;
  external _LIB_SOKOL name _PU + 'igColorConvertFloat4ToU32';

procedure _igColorConvertRGBtoHSV(_r, _g, _b: Single; _out_h, _out_s, _out_v: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igColorConvertRGBtoHSV';

procedure _igColorConvertHSVtoRGB(_h, _s, _v: Single; _out_r, _out_g, _out_b: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igColorConvertHSVtoRGB';

function _igIsKeyDown(_key: _ImGuiKey): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsKeyDown';

function _igIsKeyPressed(_key: _ImGuiKey): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsKeyPressed';

function _igIsKeyPressedEx(_key: _ImGuiKey; _repeat: Boolean): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsKeyPressedEx';

function _igIsKeyReleased(_key: _ImGuiKey): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsKeyReleased';

function _igIsKeyChordPressed(_key_chord: _ImGuiKeyChord): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsKeyChordPressed';

function _igGetKeyPressedAmount(_key: _ImGuiKey; _repeat_delay, _rate: Single): Int32; cdecl;
  external _LIB_SOKOL name _PU + 'igGetKeyPressedAmount';

function _igGetKeyName(_key: _ImGuiKey): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetKeyName';

procedure _igSetNextFrameWantCaptureKeyboard(_want_capture_keyboard: Boolean); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextFrameWantCaptureKeyboard';

function _igShortcut(_key_chord: _ImGuiKeyChord; _flags: _ImGuiInputFlags): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igShortcut';

procedure _igSetNextItemShortcut(_key_chord: _ImGuiKeyChord; _flags: _ImGuiInputFlags); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextItemShortcut';

function _igSetItemKeyOwner(_key: _ImGuiKey): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igSetItemKeyOwner';

function _igIsMouseDown(_button: _ImGuiMouseButton): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsMouseDown';

function _igIsMouseClicked(_button: _ImGuiMouseButton): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsMouseClicked';

function _igIsMouseClickedEx(_button: _ImGuiMouseButton; _repeat: Boolean): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsMouseClickedEx';

function _igIsMouseReleased(_button: _ImGuiMouseButton): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsMouseReleased';

function _igIsMouseDoubleClicked(_button: _ImGuiMouseButton): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsMouseDoubleClicked';

function _igIsMouseReleasedWithDelay(_button: _ImGuiMouseButton; _delay: Single): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsMouseReleasedWithDelay';

function _igGetMouseClickedCount(_button: _ImGuiMouseButton): Int32; cdecl;
  external _LIB_SOKOL name _PU + 'igGetMouseClickedCount';

function _igIsMouseHoveringRect(_r_min, _r_max: _ImVec2): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsMouseHoveringRect';

function _igIsMouseHoveringRectEx(_r_min, _r_max: _ImVec2; _clip: Boolean): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsMouseHoveringRectEx';

function _igIsMousePosValid(_mouse_pos: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsMousePosValid';

function _igIsAnyMouseDown(): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsAnyMouseDown';

function _igGetMousePos(): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'igGetMousePos';

function _igGetMousePosOnOpeningCurrentPopup(): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'igGetMousePosOnOpeningCurrentPopup';

function _igIsMouseDragging(_button: _ImGuiMouseButton; _lock_threshold: Single): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igIsMouseDragging';

function _igGetMouseDragDelta(_button: _ImGuiMouseButton; _lock_threshold: Single): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'igGetMouseDragDelta';

procedure _igResetMouseDragDelta(); cdecl;
  external _LIB_SOKOL name _PU + 'igResetMouseDragDelta';

procedure _igResetMouseDragDeltaEx(_button: _ImGuiMouseButton); cdecl;
  external _LIB_SOKOL name _PU + 'igResetMouseDragDeltaEx';

function _igGetMouseCursor(): _ImGuiMouseCursor; cdecl;
  external _LIB_SOKOL name _PU + 'igGetMouseCursor';

procedure _igSetMouseCursor(_cursor_type: _ImGuiMouseCursor); cdecl;
  external _LIB_SOKOL name _PU + 'igSetMouseCursor';

procedure _igSetNextFrameWantCaptureMouse(_want_capture_mouse: Boolean); cdecl;
  external _LIB_SOKOL name _PU + 'igSetNextFrameWantCaptureMouse';

function _igGetClipboardText(): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igGetClipboardText';

procedure _igSetClipboardText(_text: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igSetClipboardText';

procedure _igLoadIniSettingsFromDisk(_ini_filename: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igLoadIniSettingsFromDisk';

procedure _igLoadIniSettingsFromMemory(_ini_data: Pointer; _ini_size: NativeUInt); cdecl;
  external _LIB_SOKOL name _PU + 'igLoadIniSettingsFromMemory';

procedure _igSaveIniSettingsToDisk(_ini_filename: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igSaveIniSettingsToDisk';

function _igSaveIniSettingsToMemory(_out_ini_size: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igSaveIniSettingsToMemory';

procedure _igDebugTextEncoding(_text: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igDebugTextEncoding';

procedure _igDebugFlashStyleColor(_idx: _ImGuiCol); cdecl;
  external _LIB_SOKOL name _PU + 'igDebugFlashStyleColor';

procedure _igDebugStartItemPicker(); cdecl;
  external _LIB_SOKOL name _PU + 'igDebugStartItemPicker';

function _igDebugCheckVersionAndDataLayout(_version_str: Pointer; _sz_io, _sz_style, _sz_vec2, _sz_vec4, _sz_drawvert, _sz_drawidx: NativeUInt): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'igDebugCheckVersionAndDataLayout';

procedure _igDebugLog(_fmt: Pointer); varargs; cdecl;
  external _LIB_SOKOL name _PU + 'igDebugLog';

procedure _igSetAllocatorFunctions(_alloc_func: _ImGuiMemAllocFunc; _free_func: _ImGuiMemFreeFunc; _user_data: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igSetAllocatorFunctions';

procedure _igGetAllocatorFunctions(_p_alloc_func: Pointer; _p_free_func: Pointer; _p_user_data: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igGetAllocatorFunctions';

function _igMemAlloc(_size: NativeUInt): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igMemAlloc';

procedure _igMemFree(_ptr: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igMemFree';

procedure _igUpdatePlatformWindows(); cdecl;
  external _LIB_SOKOL name _PU + 'igUpdatePlatformWindows';

procedure _igRenderPlatformWindowsDefault(); cdecl;
  external _LIB_SOKOL name _PU + 'igRenderPlatformWindowsDefault';

procedure _igRenderPlatformWindowsDefaultEx(_platform_render_arg: Pointer; _renderer_render_arg: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'igRenderPlatformWindowsDefaultEx';

procedure _igDestroyPlatformWindows(); cdecl;
  external _LIB_SOKOL name _PU + 'igDestroyPlatformWindows';

function _igFindViewportByID(_viewport_id: _ImGuiID): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igFindViewportByID';

function _igFindViewportByPlatformHandle(_platform_handle: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'igFindViewportByPlatformHandle';

procedure _ImGuiStyle_ScaleAllSizes(_self: Pointer; _scale_factor: Single); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiStyle_ScaleAllSizes';

procedure _ImGuiIO_AddKeyEvent(_self: Pointer; _key: _ImGuiKey; _down: Boolean); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_AddKeyEvent';

procedure _ImGuiIO_AddKeyAnalogEvent(_self: Pointer; _key: _ImGuiKey; _down: Boolean; _v: Single); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_AddKeyAnalogEvent';

procedure _ImGuiIO_AddMousePosEvent(_self: Pointer; _x, _y: Single); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_AddMousePosEvent';

procedure _ImGuiIO_AddMouseButtonEvent(_self: Pointer; _button: Int32; _down: Boolean); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_AddMouseButtonEvent';

procedure _ImGuiIO_AddMouseWheelEvent(_self: Pointer; _wheel_x, _wheel_y: Single); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_AddMouseWheelEvent';

procedure _ImGuiIO_AddMouseSourceEvent(_self: Pointer; _source: _ImGuiMouseSource); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_AddMouseSourceEvent';

procedure _ImGuiIO_AddMouseViewportEvent(_self: Pointer; _id: _ImGuiID); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_AddMouseViewportEvent';

procedure _ImGuiIO_AddFocusEvent(_self: Pointer; _focused: Boolean); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_AddFocusEvent';

procedure _ImGuiIO_AddInputCharacter(_self: Pointer; _c: UInt32); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_AddInputCharacter';

procedure _ImGuiIO_AddInputCharacterUTF16(_self: Pointer; _c: _ImWchar16); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_AddInputCharacterUTF16';

procedure _ImGuiIO_AddInputCharactersUTF8(_self: Pointer; _str: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_AddInputCharactersUTF8';

procedure _ImGuiIO_SetKeyEventNativeData(_self: Pointer; _key: _ImGuiKey; _native_keycode, _native_scancode: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_SetKeyEventNativeData';

procedure _ImGuiIO_SetKeyEventNativeDataEx(_self: Pointer; _key: _ImGuiKey; _native_keycode, _native_scancode: Int32; _native_legacy_index: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_SetKeyEventNativeDataEx';

procedure _ImGuiIO_SetAppAcceptingEvents(_self: Pointer; _accepting_events: Boolean); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_SetAppAcceptingEvents';

procedure _ImGuiIO_ClearEventsQueue(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_ClearEventsQueue';

procedure _ImGuiIO_ClearInputKeys(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_ClearInputKeys';

procedure _ImGuiIO_ClearInputMouse(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiIO_ClearInputMouse';

procedure _ImGuiInputTextCallbackData_DeleteChars(_self: Pointer; _pos, _bytes_count: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiInputTextCallbackData_DeleteChars';

procedure _ImGuiInputTextCallbackData_InsertChars(_self: Pointer; _pos: Int32; _text: Pointer; _text_end: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiInputTextCallbackData_InsertChars';

procedure _ImGuiInputTextCallbackData_SelectAll(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiInputTextCallbackData_SelectAll';

procedure _ImGuiInputTextCallbackData_SetSelection(_self: Pointer; _s, _e: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiInputTextCallbackData_SetSelection';

procedure _ImGuiInputTextCallbackData_ClearSelection(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiInputTextCallbackData_ClearSelection';

function _ImGuiInputTextCallbackData_HasSelection(_self: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiInputTextCallbackData_HasSelection';

procedure _ImGuiPayload_Clear(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiPayload_Clear';

function _ImGuiPayload_IsDataType(_self: Pointer; _type: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiPayload_IsDataType';

function _ImGuiPayload_IsPreview(_self: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiPayload_IsPreview';

function _ImGuiPayload_IsDelivery(_self: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiPayload_IsDelivery';

function _ImGuiTextFilter_ImGuiTextRange_empty(_self: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextFilter_ImGuiTextRange_empty';

procedure _ImGuiTextFilter_ImGuiTextRange_split(_self: Pointer; _separator: UTF8Char; _out: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextFilter_ImGuiTextRange_split';

function _ImGuiTextFilter_Draw(_self: Pointer; _label: Pointer; _width: Single): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextFilter_Draw';

function _ImGuiTextFilter_PassFilter(_self: Pointer; _text: Pointer; _text_end: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextFilter_PassFilter';

procedure _ImGuiTextFilter_Build(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextFilter_Build';

procedure _ImGuiTextFilter_Clear(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextFilter_Clear';

function _ImGuiTextFilter_IsActive(_self: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextFilter_IsActive';

function _ImGuiTextBuffer_begin(_self: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextBuffer_begin';

function _ImGuiTextBuffer_end(_self: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextBuffer_end';

function _ImGuiTextBuffer_size(_self: Pointer): Int32; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextBuffer_size';

function _ImGuiTextBuffer_empty(_self: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextBuffer_empty';

procedure _ImGuiTextBuffer_clear(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextBuffer_clear';

procedure _ImGuiTextBuffer_resize(_self: Pointer; _size: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextBuffer_resize';

procedure _ImGuiTextBuffer_reserve(_self: Pointer; _capacity: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextBuffer_reserve';

function _ImGuiTextBuffer_c_str(_self: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextBuffer_c_str';

procedure _ImGuiTextBuffer_append(_self: Pointer; _str: Pointer; _str_end: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextBuffer_append';

procedure _ImGuiTextBuffer_appendf(_self: Pointer; _fmt: Pointer); varargs; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiTextBuffer_appendf';

procedure _ImGuiStorage_Clear(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiStorage_Clear';

function _ImGuiStorage_GetInt(_self: Pointer; _key: _ImGuiID; _default_val: Int32): Int32; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiStorage_GetInt';

procedure _ImGuiStorage_SetInt(_self: Pointer; _key: _ImGuiID; _val: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiStorage_SetInt';

function _ImGuiStorage_GetBool(_self: Pointer; _key: _ImGuiID; _default_val: Boolean): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiStorage_GetBool';

procedure _ImGuiStorage_SetBool(_self: Pointer; _key: _ImGuiID; _val: Boolean); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiStorage_SetBool';

function _ImGuiStorage_GetFloat(_self: Pointer; _key: _ImGuiID; _default_val: Single): Single; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiStorage_GetFloat';

procedure _ImGuiStorage_SetFloat(_self: Pointer; _key: _ImGuiID; _val: Single); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiStorage_SetFloat';

function _ImGuiStorage_GetVoidPtr(_self: Pointer; _key: _ImGuiID): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiStorage_GetVoidPtr';

procedure _ImGuiStorage_SetVoidPtr(_self: Pointer; _key: _ImGuiID; _val: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiStorage_SetVoidPtr';

function _ImGuiStorage_GetIntRef(_self: Pointer; _key: _ImGuiID; _default_val: Int32): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiStorage_GetIntRef';

function _ImGuiStorage_GetBoolRef(_self: Pointer; _key: _ImGuiID; _default_val: Boolean): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiStorage_GetBoolRef';

function _ImGuiStorage_GetFloatRef(_self: Pointer; _key: _ImGuiID; _default_val: Single): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiStorage_GetFloatRef';

function _ImGuiStorage_GetVoidPtrRef(_self: Pointer; _key: _ImGuiID; _default_val: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiStorage_GetVoidPtrRef';

procedure _ImGuiStorage_BuildSortByKey(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiStorage_BuildSortByKey';

procedure _ImGuiStorage_SetAllInt(_self: Pointer; _val: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiStorage_SetAllInt';

procedure _ImGuiListClipper_Begin(_self: Pointer; _items_count: Int32; _items_height: Single); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiListClipper_Begin';

procedure _ImGuiListClipper_End(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiListClipper_End';

function _ImGuiListClipper_Step(_self: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiListClipper_Step';

procedure _ImGuiListClipper_IncludeItemByIndex(_self: Pointer; _item_index: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiListClipper_IncludeItemByIndex';

procedure _ImGuiListClipper_IncludeItemsByIndex(_self: Pointer; _item_begin, _item_end: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiListClipper_IncludeItemsByIndex';

procedure _ImGuiListClipper_SeekCursorForItem(_self: Pointer; _item_index: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiListClipper_SeekCursorForItem';

procedure _ImColor_SetHSV(_self: Pointer; _h, _s, _v: Single; _a: Single); cdecl;
  external _LIB_SOKOL name _PU + 'ImColor_SetHSV';

function _ImColor_HSV(_h, _s, _v: Single; _a: Single): _ImColor; cdecl;
  external _LIB_SOKOL name _PU + 'ImColor_HSV';

procedure _ImGuiSelectionBasicStorage_ApplyRequests(_self: Pointer; _ms_io: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiSelectionBasicStorage_ApplyRequests';

function _ImGuiSelectionBasicStorage_Contains(_self: Pointer; _id: _ImGuiID): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiSelectionBasicStorage_Contains';

procedure _ImGuiSelectionBasicStorage_Clear(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiSelectionBasicStorage_Clear';

procedure _ImGuiSelectionBasicStorage_Swap(_self: Pointer; _r: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiSelectionBasicStorage_Swap';

procedure _ImGuiSelectionBasicStorage_SetItemSelected(_self: Pointer; _id: _ImGuiID; _selected: Boolean); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiSelectionBasicStorage_SetItemSelected';

function _ImGuiSelectionBasicStorage_GetNextSelectedItem(_self: Pointer; _opaque_it: Pointer; _out_id: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiSelectionBasicStorage_GetNextSelectedItem';

function _ImGuiSelectionBasicStorage_GetStorageIdFromIndex(_self: Pointer; _idx: Int32): _ImGuiID; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiSelectionBasicStorage_GetStorageIdFromIndex';

procedure _ImGuiSelectionExternalStorage_ApplyRequests(_self: Pointer; _ms_io: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiSelectionExternalStorage_ApplyRequests';

function _ImDrawCmd_GetTexID(_self: Pointer): _ImTextureID; cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawCmd_GetTexID';

procedure _ImDrawListSplitter_Clear(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawListSplitter_Clear';

procedure _ImDrawListSplitter_ClearFreeMemory(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawListSplitter_ClearFreeMemory';

procedure _ImDrawListSplitter_Split(_self: Pointer; _draw_list: Pointer; _count: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawListSplitter_Split';

procedure _ImDrawListSplitter_Merge(_self: Pointer; _draw_list: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawListSplitter_Merge';

procedure _ImDrawListSplitter_SetCurrentChannel(_self: Pointer; _draw_list: Pointer; _channel_idx: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawListSplitter_SetCurrentChannel';

procedure _ImDrawList_PushClipRect(_self: Pointer; _clip_rect_min, _clip_rect_max: _ImVec2; _intersect_with_current_clip_rect: Boolean); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PushClipRect';

procedure _ImDrawList_PushClipRectFullScreen(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PushClipRectFullScreen';

procedure _ImDrawList_PopClipRect(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PopClipRect';

procedure _ImDrawList_PushTexture(_self: Pointer; _tex_ref: _ImTextureRef); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PushTexture';

procedure _ImDrawList_PopTexture(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PopTexture';

function _ImDrawList_GetClipRectMin(_self: Pointer): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_GetClipRectMin';

function _ImDrawList_GetClipRectMax(_self: Pointer): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_GetClipRectMax';

procedure _ImDrawList_AddLine(_self: Pointer; _p1, _p2: _ImVec2; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddLine';

procedure _ImDrawList_AddLineEx(_self: Pointer; _p1, _p2: _ImVec2; _col: _ImU32; _thickness: Single); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddLineEx';

procedure _ImDrawList_AddLineH(_self: Pointer; _min_x, _max_x, _y: Single; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddLineH';

procedure _ImDrawList_AddLineHEx(_self: Pointer; _min_x, _max_x, _y: Single; _col: _ImU32; _thickness: Single); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddLineHEx';

procedure _ImDrawList_AddLineV(_self: Pointer; _x, _min_y, _max_y: Single; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddLineV';

procedure _ImDrawList_AddLineVEx(_self: Pointer; _x, _min_y, _max_y: Single; _col: _ImU32; _thickness: Single); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddLineVEx';

procedure _ImDrawList_AddRect(_self: Pointer; _p_min, _p_max: _ImVec2; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddRect';

procedure _ImDrawList_AddRectEx(_self: Pointer; _p_min, _p_max: _ImVec2; _col: _ImU32; _rounding: Single; _thickness: Single; _flags: _ImDrawFlags); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddRectEx';

procedure _ImDrawList_AddRectFilled(_self: Pointer; _p_min, _p_max: _ImVec2; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddRectFilled';

procedure _ImDrawList_AddRectFilledEx(_self: Pointer; _p_min, _p_max: _ImVec2; _col: _ImU32; _rounding: Single; _flags: _ImDrawFlags); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddRectFilledEx';

procedure _ImDrawList_AddRectFilledMultiColor(_self: Pointer; _p_min, _p_max: _ImVec2; _col_upr_left, _col_upr_right, _col_bot_right, _col_bot_left: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddRectFilledMultiColor';

procedure _ImDrawList_AddQuad(_self: Pointer; _p1, _p2, _p3, _p4: _ImVec2; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddQuad';

procedure _ImDrawList_AddQuadEx(_self: Pointer; _p1, _p2, _p3, _p4: _ImVec2; _col: _ImU32; _thickness: Single); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddQuadEx';

procedure _ImDrawList_AddQuadFilled(_self: Pointer; _p1, _p2, _p3, _p4: _ImVec2; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddQuadFilled';

procedure _ImDrawList_AddTriangle(_self: Pointer; _p1, _p2, _p3: _ImVec2; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddTriangle';

procedure _ImDrawList_AddTriangleEx(_self: Pointer; _p1, _p2, _p3: _ImVec2; _col: _ImU32; _thickness: Single); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddTriangleEx';

procedure _ImDrawList_AddTriangleFilled(_self: Pointer; _p1, _p2, _p3: _ImVec2; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddTriangleFilled';

procedure _ImDrawList_AddCircle(_self: Pointer; _center: _ImVec2; _radius: Single; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddCircle';

procedure _ImDrawList_AddCircleEx(_self: Pointer; _center: _ImVec2; _radius: Single; _col: _ImU32; _num_segments: Int32; _thickness: Single); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddCircleEx';

procedure _ImDrawList_AddCircleFilled(_self: Pointer; _center: _ImVec2; _radius: Single; _col: _ImU32; _num_segments: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddCircleFilled';

procedure _ImDrawList_AddNgon(_self: Pointer; _center: _ImVec2; _radius: Single; _col: _ImU32; _num_segments: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddNgon';

procedure _ImDrawList_AddNgonEx(_self: Pointer; _center: _ImVec2; _radius: Single; _col: _ImU32; _num_segments: Int32; _thickness: Single); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddNgonEx';

procedure _ImDrawList_AddNgonFilled(_self: Pointer; _center: _ImVec2; _radius: Single; _col: _ImU32; _num_segments: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddNgonFilled';

procedure _ImDrawList_AddEllipse(_self: Pointer; _center, _radius: _ImVec2; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddEllipse';

procedure _ImDrawList_AddEllipseEx(_self: Pointer; _center, _radius: _ImVec2; _col: _ImU32; _rot: Single; _num_segments: Int32; _thickness: Single); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddEllipseEx';

procedure _ImDrawList_AddEllipseFilled(_self: Pointer; _center, _radius: _ImVec2; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddEllipseFilled';

procedure _ImDrawList_AddEllipseFilledEx(_self: Pointer; _center, _radius: _ImVec2; _col: _ImU32; _rot: Single; _num_segments: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddEllipseFilledEx';

procedure _ImDrawList_AddText(_self: Pointer; _pos: _ImVec2; _col: _ImU32; _text_begin: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddText';

procedure _ImDrawList_AddTextEx(_self: Pointer; _pos: _ImVec2; _col: _ImU32; _text_begin: Pointer; _text_end: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddTextEx';

procedure _ImDrawList_AddTextImFontPtr(_self: Pointer; _font: Pointer; _font_size: Single; _pos: _ImVec2; _col: _ImU32; _text_begin: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddTextImFontPtr';

procedure _ImDrawList_AddTextImFontPtrEx(_self: Pointer; _font: Pointer; _font_size: Single; _pos: _ImVec2; _col: _ImU32; _text_begin: Pointer; _text_end: Pointer; _wrap_width: Single; _cpu_fine_clip_rect: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddTextImFontPtrEx';

procedure _ImDrawList_AddBezierCubic(_self: Pointer; _p1, _p2, _p3, _p4: _ImVec2; _col: _ImU32; _thickness: Single; _num_segments: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddBezierCubic';

procedure _ImDrawList_AddBezierQuadratic(_self: Pointer; _p1, _p2, _p3: _ImVec2; _col: _ImU32; _thickness: Single; _num_segments: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddBezierQuadratic';

procedure _ImDrawList_AddPolyline(_self: Pointer; _points: Pointer; _num_points: Int32; _col: _ImU32; _thickness: Single; _flags: _ImDrawFlags); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddPolyline';

procedure _ImDrawList_AddConvexPolyFilled(_self: Pointer; _points: Pointer; _num_points: Int32; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddConvexPolyFilled';

procedure _ImDrawList_AddConcavePolyFilled(_self: Pointer; _points: Pointer; _num_points: Int32; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddConcavePolyFilled';

procedure _ImDrawList_AddImage(_self: Pointer; _tex_ref: _ImTextureRef; _p_min, _p_max: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddImage';

procedure _ImDrawList_AddImageEx(_self: Pointer; _tex_ref: _ImTextureRef; _p_min, _p_max, _uv_min, _uv_max: _ImVec2; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddImageEx';

procedure _ImDrawList_AddImageQuad(_self: Pointer; _tex_ref: _ImTextureRef; _p1, _p2, _p3, _p4: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddImageQuad';

procedure _ImDrawList_AddImageQuadEx(_self: Pointer; _tex_ref: _ImTextureRef; _p1, _p2, _p3, _p4, _uv1, _uv2, _uv3, _uv4: _ImVec2; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddImageQuadEx';

procedure _ImDrawList_AddImageRounded(_self: Pointer; _tex_ref: _ImTextureRef; _p_min, _p_max, _uv_min, _uv_max: _ImVec2; _col: _ImU32; _rounding: Single; _flags: _ImDrawFlags); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddImageRounded';

procedure _ImDrawList_PathClear(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PathClear';

procedure _ImDrawList_PathLineTo(_self: Pointer; _pos: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PathLineTo';

procedure _ImDrawList_PathLineToMergeDuplicate(_self: Pointer; _pos: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PathLineToMergeDuplicate';

procedure _ImDrawList_PathFillConvex(_self: Pointer; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PathFillConvex';

procedure _ImDrawList_PathFillConcave(_self: Pointer; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PathFillConcave';

procedure _ImDrawList_PathStroke(_self: Pointer; _col: _ImU32; _thickness: Single; _flags: _ImDrawFlags); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PathStroke';

procedure _ImDrawList_PathArcTo(_self: Pointer; _center: _ImVec2; _radius, _a_min, _a_max: Single; _num_segments: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PathArcTo';

procedure _ImDrawList_PathArcToFast(_self: Pointer; _center: _ImVec2; _radius: Single; _a_min_of_12, _a_max_of_12: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PathArcToFast';

procedure _ImDrawList_PathEllipticalArcTo(_self: Pointer; _center, _radius: _ImVec2; _rot, _a_min, _a_max: Single); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PathEllipticalArcTo';

procedure _ImDrawList_PathEllipticalArcToEx(_self: Pointer; _center, _radius: _ImVec2; _rot, _a_min, _a_max: Single; _num_segments: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PathEllipticalArcToEx';

procedure _ImDrawList_PathBezierCubicCurveTo(_self: Pointer; _p2, _p3, _p4: _ImVec2; _num_segments: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PathBezierCubicCurveTo';

procedure _ImDrawList_PathBezierQuadraticCurveTo(_self: Pointer; _p2, _p3: _ImVec2; _num_segments: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PathBezierQuadraticCurveTo';

procedure _ImDrawList_PathRect(_self: Pointer; _rect_min, _rect_max: _ImVec2; _rounding: Single; _flags: _ImDrawFlags); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PathRect';

procedure _ImDrawList_AddCallback(_self: Pointer; _callback: _ImDrawCallback); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddCallback';

procedure _ImDrawList_AddCallbackEx(_self: Pointer; _callback: _ImDrawCallback; _userdata: Pointer; _userdata_size: NativeUInt); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddCallbackEx';

procedure _ImDrawList_AddDrawCmd(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_AddDrawCmd';

function _ImDrawList_CloneOutput(_self: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_CloneOutput';

procedure _ImDrawList_ChannelsSplit(_self: Pointer; _count: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_ChannelsSplit';

procedure _ImDrawList_ChannelsMerge(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_ChannelsMerge';

procedure _ImDrawList_ChannelsSetCurrent(_self: Pointer; _n: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_ChannelsSetCurrent';

procedure _ImDrawList_PrimReserve(_self: Pointer; _idx_count, _vtx_count: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PrimReserve';

procedure _ImDrawList_PrimUnreserve(_self: Pointer; _idx_count, _vtx_count: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PrimUnreserve';

procedure _ImDrawList_PrimRect(_self: Pointer; _a, _b: _ImVec2; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PrimRect';

procedure _ImDrawList_PrimRectUV(_self: Pointer; _a, _b, _uv_a, _uv_b: _ImVec2; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PrimRectUV';

procedure _ImDrawList_PrimQuadUV(_self: Pointer; _a, _b, _c, _d, _uv_a, _uv_b, _uv_c, _uv_d: _ImVec2; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PrimQuadUV';

procedure _ImDrawList_PrimWriteVtx(_self: Pointer; _pos, _uv: _ImVec2; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PrimWriteVtx';

procedure _ImDrawList_PrimWriteIdx(_self: Pointer; _idx: _ImDrawIdx); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PrimWriteIdx';

procedure _ImDrawList_PrimVtx(_self: Pointer; _pos, _uv: _ImVec2; _col: _ImU32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList_PrimVtx';

procedure _ImDrawList__SetDrawListSharedData(_self: Pointer; _data: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList__SetDrawListSharedData';

procedure _ImDrawList__ResetForNewFrame(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList__ResetForNewFrame';

procedure _ImDrawList__ClearFreeMemory(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList__ClearFreeMemory';

procedure _ImDrawList__PopUnusedDrawCmd(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList__PopUnusedDrawCmd';

procedure _ImDrawList__TryMergeDrawCmds(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList__TryMergeDrawCmds';

procedure _ImDrawList__OnChangedClipRect(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList__OnChangedClipRect';

procedure _ImDrawList__OnChangedTexture(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList__OnChangedTexture';

procedure _ImDrawList__OnChangedVtxOffset(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList__OnChangedVtxOffset';

procedure _ImDrawList__SetTexture(_self: Pointer; _tex_ref: _ImTextureRef); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList__SetTexture';

function _ImDrawList__CalcCircleAutoSegmentCount(_self: Pointer; _radius: Single): Int32; cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList__CalcCircleAutoSegmentCount';

procedure _ImDrawList__PathArcToFastEx(_self: Pointer; _center: _ImVec2; _radius: Single; _a_min_sample, _a_max_sample, _a_step: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList__PathArcToFastEx';

procedure _ImDrawList__PathArcToN(_self: Pointer; _center: _ImVec2; _radius, _a_min, _a_max: Single; _num_segments: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawList__PathArcToN';

procedure _ImDrawData_Clear(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawData_Clear';

procedure _ImDrawData_AddDrawList(_self: Pointer; _draw_list: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawData_AddDrawList';

procedure _ImDrawData_DeIndexAllBuffers(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawData_DeIndexAllBuffers';

procedure _ImDrawData_ScaleClipRects(_self: Pointer; _fb_scale: _ImVec2); cdecl;
  external _LIB_SOKOL name _PU + 'ImDrawData_ScaleClipRects';

procedure _ImTextureData_Create(_self: Pointer; _format: _ImTextureFormat; _w, _h: Int32); cdecl;
  external _LIB_SOKOL name _PU + 'ImTextureData_Create';

procedure _ImTextureData_DestroyPixels(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImTextureData_DestroyPixels';

function _ImTextureData_GetPixels(_self: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImTextureData_GetPixels';

function _ImTextureData_GetPixelsAt(_self: Pointer; _x, _y: Int32): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImTextureData_GetPixelsAt';

function _ImTextureData_GetSizeInBytes(_self: Pointer): Int32; cdecl;
  external _LIB_SOKOL name _PU + 'ImTextureData_GetSizeInBytes';

function _ImTextureData_GetPitch(_self: Pointer): Int32; cdecl;
  external _LIB_SOKOL name _PU + 'ImTextureData_GetPitch';

function _ImTextureData_GetTexRef(_self: Pointer): _ImTextureRef; cdecl;
  external _LIB_SOKOL name _PU + 'ImTextureData_GetTexRef';

function _ImTextureData_GetTexID(_self: Pointer): _ImTextureID; cdecl;
  external _LIB_SOKOL name _PU + 'ImTextureData_GetTexID';

procedure _ImTextureData_SetTexID(_self: Pointer; _tex_id: _ImTextureID); cdecl;
  external _LIB_SOKOL name _PU + 'ImTextureData_SetTexID';

procedure _ImTextureData_SetStatus(_self: Pointer; _status: _ImTextureStatus); cdecl;
  external _LIB_SOKOL name _PU + 'ImTextureData_SetStatus';

procedure _ImFontGlyphRangesBuilder_Clear(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImFontGlyphRangesBuilder_Clear';

function _ImFontGlyphRangesBuilder_GetBit(_self: Pointer; _n: NativeUInt): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImFontGlyphRangesBuilder_GetBit';

procedure _ImFontGlyphRangesBuilder_SetBit(_self: Pointer; _n: NativeUInt); cdecl;
  external _LIB_SOKOL name _PU + 'ImFontGlyphRangesBuilder_SetBit';

procedure _ImFontGlyphRangesBuilder_AddChar(_self: Pointer; _c: _ImWchar); cdecl;
  external _LIB_SOKOL name _PU + 'ImFontGlyphRangesBuilder_AddChar';

procedure _ImFontGlyphRangesBuilder_AddText(_self: Pointer; _text: Pointer; _text_end: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImFontGlyphRangesBuilder_AddText';

procedure _ImFontGlyphRangesBuilder_AddRanges(_self: Pointer; _ranges: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImFontGlyphRangesBuilder_AddRanges';

procedure _ImFontGlyphRangesBuilder_BuildRanges(_self: Pointer; _out_ranges: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImFontGlyphRangesBuilder_BuildRanges';

function _ImFontAtlas_AddFont(_self: Pointer; _font_cfg: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_AddFont';

function _ImFontAtlas_AddFontDefault(_self: Pointer; _font_cfg: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_AddFontDefault';

function _ImFontAtlas_AddFontDefaultVector(_self: Pointer; _font_cfg: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_AddFontDefaultVector';

function _ImFontAtlas_AddFontDefaultBitmap(_self: Pointer; _font_cfg: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_AddFontDefaultBitmap';

function _ImFontAtlas_AddFontFromFileTTF(_self: Pointer; _filename: Pointer; _size_pixels: Single; _font_cfg: Pointer; _glyph_ranges: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_AddFontFromFileTTF';

function _ImFontAtlas_AddFontFromMemoryTTF(_self: Pointer; _font_data: Pointer; _font_data_size: Int32; _size_pixels: Single; _font_cfg: Pointer; _glyph_ranges: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_AddFontFromMemoryTTF';

function _ImFontAtlas_AddFontFromMemoryCompressedTTF(_self: Pointer; _compressed_font_data: Pointer; _compressed_font_data_size: Int32; _size_pixels: Single; _font_cfg: Pointer; _glyph_ranges: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_AddFontFromMemoryCompressedTTF';

function _ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(_self: Pointer; _compressed_font_data_base85: Pointer; _size_pixels: Single; _font_cfg: Pointer; _glyph_ranges: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_AddFontFromMemoryCompressedBase85TTF';

procedure _ImFontAtlas_RemoveFont(_self: Pointer; _font: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_RemoveFont';

procedure _ImFontAtlas_Clear(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_Clear';

procedure _ImFontAtlas_ClearFonts(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_ClearFonts';

procedure _ImFontAtlas_CompactCache(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_CompactCache';

procedure _ImFontAtlas_SetFontLoader(_self: Pointer; _font_loader: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_SetFontLoader';

procedure _ImFontAtlas_ClearInputData(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_ClearInputData';

procedure _ImFontAtlas_ClearTexData(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_ClearTexData';

function _ImFontAtlas_GetGlyphRangesDefault(_self: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_GetGlyphRangesDefault';

function _ImFontAtlas_AddCustomRect(_self: Pointer; _width, _height: Int32; _out_r: Pointer): _ImFontAtlasRectId; cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_AddCustomRect';

procedure _ImFontAtlas_RemoveCustomRect(_self: Pointer; _id: _ImFontAtlasRectId); cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_RemoveCustomRect';

function _ImFontAtlas_GetCustomRect(_self: Pointer; _id: _ImFontAtlasRectId; _out_r: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImFontAtlas_GetCustomRect';

procedure _ImFontBaked_ClearOutputData(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImFontBaked_ClearOutputData';

function _ImFontBaked_FindGlyph(_self: Pointer; _c: _ImWchar): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImFontBaked_FindGlyph';

function _ImFontBaked_FindGlyphNoFallback(_self: Pointer; _c: _ImWchar): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImFontBaked_FindGlyphNoFallback';

function _ImFontBaked_GetCharAdvance(_self: Pointer; _c: _ImWchar): Single; cdecl;
  external _LIB_SOKOL name _PU + 'ImFontBaked_GetCharAdvance';

function _ImFontBaked_IsGlyphLoaded(_self: Pointer; _c: _ImWchar): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImFontBaked_IsGlyphLoaded';

function _ImFont_IsGlyphInFont(_self: Pointer; _c: _ImWchar): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImFont_IsGlyphInFont';

function _ImFont_IsLoaded(_self: Pointer): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImFont_IsLoaded';

function _ImFont_GetDebugName(_self: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImFont_GetDebugName';

function _ImFont_GetFontBaked(_self: Pointer; _font_size: Single): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImFont_GetFontBaked';

function _ImFont_GetFontBakedEx(_self: Pointer; _font_size: Single; _density: Single): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImFont_GetFontBakedEx';

function _ImFont_CalcTextSizeA(_self: Pointer; _size, _max_width, _wrap_width: Single; _text_begin: Pointer): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'ImFont_CalcTextSizeA';

function _ImFont_CalcTextSizeAEx(_self: Pointer; _size, _max_width, _wrap_width: Single; _text_begin: Pointer; _text_end: Pointer; _out_remaining: Pointer): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'ImFont_CalcTextSizeAEx';

function _ImFont_CalcWordWrapPosition(_self: Pointer; _size: Single; _text, _text_end: Pointer; _wrap_width: Single): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImFont_CalcWordWrapPosition';

procedure _ImFont_RenderChar(_self: Pointer; _draw_list: Pointer; _size: Single; _pos: _ImVec2; _col: _ImU32; _c: _ImWchar); cdecl;
  external _LIB_SOKOL name _PU + 'ImFont_RenderChar';

procedure _ImFont_RenderCharEx(_self: Pointer; _draw_list: Pointer; _size: Single; _pos: _ImVec2; _col: _ImU32; _c: _ImWchar; _cpu_fine_clip: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImFont_RenderCharEx';

procedure _ImFont_RenderText(_self: Pointer; _draw_list: Pointer; _size: Single; _pos: _ImVec2; _col: _ImU32; _clip_rect: _ImVec4; _text_begin, _text_end: Pointer; _wrap_width: Single; _flags: _ImDrawTextFlags); cdecl;
  external _LIB_SOKOL name _PU + 'ImFont_RenderText';

procedure _ImFont_ClearOutputData(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImFont_ClearOutputData';

procedure _ImFont_AddRemapChar(_self: Pointer; _from_codepoint, _to_codepoint: _ImWchar); cdecl;
  external _LIB_SOKOL name _PU + 'ImFont_AddRemapChar';

function _ImFont_IsGlyphRangeUnused(_self: Pointer; _c_begin, _c_last: UInt32): Boolean; cdecl;
  external _LIB_SOKOL name _PU + 'ImFont_IsGlyphRangeUnused';

function _ImGuiViewport_GetCenter(_self: Pointer): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiViewport_GetCenter';

function _ImGuiViewport_GetWorkCenter(_self: Pointer): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiViewport_GetWorkCenter';

function _ImGuiViewport_GetDebugName(_self: Pointer): Pointer; cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiViewport_GetDebugName';

procedure _ImGuiPlatformIO_ClearPlatformHandlers(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiPlatformIO_ClearPlatformHandlers';

procedure _ImGuiPlatformIO_ClearRendererHandlers(_self: Pointer); cdecl;
  external _LIB_SOKOL name _PU + 'ImGuiPlatformIO_ClearRendererHandlers';


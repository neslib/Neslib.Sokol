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
  Neslib.FastMath,
  Neslib.Sokol.Api;

{$INCLUDE 'Neslib.ImGui.inc'}

type
  PUInt8 = ^UInt8;
  PUInt16 = ^UInt16;
  PInt32 = ^Int32;

type
  TImDrawIdx = UInt16; // Default: 16-bit (for maximum compatibility with renderer backends)
  PImDrawIdx = ^TImDrawIdx;
  // Scalar data types
  TImGuiID = UInt32; // A unique ID used by widgets (typically the result of hashing a stack of string)
  PImGuiID = ^TImGuiID;
  TImGuiKeyChord = Int32; // -> ImGuiKey | ImGuiMod_XXX    // Flags: for IsKeyChordPressed(), Shortcut() etc. an ImGuiKey optionally OR-ed with one or more ImGuiMod_XXX values.
  PImGuiKeyChord = ^TImGuiKeyChord;
  // Multi-Selection item index or identifier when using BeginMultiSelect()
  // - Used by SetNextItemSelectionUserData() + and inside ImGuiMultiSelectIO structure.
  // - Most users are likely to use this store an item INDEX but this may be used to store a POINTER/ID as well. Read comments near ImGuiMultiSelectIO for details.
  TImGuiSelectionUserData = Int64; 
  PImGuiSelectionUserData = ^TImGuiSelectionUserData;
  TImTextureID = UInt64; // Default: store up to 64-bits (any pointer or integer). A majority of backends are ok with that.
  PImTextureID = ^TImTextureID;
  // An opaque identifier to a rectangle in the atlas. -1 when invalid.
  // The rectangle may move and UV may be invalidated, use GetCustomRect() to retrieve it.
  TImFontAtlasRectId = Int32; 
  PImFontAtlasRectId = ^TImFontAtlasRectId;

const
  IM_COL32_WHITE = $FFFFFFFF;
  IM_COL32_BLACK = $FF000000;

type
  // Flags for ImGui::Begin()
  // (Those are per-window flags. There are shared flags in ImGuiIO: io.ConfigWindowsResizeFromEdges and io.ConfigWindowsMoveFromTitleBarOnly)
  TImGuiWindowFlag = (
    NoTitleBar = 0,                 // Disable title-bar 
    NoResize = 1,                   // Disable user resizing with the lower-right grip 
    NoMove = 2,                     // Disable user moving the window 
    NoScrollbar = 3,                // Disable scrollbars (window can still scroll with mouse or programmatically) 
    NoScrollWithMouse = 4,          // Disable user vertically scrolling with mouse wheel. On child window, mouse wheel will be forwarded to the parent unless NoScrollbar is also set. 
    NoCollapse = 5,                 // Disable user collapsing window by double-clicking on it. Also referred to as Window Menu Button (e.g. within a docking node). 
    AlwaysAutoResize = 6,           // Resize every window to its content every frame 
    NoBackground = 7,               // Disable drawing background color (WindowBg, etc.) and outside border. Similar as using SetNextWindowBgAlpha(0.0f). 
    NoSavedSettings = 8,            // Never load/save settings in .ini file 
    NoMouseInputs = 9,              // Disable catching mouse, hovering test with pass through. 
    MenuBar = 10,                   // Has a menu-bar 
    HorizontalScrollbar = 11,       // Allow horizontal scrollbar to appear (off by default). You may use SetNextWindowContentSize(ImVec2(width,0.0f)); prior to calling Begin() to specify width. Read code in imgui_demo in the "Horizontal Scrolling" section. 
    NoFocusOnAppearing = 12,        // Disable taking focus when transitioning from hidden to visible state 
    NoBringToFrontOnFocus = 13,     // Disable bringing window to front when taking focus (e.g. clicking on it or programmatically giving it focus) 
    AlwaysVerticalScrollbar = 14,   // Always show vertical scrollbar (even if ContentSize.y < Size.y) 
    AlwaysHorizontalScrollbar = 15, // Always show horizontal scrollbar (even if ContentSize.x < Size.x) 
    NoNavInputs = 16,               // No keyboard/gamepad navigation within the window 
    NoNavFocus = 17,                // No focusing toward this window with keyboard/gamepad navigation (e.g. skipped by Ctrl+Tab) 
    UnsavedDocument = 18,           // Display a dot next to the title. When used in a tab/docking context, tab is selected when clicking the X + closure is not assumed (will wait for user to stop submitting the tab). Otherwise closure is assumed when pressing the X, so if you keep submitting the tab may reappear at end of tab bar. 
    _ = 31); 
  TImGuiWindowFlags = set of TImGuiWindowFlag;

  _TImGuiWindowFlagsHelper = record helper for TImGuiWindowFlags
  public const
    None = []; 
    NoNav = [TImGuiWindowFlag.NoNavInputs, TImGuiWindowFlag.NoNavFocus]; 
    NoDecoration = [TImGuiWindowFlag.NoTitleBar, TImGuiWindowFlag.NoResize, TImGuiWindowFlag.NoScrollbar, TImGuiWindowFlag.NoCollapse]; 
    NoInputs = [TImGuiWindowFlag.NoMouseInputs, TImGuiWindowFlag.NoNavInputs, TImGuiWindowFlag.NoNavFocus]; 
  end;

type
  // Flags for ImGui::BeginChild()
  // (Legacy: bit 0 must always correspond to ImGuiChildFlags_Borders to be backward compatible with old API using 'bool border = false'.)
  // About using AutoResizeX/AutoResizeY flags:
  // - May be combined with SetNextWindowSizeConstraints() to set a min/max size for each axis (see "Demo->Child->Auto-resize with Constraints").
  // - Size measurement for a given axis is only performed when the child window is within visible boundaries, or is just appearing.
  //   - This allows BeginChild() to return false when not within boundaries (e.g. when scrolling), which is more optimal. BUT it won't update its auto-size while clipped.
  //     While not perfect, it is a better default behavior as the always-on performance gain is more valuable than the occasional "resizing after becoming visible again" glitch.
  //   - You may also use ImGuiChildFlags_AlwaysAutoResize to force an update even when child window is not in view.
  //     HOWEVER PLEASE UNDERSTAND THAT DOING SO WILL PREVENT BeginChild() FROM EVER RETURNING FALSE, disabling benefits of coarse clipping.
  TImGuiChildFlag = (
    Borders = 0,                // Show an outer border and enable WindowPadding. (IMPORTANT: this is always == 1 == true for legacy reason) 
    AlwaysUseWindowPadding = 1, // Pad with style.WindowPadding even if no border are drawn (no padding by default for non-bordered child windows because it makes more sense) 
    ResizeX = 2,                // Allow resize from right border (layout direction). Enable .ini saving (unless ImGuiWindowFlags_NoSavedSettings passed to window flags) 
    ResizeY = 3,                // Allow resize from bottom border (layout direction). " 
    AutoResizeX = 4,            // Enable auto-resizing width. Read "IMPORTANT: Size measurement" details above. 
    AutoResizeY = 5,            // Enable auto-resizing height. Read "IMPORTANT: Size measurement" details above. 
    AlwaysAutoResize = 6,       // Combined with AutoResizeX/AutoResizeY. Always measure size even when child is hidden, always return true, always disable clipping optimization! NOT RECOMMENDED. 
    FrameStyle = 7,             // Style the child window like a framed item: use FrameBg, FrameRounding, FrameBorderSize, FramePadding instead of ChildBg, ChildRounding, ChildBorderSize, WindowPadding. 
    NavFlattened = 8,           // [BETA] Share focus scope, allow keyboard/gamepad navigation to cross over parent border to this child or between sibling child windows. 
    _ = 31); 
  TImGuiChildFlags = set of TImGuiChildFlag;

  _TImGuiChildFlagsHelper = record helper for TImGuiChildFlags
  public const
    None = []; 
  end;

type
  // Flags for ImGui::PushItemFlag()
  // (Those are shared by all submitted items)
  TImGuiItemFlag = (
    NoTabStop = 0,         // false    // Disable keyboard tabbing. This is a "lighter" version of ImGuiItemFlags_NoNav. 
    NoNav = 1,             // false    // Disable any form of focusing (keyboard/gamepad directional navigation and SetKeyboardFocusHere() calls). 
    NoNavDefaultFocus = 2, // false    // Disable item being a candidate for default focus (e.g. used by title bar items). 
    ButtonRepeat = 3,      // false    // Any button-like behavior will have repeat mode enabled (based on io.KeyRepeatDelay and io.KeyRepeatRate values). Note that you can also call IsItemActive() after any button to tell if it is being held. 
    AutoClosePopups = 4,   // true     // MenuItem()/Selectable() automatically close their parent popup window. 
    AllowDuplicateId = 5,  // false    // Allow submitting an item with the same identifier as an item already submitted this frame without triggering a warning tooltip if io.ConfigDebugHighlightIdConflicts is set. 
    Disabled = 6,          // false    // [Internal] Disable interactions. DOES NOT affect visuals. This is used by BeginDisabled()/EndDisabled() and only provided here so you can read back via GetItemFlags(). 
    _ = 31); 
  TImGuiItemFlags = set of TImGuiItemFlag;

  _TImGuiItemFlagsHelper = record helper for TImGuiItemFlags
  public const
    None = []; // (Default)
  end;

type
  // Flags for ImGui::InputText()
  // (Those are per-item flags. There are shared flags in ImGuiIO: io.ConfigInputTextCursorBlink and io.ConfigInputTextEnterKeepActive)
  TImGuiInputTextFlag = (
    CharsDecimal = 0,        // Allow 0123456789.+-*/ 
    CharsHexadecimal = 1,    // Allow 0123456789ABCDEFabcdef 
    CharsScientific = 2,     // Allow 0123456789.+-*/eE (Scientific notation input) 
    CharsUppercase = 3,      // Turn a..z into A..Z 
    CharsNoBlank = 4,        // Filter out spaces, tabs 
    // Inputs
    AllowTabInput = 5,       // Pressing TAB input a '\t' character into the text field 
    EnterReturnsTrue = 6,    // Return 'true' when Enter is pressed (as opposed to every time the value was modified). Consider using IsItemDeactivatedAfterEdit() instead! 
    EscapeClearsAll = 7,     // Escape key clears content if not empty, and deactivate otherwise (contrast to default behavior of Escape to revert) 
    CtrlEnterForNewLine = 8, // In multi-line mode: validate with Enter, add new line with Ctrl+Enter (default is opposite: validate with Ctrl+Enter, add line with Enter). Note that Shift+Enter always enter a new line either way. 
    // Other options
    ReadOnly = 9,            // Read-only mode 
    Password = 10,           // Password mode, display all characters as '*', disable copy 
    AlwaysOverwrite = 11,    // Overwrite mode 
    AutoSelectAll = 12,      // Select entire text when first taking mouse focus 
    ParseEmptyRefVal = 13,   // InputFloat(), InputInt(), InputScalar() etc. only: parse empty string as zero value. 
    DisplayEmptyRefVal = 14, // InputFloat(), InputInt(), InputScalar() etc. only: when value is zero, do not display it. Generally used with ImGuiInputTextFlags_ParseEmptyRefVal. 
    NoHorizontalScroll = 15, // Disable following the cursor horizontally 
    NoUndoRedo = 16,         // Disable undo/redo. Note that input text owns the text data while active, if you want to provide your own undo/redo stack you need e.g. to call ClearActiveID(). 
    // Elide display / Alignment
    ElideLeft = 17,          // When text doesn't fit, elide left side to ensure right side stays visible. Useful for path/filenames. Single-line only! 
    // Callback features
    CallbackCompletion = 18, // Callback on pressing TAB (for completion handling) 
    CallbackHistory = 19,    // Callback on pressing Up/Down arrows (for history handling) 
    CallbackAlways = 20,     // Callback on each iteration. User code may query cursor position, modify text buffer. 
    CallbackCharFilter = 21, // Callback on character inputs to replace or discard them. Modify 'EventChar' to replace or discard, or return 1 in callback to discard. 
    CallbackResize = 22,     // Callback on buffer capacity changes request (beyond 'buf_size' parameter value), allowing the string to grow. Notify when the string wants to be resized (for string types which hold a cache of their Size). You will be provided a new BufSize in the callback and NEED to honor it. (see misc/cpp/imgui_stdlib.h for an example of using this) 
    CallbackEdit = 23,       // Callback on any edit. Note that InputText() already returns true on edit + you can always use IsItemEdited(). The callback is useful to manipulate the underlying buffer while focus is active. 
    // Multi-line Word-Wrapping [BETA]
    // - Not well tested yet. Please report any incorrect cursor movement, selection behavior etc. bug to https://github.com/ocornut/imgui/issues/3237.
    // - Wrapping style is not ideal. Wrapping of long words/sections (e.g. words larger than total available width) may be particularly unpleasing.
    // - Wrapping width needs to always account for the possibility of a vertical scrollbar.
    // - It is much slower than regular text fields.
    //   Ballpark estimate of cost on my 2019 desktop PC: for a 100 KB text buffer: +~0.3 ms (Optimized) / +~1.0 ms (Debug build).
    //   The CPU cost is very roughly proportional to text length, so a 10 KB buffer should cost about ten times less.
    WordWrap = 24);          // InputTextMultiline(): word-wrap lines that are too long. 
  TImGuiInputTextFlags = set of TImGuiInputTextFlag;

  _TImGuiInputTextFlagsHelper = record helper for TImGuiInputTextFlags
  public const
    None = []; 
  end;

type
  // Flags for ImGui::TreeNodeEx(), ImGui::CollapsingHeader*()
  TImGuiTreeNodeFlag = (
    Selected = 0,              // Draw as selected 
    Framed = 1,                // Draw frame with background (e.g. for CollapsingHeader) 
    AllowOverlap = 2,          // Hit testing will allow subsequent widgets to overlap this one. Require previous frame HoveredId to match before being usable. Shortcut to calling SetNextItemAllowOverlap(). 
    NoTreePushOnOpen = 3,      // Don't do a TreePush() when open (e.g. for CollapsingHeader) = no extra indent nor pushing on ID stack 
    NoAutoOpenOnLog = 4,       // Don't automatically and temporarily open node when Logging is active (by default logging will automatically open tree nodes) 
    DefaultOpen = 5,           // Default node to be open 
    OpenOnDoubleClick = 6,     // Open on double-click instead of simple click (default for multi-select unless any _OpenOnXXX behavior is set explicitly). Both behaviors may be combined. 
    OpenOnArrow = 7,           // Open when clicking on the arrow part (default for multi-select unless any _OpenOnXXX behavior is set explicitly). Both behaviors may be combined. 
    Leaf = 8,                  // No collapsing, no arrow (use as a convenience for leaf nodes). Note: will always open a tree/id scope and return true. If you never use that scope, add ImGuiTreeNodeFlags_NoTreePushOnOpen. 
    Bullet = 9,                // Display a bullet instead of arrow. IMPORTANT: node can still be marked open/close if you don't set the _Leaf flag! 
    FramePadding = 10,         // Use FramePadding (even for an unframed text node) to vertically align text baseline to regular widget height. Equivalent to calling AlignTextToFramePadding() before the node. 
    SpanAvailWidth = 11,       // Extend hit box to the right-most edge, even if not framed. This is not the default in order to allow adding other items on the same line without using AllowOverlap mode. 
    SpanFullWidth = 12,        // Extend hit box to the left-most and right-most edges (cover the indent area). 
    SpanLabelWidth = 13,       // Narrow hit box + narrow hovering highlight, will only cover the label text. 
    SpanAllColumns = 14,       // Frame will span all columns of its container table (label will still fit in current column) 
    LabelSpanAllColumns = 15,  // Label will span all columns of its container table 
    //ImGuiTreeNodeFlags_NoScrollOnOpen     = 1 << 16,  // FIXME: TODO: Disable automatic scroll on TreePop() if node got just open and contents is not visible
    NavLeftJumpsToParent = 17, // Nav: left arrow moves back to parent. This is processed in TreePop() when there's an unfulfilled Left nav request remaining. 
    // [EXPERIMENTAL] Draw lines connecting TreeNode hierarchy. Discuss in GitHub issue #2920.
    // Default value is pulled from style.TreeLinesFlags. May be overridden in TreeNode calls.
    DrawLinesNone = 18,        // No lines drawn 
    DrawLinesFull = 19,        // Horizontal lines to child nodes. Vertical line drawn down to TreePop() position: cover full contents. Faster (for large trees). 
    DrawLinesToNodes = 20,     // Horizontal lines to child nodes. Vertical line drawn down to bottom-most child node. Slower (for large trees). 
    _ = 31); 
  TImGuiTreeNodeFlags = set of TImGuiTreeNodeFlag;

  _TImGuiTreeNodeFlagsHelper = record helper for TImGuiTreeNodeFlags
  public const
    None = []; 
    CollapsingHeader = [TImGuiTreeNodeFlag.Framed, TImGuiTreeNodeFlag.NoTreePushOnOpen, TImGuiTreeNodeFlag.NoAutoOpenOnLog]; 
  end;

type
  // Flags for OpenPopup*(), BeginPopupContext*(), IsPopupOpen() functions.
  // - IMPORTANT: If you ever used the left mouse button with BeginPopupContextXXX() helpers before 1.92.6: Read "API BREAKING CHANGES" 2026/01/07 (1.92.6) entry in imgui.cpp or GitHub topic #9157.
  // - Multiple buttons currently cannot be combined/or-ed in those functions (we could allow it later).
  TImGuiPopupFlag = (
    MouseButtonLeft = 2,         // For BeginPopupContext*(): open on Left Mouse release. Only one button allowed! 
    MouseButtonRight = 3,        // For BeginPopupContext*(): open on Right Mouse release. Only one button allowed! (default) 
    NoReopen = 5,                // For OpenPopup*(), BeginPopupContext*(): don't reopen same popup if already open (won't reposition, won't reinitialize navigation) 
    //ImGuiPopupFlags_NoReopenAlwaysNavInit = 1 << 6,   // For OpenPopup*(), BeginPopupContext*(): focus and initialize navigation even when not reopening.
    NoOpenOverExistingPopup = 7, // For OpenPopup*(), BeginPopupContext*(): don't open if there's already a popup at the same level of the popup stack 
    NoOpenOverItems = 8,         // For BeginPopupContextWindow(): don't return true when hovering items, only when hovering empty space 
    AnyPopupId = 10,             // For IsPopupOpen(): ignore the ImGuiID parameter and test for any popup. 
    AnyPopupLevel = 11,          // For IsPopupOpen(): search/test at any level of the popup stack (default test in the current level) 
    _ = 31); 
  TImGuiPopupFlags = set of TImGuiPopupFlag;

  _TImGuiPopupFlagsHelper = record helper for TImGuiPopupFlags
  public const
    None = []; 
    MouseButtonMiddle = [TImGuiPopupFlag.MouseButtonLeft, TImGuiPopupFlag.MouseButtonRight]; // For BeginPopupContext*(): open on Middle Mouse release. Only one button allowed!
    AnyPopup = [TImGuiPopupFlag.AnyPopupId, TImGuiPopupFlag.AnyPopupLevel]; 
  end;

type
  // Flags for ImGui::Selectable()
  TImGuiSelectableFlag = (
    NoAutoClosePopups = 0, // Clicking this doesn't close parent popup window (overrides ImGuiItemFlags_AutoClosePopups) 
    SpanAllColumns = 1,    // Frame will span all columns of its container table (text will still fit in current column) 
    AllowDoubleClick = 2,  // Generate press events on double clicks too 
    Disabled = 3,          // Cannot be selected, display grayed out text 
    AllowOverlap = 4,      // Hit testing will allow subsequent widgets to overlap this one. Require previous frame HoveredId to match before being usable. Shortcut to calling SetNextItemAllowOverlap(). 
    Highlight = 5,         // Make the item be displayed as if it is hovered 
    SelectOnNav = 6,       // Auto-select when moved into, unless Ctrl is held. Automatic when in a BeginMultiSelect() block. 
    _ = 31); 
  TImGuiSelectableFlags = set of TImGuiSelectableFlag;

  _TImGuiSelectableFlagsHelper = record helper for TImGuiSelectableFlags
  public const
    None = []; 
  end;

type
  // Flags for ImGui::BeginCombo()
  TImGuiComboFlag = (
    PopupAlignLeft = 0,  // Align the popup toward the left by default 
    HeightSmall = 1,     // Max ~4 items visible. Tip: If you want your combo popup to be a specific size you can use SetNextWindowSizeConstraints() prior to calling BeginCombo() 
    HeightRegular = 2,   // Max ~8 items visible (default) 
    HeightLarge = 3,     // Max ~20 items visible 
    HeightLargest = 4,   // As many fitting items as possible 
    NoArrowButton = 5,   // Display on the preview box without the square arrow button 
    NoPreview = 6,       // Display only a square arrow button 
    WidthFitPreview = 7, // Width dynamically calculated from preview contents 
    _ = 31); 
  TImGuiComboFlags = set of TImGuiComboFlag;

  _TImGuiComboFlagsHelper = record helper for TImGuiComboFlags
  public const
    None = []; 
  end;

type
  // Flags for ImGui::BeginTabBar()
  TImGuiTabBarFlag = (
    Reorderable = 0,                  // Allow manually dragging tabs to re-order them + New tabs are appended at the end of list 
    AutoSelectNewTabs = 1,            // Automatically select new tabs when they appear 
    TabListPopupButton = 2,           // Disable buttons to open the tab list popup 
    NoCloseWithMiddleMouseButton = 3, // Disable behavior of closing tabs (that are submitted with p_open != NULL) with middle mouse button. You may handle this behavior manually on user's side with if (IsItemHovered() && IsMouseClicked(2)) *p_open = false. 
    NoTabListScrollingButtons = 4,    // Disable scrolling buttons (apply when fitting policy is ImGuiTabBarFlags_FittingPolicyScroll) 
    NoTooltip = 5,                    // Disable tooltips when hovering a tab 
    DrawSelectedOverline = 6,         // Draw selected overline markers over selected tab 
    // Fitting/Resize policy
    FittingPolicyMixed = 7,           // Shrink down tabs when they don't fit, until width is style.TabMinWidthShrink, then enable scrolling. Setting TabMinWidthShrink to FLT_MAX makes this behave like ImGuiTabBarFlags_FittingPolicyScroll. 
    FittingPolicyShrink = 8,          // Shrink down tabs when they don't fit 
    FittingPolicyScroll = 9,          // Enable scrolling buttons when tabs don't fit 
    _ = 31); 
  TImGuiTabBarFlags = set of TImGuiTabBarFlag;

  _TImGuiTabBarFlagsHelper = record helper for TImGuiTabBarFlags
  public const
    None = []; 
  end;

type
  // Flags for ImGui::BeginTabItem()
  TImGuiTabItemFlag = (
    UnsavedDocument = 0,              // Display a dot next to the title + set ImGuiTabItemFlags_NoAssumedClosure. 
    SetSelected = 1,                  // Trigger flag to programmatically make the tab selected when calling BeginTabItem() 
    NoCloseWithMiddleMouseButton = 2, // Disable behavior of closing tabs (that are submitted with p_open != NULL) with middle mouse button. You may handle this behavior manually on user's side with if (IsItemHovered() && IsMouseClicked(2)) *p_open = false. 
    NoPushId = 3,                     // Don't call PushID()/PopID() on BeginTabItem()/EndTabItem() 
    NoTooltip = 4,                    // Disable tooltip for the given tab 
    NoReorder = 5,                    // Disable reordering this tab or having another tab cross over this tab 
    Leading = 6,                      // Enforce the tab position to the left of the tab bar (after the tab list popup button) 
    Trailing = 7,                     // Enforce the tab position to the right of the tab bar (before the scrolling buttons) 
    NoAssumedClosure = 8,             // Tab is selected when trying to close + closure is not immediately assumed (will wait for user to stop submitting the tab). Otherwise closure is assumed when pressing the X, so if you keep submitting the tab may reappear at end of tab bar. 
    _ = 31); 
  TImGuiTabItemFlags = set of TImGuiTabItemFlag;

  _TImGuiTabItemFlagsHelper = record helper for TImGuiTabItemFlags
  public const
    None = []; 
  end;

type
  // Flags for ImGui::IsWindowFocused()
  TImGuiFocusedFlag = (
    ChildWindows = 0,     // Return true if any children of the window is focused 
    RootWindow = 1,       // Test from root window (top most parent of the current hierarchy) 
    AnyWindow = 2,        // Return true if any window is focused. Important: If you are trying to tell how to dispatch your low-level inputs, do NOT use this. Use 'io.WantCaptureMouse' instead! Please read the FAQ! 
    NoPopupHierarchy = 3, // Do not consider popup hierarchy (do not treat popup emitter as parent of popup) (when used with _ChildWindows or _RootWindow) 
    _ = 31); 
  TImGuiFocusedFlags = set of TImGuiFocusedFlag;

  _TImGuiFocusedFlagsHelper = record helper for TImGuiFocusedFlags
  public const
    None = []; 
    RootAndChildWindows = [TImGuiFocusedFlag.ChildWindows, TImGuiFocusedFlag.RootWindow]; 
  end;

type
  // Flags for ImGui::IsItemHovered(), ImGui::IsWindowHovered()
  // Note: if you are trying to check whether your mouse should be dispatched to Dear ImGui or to your app, you should use 'io.WantCaptureMouse' instead! Please read the FAQ!
  // Note: windows with the ImGuiWindowFlags_NoInputs flag are ignored by IsWindowHovered() calls.
  TImGuiHoveredFlag = (
    ChildWindows = 0,                 // IsWindowHovered() only: Return true if any children of the window is hovered 
    RootWindow = 1,                   // IsWindowHovered() only: Test from root window (top most parent of the current hierarchy) 
    AnyWindow = 2,                    // IsWindowHovered() only: Return true if any window is hovered 
    NoPopupHierarchy = 3,             // IsWindowHovered() only: Do not consider popup hierarchy (do not treat popup emitter as parent of popup) (when used with _ChildWindows or _RootWindow) 
    //ImGuiHoveredFlags_DockHierarchy               = 1 << 4,   // IsWindowHovered() only: Consider docking hierarchy (treat dockspace host as parent of docked window) (when used with _ChildWindows or _RootWindow)
    AllowWhenBlockedByPopup = 5,      // Return true even if a popup window is normally blocking access to this item/window 
    //ImGuiHoveredFlags_AllowWhenBlockedByModal     = 1 << 6,   // Return true even if a modal popup window is normally blocking access to this item/window. FIXME-TODO: Unavailable yet.
    AllowWhenBlockedByActiveItem = 7, // Return true even if an active item is blocking access to this item/window. Useful for Drag and Drop patterns. 
    AllowWhenOverlappedByItem = 8,    // IsItemHovered() only: Return true even if the item uses AllowOverlap mode and is overlapped by another hoverable item. 
    AllowWhenOverlappedByWindow = 9,  // IsItemHovered() only: Return true even if the position is obstructed or overlapped by another window. 
    AllowWhenDisabled = 10,           // IsItemHovered() only: Return true even if the item is disabled 
    NoNavOverride = 11,               // IsItemHovered() only: Disable using keyboard/gamepad navigation state when active, always query mouse 
    // Tooltips mode
    // - typically used in IsItemHovered() + SetTooltip() sequence.
    // - this is a shortcut to pull flags from 'style.HoverFlagsForTooltipMouse' or 'style.HoverFlagsForTooltipNav' where you can reconfigure desired behavior.
    //   e.g. 'HoverFlagsForTooltipMouse' defaults to 'ImGuiHoveredFlags_Stationary | ImGuiHoveredFlags_DelayShort | ImGuiHoveredFlags_AllowWhenDisabled'.
    // - for frequently actioned or hovered items providing a tooltip, you want may to use ImGuiHoveredFlags_ForTooltip (stationary + delay) so the tooltip doesn't show too often.
    // - for items which main purpose is to be hovered, or items with low affordance, or in less consistent apps, prefer no delay or shorter delay.
    ForTooltip = 12,                  // Shortcut for standard flags when using IsItemHovered() + SetTooltip() sequence. 
    // (Advanced) Mouse Hovering delays.
    // - generally you can use ImGuiHoveredFlags_ForTooltip to use application-standardized flags.
    // - use those if you need specific overrides.
    Stationary = 13,                  // Require mouse to be stationary for style.HoverStationaryDelay (~0.15 sec) _at least one time_. After this, can move on same item/window. Using the stationary test tends to reduces the need for a long delay. 
    DelayNone = 14,                   // IsItemHovered() only: Return true immediately (default). As this is the default you generally ignore this. 
    DelayShort = 15,                  // IsItemHovered() only: Return true after style.HoverDelayShort elapsed (~0.15 sec) (shared between items) + requires mouse to be stationary for style.HoverStationaryDelay (once per item). 
    DelayNormal = 16,                 // IsItemHovered() only: Return true after style.HoverDelayNormal elapsed (~0.40 sec) (shared between items) + requires mouse to be stationary for style.HoverStationaryDelay (once per item). 
    NoSharedDelay = 17,               // IsItemHovered() only: Disable shared delay system where moving from one item to the next keeps the previous timer for a short time (standard for tooltips with long delays) 
    _ = 31); 
  TImGuiHoveredFlags = set of TImGuiHoveredFlag;

  _TImGuiHoveredFlagsHelper = record helper for TImGuiHoveredFlags
  public const
    None = []; // Return true if directly over the item/window, not obstructed by another window, not obstructed by an active popup or modal blocking inputs under them.
    AllowWhenOverlapped = [TImGuiHoveredFlag.AllowWhenOverlappedByItem, TImGuiHoveredFlag.AllowWhenOverlappedByWindow]; 
    RectOnly = [TImGuiHoveredFlag.AllowWhenBlockedByPopup, TImGuiHoveredFlag.AllowWhenBlockedByActiveItem, TImGuiHoveredFlag.AllowWhenOverlappedByItem, TImGuiHoveredFlag.AllowWhenOverlappedByWindow]; 
    RootAndChildWindows = [TImGuiHoveredFlag.ChildWindows, TImGuiHoveredFlag.RootWindow]; 
  end;

type
  // Flags for ImGui::BeginDragDropSource(), ImGui::AcceptDragDropPayload()
  TImGuiDragDropFlag = (
    // BeginDragDropSource() flags
    SourceNoPreviewTooltip = 0,   // Disable preview tooltip. By default, a successful call to BeginDragDropSource opens a tooltip so you can display a preview or description of the source contents. This flag disables this behavior. 
    SourceNoDisableHover = 1,     // By default, when dragging we clear data so that IsItemHovered() will return false, to avoid subsequent user code submitting tooltips. This flag disables this behavior so you can still call IsItemHovered() on the source item. 
    SourceNoHoldToOpenOthers = 2, // Disable the behavior that allows to open tree nodes and collapsing header by holding over them while dragging a source item. 
    SourceAllowNullID = 3,        // Allow items such as Text(), Image() that have no unique identifier to be used as drag source, by manufacturing a temporary identifier based on their window-relative position. This is extremely unusual within the dear imgui ecosystem and so we made it explicit. 
    SourceExtern = 4,             // External source (from outside of dear imgui), won't attempt to read current item/window info. Will always return true. Only one Extern source can be active simultaneously. 
    PayloadAutoExpire = 5,        // Automatically expire the payload if the source cease to be submitted (otherwise payloads are persisting while being dragged) 
    PayloadNoCrossContext = 6,    // Hint to specify that the payload may not be copied outside current dear imgui context. 
    PayloadNoCrossProcess = 7,    // Hint to specify that the payload may not be copied outside current process. 
    // AcceptDragDropPayload() flags
    AcceptBeforeDelivery = 10,    // AcceptDragDropPayload() will returns true even before the mouse button is released. You can then call IsDelivery() to test if the payload needs to be delivered. 
    AcceptNoDrawDefaultRect = 11, // Do not draw the default highlight rectangle when hovering over target. 
    AcceptNoPreviewTooltip = 12,  // Request hiding the BeginDragDropSource tooltip from the BeginDragDropTarget site. 
    AcceptDrawAsHovered = 13,     // Accepting item will render as if hovered. Useful for e.g. a Button() used as a drop target. 
    _ = 31); 
  TImGuiDragDropFlags = set of TImGuiDragDropFlag;

  _TImGuiDragDropFlagsHelper = record helper for TImGuiDragDropFlags
  public const
    None = []; 
    AcceptPeekOnly = [TImGuiDragDropFlag.AcceptBeforeDelivery, TImGuiDragDropFlag.AcceptNoDrawDefaultRect]; // For peeking ahead and inspecting the payload before delivery.
  end;

type
  // A primary data type
  TImGuiDataType = (
    S8 = 0,        // signed char / char (with sensible compilers) 
    U8 = 1,        // unsigned char 
    S16 = 2,       // short 
    U16 = 3,       // unsigned short 
    S32 = 4,       // int 
    U32 = 5,       // unsigned int 
    S64 = 6,       // long long / __int64 
    U64 = 7,       // unsigned long long / unsigned __int64 
    Float = 8,     // float 
    Double = 9,    // double 
    Bool = 10,     // bool (provided for user convenience, not supported by scalar widgets) 
    &String = 11); // char* (provided for user convenience, not supported by scalar widgets) 

type
  // A cardinal direction
  TImGuiDir = (
    None = -1, 
    Left = 0, 
    Right = 1, 
    Up = 2, 
    Down = 3); 

type
  // A sorting direction
  TImGuiSortDirection = (
    None = 0, 
    Ascending = 1,   // Ascending = 0->9, A->Z etc. 
    Descending = 2); // Descending = 9->0, Z->A etc. 

type
  // A key identifier (ImGuiKey_XXX or ImGuiMod_XXX value): can represent Keyboard, Mouse and Gamepad values.
  // All our named keys are >= 512. Keys value 0 to 511 are left unused and were legacy native/opaque key values (< 1.87).
  // Support for legacy keys was completely removed in 1.91.5.
  // Read details about the 1.87+ transition : https://github.com/ocornut/imgui/issues/4921
  // Note that "Keys" related to physical keys and are not the same concept as input "Characters", the latter are submitted via io.AddInputCharacter().
  // The keyboard key enum values are named after the keys on a standard US keyboard, and on other keyboard types the keys reported may not match the keycaps.
  TImGuiKey = (
    // Keyboard
    None = 0, 
    NamedKeyBEGIN = 512,      // First valid key value (other than 0) 
    Tab = 512,                // == ImGuiKey_NamedKey_BEGIN 
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
    LeftSuper = 530,          // Also see ImGuiMod_Ctrl, ImGuiMod_Shift, ImGuiMod_Alt, ImGuiMod_Super below! 
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
    F13 = 584, 
    F14 = 585, 
    F15 = 586, 
    F16 = 587, 
    F17 = 588, 
    F18 = 589, 
    F19 = 590, 
    F20 = 591, 
    F21 = 592, 
    F22 = 593, 
    F23 = 594, 
    F24 = 595, 
    Apostrophe = 596,         // ' 
    Comma = 597,              // , 
    Minus = 598,              // - 
    Period = 599,             // . 
    Slash = 600,              // / 
    Semicolon = 601,          // ; 
    Equal = 602,              // = 
    LeftBracket = 603,        // [ 
    Backslash = 604,          // \ (this text inhibit multiline comment caused by backslash) 
    RightBracket = 605,       // ] 
    GraveAccent = 606,        // ` 
    CapsLock = 607, 
    ScrollLock = 608, 
    NumLock = 609, 
    PrintScreen = 610, 
    Pause = 611, 
    Keypad0 = 612, 
    Keypad1 = 613, 
    Keypad2 = 614, 
    Keypad3 = 615, 
    Keypad4 = 616, 
    Keypad5 = 617, 
    Keypad6 = 618, 
    Keypad7 = 619, 
    Keypad8 = 620, 
    Keypad9 = 621, 
    KeypadDecimal = 622, 
    KeypadDivide = 623, 
    KeypadMultiply = 624, 
    KeypadSubtract = 625, 
    KeypadAdd = 626, 
    KeypadEnter = 627, 
    KeypadEqual = 628, 
    AppBack = 629,            // Available on some keyboard/mouses. Often referred as "Browser Back" 
    AppForward = 630, 
    Oem102 = 631,             // Non-US backslash. 
    // Gamepad
    // (analog values are 0.0f to 1.0f)
    // (download controller mapping PNG/PSD at http://dearimgui.com/controls_sheets)
    //                              // XBOX        | SWITCH  | PLAYSTA. | -> ACTION
    GamepadStart = 632,       // Menu        | +       | Options  | 
    GamepadBack = 633,        // View        | -       | Share    | 
    GamepadFaceLeft = 634,    // X           | Y       | Square   | Toggle Menu. Hold for Windowing mode (Focus/Move/Resize windows) 
    GamepadFaceRight = 635,   // B           | A       | Circle   | Cancel / Close / Exit 
    GamepadFaceUp = 636,      // Y           | X       | Triangle | Open Context Menu 
    GamepadFaceDown = 637,    // A           | B       | Cross    | Activate / Open / Toggle. Hold for 0.60f to Activate in Text Input mode (e.g. wired to an on-screen keyboard). 
    GamepadDpadLeft = 638,    // D-pad Left  | "       | "        | Move / Tweak / Resize Window (in Windowing mode) 
    GamepadDpadRight = 639,   // D-pad Right | "       | "        | Move / Tweak / Resize Window (in Windowing mode) 
    GamepadDpadUp = 640,      // D-pad Up    | "       | "        | Move / Tweak / Resize Window (in Windowing mode) 
    GamepadDpadDown = 641,    // D-pad Down  | "       | "        | Move / Tweak / Resize Window (in Windowing mode) 
    GamepadL1 = 642,          // L Bumper    | L       | L1       | Tweak Slower / Focus Previous (in Windowing mode) 
    GamepadR1 = 643,          // R Bumper    | R       | R1       | Tweak Faster / Focus Next (in Windowing mode) 
    GamepadL2 = 644,          // L Trigger   | ZL      | L2       | [Analog] 
    GamepadR2 = 645,          // R Trigger   | ZR      | R2       | [Analog] 
    GamepadL3 = 646,          // L Stick     | L3      | L3       | 
    GamepadR3 = 647,          // R Stick     | R3      | R3       | 
    GamepadLStickLeft = 648,  //             |         |          | [Analog] Move Window (in Windowing mode) 
    GamepadLStickRight = 649, //             |         |          | [Analog] Move Window (in Windowing mode) 
    GamepadLStickUp = 650,    //             |         |          | [Analog] Move Window (in Windowing mode) 
    GamepadLStickDown = 651,  //             |         |          | [Analog] Move Window (in Windowing mode) 
    GamepadRStickLeft = 652,  //             |         |          | [Analog] 
    GamepadRStickRight = 653, //             |         |          | [Analog] 
    GamepadRStickUp = 654,    //             |         |          | [Analog] 
    GamepadRStickDown = 655,  //             |         |          | [Analog] 
    // Aliases: Mouse Buttons (auto-submitted from AddMouseButtonEvent() calls)
    // - This is mirroring the data also written to io.MouseDown[], io.MouseWheel, in a format allowing them to be accessed via standard key API.
    MouseLeft = 656, 
    MouseRight = 657, 
    MouseMiddle = 658, 
    MouseX1 = 659, 
    MouseX2 = 660, 
    MouseWheelX = 661, 
    MouseWheelY = 662, 
    // Keyboard Modifiers (explicitly submitted by backend via AddKeyEvent() calls)
    // - Any functions taking a ImGuiKeyChord parameter can binary-or those with regular keys, e.g. Shortcut(ImGuiMod_Ctrl | ImGuiKey_S).
    // - Those are written back into io.KeyCtrl, io.KeyShift, io.KeyAlt, io.KeySuper for convenience,
    //   but may be accessed via standard key API such as IsKeyPressed(), IsKeyReleased(), querying duration etc.
    // - Code polling every key (e.g. an interface to detect a key press for input mapping) might want to ignore those
    //   and prefer using the real keys (e.g. ImGuiKey_LeftCtrl, ImGuiKey_RightCtrl instead of ImGuiMod_Ctrl).
    // - In theory the value of keyboard modifiers should be roughly equivalent to a logical or of the equivalent left/right keys.
    //   In practice: it's complicated; mods are often provided from different sources. Keyboard layout, IME, sticky keys and
    //   backends tend to interfere and break that equivalence. The safer decision is to relay that ambiguity down to the end-user...
    // - On macOS, we swap Cmd(Super) and Ctrl keys at the time of the io.AddKeyEvent() call.
    ImGuiModNone = 0, 
    ImGuiModCtrl = 4096,      // Ctrl (non-macOS), Cmd (macOS) 
    ImGuiModShift = 8192,     // Shift 
    ImGuiModAlt = 16384,      // Option/Menu 
    ImGuiModSuper = 32768);   // Windows/Super (non-macOS), Ctrl (macOS) 

type
  // Flags for Shortcut(), SetNextItemShortcut(),
  // (and for upcoming extended versions of IsKeyPressed(), IsMouseClicked(), Shortcut(), SetKeyOwner(), SetItemKeyOwner() that are still in imgui_internal.h)
  // Don't mistake with ImGuiInputTextFlags! (which is for ImGui::InputText() function)
  TImGuiInputFlag = (
    &Repeat = 0,               // Enable repeat. Return true on successive repeats. Default for legacy IsKeyPressed(). NOT Default for legacy IsMouseClicked(). MUST BE == 1. 
    // Flags for Shortcut(), SetNextItemShortcut()
    // - Routing policies: RouteGlobal+OverActive >> RouteActive or RouteFocused (if owner is active item) >> RouteGlobal+OverFocused >> RouteFocused (if in focused window stack) >> RouteGlobal.
    // - Default policy is RouteFocused. Can select only 1 policy among all available.
    RouteActive = 10,          // Route to active item only. 
    RouteFocused = 11,         // Route to windows in the focus stack (DEFAULT). Deep-most focused window takes inputs. Active item takes inputs over deep-most focused window. 
    RouteGlobal = 12,          // Global route (unless a focused window or active item registered the route). 
    RouteAlways = 13,          // Do not register route, poll keys directly. 
    // - Routing options
    RouteOverFocused = 14,     // Option: global route: higher priority than focused route (unless active item in focused route). 
    RouteOverActive = 15,      // Option: global route: higher priority than active item. Unlikely you need to use that: will interfere with every active items, e.g. Ctrl+A registered by InputText will be overridden by this. May not be fully honored as user/internal code is likely to always assume they can access keys when active. 
    RouteUnlessBgFocused = 16, // Option: global route: will not be applied if underlying background/void is focused (== no Dear ImGui windows are focused). Useful for overlay applications. 
    RouteFromRootWindow = 17,  // Option: route evaluated from the point of view of root window rather than current window. 
    // Flags for SetNextItemShortcut()
    Tooltip = 18,              // Automatically display a tooltip when hovering item [BETA] Unsure of right api (opt-in/opt-out) 
    _ = 31); 
  TImGuiInputFlags = set of TImGuiInputFlag;

  _TImGuiInputFlagsHelper = record helper for TImGuiInputFlags
  public const
    None = []; 
  end;

type
  // Configuration flags stored in io.ConfigFlags. Set by user/application.
  // Note that nowadays most of our configuration options are in other ImGuiIO fields, e.g. io.ConfigWindowsMoveFromTitleBarOnly.
  TImGuiConfigFlag = (
    NavEnableKeyboard = 0,   // Master keyboard navigation enable flag. Enable full Tabbing + directional arrows + Space/Enter to activate. Note: some features such as basic Tabbing and CtrL+Tab are enabled by regardless of this flag (and may be disabled via other means, see #4828, #9218). 
    NavEnableGamepad = 1,    // Master gamepad navigation enable flag. Backend also needs to set ImGuiBackendFlags_HasGamepad. 
    NoMouse = 4,             // Instruct dear imgui to disable mouse inputs and interactions. 
    NoMouseCursorChange = 5, // Instruct backend to not alter mouse cursor shape and visibility. Use if the backend cursor changes are interfering with yours and you don't want to use SetMouseCursor() to change mouse cursor. You may want to honor requests from imgui by reading GetMouseCursor() yourself instead. 
    NoKeyboard = 6,          // Instruct dear imgui to disable keyboard inputs and interactions. This is done by ignoring keyboard events and clearing existing states. 
    // [Unused] User storage (to allow your backend/engine to communicate to code that may be shared between multiple projects. Those flags are NOT used by core Dear ImGui)
    IsSRGB = 20,             // Application is SRGB-aware. 
    IsTouchScreen = 21,      // Application is using a touch screen instead of a mouse. 
    _ = 31); 
  TImGuiConfigFlags = set of TImGuiConfigFlag;

  _TImGuiConfigFlagsHelper = record helper for TImGuiConfigFlags
  public const
    None = []; 
  end;

type
  // Backend capabilities flags stored in io.BackendFlags. Set by imgui_impl_xxx or custom backend.
  TImGuiBackendFlag = (
    HasGamepad = 0,           // Backend Platform supports gamepad and currently has one connected. 
    HasMouseCursors = 1,      // Backend Platform supports honoring GetMouseCursor() value to change the OS cursor shape. 
    HasSetMousePos = 2,       // Backend Platform supports io.WantSetMousePos requests to reposition the OS mouse position (only used if io.ConfigNavMoveSetMousePos is set). 
    RendererHasVtxOffset = 3, // Backend Renderer supports ImDrawCmd::VtxOffset. This enables output of large meshes (64K+ vertices) while still using 16-bit indices. 
    RendererHasTextures = 4,  // Backend Renderer supports ImTextureData requests to create/update/destroy textures. This enables incremental texture updates and texture reloads. See https://github.com/ocornut/imgui/blob/master/docs/BACKENDS.md for instructions on how to upgrade your custom backend. 
    _ = 31); 
  TImGuiBackendFlags = set of TImGuiBackendFlag;

  _TImGuiBackendFlagsHelper = record helper for TImGuiBackendFlags
  public const
    None = []; 
  end;

type
  // Enumeration for PushStyleColor() / PopStyleColor()
  TImGuiCol = (
    Text = 0, 
    TextDisabled = 1, 
    WindowBg = 2,                   // Background of normal windows 
    ChildBg = 3,                    // Background of child windows 
    PopupBg = 4,                    // Background of popups, menus, tooltips windows 
    Border = 5, 
    BorderShadow = 6, 
    FrameBg = 7,                    // Background of checkbox, radio button, plot, slider, text input 
    FrameBgHovered = 8, 
    FrameBgActive = 9, 
    TitleBg = 10,                   // Title bar 
    TitleBgActive = 11,             // Title bar when focused 
    TitleBgCollapsed = 12,          // Title bar when collapsed 
    MenuBarBg = 13, 
    ScrollbarBg = 14, 
    ScrollbarGrab = 15, 
    ScrollbarGrabHovered = 16, 
    ScrollbarGrabActive = 17, 
    CheckMark = 18,                 // Checkbox tick and RadioButton circle 
    CheckboxSelectedBg = 19,        // Checkbox background when Selected, otherwise use FrameBg 
    SliderGrab = 20, 
    SliderGrabActive = 21, 
    Button = 22, 
    ButtonHovered = 23, 
    ButtonActive = 24, 
    Header = 25,                    // Header* colors are used for CollapsingHeader, TreeNode, Selectable, MenuItem 
    HeaderHovered = 26, 
    HeaderActive = 27, 
    Separator = 28, 
    SeparatorHovered = 29, 
    SeparatorActive = 30, 
    ResizeGrip = 31,                // Resize grip in lower-right and lower-left corners of windows. 
    ResizeGripHovered = 32, 
    ResizeGripActive = 33, 
    InputTextCursor = 34,           // InputText cursor/caret 
    TabHovered = 35,                // Tab background, when hovered 
    Tab = 36,                       // Tab background, when tab-bar is focused & tab is unselected 
    TabSelected = 37,               // Tab background, when tab-bar is focused & tab is selected 
    TabSelectedOverline = 38,       // Tab horizontal overline, when tab-bar is focused & tab is selected 
    TabDimmed = 39,                 // Tab background, when tab-bar is unfocused & tab is unselected 
    TabDimmedSelected = 40,         // Tab background, when tab-bar is unfocused & tab is selected 
    TabDimmedSelectedOverline = 41, //..horizontal overline, when tab-bar is unfocused & tab is selected 
    PlotLines = 42, 
    PlotLinesHovered = 43, 
    PlotHistogram = 44, 
    PlotHistogramHovered = 45, 
    TableHeaderBg = 46,             // Table header background 
    TableBorderStrong = 47,         // Table outer and header borders (prefer using Alpha=1.0 here) 
    TableBorderLight = 48,          // Table inner borders (prefer using Alpha=1.0 here) 
    TableRowBg = 49,                // Table row background (even rows) 
    TableRowBgAlt = 50,             // Table row background (odd rows) 
    TextLink = 51,                  // Hyperlink color 
    TextSelectedBg = 52,            // Selected text inside an InputText 
    TreeLines = 53,                 // Tree node hierarchy outlines when using ImGuiTreeNodeFlags_DrawLines 
    DragDropTarget = 54,            // Rectangle border highlighting a drop target 
    DragDropTargetBg = 55,          // Rectangle background highlighting a drop target 
    UnsavedMarker = 56,             // Unsaved Document marker (in window title and tabs) 
    NavCursor = 57,                 // Color of keyboard/gamepad navigation cursor/rectangle, when visible 
    NavWindowingHighlight = 58,     // Highlight window when using Ctrl+Tab 
    NavWindowingDimBg = 59,         // Darken/colorize entire screen behind the Ctrl+Tab window list, when active 
    ModalWindowDimBg = 60);         // Darken/colorize entire screen behind a modal window, when one is active 

type
  // Enumeration for PushStyleVar() / PopStyleVar() to temporarily modify the ImGuiStyle structure.
  // - The enum only refers to fields of ImGuiStyle which makes sense to be pushed/popped inside UI code.
  //   During initialization or between frames, feel free to just poke into ImGuiStyle directly.
  // - Tip: Use your programming IDE navigation facilities on the names in the _second column_ below to find the actual members and their description.
  //   - In Visual Studio: Ctrl+Comma ("Edit.GoToAll") can follow symbols inside comments, whereas Ctrl+F12 ("Edit.GoToImplementation") cannot.
  //   - In Visual Studio w/ Visual Assist installed: Alt+G ("VAssistX.GoToImplementation") can also follow symbols inside comments.
  //   - In VS Code, CLion, etc.: Ctrl+Click can follow symbols inside comments.
  // - When changing this enum, you need to update the associated internal table GStyleVarInfo[] accordingly. This is where we link enum values to members offset/type.
  TImGuiStyleVar = (
    // Enum name -------------------------- // Member in ImGuiStyle structure (see ImGuiStyle for descriptions)
    Alpha = 0,                        // float     Alpha 
    DisabledAlpha = 1,                // float     DisabledAlpha 
    WindowPadding = 2,                // ImVec2    WindowPadding 
    WindowRounding = 3,               // float     WindowRounding 
    WindowBorderSize = 4,             // float     WindowBorderSize 
    WindowMinSize = 5,                // ImVec2    WindowMinSize 
    WindowTitleAlign = 6,             // ImVec2    WindowTitleAlign 
    ChildRounding = 7,                // float     ChildRounding 
    ChildBorderSize = 8,              // float     ChildBorderSize 
    PopupRounding = 9,                // float     PopupRounding 
    PopupBorderSize = 10,             // float     PopupBorderSize 
    FramePadding = 11,                // ImVec2    FramePadding 
    FrameRounding = 12,               // float     FrameRounding 
    FrameBorderSize = 13,             // float     FrameBorderSize 
    ItemSpacing = 14,                 // ImVec2    ItemSpacing 
    ItemInnerSpacing = 15,            // ImVec2    ItemInnerSpacing 
    IndentSpacing = 16,               // float     IndentSpacing 
    CellPadding = 17,                 // ImVec2    CellPadding 
    ScrollbarSize = 18,               // float     ScrollbarSize 
    ScrollbarRounding = 19,           // float     ScrollbarRounding 
    ScrollbarPadding = 20,            // float     ScrollbarPadding 
    GrabMinSize = 21,                 // float     GrabMinSize 
    GrabRounding = 22,                // float     GrabRounding 
    ImageRounding = 23,               // float     ImageRounding 
    ImageBorderSize = 24,             // float     ImageBorderSize 
    TabRounding = 25,                 // float     TabRounding 
    TabBorderSize = 26,               // float     TabBorderSize 
    TabMinWidthBase = 27,             // float     TabMinWidthBase 
    TabMinWidthShrink = 28,           // float     TabMinWidthShrink 
    TabBarBorderSize = 29,            // float     TabBarBorderSize 
    TabBarOverlineSize = 30,          // float     TabBarOverlineSize 
    TableAngledHeadersAngle = 31,     // float     TableAngledHeadersAngle 
    TableAngledHeadersTextAlign = 32, // ImVec2  TableAngledHeadersTextAlign 
    TreeLinesSize = 33,               // float     TreeLinesSize 
    TreeLinesRounding = 34,           // float     TreeLinesRounding 
    DragDropTargetRounding = 35,      // float     DragDropTargetRounding 
    ButtonTextAlign = 36,             // ImVec2    ButtonTextAlign 
    SelectableTextAlign = 37,         // ImVec2    SelectableTextAlign 
    SeparatorSize = 38,               // float     SeparatorSize 
    SeparatorTextBorderSize = 39,     // float     SeparatorTextBorderSize 
    SeparatorTextAlign = 40,          // ImVec2    SeparatorTextAlign 
    SeparatorTextPadding = 41);       // ImVec2    SeparatorTextPadding 

type
  // Flags for InvisibleButton() [extended in imgui_internal.h]
  TImGuiButtonFlag = (
    MouseButtonLeft = 0,   // React on left mouse button (default) 
    MouseButtonRight = 1,  // React on right mouse button 
    MouseButtonMiddle = 2, // React on center mouse button 
    EnableNav = 3,         // InvisibleButton(): do not disable navigation/tabbing. Otherwise disabled by default. 
    AllowOverlap = 12,     // Hit testing will allow subsequent widgets to overlap this one. Require previous frame HoveredId to match before being usable. Shortcut to calling SetNextItemAllowOverlap(). 
    _ = 31); 
  TImGuiButtonFlags = set of TImGuiButtonFlag;

  _TImGuiButtonFlagsHelper = record helper for TImGuiButtonFlags
  public const
    None = []; 
  end;

type
  // Flags for ColorEdit3() / ColorEdit4() / ColorPicker3() / ColorPicker4() / ColorButton()
  TImGuiColorEditFlag = (
    NoAlpha = 1,           //              // ColorEdit, ColorPicker, ColorButton: ignore Alpha component (will only read 3 components from the input pointer). 
    NoPicker = 2,          //              // ColorEdit: disable picker when clicking on color square. 
    NoOptions = 3,         //              // ColorEdit: disable toggling options menu when right-clicking on inputs/small preview. 
    NoSmallPreview = 4,    //              // ColorEdit, ColorPicker: disable color square preview next to the inputs. (e.g. to show only the inputs) 
    NoInputs = 5,          //              // ColorEdit, ColorPicker: disable inputs sliders/text widgets (e.g. to show only the small preview color square). 
    NoTooltip = 6,         //              // ColorEdit, ColorPicker, ColorButton: disable tooltip when hovering the preview. 
    NoLabel = 7,           //              // ColorEdit, ColorPicker: disable display of inline text label (the label is still forwarded to the tooltip and picker). 
    NoSidePreview = 8,     //              // ColorPicker: disable bigger color preview on right side of the picker, use small color square preview instead. 
    NoDragDrop = 9,        //              // ColorEdit: disable drag and drop target/source. ColorButton: disable drag and drop source. 
    NoBorder = 10,         //              // ColorButton: disable border (which is enforced by default) 
    NoColorMarkers = 11,   //              // ColorEdit: disable rendering R/G/B/A color marker. May also be disabled globally by setting style.ColorMarkerSize = 0. 
    // Alpha preview
    // - Prior to 1.91.8 (2025/01/21): alpha was made opaque in the preview by default using old name ImGuiColorEditFlags_AlphaPreview.
    // - We now display the preview as transparent by default. You can use ImGuiColorEditFlags_AlphaOpaque to use old behavior.
    // - The new flags may be combined better and allow finer controls.
    AlphaOpaque = 12,      //              // ColorEdit, ColorPicker, ColorButton: disable alpha in the preview,. Contrary to _NoAlpha it may still be edited when calling ColorEdit4()/ColorPicker4(). For ColorButton() this does the same as _NoAlpha. 
    AlphaNoBg = 13,        //              // ColorEdit, ColorPicker, ColorButton: disable rendering a checkerboard background behind transparent color. 
    AlphaPreviewHalf = 14, //              // ColorEdit, ColorPicker, ColorButton: display half opaque / half transparent preview. 
    // User Options (right-click on widget to change some of them).
    AlphaBar = 18,         //              // ColorEdit, ColorPicker: show vertical alpha bar/gradient in picker. 
    HDR = 19,              //              // (WIP) ColorEdit: Currently only disable 0.0f..1.0f limits in RGBA edition (note: you probably want to use ImGuiColorEditFlags_Float flag as well). 
    DisplayRGB = 20,       // [Display]    // ColorEdit: override _display_ type among RGB/HSV/Hex. ColorPicker: select any combination using one or more of RGB/HSV/Hex. 
    DisplayHSV = 21,       // [Display]    // " 
    DisplayHex = 22,       // [Display]    // " 
    Uint8 = 23,            // [DataType]   // ColorEdit, ColorPicker, ColorButton: _display_ values formatted as 0..255. 
    Float = 24,            // [DataType]   // ColorEdit, ColorPicker, ColorButton: _display_ values formatted as 0.0f..1.0f floats instead of 0..255 integers. No round-trip of value via integers. 
    PickerHueBar = 25,     // [Picker]     // ColorPicker: bar for Hue, rectangle for Sat/Value. 
    PickerHueWheel = 26,   // [Picker]     // ColorPicker: wheel for Hue, triangle for Sat/Value. 
    InputRGB = 27,         // [Input]      // ColorEdit, ColorPicker: input and output data in RGB format. 
    InputHSV = 28);        // [Input]      // ColorEdit, ColorPicker: input and output data in HSV format. 
  TImGuiColorEditFlags = set of TImGuiColorEditFlag;

  _TImGuiColorEditFlagsHelper = record helper for TImGuiColorEditFlags
  public const
    None = []; 
  end;

type
  // Flags for DragFloat(), DragInt(), SliderFloat(), SliderInt() etc.
  // We use the same sets of flags for DragXXX() and SliderXXX() functions as the features are the same and it makes it easier to swap them.
  // (Those are per-item flags. There is shared behavior flag too: ImGuiIO: io.ConfigDragClickToInputText)
  TImGuiSliderFlag = (
    Logarithmic = 5,     // Make the widget logarithmic (linear otherwise). Consider using ImGuiSliderFlags_NoRoundToFormat with this if using a format-string with small amount of digits. 
    NoRoundToFormat = 6, // Disable rounding underlying value to match precision of the display format string (e.g. %.3f values are rounded to those 3 digits). 
    NoInput = 7,         // Disable Ctrl+Click or Enter key allowing to input text directly into the widget. 
    WrapAround = 8,      // Enable wrapping around from max to min and from min to max. Only supported by DragXXX() functions for now. 
    ClampOnInput = 9,    // Clamp value to min/max bounds when input manually with Ctrl+Click. By default Ctrl+Click allows going out of bounds. 
    ClampZeroRange = 10, // Clamp even if min==max==0.0f. Otherwise due to legacy reason DragXXX functions don't clamp with those values. When your clamping limits are dynamic you almost always want to use it. 
    NoSpeedTweaks = 11,  // Disable keyboard modifiers altering tweak speed. Useful if you want to alter tweak speed yourself based on your own logic. 
    ColorMarkers = 12,   // DragScalarN(), SliderScalarN(): Draw R/G/B/A color markers on each component. 
    _ = 31); 
  TImGuiSliderFlags = set of TImGuiSliderFlag;

  _TImGuiSliderFlagsHelper = record helper for TImGuiSliderFlags
  public const
    None = []; 
    AlwaysClamp = [TImGuiSliderFlag.ClampOnInput, TImGuiSliderFlag.ClampZeroRange]; 
  end;

type
  // Identify a mouse button.
  // Those values are guaranteed to be stable and we frequently use 0/1 directly. Named enums provided for convenience.
  TImGuiMouseButton = (
    Left = 0, 
    Right = 1, 
    Middle = 2); 

type
  // Enumeration for GetMouseCursor()
  // User code may request backend to display given cursor by calling SetMouseCursor(), which is why we have some cursors that are marked unused here
  TImGuiMouseCursor = (
    None = -1, 
    Arrow = 0, 
    TextInput = 1,    // When hovering over InputText, etc. 
    ResizeAll = 2,    // (Unused by Dear ImGui functions) 
    ResizeNS = 3,     // When hovering over a horizontal border 
    ResizeEW = 4,     // When hovering over a vertical border or a column 
    ResizeNESW = 5,   // When hovering over the bottom-left corner of a window 
    ResizeNWSE = 6,   // When hovering over the bottom-right corner of a window 
    Hand = 7,         // (Unused by Dear ImGui functions. Use for e.g. hyperlinks) 
    Wait = 8,         // When waiting for something to process/load. 
    Progress = 9,     // When waiting for something to process/load, but application is still interactive. 
    NotAllowed = 10); // When hovering something with disallowed interaction. Usually a crossed circle. 

type
  // Enumeration for AddMouseSourceEvent() actual source of Mouse Input data.
  // Historically we use "Mouse" terminology everywhere to indicate pointer data, e.g. MousePos, IsMousePressed(), io.AddMousePosEvent()
  // But that "Mouse" data can come from different source which occasionally may be useful for application to know about.
  // You can submit a change of pointer type using io.AddMouseSourceEvent().
  TImGuiMouseSource = (
    Mouse = 0,       // Input is coming from an actual mouse. 
    TouchScreen = 1, // Input is coming from a touch screen (no hovering prior to initial press, less precise initial press aiming, dual-axis wheeling possible). 
    Pen = 2);        // Input is coming from a pressure/magnetic pen (often used in conjunction with high-sampling rates). 

type
  // Enumeration for ImGui::SetNextWindow***(), SetWindow***(), SetNextItem***() functions
  // Represent a condition.
  // Important: Treat as a regular enum! Do NOT combine multiple values using binary operators! All the functions above treat 0 as a shortcut to ImGuiCond_Always.
  TImGuiCond = (
    None = 0,         // No condition (always set the variable), same as _Always 
    Always = 1,       // No condition (always set the variable), same as _None 
    Once = 2,         // Set the variable once per runtime session (only the first call will succeed) 
    FirstUseEver = 4, // Set the variable if the object/window has no persistently saved data (no entry in .ini file) 
    Appearing = 8);   // Set the variable if the object/window is appearing after being hidden/inactive (or the first time) 

type
  // Flags for ImGui::BeginTable()
  // - Important! Sizing policies have complex and subtle side effects, much more so than you would expect.
  //   Read comments/demos carefully + experiment with live demos to get acquainted with them.
  // - The DEFAULT sizing policies are:
  //    - Default to ImGuiTableFlags_SizingFixedFit    if ScrollX is on, or if host window has ImGuiWindowFlags_AlwaysAutoResize.
  //    - Default to ImGuiTableFlags_SizingStretchSame if ScrollX is off.
  // - When ScrollX is off:
  //    - Table defaults to ImGuiTableFlags_SizingStretchSame -> all Columns defaults to ImGuiTableColumnFlags_WidthStretch with same weight.
  //    - Columns sizing policy allowed: Stretch (default), Fixed/Auto.
  //    - Fixed Columns (if any) will generally obtain their requested width (unless the table cannot fit them all).
  //    - Stretch Columns will share the remaining width according to their respective weight.
  //    - Mixed Fixed/Stretch columns is possible but has various side-effects on resizing behaviors.
  //      The typical use of mixing sizing policies is: any number of LEADING Fixed columns, followed by one or two TRAILING Stretch columns.
  //      (this is because the visible order of columns have subtle but necessary effects on how they react to manual resizing).
  // - When ScrollX is on:
  //    - Table defaults to ImGuiTableFlags_SizingFixedFit -> all Columns defaults to ImGuiTableColumnFlags_WidthFixed
  //    - Columns sizing policy allowed: Fixed/Auto mostly.
  //    - Fixed Columns can be enlarged as needed. Table will show a horizontal scrollbar if needed.
  //    - When using auto-resizing (non-resizable) fixed columns, querying the content width to use item right-alignment e.g. SetNextItemWidth(-FLT_MIN) doesn't make sense, would create a feedback loop.
  //    - Using Stretch columns OFTEN DOES NOT MAKE SENSE if ScrollX is on, UNLESS you have specified a value for 'inner_width' in BeginTable().
  //      If you specify a value for 'inner_width' then effectively the scrolling space is known and Stretch or mixed Fixed/Stretch columns become meaningful again.
  // - Read on documentation at the top of imgui_tables.cpp for details.
  TImGuiTableFlag = (
    Resizable = 0,                   // Enable resizing columns. 
    Reorderable = 1,                 // Enable reordering columns in header row. (Need calling TableSetupColumn() + TableHeadersRow() to display headers, or using ImGuiTableFlags_ContextMenuInBody to access context-menu without headers). 
    Hideable = 2,                    // Enable hiding/disabling columns in context menu. 
    Sortable = 3,                    // Enable sorting. Call TableGetSortSpecs() to obtain sort specs. Also see ImGuiTableFlags_SortMulti and ImGuiTableFlags_SortTristate. 
    NoSavedSettings = 4,             // Disable persisting columns order, width, visibility and sort settings in the .ini file. 
    ContextMenuInBody = 5,           // Right-click on columns body/contents will also display table context menu. By default it is available in TableHeadersRow(). 
    // Decorations
    RowBg = 6,                       // Set each RowBg color with ImGuiCol_TableRowBg or ImGuiCol_TableRowBgAlt (equivalent of calling TableSetBgColor with ImGuiTableBgFlags_RowBg0 on each row manually) 
    BordersInnerH = 7,               // Draw horizontal borders between rows. 
    BordersOuterH = 8,               // Draw horizontal borders at the top and bottom. 
    BordersInnerV = 9,               // Draw vertical borders between columns. 
    BordersOuterV = 10,              // Draw vertical borders on the left and right sides. 
    NoBordersInBody = 11,            // [ALPHA] Disable vertical borders in columns Body (borders will always appear in Headers). -> May move to style 
    NoBordersInBodyUntilResize = 12, // [ALPHA] Disable vertical borders in columns Body until hovered for resize (borders will always appear in Headers). -> May move to style 
    // Sizing Policy (read above for defaults)
    SizingFixedFit = 13,             // Columns default to _WidthFixed or _WidthAuto (if resizable or not resizable), matching contents width. 
    SizingFixedSame = 14,            // Columns default to _WidthFixed or _WidthAuto (if resizable or not resizable), matching the maximum contents width of all columns. Implicitly enable ImGuiTableFlags_NoKeepColumnsVisible. 
    SizingStretchSame = 15,          // Columns default to _WidthStretch with default weights all equal, unless overridden by TableSetupColumn(). 
    // Sizing Extra Options
    NoHostExtendX = 16,              // Make outer width auto-fit to columns, overriding outer_size.x value. Only available when ScrollX/ScrollY are disabled and Stretch columns are not used. 
    NoHostExtendY = 17,              // Make outer height stop exactly at outer_size.y (prevent auto-extending table past the limit). Only available when ScrollX/ScrollY are disabled. Data below the limit will be clipped and not visible. 
    NoKeepColumnsVisible = 18,       // Disable keeping column always minimally visible when ScrollX is off and table gets too small. Not recommended if columns are resizable. 
    PreciseWidths = 19,              // Disable distributing remainder width to stretched columns (width allocation on a 100-wide table with 3 columns: Without this flag: 33,33,34. With this flag: 33,33,33). With larger number of columns, resizing will appear to be less smooth. 
    // Clipping
    NoClip = 20,                     // Disable clipping rectangle for every individual columns (reduce draw command count, items will be able to overflow into other columns). Generally incompatible with TableSetupScrollFreeze(). 
    // Padding
    PadOuterX = 21,                  // Default if BordersOuterV is on. Enable outermost padding. Generally desirable if you have headers. 
    NoPadOuterX = 22,                // Default if BordersOuterV is off. Disable outermost padding. 
    NoPadInnerX = 23,                // Disable inner padding between columns (double inner padding if BordersOuterV is on, single inner padding if BordersOuterV is off). 
    // Scrolling
    ScrollX = 24,                    // Enable horizontal scrolling. Require 'outer_size' parameter of BeginTable() to specify the container size. Changes default sizing policy. Because this creates a child window, ScrollY is currently generally recommended when using ScrollX. 
    ScrollY = 25,                    // Enable vertical scrolling. Require 'outer_size' parameter of BeginTable() to specify the container size. 
    // Sorting
    SortMulti = 26,                  // Hold shift when clicking headers to sort on multiple column. TableGetSortSpecs() may return specs where (SpecsCount > 1). 
    SortTristate = 27,               // Allow no sorting, disable default sorting. TableGetSortSpecs() may return specs where (SpecsCount == 0). 
    // Miscellaneous
    HighlightHoveredColumn = 28);    // Highlight column headers when hovered (may evolve into a fuller highlight) 
  TImGuiTableFlags = set of TImGuiTableFlag;

  _TImGuiTableFlagsHelper = record helper for TImGuiTableFlags
  public const
    None = []; 
    BordersH = [TImGuiTableFlag.BordersInnerH, TImGuiTableFlag.BordersOuterH]; // Draw horizontal borders.
    BordersV = [TImGuiTableFlag.BordersInnerV, TImGuiTableFlag.BordersOuterV]; // Draw vertical borders.
    BordersInner = [TImGuiTableFlag.BordersInnerH, TImGuiTableFlag.BordersInnerV]; // Draw inner borders.
    BordersOuter = [TImGuiTableFlag.BordersOuterH, TImGuiTableFlag.BordersOuterV]; // Draw outer borders.
    Borders = [TImGuiTableFlag.BordersInnerH, TImGuiTableFlag.BordersOuterH, TImGuiTableFlag.BordersInnerV, TImGuiTableFlag.BordersOuterV]; // Draw all borders.
    SizingStretchProp = [TImGuiTableFlag.SizingFixedFit, TImGuiTableFlag.SizingFixedSame]; // Columns default to _WidthStretch with default weights proportional to each columns contents widths.
  end;

type
  // Flags for ImGui::TableSetupColumn()
  TImGuiTableColumnFlag = (
    Disabled = 0,              // Overriding/master disable flag: hide column, won't show in context menu (unlike calling TableSetColumnEnabled() which manipulates the user accessible state) 
    DefaultHide = 1,           // Default as a hidden/disabled column. 
    DefaultSort = 2,           // Default as a sorting column. 
    WidthStretch = 3,          // Column will stretch. Preferable with horizontal scrolling disabled (default if table sizing policy is _SizingStretchSame or _SizingStretchProp). 
    WidthFixed = 4,            // Column will not stretch. Preferable with horizontal scrolling enabled (default if table sizing policy is _SizingFixedFit and table is resizable). 
    NoResize = 5,              // Disable manual resizing. 
    NoReorder = 6,             // Disable manual reordering this column, this will also prevent other columns from crossing over this column. 
    NoHide = 7,                // Disable ability to hide/disable this column. 
    NoClip = 8,                // Disable clipping for this column (all NoClip columns will render in a same draw command). 
    NoSort = 9,                // Disable ability to sort on this field (even if ImGuiTableFlags_Sortable is set on the table). 
    NoSortAscending = 10,      // Disable ability to sort in the ascending direction. 
    NoSortDescending = 11,     // Disable ability to sort in the descending direction. 
    NoHeaderLabel = 12,        // TableHeadersRow() will submit an empty label for this column. Convenient for some small columns. Name will still appear in context menu or in angled headers. You may append into this cell by calling TableSetColumnIndex() right after the TableHeadersRow() call. 
    NoHeaderWidth = 13,        // Disable header text width contribution to automatic column width. 
    PreferSortAscending = 14,  // Make the initial sort direction Ascending when first sorting on this column (default). 
    PreferSortDescending = 15, // Make the initial sort direction Descending when first sorting on this column. 
    IndentEnable = 16,         // Use current Indent value when entering cell (default for column 0). 
    IndentDisable = 17,        // Ignore current Indent value when entering cell (default for columns > 0). Indentation changes _within_ the cell will still be honored. 
    AngledHeader = 18,         // TableHeadersRow() will submit an angled header row for this column. Note this will add an extra row. 
    // Output status flags, read-only via TableGetColumnFlags()
    IsEnabled = 24,            // Status: is enabled == not hidden by user/api (referred to as "Hide" in _DefaultHide and _NoHide) flags. 
    IsVisible = 25,            // Status: is visible == is enabled AND not clipped by scrolling. 
    IsSorted = 26,             // Status: is currently part of the sort specs 
    IsHovered = 27);           // Status: is hovered by mouse 
  TImGuiTableColumnFlags = set of TImGuiTableColumnFlag;

  _TImGuiTableColumnFlagsHelper = record helper for TImGuiTableColumnFlags
  public const
    None = []; 
  end;

type
  // Flags for ImGui::TableNextRow()
  TImGuiTableRowFlag = (
    Headers = 0, // Identify header row (set default background color + width of its contents accounted differently for auto column width) 
    _ = 31); 
  TImGuiTableRowFlags = set of TImGuiTableRowFlag;

  _TImGuiTableRowFlagsHelper = record helper for TImGuiTableRowFlags
  public const
    None = []; 
  end;

type
  // Enum for ImGui::TableSetBgColor()
  // Background colors are rendering in 3 layers:
  //  - Layer 0: draw with RowBg0 color if set, otherwise draw with ColumnBg0 if set.
  //  - Layer 1: draw with RowBg1 color if set, otherwise draw with ColumnBg1 if set.
  //  - Layer 2: draw with CellBg color if set.
  // The purpose of the two row/columns layers is to let you decide if a background color change should override or blend with the existing color.
  // When using ImGuiTableFlags_RowBg on the table, each row has the RowBg0 color automatically set for odd/even rows.
  // If you set the color of RowBg0 target, your color will override the existing RowBg0 color.
  // If you set the color of RowBg1 or ColumnBg1 target, your color will blend over the RowBg0 color.
  TImGuiTableBgTarget = (
    None = 0, 
    RowBg0 = 1,  // Set row background color 0 (generally used for background, automatically set when ImGuiTableFlags_RowBg is used) 
    RowBg1 = 2,  // Set row background color 1 (generally used for selection marking) 
    CellBg = 3); // Set cell background color (top-most color) 

type
  // Flags for ImGuiListClipper (currently not fully exposed in function calls: a future refactor will likely add this to ImGuiListClipper::Begin function equivalent)
  TImGuiListClipperFlag = (
    NoSetTableRowCounters = 0, // [Internal] Disabled modifying table row counters. Avoid assumption that 1 clipper item == 1 table row. 
    _ = 31); 
  TImGuiListClipperFlags = set of TImGuiListClipperFlag;

  _TImGuiListClipperFlagsHelper = record helper for TImGuiListClipperFlags
  public const
    None = []; 
  end;

type
  // Flags for BeginMultiSelect()
  TImGuiMultiSelectFlag = (
    SingleSelect = 0,          // Disable selecting more than one item. This is available to allow single-selection code to share same code/logic if desired. It essentially disables the main purpose of BeginMultiSelect() tho! 
    NoSelectAll = 1,           // Disable Ctrl+A shortcut to select all. 
    NoRangeSelect = 2,         // Disable Shift+selection mouse/keyboard support (useful for unordered 2D selection). With BoxSelect is also ensure contiguous SetRange requests are not combined into one. This allows not handling interpolation in SetRange requests. 
    NoAutoSelect = 3,          // Disable selecting items when navigating (useful for e.g. supporting range-select in a list of checkboxes). 
    NoAutoClear = 4,           // Disable clearing selection when navigating or selecting another one (generally used with ImGuiMultiSelectFlags_NoAutoSelect. useful for e.g. supporting range-select in a list of checkboxes). 
    NoAutoClearOnReselect = 5, // Disable clearing selection when clicking/selecting an already selected item. 
    BoxSelect1d = 6,           // Enable box-selection with same width and same x pos items (e.g. full row Selectable()). Box-selection works better with little bit of spacing between items hit-box in order to be able to aim at empty space. 
    BoxSelect2d = 7,           // Enable box-selection with varying width or varying x pos items support (e.g. different width labels, or 2D layout/grid). This is slower: alters clipping logic so that e.g. horizontal movements will update selection of normally clipped items. 
    BoxSelectNoScroll = 8,     // Disable scrolling when box-selecting and moving mouse near edges of scope. 
    ClearOnEscape = 9,         // Clear selection when pressing Escape while scope is focused. 
    ClearOnClickVoid = 10,     // Clear selection when clicking on empty location within scope. 
    ScopeWindow = 11,          // Scope for _BoxSelect and _ClearOnClickVoid is whole window (Default). Use if BeginMultiSelect() covers a whole window or used a single time in same window. 
    ScopeRect = 12,            // Scope for _BoxSelect and _ClearOnClickVoid is rectangle encompassing BeginMultiSelect()/EndMultiSelect(). Use if BeginMultiSelect() is called multiple times in same window. 
    SelectOnAuto = 13,         // Apply selection on mouse down when clicking on unselected item, on mouse up when clicking on selected item. (Default) 
    SelectOnClickAlways = 14,  // Apply selection on mouse down when clicking on any items. Prevents Drag and Drop from being used on multiple-selection, but allows e.g. BoxSelect to always reselect even when clicking inside an existing selection. (Excel style behavior) 
    SelectOnClickRelease = 15, // Apply selection on mouse release when clicking an unselected item. Allow dragging an unselected item without altering selection. 
    //ImGuiMultiSelectFlags_RangeSelect2d       = 1 << 15,  // Shift+Selection uses 2d geometry instead of linear sequence, so possible to use Shift+up/down to select vertically in grid. Analogous to what BoxSelect does.
    NavWrapX = 16,             // [Temporary] Enable navigation wrapping on X axis. Provided as a convenience because we don't have a design for the general Nav API for this yet. When the more general feature be public we may obsolete this flag in favor of new one. 
    NoSelectOnRightClick = 17, // Disable default right-click processing, which selects item on mouse down, and is designed for context-menus. 
    _ = 31); 
  TImGuiMultiSelectFlags = set of TImGuiMultiSelectFlag;

  _TImGuiMultiSelectFlagsHelper = record helper for TImGuiMultiSelectFlags
  public const
    None = []; 
  end;

type
  // Selection request type
  TImGuiSelectionRequestType = (
    None = 0, 
    SetAll = 1,    // Request app to clear selection (if Selected==false) or select all items (if Selected==true). We cannot set RangeFirstItem/RangeLastItem as its contents is entirely up to user (not necessarily an index) 
    SetRange = 2); // Request app to select/unselect [RangeFirstItem..RangeLastItem] items (inclusive) based on value of Selected. Only EndMultiSelect() request this, app code can read after BeginMultiSelect() and it will always be false. 

type
  // Flags for ImDrawList functions
  TImDrawFlag = (
    RoundCornersTopLeft = 4,     // AddRect(), AddRectFilled(), PathRect(): enable rounding top-left corner only (when rounding > 0.0f, we default to all corners). Was 0x01. 
    RoundCornersTopRight = 5,    // AddRect(), AddRectFilled(), PathRect(): enable rounding top-right corner only (when rounding > 0.0f, we default to all corners). Was 0x02. 
    RoundCornersBottomLeft = 6,  // AddRect(), AddRectFilled(), PathRect(): enable rounding bottom-left corner only (when rounding > 0.0f, we default to all corners). Was 0x04. 
    RoundCornersBottomRight = 7, // AddRect(), AddRectFilled(), PathRect(): enable rounding bottom-right corner only (when rounding > 0.0f, we default to all corners). Wax 0x08. 
    RoundCornersNone = 8,        // AddRect(), AddRectFilled(), PathRect(): disable rounding on all corners (when rounding > 0.0f). This is NOT zero, NOT an implicit flag! 
    Closed = 9,                  // PathStroke(), AddPolyline(): specify that shape should be closed (Important: this is always == 1 for legacy reason) 
    _ = 31); 
  TImDrawFlags = set of TImDrawFlag;

  _TImDrawFlagsHelper = record helper for TImDrawFlags
  public const
    None = []; 
    RoundCornersTop = [TImDrawFlag.RoundCornersTopLeft, TImDrawFlag.RoundCornersTopRight]; 
    RoundCornersBottom = [TImDrawFlag.RoundCornersBottomLeft, TImDrawFlag.RoundCornersBottomRight]; 
    RoundCornersLeft = [TImDrawFlag.RoundCornersTopLeft, TImDrawFlag.RoundCornersBottomLeft]; 
    RoundCornersRight = [TImDrawFlag.RoundCornersTopRight, TImDrawFlag.RoundCornersBottomRight]; 
    RoundCornersAll = [TImDrawFlag.RoundCornersTopLeft, TImDrawFlag.RoundCornersTopRight, TImDrawFlag.RoundCornersBottomLeft, TImDrawFlag.RoundCornersBottomRight]; 
  end;

type
  // Flags for ImDrawList instance. Those are set automatically by ImGui:: functions from ImGuiIO settings, and generally not manipulated directly.
  // It is however possible to temporarily alter flags between calls to ImDrawList:: functions.
  TImDrawListFlag = (
    AntiAliasedLines = 0,       // Enable anti-aliased lines/borders (*2 the number of triangles for 1.0f wide line or lines thin enough to be drawn using textures, otherwise *3 the number of triangles) 
    AntiAliasedLinesUseTex = 1, // Enable anti-aliased lines/borders using textures when possible. Require backend to render with bilinear filtering (NOT point/nearest filtering). 
    AntiAliasedFill = 2,        // Enable anti-aliased edge around filled shapes (rounded rectangles, circles). 
    AllowVtxOffset = 3,         // Can emit 'VtxOffset > 0' to allow large meshes. Set when 'ImGuiBackendFlags_RendererHasVtxOffset' is enabled. 
    _ = 31); 
  TImDrawListFlags = set of TImDrawListFlag;

  _TImDrawListFlagsHelper = record helper for TImDrawListFlags
  public const
    None = []; 
  end;

type
  // Most standard backends only support RGBA32 but we provide a single channel option for low-resource/embedded systems.
  TImTextureFormat = (
    RGBA32 = 0,  // 4 components per pixel, each is unsigned 8-bit. Total size = TexWidth * TexHeight * 4 
    Alpha8 = 1); // 1 component per pixel, each is unsigned 8-bit. Total size = TexWidth * TexHeight 

type
  // Status of a texture to communicate with Renderer Backend.
  TImTextureStatus = (
    OK = 0, 
    Destroyed = 1,    // Backend destroyed the texture. 
    WantCreate = 2,   // Requesting backend to create the texture. Set status OK when done. 
    WantUpdates = 3,  // Requesting backend to update specific blocks of pixels (write to texture portions which have never been used before). Set status OK when done. 
    WantDestroy = 4); // Requesting backend to destroy the texture. Set status to Destroyed when done. 

type
  // Flags for ImFontAtlas build
  TImFontAtlasFlag = (
    NoPowerOfTwoHeight = 0, // Don't round the height to next power of two 
    NoMouseCursors = 1,     // Don't build software mouse cursors into the atlas (save a little texture memory) 
    NoBakedLines = 2,       // Don't build thick line textures into the atlas (save a little texture memory, allow support for point/nearest filtering). The AntiAliasedLinesUseTex features uses them, otherwise they will be rendered using polygons (more expensive for CPU/GPU). 
    _ = 31); 
  TImFontAtlasFlags = set of TImFontAtlasFlag;

  _TImFontAtlasFlagsHelper = record helper for TImFontAtlasFlags
  public const
    None = []; 
  end;

type
  // Font flags
  // (in future versions as we redesign font loading API, this will become more important and better documented. for now please consider this as internal/advanced use)
  TImFontFlag = (
    NoLoadError = 1,     // Disable throwing an error/assert when calling AddFontXXX() with missing file/data. Calling code is expected to check AddFontXXX() return value. 
    NoLoadGlyphs = 2,    // [Internal] Disable loading new glyphs. 
    LockBakedSizes = 3,  // [Internal] Disable loading new baked sizes, disable garbage collecting current ones. e.g. if you want to lock a font to a single size. Important: if you use this to preload given sizes, consider the possibility of multiple font density used on Retina display. 
    ImplicitRefSize = 4, // [Internal] Reference size was not set explicitly. 
    _ = 31); 
  TImFontFlags = set of TImFontFlag;

  _TImFontFlagsHelper = record helper for TImFontFlags
  public const
    None = []; 
  end;

type
  // Flags stored in ImGuiViewport::Flags, giving indications to the platform backends.
  TImGuiViewportFlag = (
    IsPlatformWindow = 0,  // Represent a Platform Window 
    IsPlatformMonitor = 1, // Represent a Platform Monitor (unused yet) 
    OwnedByApp = 2,        // Platform Window: Is created/managed by the application (rather than a dear imgui backend) 
    _ = 31); 
  TImGuiViewportFlags = set of TImGuiViewportFlag;

  _TImGuiViewportFlagsHelper = record helper for TImGuiViewportFlags
  public const
    None = []; 
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
  _PImGuiInputTextCallbackData = ^_ImGuiInputTextCallbackData;

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
  TImDrawListSharedDataPtr = ^TImDrawListSharedData;
  PImDrawListSharedData = ^TImDrawListSharedData;
  PPImDrawListSharedData = ^PImDrawListSharedData;
  TImFontAtlasBuilderPtr = ^TImFontAtlasBuilder;
  PImFontAtlasBuilder = ^TImFontAtlasBuilder;
  PPImFontAtlasBuilder = ^PImFontAtlasBuilder;
  TImFontLoaderPtr = ^TImFontLoader;
  PImFontLoader = ^TImFontLoader;
  PPImFontLoader = ^PImFontLoader;
  TImGuiContextPtr = ^TImGuiContext;
  PImGuiContext = ^TImGuiContext;
  PPImGuiContext = ^PImGuiContext;
  TImTextureRefPtr = ^TImTextureRef;
  PImTextureRef = ^TImTextureRef;
  PPImTextureRef = ^PImTextureRef;
  TImGuiTableSortSpecsPtr = ^TImGuiTableSortSpecs;
  PImGuiTableSortSpecs = ^TImGuiTableSortSpecs;
  PPImGuiTableSortSpecs = ^PImGuiTableSortSpecs;
  TImGuiTableColumnSortSpecsPtr = ^TImGuiTableColumnSortSpecs;
  PImGuiTableColumnSortSpecs = ^TImGuiTableColumnSortSpecs;
  PPImGuiTableColumnSortSpecs = ^PImGuiTableColumnSortSpecs;
  TImGuiStylePtr = ^TImGuiStyle;
  PImGuiStyle = ^TImGuiStyle;
  PPImGuiStyle = ^PImGuiStyle;
  TImGuiKeyDataPtr = ^TImGuiKeyData;
  PImGuiKeyData = ^TImGuiKeyData;
  PPImGuiKeyData = ^PImGuiKeyData;
  TImGuiIOPtr = ^TImGuiIO;
  PImGuiIO = ^TImGuiIO;
  PPImGuiIO = ^PImGuiIO;
  TImGuiInputTextCallbackDataPtr = ^TImGuiInputTextCallbackData;
  PImGuiInputTextCallbackData = ^TImGuiInputTextCallbackData;
  PPImGuiInputTextCallbackData = ^PImGuiInputTextCallbackData;
  TImGuiSizeCallbackDataPtr = ^TImGuiSizeCallbackData;
  PImGuiSizeCallbackData = ^TImGuiSizeCallbackData;
  PPImGuiSizeCallbackData = ^PImGuiSizeCallbackData;
  TImGuiPayloadPtr = ^TImGuiPayload;
  PImGuiPayload = ^TImGuiPayload;
  PPImGuiPayload = ^PImGuiPayload;
  TImGuiTextRangePtr = ^TImGuiTextRange;
  PImGuiTextRange = ^TImGuiTextRange;
  PPImGuiTextRange = ^PImGuiTextRange;
  TImGuiTextFilterPtr = ^TImGuiTextFilter;
  PImGuiTextFilter = ^TImGuiTextFilter;
  PPImGuiTextFilter = ^PImGuiTextFilter;
  TImGuiTextBufferPtr = ^TImGuiTextBuffer;
  PImGuiTextBuffer = ^TImGuiTextBuffer;
  PPImGuiTextBuffer = ^PImGuiTextBuffer;
  TImGuiStoragePairPtr = ^TImGuiStoragePair;
  PImGuiStoragePair = ^TImGuiStoragePair;
  PPImGuiStoragePair = ^PImGuiStoragePair;
  TImGuiStoragePtr = ^TImGuiStorage;
  PImGuiStorage = ^TImGuiStorage;
  PPImGuiStorage = ^PImGuiStorage;
  TImGuiListClipperPtr = ^TImGuiListClipper;
  PImGuiListClipper = ^TImGuiListClipper;
  PPImGuiListClipper = ^PImGuiListClipper;
  TImGuiSelectionRequestPtr = ^TImGuiSelectionRequest;
  PImGuiSelectionRequest = ^TImGuiSelectionRequest;
  PPImGuiSelectionRequest = ^PImGuiSelectionRequest;
  TImGuiMultiSelectIOPtr = ^TImGuiMultiSelectIO;
  PImGuiMultiSelectIO = ^TImGuiMultiSelectIO;
  PPImGuiMultiSelectIO = ^PImGuiMultiSelectIO;
  TImGuiSelectionBasicStoragePtr = ^TImGuiSelectionBasicStorage;
  PImGuiSelectionBasicStorage = ^TImGuiSelectionBasicStorage;
  PPImGuiSelectionBasicStorage = ^PImGuiSelectionBasicStorage;
  TImGuiSelectionExternalStoragePtr = ^TImGuiSelectionExternalStorage;
  PImGuiSelectionExternalStorage = ^TImGuiSelectionExternalStorage;
  PPImGuiSelectionExternalStorage = ^PImGuiSelectionExternalStorage;
  TImDrawCmdPtr = ^TImDrawCmd;
  PImDrawCmd = ^TImDrawCmd;
  PPImDrawCmd = ^PImDrawCmd;
  TImDrawVertPtr = ^TImDrawVert;
  PImDrawVert = ^TImDrawVert;
  PPImDrawVert = ^PImDrawVert;
  TImDrawCmdHeaderPtr = ^TImDrawCmdHeader;
  PImDrawCmdHeader = ^TImDrawCmdHeader;
  PPImDrawCmdHeader = ^PImDrawCmdHeader;
  TImDrawChannelPtr = ^TImDrawChannel;
  PImDrawChannel = ^TImDrawChannel;
  PPImDrawChannel = ^PImDrawChannel;
  TImDrawListSplitterPtr = ^TImDrawListSplitter;
  PImDrawListSplitter = ^TImDrawListSplitter;
  PPImDrawListSplitter = ^PImDrawListSplitter;
  TImDrawListPtr = ^TImDrawList;
  PImDrawList = ^TImDrawList;
  PPImDrawList = ^PImDrawList;
  TImDrawDataPtr = ^TImDrawData;
  PImDrawData = ^TImDrawData;
  PPImDrawData = ^PImDrawData;
  TImTextureRectPtr = ^TImTextureRect;
  PImTextureRect = ^TImTextureRect;
  PPImTextureRect = ^PImTextureRect;
  TImTextureDataPtr = ^TImTextureData;
  PImTextureData = ^TImTextureData;
  PPImTextureData = ^PImTextureData;
  TImFontConfigPtr = ^TImFontConfig;
  PImFontConfig = ^TImFontConfig;
  PPImFontConfig = ^PImFontConfig;
  TImFontGlyphPtr = ^TImFontGlyph;
  PImFontGlyph = ^TImFontGlyph;
  PPImFontGlyph = ^PImFontGlyph;
  TImFontGlyphRangesBuilderPtr = ^TImFontGlyphRangesBuilder;
  PImFontGlyphRangesBuilder = ^TImFontGlyphRangesBuilder;
  PPImFontGlyphRangesBuilder = ^PImFontGlyphRangesBuilder;
  TImFontAtlasRectPtr = ^TImFontAtlasRect;
  PImFontAtlasRect = ^TImFontAtlasRect;
  PPImFontAtlasRect = ^PImFontAtlasRect;
  TImFontAtlasPtr = ^TImFontAtlas;
  PImFontAtlas = ^TImFontAtlas;
  PPImFontAtlas = ^PImFontAtlas;
  TImFontBakedPtr = ^TImFontBaked;
  PImFontBaked = ^TImFontBaked;
  PPImFontBaked = ^PImFontBaked;
  TImFontPtr = ^TImFont;
  PImFont = ^TImFont;
  PPImFont = ^PImFont;
  TImGuiViewportPtr = ^TImGuiViewport;
  PImGuiViewport = ^TImGuiViewport;
  PPImGuiViewport = ^PImGuiViewport;
  TImGuiPlatformIOPtr = ^TImGuiPlatformIO;
  PImGuiPlatformIO = ^TImGuiPlatformIO;
  PPImGuiPlatformIO = ^PImGuiPlatformIO;
  TImGuiPlatformImeDataPtr = ^TImGuiPlatformImeData;
  PImGuiPlatformImeData = ^TImGuiPlatformImeData;
  PPImGuiPlatformImeData = ^PImGuiPlatformImeData;

  TImVectorImTextureDataPtr = TImVector<TImTextureDataPtr>;
  PImVectorImTextureDataPtr = ^TImVectorImTextureDataPtr;
  TImVectorImWchar = TImVector<Char>;
  PImVectorImWchar = ^TImVectorImWchar;

  TImGuiStringGetter = function(AUserData: Pointer; AIndex: Integer): PUTF8Char; cdecl;
  TImGuiValueGetter = function(AUserData: Pointer; AIndex: Integer): Single; cdecl;
  TImDrawCallback = procedure(const AParentList: PImDrawList; const ACommand: PImDrawCmd); cdecl;
  TImGuiSizeCallback = procedure(AData: PImGuiSizeCallbackData); cdecl;
  TImGuiInputTextCallback = function(AData: _PImGuiInputTextCallbackData): Integer; cdecl;
  TImGuiMemAllocFunc = function(ASize: NativeInt; AUserData: Pointer): Pointer; cdecl;
  PImGuiMemAllocFunc = ^TImGuiMemAllocFunc;
  TImGuiMemFreeFunc = procedure(APtr, AUserData: Pointer); cdecl;
  PImGuiMemFreeFunc = ^TImGuiMemFreeFunc;

  TImDrawListSharedData = record
  end; // Data shared among multiple draw lists (typically owned by parent ImGui context, but you may create one yourself)

  TImFontAtlasBuilder = record
  end; // Opaque storage for building a ImFontAtlas

  TImFontLoader = record
  end; // Opaque interface to a font loading backend (stb_truetype, FreeType etc.).

  // Forward declarations: ImGui layer
  TImGuiContext = record
  end; // Dear ImGui context (opaque structure, unless including imgui_internal.h)

  TImTextureRef = record
  public
    // Members (either are set, never both!)
    TexData: PImTextureData; //      A texture, generally owned by a ImFontAtlas. Will convert to ImTextureID during render loop, after texture has been uploaded. 
    TexID: TImTextureID;     // _OR_ Low-level backend texture identifier, if already uploaded or created by user/app. Generally provided to e.g. ImGui::Image() calls. 
  public
    // Initialize with default values
    procedure Initialize; inline;

    // == (_TexData ? _TexData->TexID : _TexID) // Implemented below in the file.
    function GetTexID: TImTextureID; inline;
  end; 

  // Sorting specifications for a table (often handling sort specs for a single column, occasionally more)
  // Obtained by calling TableGetSortSpecs().
  // When 'SpecsDirty == true' you can sort your data. It will be true with sorting specs have changed since last call, or the first time.
  // Make sure to set 'SpecsDirty = false' after sorting, else you may wastefully sort your data every frame!
  TImGuiTableSortSpecs = record
  public
    Specs: PImGuiTableColumnSortSpecs; // Pointer to sort spec array. 
    SpecsCount: Int32;                 // Sort spec count. Most often 1. May be > 1 when ImGuiTableFlags_SortMulti is enabled. May be == 0 when ImGuiTableFlags_SortTristate is enabled. 
    SpecsDirty: Boolean;               // Set to true when specs have changed since last time! Use this to sort again, then clear the flag. 
  public
    // Initialize with default values
    procedure Initialize; inline;
  end; 

  // Sorting specification for one column of a table (sizeof == 12 bytes)
  TImGuiTableColumnSortSpecs = record
  public
    ColumnUserID: TImGuiID;             // User id of the column (if specified by a TableSetupColumn() call) 
    ColumnIndex: Int16;                 // Index of the column 
    SortOrder: Int16;                   // Index within parent ImGuiTableSortSpecs (always stored in order starting from 0, tables sorted on a single criteria will always have a 0 here) 
    SortDirection: TImGuiSortDirection; // ImGuiSortDirection_Ascending or ImGuiSortDirection_Descending 
  public
    // Initialize with default values
    procedure Initialize; inline;
  end; 

  TImGuiStyle = record
  public
    // Font scaling
    // - recap: ImGui::GetFontSize() == FontSizeBase * (FontScaleMain * FontScaleDpi * other_scaling_factors)
    FontSizeBase: Single;                          // Current base font size before external global factors are applied. Use PushFont(NULL, size) to modify. Use ImGui::GetFontSize() to obtain scaled value. 
    FontScaleMain: Single;                         // Main global scale factor. May be set by application once, or exposed to end-user. 
    FontScaleDpi: Single;                          // Additional global scale factor from viewport/monitor contents scale. In docking branch: when io.ConfigDpiScaleFonts is enabled, this is automatically overwritten when changing monitor DPI. 
    Alpha: Single;                                 // Global alpha applies to everything in Dear ImGui. 
    DisabledAlpha: Single;                         // Additional alpha multiplier applied by BeginDisabled(). Multiply over current value of Alpha. 
    WindowPadding: TVector2;                       // Padding within a window. 
    WindowRounding: Single;                        // Radius of window corners rounding. Set to 0.0f to have rectangular windows. Large values tend to lead to variety of artifacts and are not recommended. 
    WindowBorderSize: Single;                      // Thickness of border around windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly). 
    WindowBorderHoverPadding: Single;              // Hit-testing extent outside/inside resizing border. Also extend determination of hovered window. Generally meaningfully larger than WindowBorderSize to make it easy to reach borders. 
    WindowMinSize: TVector2;                       // Minimum window size. This is a global setting. If you want to constrain individual windows, use SetNextWindowSizeConstraints(). 
    WindowTitleAlign: TVector2;                    // Alignment for title bar text. Defaults to (0.0f,0.5f) for left-aligned,vertically centered. 
    WindowMenuButtonPosition: TImGuiDir;           // Side of the collapsing/docking button in the title bar (None/Left/Right). Defaults to ImGuiDir_Left. 
    ChildRounding: Single;                         // Radius of child window corners rounding. Set to 0.0f to have rectangular windows. 
    ChildBorderSize: Single;                       // Thickness of border around child windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly). 
    PopupRounding: Single;                         // Radius of popup window corners rounding. (Note that tooltip windows use WindowRounding) 
    PopupBorderSize: Single;                       // Thickness of border around popup/tooltip windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly). 
    FramePadding: TVector2;                        // Padding within a framed rectangle (used by most widgets). 
    FrameRounding: Single;                         // Radius of frame corners rounding. Set to 0.0f to have rectangular frame (used by most widgets). 
    FrameBorderSize: Single;                       // Thickness of border around frames. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly). 
    ItemSpacing: TVector2;                         // Horizontal and vertical spacing between widgets/lines. 
    ItemInnerSpacing: TVector2;                    // Horizontal and vertical spacing between within elements of a composed widget (e.g. a slider and its label). 
    CellPadding: TVector2;                         // Padding within a table cell. Cellpadding.x is locked for entire table. CellPadding.y may be altered between different rows. 
    TouchExtraPadding: TVector2;                   // Expand reactive bounding box for touch-based system where touch position is not accurate enough. Unfortunately we don't sort widgets so priority on overlap will always be given to the first widget. So don't grow this too much! 
    IndentSpacing: Single;                         // Horizontal indentation when e.g. entering a tree node. Generally == (FontSize + FramePadding.x*2). 
    ColumnsMinSpacing: Single;                     // Minimum horizontal spacing between two columns. Preferably > (FramePadding.x + 1). 
    ScrollbarSize: Single;                         // Width of the vertical scrollbar, Height of the horizontal scrollbar. 
    ScrollbarRounding: Single;                     // Radius of grab corners for scrollbar. 
    ScrollbarPadding: Single;                      // Padding of scrollbar grab within its frame (same for both axes). 
    GrabMinSize: Single;                           // Minimum width/height of a grab box for slider/scrollbar. 
    GrabRounding: Single;                          // Radius of grabs corners rounding. Set to 0.0f to have rectangular slider grabs. 
    LogSliderDeadzone: Single;                     // The size in pixels of the dead-zone around zero on logarithmic sliders that cross zero. 
    ImageRounding: Single;                         // Rounding of Image() calls. 
    ImageBorderSize: Single;                       // Thickness of border around Image() calls. 
    TabRounding: Single;                           // Radius of upper corners of a tab. Set to 0.0f to have rectangular tabs. 
    TabBorderSize: Single;                         // Thickness of border around tabs. 
    TabMinWidthBase: Single;                       // Minimum tab width, to make tabs larger than their contents. TabBar buttons are not affected. 
    TabMinWidthShrink: Single;                     // Minimum tab width after shrinking, when using ImGuiTabBarFlags_FittingPolicyMixed policy. 
    TabCloseButtonMinWidthSelected: Single;        // -1: always visible. 0.0f: visible when hovered. >0.0f: visible when hovered if minimum width. FLT_MAX: never shrink, will behave like ImGuiTabBarFlags_FittingPolicyScroll. 
    TabCloseButtonMinWidthUnselected: Single;      // -1: always visible. 0.0f: visible when hovered. >0.0f: visible when hovered if minimum width. FLT_MAX: never show close button when unselected. 
    TabBarBorderSize: Single;                      // Thickness of tab-bar separator, which takes on the tab active color to denote focus. 
    TabBarOverlineSize: Single;                    // Thickness of tab-bar overline, which highlights the selected tab-bar. 
    TableAngledHeadersAngle: Single;               // Angle of angled headers (supported values range from -50.0f degrees to +50.0f degrees). 
    TableAngledHeadersTextAlign: TVector2;         // Alignment of angled headers within the cell 
    TreeLinesFlags: TImGuiTreeNodeFlags;           // Default way to draw lines connecting TreeNode hierarchy. ImGuiTreeNodeFlags_DrawLinesNone or ImGuiTreeNodeFlags_DrawLinesFull or ImGuiTreeNodeFlags_DrawLinesToNodes. 
    TreeLinesSize: Single;                         // Thickness of outlines when using ImGuiTreeNodeFlags_DrawLines. 
    TreeLinesRounding: Single;                     // Radius of lines connecting child nodes to the vertical line. 
    DragDropTargetRounding: Single;                // Radius of the drag and drop target frame. When <0.0f: use FrameRounding. 
    DragDropTargetBorderSize: Single;              // Thickness of the drag and drop target border. 
    DragDropTargetPadding: Single;                 // Size to expand the drag and drop target from actual target item size. 
    ColorMarkerSize: Single;                       // Size of R/G/B/A color markers for ColorEdit4() and for Drags/Sliders when using ImGuiSliderFlags_ColorMarkers. 
    ColorButtonPosition: TImGuiDir;                // Side of the color button in the ColorEdit4 widget (left/right). Defaults to ImGuiDir_Right. 
    ButtonTextAlign: TVector2;                     // Alignment of button text when button is larger than text. Defaults to (0.5f, 0.5f) (centered). 
    SelectableTextAlign: TVector2;                 // Alignment of selectable text. Defaults to (0.0f, 0.0f) (top-left aligned). It's generally important to keep this left-aligned if you want to lay multiple items on a same line. 
    SeparatorSize: Single;                         // Thickness of border in Separator(). Must be >= 1.0f. 
    SeparatorTextBorderSize: Single;               // Thickness of border in SeparatorText() 
    SeparatorTextAlign: TVector2;                  // Alignment of text within the separator. Defaults to (0.0f, 0.5f) (left aligned, center). 
    SeparatorTextPadding: TVector2;                // Horizontal offset of text from each edge of the separator + spacing on other axis. Generally small values. .y is recommended to be == FramePadding.y. 
    DisplayWindowPadding: TVector2;                // Apply to regular windows: amount which we enforce to keep visible when moving near edges of your screen. 
    DisplaySafeAreaPadding: TVector2;              // Apply to every windows, menus, popups, tooltips: amount where we avoid displaying contents. Adjust if you cannot see the edges of your screen (e.g. on a TV where scaling has not been configured). 
    MouseCursorScale: Single;                      // Scale software rendered mouse cursor (when io.MouseDrawCursor is enabled). We apply per-monitor DPI scaling over this scale. May be removed later. 
    AntiAliasedLines: Boolean;                     // Enable anti-aliased lines/borders. Disable if you are really tight on CPU/GPU. Latched at the beginning of the frame (copied to ImDrawList). 
    AntiAliasedLinesUseTex: Boolean;               // Enable anti-aliased lines/borders using textures where possible. Require backend to render with bilinear filtering (NOT point/nearest filtering). Latched at the beginning of the frame (copied to ImDrawList). 
    AntiAliasedFill: Boolean;                      // Enable anti-aliased edges around filled shapes (rounded rectangles, circles, etc.). Disable if you are really tight on CPU/GPU. Latched at the beginning of the frame (copied to ImDrawList). 
    CurveTessellationTol: Single;                  // Tessellation tolerance when using PathBezierCurveTo() without a specific number of segments. Decrease for highly tessellated curves (higher quality, more polygons), increase to reduce quality. 
    CircleTessellationMaxError: Single;            // Maximum error (in pixels) allowed when using AddCircle()/AddCircleFilled() or drawing rounded corner rectangles with no explicit segment count specified. Decrease for higher quality but more geometry. 
    // Colors
    Colors: array [0.._ImGuiCol_COUNT - 1] of TVector4; 
    // Behaviors
    // (It is possible to modify those fields mid-frame if specific behavior need it, unlike e.g. configuration fields in ImGuiIO)
    HoverStationaryDelay: Single;                  // Delay for IsItemHovered(ImGuiHoveredFlags_Stationary). Time required to consider mouse stationary. 
    HoverDelayShort: Single;                       // Delay for IsItemHovered(ImGuiHoveredFlags_DelayShort). Usually used along with HoverStationaryDelay. 
    HoverDelayNormal: Single;                      // Delay for IsItemHovered(ImGuiHoveredFlags_DelayNormal). " 
    HoverFlagsForTooltipMouse: TImGuiHoveredFlags; // Default flags when using IsItemHovered(ImGuiHoveredFlags_ForTooltip) or BeginItemTooltip()/SetItemTooltip() while using mouse. 
    HoverFlagsForTooltipNav: TImGuiHoveredFlags;   // Default flags when using IsItemHovered(ImGuiHoveredFlags_ForTooltip) or BeginItemTooltip()/SetItemTooltip() while using keyboard/gamepad. 
    // [Internal]
    MainScale: Single;                             // FIXME-WIP: Reference scale, as applied by ScaleAllSizes(). PLEASE DO NOT USE THIS FOR NOW. 
    NextFrameFontSizeBase: Single;                 // FIXME: Temporary hack until we finish remaining work. 
  public
    // Initialize with default values
    procedure Initialize; inline;

    // Scale all spacing/padding/thickness values. Do not scale fonts. See comments in definition. Consider not calling this if your initial scale factor if <1.0.
    procedure ScaleAllSizes(const AScaleFactor: Single); inline;
  end; 

  // [Internal] Storage used by IsKeyDown(), IsKeyPressed() etc functions.
  // If prior to 1.87 you used io.KeysDownDuration[] (which was marked as internal), you should use GetKeyData(key)->DownDuration and *NOT* io.KeysData[key]->DownDuration.
  TImGuiKeyData = record
  public
    Down: Boolean;            // True for if key is down 
    DownDuration: Single;     // Duration the key has been down (<0.0f: not pressed, 0.0f: just pressed, >0.0f: time held) 
    DownDurationPrev: Single; // Last frame duration the key has been down 
    AnalogValue: Single;      // 0.0f..1.0f for gamepad values 
  public
    // Initialize with default values
    procedure Initialize; inline;
  end; 

  TImGuiIO = record
  public
    ConfigFlags: TImGuiConfigFlags;                                     // = 0              // See ImGuiConfigFlags_ enum. Set by user/application. Keyboard/Gamepad navigation options, etc. 
    BackendFlags: TImGuiBackendFlags;                                   // = 0              // See ImGuiBackendFlags_ enum. Set by backend (imgui_impl_xxx files or custom backend) to communicate features supported by the backend. 
    DisplaySize: TVector2;                                              // <unset>          // Main display size, in pixels (== GetMainViewport()->Size). May change every frame. 
    DisplayFramebufferScale: TVector2;                                  // = (1, 1)         // Main display density. For retina display where window coordinates are different from framebuffer coordinates. This will affect font density + will end up in ImDrawData::FramebufferScale. 
    DeltaTime: Single;                                                  // = 1.0f/60.0f     // Time elapsed since last frame, in seconds. May change every frame. 
    IniSavingRate: Single;                                              // = 5.0f           // Minimum time between saving positions/sizes to .ini file, in seconds. 
    IniFilename: PUTF8Char;                                             // = "imgui.ini"    // Path to .ini file (important: default "imgui.ini" is relative to current working dir!). Set NULL to disable automatic .ini loading/saving or if you want to manually call LoadIniSettingsXXX() / SaveIniSettingsXXX() functions. 
    LogFilename: PUTF8Char;                                             // = "imgui_log.txt"// Path to .log file (default parameter to ImGui::LogToFile when no file is specified). 
    UserData: Pointer;                                                  // = NULL           // Store your own data. 
    // Font system
    Fonts: PImFontAtlas;                                                // <auto>           // Font atlas: load, rasterize and pack one or more fonts into a single texture. 
    FontDefault: PImFont;                                               // = NULL           // Font to use on NewFrame(). Use NULL to uses Fonts->Fonts[0]. 
    FontAllowUserScaling: Boolean;                                      // = false          // Allow user scaling text of individual window with Ctrl+Wheel. 
    // Keyboard/Gamepad Navigation options
    ConfigNavSwapGamepadButtons: Boolean;                               // = false          // Swap Activate<>Cancel (A<>B) buttons, matching typical "Nintendo/Japanese style" gamepad layout. 
    ConfigNavMoveSetMousePos: Boolean;                                  // = false          // Directional/tabbing navigation teleports the mouse cursor. May be useful on TV/console systems where moving a virtual mouse is difficult. Will update io.MousePos and set io.WantSetMousePos=true. 
    ConfigNavCaptureKeyboard: Boolean;                                  // = true           // Sets io.WantCaptureKeyboard when io.NavActive is set. 
    ConfigNavEscapeClearFocusItem: Boolean;                             // = true           // Pressing Escape can clear focused item + navigation id/highlight. Set to false if you want to always keep highlight on. 
    ConfigNavEscapeClearFocusWindow: Boolean;                           // = false          // Pressing Escape can clear focused window as well (super set of io.ConfigNavEscapeClearFocusItem). 
    ConfigNavCursorVisibleAuto: Boolean;                                // = true           // Using directional navigation key makes the cursor visible. Mouse click hides the cursor. 
    ConfigNavCursorVisibleAlways: Boolean;                              // = false          // Navigation cursor is always visible. 
    // Miscellaneous options
    // (you can visualize and interact with all options in 'Demo->Configuration')
    MouseDrawCursor: Boolean;                                           // = false          // Request ImGui to draw a mouse cursor for you (if you are on a platform without a mouse cursor). Cannot be easily renamed to 'io.ConfigXXX' because this is frequently used by backend implementations. 
    ConfigMacOSXBehaviors: Boolean;                                     // = defined(__APPLE__) // Swap Cmd<>Ctrl keys + OS X style text editing cursor movement using Alt instead of Ctrl, Shortcuts using Cmd/Super instead of Ctrl, Line/Text Start and End using Cmd+Arrows instead of Home/End, Double click selects by word instead of selecting whole text, Multi-selection in lists uses Cmd/Super instead of Ctrl. 
    ConfigInputTrickleEventQueue: Boolean;                              // = true           // Enable input queue trickling: some types of events submitted during the same frame (e.g. button down + up) will be spread over multiple frames, improving interactions with low framerates. 
    ConfigInputTextCursorBlink: Boolean;                                // = true           // Enable blinking cursor (optional as some users consider it to be distracting). 
    ConfigInputTextEnterKeepActive: Boolean;                            // = false          // [BETA] Pressing Enter will reactivate item and select all text (single-line only). 
    ConfigDragClickToInputText: Boolean;                                // = false          // [BETA] Enable turning DragXXX widgets into text input with a simple mouse click-release (without moving). Not desirable on devices without a keyboard. 
    ConfigWindowsResizeFromEdges: Boolean;                              // = true           // Enable resizing of windows from their edges and from the lower-left corner. This requires ImGuiBackendFlags_HasMouseCursors for better mouse cursor feedback. (This used to be a per-window ImGuiWindowFlags_ResizeFromAnySide flag) 
    ConfigWindowsMoveFromTitleBarOnly: Boolean;                         // = false      // Enable allowing to move windows only when clicking on their title bar. Does not apply to windows without a title bar. 
    ConfigWindowsCopyContentsWithCtrlC: Boolean;                        // = false      // [EXPERIMENTAL] Ctrl+C copy the contents of focused window into the clipboard. Experimental because: (1) has known issues with nested Begin/End pairs (2) text output quality varies (3) text output is in submission order rather than spatial order. 
    ConfigScrollbarScrollByPage: Boolean;                               // = true           // Enable scrolling page by page when clicking outside the scrollbar grab. When disabled, always scroll to clicked location. When enabled, Shift+Click scrolls to clicked location. 
    ConfigMemoryCompactTimer: Single;                                   // = 60.0f          // Timer (in seconds) to free transient windows/tables memory buffers when unused. Set to -1.0f to disable. 
    // Inputs Behaviors
    // (other variables, ones which are expected to be tweaked within UI code, are exposed in ImGuiStyle)
    MouseDoubleClickTime: Single;                                       // = 0.30f          // Time for a double-click, in seconds. 
    MouseDoubleClickMaxDist: Single;                                    // = 6.0f           // Distance threshold to stay in to validate a double-click, in pixels. 
    MouseDragThreshold: Single;                                         // = 6.0f           // Distance threshold before considering we are dragging. 
    KeyRepeatDelay: Single;                                             // = 0.275f         // When holding a key/button, time before it starts repeating, in seconds (for buttons in Repeat mode, etc.). 
    KeyRepeatRate: Single;                                              // = 0.050f         // When holding a key/button, rate at which it repeats, in seconds. 
    // Options to configure Error Handling and how we handle recoverable errors [EXPERIMENTAL]
    // - Error recovery is provided as a way to facilitate:
    //    - Recovery after a programming error (native code or scripting language - the latter tends to facilitate iterating on code while running).
    //    - Recovery after running an exception handler or any error processing which may skip code after an error has been detected.
    // - Error recovery is not perfect nor guaranteed! It is a feature to ease development.
    //   You not are not supposed to rely on it in the course of a normal application run.
    // - Functions that support error recovery are using IM_ASSERT_USER_ERROR() instead of IM_ASSERT().
    // - By design, we do NOT allow error recovery to be 100% silent. One of the three options needs to be checked!
    // - Always ensure that on programmers seats you have at minimum Asserts or Tooltips enabled when making direct imgui API calls!
    //   Otherwise it would severely hinder your ability to catch and correct mistakes!
    // Read https://github.com/ocornut/imgui/wiki/Error-Handling for details.
    // - Programmer seats: keep asserts (default), or disable asserts and keep error tooltips (new and nice!)
    // - Non-programmer seats: maybe disable asserts, but make sure errors are resurfaced (tooltips, visible log entries, use callback etc.)
    // - Recovery after error/exception: record stack sizes with ErrorRecoveryStoreState(), disable assert, set log callback (to e.g. trigger high-level breakpoint), recover with ErrorRecoveryTryToRecoverState(), restore settings.
    ConfigErrorRecovery: Boolean;                                       // = true       // Enable error recovery support. Some errors won't be detected and lead to direct crashes if recovery is disabled. 
    ConfigErrorRecoveryEnableAssert: Boolean;                           // = true       // Enable asserts on recoverable error. By default call IM_ASSERT() when returning from a failing IM_ASSERT_USER_ERROR() 
    ConfigErrorRecoveryEnableDebugLog: Boolean;                         // = true       // Enable debug log output on recoverable errors. 
    ConfigErrorRecoveryEnableTooltip: Boolean;                          // = true       // Enable tooltip on recoverable errors. The tooltip include a way to enable asserts if they were disabled. 
    // Option to enable various debug tools showing buttons that will call the IM_DEBUG_BREAK() macro.
    // - The Item Picker tool will be available regardless of this being enabled, in order to maximize its discoverability.
    // - Requires a debugger being attached, otherwise IM_DEBUG_BREAK() options will appear to crash your application.
    //   e.g. io.ConfigDebugIsDebuggerPresent = ::IsDebuggerPresent() on Win32, or refer to ImOsIsDebuggerPresent() imgui_test_engine/imgui_te_utils.cpp for a Unix compatible version.
    ConfigDebugIsDebuggerPresent: Boolean;                              // = false          // Enable various tools calling IM_DEBUG_BREAK(). 
    // Tools to detect code submitting items with conflicting/duplicate IDs
    // - Code should use PushID()/PopID() in loops, or append "##xx" to same-label identifiers.
    // - Empty label e.g. Button("") == same ID as parent widget/node. Use Button("##xx") instead!
    // - See FAQ https://github.com/ocornut/imgui/blob/master/docs/FAQ.md#q-about-the-id-stack-system
    ConfigDebugHighlightIdConflicts: Boolean;                           // = true           // Highlight and show an error message popup when multiple items have conflicting identifiers. 
    ConfigDebugHighlightIdConflictsShowItemPicker: Boolean;             //=true // Show "Item Picker" button in aforementioned popup. 
    // Tools to test correct Begin/End and BeginChild/EndChild behaviors.
    // - Presently Begin()/End() and BeginChild()/EndChild() needs to ALWAYS be called in tandem, regardless of return value of BeginXXX()
    // - This is inconsistent with other BeginXXX functions and create confusion for many users.
    // - We expect to update the API eventually. In the meanwhile we provide tools to facilitate checking user-code behavior.
    ConfigDebugBeginReturnValueOnce: Boolean;                           // = false          // First-time calls to Begin()/BeginChild() will return false. NEEDS TO BE SET AT APPLICATION BOOT TIME if you don't want to miss windows. 
    ConfigDebugBeginReturnValueLoop: Boolean;                           // = false          // Some calls to Begin()/BeginChild() will return false. Will cycle through window depths then repeat. Suggested use: add "io.ConfigDebugBeginReturnValue = io.KeyShift" in your main loop then occasionally press SHIFT. Windows should be flickering while running. 
    // Option to deactivate io.AddFocusEvent(false) handling.
    // - May facilitate interactions with a debugger when focus loss leads to clearing inputs data.
    // - Backends may have other side-effects on focus loss, so this will reduce side-effects but not necessary remove all of them.
    ConfigDebugIgnoreFocusLoss: Boolean;                                // = false          // Ignore io.AddFocusEvent(false), consequently not calling io.ClearInputKeys()/io.ClearInputMouse() in input processing. 
    // Option to audit .ini data
    ConfigDebugIniSettings: Boolean;                                    // = false          // Save .ini data with extra comments (particularly helpful for Docking, but makes saving slower) 
    // Nowadays those would be stored in ImGuiPlatformIO but we are leaving them here for legacy reasons.
    // Optional: Platform/Renderer backend name (informational only! will be displayed in About Window) + User data for backend/wrappers to store their own stuff.
    BackendPlatformName: PUTF8Char;                                     // = NULL 
    BackendRendererName: PUTF8Char;                                     // = NULL 
    BackendPlatformUserData: Pointer;                                   // = NULL           // User data for platform backend 
    BackendRendererUserData: Pointer;                                   // = NULL           // User data for renderer backend 
    BackendLanguageUserData: Pointer;                                   // = NULL           // User data for non C++ programming language backend 
    WantCaptureMouse: Boolean;                                          // Set when Dear ImGui will use mouse inputs, in this case do not dispatch them to your main game/application (either way, always pass on mouse inputs to imgui). (e.g. unclicked mouse is hovering over an imgui window, widget is active, mouse was clicked over an imgui window, etc.). 
    WantCaptureKeyboard: Boolean;                                       // Set when Dear ImGui will use keyboard inputs, in this case do not dispatch them to your main game/application (either way, always pass keyboard inputs to imgui). (e.g. InputText active, or an imgui window is focused and navigation is enabled, etc.). 
    WantTextInput: Boolean;                                             // Mobile/console: when set, you may display an on-screen keyboard. This is set by Dear ImGui when it wants textual keyboard input to happen (e.g. when a InputText widget is active). 
    WantSetMousePos: Boolean;                                           // MousePos has been altered, backend should reposition mouse on next frame. Rarely used! Set only when io.ConfigNavMoveSetMousePos is enabled. 
    WantSaveIniSettings: Boolean;                                       // When manual .ini load/save is active (io.IniFilename == NULL), this will be set to notify your application that you can call SaveIniSettingsToMemory() and save yourself. Important: clear io.WantSaveIniSettings yourself after saving! 
    NavActive: Boolean;                                                 // Keyboard/Gamepad navigation is currently allowed (will handle ImGuiKey_NavXXX events) = a window is focused and it doesn't use the ImGuiWindowFlags_NoNavInputs flag. 
    NavVisible: Boolean;                                                // Keyboard/Gamepad navigation highlight is visible and allowed (will handle ImGuiKey_NavXXX events). 
    Framerate: Single;                                                  // Estimate of application framerate (rolling average over 60 frames, based on io.DeltaTime), in frame per second. Solely for convenience. Slow applications may not want to use a moving average or may want to reset underlying buffers occasionally. 
    MetricsRenderVertices: Int32;                                       // Vertices output during last call to Render() 
    MetricsRenderIndices: Int32;                                        // Indices output during last call to Render() = number of triangles * 3 
    MetricsRenderWindows: Int32;                                        // Number of visible windows 
    MetricsActiveWindows: Int32;                                        // Number of active windows 
    MouseDelta: TVector2;                                               // Mouse delta. Note that this is zero if either current or previous position are invalid (-FLT_MAX,-FLT_MAX), so a disappearing/reappearing mouse won't have a huge delta. 
    Ctx: PImGuiContext;                                                 // Parent UI context (needs to be set explicitly by parent). 
    // Main Input State
    // (this block used to be written by backend, since 1.87 it is best to NOT write to those directly, call the AddXXX functions above instead)
    // (reading from those variables is fair game, as they are extremely unlikely to be moving anywhere)
    MousePos: TVector2;                                                 // Mouse position, in pixels. Set to ImVec2(-FLT_MAX, -FLT_MAX) if mouse is unavailable (on another screen, etc.) 
    MouseDown: array [0..4] of Boolean;                                 // Mouse buttons: 0=left, 1=right, 2=middle + extras (ImGuiMouseButton_COUNT == 5). Dear ImGui mostly uses left and right buttons. Other buttons allow us to track if the mouse is being used by your application + available to user as a convenience via IsMouse** API. 
    MouseWheel: Single;                                                 // Mouse wheel Vertical: 1 unit scrolls about 5 lines text. >0 scrolls Up, <0 scrolls Down. Hold Shift to turn vertical scroll into horizontal scroll. 
    MouseWheelH: Single;                                                // Mouse wheel Horizontal. >0 scrolls Left, <0 scrolls Right. Most users don't have a mouse with a horizontal wheel, may not be filled by all backends. 
    MouseSource: TImGuiMouseSource;                                     // Mouse actual input peripheral (Mouse/TouchScreen/Pen). 
    KeyCtrl: Boolean;                                                   // Keyboard modifier down: Ctrl (non-macOS), Cmd (macOS) 
    KeyShift: Boolean;                                                  // Keyboard modifier down: Shift 
    KeyAlt: Boolean;                                                    // Keyboard modifier down: Alt 
    KeySuper: Boolean;                                                  // Keyboard modifier down: Windows/Super (non-macOS), Ctrl (macOS) 
    // Other state maintained from data above + IO function calls
    KeyMods: TImGuiKeyChord;                                            // Key mods flags (any of ImGuiMod_Ctrl/ImGuiMod_Shift/ImGuiMod_Alt/ImGuiMod_Super flags, same as io.KeyCtrl/KeyShift/KeyAlt/KeySuper but merged into flags). Read-only, updated by NewFrame() 
    KeysData: array [0.._ImGuiKey_NamedKey_COUNT - 1] of TImGuiKeyData; // Key state for all known keys. MUST use 'key - ImGuiKey_NamedKey_BEGIN' as index. Use IsKeyXXX() functions to access this. 
    WantCaptureMouseUnlessPopupClose: Boolean;                          // Alternative to WantCaptureMouse: (WantCaptureMouse == true && WantCaptureMouseUnlessPopupClose == false) when a click over void is expected to close a popup. 
    MousePosPrev: TVector2;                                             // Previous mouse position (note that MouseDelta is not necessary == MousePos-MousePosPrev, in case either position is invalid) 
    MouseClickedPos: array [0..4] of TVector2;                          // Position at time of clicking 
    MouseClickedTime: array [0..4] of Double;                           // Time of last click (used to figure out double-click) 
    MouseClicked: array [0..4] of Boolean;                              // Mouse button went from !Down to Down (same as MouseClickedCount[x] != 0) 
    MouseDoubleClicked: array [0..4] of Boolean;                        // Has mouse button been double-clicked? (same as MouseClickedCount[x] == 2) 
    MouseClickedCount: array [0..4] of UInt16;                          // == 0 (not clicked), == 1 (same as MouseClicked[]), == 2 (double-clicked), == 3 (triple-clicked) etc. when going from !Down to Down 
    MouseClickedLastCount: array [0..4] of UInt16;                      // Count successive number of clicks. Stays valid after mouse release. Reset after another click is done. 
    MouseReleased: array [0..4] of Boolean;                             // Mouse button went from Down to !Down 
    MouseReleasedTime: array [0..4] of Double;                          // Time of last released (rarely used! but useful to handle delayed single-click when trying to disambiguate them from double-click). 
    MouseDownOwned: array [0..4] of Boolean;                            // Track if button was clicked inside a dear imgui window or over void blocked by a popup. We don't request mouse capture from the application if click started outside ImGui bounds. 
    MouseDownOwnedUnlessPopupClose: array [0..4] of Boolean;            // Track if button was clicked inside a dear imgui window. 
    MouseWheelRequestAxisSwap: Boolean;                                 // On a non-Mac system, holding Shift requests WheelY to perform the equivalent of a WheelX event. On a Mac system this is already enforced by the system. 
    MouseCtrlLeftAsRightClick: Boolean;                                 // (OSX) Set to true when the current click was a Ctrl+Click that spawned a simulated right click 
    MouseDownDuration: array [0..4] of Single;                          // Duration the mouse button has been down (0.0f == just clicked) 
    MouseDownDurationPrev: array [0..4] of Single;                      // Previous time the mouse button has been down 
    MouseDragMaxDistanceSqr: array [0..4] of Single;                    // Squared maximum distance of how much mouse has traveled from the clicking point (used for moving thresholds) 
    PenPressure: Single;                                                // Touch/Pen pressure (0.0f to 1.0f, should be >0.0f only when MouseDown[0] == true). Helper storage currently unused by Dear ImGui. 
    AppFocusLost: Boolean;                                              // Only modify via AddFocusEvent() 
    AppAcceptingEvents: Boolean;                                        // Only modify via SetAppAcceptingEvents() 
    InputQueueSurrogate: Char;                                          // For AddInputCharacterUTF16() 
    InputQueueCharacters: TImVector<Char>;                              // Queue of _characters_ input (obtained by platform backend). Fill using AddInputCharacter() helper. 
  public
    // Initialize with default values
    procedure Initialize; inline;

    // Input Functions
    // Queue a new key down/up event. Key should be "translated" (as in, generally ImGuiKey_A matches the key end-user would use to emit an 'A' character)
    procedure AddKeyEvent(const AKey: TImGuiKey; const ADown: Boolean); inline;

    // Queue a new key down/up event for analog values (e.g. ImGuiKey_Gamepad_ values). Dead-zones should be handled by the backend.
    procedure AddKeyAnalogEvent(const AKey: TImGuiKey; const ADown: Boolean; const AV: Single); inline;

    // Queue a mouse position update. Use -FLT_MAX,-FLT_MAX to signify no mouse (e.g. app not focused and not hovered)
    procedure AddMousePosEvent(const AX, AY: Single); inline;

    // Queue a mouse button change
    procedure AddMouseButtonEvent(const AButton: Int32; const ADown: Boolean); inline;

    // Queue a mouse wheel update. wheel_y<0: scroll down, wheel_y>0: scroll up, wheel_x<0: scroll right, wheel_x>0: scroll left.
    procedure AddMouseWheelEvent(const AWheelX, AWheelY: Single); inline;

    // Queue a mouse source change (Mouse/TouchScreen/Pen)
    procedure AddMouseSourceEvent(const ASource: TImGuiMouseSource); inline;

    // Queue a gain/loss of focus for the application (generally based on OS/platform focus of your window)
    procedure AddFocusEvent(const AFocused: Boolean); inline;

    // Queue a new character input
    procedure AddInputCharacter(const AC: UInt32); inline;

    // Queue a new character input from a UTF-16 character, it can be a surrogate
    procedure AddInputCharacterUTF16(const AC: Char); inline;

    // Queue a new characters input from a UTF-8 string
    procedure AddInputCharactersUTF8(const AStr: PUTF8Char); inline;

    // Implied native_legacy_index = -1
    procedure SetKeyEventNativeData(const AKey: TImGuiKey; const ANativeKeycode, 
      ANativeScancode: Int32); overload; inline;

    // [Optional] Specify index for legacy <1.87 IsKeyXXX() functions with native indices + specify native keycode, scancode.
    procedure SetKeyEventNativeData(const AKey: TImGuiKey; const ANativeKeycode, 
      ANativeScancode: Int32; const ANativeLegacyIndex: Int32 = -1); overload; inline;

    // Set master flag for accepting key/mouse/text events (default to true). Useful if you have native dialog boxes that are interrupting your application loop/refresh, and you want to disable events being queued while your app is frozen.
    procedure SetAppAcceptingEvents(const AAcceptingEvents: Boolean); inline;

    // Clear all incoming events.
    procedure ClearEventsQueue; inline;

    // Clear current keyboard/gamepad state + current frame text input buffer. Equivalent to releasing all keys/buttons.
    procedure ClearInputKeys; inline;

    // Clear current mouse state.
    procedure ClearInputMouse; inline;
  end; 

  // Shared state of InputText(), passed as an argument to your callback when a ImGuiInputTextFlags_Callback* flag is used.
  // The callback function should return 0 by default.
  // Callbacks (follow a flag name and see comments in ImGuiInputTextFlags_ declarations for more details)
  // - ImGuiInputTextFlags_CallbackEdit:        Callback on buffer edit. Note that InputText() already returns true on edit + you can always use IsItemEdited(). The callback is useful to manipulate the underlying buffer while focus is active.
  // - ImGuiInputTextFlags_CallbackAlways:      Callback on each iteration
  // - ImGuiInputTextFlags_CallbackCompletion:  Callback on pressing TAB
  // - ImGuiInputTextFlags_CallbackHistory:     Callback on pressing Up/Down arrows
  // - ImGuiInputTextFlags_CallbackCharFilter:  Callback on character inputs to replace or discard them. Modify 'EventChar' to replace or discard, or return 1 in callback to discard.
  // - ImGuiInputTextFlags_CallbackResize:      Callback on buffer capacity changes request (beyond 'buf_size' parameter value), allowing the string to grow.
  TImGuiInputTextCallbackData = record
  public
    Ctx: PImGuiContext;              // Parent UI context 
    EventFlag: TImGuiInputTextFlags; // One ImGuiInputTextFlags_Callback*    // Read-only 
    Flags: TImGuiInputTextFlags;     // What user passed to InputText()      // Read-only 
    UserData: Pointer;               // What user passed to InputText()      // Read-only 
    ID: TImGuiID;                    // Widget ID                            // Read-only 
    // Arguments for the different callback events
    // - During Resize callback, Buf will be same as your input buffer.
    // - However, during Completion/History/Always callback, Buf always points to our own internal data (it is not the same as your buffer)! Changes to it will be reflected into your own buffer shortly after the callback.
    // - To modify the text buffer in a callback, prefer using the InsertChars() / DeleteChars() function. InsertChars() will take care of calling the resize callback if necessary.
    // - If you know your edits are not going to resize the underlying buffer allocation, you may modify the contents of 'Buf[]' directly. You need to update 'BufTextLen' accordingly (0 <= BufTextLen < BufSize) and set 'BufDirty'' to true so InputText can update its internal state.
    EventKey: TImGuiKey;             // Key pressed (Up/Down/TAB)            // Read-only    // [Completion,History] 
    EventChar: Char;                 // Character input                      // Read-write   // [CharFilter] Replace character with another one, or set to zero to drop. return 1 is equivalent to setting EventChar=0; 
    EventActivated: Boolean;         // Input field just got activated       // Read-only    // [Always] 
    BufDirty: Boolean;               // Set if you modify Buf/BufTextLen!    // Write        // [Completion,History,Always] 
    Buf: PUTF8Char;                  // Text buffer                          // Read-write   // [Resize] Can replace pointer / [Completion,History,Always] Only write to pointed data, don't replace the actual pointer! 
    BufTextLen: Int32;               // Text length (in bytes)               // Read-write   // [Resize,Completion,History,Always] Exclude zero-terminator storage. In C land: == strlen(some_text), in C++ land: string.length() 
    BufSize: Int32;                  // Buffer size (in bytes) = capacity+1  // Read-only    // [Resize,Completion,History,Always] Include zero-terminator storage. In C land: == ARRAYSIZE(my_char_array), in C++ land: string.capacity()+1 
    CursorPos: Int32;                //                                      // Read-write   // [Completion,History,Always,CharFilter] 
    SelectionStart: Int32;           //                                      // Read-write   // [Completion,History,Always,CharFilter] == to SelectionEnd when no selection 
    SelectionEnd: Int32;             //                                      // Read-write   // [Completion,History,Always,CharFilter] 
  public
    // Initialize with default values
    procedure Initialize; inline;

    procedure DeleteChars(const APos, ABytesCount: Int32); inline;
    procedure InsertChars(const APos: Int32; const AText: PUTF8Char; const ATextEnd: PUTF8Char = nil); inline;
    procedure SelectAll; inline;
    procedure SetSelection(const &AS, AE: Int32); inline;
    procedure ClearSelection; inline;
    function HasSelection: Boolean; inline;
  end; 

  // Resizing callback data to apply custom constraint. As enabled by SetNextWindowSizeConstraints(). Callback is called during the next Begin().
  // NB: For basic min/max size constraint on each axis you don't need to use the callback! The SetNextWindowSizeConstraints() parameters are enough.
  TImGuiSizeCallbackData = record
  public
    UserData: Pointer;     // Read-only.   What user passed to SetNextWindowSizeConstraints(). Generally store an integer or float in here (need reinterpret_cast<>). 
    Pos: TVector2;         // Read-only.   Window position, for reference. 
    CurrentSize: TVector2; // Read-only.   Current window size. 
    DesiredSize: TVector2; // Read-write.  Desired size, based on user's mouse position. Write to this field to restrain resizing. 
  public
    // Initialize with default values
    procedure Initialize; inline;
  end; 

  // Data payload for Drag and Drop operations: AcceptDragDropPayload(), GetDragDropPayload()
  TImGuiPayload = record
  public
    // Members
    Data: Pointer;                             // Data (copied and owned by dear imgui) 
    DataSize: Int32;                           // Data size 
    // [Internal]
    SourceId: TImGuiID;                        // Source item id 
    SourceParentId: TImGuiID;                  // Source parent id (if available) 
    DataFrameCount: Int32;                     // Data timestamp 
    DataType: array [0..32+1 - 1] of UTF8Char; // Data type tag (short user-supplied string, 32 characters max) 
    Preview: Boolean;                          // Set when AcceptDragDropPayload() was called and mouse has been hovering the target item (nb: handle overlapping drag targets) 
    Delivery: Boolean;                         // Set when AcceptDragDropPayload() was called and mouse button is released over the target item. 
  public
    // Initialize with default values
    procedure Initialize; inline;

    procedure Clear; inline;
    function IsDataType(const AType: PUTF8Char): Boolean; inline;
    function IsPreview: Boolean; inline;
    function IsDelivery: Boolean; inline;
  end; 

  // [Internal]
  TImGuiTextRange = record
  public
    B: PUTF8Char; 
    E: PUTF8Char; 
  public
    // Initialize with default values
    procedure Initialize; inline;
  end; 

  // Helper: Parse and apply text filters. In format "aaaaa[,bbbb][,ccccc]"
  TImGuiTextFilter = record
  public
    InputBuf: array [0..255] of UTF8Char; 
    Filters: TImVector<TImGuiTextRange>; 
    CountGrep: Int32; 
  public
    // Initialize with default values
    procedure Initialize; inline;

    // Helper calling InputText+Build
    function Draw(const ALabel: PUTF8Char; const AWidth: Single = 0.0): Boolean; overload; inline;
    function Draw(const AWidth: Single = 0.0): Boolean; overload; inline;
    function PassFilter(const AText: PUTF8Char; const ATextEnd: PUTF8Char = nil): Boolean; inline;
    procedure Build; inline;
    procedure Clear; inline;
    function IsActive: Boolean; inline;
  end; 

  // Helper: Growable text buffer for logging/accumulating text
  // (this could be called 'ImGuiTextBuilder' / 'ImGuiStringBuilder')
  TImGuiTextBuffer = record
  public
    Buf: TImVector<UTF8Char>; 
  public
    // Initialize with default values
    procedure Initialize; inline;

    function &Begin: PUTF8Char; inline;

    // Buf is zero-terminated, so end() will point on the zero-terminator
    function &End: PUTF8Char; inline;
    function Size: Int32; inline;
    function Empty: Boolean; inline;
    procedure Clear; inline;

    // Similar to resize(0) on ImVector: empty string but don't free buffer.
    procedure Resize(const ASize: Int32); inline;
    procedure Reserve(const ACapacity: Int32); inline;
    function CStr: PUTF8Char; inline;
    procedure Append(const AStr: PUTF8Char; const AStrEnd: PUTF8Char = nil); inline;
    procedure Appendf(const AFmt: PUTF8Char); inline;
  end; 

  // [Internal] Key+Value for ImGuiStorage
  TImGuiStoragePair = record
  public
    Key: TImGuiID; 
    A0: record case Byte of
          0: (ValI: Int32);
          1: (ValF: Single);
          2: (ValP: Pointer);
        end; 
  public
    // Initialize with default values
    procedure Initialize; inline;
  end; 

  // Helper: Key->Value storage
  // Typically you don't have to worry about this since a storage is held within each Window.
  // We use it to e.g. store collapse state for a tree (Int 0/1)
  // This is optimized for efficient lookup (dichotomy into a contiguous buffer) and rare insertion (typically tied to user interactions aka max once a frame)
  // You can use it as custom user storage for temporary values. Declare your own storage if, for example:
  // - You want to manipulate the open/close state of a particular sub-tree in your interface (tree node uses Int 0/1 to store their state).
  // - You want to store custom debug data easily without adding or editing structures in your code (probably not efficient, but convenient)
  // Types are NOT stored, so it is up to you to make sure your Key don't collide with different types.
  TImGuiStorage = record
  public
    // [Internal]
    Data: TImVector<TImGuiStoragePair>; 
  public
    // Initialize with default values
    procedure Initialize; inline;

    // - Get***() functions find pair, never add/allocate. Pairs are sorted so a query is O(log N)
    // - Set***() functions find pair, insertion on demand if missing.
    // - Sorted insertion is costly, paid once. A typical frame shouldn't need to insert any new pair.
    procedure Clear; inline;
    function GetInt(const AKey: TImGuiID; const ADefaultVal: Int32 = 0): Int32; inline;
    procedure SetInt(const AKey: TImGuiID; const AVal: Int32); inline;
    function GetBool(const AKey: TImGuiID; const ADefaultVal: Boolean = false): Boolean; inline;
    procedure SetBool(const AKey: TImGuiID; const AVal: Boolean); inline;
    function GetFloat(const AKey: TImGuiID; const ADefaultVal: Single = 0.0): Single; inline;
    procedure SetFloat(const AKey: TImGuiID; const AVal: Single); inline;

    // default_val is NULL
    function GetVoidPtr(const AKey: TImGuiID): Pointer; inline;
    procedure SetVoidPtr(const AKey: TImGuiID; const AVal: Pointer); inline;

    // - Get***Ref() functions finds pair, insert on demand if missing, return pointer. Useful if you intend to do Get+Set.
    // - References are only valid until a new value is added to the storage. Calling a Set***() function or a Get***Ref() function invalidates the pointer.
    // - A typical use case where this is convenient for quick hacking (e.g. add storage during a live Edit&Continue session if you can't modify existing struct)
    //      float* pvar = ImGui::GetFloatRef(key); ImGui::SliderFloat("var", pvar, 0, 100.0f); some_var += *pvar;
    function GetIntRef(const AKey: TImGuiID; const ADefaultVal: Int32 = 0): PInt32; inline;
    function GetBoolRef(const AKey: TImGuiID; const ADefaultVal: Boolean = false): PBoolean; inline;
    function GetFloatRef(const AKey: TImGuiID; const ADefaultVal: Single = 0.0): PSingle; inline;
    function GetVoidPtrRef(const AKey: TImGuiID; const ADefaultVal: Pointer = nil): PPointer; inline;

    // Advanced: for quicker full rebuild of a storage (instead of an incremental one), you may add all your contents and then sort once.
    procedure BuildSortByKey; inline;

    // Obsolete: use on your own storage if you know only integer are being stored (open/close all tree nodes)
    procedure SetAllInt(const AVal: Int32); inline;
  end; 

  // Helper: Manually clip large list of items.
  // If you have lots evenly spaced items and you have random access to the list, you can perform coarse
  // clipping based on visibility to only submit items that are in view.
  // The clipper calculates the range of visible items and advance the cursor to compensate for the non-visible items we have skipped.
  // (Dear ImGui already clip items based on their bounds but: it needs to first layout the item to do so, and generally
  //  fetching/submitting your own data incurs additional cost. Coarse clipping using ImGuiListClipper allows you to easily
  //  scale using lists with tens of thousands of items without a problem)
  // Usage:
  //   ImGuiListClipper clipper;
  //   clipper.Begin(1000);         // We have 1000 elements, evenly spaced.
  //   while (clipper.Step())
  //       for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++)
  //           ImGui::Text("line number %d", i);
  // Generally what happens is:
  // - Clipper lets you process the first element (DisplayStart = 0, DisplayEnd = 1) regardless of it being visible or not.
  // - User code submit that one element.
  // - Clipper can measure the height of the first element
  // - Clipper calculate the actual range of elements to display based on the current clipping rectangle, position the cursor before the first visible element.
  // - User code submit visible elements.
  // - The clipper also handles various subtleties related to keyboard/gamepad navigation, wrapping etc.
  TImGuiListClipper = record
  public
    DisplayStart: Int32;           // First item to display, updated by each call to Step() 
    DisplayEnd: Int32;             // End of items to display (exclusive) 
    UserIndex: Int32;              // Helper storage for user convenience/code. Optional, and otherwise unused if you don't use it. 
    ItemsCount: Int32;             // [Internal] Number of items 
    ItemsHeight: Single;           // [Internal] Height of item after a first step and item submission can calculate it 
    Flags: TImGuiListClipperFlags; // [Internal] Flags, currently not yet well exposed. 
    StartPosY: Double;             // [Internal] Cursor position at the time of Begin() or after table frozen rows are all processed 
    StartSeekOffsetY: Double;      // [Internal] Account for frozen rows in a table and initial loss of precision in very large windows. 
    Ctx: PImGuiContext;            // [Internal] Parent UI context 
    TempData: Pointer;             // [Internal] Internal data 
  public
    // Initialize with default values
    procedure Initialize; inline;

    procedure &Begin(const AItemsCount: Int32; const AItemsHeight: Single = -1.0); inline;

    // Automatically called on the last call of Step() that returns false.
    procedure &End; inline;

    // Call until it returns false. The DisplayStart/DisplayEnd fields will be set and you can process/draw those items.
    function Step: Boolean; inline;

    // Call IncludeItemByIndex() or IncludeItemsByIndex() *BEFORE* first call to Step() if you need a range of items to not be clipped, regardless of their visibility.
    // (Due to alignment / padding of certain items it is possible that an extra item may be included on either end of the display range).
    procedure IncludeItemByIndex(const AItemIndex: Int32); inline;

    // item_end is exclusive e.g. use (42, 42+1) to make item 42 never clipped.
    procedure IncludeItemsByIndex(const AItemBegin, AItemEnd: Int32); inline;

    // Seek cursor toward given item. This is automatically called while stepping.
    // - The only reason to call this is: you can use ImGuiListClipper::Begin(INT_MAX) if you don't know item count ahead of time.
    // - In this case, after all steps are done, you'll want to call SeekCursorForItem(item_count).
    procedure SeekCursorForItem(const AItemIndex: Int32); inline;
  end; 

  // Selection request item
  TImGuiSelectionRequest = record
  public
    //------------------------------------------// BeginMultiSelect / EndMultiSelect
    &Type: TImGuiSelectionRequestType;       //  ms:w, app:r     /  ms:w, app:r   // Request type. You'll most often receive 1 Clear + 1 SetRange with a single-item range. 
    Selected: Boolean;                       //  ms:w, app:r     /  ms:w, app:r   // Parameter for SetAll/SetRange requests (true = select, false = unselect) 
    RangeDirection: UTF8Char;                //                  /  ms:w  app:r   // Parameter for SetRange request: +1 when RangeFirstItem comes before RangeLastItem, -1 otherwise. Useful if you want to preserve selection order on a backward Shift+Click. 
    RangeFirstItem: TImGuiSelectionUserData; //                  /  ms:w, app:r   // Parameter for SetRange request (this is generally == RangeSrcItem when shift selecting from top to bottom). 
    RangeLastItem: TImGuiSelectionUserData;  //                  /  ms:w, app:r   // Parameter for SetRange request (this is generally == RangeSrcItem when shift selecting from bottom to top). Inclusive! 
  public
    // Initialize with default values
    procedure Initialize; inline;
  end; 

  // Main IO structure returned by BeginMultiSelect()/EndMultiSelect().
  // This mainly contains a list of selection requests.
  // - Use 'Demo->Tools->Debug Log->Selection' to see requests as they happen.
  // - Some fields are only useful if your list is dynamic and allows deletion (getting post-deletion focus/state right is shown in the demo)
  // - Below: who reads/writes each fields? 'r'=read, 'w'=write, 'ms'=multi-select code, 'app'=application/user code.
  TImGuiMultiSelectIO = record
  public
    //------------------------------------------// BeginMultiSelect / EndMultiSelect
    Requests: TImVector<TImGuiSelectionRequest>; //  ms:w, app:r     /  ms:w  app:r   // Requests to apply to your selection data. 
    RangeSrcItem: TImGuiSelectionUserData;       //  ms:w  app:r     /                // (If using clipper) Begin: Source item (often the first selected item) must never be clipped: use clipper.IncludeItemByIndex() to ensure it is submitted. 
    NavIdItem: TImGuiSelectionUserData;          //  ms:w, app:r     /                // (If using deletion) Last known SetNextItemSelectionUserData() value for NavId (if part of submitted items). 
    NavIdSelected: Boolean;                      //  ms:w, app:r     /        app:r   // (If using deletion) Last known selection state for NavId (if part of submitted items). 
    RangeSrcReset: Boolean;                      //        app:w     /  ms:r          // (If using deletion) Set before EndMultiSelect() to reset ResetSrcItem (e.g. if deleted selection). 
    ItemsCount: Int32;                           //  ms:w, app:r     /        app:r   // 'int items_count' parameter to BeginMultiSelect() is copied here for convenience, allowing simpler calls to your ApplyRequests handler. Not used internally. 
  public
    // Initialize with default values
    procedure Initialize; inline;
  end; 

  // Optional helper to store multi-selection state + apply multi-selection requests.
  // - Used by our demos and provided as a convenience to easily implement basic multi-selection.
  // - Iterate selection with 'void* it = NULL; ImGuiID id; while (selection.GetNextSelectedItem(&it, &id)) { ... }'
  //   Or you can check 'if (Contains(id)) { ... }' for each possible object if their number is not too high to iterate.
  // - USING THIS IS NOT MANDATORY. This is only a helper and not a required API.
  // To store a multi-selection, in your application you could:
  // - Use this helper as a convenience. We use our simple key->value ImGuiStorage as a std::set<ImGuiID> replacement.
  // - Use your own external storage: e.g. std::set<MyObjectId>, std::vector<MyObjectId>, interval trees, intrusively stored selection etc.
  // In ImGuiSelectionBasicStorage we:
  // - always use indices in the multi-selection API (passed to SetNextItemSelectionUserData(), retrieved in ImGuiMultiSelectIO)
  // - use the AdapterIndexToStorageId() indirection layer to abstract how persistent selection data is derived from an index.
  // - use decently optimized logic to allow queries and insertion of very large selection sets.
  // - do not preserve selection order.
  // Many combinations are possible depending on how you prefer to store your items and how you prefer to store your selection.
  // Large applications are likely to eventually want to get rid of this indirection layer and do their own thing.
  // See https://github.com/ocornut/imgui/wiki/Multi-Select for details and pseudo-code using this helper.
  TImGuiSelectionBasicStorage = record
  public
    // Members
    Size: Int32;                                                                   //          // Number of selected items, maintained by this helper. 
    PreserveOrder: Boolean;                                                        // = false  // GetNextSelectedItem() will return ordered selection (currently implemented by two additional sorts of selection. Could be improved) 
    UserData: Pointer;                                                             // = NULL   // User data for use by adapter function        // e.g. selection.UserData = (void*)my_items; 
    AdapterIndexToStorageId: function(self: Pointer; idx: Int32): _ImGuiID; cdecl; // e.g. selection.AdapterIndexToStorageId = [](ImGuiSelectionBasicStorage* self, int idx) { return ((MyItems**)self->UserData)[idx]->ID; }; 
    SelectionOrder: Int32;                                                         // [Internal] Increasing counter to store selection order 
    Storage: TImGuiStorage;                                                        // [Internal] Selection set. Think of this as similar to e.g. std::set<ImGuiID>. Prefer not accessing directly: iterate with GetNextSelectedItem(). 
  public
    // Initialize with default values
    procedure Initialize; inline;

    // Apply selection requests coming from BeginMultiSelect() and EndMultiSelect() functions. It uses 'items_count' passed to BeginMultiSelect()
    procedure ApplyRequests(const AMsIo: PImGuiMultiSelectIO); inline;

    // Query if an item id is in selection.
    function Contains(const AId: TImGuiID): Boolean; inline;

    // Clear selection
    procedure Clear; inline;

    // Swap two selections
    procedure Swap(const AR: PImGuiSelectionBasicStorage); inline;

    // Add/remove an item from selection (generally done by ApplyRequests() function)
    procedure SetItemSelected(const AId: TImGuiID; const ASelected: Boolean); inline;

    // Iterate selection with 'void* it = NULL; ImGuiID id; while (selection.GetNextSelectedItem(&it, &id)) { ... }'
    function GetNextSelectedItem(const AOpaqueIt: PPointer; const AOutId: PImGuiID): Boolean; inline;

    // Convert index to item id based on provided adapter.
    function GetStorageIdFromIndex(const AIdx: Int32): TImGuiID; inline;
  end; 

  // Optional helper to apply multi-selection requests to existing randomly accessible storage.
  // Convenient if you want to quickly wire multi-select API on e.g. an array of bool or items storing their own selection state.
  TImGuiSelectionExternalStorage = record
  public
    // Members
    UserData: Pointer;                                                                      // User data for use by adapter function                                // e.g. selection.UserData = (void*)my_items; 
    AdapterSetItemSelected: procedure(self: Pointer; idx: Int32; selected: Boolean); cdecl; // e.g. AdapterSetItemSelected = [](ImGuiSelectionExternalStorage* self, int idx, bool selected) { ((MyItems**)self->UserData)[idx]->Selected = selected; } 
  public
    // Initialize with default values
    procedure Initialize; inline;

    // Apply selection requests by using AdapterSetItemSelected() calls
    procedure ApplyRequests(const AMsIo: PImGuiMultiSelectIO); inline;
  end; 

  // Typically, 1 command = 1 GPU draw call (unless command is a callback)
  // - VtxOffset: When 'io.BackendFlags & ImGuiBackendFlags_RendererHasVtxOffset' is enabled,
  //   this fields allow us to render meshes larger than 64K vertices while keeping 16-bit indices.
  //   Backends made for <1.71. will typically ignore the VtxOffset fields.
  // - The ClipRect/TexRef/VtxOffset fields must be contiguous as we memcmp() them together (this is asserted for).
  TImDrawCmd = record
  public
    ClipRect: TVector4;            // 4*4  // Clipping rectangle (x1, y1, x2, y2). Subtract ImDrawData->DisplayPos to get clipping rectangle in "viewport" coordinates 
    TexRef: TImTextureRef;         // 16   // Reference to a font/texture atlas (where backend called ImTextureData::SetTexID()) or to a user-provided texture ID (via e.g. ImGui::Image() calls). Both will lead to a ImTextureID value. 
    VtxOffset: UInt32;             // 4    // Start offset in vertex buffer. ImGuiBackendFlags_RendererHasVtxOffset: always 0, otherwise may be >0 to support meshes larger than 64K vertices with 16-bit indices. 
    IdxOffset: UInt32;             // 4    // Start offset in index buffer. 
    ElemCount: UInt32;             // 4    // Number of indices (multiple of 3) to be rendered as triangles. Vertices are stored in the callee ImDrawList's vtx_buffer[] array, indices in idx_buffer[]. 
    UserCallback: TImDrawCallback; // 4-8  // If != NULL, call the function instead of rendering the vertices. clip_rect and texture_id will be set normally. 
    UserCallbackData: Pointer;     // 4-8  // Callback user data (when UserCallback != NULL). If called AddCallback() with size == 0, this is a copy of the AddCallback() argument. If called AddCallback() with size > 0, this is pointing to a buffer where data is stored. 
    UserCallbackDataSize: Int32;   // 4 // Size of callback user data when using storage, otherwise 0. 
    UserCallbackDataOffset: Int32; // 4 // [Internal] Offset of callback user data when using storage, otherwise -1. 
  public
    // Initialize with default values
    procedure Initialize; inline;

    // Since 1.83: returns ImTextureID associated with this draw call. Warning: DO NOT assume this is always same as 'TextureId' (we will change this function for an upcoming feature)
    // Since 1.92: removed ImDrawCmd::TextureId field, the getter function must be used!
    // == (TexRef._TexData ? TexRef._TexData->TexID : TexRef._TexID)
    function GetTexID: TImTextureID; inline;
  end; 

  TImDrawVert = record
  public
    Pos: TVector2; 
    Uv: TVector2; 
    Col: UInt32; 
  public
    // Initialize with default values
    procedure Initialize; inline;
  end; 

  // [Internal] For use by ImDrawList
  TImDrawCmdHeader = record
  public
    ClipRect: TVector4; 
    TexRef: TImTextureRef; 
    VtxOffset: UInt32; 
  public
    // Initialize with default values
    procedure Initialize; inline;
  end; 

  // [Internal] For use by ImDrawListSplitter
  TImDrawChannel = record
  public
    CmdBuffer: TImVector<TImDrawCmd>; 
    IdxBuffer: TImVector<UInt16>; 
  public
    // Initialize with default values
    procedure Initialize; inline;
  end; 

  // Split/Merge functions are used to split the draw list into different layers which can be drawn into out of order.
  // This is used by the Columns/Tables API, so items of each column can be batched together in a same draw call.
  TImDrawListSplitter = record
  public
    Current: Int32;                      // Current channel number (0) 
    Count: Int32;                        // Number of active channels (1+) 
    Channels: TImVector<TImDrawChannel>; // Draw channels (not resized down so _Count might be < Channels.Size) 
  public
    // Initialize with default values
    procedure Initialize; inline;

    // Do not clear Channels[] so our allocations are reused next frame
    procedure Clear; inline;
    procedure ClearFreeMemory; inline;
    procedure Split(const ADrawList: PImDrawList; const ACount: Int32); inline;
    procedure Merge(const ADrawList: PImDrawList); inline;
    procedure SetCurrentChannel(const ADrawList: PImDrawList; const AChannelIdx: Int32); inline;
  end; 

  // Draw command list
  // This is the low-level list of polygons that ImGui:: functions are filling. At the end of the frame,
  // all command lists are passed to your ImGuiIO::RenderDrawListFn function for rendering.
  // Each dear imgui window contains its own ImDrawList. You can use ImGui::GetWindowDrawList() to
  // access the current window draw list and draw custom primitives.
  // You can interleave normal ImGui:: calls and adding primitives to the current draw list.
  // In single viewport mode, top-left is == GetMainViewport()->Pos (generally 0,0), bottom-right is == GetMainViewport()->Pos+Size (generally io.DisplaySize).
  // You are totally free to apply whatever transformation matrix you want to the data (depending on the use of the transformation you may want to apply it to ClipRect as well!)
  // Important: Primitives are always added to the list and not culled (culling is done at higher-level by ImGui:: functions), if you use this API a lot consider coarse culling your drawn objects.
  TImDrawList = record
  public
    // This is what you have to render
    CmdBuffer: TImVector<TImDrawCmd>;       // Draw commands. Typically 1 command = 1 GPU draw call, unless the command is a callback. 
    IdxBuffer: TImVector<UInt16>;           // Index buffer. Each command consume ImDrawCmd::ElemCount of those 
    VtxBuffer: TImVector<TImDrawVert>;      // Vertex buffer. 
    Flags: TImDrawListFlags;                // Flags, you may poke into these to adjust anti-aliasing settings per-primitive. 
    // [Internal, used while building lists]
    VtxCurrentIdx: UInt32;                  // [Internal] generally == VtxBuffer.Size unless we are past 64K vertices, in which case this gets reset to 0. 
    Data: PImDrawListSharedData;            // Pointer to shared draw data (you can use ImGui::GetDrawListSharedData() to get the one from current ImGui context) 
    VtxWritePtr: PImDrawVert;               // [Internal] point within VtxBuffer.Data after each add command (to avoid using the ImVector<> operators too much) 
    IdxWritePtr: PImDrawIdx;                // [Internal] point within IdxBuffer.Data after each add command (to avoid using the ImVector<> operators too much) 
    Path: TImVector<TVector2>;              // [Internal] current path building 
    CmdHeader: TImDrawCmdHeader;            // [Internal] template of active commands. Fields should match those of CmdBuffer.back(). 
    Splitter: TImDrawListSplitter;          // [Internal] for channels api (note: prefer using your own persistent instance of ImDrawListSplitter!) 
    ClipRectStack: TImVector<TVector4>;     // [Internal] 
    TextureStack: TImVector<TImTextureRef>; // [Internal] 
    CallbacksDataBuf: TImVector<UInt8>;     // [Internal] 
    FringeScale: Single;                    // [Internal] anti-alias fringe is scaled by this value, this helps to keep things sharp while zooming at vertex buffer content 
    OwnerName: PUTF8Char;                   // Pointer to owner window's name for debugging 
  public
    // Initialize with default values
    procedure Initialize; inline;

    // Render-level scissoring. This is passed down to your render function but not used for CPU-side coarse clipping. Prefer using higher-level ImGui::PushClipRect() to affect logic (hit-testing and widget culling)
    procedure PushClipRect(const AClipRectMin, AClipRectMax: TVector2; const AIntersectWithCurrentClipRect: Boolean = false); inline;
    procedure PushClipRectFullScreen; inline;
    procedure PopClipRect; inline;
    procedure PushTexture(const ATexRef: TImTextureRef); inline;
    procedure PopTexture; inline;
    function GetClipRectMin: TVector2; inline;
    function GetClipRectMax: TVector2; inline;

    // Primitives
    // - Filled shapes must always use clockwise winding order. The anti-aliasing fringe depends on it. Counter-clockwise shapes will have "inward" anti-aliasing.
    // - For rectangular primitives, "p_min" and "p_max" represent the upper-left and lower-right corners.
    // - For circle primitives, use "num_segments == 0" to automatically calculate tessellation (preferred).
    //   In older versions (until Dear ImGui 1.77) the AddCircle functions defaulted to num_segments == 12.
    //   In future versions we will use textures to provide cheaper and higher-quality circles.
    //   Use AddNgon() and AddNgonFilled() functions if you need to guarantee a specific number of sides.
    // Implied thickness = 1.0f
    procedure AddLine(const AP1, AP2: TVector2; const ACol: UInt32); overload; inline;
    procedure AddLine(const AP1, AP2: TVector2; const ACol: UInt32; const AThickness: Single = 1.0); overload; inline;

    // Implied thickness = 1.0f
    procedure AddLineH(const AMinX, AMaxX, AY: Single; const ACol: UInt32); overload; inline;
    procedure AddLineH(const AMinX, AMaxX, AY: Single; const ACol: UInt32; const AThickness: Single = 1.0); overload; inline;

    // Implied thickness = 1.0f
    procedure AddLineV(const AX, AMinY, AMaxY: Single; const ACol: UInt32); overload; inline;
    procedure AddLineV(const AX, AMinY, AMaxY: Single; const ACol: UInt32; const AThickness: Single = 1.0); overload; inline;

    // Implied rounding = 0.0f, thickness = 1.0f, flags = 0
    procedure AddRect(const APMin, APMax: TVector2; const ACol: UInt32); overload; inline;

    // a: upper-left, b: lower-right (== upper-left + size)
    procedure AddRect(const APMin, APMax: TVector2; const ACol: UInt32; const ARounding: Single = 0.0; 
      const AThickness: Single = 1.0; const AFlags: TImDrawFlags = []); overload; inline;

    // Implied rounding = 0.0f, flags = 0
    procedure AddRectFilled(const APMin, APMax: TVector2; const ACol: UInt32); overload; inline;

    // a: upper-left, b: lower-right (== upper-left + size)
    procedure AddRectFilled(const APMin, APMax: TVector2; const ACol: UInt32; const ARounding: Single = 0.0; 
      const AFlags: TImDrawFlags = []); overload; inline;
    procedure AddRectFilledMultiColor(const APMin, APMax: TVector2; const AColUprLeft, 
      AColUprRight, AColBotRight, AColBotLeft: UInt32); inline;

    // Implied thickness = 1.0f
    procedure AddQuad(const AP1, AP2, AP3, AP4: TVector2; const ACol: UInt32); overload; inline;
    procedure AddQuad(const AP1, AP2, AP3, AP4: TVector2; const ACol: UInt32; const AThickness: Single = 1.0); overload; inline;
    procedure AddQuadFilled(const AP1, AP2, AP3, AP4: TVector2; const ACol: UInt32); inline;

    // Implied thickness = 1.0f
    procedure AddTriangle(const AP1, AP2, AP3: TVector2; const ACol: UInt32); overload; inline;
    procedure AddTriangle(const AP1, AP2, AP3: TVector2; const ACol: UInt32; const AThickness: Single = 1.0); overload; inline;
    procedure AddTriangleFilled(const AP1, AP2, AP3: TVector2; const ACol: UInt32); inline;

    // Implied num_segments = 0, thickness = 1.0f
    procedure AddCircle(const ACenter: TVector2; const ARadius: Single; const ACol: UInt32); overload; inline;
    procedure AddCircle(const ACenter: TVector2; const ARadius: Single; const ACol: UInt32; 
      const ANumSegments: Int32 = 0; const AThickness: Single = 1.0); overload; inline;
    procedure AddCircleFilled(const ACenter: TVector2; const ARadius: Single; const ACol: UInt32; 
      const ANumSegments: Int32 = 0); inline;

    // Implied thickness = 1.0f
    procedure AddNgon(const ACenter: TVector2; const ARadius: Single; const ACol: UInt32; 
      const ANumSegments: Int32); overload; inline;
    procedure AddNgon(const ACenter: TVector2; const ARadius: Single; const ACol: UInt32; 
      const ANumSegments: Int32; const AThickness: Single = 1.0); overload; inline;
    procedure AddNgonFilled(const ACenter: TVector2; const ARadius: Single; const ACol: UInt32; 
      const ANumSegments: Int32); inline;

    // Implied rot = 0.0f, num_segments = 0, thickness = 1.0f
    procedure AddEllipse(const ACenter, ARadius: TVector2; const ACol: UInt32); overload; inline;
    procedure AddEllipse(const ACenter, ARadius: TVector2; const ACol: UInt32; const ARot: Single = 0.0; 
      const ANumSegments: Int32 = 0; const AThickness: Single = 1.0); overload; inline;

    // Implied rot = 0.0f, num_segments = 0
    procedure AddEllipseFilled(const ACenter, ARadius: TVector2; const ACol: UInt32); overload; inline;
    procedure AddEllipseFilled(const ACenter, ARadius: TVector2; const ACol: UInt32; 
      const ARot: Single = 0.0; const ANumSegments: Int32 = 0); overload; inline;

    // Implied text_end = NULL
    procedure AddText(const APos: TVector2; const ACol: UInt32; const ATextBegin: PUTF8Char); overload; inline;
    procedure AddText(const APos: TVector2; const ACol: UInt32; const ATextBegin: PUTF8Char; 
      const ATextEnd: PUTF8Char = nil); overload; inline;

    // Implied text_end = NULL, wrap_width = 0.0f, cpu_fine_clip_rect = NULL
    procedure AddText(const AFont: PImFont; const AFontSize: Single; const APos: TVector2; 
      const ACol: UInt32; const ATextBegin: PUTF8Char); overload; inline;
    procedure AddText(const AFont: PImFont; const AFontSize: Single; const APos: TVector2; 
      const ACol: UInt32; const ATextBegin: PUTF8Char; const ATextEnd: PUTF8Char = nil; 
      const AWrapWidth: Single = 0.0; const ACpuFineClipRect: PVector4 = nil); overload; inline;

    // Cubic Bezier (4 control points)
    procedure AddBezierCubic(const AP1, AP2, AP3, AP4: TVector2; const ACol: UInt32; 
      const AThickness: Single; const ANumSegments: Int32 = 0); inline;

    // Quadratic Bezier (3 control points)
    procedure AddBezierQuadratic(const AP1, AP2, AP3: TVector2; const ACol: UInt32; 
      const AThickness: Single; const ANumSegments: Int32 = 0); inline;

    // General polygon
    // - Only simple polygons are supported by filling functions (no self-intersections, no holes).
    // - Concave polygon fill is more expensive than convex one: it has O(N^2) complexity. Provided as a convenience for the user but not used by the main library.
    procedure AddPolyline(const APoints: PVector2; const ANumPoints: Int32; const ACol: UInt32; 
      const AThickness: Single; const AFlags: TImDrawFlags = []); inline;
    procedure AddConvexPolyFilled(const APoints: PVector2; const ANumPoints: Int32; 
      const ACol: UInt32); inline;
    procedure AddConcavePolyFilled(const APoints: PVector2; const ANumPoints: Int32; 
      const ACol: UInt32); inline;

    // Image primitives
    // - Read FAQ to understand what ImTextureID/ImTextureRef are.
    // - "p_min" and "p_max" represent the upper-left and lower-right corners of the rectangle.
    // - "uv_min" and "uv_max" represent the normalized texture coordinates to use for those corners. Using (0,0)->(1,1) texture coordinates will generally display the entire texture.
    // Implied uv_min = ImVec2(0, 0), uv_max = ImVec2(1, 1), col = IM_COL32_WHITE
    procedure AddImage(const ATexRef: TImTextureRef; const APMin, APMax: TVector2); overload; inline;
    procedure AddImage(const ATexRef: TImTextureRef; const APMin, APMax, AUvMin, 
      AUvMax: TVector2; const ACol: UInt32 = IM_COL32_WHITE); overload; inline;
    procedure AddImage(const ATexRef: TImTextureRef; const APMin, APMax, AUvMin: TVector2; const ACol: UInt32 = IM_COL32_WHITE); overload; inline;

    // Implied uv1 = ImVec2(0, 0), uv2 = ImVec2(1, 0), uv3 = ImVec2(1, 1), uv4 = ImVec2(0, 1), col = IM_COL32_WHITE
    procedure AddImageQuad(const ATexRef: TImTextureRef; const AP1, AP2, AP3, AP4: TVector2); overload; inline;
    procedure AddImageQuad(const ATexRef: TImTextureRef; const AP1, AP2, AP3, AP4, 
      AUv1, AUv2, AUv3, AUv4: TVector2; const ACol: UInt32 = IM_COL32_WHITE); overload; inline;
    procedure AddImageQuad(const ATexRef: TImTextureRef; const AP1, AP2, AP3, AP4,
      AUv1: TVector2; const ACol: UInt32 = IM_COL32_WHITE); overload; inline;
    procedure AddImageQuad(const ATexRef: TImTextureRef; const AP1, AP2, AP3, AP4,
      AUv1, AUv2: TVector2; const ACol: UInt32 = IM_COL32_WHITE); overload; inline;
    procedure AddImageQuad(const ATexRef: TImTextureRef; const AP1, AP2, AP3, AP4,
      AUv1, AUv2, AUv3: TVector2; const ACol: UInt32 = IM_COL32_WHITE); overload; inline;
    procedure AddImageRounded(const ATexRef: TImTextureRef; const APMin, APMax, 
      AUvMin, AUvMax: TVector2; const ACol: UInt32; const ARounding: Single; const AFlags: TImDrawFlags = []); inline;

    // Stateful path API, add points then finish with PathFillConvex() or PathStroke()
    // - Important: filled shapes must always use clockwise winding order! The anti-aliasing fringe depends on it. Counter-clockwise shapes will have "inward" anti-aliasing.
    //   so e.g. 'PathArcTo(center, radius, PI * -0.5f, PI)' is ok, whereas 'PathArcTo(center, radius, PI, PI * -0.5f)' won't have correct anti-aliasing when followed by PathFillConvex().
    procedure PathClear; inline;
    procedure PathLineTo(const APos: TVector2); inline;
    procedure PathLineToMergeDuplicate(const APos: TVector2); inline;
    procedure PathFillConvex(const ACol: UInt32); inline;
    procedure PathFillConcave(const ACol: UInt32); inline;
    procedure PathStroke(const ACol: UInt32; const AThickness: Single = 1.0; const AFlags: TImDrawFlags = []); inline;
    procedure PathArcTo(const ACenter: TVector2; const ARadius, AAMin, AAMax: Single; 
      const ANumSegments: Int32 = 0); inline;

    // Use precomputed angles for a 12 steps circle
    procedure PathArcToFast(const ACenter: TVector2; const ARadius: Single; const AAMinOf12, 
      AAMaxOf12: Int32); inline;

    // Implied num_segments = 0
    procedure PathEllipticalArcTo(const ACenter, ARadius: TVector2; const ARot, 
      AAMin, AAMax: Single); overload; inline;

    // Ellipse
    procedure PathEllipticalArcTo(const ACenter, ARadius: TVector2; const ARot, 
      AAMin, AAMax: Single; const ANumSegments: Int32 = 0); overload; inline;

    // Cubic Bezier (4 control points)
    procedure PathBezierCubicCurveTo(const AP2, AP3, AP4: TVector2; const ANumSegments: Int32 = 0); inline;

    // Quadratic Bezier (3 control points)
    procedure PathBezierQuadraticCurveTo(const AP2, AP3: TVector2; const ANumSegments: Int32 = 0); inline;
    procedure PathRect(const ARectMin, ARectMax: TVector2; const ARounding: Single = 0.0; 
      const AFlags: TImDrawFlags = []); inline;

    // Advanced: Draw Callbacks
    // - May be used to alter render state (change sampler, blending, current shader). May be used to emit custom rendering commands (difficult to do correctly, but possible).
    // - Use special GetPlatformIO().DrawCallback_ResetRenderState callback to instruct backend to reset its render state to the default.
    // - See other standard callbacks in GetPlatformIO(), which may or not be supported by your backend.
    // - Your rendering loop must check for 'UserCallback' in ImDrawCmd and call the function instead of rendering triangles. All standard backends are honoring this.
    // - For some backends, the callback may access selected render-states exposed by the backend in a ImGui_ImplXXXX_RenderState structure pointed to by platform_io.Renderer_RenderState.
    // - IMPORTANT: please be mindful of the different level of indirection between using size==0 (copying argument) and using size>0 (copying pointed data into a buffer).
    //   - If userdata_size == 0: we copy/store the 'userdata' argument as-is. It will be available unmodified in ImDrawCmd::UserCallbackData during render.
    //   - If userdata_size > 0,  we copy/store 'userdata_size' bytes pointed to by 'userdata'. We store them in a buffer stored inside the drawlist. ImDrawCmd::UserCallbackData will point inside that buffer so you have to retrieve data from there. Your callback may need to use ImDrawCmd::UserCallbackDataSize if you expect dynamically-sized data.
    //   - Support for userdata_size > 0 was added in v1.91.4, October 2024. So earlier code always only allowed to copy/store a simple void*.
    // Implied userdata = NULL, userdata_size = 0
    procedure AddCallback(const ACallback: TImDrawCallback); overload; inline;
    procedure AddCallback(const ACallback: TImDrawCallback; const AUserdata: Pointer = nil; 
      const AUserdataSize: NativeUInt = 0); overload; inline;

    // Advanced: Miscellaneous
    // This is useful if you need to forcefully create a new draw call (to allow for dependent rendering / blending). Otherwise primitives are merged into the same draw-call as much as possible
    procedure AddDrawCmd; inline;

    // Create a clone of the CmdBuffer/IdxBuffer/VtxBuffer. For multi-threaded rendering, consider using `imgui_threaded_rendering` from https://github.com/ocornut/imgui_club instead.
    function CloneOutput: PImDrawList; inline;

    // Advanced: Channels
    // - Use to split render into layers. By switching channels to can render out-of-order (e.g. submit FG primitives before BG primitives)
    // - Use to minimize draw calls (e.g. if going back-and-forth between multiple clipping rectangles, prefer to append into separate channels then merge at the end)
    // - This API shouldn't have been in ImDrawList in the first place!
    //   Prefer using your own persistent instance of ImDrawListSplitter as you can stack them.
    //   Using the ImDrawList::ChannelsXXXX you cannot stack a split over another.
    procedure ChannelsSplit(const ACount: Int32); inline;
    procedure ChannelsMerge; inline;
    procedure ChannelsSetCurrent(const AN: Int32); inline;

    // Advanced: Primitives allocations
    // - We render triangles (three vertices)
    // - All primitives needs to be reserved via PrimReserve() beforehand.
    procedure PrimReserve(const AIdxCount, AVtxCount: Int32); inline;
    procedure PrimUnreserve(const AIdxCount, AVtxCount: Int32); inline;

    // Axis aligned rectangle (composed of two triangles)
    procedure PrimRect(const AA, AB: TVector2; const ACol: UInt32); inline;
    procedure PrimRectUV(const AA, AB, AUvA, AUvB: TVector2; const ACol: UInt32); inline;
    procedure PrimQuadUV(const AA, AB, AC, AD, AUvA, AUvB, AUvC, AUvD: TVector2; 
      const ACol: UInt32); inline;
    procedure PrimWriteVtx(const APos, AUv: TVector2; const ACol: UInt32); inline;
    procedure PrimWriteIdx(const AIdx: TImDrawIdx); inline;

    // Write vertex with unique index
    procedure PrimVtx(const APos, AUv: TVector2; const ACol: UInt32); inline;

    // [Internal helpers]
    procedure SetDrawListSharedData(const AData: PImDrawListSharedData); inline;
    procedure ResetForNewFrame; inline;
    procedure ClearFreeMemory; inline;
    procedure PopUnusedDrawCmd; inline;
    procedure TryMergeDrawCmds; inline;
    procedure OnChangedClipRect; inline;
    procedure OnChangedTexture; inline;
    procedure OnChangedVtxOffset; inline;
    procedure SetTexture(const ATexRef: TImTextureRef); inline;
    function CalcCircleAutoSegmentCount(const ARadius: Single): Int32; inline;
    procedure PathArcToFastEx(const ACenter: TVector2; const ARadius: Single; const AAMinSample, 
      AAMaxSample, AAStep: Int32); inline;
    procedure PathArcToN(const ACenter: TVector2; const ARadius, AAMin, AAMax: Single; 
      const ANumSegments: Int32); inline;
  end; 

  // All draw data to render a Dear ImGui frame
  // (NB: the style and the naming convention here is a little inconsistent, we currently preserve them for backward compatibility purpose,
  // as this is one of the oldest structure exposed by the library! Basically, ImDrawList == CmdList)
  TImDrawData = record
  public
    Valid: Boolean;                      // Only valid after Render() is called and before the next NewFrame() is called. 
    CmdListsCount: Int32;                // == CmdLists.Size. (OBSOLETE: exists for legacy reasons). Number of ImDrawList* to render. 
    TotalIdxCount: Int32;                // For convenience, sum of all ImDrawList's IdxBuffer.Size 
    TotalVtxCount: Int32;                // For convenience, sum of all ImDrawList's VtxBuffer.Size 
    CmdLists: TImVector<TImDrawListPtr>; // Array of ImDrawList* to render. The ImDrawLists are owned by ImGuiContext and only pointed to from here. 
    DisplayPos: TVector2;                // Top-left position of the viewport to render (== top-left of the orthogonal projection matrix to use) (== GetMainViewport()->Pos for the main viewport, == (0.0) in most single-viewport applications) 
    DisplaySize: TVector2;               // Size of the viewport to render (== GetMainViewport()->Size for the main viewport, == io.DisplaySize in most single-viewport applications) 
    FramebufferScale: TVector2;          // Amount of pixels for each unit of DisplaySize. Copied from viewport->FramebufferScale (== io.DisplayFramebufferScale for main viewport). Generally (1,1) on normal display, (2,2) on OSX with Retina display. 
    OwnerViewport: PImGuiViewport;       // Viewport carrying the ImDrawData instance, might be of use to the renderer (generally not). 
    Textures: PImVectorImTextureDataPtr; // List of textures to update. Most of the times the list is shared by all ImDrawData, has only 1 texture and it doesn't need any update. This almost always points to ImGui::GetPlatformIO().Textures[]. May be overridden or set to NULL if you want to manually update textures. 
  public
    // Initialize with default values
    procedure Initialize; inline;

    procedure Clear; inline;

    // Helper to add an external draw list into an existing ImDrawData.
    procedure AddDrawList(const ADrawList: PImDrawList); inline;

    // Helper to convert all buffers from indexed to non-indexed, in case you cannot render indexed. Note: this is slow and most likely a waste of resources. Always prefer indexed rendering!
    procedure DeIndexAllBuffers; inline;

    // Helper to scale the ClipRect field of each ImDrawCmd. Use if your final output buffer is at a different scale than Dear ImGui expects, or if there is a difference between your window resolution and framebuffer resolution.
    procedure ScaleClipRects(const AFbScale: TVector2); inline;
  end; 

  // Coordinates of a rectangle within a texture.
  // When a texture is in ImTextureStatus_WantUpdates state, we provide a list of individual rectangles to copy to the graphics system.
  // You may use ImTextureData::Updates[] for the list, or ImTextureData::UpdateBox for a single bounding box.
  TImTextureRect = record
  public
    X: UInt16; // Upper-left coordinates of rectangle to update 
    Y: UInt16; // Upper-left coordinates of rectangle to update 
    W: UInt16; // Size of rectangle to update (in pixels) 
    H: UInt16; // Size of rectangle to update (in pixels) 
  public
    // Initialize with default values
    procedure Initialize; inline;
  end; 

  // Specs and pixel storage for a texture used by Dear ImGui.
  // This is only useful for (1) core library and (2) backends. End-user/applications do not need to care about this.
  // Renderer Backends will create a GPU-side version of this.
  // Why does we store two identifiers: TexID and BackendUserData?
  // - ImTextureID    TexID           = lower-level identifier stored in ImDrawCmd. ImDrawCmd can refer to textures not created by the backend, and for which there's no ImTextureData.
  // - void*          BackendUserData = higher-level opaque storage for backend own book-keeping. Some backends may have enough with TexID and not need both.
  // In columns below: who reads/writes each fields? 'r'=read, 'w'=write, 'core'=main library, 'backend'=renderer backend
  TImTextureData = record
  public
    //------------------------------------------ core / backend ---------------------------------------
    UniqueID: Int32;                    // w    -   // [DEBUG] Sequential index to facilitate identifying a texture when debugging/printing. Unique per atlas. 
    Status: TImTextureStatus;           // rw   rw  // ImTextureStatus_OK/_WantCreate/_WantUpdates/_WantDestroy. Always use SetStatus() to modify! 
    BackendUserData: Pointer;           // -    rw  // Convenience storage for backend. Some backends may have enough with TexID. 
    TexID: TImTextureID;                // r    w   // Backend-specific texture identifier. Always use SetTexID() to modify! The identifier will stored in ImDrawCmd::GetTexID() and passed to backend's RenderDrawData function. 
    Format: TImTextureFormat;           // w    r   // ImTextureFormat_RGBA32 (default) or ImTextureFormat_Alpha8 
    Width: Int32;                       // w    r   // Texture width 
    Height: Int32;                      // w    r   // Texture height 
    BytesPerPixel: Int32;               // w    r   // 4 or 1 
    Pixels: PUInt8;                     // w    r   // Pointer to buffer holding 'Width*Height' pixels and 'Width*Height*BytesPerPixels' bytes. 
    UsedRect: TImTextureRect;           // w    r   // Bounding box encompassing all past and queued Updates[]. 
    UpdateRect: TImTextureRect;         // w    r   // Bounding box encompassing all queued Updates[]. 
    Updates: TImVector<TImTextureRect>; // w    r   // Array of individual updates. 
    UnusedFrames: Int32;                // w    r   // In order to facilitate handling Status==WantDestroy in some backend: this is a count successive frames where the texture was not used. Always >0 when Status==WantDestroy. 
    RefCount: UInt16;                   // w    r   // Number of contexts using this texture. Used during backend shutdown. 
    UseColors: Boolean;                 // w    r   // Tell whether our texture data is known to use colors (rather than just white + alpha). 
    WantDestroyNextFrame: Boolean;      // rw   -   // [Internal] Queued to set ImTextureStatus_WantDestroy next frame. May still be used in the current frame. 
  public
    // Initialize with default values
    procedure Initialize; inline;

    procedure Create(const AFormat: TImTextureFormat; const AW, AH: Int32); inline;
    procedure DestroyPixels; inline;
    function GetPixels: Pointer; inline;
    function GetPixelsAt(const AX, AY: Int32): Pointer; inline;
    function GetSizeInBytes: Int32; inline;
    function GetPitch: Int32; inline;
    function GetTexRef: TImTextureRef; inline;
    function GetTexID: TImTextureID; inline;

    // Called by Renderer backend
    // - Call SetTexID() and SetStatus() after honoring texture requests. Never modify TexID and Status directly!
    // - A backend may decide to destroy a texture that we did not request to destroy, which is fine (e.g. freeing resources), but we immediately set the texture back in _WantCreate mode.
    procedure SetTexID(const ATexId: TImTextureID); inline;
    procedure SetStatus(const AStatus: TImTextureStatus); inline;
  end; 

  // A font input/source (we may rename this to ImFontSource in the future)
  TImFontConfig = record
  public
    // Data Source
    Name: array [0..39] of UTF8Char; // <auto>   // Name (strictly to ease debugging, hence limited size buffer) 
    FontData: Pointer;               //          // TTF/OTF data 
    FontDataSize: Int32;             //          // TTF/OTF data size 
    FontDataOwnedByAtlas: Boolean;   // true     // TTF/OTF data ownership taken by the owner ImFontAtlas (will delete memory itself). SINCE 1.92, THE DATA NEEDS TO PERSIST FOR WHOLE DURATION OF ATLAS. 
    // Options
    MergeMode: Boolean;              // false    // Merge into previous ImFont, so you can combine multiple inputs font into one ImFont (e.g. ASCII font + icons + Japanese glyphs). You may want to use GlyphOffset.y when merge font of different heights. 
    PixelSnapH: Boolean;             // false    // Align every glyph AdvanceX to pixel boundaries. Prevents fractional font size from working correctly! Useful e.g. if you are merging a non-pixel aligned font with the default font. If enabled, OversampleH/V will default to 1. 
    OversampleH: UTF8Char;           // 0 (2)    // Rasterize at higher quality for sub-pixel positioning. 0 == auto == 1 or 2 depending on size. Note the difference between 2 and 3 is minimal. You can reduce this to 1 for large glyphs save memory. Read https://github.com/nothings/stb/blob/master/tests/oversample/README.md for details. 
    OversampleV: UTF8Char;           // 0 (1)    // Rasterize at higher quality for sub-pixel positioning. 0 == auto == 1. This is not really useful as we don't use sub-pixel positions on the Y axis. 
    EllipsisChar: Char;              // 0        // Explicitly specify Unicode codepoint of ellipsis character. When fonts are being merged first specified ellipsis will be used. 
    SizePixels: Single;              //          // Output size in pixels for rasterizer (more or less maps to the resulting font height). 
    GlyphRanges: PChar;              // NULL     // *LEGACY* THE ARRAY DATA NEEDS TO PERSIST AS LONG AS THE FONT IS ALIVE. Pointer to a user-provided list of Unicode range (2 value per range, values are inclusive, zero-terminated list). 
    GlyphExcludeRanges: PChar;       // NULL     // Pointer to a small user-provided list of Unicode ranges (2 value per range, values are inclusive, zero-terminated list). This is very close to GlyphRanges[] but designed to exclude ranges from a font source, when merging fonts with overlapping glyphs. Use "Input Glyphs Overlap Detection Tool" to find about your overlapping ranges. 
    //ImVec2        GlyphExtraSpacing;      // 0, 0     // (REMOVED AT IT SEEMS LARGELY OBSOLETE. PLEASE REPORT IF YOU WERE USING THIS). Extra spacing (in pixels) between glyphs when rendered: essentially add to glyph->AdvanceX. Only X axis is supported for now.
    GlyphOffset: TVector2;           // 0, 0     // Offset (in pixels) all glyphs from this font input. Absolute value for default size, other sizes will scale this value. 
    GlyphMinAdvanceX: Single;        // 0        // Minimum AdvanceX for glyphs, set Min to align font icons, set both Min/Max to enforce mono-space font. Absolute value for default size, other sizes will scale this value. 
    GlyphMaxAdvanceX: Single;        // FLT_MAX  // Maximum AdvanceX for glyphs 
    GlyphExtraAdvanceX: Single;      // 0        // Extra spacing (in pixels) between glyphs. Please contact us if you are using this. // FIXME-NEWATLAS: Intentionally unscaled 
    FontNo: UInt32;                  // 0        // Index of font within TTF/OTF file 
    FontLoaderFlags: UInt32;         // 0        // Settings for custom font builder. THIS IS BUILDER IMPLEMENTATION DEPENDENT. Leave as zero if unsure. 
    //unsigned int  FontBuilderFlags;       // --       // [Renamed in 1.92] Use FontLoaderFlags.
    RasterizerMultiply: Single;      // 1.0f     // Linearly brighten (>1.0f) or darken (<1.0f) font output. Brightening small fonts may be a good workaround to make them more readable. This is a silly thing we may remove in the future. 
    RasterizerDensity: Single;       // 1.0f     // [LEGACY: this only makes sense when ImGuiBackendFlags_RendererHasTextures is not supported] DPI scale multiplier for rasterization. Not altering other font metrics: makes it easy to swap between e.g. a 100% and a 400% fonts for a zooming display, or handle Retina screen. IMPORTANT: If you change this it is expected that you increase/decrease font scale roughly to the inverse of this, otherwise quality may look lowered. 
    ExtraSizeScale: Single;          // 1.0f     // Extra rasterizer scale over SizePixels. 
    // [Internal]
    Flags: TImFontFlags;             // Font flags (don't use just yet, will be exposed in upcoming 1.92.X updates) 
    DstFont: PImFont;                // Target font (as we merging fonts, multiple ImFontConfig may target the same font) 
    FontLoader: PImFontLoader;       // Custom font backend for this source (default source is the one stored in ImFontAtlas) 
    FontLoaderData: Pointer;         // Font loader opaque storage (per font config) 
  public
    // Initialize with default values
    procedure Initialize; inline;
  end; 

  // Hold rendering data for one glyph.
  // (Note: some language parsers may fail to convert the bitfield members, in this case maybe drop store a single u32 or we can rework this)
  TImFontGlyph = record
  public
    _Flags0: UInt32; 
    AdvanceX: Single; // Horizontal distance to advance cursor/layout position. 
    X0: Single;       // Glyph corners. Offsets from current cursor/layout position. 
    Y0: Single;       // Glyph corners. Offsets from current cursor/layout position. 
    X1: Single;       // Glyph corners. Offsets from current cursor/layout position. 
    Y1: Single;       // Glyph corners. Offsets from current cursor/layout position. 
    U0: Single;       // Texture coordinates for the current value of ImFontAtlas->TexRef. Cached equivalent of calling GetCustomRect() with PackId. 
    V0: Single;       // Texture coordinates for the current value of ImFontAtlas->TexRef. Cached equivalent of calling GetCustomRect() with PackId. 
    U1: Single;       // Texture coordinates for the current value of ImFontAtlas->TexRef. Cached equivalent of calling GetCustomRect() with PackId. 
    V1: Single;       // Texture coordinates for the current value of ImFontAtlas->TexRef. Cached equivalent of calling GetCustomRect() with PackId. 
    PackId: Int32;    // [Internal] ImFontAtlasRectId value (FIXME: Cold data, could be moved elsewhere?) 
  {$REGION 'Internal Declarations'}
  private
    function GetColored: Cardinal; inline;
    procedure SetColored(const AValue: Cardinal); inline;
    function GetVisible: Cardinal; inline;
    procedure SetVisible(const AValue: Cardinal); inline;
    function GetSourceIdx: Cardinal; inline;
    procedure SetSourceIdx(const AValue: Cardinal); inline;
    function GetCodepoint: Cardinal; inline;
    procedure SetCodepoint(const AValue: Cardinal); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Colored: Cardinal read GetColored write SetColored; // Flag to indicate glyph is colored and should generally ignore tinting (make it usable with no shift on little-endian as this is used in loops)
    property Visible: Cardinal read GetVisible write SetVisible; // Flag to indicate glyph has no visible pixels (e.g. space). Allow early out when rendering.
    property SourceIdx: Cardinal read GetSourceIdx write SetSourceIdx; // Index of source in parent font
    property Codepoint: Cardinal read GetCodepoint write SetCodepoint; // 0x0000..0x10FFFF
  public
    // Initialize with default values
    procedure Initialize; inline;
  end; 

  // Helper to build glyph ranges from text/string data. Feed your application strings/characters to it then call BuildRanges().
  // This is essentially a tightly packed of vector of 64k booleans = 8KB storage.
  TImFontGlyphRangesBuilder = record
  public
    UsedChars: TImVector<UInt32>; // Store 1-bit per Unicode code point (0=unused, 1=used) 
  public
    // Initialize with default values
    procedure Initialize; inline;

    procedure Clear; inline;

    // Get bit n in the array
    function GetBit(const AN: NativeUInt): Boolean; inline;

    // Set bit n in the array
    procedure SetBit(const AN: NativeUInt); inline;

    // Add character
    procedure AddChar(const AC: Char); inline;

    // Add string (each character of the UTF-8 string are added)
    procedure AddText(const AText: PUTF8Char; const ATextEnd: PUTF8Char = nil); inline;

    // Add ranges, e.g. builder.AddRanges(ImFontAtlas::GetGlyphRangesDefault()) to force add all of ASCII/Latin+Ext
    procedure AddRanges(const ARanges: PChar); inline;

    // Output new ranges (ImVector_Construct()/ImVector_Destruct() can be used to safely construct out_ranges)
    procedure BuildRanges(const AOutRanges: PImVectorImWchar); inline;
  end; 

  // Output of ImFontAtlas::GetCustomRect() when using custom rectangles.
  // Those values may not be cached/stored as they are only valid for the current value of atlas->TexRef
  // (this is in theory derived from ImTextureRect but we use separate structures for reasons)
  TImFontAtlasRect = record
  public
    X: UInt16;     // Position (in current texture) 
    Y: UInt16;     // Position (in current texture) 
    W: UInt16;     // Size 
    H: UInt16;     // Size 
    Uv0: TVector2; // UV coordinates (in current texture) 
    Uv1: TVector2; // UV coordinates (in current texture) 
  public
    // Initialize with default values
    procedure Initialize; inline;
  end; 

  // Load and rasterize multiple TTF/OTF fonts into a same texture. The font atlas will build a single texture holding:
  //  - One or more fonts.
  //  - Custom graphics data needed to render the shapes needed by Dear ImGui.
  //  - Mouse cursor shapes for software cursor rendering (unless setting 'Flags |= ImFontAtlasFlags_NoMouseCursors' in the font atlas).
  //  - If you don't call any AddFont*** functions, the default font embedded in the code will be loaded for you.
  // It is the rendering backend responsibility to upload texture into your graphics API:
  //  - ImGui_ImplXXXX_RenderDrawData() functions generally iterate platform_io->Textures[] to create/update/destroy each ImTextureData instance.
  //  - Backend then set ImTextureData's TexID and BackendUserData.
  //  - Texture id are passed back to you during rendering to identify the texture. Read FAQ entry about ImTextureID/ImTextureRef for more details.
  // Legacy path:
  //  - Call Build() + GetTexDataAsAlpha8() or GetTexDataAsRGBA32() to build and retrieve pixels data.
  //  - Call SetTexID(my_tex_id); and pass the pointer/identifier to your texture in a format natural to your graphics API.
  // Common pitfalls:
  // - If you pass a 'glyph_ranges' array to AddFont*** functions, you need to make sure that your array persists up until the
  //   atlas is build (when calling GetTexData*** or Build()). We only copy the pointer, not the data.
  // - Important: By default, AddFontFromMemoryTTF() takes ownership of the data. Even though we are not writing to it, we will free the pointer on destruction.
  //   You can set font_cfg->FontDataOwnedByAtlas=false to keep ownership of your data and it won't be freed,
  // - Even though many functions are suffixed with "TTF", OTF data is supported just as well.
  // - This is an old API and it is currently awkward for those and various other reasons! We will address them in the future!
  TImFontAtlas = record
  public
    // Input
    Flags: TImFontAtlasFlags;                                                  // Build flags (see ImFontAtlasFlags_) 
    TexDesiredFormat: TImTextureFormat;                                        // Desired texture format (default to ImTextureFormat_RGBA32 but may be changed to ImTextureFormat_Alpha8). 
    TexGlyphPadding: Int32;                                                    // FIXME: Should be called "TexPackPadding". Padding between glyphs within texture in pixels. Defaults to 1. If your rendering method doesn't rely on bilinear filtering you may set this to 0 (will also need to set AntiAliasedLinesUseTex = false). 
    TexMinWidth: Int32;                                                        // Minimum desired texture width. Must be a power of two. Default to 512. 
    TexMinHeight: Int32;                                                       // Minimum desired texture height. Must be a power of two. Default to 128. 
    TexMaxWidth: Int32;                                                        // Maximum desired texture width. Must be a power of two. Default to 8192. 
    TexMaxHeight: Int32;                                                       // Maximum desired texture height. Must be a power of two. Default to 8192. 
    UserData: Pointer;                                                         // Store your own atlas related user-data (if e.g. you have multiple font atlas). 
    TexRef: TImTextureRef;                                                     // Latest texture identifier == TexData->GetTexRef(). 
    TexData: PImTextureData;                                                   // Latest texture. 
    // [Internal]
    TexList: TImVector<TImTextureDataPtr>;                                     // Texture list (most often TexList.Size == 1). TexData is always == TexList.back(). DO NOT USE DIRECTLY, USE GetDrawData().Textures[]/GetPlatformIO().Textures[] instead! 
    Locked: Boolean;                                                           // Marked as locked during ImGui::NewFrame()..EndFrame() scope if TexUpdates are not supported. Any attempt to modify the atlas will assert. 
    RendererHasTextures: Boolean;                                              // Copy of (BackendFlags & ImGuiBackendFlags_RendererHasTextures) from supporting context. 
    TexIsBuilt: Boolean;                                                       // Set when texture was built matching current font input. Mostly useful for legacy IsBuilt() call. 
    TexPixelsUseColors: Boolean;                                               // Tell whether our texture data is known to use colors (rather than just alpha channel), in order to help backend select a format or conversion process. 
    TexUvScale: TVector2;                                                      // = (1.0f/TexData->TexWidth, 1.0f/TexData->TexHeight). May change as new texture gets created. 
    TexUvWhitePixel: TVector2;                                                 // Texture coordinates to a white pixel. May change as new texture gets created. 
    Fonts: TImVector<TImFontPtr>;                                              // Hold all the fonts returned by AddFont*. Fonts[0] is the default font upon calling ImGui::NewFrame(), use ImGui::PushFont()/PopFont() to change the current font. 
    Sources: TImVector<TImFontConfig>;                                         // Source/configuration data 
    TexUvLines: array [0.._IM_DRAWLIST_TEX_LINES_WIDTH_MAX+1 - 1] of TVector4; // UVs for baked anti-aliased lines 
    TexNextUniqueID: Int32;                                                    // Next value to be stored in TexData->UniqueID 
    FontNextUniqueID: Int32;                                                   // Next value to be stored in ImFont->FontID 
    DrawListSharedDatas: TImVector<TImDrawListSharedDataPtr>;                  // List of users for this atlas. Typically one per Dear ImGui context. 
    Builder: PImFontAtlasBuilder;                                              // Opaque interface to our data that doesn't need to be public and may be discarded when rebuilding. 
    FontLoader: PImFontLoader;                                                 // Font loader opaque interface (default to use FreeType when IMGUI_ENABLE_FREETYPE is defined, otherwise default to use stb_truetype). Use SetFontLoader() to change this at runtime. 
    FontLoaderName: PUTF8Char;                                                 // Font loader name (for display e.g. in About box) == FontLoader->Name 
    FontLoaderData: Pointer;                                                   // Font backend opaque storage 
    FontLoaderFlags: UInt32;                                                   // Shared flags (for all fonts) for font loader. THIS IS BUILD IMPLEMENTATION DEPENDENT (e.g. Per-font override is also available in ImFontConfig). 
    RefCount: Int32;                                                           // Number of contexts using this atlas 
    OwnerContext: PImGuiContext;                                               // Context which own the atlas will be in charge of updating and destroying it. 
  public
    // Initialize with default values
    procedure Initialize; inline;

    function AddFont(const AFontCfg: PImFontConfig): PImFont; inline;

    // Selects between AddFontDefaultVector() and AddFontDefaultBitmap().
    function AddFontDefault(const AFontCfg: PImFontConfig = nil): PImFont; inline;

    // Embedded scalable font. Recommended at any higher size.
    function AddFontDefaultVector(const AFontCfg: PImFontConfig = nil): PImFont; inline;

    // Embedded classic pixel-clean font. Recommended at Size 13px with no scaling.
    function AddFontDefaultBitmap(const AFontCfg: PImFontConfig = nil): PImFont; inline;
    function AddFontFromFileTTF(const AFilename: PUTF8Char; const ASizePixels: Single = 0.0; 
      const AFontCfg: PImFontConfig = nil; const AGlyphRanges: PChar = nil): PImFont; inline;

    // Note: Transfer ownership of 'ttf_data' to ImFontAtlas! Will be deleted after destruction of the atlas. Set font_cfg->FontDataOwnedByAtlas=false to keep ownership of your data and it won't be freed.
    function AddFontFromMemoryTTF(const AFontData: Pointer; const AFontDataSize: Int32; 
      const ASizePixels: Single = 0.0; const AFontCfg: PImFontConfig = nil; const AGlyphRanges: PChar = nil): PImFont; inline;

    // 'compressed_font_data' still owned by caller. Compress with binary_to_compressed_c.cpp.
    function AddFontFromMemoryCompressedTTF(const ACompressedFontData: Pointer; 
      const ACompressedFontDataSize: Int32; const ASizePixels: Single = 0.0; const AFontCfg: PImFontConfig = nil; 
      const AGlyphRanges: PChar = nil): PImFont; inline;

    // 'compressed_font_data_base85' still owned by caller. Compress with binary_to_compressed_c.cpp with -base85 parameter.
    function AddFontFromMemoryCompressedBase85TTF(const ACompressedFontDataBase85: PUTF8Char; 
      const ASizePixels: Single = 0.0; const AFontCfg: PImFontConfig = nil; const AGlyphRanges: PChar = nil): PImFont; inline;
    procedure RemoveFont(const AFont: PImFont); inline;

    // Clear everything (fonts + textures). Don't call mid-frame!
    procedure Clear; inline;

    // Clear input+output font data/glyphs. You can call this mid-frame if you load new fonts afterwards!
    procedure ClearFonts; inline;

    // Compact cached glyphs and texture.
    procedure CompactCache; inline;

    // Change font loader at runtime.
    procedure SetFontLoader(const AFontLoader: PImFontLoader); inline;

    // As we are transitioning toward a new font system, we expect to obsolete those soon:
    // [OBSOLETE] Clear input data (all ImFontConfig structures including sizes, TTF data, glyph ranges, etc.) = all the data used to build the texture and fonts.
    procedure ClearInputData; inline;

    // [OBSOLETE] Clear CPU-side copy of the texture data. Saves RAM once the texture has been copied to graphics memory.
    procedure ClearTexData; inline;

    // Since 1.92: specifying glyph ranges is only useful/necessary if your backend doesn't support ImGuiBackendFlags_RendererHasTextures!
    // Basic Latin, Extended Latin
    function GetGlyphRangesDefault: PChar; inline;

    // Register and retrieve custom rectangles
    // - You can request arbitrary rectangles to be packed into the atlas, for your own purpose.
    // - Since 1.92.0, packing is done immediately in the function call (previously packing was done during the Build call)
    // - You can render your pixels into the texture right after calling the AddCustomRect() functions.
    // - VERY IMPORTANT:
    //   - Texture may be created/resized at any time when calling ImGui or ImFontAtlas functions.
    //   - IT WILL INVALIDATE RECTANGLE DATA SUCH AS UV COORDINATES. Always use latest values from GetCustomRect().
    //   - UV coordinates are associated to the current texture identifier aka 'atlas->TexRef'. Both TexRef and UV coordinates are typically changed at the same time.
    // - If you render colored output into your custom rectangles: set 'atlas->TexPixelsUseColors = true' as this may help some backends decide of preferred texture format.
    // - Read docs/FONTS.md for more details about using colorful icons.
    // - Note: this API may be reworked further in order to facilitate supporting e.g. multi-monitor, varying DPI settings.
    // - (Pre-1.92 names) ------------> (1.92 names)
    //   - GetCustomRectByIndex()   --> Use GetCustomRect()
    //   - CalcCustomRectUV()       --> Use GetCustomRect() and read uv0, uv1 fields.
    //   - AddCustomRectRegular()   --> Renamed to AddCustomRect()
    //   - AddCustomRectFontGlyph() --> Prefer using custom ImFontLoader inside ImFontConfig
    //   - ImFontAtlasCustomRect    --> Renamed to ImFontAtlasRect
    // Register a rectangle. Return -1 (ImFontAtlasRectId_Invalid) on error.
    function AddCustomRect(const AWidth, AHeight: Int32; const AOutR: PImFontAtlasRect = nil): TImFontAtlasRectId; inline;

    // Unregister a rectangle. Existing pixels will stay in texture until resized / garbage collected.
    procedure RemoveCustomRect(const AId: TImFontAtlasRectId); inline;

    // Get rectangle coordinates for current texture. Valid immediately, never store this (read above)!
    function GetCustomRect(const AId: TImFontAtlasRectId; const AOutR: PImFontAtlasRect): Boolean; inline;
  end; 

  // Font runtime data for a given size
  // Important: pointers to ImFontBaked are only valid for the current frame.
  TImFontBaked = record
  public
    // [Internal] Members: Hot ~20/24 bytes (for CalcTextSize)
    IndexAdvanceX: TImVector<Single>; // 12-16 // out // Sparse. Glyphs->AdvanceX in a directly indexable way (cache-friendly for CalcTextSize functions which only this info, and are often bottleneck in large UI). 
    FallbackAdvanceX: Single;         // 4     // out // FindGlyph(FallbackChar)->AdvanceX 
    Size: Single;                     // 4     // in  // Height of characters/line, set during loading (doesn't change after loading) 
    RasterizerDensity: Single;        // 4     // in  // Density this is baked at 
    // [Internal] Members: Hot ~28/36 bytes (for RenderText loop)
    IndexLookup: TImVector<UInt16>;   // 12-16 // out // Sparse. Index glyphs by Unicode code-point. 
    Glyphs: TImVector<TImFontGlyph>;  // 12-16 // out // All glyphs. 
    FallbackGlyphIndex: Int32;        // 4     // out // Index of FontFallbackChar 
    // [Internal] Members: Cold
    Ascent: Single;                   // 4+4   // out // Ascent: distance from top to bottom of e.g. 'A' [0..FontSize] (unscaled) 
    // [Internal] Members: Cold
    Descent: Single;                  // 4+4   // out // Ascent: distance from top to bottom of e.g. 'A' [0..FontSize] (unscaled) 
    _Flags9: UInt32; 
    LastUsedFrame: Int32;             // 4  //     // Record of that time this was bounds 
    BakedId: TImGuiID;                // 4     //     // Unique ID for this baked storage 
    OwnerFont: PImFont;               // 4-8   // in  // Parent font 
    FontLoaderDatas: Pointer;         // 4-8   //     // Font loader opaque storage (per baked font * sources): single contiguous buffer allocated by imgui, passed to loader. 
  {$REGION 'Internal Declarations'}
  private
    function GetMetricsTotalSurface: Cardinal; inline;
    procedure SetMetricsTotalSurface(const AValue: Cardinal); inline;
    function GetWantDestroy: Cardinal; inline;
    procedure SetWantDestroy(const AValue: Cardinal); inline;
    function GetLoadNoFallback: Cardinal; inline;
    procedure SetLoadNoFallback(const AValue: Cardinal); inline;
    function GetLoadNoRenderOnLayout: Cardinal; inline;
    procedure SetLoadNoRenderOnLayout(const AValue: Cardinal); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property MetricsTotalSurface: Cardinal read GetMetricsTotalSurface write SetMetricsTotalSurface; // 3  // out // Total surface in pixels to get an idea of the font rasterization/texture cost (not exact, we approximate the cost of padding between glyphs)
    property WantDestroy: Cardinal read GetWantDestroy write SetWantDestroy; // 0  //     // Queued for destroy
    property LoadNoFallback: Cardinal read GetLoadNoFallback write SetLoadNoFallback; // 0  //     // Disable loading fallback in lower-level calls.
    property LoadNoRenderOnLayout: Cardinal read GetLoadNoRenderOnLayout write SetLoadNoRenderOnLayout; // 0  //     // Enable a two-steps mode where CalcTextSize() calls will load AdvanceX *without* rendering/packing glyphs. Only advantageous if you know that the glyph is unlikely to actually be rendered, otherwise it is slower because we'd do one query on the first CalcTextSize and one query on the first Draw.
  public
    // Initialize with default values
    procedure Initialize; inline;

    procedure ClearOutputData; inline;

    // Return U+FFFD glyph if requested glyph doesn't exists.
    function FindGlyph(const AC: Char): PImFontGlyph; inline;

    // Return NULL if glyph doesn't exist
    function FindGlyphNoFallback(const AC: Char): PImFontGlyph; inline;
    function GetCharAdvance(const AC: Char): Single; inline;
    function IsGlyphLoaded(const AC: Char): Boolean; inline;
  end; 

  // Font runtime data and rendering
  // - ImFontAtlas automatically loads a default embedded font for you if you didn't load one manually.
  // - Since 1.92.0 a font may be rendered as any size! Therefore a font doesn't have one specific size.
  // - Use 'font->GetFontBaked(size)' to retrieve the ImFontBaked* corresponding to a given size.
  // - If you used g.Font + g.FontSize (which is frequent from the ImGui layer), you can use g.FontBaked as a shortcut, as g.FontBaked == g.Font->GetFontBaked(g.FontSize).
  TImFont = record
  public
    // [Internal] Members: Hot ~12-20 bytes
    LastBaked: PImFontBaked;                                                               // 4-8   // Cache last bound baked. NEVER USE DIRECTLY. Use GetFontBaked(). 
    OwnerAtlas: PImFontAtlas;                                                              // 4-8   // What we have been loaded into. 
    Flags: TImFontFlags;                                                                   // 4     // Font flags. 
    CurrentRasterizerDensity: Single;                                                      // Current rasterizer density. This is a varying state of the font. 
    // [Internal] Members: Cold ~24-52 bytes
    // Conceptually Sources[] is the list of font sources merged to create this font.
    FontId: TImGuiID;                                                                      // Unique identifier for the font 
    LegacySize: Single;                                                                    // 4     // in  // Font size passed to AddFont(). Use for old code calling PushFont() expecting to use that size. (use ImGui::GetFontBaked() to get font baked at current bound size). 
    Sources: TImVector<TImFontConfigPtr>;                                                  // 16    // in  // List of sources. Pointers within OwnerAtlas->Sources[] 
    EllipsisChar: Char;                                                                    // 2-4   // out // Character used for ellipsis rendering ('...'). If you ever want to temporarily swap this for an alternative/dummy char, make sure to clear EllipsisAutoBake. 
    FallbackChar: Char;                                                                    // 2-4   // out // Character used if a glyph isn't found (U+FFFD, '?') 
    Used8kPagesMap: array [0..(_IM_UNICODE_CODEPOINT_MAX +1) div 8192 div 8 - 1] of UInt8; // 1 bytes if ImWchar=ImWchar16, 17 bytes if ImWchar==ImWchar32. Store 1-bit for each block of 8K codepoints that has one active glyph. This is mainly used to facilitate iterations across all used codepoints. 
    EllipsisAutoBake: Boolean;                                                             // 1     //     // Mark when the "..." glyph (== EllipsisChar) needs to be generated by combining multiple '.'. 
    RemapPairs: TImGuiStorage;                                                             // 16    //     // Remapping pairs when using AddRemapChar(), otherwise empty. 
  public
    // Initialize with default values
    procedure Initialize; inline;

    function IsGlyphInFont(const AC: Char): Boolean; inline;
    function IsLoaded: Boolean; inline;

    // Fill ImFontConfig::Name.
    function GetDebugName: PUTF8Char; inline;

    // [Internal] Don't use!
    // 'max_width' stops rendering after a certain width (could be turned into a 2d size). FLT_MAX to disable.
    // 'wrap_width' enable automatic word-wrapping across multiple lines to fit into given width. 0.0f to disable.
    // Implied density = -1.0f
    function GetFontBaked(const AFontSize: Single): PImFontBaked; overload; inline;

    // Get or create baked data for given size
    function GetFontBaked(const AFontSize: Single; const ADensity: Single = -1.0): PImFontBaked; overload; inline;

    // Implied text_end = NULL, out_remaining = NULL
    function CalcTextSizeA(const ASize, AMaxWidth, AWrapWidth: Single; const ATextBegin: PUTF8Char): TVector2; overload; inline;
    function CalcTextSizeA(const ASize, AMaxWidth, AWrapWidth: Single; const ATextBegin: PUTF8Char; 
      const ATextEnd: PUTF8Char = nil; const AOutRemaining: PPUTF8Char = nil): TVector2; overload; inline;
    function CalcWordWrapPosition(const ASize: Single; const AText, ATextEnd: PUTF8Char; 
      const AWrapWidth: Single): PUTF8Char; inline;

    // Implied cpu_fine_clip = NULL
    procedure RenderChar(const ADrawList: PImDrawList; const ASize: Single; const APos: TVector2; 
      const ACol: UInt32; const AC: Char); overload; inline;
    procedure RenderChar(const ADrawList: PImDrawList; const ASize: Single; const APos: TVector2; 
      const ACol: UInt32; const AC: Char; const ACpuFineClip: PVector4 = nil); overload; inline;
    procedure RenderText(const ADrawList: PImDrawList; const ASize: Single; const APos: TVector2; 
      const ACol: UInt32; const AClipRect: TVector4; const ATextBegin, ATextEnd: PUTF8Char; 
      const AWrapWidth: Single = 0.0; const AFlags: Int32 = 0); inline;

    // [Internal] Don't use!
    procedure ClearOutputData; inline;

    // Makes 'from_codepoint' character points to 'to_codepoint' glyph.
    procedure AddRemapChar(const AFromCodepoint, AToCodepoint: Char); inline;
    function IsGlyphRangeUnused(const ACBegin, ACLast: UInt32): Boolean; inline;
  end; 

  // - Currently represents the Platform Window created by the application which is hosting our Dear ImGui windows.
  // - In 'docking' branch with multi-viewport enabled, we extend this concept to have multiple active viewports.
  // - In the future we will extend this concept further to also represent Platform Monitor and support a "no main platform window" operation mode.
  // - About Main Area vs Work Area:
  //   - Main Area = entire viewport.
  //   - Work Area = entire viewport minus sections used by main menu bars (for platform windows), or by task bar (for platform monitor).
  //   - Windows are generally trying to stay within the Work Area of their host viewport.
  TImGuiViewport = record
  public
    ID: TImGuiID;               // Unique identifier for the viewport 
    Flags: TImGuiViewportFlags; // See ImGuiViewportFlags_ 
    Pos: TVector2;              // Main Area: Position of the viewport (Dear ImGui coordinates are the same as OS desktop/native coordinates) 
    Size: TVector2;             // Main Area: Size of the viewport. 
    FramebufferScale: TVector2; // Density of the viewport for Retina display (always 1,1 on Windows, may be 2,2 etc on macOS/iOS). This will affect font rasterizer density. 
    WorkPos: TVector2;          // Work Area: Position of the viewport minus task bars, menus bars, status bars (>= Pos) 
    WorkSize: TVector2;         // Work Area: Size of the viewport minus task bars, menu bars, status bars (<= Size) 
    // Platform/Backend Dependent Data
    PlatformHandle: Pointer;    // void* to hold higher-level, platform window handle (e.g. HWND, GLFWWindow*, SDL_Window*) 
    PlatformHandleRaw: Pointer; // void* to hold lower-level, platform-native window handle (under Win32 this is expected to be a HWND, unused for other platforms) 
  public
    // Initialize with default values
    procedure Initialize; inline;

    // Helpers
    function GetCenter: TVector2; inline;
    function GetWorkCenter: TVector2; inline;
  end; 

  // Access via ImGui::GetPlatformIO()
  TImGuiPlatformIO = record
  public
    // Optional: Access OS clipboard
    // (default to use native Win32 clipboard on Windows, otherwise uses a private clipboard. Override to access OS clipboard on other architectures)
    PlatformGetClipboardTextFn: function(ctx: Pointer): Pointer; cdecl; // Should return NULL on failure (e.g. clipboard data is not text). 
    PlatformSetClipboardTextFn: procedure(ctx: Pointer; text: Pointer); cdecl; 
    PlatformClipboardUserData: Pointer; 
    // Optional: Open link/folder/file in OS Shell
    // (default to use ShellExecuteW() on Windows, system() on Linux/Mac. expected to return false on failure, but some platforms may always return true)
    PlatformOpenInShellFn: function(ctx: Pointer; path: Pointer): Boolean; cdecl; 
    PlatformOpenInShellUserData: Pointer; 
    // Optional: Notify OS Input Method Editor of the screen position of your cursor for text input position (e.g. when using Japanese/Chinese IME on Windows)
    // (default to use native imm32 api on Windows)
    PlatformSetImeDataFn: procedure(ctx: Pointer; viewport: Pointer; data: Pointer); cdecl; 
    PlatformImeUserData: Pointer; 
    // Optional: Platform locale
    // [Experimental] Configure decimal point e.g. '.' or ',' useful for some languages (e.g. German), generally pulled from *localeconv()->decimal_point
    PlatformLocaleDecimalPoint: Char;                                   // '.' 
    // Optional: Maximum texture size supported by renderer (used to adjust how we size textures). 0 if not known.
    RendererTextureMaxWidth: Int32; 
    RendererTextureMaxHeight: Int32; 
    // Written by some backends during ImGui_ImplXXXX_RenderDrawData() call to point backend_specific ImGui_ImplXXXX_RenderState* structure.
    RendererRenderState: Pointer; 
    // Standard draw callbacks provided by renderer backend.
    DrawCallbackResetRenderState: TImDrawCallback;                      // Request to reset the graphics/render state. 
    DrawCallbackSetSamplerLinear: TImDrawCallback;                      // Request backend to set texture sampling to Linear. 
    DrawCallbackSetSamplerNearest: TImDrawCallback;                     // Request backend to set texture sampling to Nearest/Point. 
    // Textures list (the list is updated by calling ImGui::EndFrame or ImGui::Render)
    // The ImGui_ImplXXXX_RenderDrawData() function of each backend generally access this via ImDrawData::Textures which points to this. The array is available here mostly because backends will want to destroy textures on shutdown.
    Textures: TImVector<TImTextureDataPtr>;                             // List of textures used by Dear ImGui (most often 1) + contents of external texture list is automatically appended into this. 
  public
    // Initialize with default values
    procedure Initialize; inline;

    // Clear all Platform_XXX fields. Typically called on Platform Backend shutdown.
    procedure ClearPlatformHandlers; inline;

    // Clear all Renderer_XXX fields. Typically called on Renderer Backend shutdown.
    procedure ClearRendererHandlers; inline;
  end; 

  // (Optional) Support for IME (Input Method Editor) via the platform_io.Platform_SetImeDataFn() function. Handler is called during EndFrame().
  TImGuiPlatformImeData = record
  public
    WantVisible: Boolean;    // A widget wants the IME to be visible. 
    WantTextInput: Boolean;  // A widget wants text input, not necessarily IME to be visible. This is automatically set to the upcoming value of io.WantTextInput. 
    InputPos: TVector2;      // Position of input cursor (for IME). 
    InputLineHeight: Single; // Line height (for IME). 
    ViewportId: TImGuiID;    // ID of platform window/viewport. 
  public
    // Initialize with default values
    procedure Initialize; inline;
  end;

  // Main ImGui interface
  ImGui = record
  public
    // Context creation and access
    // - Each context create its own ImFontAtlas by default. You may instance one yourself and pass it to CreateContext() to share a font atlas between contexts.
    // - DLL users: heaps and globals are not shared across DLL boundaries! You will need to call SetCurrentContext() + SetAllocatorFunctions()
    //   for each static/DLL boundary you are calling from. Read "Context and Memory Allocators" section of imgui.cpp for details.
    class function CreateContext(const ASharedFontAtlas: PImFontAtlas = nil): PImGuiContext; inline; static;

    // NULL = destroy current context
    class procedure DestroyContext(const ACtx: PImGuiContext = nil); inline; static;
    class function GetCurrentContext: PImGuiContext; inline; static;
    class procedure SetCurrentContext(const ACtx: PImGuiContext); inline; static;

    // Main
    // access the ImGuiIO structure (mouse/keyboard/gamepad inputs, time, various configuration options/flags)
    class function GetIO: PImGuiIO; inline; static;

    // access the ImGuiPlatformIO structure (mostly hooks/functions to connect to platform/renderer and OS Clipboard, IME etc.)
    class function GetPlatformIO: PImGuiPlatformIO; inline; static;

    // access the Style structure (colors, sizes). Always use PushStyleColor(), PushStyleVar() to modify style mid-frame!
    class function GetStyle: PImGuiStyle; inline; static;

    // start a new Dear ImGui frame, you can submit any command from this point until Render()/EndFrame().
    class procedure NewFrame; inline; static;

    // ends the Dear ImGui frame. automatically called by Render(). If you don't need to render data (skipping rendering) you may call EndFrame() without Render()... but you'll have wasted CPU already! If you don't need to render, better to not create any windows and not call NewFrame() at all!
    class procedure EndFrame; inline; static;

    // ends the Dear ImGui frame, finalize the draw data. You can then get call GetDrawData().
    class procedure Render; inline; static;

    // valid after Render() and until the next call to NewFrame(). Call ImGui_ImplXXXX_RenderDrawData() function in your Renderer Backend to render.
    class function GetDrawData: PImDrawData; inline; static;

    // Demo, Debug, Information
    // create Demo window. demonstrate most ImGui features. call this to learn about the library! try to make it always available in your application!
    class procedure ShowDemoWindow(const APOpen: PBoolean = nil); inline; static;

    // create Metrics/Debugger window. display Dear ImGui internals: windows, draw commands, various internal state, etc.
    class procedure ShowMetricsWindow(const APOpen: PBoolean = nil); inline; static;

    // create Debug Log window. display a simplified log of important dear imgui events.
    class procedure ShowDebugLogWindow(const APOpen: PBoolean = nil); inline; static;

    // create Stack Tool window. hover items with mouse to query information about the source of their unique ID.
    class procedure ShowIDStackToolWindow(const APOpen: PBoolean = nil); overload; inline; static;

    // create About window. display Dear ImGui version, credits and build/system information.
    class procedure ShowAboutWindow(const APOpen: PBoolean = nil); inline; static;

    // add style editor block (not a window). you can pass in a reference ImGuiStyle structure to compare to, revert to and save to (else it uses the default style)
    class procedure ShowStyleEditor(const ARef: PImGuiStyle = nil); inline; static;

    // add style selector block (not a window), essentially a combo listing the default styles.
    class function ShowStyleSelector(const ALabel: PUTF8Char): Boolean; inline; static;

    // add font selector block (not a window), essentially a combo listing the loaded fonts.
    class procedure ShowFontSelector(const ALabel: PUTF8Char); inline; static;

    // add basic help/info block (not a window): how to manipulate ImGui as an end-user (mouse/keyboard controls).
    class procedure ShowUserGuide; inline; static;

    // get the compiled version string e.g. "1.80 WIP" (essentially the value for IMGUI_VERSION from the compiled version of imgui.cpp)
    class function GetVersion: PUTF8Char; inline; static;

    // Styles
    // new, recommended style (default)
    class procedure StyleColorsDark(const ADst: PImGuiStyle = nil); inline; static;

    // best used with borders and a custom, thicker font
    class procedure StyleColorsLight(const ADst: PImGuiStyle = nil); inline; static;

    // classic imgui style
    class procedure StyleColorsClassic(const ADst: PImGuiStyle = nil); inline; static;

    // Windows
    // - Begin() = push window to the stack and start appending to it. End() = pop window from the stack.
    // - Passing 'bool* p_open != NULL' shows a window-closing widget in the upper-right corner of the window,
    //   which clicking will set the boolean to false when clicked.
    // - You may append multiple times to the same window during the same frame by calling Begin()/End() pairs multiple times.
    //   Some information such as 'flags' or 'p_open' will only be considered by the first call to Begin().
    // - Begin() return false to indicate the window is collapsed or fully clipped, so you may early out and omit submitting
    //   anything to the window. Always call a matching End() for each Begin() call, regardless of its return value!
    //   [Important: due to legacy reason, Begin/End and BeginChild/EndChild are inconsistent with all other functions
    //    such as BeginMenu/EndMenu, BeginPopup/EndPopup, etc. where the EndXXX call should only be called if the corresponding
    //    BeginXXX function returned true. Begin and BeginChild are the only odd ones out. Will be fixed in a future update.]
    // - Note that the bottom of window stack always contains a window called "Debug".
    class function &Begin(const AName: PUTF8Char; const APOpen: PBoolean = nil; 
      const AFlags: TImGuiWindowFlags = []): Boolean; inline; static;
    class procedure &End; inline; static;

    // Child Windows
    // - Use child windows to begin into a self-contained independent scrolling/clipping regions within a host window. Child windows can embed their own child.
    // - Before 1.90 (November 2023), the "ImGuiChildFlags child_flags = 0" parameter was "bool border = false".
    //   This API is backward compatible with old code, as we guarantee that ImGuiChildFlags_Borders == true.
    //   Consider updating your old code:
    //      BeginChild("Name", size, false)   -> Begin("Name", size, 0); or Begin("Name", size, ImGuiChildFlags_None);
    //      BeginChild("Name", size, true)    -> Begin("Name", size, ImGuiChildFlags_Borders);
    // - Manual sizing (each axis can use a different setting e.g. ImVec2(0.0f, 400.0f)):
    //     == 0.0f: use remaining parent window size for this axis.
    //      > 0.0f: use specified size for this axis.
    //      < 0.0f: right/bottom-align to specified distance from available content boundaries.
    // - Specifying ImGuiChildFlags_AutoResizeX or ImGuiChildFlags_AutoResizeY makes the sizing automatic based on child contents.
    //   Combining both ImGuiChildFlags_AutoResizeX _and_ ImGuiChildFlags_AutoResizeY defeats purpose of a scrolling region and is NOT recommended.
    // - BeginChild() returns false to indicate the window is collapsed or fully clipped, so you may early out and omit submitting
    //   anything to the window. Always call a matching EndChild() for each BeginChild() call, regardless of its return value.
    //   [Important: due to legacy reason, Begin/End and BeginChild/EndChild are inconsistent with all other functions
    //    such as BeginMenu/EndMenu, BeginPopup/EndPopup, etc. where the EndXXX call should only be called if the corresponding
    //    BeginXXX function returned true. Begin and BeginChild are the only odd ones out. Will be fixed in a future update.]
    class function BeginChild(const AStrId: PUTF8Char; const ASize: TVector2; const AChildFlags: TImGuiChildFlags = []; 
      const AWindowFlags: TImGuiWindowFlags = []): Boolean; overload; inline; static;
    class function BeginChild(const AStrId: PUTF8Char; const AChildFlags: TImGuiChildFlags = [];
      const AWindowFlags: TImGuiWindowFlags = []): Boolean; overload; inline; static;
    class function BeginChild(const AId: TImGuiID; const ASize: TVector2; const AChildFlags: TImGuiChildFlags = []; 
      const AWindowFlags: TImGuiWindowFlags = []): Boolean; overload; inline; static;
    class function BeginChild(const AId: TImGuiID; const AChildFlags: TImGuiChildFlags = [];
      const AWindowFlags: TImGuiWindowFlags = []): Boolean; overload; inline; static;
    class procedure EndChild; inline; static;

    // Windows Utilities
    // - 'current window' = the window we are appending into while inside a Begin()/End() block. 'next window' = next window we will Begin() into.
    class function IsWindowAppearing: Boolean; inline; static;
    class function IsWindowCollapsed: Boolean; inline; static;

    // is current window focused? or its root/child, depending on flags. see flags for options.
    class function IsWindowFocused(const AFlags: TImGuiFocusedFlags = []): Boolean; inline; static;

    // is current window hovered and hoverable (e.g. not blocked by a popup/modal)? See ImGuiHoveredFlags_ for options. IMPORTANT: If you are trying to check whether your mouse should be dispatched to Dear ImGui or to your underlying app, you should not use this function! Use the 'io.WantCaptureMouse' boolean for that! Refer to FAQ entry "How can I tell whether to dispatch mouse/keyboard to Dear ImGui or my application?" for details.
    class function IsWindowHovered(const AFlags: TImGuiHoveredFlags = []): Boolean; inline; static;

    // get draw list associated to the current window, to append your own drawing primitives
    class function GetWindowDrawList: PImDrawList; inline; static;

    // get current window position in screen space (IT IS UNLIKELY YOU EVER NEED TO USE THIS. Consider always using GetCursorScreenPos() and GetContentRegionAvail() instead)
    class function GetWindowPos: TVector2; inline; static;

    // get current window size (IT IS UNLIKELY YOU EVER NEED TO USE THIS. Consider always using GetCursorScreenPos() and GetContentRegionAvail() instead)
    class function GetWindowSize: TVector2; inline; static;

    // get current window width (IT IS UNLIKELY YOU EVER NEED TO USE THIS). Shortcut for GetWindowSize().x.
    class function GetWindowWidth: Single; inline; static;

    // get current window height (IT IS UNLIKELY YOU EVER NEED TO USE THIS). Shortcut for GetWindowSize().y.
    class function GetWindowHeight: Single; inline; static;

    // Window manipulation
    // - Prefer using SetNextXXX functions (before Begin) rather that SetXXX functions (after Begin).
    // Implied pivot = ImVec2(0, 0)
    class procedure SetNextWindowPos(const APos: TVector2; const ACond: TImGuiCond = TImGuiCond(0)); overload; inline; static;

    // set next window position. call before Begin(). use pivot=(0.5f,0.5f) to center on given point, etc.
    class procedure SetNextWindowPos(const APos: TVector2; const ACond: TImGuiCond; 
      const APivot: TVector2); overload; inline; static;

    // set next window size. set axis to 0.0f to force an auto-fit on this axis. call before Begin()
    class procedure SetNextWindowSize(const ASize: TVector2; const ACond: TImGuiCond = TImGuiCond(0)); inline; static;

    // set next window size limits. use 0.0f or FLT_MAX if you don't want limits. Use -1 for both min and max of same axis to preserve current size (which itself is a constraint). Use callback to apply non-trivial programmatic constraints.
    class procedure SetNextWindowSizeConstraints(const ASizeMin, ASizeMax: TVector2; 
      const ACustomCallback: TImGuiSizeCallback = nil; const ACustomCallbackData: Pointer = nil); inline; static;

    // set next window content size (~ scrollable client area, which enforce the range of scrollbars). Not including window decorations (title bar, menu bar, etc.) nor WindowPadding. set an axis to 0.0f to leave it automatic. call before Begin()
    class procedure SetNextWindowContentSize(const ASize: TVector2); inline; static;

    // set next window collapsed state. call before Begin()
    class procedure SetNextWindowCollapsed(const ACollapsed: Boolean; const ACond: TImGuiCond = TImGuiCond(0)); inline; static;

    // set next window to be focused / top-most. call before Begin()
    class procedure SetNextWindowFocus; inline; static;

    // set next window scrolling value (use < 0.0f to not affect a given axis).
    class procedure SetNextWindowScroll(const AScroll: TVector2); inline; static;

    // set next window background color alpha. helper to easily override the Alpha component of ImGuiCol_WindowBg/ChildBg/PopupBg. you may also use ImGuiWindowFlags_NoBackground.
    class procedure SetNextWindowBgAlpha(const AAlpha: Single); inline; static;

    // (not recommended) set current window position - call within Begin()/End(). prefer using SetNextWindowPos(), as this may incur tearing and side-effects.
    class procedure SetWindowPos(const APos: TVector2; const ACond: TImGuiCond = TImGuiCond(0)); overload; inline; static;

    // (not recommended) set current window size - call within Begin()/End(). set to ImVec2(0, 0) to force an auto-fit. prefer using SetNextWindowSize(), as this may incur tearing and minor side-effects.
    class procedure SetWindowSize(const ASize: TVector2; const ACond: TImGuiCond = TImGuiCond(0)); overload; inline; static;

    // (not recommended) set current window collapsed state. prefer using SetNextWindowCollapsed().
    class procedure SetWindowCollapsed(const ACollapsed: Boolean; const ACond: TImGuiCond = TImGuiCond(0)); overload; inline; static;

    // (not recommended) set current window to be focused / top-most. prefer using SetNextWindowFocus().
    class procedure SetWindowFocus; overload; inline; static;

    // set named window position.
    class procedure SetWindowPos(const AName: PUTF8Char; const APos: TVector2; const ACond: TImGuiCond = TImGuiCond(0)); overload; inline; static;

    // set named window size. set axis to 0.0f to force an auto-fit on this axis.
    class procedure SetWindowSize(const AName: PUTF8Char; const ASize: TVector2; 
      const ACond: TImGuiCond = TImGuiCond(0)); overload; inline; static;

    // set named window collapsed state
    class procedure SetWindowCollapsed(const AName: PUTF8Char; const ACollapsed: Boolean; 
      const ACond: TImGuiCond = TImGuiCond(0)); overload; inline; static;

    // set named window to be focused / top-most. use NULL to remove focus.
    class procedure SetWindowFocus(const AName: PUTF8Char); overload; inline; static;

    // Windows Scrolling
    // - Any change of Scroll will be applied at the beginning of next frame in the first call to Begin().
    // - You may instead use SetNextWindowScroll() prior to calling Begin() to avoid this delay, as an alternative to using SetScrollX()/SetScrollY().
    // get scrolling amount [0 .. GetScrollMaxX()]
    class function GetScrollX: Single; inline; static;

    // get scrolling amount [0 .. GetScrollMaxY()]
    class function GetScrollY: Single; inline; static;

    // set scrolling amount [0 .. GetScrollMaxX()]
    class procedure SetScrollX(const AScrollX: Single); inline; static;

    // set scrolling amount [0 .. GetScrollMaxY()]
    class procedure SetScrollY(const AScrollY: Single); inline; static;

    // get maximum scrolling amount ~~ ContentSize.x - WindowSize.x - DecorationsSize.x
    class function GetScrollMaxX: Single; inline; static;

    // get maximum scrolling amount ~~ ContentSize.y - WindowSize.y - DecorationsSize.y
    class function GetScrollMaxY: Single; inline; static;

    // adjust scrolling amount to make current cursor position visible. center_x_ratio=0.0: left, 0.5: center, 1.0: right. When using to make a "default/current item" visible, consider using SetItemDefaultFocus() instead.
    class procedure SetScrollHereX(const ACenterXRatio: Single = 0.5); inline; static;

    // adjust scrolling amount to make current cursor position visible. center_y_ratio=0.0: top, 0.5: center, 1.0: bottom. When using to make a "default/current item" visible, consider using SetItemDefaultFocus() instead.
    class procedure SetScrollHereY(const ACenterYRatio: Single = 0.5); inline; static;

    // adjust scrolling amount to make given position visible. Generally GetCursorStartPos() + offset to compute a valid position.
    class procedure SetScrollFromPosX(const ALocalX: Single; const ACenterXRatio: Single = 0.5); inline; static;

    // adjust scrolling amount to make given position visible. Generally GetCursorStartPos() + offset to compute a valid position.
    class procedure SetScrollFromPosY(const ALocalY: Single; const ACenterYRatio: Single = 0.5); inline; static;

    // Parameters stacks (font)
    //  - PushFont(font, 0.0f)                       // Change font and keep current size
    //  - PushFont(NULL, 20.0f)                      // Keep font and change current size
    //  - PushFont(font, 20.0f)                      // Change font and set size to 20.0f
    //  - PushFont(font, style.FontSizeBase * 2.0f)  // Change font and set size to be twice bigger than current size.
    //  - PushFont(font, font->LegacySize)           // Change font and set size to size passed to AddFontXXX() function. Same as pre-1.92 behavior.
    // *IMPORTANT* before 1.92, fonts had a single size. They can now be dynamically be adjusted.
    //  - In 1.92 we have REMOVED the single parameter version of PushFont() because it seems like the easiest way to provide an error-proof transition.
    //  - PushFont(font) before 1.92 = PushFont(font, font->LegacySize) after 1.92          // Use default font size as passed to AddFontXXX() function.
    // *IMPORTANT* global scale factors are applied over the provided size.
    //  - Global scale factors are: 'style.FontScaleMain', 'style.FontScaleDpi' and maybe more.
    // -  If you want to apply a factor to the _current_ font size:
    //  - CORRECT:   PushFont(NULL, style.FontSizeBase)         // use current unscaled size    == does nothing
    //  - CORRECT:   PushFont(NULL, style.FontSizeBase * 2.0f)  // use current unscaled size x2 == make text twice bigger
    //  - INCORRECT: PushFont(NULL, GetFontSize())              // INCORRECT! using size after global factors already applied == GLOBAL SCALING FACTORS WILL APPLY TWICE!
    //  - INCORRECT: PushFont(NULL, GetFontSize() * 2.0f)       // INCORRECT! using size after global factors already applied == GLOBAL SCALING FACTORS WILL APPLY TWICE!
    // Use NULL as a shortcut to keep current font. Use 0.0f to keep current size.
    class procedure PushFont(const AFont: PImFont; const AFontSizeBaseUnscaled: Single); inline; static;
    class procedure PopFont; inline; static;

    // get current font
    class function GetFont: PImFont; inline; static;

    // get current scaled font size (= height in pixels). AFTER global scale factors applied. *IMPORTANT* DO NOT PASS THIS VALUE TO PushFont()! Use ImGui::GetStyle().FontSizeBase to get value before global scale factors.
    class function GetFontSize: Single; inline; static;

    // get current font bound at current size // == GetFont()->GetFontBaked(GetFontSize())
    class function GetFontBaked: PImFontBaked; inline; static;

    // Parameters stacks (shared)
    // modify a style color. always use this if you modify the style after NewFrame().
    class procedure PushStyleColor(const AIdx: TImGuiCol; const ACol: UInt32); overload; inline; static;
    class procedure PushStyleColor(const AIdx: TImGuiCol; const ACol: TVector4); overload; inline; static;
    class procedure PopStyleColor(const ACount: Int32 = 1); overload; inline; static;

    // modify a style float variable. always use this if you modify the style after NewFrame()!
    class procedure PushStyleVar(const AIdx: TImGuiStyleVar; const AVal: Single); overload; inline; static;

    // modify a style ImVec2 variable. "
    class procedure PushStyleVar(const AIdx: TImGuiStyleVar; const AVal: TVector2); overload; inline; static;

    // modify X component of a style ImVec2 variable. "
    class procedure PushStyleVarX(const AIdx: TImGuiStyleVar; const AValX: Single); inline; static;

    // modify Y component of a style ImVec2 variable. "
    class procedure PushStyleVarY(const AIdx: TImGuiStyleVar; const AValY: Single); inline; static;
    class procedure PopStyleVar(const ACount: Int32 = 1); overload; inline; static;

    // modify specified shared item flag, e.g. PushItemFlag(ImGuiItemFlags_NoTabStop, true)
    class procedure PushItemFlag(const AOption: TImGuiItemFlags; const AEnabled: Boolean); inline; static;
    class procedure PopItemFlag; inline; static;

    // Parameters stacks (current window)
    // push width of items for common large "item+label" widgets. >0.0f: width in pixels, <0.0f align xx pixels to the right of window (so -FLT_MIN always align width to the right side).
    class procedure PushItemWidth(const AItemWidth: Single); inline; static;
    class procedure PopItemWidth; inline; static;

    // set width of the _next_ common large "item+label" widget. >0.0f: width in pixels, <0.0f align xx pixels to the right of window (so -FLT_MIN always align width to the right side)
    class procedure SetNextItemWidth(const AItemWidth: Single); inline; static;

    // width of item given pushed settings and current cursor position. NOT necessarily the width of last item unlike most 'Item' functions.
    class function CalcItemWidth: Single; inline; static;

    // push word-wrapping position for Text*() commands. < 0.0f: no wrapping; 0.0f: wrap to end of window (or column); > 0.0f: wrap at 'wrap_pos_x' position in window local space
    class procedure PushTextWrapPos(const AWrapLocalPosX: Single = 0.0); inline; static;
    class procedure PopTextWrapPos; inline; static;

    // Style read access
    // - Use the ShowStyleEditor() function to interactively see/edit the colors.
    // get UV coordinate for a white pixel, useful to draw custom shapes via the ImDrawList API
    class function GetFontTexUvWhitePixel: TVector2; inline; static;

    // retrieve given style color with style alpha applied and optional extra alpha multiplier, packed as a 32-bit value suitable for ImDrawList
    class function GetColorU32(const AIdx: TImGuiCol; const AAlphaMul: Single = 1.0): UInt32; overload; inline; static;

    // retrieve given color with style alpha applied, packed as a 32-bit value suitable for ImDrawList
    class function GetColorU32(const ACol: TVector4): UInt32; overload; inline; static;

    // retrieve given color with style alpha applied, packed as a 32-bit value suitable for ImDrawList
    class function GetColorU32(const ACol: UInt32; const AAlphaMul: Single = 1.0): UInt32; overload; inline; static;

    // retrieve style color as stored in ImGuiStyle structure. use to feed back into PushStyleColor(), otherwise use GetColorU32() to get style color with style alpha baked in.
    class function GetStyleColorVec4(const AIdx: TImGuiCol): PVector4; inline; static;

    // Layout cursor positioning
    // - By "cursor" we mean the current output position.
    // - The typical widget behavior is to output themselves at the current cursor position, then move the cursor one line down.
    // - You can call SameLine() between widgets to undo the last carriage return and output at the right of the preceding widget.
    // - YOU CAN DO 99% OF WHAT YOU NEED WITH ONLY GetCursorScreenPos() and GetContentRegionAvail().
    // - Attention! We currently have inconsistencies between window-local and absolute positions we will aim to fix with future API:
    //    - Absolute coordinate:        GetCursorScreenPos(), SetCursorScreenPos(), all ImDrawList:: functions. -> this is the preferred way forward.
    //    - Window-local coordinates:   SameLine(offset), GetCursorPos(), SetCursorPos(), GetCursorStartPos(), PushTextWrapPos()
    //    - Window-local coordinates:   GetContentRegionMax(), GetWindowContentRegionMin(), GetWindowContentRegionMax() --> all obsoleted. YOU DON'T NEED THEM.
    // - GetCursorScreenPos() = GetCursorPos() + GetWindowPos(). GetWindowPos() is almost only ever useful to convert from window-local to absolute coordinates. Try not to use it.
    // cursor position, absolute coordinates. THIS IS YOUR BEST FRIEND (prefer using this rather than GetCursorPos(), also more useful to work with ImDrawList API).
    class function GetCursorScreenPos: TVector2; inline; static;

    // cursor position, absolute coordinates. THIS IS YOUR BEST FRIEND.
    class procedure SetCursorScreenPos(const APos: TVector2); inline; static;

    // available space from current position. THIS IS YOUR BEST FRIEND.
    class function GetContentRegionAvail: TVector2; inline; static;

    // [window-local] cursor position in window-local coordinates. This is not your best friend.
    class function GetCursorPos: TVector2; inline; static;

    // [window-local] "
    class function GetCursorPosX: Single; inline; static;

    // [window-local] "
    class function GetCursorPosY: Single; inline; static;

    // [window-local] "
    class procedure SetCursorPos(const ALocalPos: TVector2); inline; static;

    // [window-local] "
    class procedure SetCursorPosX(const ALocalX: Single); inline; static;

    // [window-local] "
    class procedure SetCursorPosY(const ALocalY: Single); inline; static;

    // [window-local] initial cursor position, in window-local coordinates. Call GetCursorScreenPos() after Begin() to get the absolute coordinates version.
    class function GetCursorStartPos: TVector2; inline; static;

    // Other layout functions
    // separator, generally horizontal. inside a menu bar or in horizontal layout mode, this becomes a vertical separator.
    class procedure Separator; inline; static;

    // call between widgets or groups to layout them horizontally. X position given in window coordinates.
    class procedure SameLine(const AOffsetFromStartX: Single = 0.0; const ASpacing: Single = -1.0); overload; inline; static;

    // undo a SameLine() or force a new line when in a horizontal-layout context.
    class procedure NewLine; inline; static;

    // add vertical spacing.
    class procedure Spacing; inline; static;

    // add a dummy item of given size. unlike InvisibleButton(), Dummy() won't take the mouse click or be navigable into.
    class procedure Dummy(const ASize: TVector2); inline; static;

    // move content position toward the right, by indent_w, or style.IndentSpacing if indent_w <= 0
    class procedure Indent(const AIndentW: Single = 0.0); overload; inline; static;

    // move content position back to the left, by indent_w, or style.IndentSpacing if indent_w <= 0
    class procedure Unindent(const AIndentW: Single = 0.0); overload; inline; static;

    // lock horizontal starting position
    class procedure BeginGroup; inline; static;

    // unlock horizontal starting position + capture the whole group bounding box into one "item" (so you can use IsItemHovered() or layout primitives such as SameLine() on whole group, etc.)
    class procedure EndGroup; inline; static;

    // vertically align upcoming text baseline to FramePadding.y so that it will align properly to regularly framed items (call if you have text on a line before a framed item)
    class procedure AlignTextToFramePadding; inline; static;

    // ~ FontSize
    class function GetTextLineHeight: Single; inline; static;

    // ~ FontSize + style.ItemSpacing.y (distance in pixels between 2 consecutive lines of text)
    class function GetTextLineHeightWithSpacing: Single; inline; static;

    // ~ FontSize + style.FramePadding.y * 2
    class function GetFrameHeight: Single; inline; static;

    // ~ FontSize + style.FramePadding.y * 2 + style.ItemSpacing.y (distance in pixels between 2 consecutive lines of framed widgets)
    class function GetFrameHeightWithSpacing: Single; inline; static;

    // ID stack/scopes
    // Read the FAQ (docs/FAQ.md or http://dearimgui.com/faq) for more details about how ID are handled in dear imgui.
    // - Those questions are answered and impacted by understanding of the ID stack system:
    //   - "Q: Why is my widget not reacting when I click on it?"
    //   - "Q: How can I have widgets with an empty label?"
    //   - "Q: How can I have multiple widgets with the same label?"
    // - Short version: ID are hashes of the entire ID stack. If you are creating widgets in a loop you most likely
    //   want to push a unique identifier (e.g. object pointer, loop index) to uniquely differentiate them.
    // - You can also use the "Label##foobar" syntax within widget label to distinguish them from each others.
    // - In this header file we use the "label"/"name" terminology to denote a string that will be displayed + used as an ID,
    //   whereas "str_id" denote a string that is only used as an ID and not normally displayed.
    // push string into the ID stack (will hash string).
    class procedure PushID(const AStrId: PUTF8Char); overload; inline; static;

    // push string into the ID stack (will hash string).
    class procedure PushID(const AStrIdBegin, AStrIdEnd: PUTF8Char); overload; inline; static;

    // push pointer into the ID stack (will hash pointer).
    class procedure PushID(const APtrId: Pointer); overload; inline; static;

    // push integer into the ID stack (will hash integer).
    class procedure PushID(const AIntId: Int32); overload; inline; static;

    // pop from the ID stack.
    class procedure PopID; inline; static;

    // calculate unique ID (hash of whole ID stack + given parameter). e.g. if you want to query into ImGuiStorage yourself
    class function GetID(const AStrId: PUTF8Char): TImGuiID; overload; inline; static;
    class function GetID(const AStrIdBegin, AStrIdEnd: PUTF8Char): TImGuiID; overload; inline; static;
    class function GetID(const APtrId: Pointer): TImGuiID; overload; inline; static;
    class function GetID(const AIntId: Int32): TImGuiID; overload; inline; static;

    // raw text without formatting. Roughly equivalent to Text("%s", text) but: A) doesn't require null terminated string if 'text_end' is specified, B) it's faster, no memory copy is done, no buffer size limits, recommended for long chunks of text.
    class procedure TextUnformatted(const AText: PUTF8Char; const ATextEnd: PUTF8Char = nil); overload; inline; static;

    // formatted text
    class procedure Text(const AFmt: PUTF8Char); inline; static;

    // shortcut for PushStyleColor(ImGuiCol_Text, col); Text(fmt, ...); PopStyleColor();
    class procedure TextColored(const ACol: TVector4; const AFmt: PUTF8Char); inline; static;

    // shortcut for PushStyleColor(ImGuiCol_Text, style.Colors[ImGuiCol_TextDisabled]); Text(fmt, ...); PopStyleColor();
    class procedure TextDisabled(const AFmt: PUTF8Char); inline; static;

    // shortcut for PushTextWrapPos(0.0f); Text(fmt, ...); PopTextWrapPos();. Note that this won't work on an auto-resizing window if there's no other widgets to extend the window width, yoy may need to set a size using SetNextWindowSize().
    class procedure TextWrapped(const AFmt: PUTF8Char); inline; static;

    // display text+label aligned the same way as value+label widgets
    class procedure LabelText(const ALabel, AFmt: PUTF8Char); inline; static;

    // shortcut for Bullet()+Text()
    class procedure BulletText(const AFmt: PUTF8Char); inline; static;

    // currently: formatted text with a horizontal line
    class procedure SeparatorText(const ALabel: PUTF8Char); inline; static;

    // Widgets: Main
    // - Most widgets return true when the value has been changed or when pressed/selected
    // - You may also use one of the many IsItemXXX functions (e.g. IsItemActive, IsItemHovered, etc.) to query widget state.
    // Implied size = ImVec2(0, 0)
    class function Button(const ALabel: PUTF8Char): Boolean; overload; inline; static;

    // button
    class function Button(const ALabel: PUTF8Char; const ASize: TVector2): Boolean; overload; inline; static;

    // button with (FramePadding.y == 0) to easily embed within text
    class function SmallButton(const ALabel: PUTF8Char): Boolean; inline; static;

    // flexible button behavior without the visuals, frequently useful to build custom behaviors using the public api (along with IsItemActive, IsItemHovered, etc.)
    class function InvisibleButton(const AStrId: PUTF8Char; const ASize: TVector2; 
      const AFlags: TImGuiButtonFlags = []): Boolean; inline; static;

    // square button with an arrow shape
    class function ArrowButton(const AStrId: PUTF8Char; const ADir: TImGuiDir): Boolean; inline; static;
    class function Checkbox(const ALabel: PUTF8Char; const AV: PBoolean): Boolean; inline; static;
    class function CheckboxFlags(const ALabel: PUTF8Char; const AFlags: PInt32; 
      const AFlagsValue: Int32): Boolean; overload; inline; static;
    class function CheckboxFlags(const ALabel: PUTF8Char; const AFlags: PUInt32; 
      const AFlagsValue: UInt32): Boolean; overload; inline; static;

    // use with e.g. if (RadioButton("one", my_value==1)) { my_value = 1; }
    class function RadioButton(const ALabel: PUTF8Char; const AActive: Boolean): Boolean; overload; inline; static;

    // shortcut to handle the above pattern when value is an integer
    class function RadioButton(const ALabel: PUTF8Char; const AV: PInt32; const AVButton: Int32): Boolean; overload; inline; static;
    class procedure ProgressBar(const AFraction: Single; const ASizeArg: TVector2; 
      const AOverlay: PUTF8Char = nil); overload; inline; static;
    class procedure ProgressBar(const AFraction: Single; const AOverlay: PUTF8Char = nil); overload; inline; static;

    // draw a small circle + keep the cursor on the same line. advance cursor x position by GetTreeNodeToLabelSpacing(), same distance that TreeNode() uses
    class procedure Bullet; inline; static;

    // hyperlink text button, return true when clicked
    class function TextLink(const ALabel: PUTF8Char): Boolean; inline; static;

    // hyperlink text button, automatically open file/url when clicked
    class function TextLinkOpenURL(const ALabel: PUTF8Char; const AUrl: PUTF8Char = nil): Boolean; overload; inline; static;

    // Widgets: Images
    // - Read about ImTextureID/ImTextureRef  here: https://github.com/ocornut/imgui/wiki/Image-Loading-and-Displaying-Examples
    // - 'uv0' and 'uv1' are texture coordinates. Read about them from the same link above.
    // - Image() pads adds style.ImageBorderSize on each side, ImageButton() adds style.FramePadding on each side.
    // - ImageButton() draws a background based on regular Button() color + optionally an inner background if specified.
    // - An obsolete version of Image(), before 1.91.9 (March 2025), had a 'tint_col' parameter which is now supported by the ImageWithBg() function.
    // Implied uv0 = ImVec2(0, 0), uv1 = ImVec2(1, 1)
    class procedure Image(const ATexRef: TImTextureRef; const AImageSize: TVector2); overload; inline; static;
    class procedure Image(const ATexRef: TImTextureRef; const AImageSize, AUv0, 
      AUv1: TVector2); overload; inline; static;
    class procedure Image(const ATexRef: TImTextureRef; const AImageSize, AUv0: TVector2); overload; inline; static;

    // Implied uv0 = ImVec2(0, 0), uv1 = ImVec2(1, 1), bg_col = ImVec4(0, 0, 0, 0), tint_col = ImVec4(1, 1, 1, 1)
    class procedure ImageWithBg(const ATexRef: TImTextureRef; const AImageSize: TVector2); overload; inline; static;
    class procedure ImageWithBg(const ATexRef: TImTextureRef; const AImageSize, 
      AUv0, AUv1: TVector2; const ABgCol, ATintCol: TVector4); overload; inline; static;
    class procedure ImageWithBg(const ATexRef: TImTextureRef; const AImageSize,
      AUv0, AUv1: TVector2; const ABgCol: TVector4); overload; inline; static;
    class procedure ImageWithBg(const ATexRef: TImTextureRef; const AImageSize,
      AUv0, AUv1: TVector2); overload; inline; static;
    class procedure ImageWithBg(const ATexRef: TImTextureRef; const AImageSize,
      AUv0: TVector2); overload; inline; static;

    // Implied uv0 = ImVec2(0, 0), uv1 = ImVec2(1, 1), bg_col = ImVec4(0, 0, 0, 0), tint_col = ImVec4(1, 1, 1, 1)
    class function ImageButton(const AStrId: PUTF8Char; const ATexRef: TImTextureRef; 
      const AImageSize: TVector2): Boolean; overload; inline; static;
    class function ImageButton(const AStrId: PUTF8Char; const ATexRef: TImTextureRef; 
      const AImageSize, AUv0, AUv1: TVector2; const ABgCol, ATintCol: TVector4): Boolean; overload; inline; static;
    class function ImageButton(const AStrId: PUTF8Char; const ATexRef: TImTextureRef;
      const AImageSize, AUv0, AUv1: TVector2; const ABgCol: TVector4): Boolean; overload; inline; static;
    class function ImageButton(const AStrId: PUTF8Char; const ATexRef: TImTextureRef;
      const AImageSize, AUv0, AUv1: TVector2): Boolean; overload; inline; static;
    class function ImageButton(const AStrId: PUTF8Char; const ATexRef: TImTextureRef;
      const AImageSize, AUv0: TVector2): Boolean; overload; inline; static;

    // Widgets: Combo Box (Dropdown)
    // - The BeginCombo()/EndCombo() api allows you to manage your contents and selection state however you want it, by creating e.g. Selectable() items.
    // - The old Combo() api are helpers over BeginCombo()/EndCombo() which are kept available for convenience purpose. This is analogous to how ListBox are created.
    class function BeginCombo(const ALabel, APreviewValue: PUTF8Char; const AFlags: TImGuiComboFlags = []): Boolean; inline; static;

    // only call EndCombo() if BeginCombo() returns true!
    class procedure EndCombo; inline; static;

    // Implied popup_max_height_in_items = -1
    class function Combo(const ALabel: PUTF8Char; const ACurrentItem: PInt32; const AItems: PPUTF8Char; 
      const AItemsCount: Int32): Boolean; overload; inline; static;
    class function Combo(const ALabel: PUTF8Char; const ACurrentItem: PInt32; const AItems: PPUTF8Char; 
      const AItemsCount: Int32; const APopupMaxHeightInItems: Int32 = -1): Boolean; overload; inline; static;

    // Separate items with \0 within a string, end item-list with \0\0. e.g. "One\0Two\0Three\0"
    class function Combo(const ALabel: PUTF8Char; const ACurrentItem: PInt32; const AItemsSeparatedByZeros: PUTF8Char; 
      const APopupMaxHeightInItems: Int32 = -1): Boolean; overload; inline; static;

    // Implied popup_max_height_in_items = -1
    class function Combo(const ALabel: PUTF8Char; const ACurrentItem: PInt32; const AGetter: TImGuiStringGetter; 
      const AUserData: Pointer; const AItemsCount: Int32): Boolean; overload; inline; static;
    class function Combo(const ALabel: PUTF8Char; const ACurrentItem: PInt32; const AGetter: TImGuiStringGetter; 
      const AUserData: Pointer; const AItemsCount: Int32; const APopupMaxHeightInItems: Int32 = -1): Boolean; overload; inline; static;

    // Widgets: Drag Sliders
    // - Ctrl+Click on any drag box to turn them into an input box. Manually input values aren't clamped by default and can go off-bounds. Use ImGuiSliderFlags_AlwaysClamp to always clamp.
    // - For all the Float2/Float3/Float4/Int2/Int3/Int4 versions of every function, note that a 'float v[X]' function argument is the same as 'float* v',
    //   the array syntax is just a way to document the number of elements that are expected to be accessible. You can pass address of your first element out of a contiguous set, e.g. &myvector.x
    // - Adjust format string to decorate the value with a prefix, a suffix, or adapt the editing and display precision e.g. "%.3f" -> 1.234; "%5.2f secs" -> 01.23 secs; "Biscuit: %.0f" -> Biscuit: 1; etc.
    // - Format string may also be set to NULL or use the default format ("%f" or "%d").
    // - Speed are per-pixel of mouse movement (v_speed=0.2f: mouse needs to move by 5 pixels to increase value by 1). For keyboard/gamepad navigation, minimum speed is Max(v_speed, minimum_step_at_given_precision).
    // - Use v_min < v_max to clamp edits to given limits. Note that Ctrl+Click manual input can override those limits if ImGuiSliderFlags_AlwaysClamp is not used.
    // - Use v_max = FLT_MAX / INT_MAX etc to avoid clamping to a maximum, same with v_min = -FLT_MAX / INT_MIN to avoid clamping to a minimum.
    // - We use the same sets of flags for DragXXX() and SliderXXX() functions as the features are the same and it makes it easier to swap them.
    // - Legacy: Pre-1.78 there are DragXXX() function signatures that take a final `float power=1.0f' argument instead of the `ImGuiSliderFlags flags=0' argument.
    //   If you get a warning converting a float to ImGuiSliderFlags, read https://github.com/ocornut/imgui/issues/3361
    // Implied v_speed = 1.0f, v_min = 0.0f, v_max = 0.0f, format = "%.3f", flags = 0
    class function DragFloat(const ALabel: PUTF8Char; const AV: PSingle): Boolean; overload; inline; static;

    // If v_min >= v_max we have no bound
    class function DragFloat(const ALabel: PUTF8Char; const AV: PSingle; const AVSpeed: Single; 
      const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function DragFloat(const ALabel: PUTF8Char; const AV: PSingle; const AVSpeed: Single = 1.0;
      const AVMin: Single = 0.0; const AVMax: Single = 0.0): Boolean; overload; inline; static;

    // Implied v_speed = 1.0f, v_min = 0.0f, v_max = 0.0f, format = "%.3f", flags = 0
    class function DragFloat2(const ALabel: PUTF8Char; const AV: PSingle): Boolean; overload; inline; static;
    class function DragFloat2(const ALabel: PUTF8Char; const AV: PSingle; const AVSpeed: Single; 
      const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function DragFloat2(const ALabel: PUTF8Char; const AV: PSingle; const AVSpeed: Single = 1.0;
      const AVMin: Single = 0.0; const AVMax: Single = 0.0): Boolean; overload; inline; static;

    // Implied v_speed = 1.0f, v_min = 0.0f, v_max = 0.0f, format = "%.3f", flags = 0
    class function DragFloat3(const ALabel: PUTF8Char; const AV: PSingle): Boolean; overload; inline; static;
    class function DragFloat3(const ALabel: PUTF8Char; const AV: PSingle; const AVSpeed: Single; 
      const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function DragFloat3(const ALabel: PUTF8Char; const AV: PSingle; const AVSpeed: Single = 1.0;
      const AVMin: Single = 0.0; const AVMax: Single = 0.0): Boolean; overload; inline; static;

    // Implied v_speed = 1.0f, v_min = 0.0f, v_max = 0.0f, format = "%.3f", flags = 0
    class function DragFloat4(const ALabel: PUTF8Char; const AV: PSingle): Boolean; overload; inline; static;
    class function DragFloat4(const ALabel: PUTF8Char; const AV: PSingle; const AVSpeed: Single; 
      const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function DragFloat4(const ALabel: PUTF8Char; const AV: PSingle; const AVSpeed: Single = 1.0;
      const AVMin: Single = 0.0; const AVMax: Single = 0.0): Boolean; overload; inline; static;

    // Implied v_speed = 1.0f, v_min = 0.0f, v_max = 0.0f, format = "%.3f", format_max = NULL, flags = 0
    class function DragFloatRange2(const ALabel: PUTF8Char; const AVCurrentMin, 
      AVCurrentMax: PSingle): Boolean; overload; inline; static;
    class function DragFloatRange2(const ALabel: PUTF8Char; const AVCurrentMin, 
      AVCurrentMax: PSingle; const AVSpeed: Single; const AVMin: Single; const AVMax: Single; 
      const AFormat: PUTF8Char; const AFormatMax: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function DragFloatRange2(const ALabel: PUTF8Char; const AVCurrentMin,
      AVCurrentMax: PSingle; const AVSpeed: Single = 1.0; const AVMin: Single = 0.0;
      const AVMax: Single = 0.0): Boolean; overload; inline; static;

    // Implied v_speed = 1.0f, v_min = 0, v_max = 0, format = "%d", flags = 0
    class function DragInt(const ALabel: PUTF8Char; const AV: PInt32): Boolean; overload; inline; static;

    // If v_min >= v_max we have no bound
    class function DragInt(const ALabel: PUTF8Char; const AV: PInt32; const AVSpeed: Single; 
      const AVMin: Int32; const AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function DragInt(const ALabel: PUTF8Char; const AV: PInt32; const AVSpeed: Single = 1.0;
      const AVMin: Int32 = 0; const AVMax: Int32 = 0): Boolean; overload; inline; static;

    // Implied v_speed = 1.0f, v_min = 0, v_max = 0, format = "%d", flags = 0
    class function DragInt2(const ALabel: PUTF8Char; const AV: PInt32): Boolean; overload; inline; static;
    class function DragInt2(const ALabel: PUTF8Char; const AV: PInt32; const AVSpeed: Single; 
      const AVMin: Int32; const AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function DragInt2(const ALabel: PUTF8Char; const AV: PInt32; const AVSpeed: Single = 1.0;
      const AVMin: Int32 = 0; const AVMax: Int32 = 0): Boolean; overload; inline; static;

    // Implied v_speed = 1.0f, v_min = 0, v_max = 0, format = "%d", flags = 0
    class function DragInt3(const ALabel: PUTF8Char; const AV: PInt32): Boolean; overload; inline; static;
    class function DragInt3(const ALabel: PUTF8Char; const AV: PInt32; const AVSpeed: Single; 
      const AVMin: Int32; const AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function DragInt3(const ALabel: PUTF8Char; const AV: PInt32; const AVSpeed: Single = 1.0;
      const AVMin: Int32 = 0; const AVMax: Int32 = 0): Boolean; overload; inline; static;

    // Implied v_speed = 1.0f, v_min = 0, v_max = 0, format = "%d", flags = 0
    class function DragInt4(const ALabel: PUTF8Char; const AV: PInt32): Boolean; overload; inline; static;
    class function DragInt4(const ALabel: PUTF8Char; const AV: PInt32; const AVSpeed: Single; 
      const AVMin: Int32; const AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function DragInt4(const ALabel: PUTF8Char; const AV: PInt32; const AVSpeed: Single = 1.0;
      const AVMin: Int32 = 0; const AVMax: Int32 = 0): Boolean; overload; inline; static;

    // Implied v_speed = 1.0f, v_min = 0, v_max = 0, format = "%d", format_max = NULL, flags = 0
    class function DragIntRange2(const ALabel: PUTF8Char; const AVCurrentMin, AVCurrentMax: PInt32): Boolean; overload; inline; static;
    class function DragIntRange2(const ALabel: PUTF8Char; const AVCurrentMin, AVCurrentMax: PInt32; 
      const AVSpeed: Single; const AVMin: Int32; const AVMax: Int32; const AFormat: PUTF8Char; 
      const AFormatMax: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function DragIntRange2(const ALabel: PUTF8Char; const AVCurrentMin,
      AVCurrentMax: PInt32; const AVSpeed: Single = 1.0; const AVMin: Int32 = 0;
      const AVMax: Int32 = 0): Boolean; overload; inline; static;
    class function DragScalar(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; 
      const APData: Pointer; const AVSpeed: Single = 1.0; const APMin: Pointer = nil; 
      const APMax: Pointer = nil; const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function DragScalarN(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; 
      const APData: Pointer; const AComponents: Int32; const AVSpeed: Single = 1.0; 
      const APMin: Pointer = nil; const APMax: Pointer = nil; const AFormat: PUTF8Char = nil; 
      const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;

    // Widgets: Regular Sliders
    // - Ctrl+Click on any slider to turn them into an input box. Manually input values aren't clamped by default and can go off-bounds. Use ImGuiSliderFlags_AlwaysClamp to always clamp.
    // - Adjust format string to decorate the value with a prefix, a suffix, or adapt the editing and display precision e.g. "%.3f" -> 1.234; "%5.2f secs" -> 01.23 secs; "Biscuit: %.0f" -> Biscuit: 1; etc.
    // - Format string may also be set to NULL or use the default format ("%f" or "%d").
    // - Legacy: Pre-1.78 there are SliderXXX() function signatures that take a final `float power=1.0f' argument instead of the `ImGuiSliderFlags flags=0' argument.
    //   If you get a warning converting a float to ImGuiSliderFlags, read https://github.com/ocornut/imgui/issues/3361
    // Implied format = "%.3f", flags = 0
    class function SliderFloat(const ALabel: PUTF8Char; const AV: PSingle; const AVMin, 
      AVMax: Single): Boolean; overload; inline; static;

    // adjust format to decorate the value with a prefix or a suffix for in-slider labels or unit display.
    class function SliderFloat(const ALabel: PUTF8Char; const AV: PSingle; const AVMin, 
      AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function SliderFloat(const ALabel: PUTF8Char; const AV: PSingle;
      const AVMin: Single = 0.0): Boolean; overload; inline; static;

    // Implied format = "%.3f", flags = 0
    class function SliderFloat2(const ALabel: PUTF8Char; const AV: PSingle; const AVMin, 
      AVMax: Single): Boolean; overload; inline; static;
    class function SliderFloat2(const ALabel: PUTF8Char; const AV: PSingle; const AVMin, 
      AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function SliderFloat2(const ALabel: PUTF8Char; const AV: PSingle;
      const AVMin: Single = 0.0): Boolean; overload; inline; static;

    // Implied format = "%.3f", flags = 0
    class function SliderFloat3(const ALabel: PUTF8Char; const AV: PSingle; const AVMin, 
      AVMax: Single): Boolean; overload; inline; static;
    class function SliderFloat3(const ALabel: PUTF8Char; const AV: PSingle; const AVMin, 
      AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function SliderFloat3(const ALabel: PUTF8Char; const AV: PSingle;
      const AVMin: Single = 0.0): Boolean; overload; inline; static;

    // Implied format = "%.3f", flags = 0
    class function SliderFloat4(const ALabel: PUTF8Char; const AV: PSingle; const AVMin, 
      AVMax: Single): Boolean; overload; inline; static;
    class function SliderFloat4(const ALabel: PUTF8Char; const AV: PSingle; const AVMin, 
      AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function SliderFloat4(const ALabel: PUTF8Char; const AV: PSingle;
      const AVMin: Single = 0.0): Boolean; overload; inline; static;

    // Implied v_degrees_min = -360.0f, v_degrees_max = +360.0f, format = "%.0f deg", flags = 0
    class function SliderAngle(const ALabel: PUTF8Char; const AVRad: PSingle): Boolean; overload; inline; static;
    class function SliderAngle(const ALabel: PUTF8Char; const AVRad: PSingle; const AVDegreesMin: Single; 
      const AVDegreesMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function SliderAngle(const ALabel: PUTF8Char; const AVRad: PSingle;
      const AVDegreesMin: Single = -360.0; const AVDegreesMax: Single = 360.0): Boolean; overload; inline; static;

    // Implied format = "%d", flags = 0
    class function SliderInt(const ALabel: PUTF8Char; const AV: PInt32; const AVMin, 
      AVMax: Int32): Boolean; overload; inline; static;
    class function SliderInt(const ALabel: PUTF8Char; const AV: PInt32; const AVMin, 
      AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function SliderInt(const ALabel: PUTF8Char; const AV: PInt32;
      const AVMin: Int32 = 0): Boolean; overload; inline; static;

    // Implied format = "%d", flags = 0
    class function SliderInt2(const ALabel: PUTF8Char; const AV: PInt32; const AVMin, 
      AVMax: Int32): Boolean; overload; inline; static;
    class function SliderInt2(const ALabel: PUTF8Char; const AV: PInt32; const AVMin, 
      AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function SliderInt2(const ALabel: PUTF8Char; const AV: PInt32;
      const AVMin: Int32 = 0): Boolean; overload; inline; static;

    // Implied format = "%d", flags = 0
    class function SliderInt3(const ALabel: PUTF8Char; const AV: PInt32; const AVMin, 
      AVMax: Int32): Boolean; overload; inline; static;
    class function SliderInt3(const ALabel: PUTF8Char; const AV: PInt32; const AVMin, 
      AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function SliderInt3(const ALabel: PUTF8Char; const AV: PInt32;
      const AVMin: Int32 = 0): Boolean; overload; inline; static;

    // Implied format = "%d", flags = 0
    class function SliderInt4(const ALabel: PUTF8Char; const AV: PInt32; const AVMin, 
      AVMax: Int32): Boolean; overload; inline; static;
    class function SliderInt4(const ALabel: PUTF8Char; const AV: PInt32; const AVMin, 
      AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function SliderInt4(const ALabel: PUTF8Char; const AV: PInt32;
      const AVMin: Int32 = 0): Boolean; overload; inline; static;
    class function SliderScalar(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; 
      const APData: Pointer; const APMin, APMax: Pointer; const AFormat: PUTF8Char = nil; 
      const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function SliderScalarN(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; 
      const APData: Pointer; const AComponents: Int32; const APMin, APMax: Pointer; 
      const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;

    // Implied format = "%.3f", flags = 0
    class function VSliderFloat(const ALabel: PUTF8Char; const ASize: TVector2; 
      const AV: PSingle; const AVMin, AVMax: Single): Boolean; overload; inline; static;
    class function VSliderFloat(const ALabel: PUTF8Char; const ASize: TVector2; 
      const AV: PSingle; const AVMin, AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function VSliderFloat(const ALabel: PUTF8Char; const ASize: TVector2;
      const AV: PSingle; const AVMin: Single = 0.0): Boolean; overload; inline; static;

    // Implied format = "%d", flags = 0
    class function VSliderInt(const ALabel: PUTF8Char; const ASize: TVector2; const AV: PInt32; 
      const AVMin, AVMax: Int32): Boolean; overload; inline; static;
    class function VSliderInt(const ALabel: PUTF8Char; const ASize: TVector2; const AV: PInt32; 
      const AVMin, AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function VSliderInt(const ALabel: PUTF8Char; const ASize: TVector2;
      const AV: PInt32; const AVMin: Int32 = 0): Boolean; overload; inline; static;
    class function VSliderScalar(const ALabel: PUTF8Char; const ASize: TVector2; 
      const ADataType: TImGuiDataType; const APData: Pointer; const APMin, APMax: Pointer; 
      const AFormat: PUTF8Char = nil; const AFlags: TImGuiSliderFlags = []): Boolean; overload; inline; static;
    class function InputText(const ALabel: PUTF8Char; const ABuf: PUTF8Char; const ABufSize: NativeUInt; 
      const AFlags: TImGuiInputTextFlags = []; const ACallback: TImGuiInputTextCallback = nil; 
      const AUserData: Pointer = nil): Boolean; overload; inline; static;
    class function InputText(const ALabel: PUTF8Char; const AText: TImGUiText;
      const AFlags: TImGuiInputTextFlags = []): Boolean; overload; inline; static;

    // Implied size = ImVec2(0, 0), flags = 0, callback = NULL, user_data = NULL
    class function InputTextMultiline(const ALabel: PUTF8Char; const ABuf: PUTF8Char; 
      const ABufSize: NativeUInt): Boolean; overload; inline; static;
    class function InputTextMultiline(const ALabel: PUTF8Char; const AText: TImGuiText): Boolean; overload; static; inline;
    class function InputTextMultiline(const ALabel: PUTF8Char; const AText: TImGuiText;
      const ASize: TVector2; const AFlags: TImGuiInputTextFlags = []): Boolean; overload; static; inline;
    class function InputTextMultiline(const ALabel: PUTF8Char; const ABuf: PUTF8Char; 
      const ABufSize: NativeUInt; const ASize: TVector2; const AFlags: TImGuiInputTextFlags = []; 
      const ACallback: TImGuiInputTextCallback = nil; const AUserData: Pointer = nil): Boolean; overload; inline; static;
    class function InputTextWithHint(const ALabel, AHint: PUTF8Char; const ABuf: PUTF8Char; 
      const ABufSize: NativeUInt; const AFlags: TImGuiInputTextFlags = []; const ACallback: TImGuiInputTextCallback = nil; 
      const AUserData: Pointer = nil): Boolean; overload; inline; static;
    class function InputTextWithHint(const ALabel, AHint: PUTF8Char; const AText: TImGUiText;
      const AFlags: TImGuiInputTextFlags = []): Boolean; overload; inline; static;

    // Implied step = 0.0f, step_fast = 0.0f, format = "%.3f", flags = 0
    class function InputFloat(const ALabel: PUTF8Char; const AV: PSingle): Boolean; overload; inline; static;
    class function InputFloat(const ALabel: PUTF8Char; const AV: PSingle; const AStep: Single; 
      const AStepFast: Single; const AFormat: PUTF8Char; const AFlags: TImGuiInputTextFlags = []): Boolean; overload; inline; static;
    class function InputFloat(const ALabel: PUTF8Char; const AV: PSingle; const AStep: Single;
      const AStepFast: Single = 0.0): Boolean; overload; inline; static;

    // Implied format = "%.3f", flags = 0
    class function InputFloat2(const ALabel: PUTF8Char; const AV: PSingle): Boolean; overload; inline; static;
    class function InputFloat2(const ALabel: PUTF8Char; const AV: PSingle; const AFormat: PUTF8Char; 
      const AFlags: TImGuiInputTextFlags = []): Boolean; overload; inline; static;

    // Implied format = "%.3f", flags = 0
    class function InputFloat3(const ALabel: PUTF8Char; const AV: PSingle): Boolean; overload; inline; static;
    class function InputFloat3(const ALabel: PUTF8Char; const AV: PSingle; const AFormat: PUTF8Char; 
      const AFlags: TImGuiInputTextFlags = []): Boolean; overload; inline; static;

    // Implied format = "%.3f", flags = 0
    class function InputFloat4(const ALabel: PUTF8Char; const AV: PSingle): Boolean; overload; inline; static;
    class function InputFloat4(const ALabel: PUTF8Char; const AV: PSingle; const AFormat: PUTF8Char; 
      const AFlags: TImGuiInputTextFlags = []): Boolean; overload; inline; static;
    class function InputInt(const ALabel: PUTF8Char; const AV: PInt32; const AStep: Int32 = 1; 
      const AStepFast: Int32 = 100; const AFlags: TImGuiInputTextFlags = []): Boolean; overload; inline; static;
    class function InputInt2(const ALabel: PUTF8Char; const AV: PInt32; const AFlags: TImGuiInputTextFlags = []): Boolean; inline; static;
    class function InputInt3(const ALabel: PUTF8Char; const AV: PInt32; const AFlags: TImGuiInputTextFlags = []): Boolean; inline; static;
    class function InputInt4(const ALabel: PUTF8Char; const AV: PInt32; const AFlags: TImGuiInputTextFlags = []): Boolean; inline; static;

    // Implied step = 0.0, step_fast = 0.0, format = "%.6f", flags = 0
    class function InputDouble(const ALabel: PUTF8Char; const AV: PDouble): Boolean; overload; inline; static;
    class function InputDouble(const ALabel: PUTF8Char; const AV: PDouble; const AStep: Double; 
      const AStepFast: Double; const AFormat: PUTF8Char; const AFlags: TImGuiInputTextFlags = []): Boolean; overload; inline; static;
    class function InputDouble(const ALabel: PUTF8Char; const AV: PDouble; const AStep: Double;
      const AStepFast: Double = 0.0): Boolean; overload; inline; static;
    class function InputScalar(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; 
      const APData: Pointer; const APStep: Pointer = nil; const APStepFast: Pointer = nil; 
      const AFormat: PUTF8Char = nil; const AFlags: TImGuiInputTextFlags = []): Boolean; overload; inline; static;
    class function InputScalarN(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; 
      const APData: Pointer; const AComponents: Int32; const APStep: Pointer = nil; 
      const APStepFast: Pointer = nil; const AFormat: PUTF8Char = nil; const AFlags: TImGuiInputTextFlags = []): Boolean; overload; inline; static;

    // Widgets: Color Editor/Picker (tip: the ColorEdit* functions have a little color square that can be left-clicked to open a picker, and right-clicked to open an option menu.)
    // - Note that in C++ a 'float v[X]' function argument is the _same_ as 'float* v', the array syntax is just a way to document the number of elements that are expected to be accessible.
    // - You can pass the address of a first float element out of a contiguous structure, e.g. &myvector.x
    class function ColorEdit3(const ALabel: PUTF8Char; const ACol: PSingle; const AFlags: TImGuiColorEditFlags = []): Boolean; inline; static;
    class function ColorEdit4(const ALabel: PUTF8Char; const ACol: PSingle; const AFlags: TImGuiColorEditFlags = []): Boolean; inline; static;
    class function ColorPicker3(const ALabel: PUTF8Char; const ACol: PSingle; const AFlags: TImGuiColorEditFlags = []): Boolean; inline; static;
    class function ColorPicker4(const ALabel: PUTF8Char; const ACol: PSingle; const AFlags: TImGuiColorEditFlags = []; 
      const ARefCol: PSingle = nil): Boolean; inline; static;

    // Implied size = ImVec2(0, 0)
    class function ColorButton(const ADescId: PUTF8Char; const ACol: TVector4; const AFlags: TImGuiColorEditFlags = []): Boolean; overload; inline; static;

    // display a color square/button, hover for details, return true when pressed.
    class function ColorButton(const ADescId: PUTF8Char; const ACol: TVector4; const AFlags: TImGuiColorEditFlags; 
      const ASize: TVector2): Boolean; overload; inline; static;

    // initialize current options (generally on application startup) if you want to select a default format, picker type, etc. User will be able to change many settings, unless you pass the _NoOptions flag to your calls.
    class procedure SetColorEditOptions(const AFlags: TImGuiColorEditFlags); inline; static;

    // Widgets: Trees
    // - TreeNode functions return true when the node is open, in which case you need to also call TreePop() when you are finished displaying the tree node contents.
    class function TreeNode(const ALabel: PUTF8Char): Boolean; overload; inline; static;

    // helper variation to easily decorrelate the id from the displayed string. Read the FAQ about why and how to use ID. to align arbitrary text at the same level as a TreeNode() you can use Bullet().
    class function TreeNode(const AStrId, AFmt: PUTF8Char): Boolean; overload; inline; static;

    // "
    class function TreeNode(const APtrId: Pointer; const AFmt: PUTF8Char): Boolean; overload; inline; static;
    class function TreeNodeEx(const ALabel: PUTF8Char; const AFlags: TImGuiTreeNodeFlags = []): Boolean; overload; inline; static;
    class function TreeNodeEx(const AStrId: PUTF8Char; const AFlags: TImGuiTreeNodeFlags; 
      const AFmt: PUTF8Char): Boolean; overload; inline; static;
    class function TreeNodeEx(const APtrId: Pointer; const AFlags: TImGuiTreeNodeFlags; 
      const AFmt: PUTF8Char): Boolean; overload; inline; static;

    // ~ Indent()+PushID(). Already called by TreeNode() when returning true, but you can call TreePush/TreePop yourself if desired.
    class procedure TreePush(const AStrId: PUTF8Char); overload; inline; static;

    // "
    class procedure TreePush(const APtrId: Pointer); overload; inline; static;

    // ~ Unindent()+PopID()
    class procedure TreePop; inline; static;

    // horizontal distance preceding label when using TreeNode*() or Bullet() == (g.FontSize + style.FramePadding.x*2) for a regular unframed TreeNode
    class function GetTreeNodeToLabelSpacing: Single; inline; static;

    // if returning 'true' the header is open. doesn't indent nor push on ID stack. user doesn't have to call TreePop().
    class function CollapsingHeader(const ALabel: PUTF8Char; const AFlags: TImGuiTreeNodeFlags = []): Boolean; overload; inline; static;

    // when 'p_visible != NULL': if '*p_visible==true' display an additional small close button on upper right of the header which will set the bool to false when clicked, if '*p_visible==false' don't display the header.
    class function CollapsingHeader(const ALabel: PUTF8Char; const APVisible: PBoolean; 
      const AFlags: TImGuiTreeNodeFlags = []): Boolean; overload; inline; static;

    // set next TreeNode/CollapsingHeader open state.
    class procedure SetNextItemOpen(const AIsOpen: Boolean; const ACond: TImGuiCond = TImGuiCond(0)); inline; static;

    // set id to use for open/close storage (default to same as item id).
    class procedure SetNextItemStorageID(const AStorageId: TImGuiID); inline; static;

    // retrieve tree node open/close state.
    class function TreeNodeGetOpen(const AStorageId: TImGuiID): Boolean; inline; static;

    // Widgets: Selectables
    // - A selectable highlights when hovered, and can display another color when selected.
    // - Neighbors selectable extend their highlight bounds in order to leave no gap between them. This is so a series of selected Selectable appear contiguous.
    // Implied selected = false, flags = 0, size = ImVec2(0, 0)
    class function Selectable(const ALabel: PUTF8Char): Boolean; overload; inline; static;

    // "bool selected" carry the selection state (read-only). Selectable() is clicked is returns true so you can modify your selection state. size.x==0.0: use remaining width, size.x>0.0: specify width. size.y==0.0: use label height, size.y>0.0: specify height
    class function Selectable(const ALabel: PUTF8Char; const ASelected: Boolean; 
      const AFlags: TImGuiSelectableFlags; const ASize: TVector2): Boolean; overload; inline; static;
    class function Selectable(const ALabel: PUTF8Char; const ASelected: Boolean;
      const AFlags: TImGuiSelectableFlags = []): Boolean; overload; inline; static;

    // Implied size = ImVec2(0, 0)
    class function Selectable(const ALabel: PUTF8Char; const APSelected: PBoolean; 
      const AFlags: TImGuiSelectableFlags = []): Boolean; overload; inline; static;

    // "bool* p_selected" point to the selection state (read-write), as a convenient helper.
    class function Selectable(const ALabel: PUTF8Char; const APSelected: PBoolean; 
      const AFlags: TImGuiSelectableFlags; const ASize: TVector2): Boolean; overload; inline; static;
    class function BeginMultiSelect(const AFlags: TImGuiMultiSelectFlags; const ASelectionSize: Int32 = -1; 
      const AItemsCount: Int32 = -1): PImGuiMultiSelectIO; overload; inline; static;
    class function EndMultiSelect: PImGuiMultiSelectIO; inline; static;
    class procedure SetNextItemSelectionUserData(const ASelectionUserData: TImGuiSelectionUserData); inline; static;

    // Was the last item selection state toggled? Useful if you need the per-item information _before_ reaching EndMultiSelect(). We only returns toggle _event_ in order to handle clipping correctly.
    class function IsItemToggledSelection: Boolean; inline; static;

    // Widgets: List Boxes
    // - This is essentially a thin wrapper to using BeginChild/EndChild with the ImGuiChildFlags_FrameStyle flag for stylistic changes + displaying a label.
    // - If you don't need a label you can probably simply use BeginChild() with the ImGuiChildFlags_FrameStyle flag for the same result.
    // - You can submit contents and manage your selection state however you want it, by creating e.g. Selectable() or any other items.
    // - The simplified/old ListBox() api are helpers over BeginListBox()/EndListBox() which are kept available for convenience purpose. This is analogous to how Combos are created.
    // - Choose frame width:   size.x > 0.0f: custom  /  size.x < 0.0f or -FLT_MIN: right-align   /  size.x = 0.0f (default): use current ItemWidth
    // - Choose frame height:  size.y > 0.0f: custom  /  size.y < 0.0f or -FLT_MIN: bottom-align  /  size.y = 0.0f (default): arbitrary default height which can fit ~7 items
    // open a framed scrolling region
    class function BeginListBox(const ALabel: PUTF8Char; const ASize: TVector2): Boolean; overload; inline; static;
    class function BeginListBox(const ALabel: PUTF8Char): Boolean; overload; inline; static;

    // only call EndListBox() if BeginListBox() returned true!
    class procedure EndListBox; inline; static;
    class function ListBox(const ALabel: PUTF8Char; const ACurrentItem: PInt32; 
      const AItems: PPUTF8Char; const AItemsCount: Int32; const AHeightInItems: Int32 = -1): Boolean; overload; inline; static;

    // Implied height_in_items = -1
    class function ListBox(const ALabel: PUTF8Char; const ACurrentItem: PInt32; 
      const AGetter: TImGuiStringGetter; const AUserData: Pointer; const AItemsCount: Int32): Boolean; overload; inline; static;
    class function ListBox(const ALabel: PUTF8Char; const ACurrentItem: PInt32; 
      const AGetter: TImGuiStringGetter; const AUserData: Pointer; const AItemsCount: Int32; 
      const AHeightInItems: Int32 = -1): Boolean; overload; inline; static;

    // Widgets: Data Plotting
    // - Consider using ImPlot (https://github.com/epezent/implot) which is much better!
    // Implied values_offset = 0, overlay_text = NULL, scale_min = FLT_MAX, scale_max = FLT_MAX, graph_size = ImVec2(0, 0), stride = sizeof(float)
    class procedure PlotLines(const ALabel: PUTF8Char; const AValues: PSingle; const AValuesCount: Int32); overload; inline; static;
    class procedure PlotLines(const ALabel: PUTF8Char; const AValues: PSingle; const AValuesCount: Int32; 
      const AValuesOffset: Int32; const AOverlayText: PUTF8Char; const AScaleMin: Single; 
      const AScaleMax: Single; const AGraphSize: TVector2; const AStride: Int32 = SizeOf(Single)); overload; inline; static;
    class procedure PlotLines(const ALabel: PUTF8Char; const AValues: PSingle; const AValuesCount: Int32;
      const AValuesOffset: Int32 = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle;
      const AScaleMax: Single = MaxSingle); overload; inline; static;

    // Implied values_offset = 0, overlay_text = NULL, scale_min = FLT_MAX, scale_max = FLT_MAX, graph_size = ImVec2(0, 0)
    class procedure PlotLines(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValueGetter; 
      const AData: Pointer; const AValuesCount: Int32); overload; inline; static;
    class procedure PlotLines(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValueGetter; 
      const AData: Pointer; const AValuesCount: Int32; const AValuesOffset: Int32; 
      const AOverlayText: PUTF8Char; const AScaleMin: Single; const AScaleMax: Single; 
      const AGraphSize: TVector2); overload; inline; static;
    class procedure PlotLines(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValueGetter;
      const AData: Pointer; const AValuesCount: Int32; const AValuesOffset: Int32 = 0;
      const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle;
      const AScaleMax: Single = MaxSingle); overload; inline; static;

    // Implied values_offset = 0, overlay_text = NULL, scale_min = FLT_MAX, scale_max = FLT_MAX, graph_size = ImVec2(0, 0), stride = sizeof(float)
    class procedure PlotHistogram(const ALabel: PUTF8Char; const AValues: PSingle; 
      const AValuesCount: Int32); overload; inline; static;
    class procedure PlotHistogram(const ALabel: PUTF8Char; const AValues: PSingle; 
      const AValuesCount: Int32; const AValuesOffset: Int32; const AOverlayText: PUTF8Char; 
      const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2; 
      const AStride: Int32 = SizeOf(Single)); overload; inline; static;
    class procedure PlotHistogram(const ALabel: PUTF8Char; const AValues: PSingle;
      const AValuesCount: Int32; const AValuesOffset: Int32 = 0; const AOverlayText: PUTF8Char = nil;
      const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle); overload; inline; static;

    // Implied values_offset = 0, overlay_text = NULL, scale_min = FLT_MAX, scale_max = FLT_MAX, graph_size = ImVec2(0, 0)
    class procedure PlotHistogram(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValueGetter; 
      const AData: Pointer; const AValuesCount: Int32); overload; inline; static;
    class procedure PlotHistogram(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValueGetter; 
      const AData: Pointer; const AValuesCount: Int32; const AValuesOffset: Int32; 
      const AOverlayText: PUTF8Char; const AScaleMin: Single; const AScaleMax: Single; 
      const AGraphSize: TVector2); overload; inline; static;
    class procedure PlotHistogram(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValueGetter;
      const AData: Pointer; const AValuesCount: Int32; const AValuesOffset: Int32 = 0;
      const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle;
      const AScaleMax: Single = MaxSingle); overload; inline; static;

    // Widgets: Menus
    // - Use BeginMenuBar() on a window ImGuiWindowFlags_MenuBar to append to its menu bar.
    // - Use BeginMainMenuBar() to create a menu bar at the top of the screen and append to it.
    // - Use BeginMenu() to create a menu. You can call BeginMenu() multiple time with the same identifier to append more items to it.
    // - Not that MenuItem() keyboardshortcuts are displayed as a convenience but _not processed_ by Dear ImGui at the moment.
    // append to menu-bar of current window (requires ImGuiWindowFlags_MenuBar flag set on parent window).
    class function BeginMenuBar: Boolean; inline; static;

    // only call EndMenuBar() if BeginMenuBar() returns true!
    class procedure EndMenuBar; inline; static;

    // create and append to a full screen menu-bar.
    class function BeginMainMenuBar: Boolean; inline; static;

    // only call EndMainMenuBar() if BeginMainMenuBar() returns true!
    class procedure EndMainMenuBar; inline; static;

    // create a sub-menu entry. only call EndMenu() if this returns true!
    class function BeginMenu(const ALabel: PUTF8Char; const AEnabled: Boolean = true): Boolean; overload; inline; static;

    // only call EndMenu() if BeginMenu() returns true!
    class procedure EndMenu; inline; static;

    // return true when activated.
    class function MenuItem(const ALabel: PUTF8Char; const AShortcut: PUTF8Char = nil; 
      const ASelected: Boolean = false; const AEnabled: Boolean = true): Boolean; overload; inline; static;

    // return true when activated + toggle (*p_selected) if p_selected != NULL
    class function MenuItem(const ALabel, AShortcut: PUTF8Char; const APSelected: PBoolean; 
      const AEnabled: Boolean = true): Boolean; overload; inline; static;

    // Tooltips
    // - Tooltips are windows following the mouse. They do not take focus away.
    // - A tooltip window can contain items of any types.
    // - SetTooltip() is more or less a shortcut for the 'if (BeginTooltip()) { Text(...); EndTooltip(); }' idiom (with a subtlety that it discard any previously submitted tooltip)
    // begin/append a tooltip window.
    class function BeginTooltip: Boolean; inline; static;

    // only call EndTooltip() if BeginTooltip()/BeginItemTooltip() returns true!
    class procedure EndTooltip; inline; static;

    // set a text-only tooltip. Often used after a ImGui::IsItemHovered() check. Override any previous call to SetTooltip().
    class procedure SetTooltip(const AFmt: PUTF8Char); inline; static;

    // Tooltips: helpers for showing a tooltip when hovering an item
    // - BeginItemTooltip() is a shortcut for the 'if (IsItemHovered(ImGuiHoveredFlags_ForTooltip) && BeginTooltip())' idiom.
    // - SetItemTooltip() is a shortcut for the 'if (IsItemHovered(ImGuiHoveredFlags_ForTooltip)) { SetTooltip(...); }' idiom.
    // - Where 'ImGuiHoveredFlags_ForTooltip' itself is a shortcut to use 'style.HoverFlagsForTooltipMouse' or 'style.HoverFlagsForTooltipNav' depending on active input type. For mouse it defaults to 'ImGuiHoveredFlags_Stationary | ImGuiHoveredFlags_DelayShort'.
    // begin/append a tooltip window if preceding item was hovered.
    class function BeginItemTooltip: Boolean; inline; static;

    // set a text-only tooltip if preceding item was hovered. override any previous call to SetTooltip().
    class procedure SetItemTooltip(const AFmt: PUTF8Char); inline; static;

    // Popups, Modals
    //  - They block normal mouse hovering detection (and therefore most mouse interactions) behind them.
    //  - If not modal: they can be closed by clicking anywhere outside them, or by pressing ESCAPE.
    //  - Their visibility state (~bool) is held internally instead of being held by the programmer as we are used to with regular Begin*() calls.
    //  - The 3 properties above are related: we need to retain popup visibility state in the library because popups may be closed as any time.
    //  - You can bypass the hovering restriction by using ImGuiHoveredFlags_AllowWhenBlockedByPopup when calling IsItemHovered() or IsWindowHovered().
    //  - IMPORTANT: Popup identifiers are relative to the current ID stack, so OpenPopup and BeginPopup generally needs to be at the same level of the stack.
    //    This is sometimes leading to confusing mistakes. May rework this in the future.
    //  - BeginPopup(): query popup state, if open start appending into the window. Call EndPopup() afterwards if returned true. ImGuiWindowFlags are forwarded to the window.
    //  - BeginPopupModal(): block every interaction behind the window, cannot be closed by user, add a dimming background, has a title bar.
    // return true if the popup is open, and you can start outputting to it.
    class function BeginPopup(const AStrId: PUTF8Char; const AFlags: TImGuiWindowFlags = []): Boolean; inline; static;

    // return true if the modal is open, and you can start outputting to it.
    class function BeginPopupModal(const AName: PUTF8Char; const APOpen: PBoolean = nil; 
      const AFlags: TImGuiWindowFlags = []): Boolean; inline; static;

    // only call EndPopup() if BeginPopupXXX() returns true!
    class procedure EndPopup; inline; static;

    // Popups: open/close functions
    //  - OpenPopup(): set popup state to open. ImGuiPopupFlags are available for opening options.
    //  - If not modal: they can be closed by clicking anywhere outside them, or by pressing ESCAPE.
    //  - CloseCurrentPopup(): use inside the BeginPopup()/EndPopup() scope to close manually.
    //  - CloseCurrentPopup() is called by default by Selectable()/MenuItem() when activated (FIXME: need some options).
    //  - Use ImGuiPopupFlags_NoOpenOverExistingPopup to avoid opening a popup if there's already one at the same level. This is equivalent to e.g. testing for !IsAnyPopupOpen() prior to OpenPopup().
    //  - Use IsWindowAppearing() after BeginPopup() to tell if a window just opened.
    // call to mark popup as open (don't call every frame!).
    class procedure OpenPopup(const AStrId: PUTF8Char; const APopupFlags: TImGuiPopupFlags = []); overload; inline; static;

    // id overload to facilitate calling from nested stacks
    class procedure OpenPopup(const AId: TImGuiID; const APopupFlags: TImGuiPopupFlags = []); overload; inline; static;

    // helper to open popup when clicked on last item. Default to ImGuiPopupFlags_MouseButtonRight == 1. (note: actually triggers on the mouse _released_ event to be consistent with popup behaviors)
    class procedure OpenPopupOnItemClick(const AStrId: PUTF8Char = nil; const APopupFlags: TImGuiPopupFlags = []); inline; static;

    // manually close the popup we have begin-ed into.
    class procedure CloseCurrentPopup; inline; static;

    // open+begin popup when clicked on last item. Use str_id==NULL to associate the popup to previous item. If you want to use that on a non-interactive item such as Text() you need to pass in an explicit ID here. read comments in .cpp!
    class function BeginPopupContextItem(const AStrId: PUTF8Char = nil; const APopupFlags: TImGuiPopupFlags = []): Boolean; overload; inline; static;

    // open+begin popup when clicked on current window.
    class function BeginPopupContextWindow(const AStrId: PUTF8Char = nil; const APopupFlags: TImGuiPopupFlags = []): Boolean; overload; inline; static;

    // open+begin popup when clicked in void (where there are no windows).
    class function BeginPopupContextVoid(const AStrId: PUTF8Char = nil; const APopupFlags: TImGuiPopupFlags = []): Boolean; overload; inline; static;

    // Popups: query functions
    //  - IsPopupOpen(): return true if the popup is open at the current BeginPopup() level of the popup stack.
    //  - IsPopupOpen() with ImGuiPopupFlags_AnyPopupId: return true if any popup is open at the current BeginPopup() level of the popup stack.
    //  - IsPopupOpen() with ImGuiPopupFlags_AnyPopupId + ImGuiPopupFlags_AnyPopupLevel: return true if any popup is open.
    // return true if the popup is open.
    class function IsPopupOpen(const AStrId: PUTF8Char; const AFlags: TImGuiPopupFlags = []): Boolean; inline; static;

    // Tables
    // - Full-featured replacement for old Columns API.
    // - See Demo->Tables for demo code. See top of imgui_tables.cpp for general commentary.
    // - See ImGuiTableFlags_ and ImGuiTableColumnFlags_ enums for a description of available flags.
    // The typical call flow is:
    // - 1. Call BeginTable(), early out if returning false.
    // - 2. Optionally call TableSetupColumn() to submit column name/flags/defaults.
    // - 3. Optionally call TableSetupScrollFreeze() to request scroll freezing of columns/rows.
    // - 4. Optionally call TableHeadersRow() to submit a header row. Names are pulled from TableSetupColumn() data.
    // - 5. Populate contents:
    //    - In most situations you can use TableNextRow() + TableSetColumnIndex(N) to start appending into a column.
    //    - If you are using tables as a sort of grid, where every column is holding the same type of contents,
    //      you may prefer using TableNextColumn() instead of TableNextRow() + TableSetColumnIndex().
    //      TableNextColumn() will automatically wrap-around into the next row if needed.
    //    - IMPORTANT: Comparatively to the old Columns() API, we need to call TableNextColumn() for the first column!
    //    - Summary of possible call flow:
    //        - TableNextRow() -> TableSetColumnIndex(0) -> Text("Hello 0") -> TableSetColumnIndex(1) -> Text("Hello 1")  // OK
    //        - TableNextRow() -> TableNextColumn()      -> Text("Hello 0") -> TableNextColumn()      -> Text("Hello 1")  // OK
    //        -                   TableNextColumn()      -> Text("Hello 0") -> TableNextColumn()      -> Text("Hello 1")  // OK: TableNextColumn() automatically gets to next row!
    //        - TableNextRow()                           -> Text("Hello 0")                                               // Not OK! Missing TableSetColumnIndex() or TableNextColumn()! Text will not appear!
    // - 5. Call EndTable()
    // Implied outer_size = ImVec2(0.0f, 0.0f), inner_width = 0.0f
    class function BeginTable(const AStrId: PUTF8Char; const AColumns: Int32; const AFlags: TImGuiTableFlags = []): Boolean; overload; inline; static;
    class function BeginTable(const AStrId: PUTF8Char; const AColumns: Int32; const AFlags: TImGuiTableFlags; 
      const AOuterSize: TVector2; const AInnerWidth: Single = 0.0): Boolean; overload; inline; static;

    // only call EndTable() if BeginTable() returns true!
    class procedure EndTable; inline; static;

    // append into the first cell of a new row. 'min_row_height' include the minimum top and bottom padding aka CellPadding.y * 2.0f.
    class procedure TableNextRow(const ARowFlags: TImGuiTableRowFlags = []; const AMinRowHeight: Single = 0.0); overload; inline; static;

    // append into the next column (or first column of next row if currently in last column). Return true when column is visible.
    class function TableNextColumn: Boolean; inline; static;

    // append into the specified column. Return true when column is visible.
    class function TableSetColumnIndex(const AColumnN: Int32): Boolean; inline; static;
    class procedure TableSetupColumn(const ALabel: PUTF8Char; const AFlags: TImGuiTableColumnFlags = []; 
      const AInitWidthOrWeight: Single = 0.0; const AUserId: TImGuiID = TImGuiID(0)); overload; inline; static;

    // lock columns/rows so they stay visible when scrolled.
    class procedure TableSetupScrollFreeze(const ACols, ARows: Int32); inline; static;

    // submit one header cell manually (rarely used)
    class procedure TableHeader(const ALabel: PUTF8Char); inline; static;

    // submit a row with headers cells based on data provided to TableSetupColumn() + submit context menu
    class procedure TableHeadersRow; inline; static;

    // submit a row with angled headers for every column with the ImGuiTableColumnFlags_AngledHeader flag. MUST BE FIRST ROW.
    class procedure TableAngledHeadersRow; inline; static;

    // Tables: Sorting & Miscellaneous functions
    // - Sorting: call TableGetSortSpecs() to retrieve latest sort specs for the table. NULL when not sorting.
    //   When 'sort_specs->SpecsDirty == true' you should sort your data. It will be true when sorting specs have
    //   changed since last call, or the first time. Make sure to set 'SpecsDirty = false' after sorting,
    //   else you may wastefully sort your data every frame!
    // - Functions args 'int column_n' treat the default value of -1 as the same as passing the current column index.
    // get latest sort specs for the table (NULL if not sorting).  Lifetime: don't hold on this pointer over multiple frames or past any subsequent call to BeginTable().
    class function TableGetSortSpecs: PImGuiTableSortSpecs; inline; static;

    // return number of columns (value passed to BeginTable)
    class function TableGetColumnCount: Int32; inline; static;

    // return current column index.
    class function TableGetColumnIndex: Int32; inline; static;

    // return current row index (header rows are accounted for)
    class function TableGetRowIndex: Int32; inline; static;

    // return "" if column didn't have a name declared by TableSetupColumn(). Pass -1 to use current column.
    class function TableGetColumnName(const AColumnN: Int32 = -1): PUTF8Char; inline; static;

    // return column flags so you can query their Enabled/Visible/Sorted/Hovered status flags. Pass -1 to use current column.
    class function TableGetColumnFlags(const AColumnN: Int32 = -1): TImGuiTableColumnFlags; inline; static;

    // change user accessible enabled/disabled state of a column. Set to false to hide the column. User can use the context menu to change this themselves (right-click in headers, or right-click in columns body with ImGuiTableFlags_ContextMenuInBody)
    class procedure TableSetColumnEnabled(const AColumnN: Int32; const AV: Boolean); inline; static;

    // return hovered column. return -1 when table is not hovered. return columns_count if the unused space at the right of visible columns is hovered. Can also use (TableGetColumnFlags() & ImGuiTableColumnFlags_IsHovered) instead.
    class function TableGetHoveredColumn: Int32; inline; static;

    // change the color of a cell, row, or column. See ImGuiTableBgTarget_ flags for details.
    class procedure TableSetBgColor(const ATarget: TImGuiTableBgTarget; const AColor: UInt32; 
      const AColumnN: Int32 = -1); inline; static;
    class procedure Columns(const ACount: Int32 = 1; const AId: PUTF8Char = nil; 
      const ABorders: Boolean = true); overload; inline; static;

    // next column, defaults to current row or next row if the current row is finished
    class procedure NextColumn; inline; static;

    // get current column index
    class function GetColumnIndex: Int32; inline; static;

    // get column width (in pixels). pass -1 to use current column
    class function GetColumnWidth(const AColumnIndex: Int32 = -1): Single; inline; static;

    // set column width (in pixels). pass -1 to use current column
    class procedure SetColumnWidth(const AColumnIndex: Int32; const AWidth: Single); inline; static;

    // get position of column line (in pixels, from the left side of the contents region). pass -1 to use current column, otherwise 0..GetColumnsCount() inclusive. column 0 is typically 0.0f
    class function GetColumnOffset(const AColumnIndex: Int32 = -1): Single; inline; static;

    // set position of column line (in pixels, from the left side of the contents region). pass -1 to use current column
    class procedure SetColumnOffset(const AColumnIndex: Int32; const AOffsetX: Single); inline; static;
    class function GetColumnsCount: Int32; inline; static;

    // Tab Bars, Tabs
    // - Note: Tabs are automatically created by the docking system (when in 'docking' branch). Use this to create tab bars/tabs yourself.
    // create and append into a TabBar
    class function BeginTabBar(const AStrId: PUTF8Char; const AFlags: TImGuiTabBarFlags = []): Boolean; inline; static;

    // only call EndTabBar() if BeginTabBar() returns true!
    class procedure EndTabBar; inline; static;

    // create a Tab. Returns true if the Tab is selected.
    class function BeginTabItem(const ALabel: PUTF8Char; const APOpen: PBoolean = nil; 
      const AFlags: TImGuiTabItemFlags = []): Boolean; inline; static;

    // only call EndTabItem() if BeginTabItem() returns true!
    class procedure EndTabItem; inline; static;

    // create a Tab behaving like a button. return true when clicked. cannot be selected in the tab bar.
    class function TabItemButton(const ALabel: PUTF8Char; const AFlags: TImGuiTabItemFlags = []): Boolean; inline; static;

    // notify TabBar or Docking system of a closed tab/window ahead (useful to reduce visual flicker on reorderable tab bars). For tab-bar: call after BeginTabBar() and before Tab submissions. Otherwise call with a window name.
    class procedure SetTabItemClosed(const ATabOrDockedWindowLabel: PUTF8Char); inline; static;

    // Logging/Capture
    // - All text output from the interface can be captured into tty/file/clipboard. By default, tree nodes are automatically opened during logging.
    // start logging to tty (stdout)
    class procedure LogToTTY(const AAutoOpenDepth: Int32 = -1); inline; static;

    // start logging to file
    class procedure LogToFile(const AAutoOpenDepth: Int32 = -1; const AFilename: PUTF8Char = nil); inline; static;

    // start logging to OS clipboard
    class procedure LogToClipboard(const AAutoOpenDepth: Int32 = -1); inline; static;

    // stop logging (close file, etc.)
    class procedure LogFinish; inline; static;

    // helper to display buttons for logging to tty/file/clipboard
    class procedure LogButtons; inline; static;

    // pass text data straight to log (without being displayed)
    class procedure LogText(const AFmt: PUTF8Char); inline; static;

    // Drag and Drop
    // - On source items, call BeginDragDropSource(), if it returns true also call SetDragDropPayload() + EndDragDropSource().
    // - On target candidates, call BeginDragDropTarget(), if it returns true also call AcceptDragDropPayload() + EndDragDropTarget().
    // - If you stop calling BeginDragDropSource() the payload is preserved however it won't have a preview tooltip (we currently display a fallback "..." tooltip, see #1725)
    // - An item can be both drag source and drop target.
    // call after submitting an item which may be dragged. when this return true, you can call SetDragDropPayload() + EndDragDropSource()
    class function BeginDragDropSource(const AFlags: TImGuiDragDropFlags = []): Boolean; inline; static;

    // type is a user defined string of maximum 32 characters. Strings starting with '_' are reserved for dear imgui internal types. Data is copied and held by imgui. Return true when payload has been accepted.
    class function SetDragDropPayload(const AType: PUTF8Char; const AData: Pointer; 
      const ASz: NativeUInt; const ACond: TImGuiCond = TImGuiCond(0)): Boolean; inline; static;

    // only call EndDragDropSource() if BeginDragDropSource() returns true!
    class procedure EndDragDropSource; inline; static;

    // call after submitting an item that may receive a payload. If this returns true, you can call AcceptDragDropPayload() + EndDragDropTarget()
    class function BeginDragDropTarget: Boolean; inline; static;

    // accept contents of a given type. If ImGuiDragDropFlags_AcceptBeforeDelivery is set you can peek into the payload before the mouse button is released.
    class function AcceptDragDropPayload(const AType: PUTF8Char; const AFlags: TImGuiDragDropFlags = []): PImGuiPayload; inline; static;

    // only call EndDragDropTarget() if BeginDragDropTarget() returns true!
    class procedure EndDragDropTarget; inline; static;

    // peek directly into the current payload from anywhere. returns NULL when drag and drop is finished or inactive. use ImGuiPayload::IsDataType() to test for the payload type.
    class function GetDragDropPayload: PImGuiPayload; inline; static;

    // Disabling [BETA API]
    // - Disable all user interactions and dim items visuals (applying style.DisabledAlpha over current colors)
    // - Those can be nested but it cannot be used to enable an already disabled section (a single BeginDisabled(true) in the stack is enough to keep everything disabled)
    // - Tooltips windows are automatically opted out of disabling. Note that IsItemHovered() by default returns false on disabled items, unless using ImGuiHoveredFlags_AllowWhenDisabled.
    // - BeginDisabled(false)/EndDisabled() essentially does nothing but is provided to facilitate use of boolean expressions (as a micro-optimization: if you have tens of thousands of BeginDisabled(false)/EndDisabled() pairs, you might want to reformulate your code to avoid making those calls)
    class procedure BeginDisabled(const ADisabled: Boolean = true); inline; static;
    class procedure EndDisabled; inline; static;

    // Clipping
    // - Mouse hovering is affected by ImGui::PushClipRect() calls, unlike direct calls to ImDrawList::PushClipRect() which are render only.
    class procedure PushClipRect(const AClipRectMin, AClipRectMax: TVector2; const AIntersectWithCurrentClipRect: Boolean); inline; static;
    class procedure PopClipRect; inline; static;

    // Focus, Activation
    // make last item the default focused item of a newly appearing window.
    class procedure SetItemDefaultFocus; inline; static;

    // focus keyboard on the next widget. Use positive 'offset' to access sub components of a multiple component widget. Use -1 to access previous widget.
    class procedure SetKeyboardFocusHere(const AOffset: Int32 = 0); overload; inline; static;

    // Keyboard/Gamepad Navigation
    // alter visibility of keyboard/gamepad cursor. by default: show when using an arrow key, hide when clicking with mouse.
    class procedure SetNavCursorVisible(const AVisible: Boolean); inline; static;

    // Overlapping mode
    // allow next item to be overlapped by a subsequent item. Typically useful with InvisibleButton(), Selectable(), TreeNode() covering an area where subsequent items may need to be added. Note that both Selectable() and TreeNode() have dedicated flags doing this.
    class procedure SetNextItemAllowOverlap; inline; static;

    // Item/Widgets Utilities and Query Functions
    // - Most of the functions are referring to the previous Item that has been submitted.
    // - See Demo Window under "Widgets->Querying Status" for an interactive visualization of most of those functions.
    // is the last item hovered? (and usable, aka not blocked by a popup, etc.). See ImGuiHoveredFlags for more options.
    class function IsItemHovered(const AFlags: TImGuiHoveredFlags = []): Boolean; inline; static;

    // is the last item active? (e.g. button being held, text field being edited. This will continuously return true while holding mouse button on an item. Items that don't interact will always return false)
    class function IsItemActive: Boolean; inline; static;

    // is the last item focused for keyboard/gamepad navigation?
    class function IsItemFocused: Boolean; inline; static;

    // is the last item hovered and mouse clicked on? (**)  == IsMouseClicked(mouse_button) && IsItemHovered()Important. (**) this is NOT equivalent to the behavior of e.g. Button(). Read comments in function definition.
    class function IsItemClicked(const AMouseButton: TImGuiMouseButton = TImGuiMouseButton(0)): Boolean; overload; inline; static;

    // is the last item visible? (items may be out of sight because of clipping/scrolling)
    class function IsItemVisible: Boolean; inline; static;

    // did the last item modify its underlying value this frame? or was pressed? This is generally the same as the "bool" return value of many widgets.
    class function IsItemEdited: Boolean; inline; static;

    // was the last item just made active (item was previously inactive).
    class function IsItemActivated: Boolean; inline; static;

    // was the last item just made inactive (item was previously active). Useful for Undo/Redo patterns with widgets that require continuous editing.
    class function IsItemDeactivated: Boolean; inline; static;

    // was the last item just made inactive and made a value change when it was active? (e.g. Slider/Drag moved). Useful for Undo/Redo patterns with widgets that require continuous editing. Note that you may get false positives (some widgets such as Combo()/ListBox()/Selectable() will return true even when clicking an already selected item).
    class function IsItemDeactivatedAfterEdit: Boolean; inline; static;

    // was the last item open state toggled? set by TreeNode().
    class function IsItemToggledOpen: Boolean; inline; static;

    // is any item hovered?
    class function IsAnyItemHovered: Boolean; inline; static;

    // is any item active?
    class function IsAnyItemActive: Boolean; inline; static;

    // is any item focused?
    class function IsAnyItemFocused: Boolean; inline; static;

    // get ID of last item (~~ often same ImGui::GetID(label) beforehand)
    class function GetItemID: TImGuiID; inline; static;

    // get upper-left bounding rectangle of the last item (screen space)
    class function GetItemRectMin: TVector2; inline; static;

    // get lower-right bounding rectangle of the last item (screen space)
    class function GetItemRectMax: TVector2; inline; static;

    // get size of last item
    class function GetItemRectSize: TVector2; inline; static;

    // get generic flags of last item
    class function GetItemFlags: TImGuiItemFlags; inline; static;

    // Viewports
    // - Currently represents the Platform Window created by the application which is hosting our Dear ImGui windows.
    // - In 'docking' branch with multi-viewport enabled, we extend this concept to have multiple active viewports.
    // - In the future we will extend this concept further to also represent Platform Monitor and support a "no main platform window" operation mode.
    // return primary/default viewport. This can never be NULL.
    class function GetMainViewport: PImGuiViewport; inline; static;

    // Background/Foreground Draw Lists
    // this draw list will be the first rendered one. Useful to quickly draw shapes/text behind dear imgui contents.
    class function GetBackgroundDrawList: PImDrawList; inline; static;

    // this draw list will be the last rendered one. Useful to quickly draw shapes/text over dear imgui contents.
    class function GetForegroundDrawList: PImDrawList; inline; static;

    // Miscellaneous Utilities
    // test if rectangle (of given size, starting from cursor position) is visible / not clipped.
    class function IsRectVisible(const ASize: TVector2): Boolean; overload; inline; static;

    // test if rectangle (in screen space) is visible / not clipped. to perform coarse clipping on user's side.
    class function IsRectVisible(const ARectMin, ARectMax: TVector2): Boolean; overload; inline; static;

    // get global imgui time. incremented by io.DeltaTime every frame.
    class function GetTime: Double; inline; static;

    // get global imgui frame count. incremented by 1 every frame.
    class function GetFrameCount: Int32; inline; static;

    // you may use this when creating your own ImDrawList instances.
    class function GetDrawListSharedData: PImDrawListSharedData; inline; static;

    // get a string corresponding to the enum value (for display, saving, etc.).
    class function GetStyleColorName(const AIdx: TImGuiCol): PUTF8Char; inline; static;

    // replace current window storage with our own (if you want to manipulate it yourself, typically clear subsection of it)
    class procedure SetStateStorage(const AStorage: PImGuiStorage); inline; static;
    class function GetStateStorage: PImGuiStorage; inline; static;
    class function CalcTextSize(const AText: PUTF8Char; const ATextEnd: PUTF8Char = nil; 
      const AHideTextAfterDoubleHash: Boolean = false; const AWrapWidth: Single = -1.0): TVector2; overload; inline; static;

    // Color Utilities
    class function ColorConvertU32ToFloat4(const AIn: UInt32): TVector4; inline; static;
    class function ColorConvertFloat4ToU32(const AIn: TVector4): UInt32; inline; static;
    class procedure ColorConvertRGBtoHSV(const AR, AG, AB: Single; const AOutH, 
      AOutS, AOutV: PSingle); inline; static;
    class procedure ColorConvertHSVtoRGB(const AH, &AS, AV: Single; const AOutR, 
      AOutG, AOutB: PSingle); inline; static;

    // Inputs Utilities: Raw Keyboard/Mouse/Gamepad Access
    // - Consider using the Shortcut() function instead of IsKeyPressed()/IsKeyChordPressed()! Shortcut() is easier to use and better featured (can do focus routing check).
    // - the ImGuiKey enum contains all possible keyboard, mouse and gamepad inputs (e.g. ImGuiKey_A, ImGuiKey_MouseLeft, ImGuiKey_GamepadDpadUp...).
    // - (legacy: before v1.87 (2022-02), we used ImGuiKey < 512 values to carry native/user indices as defined by each backends. This was obsoleted in 1.87 (2022-02) and completely removed in 1.91.5 (2024-11). See https://github.com/ocornut/imgui/issues/4921)
    // is key being held.
    class function IsKeyDown(const AKey: TImGuiKey): Boolean; inline; static;

    // was key pressed (went from !Down to Down)? Repeat rate uses io.KeyRepeatDelay / KeyRepeatRate.
    class function IsKeyPressed(const AKey: TImGuiKey; const ARepeat: Boolean = true): Boolean; overload; inline; static;

    // was key released (went from Down to !Down)?
    class function IsKeyReleased(const AKey: TImGuiKey): Boolean; inline; static;

    // was key chord (mods + key) pressed, e.g. you can pass 'ImGuiMod_Ctrl | ImGuiKey_S' as a key-chord. This doesn't do any routing or focus check, please consider using Shortcut() function instead.
    class function IsKeyChordPressed(const AKeyChord: TImGuiKeyChord): Boolean; inline; static;

    // uses provided repeat rate/delay. return a count, most often 0 or 1 but might be >1 if RepeatRate is small enough that DeltaTime > RepeatRate
    class function GetKeyPressedAmount(const AKey: TImGuiKey; const ARepeatDelay, 
      ARate: Single): Int32; inline; static;

    // [DEBUG] returns English name of the key. Those names are provided for debugging purpose and are not meant to be saved persistently nor compared.
    class function GetKeyName(const AKey: TImGuiKey): PUTF8Char; inline; static;

    // Override io.WantCaptureKeyboard flag next frame (said flag is left for your application to handle, typically when true it instructs your app to ignore inputs). e.g. force capture keyboard when your widget is being hovered. This is equivalent to setting "io.WantCaptureKeyboard = want_capture_keyboard"; after the next NewFrame() call.
    class procedure SetNextFrameWantCaptureKeyboard(const AWantCaptureKeyboard: Boolean); inline; static;

    // Inputs Utilities: Shortcut Testing & Routing
    // - Typical use is e.g.: 'if (ImGui::Shortcut(ImGuiMod_Ctrl | ImGuiKey_S)) { ... }'.
    // - Flags: Default route use ImGuiInputFlags_RouteFocused, but see ImGuiInputFlags_RouteGlobal and other options in ImGuiInputFlags_!
    // - Flags: Use ImGuiInputFlags_Repeat to support repeat.
    // - ImGuiKeyChord = a ImGuiKey + optional ImGuiMod_Alt/ImGuiMod_Ctrl/ImGuiMod_Shift/ImGuiMod_Super.
    //       ImGuiKey_C                          // Accepted by functions taking ImGuiKey or ImGuiKeyChord arguments
    //       ImGuiMod_Ctrl | ImGuiKey_C          // Accepted by functions taking ImGuiKeyChord arguments
    //   only ImGuiMod_XXX values are legal to combine with an ImGuiKey. You CANNOT combine two ImGuiKey values.
    // - The general idea is that several callers may register interest in a shortcut, and only one owner gets it.
    //      Parent   -> call Shortcut(Ctrl+S)    // When Parent is focused, Parent gets the shortcut.
    //        Child1 -> call Shortcut(Ctrl+S)    // When Child1 is focused, Child1 gets the shortcut (Child1 overrides Parent shortcuts)
    //        Child2 -> no call                  // When Child2 is focused, Parent gets the shortcut.
    //   The whole system is order independent, so if Child1 makes its calls before Parent, results will be identical.
    //   This is an important property as it facilitate working with foreign code or larger codebase.
    // - To understand the difference:
    //   - IsKeyChordPressed() compares mods and call IsKeyPressed()
    //     -> the function has no side-effect.
    //   - Shortcut() submits a route, routes are resolved, if it currently can be routed it calls IsKeyChordPressed()
    //     -> the function has (desirable) side-effects as it can prevents another call from getting the route.
    // - Visualize registered routes in 'Metrics/Debugger->Inputs'.
    class function Shortcut(const AKeyChord: TImGuiKeyChord; const AFlags: TImGuiInputFlags = []): Boolean; inline; static;
    class procedure SetNextItemShortcut(const AKeyChord: TImGuiKeyChord; const AFlags: TImGuiInputFlags = []); inline; static;

    // Inputs Utilities: Key/Input Ownership [BETA]
    // - One common use case would be to allow your items to disable standard inputs behaviors such
    //   as Tab or Alt key handling, Mouse Wheel scrolling, etc.
    //   e.g. `Button(...); if (SetItemKeyOwner(ImGuiKey_MouseWheelY)) { ... }` to make hovering/activating a button disable wheel for scrolling.
    // - Reminder ImGuiKey enum include access to mouse buttons and gamepad, so key ownership can apply to them.
    // - The return value of SetItemKeyOwner() says if ownership has been requested for the item, which is a shortcut to calling yet non-public TestKeyOwner() function.
    // - Many related features are still in imgui_internal.h. For instance, most IsKeyXXX()/IsMouseXXX() functions have an owner-id-aware version.
    // Set key owner to last item ID if it is hovered or active. Return true when ownership has been set. Roughly equivalent to 'if (TestKeyOwner(key, GetItemID()) && (IsItemHovered() || IsItemActive())) { SetKeyOwner(key, GetItemID());'.
    class function SetItemKeyOwner(const AKey: TImGuiKey): Boolean; inline; static;

    // Inputs Utilities: Mouse
    // - To refer to a mouse button, you may use named enums in your code e.g. ImGuiMouseButton_Left, ImGuiMouseButton_Right.
    // - You can also use regular integer: it is forever guaranteed that 0=Left, 1=Right, 2=Middle.
    // - Dragging operations are only reported after mouse has moved a certain distance away from the initial clicking position (see 'lock_threshold' and 'io.MouseDraggingThreshold')
    // is mouse button held?
    class function IsMouseDown(const AButton: TImGuiMouseButton): Boolean; inline; static;

    // did mouse button clicked? (went from !Down to Down). Same as GetMouseClickedCount() == 1.
    class function IsMouseClicked(const AButton: TImGuiMouseButton; const ARepeat: Boolean = false): Boolean; overload; inline; static;

    // did mouse button released? (went from Down to !Down)
    class function IsMouseReleased(const AButton: TImGuiMouseButton): Boolean; inline; static;

    // did mouse button double-clicked? Same as GetMouseClickedCount() == 2. (note that a double-click will also report IsMouseClicked() == true)
    class function IsMouseDoubleClicked(const AButton: TImGuiMouseButton): Boolean; inline; static;

    // delayed mouse release (use very sparingly!). Generally used with 'delay >= io.MouseDoubleClickTime' + combined with a 'io.MouseClickedLastCount==1' test. This is a very rarely used UI idiom, but some apps use this: e.g. MS Explorer single click on an icon to rename.
    class function IsMouseReleasedWithDelay(const AButton: TImGuiMouseButton; const ADelay: Single): Boolean; inline; static;

    // return the number of successive mouse-clicks at the time where a click happen (otherwise 0).
    class function GetMouseClickedCount(const AButton: TImGuiMouseButton): Int32; inline; static;

    // is mouse hovering given bounding rect (in screen space). clipped by current clipping settings, but disregarding of other consideration of focus/window ordering/popup-block.
    class function IsMouseHoveringRect(const ARMin, ARMax: TVector2; const AClip: Boolean = true): Boolean; overload; inline; static;

    // by convention we use (-FLT_MAX,-FLT_MAX) to denote that there is no mouse available
    class function IsMousePosValid(const AMousePos: PVector2 = nil): Boolean; inline; static;

    // [WILL OBSOLETE] is any mouse button held? This was designed for backends, but prefer having backend maintain a mask of held mouse buttons, because upcoming input queue system will make this invalid.
    class function IsAnyMouseDown: Boolean; inline; static;

    // shortcut to ImGui::GetIO().MousePos provided by user, to be consistent with other calls
    class function GetMousePos: TVector2; inline; static;

    // retrieve mouse position at the time of opening popup we have BeginPopup() into (helper to avoid user backing that value themselves)
    class function GetMousePosOnOpeningCurrentPopup: TVector2; inline; static;

    // is mouse dragging? (uses io.MouseDraggingThreshold if lock_threshold < 0.0f)
    class function IsMouseDragging(const AButton: TImGuiMouseButton; const ALockThreshold: Single = -1.0): Boolean; inline; static;

    // return the delta from the initial clicking position while the mouse button is pressed or was just released. This is locked and return 0.0f until the mouse moves past a distance threshold at least once (uses io.MouseDraggingThreshold if lock_threshold < 0.0f)
    class function GetMouseDragDelta(const AButton: TImGuiMouseButton = TImGuiMouseButton(0); 
      const ALockThreshold: Single = -1.0): TVector2; inline; static;

    //
    class procedure ResetMouseDragDelta(const AButton: TImGuiMouseButton = TImGuiMouseButton(0)); overload; inline; static;

    // get desired mouse cursor shape. Important: reset in ImGui::NewFrame(), this is updated during the frame. valid before Render(). If you use software rendering by setting io.MouseDrawCursor ImGui will render those for you
    class function GetMouseCursor: TImGuiMouseCursor; inline; static;

    // set desired mouse cursor shape
    class procedure SetMouseCursor(const ACursorType: TImGuiMouseCursor); inline; static;

    // Override io.WantCaptureMouse flag next frame (said flag is left for your application to handle, typical when true it instructs your app to ignore inputs). This is equivalent to setting "io.WantCaptureMouse = want_capture_mouse;" after the next NewFrame() call.
    class procedure SetNextFrameWantCaptureMouse(const AWantCaptureMouse: Boolean); inline; static;

    // Clipboard Utilities
    // - Also see the LogToClipboard() function to capture GUI into clipboard, or easily output text data to the clipboard.
    class function GetClipboardText: PUTF8Char; inline; static;
    class procedure SetClipboardText(const AText: PUTF8Char); inline; static;

    // Settings/.Ini Utilities
    // - The disk functions are automatically called if io.IniFilename != NULL (default is "imgui.ini").
    // - Set io.IniFilename to NULL to load/save manually. Read io.WantSaveIniSettings description about handling .ini saving manually.
    // - Important: default value "imgui.ini" is relative to current working dir! Most apps will want to lock this to an absolute path (e.g. same path as executables).
    // call after CreateContext() and before the first call to NewFrame(). NewFrame() automatically calls LoadIniSettingsFromDisk(io.IniFilename).
    class procedure LoadIniSettingsFromDisk(const AIniFilename: PUTF8Char); inline; static;

    // call after CreateContext() and before the first call to NewFrame() to provide .ini data from your own data source.
    class procedure LoadIniSettingsFromMemory(const AIniData: PUTF8Char; const AIniSize: NativeUInt = 0); inline; static;

    // this is automatically called (if io.IniFilename is not empty) a few seconds after any modification that should be reflected in the .ini file (and also by DestroyContext).
    class procedure SaveIniSettingsToDisk(const AIniFilename: PUTF8Char); inline; static;

    // return a zero-terminated string with the .ini data which you can save by your own mean. call when io.WantSaveIniSettings is set, then save data by your own mean and clear io.WantSaveIniSettings.
    class function SaveIniSettingsToMemory(const AOutIniSize: PNativeUInt = nil): PUTF8Char; inline; static;

    // Debug Utilities
    // - Your main debugging friend is the ShowMetricsWindow() function.
    // - Interactive tools are all accessible from the 'Dear ImGui Demo->Tools' menu.
    // - Read https://github.com/ocornut/imgui/wiki/Debug-Tools for a description of all available debug tools.
    class procedure DebugTextEncoding(const AText: PUTF8Char); inline; static;
    class procedure DebugFlashStyleColor(const AIdx: TImGuiCol); inline; static;
    class procedure DebugStartItemPicker; inline; static;

    // This is called by IMGUI_CHECKVERSION() macro.
    class function DebugCheckVersionAndDataLayout(const AVersionStr: PUTF8Char; 
      const ASzIo, ASzStyle, ASzVec2, ASzVec4, ASzDrawvert, ASzDrawidx: NativeUInt): Boolean; inline; static;

    // Call via IMGUI_DEBUG_LOG() for maximum stripping in caller code!
    class procedure DebugLog(const AFmt: PUTF8Char); inline; static;

    // Memory Allocators
    // - Those functions are not reliant on the current context.
    // - DLL users: heaps and globals are not shared across DLL boundaries! You will need to call SetCurrentContext() + SetAllocatorFunctions()
    //   for each static/DLL boundary you are calling from. Read "Context and Memory Allocators" section of imgui.cpp for more details.
    class procedure SetAllocatorFunctions(const AAllocFunc: TImGuiMemAllocFunc; 
      const AFreeFunc: TImGuiMemFreeFunc; const AUserData: Pointer = nil); inline; static;
    class procedure GetAllocatorFunctions(const APAllocFunc: PImGuiMemAllocFunc; 
      const APFreeFunc: PImGuiMemFreeFunc; const APUserData: PPointer); inline; static;
    class function MemAlloc(const ASize: NativeUInt): Pointer; inline; static;
    class procedure MemFree(const APtr: Pointer); inline; static;
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

type
  TImDefaults = record // static
  public
    class procedure Apply<T: record>(var ARec: T); static;
  end;

class procedure TImDefaults.Apply<T>(var ARec: T);
var 
  FC: TImFontConfig absolute ARec;
begin
  if (TypeInfo(T) = TypeInfo(TImFontConfig)) then
  begin
    FC.FontDataOwnedByAtlas := True;
    FC.ExtraSizeScale := 1;
    FC.GlyphMaxAdvanceX := Single.MaxValue;
    FC.RasterizerMultiply := 1;
    FC.RasterizerDensity := 1;
  end;
end;

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
  if Assigned(AData) and Assigned(AData._UserData) then
    PImGuiText(AData._UserData).Update(AData);
    
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
  if (TImGuiInputTextFlags(AData._EventFlag) = [TImGuiInputTextFlag.CallbackResize])
    and ((AData._BufTextLen + 2) > AData._BufSize) then
  begin
    SetLength(FBuffer, GrowCollection(Length(FBuffer), AData._BufTextLen + 1));
    AData._Buf := Pointer(FBuffer);
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

{ TImTextureRef }

procedure TImTextureRef.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

function TImTextureRef.GetTexID: TImTextureID;
begin
  Result := TImTextureID(_ImTextureRef_GetTexID(@Self));
end;

{ TImGuiTableSortSpecs }

procedure TImGuiTableSortSpecs.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

{ TImGuiTableColumnSortSpecs }

procedure TImGuiTableColumnSortSpecs.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

{ TImGuiStyle }

procedure TImGuiStyle.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

procedure TImGuiStyle.ScaleAllSizes(const AScaleFactor: Single);
begin
  _ImGuiStyle_ScaleAllSizes(@Self, AScaleFactor);
end;

{ TImGuiKeyData }

procedure TImGuiKeyData.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

{ TImGuiIO }

procedure TImGuiIO.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

procedure TImGuiIO.AddKeyEvent(const AKey: TImGuiKey; const ADown: Boolean);
begin
  _ImGuiIO_AddKeyEvent(@Self, _ImGuiKey(AKey), ADown);
end;

procedure TImGuiIO.AddKeyAnalogEvent(const AKey: TImGuiKey; const ADown: Boolean; 
  const AV: Single);
begin
  _ImGuiIO_AddKeyAnalogEvent(@Self, _ImGuiKey(AKey), ADown, AV);
end;

procedure TImGuiIO.AddMousePosEvent(const AX, AY: Single);
begin
  _ImGuiIO_AddMousePosEvent(@Self, AX, AY);
end;

procedure TImGuiIO.AddMouseButtonEvent(const AButton: Int32; const ADown: Boolean);
begin
  _ImGuiIO_AddMouseButtonEvent(@Self, AButton, ADown);
end;

procedure TImGuiIO.AddMouseWheelEvent(const AWheelX, AWheelY: Single);
begin
  _ImGuiIO_AddMouseWheelEvent(@Self, AWheelX, AWheelY);
end;

procedure TImGuiIO.AddMouseSourceEvent(const ASource: TImGuiMouseSource);
begin
  _ImGuiIO_AddMouseSourceEvent(@Self, _ImGuiMouseSource(ASource));
end;

procedure TImGuiIO.AddFocusEvent(const AFocused: Boolean);
begin
  _ImGuiIO_AddFocusEvent(@Self, AFocused);
end;

procedure TImGuiIO.AddInputCharacter(const AC: UInt32);
begin
  _ImGuiIO_AddInputCharacter(@Self, AC);
end;

procedure TImGuiIO.AddInputCharacterUTF16(const AC: Char);
begin
  _ImGuiIO_AddInputCharacterUTF16(@Self, _ImWchar16(AC));
end;

procedure TImGuiIO.AddInputCharactersUTF8(const AStr: PUTF8Char);
begin
  _ImGuiIO_AddInputCharactersUTF8(@Self, AStr);
end;

procedure TImGuiIO.SetKeyEventNativeData(const AKey: TImGuiKey; const ANativeKeycode, 
  ANativeScancode: Int32);
begin
  _ImGuiIO_SetKeyEventNativeData(@Self, _ImGuiKey(AKey), ANativeKeycode, ANativeScancode);
end;

procedure TImGuiIO.SetKeyEventNativeData(const AKey: TImGuiKey; const ANativeKeycode, 
  ANativeScancode: Int32; const ANativeLegacyIndex: Int32);
begin
  _ImGuiIO_SetKeyEventNativeDataEx(@Self, _ImGuiKey(AKey), ANativeKeycode, ANativeScancode, ANativeLegacyIndex);
end;

procedure TImGuiIO.SetAppAcceptingEvents(const AAcceptingEvents: Boolean);
begin
  _ImGuiIO_SetAppAcceptingEvents(@Self, AAcceptingEvents);
end;

procedure TImGuiIO.ClearEventsQueue;
begin
  _ImGuiIO_ClearEventsQueue(@Self);
end;

procedure TImGuiIO.ClearInputKeys;
begin
  _ImGuiIO_ClearInputKeys(@Self);
end;

procedure TImGuiIO.ClearInputMouse;
begin
  _ImGuiIO_ClearInputMouse(@Self);
end;

{ TImGuiInputTextCallbackData }

procedure TImGuiInputTextCallbackData.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

procedure TImGuiInputTextCallbackData.DeleteChars(const APos, ABytesCount: Int32);
begin
  _ImGuiInputTextCallbackData_DeleteChars(@Self, APos, ABytesCount);
end;

procedure TImGuiInputTextCallbackData.InsertChars(const APos: Int32; const AText: PUTF8Char; 
  const ATextEnd: PUTF8Char);
begin
  _ImGuiInputTextCallbackData_InsertChars(@Self, APos, AText, ATextEnd);
end;

procedure TImGuiInputTextCallbackData.SelectAll;
begin
  _ImGuiInputTextCallbackData_SelectAll(@Self);
end;

procedure TImGuiInputTextCallbackData.SetSelection(const &AS, AE: Int32);
begin
  _ImGuiInputTextCallbackData_SetSelection(@Self, &AS, AE);
end;

procedure TImGuiInputTextCallbackData.ClearSelection;
begin
  _ImGuiInputTextCallbackData_ClearSelection(@Self);
end;

function TImGuiInputTextCallbackData.HasSelection: Boolean;
begin
  Result := _ImGuiInputTextCallbackData_HasSelection(@Self);
end;

{ TImGuiSizeCallbackData }

procedure TImGuiSizeCallbackData.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

{ TImGuiPayload }

procedure TImGuiPayload.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

procedure TImGuiPayload.Clear;
begin
  _ImGuiPayload_Clear(@Self);
end;

function TImGuiPayload.IsDataType(const AType: PUTF8Char): Boolean;
begin
  Result := _ImGuiPayload_IsDataType(@Self, AType);
end;

function TImGuiPayload.IsPreview: Boolean;
begin
  Result := _ImGuiPayload_IsPreview(@Self);
end;

function TImGuiPayload.IsDelivery: Boolean;
begin
  Result := _ImGuiPayload_IsDelivery(@Self);
end;

{ TImGuiTextRange }

procedure TImGuiTextRange.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

{ TImGuiTextFilter }

procedure TImGuiTextFilter.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

function TImGuiTextFilter.Draw(const ALabel: PUTF8Char; const AWidth: Single): Boolean;
begin
  Result := _ImGuiTextFilter_Draw(@Self, ALabel, AWidth);
end;

function TImGuiTextFilter.Draw(const AWidth: Single = 0.0): Boolean;
begin
  Result := _ImGuiTextFilter_Draw(@Self, PUTF8Char('Filter (inc,-exc)'), AWidth);
end;

function TImGuiTextFilter.PassFilter(const AText: PUTF8Char; const ATextEnd: PUTF8Char): Boolean;
begin
  Result := _ImGuiTextFilter_PassFilter(@Self, AText, ATextEnd);
end;

procedure TImGuiTextFilter.Build;
begin
  _ImGuiTextFilter_Build(@Self);
end;

procedure TImGuiTextFilter.Clear;
begin
  _ImGuiTextFilter_Clear(@Self);
end;

function TImGuiTextFilter.IsActive: Boolean;
begin
  Result := _ImGuiTextFilter_IsActive(@Self);
end;

{ TImGuiTextBuffer }

procedure TImGuiTextBuffer.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

function TImGuiTextBuffer.&Begin: PUTF8Char;
begin
  Result := _ImGuiTextBuffer_begin(@Self);
end;

function TImGuiTextBuffer.&End: PUTF8Char;
begin
  Result := _ImGuiTextBuffer_end(@Self);
end;

function TImGuiTextBuffer.Size: Int32;
begin
  Result := _ImGuiTextBuffer_size(@Self);
end;

function TImGuiTextBuffer.Empty: Boolean;
begin
  Result := _ImGuiTextBuffer_empty(@Self);
end;

procedure TImGuiTextBuffer.Clear;
begin
  _ImGuiTextBuffer_clear(@Self);
end;

procedure TImGuiTextBuffer.Resize(const ASize: Int32);
begin
  _ImGuiTextBuffer_resize(@Self, ASize);
end;

procedure TImGuiTextBuffer.Reserve(const ACapacity: Int32);
begin
  _ImGuiTextBuffer_reserve(@Self, ACapacity);
end;

function TImGuiTextBuffer.CStr: PUTF8Char;
begin
  Result := _ImGuiTextBuffer_c_str(@Self);
end;

procedure TImGuiTextBuffer.Append(const AStr: PUTF8Char; const AStrEnd: PUTF8Char);
begin
  _ImGuiTextBuffer_append(@Self, AStr, AStrEnd);
end;

procedure TImGuiTextBuffer.Appendf(const AFmt: PUTF8Char);
begin
  _ImGuiTextBuffer_appendf(@Self, AFmt);
end;

{ TImGuiStoragePair }

procedure TImGuiStoragePair.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

{ TImGuiStorage }

procedure TImGuiStorage.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

procedure TImGuiStorage.Clear;
begin
  _ImGuiStorage_Clear(@Self);
end;

function TImGuiStorage.GetInt(const AKey: TImGuiID; const ADefaultVal: Int32): Int32;
begin
  Result := _ImGuiStorage_GetInt(@Self, _ImGuiID(AKey), ADefaultVal);
end;

procedure TImGuiStorage.SetInt(const AKey: TImGuiID; const AVal: Int32);
begin
  _ImGuiStorage_SetInt(@Self, _ImGuiID(AKey), AVal);
end;

function TImGuiStorage.GetBool(const AKey: TImGuiID; const ADefaultVal: Boolean): Boolean;
begin
  Result := _ImGuiStorage_GetBool(@Self, _ImGuiID(AKey), ADefaultVal);
end;

procedure TImGuiStorage.SetBool(const AKey: TImGuiID; const AVal: Boolean);
begin
  _ImGuiStorage_SetBool(@Self, _ImGuiID(AKey), AVal);
end;

function TImGuiStorage.GetFloat(const AKey: TImGuiID; const ADefaultVal: Single): Single;
begin
  Result := _ImGuiStorage_GetFloat(@Self, _ImGuiID(AKey), ADefaultVal);
end;

procedure TImGuiStorage.SetFloat(const AKey: TImGuiID; const AVal: Single);
begin
  _ImGuiStorage_SetFloat(@Self, _ImGuiID(AKey), AVal);
end;

function TImGuiStorage.GetVoidPtr(const AKey: TImGuiID): Pointer;
begin
  Result := _ImGuiStorage_GetVoidPtr(@Self, _ImGuiID(AKey));
end;

procedure TImGuiStorage.SetVoidPtr(const AKey: TImGuiID; const AVal: Pointer);
begin
  _ImGuiStorage_SetVoidPtr(@Self, _ImGuiID(AKey), AVal);
end;

function TImGuiStorage.GetIntRef(const AKey: TImGuiID; const ADefaultVal: Int32): PInt32;
begin
  Result := _ImGuiStorage_GetIntRef(@Self, _ImGuiID(AKey), ADefaultVal);
end;

function TImGuiStorage.GetBoolRef(const AKey: TImGuiID; const ADefaultVal: Boolean): PBoolean;
begin
  Result := _ImGuiStorage_GetBoolRef(@Self, _ImGuiID(AKey), ADefaultVal);
end;

function TImGuiStorage.GetFloatRef(const AKey: TImGuiID; const ADefaultVal: Single): PSingle;
begin
  Result := _ImGuiStorage_GetFloatRef(@Self, _ImGuiID(AKey), ADefaultVal);
end;

function TImGuiStorage.GetVoidPtrRef(const AKey: TImGuiID; const ADefaultVal: Pointer): PPointer;
begin
  Result := _ImGuiStorage_GetVoidPtrRef(@Self, _ImGuiID(AKey), ADefaultVal);
end;

procedure TImGuiStorage.BuildSortByKey;
begin
  _ImGuiStorage_BuildSortByKey(@Self);
end;

procedure TImGuiStorage.SetAllInt(const AVal: Int32);
begin
  _ImGuiStorage_SetAllInt(@Self, AVal);
end;

{ TImGuiListClipper }

procedure TImGuiListClipper.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

procedure TImGuiListClipper.&Begin(const AItemsCount: Int32; const AItemsHeight: Single);
begin
  _ImGuiListClipper_Begin(@Self, AItemsCount, AItemsHeight);
end;

procedure TImGuiListClipper.&End;
begin
  _ImGuiListClipper_End(@Self);
end;

function TImGuiListClipper.Step: Boolean;
begin
  Result := _ImGuiListClipper_Step(@Self);
end;

procedure TImGuiListClipper.IncludeItemByIndex(const AItemIndex: Int32);
begin
  _ImGuiListClipper_IncludeItemByIndex(@Self, AItemIndex);
end;

procedure TImGuiListClipper.IncludeItemsByIndex(const AItemBegin, AItemEnd: Int32);
begin
  _ImGuiListClipper_IncludeItemsByIndex(@Self, AItemBegin, AItemEnd);
end;

procedure TImGuiListClipper.SeekCursorForItem(const AItemIndex: Int32);
begin
  _ImGuiListClipper_SeekCursorForItem(@Self, AItemIndex);
end;

{ TImGuiSelectionRequest }

procedure TImGuiSelectionRequest.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

{ TImGuiMultiSelectIO }

procedure TImGuiMultiSelectIO.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

{ TImGuiSelectionBasicStorage }

procedure TImGuiSelectionBasicStorage.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

procedure TImGuiSelectionBasicStorage.ApplyRequests(const AMsIo: PImGuiMultiSelectIO);
begin
  _ImGuiSelectionBasicStorage_ApplyRequests(@Self, AMsIo);
end;

function TImGuiSelectionBasicStorage.Contains(const AId: TImGuiID): Boolean;
begin
  Result := _ImGuiSelectionBasicStorage_Contains(@Self, _ImGuiID(AId));
end;

procedure TImGuiSelectionBasicStorage.Clear;
begin
  _ImGuiSelectionBasicStorage_Clear(@Self);
end;

procedure TImGuiSelectionBasicStorage.Swap(const AR: PImGuiSelectionBasicStorage);
begin
  _ImGuiSelectionBasicStorage_Swap(@Self, AR);
end;

procedure TImGuiSelectionBasicStorage.SetItemSelected(const AId: TImGuiID; const ASelected: Boolean);
begin
  _ImGuiSelectionBasicStorage_SetItemSelected(@Self, _ImGuiID(AId), ASelected);
end;

function TImGuiSelectionBasicStorage.GetNextSelectedItem(const AOpaqueIt: PPointer; 
  const AOutId: PImGuiID): Boolean;
begin
  Result := _ImGuiSelectionBasicStorage_GetNextSelectedItem(@Self, AOpaqueIt, AOutId);
end;

function TImGuiSelectionBasicStorage.GetStorageIdFromIndex(const AIdx: Int32): TImGuiID;
begin
  Result := TImGuiID(_ImGuiSelectionBasicStorage_GetStorageIdFromIndex(@Self, AIdx));
end;

{ TImGuiSelectionExternalStorage }

procedure TImGuiSelectionExternalStorage.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

procedure TImGuiSelectionExternalStorage.ApplyRequests(const AMsIo: PImGuiMultiSelectIO);
begin
  _ImGuiSelectionExternalStorage_ApplyRequests(@Self, AMsIo);
end;

{ TImDrawCmd }

procedure TImDrawCmd.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

function TImDrawCmd.GetTexID: TImTextureID;
begin
  Result := TImTextureID(_ImDrawCmd_GetTexID(@Self));
end;

{ TImDrawVert }

procedure TImDrawVert.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

{ TImDrawCmdHeader }

procedure TImDrawCmdHeader.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

{ TImDrawChannel }

procedure TImDrawChannel.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

{ TImDrawListSplitter }

procedure TImDrawListSplitter.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

procedure TImDrawListSplitter.Clear;
begin
  _ImDrawListSplitter_Clear(@Self);
end;

procedure TImDrawListSplitter.ClearFreeMemory;
begin
  _ImDrawListSplitter_ClearFreeMemory(@Self);
end;

procedure TImDrawListSplitter.Split(const ADrawList: PImDrawList; const ACount: Int32);
begin
  _ImDrawListSplitter_Split(@Self, ADrawList, ACount);
end;

procedure TImDrawListSplitter.Merge(const ADrawList: PImDrawList);
begin
  _ImDrawListSplitter_Merge(@Self, ADrawList);
end;

procedure TImDrawListSplitter.SetCurrentChannel(const ADrawList: PImDrawList; const AChannelIdx: Int32);
begin
  _ImDrawListSplitter_SetCurrentChannel(@Self, ADrawList, AChannelIdx);
end;

{ TImDrawList }

procedure TImDrawList.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

procedure TImDrawList.PushClipRect(const AClipRectMin, AClipRectMax: TVector2; const AIntersectWithCurrentClipRect: Boolean);
begin
  _ImDrawList_PushClipRect(@Self, _ImVec2(AClipRectMin), _ImVec2(AClipRectMax), AIntersectWithCurrentClipRect);
end;

procedure TImDrawList.PushClipRectFullScreen;
begin
  _ImDrawList_PushClipRectFullScreen(@Self);
end;

procedure TImDrawList.PopClipRect;
begin
  _ImDrawList_PopClipRect(@Self);
end;

procedure TImDrawList.PushTexture(const ATexRef: TImTextureRef);
begin
  _ImDrawList_PushTexture(@Self, _ImTextureRef(ATexRef));
end;

procedure TImDrawList.PopTexture;
begin
  _ImDrawList_PopTexture(@Self);
end;

function TImDrawList.GetClipRectMin: TVector2;
begin
  Result := TVector2(_ImDrawList_GetClipRectMin(@Self));
end;

function TImDrawList.GetClipRectMax: TVector2;
begin
  Result := TVector2(_ImDrawList_GetClipRectMax(@Self));
end;

procedure TImDrawList.AddLine(const AP1, AP2: TVector2; const ACol: UInt32);
begin
  _ImDrawList_AddLine(@Self, _ImVec2(AP1), _ImVec2(AP2), _ImU32(ACol));
end;

procedure TImDrawList.AddLine(const AP1, AP2: TVector2; const ACol: UInt32; const AThickness: Single);
begin
  _ImDrawList_AddLineEx(@Self, _ImVec2(AP1), _ImVec2(AP2), _ImU32(ACol), AThickness);
end;

procedure TImDrawList.AddLineH(const AMinX, AMaxX, AY: Single; const ACol: UInt32);
begin
  _ImDrawList_AddLineH(@Self, AMinX, AMaxX, AY, _ImU32(ACol));
end;

procedure TImDrawList.AddLineH(const AMinX, AMaxX, AY: Single; const ACol: UInt32; 
  const AThickness: Single);
begin
  _ImDrawList_AddLineHEx(@Self, AMinX, AMaxX, AY, _ImU32(ACol), AThickness);
end;

procedure TImDrawList.AddLineV(const AX, AMinY, AMaxY: Single; const ACol: UInt32);
begin
  _ImDrawList_AddLineV(@Self, AX, AMinY, AMaxY, _ImU32(ACol));
end;

procedure TImDrawList.AddLineV(const AX, AMinY, AMaxY: Single; const ACol: UInt32; 
  const AThickness: Single);
begin
  _ImDrawList_AddLineVEx(@Self, AX, AMinY, AMaxY, _ImU32(ACol), AThickness);
end;

procedure TImDrawList.AddRect(const APMin, APMax: TVector2; const ACol: UInt32);
begin
  _ImDrawList_AddRect(@Self, _ImVec2(APMin), _ImVec2(APMax), _ImU32(ACol));
end;

procedure TImDrawList.AddRect(const APMin, APMax: TVector2; const ACol: UInt32; 
  const ARounding: Single; const AThickness: Single; const AFlags: TImDrawFlags);
begin
  _ImDrawList_AddRectEx(@Self, _ImVec2(APMin), _ImVec2(APMax), _ImU32(ACol), ARounding, AThickness, Cardinal(AFlags));
end;

procedure TImDrawList.AddRectFilled(const APMin, APMax: TVector2; const ACol: UInt32);
begin
  _ImDrawList_AddRectFilled(@Self, _ImVec2(APMin), _ImVec2(APMax), _ImU32(ACol));
end;

procedure TImDrawList.AddRectFilled(const APMin, APMax: TVector2; const ACol: UInt32; 
  const ARounding: Single; const AFlags: TImDrawFlags);
begin
  _ImDrawList_AddRectFilledEx(@Self, _ImVec2(APMin), _ImVec2(APMax), _ImU32(ACol), ARounding, Cardinal(AFlags));
end;

procedure TImDrawList.AddRectFilledMultiColor(const APMin, APMax: TVector2; const AColUprLeft, 
  AColUprRight, AColBotRight, AColBotLeft: UInt32);
begin
  _ImDrawList_AddRectFilledMultiColor(@Self, _ImVec2(APMin), _ImVec2(APMax), _ImU32(AColUprLeft), _ImU32(AColUprRight), _ImU32(AColBotRight), _ImU32(AColBotLeft));
end;

procedure TImDrawList.AddQuad(const AP1, AP2, AP3, AP4: TVector2; const ACol: UInt32);
begin
  _ImDrawList_AddQuad(@Self, _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImVec2(AP4), _ImU32(ACol));
end;

procedure TImDrawList.AddQuad(const AP1, AP2, AP3, AP4: TVector2; const ACol: UInt32; 
  const AThickness: Single);
begin
  _ImDrawList_AddQuadEx(@Self, _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImVec2(AP4), _ImU32(ACol), AThickness);
end;

procedure TImDrawList.AddQuadFilled(const AP1, AP2, AP3, AP4: TVector2; const ACol: UInt32);
begin
  _ImDrawList_AddQuadFilled(@Self, _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImVec2(AP4), _ImU32(ACol));
end;

procedure TImDrawList.AddTriangle(const AP1, AP2, AP3: TVector2; const ACol: UInt32);
begin
  _ImDrawList_AddTriangle(@Self, _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImU32(ACol));
end;

procedure TImDrawList.AddTriangle(const AP1, AP2, AP3: TVector2; const ACol: UInt32; 
  const AThickness: Single);
begin
  _ImDrawList_AddTriangleEx(@Self, _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImU32(ACol), AThickness);
end;

procedure TImDrawList.AddTriangleFilled(const AP1, AP2, AP3: TVector2; const ACol: UInt32);
begin
  _ImDrawList_AddTriangleFilled(@Self, _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImU32(ACol));
end;

procedure TImDrawList.AddCircle(const ACenter: TVector2; const ARadius: Single; 
  const ACol: UInt32);
begin
  _ImDrawList_AddCircle(@Self, _ImVec2(ACenter), ARadius, _ImU32(ACol));
end;

procedure TImDrawList.AddCircle(const ACenter: TVector2; const ARadius: Single; 
  const ACol: UInt32; const ANumSegments: Int32; const AThickness: Single);
begin
  _ImDrawList_AddCircleEx(@Self, _ImVec2(ACenter), ARadius, _ImU32(ACol), ANumSegments, AThickness);
end;

procedure TImDrawList.AddCircleFilled(const ACenter: TVector2; const ARadius: Single; 
  const ACol: UInt32; const ANumSegments: Int32);
begin
  _ImDrawList_AddCircleFilled(@Self, _ImVec2(ACenter), ARadius, _ImU32(ACol), ANumSegments);
end;

procedure TImDrawList.AddNgon(const ACenter: TVector2; const ARadius: Single; const ACol: UInt32; 
  const ANumSegments: Int32);
begin
  _ImDrawList_AddNgon(@Self, _ImVec2(ACenter), ARadius, _ImU32(ACol), ANumSegments);
end;

procedure TImDrawList.AddNgon(const ACenter: TVector2; const ARadius: Single; const ACol: UInt32; 
  const ANumSegments: Int32; const AThickness: Single);
begin
  _ImDrawList_AddNgonEx(@Self, _ImVec2(ACenter), ARadius, _ImU32(ACol), ANumSegments, AThickness);
end;

procedure TImDrawList.AddNgonFilled(const ACenter: TVector2; const ARadius: Single; 
  const ACol: UInt32; const ANumSegments: Int32);
begin
  _ImDrawList_AddNgonFilled(@Self, _ImVec2(ACenter), ARadius, _ImU32(ACol), ANumSegments);
end;

procedure TImDrawList.AddEllipse(const ACenter, ARadius: TVector2; const ACol: UInt32);
begin
  _ImDrawList_AddEllipse(@Self, _ImVec2(ACenter), _ImVec2(ARadius), _ImU32(ACol));
end;

procedure TImDrawList.AddEllipse(const ACenter, ARadius: TVector2; const ACol: UInt32; 
  const ARot: Single; const ANumSegments: Int32; const AThickness: Single);
begin
  _ImDrawList_AddEllipseEx(@Self, _ImVec2(ACenter), _ImVec2(ARadius), _ImU32(ACol), ARot, ANumSegments, AThickness);
end;

procedure TImDrawList.AddEllipseFilled(const ACenter, ARadius: TVector2; const ACol: UInt32);
begin
  _ImDrawList_AddEllipseFilled(@Self, _ImVec2(ACenter), _ImVec2(ARadius), _ImU32(ACol));
end;

procedure TImDrawList.AddEllipseFilled(const ACenter, ARadius: TVector2; const ACol: UInt32; 
  const ARot: Single; const ANumSegments: Int32);
begin
  _ImDrawList_AddEllipseFilledEx(@Self, _ImVec2(ACenter), _ImVec2(ARadius), _ImU32(ACol), ARot, ANumSegments);
end;

procedure TImDrawList.AddText(const APos: TVector2; const ACol: UInt32; const ATextBegin: PUTF8Char);
begin
  _ImDrawList_AddText(@Self, _ImVec2(APos), _ImU32(ACol), ATextBegin);
end;

procedure TImDrawList.AddText(const APos: TVector2; const ACol: UInt32; const ATextBegin: PUTF8Char; 
  const ATextEnd: PUTF8Char);
begin
  _ImDrawList_AddTextEx(@Self, _ImVec2(APos), _ImU32(ACol), ATextBegin, ATextEnd);
end;

procedure TImDrawList.AddText(const AFont: PImFont; const AFontSize: Single; const APos: TVector2; 
  const ACol: UInt32; const ATextBegin: PUTF8Char);
begin
  _ImDrawList_AddTextImFontPtr(@Self, AFont, AFontSize, _ImVec2(APos), _ImU32(ACol), ATextBegin);
end;

procedure TImDrawList.AddText(const AFont: PImFont; const AFontSize: Single; const APos: TVector2; 
  const ACol: UInt32; const ATextBegin: PUTF8Char; const ATextEnd: PUTF8Char; const AWrapWidth: Single; 
  const ACpuFineClipRect: PVector4);
begin
  _ImDrawList_AddTextImFontPtrEx(@Self, AFont, AFontSize, _ImVec2(APos), _ImU32(ACol), ATextBegin, ATextEnd, AWrapWidth, ACpuFineClipRect);
end;

procedure TImDrawList.AddBezierCubic(const AP1, AP2, AP3, AP4: TVector2; const ACol: UInt32; 
  const AThickness: Single; const ANumSegments: Int32);
begin
  _ImDrawList_AddBezierCubic(@Self, _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImVec2(AP4), _ImU32(ACol), AThickness, ANumSegments);
end;

procedure TImDrawList.AddBezierQuadratic(const AP1, AP2, AP3: TVector2; const ACol: UInt32; 
  const AThickness: Single; const ANumSegments: Int32);
begin
  _ImDrawList_AddBezierQuadratic(@Self, _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImU32(ACol), AThickness, ANumSegments);
end;

procedure TImDrawList.AddPolyline(const APoints: PVector2; const ANumPoints: Int32; 
  const ACol: UInt32; const AThickness: Single; const AFlags: TImDrawFlags);
begin
  _ImDrawList_AddPolyline(@Self, APoints, ANumPoints, _ImU32(ACol), AThickness, Cardinal(AFlags));
end;

procedure TImDrawList.AddConvexPolyFilled(const APoints: PVector2; const ANumPoints: Int32; 
  const ACol: UInt32);
begin
  _ImDrawList_AddConvexPolyFilled(@Self, APoints, ANumPoints, _ImU32(ACol));
end;

procedure TImDrawList.AddConcavePolyFilled(const APoints: PVector2; const ANumPoints: Int32; 
  const ACol: UInt32);
begin
  _ImDrawList_AddConcavePolyFilled(@Self, APoints, ANumPoints, _ImU32(ACol));
end;

procedure TImDrawList.AddImage(const ATexRef: TImTextureRef; const APMin, APMax: TVector2);
begin
  _ImDrawList_AddImage(@Self, _ImTextureRef(ATexRef), _ImVec2(APMin), _ImVec2(APMax));
end;

procedure TImDrawList.AddImage(const ATexRef: TImTextureRef; const APMin, APMax, 
  AUvMin, AUvMax: TVector2; const ACol: UInt32);
begin
  _ImDrawList_AddImageEx(@Self, _ImTextureRef(ATexRef), _ImVec2(APMin), _ImVec2(APMax), _ImVec2(AUvMin), _ImVec2(AUvMax), _ImU32(ACol));
end;

procedure TImDrawList.AddImage(const ATexRef: TImTextureRef; const APMin, APMax, AUvMin: TVector2; const ACol: UInt32 = IM_COL32_WHITE);
begin
  _ImDrawList_AddImageEx(@Self, _ImTextureRef(ATexRef), _ImVec2(APMin), _ImVec2(APMax), _ImVec2(AUvMin), _ImVec2(TVector2.One), _ImU32(ACol));
end;

procedure TImDrawList.AddImageQuad(const ATexRef: TImTextureRef; const AP1, AP2, 
  AP3, AP4: TVector2);
begin
  _ImDrawList_AddImageQuad(@Self, _ImTextureRef(ATexRef), _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImVec2(AP4));
end;

procedure TImDrawList.AddImageQuad(const ATexRef: TImTextureRef; const AP1, AP2, 
  AP3, AP4, AUv1, AUv2, AUv3, AUv4: TVector2; const ACol: UInt32);
begin
  _ImDrawList_AddImageQuadEx(@Self, _ImTextureRef(ATexRef), _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImVec2(AP4), _ImVec2(AUv1), _ImVec2(AUv2), _ImVec2(AUv3), _ImVec2(AUv4), _ImU32(ACol));
end;

procedure TImDrawList.AddImageQuad(const ATexRef: TImTextureRef; const AP1, AP2, AP3, AP4, AUv1: TVector2; const ACol: UInt32 = IM_COL32_WHITE);
begin
  _ImDrawList_AddImageQuadEx(@Self, _ImTextureRef(ATexRef), _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImVec2(AP4), _ImVec2(AUv1), _ImVec2(TVector2.UnitX), _ImVec2(TVector2.One), _ImVec2(TVector2.UnitY), _ImU32(ACol));
end;

procedure TImDrawList.AddImageQuad(const ATexRef: TImTextureRef; const AP1, AP2, AP3, AP4, AUv1, AUv2: TVector2; const ACol: UInt32 = IM_COL32_WHITE);
begin
  _ImDrawList_AddImageQuadEx(@Self, _ImTextureRef(ATexRef), _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImVec2(AP4), _ImVec2(AUv1), _ImVec2(AUv2), _ImVec2(TVector2.One), _ImVec2(TVector2.UnitY), _ImU32(ACol));
end;

procedure TImDrawList.AddImageQuad(const ATexRef: TImTextureRef; const AP1, AP2, AP3, AP4, AUv1, AUv2, AUv3: TVector2; const ACol: UInt32 = IM_COL32_WHITE);
begin
  _ImDrawList_AddImageQuadEx(@Self, _ImTextureRef(ATexRef), _ImVec2(AP1), _ImVec2(AP2), _ImVec2(AP3), _ImVec2(AP4), _ImVec2(AUv1), _ImVec2(AUv2), _ImVec2(AUv3), _ImVec2(TVector2.UnitY), _ImU32(ACol));
end;

procedure TImDrawList.AddImageRounded(const ATexRef: TImTextureRef; const APMin, 
  APMax, AUvMin, AUvMax: TVector2; const ACol: UInt32; const ARounding: Single; 
  const AFlags: TImDrawFlags);
begin
  _ImDrawList_AddImageRounded(@Self, _ImTextureRef(ATexRef), _ImVec2(APMin), _ImVec2(APMax), _ImVec2(AUvMin), _ImVec2(AUvMax), _ImU32(ACol), ARounding, Cardinal(AFlags));
end;

procedure TImDrawList.PathClear;
begin
  _ImDrawList_PathClear(@Self);
end;

procedure TImDrawList.PathLineTo(const APos: TVector2);
begin
  _ImDrawList_PathLineTo(@Self, _ImVec2(APos));
end;

procedure TImDrawList.PathLineToMergeDuplicate(const APos: TVector2);
begin
  _ImDrawList_PathLineToMergeDuplicate(@Self, _ImVec2(APos));
end;

procedure TImDrawList.PathFillConvex(const ACol: UInt32);
begin
  _ImDrawList_PathFillConvex(@Self, _ImU32(ACol));
end;

procedure TImDrawList.PathFillConcave(const ACol: UInt32);
begin
  _ImDrawList_PathFillConcave(@Self, _ImU32(ACol));
end;

procedure TImDrawList.PathStroke(const ACol: UInt32; const AThickness: Single; const AFlags: TImDrawFlags);
begin
  _ImDrawList_PathStroke(@Self, _ImU32(ACol), AThickness, Cardinal(AFlags));
end;

procedure TImDrawList.PathArcTo(const ACenter: TVector2; const ARadius, AAMin, AAMax: Single; 
  const ANumSegments: Int32);
begin
  _ImDrawList_PathArcTo(@Self, _ImVec2(ACenter), ARadius, AAMin, AAMax, ANumSegments);
end;

procedure TImDrawList.PathArcToFast(const ACenter: TVector2; const ARadius: Single; 
  const AAMinOf12, AAMaxOf12: Int32);
begin
  _ImDrawList_PathArcToFast(@Self, _ImVec2(ACenter), ARadius, AAMinOf12, AAMaxOf12);
end;

procedure TImDrawList.PathEllipticalArcTo(const ACenter, ARadius: TVector2; const ARot, 
  AAMin, AAMax: Single);
begin
  _ImDrawList_PathEllipticalArcTo(@Self, _ImVec2(ACenter), _ImVec2(ARadius), ARot, AAMin, AAMax);
end;

procedure TImDrawList.PathEllipticalArcTo(const ACenter, ARadius: TVector2; const ARot, 
  AAMin, AAMax: Single; const ANumSegments: Int32);
begin
  _ImDrawList_PathEllipticalArcToEx(@Self, _ImVec2(ACenter), _ImVec2(ARadius), ARot, AAMin, AAMax, ANumSegments);
end;

procedure TImDrawList.PathBezierCubicCurveTo(const AP2, AP3, AP4: TVector2; const ANumSegments: Int32);
begin
  _ImDrawList_PathBezierCubicCurveTo(@Self, _ImVec2(AP2), _ImVec2(AP3), _ImVec2(AP4), ANumSegments);
end;

procedure TImDrawList.PathBezierQuadraticCurveTo(const AP2, AP3: TVector2; const ANumSegments: Int32);
begin
  _ImDrawList_PathBezierQuadraticCurveTo(@Self, _ImVec2(AP2), _ImVec2(AP3), ANumSegments);
end;

procedure TImDrawList.PathRect(const ARectMin, ARectMax: TVector2; const ARounding: Single; 
  const AFlags: TImDrawFlags);
begin
  _ImDrawList_PathRect(@Self, _ImVec2(ARectMin), _ImVec2(ARectMax), ARounding, Cardinal(AFlags));
end;

procedure TImDrawList.AddCallback(const ACallback: TImDrawCallback);
begin
  _ImDrawList_AddCallback(@Self, _ImDrawCallback(ACallback));
end;

procedure TImDrawList.AddCallback(const ACallback: TImDrawCallback; const AUserdata: Pointer; 
  const AUserdataSize: NativeUInt);
begin
  _ImDrawList_AddCallbackEx(@Self, _ImDrawCallback(ACallback), AUserdata, AUserdataSize);
end;

procedure TImDrawList.AddDrawCmd;
begin
  _ImDrawList_AddDrawCmd(@Self);
end;

function TImDrawList.CloneOutput: PImDrawList;
begin
  Result := _ImDrawList_CloneOutput(@Self);
end;

procedure TImDrawList.ChannelsSplit(const ACount: Int32);
begin
  _ImDrawList_ChannelsSplit(@Self, ACount);
end;

procedure TImDrawList.ChannelsMerge;
begin
  _ImDrawList_ChannelsMerge(@Self);
end;

procedure TImDrawList.ChannelsSetCurrent(const AN: Int32);
begin
  _ImDrawList_ChannelsSetCurrent(@Self, AN);
end;

procedure TImDrawList.PrimReserve(const AIdxCount, AVtxCount: Int32);
begin
  _ImDrawList_PrimReserve(@Self, AIdxCount, AVtxCount);
end;

procedure TImDrawList.PrimUnreserve(const AIdxCount, AVtxCount: Int32);
begin
  _ImDrawList_PrimUnreserve(@Self, AIdxCount, AVtxCount);
end;

procedure TImDrawList.PrimRect(const AA, AB: TVector2; const ACol: UInt32);
begin
  _ImDrawList_PrimRect(@Self, _ImVec2(AA), _ImVec2(AB), _ImU32(ACol));
end;

procedure TImDrawList.PrimRectUV(const AA, AB, AUvA, AUvB: TVector2; const ACol: UInt32);
begin
  _ImDrawList_PrimRectUV(@Self, _ImVec2(AA), _ImVec2(AB), _ImVec2(AUvA), _ImVec2(AUvB), _ImU32(ACol));
end;

procedure TImDrawList.PrimQuadUV(const AA, AB, AC, AD, AUvA, AUvB, AUvC, AUvD: TVector2; 
  const ACol: UInt32);
begin
  _ImDrawList_PrimQuadUV(@Self, _ImVec2(AA), _ImVec2(AB), _ImVec2(AC), _ImVec2(AD), _ImVec2(AUvA), _ImVec2(AUvB), _ImVec2(AUvC), _ImVec2(AUvD), _ImU32(ACol));
end;

procedure TImDrawList.PrimWriteVtx(const APos, AUv: TVector2; const ACol: UInt32);
begin
  _ImDrawList_PrimWriteVtx(@Self, _ImVec2(APos), _ImVec2(AUv), _ImU32(ACol));
end;

procedure TImDrawList.PrimWriteIdx(const AIdx: TImDrawIdx);
begin
  _ImDrawList_PrimWriteIdx(@Self, _ImDrawIdx(AIdx));
end;

procedure TImDrawList.PrimVtx(const APos, AUv: TVector2; const ACol: UInt32);
begin
  _ImDrawList_PrimVtx(@Self, _ImVec2(APos), _ImVec2(AUv), _ImU32(ACol));
end;

procedure TImDrawList.SetDrawListSharedData(const AData: PImDrawListSharedData);
begin
  _ImDrawList__SetDrawListSharedData(@Self, AData);
end;

procedure TImDrawList.ResetForNewFrame;
begin
  _ImDrawList__ResetForNewFrame(@Self);
end;

procedure TImDrawList.ClearFreeMemory;
begin
  _ImDrawList__ClearFreeMemory(@Self);
end;

procedure TImDrawList.PopUnusedDrawCmd;
begin
  _ImDrawList__PopUnusedDrawCmd(@Self);
end;

procedure TImDrawList.TryMergeDrawCmds;
begin
  _ImDrawList__TryMergeDrawCmds(@Self);
end;

procedure TImDrawList.OnChangedClipRect;
begin
  _ImDrawList__OnChangedClipRect(@Self);
end;

procedure TImDrawList.OnChangedTexture;
begin
  _ImDrawList__OnChangedTexture(@Self);
end;

procedure TImDrawList.OnChangedVtxOffset;
begin
  _ImDrawList__OnChangedVtxOffset(@Self);
end;

procedure TImDrawList.SetTexture(const ATexRef: TImTextureRef);
begin
  _ImDrawList__SetTexture(@Self, _ImTextureRef(ATexRef));
end;

function TImDrawList.CalcCircleAutoSegmentCount(const ARadius: Single): Int32;
begin
  Result := _ImDrawList__CalcCircleAutoSegmentCount(@Self, ARadius);
end;

procedure TImDrawList.PathArcToFastEx(const ACenter: TVector2; const ARadius: Single; 
  const AAMinSample, AAMaxSample, AAStep: Int32);
begin
  _ImDrawList__PathArcToFastEx(@Self, _ImVec2(ACenter), ARadius, AAMinSample, AAMaxSample, AAStep);
end;

procedure TImDrawList.PathArcToN(const ACenter: TVector2; const ARadius, AAMin, 
  AAMax: Single; const ANumSegments: Int32);
begin
  _ImDrawList__PathArcToN(@Self, _ImVec2(ACenter), ARadius, AAMin, AAMax, ANumSegments);
end;

{ TImDrawData }

procedure TImDrawData.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

procedure TImDrawData.Clear;
begin
  _ImDrawData_Clear(@Self);
end;

procedure TImDrawData.AddDrawList(const ADrawList: PImDrawList);
begin
  _ImDrawData_AddDrawList(@Self, ADrawList);
end;

procedure TImDrawData.DeIndexAllBuffers;
begin
  _ImDrawData_DeIndexAllBuffers(@Self);
end;

procedure TImDrawData.ScaleClipRects(const AFbScale: TVector2);
begin
  _ImDrawData_ScaleClipRects(@Self, _ImVec2(AFbScale));
end;

{ TImTextureRect }

procedure TImTextureRect.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

{ TImTextureData }

procedure TImTextureData.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

procedure TImTextureData.Create(const AFormat: TImTextureFormat; const AW, AH: Int32);
begin
  _ImTextureData_Create(@Self, _ImTextureFormat(AFormat), AW, AH);
end;

procedure TImTextureData.DestroyPixels;
begin
  _ImTextureData_DestroyPixels(@Self);
end;

function TImTextureData.GetPixels: Pointer;
begin
  Result := _ImTextureData_GetPixels(@Self);
end;

function TImTextureData.GetPixelsAt(const AX, AY: Int32): Pointer;
begin
  Result := _ImTextureData_GetPixelsAt(@Self, AX, AY);
end;

function TImTextureData.GetSizeInBytes: Int32;
begin
  Result := _ImTextureData_GetSizeInBytes(@Self);
end;

function TImTextureData.GetPitch: Int32;
begin
  Result := _ImTextureData_GetPitch(@Self);
end;

function TImTextureData.GetTexRef: TImTextureRef;
begin
  Result := TImTextureRef(_ImTextureData_GetTexRef(@Self));
end;

function TImTextureData.GetTexID: TImTextureID;
begin
  Result := TImTextureID(_ImTextureData_GetTexID(@Self));
end;

procedure TImTextureData.SetTexID(const ATexId: TImTextureID);
begin
  _ImTextureData_SetTexID(@Self, _ImTextureID(ATexId));
end;

procedure TImTextureData.SetStatus(const AStatus: TImTextureStatus);
begin
  _ImTextureData_SetStatus(@Self, _ImTextureStatus(AStatus));
end;

{ TImFontConfig }

procedure TImFontConfig.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

{ TImFontGlyph }

procedure TImFontGlyph.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

function TImFontGlyph.GetColored: Cardinal;
begin
  Result := _Flags0 and $1;
end;

procedure TImFontGlyph.SetColored(const AValue: Cardinal);
begin
  _Flags0 := (_Flags0 and $FFFFFFFE) or (AValue and $1);
end;

function TImFontGlyph.GetVisible: Cardinal;
begin
  Result := (_Flags0 shr 1) and $1;
end;

procedure TImFontGlyph.SetVisible(const AValue: Cardinal);
begin
  _Flags0 := (_Flags0 and $FFFFFFFD) or ((AValue and $1) shl 1);
end;

function TImFontGlyph.GetSourceIdx: Cardinal;
begin
  Result := (_Flags0 shr 2) and $F;
end;

procedure TImFontGlyph.SetSourceIdx(const AValue: Cardinal);
begin
  _Flags0 := (_Flags0 and $FFFFFFC3) or ((AValue and $F) shl 2);
end;

function TImFontGlyph.GetCodepoint: Cardinal;
begin
  Result := (_Flags0 shr 6) and $3FFFFFF;
end;

procedure TImFontGlyph.SetCodepoint(const AValue: Cardinal);
begin
  _Flags0 := (_Flags0 and $3F) or ((AValue and $3FFFFFF) shl 6);
end;

{ TImFontGlyphRangesBuilder }

procedure TImFontGlyphRangesBuilder.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
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

procedure TImFontGlyphRangesBuilder.AddChar(const AC: Char);
begin
  _ImFontGlyphRangesBuilder_AddChar(@Self, _ImWchar(AC));
end;

procedure TImFontGlyphRangesBuilder.AddText(const AText: PUTF8Char; const ATextEnd: PUTF8Char);
begin
  _ImFontGlyphRangesBuilder_AddText(@Self, AText, ATextEnd);
end;

procedure TImFontGlyphRangesBuilder.AddRanges(const ARanges: PChar);
begin
  _ImFontGlyphRangesBuilder_AddRanges(@Self, ARanges);
end;

procedure TImFontGlyphRangesBuilder.BuildRanges(const AOutRanges: PImVectorImWchar);
begin
  _ImFontGlyphRangesBuilder_BuildRanges(@Self, AOutRanges);
end;

{ TImFontAtlasRect }

procedure TImFontAtlasRect.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

{ TImFontAtlas }

procedure TImFontAtlas.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

function TImFontAtlas.AddFont(const AFontCfg: PImFontConfig): PImFont;
begin
  Result := _ImFontAtlas_AddFont(@Self, AFontCfg);
end;

function TImFontAtlas.AddFontDefault(const AFontCfg: PImFontConfig): PImFont;
begin
  Result := _ImFontAtlas_AddFontDefault(@Self, AFontCfg);
end;

function TImFontAtlas.AddFontDefaultVector(const AFontCfg: PImFontConfig): PImFont;
begin
  Result := _ImFontAtlas_AddFontDefaultVector(@Self, AFontCfg);
end;

function TImFontAtlas.AddFontDefaultBitmap(const AFontCfg: PImFontConfig): PImFont;
begin
  Result := _ImFontAtlas_AddFontDefaultBitmap(@Self, AFontCfg);
end;

function TImFontAtlas.AddFontFromFileTTF(const AFilename: PUTF8Char; const ASizePixels: Single; 
  const AFontCfg: PImFontConfig; const AGlyphRanges: PChar): PImFont;
begin
  Result := _ImFontAtlas_AddFontFromFileTTF(@Self, AFilename, ASizePixels, AFontCfg, AGlyphRanges);
end;

function TImFontAtlas.AddFontFromMemoryTTF(const AFontData: Pointer; const AFontDataSize: Int32; 
  const ASizePixels: Single; const AFontCfg: PImFontConfig; const AGlyphRanges: PChar): PImFont;
begin
  Result := _ImFontAtlas_AddFontFromMemoryTTF(@Self, AFontData, AFontDataSize, ASizePixels, AFontCfg, AGlyphRanges);
end;

function TImFontAtlas.AddFontFromMemoryCompressedTTF(const ACompressedFontData: Pointer; 
  const ACompressedFontDataSize: Int32; const ASizePixels: Single; const AFontCfg: PImFontConfig; 
  const AGlyphRanges: PChar): PImFont;
begin
  Result := _ImFontAtlas_AddFontFromMemoryCompressedTTF(@Self, ACompressedFontData, ACompressedFontDataSize, ASizePixels, AFontCfg, AGlyphRanges);
end;

function TImFontAtlas.AddFontFromMemoryCompressedBase85TTF(const ACompressedFontDataBase85: PUTF8Char; 
  const ASizePixels: Single; const AFontCfg: PImFontConfig; const AGlyphRanges: PChar): PImFont;
begin
  Result := _ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(@Self, ACompressedFontDataBase85, ASizePixels, AFontCfg, AGlyphRanges);
end;

procedure TImFontAtlas.RemoveFont(const AFont: PImFont);
begin
  _ImFontAtlas_RemoveFont(@Self, AFont);
end;

procedure TImFontAtlas.Clear;
begin
  _ImFontAtlas_Clear(@Self);
end;

procedure TImFontAtlas.ClearFonts;
begin
  _ImFontAtlas_ClearFonts(@Self);
end;

procedure TImFontAtlas.CompactCache;
begin
  _ImFontAtlas_CompactCache(@Self);
end;

procedure TImFontAtlas.SetFontLoader(const AFontLoader: PImFontLoader);
begin
  _ImFontAtlas_SetFontLoader(@Self, AFontLoader);
end;

procedure TImFontAtlas.ClearInputData;
begin
  _ImFontAtlas_ClearInputData(@Self);
end;

procedure TImFontAtlas.ClearTexData;
begin
  _ImFontAtlas_ClearTexData(@Self);
end;

function TImFontAtlas.GetGlyphRangesDefault: PChar;
begin
  Result := _ImFontAtlas_GetGlyphRangesDefault(@Self);
end;

function TImFontAtlas.AddCustomRect(const AWidth, AHeight: Int32; const AOutR: PImFontAtlasRect): TImFontAtlasRectId;
begin
  Result := TImFontAtlasRectId(_ImFontAtlas_AddCustomRect(@Self, AWidth, AHeight, AOutR));
end;

procedure TImFontAtlas.RemoveCustomRect(const AId: TImFontAtlasRectId);
begin
  _ImFontAtlas_RemoveCustomRect(@Self, _ImFontAtlasRectId(AId));
end;

function TImFontAtlas.GetCustomRect(const AId: TImFontAtlasRectId; const AOutR: PImFontAtlasRect): Boolean;
begin
  Result := _ImFontAtlas_GetCustomRect(@Self, _ImFontAtlasRectId(AId), AOutR);
end;

{ TImFontBaked }

procedure TImFontBaked.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

function TImFontBaked.GetMetricsTotalSurface: Cardinal;
begin
  Result := _Flags9 and $3FFFFFF;
end;

procedure TImFontBaked.SetMetricsTotalSurface(const AValue: Cardinal);
begin
  _Flags9 := (_Flags9 and $FC000000) or (AValue and $3FFFFFF);
end;

function TImFontBaked.GetWantDestroy: Cardinal;
begin
  Result := (_Flags9 shr 26) and $1;
end;

procedure TImFontBaked.SetWantDestroy(const AValue: Cardinal);
begin
  _Flags9 := (_Flags9 and $FBFFFFFF) or ((AValue and $1) shl 26);
end;

function TImFontBaked.GetLoadNoFallback: Cardinal;
begin
  Result := (_Flags9 shr 27) and $1;
end;

procedure TImFontBaked.SetLoadNoFallback(const AValue: Cardinal);
begin
  _Flags9 := (_Flags9 and $F7FFFFFF) or ((AValue and $1) shl 27);
end;

function TImFontBaked.GetLoadNoRenderOnLayout: Cardinal;
begin
  Result := (_Flags9 shr 28) and $1;
end;

procedure TImFontBaked.SetLoadNoRenderOnLayout(const AValue: Cardinal);
begin
  _Flags9 := (_Flags9 and $EFFFFFFF) or ((AValue and $1) shl 28);
end;

procedure TImFontBaked.ClearOutputData;
begin
  _ImFontBaked_ClearOutputData(@Self);
end;

function TImFontBaked.FindGlyph(const AC: Char): PImFontGlyph;
begin
  Result := _ImFontBaked_FindGlyph(@Self, _ImWchar(AC));
end;

function TImFontBaked.FindGlyphNoFallback(const AC: Char): PImFontGlyph;
begin
  Result := _ImFontBaked_FindGlyphNoFallback(@Self, _ImWchar(AC));
end;

function TImFontBaked.GetCharAdvance(const AC: Char): Single;
begin
  Result := _ImFontBaked_GetCharAdvance(@Self, _ImWchar(AC));
end;

function TImFontBaked.IsGlyphLoaded(const AC: Char): Boolean;
begin
  Result := _ImFontBaked_IsGlyphLoaded(@Self, _ImWchar(AC));
end;

{ TImFont }

procedure TImFont.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

function TImFont.IsGlyphInFont(const AC: Char): Boolean;
begin
  Result := _ImFont_IsGlyphInFont(@Self, _ImWchar(AC));
end;

function TImFont.IsLoaded: Boolean;
begin
  Result := _ImFont_IsLoaded(@Self);
end;

function TImFont.GetDebugName: PUTF8Char;
begin
  Result := _ImFont_GetDebugName(@Self);
end;

function TImFont.GetFontBaked(const AFontSize: Single): PImFontBaked;
begin
  Result := _ImFont_GetFontBaked(@Self, AFontSize);
end;

function TImFont.GetFontBaked(const AFontSize: Single; const ADensity: Single): PImFontBaked;
begin
  Result := _ImFont_GetFontBakedEx(@Self, AFontSize, ADensity);
end;

function TImFont.CalcTextSizeA(const ASize, AMaxWidth, AWrapWidth: Single; const ATextBegin: PUTF8Char): TVector2;
begin
  Result := TVector2(_ImFont_CalcTextSizeA(@Self, ASize, AMaxWidth, AWrapWidth, ATextBegin));
end;

function TImFont.CalcTextSizeA(const ASize, AMaxWidth, AWrapWidth: Single; const ATextBegin: PUTF8Char; 
  const ATextEnd: PUTF8Char; const AOutRemaining: PPUTF8Char): TVector2;
begin
  Result := TVector2(_ImFont_CalcTextSizeAEx(@Self, ASize, AMaxWidth, AWrapWidth, ATextBegin, ATextEnd, AOutRemaining));
end;

function TImFont.CalcWordWrapPosition(const ASize: Single; const AText, ATextEnd: PUTF8Char; 
  const AWrapWidth: Single): PUTF8Char;
begin
  Result := _ImFont_CalcWordWrapPosition(@Self, ASize, AText, ATextEnd, AWrapWidth);
end;

procedure TImFont.RenderChar(const ADrawList: PImDrawList; const ASize: Single; 
  const APos: TVector2; const ACol: UInt32; const AC: Char);
begin
  _ImFont_RenderChar(@Self, ADrawList, ASize, _ImVec2(APos), _ImU32(ACol), _ImWchar(AC));
end;

procedure TImFont.RenderChar(const ADrawList: PImDrawList; const ASize: Single; 
  const APos: TVector2; const ACol: UInt32; const AC: Char; const ACpuFineClip: PVector4);
begin
  _ImFont_RenderCharEx(@Self, ADrawList, ASize, _ImVec2(APos), _ImU32(ACol), _ImWchar(AC), ACpuFineClip);
end;

procedure TImFont.RenderText(const ADrawList: PImDrawList; const ASize: Single; 
  const APos: TVector2; const ACol: UInt32; const AClipRect: TVector4; const ATextBegin, 
  ATextEnd: PUTF8Char; const AWrapWidth: Single; const AFlags: Int32);
begin
  _ImFont_RenderText(@Self, ADrawList, ASize, _ImVec2(APos), _ImU32(ACol), _ImVec4(AClipRect), ATextBegin, ATextEnd, AWrapWidth, Cardinal(AFlags));
end;

procedure TImFont.ClearOutputData;
begin
  _ImFont_ClearOutputData(@Self);
end;

procedure TImFont.AddRemapChar(const AFromCodepoint, AToCodepoint: Char);
begin
  _ImFont_AddRemapChar(@Self, _ImWchar(AFromCodepoint), _ImWchar(AToCodepoint));
end;

function TImFont.IsGlyphRangeUnused(const ACBegin, ACLast: UInt32): Boolean;
begin
  Result := _ImFont_IsGlyphRangeUnused(@Self, ACBegin, ACLast);
end;

{ TImGuiViewport }

procedure TImGuiViewport.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

function TImGuiViewport.GetCenter: TVector2;
begin
  Result := TVector2(_ImGuiViewport_GetCenter(@Self));
end;

function TImGuiViewport.GetWorkCenter: TVector2;
begin
  Result := TVector2(_ImGuiViewport_GetWorkCenter(@Self));
end;

{ TImGuiPlatformIO }

procedure TImGuiPlatformIO.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

procedure TImGuiPlatformIO.ClearPlatformHandlers;
begin
  _ImGuiPlatformIO_ClearPlatformHandlers(@Self);
end;

procedure TImGuiPlatformIO.ClearRendererHandlers;
begin
  _ImGuiPlatformIO_ClearRendererHandlers(@Self);
end;

{ TImGuiPlatformImeData }

procedure TImGuiPlatformImeData.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);
  TImDefaults.Apply(Self);
end;

{ ImGui }

class function ImGui.CreateContext(const ASharedFontAtlas: PImFontAtlas): PImGuiContext;
begin
  Result := _igCreateContext(ASharedFontAtlas);
end;

class procedure ImGui.DestroyContext(const ACtx: PImGuiContext);
begin
  _igDestroyContext(ACtx);
end;

class function ImGui.GetCurrentContext: PImGuiContext;
begin
  Result := _igGetCurrentContext();
end;

class procedure ImGui.SetCurrentContext(const ACtx: PImGuiContext);
begin
  _igSetCurrentContext(ACtx);
end;

class function ImGui.GetIO: PImGuiIO;
begin
  Result := _igGetIO();
end;

class function ImGui.GetPlatformIO: PImGuiPlatformIO;
begin
  Result := _igGetPlatformIO();
end;

class function ImGui.GetStyle: PImGuiStyle;
begin
  Result := _igGetStyle();
end;

class procedure ImGui.NewFrame;
begin
  _igNewFrame();
end;

class procedure ImGui.EndFrame;
begin
  _igEndFrame();
end;

class procedure ImGui.Render;
begin
  _igRender();
end;

class function ImGui.GetDrawData: PImDrawData;
begin
  Result := _igGetDrawData();
end;

class procedure ImGui.ShowDemoWindow(const APOpen: PBoolean);
begin
  _igShowDemoWindow(APOpen);
end;

class procedure ImGui.ShowMetricsWindow(const APOpen: PBoolean);
begin
  _igShowMetricsWindow(APOpen);
end;

class procedure ImGui.ShowDebugLogWindow(const APOpen: PBoolean);
begin
  _igShowDebugLogWindow(APOpen);
end;

class procedure ImGui.ShowIDStackToolWindow(const APOpen: PBoolean);
begin
  _igShowIDStackToolWindowEx(APOpen);
end;

class procedure ImGui.ShowAboutWindow(const APOpen: PBoolean);
begin
  _igShowAboutWindow(APOpen);
end;

class procedure ImGui.ShowStyleEditor(const ARef: PImGuiStyle);
begin
  _igShowStyleEditor(ARef);
end;

class function ImGui.ShowStyleSelector(const ALabel: PUTF8Char): Boolean;
begin
  Result := _igShowStyleSelector(ALabel);
end;

class procedure ImGui.ShowFontSelector(const ALabel: PUTF8Char);
begin
  _igShowFontSelector(ALabel);
end;

class procedure ImGui.ShowUserGuide;
begin
  _igShowUserGuide();
end;

class function ImGui.GetVersion: PUTF8Char;
begin
  Result := _igGetVersion();
end;

class procedure ImGui.StyleColorsDark(const ADst: PImGuiStyle);
begin
  _igStyleColorsDark(ADst);
end;

class procedure ImGui.StyleColorsLight(const ADst: PImGuiStyle);
begin
  _igStyleColorsLight(ADst);
end;

class procedure ImGui.StyleColorsClassic(const ADst: PImGuiStyle);
begin
  _igStyleColorsClassic(ADst);
end;

class function ImGui.&Begin(const AName: PUTF8Char; const APOpen: PBoolean; const AFlags: TImGuiWindowFlags): Boolean;
begin
  Result := _igBegin(AName, APOpen, Cardinal(AFlags));
end;

class procedure ImGui.&End;
begin
  _igEnd();
end;

class function ImGui.BeginChild(const AStrId: PUTF8Char; const ASize: TVector2; 
  const AChildFlags: TImGuiChildFlags; const AWindowFlags: TImGuiWindowFlags): Boolean;
begin
  Result := _igBeginChild(AStrId, _ImVec2(ASize), Cardinal(AChildFlags), Cardinal(AWindowFlags));
end;

class function ImGui.BeginChild(const AStrId: PUTF8Char; const AChildFlags: TImGuiChildFlags = []; const AWindowFlags: TImGuiWindowFlags = []): Boolean;
begin
  Result := _igBeginChild(AStrId, _ImVec2(TVector2.Zero), Cardinal(AChildFlags), Cardinal(AWindowFlags));
end;

class function ImGui.BeginChild(const AId: TImGuiID; const ASize: TVector2; const AChildFlags: TImGuiChildFlags; 
  const AWindowFlags: TImGuiWindowFlags): Boolean;
begin
  Result := _igBeginChildID(_ImGuiID(AId), _ImVec2(ASize), Cardinal(AChildFlags), Cardinal(AWindowFlags));
end;

class function ImGui.BeginChild(const AId: TImGuiID; const AChildFlags: TImGuiChildFlags = []; const AWindowFlags: TImGuiWindowFlags = []): Boolean;
begin
  Result := _igBeginChildID(_ImGuiID(AId), _ImVec2(TVector2.Zero), Cardinal(AChildFlags), Cardinal(AWindowFlags));
end;

class procedure ImGui.EndChild;
begin
  _igEndChild();
end;

class function ImGui.IsWindowAppearing: Boolean;
begin
  Result := _igIsWindowAppearing();
end;

class function ImGui.IsWindowCollapsed: Boolean;
begin
  Result := _igIsWindowCollapsed();
end;

class function ImGui.IsWindowFocused(const AFlags: TImGuiFocusedFlags): Boolean;
begin
  Result := _igIsWindowFocused(Cardinal(AFlags));
end;

class function ImGui.IsWindowHovered(const AFlags: TImGuiHoveredFlags): Boolean;
begin
  Result := _igIsWindowHovered(Cardinal(AFlags));
end;

class function ImGui.GetWindowDrawList: PImDrawList;
begin
  Result := _igGetWindowDrawList();
end;

class function ImGui.GetWindowPos: TVector2;
begin
  Result := TVector2(_igGetWindowPos());
end;

class function ImGui.GetWindowSize: TVector2;
begin
  Result := TVector2(_igGetWindowSize());
end;

class function ImGui.GetWindowWidth: Single;
begin
  Result := _igGetWindowWidth();
end;

class function ImGui.GetWindowHeight: Single;
begin
  Result := _igGetWindowHeight();
end;

class procedure ImGui.SetNextWindowPos(const APos: TVector2; const ACond: TImGuiCond);
begin
  _igSetNextWindowPos(_ImVec2(APos), _ImGuiCond(ACond));
end;

class procedure ImGui.SetNextWindowPos(const APos: TVector2; const ACond: TImGuiCond; 
  const APivot: TVector2);
begin
  _igSetNextWindowPosEx(_ImVec2(APos), _ImGuiCond(ACond), _ImVec2(APivot));
end;

class procedure ImGui.SetNextWindowSize(const ASize: TVector2; const ACond: TImGuiCond);
begin
  _igSetNextWindowSize(_ImVec2(ASize), _ImGuiCond(ACond));
end;

class procedure ImGui.SetNextWindowSizeConstraints(const ASizeMin, ASizeMax: TVector2; 
  const ACustomCallback: TImGuiSizeCallback; const ACustomCallbackData: Pointer);
begin
  _igSetNextWindowSizeConstraints(_ImVec2(ASizeMin), _ImVec2(ASizeMax), _ImGuiSizeCallback(ACustomCallback), ACustomCallbackData);
end;

class procedure ImGui.SetNextWindowContentSize(const ASize: TVector2);
begin
  _igSetNextWindowContentSize(_ImVec2(ASize));
end;

class procedure ImGui.SetNextWindowCollapsed(const ACollapsed: Boolean; const ACond: TImGuiCond);
begin
  _igSetNextWindowCollapsed(ACollapsed, _ImGuiCond(ACond));
end;

class procedure ImGui.SetNextWindowFocus;
begin
  _igSetNextWindowFocus();
end;

class procedure ImGui.SetNextWindowScroll(const AScroll: TVector2);
begin
  _igSetNextWindowScroll(_ImVec2(AScroll));
end;

class procedure ImGui.SetNextWindowBgAlpha(const AAlpha: Single);
begin
  _igSetNextWindowBgAlpha(AAlpha);
end;

class procedure ImGui.SetWindowPos(const APos: TVector2; const ACond: TImGuiCond);
begin
  _igSetWindowPos(_ImVec2(APos), _ImGuiCond(ACond));
end;

class procedure ImGui.SetWindowSize(const ASize: TVector2; const ACond: TImGuiCond);
begin
  _igSetWindowSize(_ImVec2(ASize), _ImGuiCond(ACond));
end;

class procedure ImGui.SetWindowCollapsed(const ACollapsed: Boolean; const ACond: TImGuiCond);
begin
  _igSetWindowCollapsed(ACollapsed, _ImGuiCond(ACond));
end;

class procedure ImGui.SetWindowFocus;
begin
  _igSetWindowFocus();
end;

class procedure ImGui.SetWindowPos(const AName: PUTF8Char; const APos: TVector2; 
  const ACond: TImGuiCond);
begin
  _igSetWindowPosStr(AName, _ImVec2(APos), _ImGuiCond(ACond));
end;

class procedure ImGui.SetWindowSize(const AName: PUTF8Char; const ASize: TVector2; 
  const ACond: TImGuiCond);
begin
  _igSetWindowSizeStr(AName, _ImVec2(ASize), _ImGuiCond(ACond));
end;

class procedure ImGui.SetWindowCollapsed(const AName: PUTF8Char; const ACollapsed: Boolean; 
  const ACond: TImGuiCond);
begin
  _igSetWindowCollapsedStr(AName, ACollapsed, _ImGuiCond(ACond));
end;

class procedure ImGui.SetWindowFocus(const AName: PUTF8Char);
begin
  _igSetWindowFocusStr(AName);
end;

class function ImGui.GetScrollX: Single;
begin
  Result := _igGetScrollX();
end;

class function ImGui.GetScrollY: Single;
begin
  Result := _igGetScrollY();
end;

class procedure ImGui.SetScrollX(const AScrollX: Single);
begin
  _igSetScrollX(AScrollX);
end;

class procedure ImGui.SetScrollY(const AScrollY: Single);
begin
  _igSetScrollY(AScrollY);
end;

class function ImGui.GetScrollMaxX: Single;
begin
  Result := _igGetScrollMaxX();
end;

class function ImGui.GetScrollMaxY: Single;
begin
  Result := _igGetScrollMaxY();
end;

class procedure ImGui.SetScrollHereX(const ACenterXRatio: Single);
begin
  _igSetScrollHereX(ACenterXRatio);
end;

class procedure ImGui.SetScrollHereY(const ACenterYRatio: Single);
begin
  _igSetScrollHereY(ACenterYRatio);
end;

class procedure ImGui.SetScrollFromPosX(const ALocalX: Single; const ACenterXRatio: Single);
begin
  _igSetScrollFromPosX(ALocalX, ACenterXRatio);
end;

class procedure ImGui.SetScrollFromPosY(const ALocalY: Single; const ACenterYRatio: Single);
begin
  _igSetScrollFromPosY(ALocalY, ACenterYRatio);
end;

class procedure ImGui.PushFont(const AFont: PImFont; const AFontSizeBaseUnscaled: Single);
begin
  _igPushFontFloat(AFont, AFontSizeBaseUnscaled);
end;

class procedure ImGui.PopFont;
begin
  _igPopFont();
end;

class function ImGui.GetFont: PImFont;
begin
  Result := _igGetFont();
end;

class function ImGui.GetFontSize: Single;
begin
  Result := _igGetFontSize();
end;

class function ImGui.GetFontBaked: PImFontBaked;
begin
  Result := _igGetFontBaked();
end;

class procedure ImGui.PushStyleColor(const AIdx: TImGuiCol; const ACol: UInt32);
begin
  _igPushStyleColor(_ImGuiCol(AIdx), _ImU32(ACol));
end;

class procedure ImGui.PushStyleColor(const AIdx: TImGuiCol; const ACol: TVector4);
begin
  _igPushStyleColorImVec4(_ImGuiCol(AIdx), _ImVec4(ACol));
end;

class procedure ImGui.PopStyleColor(const ACount: Int32);
begin
  _igPopStyleColorEx(ACount);
end;

class procedure ImGui.PushStyleVar(const AIdx: TImGuiStyleVar; const AVal: Single);
begin
  _igPushStyleVar(_ImGuiStyleVar(AIdx), AVal);
end;

class procedure ImGui.PushStyleVar(const AIdx: TImGuiStyleVar; const AVal: TVector2);
begin
  _igPushStyleVarImVec2(_ImGuiStyleVar(AIdx), _ImVec2(AVal));
end;

class procedure ImGui.PushStyleVarX(const AIdx: TImGuiStyleVar; const AValX: Single);
begin
  _igPushStyleVarX(_ImGuiStyleVar(AIdx), AValX);
end;

class procedure ImGui.PushStyleVarY(const AIdx: TImGuiStyleVar; const AValY: Single);
begin
  _igPushStyleVarY(_ImGuiStyleVar(AIdx), AValY);
end;

class procedure ImGui.PopStyleVar(const ACount: Int32);
begin
  _igPopStyleVarEx(ACount);
end;

class procedure ImGui.PushItemFlag(const AOption: TImGuiItemFlags; const AEnabled: Boolean);
begin
  _igPushItemFlag(Cardinal(AOption), AEnabled);
end;

class procedure ImGui.PopItemFlag;
begin
  _igPopItemFlag();
end;

class procedure ImGui.PushItemWidth(const AItemWidth: Single);
begin
  _igPushItemWidth(AItemWidth);
end;

class procedure ImGui.PopItemWidth;
begin
  _igPopItemWidth();
end;

class procedure ImGui.SetNextItemWidth(const AItemWidth: Single);
begin
  _igSetNextItemWidth(AItemWidth);
end;

class function ImGui.CalcItemWidth: Single;
begin
  Result := _igCalcItemWidth();
end;

class procedure ImGui.PushTextWrapPos(const AWrapLocalPosX: Single);
begin
  _igPushTextWrapPos(AWrapLocalPosX);
end;

class procedure ImGui.PopTextWrapPos;
begin
  _igPopTextWrapPos();
end;

class function ImGui.GetFontTexUvWhitePixel: TVector2;
begin
  Result := TVector2(_igGetFontTexUvWhitePixel());
end;

class function ImGui.GetColorU32(const AIdx: TImGuiCol; const AAlphaMul: Single): UInt32;
begin
  Result := UInt32(_igGetColorU32Ex(_ImGuiCol(AIdx), AAlphaMul));
end;

class function ImGui.GetColorU32(const ACol: TVector4): UInt32;
begin
  Result := UInt32(_igGetColorU32ImVec4(_ImVec4(ACol)));
end;

class function ImGui.GetColorU32(const ACol: UInt32; const AAlphaMul: Single): UInt32;
begin
  Result := UInt32(_igGetColorU32ImU32Ex(_ImU32(ACol), AAlphaMul));
end;

class function ImGui.GetStyleColorVec4(const AIdx: TImGuiCol): PVector4;
begin
  Result := _igGetStyleColorVec4(_ImGuiCol(AIdx));
end;

class function ImGui.GetCursorScreenPos: TVector2;
begin
  Result := TVector2(_igGetCursorScreenPos());
end;

class procedure ImGui.SetCursorScreenPos(const APos: TVector2);
begin
  _igSetCursorScreenPos(_ImVec2(APos));
end;

class function ImGui.GetContentRegionAvail: TVector2;
begin
  Result := TVector2(_igGetContentRegionAvail());
end;

class function ImGui.GetCursorPos: TVector2;
begin
  Result := TVector2(_igGetCursorPos());
end;

class function ImGui.GetCursorPosX: Single;
begin
  Result := _igGetCursorPosX();
end;

class function ImGui.GetCursorPosY: Single;
begin
  Result := _igGetCursorPosY();
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

class function ImGui.GetCursorStartPos: TVector2;
begin
  Result := TVector2(_igGetCursorStartPos());
end;

class procedure ImGui.Separator;
begin
  _igSeparator();
end;

class procedure ImGui.SameLine(const AOffsetFromStartX: Single; const ASpacing: Single);
begin
  _igSameLineEx(AOffsetFromStartX, ASpacing);
end;

class procedure ImGui.NewLine;
begin
  _igNewLine();
end;

class procedure ImGui.Spacing;
begin
  _igSpacing();
end;

class procedure ImGui.Dummy(const ASize: TVector2);
begin
  _igDummy(_ImVec2(ASize));
end;

class procedure ImGui.Indent(const AIndentW: Single);
begin
  _igIndentEx(AIndentW);
end;

class procedure ImGui.Unindent(const AIndentW: Single);
begin
  _igUnindentEx(AIndentW);
end;

class procedure ImGui.BeginGroup;
begin
  _igBeginGroup();
end;

class procedure ImGui.EndGroup;
begin
  _igEndGroup();
end;

class procedure ImGui.AlignTextToFramePadding;
begin
  _igAlignTextToFramePadding();
end;

class function ImGui.GetTextLineHeight: Single;
begin
  Result := _igGetTextLineHeight();
end;

class function ImGui.GetTextLineHeightWithSpacing: Single;
begin
  Result := _igGetTextLineHeightWithSpacing();
end;

class function ImGui.GetFrameHeight: Single;
begin
  Result := _igGetFrameHeight();
end;

class function ImGui.GetFrameHeightWithSpacing: Single;
begin
  Result := _igGetFrameHeightWithSpacing();
end;

class procedure ImGui.PushID(const AStrId: PUTF8Char);
begin
  _igPushID(AStrId);
end;

class procedure ImGui.PushID(const AStrIdBegin, AStrIdEnd: PUTF8Char);
begin
  _igPushIDStr(AStrIdBegin, AStrIdEnd);
end;

class procedure ImGui.PushID(const APtrId: Pointer);
begin
  _igPushIDPtr(APtrId);
end;

class procedure ImGui.PushID(const AIntId: Int32);
begin
  _igPushIDInt(AIntId);
end;

class procedure ImGui.PopID;
begin
  _igPopID();
end;

class function ImGui.GetID(const AStrId: PUTF8Char): TImGuiID;
begin
  Result := TImGuiID(_igGetID(AStrId));
end;

class function ImGui.GetID(const AStrIdBegin, AStrIdEnd: PUTF8Char): TImGuiID;
begin
  Result := TImGuiID(_igGetIDStr(AStrIdBegin, AStrIdEnd));
end;

class function ImGui.GetID(const APtrId: Pointer): TImGuiID;
begin
  Result := TImGuiID(_igGetIDPtr(APtrId));
end;

class function ImGui.GetID(const AIntId: Int32): TImGuiID;
begin
  Result := TImGuiID(_igGetIDInt(AIntId));
end;

class procedure ImGui.TextUnformatted(const AText: PUTF8Char; const ATextEnd: PUTF8Char);
begin
  _igTextUnformattedEx(AText, ATextEnd);
end;

class procedure ImGui.Text(const AFmt: PUTF8Char);
begin
  _igText(AFmt);
end;

class procedure ImGui.TextColored(const ACol: TVector4; const AFmt: PUTF8Char);
begin
  _igTextColored(_ImVec4(ACol), AFmt);
end;

class procedure ImGui.TextDisabled(const AFmt: PUTF8Char);
begin
  _igTextDisabled(AFmt);
end;

class procedure ImGui.TextWrapped(const AFmt: PUTF8Char);
begin
  _igTextWrapped(AFmt);
end;

class procedure ImGui.LabelText(const ALabel, AFmt: PUTF8Char);
begin
  _igLabelText(ALabel, AFmt);
end;

class procedure ImGui.BulletText(const AFmt: PUTF8Char);
begin
  _igBulletText(AFmt);
end;

class procedure ImGui.SeparatorText(const ALabel: PUTF8Char);
begin
  _igSeparatorText(ALabel);
end;

class function ImGui.Button(const ALabel: PUTF8Char): Boolean;
begin
  Result := _igButton(ALabel);
end;

class function ImGui.Button(const ALabel: PUTF8Char; const ASize: TVector2): Boolean;
begin
  Result := _igButtonEx(ALabel, _ImVec2(ASize));
end;

class function ImGui.SmallButton(const ALabel: PUTF8Char): Boolean;
begin
  Result := _igSmallButton(ALabel);
end;

class function ImGui.InvisibleButton(const AStrId: PUTF8Char; const ASize: TVector2; 
  const AFlags: TImGuiButtonFlags): Boolean;
begin
  Result := _igInvisibleButton(AStrId, _ImVec2(ASize), Cardinal(AFlags));
end;

class function ImGui.ArrowButton(const AStrId: PUTF8Char; const ADir: TImGuiDir): Boolean;
begin
  Result := _igArrowButton(AStrId, _ImGuiDir(ADir));
end;

class function ImGui.Checkbox(const ALabel: PUTF8Char; const AV: PBoolean): Boolean;
begin
  Result := _igCheckbox(ALabel, AV);
end;

class function ImGui.CheckboxFlags(const ALabel: PUTF8Char; const AFlags: PInt32; 
  const AFlagsValue: Int32): Boolean;
begin
  Result := _igCheckboxFlagsIntPtr(ALabel, AFlags, AFlagsValue);
end;

class function ImGui.CheckboxFlags(const ALabel: PUTF8Char; const AFlags: PUInt32; 
  const AFlagsValue: UInt32): Boolean;
begin
  Result := _igCheckboxFlagsUintPtr(ALabel, AFlags, AFlagsValue);
end;

class function ImGui.RadioButton(const ALabel: PUTF8Char; const AActive: Boolean): Boolean;
begin
  Result := _igRadioButton(ALabel, AActive);
end;

class function ImGui.RadioButton(const ALabel: PUTF8Char; const AV: PInt32; const AVButton: Int32): Boolean;
begin
  Result := _igRadioButtonIntPtr(ALabel, AV, AVButton);
end;

class procedure ImGui.ProgressBar(const AFraction: Single; const ASizeArg: TVector2; 
  const AOverlay: PUTF8Char);
begin
  _igProgressBar(AFraction, _ImVec2(ASizeArg), AOverlay);
end;

class procedure ImGui.ProgressBar(const AFraction: Single; const AOverlay: PUTF8Char = nil);
begin
  _igProgressBar(AFraction, _ImVec2(Vector2(Single.MinValue, 0)), AOverlay);
end;

class procedure ImGui.Bullet;
begin
  _igBullet();
end;

class function ImGui.TextLink(const ALabel: PUTF8Char): Boolean;
begin
  Result := _igTextLink(ALabel);
end;

class function ImGui.TextLinkOpenURL(const ALabel: PUTF8Char; const AUrl: PUTF8Char): Boolean;
begin
  Result := _igTextLinkOpenURLEx(ALabel, AUrl);
end;

class procedure ImGui.Image(const ATexRef: TImTextureRef; const AImageSize: TVector2);
begin
  _igImage(_ImTextureRef(ATexRef), _ImVec2(AImageSize));
end;

class procedure ImGui.Image(const ATexRef: TImTextureRef; const AImageSize, AUv0, 
  AUv1: TVector2);
begin
  _igImageEx(_ImTextureRef(ATexRef), _ImVec2(AImageSize), _ImVec2(AUv0), _ImVec2(AUv1));
end;

class procedure ImGui.Image(const ATexRef: TImTextureRef; const AImageSize, AUv0: TVector2);
begin
  _igImageEx(_ImTextureRef(ATexRef), _ImVec2(AImageSize), _ImVec2(AUv0), _ImVec2(TVector2.One));
end;

class procedure ImGui.ImageWithBg(const ATexRef: TImTextureRef; const AImageSize: TVector2);
begin
  _igImageWithBg(_ImTextureRef(ATexRef), _ImVec2(AImageSize));
end;

class procedure ImGui.ImageWithBg(const ATexRef: TImTextureRef; const AImageSize, 
  AUv0, AUv1: TVector2; const ABgCol, ATintCol: TVector4);
begin
  _igImageWithBgEx(_ImTextureRef(ATexRef), _ImVec2(AImageSize), _ImVec2(AUv0), _ImVec2(AUv1), _ImVec4(ABgCol), _ImVec4(ATintCol));
end;

class procedure ImGui.ImageWithBg(const ATexRef: TImTextureRef; const AImageSize, AUv0, AUv1: TVector2; const ABgCol: TVector4);
begin
  _igImageWithBgEx(_ImTextureRef(ATexRef), _ImVec2(AImageSize), _ImVec2(AUv0), _ImVec2(AUv1), _ImVec4(ABgCol), _ImVec4(TVector4.One));
end;

class procedure ImGui.ImageWithBg(const ATexRef: TImTextureRef; const AImageSize, AUv0, AUv1: TVector2);
begin
  _igImageWithBgEx(_ImTextureRef(ATexRef), _ImVec2(AImageSize), _ImVec2(AUv0), _ImVec2(AUv1), _ImVec4(TVector4.Zero), _ImVec4(TVector4.One));
end;

class procedure ImGui.ImageWithBg(const ATexRef: TImTextureRef; const AImageSize, AUv0: TVector2);
begin
  _igImageWithBgEx(_ImTextureRef(ATexRef), _ImVec2(AImageSize), _ImVec2(AUv0), _ImVec2(TVector2.One), _ImVec4(TVector4.Zero), _ImVec4(TVector4.One));
end;

class function ImGui.ImageButton(const AStrId: PUTF8Char; const ATexRef: TImTextureRef; 
  const AImageSize: TVector2): Boolean;
begin
  Result := _igImageButton(AStrId, _ImTextureRef(ATexRef), _ImVec2(AImageSize));
end;

class function ImGui.ImageButton(const AStrId: PUTF8Char; const ATexRef: TImTextureRef; 
  const AImageSize, AUv0, AUv1: TVector2; const ABgCol, ATintCol: TVector4): Boolean;
begin
  Result := _igImageButtonEx(AStrId, _ImTextureRef(ATexRef), _ImVec2(AImageSize), _ImVec2(AUv0), _ImVec2(AUv1), _ImVec4(ABgCol), _ImVec4(ATintCol));
end;

class function ImGui.ImageButton(const AStrId: PUTF8Char; const ATexRef: TImTextureRef; const AImageSize, AUv0, AUv1: TVector2; const ABgCol: TVector4): Boolean;
begin
  Result := _igImageButtonEx(AStrId, _ImTextureRef(ATexRef), _ImVec2(AImageSize), _ImVec2(AUv0), _ImVec2(AUv1), _ImVec4(ABgCol), _ImVec4(TVector4.One));
end;

class function ImGui.ImageButton(const AStrId: PUTF8Char; const ATexRef: TImTextureRef; const AImageSize, AUv0, AUv1: TVector2): Boolean;
begin
  Result := _igImageButtonEx(AStrId, _ImTextureRef(ATexRef), _ImVec2(AImageSize), _ImVec2(AUv0), _ImVec2(AUv1), _ImVec4(TVector4.Zero), _ImVec4(TVector4.One));
end;

class function ImGui.ImageButton(const AStrId: PUTF8Char; const ATexRef: TImTextureRef; const AImageSize, AUv0: TVector2): Boolean;
begin
  Result := _igImageButtonEx(AStrId, _ImTextureRef(ATexRef), _ImVec2(AImageSize), _ImVec2(AUv0), _ImVec2(TVector2.One), _ImVec4(TVector4.Zero), _ImVec4(TVector4.One));
end;

class function ImGui.BeginCombo(const ALabel, APreviewValue: PUTF8Char; const AFlags: TImGuiComboFlags): Boolean;
begin
  Result := _igBeginCombo(ALabel, APreviewValue, Cardinal(AFlags));
end;

class procedure ImGui.EndCombo;
begin
  _igEndCombo();
end;

class function ImGui.Combo(const ALabel: PUTF8Char; const ACurrentItem: PInt32; 
  const AItems: PPUTF8Char; const AItemsCount: Int32): Boolean;
begin
  Result := _igComboChar(ALabel, ACurrentItem, AItems, AItemsCount);
end;

class function ImGui.Combo(const ALabel: PUTF8Char; const ACurrentItem: PInt32; 
  const AItems: PPUTF8Char; const AItemsCount: Int32; const APopupMaxHeightInItems: Int32): Boolean;
begin
  Result := _igComboCharEx(ALabel, ACurrentItem, AItems, AItemsCount, APopupMaxHeightInItems);
end;

class function ImGui.Combo(const ALabel: PUTF8Char; const ACurrentItem: PInt32; 
  const AItemsSeparatedByZeros: PUTF8Char; const APopupMaxHeightInItems: Int32): Boolean;
begin
  Result := _igComboEx(ALabel, ACurrentItem, AItemsSeparatedByZeros, APopupMaxHeightInItems);
end;

class function ImGui.Combo(const ALabel: PUTF8Char; const ACurrentItem: PInt32; 
  const AGetter: TImGuiStringGetter; const AUserData: Pointer; const AItemsCount: Int32): Boolean;
begin
  Result := _igComboCallback(ALabel, ACurrentItem, @AGetter, AUserData, AItemsCount);
end;

class function ImGui.Combo(const ALabel: PUTF8Char; const ACurrentItem: PInt32; 
  const AGetter: TImGuiStringGetter; const AUserData: Pointer; const AItemsCount: Int32; 
  const APopupMaxHeightInItems: Int32): Boolean;
begin
  Result := _igComboCallbackEx(ALabel, ACurrentItem, @AGetter, AUserData, AItemsCount, APopupMaxHeightInItems);
end;

class function ImGui.DragFloat(const ALabel: PUTF8Char; const AV: PSingle): Boolean;
begin
  Result := _igDragFloat(ALabel, AV);
end;

class function ImGui.DragFloat(const ALabel: PUTF8Char; const AV: PSingle; const AVSpeed: Single; 
  const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragFloatEx(ALabel, AV, AVSpeed, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.DragFloat(const ALabel: PUTF8Char; const AV: PSingle; const AVSpeed: Single = 1.0; const AVMin: Single = 0.0; const AVMax: Single = 0.0): Boolean;
begin
  Result := _igDragFloatEx(ALabel, AV, AVSpeed, AVMin, AVMax, PUTF8Char('%.3f'), 0);
end;

class function ImGui.DragFloat2(const ALabel: PUTF8Char; const AV: PSingle): Boolean;
begin
  Result := _igDragFloat2(ALabel, AV);
end;

class function ImGui.DragFloat2(const ALabel: PUTF8Char; const AV: PSingle; const AVSpeed: Single; 
  const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragFloat2Ex(ALabel, AV, AVSpeed, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.DragFloat2(const ALabel: PUTF8Char; const AV: PSingle; const AVSpeed: Single = 1.0; const AVMin: Single = 0.0; const AVMax: Single = 0.0): Boolean;
begin
  Result := _igDragFloat2Ex(ALabel, AV, AVSpeed, AVMin, AVMax, PUTF8Char('%.3f'), 0);
end;

class function ImGui.DragFloat3(const ALabel: PUTF8Char; const AV: PSingle): Boolean;
begin
  Result := _igDragFloat3(ALabel, AV);
end;

class function ImGui.DragFloat3(const ALabel: PUTF8Char; const AV: PSingle; const AVSpeed: Single; 
  const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragFloat3Ex(ALabel, AV, AVSpeed, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.DragFloat3(const ALabel: PUTF8Char; const AV: PSingle; const AVSpeed: Single = 1.0; const AVMin: Single = 0.0; const AVMax: Single = 0.0): Boolean;
begin
  Result := _igDragFloat3Ex(ALabel, AV, AVSpeed, AVMin, AVMax, PUTF8Char('%.3f'), 0);
end;

class function ImGui.DragFloat4(const ALabel: PUTF8Char; const AV: PSingle): Boolean;
begin
  Result := _igDragFloat4(ALabel, AV);
end;

class function ImGui.DragFloat4(const ALabel: PUTF8Char; const AV: PSingle; const AVSpeed: Single; 
  const AVMin: Single; const AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragFloat4Ex(ALabel, AV, AVSpeed, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.DragFloat4(const ALabel: PUTF8Char; const AV: PSingle; const AVSpeed: Single = 1.0; const AVMin: Single = 0.0; const AVMax: Single = 0.0): Boolean;
begin
  Result := _igDragFloat4Ex(ALabel, AV, AVSpeed, AVMin, AVMax, PUTF8Char('%.3f'), 0);
end;

class function ImGui.DragFloatRange2(const ALabel: PUTF8Char; const AVCurrentMin, 
  AVCurrentMax: PSingle): Boolean;
begin
  Result := _igDragFloatRange2(ALabel, AVCurrentMin, AVCurrentMax);
end;

class function ImGui.DragFloatRange2(const ALabel: PUTF8Char; const AVCurrentMin, 
  AVCurrentMax: PSingle; const AVSpeed: Single; const AVMin: Single; const AVMax: Single; 
  const AFormat: PUTF8Char; const AFormatMax: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragFloatRange2Ex(ALabel, AVCurrentMin, AVCurrentMax, AVSpeed, AVMin, AVMax, AFormat, AFormatMax, Cardinal(AFlags));
end;

class function ImGui.DragFloatRange2(const ALabel: PUTF8Char; const AVCurrentMin, AVCurrentMax: PSingle; const AVSpeed: Single = 1.0; const AVMin: Single = 0.0; const AVMax: Single = 0.0): Boolean;
begin
  Result := _igDragFloatRange2Ex(ALabel, AVCurrentMin, AVCurrentMax, AVSpeed, AVMin, AVMax, PUTF8Char('%.3f'), nil, 0);
end;

class function ImGui.DragInt(const ALabel: PUTF8Char; const AV: PInt32): Boolean;
begin
  Result := _igDragInt(ALabel, AV);
end;

class function ImGui.DragInt(const ALabel: PUTF8Char; const AV: PInt32; const AVSpeed: Single; 
  const AVMin: Int32; const AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragIntEx(ALabel, AV, AVSpeed, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.DragInt(const ALabel: PUTF8Char; const AV: PInt32; const AVSpeed: Single = 1.0; const AVMin: Int32 = 0; const AVMax: Int32 = 0): Boolean;
begin
  Result := _igDragIntEx(ALabel, AV, AVSpeed, AVMin, AVMax, PUTF8Char('%.3f'), 0);
end;

class function ImGui.DragInt2(const ALabel: PUTF8Char; const AV: PInt32): Boolean;
begin
  Result := _igDragInt2(ALabel, AV);
end;

class function ImGui.DragInt2(const ALabel: PUTF8Char; const AV: PInt32; const AVSpeed: Single; 
  const AVMin: Int32; const AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragInt2Ex(ALabel, AV, AVSpeed, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.DragInt2(const ALabel: PUTF8Char; const AV: PInt32; const AVSpeed: Single = 1.0; const AVMin: Int32 = 0; const AVMax: Int32 = 0): Boolean;
begin
  Result := _igDragInt2Ex(ALabel, AV, AVSpeed, AVMin, AVMax, PUTF8Char('%.3f'), 0);
end;

class function ImGui.DragInt3(const ALabel: PUTF8Char; const AV: PInt32): Boolean;
begin
  Result := _igDragInt3(ALabel, AV);
end;

class function ImGui.DragInt3(const ALabel: PUTF8Char; const AV: PInt32; const AVSpeed: Single; 
  const AVMin: Int32; const AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragInt3Ex(ALabel, AV, AVSpeed, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.DragInt3(const ALabel: PUTF8Char; const AV: PInt32; const AVSpeed: Single = 1.0; const AVMin: Int32 = 0; const AVMax: Int32 = 0): Boolean;
begin
  Result := _igDragInt3Ex(ALabel, AV, AVSpeed, AVMin, AVMax, PUTF8Char('%.3f'), 0);
end;

class function ImGui.DragInt4(const ALabel: PUTF8Char; const AV: PInt32): Boolean;
begin
  Result := _igDragInt4(ALabel, AV);
end;

class function ImGui.DragInt4(const ALabel: PUTF8Char; const AV: PInt32; const AVSpeed: Single; 
  const AVMin: Int32; const AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragInt4Ex(ALabel, AV, AVSpeed, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.DragInt4(const ALabel: PUTF8Char; const AV: PInt32; const AVSpeed: Single = 1.0; const AVMin: Int32 = 0; const AVMax: Int32 = 0): Boolean;
begin
  Result := _igDragInt4Ex(ALabel, AV, AVSpeed, AVMin, AVMax, PUTF8Char('%.3f'), 0);
end;

class function ImGui.DragIntRange2(const ALabel: PUTF8Char; const AVCurrentMin, 
  AVCurrentMax: PInt32): Boolean;
begin
  Result := _igDragIntRange2(ALabel, AVCurrentMin, AVCurrentMax);
end;

class function ImGui.DragIntRange2(const ALabel: PUTF8Char; const AVCurrentMin, 
  AVCurrentMax: PInt32; const AVSpeed: Single; const AVMin: Int32; const AVMax: Int32; 
  const AFormat: PUTF8Char; const AFormatMax: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragIntRange2Ex(ALabel, AVCurrentMin, AVCurrentMax, AVSpeed, AVMin, AVMax, AFormat, AFormatMax, Cardinal(AFlags));
end;

class function ImGui.DragIntRange2(const ALabel: PUTF8Char; const AVCurrentMin, AVCurrentMax: PInt32; const AVSpeed: Single = 1.0; const AVMin: Int32 = 0; const AVMax: Int32 = 0): Boolean;
begin
  Result := _igDragIntRange2Ex(ALabel, AVCurrentMin, AVCurrentMax, AVSpeed, AVMin, AVMax, PUTF8Char('%.3f'), nil, 0);
end;

class function ImGui.DragScalar(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; 
  const APData: Pointer; const AVSpeed: Single; const APMin: Pointer; const APMax: Pointer; 
  const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragScalarEx(ALabel, _ImGuiDataType(ADataType), APData, AVSpeed, APMin, APMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.DragScalarN(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; 
  const APData: Pointer; const AComponents: Int32; const AVSpeed: Single; const APMin: Pointer; 
  const APMax: Pointer; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igDragScalarNEx(ALabel, _ImGuiDataType(ADataType), APData, AComponents, AVSpeed, APMin, APMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.SliderFloat(const ALabel: PUTF8Char; const AV: PSingle; const AVMin, 
  AVMax: Single): Boolean;
begin
  Result := _igSliderFloat(ALabel, AV, AVMin, AVMax);
end;

class function ImGui.SliderFloat(const ALabel: PUTF8Char; const AV: PSingle; const AVMin, 
  AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderFloatEx(ALabel, AV, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.SliderFloat(const ALabel: PUTF8Char; const AV: PSingle; const AVMin: Single = 0.0): Boolean;
begin
  Result := _igSliderFloatEx(ALabel, AV, AVMin, 0, PUTF8Char('%.3f'), 0);
end;

class function ImGui.SliderFloat2(const ALabel: PUTF8Char; const AV: PSingle; const AVMin, 
  AVMax: Single): Boolean;
begin
  Result := _igSliderFloat2(ALabel, AV, AVMin, AVMax);
end;

class function ImGui.SliderFloat2(const ALabel: PUTF8Char; const AV: PSingle; const AVMin, 
  AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderFloat2Ex(ALabel, AV, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.SliderFloat2(const ALabel: PUTF8Char; const AV: PSingle; const AVMin: Single = 0.0): Boolean;
begin
  Result := _igSliderFloat2Ex(ALabel, AV, AVMin, 0, PUTF8Char('%.3f'), 0);
end;

class function ImGui.SliderFloat3(const ALabel: PUTF8Char; const AV: PSingle; const AVMin, 
  AVMax: Single): Boolean;
begin
  Result := _igSliderFloat3(ALabel, AV, AVMin, AVMax);
end;

class function ImGui.SliderFloat3(const ALabel: PUTF8Char; const AV: PSingle; const AVMin, 
  AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderFloat3Ex(ALabel, AV, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.SliderFloat3(const ALabel: PUTF8Char; const AV: PSingle; const AVMin: Single = 0.0): Boolean;
begin
  Result := _igSliderFloat3Ex(ALabel, AV, AVMin, 0, PUTF8Char('%.3f'), 0);
end;

class function ImGui.SliderFloat4(const ALabel: PUTF8Char; const AV: PSingle; const AVMin, 
  AVMax: Single): Boolean;
begin
  Result := _igSliderFloat4(ALabel, AV, AVMin, AVMax);
end;

class function ImGui.SliderFloat4(const ALabel: PUTF8Char; const AV: PSingle; const AVMin, 
  AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderFloat4Ex(ALabel, AV, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.SliderFloat4(const ALabel: PUTF8Char; const AV: PSingle; const AVMin: Single = 0.0): Boolean;
begin
  Result := _igSliderFloat4Ex(ALabel, AV, AVMin, 0, PUTF8Char('%.3f'), 0);
end;

class function ImGui.SliderAngle(const ALabel: PUTF8Char; const AVRad: PSingle): Boolean;
begin
  Result := _igSliderAngle(ALabel, AVRad);
end;

class function ImGui.SliderAngle(const ALabel: PUTF8Char; const AVRad: PSingle; 
  const AVDegreesMin: Single; const AVDegreesMax: Single; const AFormat: PUTF8Char; 
  const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderAngleEx(ALabel, AVRad, AVDegreesMin, AVDegreesMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.SliderAngle(const ALabel: PUTF8Char; const AVRad: PSingle; const AVDegreesMin: Single = -360.0; const AVDegreesMax: Single = 360.0): Boolean;
begin
  Result := _igSliderAngleEx(ALabel, AVRad, AVDegreesMin, AVDegreesMax, PUTF8Char('%.3f'), 0);
end;

class function ImGui.SliderInt(const ALabel: PUTF8Char; const AV: PInt32; const AVMin, 
  AVMax: Int32): Boolean;
begin
  Result := _igSliderInt(ALabel, AV, AVMin, AVMax);
end;

class function ImGui.SliderInt(const ALabel: PUTF8Char; const AV: PInt32; const AVMin, 
  AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderIntEx(ALabel, AV, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.SliderInt(const ALabel: PUTF8Char; const AV: PInt32; const AVMin: Int32 = 0): Boolean;
begin
  Result := _igSliderIntEx(ALabel, AV, AVMin, 0, PUTF8Char('%.3f'), 0);
end;

class function ImGui.SliderInt2(const ALabel: PUTF8Char; const AV: PInt32; const AVMin, 
  AVMax: Int32): Boolean;
begin
  Result := _igSliderInt2(ALabel, AV, AVMin, AVMax);
end;

class function ImGui.SliderInt2(const ALabel: PUTF8Char; const AV: PInt32; const AVMin, 
  AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderInt2Ex(ALabel, AV, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.SliderInt2(const ALabel: PUTF8Char; const AV: PInt32; const AVMin: Int32 = 0): Boolean;
begin
  Result := _igSliderInt2Ex(ALabel, AV, AVMin, 0, PUTF8Char('%.3f'), 0);
end;

class function ImGui.SliderInt3(const ALabel: PUTF8Char; const AV: PInt32; const AVMin, 
  AVMax: Int32): Boolean;
begin
  Result := _igSliderInt3(ALabel, AV, AVMin, AVMax);
end;

class function ImGui.SliderInt3(const ALabel: PUTF8Char; const AV: PInt32; const AVMin, 
  AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderInt3Ex(ALabel, AV, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.SliderInt3(const ALabel: PUTF8Char; const AV: PInt32; const AVMin: Int32 = 0): Boolean;
begin
  Result := _igSliderInt3Ex(ALabel, AV, AVMin, 0, PUTF8Char('%.3f'), 0);
end;

class function ImGui.SliderInt4(const ALabel: PUTF8Char; const AV: PInt32; const AVMin, 
  AVMax: Int32): Boolean;
begin
  Result := _igSliderInt4(ALabel, AV, AVMin, AVMax);
end;

class function ImGui.SliderInt4(const ALabel: PUTF8Char; const AV: PInt32; const AVMin, 
  AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderInt4Ex(ALabel, AV, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.SliderInt4(const ALabel: PUTF8Char; const AV: PInt32; const AVMin: Int32 = 0): Boolean;
begin
  Result := _igSliderInt4Ex(ALabel, AV, AVMin, 0, PUTF8Char('%.3f'), 0);
end;

class function ImGui.SliderScalar(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; 
  const APData: Pointer; const APMin, APMax: Pointer; const AFormat: PUTF8Char; 
  const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderScalarEx(ALabel, _ImGuiDataType(ADataType), APData, APMin, APMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.SliderScalarN(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; 
  const APData: Pointer; const AComponents: Int32; const APMin, APMax: Pointer; 
  const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igSliderScalarNEx(ALabel, _ImGuiDataType(ADataType), APData, AComponents, APMin, APMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.VSliderFloat(const ALabel: PUTF8Char; const ASize: TVector2; 
  const AV: PSingle; const AVMin, AVMax: Single): Boolean;
begin
  Result := _igVSliderFloat(ALabel, _ImVec2(ASize), AV, AVMin, AVMax);
end;

class function ImGui.VSliderFloat(const ALabel: PUTF8Char; const ASize: TVector2; 
  const AV: PSingle; const AVMin, AVMax: Single; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igVSliderFloatEx(ALabel, _ImVec2(ASize), AV, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.VSliderFloat(const ALabel: PUTF8Char; const ASize: TVector2; const AV: PSingle; const AVMin: Single = 0.0): Boolean;
begin
  Result := _igVSliderFloatEx(ALabel, _ImVec2(ASize), AV, AVMin, 0, PUTF8Char('%.3f'), 0);
end;

class function ImGui.VSliderInt(const ALabel: PUTF8Char; const ASize: TVector2; 
  const AV: PInt32; const AVMin, AVMax: Int32): Boolean;
begin
  Result := _igVSliderInt(ALabel, _ImVec2(ASize), AV, AVMin, AVMax);
end;

class function ImGui.VSliderInt(const ALabel: PUTF8Char; const ASize: TVector2; 
  const AV: PInt32; const AVMin, AVMax: Int32; const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igVSliderIntEx(ALabel, _ImVec2(ASize), AV, AVMin, AVMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.VSliderInt(const ALabel: PUTF8Char; const ASize: TVector2; const AV: PInt32; const AVMin: Int32 = 0): Boolean;
begin
  Result := _igVSliderIntEx(ALabel, _ImVec2(ASize), AV, AVMin, 0, PUTF8Char('%.3f'), 0);
end;

class function ImGui.VSliderScalar(const ALabel: PUTF8Char; const ASize: TVector2; 
  const ADataType: TImGuiDataType; const APData: Pointer; const APMin, APMax: Pointer; 
  const AFormat: PUTF8Char; const AFlags: TImGuiSliderFlags): Boolean;
begin
  Result := _igVSliderScalarEx(ALabel, _ImVec2(ASize), _ImGuiDataType(ADataType), APData, APMin, APMax, AFormat, Cardinal(AFlags));
end;

class function ImGui.InputText(const ALabel: PUTF8Char; const ABuf: PUTF8Char; const ABufSize: NativeUInt; 
  const AFlags: TImGuiInputTextFlags; const ACallback: TImGuiInputTextCallback; 
  const AUserData: Pointer): Boolean;
begin
  Result := _igInputTextEx(ALabel, ABuf, ABufSize, Cardinal(AFlags), _ImGuiInputTextCallback(ACallback), AUserData);
end;

class function ImGui.InputText(const ALabel: PUTF8Char; const AText: TImGUiText; const AFlags: TImGuiInputTextFlags = []): Boolean;
begin
  var Flags := AFlags + [TImGuiInputTextFlag.CallbackResize];
  AText.Validate;
  Result := _igInputTextEx(ALabel, Pointer(AText.FBuffer), Length(AText.FBuffer), Cardinal(Flags), @__ImGuiInputTextCallback, @AText);
end;

class function ImGui.InputTextMultiline(const ALabel: PUTF8Char; const ABuf: PUTF8Char; 
  const ABufSize: NativeUInt): Boolean;
begin
  Result := _igInputTextMultiline(ALabel, ABuf, ABufSize);
end;

class function ImGui.InputTextMultiline(const ALabel: PUTF8Char; const AText: TImGuiText): Boolean;
begin
  Result := InputTextMultiline(ALabel, AText, TVector2.Zero);
end;

class function ImGui.InputTextMultiline(const ALabel: PUTF8Char; const AText: TImGuiText; const ASize: TVector2; const AFlags: TImGuiInputTextFlags = []): Boolean;
begin
  var Flags := AFlags + [TImGuiInputTextFlag.CallbackResize];
  AText.Validate;
  Result := _igInputTextMultilineEx(ALabel, Pointer(AText.FBuffer), Length(AText.FBuffer), _ImVec2(ASize), Cardinal(Flags), @__ImGuiInputTextCallback, @AText);
end;

class function ImGui.InputTextMultiline(const ALabel: PUTF8Char; const ABuf: PUTF8Char; 
  const ABufSize: NativeUInt; const ASize: TVector2; const AFlags: TImGuiInputTextFlags; 
  const ACallback: TImGuiInputTextCallback; const AUserData: Pointer): Boolean;
begin
  Result := _igInputTextMultilineEx(ALabel, ABuf, ABufSize, _ImVec2(ASize), Cardinal(AFlags), _ImGuiInputTextCallback(ACallback), AUserData);
end;

class function ImGui.InputTextWithHint(const ALabel, AHint: PUTF8Char; const ABuf: PUTF8Char; 
  const ABufSize: NativeUInt; const AFlags: TImGuiInputTextFlags; const ACallback: TImGuiInputTextCallback; 
  const AUserData: Pointer): Boolean;
begin
  Result := _igInputTextWithHintEx(ALabel, AHint, ABuf, ABufSize, Cardinal(AFlags), _ImGuiInputTextCallback(ACallback), AUserData);
end;

class function ImGui.InputTextWithHint(const ALabel, AHint: PUTF8Char; const AText: TImGUiText; const AFlags: TImGuiInputTextFlags = []): Boolean;
begin
  var Flags := AFlags + [TImGuiInputTextFlag.CallbackResize];
  AText.Validate;
  Result := _igInputTextWithHintEx(ALabel, AHint, Pointer(AText.FBuffer), Length(AText.FBuffer), Cardinal(Flags), @__ImGuiInputTextCallback, @AText);
end;

class function ImGui.InputFloat(const ALabel: PUTF8Char; const AV: PSingle): Boolean;
begin
  Result := _igInputFloat(ALabel, AV);
end;

class function ImGui.InputFloat(const ALabel: PUTF8Char; const AV: PSingle; const AStep: Single; 
  const AStepFast: Single; const AFormat: PUTF8Char; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputFloatEx(ALabel, AV, AStep, AStepFast, AFormat, Cardinal(AFlags));
end;

class function ImGui.InputFloat(const ALabel: PUTF8Char; const AV: PSingle; const AStep: Single; const AStepFast: Single = 0.0): Boolean;
begin
  Result := _igInputFloatEx(ALabel, AV, AStep, AStepFast, PUTF8Char('%.3f'), 0);
end;

class function ImGui.InputFloat2(const ALabel: PUTF8Char; const AV: PSingle): Boolean;
begin
  Result := _igInputFloat2(ALabel, AV);
end;

class function ImGui.InputFloat2(const ALabel: PUTF8Char; const AV: PSingle; const AFormat: PUTF8Char; 
  const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputFloat2Ex(ALabel, AV, AFormat, Cardinal(AFlags));
end;

class function ImGui.InputFloat3(const ALabel: PUTF8Char; const AV: PSingle): Boolean;
begin
  Result := _igInputFloat3(ALabel, AV);
end;

class function ImGui.InputFloat3(const ALabel: PUTF8Char; const AV: PSingle; const AFormat: PUTF8Char; 
  const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputFloat3Ex(ALabel, AV, AFormat, Cardinal(AFlags));
end;

class function ImGui.InputFloat4(const ALabel: PUTF8Char; const AV: PSingle): Boolean;
begin
  Result := _igInputFloat4(ALabel, AV);
end;

class function ImGui.InputFloat4(const ALabel: PUTF8Char; const AV: PSingle; const AFormat: PUTF8Char; 
  const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputFloat4Ex(ALabel, AV, AFormat, Cardinal(AFlags));
end;

class function ImGui.InputInt(const ALabel: PUTF8Char; const AV: PInt32; const AStep: Int32; 
  const AStepFast: Int32; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputIntEx(ALabel, AV, AStep, AStepFast, Cardinal(AFlags));
end;

class function ImGui.InputInt2(const ALabel: PUTF8Char; const AV: PInt32; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputInt2(ALabel, AV, Cardinal(AFlags));
end;

class function ImGui.InputInt3(const ALabel: PUTF8Char; const AV: PInt32; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputInt3(ALabel, AV, Cardinal(AFlags));
end;

class function ImGui.InputInt4(const ALabel: PUTF8Char; const AV: PInt32; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputInt4(ALabel, AV, Cardinal(AFlags));
end;

class function ImGui.InputDouble(const ALabel: PUTF8Char; const AV: PDouble): Boolean;
begin
  Result := _igInputDouble(ALabel, AV);
end;

class function ImGui.InputDouble(const ALabel: PUTF8Char; const AV: PDouble; const AStep: Double; 
  const AStepFast: Double; const AFormat: PUTF8Char; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputDoubleEx(ALabel, AV, AStep, AStepFast, AFormat, Cardinal(AFlags));
end;

class function ImGui.InputDouble(const ALabel: PUTF8Char; const AV: PDouble; const AStep: Double; const AStepFast: Double = 0.0): Boolean;
begin
  Result := _igInputDoubleEx(ALabel, AV, AStep, AStepFast, PUTF8Char('%.3f'), 0);
end;

class function ImGui.InputScalar(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; 
  const APData: Pointer; const APStep: Pointer; const APStepFast: Pointer; const AFormat: PUTF8Char; 
  const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputScalarEx(ALabel, _ImGuiDataType(ADataType), APData, APStep, APStepFast, AFormat, Cardinal(AFlags));
end;

class function ImGui.InputScalarN(const ALabel: PUTF8Char; const ADataType: TImGuiDataType; 
  const APData: Pointer; const AComponents: Int32; const APStep: Pointer; const APStepFast: Pointer; 
  const AFormat: PUTF8Char; const AFlags: TImGuiInputTextFlags): Boolean;
begin
  Result := _igInputScalarNEx(ALabel, _ImGuiDataType(ADataType), APData, AComponents, APStep, APStepFast, AFormat, Cardinal(AFlags));
end;

class function ImGui.ColorEdit3(const ALabel: PUTF8Char; const ACol: PSingle; const AFlags: TImGuiColorEditFlags): Boolean;
begin
  Result := _igColorEdit3(ALabel, ACol, Cardinal(AFlags));
end;

class function ImGui.ColorEdit4(const ALabel: PUTF8Char; const ACol: PSingle; const AFlags: TImGuiColorEditFlags): Boolean;
begin
  Result := _igColorEdit4(ALabel, ACol, Cardinal(AFlags));
end;

class function ImGui.ColorPicker3(const ALabel: PUTF8Char; const ACol: PSingle; 
  const AFlags: TImGuiColorEditFlags): Boolean;
begin
  Result := _igColorPicker3(ALabel, ACol, Cardinal(AFlags));
end;

class function ImGui.ColorPicker4(const ALabel: PUTF8Char; const ACol: PSingle; 
  const AFlags: TImGuiColorEditFlags; const ARefCol: PSingle): Boolean;
begin
  Result := _igColorPicker4(ALabel, ACol, Cardinal(AFlags), ARefCol);
end;

class function ImGui.ColorButton(const ADescId: PUTF8Char; const ACol: TVector4; 
  const AFlags: TImGuiColorEditFlags): Boolean;
begin
  Result := _igColorButton(ADescId, _ImVec4(ACol), Cardinal(AFlags));
end;

class function ImGui.ColorButton(const ADescId: PUTF8Char; const ACol: TVector4; 
  const AFlags: TImGuiColorEditFlags; const ASize: TVector2): Boolean;
begin
  Result := _igColorButtonEx(ADescId, _ImVec4(ACol), Cardinal(AFlags), _ImVec2(ASize));
end;

class procedure ImGui.SetColorEditOptions(const AFlags: TImGuiColorEditFlags);
begin
  _igSetColorEditOptions(Cardinal(AFlags));
end;

class function ImGui.TreeNode(const ALabel: PUTF8Char): Boolean;
begin
  Result := _igTreeNode(ALabel);
end;

class function ImGui.TreeNode(const AStrId, AFmt: PUTF8Char): Boolean;
begin
  Result := _igTreeNodeStr(AStrId, AFmt);
end;

class function ImGui.TreeNode(const APtrId: Pointer; const AFmt: PUTF8Char): Boolean;
begin
  Result := _igTreeNodePtr(APtrId, AFmt);
end;

class function ImGui.TreeNodeEx(const ALabel: PUTF8Char; const AFlags: TImGuiTreeNodeFlags): Boolean;
begin
  Result := _igTreeNodeEx(ALabel, Cardinal(AFlags));
end;

class function ImGui.TreeNodeEx(const AStrId: PUTF8Char; const AFlags: TImGuiTreeNodeFlags; 
  const AFmt: PUTF8Char): Boolean;
begin
  Result := _igTreeNodeExStr(AStrId, Cardinal(AFlags), AFmt);
end;

class function ImGui.TreeNodeEx(const APtrId: Pointer; const AFlags: TImGuiTreeNodeFlags; 
  const AFmt: PUTF8Char): Boolean;
begin
  Result := _igTreeNodeExPtr(APtrId, Cardinal(AFlags), AFmt);
end;

class procedure ImGui.TreePush(const AStrId: PUTF8Char);
begin
  _igTreePush(AStrId);
end;

class procedure ImGui.TreePush(const APtrId: Pointer);
begin
  _igTreePushPtr(APtrId);
end;

class procedure ImGui.TreePop;
begin
  _igTreePop();
end;

class function ImGui.GetTreeNodeToLabelSpacing: Single;
begin
  Result := _igGetTreeNodeToLabelSpacing();
end;

class function ImGui.CollapsingHeader(const ALabel: PUTF8Char; const AFlags: TImGuiTreeNodeFlags): Boolean;
begin
  Result := _igCollapsingHeader(ALabel, Cardinal(AFlags));
end;

class function ImGui.CollapsingHeader(const ALabel: PUTF8Char; const APVisible: PBoolean; 
  const AFlags: TImGuiTreeNodeFlags): Boolean;
begin
  Result := _igCollapsingHeaderBoolPtr(ALabel, APVisible, Cardinal(AFlags));
end;

class procedure ImGui.SetNextItemOpen(const AIsOpen: Boolean; const ACond: TImGuiCond);
begin
  _igSetNextItemOpen(AIsOpen, _ImGuiCond(ACond));
end;

class procedure ImGui.SetNextItemStorageID(const AStorageId: TImGuiID);
begin
  _igSetNextItemStorageID(_ImGuiID(AStorageId));
end;

class function ImGui.TreeNodeGetOpen(const AStorageId: TImGuiID): Boolean;
begin
  Result := _igTreeNodeGetOpen(_ImGuiID(AStorageId));
end;

class function ImGui.Selectable(const ALabel: PUTF8Char): Boolean;
begin
  Result := _igSelectable(ALabel);
end;

class function ImGui.Selectable(const ALabel: PUTF8Char; const ASelected: Boolean; 
  const AFlags: TImGuiSelectableFlags; const ASize: TVector2): Boolean;
begin
  Result := _igSelectableEx(ALabel, ASelected, Cardinal(AFlags), _ImVec2(ASize));
end;

class function ImGui.Selectable(const ALabel: PUTF8Char; const ASelected: Boolean; const AFlags: TImGuiSelectableFlags = []): Boolean;
begin
  Result := _igSelectableEx(ALabel, ASelected, Cardinal(AFlags), _ImVec2(TVector2.Zero));
end;

class function ImGui.Selectable(const ALabel: PUTF8Char; const APSelected: PBoolean; 
  const AFlags: TImGuiSelectableFlags): Boolean;
begin
  Result := _igSelectableBoolPtr(ALabel, APSelected, Cardinal(AFlags));
end;

class function ImGui.Selectable(const ALabel: PUTF8Char; const APSelected: PBoolean; 
  const AFlags: TImGuiSelectableFlags; const ASize: TVector2): Boolean;
begin
  Result := _igSelectableBoolPtrEx(ALabel, APSelected, Cardinal(AFlags), _ImVec2(ASize));
end;

class function ImGui.BeginMultiSelect(const AFlags: TImGuiMultiSelectFlags; const ASelectionSize: Int32; 
  const AItemsCount: Int32): PImGuiMultiSelectIO;
begin
  Result := _igBeginMultiSelectEx(Cardinal(AFlags), ASelectionSize, AItemsCount);
end;

class function ImGui.EndMultiSelect: PImGuiMultiSelectIO;
begin
  Result := _igEndMultiSelect();
end;

class procedure ImGui.SetNextItemSelectionUserData(const ASelectionUserData: TImGuiSelectionUserData);
begin
  _igSetNextItemSelectionUserData(_ImGuiSelectionUserData(ASelectionUserData));
end;

class function ImGui.IsItemToggledSelection: Boolean;
begin
  Result := _igIsItemToggledSelection();
end;

class function ImGui.BeginListBox(const ALabel: PUTF8Char; const ASize: TVector2): Boolean;
begin
  Result := _igBeginListBox(ALabel, _ImVec2(ASize));
end;

class function ImGui.BeginListBox(const ALabel: PUTF8Char): Boolean;
begin
  Result := _igBeginListBox(ALabel, _ImVec2(TVector2.Zero));
end;

class procedure ImGui.EndListBox;
begin
  _igEndListBox();
end;

class function ImGui.ListBox(const ALabel: PUTF8Char; const ACurrentItem: PInt32; 
  const AItems: PPUTF8Char; const AItemsCount: Int32; const AHeightInItems: Int32): Boolean;
begin
  Result := _igListBox(ALabel, ACurrentItem, AItems, AItemsCount, AHeightInItems);
end;

class function ImGui.ListBox(const ALabel: PUTF8Char; const ACurrentItem: PInt32; 
  const AGetter: TImGuiStringGetter; const AUserData: Pointer; const AItemsCount: Int32): Boolean;
begin
  Result := _igListBoxCallback(ALabel, ACurrentItem, @AGetter, AUserData, AItemsCount);
end;

class function ImGui.ListBox(const ALabel: PUTF8Char; const ACurrentItem: PInt32; 
  const AGetter: TImGuiStringGetter; const AUserData: Pointer; const AItemsCount: Int32; 
  const AHeightInItems: Int32): Boolean;
begin
  Result := _igListBoxCallbackEx(ALabel, ACurrentItem, @AGetter, AUserData, AItemsCount, AHeightInItems);
end;

class procedure ImGui.PlotLines(const ALabel: PUTF8Char; const AValues: PSingle; 
  const AValuesCount: Int32);
begin
  _igPlotLines(ALabel, AValues, AValuesCount);
end;

class procedure ImGui.PlotLines(const ALabel: PUTF8Char; const AValues: PSingle; 
  const AValuesCount: Int32; const AValuesOffset: Int32; const AOverlayText: PUTF8Char; 
  const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2; 
  const AStride: Int32);
begin
  _igPlotLinesEx(ALabel, AValues, AValuesCount, AValuesOffset, AOverlayText, AScaleMin, AScaleMax, _ImVec2(AGraphSize), AStride);
end;

class procedure ImGui.PlotLines(const ALabel: PUTF8Char; const AValues: PSingle; const AValuesCount: Int32; const AValuesOffset: Int32 = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle);
begin
  _igPlotLinesEx(ALabel, AValues, AValuesCount, AValuesOffset, AOverlayText, AScaleMin, AScaleMax, _ImVec2(TVector2.Zero), SizeOf(Single));
end;

class procedure ImGui.PlotLines(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValueGetter; 
  const AData: Pointer; const AValuesCount: Int32);
begin
  _igPlotLinesCallback(ALabel, @AValuesGetter, AData, AValuesCount);
end;

class procedure ImGui.PlotLines(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValueGetter; 
  const AData: Pointer; const AValuesCount: Int32; const AValuesOffset: Int32; const AOverlayText: PUTF8Char; 
  const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2);
begin
  _igPlotLinesCallbackEx(ALabel, @AValuesGetter, AData, AValuesCount, AValuesOffset, AOverlayText, AScaleMin, AScaleMax, _ImVec2(AGraphSize));
end;

class procedure ImGui.PlotLines(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValueGetter; const AData: Pointer; const AValuesCount: Int32; const AValuesOffset: Int32 = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle);
begin
  _igPlotLinesCallbackEx(ALabel, @AValuesGetter, AData, AValuesCount, AValuesOffset, AOverlayText, AScaleMin, AScaleMax, _ImVec2(TVector2.Zero));
end;

class procedure ImGui.PlotHistogram(const ALabel: PUTF8Char; const AValues: PSingle; 
  const AValuesCount: Int32);
begin
  _igPlotHistogram(ALabel, AValues, AValuesCount);
end;

class procedure ImGui.PlotHistogram(const ALabel: PUTF8Char; const AValues: PSingle; 
  const AValuesCount: Int32; const AValuesOffset: Int32; const AOverlayText: PUTF8Char; 
  const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2; 
  const AStride: Int32);
begin
  _igPlotHistogramEx(ALabel, AValues, AValuesCount, AValuesOffset, AOverlayText, AScaleMin, AScaleMax, _ImVec2(AGraphSize), AStride);
end;

class procedure ImGui.PlotHistogram(const ALabel: PUTF8Char; const AValues: PSingle; const AValuesCount: Int32; const AValuesOffset: Int32 = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle);
begin
  _igPlotHistogramEx(ALabel, AValues, AValuesCount, AValuesOffset, AOverlayText, AScaleMin, AScaleMax, _ImVec2(TVector2.Zero), SizeOf(Single));
end;

class procedure ImGui.PlotHistogram(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValueGetter; 
  const AData: Pointer; const AValuesCount: Int32);
begin
  _igPlotHistogramCallback(ALabel, @AValuesGetter, AData, AValuesCount);
end;

class procedure ImGui.PlotHistogram(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValueGetter; 
  const AData: Pointer; const AValuesCount: Int32; const AValuesOffset: Int32; const AOverlayText: PUTF8Char; 
  const AScaleMin: Single; const AScaleMax: Single; const AGraphSize: TVector2);
begin
  _igPlotHistogramCallbackEx(ALabel, @AValuesGetter, AData, AValuesCount, AValuesOffset, AOverlayText, AScaleMin, AScaleMax, _ImVec2(AGraphSize));
end;

class procedure ImGui.PlotHistogram(const ALabel: PUTF8Char; const AValuesGetter: TImGuiValueGetter; const AData: Pointer; const AValuesCount: Int32; const AValuesOffset: Int32 = 0; const AOverlayText: PUTF8Char = nil; const AScaleMin: Single = MaxSingle; const AScaleMax: Single = MaxSingle);
begin
  _igPlotHistogramCallbackEx(ALabel, @AValuesGetter, AData, AValuesCount, AValuesOffset, AOverlayText, AScaleMin, AScaleMax, _ImVec2(TVector2.Zero));
end;

class function ImGui.BeginMenuBar: Boolean;
begin
  Result := _igBeginMenuBar();
end;

class procedure ImGui.EndMenuBar;
begin
  _igEndMenuBar();
end;

class function ImGui.BeginMainMenuBar: Boolean;
begin
  Result := _igBeginMainMenuBar();
end;

class procedure ImGui.EndMainMenuBar;
begin
  _igEndMainMenuBar();
end;

class function ImGui.BeginMenu(const ALabel: PUTF8Char; const AEnabled: Boolean): Boolean;
begin
  Result := _igBeginMenuEx(ALabel, AEnabled);
end;

class procedure ImGui.EndMenu;
begin
  _igEndMenu();
end;

class function ImGui.MenuItem(const ALabel: PUTF8Char; const AShortcut: PUTF8Char; 
  const ASelected: Boolean; const AEnabled: Boolean): Boolean;
begin
  Result := _igMenuItemEx(ALabel, AShortcut, ASelected, AEnabled);
end;

class function ImGui.MenuItem(const ALabel, AShortcut: PUTF8Char; const APSelected: PBoolean; 
  const AEnabled: Boolean): Boolean;
begin
  Result := _igMenuItemBoolPtr(ALabel, AShortcut, APSelected, AEnabled);
end;

class function ImGui.BeginTooltip: Boolean;
begin
  Result := _igBeginTooltip();
end;

class procedure ImGui.EndTooltip;
begin
  _igEndTooltip();
end;

class procedure ImGui.SetTooltip(const AFmt: PUTF8Char);
begin
  _igSetTooltip(AFmt);
end;

class function ImGui.BeginItemTooltip: Boolean;
begin
  Result := _igBeginItemTooltip();
end;

class procedure ImGui.SetItemTooltip(const AFmt: PUTF8Char);
begin
  _igSetItemTooltip(AFmt);
end;

class function ImGui.BeginPopup(const AStrId: PUTF8Char; const AFlags: TImGuiWindowFlags): Boolean;
begin
  Result := _igBeginPopup(AStrId, Cardinal(AFlags));
end;

class function ImGui.BeginPopupModal(const AName: PUTF8Char; const APOpen: PBoolean; 
  const AFlags: TImGuiWindowFlags): Boolean;
begin
  Result := _igBeginPopupModal(AName, APOpen, Cardinal(AFlags));
end;

class procedure ImGui.EndPopup;
begin
  _igEndPopup();
end;

class procedure ImGui.OpenPopup(const AStrId: PUTF8Char; const APopupFlags: TImGuiPopupFlags);
begin
  _igOpenPopup(AStrId, Cardinal(APopupFlags));
end;

class procedure ImGui.OpenPopup(const AId: TImGuiID; const APopupFlags: TImGuiPopupFlags);
begin
  _igOpenPopupID(_ImGuiID(AId), Cardinal(APopupFlags));
end;

class procedure ImGui.OpenPopupOnItemClick(const AStrId: PUTF8Char; const APopupFlags: TImGuiPopupFlags);
begin
  _igOpenPopupOnItemClick(AStrId, Cardinal(APopupFlags));
end;

class procedure ImGui.CloseCurrentPopup;
begin
  _igCloseCurrentPopup();
end;

class function ImGui.BeginPopupContextItem(const AStrId: PUTF8Char; const APopupFlags: TImGuiPopupFlags): Boolean;
begin
  Result := _igBeginPopupContextItemEx(AStrId, Cardinal(APopupFlags));
end;

class function ImGui.BeginPopupContextWindow(const AStrId: PUTF8Char; const APopupFlags: TImGuiPopupFlags): Boolean;
begin
  Result := _igBeginPopupContextWindowEx(AStrId, Cardinal(APopupFlags));
end;

class function ImGui.BeginPopupContextVoid(const AStrId: PUTF8Char; const APopupFlags: TImGuiPopupFlags): Boolean;
begin
  Result := _igBeginPopupContextVoidEx(AStrId, Cardinal(APopupFlags));
end;

class function ImGui.IsPopupOpen(const AStrId: PUTF8Char; const AFlags: TImGuiPopupFlags): Boolean;
begin
  Result := _igIsPopupOpen(AStrId, Cardinal(AFlags));
end;

class function ImGui.BeginTable(const AStrId: PUTF8Char; const AColumns: Int32; 
  const AFlags: TImGuiTableFlags): Boolean;
begin
  Result := _igBeginTable(AStrId, AColumns, Cardinal(AFlags));
end;

class function ImGui.BeginTable(const AStrId: PUTF8Char; const AColumns: Int32; 
  const AFlags: TImGuiTableFlags; const AOuterSize: TVector2; const AInnerWidth: Single): Boolean;
begin
  Result := _igBeginTableEx(AStrId, AColumns, Cardinal(AFlags), _ImVec2(AOuterSize), AInnerWidth);
end;

class procedure ImGui.EndTable;
begin
  _igEndTable();
end;

class procedure ImGui.TableNextRow(const ARowFlags: TImGuiTableRowFlags; const AMinRowHeight: Single);
begin
  _igTableNextRowEx(Cardinal(ARowFlags), AMinRowHeight);
end;

class function ImGui.TableNextColumn: Boolean;
begin
  Result := _igTableNextColumn();
end;

class function ImGui.TableSetColumnIndex(const AColumnN: Int32): Boolean;
begin
  Result := _igTableSetColumnIndex(AColumnN);
end;

class procedure ImGui.TableSetupColumn(const ALabel: PUTF8Char; const AFlags: TImGuiTableColumnFlags; 
  const AInitWidthOrWeight: Single; const AUserId: TImGuiID);
begin
  _igTableSetupColumnEx(ALabel, Cardinal(AFlags), AInitWidthOrWeight, _ImGuiID(AUserId));
end;

class procedure ImGui.TableSetupScrollFreeze(const ACols, ARows: Int32);
begin
  _igTableSetupScrollFreeze(ACols, ARows);
end;

class procedure ImGui.TableHeader(const ALabel: PUTF8Char);
begin
  _igTableHeader(ALabel);
end;

class procedure ImGui.TableHeadersRow;
begin
  _igTableHeadersRow();
end;

class procedure ImGui.TableAngledHeadersRow;
begin
  _igTableAngledHeadersRow();
end;

class function ImGui.TableGetSortSpecs: PImGuiTableSortSpecs;
begin
  Result := _igTableGetSortSpecs();
end;

class function ImGui.TableGetColumnCount: Int32;
begin
  Result := _igTableGetColumnCount();
end;

class function ImGui.TableGetColumnIndex: Int32;
begin
  Result := _igTableGetColumnIndex();
end;

class function ImGui.TableGetRowIndex: Int32;
begin
  Result := _igTableGetRowIndex();
end;

class function ImGui.TableGetColumnName(const AColumnN: Int32): PUTF8Char;
begin
  Result := _igTableGetColumnName(AColumnN);
end;

class function ImGui.TableGetColumnFlags(const AColumnN: Int32): TImGuiTableColumnFlags;
begin
  Result := TImGuiTableColumnFlags(_igTableGetColumnFlags(AColumnN));
end;

class procedure ImGui.TableSetColumnEnabled(const AColumnN: Int32; const AV: Boolean);
begin
  _igTableSetColumnEnabled(AColumnN, AV);
end;

class function ImGui.TableGetHoveredColumn: Int32;
begin
  Result := _igTableGetHoveredColumn();
end;

class procedure ImGui.TableSetBgColor(const ATarget: TImGuiTableBgTarget; const AColor: UInt32; 
  const AColumnN: Int32);
begin
  _igTableSetBgColor(_ImGuiTableBgTarget(ATarget), _ImU32(AColor), AColumnN);
end;

class procedure ImGui.Columns(const ACount: Int32; const AId: PUTF8Char; const ABorders: Boolean);
begin
  _igColumnsEx(ACount, AId, ABorders);
end;

class procedure ImGui.NextColumn;
begin
  _igNextColumn();
end;

class function ImGui.GetColumnIndex: Int32;
begin
  Result := _igGetColumnIndex();
end;

class function ImGui.GetColumnWidth(const AColumnIndex: Int32): Single;
begin
  Result := _igGetColumnWidth(AColumnIndex);
end;

class procedure ImGui.SetColumnWidth(const AColumnIndex: Int32; const AWidth: Single);
begin
  _igSetColumnWidth(AColumnIndex, AWidth);
end;

class function ImGui.GetColumnOffset(const AColumnIndex: Int32): Single;
begin
  Result := _igGetColumnOffset(AColumnIndex);
end;

class procedure ImGui.SetColumnOffset(const AColumnIndex: Int32; const AOffsetX: Single);
begin
  _igSetColumnOffset(AColumnIndex, AOffsetX);
end;

class function ImGui.GetColumnsCount: Int32;
begin
  Result := _igGetColumnsCount();
end;

class function ImGui.BeginTabBar(const AStrId: PUTF8Char; const AFlags: TImGuiTabBarFlags): Boolean;
begin
  Result := _igBeginTabBar(AStrId, Cardinal(AFlags));
end;

class procedure ImGui.EndTabBar;
begin
  _igEndTabBar();
end;

class function ImGui.BeginTabItem(const ALabel: PUTF8Char; const APOpen: PBoolean; 
  const AFlags: TImGuiTabItemFlags): Boolean;
begin
  Result := _igBeginTabItem(ALabel, APOpen, Cardinal(AFlags));
end;

class procedure ImGui.EndTabItem;
begin
  _igEndTabItem();
end;

class function ImGui.TabItemButton(const ALabel: PUTF8Char; const AFlags: TImGuiTabItemFlags): Boolean;
begin
  Result := _igTabItemButton(ALabel, Cardinal(AFlags));
end;

class procedure ImGui.SetTabItemClosed(const ATabOrDockedWindowLabel: PUTF8Char);
begin
  _igSetTabItemClosed(ATabOrDockedWindowLabel);
end;

class procedure ImGui.LogToTTY(const AAutoOpenDepth: Int32);
begin
  _igLogToTTY(AAutoOpenDepth);
end;

class procedure ImGui.LogToFile(const AAutoOpenDepth: Int32; const AFilename: PUTF8Char);
begin
  _igLogToFile(AAutoOpenDepth, AFilename);
end;

class procedure ImGui.LogToClipboard(const AAutoOpenDepth: Int32);
begin
  _igLogToClipboard(AAutoOpenDepth);
end;

class procedure ImGui.LogFinish;
begin
  _igLogFinish();
end;

class procedure ImGui.LogButtons;
begin
  _igLogButtons();
end;

class procedure ImGui.LogText(const AFmt: PUTF8Char);
begin
  _igLogText(AFmt);
end;

class function ImGui.BeginDragDropSource(const AFlags: TImGuiDragDropFlags): Boolean;
begin
  Result := _igBeginDragDropSource(Cardinal(AFlags));
end;

class function ImGui.SetDragDropPayload(const AType: PUTF8Char; const AData: Pointer; 
  const ASz: NativeUInt; const ACond: TImGuiCond): Boolean;
begin
  Result := _igSetDragDropPayload(AType, AData, ASz, _ImGuiCond(ACond));
end;

class procedure ImGui.EndDragDropSource;
begin
  _igEndDragDropSource();
end;

class function ImGui.BeginDragDropTarget: Boolean;
begin
  Result := _igBeginDragDropTarget();
end;

class function ImGui.AcceptDragDropPayload(const AType: PUTF8Char; const AFlags: TImGuiDragDropFlags): PImGuiPayload;
begin
  Result := _igAcceptDragDropPayload(AType, Cardinal(AFlags));
end;

class procedure ImGui.EndDragDropTarget;
begin
  _igEndDragDropTarget();
end;

class function ImGui.GetDragDropPayload: PImGuiPayload;
begin
  Result := _igGetDragDropPayload();
end;

class procedure ImGui.BeginDisabled(const ADisabled: Boolean);
begin
  _igBeginDisabled(ADisabled);
end;

class procedure ImGui.EndDisabled;
begin
  _igEndDisabled();
end;

class procedure ImGui.PushClipRect(const AClipRectMin, AClipRectMax: TVector2; const AIntersectWithCurrentClipRect: Boolean);
begin
  _igPushClipRect(_ImVec2(AClipRectMin), _ImVec2(AClipRectMax), AIntersectWithCurrentClipRect);
end;

class procedure ImGui.PopClipRect;
begin
  _igPopClipRect();
end;

class procedure ImGui.SetItemDefaultFocus;
begin
  _igSetItemDefaultFocus();
end;

class procedure ImGui.SetKeyboardFocusHere(const AOffset: Int32);
begin
  _igSetKeyboardFocusHereEx(AOffset);
end;

class procedure ImGui.SetNavCursorVisible(const AVisible: Boolean);
begin
  _igSetNavCursorVisible(AVisible);
end;

class procedure ImGui.SetNextItemAllowOverlap;
begin
  _igSetNextItemAllowOverlap();
end;

class function ImGui.IsItemHovered(const AFlags: TImGuiHoveredFlags): Boolean;
begin
  Result := _igIsItemHovered(Cardinal(AFlags));
end;

class function ImGui.IsItemActive: Boolean;
begin
  Result := _igIsItemActive();
end;

class function ImGui.IsItemFocused: Boolean;
begin
  Result := _igIsItemFocused();
end;

class function ImGui.IsItemClicked(const AMouseButton: TImGuiMouseButton): Boolean;
begin
  Result := _igIsItemClickedEx(_ImGuiMouseButton(AMouseButton));
end;

class function ImGui.IsItemVisible: Boolean;
begin
  Result := _igIsItemVisible();
end;

class function ImGui.IsItemEdited: Boolean;
begin
  Result := _igIsItemEdited();
end;

class function ImGui.IsItemActivated: Boolean;
begin
  Result := _igIsItemActivated();
end;

class function ImGui.IsItemDeactivated: Boolean;
begin
  Result := _igIsItemDeactivated();
end;

class function ImGui.IsItemDeactivatedAfterEdit: Boolean;
begin
  Result := _igIsItemDeactivatedAfterEdit();
end;

class function ImGui.IsItemToggledOpen: Boolean;
begin
  Result := _igIsItemToggledOpen();
end;

class function ImGui.IsAnyItemHovered: Boolean;
begin
  Result := _igIsAnyItemHovered();
end;

class function ImGui.IsAnyItemActive: Boolean;
begin
  Result := _igIsAnyItemActive();
end;

class function ImGui.IsAnyItemFocused: Boolean;
begin
  Result := _igIsAnyItemFocused();
end;

class function ImGui.GetItemID: TImGuiID;
begin
  Result := TImGuiID(_igGetItemID());
end;

class function ImGui.GetItemRectMin: TVector2;
begin
  Result := TVector2(_igGetItemRectMin());
end;

class function ImGui.GetItemRectMax: TVector2;
begin
  Result := TVector2(_igGetItemRectMax());
end;

class function ImGui.GetItemRectSize: TVector2;
begin
  Result := TVector2(_igGetItemRectSize());
end;

class function ImGui.GetItemFlags: TImGuiItemFlags;
begin
  Result := TImGuiItemFlags(_igGetItemFlags());
end;

class function ImGui.GetMainViewport: PImGuiViewport;
begin
  Result := _igGetMainViewport();
end;

class function ImGui.GetBackgroundDrawList: PImDrawList;
begin
  Result := _igGetBackgroundDrawList();
end;

class function ImGui.GetForegroundDrawList: PImDrawList;
begin
  Result := _igGetForegroundDrawList();
end;

class function ImGui.IsRectVisible(const ASize: TVector2): Boolean;
begin
  Result := _igIsRectVisibleBySize(_ImVec2(ASize));
end;

class function ImGui.IsRectVisible(const ARectMin, ARectMax: TVector2): Boolean;
begin
  Result := _igIsRectVisible(_ImVec2(ARectMin), _ImVec2(ARectMax));
end;

class function ImGui.GetTime: Double;
begin
  Result := _igGetTime();
end;

class function ImGui.GetFrameCount: Int32;
begin
  Result := _igGetFrameCount();
end;

class function ImGui.GetDrawListSharedData: PImDrawListSharedData;
begin
  Result := _igGetDrawListSharedData();
end;

class function ImGui.GetStyleColorName(const AIdx: TImGuiCol): PUTF8Char;
begin
  Result := _igGetStyleColorName(_ImGuiCol(AIdx));
end;

class procedure ImGui.SetStateStorage(const AStorage: PImGuiStorage);
begin
  _igSetStateStorage(AStorage);
end;

class function ImGui.GetStateStorage: PImGuiStorage;
begin
  Result := _igGetStateStorage();
end;

class function ImGui.CalcTextSize(const AText: PUTF8Char; const ATextEnd: PUTF8Char; 
  const AHideTextAfterDoubleHash: Boolean; const AWrapWidth: Single): TVector2;
begin
  Result := TVector2(_igCalcTextSizeEx(AText, ATextEnd, AHideTextAfterDoubleHash, AWrapWidth));
end;

class function ImGui.ColorConvertU32ToFloat4(const AIn: UInt32): TVector4;
begin
  Result := TVector4(_igColorConvertU32ToFloat4(_ImU32(AIn)));
end;

class function ImGui.ColorConvertFloat4ToU32(const AIn: TVector4): UInt32;
begin
  Result := UInt32(_igColorConvertFloat4ToU32(_ImVec4(AIn)));
end;

class procedure ImGui.ColorConvertRGBtoHSV(const AR, AG, AB: Single; const AOutH, 
  AOutS, AOutV: PSingle);
begin
  _igColorConvertRGBtoHSV(AR, AG, AB, AOutH, AOutS, AOutV);
end;

class procedure ImGui.ColorConvertHSVtoRGB(const AH, &AS, AV: Single; const AOutR, 
  AOutG, AOutB: PSingle);
begin
  _igColorConvertHSVtoRGB(AH, &AS, AV, AOutR, AOutG, AOutB);
end;

class function ImGui.IsKeyDown(const AKey: TImGuiKey): Boolean;
begin
  Result := _igIsKeyDown(_ImGuiKey(AKey));
end;

class function ImGui.IsKeyPressed(const AKey: TImGuiKey; const ARepeat: Boolean): Boolean;
begin
  Result := _igIsKeyPressedEx(_ImGuiKey(AKey), ARepeat);
end;

class function ImGui.IsKeyReleased(const AKey: TImGuiKey): Boolean;
begin
  Result := _igIsKeyReleased(_ImGuiKey(AKey));
end;

class function ImGui.IsKeyChordPressed(const AKeyChord: TImGuiKeyChord): Boolean;
begin
  Result := _igIsKeyChordPressed(_ImGuiKeyChord(AKeyChord));
end;

class function ImGui.GetKeyPressedAmount(const AKey: TImGuiKey; const ARepeatDelay, 
  ARate: Single): Int32;
begin
  Result := _igGetKeyPressedAmount(_ImGuiKey(AKey), ARepeatDelay, ARate);
end;

class function ImGui.GetKeyName(const AKey: TImGuiKey): PUTF8Char;
begin
  Result := _igGetKeyName(_ImGuiKey(AKey));
end;

class procedure ImGui.SetNextFrameWantCaptureKeyboard(const AWantCaptureKeyboard: Boolean);
begin
  _igSetNextFrameWantCaptureKeyboard(AWantCaptureKeyboard);
end;

class function ImGui.Shortcut(const AKeyChord: TImGuiKeyChord; const AFlags: TImGuiInputFlags): Boolean;
begin
  Result := _igShortcut(_ImGuiKeyChord(AKeyChord), Cardinal(AFlags));
end;

class procedure ImGui.SetNextItemShortcut(const AKeyChord: TImGuiKeyChord; const AFlags: TImGuiInputFlags);
begin
  _igSetNextItemShortcut(_ImGuiKeyChord(AKeyChord), Cardinal(AFlags));
end;

class function ImGui.SetItemKeyOwner(const AKey: TImGuiKey): Boolean;
begin
  Result := _igSetItemKeyOwner(_ImGuiKey(AKey));
end;

class function ImGui.IsMouseDown(const AButton: TImGuiMouseButton): Boolean;
begin
  Result := _igIsMouseDown(_ImGuiMouseButton(AButton));
end;

class function ImGui.IsMouseClicked(const AButton: TImGuiMouseButton; const ARepeat: Boolean): Boolean;
begin
  Result := _igIsMouseClickedEx(_ImGuiMouseButton(AButton), ARepeat);
end;

class function ImGui.IsMouseReleased(const AButton: TImGuiMouseButton): Boolean;
begin
  Result := _igIsMouseReleased(_ImGuiMouseButton(AButton));
end;

class function ImGui.IsMouseDoubleClicked(const AButton: TImGuiMouseButton): Boolean;
begin
  Result := _igIsMouseDoubleClicked(_ImGuiMouseButton(AButton));
end;

class function ImGui.IsMouseReleasedWithDelay(const AButton: TImGuiMouseButton; 
  const ADelay: Single): Boolean;
begin
  Result := _igIsMouseReleasedWithDelay(_ImGuiMouseButton(AButton), ADelay);
end;

class function ImGui.GetMouseClickedCount(const AButton: TImGuiMouseButton): Int32;
begin
  Result := _igGetMouseClickedCount(_ImGuiMouseButton(AButton));
end;

class function ImGui.IsMouseHoveringRect(const ARMin, ARMax: TVector2; const AClip: Boolean): Boolean;
begin
  Result := _igIsMouseHoveringRectEx(_ImVec2(ARMin), _ImVec2(ARMax), AClip);
end;

class function ImGui.IsMousePosValid(const AMousePos: PVector2): Boolean;
begin
  Result := _igIsMousePosValid(AMousePos);
end;

class function ImGui.IsAnyMouseDown: Boolean;
begin
  Result := _igIsAnyMouseDown();
end;

class function ImGui.GetMousePos: TVector2;
begin
  Result := TVector2(_igGetMousePos());
end;

class function ImGui.GetMousePosOnOpeningCurrentPopup: TVector2;
begin
  Result := TVector2(_igGetMousePosOnOpeningCurrentPopup());
end;

class function ImGui.IsMouseDragging(const AButton: TImGuiMouseButton; const ALockThreshold: Single): Boolean;
begin
  Result := _igIsMouseDragging(_ImGuiMouseButton(AButton), ALockThreshold);
end;

class function ImGui.GetMouseDragDelta(const AButton: TImGuiMouseButton; const ALockThreshold: Single): TVector2;
begin
  Result := TVector2(_igGetMouseDragDelta(_ImGuiMouseButton(AButton), ALockThreshold));
end;

class procedure ImGui.ResetMouseDragDelta(const AButton: TImGuiMouseButton);
begin
  _igResetMouseDragDeltaEx(_ImGuiMouseButton(AButton));
end;

class function ImGui.GetMouseCursor: TImGuiMouseCursor;
begin
  Result := TImGuiMouseCursor(_igGetMouseCursor());
end;

class procedure ImGui.SetMouseCursor(const ACursorType: TImGuiMouseCursor);
begin
  _igSetMouseCursor(_ImGuiMouseCursor(ACursorType));
end;

class procedure ImGui.SetNextFrameWantCaptureMouse(const AWantCaptureMouse: Boolean);
begin
  _igSetNextFrameWantCaptureMouse(AWantCaptureMouse);
end;

class function ImGui.GetClipboardText: PUTF8Char;
begin
  Result := _igGetClipboardText();
end;

class procedure ImGui.SetClipboardText(const AText: PUTF8Char);
begin
  _igSetClipboardText(AText);
end;

class procedure ImGui.LoadIniSettingsFromDisk(const AIniFilename: PUTF8Char);
begin
  _igLoadIniSettingsFromDisk(AIniFilename);
end;

class procedure ImGui.LoadIniSettingsFromMemory(const AIniData: PUTF8Char; const AIniSize: NativeUInt);
begin
  _igLoadIniSettingsFromMemory(AIniData, AIniSize);
end;

class procedure ImGui.SaveIniSettingsToDisk(const AIniFilename: PUTF8Char);
begin
  _igSaveIniSettingsToDisk(AIniFilename);
end;

class function ImGui.SaveIniSettingsToMemory(const AOutIniSize: PNativeUInt): PUTF8Char;
begin
  Result := _igSaveIniSettingsToMemory(AOutIniSize);
end;

class procedure ImGui.DebugTextEncoding(const AText: PUTF8Char);
begin
  _igDebugTextEncoding(AText);
end;

class procedure ImGui.DebugFlashStyleColor(const AIdx: TImGuiCol);
begin
  _igDebugFlashStyleColor(_ImGuiCol(AIdx));
end;

class procedure ImGui.DebugStartItemPicker;
begin
  _igDebugStartItemPicker();
end;

class function ImGui.DebugCheckVersionAndDataLayout(const AVersionStr: PUTF8Char; 
  const ASzIo, ASzStyle, ASzVec2, ASzVec4, ASzDrawvert, ASzDrawidx: NativeUInt): Boolean;
begin
  Result := _igDebugCheckVersionAndDataLayout(AVersionStr, ASzIo, ASzStyle, ASzVec2, ASzVec4, ASzDrawvert, ASzDrawidx);
end;

class procedure ImGui.DebugLog(const AFmt: PUTF8Char);
begin
  _igDebugLog(AFmt);
end;

class procedure ImGui.SetAllocatorFunctions(const AAllocFunc: TImGuiMemAllocFunc; 
  const AFreeFunc: TImGuiMemFreeFunc; const AUserData: Pointer);
begin
  _igSetAllocatorFunctions(_ImGuiMemAllocFunc(AAllocFunc), _ImGuiMemFreeFunc(AFreeFunc), AUserData);
end;

class procedure ImGui.GetAllocatorFunctions(const APAllocFunc: PImGuiMemAllocFunc; 
  const APFreeFunc: PImGuiMemFreeFunc; const APUserData: PPointer);
begin
  _igGetAllocatorFunctions(APAllocFunc, APFreeFunc, APUserData);
end;

class function ImGui.MemAlloc(const ASize: NativeUInt): Pointer;
begin
  Result := _igMemAlloc(ASize);
end;

class procedure ImGui.MemFree(const APtr: Pointer);
begin
  _igMemFree(APtr);
end;

initialization
  Assert(SizeOf(TImDrawListSharedData) = SizeOf(_ImDrawListSharedData));
  Assert(SizeOf(TImFontAtlasBuilder) = SizeOf(_ImFontAtlasBuilder));
  Assert(SizeOf(TImFontLoader) = SizeOf(_ImFontLoader));
  Assert(SizeOf(TImGuiContext) = SizeOf(_ImGuiContext));
  Assert(SizeOf(TImTextureRef) = SizeOf(_ImTextureRef));
  Assert(SizeOf(TImGuiTableSortSpecs) = SizeOf(_ImGuiTableSortSpecs));
  Assert(SizeOf(TImGuiTableColumnSortSpecs) = SizeOf(_ImGuiTableColumnSortSpecs));
  Assert(SizeOf(TImGuiStyle) = SizeOf(_ImGuiStyle));
  Assert(SizeOf(TImGuiKeyData) = SizeOf(_ImGuiKeyData));
  Assert(SizeOf(TImGuiIO) = SizeOf(_ImGuiIO));
  Assert(SizeOf(TImGuiInputTextCallbackData) = SizeOf(_ImGuiInputTextCallbackData));
  Assert(SizeOf(TImGuiSizeCallbackData) = SizeOf(_ImGuiSizeCallbackData));
  Assert(SizeOf(TImGuiPayload) = SizeOf(_ImGuiPayload));
  Assert(SizeOf(TImGuiTextRange) = SizeOf(_ImGuiTextRange));
  Assert(SizeOf(TImGuiTextFilter) = SizeOf(_ImGuiTextFilter));
  Assert(SizeOf(TImGuiTextBuffer) = SizeOf(_ImGuiTextBuffer));
  Assert(SizeOf(TImGuiStoragePair) = SizeOf(_ImGuiStoragePair));
  Assert(SizeOf(TImGuiStorage) = SizeOf(_ImGuiStorage));
  Assert(SizeOf(TImGuiListClipper) = SizeOf(_ImGuiListClipper));
  Assert(SizeOf(TImGuiSelectionRequest) = SizeOf(_ImGuiSelectionRequest));
  Assert(SizeOf(TImGuiMultiSelectIO) = SizeOf(_ImGuiMultiSelectIO));
  Assert(SizeOf(TImGuiSelectionBasicStorage) = SizeOf(_ImGuiSelectionBasicStorage));
  Assert(SizeOf(TImGuiSelectionExternalStorage) = SizeOf(_ImGuiSelectionExternalStorage));
  Assert(SizeOf(TImDrawCmd) = SizeOf(_ImDrawCmd));
  Assert(SizeOf(TImDrawVert) = SizeOf(_ImDrawVert));
  Assert(SizeOf(TImDrawCmdHeader) = SizeOf(_ImDrawCmdHeader));
  Assert(SizeOf(TImDrawChannel) = SizeOf(_ImDrawChannel));
  Assert(SizeOf(TImDrawListSplitter) = SizeOf(_ImDrawListSplitter));
  Assert(SizeOf(TImDrawList) = SizeOf(_ImDrawList));
  Assert(SizeOf(TImDrawData) = SizeOf(_ImDrawData));
  Assert(SizeOf(TImTextureRect) = SizeOf(_ImTextureRect));
  Assert(SizeOf(TImTextureData) = SizeOf(_ImTextureData));
  Assert(SizeOf(TImFontConfig) = SizeOf(_ImFontConfig));
  Assert(SizeOf(TImFontGlyph) = SizeOf(_ImFontGlyph));
  Assert(SizeOf(TImFontGlyphRangesBuilder) = SizeOf(_ImFontGlyphRangesBuilder));
  Assert(SizeOf(TImFontAtlasRect) = SizeOf(_ImFontAtlasRect));
  Assert(SizeOf(TImFontAtlas) = SizeOf(_ImFontAtlas));
  Assert(SizeOf(TImFontBaked) = SizeOf(_ImFontBaked));
  Assert(SizeOf(TImFont) = SizeOf(_ImFont));
  Assert(SizeOf(TImGuiViewport) = SizeOf(_ImGuiViewport));
  Assert(SizeOf(TImGuiPlatformIO) = SizeOf(_ImGuiPlatformIO));
  Assert(SizeOf(TImGuiPlatformImeData) = SizeOf(_ImGuiPlatformImeData));

end.

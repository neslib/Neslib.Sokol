unit Neslib.Sokol.ImGui;
{ Drop-in Dear ImGui renderer/event-handler Neslib.Sokol.Gfx.

  For a user guide, check out the Neslib.Sokol.ImGui.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.ImGui.md }

interface

uses
  Neslib.Sokol.Api,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Types;

type
  { An enum with a unique item for each log message, warning, error and
    validation layer message. Note that these messages are only visible when a
    logger function is installed in the SokolImGui.Setup call. }
  TImGuiLogItem = (
    Ok,
    MallocFailed,
    BufferOverflow);

type
  _TImGuiLogItemHelper = record helper for TImGuiLogItem
  public
    function ToString: String;
  end;

type
  { Used in TSokolImGuiDesc to provide a logging function. Please be aware that
    without logging function, Neslib.Sokol.ImGui will be completely silent, e.g.
    it will not report errors, warnings and validation layer messages. For
    maximum error verbosity, compile in debug mode and provide a compatible
    logger function in the SokolImGui.Setup call (for instance the standard
    logging function TSokolImGuiDesc.DefaultLogger).

    Parameters:
    * ALevel: log level
    * AItem: log item
    * AMessage: the log message corresponding to AItem.
    * ALineNr: line number in original sokol_imgui.h file. }
  TImGuiLogger = procedure(const ALevel: TLogLevel; const AItem: TImGuiLogItem;
    const AMessage: String; const ALineNr: Integer) of object;

type
  { Configurations settings for SokolImGui }
  TSokolImGuiDesc = record
  {$REGION 'Internal Declarations'}
  private class var
    GLogger: TImGuiLogger;
  private
    class procedure LogCallback(const ATag: PUTF8Char; ALogLevel,
      ALogItemId: UInt32; const AMessageOrNull: PUTF8Char; ALineNr: UInt32;
      const AFilenameOrNull: PUTF8Char; AUserData: Pointer); cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    { The maximum number of vertices used for UI rendering, default is 65536.
      This unit will use this to compute the size of the vertex- and
      index-buffers. }
    MaxVertices: Integer;

    { The color pixel format of the render pass where the UI will be rendered.
      The default matches Neslib.Sokol.Gfx's default pass. }
    ColorFormat: TPixelFormat;

    { The depth-buffer pixel format of the render pass where the UI will be
      rendered. The default matches Neslib.Sokol.Gfx's default pass depth
      format. }
    DepthFormat: TPixelFormat;

    { The MSAA sample-count of the render pass where the UI will be rendered.
      The default matches Neslib.Sokol.Gfx's  default pass sample count. }
    SampleCount: Integer;

    { Sets this path as ImGui.GetIO.IniFilename where ImGui will store and
      load UI persistency data. By default this is empty, so that Dear ImGui
      will not preserve state between sessions (and also won't do any
      filesystem calls). Also see the ImGui functions:
        - LoadIniSettingsFromMemory
        - SaveIniSettingsFromMemory
      These functions give you explicit control over loading and saving UI
      state while using your own filesystem wrapper functions (in this case
      keep IniFilename empty). }
    IniFilename: String;

    { Set this to True if you don't want to use ImGui's default font. In this
      case you need to initialize the font yourself after SokolImGui.Setup is
      called. }
    NoDefaultFont: Boolean;

    { If set to True, this unit will not 'emulate' a Dear Imgui clipboard
      paste action on TApplication.ClipboardPasted event. In general,
      copy/paste support isn't properly fleshed out in this unit yet. }
    DisablePasteOverride: Boolean;

    { If True, this unit will not control the mouse cursor type by using
      TApplication.MouseCursor. }
    DisableSetMouseCursor: Boolean;

    { If True, windows can only be resized from the bottom right corner.
      The default is False, meaning windows can be resized from edges. }
    DisableWindowsResizeFromEdges: Boolean;

    { Set this to True if you want alpha values written to the framebuffer. By
      default this behavior is disabled. }
    WriteAlphaChannel: Boolean;

    { Set to True to use Delphi's memory manager instead of Sokol's internal
      one.
      When SOKOL_MEM_TRACK is defined, it always uses Delphi's memory manager. }
    UseDelphiMemoryManager: Boolean;

    { Optional log function override }
    Logger: TImGuiLogger;
  public
    { Initializes with default values }
    class function Create: TSokolImGuiDesc; inline; static;
    procedure Init;

    { A default log function you can assign to the Logger field. }
    procedure DefaultLogger(const ALevel: TLogLevel; const AItem: TImGuiLogItem;
      const AMessage: String; const ALineNr: Integer);
  end;
  PSokolImGuiDesc = ^TSokolImGuiDesc;

type
  { Describes a frame for rendering }
  TSokolImGuiFrameDesc = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _simgui_frame_desc_t;
  {$ENDREGION 'Internal Declarations'}
  public
    { Initializes with default values }
    class function Create: TSokolImGuiFrameDesc; inline; static;
    procedure Init;

    { The dimensions of the rendering surface, passed to
      ImGui.GetIO.DisplaySize. }
    property Width: Integer read FHandle.width write FHandle.width;
    property Height: Integer read FHandle.height write FHandle.height;

    { The frame duration passed to ImGui.GetIO.DeltaTime. }
    property DeltaTime: Double read FHandle.delta_time write FHandle.delta_time;

    { The current DPI scale factor, if this is left zero-initialized, 1.0 will
      be used instead. Typical values for DpiScale are >= 1.0. }
    property DpiScale: Single read FHandle.dpi_scale write FHandle.dpi_scale;
  end;
  PSokolImGuiFrameDesc = ^TSokolImGuiFrameDesc;

type
  TSokolImGuiFontTexDesc = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _simgui_font_tex_desc_t;
    function GetMinFilter: TFilter; inline;
    procedure SetMinFilter(const AValue: TFilter); inline;
    function GetMagFilter: TFilter; inline;
    procedure SetMagFilter(const AValue: TFilter); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Initializes with default values }
    class function Create: TSokolImGuiFontTexDesc; inline; static;
    procedure Init;

    property MinFilter: TFilter read GetMinFilter write SetMinFilter;
    property MagFilter: TFilter read GetMagFilter write SetMagFilter;
  end;
  PSokolImGuiFontTexDesc = ^TSokolImGuiFontTexDesc;

type
  { The native event handler as used by SokolImGui.GetNativeEventHandler.

    Parameters:
      AEvent: the native event to handle.

    Returns:
      True if the event was handled and shouldn't be processed further.
      False otherwise.  }
  TNativeEventHandler = function (const AEvent: _Psapp_event): Boolean; cdecl;

type
  { Entry point for Sokol - ImGui integration }
  SokolImGui = record // static
  public
    { Initializes Dear ImGui and create Neslib.Sokol.Gfx resources (two buffers
      for vertices and indices, a font texture and a pipeline-state-object).

      Parameters:
        ADesc: configuration options }
    class procedure Setup(const ADesc: TSokolImGuiDesc); static;

    { Starts a new frame.

      Parameters:
        ADesc: frame settings }
    class procedure NewFrame(const ADesc: TSokolImGuiFrameDesc); inline; static;

    { Renders the ImGui frame. Call this before TGfx.EndPass. }
    class procedure Render; inline; static;

    { Shutsdown ImGui integration }
    class procedure Shutdown; inline; static;

    { Create a TImTextureID from a texture view }
    class function ImTextureId(const ATexView: TView): UInt64; overload; inline; static;

    { Create a TImTextureID from a texture view and a sampler }
    class function ImTextureId(const ATexView: TView;
      const ASmp: TSampler): UInt64; overload; inline; static;

    { Extract the texture view from a TImTextureID }
    class function TextureViewFromImTextureId(const AImTexID: UInt64): TView; inline; static;

    { Extract the sampler from a TImTextureID }
    class function SamplerFromImTextureId(const AImTexID: UInt64): TSampler; inline; static;

    { Handles an app event }
    class function HandleEvent(const AEvent: _Psapp_event): Boolean; inline; static;

    { Converts a Neslib.Sokol.App TKeyCode to an ImGui key code.

      Parameters:
        AKeyCode: the ordinal value of the TKeyCode enum. (Note that this
          parameter is *not* of type TKeyCode to avoid a dependency on the
          Neslib.Sokol.App unit.

      Returns:
        The corresponding ImGui keycode }
    class function MapKeyCode(const AKeyCode: Integer): Integer; inline; static;

    class procedure AddFocusEvent(const AFocus: Boolean); inline; static;
    class procedure AddMousePosEvent(const AX, AY: Single); inline; static;
    class procedure AddTouchPosEvent(const AX, AY: Single); inline; static;
    class procedure AddMouseButtonEvent(const AMouseButton: Integer; const ADown: Boolean); inline; static;
    class procedure AddMouseWheelEvent(const AWheelX, AWheelY: Single); inline; static;
    class procedure AddTouchButtonEvent(const AMouseButton: Integer; const ADown: Boolean); inline; static;
    class procedure AddKeyEvent(const AImGuiKey: Integer; const ADown: Boolean); inline; static;
    class procedure AddInputCharacter(const AChar: Char); overload; inline; static;
    class procedure AddInputCharacter(const AChar: UCS4Char); overload; inline; static;
    class procedure AddInputCharacters(const AChars: PUTF8Char); overload; inline; static;
    class procedure AddInputCharacters(const AChars: String); overload; inline; static;
  end;

implementation

uses
  {$IFDEF SOKOL_MEM_TRACK}
  Neslib.Sokol.MemTrack,
  {$ENDIF}
  Neslib.Sokol.Utils,
  Neslib.ImGui;

{ _TImGuiLogItemHelper }

function _TImGuiLogItemHelper.ToString: String;
const
  STRINGS: array [TImGuiLogItem] of String = (
    'Ok',
    'memory allocation failed',
    'internal vertex/index buffer overflow (increase TSokolImGuiDesc.MaxVertices)');
begin
  Result := STRINGS[Self];
end;

{ TSokolImGuiDesc }

class function TSokolImGuiDesc.Create: TSokolImGuiDesc;
begin
  Result.Init;
end;

procedure TSokolImGuiDesc.DefaultLogger(const ALevel: TLogLevel;
  const AItem: TImGuiLogItem; const AMessage: String; const ALineNr: Integer);
begin
  _LogDefault(ALevel, Ord(AItem), AMessage, ALineNr);
end;

procedure TSokolImGuiDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

class procedure TSokolImGuiDesc.LogCallback(const ATag: PUTF8Char; ALogLevel,
  ALogItemId: UInt32; const AMessageOrNull: PUTF8Char; ALineNr: UInt32;
  const AFilenameOrNull: PUTF8Char; AUserData: Pointer);
begin
  Assert(Assigned(GLogger));
  var Msg: String;
  if (ALogItemId <= Cardinal(Ord(High(TImGuiLogItem)))) then
    Msg := TImGuiLogItem(ALogItemId).ToString
  else
    Msg := String(UTF8String(AMessageOrNull));

  GLogger(TLogLevel(ALogLevel), TImGuiLogItem(ALogItemId), Msg, ALineNr);
end;

{ TSokolImGuiFrameDesc }

class function TSokolImGuiFrameDesc.Create: TSokolImGuiFrameDesc;
begin
  Result.Init;
end;

procedure TSokolImGuiFrameDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TSokolImGuiFontTexDesc }

class function TSokolImGuiFontTexDesc.Create: TSokolImGuiFontTexDesc;
begin
  Result.Init;
end;

function TSokolImGuiFontTexDesc.GetMagFilter: TFilter;
begin
  Result := TFilter(FHandle.mag_filter);
end;

function TSokolImGuiFontTexDesc.GetMinFilter: TFilter;
begin
  Result := TFilter(FHandle.min_filter);
end;

procedure TSokolImGuiFontTexDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TSokolImGuiFontTexDesc.SetMagFilter(const AValue: TFilter);
begin
  FHandle.mag_filter := Ord(AValue);
end;

procedure TSokolImGuiFontTexDesc.SetMinFilter(const AValue: TFilter);
begin
  FHandle.min_filter := Ord(AValue);
end;

{ SokolImGui }

class procedure SokolImGui.AddFocusEvent(const AFocus: Boolean);
begin
  _simgui_add_focus_event(AFocus);
end;

class procedure SokolImGui.AddInputCharacter(const AChar: UCS4Char);
begin
  _simgui_add_input_character(AChar);
end;

class procedure SokolImGui.AddInputCharacter(const AChar: Char);
begin
  _simgui_add_input_character(Ord(AChar));
end;

class procedure SokolImGui.AddInputCharacters(const AChars: String);
begin
  _simgui_add_input_characters_utf8(ImGui.ToUtf8(AChars));
end;

class procedure SokolImGui.AddInputCharacters(const AChars: PUTF8Char);
begin
  _simgui_add_input_characters_utf8(AChars);
end;

class procedure SokolImGui.AddKeyEvent(const AImGuiKey: Integer;
  const ADown: Boolean);
begin
  _simgui_add_key_event(AImGuiKey, ADown);
end;

class procedure SokolImGui.AddMouseButtonEvent(const AMouseButton: Integer;
  const ADown: Boolean);
begin
  _simgui_add_mouse_button_event(AMouseButton, ADown);
end;

class procedure SokolImGui.AddMousePosEvent(const AX, AY: Single);
begin
  _simgui_add_mouse_pos_event(AX, AY);
end;

class procedure SokolImGui.AddMouseWheelEvent(const AWheelX, AWheelY: Single);
begin
  _simgui_add_mouse_wheel_event(AWheelX, AWheelY);
end;

class procedure SokolImGui.AddTouchButtonEvent(const AMouseButton: Integer;
  const ADown: Boolean);
begin
  _simgui_add_touch_button_event(AMouseButton, ADown);
end;

class procedure SokolImGui.AddTouchPosEvent(const AX, AY: Single);
begin
  _simgui_add_touch_pos_event(AX, AY);
end;

class function SokolImGui.HandleEvent(const AEvent: _Psapp_event): Boolean;
begin
  Result := _simgui_handle_event(AEvent);
end;

class function SokolImGui.ImTextureId(const ATexView: TView;
  const ASmp: TSampler): UInt64;
begin
  Result := _simgui_imtextureid_with_sampler(_sg_view(ATexView), _sg_sampler(ASmp));
end;

class function SokolImGui.ImTextureId(const ATexView: TView): UInt64;
begin
  Result := _simgui_imtextureid(_sg_view(ATexView));
end;

class function SokolImGui.MapKeyCode(const AKeyCode: Integer): Integer;
begin
  Result := _simgui_map_keycode(AKeyCode);
end;

class procedure SokolImGui.NewFrame(const ADesc: TSokolImGuiFrameDesc);
begin
  _simgui_new_frame(@ADesc.FHandle);
end;

class procedure SokolImGui.Render;
begin
  _simgui_render;
end;

class function SokolImGui.SamplerFromImTextureId(
  const AImTexID: UInt64): TSampler;
begin
  Result := TSampler(_simgui_sampler_from_imtextureid(AImTexID));
end;

class procedure SokolImGui.Setup(const ADesc: TSokolImGuiDesc);
begin
  var Desc: _simgui_desc_t;
  FillChar(Desc, SizeOf(Desc), 0);

  Desc.max_vertices := ADesc.MaxVertices;
  Desc.color_format := Ord(ADesc.ColorFormat);
  Desc.depth_format := Ord(ADesc.DepthFormat);
  Desc.sample_count := ADesc.SampleCount;

  if (ADesc.IniFilename <> '') then
    Desc.ini_filename := PUTF8Char(UTF8String(ADesc.IniFilename));

  Desc.no_default_font := ADesc.NoDefaultFont;
  Desc.disable_paste_override := ADesc.DisablePasteOverride;
  Desc.disable_set_mouse_cursor := ADesc.DisableSetMouseCursor;
  Desc.disable_windows_resize_from_edges := ADesc.DisableWindowsResizeFromEdges;
  Desc.write_alpha_channel := ADesc.WriteAlphaChannel;

  {$IFDEF SOKOL_MEM_TRACK}
  Desc.allocator.alloc_fn := _MemTrackAlloc;
  Desc.allocator.free_fn := _MemTrackFree;
  {$ELSE}
  if (ADesc.UseDelphiMemoryManager) then
  begin
    Desc.allocator.alloc_fn := _AllocCallback;
    Desc.allocator.free_fn := _FreeCallback;
  end;
  {$ENDIF}

  if Assigned(ADesc.Logger) then
  begin
    TSokolImGuiDesc.GLogger := ADesc.Logger;
    Desc.logger.func := ADesc.LogCallback;
  end
  else
    Desc.logger.func := nil;

  _simgui_setup(@Desc);
end;

class procedure SokolImGui.Shutdown;
begin
  _simgui_shutdown;
end;

class function SokolImGui.TextureViewFromImTextureId(
  const AImTexID: UInt64): TView;
begin
  Result := TView(_simgui_texture_view_from_imtextureid(AImTexID));
end;

end.

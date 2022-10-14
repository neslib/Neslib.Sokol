unit Neslib.Sokol.ImGui;
{ Drop-in Dear ImGui renderer/event-handler Neslib.Sokol.Gfx.

  For a user guide, check out the Neslib.Sokol.ImGui.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.ImGui.md }

interface

uses
  Neslib.Sokol.Api,
  Neslib.Sokol.Gfx;

type
  { Configurations settings for SokolImGui }
  TSokolImGuiDesc = record
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
  public
    { Initializes with default values }
    class function Create: TSokolImGuiDesc; inline; static;
    procedure Init;
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

    { Converts a Neslib.Sokol.App TKeyCode to an ImGui key code.

      Parameters:
        AKeyCode: the ordinal value of the TKeyCode enum. (Note that this
          parameter is *not* of type TKeyCode to avoid a dependency on the
          Neslib.Sokol.App unit.

      Returns:
        The corresponding ImGui keycode }
    class function MapKeyCode(const AKeyCode: Integer): Integer; inline; static;
  end;

implementation

uses
  {$IFDEF SOKOL_MEM_TRACK}
  Neslib.Sokol.MemTrack;
  {$ELSE}
  Neslib.Sokol.Utils;
  {$ENDIF}

{ TSokolImGuiDesc }

class function TSokolImGuiDesc.Create: TSokolImGuiDesc;
begin
  Result.Init;
end;

procedure TSokolImGuiDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
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

{ SokolImGui }

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
  Desc.allocator.alloc := _MemTrackAlloc;
  Desc.allocator.free := _MemTrackFree;
  {$ELSE}
  if (ADesc.UseDelphiMemoryManager) then
  begin
    Desc.allocator.alloc := _AllocCallback;
    Desc.allocator.free := _FreeCallback;
  end;
  {$ENDIF}

  _simgui_setup(@Desc);
end;

class procedure SokolImGui.Shutdown;
begin
  _simgui_shutdown;
end;

end.

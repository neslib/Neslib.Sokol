unit Neslib.Sokol.Gfx.ImGui;
{ Debug-inspection UI for Neslib.Sokol.Gfx using Dear ImGui

  For a user guide, check out the Neslib.Sokol.Gfx.ImGui.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.Gfx.ImGui.md }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.Sokol.Api;

type
  { A context for drawing a Debug UI using Dear ImGui }
  TImGuiDebugContext = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_imgui_t;
    function GetBuffersOpen: PBoolean; inline;
    function GetCapabilitiesOpen: PBoolean; inline;
    function GetCaptureOpen: PBoolean; inline;
    function GetImagesOpen: PBoolean; inline;
    function GetPassesOpen: PBoolean; inline;
    function GetPipelinesOpen: PBoolean; inline;
    function GetShadersOpen: PBoolean; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a new context.

      Parameters:
        AUseDelphiMemoryManager: (optional) whether to use Delphi's memory
          manager (True) or Sokol's internal one (False, default).
          When SOKOL_MEM_TRACK is defined, it always uses Delphi's memory
          manager. }
    procedure Init(const AUseDelphiMemoryManager: Boolean = False);

    { Frees the context }
    procedure Free;

    { Draws the entire Debug UI.
      This is an all-on-one method that internally uses all the methods below. }
    procedure Draw;

    { These methods call individual window content (to integrate with your own
      windows). Don't use this if you use the all-in-one Draw method. }
    procedure DrawBuffersContent; inline;
    procedure DrawImagesContent; inline;
    procedure DrawShadersContent; inline;
    procedure DrawPipelinesContent; inline;
    procedure DrawPassesContent; inline;
    procedure DrawCaptureContent; inline;
    procedure DrawCapabilitiesContent; inline;

    { These methods call individual windows with content.
      Don't use this if you use the all-in-one Draw method. }
    procedure DrawBuffersWindow; inline;
    procedure DrawImagesWindow; inline;
    procedure DrawShadersWindow; inline;
    procedure DrawPipelinesWindow; inline;
    procedure DrawPassesWindow; inline;
    procedure DrawCaptureWindow; inline;
    procedure DrawCapabilitiesWindow; inline;

    { Whether individual debug windows should be opened. All default to False. }
    property BuffersOpen: PBoolean read GetBuffersOpen;
    property ImagesOpen: PBoolean read GetImagesOpen;
    property ShadersOpen: PBoolean read GetShadersOpen;
    property PipelinesOpen: PBoolean read GetPipelinesOpen;
    property PassesOpen: PBoolean read GetPassesOpen;
    property CaptureOpen: PBoolean read GetCaptureOpen;
    property CapabilitiesOpen: PBoolean read GetCapabilitiesOpen;
  end;
  PImGuiDebugContext = ^TImGuiDebugContext;

implementation

uses
  {$IFDEF SOKOL_MEM_TRACK}
  Neslib.Sokol.MemTrack;
  {$ELSE}
  Neslib.Sokol.Utils;
  {$ENDIF}

{ TImGuiDebugContext }

procedure TImGuiDebugContext.Draw;
begin
  _sg_imgui_draw(@FHandle);
end;

procedure TImGuiDebugContext.DrawBuffersContent;
begin
  _sg_imgui_draw_buffers_content(@FHandle);
end;

procedure TImGuiDebugContext.DrawBuffersWindow;
begin
  _sg_imgui_draw_buffers_window(@FHandle);
end;

procedure TImGuiDebugContext.DrawCapabilitiesContent;
begin
  _sg_imgui_draw_capabilities_content(@FHandle);
end;

procedure TImGuiDebugContext.DrawCapabilitiesWindow;
begin
  _sg_imgui_draw_capabilities_window(@FHandle);
end;

procedure TImGuiDebugContext.DrawCaptureContent;
begin
  _sg_imgui_draw_capture_content(@FHandle);
end;

procedure TImGuiDebugContext.DrawCaptureWindow;
begin
  _sg_imgui_draw_capture_window(@FHandle);
end;

procedure TImGuiDebugContext.DrawImagesContent;
begin
  _sg_imgui_draw_images_content(@FHandle);
end;

procedure TImGuiDebugContext.DrawImagesWindow;
begin
  _sg_imgui_draw_images_window(@FHandle);
end;

procedure TImGuiDebugContext.DrawPassesContent;
begin
  _sg_imgui_draw_passes_content(@FHandle);
end;

procedure TImGuiDebugContext.DrawPassesWindow;
begin
  _sg_imgui_draw_passes_window(@FHandle);
end;

procedure TImGuiDebugContext.DrawPipelinesContent;
begin
  _sg_imgui_draw_pipelines_content(@FHandle);
end;

procedure TImGuiDebugContext.DrawPipelinesWindow;
begin
  _sg_imgui_draw_pipelines_window(@FHandle);
end;

procedure TImGuiDebugContext.DrawShadersContent;
begin
  _sg_imgui_draw_shaders_content(@FHandle);
end;

procedure TImGuiDebugContext.DrawShadersWindow;
begin
  _sg_imgui_draw_shaders_window(@FHandle);
end;

procedure TImGuiDebugContext.Free;
begin
  _sg_imgui_discard(@FHandle);
end;

function TImGuiDebugContext.GetBuffersOpen: PBoolean;
begin
  Result := @FHandle.buffers.open;
end;

function TImGuiDebugContext.GetCapabilitiesOpen: PBoolean;
begin
  Result := @FHandle.caps.open;
end;

function TImGuiDebugContext.GetCaptureOpen: PBoolean;
begin
  Result := @FHandle.capture.open;
end;

function TImGuiDebugContext.GetImagesOpen: PBoolean;
begin
  Result := @FHandle.images.open;
end;

function TImGuiDebugContext.GetPassesOpen: PBoolean;
begin
  Result := @FHandle.passes.open;
end;

function TImGuiDebugContext.GetPipelinesOpen: PBoolean;
begin
  Result := @FHandle.pipelines.open;
end;

function TImGuiDebugContext.GetShadersOpen: PBoolean;
begin
  Result := @FHandle.shaders.open;
end;

procedure TImGuiDebugContext.Init(const AUseDelphiMemoryManager: Boolean);
begin
  FillChar(Self, SizeOf(Self), 0);

  var Desc: _sg_imgui_desc_t;
  FillChar(Desc, SizeOf(Desc), 0);
  {$IFDEF SOKOL_MEM_TRACK}
  Desc.allocator.alloc := _MemTrackAlloc;
  Desc.allocator.free := _MemTrackFree;
  {$ELSE}
  if (AUseDelphiMemoryManager) then
  begin
    Desc.allocator.alloc := _AllocCallback;
    Desc.allocator.free := _FreeCallback;
  end;
  {$ENDIF}
  _sg_imgui_init(@FHandle, @Desc);
end;

end.

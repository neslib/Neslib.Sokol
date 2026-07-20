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
  { Options to initialize TGfxImGui }
  TGfxImGuiDesc = record
  public
    { Whether to use Delphi's memory manager instead of the default memory
      manager used by the Sokol library.
      When SOKOL_MEM_TRACK is defined, it always uses Delphi's memory manager.
      Default: False }
    UseDelphiMemoryManager: Boolean;
  public
    { Initializes with default values }
    class function Create: TGfxImGuiDesc; inline; static;
    procedure Init;
  end;

type
  { Debug-inspection UI for Neslib.Sokol.Gfx using Dear ImGui }
  TGfxImGui = record
  public
    class procedure Setup(const ADesc: TGfxImGuiDesc); inline; static;
    class procedure Shutdown; inline; static;

    class procedure Draw; inline; static;
    class procedure DrawMenu(const ATitle: PUTF8Char); inline; static;

    class procedure DrawBufferWindowContent; inline; static;
    class procedure DrawImageWindowContent; inline; static;
    class procedure DrawSamplerWindowContent; inline; static;
    class procedure DrawShaderWindowContent; inline; static;
    class procedure DrawPipelineWindowContent; inline; static;
    class procedure DrawViewWindowContent; inline; static;
    class procedure DrawCaptureWindowContent; inline; static;
    class procedure DrawCapabilitiesWindowContent; inline; static;
    class procedure DrawFrameStatsWindowContent; inline; static;

    class procedure DrawBufferWindow(const ATitle: PUTF8Char); inline; static;
    class procedure DrawImageWindow(const ATitle: PUTF8Char); inline; static;
    class procedure DrawSamplerWindow(const ATitle: PUTF8Char); inline; static;
    class procedure DrawShaderWindow(const ATitle: PUTF8Char); inline; static;
    class procedure DrawPipelineWindow(const ATitle: PUTF8Char); inline; static;
    class procedure DrawViewWindow(const ATitle: PUTF8Char); inline; static;
    class procedure DrawCaptureWindow(const ATitle: PUTF8Char); inline; static;
    class procedure DrawCapabilitiesWindow(const ATitle: PUTF8Char); inline; static;
    class procedure DrawFrameStatsWindow(const ATitle: PUTF8Char); inline; static;

    class procedure DrawBufferMenuItem(const ALabel: PUTF8Char); inline; static;
    class procedure DrawImageMenuItem(const ALabel: PUTF8Char); inline; static;
    class procedure DrawSamplerMenuItem(const ALabel: PUTF8Char); inline; static;
    class procedure DrawShaderMenuItem(const ALabel: PUTF8Char); inline; static;
    class procedure DrawPipelineMenuItem(const ALabel: PUTF8Char); inline; static;
    class procedure DrawViewMenuItem(const ALabel: PUTF8Char); inline; static;
    class procedure DrawCaptureMenuItem(const ALabel: PUTF8Char); inline; static;
    class procedure DrawCapabilitiesMenuItem(const ALabel: PUTF8Char); inline; static;
    class procedure DrawFrameStatsMenuItem(const ALabel: PUTF8Char); inline; static;

  end;

implementation

uses
  {$IFDEF SOKOL_MEM_TRACK}
  Neslib.Sokol.MemTrack;
  {$ELSE}
  Neslib.Sokol.Utils;
  {$ENDIF}

{ TGfxImGuiDesc }

class function TGfxImGuiDesc.Create: TGfxImGuiDesc;
begin
  Result.Init;
end;

procedure TGfxImGuiDesc.Init;
begin
  UseDelphiMemoryManager := False;
end;

{ TGfxImGui }

class procedure TGfxImGui.Draw;
begin
  _sgimgui_draw;
end;

class procedure TGfxImGui.DrawBufferMenuItem(const ALabel: PUTF8Char);
begin
  _sgimgui_draw_buffer_menu_item(ALabel);
end;

class procedure TGfxImGui.DrawBufferWindow(const ATitle: PUTF8Char);
begin
  _sgimgui_draw_buffer_window(ATitle);
end;

class procedure TGfxImGui.DrawBufferWindowContent;
begin
  _sgimgui_draw_buffer_window_content;
end;

class procedure TGfxImGui.DrawCapabilitiesMenuItem(const ALabel: PUTF8Char);
begin
  _sgimgui_draw_capture_menu_item(ALabel);
end;

class procedure TGfxImGui.DrawCapabilitiesWindow(const ATitle: PUTF8Char);
begin
  _sgimgui_draw_capabilities_window(ATitle);
end;

class procedure TGfxImGui.DrawCapabilitiesWindowContent;
begin
  _sgimgui_draw_capabilities_window_content;
end;

class procedure TGfxImGui.DrawCaptureMenuItem(const ALabel: PUTF8Char);
begin
  _sgimgui_draw_capture_menu_item(ALabel);
end;

class procedure TGfxImGui.DrawCaptureWindow(const ATitle: PUTF8Char);
begin
  _sgimgui_draw_capture_window(ATitle);
end;

class procedure TGfxImGui.DrawCaptureWindowContent;
begin
  _sgimgui_draw_capture_window_content;
end;

class procedure TGfxImGui.DrawFrameStatsMenuItem(const ALabel: PUTF8Char);
begin
  _sgimgui_draw_frame_stats_menu_item(ALabel);
end;

class procedure TGfxImGui.DrawFrameStatsWindow(const ATitle: PUTF8Char);
begin
  _sgimgui_draw_frame_stats_window(ATitle);
end;

class procedure TGfxImGui.DrawFrameStatsWindowContent;
begin
  _sgimgui_draw_frame_stats_window_content;
end;

class procedure TGfxImGui.DrawImageMenuItem(const ALabel: PUTF8Char);
begin
  _sgimgui_draw_image_menu_item(ALabel);
end;

class procedure TGfxImGui.DrawImageWindow(const ATitle: PUTF8Char);
begin
  _sgimgui_draw_image_window(ATitle);
end;

class procedure TGfxImGui.DrawImageWindowContent;
begin
  _sgimgui_draw_image_window_content;
end;

class procedure TGfxImGui.DrawMenu(const ATitle: PUTF8Char);
begin
  _sgimgui_draw_menu(ATitle);
end;

class procedure TGfxImGui.DrawPipelineMenuItem(const ALabel: PUTF8Char);
begin
  _sgimgui_draw_pipeline_menu_item(ALabel);
end;

class procedure TGfxImGui.DrawPipelineWindow(const ATitle: PUTF8Char);
begin
  _sgimgui_draw_pipeline_window(ATitle)
end;

class procedure TGfxImGui.DrawPipelineWindowContent;
begin
  _sgimgui_draw_pipeline_window_content;
end;

class procedure TGfxImGui.DrawSamplerMenuItem(const ALabel: PUTF8Char);
begin
  _sgimgui_draw_sampler_menu_item(ALabel);
end;

class procedure TGfxImGui.DrawSamplerWindow(const ATitle: PUTF8Char);
begin
  _sgimgui_draw_sampler_window(ATitle);
end;

class procedure TGfxImGui.DrawSamplerWindowContent;
begin
  _sgimgui_draw_sampler_window_content;
end;

class procedure TGfxImGui.DrawShaderMenuItem(const ALabel: PUTF8Char);
begin
  _sgimgui_draw_shader_menu_item(ALabel);
end;

class procedure TGfxImGui.DrawShaderWindow(const ATitle: PUTF8Char);
begin
  _sgimgui_draw_shader_window(ATitle);
end;

class procedure TGfxImGui.DrawShaderWindowContent;
begin
  _sgimgui_draw_shader_window_content;
end;

class procedure TGfxImGui.DrawViewMenuItem(const ALabel: PUTF8Char);
begin
  _sgimgui_draw_view_menu_item(ALabel);
end;

class procedure TGfxImGui.DrawViewWindow(const ATitle: PUTF8Char);
begin
  _sgimgui_draw_view_window(ATitle);
end;

class procedure TGfxImGui.DrawViewWindowContent;
begin
  _sgimgui_draw_view_window_content;
end;

class procedure TGfxImGui.Setup(const ADesc: TGfxImGuiDesc);
begin
  var Desc: _sgimgui_desc_t;
  FillChar(Desc, SizeOf(Desc), 0);
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
  _sgimgui_setup(@Desc);
end;

class procedure TGfxImGui.Shutdown;
begin
  _sgimgui_shutdown;
end;

end.

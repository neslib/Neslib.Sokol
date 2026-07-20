unit Neslib.Sokol.App.ImGui;
{ Debug-inspection UI for Neslib.Sokol.App using Dear ImGui

  For a user guide, check out the Neslib.Sokol.App.ImGui.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.App.ImGui.md }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.Sokol.App;

type
  TAppImGui = record // static
  public
    class procedure Setup; inline; static;
    class procedure Shutdown; inline; static;

    class procedure TrackFrame; inline; static;
    class procedure TrackEvent(const AEvent: TEvent); inline; static;
    class procedure Draw; inline; static;
    class procedure DrawMenu(const ATitle: PUTF8Char); inline; static;

    class procedure DrawHudWindowContent; inline; static;
    class procedure DrawPublicStateWindowContent; inline; static;
    class procedure DrawEventWindowContent; inline; static;

    class procedure DrawHudWindow(const ATitle: PUTF8Char); inline; static;
    class procedure DrawPublicStateWindow(const ATitle: PUTF8Char); inline; static;
    class procedure DrawEventWindow(const ATitle: PUTF8Char); inline; static;

    class procedure DrawHudMenuItem(const ALabel: PUTF8Char); inline; static;
    class procedure DrawPublicStateMenuItem(const ALabel: PUTF8Char); inline; static;
    class procedure DrawEventMenuItem(const ALabel: PUTF8Char); inline; static;
  end;

implementation

uses
  Neslib.Sokol.Api;

{ TAppImGui }

class procedure TAppImGui.Draw;
begin
  _sappimgui_draw;
end;

class procedure TAppImGui.DrawEventMenuItem(const ALabel: PUTF8Char);
begin
  _sappimgui_draw_event_menu_item(ALabel);
end;

class procedure TAppImGui.DrawEventWindow(const ATitle: PUTF8Char);
begin
  _sappimgui_draw_event_window(ATitle);
end;

class procedure TAppImGui.DrawEventWindowContent;
begin
  _sappimgui_draw_event_window_content;
end;

class procedure TAppImGui.DrawHudMenuItem(const ALabel: PUTF8Char);
begin
  _sappimgui_draw_hud_menu_item(ALabel);
end;

class procedure TAppImGui.DrawHudWindow(const ATitle: PUTF8Char);
begin
  _sappimgui_draw_hud_window(ATitle);
end;

class procedure TAppImGui.DrawHudWindowContent;
begin
  _sappimgui_draw_hud_window_content;
end;

class procedure TAppImGui.DrawMenu(const ATitle: PUTF8Char);
begin
  _sappimgui_draw_menu(ATitle);
end;

class procedure TAppImGui.DrawPublicStateMenuItem(const ALabel: PUTF8Char);
begin
  _sappimgui_draw_publicstate_menu_item(ALabel);
end;

class procedure TAppImGui.DrawPublicStateWindow(const ATitle: PUTF8Char);
begin
  _sappimgui_draw_publicstate_window(ATitle);
end;

class procedure TAppImGui.DrawPublicStateWindowContent;
begin
  _sappimgui_draw_publicstate_window_content;
end;

class procedure TAppImGui.Setup;
begin
  _sappimgui_setup;
end;

class procedure TAppImGui.Shutdown;
begin
  _sappimgui_shutdown;
end;

class procedure TAppImGui.TrackEvent(const AEvent: TEvent);
begin
  _sappimgui_track_event(@AEvent);
end;

class procedure TAppImGui.TrackFrame;
begin
  _sappimgui_track_frame;
end;

end.

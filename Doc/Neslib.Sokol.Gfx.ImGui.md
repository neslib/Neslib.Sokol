# Neslib.Sokol.Gfx.ImGui

Debug-inspection UI for [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md) using Dear ImGui.

This is a light-weight OOP layer on top of [sokol_gfx_imgui.h](https://github.com/floooh/sokol).

## Step by Step
* Call `TGfxImGui.Setup` with a description record:
  
  ```pascal
  var Desc := TGfxImGuiDesc.Create;
  Desc.UseDelphiMemoryManager := True;
  TGfxImGui.Setup(Desc);
  ```

  `TGfxImGuiDesc` currently only has one field: `UseDelphiMemoryManager` to indicate whether to use Delphi's memory manager instead of Sokol's internal one.
  
* Somewhere in the per-frame code call:

  ```pascal
  TGfxImGui.Draw;
  ```

  This won't draw anything yet, since no windows are open.

* Call the convenience method `TGfxImGui.DrawMenu` to render a menu which allows to open/close the provided debug windows:
  
  ```pascal
  TGfxImGui.DrawMenu('Neslib.Sokol.Gfx');
  ```
  
* Alternatively draw the individual single menu items via:
  
  ```pascal
  if ImGui.BeginMainMenuBar then
  begin
    if ImGui.BeginMenu('Neslib.Sokol.Gfx') then
    begin
      TGfxImGui.DrawBufferWindowMenuItem('Buffers');
      TGfxImGui.DrawImageWindowMenuItem('Images');
      TGfxImGui.DrawSamplerWindowMenuItem('Samplers');
      TGfxImGui.DrawShaderWindowMenuItem('Shaders');
      TGfxImGui.DrawPipelineWindowMenuItem('Pipelines');
      TGfxImGui.DrawViewWindowMenuItem('View');
      TGfxImGui.DrawCaptureWindowMenuItem('Calls');
      TGfxImGui.DrawCapabilitiesWindowMenuItem('Capabilities');
      TGfxImGui.DrawFrameStatsWindowMenuItem('Frame Stats');
      ImGui.EndMenu;
    end;
  end;
  ```
  
* Before application shutdown, call:
  
  ```pascal
  TGfxImGui.Shutdown;
  ```
  
  This is not strictly necessary because the application exits anyway, but not doing this may trigger memory leak detection tools.
  
* Finally, your application needs an ImGui renderer, you can either provide your own, or drop in the [Neslib.Sokol.ImGui](Neslib.Sokol.ImGui.md) unit.

Alternative Drawing Methods
---------------------------
Instead of the convenient but all-in-one `TGfxImGui.Draw` method, you can also use the following granular functions which might allow better integration with your existing UI.

The following methods only render the window *content* (so you can integrate the UI into you own windows):

* `DrawBufferWindowContent`
* `DrawImageWindowContent`
* `DrawSamplerWindowContent`
* `DrawShaderWindowContent`
* `DrawPipelineWindowContent`
* `DrawViewWindowContent`
* `DrawCapturWindowContent`
* `DrawCapabilitiesWindowContent`
* `DrawFrameStatsWindowContent`

And these are the 'full window' drawing functions:

* `DrawBufferWindow(const ATitle: PUTF8Char)`
* `DrawImageWindow(const ATitle: PUTF8Char)`
* `DrawSamplerWindow(const ATitle: PUTF8Char)`
* `DrawShaderWindow(const ATitle: PUTF8Char)`
* `DrawPipelineWindow(const ATitle: PUTF8Char)`
* `DrawViewWindow(const ATitle: PUTF8Char)`
* `DrawCaptureWindow(const ATitle: PUTF8Char)`
* `DrawCapabilitiesWindow(const ATitle: PUTF8Char)`
* `DrawFrameStatsWindow(const ATitle: PUTF8Char)`

To draw the individual menu items:

* `DrawBufferMenuItem(const ALabel: PUTF8Char)`
* `DrawImageMenuItem(const ALabel: PUTF8Char)`
* `DrawSamplerMenuItem(const ALabel: PUTF8Char)`
* `DrawShaderMenuItem(const ALabel: PUTF8Char)`
* `DrawPipelineMenuItem(const ALabel: PUTF8Char)`
* `DrawViewMenuItem(const ALabel: PUTF8Char)`
* `DrawCaptureMenuItem(const ALabel: PUTF8Char)`
* `DrawCapabilitiesMenuItem(const ALabel: PUTF8Char)`
* `DrawFrameStatsMenuItem(const ALabel: PUTF8Char)`
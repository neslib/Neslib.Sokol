# Neslib.Sokol.Gfx.ImGui

Debug-inspection UI for [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md) using Dear ImGui.

This is a light-weight OOP layer on top of [sokol_gfx_imgui.h](https://github.com/floooh/sokol).

## Step by Step
* Create an `TImGuiContext` record (which must be preserved between frames) and initialize it with:
  
  ```pascal
  var Context := TImGuiContext.Create;
  ```
  
  This method has an optional `Boolean` parameter that you can set to `True` to use Delphi's memory manager instead of Sokol's internal one.

* Somewhere in the per-frame code call:

  ```pascal
  Context.Draw;
  ```

  This won't draw anything yet, since no windows are open.

* Open and close windows directly by setting the following properties in the `TImGuiContext` record:
  
  ```pascal
    Context.BuffersOpen^ := True;
    Context.ImagesOpen^ := True;
    Context.ShadersOpen^ := True;
    Context.PipelinesOpen^ := True;
    Context.PassesOpen^ := True;
    Context.CaptureOpen^ := True;
  ```
  
  For instance, to control the window visibility through menu items, the following code can be used:

  ```pascal
    if ImGui.BeginMainMenuBar then
    begin
      if ImGui.BeginMenu('Neslib.Sokol.Gfx') then
      begin
        ImGui.MenuItem('Buffers', '', Context.BuffersOpen);
        ImGui.MenuItem('Images', '', Context.ImagesOpen);
        ImGui.MenuItem('Shaders', '', Context.ShadersOpen);
        ImGui.MenuItem('Pipelines', '', Context.PipelinesOpen);
        ImGui.MenuItem('Passes', '', Context.PassesOpen);
        ImGui.MenuItem('Calls', '', Context.CaptureOpen);
      end;
    end;
  ```
  
* Before application shutdown, call:

  ```pascal
  Context.Free;
  ```

  This is not strictly necessary because the application exits anyway, but not doing this may trigger memory leak detection tools.

* Finally, your application needs an ImGui renderer, you can either provide your own, or drop in the [Neslib.Sokol.ImGui](Neslib.Sokol.ImGui.md) unit.

Alternative Drawing Methods
---------------------------
Instead of the convenient, but all-in-one `TImGuiContext.Draw` method, you can also use the following granular functions which might allow better integration with your existing UI.

The following methods only render the window *content* (so you can integrate the UI into you own windows):

* `DrawBuffersContent`
* `DrawImagesContent`
* `DrawShadersContent`
* `DrawPipelinesContent`
* `DrawPassesContent`
* `DrawCaptureContent`
* `DrawCapabilitiesContent`

And these are the 'full window' drawing functions:

* `DrawBuffersWindow`
* `DrawImagesWindow`
* `DrawShadersWindow`
* `DrawPipelinesWindow`
* `DrawPassesWindow`
* `DrawCaptureWindow`
* `DrawCapabilitiesWindow`

Finer-grained drawing functions may be moved to the public API in the future as needed.
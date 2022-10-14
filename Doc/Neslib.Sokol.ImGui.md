# Neslib.Sokol.ImGui

Drop-in Dear ImGui renderer/event-handler for [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md).

This is a light-weight OOP layer on top of [sokol_imgui.h](https://github.com/floooh/sokol).

## Feature Overview

This unit implements the initialization, rendering and event-handling code for [Dear ImGui](https://github.com/ocornut/imgui) on top of [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md) and [Neslib.Sokol.App](Neslib.Sokol.App.md).

This unit is not thread-safe, all calls must be made from the same thread where [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md) is running.

## How-to

* To initialize, call:

  ```pascal
  SokolImGui.Setup(const ADesc: TSokolImGuiDesc);
  ```

  This will initialize Dear ImGui and create [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md) resources (two buffers for vertices and indices, a font texture and a pipeline-state-object).

  Use the following `TSokolImGuiDesc` fields to configure behavior:

  * `MaxVertices: Integer`: The maximum number of vertices used for UI rendering, default is 65536. This unit will use this to compute the size of the vertex- and index-buffers.

  * `ColorFormat: TPixelFormat`: The color pixel format of the render pass where the UI will be rendered. The default matches [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md)'s default pass.

  * `DepthFormat: TPixelFormat`: The depth-buffer pixel format of the render pass where the UI will be rendered. The default matches [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md)'s default pass depth format.

  * `SampleCount: Integer`: The MSAA sample-count of the render pass where the UI will be rendered. The default matches [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md)'s  default pass sample count.

  * `IniFilename: String`: Sets this path as `ImGui.GetIO.IniFilename` where ImGui will store and load UI persistency data. By default this is empty, so that Dear ImGui will not preserve state between sessions (and also won't do any filesystem calls). Also see the ImGui functions:

    - `LoadIniSettingsFromMemory`
    - `SaveIniSettingsFromMemory`

    These functions give you explicit control over loading and saving UI state while using your own filesystem wrapper functions (in this case keep `IniFilename` empty).

  * `NoDefaultFont: Boolean`: Set this to `True` if you don't want to use ImGui's default font. In this case you need to initialize the font yourself after `SokolImGui.Setup` is called.

  * `DisablePasteOverride: Boolean`: If set to `True`, this unit will not 'emulate' a Dear ImGui clipboard paste action on `TApplication.ClipboardPasted` event. In general, copy/paste support isn't properly fleshed out in this unit yet.

  * `DisableSetMouseCursor: Boolean`: If `True`, this unit will not control the mouse cursor type by using `TApplication.MouseCursor`.

  * `DisableWindowsResizeFromEdges: Boolean`: If `True`, windows can only be resized from the bottom right corner. The default is `False`, meaning windows can be resized from edges.

  * `WriteAlphaChannel: Boolean`: Set this to `True` if you want alpha values written to the framebuffer. By default this behavior is disabled.

  * `UseDelphiMemoryManager: Boolean`: Set to `True` to use Delphi's memory manager instead of Sokol's internal one.

* At the start of a frame, call:

  ```pascal
  SokolImGui.NewFrame(const ADesc: TSokolImGuiFrameDesc);
  ```

  Use the following `TSokolImGuiFrameDesc` fields to configure behaviour:

  * `Width and Height: Integer`: The dimensions of the rendering surface, passed to `ImGui.GetIO.DisplaySize`.
  * `DeltaTime: Double`: The frame duration passed to `ImGui.GetIO.DeltaTime`.
  * `DpiScale: Single`: The current DPI scale factor, if this is left zero-initialized, 1.0 will be used instead. Typical values for `DpiScale` are >= 1.0.

  For example, if you are using [Neslib.Sokol.App](Neslib.Sokol.App.md) to render to the default framebuffer:

  ```pascal
    Desc.Width := TApplication.FramebufferWidth;
    Desc.Height := TApplication.FramebufferHeight;
    Desc.DeltaTime := TApplication.FrameDuration;
    Desc.DpiScale := TApplication.DpiScale;
    SokolImGui.NewFrame(Desc);
  ```

* At the end of the frame, before `TGfx.EndPass` where you want to render the UI, call:

  ```pascal
    SokolImGui.Render;
  ```

  This will first call `ImGui.Render`, and then render ImGui's draw list through [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md).

* If you're using [Neslib.Sokol.App](Neslib.Sokol.App.md), then you should pass events to SokolImGui by calling:

  ```pascal
    var EventHandler := SokolImGui.GetNativeEventHandler;
    TApplication.SetNativeEventHandler(EventHandler);
  ```

  If you want to use the ImGui functions for checking if a key is pressed (e.g. `ImGui.IsKeyPressed`) the following helper function to map a `TKeyCode`
  to an ImGuiKey value may be useful:

  ```pascal
    function SokolImGui.MapKeyCode(const AKeyCode: Integer): Integer;
  ```

  Where `AKeyCode` is the ordinal value of `TKeyCode` (e.g. `Ord(TKeyCode.*)`).

* Finally, on application shutdown, call:

    ```pascal
    SokolImGui.Shutdown;
    ```
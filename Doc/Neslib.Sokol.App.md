# Neslib.Sokol.App

This is a light-weight OOP layer on top of [sokol_app.h](https://github.com/floooh/sokol).

It can be used as an entry point for cross-platform applications that do *not* use Delphi's FireMonkey framework.

## Feature Overview
This unit provides a minimalistic cross-platform API which implements the 'application-wrapper' parts of a 3D application:

* a common application entry function
* creates a window and 3D-API context/device with a 'default framebuffer'
* makes the rendered frame visible
* provides keyboard-, mouse- and low-level touch-events
* platforms: Windows, MacOS, iOS, Android
* 3D-APIs: D3D11, Metal, GLES-2, GLES-3

This unit does not have any dependencies and can be used with your own rendering code or in combination with [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md) for rendering. You should *not* use this unit inside a VCL or FMX application, since this unit provides its own application loop. You should also not use any VCL or FMX units if your Sokol application.

If you plan to use [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md) (which you probably want), then you need the [FastMath](https://github.com/neslib/FastMath) library. Make sure the FastMath\FastMath subdirectory is in your Delphi library path or add it to the search path of your Sokol projects.

## Feature/Platform Matrix

|                 | Windows | macOS  | iOS  | Android |
| --------------- | ------- | ------ | ---- | ------- |
| GLES-2          | ---     | ---    | ---  | YES     |
| GLES-3          | ---     | ---    | ---  | YES     |
| Metal           | ---     | YES    | YES  | ---     |
| D3D11           | YES     | ---    | ---  | ---     |
| KeyDown         | YES     | YES    | SOME | TODO    |
| KeyUp           | YES     | YES    | SOME | TODO    |
| KeyChar         | YES     | YES    | YES  | TODO    |
| MouseDown       | YES     | YES    | ---  | ---     |
| MouseUp         | YES     | YES    | ---  | ---     |
| MouseScroll     | YES     | YES    | ---  | ---     |
| MouseMove       | YES     | YES    | ---  | ---     |
| MouseEnter      | YES     | YES    | ---  | ---     |
| MouseLeave      | YES     | YES    | ---  | ---     |
| TouchesBegan    | ---     | ---    | YES  | YES     |
| TouchedMoved    | ---     | ---    | YES  | YES     |
| TouchesEnded    | ---     | ---    | YES  | YES     |
| ToucesCancelled | ---     | ---    | YES  | YES     |
| Resized         | YES     | YES    | YES  | YES     |
| Iconified       | YES     | YES    | ---  | ---     |
| Restored        | YES     | YES    | ---  | ---     |
| Focused         | YES     | YES    | ---  | ---     |
| Unfocused       | YES     | YES    | ---  | ---     |
| Suspended       | ---     | ---    | YES  | YES     |
| Resumed         | ---     | ---    | YES  | YES     |
| QuitRequested   | YES     | YES    | ---  | ---     |
| IME             | TODO    | TODO?  | ???  | TODO    |
| Key repeat flag | YES     | YES    | ---  | ---     |
| Windowed        | YES     | YES    | ---  | ---     |
| Fullscreen      | YES     | YES    | YES  | YES     |
| Mouse hide      | YES     | YES    | ---  | ---     |
| Mouse lock      | YES     | YES    | ---  | ---     |
| Set cursor type | YES     | YES    | ---  | ---     |
| Screen keyboard | ---     | ---    | YES  | TODO    |
| Swap interval   | YES     | YES    | YES  | TODO    |
| High-DPI        | YES     | YES    | YES  | YES     |
| Clipboard       | YES     | YES    | ---  | ---     |
| MSAA            | YES     | YES    | YES  | YES     |
| Drag'n'drop     | YES     | YES    | ---  | ---     |
| Window icon     | YES     | YES(1) | ---  | ---     |

(1) macOS has no regular window icons, instead the dock icon is changed

## Example
A simple clear-loop sample using Neslib.Sokol.App and [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md):

```pascal
  uses
    Neslib.Sokol.App,
    Neslib.Sokol.Gfx;

  type
    TMyApp = class(TApplication)
    private
      FPassAction: TPassAction;
    protected
      procedure Configure(var AConfig: TAppConfig); override;
      procedure Init; override;
      procedure Frame; override;
      procedure Cleanup; override;
    end;

  procedure TMyApp.Configure(var AConfig: TAppConfig);
  begin
    inherited;
    AConfig.WindowTitle := 'Clear';
    AConfig.Width := 800;
    AConfig.Height := 600;
    ...
  end;

  procedure TMyApp.Init;
  begin
    inherited;
    var Desc := TGfxDesc.Create;
    Desc.Context := Context;
    TGfx.Setup(Desc);

    FPassAction.Colors[0].Init(TAction.Clear, 1, 0, 0);

  end;

  procedure TMyApp.Frame;
  var
    G: Single;
  begin
    G := FPassAction.Colors[0].Val[1] + 0.01;
    if (G > 1) then
      G := 0;
    FPassAction.Colors[0].Val[1] := G;

    TGfx.BeginDefaultPass(FPassAction, Width, Height);
    TGfx.EndPass;
    TGfx.Commit;

  end;

  procedure TMyApp.Cleanup;
  begin
    inherited;
  end;

```

You don't have to use [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md) to use Neslib.Sokol.App; you can use your own or 3rd party rendering backend if you prefer. In that case, you can use `TApplication` properties like `MetalDevice` or `D3D11Device` to access the graphics backend that Neslib.Sokol.App created.

For more examples, take a look at the demo projects in the Samples directory. In particular, the SampleApp unit contains a basic subclass of `TApplication` that is used by all demos.

## Step-by-Step
* The fastest way to get started is to copy an existing Sokol (sample) app and rename and modify it. But if you want to start from scratch, then follow these steps:

* Create a new 2D FireMonkey application.

* Remove the main form from the app.

* Add the Neslib.Sokol.App unit to the project.

* Open the Project Options and navigate to "Building | Delphi Compiler".

* Select the target "All configurations - All platforms" and add the Conditional Define `FM_COLUMN_MAJOR`. This is required for the FastMath matrix calculations to be compatible with Sokol.

* Open the project (.dpr) source and remove almost everything until only the following remains.

  ```pascal
    program Project1;
  
    {$R *.res}
  
    uses
      Neslib.Sokol.App in ...;
  
    begin
    end.
  ```

* Create a new unit with class that derives from `TApplication`. In the text below, we call this call `TMyApp`, but you can give it any name.

* In the project source code, run the application by calling `RunApp` with the name of your class:

  ```pascal
    program Project1;
  
    {$R *.res}
  
    uses
      Neslib.Sokol.App in ...;
  
    begin
      RunApp(TMyApp);
    end.
  ```

* Override the Configure method of your app class to configure the application:

  ```pascal
    procedure TMyApp.Configure(var AConfig: TAppConfig);
    begin
      inherited;
      AConfig.Width := 800;
      AConfig.Height := 600;
      AConfig. ...
    end;
  ```

  There are many more setup parameters, but these are the most important. For a complete list see the `TAppConfig` record declaration below.

  **Do not** call any Sokol functions from inside Configure, since the application will not be initialized at this point.

  The Width and Height settings are the preferred size of the 3D rendering canvas. The actual size may differ from this depending on platform and other circumstances. Also the canvas size may change at any time (for instance when the user resizes the application window, or rotates the mobile device). You can just keep Width and Height zero-initialized to open a default-sized window (what "default-size" exactly means is platform-specific, but usually it's a size that covers most of, but not all, of the display).

* Override any other methods to initialize and cleanup resources, render frames and handle events. All these methods will be called from the same thread, but this may be different from the main thread. Some methods of interest are:

* `TApplication.Init`: This method is called once after the application window, 3D rendering context and swap chain have been created. You typically create your (graphics) resources here. All Sokol functions and properties can be used at this point. The most useful are:

    - `FrameBufferWidth`, `FrameBufferHeight`: the current width and height of the default framebuffer in pixels. This may change from one frame to the next, and it may be different from the initial size provided in the `TAppConfig` record struct.
      
    - `FrameDuration`: the frame duration in seconds averaged over a number of frames to smooth out any jittering spikes.
      
    - `ColorFormat`, `DepthFormat`: the color and depth-stencil pixel formats of the default framebuffer.
      
    - `SampleCount`: the MSAA sample count of the default framebuffer.

    - `UsesGles2`: True if a GLES-2 context has been created. This is useful when a GLES-3 context was requested but is not available so that the app had to fallback to GLES-2.

* `TApplication.Frame`: This is called once per frame (usually called 60 times per second). This is where your application would update most of its state and perform all rendering. Note that the size of the rendering framebuffer might have changed since the frame callback was called last. Use the `FramebufferWidth` and `FramebufferHeight` properties each frame to get the current size.

* `TApplication.Cleanup`: This method is called once right before the application quits. You typically free your (graphics) resources here. This is basically the inverse of the Init method. Note that this method isn't guaranteed to be called on mobile platforms.

* Various event methods like `KeyDown`, `MouseDown`, `TouchesBegan`, `Resized` etc.
  **Note**: Do *not* call any 3D API rendering functions in the event methods, since the 3D API context may not be active when the event is fired (it may work on some platforms and 3D APIs, but not others, and the exact behaviour may change between versions).

## Mouse cursor type and visiblity
You can show and hide the mouse cursor by setting the `MouseCursorVisible` property. Note that hiding the mouse cursor is different and independent from the Mouse/Pointer Lock feature which will also hide the mouse pointer when active (this is described below).

To change the mouse cursor to one of several predefined types, set the `MouseCursor` property. Setting this property to `TMouseCursor.Default` will restore the standard look.

## Mouse Lock (aka Pointer Lock, aka Mouse Capture)
In normal mouse mode, no mouse movement events are reported when the mouse leaves the windows client area or hits the screen border (whether it is one or the other depends on the platform), and the mouse move events (`MouseMove`) contain absolute mouse positions in framebuffer pixels (in the `AX` and `AY` parameters), and relative movement in framebuffer pixels (in the `ADX` and `ADY` parameters).

To get continuous mouse movement (also when the mouse leaves the window client area or hits the screen border), activate mouse-lock mode by setting the `MouseLocked` property to True.

When mouse lock is activated, the mouse pointer is hidden, the reported absolute mouse position (`AX` and `AY` parameters) appears frozen, and the relative mouse movement (`ADX` and `ADY`) no longer has a direct relation to framebuffer pixels but instead uses "raw mouse input" (what "raw mouse input" exactly means also differs by platform).

## Clipboard support
Applications can send and receive UTF-8 encoded text data from and to the system clipboard. By default, clipboard support is disabled and must be enabled at startup via the following `TAppConfig` fields:

* `EnableClipboard`: set to True to enable clipboard support.
* `ClipboardSize`: size of the internal clipboard buffer in bytes.

Enabling the clipboard will dynamically allocate a clipboard buffer for UTF-8 encoded text data of the requested size in bytes, the default size is 8 KB. Strings that don't fit into the clipboard buffer (including the terminating zero) will be silently clipped, so it's important that you provide a big enough clipboard size for your use case.

To send data to the clipboard, set the `ClipboardString` property.

To get data from the clipboard, override the `ClipbaordPasted` method, which has a parameter with the text on the clipboard. This event will be called when:

* macOS: when the Cmd+V key is pressed down
* on all other platforms: when the Ctrl+V key is pressed down

## Drag and Drop Support
Like clipboard support, drag'n'drop support must be explicitly enabled at startup in the `TAppConfig` record by setting `EnableDragDrop` to True.

You can also adjust the maximum number of files that are accepted in a drop operation, and the maximum path length in bytes if needed (through the `MaxDroppedFiles` and `MaxDroppedFilePathLength` properties).

When drag'n'drop is enabled, the `FiledDropped` method will be called whenever the user drops files on the application window. It received the mouse position where the drop happened as well as an array of filenames of the dropped files.

Drag'n'drop caveats:
* if more files are dropped in a single drop-action than `TAppConfig.MaxDroppedFiles`, the additional files will be silently ignored
* if any of the file paths is longer than `TAppConfig.MaxDroppedFilePathLength` (in number of bytes, after UTF-8 encoding) the entire drop operation will be silently ignored (this needs some sort of error feedback in the future)
* no mouse positions are reported while the drag is in process. This may change in the future

Check the DropTest demo app for an example.

## High-DPI rendering
You can set the `TAppConfig.HighDpi` flag during initialization to request a full-resolution framebuffer on HighDPI displays. The default behaviour is `HighDpi = False`. This means that the application will render to a lower-resolution framebuffer on HighDPI displays and the rendered content will be upscaled by the window system composer.

In a HighDPI scenario, you still request the same window size during, but the framebuffer sizes returned by `FramebufferWidth` and `FramebufferHeight` will be scaled up according to the DPI scaling ratio.

Note that on some platforms the DPI scaling factor may change at any time (for instance when a window is moved from a high-dpi display to a low-dpi display).

To query the current DPI scaling factor, use the `DpiScale` property.

For instance on a Retina Mac, filling the `TAppConfig` record like this:

```pascal
  AConfig.Width := 640;
  AConfig.Height := 480;
  AConfig.HighDpi := True;
```

...results in these property values:

```
  FramebufferWidth : 1280
  FramebufferHeight: 960
  DpiScale         : 2.0
```

If the `HighDpi` flag is False, or you're not running on a Retina display, the values would be:

```
  FramebufferWidth : 640
  FramebufferHeight: 480
  DpiScale         : 1.0
```

If the window is moved from the Retina display to a low-dpi external display, the values would change as follows:

```
  FramebufferWidth : 1280 => 640
  FramebufferHeight:  960 => 480
  DpiScale         :  2.0 => 1.0
```

Currently there is no event associated with a DPI change, but a `Resized` event will be fired as a side effect of the framebuffer size changing.

Per-monitor DPI is currently supported on macOS and Windows.

This unit makes a distinction between "logical" and "physical" coordinates:

* "Logical" coordinates are used for window sizes and positions and for mouse positions.
* "Physical" (or "pixel") coordinates are used for the physical dimensions of the render back buffer.

"Logical" coordinates may be different from "pixel" coordinates on high-DPI displays. For example, a retina iPad can have a physical (pixel) resolution of
2048 x 1536 pixels. Since it has a pixel scale of 2.0, the logical resolution will be 1024 x 768.

On Windows, the pixel scale is the "font" scale factor set in the control panel for a monitor. Every monitor can have a different scale. For example,if you have a 4K monitor (3840 x 2160) and you have set the scaling to 200%, then the logical dimensions will be 1920 x 1080. This means you window size will  be equal or less than this, and all mouse coordinates will be in this logical range as well.

On Windows, you *must* use the manifest to specify how the application should behave in high-DPI environments (Project options | Application | Manifest).

When you set `TAppConfig.HighDpi` to `False`, then you *must* set the DPI awareness to "Unaware". In that case, Windows will automatically scale everything so the application looks like it is run on a regular-DPI monitor. The `FramebufferWidth` and `FramebufferHeight` properties will return the logical dimensions of the window, and the `DpiScale` property will return 1.0.

When you set `TAppConfig.HighDpi` to `True`, then you *must* set the DPI awareness to "Per Monitor v2". In that case the `FramebufferWidth` and
`FramebufferHeight` properties will return the physical dimensions of the frame buffer (in pixels) and the `DpiScale` property will return the scale factor (eg. 2.0 for retina displays).

## Application Quit
Without special quit handling, the application will quit 'gracefully' when the user clicks the window close-button unless a platform's application model prevents this (e.g. mobile). 'Graceful exit' means that the application-provided cleanup method will be called before the application quits.

Native desktop platforms provide more control over the application-quit-process. It's possible to initiate a 'programmatic quit' from the application code, and a quit initiated by the application user can be intercepted (for instance to show a custom dialog box).

This 'programmatic quit protocol' is implemented through:

* `TApplication.Quit`: This method simply quits the application without giving the user a chance to intervene. Usually this might be called when the user clicks the 'Ok' button in a 'Really Quit?' dialog box.
* `TApplication.RequestQuit`: Calling this method will fire a `QuitRequested` event, giving the user code a chance to intervene and cancel the pending quit process (for instance to show a 'Really Quit?' dialog box). If the event does nothing, the application will be quit as usual. To prevent this, set the `ACanQuit` parameter of this method to `False`.

The ImGuiHighDpi sample contains example code of how to implement a 'Really Quit?' dialog box with Dear ImGui (native desktop platforms only).

## Full screen
If the `TAppConfig.FullScreen` flag is `True`, the app will try to create a full screen window on platforms with a 'proper' window system (mobile devices will always use full screen). The implementation details depend on the target platform. In general the app will use a 'soft approach' which doesn't interfere too much with the platform's window system (for instance borderless full screen window instead of a 'real' full screen mode). Such details might
change over time.

The most important effect of full screen mode to keep in mind is that the requested canvas width and height will be ignored for the initial window size. The `FramebufferWidth` and `FramebufferHeight` properties will instead return the resolution of the full screen canvas (however the provided size might still be used for the non-full-screen window, in case the user can switch back from full screen- to windowed-mode).

To toggle full screen mode programmatically, call `ToggleFullScreen` or set the `FullScreen` property.

## Window icon support
Some backends allow to change the window icon programmatically. Note that it is not possible to set the actual application icon which is displayed by the operating system on the desktop or 'home screen'. Those icons must be provided using the Project Options in Delphi (under Application | Icons).

There are two ways to set the window icon:
* at application start, set the `TAppConfig.Icon` field.
* or later by calling `SetAppIcon`.

As a convenient shortcut, Sokol applications come with a built-in default-icon (a rainbow-colored 'S', which at least looks a bit better than the Windows default icon for applications), which can be activated by setting the `TAppConfig.Icon.UseDefault` field to `True`.

Note that a completely zero-initialized `TIconDesc` record will not update the window icon in any way. This is an 'escape hatch' so that you can handle the window icon update yourself.

You provide one or more 'candidate images' in different sizes, and the backend picks the best match for the specific backend and icon type.

For each candidate image, you need to provide:
* the width in pixels
* the height in pixels
* and the actual pixel data in RGBA8 pixel format (e.g. $FFCC8844 means: alpha=$FF, blue=$CC, green=$88, red=$44)

For an example and test of the window icon feature, check out the Icon sample app.

## Onscreen keyboard
On some platforms which don't provide a physical keyboard, the app can display the platform's integrated onscreen keyboard for text input. Use the `KeyboardVisible` property to show and hide the keyboard.
# Neslib.Sokol.Framebuffer

Pixel framebuffer for CPU rendering.

This is a light-weight OOP layer on top of [sokol_framebuffer.h](https://github.com/floooh/sokol).

## Feature Overview

Provides old-school pixel framebuffers for CPU rendering in two pixel format:

  - direct RGBA8 (32 bits per pixel)
  - 8-bits per pixel indexing a 256-entry RGBA8 color palette

## Step-by-Step

### Initialize Neslib.Sokol.Framebuffer

First initialize Neslib.Sokol.Framebuffer via:

```pascal
var SetupDesc := TFramebufferSetupDesc.Create;
SetupDesc.Logger := SetupDesc.DefaultLogger;
TFramebuffer.Setup(SetupDesc);
```

If you need more than 8 framebuffers at the same time, increase the framebuffer pool:

```pascal
var SetupDesc := TFramebufferSetupDesc.Create;
SetupDesc.FramebufferPoolSize := 129;
SetupDesc.Logger := SetupDesc.DefaultLogger;
TFramebuffer.Setup(SetupDesc);
```

### Create framebuffer

Next, create one or more framebuffers. You need to provide at leastb a width and height:

```pascal
var Desc := TFramebufferDesc.Create;
Desc.Width := 320;
Desc.Height := 256;
var Framebuffer := TFramebuffer.Create(Desc);
```

By default this creates an RGBA8 framebuffer. To get the paletted format (1 byte per pixel and 256 color palette entries):

```pascal
var Desc := TFramebufferDesc.Create;
Desc.Width := 320;
Desc.Height := 256;
Desc.Format := TFramebufferFormat.Palette8;
var Framebuffer := TFramebuffer.Create(Desc);
```

You can also provide a 'prescale factor'. This allows to balance pixel crispiness against bluriness. E.g. if you want your final rendered framebuffer to look less blurry but not quite have the harsh look of nearest filtering, try a prescale factor of 2:

```pascal
var Desc := TFramebufferDesc.Create;
Desc.Width := 320;
Desc.Height := 256;
Desc.Format := TFramebufferFormat.Palette8;
Desc.Prescale := 2;
var Framebuffer := TFramebuffer.Create(Desc);
```

You can rotate the framebuffer by 90 degrees, this is mainly useful to emulate some classic arcade machines where a regular 4:3 CRT was installed in 'portrait mode':

```pascal
var Desc := TFramebufferDesc.Create;
Desc.Width := 320;
Desc.Height := 256;
Desc.Format := TFramebufferFormat.Palette8;
Desc.Prescale := 2;
Desc.Rotate90 := True;
var Framebuffer := TFramebuffer.Create(Desc);
```

You can define a sub-rectangle of the framebuffer to be rendered. For instance to only render the upper-left quadrant of a 320x256 framebuffer:

```pascal
var Desc := TFramebufferDesc.Create;
Desc.Width := 320;
Desc.Height := 256;
Desc.Format := TFramebufferFormat.Palette8;
Desc.Prescale := 2;
Desc.Rotate90 := True;
Desc.Cliprect.X := 0;
Desc.Cliprect.Y := 0;
Desc.Cliprect.Width := 160;
Desc.Cliprect.Height := 128;
var Framebuffer := TFramebuffer.Create(Desc);
```

Finally if you plan to render the framebuffer in a render pass with different properties than the default swapchain format, you'll need to provide a color- and depth-pixelformat and a sample count which matches the properties of the render pass:

```pascal
var Desc := TFramebufferDesc.Create;
Desc.Width := 320;
Desc.Height := 256;
Desc.Format := TFramebufferFormat.Palette8;
Desc.Prescale := 2;
Desc.Rotate90 := True;
Desc.RenderPass.ColorFormat := TPixelFormat....;
Desc.RenderPass.DepthFormat := TPixelFormat....;
Desc.RenderPass.SampleCount := ...;
var Framebuffer := TFramebuffer.Create(Desc);
```

### Define pixel buffer and optional color palette

The actual pixel buffer and color palette are owned by you. For a 320x256  framebuffer with 32-bits per pixel (`TFramebufferFormat.Rgba8`), use an UInt32 buffer like this:

```pascal
var Pixels: array [0..255, 0..319] of UInt32;
```

For the paletted format (1 byte per pixel and a 256 entry color palette):

```pascal
var Pixels: array [0..255, 0..319] of UInt8;
var Palette: array [0..255] of UInt32;
```

### Fill pixel buffer and optional palette

Now 'render' into the pixel and palette buffers with the CPU.

An RGBA8 pixel or palette entry split into red, green, blue, alpha like this:

```
|AAAAAAAA|BBBBBBBB|GGGGGGGG|RRRRRRRR|
```

E.g. bits 24 to 31 are the alpha component, bits 16 to 23 the blue component, bits 8 to 15 to green component and bits 0 to 7 the red component. Or typically:

```pascal
var A: Byte := 255;
var R: Byte := ...;
var G: Byte := ...;
var B: Byte := ...;
var Pixel: UInt32 := (A shl 24) or (B shl 16) or (G shl 8) or R;
```

Whenever the pixel buffer or color palette content changes, call` TFramebuffer.Update` outside a Neslib.Sokol.Gfx render pass, and *only once per frame* at most:

```pascal
var UpdateDesc := TFramebufferUpdateDesc.Create;
UpdateDesc.Pixels := TRange.Create(Pixels);
UpdateDesc.Palette := TRange.Create(Palette);
Framebuffer.Update(UpdateDesc);
```

Of course for an RGBA8 framebuffer you'd only provide the pixels:

```pascal
var UpdateDesc := TFramebufferUpdateDesc.Create;
UpdateDesc.Pixels := TRange.Create(Pixels);
Framebuffer.Update(UpdateDesc);
```

But even for a paletted framebuffer you can omit the data that doesn't change. E.g. when only the palette changes but not the pixel data:

```pascal
var UpdateDesc := TFramebufferUpdateDesc.Create;
UpdateDesc.Palette := TRange.Create(Palette);
Framebuffer.Update(UpdateDesc);
```

Or vice versa when only the pixels but not the palette entries change:

```pascal
var UpdateDesc := TFramebufferUpdateDesc.Create;
UpdateDesc.Pixels := TRange.Create(Pixels);
Framebuffer.Update(UpdateDesc);
```

The `TFramebuffer.Update` method will do up to two calls to the Neslib.Sokol.Gfx method `TImage.Update`: once for the pixel data and once for the palette data (this is why the function must only be called at most once per frame), and then do an render pass into an internal color attachment texture (this is why the function must be called outside any Neslib.Sokol.Gfx pass).

Finally, to render your framebuffer to the display, call `TFramebuffer.Render` *inside* a Neslib.Sokol.Gfx render pass:

```pascal
TGfx.BeginPass(Pass);
Framebuffer.Render;
...
TGfx.EndPass;
```

This will stretch the framebuffer to the whole canvas which might distort its aspect ratio. If you want a fixed aspect ratio consider setting a viewport with the help of Neslib.Sokol.Letterbox.

For more control over the rendering process, call `TFramebuffer.Render` with a `TFramebufferRenderDesc` instead. For instance to override the default sampler with linear filtering and instead use a builtin sampler with nearest filtering:

```pascal
var RenderDesc := TFramebufferRenderDesc.Create;
RenderDesc.UseNearestFilter := True;
Framebuffer.Render(RenderDesc);
```

Note though that the prescale factor provided in `TFramebufferDesc` is a better way to tweak bluriness vs crispiness. Only use the nearest-filter override if you want a 100% pixelized look.

The main purpose of `TFramebufferRenderDesc` is to inject a more advanced shader though (like a CRT shader).

### Resizing

If any of the sizing properties of the framebuffer changes, call:

```pascal
var ResizeDesc := TFramebufferResizerDesc.Create;
ResizeDesc.Width := NewWidth;
ResizeDesc.Height := NewHeight;
ResizeDesc.Prescale := NewPrescale;
ResizeDesc.ClipRect := NewClipRect;
Framebuffer.Resize(ResizeDesc);
```

The `TFramebuffer.Resize` method function is 'lazy'; It will only destroy and recreate internal objects when actually needed (e.g. the size of image objects has changed). In that case, `True` is returned. When the function returns `False`, it was basically a cheap no-op.

### Query information

If you want to do the final rendering entirely yourself you can get handles to all the internally used resources of a framebuffer object via:

```pascal
var Info := Framebuffer.Info;
```

This returns handles to all internal image, view and sampler objects as well as image sizes and pixel formats.

To query the current 'resource state' of a framebuffer:

```pascal
var State := Framebuffer.State;
```

Tthis is mainly useful to check whether framebuffer creation via `TFramebuffer.Create` had failed.

To get a copy the the` TFramebufferDesc` record struct (patched with defaults) of a framebuffer object:

```pascal
var Desc := Framebuffer.Desc;
```

### Cleanup

To destroy a framebuffer object:

```pascal
Framebuffer.Free;
```

Calling `TFramebuffer.Shutdown` will also destroy any remaining framebuffer objects:

```pascal
TFramebuffer.Shutdown;
```

## Memory Allocation Override

You can use Delphi's memory manager instead of the system memory manager by setting `TFramebufferSetupDesc.UseDelphiMemoryManager` to `True`.  This only affects memory allocation calls done by Neslib.Sokol.Framebuffer itself though, not any allocations in OS libraries.

## Error reporting and logging

To get any logging information at all you need to provide a logging callback in the `TFramebufferSetupDesc` record. The easiest way is using the DefaultLogger provided by Sokol:

```pascal
  var Desc := TFramebufferSetupDesc.Create;
  Desc.Logger := Desc.DefaultLogger;
  ...
  TFramebuffer.Setup(Desc);
```

The provided logging function must be reentrant (e.g. be callable from different threads).

If you don't want to provide your own custom logger it is highly recommended to use the standard logger, otherwise you won't see any warnings or errors.
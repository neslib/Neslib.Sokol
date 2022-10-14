# Neslib.Sokol.DebugText

Simple ASCII debug text rendering on top of [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md).

This is a light-weight OOP layer on top of [sokol_debugtext.h](https://github.com/floooh/sokol).

## Features and Concepts

- renders 8-bit ASCII text as fixed-size 8x8 pixel characters
- comes with 6 embedded 8-bit home computer fonts (each taking up 2 KB)
- easily plug in your own fonts
- create multiple contexts for rendering text in different layers or render passes

## Step by Step

* To initialize, call `TDbgText.Setup` *after* initializing [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md):

  ```pascal
  var Desc := TDbgTextDesc.Create;
  TDbgText.Setup(Desc);
  ```

* Configure `TDbgText` by populating the `TDbgTextDesc` record:

    * `.ContextPoolSize` (default: 8): The max number of text contexts that can be created.

    * `.Fonts` (default: none): An array of `TDbgTextFontDesc` records used to configure the fonts that can be used for rendering. To use all built-in fonts call `TDbgText.Setup` like this:

        ```pascal
        var Desc := TDbgTextDesc.Create;
        Desc.Fonts[0] := TDbgTextFont.KC853;
        Desc.Fonts[1] := TDbgTextFont.KC854;
        Desc.Fonts[2] := TDbgTextFont.Z1013;
        Desc.Fonts[3] := TDbgTextFont.CPC;
        Desc.Fonts[4] := TDbgTextFont.C64;
        Desc.Fonts[5] := TDbgTextFont.Oric;
        TDbgText.Setup(Desc);
        ```
    
        For documentation on how to use you own font data, read the [Using your own Font Data](#using-your-own-font-data) section.
    
    * `.Context`: The setup parameters for the default text context. This will be active right after `TDbgText.Setup`, or when calling `TDbgText.SetDefaultContext`.    
    
        * `.CharBufSize` (default: 4096):  The number of characters that can be rendered per frame in this context, defines the size of an internal fixed-size vertex buffer.  Any additional characters will be silently ignored.
    
        * `.CanvasWidth` (default: 640), `.CanvasHeight` (default: 480): The 'virtual canvas size' in pixels. This defines how big characters will be rendered relative to the default framebuffer dimensions. Each character occupies a grid of 8x8 'virtual canvas pixels' (so a virtual canvas size of 640x480 means that 80x60 characters fit on the screen). For rendering in a resizable window, you should dynamically update the canvas size in each frame by calling `TDbgText.Canvas(W, H)`.
    
        * `.TabWidth` (default: 4): The width of a tab character in number of character cells.
    
        * `.ColorFormat` (default: `TPixelFormat.Default`), `.DepthFormat` (default: `TPixelFormat.Default`), `.SampleCount` (default: 0): The pixel format description for the default context needed for creating the context's `TPipeline` object. When rendering to the default framebuffer you can leave those zero-initialized. In this case the proper values will be filled in by Sokol Gfx. You only need to provide non-default values here when rendering to render targets with different pixel format attributes than the default framebuffer.
    

- Before starting to render text, optionally call `TDbgText.Canvas` to dynamically resize the virtual canvas. This is recommended when rendering to a resizable window. The virtual canvas size can also be used to scale text in relation to the display resolution.

  Examples when using sokol-app:

  * to render characters at 8x8 'physical pixels':

    ```pascal
    TDbgText.Canvas(TApplication.FramebufferWidth, TApplication.FramebufferHeight);
    ```

  * to render characters at 16x16 physical pixels:

    ```pascal
    TDbgText.Canvas(TApplication.FramebufferWidth / 2, TApplication.FramebufferHeight / 2);
    ```

​				Do *not* use integer math here, since this will not look nice when the render target size isn't divisible by 2.

* Optionally define the origin for the character grid with:

  ```pascal
  TDbgText.Origin(X, Y);
  ```
  The provided coordinates are in character grid cells, not in virtual canvas pixels. E.g. to set the origin to 2 character tiles from the left and top border:
  
  ```pascal
  TDbgText.Origin(2, 2);
  ```
  
  You can define fractions, e.g. to start rendering half a character tile from the top-left corner:
  
  ```pascal
  TDbgText.Origin(0.5, 0.5);
  ```

* Optionally set a different font by calling:

  ```pascal
  TDbgText.Font(FontIndex);
  ```
Neslib.Sokol.DebugText provides 8 font slots which can be populated with the built-in fonts or with user-provided font data, so 'font_index' must be a number from 0 to 7.

* Position the text cursor with one of the following calls. All arguments are in character grid cells as floats and relative to the origin defined with `TDbgText.Origin`:

  ```
      TDbgText.Pos(X, Y)   - sets absolute cursor position
      TDbgText.PosX(X)     - only set absolute x cursor position
      TDbgText.PosY(Y)     - only set absolute y cursor position
  
      TDbgText.Move(X, Y)  - move cursor relative in x and y direction
      TDbgText.MoveX(X)    - move cursor relative only in x direction
      TDbgText.MoveY(Y)    - move cursor relative only in y direction
  
      TDbgText.NewLine()   - set cursor to beginning of next line
                             (same as TDbgText.PosX(0) + TDbgText.MoveY(1))
      TDbgText.Home()      - resets the cursor to the origin
                             (same as TDbgText.Pos(0, 0))
  ```

* Set a new text color with any of the following functions:

  ```
      TDbgText.Color(R, G, B)     - RGB 0..255, A=255
      TDbgText.Color(R, G, B, A)  - RGBA 0..255
      TDbgText.ColorF(R, G, B)    - RGB 0.0..1.0, A=1.0
      TDbgText.ColorF(R, G, B, A) - RGBA 0.0..1.0
      TDbgText.Color(Rgba)        - ABGR ($AABBGGRR)
  ```

* Output 8-bit ASCII text with the following functions:

  ```
      TDbgText.Write(C)           - output a single character
      TDbgText.Write(Str)         - output a (Unicode) string (without a newline)
      TDbgText.WriteAnsi(Str)     - output a AnsiString (without a newline, more efficient)
      TDbgText.Write(Str, Args)   - output a (Unicode) string with formatting 
                                    arguments (without a newline)
      TDbgText.WriteLn(Str)       - output a (Unicode) string and a newline
      TDbgText.WriteAnsiLn(Str)   - output a AnsiString and a newline (more efficient)
      TDbgText.WriteLn(Str, Args) - output a (Unicode) string with formatting 
                                    arguments and a newline
  ```

  * Note that the text will not yet be rendered, only recorded for rendering at a later time, the actual rendering happens when `TDbgText.Draw` is called inside a Sokol Gfx render pass.
  * This also means that you can output text anywhere in the frame. It doesn't have to be inside a render pass.
  * Note that character codes < #32 are reserved as control characters and won't render anything. Currently only the following control characters are implemented:
    * #13: carriage return (same as `TDbgText.PosX(0)`)
    * #10: carriage return + line feed (same as `TDbgText.NewLine`)
    * #9: A tab character

* Finally, from within a Sokol Gfx render pass, call:

  ```pascal
  TDbgText.Draw;
  ```
  to actually render the text. Calling `TDbgText.Draw` will also rewind the text context:
  
  - the internal vertex buffer pointer is reset to the beginning
  - the current font is set to 0
  - the cursor position is reset
  
## Rendering with Multiple Contexts

Use multiple text contexts if you need to render debug text in different Sokol Gfx render passes, or want to render text to different layers in the same render pass, each with its own set of parameters.

To create a new text context call:

```pascal
var CtxDesc := TDbgTextContextDesc.Create;
var Ctx := TDbgTextContext.Create(CtxDesc);
```

The creation parameters in the `TDbgTextContextDesc` record are the same as already described above in the `TDbgText.Setup` method:

```
.CharBufSize   -- max number of characters rendered in one frame, default: 4096
.CanvasWidth   -- the initial virtual canvas width, default: 640
.CanvasHeight  -- the initial virtual canvas height, default: 400
.TabWidth      -- tab width in number of characters, default: 4
.ColorFormat   -- color pixel format of target render pass
.DepthFormat   -- depth pixel format of target render pass
.SampleCount   -- MSAA sample count of target render pass
```

To make a new context the active context:

```pascal
TDbgText.Context := Ctx;
```

...and after that call the text output functions as described above, and finally, inside a Sokol Gfx render pass, call `TDbgText.Draw` to actually render the text for this context.

A context keeps track of the following parameters:
- the active font
- the virtual canvas size
- the origin position
- the current cursor position
- the current tab width
- and the current color

You can get the currently active context with:

```pascal
var Ctx := TDbgText.Context;
```

To make the default context current, call:

```pascal
TDbgText.SetDefaultContext;
```

To destroy a context, call:

```pascal
Ctx.Free;
```

If a context is set as active that no longer exists, all DebugText functions that require an active context will silently fail.

Using your own Font Data
------------------------

Instead of the built-in fonts you can also plug your own font data into Neslib.Sokol.DebugText by providing one or several `TDbgTextFontDesc` records in the `TDbgText.Setup` call.

For instance to use a built-in font at slot 0, and a user-font at font slot 1, the `TDbgText.Setup` call might look like this:

```pascal
var Desc := TDbgTextDesc.Create;
Desc.Fonts[0] := TDbgTextFont.KC853;
Desc.Fonts[1].Data := TRange.Create(MyFontData);
Desc.Fonts[1].FirstChar := ...;
Desc.Fonts[1].LastChar := ...;
TDbgText.Setup(Desc);
```

Where `MyFontData` is a byte array where every character is described by 8 bytes arranged like this:

    bits
    7 6 5 4 3 2 1 0
    . . . X X . . .     byte 0: $18
    . . X X X X . .     byte 1: $3C
    . X X . . X X .     byte 2: $66
    . X X . . X X .     byte 3: $66
    . X X X X X X .     byte 4: $7E
    . X X . . X X .     byte 5: $66
    . X X . . X X .     byte 6: $66
    . . . . . . . .     byte 7: $00

A complete font consists of 256 characters, resulting in 2048 bytes for the font data array (but note that the character codes 0..31 will never be rendered).

If you provide such a complete font data array, you can drop the `.FirstChar` and `.LastChar` initialization parameters since those default to #0 and #255. 

If the font doesn't define all 256 character tiles, or you don't need an entire 256-character font and want to save a couple of bytes, use the `.FirstChar` and `.LastChar` initialization parameters to define a sub-range. For instance if the font only contains the characters between the Space (ASCII code 32) and uppercase character 'Z' (ASCII code 90):

```pascal
var Desc := TDbgTextDesc.Create;
Desc.Fonts[0] := TDbgTextFont.KC853;
Desc.Fonts[1].Data := TRange.Create(MyFontData);
Desc.Fonts[1].FirstChar := ' ';
Desc.Fonts[1].LastChar := 'Z';
TDbgText.Setup(Desc);
```

Character tiles that haven't been defined in the font will be rendered as a solid 8x8 quad.

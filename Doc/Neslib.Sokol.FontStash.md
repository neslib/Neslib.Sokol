# Neslib.Sokol.FontStash

Renderer for [FontStash](https://github.com/memononen/fontstash) on top of [Neslib.Sokol.GL](Neslib.Sokol.GL.md).

This is a light-weight OOP layer on top of [sokol_fontstash.h](https://github.com/floooh/sokol).

## How To

* First initialize [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md) and [Neslib.Sokol.GL](Neslib.Sokol.GL.md) as usual:
    ```pascal
    TGfx.Setup(...);
    sglSetup(...);
    ```

* Create at least one `TFontStash` context with `TSokolFontStash.Create`:
    ```pascal
    var Ctx: TFontStash := TSokolFontStash.Create(AtlasWidth, AtlasHeight);
    ```
    
    Each `TFontStash` manages one font atlas texture which can hold rasterized glyphs for multiple fonts.
    Note that `TFontStash` (in the Neslib.FontStash unit) provides access to the general FontStash API's, while `TSokolFontStash` (in the Neslib.Sokol.FontStash unit) links Sokol and FontStash together.
    
* From here on, use the `TFontStash` methods "as usual" to add TTF font data and draw text. Note that (just like with Sokol GL), text rendering can happen anywhere in the frame, not only inside a Sokol Gfx rendering pass.

* Once per frame before calling `sglDraw`, call:

    ```pascal
    TSokolFontStash.Flush(Ctx);
    ```
    
    This will update the dynamic Sokol Gfx texture with the latest font atlas content.

* To actually render the text (and any other Sokol GL draw commands), call `sglDraw` inside a Sokol Gfx frame.

* Note that you can mix `TFontStash` calls with Sokol GL calls to mix text rendering with Sokol GL rendering. You can also use Sokol GL's matrix stack to position `TFontStash` text in 3D.

* finally on application shutdown, call:

    ```pascal
    TSokolFontStash.Free(Ctx);
    ```

    before `sglShutdown` and TGfx`.Shutdown`.
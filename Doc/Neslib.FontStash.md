# Neslib.FontStash

Delphi wrapper for [FontStash](https://github.com/memononen/fontstash).

Font stash is light-weight online font texture atlas builder written in C. It uses [stb_truetype](http://nothings.org/) to render fonts on demand to a texture atlas.

## Example

```pascal
// Create GL stash for 512x512 texture, our coordinate system has zero at top-left.
var Params := TFontStashParams.Create(512, 512);
var Stash := TFontStash.Create(Params);

// Add font to stash.
var FontNormal := Stash.AddFont('sans', 'DroidSerif-Regular.ttf');

// Render some text
Stash.SetFont(FontNormal);
Stash.SetSize(124.0);
Stash.SetColor(TAlphaColors.White);
var X := Stash.DrawText(10, 10, "The big ");

Stash.SetSize(24);
Stash.SetColor(TAlphaColors.Brown);
Stash.DrawText(X, 10, 'brown fox');

Stash.Free;
```

## Using a custom rendering backend

You can use the [Neslib.Sokol.FontStash](Neslib.Sokol.FontStash.md) unit to render using Sokol. To use another rendering backend, set the following events of the `TFontStashParams` record:

* `OnRenderCreate: function(const AWidth, AHeight: Integer): Boolean of object;` - is called to create renderer for specific API, this is where you should create a texture of given size. It should return `True` on success or `False` otherwise.
* `OnRenderResize: function(const AWidth, AHeight: Integer): Boolean of object;` - is called to resize the texture. Called when user explicitly expands or resets the atlas texture. It should return `True` on success or `False` otherwise.
* `OnRenderUpdate: procedure(const ARect: TRect; const AData: Pointer) of object;` - is called to update texture data:
  - `ARect` describes the region of the texture that has changed.
  - `AData` is a pointer to full texture data.
* `OnRenderDraw: procedure(const AVerts, ATexCoords: PPointF; const AColors: PCardinal; const ACount: Integer) of object;` - is called when the font triangles should be drawn:
  - `AVerts` is a pointer to vertex position data, 2 floats per vertex.
  - `ATexCoords` is a pointer to texture coordinate data, 2 floats per vertex.
  - `AColors` pointer to color data, 1 cardinal per vertex (or 4 bytes).
  - `ACount` is the number of vertices to draw.
* `OnRenderDelete: procedure of object;` -  is called when the renderer should be deleted.
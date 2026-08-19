# Neslib.Stb.TrueType

Delphi wrapper for [stb_truetype.h](https://github.com/nothings/stb).

## TStbFont

Main class for loading, rasterizing and retrieving information from TrueType and OpenType fonts.

> NOTE: Do *not* use this class with untrusted font files. This class does no  range checking of the offsets found in the file, meaning an attacker can use it to read arbitrary memory.
>

Use this class to:
* Parse TrueType and OpenType files
* Extract glyph metrics
* Extract glyph shapes
* Render glyphs to one-channel bitmaps with antialiasing (box filter)
* Render glyphs to one-channel SDF bitmaps (signed-distance field/function)

## Concepts
Some important concepts to understand to use this class:

* **Codepoint**: Characters are defined by unicode codepoints, e.g. 65 is uppercase A, 231 is lowercase c with a cedilla, $7e30 is the hiragana for "ma".
* **Glyph**: A visual character shape (every codepoint is rendered as some glyph).
* **Glyph index**: A font-specific integer ID representing a glyph.
* **Baseline**: Glyph shapes are defined relative to a baseline, which is the bottom of uppercase characters. Characters extend both above and below the baseline.
* **Current Point**: As you draw text to the screen, you keep track of a "current point" which is the origin of each character. The current point's vertical position is the baseline. Even "baked fonts" use this model.
* **Vertical Font Metrics**: The vertical qualities of the font, used to vertically position and space the characters. See `GetFontVMetrics`.
* **Font Size in Pixels or Points**: The preferred interface for specifying font sizes is to specify how tall the font's vertical extent should be in pixels. Most other font APIs instead use "points", which are a common typographic measurement for describing font size, defined as 72 points per inch. This class provides a point API for compatibility. However, true "per inch" conventions don't make much sense on computer displays since different monitors have different number of pixels per inch. For example, Windows traditionally uses a convention that there are 96 pixels per inch, thus making 'inch' measurements have nothing to do with inches, and thus effectively defining a point to be 1.333 pixels. Additionally, the TrueType font data provides an explicit scale factor to scale a given font's glyphs to points, but the author has observed that this scale factor is often wrong for non-commercial fonts, thus making fonts scaled in points according to the TrueType spec incoherently sized in practice.

## Detailed usage

1. **Scale**: Select how high you want the font to be, in points or pixels. Call `ScaleForPixelHeight` or `ScaleForMappingEmToPixels` to compute a scale factor `SF` that will be used by all other method.
2. **Baseline**: You need to select a y-coordinate that is the baseline of where your text will appear. Call `GetBoundingBox` to get the baseline-relative bounding box for all characters. `SF*-Y0` will be the distance in pixels that the worst-case character could extend above the baseline, so if you want the top edge of characters to appear at the top of the screen where y=0, then you would set the baseline to `SF*-Y0`.
3. **Current point**: Set the current point where the first character will appear. The first character could extend left of the current point; this is font dependent. You can either choose a current point that is the leftmost point and hope, or add some padding, or check the bounding box or left-side-bearing of the first character to be displayed and set the current point based on that.
4. **Displaying a character**: Compute the bounding box of the character. It will contain signed values relative to `<CurrentPoint, Baseline>`. I.e. if it returns `X0,Y0,X1,Y1`, then the character should be displayed in the rectangle from `<CurrentPoint+SF*X0, Baseline+SF*Y0>` to `<CurrentPoint+SF*X1, Baseline+SF*Y1>`.
5. **Advancing for the next character**: Call `GetGlyphHMetrics`, and compute `CurrentPoint := CurrentPoint + SF * Advance`.

## Advanced usage

### Quality
Use the functions with `Subpixel` at the end to allow your characters to have subpixel positioning. Since the font is anti-aliased, not hinted, this is very import for quality. (This is not possible with baked fonts.)

Kerning is now supported, and if you're supporting subpixel rendering then kerning is worth using to give your text a polished look.

### Performance

Convert Unicode codepoints to glyph indexes and operate on the glyphs; if you don't do this, TStbFont is forced to do the conversion on every call.

## Notes

The system uses the raw data found in the .ttf file without changing it and without building auxiliary data structures. This is a bit inefficient on llittle-endian systems (the data is big-endian), but assuming you're caching the bitmaps or glyph shapes this shouldn't be a big deal.
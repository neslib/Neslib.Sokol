unit Neslib.Stb.TrueType;
{ Delphi wrapper for stb_truetype.h 1.26 (https://github.com/nothings/stb) }

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  Neslib.Sokol.Api;

type
  { Information about a baked quad in TStbBakedCharacters }
  TStbAlignedQuad = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _stbtt_aligned_quad;
  {$ENDREGION 'Internal Declarations'}
  public
    { Top-left pixel coordinates }
    property X0: Single read FHandle.x0;
    property Y0: Single read FHandle.y0;

    { Bottom-right pixel coordinates }
    property X1: Single read FHandle.x1;
    property Y1: Single read FHandle.y1;

    { Top-left UV coordinates }
    property S0: Single read FHandle.s0;
    property T0: Single read FHandle.t0;

    { Bottom-right UV coordinates }
    property S1: Single read FHandle.s1;
    property T1: Single read FHandle.t1;
  end;

type
  { Information about a baked character as returned by TStbFont.Bake }
  TStbBakedCharacter = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _stbtt_bakedchar;
  {$ENDREGION 'Internal Declarations'}
  public
    { Coordinates of bounding box in bitmap }
    property X0: Word read FHandle.x0;
    property Y0: Word read FHandle.y0;
    property X1: Word read FHandle.x1;
    property Y1: Word read FHandle.y1;

    { X offset to use when drawing the character }
    property XOffset: Single read FHandle.xoff;

    { Y offset to use when drawing the character }
    property YOffset: Single read FHandle.yoff;

    { Number of pixels to advance horizontally for the next character }
    property XAdvance: Single read FHandle.xadvance;
  end;

type
  { A baked character range as returned by TStbFont.Bake }
  TStbBakedCharacters = record
  public
    { Information about each baked character.
      Will be nil (empty) if no characters fit in the bitmap. }
    Chars: TArray<TStbBakedCharacter>;

    { Width of the bitmap containing the baked characters }
    BitmapWidth: Integer;

    { Height of the bitmap containing the baked characters }
    BitmapHeight: Integer;

    { The next unused row in the bitmap that can be used for other purposes.
      If set to BitmapHeight then either the entire bitmap is used, or the
      bitmap wasn't large enough to fit all character glyphs. }
    NextRowInBitmap: Integer;

    { First character (codepoint) in this range.
      The number of codepoints is Length(Chars). }
    FirstChar: UCS4Char;
  public
    { Creates the quad you need to draw and advances the current position.

      AChar is the character (codepoint) to display.
      AXPos and AYPos contain the current position in screen pixel space, and
      will be adjust to draw the next character.

      Set AOpenGLFillRule to True when using OpenGL, or leave it to False
      otherwise.

      Returns the quad information. The result will be all zeros if AChar does
      not fall in this character range.

      The coordinate system used assumes Y increases downwards.

      Characters will extend both above and below the current position;
      See discussion of "Baseline" in comments of TStbFont.

      This method is inefficient. }
    function GetQuad(const AChar: UCS4Char; var AXPos, AYPos: Single;
      const AOpenGLFillRule: Boolean = False): TStbAlignedQuad;

    { As GetQuad but uses a character index (into the Chars array) instead of
      a codepoint value }
    function GetQuadByIndex(const ACharIndex: Integer; var AXPos, AYPos: Single;
      const AOpenGLFillRule: Boolean = False): TStbAlignedQuad;
  end;

type
  { Information about a baked and packed character }
  TStbPackedCharacter = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _stbtt_packedchar;
  {$ENDREGION 'Internal Declarations'}
  public
    { Coordinates of bounding box in bitmap }
    property X0: Word read FHandle.x0;
    property Y0: Word read FHandle.y0;
    property X1: Word read FHandle.x1;
    property Y1: Word read FHandle.y1;

    { X offset to use when drawing the character }
    property XOffset: Single read FHandle.xoff;

    { Y offset to use when drawing the character }
    property YOffset: Single read FHandle.yoff;

    { Number of pixels to advance horizontally for the next character }
    property XAdvance: Single read FHandle.xadvance;

    property XOffset2: Single read FHandle.xoff2;
    property YOffset2: Single read FHandle.yoff2;
  end;

type
  { A baked and packed character range as returned by
    TStbPackContext.PackRange(s) }
  TStbPackedCharacters = record
  public
    { Information about each baked and packed character.
      Will be nil (empty) if TStbPackContext.PackRange(s) failed. }
    Chars: TArray<TStbPackedCharacter>;

    { Width of the bitmap containing the baked and packed characters }
    BitmapWidth: Integer;

    { Height of the bitmap containing the baked and packed characters }
    BitmapHeight: Integer;

    { First character (codepoint) in this range. The number of codepoints is
      Length(Chars). Is 0 if an array of codepoints was used to bake the
      characters. }
    FirstCharInRange: UCS4Char;
  public
    { Creates the quad you need to draw and advances the current position.

      AChar is the character (codepoint) to display.
      AXPos and AYPos contain the current position in screen pixel space, and
      will be adjust to draw the next character.

      Set AAlignToInteger to True align quad pixel values to integer
      coordinates.

      Returns the quad information. The result will be all zeros if AChar does
      not fall in this character range.

      The coordinate system used assumes Y increases downwards.

      Characters will extend both above and below the current position;
      See discussion of "Baseline" in comments of TStbFont.

      IMPORTANT: This method can only be used when a character range was used
      to create this record (that is, when FirstCharInRange is not 0).
      Otherwise a zero quad is return and you should use GetQuadByIndex instead. }
    function GetQuad(const AChar: UCS4Char; var AXPos, AYPos: Single;
      const AAlignToInteger: Boolean = False): TStbAlignedQuad;

    { As GetQuad but uses a character index (into the Chars array) instead of
      a codepoint value }
    function GetQuadByIndex(const ACharIndex: Integer; var AXPos, AYPos: Single;
      const AAlignToInteger: Boolean = False): TStbAlignedQuad;
  end;

type
  { Used to pack multiple character ranges at once using
    TStbPackContext.PackRanges }
  TStbPackRange = record
  public
    { The full height of the character from ascender to descender, as computed
      by TStbFont.ScaleForPixelHeight. To use a point size as computed by
      TStbFont.ScaleForMappingEmToPixels, use a negative value:
        FontSize =  20; // font max minus min y is 20 pixels tall
        FontSize = -20; // 'M' is 20 pixels tall }
    FontSize: Single;

    { If non-zero, then this is the first unicode codepoint in a continous
      character range. If zero, then ArrayOfChars is used instead. }
    FirstCharInRange: UCS4Char;

    { Number of characters in the range. Only used if FirstCharInRange is not
      zero. }
    NumCharsInRange: Integer;

    { Array of unicode codepoints to use (instead of FirstCharInRange and
      NumCharsInRange). If FirstCharInRange is non-zero as well, then only
      ArrayOfChars is used.}
    ArrayOfChars: TArray<UCS4Char>;
  end;

type
  { Unscaled vertical font metrics. These are expressed in unscaled coordinates,
    so you must multiply by the scale factor for a given size. }
  TStbVMetrics = record
  public
    { The coordinate above the baseline the font extends }
    Ascent: Integer;

    { The coordinate below the baseline the font extends (i.e. it is typically
      negative) }
    Descent: Integer;

    { The spacing between one row's descent and the next row's ascent.
      So you should advance the vertical position by
      "Ascent - Descent + LineGap" }
    LineGap: Integer;
  end;

type
  { Scaled vertical font metrics.  }
  TStbScaledVMetrics = record
  public
    { The coordinate above the baseline the font extends }
    Ascent: Single;

    { The coordinate below the baseline the font extends (i.e. it is typically
      negative) }
    Descent: Single;

    { The spacing between one row's descent and the next row's ascent.
      So you should advance the vertical position by
      "Ascent - Descent + LineGap" }
    LineGap: Single;
  end;

type
  { Unscaled horizontal font metrics. These are expressed in unscaled
    coordinates, so you must multiply by the scale factor for a given size. }
  TStbHMetrics = record
  public
    { The offset from the current horizontal position to the next horizontal
      position }
    AdvanceWidth: Integer;

    { The offset from the current horizontal position to the left edge of the
      character }
    LeftSideBearing: Integer;
  end;

type

  { An (unscaled) bounding box }
  TStbBoundingBox = record
  public
    { Top-left pixel coordinates }
    X0: Integer;
    Y0: Integer;

    { Bottom-right pixel coordinates }
    X1: Integer;
    Y1: Integer;
  end;

type
  { Entries in a kerning table as returned by TStbFont.GetKerningTable. }
  TStbKerningEntry = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _stbtt_kerningentry;
  {$ENDREGION 'Internal Declarations'}
  public
    { Index of the first glyph }
    property Glyph1: Integer read FHandle.glyph1;

    { Index of the second glyph }
    property Glyph2: Integer read FHandle.glyph2;

    { The additional amount (kerning) to add to the 'advance' value between
      the two glyph indices. In unscaled coordinates. }
    property Advance: Integer read FHandle.advance;
  end;

type
  { Type of TStbVertex }
  TStbVertexKind = (
    { Moves the "pen" to (X, Y) }
    MoveTo  = _STBTT_vmove,

    { Draws a line from previous endpoint to its (X, Y). }
    LineTo  = _STBTT_vline,

    { Draws a quadratic bezier from previous endpoint to its (X, Y), using
      (CX, CY) as the bezier control point. }
    CurveTo = _STBTT_vcurve,

    { Draws a cubic curve from previous endpoint to its (X, Y), using (CX, CY)
      and (CX1, CY1) as the control points. }
    CubicTo = _STBTT_vcubic);

type
  { A vertex in a TStbGlyphShape. }
  TStbVertex = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _stbtt_vertex;
    function GetKind: TStbVertexKind; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { The type of vertex }
    property Kind: TStbVertexKind read GetKind;

    { End coordinates of the vertex. Used for all vertex types. }
    property X: Int16 read FHandle.x;
    property Y: Int16 read FHandle.y;

    { (First) control point the vertex. Used for CurveTo and CubicTo types. }
    property CX: Int16 read FHandle.cx;
    property CY: Int16 read FHandle.cy;

    { Second control point the vertex. Only used for CubicTo types. }
    property CX1: Int16 read FHandle.cx1;
    property CY1: Int16 read FHandle.cy1;
  end;
  PStbVertex = ^TStbVertex;

type
  { A list of vertices that defines a glyph shape.
    See TStbFont.GetCodepointShape/GetGlyphShape. }
  TStbGlyphShape = record
  {$REGION 'Internal Declarations'}
  private
    FVertices: _Pstbtt_vertex;
    FCount: Integer;
    function GetVertex(const AIndex: Integer): PStbVertex;
  {$ENDREGION 'Internal Declarations'}
  public
    { The number of vertices in the shape }
    property Count: Integer read FCount;

    { The vertices in the shape }
    property Vertices[const AIndex: Integer]: PStbVertex read GetVertex; default;
  end;

type
  { An 8-bits-per-pixel bitmap to render a glyph into. }
  TStbGlyphBitmap = record
  {$REGION 'Internal Declarations'}
  private
    FData: Pointer;
    FWidth: Integer;
    FHeight: Integer;
    FXOffset: Integer;
    FYOffset: Integer;
    FStride: Integer;
    FIsDelphiAllocated: Boolean;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates an empty bitmap. }
    constructor Create(const AWidth, AHeight: Integer;
      const AStride: Integer = 0);

    { Frees the bitmap }
    procedure Free; inline;

    { Pointer to the data of the bitmap }
    property Data: Pointer read FData;

    { Width of the bitmap }
    property Width: Integer read FWidth;

    { Height of the bitmap }
    property Height: Integer read FHeight;

    { Offset in pixel space from the glyph origin to the left of the bitmap }
    property XOffset: Integer read FXOffset;

    { Offset in pixel space from the glyph origin to the top of the bitmap }
    property YOffset: Integer read FYOffset;

    { Stride of the bitmap, or 0 for tight packing. }
    property Stride: Integer read FStride;
  end;

type
  TStbFont = class;

  { Class for baking characters into a bitmap. Do not create instances of this
    class yourself. Use TStbFont.Pack instead. }
  TStbPackContext = class
  {$REGION 'Internal Declarations'}
  private
    FFont: TStbFont;
    FContext: _stbtt_pack_context;
    function GetHOversample: Integer;
    procedure SetHOversample(const AValue: Integer);
    function GetVOversample: Integer;
    procedure SetVOversample(const AValue: Integer);
    function GetSkipMissingCodepoints: Boolean;
    procedure SetSkipMissingCodepoints(const AValue: Boolean);
  private
    constructor Create(const AFont: TStbFont;
      const AContext: _stbtt_pack_context);
  {$ENDREGION 'Internal Declarations'}
  public
    destructor Destroy; override;

    { Creates character bitmaps from the font. It creates ANumCharsInRange
      bitmaps for characters with unicode values starting at AFirstCharInRange
      and increasing.

      Returns information about the packed characters. If the length of
      Result.Chars is 0 then packing failed.

      AFontSize is the full height of the character from ascender to descender,
      as computed by TStbFont.ScaleForPixelHeight. To use a point size as
      computed by TStbFont.ScaleForMappingEmToPixels, use a negative value:
        AFontSize =  20; // font max minus min y is 20 pixels tall
        AFontSize = -20; // 'M' is 20 pixels tall

      AFontIndex is an optional index of the font in case the font file contains
      multiple fonts. }
    function PackRange(const AFontSize: Single; const AFirstCharInRange: UCS4Char;
      const ANumCharsInRange: Integer; const AFontIndex: Integer = 0): TStbPackedCharacters;

    { Creates character bitmaps from multiple ranges of characters. This will
      usually create a better-packed bitmap than multiple calls to PackRange.
      Note that you can call this multiple times as well.

      ARanges is an array of ranges to pack.

      Returns an array of TStbPackedCharacters records, one for each range (and
      where each Chars field in the record contains information about a
      specific character in that range). Returns nil on failure.

      AFontIndex is an optional index of the font in case the font file contains
      multiple fonts. }
    function PackRanges(const ARanges: TArray<TStbPackRange>;
      const AFontIndex: Integer = 0): TArray<TStbPackedCharacters>;

    { Oversampling a font increases the quality by allowing higher-quality
      subpixel positioning, and is especially valuable at smaller text sizes.

      This method sets the amount of oversampling for all following calls to
      PackRange(s) or PackRangesGatherRects.

      The default (no oversampling) is achieved by AHOversample=1 and
      AVOversample=1. The total number of pixels required is
      AHOversample * AVOversample larger than the default. For example, 2x2
      oversampling requires 4x the storage of 1x1.

      The maximum value of AHOversample or AVOversample is 8.

      For best results, render oversampled textures with bilinear filtering. }
    procedure SetOversampling(const AHOversample: Integer = 1;
      const AVOversample: Integer = 1);

    { Whether to skip any codepoints for which there is no corresponding glyph.
      If False (which is the default), then codepoints without a glyph received
      the font's "missing character" glyph, typically an empty box by convention. }
    property SkipMissingCodepoints: Boolean read GetSkipMissingCodepoints write SetSkipMissingCodepoints;

    { Horizontal oversampling value. See SetOversampling for details. }
    property HOversample: Integer read GetHOversample write SetHOversample;

    { Vertical oversampling value. See SetOversampling for details. }
    property VOversample: Integer read GetVOversample write SetVOversample;
  end;

  { Class for loading, rasterizing and retrieving information from TrueType and
    OpenType fonts.

    NOTE: Do *not* use this class with untrusted font files. This class does no
    range checking of the offsets found in the file, meaning an attacker can use
    it to read arbitrary memory.

    Use this class to:
    * Parse TrueType and OpenType files
    * Extract glyph metrics
    * Extract glyph shapes
    * Render glyphs to one-channel bitmaps with antialiasing (box filter)
    * Render glyphs to one-channel SDF bitmaps (signed-distance field/function)

    Some important concepts to understand to use this class:

    * Codepoint: Characters are defined by unicode codepoints, e.g. 65 is
      uppercase A, 231 is lowercase c with a cedilla, $7e30 is the hiragana
      for "ma".
    * Glyph: A visual character shape (every codepoint is rendered as some
      glyph).
    * Glyph index: A font-specific integer ID representing a glyph.
    * Baseline: Glyph shapes are defined relative to a baseline, which is the
      bottom of uppercase characters. Characters extend both above and below the
      baseline.
    * Current Point: As you draw text to the screen, you keep track of a
      "current point" which is the origin of each character. The current point's
      vertical position is the baseline. Even "baked fonts" use this model.
    * Vertical Font Metrics: The vertical qualities of the font, used to
      vertically position and space the characters. See GetFontVMetrics.
    * Font Size in Pixels or Points: The preferred interface for specifying font
      sizes is to specify how tall the font's vertical extent should be in
      pixels. Most other font APIs instead use "points", which are a common
      typographic measurement for describing font size, defined as 72 points per
      inch. This class provides a point API for compatibility. However, true
      "per inch" conventions don't make much sense on computer displays since
      different monitors have different number of pixels per inch. For example,
      Windows traditionally uses a convention that there are 96 pixels per inch,
      thus making 'inch' measurements have nothing to do with inches, and thus
      effectively defining a point to be 1.333 pixels. Additionally, the
      TrueType font data provides an explicit scale factor to scale a given
      font's glyphs to points, but the author has observed that this scale
      factor is often wrong for non-commercial fonts, thus making fonts scaled
      in points according to the TrueType spec incoherently sized in practice.

    Detailed usage:

    * Scale: Select how high you want the font to be, in points or pixels.
      Call ScaleForPixelHeight or ScaleForMappingEmToPixels to compute a scale
      factor SF that will be used by all other method.
    * Baseline: You need to select a y-coordinate that is the baseline of where
      your text will appear. Call GetBoundingBox to get the baseline-relative
      bounding box for all characters. SF*-Y0 will be the distance in pixels
      that the worst-case character could extend above the baseline, so if you
      want the top edge of characters to appear at the top of the screen where
      y=0, then you would set the baseline to SF*-Y0.
    * Current point: Set the current point where the first character will
      appear. The first character could extend left of the current point; this
      is font dependent. You can either choose a current point that is the
      leftmost point and hope, or add some padding, or check the bounding box or
      left-side-bearing of the first character to be displayed and set the
      current point based on that.
    * Displaying a character: Compute the bounding box of the character. It will
      contain signed values relative to <CurrentPoint, Baseline>. I.e. if it
      returns X0,Y0,X1,Y1, then the character should be displayed in the
      rectangle from <CurrentPoint+SF*X0, Baseline+SF*Y0> to
      <CurrentPoint+SF*X1, Baseline+SF*Y1>.
    * Advancing for the next character: Call GetGlyphHMetrics, and compute
      'CurrentPoint := CurrentPoint + SF * Advance'.

    Advanced usage:

    * Quality:
      * Use the functions with Subpixel at the end to allow your characters to
        have subpixel positioning. Since the font is anti-aliased, not hinted,
        this is very import for quality. (This is not possible with baked
        fonts.)
      * Kerning is now supported, and if you're supporting subpixel rendering
        then kerning is worth using to give your text a polished look.

    * Performance:
      * Convert Unicode codepoints to glyph indexes and operate on the glyphs;
        if you don't do this, TStbFont is forced to do the conversion on every
        call.

    Notes:

    The system uses the raw data found in the .ttf file without changing it and
    without building auxiliary data structures. This is a bit inefficient on
    little-endian systems (the data is big-endian), but assuming you're caching
    the bitmaps or glyph shapes this shouldn't be a big deal. }
  TStbFont = class
  {$REGION 'Internal Declarations'}
  private
    FBuffer: TBytes;
    FData: Pointer;
    FInfo: _stbtt_fontinfo;
    function GetFontCount: Integer; inline;
    function GetFontOffset(const AFontIndex: Integer): Integer; inline;
  private
    procedure Unload;
    function GetFontOffsetOrZero(const AFontIndex: Integer): Integer; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Loads a font from a file or memory.
      This only loads the font data into memory but does *not* parse and verify
      it. That only happens when the font is opened (using the Open) method
      or baked (using the Bake method). }
    function Load(const AFilename: String): Boolean; overload;
    function Load(const ABuffer: TBytes): Boolean; overload;

    { As above. AData *must* stay alive as long as the font is used. }
    function Load(const AData: Pointer; const ASize: Integer): Boolean; overload;
  public
    (************************************************************************)
    (** Quick & Dirty Texture Baking.                                      **)
    (** Do not use in production, but it's fine for tools and quick start. **)
    (************************************************************************)

    { Bakes a character range into a bitmap.
      APixelHeight is the height of the font in pixels.
      APixels, AWidth, and AHeight is the bitmap (1 bit per pixel) to be filled in.
      AFirstChar and ANumChars define the character (codepoint) range to bake.
      AFontIndex is an optional index of the font in case the font file contains
      multiple fonts.

      Returns information about the baked characters.

      If the length of Result.Chars is 0 then no characters fit and no rows were
      used.

      If the length of Result.Chars is less than ANumChars, then not all
      characters fit.

      This uses a very crappy packing. }
    function Bake(const APixelHeight: Single; const APixels: Pointer;
      const AWidth, AHeight: Integer; const AFirstChar: UCS4Char;
      const ANumChars: Integer; const AFontIndex: Integer = 0): TStbBakedCharacters; overload;
  public
    (************************************************************************)
    (** Improved Texture Baking.                                           **)
    (** This provides options for packing multiple fonts into one atlas.   **)
    (** Not perfect but better than nothing.                               **)
    (************************************************************************)

    { Creates a packing context for baking characters.

      APixels, AWidth, and AHeight is the bitmap (1 bit per pixel) to be filled in.
      The optional AStrideInBytes is the distance from one row to the next (or 0
      to mean they are packed tightly together).
      The opitional APadding is the amount of padding to leave between each
      character. Normally you want 1 (the default) for bitmaps you'll use as
      textures with bilinear filtering).

      Returns the packing context of nil on failure.
      You must free the returned context when done. }
    function Pack(const APixels: Pointer; const AWidth, AHeight: Integer;
      const AStrideInBytes: Integer = 0; const APadding: Integer = 1): TStbPackContext;
  public
    (************************************************************************)
    (** Font Information.                                                  **)
    (** This information is available without opening the font file first. **)
    (************************************************************************)

    { Query the font vertical metrics.

      ASize is the font size.
      AFontIndex is an optional index of the font in case the font file contains
      multiple fonts. }
    function GetScaledVMetrics(const ASize: Single;
      const AFontIndex: Integer = 0): TStbScaledVMetrics;

    { Returns the number of fonts in a font file.  TrueType collection (.ttc)
      files may contain multiple fonts, while TrueType font (.ttf) files only
      contain one font. If an error occurs, -1 is returned. }
    property FontCount: Integer read GetFontCount;

    { Each .ttf/.ttc file may have more than one font. Each font has a
      sequential index number starting from 0 up to FontCount - 1. This property
      returns the byte offset in the font file for AFontIndex, or -1 of the
      index is out of range.

      A regular .ttf file will only define one font and it always be at offset
      0, so it will return '0' for index 0, and -1 for all other indices. }
    property FontOffsets[const AFontIndex: Integer]: Integer read GetFontOffset;
  public
    (************************************************************************)
    (** Font Information.                                                  **)
    (** This information is available after opening the font file.         **)
    (************************************************************************)

    { Given a font index (from 0 to FontCount - 1), this method builds the
      necessary cached info for the rest of the system.
      Returns False on Failure.}
    function Open(const AFontIndex: Integer = 0): Boolean;

    { If you're going to perform multiple operations on the same character and
      you want a speed-up, call this method with the character you're going to
      process, then use glyph-based functions instead of the codepoint-based
      functions.
      Returns 0 if the character codepoint is not defined in the font. }
    function FindGlyphIndex(const AUnicodeCodepoint: UCS4Char): Integer; inline;

    { Computes a scale factor to produce a font whose "height" is APixels tall.
      Height is measured as the distance from the highest ascender to the lowest
      descender; in other words, it's equivalent to calling GetVMetrics and
      computing:
        Scale := APixels / (VMetrics.Ascent - VMetrics.Ddescent);
      so if you prefer to measure height by the ascent only, use a similar
      calculation. }
    function ScaleForPixelHeight(const APixels: Single): Single; inline;

    { Computes a scale factor to produce a font whose EM size is mapped to
      APixels tall. This is probably what traditional font APIs compute. }
    function ScaleForMappingEmToPixels(const APixels: Single): Single; inline;

    { Gets the vertical metrics of the font. }
    function GetVMetrics: TStbVMetrics; inline;

    { Analogous to GetVMetrics, but returns the "typographic" values from the
      OS/2 table (specific to MS/Windows TTF files).
      Returns False if the font file does not contain this table. }
    function GetVMetricsOS2(out AVMetrics: TStbVMetrics): Boolean; inline;

    { The bounding box around all possible characters }
    function GetBoundingBox: TStbBoundingBox; inline;

    { Get the horizontal metrics for the given codepoint }
    function GetCodepointHMetrics(const ACodepoint: UCS4Char): TStbHMetrics; inline;

    { Get the horizontal metrics for the given glyph index }
    function GetGlyphHMetrics(const AGlyphIndex: Integer): TStbHMetrics; inline;

    { Get the additional amount (kerning) to add to the 'advance' value between
      the two given codepoints. }
    function GetCodepointKernAdvance(const ACodepoint1, ACodepoint2: UCS4Char): Integer; inline;

    { Get the additional amount (kerning) to add to the 'advance' value between
      the two given glyph indices. }
    function GetGlyphKernAdvance(const AGlyphIndex1, AGlyphIndex2: Integer): Integer; inline;

    { Gets the bounding box of the visible part of the glyph for the given
      codepoint, in unscaled coordinates }
    function GetCodepointBox(const ACodepoint: UCS4Char): TStbBoundingBox; inline;

    { Gets the bounding box of the visible part of the glyph with the given
      index, in unscaled coordinates }
    function GetGlyphBox(const AGlyphIndex: Integer): TStbBoundingBox; inline;

    { Retrieves a complete list of all of the kerning pairs provided by the
      font. The table will be sorted by Glyph1 first and the by Glyph2. }
    function GetKerningTable: TArray<TStbKerningEntry>;

    { Returns True if nothing is drawn for the given glyph }
    function IsGlyphEmpty(const AGlyphIndex: Integer): Boolean; inline;

    { Returns the vertices of the glyph for the given codepoint, expressed in
      "unscaled" coordinates.

      The shape is a series of contours. Each one starts with a
      TStbVertexType.MoveTo, then consists of a series of mixed
      TStbVertexType.LineTo, TStbVertexType.CurveTo and/or
      TStbVertexType.CubicTo segments.
      A LineTo draws a line from previous endpoint to its (X, Y).
      A CurveTo draws a quadratic bezier from previous endpoint to its (X, Y),
      using (CX, CY) as the bezier control point.
      A CubicTo draws a cubic curve from previous endpoint to its (X, Y), using
      (CX, CY) and (CX1, CY1) as the control points.

      IMPORTANT: You must call FreeShape when you're done with the shape! }
    function GetCodepointShape(const ACodepoint: UCS4Char): TStbGlyphShape; inline;

    { As GetCodepointShape but uses a glyph index instead. }
    function GetGlyphShape(const AGlyphIndex: Integer): TStbGlyphShape; inline;

    { Frees the glyph shape returned by GetCodepointShape or GetGlyphShape. }
    procedure FreeShape(const AShape: TStbGlyphShape); inline;

    { Returns a pointer in the font data to the SVG document for the given
      glyph index, or nil of not found. }
    function FindSvgDoc(const AGlyphIndex: Integer): Pointer; inline;

    { Returns the SVG string for the given codepoint, or an empty string if not
      found. }
    function GetCodepointSvg(const ACodepoint: UCS4Char): String;

    { Returns the SVG string for the given glyph index, or an empty string if
      not found. }
    function GetGlyphSvg(const AGlyphIndex: Integer): String;

    { Allocates a large-enough single-channel 8bpp bitmap and renders the
      specified codepoint at the specified scale into it, with antialiasing.
      0 is no coverage (transparent), 255 is fully covered (opaque).

      IMPORTANT: You must TStbGlyphBitmap.Free when you're done with the bitmap! }
    function GetCodepointBitmap(const ACodepoint: UCS4Char; const AScaleX,
      AScaleY: Single): TStbGlyphBitmap; inline;

    { As GetCodepointBitmap but with a subpixel shift for the character. }
    function GetCodepointBitmapSubpixel(const ACodepoint: UCS4Char;
      const AScaleX, AScaleY, AShiftX, AShiftY: Single): TStbGlyphBitmap; inline;

    { As GetCodepointBitmap but you specify a pre-allocated bitmap. }
    procedure MakeCodepointBitmap(const ACodepoint: UCS4Char; const AScaleX,
      AScaleY: Single; const ATarget: TStbGlyphBitmap); inline;

    { As MakeCodepointBitmap but with a subpixel shift for the character. }
    procedure MakeCodepointBitmapSubpixel(const ACodepoint: UCS4Char;
      const AScaleX, AScaleY, AShiftX, AShiftY: Single;
      const ATarget: TStbGlyphBitmap); inline;

    { As MakeCodepointBitmapSubpixel but prefiltering is performed.
      See TStbPackContext.SetOversampling. }
    procedure MakeCodepointBitmapSubpixelPrefilter(const ACodepoint: UCS4Char;
      const AScaleX, AScaleY, AShiftX, AShiftY: Single; const AOversampleX,
      AOversampleY: Integer; out ASubX, ASubY: Single;
      const ATarget: TStbGlyphBitmap); inline;

    { Get the bounding box of the bitmap centered around the glyph origin. So
      the bitmap width is X1-X0, height is Y1-Y0, and location to place the
      bitmap top left is (LeftSideBearing * Scale,Y0).
      Note that the bitmap uses y-increases-down, but the shape uses
      y-increases-up, so GetCodepointBitmapBox and GetCodepointBox are inverted. }
    function GetCodepointBitmapBox(const ACodepoint: UCS4Char;
      const AScaleX, AScaleY: Single): TStbBoundingBox; inline;

    { As GetCodepointBitmapBox but with a subpixel shift for the character. }
    function GetCodepointBitmapBoxSubpixel(const ACodepoint: UCS4Char;
      const AScaleX, AScaleY, AShiftX, AShiftY: Single): TStbBoundingBox; inline;

    { As GetCodepointBitmap but uses a glyph index instead. }
    function GetGlyphBitmap(const AGlyphIndex: Integer; const AScaleX,
      AScaleY: Single): TStbGlyphBitmap; inline;

    { As GetCodepointBitmapSubpixel but uses a glyph index instead. }
    function GetGlyphBitmapSubpixel(const AGlyphIndex: Integer;
      const AScaleX, AScaleY, AShiftX, AShiftY: Single): TStbGlyphBitmap; inline;

    { As MakeCodepointBitmap but uses a glyph index instead. }
    procedure MakeGlyphBitmap(const AGlyphIndex: Integer; const AScaleX,
      AScaleY: Single; const ATarget: TStbGlyphBitmap); inline;

    { As MakeCodepointBitmapSubpixel but uses a glyph index instead. }
    procedure MakeGlyphBitmapSubpixel(const AGlyphIndex: Integer;
      const AScaleX, AScaleY, AShiftX, AShiftY: Single;
      const ATarget: TStbGlyphBitmap); inline;

    { As MakeCodepointBitmapSubpixelPrefilter but uses a glyph index instead. }
    procedure MakeGlyphBitmapSubpixelPrefilter(const AGlyphIndex: Integer;
      const AScaleX, AScaleY, AShiftX, AShiftY: Single; const AOversampleX,
      AOversampleY: Integer; out ASubX, ASubY: Single;
      const ATarget: TStbGlyphBitmap); inline;

    { As GetCodepointBitmapBox but uses a glyph index instead. }
    function GetGlyphBitmapBox(const AGlyphIndex: Integer;
      const AScaleX, AScaleY: Single): TStbBoundingBox; inline;

    { As GetCodepointBitmapBoxSubpixel but uses a glyph index instead. }
    function GetGlyphBitmapBoxSubpixel(const AGlyphIndex: Integer;
      const AScaleX, AScaleY, AShiftX, AShiftY: Single): TStbBoundingBox; inline;

    { Compute a discretized SDF field for a single character, suitable for
      storing in a single-channel texture, sampling with bilinear filtering, and
      testing against larger than some threshold to produce scalable fonts.

      Parameters:
        AScale: controls the size of the resulting SDF bitmap, same as it would
          be creating a regular bitmap
        ACodepoint: the character to generate the SDF for
        APadding: extra "pixels" around the character which are filled with the
          distance to the character (not 0), which allows effects like bit
          outlines
        AOnEdgeValue: value 0-255 to test the SDF against to reconstruct the
          character (i.e. the isocontour of the character)
        APixelDistScale: what value the SDF should increase by when moving one
          SDF "pixel" away from the edge (on the 0..255 scale).
          If positive, > AOnEdgeValue is inside; if negative, < AOnEdgeValue is
          inside

      Returns:
        The bitmap. You *MUST* free this bitmap when you're done with it!

      APixelDistScale and AOnEdgeValue are a scale & bias that allows you to
      make optimal use of the limited 0..255 for your application, trading off
      precision and special effects. SDF values outside the range 0..255 are
      clamped to 0..255.

      Example:
        AScale = ScaleForPixelHeight(22)
        APadding = 5
        AOnEdgeValue = 180
        APixelDistScale = 180/5.0 = 36.0

        This will create an SDF bitmap in which the character is about 22 pixels
        high but the whole bitmap is about 22+5+5=32 pixels high. To produce a
        filled shape, sample the SDF at each pixel and fill the pixel if the SDF
        value is greater than or equal to 180/255. (You'll actually want to
        antialias, which is beyond the scope of this example.) Additionally, you
        can compute offset outlines (e.g. to stroke the character border inside
        & outside, or only outside). For example, to fill outside the character
        up to 3 SDF pixels, you would compare against (180-36.0*3)/255 = 72/255.
        The above choice of variables maps a range from 5 pixels outside the
        shape to 2 pixels inside the shape to 0..255; this is intended primarily
        for apply outside effects only (the interior range is needed to allow
        proper antialiasing of the font at *smaller* sizes)

      This method function computes the SDF analytically at each SDF pixel, not
      by e.g. building a higher-res bitmap and approximating it. In theory the
      quality should be as high as possible for an SDF of this size and
      representation, but unclear if this is true in practice (perhaps building
      a higher-res bitmap and computing from that can allow drop-out prevention).

      The algorithm has not been optimized at all, so expect it to be slow
      if computing lots of characters or very large sizes. }
    function GetCodepointSdf(const ACodepoint: UCS4Char; const AScale: Single;
      const APadding: Integer; const AOnEdgeValue: Byte;
      const APixelDistScale: Single): TStbGlyphBitmap; inline;

    { As GetCodepointSdf but uses a glyph index instead. }
    function GetGlyphSdf(const AGlyphIndex: Integer; const AScale: Single;
      const APadding: Integer; const AOnEdgeValue: Byte;
      const APixelDistScale: Single): TStbGlyphBitmap; inline;

    { Number of glyphs in the font }
    property GlyphCount: Integer read FInfo.numGlyphs;
  end;

implementation

uses
  System.Classes;

type
  PStbPackRange = ^TStbPackRange;

{ TStbBakedCharacters }

function TStbBakedCharacters.GetQuad(const AChar: UCS4Char; var AXPos,
  AYPos: Single; const AOpenGLFillRule: Boolean): TStbAlignedQuad;
begin
  if (AChar < FirstChar) or (AChar >= (FirstChar + Cardinal(Length(Chars)))) then
    Exit(Default(TStbAlignedQuad));

  _stbtt_GetBakedQuad(Pointer(Chars), BitmapWidth, BitmapHeight,
    AChar - FirstChar, @AXPos, @AYPOs, @Result.FHandle, Ord(AOpenGLFillRule));
end;

function TStbBakedCharacters.GetQuadByIndex(const ACharIndex: Integer;
  var AXPos, AYPos: Single; const AOpenGLFillRule: Boolean): TStbAlignedQuad;
begin
  if (Cardinal(ACharIndex) >= Cardinal(Length(Chars))) then
    Exit(Default(TStbAlignedQuad));

  _stbtt_GetBakedQuad(Pointer(Chars), BitmapWidth, BitmapHeight,
    ACharIndex, @AXPos, @AYPOs, @Result.FHandle, Ord(AOpenGLFillRule));
end;

{ TStbPackedCharacters }

function TStbPackedCharacters.GetQuad(const AChar: UCS4Char; var AXPos,
  AYPos: Single; const AAlignToInteger: Boolean): TStbAlignedQuad;
begin
  if (FirstCharInRange = 0) or (AChar < FirstCharInRange) or (AChar >= (FirstCharInRange + Cardinal(Length(Chars)))) then
    Exit(Default(TStbAlignedQuad));

  _stbtt_GetPackedQuad(Pointer(Chars), BitmapWidth, BitmapHeight,
    AChar - FirstCharInRange, @AXPos, @AYPOs, @Result.FHandle,
    Ord(AAlignToInteger));
end;

function TStbPackedCharacters.GetQuadByIndex(const ACharIndex: Integer;
  var AXPos, AYPos: Single; const AAlignToInteger: Boolean): TStbAlignedQuad;
begin
  if (Cardinal(ACharIndex) >= Cardinal(Length(Chars))) then
    Exit(Default(TStbAlignedQuad));

  _stbtt_GetPackedQuad(Pointer(Chars), BitmapWidth, BitmapHeight,
    ACharIndex, @AXPos, @AYPOs, @Result.FHandle, Ord(AAlignToInteger));
end;

{ TStbFont }

function TStbFont.Bake(const APixelHeight: Single; const APixels: Pointer;
  const AWidth, AHeight: Integer; const AFirstChar: UCS4Char; const ANumChars,
  AFontIndex: Integer): TStbBakedCharacters;
begin
  if (ANumChars <= 0) then
    Exit(Default(TStbBakedCharacters));

  SetLength(Result.Chars, ANumChars);
  var PackResult := _stbtt_BakeFontBitmap(FData, GetFontOffsetOrZero(AFontIndex),
    APixelHeight, APixels, AWidth, AHeight, AFirstChar, ANumChars,
    Pointer(Result.Chars));

  if (PackResult = 0) then
    Exit(Default(TStbBakedCharacters));

  Result.BitmapWidth := AWidth;
  Result.BitmapHeight := AHeight;
  Result.FirstChar := AFirstChar;

  if (PackResult < 0) then
  begin
    Result.NextRowInBitmap := AHeight;
    PackResult := -PackResult;
    if (PackResult <> ANumChars) then
      SetLength(Result.Chars, PackResult);
  end
  else
    Result.NextRowInBitmap := PackResult;
end;

function TStbFont.FindGlyphIndex(const AUnicodeCodepoint: UCS4Char): Integer;
begin
  Result := _stbtt_FindGlyphIndex(@FInfo, AUnicodeCodepoint);
end;

function TStbFont.FindSvgDoc(const AGlyphIndex: Integer): Pointer;
begin
  Result := _stbtt_FindSVGDoc(@FInfo, AGlyphIndex);
end;

procedure TStbFont.FreeShape(const AShape: TStbGlyphShape);
begin
  _stbtt_FreeShape(@FInfo, AShape.FVertices);
end;

function TStbFont.GetBoundingBox: TStbBoundingBox;
begin
  _stbtt_GetFontBoundingBox(@FInfo, @Result.X0, @Result.Y0, @Result.X1, @Result.Y1);
end;

function TStbFont.GetCodepointBitmap(const ACodepoint: UCS4Char; const AScaleX,
  AScaleY: Single): TStbGlyphBitmap;
begin
  Result.FData := _stbtt_GetCodepointBitmap(@FInfo, AScaleX, AScaleY,
    ACodepoint, @Result.FWidth, @Result.FHeight, @Result.FXOffset, @Result.FYOffset);
  Result.FStride := 0;
  Result.FIsDelphiAllocated := False;
end;

function TStbFont.GetCodepointBitmapBox(const ACodepoint: UCS4Char;
  const AScaleX, AScaleY: Single): TStbBoundingBox;
begin
  _stbtt_GetCodepointBitmapBox(@FInfo, ACodepoint, AScaleX, AScaleY, @Result.X0,
    @Result.Y0, @Result.X1, @Result.Y1);
end;

function TStbFont.GetCodepointBitmapBoxSubpixel(const ACodepoint: UCS4Char;
  const AScaleX, AScaleY, AShiftX, AShiftY: Single): TStbBoundingBox;
begin
  _stbtt_GetCodepointBitmapBoxSubpixel(@FInfo, ACodepoint, AScaleX, AScaleY,
    AShiftX, AShiftY, @Result.X0, @Result.Y0, @Result.X1, @Result.Y1);
end;

function TStbFont.GetCodepointBitmapSubpixel(const ACodepoint: UCS4Char;
  const AScaleX, AScaleY, AShiftX, AShiftY: Single): TStbGlyphBitmap;
begin
  Result.FData := _stbtt_GetCodepointBitmapSubpixel(@FInfo, AScaleX, AScaleY,
    AShiftX, AShiftY, ACodepoint, @Result.FWidth, @Result.FHeight,
    @Result.FXOffset, @Result.FYOffset);
  Result.FStride := 0;
  Result.FIsDelphiAllocated := False;
end;

function TStbFont.GetCodepointBox(const ACodepoint: UCS4Char): TStbBoundingBox;
begin
  _stbtt_GetCodepointBox(@FInfo, ACodepoint, @Result.X0, @Result.Y0, @Result.X1, @Result.Y1);
end;

function TStbFont.GetCodepointHMetrics(
  const ACodepoint: UCS4Char): TStbHMetrics;
begin
  _stbtt_GetCodepointHMetrics(@FInfo, ACodepoint, @Result.AdvanceWidth, @Result.LeftSideBearing);
end;

function TStbFont.GetCodepointKernAdvance(const ACodepoint1,
  ACodepoint2: UCS4Char): Integer;
begin
  Result := _stbtt_GetCodepointKernAdvance(@FInfo, ACodepoint1, ACodepoint2);
end;

function TStbFont.GetCodepointSdf(const ACodepoint: UCS4Char;
  const AScale: Single; const APadding: Integer; const AOnEdgeValue: Byte;
  const APixelDistScale: Single): TStbGlyphBitmap;
begin
  Result.FData := _stbtt_GetCodepointSDF(@FInfo, AScale, ACodepoint, APadding,
    AOnEdgeValue, APixelDistScale, @Result.FWidth, @Result.FHeight,
    @Result.FXOffset, @Result.FYOffset);
  Result.FStride := 0;
  Result.FIsDelphiAllocated := False;
end;

function TStbFont.GetCodepointShape(const ACodepoint: UCS4Char): TStbGlyphShape;
begin
  Result.FCount := _stbtt_GetCodepointShape(@FInfo, ACodepoint, @Result.FVertices);
end;

function TStbFont.GetCodepointSvg(const ACodepoint: UCS4Char): String;
begin
  var Svg: PUTF8Char;
  var Len := _stbtt_GetCodepointSVG(@FInfo, ACodepoint, @Svg);
  if (Len = 0) then
    Exit('');

  var S: UTF8String;
  SetString(S, Svg, Len);
  Result := String(S);
end;

function TStbFont.GetFontCount: Integer;
begin
  Result := _stbtt_GetNumberOfFonts(FData);
end;

function TStbFont.GetFontOffset(const AFontIndex: Integer): Integer;
begin
  Result := _stbtt_GetFontOffsetForIndex(FData, AFontIndex);
end;

function TStbFont.GetFontOffsetOrZero(const AFontIndex: Integer): Integer;
begin
  Result := _stbtt_GetFontOffsetForIndex(FData, AFontIndex);
  if (Result < 0) then
    Result := 0;
end;

function TStbFont.GetGlyphBitmap(const AGlyphIndex: Integer; const AScaleX,
  AScaleY: Single): TStbGlyphBitmap;
begin
  Result.FData := _stbtt_GetGlyphBitmap(@FInfo, AScaleX, AScaleY,
    AGlyphIndex, @Result.FWidth, @Result.FHeight, @Result.FXOffset, @Result.FYOffset);
  Result.FStride := 0;
  Result.FIsDelphiAllocated := False;
end;

function TStbFont.GetGlyphBitmapBox(const AGlyphIndex: Integer; const AScaleX,
  AScaleY: Single): TStbBoundingBox;
begin
  _stbtt_GetGlyphBitmapBox(@FInfo, AGlyphIndex, AScaleX, AScaleY, @Result.X0,
    @Result.Y0, @Result.X1, @Result.Y1);
end;

function TStbFont.GetGlyphBitmapBoxSubpixel(const AGlyphIndex: Integer;
  const AScaleX, AScaleY, AShiftX, AShiftY: Single): TStbBoundingBox;
begin
  _stbtt_GetGlyphBitmapBoxSubpixel(@FInfo, AGlyphIndex, AScaleX, AScaleY,
    AShiftX, AShiftY, @Result.X0, @Result.Y0, @Result.X1, @Result.Y1);
end;

function TStbFont.GetGlyphBitmapSubpixel(const AGlyphIndex: Integer;
  const AScaleX, AScaleY, AShiftX, AShiftY: Single): TStbGlyphBitmap;
begin
  Result.FData := _stbtt_GetGlyphBitmapSubpixel(@FInfo, AScaleX, AScaleY,
    AShiftX, AShiftY, AGlyphIndex, @Result.FWidth, @Result.FHeight,
    @Result.FXOffset, @Result.FYOffset);
  Result.FStride := 0;
  Result.FIsDelphiAllocated := False;
end;

function TStbFont.GetGlyphBox(const AGlyphIndex: Integer): TStbBoundingBox;
begin
  _stbtt_GetGlyphBox(@FInfo, AGlyphIndex, @Result.X0, @Result.Y0, @Result.X1, @Result.Y1);
end;

function TStbFont.GetGlyphHMetrics(const AGlyphIndex: Integer): TStbHMetrics;
begin
  _stbtt_GetGlyphHMetrics(@FInfo, AGlyphIndex, @Result.AdvanceWidth, @Result.LeftSideBearing);
end;

function TStbFont.GetGlyphKernAdvance(const AGlyphIndex1,
  AGlyphIndex2: Integer): Integer;
begin
  Result := _stbtt_GetGlyphKernAdvance(@FInfo, AGlyphIndex1, AGlyphIndex2);
end;

function TStbFont.GetGlyphSdf(const AGlyphIndex: Integer; const AScale: Single;
  const APadding: Integer; const AOnEdgeValue: Byte;
  const APixelDistScale: Single): TStbGlyphBitmap;
begin
  Result.FData := _stbtt_GetGlyphSDF(@FInfo, AScale, AGlyphIndex, APadding,
    AOnEdgeValue, APixelDistScale, @Result.FWidth, @Result.FHeight,
    @Result.FXOffset, @Result.FYOffset);
  Result.FStride := 0;
  Result.FIsDelphiAllocated := False;
end;

function TStbFont.GetGlyphShape(const AGlyphIndex: Integer): TStbGlyphShape;
begin
  Result.FCount := _stbtt_GetGlyphShape(@FInfo, AGlyphIndex, @Result.FVertices);
end;

function TStbFont.GetGlyphSvg(const AGlyphIndex: Integer): String;
begin
  var Svg: PUTF8Char;
  var Len := _stbtt_GetGlyphSVG(@FInfo, AGlyphIndex, @Svg);
  if (Len = 0) then
    Exit('');

  var S: UTF8String;
  SetString(S, Svg, Len);
  Result := String(S);
end;

function TStbFont.GetKerningTable: TArray<TStbKerningEntry>;
begin
  var Count := _stbtt_GetKerningTableLength(@FInfo);
  if (Count = 0) then
    Exit(nil);

  SetLength(Result, Count);
  Count := _stbtt_GetKerningTable(@FInfo, Pointer(Result), Count);
  if (Count <> Length(Result)) then
    SetLength(Result, Count);
end;

function TStbFont.GetScaledVMetrics(const ASize: Single;
  const AFontIndex: Integer): TStbScaledVMetrics;
begin
  _stbtt_GetScaledFontVMetrics(FData, AFontIndex, ASize, @Result.Ascent,
    @Result.Descent, @Result.LineGap);
end;

function TStbFont.GetVMetrics: TStbVMetrics;
begin
  _stbtt_GetFontVMetrics(@FInfo, @Result.Ascent, @Result.Descent, @Result.LineGap);
end;

function TStbFont.GetVMetricsOS2(out AVMetrics: TStbVMetrics): Boolean;
begin
  Result := (_stbtt_GetFontVMetricsOS2(@FInfo, @AVMetrics.Ascent,
    @AVMetrics.Descent, @AVMetrics.LineGap) <> 0);
end;

function TStbFont.IsGlyphEmpty(const AGlyphIndex: Integer): Boolean;
begin
  Result := (_stbtt_IsGlyphEmpty(@FInfo, AGlyphIndex) <> 0);
end;

function TStbFont.Load(const ABuffer: TBytes): Boolean;
begin
  Unload;
  FBuffer := ABuffer;
  FData := Pointer(ABuffer);
  Result := Assigned(FData);
end;

function TStbFont.Load(const AData: Pointer; const ASize: Integer): Boolean;
begin
  Unload;
  FBuffer := nil;
  FData := AData;
  Result := Assigned(FData) and (ASize > 0);
end;

procedure TStbFont.MakeCodepointBitmap(const ACodepoint: UCS4Char;
  const AScaleX, AScaleY: Single; const ATarget: TStbGlyphBitmap);
begin
  if (ATarget.FData = nil) then
  begin
    Assert(False, 'No bitmap data');
    Exit;
  end;

  var Stride := ATarget.FStride;
  if (Stride = 0) then
    Stride := ATarget.FWidth;

  _stbtt_MakeCodepointBitmap(@FInfo, ATarget.FData, ATarget.FWidth,
    ATarget.FHeight, Stride, AScaleX, AScaleY, ACodepoint);
end;

procedure TStbFont.MakeCodepointBitmapSubpixel(const ACodepoint: UCS4Char;
  const AScaleX, AScaleY, AShiftX, AShiftY: Single;
  const ATarget: TStbGlyphBitmap);
begin
  if (ATarget.FData = nil) then
  begin
    Assert(False, 'No bitmap data');
    Exit;
  end;

  var Stride := ATarget.FStride;
  if (Stride = 0) then
    Stride := ATarget.FWidth;

  _stbtt_MakeCodepointBitmapSubpixel(@FInfo, ATarget.FData, ATarget.FWidth,
    ATarget.FHeight, Stride, AScaleX, AScaleY, AShiftX, AShiftY, ACodepoint);
end;

procedure TStbFont.MakeCodepointBitmapSubpixelPrefilter(
  const ACodepoint: UCS4Char; const AScaleX, AScaleY, AShiftX, AShiftY: Single;
  const AOversampleX, AOversampleY: Integer; out ASubX, ASubY: Single;
  const ATarget: TStbGlyphBitmap);
begin
  if (ATarget.FData = nil) then
  begin
    Assert(False, 'No bitmap data');
    Exit;
  end;

  var Stride := ATarget.FStride;
  if (Stride = 0) then
    Stride := ATarget.FWidth;

  _stbtt_MakeCodepointBitmapSubpixelPrefilter(@FInfo, ATarget.FData,
    ATarget.FWidth, ATarget.FHeight, Stride, AScaleX, AScaleY, AShiftX, AShiftY,
    AOversampleX, AOversampleY, @ASubX, @ASubY, ACodepoint);
end;

procedure TStbFont.MakeGlyphBitmap(const AGlyphIndex: Integer; const AScaleX,
  AScaleY: Single; const ATarget: TStbGlyphBitmap);
begin
  if (ATarget.FData = nil) then
  begin
    Assert(False, 'No bitmap data');
    Exit;
  end;

  var Stride := ATarget.FStride;
  if (Stride = 0) then
    Stride := ATarget.FWidth;

  _stbtt_MakeGlyphBitmap(@FInfo, ATarget.FData, ATarget.FWidth,
    ATarget.FHeight, Stride, AScaleX, AScaleY, AGlyphIndex);
end;

procedure TStbFont.MakeGlyphBitmapSubpixel(const AGlyphIndex: Integer;
  const AScaleX, AScaleY, AShiftX, AShiftY: Single;
  const ATarget: TStbGlyphBitmap);
begin
  if (ATarget.FData = nil) then
  begin
    Assert(False, 'No bitmap data');
    Exit;
  end;

  var Stride := ATarget.FStride;
  if (Stride = 0) then
    Stride := ATarget.FWidth;

  _stbtt_MakeGlyphBitmapSubpixel(@FInfo, ATarget.FData, ATarget.FWidth,
    ATarget.FHeight, Stride, AScaleX, AScaleY, AShiftX, AShiftY, AGlyphIndex);
end;

procedure TStbFont.MakeGlyphBitmapSubpixelPrefilter(const AGlyphIndex: Integer;
  const AScaleX, AScaleY, AShiftX, AShiftY: Single; const AOversampleX,
  AOversampleY: Integer; out ASubX, ASubY: Single;
  const ATarget: TStbGlyphBitmap);
begin
  if (ATarget.FData = nil) then
  begin
    Assert(False, 'No bitmap data');
    Exit;
  end;

  var Stride := ATarget.FStride;
  if (Stride = 0) then
    Stride := ATarget.FWidth;

  _stbtt_MakeGlyphBitmapSubpixelPrefilter(@FInfo, ATarget.FData,
    ATarget.FWidth, ATarget.FHeight, Stride, AScaleX, AScaleY, AShiftX, AShiftY,
    AOversampleX, AOversampleY, @ASubX, @ASubY, AGlyphIndex);
end;

function TStbFont.Open(const AFontIndex: Integer): Boolean;
begin
  Result := (_stbtt_InitFont(@FInfo, Pointer(FData),
    GetFontOffsetOrZero(AFontIndex)) <> 0);
end;

function TStbFont.Pack(const APixels: Pointer; const AWidth, AHeight,
  AStrideInBytes, APadding: Integer): TStbPackContext;
begin
  var Context: _stbtt_pack_context;
  if (_stbtt_PackBegin(@Context, APixels, AWidth, AHeight, AStrideInBytes,
    APadding, nil) = 0)
  then
    Exit(nil);

  Result := TStbPackContext.Create(Self, Context);
end;

function TStbFont.ScaleForMappingEmToPixels(const APixels: Single): Single;
begin
  Result := _stbtt_ScaleForMappingEmToPixels(@FInfo, APixels);
end;

function TStbFont.ScaleForPixelHeight(const APixels: Single): Single;
begin
  Result := _stbtt_ScaleForPixelHeight(@FInfo, APixels);
end;

function TStbFont.Load(const AFilename: String): Boolean;
begin
  var Buffer: TBytes;
  try
    var Stream := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyWrite);
    try
      SetLength(Buffer, Stream.Size);
      Stream.ReadBuffer(Buffer, Length(Buffer));
    finally
      Stream.Free;
    end;
    Result := Load(Buffer);
  except
    Result := False;
  end;
end;

procedure TStbFont.Unload;
begin
  FBuffer := nil;
  FData := nil;
  FillChar(FInfo, SizeOf(FInfo), 0);
end;

{ TStbPackContext }

constructor TStbPackContext.Create(const AFont: TStbFont;
  const AContext: _stbtt_pack_context);
begin
  inherited Create;
  FFont := AFont;
  FContext := AContext;
end;

destructor TStbPackContext.Destroy;
begin
  _stbtt_PackEnd(@FContext);
  inherited;
end;

function TStbPackContext.GetHOversample: Integer;
begin
  Result := FContext.h_oversample;
end;

function TStbPackContext.GetSkipMissingCodepoints: Boolean;
begin
  Result := (FContext.skip_missing <> 0);
end;

function TStbPackContext.GetVOversample: Integer;
begin
  Result := FContext.v_oversample;
end;

function TStbPackContext.PackRange(const AFontSize: Single;
  const AFirstCharInRange: UCS4Char; const ANumCharsInRange,
  AFontIndex: Integer): TStbPackedCharacters;
begin
  SetLength(Result.Chars, ANumCharsInRange);
  if (_stbtt_PackFontRange(@FContext, FFont.FData, AFontIndex, AFontSize,
    AFirstCharInRange, ANumCharsInRange, Pointer(Result.Chars)) = 0)
  then
    Exit(Default(TStbPackedCharacters));

  Result.BitmapWidth := FContext.width;
  Result.BitmapHeight := FContext.height;
  Result.FirstCharInRange := AFirstCharInRange;
end;

function TStbPackContext.PackRanges(const ARanges: TArray<TStbPackRange>;
  const AFontIndex: Integer): TArray<TStbPackedCharacters>;
begin
  if (ARanges = nil) then
    Exit(nil);

  var DstRanges: TArray<_stbtt_pack_range>;
  SetLength(DstRanges, Length(ARanges));
  SetLength(Result, Length(ARanges));

  var Src := PStbPackRange(ARanges);
  var Dst := _Pstbtt_pack_range(DstRanges);

  for var I := 0 to Length(ARanges) - 1 do
  begin
    Dst.font_size := Src.FontSize;

    if (Src.ArrayOfChars = nil) then
    begin
      Dst.first_unicode_codepoint_in_range := Src.FirstCharInRange;
      Dst.num_chars := Src.NumCharsInRange;
    end
    else
    begin
      Dst.array_of_unicode_codepoints := Pointer(Src.ArrayOfChars);
      Dst.num_chars := Length(Src.ArrayOfChars);
    end;

    SetLength(Result[I].Chars, Dst.num_chars);
    Dst.chardata_for_range := Pointer(Result[I].Chars);

    Inc(Src);
    Inc(Dst);
  end;

  if (_stbtt_PackFontRanges(@FContext, FFont.FData, AFontIndex,
    Pointer(DstRanges), Length(DstRanges)) = 0)
  then
    Exit(nil);

  for var I := 0 to Length(Result) - 1 do
  begin
    Result[I].BitmapWidth := FContext.width;
    Result[I].BitmapHeight := FContext.height;

    if (ARanges[I].ArrayOfChars = nil) then
      Result[I].FirstCharInRange := ARanges[I].FirstCharInRange;
  end;
end;

procedure TStbPackContext.SetHOversample(const AValue: Integer);
begin
  _stbtt_PackSetOversampling(@FContext, AValue, FContext.v_oversample);
end;

procedure TStbPackContext.SetOversampling(const AHOversample,
  AVOversample: Integer);
begin
  _stbtt_PackSetOversampling(@FContext, AHOversample, AVOversample);
end;

procedure TStbPackContext.SetSkipMissingCodepoints(const AValue: Boolean);
begin
  _stbtt_PackSetSkipMissingCodepoints(@FContext, Ord(AValue));
end;

procedure TStbPackContext.SetVOversample(const AValue: Integer);
begin
  _stbtt_PackSetOversampling(@FContext, FContext.h_oversample, AValue);
end;

{ TStbVertex }

function TStbVertex.GetKind: TStbVertexKind;
begin
  Result := TStbVertexKind(FHandle.&type);
end;

{ TStbGlyphShape }

function TStbGlyphShape.GetVertex(const AIndex: Integer): PStbVertex;
begin
  Assert(Cardinal(AIndex) < Cardinal(FCount));
  Result := PStbVertex(FVertices);
  Inc(Result, AIndex);
end;

{ TStbGlyphBitmap }

constructor TStbGlyphBitmap.Create(const AWidth, AHeight, AStride: Integer);
begin
  Assert(AWidth > 0);
  Assert(AHeight > 0);
  Assert((AStride = 0) or (AStride >= AWidth));

  if (AStride = 0) then
    GetMem(FData, AWidth * AHeight)
  else
    GetMem(FData, AStride * AHeight);

  FWidth := AWidth;
  FHeight := AHeight;
  FXOffset := 0;
  FYOffset := 0;
  FStride := AStride;
  FIsDelphiAllocated := True;
end;

procedure TStbGlyphBitmap.Free;
begin
  if (FIsDelphiAllocated) then
    FreeMem(FData)
  else
    _stbtt_FreeBitmap(FData, nil);
  FData := nil;
  FIsDelphiAllocated := False;
end;

end.

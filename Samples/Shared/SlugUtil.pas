unit SlugUtil;
{ Slug utility functions.
  NOTE: memory management during font loading is *really* unoptimized.
  PS: should the font processing actually be moved into an offline tool? }

interface

uses
  System.Math,
  System.Generics.Defaults,
  System.Generics.Collections,
  Neslib.FastMath,
  Neslib.Stb.TrueType,
  Neslib.Sokol.Gfx;

const
  SLUG_TEX_SHIFT = 12;
  SLUG_TEX_WIDTH = 1 shl SLUG_TEX_SHIFT;
  SLUG_TEX_MASK  = SLUG_TEX_WIDTH - 1;
  SLUG_MAX_BANDS = 16;

type
  TSlugRange = record
  public
    Ptr: Pointer;
    Size: NativeInt;
  public
    constructor Create(const APointer: Pointer; const ASize: NativeInt);
  end;

type
  TSlugBBox = record
  public
    X0: Single;
    Y0: Single;
    X1: Single;
    Y1: Single;
  end;

type
  TSlugGlyph = record
  public
    BBox: TSlugBBox;
    Advance: Single;
    Lsb: Single;
    MaxBandX: Integer;
    MaxBandY: Integer;
    BandScale: TVector2;
    BandOffset: TVector2;
    GlyphLoc: array [0..1] of Integer;
  end;
  PSlugGlyph = ^TSlugGlyph;

type
  TSlugColorLayer = packed record
  public
    GlyphId: UInt16;
    PaletteIndex: UInt16;
  end;

type
  TSlugColorBase = packed record
  public class var
    GComparer: IComparer<TSlugColorBase>;
  public
    class constructor Create;
  public
    GlyphId: UInt16;
    FirstLayer: UInt16;
    NumLayers: UInt16;
    _Pad: UInt16;
  end;
  PSlugColorBase = ^TSlugColorBase;

type
  TSlugCurve = packed record
  public
    P: array [0..2] of TVector2;
    Texture: array [0..1] of UInt16;
  end;
  PSlugCurve = ^TSlugCurve;

type
  TSlugContourRange = record
  public
    Start: Integer;
    Count: Integer;
  end;
  PSlugContourRange = ^TSlugContourRange;

type
  TSlugBandEntry = record
  public class var
    GComparer: IComparer<TSlugBandEntry>;
  public
    class constructor Create;
  public
    CurveIndex: Integer;
    SortKey: Single;
  end;
  PSlugBandEntry = ^TSlugBandEntry;

type
  TSlugGlyphBuild = class
  {$REGION 'Internal Declarations'}
  private
    FCurves: TList<TSlugCurve>;
    FContours: TList<TSlugContourRange>;
    FBBox: TSlugBBox;
    FAdvance: Single;
    FLsb: Single;
    FHorizontalBands: TObjectList<TList<TSlugBandEntry>>;
    FVerticalBands: TObjectList<TList<TSlugBandEntry>>;
    FBandScale: TVector2;
    FBandOffset: TVector2;
    FGlyphLoc: array [0..1] of Integer;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AFont: TStbFont; const AGlyphIndex: Integer;
      const AEMScale: Single);
    destructor Destroy; override;

    procedure BuildBands;
  end;

type
  TSlugFont = class
  {$REGION 'Internal Declarations'}
  private type
    TCurveOrBand = record
    public
      Image: TImage;
      TexView: TView;
      Height: Integer;
    public
      procedure Free;
    end;
  private
    FValid: Boolean;
    FGlyphs: TList<TSlugGlyph>;
    FFont: TStbFont;
    FCurve: TCurveOrBand;
    FBand: TCurveOrBand;
    FCPalColors: TList<TVector4>;
    FColorBases: TList<TSlugColorBase>;
    FColorLayers: TList<TSlugColorLayer>;
    function GetColorLayer(const AIndex: Integer): TSlugColorLayer; inline;
    function GetGlyphCount: Integer; inline;
    function GetSlugGlyph(const AIndex: Integer): PSlugGlyph; inline;
    function GetPaletteColorCount: Integer; inline;
    function GetPaletteColor(const AIndex: Integer): TVector4; inline;
  private
    class function MakeTag(const AFourCC: PAnsiChar): UInt32; static;
    class function FindOtfTable(const AData: TSlugRange;
      const ATag: UInt32): Integer; static;
    class function ReadU16BE(const AData: TSlugRange;
      const AOffset: NativeInt): UInt16; static;
    class function ReadU32BE(const AData: TSlugRange;
      const AOffset: NativeInt): UInt32; static;
  private
    function ParseColrV0(const AData: TSlugRange): Boolean;
    function ParseCPal(const AData: TSlugRange): Boolean;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    function Load(const AData: TSlugRange): Boolean;
    procedure Unload;

    function GetGlyph(const ACodepoint: UInt32): PSlugGlyph;
    function FindColorBase(const ACodepoint: UInt32): PSlugColorBase;

    property Valid: Boolean read FValid;
    property CurveTexView: TView read FCurve.TexView;
    property BandTexView: TView read FBand.TexView;
    property ColorLayers[const AIndex: Integer]: TSlugColorLayer read GetColorLayer;
    property GlyphCount: Integer read GetGlyphCount;
    property Glyphs[const AIndex: Integer]: PSlugGlyph read GetSlugGlyph;
    property PaletteColorCount: Integer read GetPaletteColorCount;
    property PaletteColors[const AIndex: Integer]: TVector4 read GetPaletteColor;
  end;

implementation

uses
  Neslib.Sokol.Api;

type
  TU16Vector2 = packed record
  public
    X: UInt16;
    Y: UInt16;
  end;

type
  TPackTextures = class
  private
    FCurvePixels: TList<TVector4>;
    FCurveHeight: Integer;
    FBandPixels: TList<TU16Vector2>;
    FBandHeight: Integer;
  private
    procedure PadToRowCurvePixels(const ANeeded: Integer);
    procedure PadToRowBandPixels(const ANeeded: Integer);
    procedure WriteBandSet(const ABands: TObjectList<TList<TSlugBandEntry>>;
      const ACurves: TList<TSlugCurve>; const AGlyphStart,
      AHeaderOffset: Integer; var AWriteOffset: NativeInt);
    procedure FinalizeCurvePixels;
    procedure FinalizeBandPixels;
  public
    constructor Create(const AGlyphs: TObjectList<TSlugGlyphBuild>);
    destructor Destroy; override;
  end;

{ TSlugRange }

constructor TSlugRange.Create(const APointer: Pointer; const ASize: NativeInt);
begin
  Ptr := APointer;
  Size := ASize;
end;

{ TSlugGlyphBuild }

procedure TSlugGlyphBuild.BuildBands;
begin
  var NumCurves := FCurves.Count;
  if (NumCurves = 0) then
    Exit;

  var BandWidth: Single := Max(FBBox.X1 - FBBox.X0, 1);
  var BandHeight: Single := Max(FBBox.Y1 - FBBox.Y0, 1);
  var NumberOfBandsHeight := EnsureRange(NumCurves, 1, SLUG_MAX_BANDS);
  var NumberOfBandsWidth := EnsureRange(NumCurves, 1, SLUG_MAX_BANDS);

  FHorizontalBands.Count := NumberOfBandsHeight;
  for var I := 0 to NumberOfBandsHeight - 1 do
  begin
    if (FHorizontalBands[I] = nil) then
      FHorizontalBands[I] := TList<TSlugBandEntry>.Create;
  end;

  FVerticalBands.Count := NumberOfBandsWidth;
  for var I := 0 to NumberOfBandsWidth - 1 do
  begin
    if (FVerticalBands[I] = nil) then
      FVerticalBands[I] := TList<TSlugBandEntry>.Create;
  end;

  FBandScale.Init(NumberOfBandsWidth / BandWidth, NumberOfBandsHeight / BandHeight);
  FBandOffset.Init(-FBBox.X0 * FBandScale.X, -FBBox.Y0 * FBandScale.Y);

  var HorizontalBandHeight: Single := BandHeight / NumberOfBandsHeight;
  var VerticalBandWidth: Single := BandWidth / NumberOfBandsWidth;
  var HorizontalPad: Single := HorizontalBandHeight * 0.5;
  var VerticalPad: Single := VerticalBandWidth * 0.5;

  var BandFirst, BandLast: Integer;
  var Curve := PSlugCurve(FCurves.List);
  var Entry: TSlugBandEntry;
  for var CurveIndex := 0 to FCurves.Count - 1 do
  begin
    var CurveMin := Min(Min(Curve.P[0], Curve.P[1]), Curve.P[2]);
    var CurveMax := Max(Max(Curve.P[0], Curve.P[1]), Curve.P[2]);

    BandFirst := EnsureRange(
      Floor((CurveMin.Y - HorizontalPad - FBBox.Y0) / HorizontalBandHeight),
      0, NumberOfBandsHeight - 1);

    BandLast := EnsureRange(
      Floor((CurveMax.Y + HorizontalPad - FBBox.Y0) / HorizontalBandHeight),
      0, NumberOfBandsHeight - 1);

    for var I := BandFirst to BandLast do
    begin
      Entry.CurveIndex := CurveIndex;
      Entry.SortKey := CurveMax.X;
      FHorizontalBands[I].Add(Entry);
    end;

    BandFirst := EnsureRange(
      Floor((CurveMin.X - VerticalPad - FBBox.X0) / VerticalBandWidth),
      0, NumberOfBandsWidth - 1);

    BandLast := EnsureRange(
      Floor((CurveMax.X + VerticalPad - FBBox.X0) / VerticalBandWidth),
      0, NumberOfBandsWidth - 1);

    for var I := BandFirst to BandLast do
    begin
      Entry.CurveIndex := CurveIndex;
      Entry.SortKey := CurveMax.Y;
      FVerticalBands[I].Add(Entry);
    end;

    Inc(Curve);
  end;

  for var I := 0 to FHorizontalBands.Count - 1 do
    FHorizontalBands[I].Sort(TSlugBandEntry.GComparer);

  for var I := 0 to FVerticalBands.Count - 1 do
    FVerticalBands[I].Sort(TSlugBandEntry.GComparer);
end;

constructor TSlugGlyphBuild.Create(const AFont: TStbFont;
  const AGlyphIndex: Integer; const AEMScale: Single);
const
  T = 1 / 3;
begin
  inherited Create;
  FCurves := TList<TSlugCurve>.Create;
  FContours := TList<TSlugContourRange>.Create;
  FHorizontalBands := TObjectList<TList<TSlugBandEntry>>.Create;
  FVerticalBands := TObjectList<TList<TSlugBandEntry>>.Create;

  var Metrics := AFont.GetGlyphHMetrics(AGlyphIndex);
  FAdvance := Metrics.AdvanceWidth * AEMScale;
  FLsb := Metrics.LeftSideBearing * AEMScale;

  var Box := AFont.GetGlyphBox(AGlyphIndex);
  FBBox.X0 := Box.X0 * AEMScale;
  FBBox.Y0 := Box.Y0 * AEMScale;
  FBBox.X1 := Box.X1 * AEMScale;
  FBBox.Y1 := Box.Y1 * AEMScale;

  var Shape := AFont.GetGlyphShape(AGlyphIndex);
  try
    var InContour := False;
    var ContourStart := 0;
    var Previous := TVector2.Zero;

    var Curve: TSlugCurve;
    var ContourRange: TSlugContourRange;

    for var I := 0 to Shape.Count - 1 do
    begin
      var Vert := Shape[I];
      case Vert.Kind of
        TStbVertexKind.MoveTo:
          begin
            if (InContour) then
            begin
              var Count := FCurves.Count - ContourStart;
              if (Count > 0) then
              begin
                ContourRange.Start := ContourStart;
                ContourRange.Count := Count;
                FContours.Add(ContourRange);
              end;
            end;
             Previous.Init(Vert.x * AEMScale, Vert.y * AEMScale);
            ContourStart := FCurves.Count;
            InContour := True;
          end;

        TStbVertexKind.LineTo:
          begin
            var Current := Vector2(Vert.x * AEMScale, Vert.y * AEMScale);
            Curve.P[0] := Previous;
            Curve.P[1] := (Previous + Current) * 0.5;
            Curve.P[2] := Current;
            FCurves.Add(Curve);
            Previous := Current;
          end;

        TStbVertexKind.CurveTo:
          begin
            var Current := Vector2(Vert.x * AEMScale, Vert.y * AEMScale);
            Curve.P[0] := Previous;
            Curve.P[1] := Vector2(Vert.cx * AEMScale, Vert.cy * AEMScale);
            Curve.P[2] := Current;
            FCurves.Add(Curve);
            Previous := Current;
          end;

        TStbVertexKind.CubicTo:
          begin
            { Approximate with three quadratic Beziers:
              Split cubic P0,C1,C2,P3 at t=1/3 and t=2/3 via de Casteljau.
              Then approximate each sub-cubic as a quadratic with ctrl=(c1+c2)/2. }
            var P3 := Vector2(Vert.x * AEMScale, Vert.y * AEMScale);
            var C1 := Vector2(Vert.cx * AEMScale, Vert.cy * AEMScale);
            var C2 := Vector2(Vert.cx1 * AEMScale, Vert.cy1 * AEMScale);
            var P0 := Previous;

            { De Casteljau split at t=1/3 }
            var AB := P0 + ((C1 - P0) * T);
            var BC := C1 + ((C2 - C1) * T);
            var CD := C2 + ((P3 - C2) * T);
            var ABC := AB + ((BC - AB) * T);
            var BCD := BC + ((CD - BC) * T);

            { Point on curve at T=1/3 }
            var E1 := ABC + ((BCD - ABC) * T);

            { Sub-cubic 1: p0, ab, abc, e1 -> quadratic ctrl = (ab + abc) * 0.5 }
            var Q1 := (AB + ABC) * 0.5;

            { De Casteljau split remaining cubic (e1, bcd, cd, p3) at t=0.5
              (= t=2/3 of original) }
            var AB2 := E1 + ((BCD - E1) * 0.5);
            var BC2 := BCD + ((CD - BCD) * 0.5);
            var CD2 := CD + ((P3 - CD) * 0.5);
            var ABC2 := AB2 + ((BC2 - AB2) * 0.5);
            var BCD2 := BC2 + ((CD2 - BC2) * 0.5);

            { point on curve at t=2/3 }
            var E2 := ABC2 + ((BCD2 - ABC2) * 0.5);

            { Sub-cubic 2: e1, ab2, abc2, e2 -> quadratic ctrl = (ab2 + abc2) * 0.5 }
            var Q2 := (AB2 + ABC2) * 0.5;
            var Q3 := (BCD2 + CD2) * 0.5;

            Curve.P[0] := P0;
            Curve.P[1] := Q1;
            Curve.P[2] := E1;
            FCurves.Add(Curve);

            Curve.P[0] := E1;
            Curve.P[1] := Q2;
            Curve.P[2] := E2;
            FCurves.Add(Curve);

            Curve.P[0] := E2;
            Curve.P[1] := Q3;
            Curve.P[2] := P3;
            FCurves.Add(Curve);

            Previous := P3;
          end;
      end;
    end;

    if (InContour) then
    begin
      var Count := FCurves.Count - ContourStart;
      if (Count > 0) then
      begin
        ContourRange.Start := ContourStart;
        ContourRange.Count := Count;
        FContours.Add(ContourRange);
      end;
    end;
  finally
    AFont.FreeShape(Shape);
  end;
end;

destructor TSlugGlyphBuild.Destroy;
begin
  FVerticalBands.Free;
  FHorizontalBands.Free;
  FContours.Free;
  FCurves.Free;
  inherited;
end;

{ TSlugFont }

constructor TSlugFont.Create;
begin
  inherited;
  FFont := TStbFont.Create;
  FGlyphs := TList<TSlugGlyph>.Create;
  FCPalColors := TList<TVector4>.Create;
  FColorBases := TList<TSlugColorBase>.Create;
  FColorLayers := TList<TSlugColorLayer>.Create;
end;

destructor TSlugFont.Destroy;
begin
  Unload;
  FColorLayers.Free;
  FColorBases.Free;
  FCPalColors.Free;
  FGlyphs.Free;
  FFont.Free;
  inherited;
end;

function TSlugFont.FindColorBase(const ACodepoint: UInt32): PSlugColorBase;
begin
  var Idx := FFont.FindGlyphIndex(ACodepoint);
  if (Idx <= 0) then
    Exit(nil);

  var Num := FColorBases.Count;
  if (Num = 0) then
    Exit(nil);

  var Key: TSlugColorBase;
  Key.GlyphId := Idx;

  var FoundIndex: NativeInt;
  if (not FColorBases.BinarySearch(Key, FoundIndex, TSlugColorBase.GComparer)) then
    Exit(nil);

  Result := PSlugColorBase(FColorBases.List);
  Inc(Result, FoundIndex);
end;

class function TSlugFont.FindOtfTable(const AData: TSlugRange;
  const ATag: UInt32): Integer;
begin
  if (AData.Size < 12) then
    Exit(-1);

  var NumTables: Integer := ReadU16BE(AData, 4);
  for var I := 0 to NumTables - 1 do
  begin
    var RecordOffset := 12 + (I * 16);
    if ((RecordOffset + 16) > AData.Size) then
      Break;

    var RecordTag := ReadU32BE(AData, RecordOffset);
    if (RecordTag = ATag) then
      Exit(ReadU32BE(AData, RecordOffset + 8));
  end;

  Result := -1;
end;

function TSlugFont.GetColorLayer(const AIndex: Integer): TSlugColorLayer;
begin
  Result := FColorLayers[AIndex];
end;

function TSlugFont.GetGlyph(const ACodepoint: UInt32): PSlugGlyph;
begin
  var Idx := FFont.FindGlyphIndex(ACodepoint);
  if (Cardinal(Idx) < Cardinal(FGlyphs.Count)) then
  begin
    Result := PSlugGlyph(FGlyphs.List);
    Inc(Result, Idx);
  end
  else
    Result := nil;
end;

function TSlugFont.GetGlyphCount: Integer;
begin
  Result := FGlyphs.Count;
end;

function TSlugFont.GetPaletteColor(const AIndex: Integer): TVector4;
begin
  Result := FCPalColors[AIndex];
end;

function TSlugFont.GetPaletteColorCount: Integer;
begin
  Result := FCPalColors.Count;
end;

function TSlugFont.GetSlugGlyph(const AIndex: Integer): PSlugGlyph;
begin
  Result := PSlugGlyph(FGlyphs.List);
  Inc(Result, AIndex);
end;

function TSlugFont.Load(const AData: TSlugRange): Boolean;
begin
  Assert((AData.Ptr <> nil) and (AData.Size > 0));
  Assert(not FValid);

  if (not FFont.Load(AData.Ptr, AData.Size)) then
  begin
    Unload;
    Exit(False);
  end;

  if (not FFont.Open) then
  begin
    Unload;
    Exit(False);
  end;

  var EMScale: Single := FFont.ScaleForMappingEmToPixels(1);

  { Colored emoji-fonts... }
  if (not ParseColrV0(AData)) then
  begin
    Unload;
    Exit(False);
  end;

  if (not ParseCPal(AData)) then
  begin
    Unload;
    Exit(False);
  end;

  var BuildGlyphs := TObjectList<TSlugGlyphBuild>.Create;
  try
    BuildGlyphs.Count := FFont.GlyphCount;
    for var I := 0 to BuildGlyphs.Count - 1 do
    begin
      BuildGlyphs[I] := TSlugGlyphBuild.Create(FFont, I, EMScale);
      BuildGlyphs[I].BuildBands;
    end;

    var Res := TPackTextures.Create(BuildGlyphs);
    try
      FCurve.Height := Res.FCurveHeight;
      FBand.Height := Res.FBandHeight;

      var ImgDesc := TImageDesc.Create;
      ImgDesc.Width := SLUG_TEX_WIDTH;
      ImgDesc.Height := FCurve.Height;
      ImgDesc.PixelFormat := TPixelFormat.Rgba32F;
      ImgDesc.Data.MipLevels[0].Data := Res.FCurvePixels.List;
      ImgDesc.Data.MipLevels[0].Size := Res.FCurvePixels.Count * SizeOf(TVector4);
      FCurve.Image := TImage.Create(ImgDesc);

      var ViewDesc := TViewDesc.Create;
      ViewDesc.Texture.Image := FCurve.Image;
      FCurve.TexView := TView.Create(ViewDesc);

      ImgDesc.Init;
      ImgDesc.Width := SLUG_TEX_WIDTH;
      ImgDesc.Height := FBand.Height;
      ImgDesc.PixelFormat := TPixelFormat.Rg16UI;
      ImgDesc.Data.MipLevels[0].Data := Res.FBandPixels.List;
      ImgDesc.Data.MipLevels[0].Size := Res.FBandPixels.Count * SizeOf(TU16Vector2);
      FBand.Image := TImage.Create(ImgDesc);

      ViewDesc.Init;
      ViewDesc.Texture.Image := FBand.Image;
      FBand.TexView := TView.Create(ViewDesc);

      var NumGlyphs := BuildGlyphs.Count;
      FGlyphs.Count := NumGlyphs;
      var Glyph := PSlugGlyph(FGlyphs.List);
      for var I := 0 to NumGlyphs - 1 do
      begin
        var BG := BuildGlyphs[I];
        Glyph.BBox := BG.FBBox;
        Glyph.Advance := BG.FAdvance;
        Glyph.Lsb := BG.FLsb;
        Glyph.MaxBandX := BG.FVerticalBands.Count - 1;
        Glyph.MaxBandY := BG.FHorizontalBands.Count - 1;
        Glyph.BandScale := BG.FBandScale;
        Glyph.BandOffset := BG.FBandOffset;
        Glyph.GlyphLoc[0] := BG.FGlyphLoc[0];
        Glyph.GlyphLoc[1] := BG.FGlyphLoc[1];
        Inc(Glyph);
      end;
    finally
      Res.Free;
    end;
  finally
    BuildGlyphs.Free;
  end;
  FValid := True;
  Result := True;
end;

class function TSlugFont.MakeTag(const AFourCC: PAnsiChar): UInt32;
begin
  Result := (Ord(AFourCC[0]) shl 24) or (Ord(AFourCC[1]) shl 16)
    or (Ord(AFourCC[2]) shl 8) or Ord(AFourCC[3]);
end;

function TSlugFont.ParseColrV0(const AData: TSlugRange): Boolean;
begin
  var TableOffset := FindOtfTable(AData, MakeTag('COLR'));
  if (TableOffset < 0) then
    { COLR table is optional }
    Exit(True);

  var Version := ReadU16BE(AData, TableOffset);
  if (Version <> 0) then
    { Don't support COLRv1 }
    Exit(False);

  { Table header (14 bytes from table start):
      Offset +0:  u16 version                (must be 0 for COLRv0)
      Offset +2:  u16 numBaseGlyphRecords
      Offset +4:  u32 offsetBaseGlyphRecord  (from table start)
      Offset +8:  u32 offsetLayerRecord      (from table start)
      Offset +12: u16 numLayerRecords }
  var NumBaseGlyphs: Integer := ReadU16BE(AData, TableOffset + 2);
  var OffsetBase := TableOffset + Integer(ReadU32BE(AData, TableOffset + 4));
  var OffsetLayer := TableOffset + Integer(ReadU32BE(AData, TableOffset + 8));
  var NumLayers: Integer := ReadU16BE(AData, TableOffset + 12);
  FColorBases.Count := NumBaseGlyphs;

  for var I := 0 to NumBaseGlyphs - 1 do
  begin
    { Each record is 6 bytes }
    var Offset := OffsetBase + (I * 6);
    var ColorBase: TSlugColorBase;

    { [glyphID: u16, firstLayerIndex: u16, numLayers: u16] }
    ColorBase.GlyphId := ReadU16BE(AData, Offset);
    ColorBase.FirstLayer := ReadU16BE(AData, Offset + 2);
    ColorBase.NumLayers := ReadU16BE(AData, Offset + 4);
    ColorBase._Pad := 0;
    FColorBases[I] := ColorBase;
  end;

  FColorBases.Sort(TSlugColorBase.GComparer);

  FColorLayers.Count := NumLayers;
  for var I := 0 to NumLayers - 1 do
  begin
    { Each record is 6 bytes }
    var Offset := OffsetLayer + (I * 4);
    var ColorLayer: TSlugColorLayer;

    ColorLayer.GlyphId := ReadU16BE(AData, Offset);
    ColorLayer.PaletteIndex := ReadU16BE(AData, Offset + 2);
    FColorLayers[I] := ColorLayer;
  end;

  Result := True;
end;

function TSlugFont.ParseCPal(const AData: TSlugRange): Boolean;
begin
  var TableOffset := FindOtfTable(AData, MakeTag('CPAL'));
  if (TableOffset < 0) then
    { CPAL table is optional }
    Exit(True);

  { Table header (12 bytes from table start):
      Offset +0: u16 version
      Offset +2: u16 numPaletteEntries   (number of colors per palette)
      Offset +4: u16 numPalettes         (usually 1)
      Offset +6: u16 numColorRecords     (total colors across all palettes)
      Offset +8: u32 offsetFirstColorRecord  (from table start) }

  var NumEntries: Integer := ReadU16BE(AData, TableOffset + 2);
  var NumColorRecords: Integer := ReadU16BE(AData, TableOffset + 6);
  var ColorOffset := TableOffset + Integer(ReadU32BE(AData, TableOffset + 8));
  var Count := Min(NumEntries, NumColorRecords);

  FCPalColors.Count := Count;
  for var I := 0 to Count - 1 do
  begin
    var Src := PByte(AData.Ptr) + ColorOffset + (I * 4);

    var Color: TVector4;
    Color.R := Src[2] / 255;
    Color.G := Src[1] / 255;
    Color.B := Src[0] / 255;
    Color.A := Src[3] / 255;
    FCPalColors[I] := Color;
  end;

  Result := True;
end;

class function TSlugFont.ReadU16BE(const AData: TSlugRange;
  const AOffset: NativeInt): UInt16;
begin
  Assert((AOffset + SizeOf(UInt16)) <= AData.Size);
  var P := PByte(AData.Ptr);
  Result := (P[AOffset] shl 8) or P[AOffset + 1];
end;

class function TSlugFont.ReadU32BE(const AData: TSlugRange;
  const AOffset: NativeInt): UInt32;
begin
  Assert((AOffset + SizeOf(UInt32)) <= AData.Size);
  var P := PByte(AData.Ptr);
  Result := (P[AOffset] shl 24) or (P[AOffset + 1] shl 16)
    or (P[AOffset + 2] shl 8) or P[AOffset + 3];
end;

procedure TSlugFont.Unload;
begin
  FCurve.Free;
  FBand.Free;
  FGlyphs.Clear;
  FCPalColors.Clear;
  FColorBases.Clear;
  FColorLayers.Clear;
end;

{ TSlugFont.TCurveOrBand }

procedure TSlugFont.TCurveOrBand.Free;
begin
  Image.Free;
  TexView.Free;
end;

{ TSlugColorBase }

class constructor TSlugColorBase.Create;
begin
  GComparer := TComparer<TSlugColorBase>.Construct(
    function(const ALeft, ARight: TSlugColorBase): Integer
    begin
      if (ALeft.GlyphId < ARight.GlyphId) then
        Result := -1
      else if (ALeft.GlyphId > ARight.GlyphId) then
        Result := 1
      else
        Result := 0;
    end);
end;

{ TSlugBandEntry }

class constructor TSlugBandEntry.Create;
begin
  GComparer := TComparer<TSlugBandEntry>.Construct(
    function(const ALeft, ARight: TSlugBandEntry): Integer
    begin
      { NOTE: inverted sort-order is not a bug }
      if (ALeft.SortKey > ARight.SortKey) then
        Result := -1
      else if (ALeft.SortKey < ARight.SortKey) then
        Result := 1
      else
        Result := 0;
    end);
end;

{ TPackTextures }

constructor TPackTextures.Create(const AGlyphs: TObjectList<TSlugGlyphBuild>);
begin
  inherited Create;
  FCurvePixels := TList<TVector4>.Create;
  FBandPixels := TList<TU16Vector2>.Create;

  { Count how many texels we'll need so we can reserve upfront.
    This avoids repeated realloc+copy as the dynamic arrays grow. }
  var EstimatedCurveSize := 0;
  var EstimatedBandSize := 0;
  for var GlyphIndex := 0 to AGlyphs.Count - 1 do
  begin
    var Glyph := AGlyphs[GlyphIndex];

    { Each contour needs (count + 1) curve texels:
        count = number of bezier curves in this contour
        +1 for the shared endpoint texel }
    var Contours := Glyph.FContours;
    for var ContourIndex := 0 to Contours.Count - 1 do
      Inc(EstimatedCurveSize, Contours[ContourIndex].Count + 1);

    var HBands := Glyph.FHorizontalBands;
    var VBands := Glyph.FVerticalBands;
    var NumH := HBands.Count;
    var NumV := VBands.Count;
    if (NumH = 0) and (NumV = 0) then
      Continue;

    { Band data per glyph:
        num_h + num_v = one header texel per band
        + sum of all curve references in each band }
    var BandSize := NumH + NumV;
    for var I := 0 to NumH - 1 do
      Inc(BandSize, HBands[I].Count);
    for var I := 0 to NumV - 1 do
      Inc(BandSize, VBands[I].Count);

    Inc(EstimatedBandSize, BandSize);
  end;

  FCurvePixels.Capacity := (EstimatedCurveSize * 6) div 5;
  FBandPixels.Capacity := (EstimatedBandSize * 6) div 5;

  for var GlyphIndex := 0 to AGlyphs.Count - 1 do
  begin
    var Glyph := AGlyphs[GlyphIndex];

    { Pack curves into texture, recording each curve's texture coordinates }
    var Contours := Glyph.FContours;
    var Contour := PSlugContourRange(Contours.List);
    for var ContourIndex := 0 to Contours.Count - 1 do
    begin
      var EntriesNeeded := Contour.Count + 1;
      PadToRowCurvePixels(EntriesNeeded);

      var Curve := PSlugCurve(Glyph.FCurves.List);
      Inc(Curve, Contour.Start);
      for var I := 0 to Contour.Count - 1 do
      begin
        var PixelIndex := FCurvePixels.Count;
        FCurvePixels.Add(Vector4(Curve.P[0].X, Curve.P[0].Y, Curve.P[1].X, Curve.P[1].Y));
        Curve.Texture[0] := PixelIndex and SLUG_TEX_MASK;
        Curve.Texture[1] := PixelIndex shr SLUG_TEX_SHIFT;
        Inc(Curve);
      end;

      Dec(Curve);
      FCurvePixels.Add(Vector4(Curve.P[2].X, Curve.P[2].Y, 0, 0));
      Inc(Contour);
    end;

    { Pack band lookup tables into texture, referencing the curve coords set above }
    var HBands := Glyph.FHorizontalBands;
    var VBands := Glyph.FVerticalBands;
    var NumHBands := HBands.Count;
    var NumVBands := VBands.Count;
    if (NumHBands = 0) and (NumVBands = 0) then
      Continue;

    var HeaderSize := NumHBands + NumVBands;
    PadToRowBandPixels(HeaderSize);

    var GlyphStart := FBandPixels.Count;
    Glyph.FGlyphLoc[0] := GlyphStart and SLUG_TEX_MASK;
    Glyph.FGlyphLoc[1] := GlyphStart shr SLUG_TEX_SHIFT;

    var TotalEntries := HeaderSize;
    for var I := 0 to NumHBands - 1 do
      Inc(TotalEntries, HBands[I].Count);
    for var I := 0 to NumVBands - 1 do
      Inc(TotalEntries, VBands[I].Count);

    FBandPixels.Count := GlyphStart + TotalEntries;

    var WriteOffset := HeaderSize;
    WriteBandSet(HBands, Glyph.FCurves, GlyphStart, 0, WriteOffset);
    WriteBandSet(VBands, Glyph.FCurves, GlyphStart, NumHBands, WriteOffset);
  end;

  FinalizeCurvePixels;
  FinalizeBandPixels;
end;

destructor TPackTextures.Destroy;
begin
  FBandPixels.Free;
  FCurvePixels.Free;
  inherited;
end;

procedure TPackTextures.FinalizeBandPixels;
begin
  var CurSize := FBandPixels.Count;
  if (CurSize = 0) then
  begin
    FBandPixels.Count := SLUG_TEX_WIDTH;
    FBandHeight := 1;
  end
  else
  begin
    FBandHeight := (FBandPixels.Count + SLUG_TEX_MASK) shr SLUG_TEX_SHIFT;
    FBandPixels.Count := FBandHeight shl SLUG_TEX_SHIFT;
  end;
end;

procedure TPackTextures.FinalizeCurvePixels;
begin
  var CurSize := FCurvePixels.Count;
  if (CurSize = 0) then
  begin
    FCurvePixels.Count := SLUG_TEX_WIDTH;
    FCurveHeight := 1;
  end
  else
  begin
    FCurveHeight := (FCurvePixels.Count + SLUG_TEX_MASK) shr SLUG_TEX_SHIFT;
    FCurvePixels.Count := FCurveHeight shl SLUG_TEX_SHIFT;
  end;
end;

procedure TPackTextures.PadToRowBandPixels(const ANeeded: Integer);
begin
  var CurLen := FBandPixels.Count;
  var Column := CurLen and SLUG_TEX_MASK;
  if ((Column + ANeeded) > SLUG_TEX_WIDTH) then
    FBandPixels.Count := CurLen + SLUG_TEX_WIDTH - Column;
end;

procedure TPackTextures.PadToRowCurvePixels(const ANeeded: Integer);
begin
  var CurLen := FCurvePixels.Count;
  var Column := CurLen and SLUG_TEX_MASK;
  if ((Column + ANeeded) > SLUG_TEX_WIDTH) then
    FCurvePixels.Count := CurLen + SLUG_TEX_WIDTH - Column;
end;

procedure TPackTextures.WriteBandSet(
  const ABands: TObjectList<TList<TSlugBandEntry>>;
  const ACurves: TList<TSlugCurve>; const AGlyphStart, AHeaderOffset: Integer;
  var AWriteOffset: NativeInt);
begin
  { Write headers: each band stores (count, data_offset) where data_offset
    is relative to glyph_start, matching how the shader indexes into the texture. }
  var DataOffset := AWriteOffset;
  for var BandIndex := 0 to ABands.Count - 1 do
  begin
    var Band := ABands[BandIndex];
    var Pixel: TU16Vector2;
    Pixel.X := Band.Count;
    Pixel.Y := DataOffset;
    FBandPixels[AGlyphStart + AHeaderOffset + BandIndex] := Pixel;
    Inc(DataOffset, Band.Count);
  end;

  { Write curve references at the offsets declared above }
  DataOffset := AWriteOffset;
  for var BandIndex := 0 to ABands.Count - 1 do
  begin
    var Band := ABands[BandIndex];
    var Entry := PSlugBandEntry(Band.List);
    for var EntryIndex := 0 to Band.Count - 1 do
    begin
      var Curve := PSlugCurve(ACurves.List);
      Inc(Curve, Entry.CurveIndex);
      var Pixel: TU16Vector2;
      Pixel.X := Curve.Texture[0];
      Pixel.Y := Curve.Texture[1];
      FBandPixels[AGlyphStart + DataOffset] := Pixel;
      Inc(DataOffset);
      Inc(Entry);
    end;
  end;

  AWriteOffset := DataOffset;
end;

end.

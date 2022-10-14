unit Neslib.FontStash;
{ Delphi wrapper for FontStash (https://github.com/memononen/fontstash)

  For a user guide, check out the Neslib.FontStash.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.FontStash.md }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  System.Types,
  System.UITypes,
  System.SysUtils,
  Neslib.Sokol.Api;

const
  { Index of an unknown font }
  FONT_STASH_INVALID = _FONS_INVALID;

type
  TFontStashError = (
    { Font atlas is full. }
    AtlasFull       = _FONS_ATLAS_FULL,

    { Scratch memory used to render glyphs is full. Requested size reported in
      the AValue parameter of the error event. }
    ScratchFull     = _FONS_SCRATCH_FULL,

    { Calls to TFontStash.PushState has created too large stack. }
    StatesOverflow  = _FONS_STATES_OVERFLOW,

    { Trying to pop too many states using TFontStash.PopState. }
    StatesUnderflow = _FONS_STATES_UNDERFLOW);

type
  TFontStashHorzAlign = (
    Default = 0,
    Left    = 0,
    Center  = 1,
    Right   = 2);

type
  TFontStashVertAlign = (
    Default  = 6,
    Top      = 3,
    Middle   = 4,
    Bottom   = 5,
    Baseline = 6);

type
  TFontStashRenderCreateEvent = function(const AWidth, AHeight: Integer): Boolean of object;
  TFontStashRenderResizeEvent = function(const AWidth, AHeight: Integer): Boolean of object;
  TFontStashRenderUpdateEvent = procedure(const ARect: TRect; const AData: Pointer) of object;
  TFontStashRenderDrawEvent = procedure(const AVerts, ATexCoords: PPointF;
    const AColors: PCardinal; const ACount: Integer) of object;
  TFontStashRenderDeleteEvent = procedure of object;
  TFontStashErrorEvent = procedure(const AError: TFontStashError;
    const AValue: Integer) of object;

type
  TFontStashParams = record
  public
    Width: Integer;
    Height: Integer;
    ZeroTopLeft: Boolean;
    OnRenderCreate: TFontStashRenderCreateEvent;
    OnRenderResize: TFontStashRenderResizeEvent;
    OnRenderUpdate: TFontStashRenderUpdateEvent;
    OnRenderDraw: TFontStashRenderDrawEvent;
    OnRenderDelete: TFontStashRenderDeleteEvent;
    OnError: TFontStashErrorEvent;
  public
    constructor Create(const AWidth, AHeight: Integer;
      const AZeroTopLeft: Boolean = True);
    procedure Init(const AWidth, AHeight: Integer;
      const AZeroTopLeft: Boolean = True);
  end;
  PFontStashParams = ^TFontStashParams;

type
  TFontStashQuad = record
  public
    X0, Y0, S0, T0: Single;
    X1, Y1, S1, T1: Single;
  end;

type
  TFontStashQuadEnumerator = record
  {$REGION 'Internal Declarations'}
  private
    FContext: _PFONScontext;
    FIter: _FONStextIter;
    FCurrent: TFontStashQuad;
  private
    constructor Create(const AContext: _PFONScontext;
      const AX, AY: Single; const AText: UTF8String);
  {$ENDREGION 'Internal Declarations'}
  public
    function MoveNext: Boolean;

    property Current: TFontStashQuad read FCurrent;
  end;

type
  TFontStashQuads = record
  {$REGION 'Internal Declarations'}
  private
    FContext: _PFONScontext;
    FX: Single;
    FY: Single;
    FText: UTF8String;
  private
    constructor Create(const AContext: _PFONScontext;
      const AX, AY: Single; const AText: String);
  {$ENDREGION 'Internal Declarations'}
  public
    function GetEnumerator: TFontStashQuadEnumerator; inline;
  end;

type
  TFontStash = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _PFONScontext;
    FParams: PFontStashParams;
    function GetAtlasSize: TSize; inline;
    procedure SetAtlasSize(const AValue: TSize);
  private
    class function DoRenderCreate(UPtr: Pointer; Width, Height: Integer): Integer; cdecl; static;
    class function DoRenderResize(UPtr: Pointer; Width, Height: Integer): Integer; cdecl; static;
    class procedure DoRenderUpdate(UPtr: Pointer; Rect: PInteger; const Data: PByte); cdecl; static;
    class procedure DoRenderDraw(UPtr: Pointer; const Verts, TCoords: PSingle;
      const Colors: PCardinal; NVerts: Integer); cdecl; static;
    class procedure DoRenderDelete(UPtr: Pointer); cdecl; static;
    class procedure DoError(UPtr: Pointer; Error, Val: Integer); cdecl; static;
  public
    procedure _Init(const AHandle: _PFONScontext);
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AParams: TFontStashParams);
    procedure Init(const AParams: TFontStashParams);
    procedure Free;

    { Expands the atlas size }
    function ExpandAtlas(const AWidth, AHeight: Integer): Boolean;

    { Resets the whole stash }
    function Reset(const AWidth, AHeight: Integer): Boolean;

    { Add fonts.
      NOTE: FontStash does *not* own the font AData. It is the responsibility
      of the called to free it when no longer in use.
      Returns an ID (index) of the font. }
    function AddFont(const AName: String; const AData: TBytes): Integer; overload;
    function AddFont(const AName: String; const AData: Pointer;
      const ASize: Integer): Integer; overload;
    function AddFallbackFont(const ABase, AFallback: Integer): Integer;

    { Returns the ID (index) of the font with the given name, or
      FONT_STASH_INVALID if not found). }
    function GetFont(const AName: String): Integer;

    { State handling }
    procedure PushState; inline;
    procedure PopState; inline;
    procedure ClearState; inline;

    { State setting }
    procedure SetSize(const ASize: Single); inline;
    procedure SetColor(const AColor: TAlphaColor); inline;
    procedure SetSpacing(const ASpacing: Single); inline;
    procedure SetBlur(const ABlur: Single); inline;
    procedure SetAlign(const AHorzAlign: TFontStashHorzAlign;
      const AVertAlign: TFontStashVertAlign); inline;
    procedure SetFont(const AFont: Integer); inline;

    { Draw text }
    function DrawText(const AX, AY: Single; const AText: String): Single; inline;

    { Measure text }

    { Returns X advance }
    function GetBounds(const AX, AY: Single; const AText: String;
      out ABounds: TRectF): Single; overload; inline;
    function GetBounds(const AX, AY: Single; const AText: String;
      const AOutBounds: PRectF): Single; overload; inline;

    procedure GetLineBounds(const AY: Single; out AMinY, AMaxY: Single); inline;
    procedure GetVertMetrics(out AAscender, ADescender, ALineHeight: Single); overload; inline;
    procedure GetVertMetrics(const AOutAscender, AOutDescender, AOutLineHeight: PSingle); overload; inline;

    { Enumerate texture quads }
    function GetQuads(const AX, AY: Single; const AText: String): TFontStashQuads; inline;

    { Pull texture changes }
    function GetTextureData(out AWidth, AHeight: Single): Pointer; inline;
    function ValidateTexture(out ADirtyRect: TRect): Boolean; overload; inline;
    function ValidateTexture(const AOutDirtyRect: PRect): Boolean; overload; inline;

    { Draws the stash texture for debugging }
    procedure DrawDebug(const AX, AY: Single); inline;

    { Current atlas size }
    property AtlasSize: TSize read GetAtlasSize write SetAtlasSize;

    { Underlying C-API handle }
    property Handle: _PFONScontext read FHandle;
  end;

implementation

constructor TFontStashParams.Create(const AWidth, AHeight: Integer;
  const AZeroTopLeft: Boolean);
begin
  Init(AWidth, AHeight, AZeroTopLeft);
end;

procedure TFontStashParams.Init(const AWidth, AHeight: Integer;
  const AZeroTopLeft: Boolean);
begin
  FillChar(Self, SizeOf(Self), 0);
  Width := AWidth;
  Height := AHeight;
  ZeroTopLeft := AZeroTopLeft;
end;

{ TFontStashQuadEnumerator }

constructor TFontStashQuadEnumerator.Create(const AContext: _PFONScontext;
  const AX, AY: Single; const AText: UTF8String);
begin
  FContext := AContext;
  var P := PUTF8Char(AText);
  if (_fonsTextIterInit(AContext, @FIter, AX, AY, P, P + Length(AText)) = 0) then
    FContext := nil;
end;

function TFontStashQuadEnumerator.MoveNext: Boolean;
begin
  if (FContext = nil) then
    Result := False
  else
    Result := (_fonsTextIterNext(FContext, @FIter, @FCurrent) <> 0);
end;

{ TFontStashQuads }

constructor TFontStashQuads.Create(const AContext: _PFONScontext; const AX,
  AY: Single; const AText: String);
begin
  FContext := AContext;
  FX := AX;
  FY := AY;
  FText := UTF8String(AText);
end;

function TFontStashQuads.GetEnumerator: TFontStashQuadEnumerator;
begin
  Result := TFontStashQuadEnumerator.Create(FContext, FX, FY, FText);
end;

{ TFontStash }

function TFontStash.AddFallbackFont(const ABase, AFallback: Integer): Integer;
begin
  Result := _fonsAddFallbackFont(FHandle, ABase, AFallback);
end;

function TFontStash.AddFont(const AName: String; const AData: Pointer;
  const ASize: Integer): Integer;
begin
  Result := _fonsAddFontMem(FHandle, PUTF8Char(UTF8String(AName)), AData,
    ASize, 0);
end;

function TFontStash.AddFont(const AName: String; const AData: TBytes): Integer;
begin
  Result := _fonsAddFontMem(FHandle, PUTF8Char(UTF8String(AName)),
    Pointer(AData), Length(AData), 0);;
end;

procedure TFontStash.ClearState;
begin
  _fonsClearState(FHandle);
end;

constructor TFontStash.Create(const AParams: TFontStashParams);
begin
  Init(AParams);
end;

class procedure TFontStash.DoError(UPtr: Pointer; Error, Val: Integer);
var
  Params: PFontStashParams absolute UPtr;
begin
  Assert(Assigned(Params) and Assigned(Params.OnError));
  Params.OnError(TFontStashError(Error), Val);
end;

class function TFontStash.DoRenderCreate(UPtr: Pointer; Width,
  Height: Integer): Integer;
var
  Params: PFontStashParams absolute UPtr;
begin
  Assert(Assigned(Params) and Assigned(Params.OnRenderCreate));
  Result := Ord(Params.OnRenderCreate(Width, Height));
end;

class procedure TFontStash.DoRenderDelete(UPtr: Pointer);
var
  Params: PFontStashParams absolute UPtr;
begin
  Assert(Assigned(Params) and Assigned(Params.OnRenderDelete));
  Params.OnRenderDelete();
end;

class procedure TFontStash.DoRenderDraw(UPtr: Pointer; const Verts,
  TCoords: PSingle; const Colors: PCardinal; NVerts: Integer);
var
  Params: PFontStashParams absolute UPtr;
begin
  Assert(Assigned(Params) and Assigned(Params.OnRenderDraw));
  Params.OnRenderDraw(PPointF(Verts), PPointF(TCoords), Colors, NVerts);
end;

class function TFontStash.DoRenderResize(UPtr: Pointer; Width,
  Height: Integer): Integer;
var
  Params: PFontStashParams absolute UPtr;
begin
  Assert(Assigned(Params) and Assigned(Params.OnRenderResize));
  Result := Ord(Params.OnRenderResize(Width, Height));
end;

class procedure TFontStash.DoRenderUpdate(UPtr: Pointer; Rect: PInteger;
  const Data: PByte);
var
  Params: PFontStashParams absolute UPtr;
  R: TRect;
begin
  Assert(Assigned(Params) and Assigned(Params.OnRenderUpdate));
  Move(Rect^, R, SizeOf(TRect));
  Params.OnRenderUpdate(R, Data);
end;

procedure TFontStash.DrawDebug(const AX, AY: Single);
begin
  _fonsDrawDebug(FHandle, AX, AY);
end;

function TFontStash.DrawText(const AX, AY: Single; const AText: String): Single;
begin
  var S := UTF8String(AText);
  var P := PUTF8Char(S);
  Result := _fonsDrawText(FHandle, AX, AY, P, P + Length(S));
end;

function TFontStash.ExpandAtlas(const AWidth, AHeight: Integer): Boolean;
begin
  Result := (_fonsExpandAtlas(FHandle, AWidth, AHeight) <> 0);
end;

procedure TFontStash.Free;
begin
  _fonsDeleteInternal(FHandle);
  FreeMem(FParams);
  FParams := nil;
end;

function TFontStash.GetAtlasSize: TSize;
begin
  _fonsGetAtlasSize(FHandle, @Result.cx, @Result.cy);
end;

function TFontStash.GetBounds(const AX, AY: Single; const AText: String;
  out ABounds: TRectF): Single;
begin
  var S := UTF8String(AText);
  var P := PUTF8Char(S);
  Result := _fonsTextBounds(FHandle, AX, AY, P, P + Length(S), @ABounds);
end;

function TFontStash.GetBounds(const AX, AY: Single; const AText: String;
  const AOutBounds: PRectF): Single;
begin
  var S := UTF8String(AText);
  var P := PUTF8Char(S);
  Result := _fonsTextBounds(FHandle, AX, AY, P, P + Length(S), Pointer(AOutBounds));
end;

function TFontStash.GetFont(const AName: String): Integer;
begin
  Result := _fonsGetFontByName(FHandle, PUTF8Char(UTF8String(AName)));
end;

procedure TFontStash.GetLineBounds(const AY: Single; out AMinY, AMaxY: Single);
begin
  _fonsLineBounds(FHandle, AY, @AMinY, @AMaxY);
end;

function TFontStash.GetQuads(const AX, AY: Single;
  const AText: String): TFontStashQuads;
begin
  Result := TFontStashQuads.Create(FHandle, AX, AY, AText);
end;

function TFontStash.GetTextureData(out AWidth, AHeight: Single): Pointer;
begin
  Result := _fonsGetTextureData(FHandle, @AWidth, @AHeight);
end;

procedure TFontStash.GetVertMetrics(const AOutAscender, AOutDescender,
  AOutLineHeight: PSingle);
begin
  _fonsVertMetrics(FHandle, AOutAscender, AOutDescender, AOutLineHeight);
end;

procedure TFontStash.GetVertMetrics(out AAscender, ADescender,
  ALineHeight: Single);
begin
  _fonsVertMetrics(FHandle, @AAscender, @ADescender, @ALineHeight);
end;

procedure TFontStash.Init(const AParams: TFontStashParams);
begin
  FHandle := nil;
  FParams := nil;
  var Params: _FONSparams;
  FillChar(Params, SizeOf(Params), 0);
  Params.width := AParams.Width;
  Params.height := AParams.Height;

  if (AParams.ZeroTopLeft) then
    Params.flags := _FONS_ZERO_TOPLEFT;

  if Assigned(AParams.OnRenderCreate) or Assigned(AParams.OnRenderResize)
    or Assigned(AParams.OnRenderUpdate) or Assigned(AParams.OnRenderDraw)
    or Assigned(AParams.OnRenderDelete) or Assigned(AParams.OnError) then
  begin
    GetMem(FParams, SizeOf(TFontStashParams));
    FParams^ := AParams;
    Params.userPtr := FParams;

    if Assigned(AParams.OnRenderCreate) then
      Params.renderCreate := DoRenderCreate;

    if Assigned(AParams.OnRenderResize) then
      Params.renderResize := DoRenderResize;

    if Assigned(AParams.OnRenderUpdate) then
      Params.renderUpdate := DoRenderUpdate;

    if Assigned(AParams.OnRenderDraw) then
      Params.renderDraw := DoRenderDraw;

    if Assigned(AParams.OnRenderDelete) then
      Params.renderDelete := DoRenderDelete;
  end;
  FHandle := _fonsCreateInternal(@Params);

  if Assigned(AParams.OnError) then
    _fonsSetErrorCallback(FHandle, DoError, FParams);
end;

procedure TFontStash.PopState;
begin
  _fonsPopState(FHandle);
end;

procedure TFontStash.PushState;
begin
  _fonsPushState(FHandle);
end;

function TFontStash.Reset(const AWidth, AHeight: Integer): Boolean;
begin
  Result := (_fonsResetAtlas(FHandle, AWidth, AHeight) <> 0);
end;

procedure TFontStash.SetAlign(const AHorzAlign: TFontStashHorzAlign;
  const AVertAlign: TFontStashVertAlign);
begin
  _fonsSetAlign(FHandle, (1 shl Ord(AHorzAlign)) or (1 shl Ord(AVertAlign)));
end;

procedure TFontStash.SetAtlasSize(const AValue: TSize);
begin
  _fonsExpandAtlas(FHandle, AValue.Width, AValue.Height);
end;

procedure TFontStash.SetBlur(const ABlur: Single);
begin
  _fonsSetBlur(FHandle, ABlur);
end;

procedure TFontStash.SetColor(const AColor: TAlphaColor);
var
  C: TAlphaColorRec absolute AColor;
begin
  _fonsSetColor(FHandle, C.R or (C.G shl 8) or (C.B shl 16) or (C.A shl 24));
end;

procedure TFontStash.SetFont(const AFont: Integer);
begin
  _fonsSetFont(FHandle, AFont);
end;

procedure TFontStash.SetSize(const ASize: Single);
begin
  _fonsSetSize(FHandle, ASize);
end;

procedure TFontStash.SetSpacing(const ASpacing: Single);
begin
  _fonsSetSpacing(FHandle, ASpacing);
end;

function TFontStash.ValidateTexture(const AOutDirtyRect: PRect): Boolean;
begin
  Result := (_fonsValidateTexture(FHandle, Pointer(AOutDirtyRect)) <> 0);
end;

function TFontStash.ValidateTexture(out ADirtyRect: TRect): Boolean;
begin
  Result := (_fonsValidateTexture(FHandle, @ADirtyRect) <> 0);
end;

procedure TFontStash._Init(const AHandle: _PFONScontext);
begin
  FHandle := AHandle;
  FParams := nil;
end;

end.

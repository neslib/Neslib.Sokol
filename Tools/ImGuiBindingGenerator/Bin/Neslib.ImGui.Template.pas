unit Neslib.ImGui;
{ This unit is automatically generated. Do not modify. 

  For a user guide, check out the Neslib.ImGui.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.ImGui.md }

{$ALIGN 8}
{$MINENUMSIZE 4}
{$SCOPEDENUMS ON}
{$POINTERMATH ON}

interface

uses
  System.Math,
  System.Types,
  System.UITypes,
  Neslib.FastMath,
  Neslib.Sokol.Api;

type
  PPUTF8Char = ^PUTF8Char;
  TImTextureID = Pointer;
  TImDrawIdx = Word;
  PImDrawIdx = ^TImDrawIdx;
  TImGuiTableColumnIdx = Shortint;
  TImGuiTableDrawChannelIdx = Byte;
  TImGuiID = Cardinal;
  PImGuiID = ^TImGuiID;
  TImGuiDockRequest = THandle;
  TImGuiDockNodeSettings = THandle;
  TImFileHandle = THandle;
  PImGuiContext = Pointer;
  PImGuiWindow = Pointer;
  PImDrawListSharedData = Pointer;
  PImFontBuilderIO = Pointer;

<%Enums%>

type
  TImVector = record
  public
    Size: Integer;
    Capacity: Integer;
    Data: Pointer;
  end;

type
  TImVector<T> = record
  {$REGION 'Internal Declarations'}
  private type
    P = ^T;
  private
    FSize: Integer;
    FCapacity: Integer;
    FData: Pointer;
    function GetItem(const AIndex: Integer): T; inline;
    function GetItemPtr(const AIndex: Integer): Pointer; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Count: Integer read FSize;
    property Capacity: Integer read FCapacity;
    property Items[const AIndex: Integer]: T read GetItem; default;
    property ItemPtrs[const AIndex: Integer]: Pointer read GetItemPtr;
    property Data: Pointer read FData;
  end;

type
  TImPoolIdx = Integer;

type
  TImPool<T> = record
  public
    Buf: TImVector<T>;
    Map: TImVector; // TImGuiStorage
    FreeIdx: TImPoolIdx;
    AliveCount: TImPoolIdx;
  end;

type
  TImSpan<T> = record
  public
    Data: Pointer;
    DataEnd: Pointer;
  end;

type
  TImChunkStream<T> = record
  public
    Buf: TImVector<T>;
  end;

type
  TImBitArrayForNamedKeys = record
  public const
    BITCOUNT = Ord(TImGuiKey.NamedKeyCOUNT);
  public
    Storage: array [0..((BITCOUNT + 31) shr 5) - 1] of UInt32;
  end;

type  
  TImChunkStream_ImGuiWindowSettings = record
  public  
    Buf: TImVector<Byte>;
  end;

type  
  TImChunkStream_ImGuiTableSettings = record
  public  
    Buf: TImVector<Byte>;
  end;
  
type
  TImGuiText = record
  {$REGION 'Internal Declarations'}
  private const
    WORK_AREA = 10;
  private
    FBuffer: TArray<UTF8Char>;
  private
    procedure Validate;
    procedure Update(const AData: _PImGuiInputTextCallbackData);
  {$ENDREGION 'Internal Declarations'}
  public
    procedure Init(const AText: String);
    function ToString: String; inline;
    function ToUTF8String: UTF8String; inline;
    function ToPUTF8Char: PUTF8Char; inline;

    class operator Implicit(const AText: String): TImGuiText; inline; static;
    class operator Implicit(const AText: TImGuiText): String; inline; static;
  end;
  PImGuiText = ^TImGuiText;
  
type
  // Forward declarations
<%ForwardStructDeclarations%>

  TImDrawCallback = procedure(const AParentList: PImDrawList; const ACmd: PImDrawCmd); cdecl;
  TImGuiErrorLogCallback = procedure(const AUserData: Pointer; const AError: PUTF8Char) varargs; cdecl;
  TImGuiMemAllocFunc = function(const ASize: NativeUInt; const AUserData: Pointer): Pointer; cdecl;
  PImGuiMemAllocFunc = ^TImGuiMemAllocFunc;
  TImGuiMemFreeFunc = procedure(const APtr, AUserData: Pointer); cdecl;
  PImGuiMemFreeFunc = ^TImGuiMemFreeFunc;
  TImGuiInputTextCallback = function(const AData: PImGuiInputTextCallbackData): Integer; cdecl;
  TImGuiSizeCallback = procedure(const AData: PImGuiSizeCallbackData); cdecl;
<%StructInterfaces%>

  TImGuiWindowPtr = PImGuiWindow;
  TImVectorPChar = TImVector<PChar>;
  _ImGuiItemsGetter = _igCombo_FnBoolPtr__items_getter;
  _ImGuiCompareFunc = _igImQsort__compare_func;
  _ImGuiValuesGetter = _igPlotEx__values_getter;
<%CustomTypes%>
<%ImGuiInterface%>

type
  { Shorter alias for the ImGui "namespace" }
  ig = ImGui;

type
  { Helper for fast conversion from Delphi Unicode Strings to PUTF8Char. 
    This is *not* thread-safe! }
  _ImGuiHelper = record helper for ImGui
  private class var
    FUtf8Buf: TArray<UTF8Char>;
  public
    class function ToUtf8(const AStr: String): PUTF8Char; static;
    class function Format(const AFmt: String; const AArgs: array of const): PUTF8Char; static;
  end;
  
function __ImGuiInputTextCallback(AData: _PImGuiInputTextCallbackData): Integer; cdecl;

implementation

uses 
  System.SysUtils;

{ TImVector<T> }

function TImVector<T>.GetItem(const AIndex: Integer): T;
begin
  Assert((AIndex >= 0) and (AIndex < FSize));
  Result := P(FData)[AIndex];
end;

function TImVector<T>.GetItemPtr(const AIndex: Integer): Pointer;
begin
  Assert((AIndex >= 0) and (AIndex < FSize));
  Result := @P(FData)[AIndex];
end;

{ _ImGuiHelper }

class function _ImGuiHelper.Format(const AFmt: String;
  const AArgs: array of const): PUTF8Char;
begin
  Result := ToUtf8(System.SysUtils.Format(AFmt, AArgs));
end;

class function _ImGuiHelper.ToUtf8(const AStr: String): PUTF8Char;
begin
  {$POINTERMATH ON}
  var SrcLength := Length(AStr);
  var BufSize := (SrcLength + 1) * 3;
  if (BufSize > Length(FUtf8Buf)) then
    SetLength(FUtf8Buf, BufSize);

  var S := PWord(AStr);
  var D := PByte(FUtf8Buf);
  var Codepoint: UInt32;

  { Try to convert 2 wide characters at a time if possible. This speeds up the
    process if those 2 characters are both ASCII characters (U+0..U+7F). }
  while (SrcLength >= 2) do
  begin
    if ((PCardinal(S)^ and $FF80FF80) = 0) then
    begin
      { Common case: 2 ASCII characters in a row.
        00000000 0yyyyyyy 00000000 0xxxxxxx => 0yyyyyyy 0xxxxxxx }
      D[0] := S[0]; // 00000000 0yyyyyyy => 0yyyyyyy
      D[1] := S[1]; // 00000000 0xxxxxxx => 0xxxxxxx
      Inc(S, 2);
      Inc(D, 2);
      Dec(SrcLength, 2);
    end
    else
    begin
      Codepoint := S^;
      Inc(S);
      Dec(SrcLength);

      if (Codepoint < $80) then
      begin
        { ASCI character (U+0..U+7F).
          00000000 0xxxxxxx => 0xxxxxxx }
        D^ := Codepoint;
        Inc(D);
      end
      else if (Codepoint < $800) then
      begin
        { 2-byte sequence (U+80..U+7FF)
          00000yyy yyxxxxxx => 110yyyyy 10xxxxxx }
        D^ := (Codepoint shr 6) or $C0;   // 00000yyy yyxxxxxx => 110yyyyy
        Inc(D);
        D^ := (Codepoint and $3F) or $80; // 00000yyy yyxxxxxx => 10xxxxxx
        Inc(D);
      end
      else if (Codepoint >= $D800) and (Codepoint <= $DBFF) then
      begin
        { The codepoint is part of a UTF-16 surrogate pair:
            S[0]: 110110yy yyyyyyyy ($D800-$DBFF, high-surrogate)
            S[1]: 110111xx xxxxxxxx ($DC00-$DFFF, low-surrogate)

          Where the UCS4 codepoint value is:
            0000yyyy yyyyyyxx xxxxxxxx + $00010000 (U+10000..U+10FFFF)

          This can be calculated using:
            (((S[0] and $03FF) shl 10) or (S[1] and $03FF)) + $00010000

          However it can be calculated faster using:
            (S[0] shl 10) + S[1] - $035FDC00

          because:
            * S[0] shl 10: also shifts the leading 110110 to the left, making
              the result $D800 shl 10 = $03600000 too large
            * S[1] is                   $0000DC00 too large
            * So we need to subract     $0360DC00 (sum of the above)
            * But we need to add        $00010000
            * So in total, we subtract  $035FDC00 (difference of the above) }

        Codepoint := (Codepoint shl 10) + S^ - $035FDC00;
        Inc(S);
        Dec(SrcLength);

        { The resulting codepoint is encoded as a 4-byte UTF-8 sequence:

          000uuuuu zzzzyyyy yyxxxxxx => 11110uuu 10uuzzzz 10yyyyyy 10xxxxxx }

        Assert(Codepoint > $FFFF);
        D^ := (Codepoint shr 18) or $F0;           // 000uuuuu zzzzyyyy yyxxxxxx => 11110uuu
        Inc(D);
        D^ := ((Codepoint shr 12) and $3F) or $80; // 000uuuuu zzzzyyyy yyxxxxxx => 10uuzzzz
        Inc(D);
        D^ := ((Codepoint shr 6) and $3F) or $80;  // 000uuuuu zzzzyyyy yyxxxxxx => 10yyyyyy
        Inc(D);
        D^ := (Codepoint and $3F) or $80;          // 000uuuuu zzzzyyyy yyxxxxxx => 10xxxxxx
        Inc(D);
      end
      else
      begin
        { 3-byte sequence (U+800..U+FFFF, excluding U+D800..U+DFFF).
          zzzzyyyy yyxxxxxx => 1110zzzz 10yyyyyy 10xxxxxx }
        D^ := (Codepoint shr 12) or $E0;           // zzzzyyyy yyxxxxxx => 1110zzzz
        Inc(D);
        D^ := ((Codepoint shr 6) and $3F) or $80;  // zzzzyyyy yyxxxxxx => 10yyyyyy
        Inc(D);
        D^ := (Codepoint and $3F) or $80;          // zzzzyyyy yyxxxxxx => 10xxxxxx
        Inc(D);
      end;
    end;
  end;

  { We may have 1 wide character left to encode.
    Use the same process as above. }
  if (SrcLength <> 0) then
  begin
    Codepoint := S^;
    Inc(S);

    if (Codepoint < $80) then
    begin
      D^ := Codepoint;
      Inc(D);
    end
    else if (Codepoint < $800) then
    begin
      D^ := (Codepoint shr 6) or $C0;
      Inc(D);
      D^ := (Codepoint and $3F) or $80;
      Inc(D);
    end
    else if (Codepoint >= $D800) and (Codepoint <= $DBFF) then
    begin
      Codepoint := (Codepoint shl 10) + S^ - $35FDC00;

      Assert(Codepoint > $FFFF);
      D^ := (Codepoint shr 18) or $F0;
      Inc(D);
      D^ := ((Codepoint shr 12) and $3F) or $80;
      Inc(D);
      D^ := ((Codepoint shr 6) and $3F) or $80;
      Inc(D);
      D^ := (Codepoint and $3F) or $80;
      Inc(D);
    end
    else
    begin
      D^ := (Codepoint shr 12) or $E0;
      Inc(D);
      D^ := ((Codepoint shr 6) and $3F) or $80;
      Inc(D);
      D^ := (Codepoint and $3F) or $80;
      Inc(D);
    end;
  end;

  { Final null-terminator }
  D^ := 0;
  {$POINTERMATH OFF}

  Result := PUTF8Char(FUtf8Buf);
end;

{ TImGuiText }

function __ImGuiInputTextCallback(AData: _PImGuiInputTextCallbackData): Integer; cdecl;
begin
  if Assigned(AData) and Assigned(AData.UserData) then
    PImGuiText(AData.UserData).Update(AData);
    
  Result := 0;
end;

class operator TImGuiText.Implicit(const AText: TImGuiText): String;
begin
  Result := AText.ToString;
end;

procedure TImGuiText.Init(const AText: String);
begin
  var S := UTF8String(AText);
  var Len := Length(S);
  SetLength(FBuffer, Len + WORK_AREA);
  if (Len > 0) then
    Move(S[Low(UTF8String)], FBuffer[0], Len);
  FBuffer[Len] := #0;
end;

function TImGuiText.ToPUTF8Char: PUTF8Char;
begin
  Result := PUTF8Char(FBuffer);
end;

function TImGuiText.ToString: String;
begin
  Result := String(UTF8String(PUTF8Char(FBuffer)));
end;

function TImGuiText.ToUTF8String: UTF8String;
begin
  Result := UTF8String(FBuffer);
end;

procedure TImGuiText.Update(const AData: _PImGuiInputTextCallbackData);
begin
  if (AData.EventFlag = _ImGuiInputTextFlags_CallbackResize)
    and ((AData.BufTextLen + 2) > AData.BufSize) then
  begin
    SetLength(FBuffer, GrowCollection(Length(FBuffer), AData.BufTextLen + 1));
    AData.Buf := Pointer(FBuffer);
  end;
end;

procedure TImGuiText.Validate;
begin
  if (FBuffer = nil) then
    SetLength(FBuffer, WORK_AREA);
end;

class operator TImGuiText.Implicit(const AText: String): TImGuiText;
begin
  Result.Init(AText);
end;
<%StructImplementations%>

end.

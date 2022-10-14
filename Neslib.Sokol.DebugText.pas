unit Neslib.Sokol.DebugText;
{ Simple ASCII debug text rendering on top of Neslib.Sokol.Gfx.

  For a user guide, check out the Neslib.Sokol.DebugText.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.DebugText.md }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  System.UITypes,
  System.SysUtils,
  Neslib.Sokol.Api,
  Neslib.Sokol.Gfx;

const
  DEBUG_TEXT_MAX_FONTS = _SDTX_MAX_FONTS;

type
  { Describes the pixel data of a font. A font consists of up to 256 8x8
    character tiles, where each character tile is described by 8 consecutive
    bytes, each byte describing 8 pixels.

    For instance the character 'A' could look like this (this is also how most
    home computers used to describe their fonts in ROM):

        bits
        7 6 5 4 3 2 1 0
        . . . X X . . .     byte 0: $18
        . . X X X X . .     byte 1: $3C
        . X X . . X X .     byte 2: $66
        . X X . . X X .     byte 3: $66
        . X X X X X X .     byte 4: $7E
        . X X . . X X .     byte 5: $66
        . X X . . X X .     byte 6: $66
        . . . . . . . .     byte 7: $00 }
  TDbgTextFontDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure InitFrom(const ADst: _sdtx_font_desc_t);
    procedure Convert(out ADst: _sdtx_font_desc_t);
  {$ENDREGION 'Internal Declarations'}
  public
    { Font pixel data }
    Data: TRange;

    { First character index in font pixel data }
    FirstChar: AnsiChar;

    { Last character index in font pixel data, inclusive (default: #255) }
    LastChar: AnsiChar;
  public
    constructor Create(const AData: TRange; const AFirstChar: AnsiChar = #0;
      const ALastChar: AnsiChar = #255);
    procedure Init(const AData: TRange; const AFirstChar: AnsiChar = #0;
      const ALastChar: AnsiChar = #255); inline;
  end;
  PDbgTextFontDesc = ^TDbgTextFontDesc;

type
  { Describes the initialization parameters of a rendering context. Creating
    additional rendering contexts is useful if you want to render in different
    Sokol Gfx rendering passes, or when rendering several layers of text. }
  TDbgTextContextDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sdtx_context_desc_t);
  {$ENDREGION 'Internal Declarations'}
  public
    { Max number of characters rendered in one frame.
      Default: 4096 }
    CharBufSize: Integer;

    { The initial virtual canvas width.
      Default: 640 }
    CanvasWidth: Single;

    { The initial virtual canvas height.
      Default: 400 }
    CanvasHeight: Single;

    { Tab width in number of characters.
      Default: 4 }
    TabWidth: Integer;

    { Color pixel format of target render pass }
    ColorFormat: TPixelFormat;

    { Depth pixel format of target render pass }
    DepthFormat: TPixelFormat;

    { MSAA sample count of target render pass }
    SampleCount: Integer;
  public
    class function Create: TDbgTextContextDesc; static;
    procedure Init; inline;
  end;
  PDbgTextContextDesc = ^TDbgTextContextDesc;

type
  { Describes the TDbgText API initialization parameters.
    Passed to the TDbgText.Setup method.

    NOTE: to populate the fonts item array with builtin fonts, use any
    of the following properties:

      TDbgTextFont.KC853
      TDbgTextFont.KC854
      TDbgTextFont.Z1013
      TDbgTextFont.CPC
      TDbgTextFont.C64
      TDbgTextFont.Oric }
  TDbgTextDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sdtx_desc_t);
  {$ENDREGION 'Internal Declarations'}
  public
    { Max number of rendering contexts that can be created.
      Default: 8 }
    ContextPoolSize: Integer;

    { Up to 8 fonts descriptions }
    Fonts: array [0..DEBUG_TEXT_MAX_FONTS - 1] of TDbgTextFontDesc;

    { The default context creation parameters }
    Context: TDbgTextContextDesc;

    { Whether to use Delphi's memory manager instead of Sokol's built-in one
      When SOKOL_MEM_TRACK is defined, it always uses Delphi's memory manager. }
    UseDelphiMemoryManager: Boolean;
  public
    class function Create: TDbgTextDesc; static;
    procedure Init; inline;
  end;
  PDbgTextDesc = ^TDbgTextDesc;

type
  { Built-in debug text fonts }
  TDbgTextFont = record
  {$REGION 'Internal Declarations'}
  private class var
    FKC853: TDbgTextFontDesc;
    FKC854: TDbgTextFontDesc;
    FZ1013: TDbgTextFontDesc;
    FCPC: TDbgTextFontDesc;
    FC64: TDbgTextFontDesc;
    FOric: TDbgTextFontDesc;
  public
    class constructor Create;
  {$ENDREGION 'Internal Declarations'}
  public
    class property KC853: TDbgTextFontDesc read FKC853;
    class property KC854: TDbgTextFontDesc read FKC854;
    class property Z1013: TDbgTextFontDesc read FZ1013;
    class property CPC: TDbgTextFontDesc read FCPC;
    class property C64: TDbgTextFontDesc read FC64;
    class property Oric: TDbgTextFontDesc read FOric;
  end;

type
  { A debug text rendering context }
  TDbgTextContext = record
  {$REGION 'Internal Declarations'}
  private class var
    FDefault: TDbgTextContext;
  private
    FHandle: _sdtx_context;
  public
    class constructor Create;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const ADesc: TDbgTextContextDesc);
    procedure Init(const ADesc: TDbgTextContextDesc); inline;
    procedure Free; inline;

    class property Default: TDbgTextContext read FDefault;
    property Id: Cardinal read FHandle.id;
  end;

type
  { Main Debug Text entry point }
  TDbgText = record // static
  {$REGION 'Internal Declarations'}
  private
    class function GetContext: TDbgTextContext; static;
    class procedure SetContext(const AValue: TDbgTextContext); static;
  {$ENDREGION 'Internal Declarations'}
  public
    { Initialization/shutdown }
    class procedure Setup(const ADesc: TDbgTextDesc); static;
    class procedure Shutdown; static;

    { Draw and rewind the current context }
    class procedure Draw; inline; static;

    { Switch to a different font }
    class procedure Font(const AFontIndex: Integer); inline; static;

    { Set a new virtual canvas size in screen pixels }
    class procedure Canvas(const AWidth, AHeight: Single); inline; static;

    { Set a new origin in character grid coordinates }
    class procedure Origin(const AX, AY: Single); inline; static;

    { Cursor movement functions (relative to origin in character grid
      coordinates) }
    class procedure Home; inline; static;
    class procedure Pos(const AX, AY: Single); inline; static;
    class procedure PosX(const AX: Single); inline; static;
    class procedure PosY(const AY: Single); inline; static;
    class procedure Move(const ADX, ADY: Single); inline; static;
    class procedure MoveX(const ADX: Single); inline; static;
    class procedure MoveY(const ADY: Single); inline; static;
    class procedure NewLine; inline; static;

    { Set the current text color }
    class procedure Color(const AR, AG, AB: Byte); overload; inline; static;
    class procedure Color(const AR, AG, AB, AA: Byte); overload; inline; static;
    class procedure Color(const ARgba: Cardinal); overload; inline; static;
    class procedure Color(const AColor: TAlphaColorF); overload; inline; static;
    class procedure ColorF(const AR, AG, AB: Single); overload; inline; static;
    class procedure ColorF(const AR, AG, AB, AA: Single); overload; inline; static;

    { Text rendering }
    class procedure Write(const AChar: AnsiChar); overload; inline; static;
    class procedure Write(const AStr: String); overload; inline; static;
    class procedure Write(const AStr: String;
      const ALen: Integer); overload; inline; static;
    class procedure Write(const AStr: String;
      const AArgs: array of const); overload; static;
    class procedure WriteAnsi(const AStr: AnsiString); overload; inline; static;
    class procedure WriteAnsi(const AStr: AnsiString;
      const ALen: Integer); overload; inline; static;

    class procedure WriteLn(const AStr: String); overload; inline; static;
    class procedure WriteLn(const AStr: String;
      const ALen: Integer); overload; inline; static;
    class procedure WriteLn(const AStr: String;
      const AArgs: array of const); overload; static;
    class procedure WriteAnsiLn(const AStr: AnsiString); overload; inline; static;
    class procedure WriteAnsiLn(const AStr: AnsiString;
      const ALen: Integer); overload; inline; static;

    { Context }
    class procedure SetDefaultContext; static;

    class property Context: TDbgTextContext read GetContext write SetContext;
  end;

implementation

uses
  {$IFDEF SOKOL_MEM_TRACK}
  Neslib.Sokol.MemTrack;
  {$ELSE}
  Neslib.Sokol.Utils;
  {$ENDIF}

{ TDbgTextFontDesc }

procedure TDbgTextFontDesc.Convert(out ADst: _sdtx_font_desc_t);
begin
  ADst.data.ptr := Data.Data;
  ADst.data.size := Data.Size;
  ADst.first_char := Ord(FirstChar);
  ADst.last_char := Ord(LastChar);
end;

constructor TDbgTextFontDesc.Create(const AData: TRange; const AFirstChar,
  ALastChar: AnsiChar);
begin
  Init(AData, AFirstChar, ALastChar);
end;

procedure TDbgTextFontDesc.Init(const AData: TRange; const AFirstChar,
  ALastChar: AnsiChar);
begin
  Data := AData;
  FirstChar := AFirstChar;
  LastChar := ALastChar;
end;

procedure TDbgTextFontDesc.InitFrom(const ADst: _sdtx_font_desc_t);
begin
  Data := TRange.Create(ADst.data.ptr, ADst.data.size);
  FirstChar := AnsiChar(ADst.first_char);
  LastChar := AnsiChar(ADst.last_char);
end;

{ TDbgTextContextDesc }

procedure TDbgTextContextDesc.Convert(out ADst: _sdtx_context_desc_t);
begin
  ADst.char_buf_size := CharBufSize;
  ADst.canvas_width := CanvasWidth;
  ADst.canvas_height := CanvasHeight;
  ADst.tab_width := TabWidth;
  ADst.color_format := Ord(ColorFormat);
  ADst.depth_format := Ord(DepthFormat);
  ADst.sample_count := SampleCount;
end;

class function TDbgTextContextDesc.Create: TDbgTextContextDesc;
begin
  Result.Init;
end;

procedure TDbgTextContextDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TDbgTextDesc }

procedure TDbgTextDesc.Convert(out ADst: _sdtx_desc_t);
begin
  ADst.context_pool_size := ContextPoolSize;
  ADst.printf_buf_size := 0;
  for var I := 0 to Length(Fonts) - 1 do
    Fonts[I].Convert(ADst.fonts[I]);
  Context.Convert(ADst.context);

  {$IFDEF SOKOL_MEM_TRACK}
  ADst.allocator.alloc := _MemTrackAlloc;
  ADst.allocator.free := _MemTrackFree;
  {$ELSE}
  if (UseDelphiMemoryManager) then
  begin
    ADst.allocator.alloc := _AllocCallback;
    ADst.allocator.free := _FreeCallback;
  end
  else
  begin
    ADst.allocator.alloc := nil;
    ADst.allocator.free := nil;
  end;
  {$ENDIF}
end;

class function TDbgTextDesc.Create: TDbgTextDesc;
begin
  Result.Init;
end;

procedure TDbgTextDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TDbgTextFont }

class constructor TDbgTextFont.Create;
begin
  FKC853.InitFrom(_sdtx_font_kc853);
  FKC854.InitFrom(_sdtx_font_kc854);
  FZ1013.InitFrom(_sdtx_font_z1013);
  FCPC.InitFrom(_sdtx_font_cpc);
  FC64.InitFrom(_sdtx_font_c64);
  FOric.InitFrom(_sdtx_font_oric);
end;

{ TDbgTextContext }

class constructor TDbgTextContext.Create;
begin
  FDefault.FHandle := _sdtx_default_context;
end;

constructor TDbgTextContext.Create(const ADesc: TDbgTextContextDesc);
begin
  Init(ADesc);
end;

procedure TDbgTextContext.Free;
begin
  _sdtx_destroy_context(FHandle);
end;

procedure TDbgTextContext.Init(const ADesc: TDbgTextContextDesc);
begin
  var Desc: _sdtx_context_desc_t;
  ADesc.Convert(Desc);
  FHandle := _sdtx_make_context(@Desc);
end;

{ TDbgText }

class procedure TDbgText.Canvas(const AWidth, AHeight: Single);
begin
  _sdtx_canvas(AWidth, AHeight);
end;

class procedure TDbgText.Color(const AR, AG, AB: Byte);
begin
  _sdtx_color3b(AR, AG, AB);
end;

class procedure TDbgText.Color(const AR, AG, AB, AA: Byte);
begin
  _sdtx_color4b(AR, AG, AB, AA);
end;

class procedure TDbgText.Color(const ARgba: Cardinal);
begin
  _sdtx_color1i(ARgba);
end;

class procedure TDbgText.Color(const AColor: TAlphaColorF);
begin
  Color(AColor.ToAlphaColor);
end;

class procedure TDbgText.ColorF(const AR, AG, AB: Single);
begin
  _sdtx_color3f(AR, AG, AB);
end;

class procedure TDbgText.ColorF(const AR, AG, AB, AA: Single);
begin
  _sdtx_color4f(AR, AG, AB, AA);
end;

class procedure TDbgText.Draw;
begin
  _sdtx_draw();
end;

class procedure TDbgText.Font(const AFontIndex: Integer);
begin
  _sdtx_font(AFontIndex);
end;

class function TDbgText.GetContext: TDbgTextContext;
begin
  Result.FHandle := _sdtx_get_context;
end;

class procedure TDbgText.Home;
begin
  _sdtx_home();
end;

class procedure TDbgText.Move(const ADX, ADY: Single);
begin
  _sdtx_move(ADX, ADY);
end;

class procedure TDbgText.MoveX(const ADX: Single);
begin
  _sdtx_move_x(ADX);
end;

class procedure TDbgText.MoveY(const ADY: Single);
begin
  _sdtx_move_y(ADY);
end;

class procedure TDbgText.NewLine;
begin
  _sdtx_crlf;
end;

class procedure TDbgText.Origin(const AX, AY: Single);
begin
  _sdtx_origin(AX, AY);
end;

class procedure TDbgText.Pos(const AX, AY: Single);
begin
  _sdtx_pos(AX, AY);
end;

class procedure TDbgText.PosX(const AX: Single);
begin
  _sdtx_pos_x(AX);
end;

class procedure TDbgText.PosY(const AY: Single);
begin
  _sdtx_pos_y(AY);
end;

class procedure TDbgText.SetContext(const AValue: TDbgTextContext);
begin
  _sdtx_set_context(AValue.FHandle);
end;

class procedure TDbgText.SetDefaultContext;
begin
  _sdtx_set_context(_sdtx_default_context);
end;

class procedure TDbgText.Setup(const ADesc: TDbgTextDesc);
begin
  var Desc : _sdtx_desc_t;
  ADesc.Convert(Desc);
  _sdtx_setup(@Desc);
end;

class procedure TDbgText.Shutdown;
begin
  _sdtx_shutdown;
end;

class procedure TDbgText.WriteAnsi(const AStr: AnsiString);
begin
  _sdtx_puts(PAnsiChar(AStr));
end;

class procedure TDbgText.WriteAnsiLn(const AStr: AnsiString);
begin
  _sdtx_puts(PAnsiChar(AStr));
  _sdtx_crlf;
end;

class procedure TDbgText.WriteAnsi(const AStr: AnsiString; const ALen: Integer);
begin
  _sdtx_putr(PAnsiChar(AStr), ALen);
end;

class procedure TDbgText.WriteAnsiLn(const AStr: AnsiString;
  const ALen: Integer);
begin
  _sdtx_putr(PAnsiChar(AStr), ALen);
  _sdtx_crlf;
end;

class procedure TDbgText.Write(const AChar: AnsiChar);
begin
  _sdtx_putc(AChar);
end;

class procedure TDbgText.Write(const AStr: String);
begin
  _sdtx_puts(PAnsiChar(AnsiString(AStr)));
end;

class procedure TDbgText.Write(const AStr: String; const AArgs: array of const);
begin
  _sdtx_puts(PAnsiChar(AnsiString(Format(AStr, AArgs))));
end;

class procedure TDbgText.Write(const AStr: String; const ALen: Integer);
begin
  _sdtx_puts(PAnsiChar(AnsiString(AStr.Substring(0, ALen))));
end;

class procedure TDbgText.WriteLn(const AStr: String);
begin
  _sdtx_puts(PAnsiChar(AnsiString(AStr)));
  _sdtx_crlf;
end;

class procedure TDbgText.WriteLn(const AStr: String;
  const AArgs: array of const);
begin
  _sdtx_puts(PAnsiChar(AnsiString(Format(AStr, AArgs))));
  _sdtx_crlf;
end;

class procedure TDbgText.WriteLn(const AStr: String; const ALen: Integer);
begin
  _sdtx_puts(PAnsiChar(AnsiString(AStr.Substring(0, ALen))));
  _sdtx_crlf;
end;

end.

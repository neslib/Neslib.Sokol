unit DebugTextUserFontApp;
{ Neslib.Sokol.DebugText: render with user-provided font data (Atari 400 ROM
  extract) }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.DebugText,
  SampleApp;

type
  TDebugTextUserFontApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api;

const
  COLOR_PALETTE: array [0..(16 * 3) - 1] of Byte = (
    $f4, $43, $36,
    $e9, $1e, $63,
    $9c, $27, $b0,
    $67, $3a, $b7,
    $3f, $51, $b5,
    $21, $96, $f3,
    $03, $a9, $f4,
    $00, $bc, $d4,
    $00, $96, $88,
    $4c, $af, $50,
    $8b, $c3, $4a,
    $cd, $dc, $39,
    $ff, $eb, $3b,
    $ff, $c1, $07,
    $ff, $98, $00,
    $ff, $57, $22);

const
  { Use font slot 1 for our user font (can be anything between 0 and
    DEBUG_TEXT_MAX_FONTS) }
  USER_FONT = 1;

const
  { Font data extracted from Atari 400 ROM at address $E000, and reshuffled to
    map to ASCII. Each character is 8 bytes, 1 bit per pixel in an 8x8 matrix. }
  USER_FONT_DATA: array [0..(128 * 8) - 1] of Byte = (
    $00, $00, $00, $00, $00, $00, $00, $00, // 20
    $00, $18, $18, $18, $18, $00, $18, $00, // 21
    $00, $66, $66, $66, $00, $00, $00, $00, // 22
    $00, $66, $FF, $66, $66, $FF, $66, $00, // 23
    $18, $3E, $60, $3C, $06, $7C, $18, $00, // 24
    $00, $66, $6C, $18, $30, $66, $46, $00, // 25
    $1C, $36, $1C, $38, $6F, $66, $3B, $00, // 26
    $00, $18, $18, $18, $00, $00, $00, $00, // 27
    $00, $0E, $1C, $18, $18, $1C, $0E, $00, // 28
    $00, $70, $38, $18, $18, $38, $70, $00, // 29
    $00, $66, $3C, $FF, $3C, $66, $00, $00, // 2A
    $00, $18, $18, $7E, $18, $18, $00, $00, // 2B
    $00, $00, $00, $00, $00, $18, $18, $30, // 2C
    $00, $00, $00, $7E, $00, $00, $00, $00, // 2D
    $00, $00, $00, $00, $00, $18, $18, $00, // 2E
    $00, $06, $0C, $18, $30, $60, $40, $00, // 2F
    $00, $3C, $66, $6E, $76, $66, $3C, $00, // 30
    $00, $18, $38, $18, $18, $18, $7E, $00, // 31
    $00, $3C, $66, $0C, $18, $30, $7E, $00, // 32
    $00, $7E, $0C, $18, $0C, $66, $3C, $00, // 33
    $00, $0C, $1C, $3C, $6C, $7E, $0C, $00, // 34
    $00, $7E, $60, $7C, $06, $66, $3C, $00, // 35
    $00, $3C, $60, $7C, $66, $66, $3C, $00, // 36
    $00, $7E, $06, $0C, $18, $30, $30, $00, // 37
    $00, $3C, $66, $3C, $66, $66, $3C, $00, // 38
    $00, $3C, $66, $3E, $06, $0C, $38, $00, // 39
    $00, $00, $18, $18, $00, $18, $18, $00, // 3A
    $00, $00, $18, $18, $00, $18, $18, $30, // 3B
    $06, $0C, $18, $30, $18, $0C, $06, $00, // 3C
    $00, $00, $7E, $00, $00, $7E, $00, $00, // 3D
    $60, $30, $18, $0C, $18, $30, $60, $00, // 3E
    $00, $3C, $66, $0C, $18, $00, $18, $00, // 3F
    $00, $3C, $66, $6E, $6E, $60, $3E, $00, // 40
    $00, $18, $3C, $66, $66, $7E, $66, $00, // 41
    $00, $7C, $66, $7C, $66, $66, $7C, $00, // 42
    $00, $3C, $66, $60, $60, $66, $3C, $00, // 43
    $00, $78, $6C, $66, $66, $6C, $78, $00, // 44
    $00, $7E, $60, $7C, $60, $60, $7E, $00, // 45
    $00, $7E, $60, $7C, $60, $60, $60, $00, // 46
    $00, $3E, $60, $60, $6E, $66, $3E, $00, // 47
    $00, $66, $66, $7E, $66, $66, $66, $00, // 48
    $00, $7E, $18, $18, $18, $18, $7E, $00, // 49
    $00, $06, $06, $06, $06, $66, $3C, $00, // 4A
    $00, $66, $6C, $78, $78, $6C, $66, $00, // 4B
    $00, $60, $60, $60, $60, $60, $7E, $00, // 4C
    $00, $63, $77, $7F, $6B, $63, $63, $00, // 4D
    $00, $66, $76, $7E, $7E, $6E, $66, $00, // 4E
    $00, $3C, $66, $66, $66, $66, $3C, $00, // 4F
    $00, $7C, $66, $66, $7C, $60, $60, $00, // 50
    $00, $3C, $66, $66, $66, $6C, $36, $00, // 51
    $00, $7C, $66, $66, $7C, $6C, $66, $00, // 52
    $00, $3C, $60, $3C, $06, $06, $3C, $00, // 53
    $00, $7E, $18, $18, $18, $18, $18, $00, // 54
    $00, $66, $66, $66, $66, $66, $7E, $00, // 55
    $00, $66, $66, $66, $66, $3C, $18, $00, // 56
    $00, $63, $63, $6B, $7F, $77, $63, $00, // 57
    $00, $66, $66, $3C, $3C, $66, $66, $00, // 58
    $00, $66, $66, $3C, $18, $18, $18, $00, // 59
    $00, $7E, $0C, $18, $30, $60, $7E, $00, // 5A
    $00, $1E, $18, $18, $18, $18, $1E, $00, // 5B
    $00, $40, $60, $30, $18, $0C, $06, $00, // 5C
    $00, $78, $18, $18, $18, $18, $78, $00, // 5D
    $00, $08, $1C, $36, $63, $00, $00, $00, // 5E
    $00, $00, $00, $00, $00, $00, $FF, $00, // 5F
    $00, $18, $3C, $7E, $7E, $3C, $18, $00, // 60
    $00, $00, $3C, $06, $3E, $66, $3E, $00, // 61
    $00, $60, $60, $7C, $66, $66, $7C, $00, // 62
    $00, $00, $3C, $60, $60, $60, $3C, $00, // 63
    $00, $06, $06, $3E, $66, $66, $3E, $00, // 64
    $00, $00, $3C, $66, $7E, $60, $3C, $00, // 65
    $00, $0E, $18, $3E, $18, $18, $18, $00, // 66
    $00, $00, $3E, $66, $66, $3E, $06, $7C, // 67
    $00, $60, $60, $7C, $66, $66, $66, $00, // 68
    $00, $18, $00, $38, $18, $18, $3C, $00, // 69
    $00, $06, $00, $06, $06, $06, $06, $3C, // 6A
    $00, $60, $60, $6C, $78, $6C, $66, $00, // 6B
    $00, $38, $18, $18, $18, $18, $3C, $00, // 6C
    $00, $00, $66, $7F, $7F, $6B, $63, $00, // 6D
    $00, $00, $7C, $66, $66, $66, $66, $00, // 6E
    $00, $00, $3C, $66, $66, $66, $3C, $00, // 6F
    $00, $00, $7C, $66, $66, $7C, $60, $60, // 70
    $00, $00, $3E, $66, $66, $3E, $06, $06, // 71
    $00, $00, $7C, $66, $60, $60, $60, $00, // 72
    $00, $00, $3E, $60, $3C, $06, $7C, $00, // 73
    $00, $18, $7E, $18, $18, $18, $0E, $00, // 74
    $00, $00, $66, $66, $66, $66, $3E, $00, // 75
    $00, $00, $66, $66, $66, $3C, $18, $00, // 76
    $00, $00, $63, $6B, $7F, $3E, $36, $00, // 77
    $00, $00, $66, $3C, $18, $3C, $66, $00, // 78
    $00, $00, $66, $66, $66, $3E, $0C, $78, // 79
    $00, $00, $7E, $0C, $18, $30, $7E, $00, // 7A
    $00, $18, $3C, $7E, $7E, $18, $3C, $00, // 7B
    $18, $18, $18, $18, $18, $18, $18, $18, // 7C
    $00, $7E, $78, $7C, $6E, $66, $06, $00, // 7D
    $08, $18, $38, $78, $38, $18, $08, $00, // 7E
    $10, $18, $1C, $1E, $1C, $18, $10, $00, // 7F
    $00, $36, $7F, $7F, $3E, $1C, $08, $00, // 80
    $18, $18, $18, $1F, $1F, $18, $18, $18, // 81
    $03, $03, $03, $03, $03, $03, $03, $03, // 82
    $18, $18, $18, $F8, $F8, $00, $00, $00, // 83
    $18, $18, $18, $F8, $F8, $18, $18, $18, // 84
    $00, $00, $00, $F8, $F8, $18, $18, $18, // 85
    $03, $07, $0E, $1C, $38, $70, $E0, $C0, // 86
    $C0, $E0, $70, $38, $1C, $0E, $07, $03, // 87
    $01, $03, $07, $0F, $1F, $3F, $7F, $FF, // 88
    $00, $00, $00, $00, $0F, $0F, $0F, $0F, // 89
    $80, $C0, $E0, $F0, $F8, $FC, $FE, $FF, // 8A
    $0F, $0F, $0F, $0F, $00, $00, $00, $00, // 8B
    $F0, $F0, $F0, $F0, $00, $00, $00, $00, // 8C
    $FF, $FF, $00, $00, $00, $00, $00, $00, // 8D
    $00, $00, $00, $00, $00, $00, $FF, $FF, // 8E
    $00, $00, $00, $00, $F0, $F0, $F0, $F0, // 8F
    $00, $1C, $1C, $77, $77, $08, $1C, $00, // 90
    $00, $00, $00, $1F, $1F, $18, $18, $18, // 91
    $00, $00, $00, $FF, $FF, $00, $00, $00, // 92
    $18, $18, $18, $FF, $FF, $18, $18, $18, // 93
    $00, $00, $3C, $7E, $7E, $7E, $3C, $00, // 94
    $00, $00, $00, $00, $FF, $FF, $FF, $FF, // 95
    $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0, // 96
    $00, $00, $00, $FF, $FF, $18, $18, $18, // 97
    $18, $18, $18, $FF, $FF, $00, $00, $00, // 98
    $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, // 99
    $18, $18, $18, $1F, $1F, $00, $00, $00, // 9A
    $78, $60, $78, $60, $7E, $18, $1E, $00, // 9B
    $00, $18, $3C, $7E, $18, $18, $18, $00, // 9C
    $00, $18, $18, $18, $7E, $3C, $18, $00, // 9D
    $00, $18, $30, $7E, $30, $18, $00, $00, // 9E
    $00, $18, $0C, $7E, $0C, $18, $00, $00);// 9F

{ TDebugTextUserFontApp }

procedure TDebugTextUserFontApp.Cleanup;
begin
  inherited;
  TDbgText.Shutdown;
end;

procedure TDebugTextUserFontApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'DebugTextUserFont';
end;

procedure TDebugTextUserFontApp.Frame;
begin
  TDbgText.Canvas(FramebufferWidth * 0.25, FramebufferHeight * 0.25);
  TDbgText.Origin(1, 2);
  TDbgText.Font(USER_FONT);
  TDbgText.Color($FF, $17, $44);
  TDbgText.WriteLn('Hello 8-bit ATARI font:');
  TDbgText.NewLine;

  var Line := 0;
  for var C: AnsiChar := #$20 to #$9F do
  begin
    if ((Ord(C) and $0F) = 0) then
    begin
      TDbgText.NewLine;
      TDbgText.Write(#9);
      Inc(Line);
    end;

    { Color scrolling effect: }
    var Index := ((Ord(C) + Line + (FrameCount div 2)) and $0F) * 3;
    TDbgText.Color(COLOR_PALETTE[Index], COLOR_PALETTE[Index + 1], COLOR_PALETTE[Index + 2]);
    TDbgText.Write(C);
  end;

  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  TDbgText.Draw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TDebugTextUserFontApp.Init;
begin
  inherited;
  FPassAction.Colors[0].Init(TAction.Clear, 0, 0.125, 0.25, 0);

  { Setup Neslib.Sokol.DebugText with the user font as the only font.
    Note that the user font only provides pixel data for the characters #$20 to
    #$9F inclusive. }
  var Desc := TDbgTextDesc.Create;
  Desc.Fonts[USER_FONT].Data := TRange.Create(USER_FONT_DATA);
  Desc.Fonts[USER_FONT].FirstChar := #$20;
  Desc.Fonts[USER_FONT].LastChar := #$9F;
  TDbgText.Setup(Desc);
end;

end.

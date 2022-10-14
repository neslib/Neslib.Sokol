unit FontStashApp;

interface

uses
  System.UITypes,
  Neslib.FontStash,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.GL,
  Neslib.Sokol.Fetch,
  Neslib.Sokol.FontStash,
  SampleApp;

type
  TFontStashApp = class(TSampleApp)
  private
    FFontStash: TFontStash;
    FDpiScale: Single;
    FFontNormal: Integer;
    FFontItalic: Integer;
    FFontBold: Integer;
    FFontJapanese: Integer;
    FFontNormalData: array [0..(256 * 1024) - 1] of Byte;
    FFontItalicData: array [0..(256 * 1024) - 1] of Byte;
    FFontBoldData: array [0..(256 * 1024) - 1] of Byte;
    FFontJapaneseData: array [0..(2 * 1024 * 1024) - 1] of Byte;
  private
    procedure FontNormalLoaded(const AResponse: TFetchResponse);
    procedure FontItalicLoaded(const AResponse: TFetchResponse);
    procedure FontBoldLoaded(const AResponse: TFetchResponse);
    procedure FontJapaneseLoaded(const AResponse: TFetchResponse);
  private
    class procedure Line(const ASX, ASY, AEX, AEY: Single); static;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api;

function RoundPow2(const AValue: Single): Integer;
{ Round to next power of 2 (see bit-twiddling-hacks) }
begin
  Result := Trunc(AValue) - 1;
  for var I := 0 to 4 do
    Result := Result or (Result shr (1 shl I));
  Inc(Result);
end;

{ TFontStashApp }

procedure TFontStashApp.Cleanup;
begin
  TFetch.Shutdown;
  TSokolFontStash.Free(FFontStash);
  sglShutdown;
  inherited;
end;

procedure TFontStashApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.HighDpi := True;
  AConfig.WindowTitle := 'FontStash';
end;

procedure TFontStashApp.FontBoldLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
    FFontBold := FFontStash.AddFont('sans-bold', AResponse.BufferPtr, AResponse.FetchedSize);
end;

procedure TFontStashApp.FontItalicLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
    FFontItalic := FFontStash.AddFont('sans-italic', AResponse.BufferPtr, AResponse.FetchedSize);
end;

procedure TFontStashApp.FontJapaneseLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
    FFontJapanese := FFontStash.AddFont('sans-japanese', AResponse.BufferPtr, AResponse.FetchedSize);
end;

procedure TFontStashApp.FontNormalLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
    FFontNormal := FFontStash.AddFont('sans', AResponse.BufferPtr, AResponse.FetchedSize);
end;

procedure TFontStashApp.Frame;
begin
  var Dpis := FDpiScale;

  { Pump sokol_fetch message queues }
  TFetch.DoWork;

  { Text rendering via Neslib.FontStash }
  var SX: Single := 50 * Dpis;
  var SY: Single := 50 * Dpis;
  var DX: Single := SX;
  var DY: Single := SY;
  var LH: Single := 0;
  FFontStash.ClearState;

  sglDefaults;
  sglMatrixModeProjection;
  sglOrtho(0, FramebufferWidth, FramebufferHeight, 0, -1, 1);

  if (FFontNormal <> FONT_STASH_INVALID) then
  begin
    FFontStash.SetFont(FFontNormal);
    FFontStash.SetSize(124 * Dpis);
    FFontStash.GetVertMetrics(nil, nil, @LH);
    DX := SX;
    DY := DY + LH;
    FFontStash.SetColor(TAlphaColors.White);
    DX := FFontStash.DrawText(DX, DY, 'The quick ');
  end;

  if (FFontItalic <> FONT_STASH_INVALID) then
  begin
    FFontStash.SetFont(FFontItalic);
    FFontStash.SetSize(48 * Dpis);
    FFontStash.SetColor(TAlphaColors.Sandybrown);
    DX := FFontStash.DrawText(DX, DY, 'brown ');
  end;

  if (FFontNormal <> FONT_STASH_INVALID) then
  begin
    FFontStash.SetFont(FFontNormal);
    FFontStash.SetSize(24 * Dpis);
    FFontStash.SetColor(TAlphaColors.White);
    DX := FFontStash.DrawText(DX, DY, 'fox');
  end;

  if (FFontNormal <> FONT_STASH_INVALID) and (FFontItalic <> FONT_STASH_INVALID)
    and (FFontBold <> FONT_STASH_INVALID) then
  begin
    FFontStash.GetVertMetrics(nil, nil, @LH);
    DX := SX;
    DY := DY + (LH * 1.2);
    FFontStash.SetFont(FFontItalic);
    DX := FFontStash.DrawText(DX, DY, 'jumps over ');
    FFontStash.SetFont(FFontBold);
    DX := FFontStash.DrawText(DX, DY, 'the lazy ');
    FFontStash.SetFont(FFontNormal);
    FFontStash.DrawText(DX, DY, 'dog.');
  end;

  if (FFontNormal <> FONT_STASH_INVALID) then
  begin
    DX := SX;
    DY := DY + (LH * 1.2);
    FFontStash.SetSize(12 * Dpis);
    FFontStash.SetFont(FFontNormal);
    FFontStash.SetColor(TAlphaColors.Deepskyblue);
    FFontStash.DrawText(DX, DY, 'Now is the time for all good men to come to the aid of the party.');
  end;

  if (FFontItalic <> FONT_STASH_INVALID) then
  begin
    FFontStash.GetVertMetrics(nil, nil, @LH);
    DX := SX;
    DY := DY + (LH * 1.2 * 2);
    FFontStash.SetSize(18 * Dpis);
    FFontStash.SetFont(FFontItalic);
    FFontStash.SetColor(TAlphaColors.White);
    FFontStash.DrawText(DX, DY, 'Ég get etið gler án þess að meiða mig.');
  end;

  if (FFontJapanese <> FONT_STASH_INVALID) then
  begin
    FFontStash.GetVertMetrics(nil, nil, @LH);
    DX := SX;
    DY := DY + (LH * 1.2);
    FFontStash.SetFont(FFontJapanese);
    FFontStash.SetColor(TAlphaColors.White);
    FFontStash.DrawText(DX, DY, '私はガラスを食べられます。それは私を傷つけません。');
  end;

  { Font alignment }
  if (FFontNormal <> FONT_STASH_INVALID) then
  begin
    FFontStash.SetSize(18 * Dpis);
    FFontStash.SetFont(FFontNormal);
    FFontStash.SetColor(TAlphaColors.White);

    DX := 50 * Dpis;
    DY := 350 * Dpis;
    Line(DX - (10 * Dpis), DY, DX + (250 * Dpis), DY);

    FFontStash.SetAlign(TFontStashHorzAlign.Left, TFontStashVertAlign.Top);
    DX := FFontStash.DrawText(DX, DY, 'Top');

    DX := DX + (10 * Dpis);
    FFontStash.SetAlign(TFontStashHorzAlign.Left, TFontStashVertAlign.Middle);
    DX := FFontStash.DrawText(DX, DY, 'Middle');

    DX := DX + (10 * Dpis);
    FFontStash.SetAlign(TFontStashHorzAlign.Left, TFontStashVertAlign.Baseline);
    DX := FFontStash.DrawText(DX, DY, 'Baseline');

    DX := DX + (10 * Dpis);
    FFontStash.SetAlign(TFontStashHorzAlign.Left, TFontStashVertAlign.Bottom);
    FFontStash.DrawText(DX, DY, 'Bottom');

    DX := 150 * Dpis;
    DY := 400 * Dpis;
    Line(DX, DY - (30 * Dpis), DX, DY + (80 * Dpis));

    FFontStash.SetAlign(TFontStashHorzAlign.Left, TFontStashVertAlign.Baseline);
    FFontStash.DrawText(DX, DY, 'Left');

    DY := DY + (30 * Dpis);
    FFontStash.SetAlign(TFontStashHorzAlign.Center, TFontStashVertAlign.Baseline);
    FFontStash.DrawText(DX, DY, 'Center');

    DY := DY + (30 * Dpis);
    FFontStash.SetAlign(TFontStashHorzAlign.Right, TFontStashVertAlign.Baseline);
    FFontStash.DrawText(DX, DY, 'Right');
  end;

  { Blur }
  if (FFontItalic <> FONT_STASH_INVALID) then
  begin
    DX := 500 * Dpis;
    DY := 350 * Dpis;
    FFontStash.SetAlign(TFontStashHorzAlign.Left, TFontStashVertAlign.Baseline);
    FFontStash.SetSize(60 * Dpis);
    FFontStash.SetFont(FFontItalic);
    FFontStash.SetColor(TAlphaColors.White);
    FFontStash.SetSpacing(5 * Dpis);
    FFontStash.SetBlur(10 * Dpis);
    FFontStash.DrawText(DX, DY, 'Blurry...');
  end;

  { Drop shadow }
  if (FFontBold <> FONT_STASH_INVALID) then
  begin
    DY := DY + (50 * Dpis);
    FFontStash.SetSize(18 * Dpis);
    FFontStash.SetFont(FFontBold);
    FFontStash.SetColor(TAlphaColors.Black);
    FFontStash.SetSpacing(0);
    FFontStash.SetBlur(3 * Dpis);
    FFontStash.DrawText(DX, DY + (2 * Dpis), 'DROP THAT SHADOW');
    FFontStash.SetColor(TAlphaColors.White);
    FFontStash.SetBlur(0);
    FFontStash.DrawText(DX, DY, 'DROP THAT SHADOW');
  end;

  { Flush FontStash's font atlas to Sokol Gfx texture }
  TSokolFontStash.Flush(FFontStash);

  { Render pass }
  var PassAction := TPassAction.Create;
  PassAction.Colors[0].Init(TAction.Clear, 0.3, 0.3, 0.32);
  TGfx.BeginDefaultPass(PassAction, FramebufferWidth, FramebufferHeight);

  sglDraw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TFontStashApp.Init;
begin
  inherited;
  FDpiScale := DpiScale;
  var GLDesc := TGLDesc.Create;
  sglSetup(GLDesc);

  { Make sure the fontstash atlas width/height is pow-2 }
  var AtlasDim := RoundPow2(512 * FDpiScale);

  FFontStash := TSokolFontStash.Create(AtlasDim, AtlasDim);
  FFontNormal := FONT_STASH_INVALID;
  FFontItalic := FONT_STASH_INVALID;
  FFontBold := FONT_STASH_INVALID;
  FFontJapanese := FONT_STASH_INVALID;

  { Use Neslib.Sokol.Fetch for loading the TTF font files }
  var FetchDesc := TFetchDesc.Create;
  FetchDesc.NumChannels := 1;
  FetchDesc.NumLanes := 4;
  FetchDesc.BaseDirectory := 'Data/Fonts';
  TFetch.Setup(FetchDesc);

  var Request := TFetchRequest.Create('DroidSerif-Regular.ttf', FontNormalLoaded,
    @FFontNormalData, Length(FFontNormalData));
  Request.Send;

  Request := TFetchRequest.Create('DroidSerif-Italic.ttf', FontItalicLoaded,
    @FFontItalicData, Length(FFontItalicData));
  Request.Send;

  Request := TFetchRequest.Create('DroidSerif-Bold.ttf', FontBoldLoaded,
    @FFontBoldData, Length(FFontBoldData));
  Request.Send;

  Request := TFetchRequest.Create('DroidSansJapanese.ttf', FontJapaneseLoaded,
    @FFontJapaneseData, Length(FFontJapaneseData));
  Request.Send;
end;

class procedure TFontStashApp.Line(const ASX, ASY, AEX, AEY: Single);
begin
  sglBeginLines;
  sglC4B(255, 255, 0, 128);
  sglV2F(ASX, ASY);
  sglV2F(AEX, AEY);
  sglEnd;
end;

end.

unit IconApp;

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.DebugText,
  SampleApp;

const
  ICON_WIDTH  = 8;
  ICON_HEIGHT = 8;

type
  TIconMode = (None, Default, User);

type
  TIconApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
    FIconModeChanged: Boolean;
    FIconMode: TIconMode;
  private
    procedure SetUserIcon;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure KeyChar(const AChar: UCS4Char; const AModifiers: TModifiers;
      const AKeyRepeat: Boolean); override;
  end;

implementation

uses
  Neslib.Sokol.Api;

const
  HELP_TEXT: array [TIconMode] of AnsiString = (
    '<NONE>', '1: default icon', '2: user icon');

{ TIconApp }

procedure TIconApp.Cleanup;
begin
  inherited;
  TDbgText.Shutdown;
end;

procedure TIconApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'Window Icon Test';
  AConfig.Icon.UseDefault := False;
end;

procedure TIconApp.Frame;
begin
  { Apply icon mode changes }
  if (FIconModeChanged) then
  begin
    FIconModeChanged := False;
    case FIconMode of
      TIconMode.Default:
        begin
          var IconDesc := TIconDesc.Create;
          IconDesc.UseDefault := True;
          SetAppIcon(IconDesc);
        end;

      TIconMode.User:
        SetUserIcon;
    end;
  end;

  { Print help text }
  TDbgText.Canvas(FramebufferWidth * 0.5, FramebufferHeight * 0.5);
  TDbgText.Origin(1, 2);
  TDbgText.Home;
  TDbgText.WriteAnsiLn('Press key to switch icon:');
  TDbgText.NewLine;

  for var Mode := TIconMode.Default to TIconMode.User do
  begin
    if (Mode = FIconMode) then
      TDbgText.WriteAnsi('==> ')
    else
      TDbgText.WriteAnsi('    ');

    TDbgText.WriteAnsiLn(HELP_TEXT[Mode]);
  end;

  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  TDbgText.Draw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TIconApp.Init;
begin
  inherited;
  FPassAction.Colors[0].Init(TAction.Clear, 0, 0.25, 0.5, 1);

  var DbgDesc := TDbgTextDesc.Create;
  DbgDesc.Fonts[0] := TDbgTextFont.Oric;
  TDbgText.Setup(DbgDesc);
end;

procedure TIconApp.KeyChar(const AChar: UCS4Char; const AModifiers: TModifiers;
  const AKeyRepeat: Boolean);
begin
  inherited;
  case AChar of
    Ord('1'): begin
                FIconMode := TIconMode.Default;
                FIconModeChanged := True;
              end;
    Ord('2'): begin
                FIconMode := TIconMode.User;
                FIconModeChanged := True;
              end;
  end;
end;

procedure TIconApp.SetUserIcon;

  procedure FillArrowPixels(APixels: PUInt32; const AW, AH: Integer);
  const
    COLORS: array [0..3] of UInt32 = (
    { Red       Green      Blue       Yellow }
      $FF0000FF, $FF00FF00, $FFFF0000, $FF00FFFF);
  begin
    for var Y := 0 to AH - 1 do
    begin
      for var X := 0 to AW - 1 do
      begin
        var Color := COLORS[((X xor Y) shr 1) and 3]; // RGBY checker pattern

        { Arrow shape }
        if (Y < (AH div 2)) then
        begin
          if (X < ((AH div 2) - Y)) or (X > ((AH div 2) + Y)) then
            Color := 0;
        end
        else
        begin
          if (X < (AW div 4)) or (X > ((AW div 4) * 3)) then
            Color := 0;
        end;

        APixels^ := Color;
        Inc(APixels);
      end;
    end;
  end;

{ Create 3 icon image candidates, 16x16, 32x32 and 64x64 pixels.
  The Neslib.Sokol.App backend code will pick the best match by size }
var
  Small: array [0..(16 * 16) - 1] of UInt32;
  Medium: array [0..(32 * 32) - 1] of UInt32;
  Big: array [0..(64 * 64) - 1] of UInt32;
begin
  FillArrowPixels(@Small, 16, 16);
  FillArrowPixels(@Medium, 32, 32);
  FillArrowPixels(@Big, 64, 64);

  var IconDesc := TIconDesc.Create;
  IconDesc.Images[0].Init(16, 16, @Small, SizeOf(Small));
  IconDesc.Images[1].Init(32, 32, @Medium, SizeOf(Medium));
  IconDesc.Images[2].Init(64, 64, @Big, SizeOf(Big));

  SetAppIcon(IconDesc);
end;

end.

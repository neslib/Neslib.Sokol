unit DebugTextApp;
{ Text rendering with Neslib.Sokol.DebugText. Test builtin fonts. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.DebugText,
  SampleApp;

type
  TDebugTextApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
  private
    procedure PrintFont(const AFontIndex: Integer; const ATitle: String;
      const AR, AG, AB: Byte);
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api;

{ TDebugTextApp }

procedure TDebugTextApp.Cleanup;
begin
  inherited;
  TDbgText.Shutdown;
end;

procedure TDebugTextApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 1024;
  AConfig.Height := 600;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'DebugText';
end;

procedure TDebugTextApp.Frame;
begin
  { Set virtual canvas size to half display size so that glyphs are 16x16
    display pixels. }
  TDbgText.Canvas(FramebufferWidth * 0.5, FramebufferHeight * 0.5);
  TDbgText.Origin(0, 2);
  TDbgText.Home;

  PrintFont(0, 'KC85/3:', $F4, $43, $36);
  PrintFont(1, 'KC85/4:', $21, $96, $F3);
  PrintFont(2, 'Z1013:', $4C, $AF, $50);
  PrintFont(3, 'Amstrad CPC:', $FF, $EB, $3B);
  PrintFont(4, 'C64:', $79, $86, $CB);
  PrintFont(5, 'Oric Atmos:', $FF, $98, $00);

  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  TDbgText.Draw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TDebugTextApp.Init;
begin
  inherited;
  FPassAction.Colors[0].Init(TAction.Clear, 0, 0.125, 0.25, 0);

  var Desc := TDbgTextDesc.Create;
  Desc.Fonts[0] := TDbgTextFont.KC853;
  Desc.Fonts[1] := TDbgTextFont.KC854;
  Desc.Fonts[2] := TDbgTextFont.Z1013;
  Desc.Fonts[3] := TDbgTextFont.CPC;
  Desc.Fonts[4] := TDbgTextFont.C64;
  Desc.Fonts[5] := TDbgTextFont.Oric;
  TDbgText.Setup(Desc);
end;

procedure TDebugTextApp.PrintFont(const AFontIndex: Integer;
  const ATitle: String; const AR, AG, AB: Byte);
begin
  TDbgText.Font(AFontIndex);
  TDbgText.Color(AR, AG, AB);
  TDbgText.WriteLn(ATitle);
  for var C: AnsiChar := #32 to #255 do
  begin
    TDbgText.Write(C);
    if (((Ord(C) + 1) and 63) = 0) then
      TDbgText.NewLine;
  end;
  TDbgText.NewLine;
end;

end.

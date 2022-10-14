unit DebugTextFormatApp;
{ Simple text rendering with Neslib.Sokol.DebugText. Formatting, tabs, etc... }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.DebugText,
  SampleApp;

const
  NUM_FONTS = 3;

type
  TDebugTextFormatApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
    FPalette: array [0..NUM_FONTS - 1] of Cardinal;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api;

{ TDebugTextFormatApp }

procedure TDebugTextFormatApp.Cleanup;
begin
  inherited;
  TDbgText.Shutdown;
end;

procedure TDebugTextFormatApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 640;
  AConfig.Height := 480;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'DebugTextFormat';
end;

procedure TDebugTextFormatApp.Frame;
begin
  var FrameCount: Integer := Self.FrameCount;
  var FrameTime: Double := FrameDuration * 1000;

  TDbgText.Canvas(FramebufferWidth * 0.5, FramebufferHeight * 0.5);
  TDbgText.Origin(3, 3);
  for var I := 0 to NUM_FONTS - 1 do
  begin
    TDbgText.Font(I);
    TDbgText.Color(FPalette[I]);

    if ((FrameCount and (1 shl 7)) <> 0) then
      TDbgText.WriteAnsiLn('Hello ''Welt''!')
    else
      TDbgText.WriteAnsiLn('Hello ''World''!');

    TDbgText.WriteLn(#9'Frame Time:'#9#9'%.3f', [FrameTime]);
    TDbgText.WriteLn(#9'Frame Count:'#9'%d'#9'$%0:.4x', [FrameCount]);

    TDbgText.WriteAnsi('Range Test 1(xyzbla)', 12);
    TDbgText.NewLine;
    TDbgText.WriteLn('Range Test 2', 32);

    TDbgText.MoveY(2);
  end;

  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  TDbgText.Draw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TDebugTextFormatApp.Init;
begin
  inherited;
  FPassAction.Colors[0].Init(TAction.Clear, 0, 0.125, 0.25, 0);
  FPalette[0] := $FF3643F4;
  FPalette[1] := $FFF39621;
  FPalette[2] := $FF50AF4C;

  var Desc := TDbgTextDesc.Create;
  Desc.Fonts[0] := TDbgTextFont.KC854;
  Desc.Fonts[1] := TDbgTextFont.C64;
  Desc.Fonts[2] := TDbgTextFont.Oric;
  TDbgText.Setup(Desc);
end;

end.

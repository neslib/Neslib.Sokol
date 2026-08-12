unit SglBoingApp;
{ Amiga-style bouncing ball demo via Neslib.Sokol.GL }

interface

uses
  System.UITypes,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.GL,
  SampleApp;

type
  TSglBoingApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
    FBallX: Single;
    FBallY: Single;
    FBallVX: Single;
    FBallVY: Single;
    FBallRadius: Single;
    FBallRotZ: Single;
    FBallRotX: Single;
  private
    class procedure DrawBall(const AX, AY, AR, ARotZ, ARotX: Single;
      const AC0, AC1: TColor); static;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.FastMath,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue;

const
  BG_COLOR: TColor = (R: 0.2; G: 0.2; B: 0.4; A: 1);

{ TSglBoingApp }

procedure TSglBoingApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'Neslib.Sokol.GL Boing';
end;

procedure TSglBoingApp.Init;
begin
  inherited;
  var GLDesc := TGLDesc.Create;
  GLDesc.UseDelphiMemoryManager := True;
  GLDesc.Logger := GLDesc.DefaultLogger;
  sglSetup(GLDesc);

  FPassAction.Colors[0].Init(TLoadAction.Clear, BG_COLOR);

  FBallRadius := 70;
  FBallX := FBallRadius + 20;
  FBallY := FramebufferHeight - FBallRadius - 20;
  FBallVX := 300;
  FBallVY := -FramebufferHeight;
end;

procedure TSglBoingApp.Frame;
const
  GRAVITY = 800;
  RED: TColor = (R: 0.9; G: 0.1; B: 0.1; A: 1);
  WHITE: TColor = (R: 1; G: 1; B: 1; A: 1);
begin
  var DT: Single := FrameDuration;

  { Apply gravity }
  FBallVY := FBallVY + (GRAVITY * DT);

  { Update position }
  FBallX := FBallX + (FBallVX * DT);
  FBallY := FBallY + (FBallVY * DT);

  { Bounce off floor }
  var FloorY: Single := FramebufferHeight - FBallRadius;
  if (FBallY > FloorY) then
  begin
    FBallY := FloorY;
    { Fixed upward velocity = constant bounce height }
    FBallVY := -FramebufferHeight;
  end;

  { Bounce off walls }
  if (FBallX < FBallRadius) then
  begin
    FBallX := FBallRadius;
    FBallVX := -FBallVX;
  end;

  if (FBallX > (FramebufferWidth - FBallRadius)) then
  begin
    FBallX := FramebufferWidth - FBallRadius;
    FBallVX := -FBallVX;
  end;

  { Update rotation based on movement }
  FBallRotZ := FBallRotZ + (FBallVX * DT * 0.3); // Rotate with horizontal movement
  FBallRotX := FBallRotX + (FBallVY * DT * 0.2); // Y-axis spin with vertical movement

  var Shadow := TColor.Create(BG_COLOR.R * 0.5, BG_COLOR.G * 0.5, BG_COLOR.B * 0.5, 1);

  sglDefaults;
  sglMatrixModeProjection;
  sglOrtho(0, FramebufferWidth, FramebufferHeight, 0, -100, 100);
  sglMatrixModeModelview;

  DrawBall(FBallX + 20, FBallY + 30, FBallRadius * 1.05, FBallRotZ, FBallRotX, Shadow, Shadow);
  DrawBall(FBallX, FBallY, FBallRadius, FBallRotZ, FBallRotX, RED, WHITE);

  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  sglDraw;

  DebugFrame;

  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TSglBoingApp.Cleanup;
begin
  sglShutdown;
  inherited;
end;

class procedure TSglBoingApp.DrawBall(const AX, AY, AR, ARotZ, ARotX: Single;
  const AC0, AC1: TColor);
const
  BANDS = 12;
  SEGS  = 12;
begin
  sglPushMatrix;
  sglTranslate(AX, AY, 0);
  sglRotate(sglRad(ARotZ), 0, 0, 1);
  sglRotate(sglRad(ARotX), 1, 0, 0);

  sglBeginQuads;
  for var Lat := 0 to BANDS - 1 do
  begin
    var LatF: Single := Lat;
    var T1: Single := Pi * (LatF / BANDS) - (Pi * 0.5);
    var T2: Single := Pi * ((LatF + 1) / BANDS) - (Pi * 0.5);
    var SinT1, CosT1, SinT2, CosT2: Single;
    FastSinCos(T1, SinT1, CosT1);
    FastSinCos(T2, SinT2, CosT2);

    for var Lon := 0 to SEGS - 1 do
    begin
      var LonF: Single := Lon;
      var P1: Single := 2 * Pi * (LonF / SEGS);
      var P2: Single := 2 * Pi * ((LonF + 1) / SEGS);
      var IsRed := (((Lat + Lon) and 1) <> 0);
      var SinP1, CosP1, SinP2, CosP2: Single;
      FastSinCos(P1, SinP1, CosP1);
      FastSinCos(P2, SinP2, CosP2);

      if (IsRed) then
        sglC3F(AC0.R, AC0.G, AC0.B)
      else
        sglC3F(AC1.R, AC1.G, AC1.B);

      sglV3F(AR * CosT1 * CosP1, AR * SinT1, AR * CosT1 * SinP1);
      sglV3F(AR * CosT1 * CosP2, AR * SinT1, AR * CosT1 * SinP2);
      sglV3F(AR * CosT2 * CosP2, AR * SinT2, AR * CosT2 * SinP2);
      sglV3F(AR * CosT2 * CosP1, AR * SinT2, AR * CosT2 * SinP1);
    end;
  end;
  sglEnd;
  sglPopMatrix;
end;

end.

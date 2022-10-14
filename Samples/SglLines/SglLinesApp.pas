unit SglLinesApp;
{ Line rendering with Neslib.Sokol.GL }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.GL,
  SampleApp;

type
  TSglLinesApp = class(TSampleApp)
  const
    RING_NUM  = 1024;
    RING_MASK = RING_NUM - 1;
  private
    FPassAction: TPassAction;
    FDepthTestPip: TGLPipeline;
    FHead: Integer;
    FX: Cardinal;
    FRing: array [0..RING_NUM - 1, 0..5] of Single;
  private
    procedure Grid(const AY: Single; const AFrameCount: Integer);
    procedure FloatyThingy(const AFrameCount: Integer);
    procedure Hairball;
    function Rnd: Single; inline;
    function XorShift32: Cardinal; inline;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api;

{ TSglLinesApp }

procedure TSglLinesApp.Cleanup;
begin
  FDepthTestPip.Free;
  sglShutdown;
  inherited;
end;

procedure TSglLinesApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 512;
  AConfig.Height := 512;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Neslib.Sokol.GL Lines';
end;

procedure TSglLinesApp.FloatyThingy(const AFrameCount: Integer);
const
  NUM_SEGS = 32;
  DX       = 0.25;
  DY       = 0.25;
  X0       = -(NUM_SEGS * DX * 0.5);
  X1       = -X0;
  Y0       = -(NUM_SEGS * DY * 0.5);
  Y1       = -Y0;
begin
  var Start := AFrameCount mod (NUM_SEGS * 2);
  if (Start < NUM_SEGS) then
    Start := 0
  else
    Dec(Start, NUM_SEGS);

  var Stop := AFrameCount mod (NUM_SEGS * 2);
  if (Stop > NUM_SEGS) then
    Stop := NUM_SEGS;

  sglBeginLines;
  for var I := Start to Stop - 1 do
  begin
    var X: Single := I * DX;
    var Y: Single := I * DY;
    sglV2f(X0 + X, Y0); sglV2f(X1, Y0 + Y);
    sglV2f(X1 - X, Y1); sglV2f(X0, Y1 - Y);
    sglV2f(X0 + X, Y1); sglV2f(X1, Y1 - Y);
    sglV2f(X1 - X, Y0); sglV2f(X0, Y0 + Y);
  end;
  sglEnd;
end;

procedure TSglLinesApp.Frame;
begin
  var FrameCount: Integer := Self.FrameCount;
  var Aspect: Single := FramebufferWidth / FramebufferHeight;

  sglDefaults;
  sglPushPipeline;
  sglLoadPipeline(FDepthTestPip);

  sglMatrixModeProjection;
  sglPerspective(sglRad(45), Aspect, 0.1, 1000);

  sglMatrixModeModelview;
  sglTranslate(Sin(FrameCount * 0.02) * 16, Sin(FrameCount * 0.01) * 4, 0);

  sglC3f(1, 0, 1);
  Grid(-7, FrameCount);
  Grid(+7, FrameCount);

  sglPushMatrix;
    sglTranslate(0, 0, -30);
    sglRotate(FrameCount * 0.05, 0, 1, 1);
    sglC3f(1, 1, 0);
    FloatyThingy(FrameCount);
  sglPopMatrix;

  sglPushMatrix;
    sglTranslate(-Sin(FrameCount * 0.02) * 32, 0, -70 + Cos(FrameCount * 0.01) * 50);
    sglRotate(FrameCount * 0.05, 0, -1, 1);
    sglC3f(0, 1, 0);
    FloatyThingy(FrameCount + 32);
  sglPopMatrix;

  sglPushMatrix;
    sglTranslate(-Sin(FrameCount * 0.02) * 16, 0, -30);
    sglRotate(FrameCount * 0.01, Sin(FrameCount * 0.005), 0, 1);
    sglC3f(0.5, 1, 0);
    Hairball;
  sglPopMatrix;

  sglPopPipeline;

  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  sglDraw;

  DebugFrame;

  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TSglLinesApp.Grid(const AY: Single; const AFrameCount: Integer);
const
  NUM = 64;
  DIST = 4.0;
begin
  var ZOffset: single := (DIST / 8) * (AFrameCount and 7);
  sglBeginLines;

  for var I := 0 to NUM - 1 do
  begin
    var X: Single := (I * DIST) - (NUM * DIST * 0.5);
    sglV3f(X, AY, -NUM * DIST);
    sglV3f(X, AY, 0);
  end;

  for var I := 0 to NUM - 1 do
  begin
    var Z: Single := ZOffset + (I * DIST) - (NUM * DIST);
    sglV3f(-NUM * DIST * 0.5, AY, Z);
    sglV3f( NUM * DIST * 0.5, AY, Z);
  end;

  sglEnd;
end;

procedure TSglLinesApp.Hairball;
begin
  var VX: Single := Rnd;
  var VY: Single := Rnd;
  var VZ: Single := Rnd;
  var R: Single := (Rnd + 1) * 0.5;
  var G: Single := (Rnd + 1) * 0.5;
  var B: Single := (Rnd + 1) * 0.5;
  var X: Single := FRing[FHead, 0];
  var Y: Single := FRing[FHead, 1];
  var Z: Single := FRing[FHead, 2];

  FHead := (FHead + 1) and RING_MASK;
  FRing[FHead, 0] := (X * 0.9) + VX;
  FRing[FHead, 1] := (Y * 0.9) + VY;
  FRing[FHead, 2] := (Z * 0.9) + VZ;
  FRing[FHead, 3] := R;
  FRing[FHead, 4] := G;
  FRing[FHead, 5] := B;

  sglBeginLineStrip;
  var I := (FHead + 1) and RING_MASK;
  while (I <> FHead) do
  begin
    sglC3f(FRing[I, 3], FRing[I, 4], FRing[I, 5]);
    sglV3f(FRing[I, 0], FRing[I, 1], FRing[I, 2]);
    I := (I + 1) and RING_MASK;
  end;
  sglEnd;
end;

procedure TSglLinesApp.Init;
begin
  inherited;
  { Setup Neslib.Sokol.GL }
  var GLDesc := TGLDesc.Create;
  sglSetup(GLDesc);

  { A pipeline object with less-equal depth-testing }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  FDepthTestPip := TGLPipeline.Create(PipDesc);

  { A default pass action }
  FPassAction.Init;
  FPassAction.Colors[0].Init(TAction.Clear, 0, 0, 0, 1);
  FX := $12345678;
end;

function TSglLinesApp.Rnd: Single;
begin
  Result := (((XorShift32 and $FFFF) / $10000) * 2) - 1;
end;

function TSglLinesApp.XorShift32: Cardinal;
begin
  Result := FX;

  Result := Result xor (Result shl 13);
  Result := Result xor (Result shr 17);
  Result := Result xor (Result shl 5);

  FX := Result;
end;

end.

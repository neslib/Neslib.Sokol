unit SglPointsApp;
{ Test point rendering with Neslib.Sokol.GL }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.GL,
  SampleApp;

type
  TRgb = record
  public
    R, G, B: Single;
  end;

type
  TSglPointsApp = class(TSampleApp)
  private
    class function ComputeColor(const AT: Single): TRgb; static;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.FastMath,
  Neslib.Sokol.Api;

const
  PALETTE: array [0..15] of TRgb = (
    (R: 0.957; G: 0.263; B: 0.212),
    (R: 0.914; G: 0.118; B: 0.388),
    (R: 0.612; G: 0.153; B: 0.690),
    (R: 0.404; G: 0.227; B: 0.718),
    (R: 0.247; G: 0.318; B: 0.710),
    (R: 0.129; G: 0.588; B: 0.953),
    (R: 0.012; G: 0.663; B: 0.957),
    (R: 0.000; G: 0.737; B: 0.831),
    (R: 0.000; G: 0.588; B: 0.533),
    (R: 0.298; G: 0.686; B: 0.314),
    (R: 0.545; G: 0.765; B: 0.290),
    (R: 0.804; G: 0.863; B: 0.224),
    (R: 1.000; G: 0.922; B: 0.231),
    (R: 1.000; G: 0.757; B: 0.027),
    (R: 1.000; G: 0.596; B: 0.000),
    (R: 1.000; G: 0.341; B: 0.133));

{ TSglPointsApp }

procedure TSglPointsApp.Cleanup;
begin
  sglShutdown;
  inherited;
end;

class function TSglPointsApp.ComputeColor(const AT: Single): TRgb;
begin
  { AT is expected to be 0.0 <= AT <= 1.0 }
  var I0 := Trunc(AT * 16) and 15;
  var I1 := (I0 + 1) and 15;
  var L: Single := Frac(AT * 16);
  var C0 := PALETTE[I0];
  var C1 := PALETTE[I1];
  Result.R := (C0.R * (1 - L)) + (C1.R * L);
  Result.G := (C0.G * (1 - L)) + (C1.G * L);
  Result.B := (C0.B * (1 - L)) + (C1.B * L);
end;

procedure TSglPointsApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 512;
  AConfig.Height := 512;
  AConfig.SampleCount := 4;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'Neslib.Sokol.GL Points';
end;

procedure TSglPointsApp.Frame;
begin
  var FrameCount: Integer := Self.FrameCount;
  var Angle: Single := FrameCount mod 360;

  sglDefaults;
  sglBeginPoints;
  var PointSize: Single := 5;
  for var I := 0 to 299 do
  begin
    var A: Single := Radians(Angle + I);
    var Color := ComputeColor(((FrameCount + I) mod 300) / 300);
    var R := FastSin(A * 4);
    var S, C: Single;
    FastSinCos(A, S, C);
    var X: Single := S * R;
    var Y: Single := C * R;
    sglC3F(Color.R, Color.G, Color.B);
    sglPointSize(PointSize);
    sglV2F(X, Y);
    PointSize := PointSize * 1.005;
  end;
  sglEnd;

  var PassAction := TPassAction.Create;
  PassAction.Colors[0].Init(TAction.Clear, 0, 0, 0, 1);

  TGfx.BeginDefaultPass(PassAction, FramebufferWidth, FramebufferHeight);
  sglDraw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TSglPointsApp.Init;
begin
  inherited;
  { Setup Neslib.Sokol.GL }
  var GLDesc := TGLDesc.Create;
  sglSetup(GLDesc);
end;

end.

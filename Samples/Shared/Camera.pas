unit Camera;
{ Quick'n'dirty Maya-style camera }

interface

uses
  Neslib.FastMath,
  Neslib.Sokol.App,
  Neslib.Sokol.Api;

const
  CAMERA_DEFAULT_MIN_DIST = 2.0;
  CAMERA_DEFAULT_MAX_DIST = 30.0;
  CAMERA_DEFAULT_MIN_LAT  = -85.0;
  CAMERA_DEFAULT_MAX_LAT  = 85.0;
  CAMERA_DEFAULT_DIST     = 5.0;
  CAMERA_DEFAULT_ASPECT   = 60.0;
  CAMERA_DEFAULT_NEARZ    = 0.01;
  CAMERA_DEFAULT_FARZ     = 100.0;

type
  TCameraDesc = record
  public
    MinDist: Single;
    MaxDist: Single;
    MinLat: Single;
    MaxLat: Single;
    Distance: Single;
    Latitude: Single;
    Longitude: Single;
    Aspect: Single;
    NearZ: Single;
    FarZ: Single;
    Center: TVector3;
  public
    class function Create: TCameraDesc; inline; static;
    procedure Init;
  end;
  PCameraDesc = ^TCameraDesc;

type
  TCamera = class
  {$REGION 'Internal Declarations'}
  private
    FStartTouchCount: Integer;
    FStartPinchDistance: Single;
    FStartDistance: Single;
    FPrevTouchPoints: array [0..1] of TTouchPoint;
  private
    function EventHandler(const AEvent: TEvent): Boolean;
    procedure HandleGesture(const AEvent: TEvent);
  private
    class function CalcPinchDistance(const AP1, AP2: TTouchPoint): Single; static;
  {$ENDREGION 'Internal Declarations'}
  public
    MinDist: Single;
    MaxDist: Single;
    MinLat: Single;
    MaxLat: Single;
    Distance: Single;
    Latitude: Single;
    Longitude: Single;
    Aspect: Single;
    NearZ: Single;
    FarZ: Single;
    Center: TVector3;
    EyePos: TVector3;
    View: TMatrix4;
    Proj: TMatrix4;
    ViewProj: TMatrix4;
  public
    constructor Create(const ADesc: TCameraDesc);
    destructor Destroy; override;

    { Feed mouse movement }
    procedure Orbit(const ADX, ADY: Single);

    { Feed zoom (mouse wheel) input }
    procedure Zoom(const AD: Single);

    { Update the View, Proj and ViewProj matrices }
    procedure Update(const AFramebufferWidth, AFramebufferHeight: Integer);
  end;
  PCamera = ^TCamera;

implementation

uses
  System.Math;

function Euclidian(const ALatitude, ALongitude: Single): TVector3;
begin
  var Lat: Single := Radians(ALatitude);
  var Long: Single := Radians(ALongitude);
  var CosLat, SinLat, SinLong, CosLong: Single;
  FastSinCos(Lat, SinLat, CosLat);
  FastSinCos(Long, SinLong, CosLong);
  Result.Init(CosLat * SinLong, SinLat, CosLat * CosLong);
end;

{ TCameraDesc }

class function TCameraDesc.Create: TCameraDesc;
begin
  Result.Init;
end;

procedure TCameraDesc.Init;
begin
  MinDist := CAMERA_DEFAULT_MIN_DIST;
  MaxDist := CAMERA_DEFAULT_MAX_DIST;
  MinLat := CAMERA_DEFAULT_MIN_LAT;
  MaxLat := CAMERA_DEFAULT_MAX_LAT;
  Distance := CAMERA_DEFAULT_DIST;
  Latitude := 0;
  Longitude := 0;
  Aspect := CAMERA_DEFAULT_ASPECT;
  NearZ := CAMERA_DEFAULT_NEARZ;
  FarZ := CAMERA_DEFAULT_FARZ;
  Center := TVector3.Zero;
end;

{ TCamera }

class function TCamera.CalcPinchDistance(const AP1,
  AP2: TTouchPoint): Single;
begin
  var DX: Single := AP1.X - AP2.X;
  var DY: Single := AP1.Y - AP2.Y;
  Result := Sqrt((DX * DX) + (DY * DY));
end;

constructor TCamera.Create(const ADesc: TCameraDesc);
begin
  inherited Create;
  TApplication.AddEventHandler(EventHandler);
  MinDist := ADesc.MinDist;
  MaxDist := ADesc.MaxDist;
  MinLat := ADesc.MinLat;
  MaxLat := ADesc.MaxLat;
  Distance := ADesc.Distance;
  Center := ADesc.Center;
  Latitude := ADesc.Latitude;
  Longitude := ADesc.Longitude;
  Aspect := ADesc.Aspect;
  NearZ := ADesc.NearZ;
  FarZ := ADesc.FarZ;
end;

destructor TCamera.Destroy;
begin
  TApplication.RemoveEventHandler(EventHandler);
  inherited;
end;

function TCamera.EventHandler(const AEvent: TEvent): Boolean;
begin
  case AEvent.Kind of
   TEventKind.MouseDown:
     if (AEvent.MouseButton = TMouseButton.Left) then
     begin
       TApplication.MouseLocked := True;
       Exit(True);
     end;

   TEventKind.MouseUp:
     if (AEvent.MouseButton = TMouseButton.Left) then
     begin
       TApplication.MouseLocked := False;
       Exit(True);
     end;

   TEventKind.MouseMove:
     if (TApplication.MouseLocked) then
     begin
       Orbit(AEvent.MouseDX * 0.25, AEvent.MouseDY * 0.25);
       Exit(True);
     end;

   TEventKind.MouseScroll:
     begin
       Zoom(AEvent.ScrollY * 0.5);
       Exit(True);
     end;

   TEventKind.TouchesBegan:
     begin
       FStartTouchCount := Min(AEvent.TouchCount, 2);
       FStartDistance := Distance;
       Move(AEvent.Touches[0]^, FPrevTouchPoints, FStartTouchCount * SizeOf(TTouchpoint));
       if (FStartTouchCount = 2) then
         FStartPinchDistance := CalcPinchDistance(AEvent.Touches[0]^, AEvent.Touches[1]^);
       Exit(True);
     end;

   TEventKind.TouchesMoved:
     begin
       HandleGesture(AEvent);
       Exit(True);
     end;
  end;
  Result := False;
end;

procedure TCamera.HandleGesture(const AEvent: TEvent);
begin
  var NumTouches := Min(AEvent.TouchCount, 2);
  if (NumTouches <> FStartTouchCount) then
    FStartTouchCount := NumTouches
  else
  begin
    if (NumTouches = 1) then
    begin
      { Drag }
      var DX: Single := AEvent.touches[0].X - FPrevTouchPoints[0].X;
      var DY: Single := AEvent.touches[0].Y - FPrevTouchPoints[0].Y;
      Orbit(DX * 0.25, DY * 0.25);
    end
    else
    begin
      { Pinch & Zoom }
      var NewPinchDistance := CalcPinchDistance(AEvent.Touches[0]^, AEvent.Touches[1]^);
      Distance := EnsureRange(FStartDistance + (0.02 * (FStartPinchDistance - NewPinchDistance)),
        MinDist, MaxDist);
    end;
  end;
  Move(AEvent.Touches[0]^, FPrevTouchPoints, NumTouches * SizeOf(TTouchpoint));
end;

procedure TCamera.Orbit(const ADX, ADY: Single);
begin
  Longitude := Longitude - ADX;
  if (Longitude < 0) then
    Longitude := Longitude + 360
  else if (Longitude > 360) then
    Longitude := Longitude - 360;

  Latitude := EnsureRange(Latitude + ADY, MinLat, MaxLat);
end;

procedure TCamera.Update(const AFramebufferWidth, AFramebufferHeight: Integer);
begin
  Assert((AFramebufferWidth > 0) and (AFramebufferHeight > 0));
  var W: Single := AFramebufferWidth;
  var H: Single := AFramebufferHeight;
  EyePos := Center + (Euclidian(Latitude, Longitude) * Distance);
  View.InitLookAtRH(EyePos, Center, TVector3.UnitY);
  Proj.InitPerspectiveFovRH(Radians(Aspect), H / W, NearZ, FarZ, True);
  ViewProj := Proj * View;
end;

procedure TCamera.Zoom(const AD: Single);
begin
  Distance := EnsureRange(Distance + AD, MinDist, MaxDist);
end;

end.

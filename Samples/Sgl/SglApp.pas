unit SglApp;
{ Rendering via Neslib.Sokol.GL }
interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.GL,
  SampleApp;

type
  TSglApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
    FImage: TImage;
    FPip3D: TGLPipeline;
    FAngleDeg: Single;
    FRot: array [0..1] of Single;
  private
    procedure DrawTriangle;
    procedure DrawQuad(const ATime: Single);
    procedure DrawCubes(const ATime: Single);
    procedure DrawTexCube(const ATime: Single);
    procedure Cube;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api;

{ TSglApp }

procedure TSglApp.Cleanup;
begin
  FPip3D.Free;
  sglShutdown;
  FImage.Free;
  inherited;
end;

procedure TSglApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 512;
  AConfig.Height := 512;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Neslib.Sokol.GL';
end;

procedure TSglApp.Cube;
{ Vertex specification for a cube with colored sides and texture coords }
begin
  sglBeginQuads;

  sglC3f(1, 0, 0);
    sglV3f_T2f(-1,  1, -1, -1,  1);
    sglV3f_T2f( 1,  1, -1,  1,  1);
    sglV3f_T2f( 1, -1, -1,  1, -1);
    sglV3f_T2f(-1, -1, -1, -1, -1);

  sglC3f(0, 1, 0);
    sglV3f_T2f(-1, -1,  1, -1,  1);
    sglV3f_T2f( 1, -1,  1,  1,  1);
    sglV3f_T2f( 1,  1,  1,  1, -1);
    sglV3f_T2f(-1,  1,  1, -1, -1);

  sglC3f(0, 0, 1);
    sglV3f_T2f(-1, -1,  1, -1,  1);
    sglV3f_T2f(-1,  1,  1,  1,  1);
    sglV3f_T2f(-1,  1, -1,  1, -1);
    sglV3f_T2f(-1, -1, -1, -1, -1);

  sglC3f(1, 0.5, 0);
    sglV3f_T2f( 1, -1,  1, -1,  1);
    sglV3f_T2f( 1, -1, -1,  1,  1);
    sglV3f_T2f( 1,  1, -1,  1, -1);
    sglV3f_T2f( 1,  1,  1, -1, -1);

  sglC3f(0, 0.5, 1);
    sglV3f_T2f( 1, -1, -1, -1,  1);
    sglV3f_T2f( 1, -1,  1,  1,  1);
    sglV3f_T2f(-1, -1,  1,  1, -1);
    sglV3f_T2f(-1, -1, -1, -1, -1);

  sglC3f(1, 0, 0.5);
    sglV3f_T2f(-1,  1, -1, -1,  1);
    sglV3f_T2f(-1,  1,  1,  1,  1);
    sglV3f_T2f( 1,  1,  1,  1, -1);
    sglV3f_T2f( 1,  1, -1, -1, -1);

  sglEnd;
end;

procedure TSglApp.DrawCubes(const ATime: Single);
begin
  FRot[0] := FRot[0] + (1.0 * ATime);
  FRot[1] := FRot[1] + (2.0 * ATime);

  sglDefaults;
  sglLoadPipeline(FPip3D);

  sglMatrixModeProjection;
  sglPerspective(sglRad(45), 1, 0.1, 100);

  sglMatrixModeModelview;
  sglTranslate(0, 0, -12);
  sglRotate(sglRad(FRot[0]), 1, 0, 0);
  sglRotate(sglRad(FRot[1]), 0, 1, 0);
  Cube;

  sglPushMatrix;
    sglTranslate(0, 0, 3);
    sglScale(0.5, 0.5, 0.5);
    sglRotate(-2 * sglRad(FRot[0]), 1, 0, 0);
    sglRotate(-2 * sglRad(FRot[1]), 0, 1, 0);
    Cube;

    sglPushMatrix;
      sglTranslate(0, 0, 3);
      sglScale(0.5, 0.5, 0.5);
      sglRotate(-3 * sglRad(2 * FRot[0]), 1, 0, 0);
      sglRotate( 3 * sglRad(2 * FRot[1]), 0, 0, 1);
      Cube;
    sglPopMatrix;

  sglPopMatrix;
end;

procedure TSglApp.DrawQuad(const ATime: Single);
var
  Scale: Single;
begin
  Scale := 1.0 + (Sin(sglRad(FAngleDeg)) * 0.5);
  FAngleDeg := FAngleDeg + (1 * ATime);
  sglDefaults;
  sglRotate(sglRad(FAngleDeg), 0, 0, 1);
  sglScale(Scale, Scale, 1);
  sglBeginQuads;
  sglV2f_C3b(-0.5, -0.5, 255, 255,   0);
  sglV2f_C3b( 0.5, -0.5,   0, 255,   0);
  sglV2f_C3b( 0.5,  0.5,   0,   0, 255);
  sglV2f_C3b(-0.5,  0.5, 255,   0,   0);
  sglEnd;
end;

procedure TSglApp.DrawTexCube(const ATime: Single);
begin
  var A := sglRad(FrameCount * ATime);

  { Texture matrix rotation and scale }
  var TexRot: Single := 0.5 * A;
  var TexScale: Single := 1.0 - Sin(A) * 0.5;

  { Compute an orbiting eye-position for testing sglLookat }
  var EyeX: Single := Sin(A) * 6.0;
  var EyeZ: Single := Cos(A) * 6.0;
  var EyeY: Single := Sin(A) * 3.0;

  sglDefaults;
  sglLoadPipeline(FPip3D);

  sglEnableTexture;
  sglTexture(FImage);

  sglMatrixModeProjection;
  sglPerspective(sglRad(45), 1, 0.1, 100);

  sglMatrixModeModelview;
  sglLookat(EyeX, EyeY, EyeZ, 0, 0, 0, 0, 1, 0);

  sglMatrixModeTexture;
  sglRotate(TexRot, 0, 0, 1);
  sglScale(TexScale, TexScale, 1);

  Cube;
end;

procedure TSglApp.DrawTriangle;
begin
  sglDefaults;
  sglBeginTriangles;
  sglV2f_C3b( 0,    0.5, 255,   0,   0);
  sglV2f_C3b(-0.5, -0.5,   0,   0, 255);
  sglV2f_C3b( 0.5, -0.5,   0, 255,   0);
  sglEnd;
end;

procedure TSglApp.Frame;
begin
  { Frame time multiplier (normalized for 60fps) }
  var T: Single := FrameDuration * 60;

  { Compute viewport rectangles so that the views are horizontally
    centered and keep a 1:1 aspect ratio }
  var DW := FramebufferWidth;
  var DH := FramebufferHeight;
  var WW := DH shr 1; // Not a bug
  var HH := DH shr 1;
  var X0 := (DW shr 1) - HH;
  var X1 := DW shr 1;
  var Y0 := 0;
  var Y1 := DH shr 1;

  { All Neslib.Sokol.GL functions except sglDraw can be called anywhere in
    the frame. }
  sglViewport(X0, Y0, WW, HH, True);
  DrawTriangle;

  sglViewport(X1, Y0, WW, HH, True);
  DrawQuad(T);

  sglViewport(X0, Y1, WW, HH, True);
  DrawCubes(T);

  sglViewport(X1, Y1, WW, HH, True);
  DrawTexCube(T);

  sglViewport(0, 0, DW, DH, True);

  { Render the Sokol.Gfx default pass. All Neslib.Sokol.GL commands that
    happened so far are rendered inside sglDraw, and this is the only
    Neslib.Sokol.GL function that must be called inside a begin/end pass pair.
    sglDraw also 'rewinds' Neslib.Sokol.GL for the next frame. }

  TGfx.BeginDefaultPass(FPassAction, DW, DH);
  sglDraw;

  DebugFrame;

  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TSglApp.Init;
var
  Pixels: array [0..7, 0..7] of UInt32;
begin
  inherited;
  { Setup Neslib.Sokol.GL }
  var GLDesc := TGLDesc.Create;
  sglSetup(GLDesc);

  { Checkerboard texture }
  for var Y := 0 to 7 do
    for var X := 0 to 7 do
    begin
      if (((Y xor X) and 1) <> 0) then
        Pixels[Y,X] := $FFFFFFFF
      else
        Pixels[Y,X] := $FF000000;
    end;

  var ImageDesc := TImageDesc.Create;
  ImageDesc.Width := 8;
  ImageDesc.Height := 8;
  ImageDesc.Data.SubImages[0] := TRange.Create(Pixels);
  FImage := TImage.Create(ImageDesc);

  { Create a pipeline object for 3d rendering, with less-equal depth-test and
    cull-face enabled. Note that we don't provide a shader, vertex-layout, pixel
    formats and sample count here, these are all filled in by Neslib.Sokol.GL }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  FPip3D := TGLPipeline.Create(PipDesc);

  { Default pass action }
  FPassAction.Init;
  FPassAction.Colors[0].Init(TAction.Clear, 0, 0, 0, 1);
end;

end.

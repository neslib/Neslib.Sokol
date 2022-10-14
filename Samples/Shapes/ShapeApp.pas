unit ShapeApp;

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Shape,
  Neslib.Sokol.DebugText,
  Neslib.FastMath,
  SampleApp,
  ShapesShader;

type
  TShape = record
  public
    Pos: TVector3;
    Draw: TShapeElementRange;
  public
    procedure Init(const AX, AY, AZ: Single; const ABuf: TShapeBuffer);
  end;

type
  TShapeType = (Box, Plane, Sphere, Cylinder, Torus);

type
  TShapeApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
    FShader: TShader;
    FPip: TPipeline;
    FVBuf: TBuffer;
    FIBuf: TBuffer;
    FShapes: array [TShapeType] of TShape;
    FVSParams: TVSParams;
    FRX: Single;
    FRY: Single;
  private
    procedure NextDrawMode;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure MouseDown(const AButton: TMouseButton; const AX, AY: Single;
      const AModifiers: TModifiers); override;
    procedure TouchesBegan(const ATouches: TTouches); override;
  end;

implementation

uses
  Neslib.Sokol.Api;

{ TShapeApp }

procedure TShapeApp.Cleanup;
begin
  FPip.Free;
  FShader.Free;
  FVBuf.Free;
  FIBuf.Free;
  inherited;
end;

procedure TShapeApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'Shapes';
end;

procedure TShapeApp.Frame;
begin
  { Help text }
  TDbgText.Canvas(FramebufferWidth * 0.5, FramebufferHeight * 0.5);
  TDbgText.Pos(1, 2);
  {$IF Defined(IOS) or Defined(ANDROID)}
  TDbgText.WriteAnsiLn('Tap the screen to switch draw mode');
  {$ELSE}
  TDbgText.WriteAnsiLn('Click the window to switch draw mode');
  {$ENDIF}
  TDbgText.WriteAnsi(' Current draw mode: ');
  if (FVSParams.DrawMode = 0) then
    TDbgText.WriteAnsi('vertex normals')
  else if (FVSParams.DrawMode = 1) then
    TDbgText.WriteAnsi('texture coords')
  else
    TDbgText.WriteAnsi('vertex color');

  { View-projection matrix... }
  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), FramebufferHeight / FramebufferWidth,
    0.01, 10.0, True);
  View.InitLookAtRH(Vector3(0, 1.5, 6), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  { Model-rotation matrix }
  var T: Single := FrameDuration * 60;
  FRX := FRX + (1 * T);
  FRY := FRY + (2 * T);
  var RXM, RYM: TMatrix4;
  RXM.InitRotationX(Radians(FRX));
  RYM.InitRotationY(Radians(FRY));
  var RM := RXM * RYM;

  { Render shapes...}
  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  TGfx.ApplyPipeline(FPip);
  var Bind := TBindings.Create;
  Bind.VertexBuffers[0] := FVBuf;
  Bind.IndexBuffer := FIBuf;
  TGfx.ApplyBindings(Bind);

  for var I := Low(TShapeType) to High(TShapeType) do
  begin
    { Per shape model-view-projection matrix }
    var Translate: TMatrix4;
    Translate.InitTranslation(FShapes[I].Pos);
    var Model := Translate * RM;
    FVSParams.Mvp := ViewProj * Model;
    TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_PARAMS,
      TRange.Create(FVSParams));
    TGfx.Draw(FShapes[I].Draw.BaseElement, FShapes[I].Draw.NumElements);
  end;

  TDbgText.Draw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TShapeApp.Init;
var
  Vertices: array [0..(6 * 1024) - 1] of TShapeVertex;
  Indices: array [0..(16 * 1024) - 1] of UInt16;
begin
  inherited;
  var DbgTextDesc := TDbgTextDesc.Create;
  DbgTextDesc.Fonts[0] := TDbgTextFont.Oric;
  TDbgText.Setup(DbgTextDesc);

  { Clear to black }
  FPassAction.Colors[0].Init(TAction.Clear, 0, 0, 0, 1);

  { Shader and pipeline object }
  FShader := TShader.Create(ShapesShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := FShader;
  PipDesc.Layout.Buffers[0] := TShapeBuffer.BufferLayoutDesc;
  PipDesc.Layout.Attrs[ATTR_VS_POSITION] := TShapeBuffer.PositionAttrDesc;
  PipDesc.Layout.Attrs[ATTR_VS_NORMAL] := TShapeBuffer.NormalAttrDesc;
  PipDesc.Layout.Attrs[ATTR_VS_TEXCOORD] := TShapeBuffer.TexCoordAttrDesc;
  PipDesc.Layout.Attrs[ATTR_VS_COLOR0] := TShapeBuffer.ColorAttrDesc;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.None;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  FPip := TPipeline.Create(PipDesc);

  { Generate shape geometries }
  var Buf := TShapeBuffer.Create(TRange.Create(Vertices), TRange.Create(Indices));

  var Box := TShapeBox.Create(1, 1, 1, 10);
  Box.RandomColors := True;
  Buf := Buf.Build(Box);
  FShapes[TShapeType.Box].Init(-1, 1, 0, Buf);

  var Plane := TShapePlane.Create(1, 1, 10);
  Plane.RandomColors := True;
  Buf := Buf.Build(Plane);
  FShapes[TShapeType.Plane].Init(1, 1, 0, Buf);

  var Sphere := TShapeSphere.Create(0.75, 36, 20);
  Sphere.RandomColors := True;
  Buf := Buf.Build(Sphere);
  FShapes[TShapeType.Sphere].Init(-2, -1, 0, Buf);

  var Cylinder := TShapeCylinder.Create(0.5, 1.5, 36, 10);
  Cylinder.RandomColors := True;
  Buf := Buf.Build(Cylinder);
  FShapes[TShapeType.Cylinder].Init(2, -1, 0, Buf);

  var Torus := TShapeTorus.Create(0.5, 0.3, 18, 36);
  Torus.RandomColors := True;
  Buf := Buf.Build(Torus);
  FShapes[TShapeType.Torus].Init(0, -1, 0, Buf);

  Assert(Buf.Valid);

  { One vertex/index-buffer-pair for all shapes }
  FVBuf := TBuffer.Create(Buf.VertexBufferDesc);
  FIBuf := TBuffer.Create(Buf.IndexBufferDesc);
end;

procedure TShapeApp.MouseDown(const AButton: TMouseButton; const AX, AY: Single;
  const AModifiers: TModifiers);
begin
  inherited;
  NextDrawMode;
end;

procedure TShapeApp.NextDrawMode;
begin
  var CurDrawMode := Trunc(FVSParams.DrawMode);
  FVSParams.DrawMode := (CurDrawMode + 1) mod 3;
end;

procedure TShapeApp.TouchesBegan(const ATouches: TTouches);
begin
  inherited;
  NextDrawMode;
end;

{ TShape }

procedure TShape.Init(const AX, AY, AZ: Single; const ABuf: TShapeBuffer);
begin
  Pos.Init(AX, AY, AZ);
  Draw := ABuf.ElementRange;
end;

end.

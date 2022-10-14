unit ShapesTransformApp;
{ Demonstrates merging multiple transformed shapes into a single draw-shape
  with Neslib.Sokol.Shape }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Shape,
  Neslib.Sokol.DebugText,
  Neslib.FastMath,
  SampleApp,
  ShapesTransformShader;

type
  TShapesTransformApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
    FShader: TShader;
    FPip: TPipeline;
    FBind: TBindings;
    FElems: TShapeElementRange;
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

{ TShapesTransformApp }

procedure TShapesTransformApp.Cleanup;
begin
  FPip.Free;
  FShader.Free;
  FBind.VertexBuffers[0].Free;
  FBind.IndexBuffer.Free;
  inherited;
end;

procedure TShapesTransformApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'Shapes Transform';
end;

procedure TShapesTransformApp.Frame;
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

  { Build model-view-projection matrix }
  var T: Single := FrameDuration * 60;
  FRX := FRX + (1 * T);
  FRY := FRY + (2 * T);

  var Proj, View, RXM, RYM: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), FramebufferHeight / FramebufferWidth,
    0.01, 10.0, True);
  View.InitLookAtRH(Vector3(0, 1.5, 6), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;
  RXM.InitRotationX(Radians(FRX));
  RYM.InitRotationY(Radians(FRY));
  var Model := RXM * RYM;
  FVSParams.Mvp := ViewProj * Model;

  { Render the single shape }
  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyBindings(FBind);
  TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_PARAMS,
    TRange.Create(FVSParams));
  TGfx.Draw(FElems.BaseElement, FElems.NumElements);

  TDbgText.Draw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TShapesTransformApp.Init;
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

  { Generate merged shape geometries }
  var Buf := TShapeBuffer.Create(TRange.Create(Vertices), TRange.Create(Indices));

  { Build the shapes... }
  var Box := TShapeBox.Create(1, 1, 1, 10);
  Box.RandomColors := True;
  Box.Transform.InitTranslation(-1, 0, 1);
  Buf := Buf.Build(Box);

  var Sphere := TShapeSphere.Create(0.75, 36, 20);
  Sphere.RandomColors := True;
  Sphere.Transform.InitTranslation(1, 0, 1);
  Sphere.Merge := True;
  Buf := Buf.Build(Sphere);

  var Cylinder := TShapeCylinder.Create(0.5, 1.5, 36, 10);
  Cylinder.RandomColors := True;
  Cylinder.Transform.InitTranslation(-1, 0, -1);
  Cylinder.Merge := True;
  Buf := Buf.Build(Cylinder);

  var Torus := TShapeTorus.Create(0.5, 0.3, 18, 36);
  Torus.RandomColors := True;
  Torus.Transform.InitTranslation(1, 0, -1);
  Torus.Merge := True;
  Buf := Buf.Build(Torus);

  Assert(Buf.Valid);

  { Extract element range for TGfx.Draw }
  FElems := Buf.ElementRange;

  { And finally create the vertex- and index-buffer }
  FBind.VertexBuffers[0] := TBuffer.Create(Buf.VertexBufferDesc);
  FBind.IndexBuffer := TBuffer.Create(Buf.IndexBufferDesc);
end;

procedure TShapesTransformApp.MouseDown(const AButton: TMouseButton; const AX, AY: Single;
  const AModifiers: TModifiers);
begin
  inherited;
  NextDrawMode;
end;

procedure TShapesTransformApp.NextDrawMode;
begin
  var CurDrawMode := Trunc(FVSParams.DrawMode);
  FVSParams.DrawMode := (CurDrawMode + 1) mod 3;
end;

procedure TShapesTransformApp.TouchesBegan(const ATouches: TTouches);
begin
  inherited;
  NextDrawMode;
end;

end.

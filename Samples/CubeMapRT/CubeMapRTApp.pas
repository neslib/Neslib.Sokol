unit CubeMapRTApp;
{ Cubemap as render target. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  CubeMapRTShader;

type
  { State record for the little cubes rotating around the big cube }
  TShape = record
  public
    Model: TMatrix4;
    Color: TVector4;
    Axis: TVector3;
    Radius: Single;
    Angle: Single;
    AngularVelocity: Single;
  end;
  PShape = ^TShape;

type
  { Vertex (normals for simple point lighting) }
  TVertex = record
  public
    Pos: TVector3;
    Norm: TVector3;
  end;

type
  { A mesh consists of a vertex- and index-buffer }
  TMesh = record
  public
    VBuf: TBuffer;
    IBuf: TBuffer;
    NumElements: Integer;
  public
    procedure MakeCube;
    procedure Free;
  end;

type
  TCubeMapRTApp = class(TSampleApp)
  private const
    { Change the OFFSCREEN_SAMPLE_COUNT between 1 and 4 to test the different
      cubemap-rendering-paths in sokol (one rendering to a separate MSAA
      surface, and MSAA-resolve in TGfx.EndPass, and the other (without MSAA)
      rendering directly to the cubemap faces. }
    OFFSCREEN_SAMPLE_COUNT = 4;
    DISPLAY_SAMPLE_COUNT   = 4;
    NUM_SHAPES             = 32;
  private
    FCubeMap: TImage;
    FDepthImg: TImage;
    FOffscreenPass: array [TCubeFace] of TPass;
    FOffscreenPassAction: TPassAction;
    FDisplayPassAction: TPassAction;
    FShapesShader: TShader;
    FCubeShader: TShader;
    FCube: TMesh;
    FOffscreenShapesPip: TPipeline;
    FDisplayShapesPip: TPipeline;
    FDisplayCubePip: TPipeline;
    FOffscreenProj: TMatrix4;
    FLightDir: TVector4;
    FRX: Single;
    FRY: Single;
    FShapes: array [0..NUM_SHAPES - 1] of TShape;
  private
    procedure DrawCubes(const APip: TPipeline; const AEyePos: TVector3;
      const AViewProj: TMatrix4);
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api;

{ Offscreen pass which renders the environment cubemap.
  FIXME: these values work for Metal and D3D11, not for GL, because of the
  different handedness of the cubemap coordinate systems }
type
  TCenterAndUp = array [TCubeFace, 0..1] of TVector3;
  PCenterAndUp = ^TCenterAndUp;

const
  CENTER_AND_UP_D3D11_METAL: TCenterAndUp = (
    ((X: +1; Y:  0; Z:  0), (X:  0; Y: -1; Z:  0)),
    ((X: -1; Y:  0; Z:  0), (X:  0; Y: -1; Z:  0)),
    ((X:  0; Y: -1; Z:  0), (X:  0; Y:  0; Z: -1)),
    ((X:  0; Y: +1; Z:  0), (X:  0; Y:  0; Z: +1)),
    ((X:  0; Y:  0; Z: +1), (X:  0; Y: -1; Z:  0)),
    ((X:  0; Y:  0; Z: -1), (X:  0; Y: -1; Z:  0)));

const
  CENTER_AND_UP_GL: TCenterAndUp = (
    ((X: +1; Y:  0; Z:  0), (X:  0; Y: -1; Z:  0)),
    ((X: -1; Y:  0; Z:  0), (X:  0; Y: -1; Z:  0)),
    ((X:  0; Y: +1; Z:  0), (X:  0; Y:  0; Z: +1)),
    ((X:  0; Y: -1; Z:  0), (X:  0; Y:  0; Z: -1)),
    ((X:  0; Y:  0; Z: +1), (X:  0; Y: -1; Z:  0)),
    ((X:  0; Y:  0; Z: -1), (X:  0; Y: -1; Z:  0)));

{ TCubeMapRTApp }

procedure TCubeMapRTApp.Cleanup;
begin
  for var Face := Low(TCubeFace) to High(TCubeFace) do
    FOffscreenPass[Face].Free;

  FDisplayCubePip.Free;
  FDisplayShapesPip.Free;
  FOffscreenShapesPip.Free;
  FCubeShader.Free;
  FShapesShader.Free;
  FCube.Free;
  FDepthImg.Free;
  FCubeMap.Free;
  inherited;
end;

procedure TCubeMapRTApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := DISPLAY_SAMPLE_COUNT;
  AConfig.WindowTitle := 'Cube Render Target';
end;

procedure TCubeMapRTApp.DrawCubes(const APip: TPipeline;
  const AEyePos: TVector3; const AViewProj: TMatrix4);
begin
  TGfx.ApplyPipeline(APip);

  var Bind := TBindings.Create;
  Bind.VertexBuffers[0] := FCube.VBuf;
  Bind.IndexBuffer := FCube.IBuf;
  TGfx.ApplyBindings(Bind);

  for var I := 0 to NUM_SHAPES - 1 do
  begin
    var Shape := PShape(@FShapes[I]);
    var Uniforms: TShapeUniforms;
    Uniforms.MVP := AViewProj * Shape.Model;
    Uniforms.Model := Shape.Model;
    Uniforms.ShapeColor := Shape.Color;
    Uniforms.LightDir := FLightDir;
    Uniforms.EyePos.Init(AEyePos, 1);

    TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_SHAPE_UNIFORMS,
      TRange.Create(Uniforms));
    TGfx.Draw(0, FCube.NumElements);
  end;
end;

procedure TCubeMapRTApp.Frame;
begin
  { Compute a frame time multiplier }
  var T: Single := FrameDuration;

  { Update the little cubes that are reflected in the big cube }
  var Scale, Rot, Trans: TMatrix4;
  for var I := 0 to NUM_SHAPES - 1 do
  begin
    FShapes[I].Angle := FShapes[I].Angle + (FShapes[I].AngularVelocity * T);
    Scale.InitScaling(0.25);
    Rot.InitRotation(FShapes[I].Axis, Radians(FShapes[I].Angle));
    Trans.InitTranslation(0, 0, FShapes[I].Radius);
    FShapes[I].Model := Rot * (Trans * Scale);
  end;

  var CenterAndUp: PCenterAndUp;
  if (TGfx.Backend in [TBackend.D3D11, TBackend.MetalIOS, TBackend.MetalMacOS]) then
    CenterAndUp := @CENTER_AND_UP_D3D11_METAL
  else
    CenterAndUp := @CENTER_AND_UP_GL;

  var View: TMatrix4;
  for var Face := Low(TCubeFace) to High(TCubeFace) do
  begin
    TGfx.BeginPass(FOffscreenPass[Face], FOffscreenPassAction);

    View.InitLookAtRH(TVector3.Zero, CenterAndUp[Face, 0], CenterAndUp[Face, 1]);
    var ViewProj := FOffscreenProj * View;
    DrawCubes(FOffscreenShapesPip, TVector3.Zero, ViewProj);

    TGfx.EndPass;
  end;

  { Render the default pass }
  var W := FramebufferWidth;
  var H := FramebufferHeight;
  TGfx.BeginDefaultPass(FDisplayPassAction, W, H);

  var EyePos: TVector3;
  var Proj: TMatrix4;
  EyePos.Init(0, 0, 30);
  Proj.InitPerspectiveFovRH(Radians(45), H / W, 0.01, 100.0, True);
  View.InitLookAtRH(EyePos, Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  { Render the orbiting cubes }
  DrawCubes(FDisplayShapesPip, EyePos, ViewProj);

  { Render a big cube in the middle with environment mapping }
  FRX := FRX + (0.1 * 60 * T);
  FRY := FRY + (0.2 * 60 * T);

  var RXM, RYM: TMatrix4;
  RXM.InitRotationX(Radians(FRX));
  RYM.InitRotationY(Radians(FRY));
  Scale.InitScaling(2);
  var Model := (RXM * RYM) * Scale;

  TGfx.ApplyPipeline(FDisplayCubePip);

  var Bind := TBindings.Create;
  Bind.VertexBuffers[0] := FCube.VBuf;
  Bind.IndexBuffer := FCube.IBuf;
  Bind.FragmentShaderImages[SLOT_TEX] := FCubeMap;
  TGfx.ApplyBindings(Bind);

  var Uniforms: TShapeUniforms;
  Uniforms.MVP := ViewProj * Model;
  Uniforms.Model := Model;
  Uniforms.ShapeColor.Init(1, 1, 1, 1);
  Uniforms.LightDir := FLightDir;
  Uniforms.EyePos := Vector4(EyePos, 1);
  TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_SHAPE_UNIFORMS,
    TRange.Create(Uniforms));

  TGfx.Draw(0, FCube.NumElements);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TCubeMapRTApp.Init;
begin
  inherited;

  { Create a cubemap as render target, and a matching depth-buffer texture }
  var ImageDesc := TImageDesc.Create;
  ImageDesc.ImageType := TImageType.Cube;
  ImageDesc.RenderTarget := True;
  ImageDesc.Width := 1024;
  ImageDesc.Height := 1024;
  ImageDesc.SampleCount := OFFSCREEN_SAMPLE_COUNT;
  ImageDesc.MinFilter := TFilter.Linear;
  ImageDesc.MagFilter := TFilter.Linear;
  ImageDesc.TraceLabel := 'CubemapColorRT';
  FCubeMap := TImage.Create(ImageDesc);

  { ... and a matching depth-buffer image }
  ImageDesc.Init;
  ImageDesc.ImageType := TImageType.TwoD;
  ImageDesc.RenderTarget := True;
  ImageDesc.Width := 1024;
  ImageDesc.Height := 1024;
  ImageDesc.PixelFormat := TPixelFormat.Depth;
  ImageDesc.SampleCount := OFFSCREEN_SAMPLE_COUNT;
  ImageDesc.TraceLabel := 'CubemapDepthRT';
  FDepthImg := TImage.Create(ImageDesc);

  { Create 6 pass objects, one for each cubemap face }
  for var Face := Low(TCubeFace) to High(TCubeFace) do
  begin
    var PassDesc := TPassDesc.Create;
    PassDesc.ColorAttachments[0].Image := FCubeMap;
    PassDesc.ColorAttachments[0].Slice := Ord(Face);
    PassDesc.DepthStencilAttachment.Image := FDepthImg;
    PassDesc.TraceLabel := 'OffscreenPass';
    FOffscreenPass[Face] := TPass.Create(PassDesc);
  end;

  { Pass action for offscreen pass (clear to dark grey) }
  FOffscreenPassAction.Colors[0].Init(TAction.Clear, 0.5, 0.5, 0.5, 1.0);

  { Pass action for default pass (clear to light grey) }
  FDisplayPassAction.Colors[0].Init(TAction.Clear, 0.75, 0.75, 0.75, 1.0);

  { Vertex- and index-buffers for cube }
  FCube.MakeCube;

  { Same vertex layout for all shaders }
  var Layout := TLayoutDesc.Create;
  Layout.Attrs[ATTR_VS_POS].Offset := 0;
  Layout.Attrs[ATTR_VS_POS].Format := TVertexFormat.Float3;
  Layout.Attrs[ATTR_VS_NORM].Offset := SizeOf(TVector3);
  Layout.Attrs[ATTR_VS_NORM].Format := TVertexFormat.Float3;

  { Shader and pipeline objects for offscreen-rendering }
  FShapesShader := TShader.Create(ShapesShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := FShapesShader;
  PipDesc.Layout := Layout;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.SampleCount := OFFSCREEN_SAMPLE_COUNT;
  PipDesc.Depth.PixelFormat := TPixelFormat.Depth;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.TraceLabel := 'OffscreenShapesPipeline';
  FOffscreenShapesPip := TPipeline.Create(PipDesc);

  PipDesc.SampleCount := DISPLAY_SAMPLE_COUNT;
  PipDesc.Depth.PixelFormat := TPixelFormat.Default;
  PipDesc.TraceLabel := 'DisplayShapesPipeline';
  FDisplayShapesPip := TPipeline.Create(PipDesc);

  { Shader and pipeline objects for display-rendering }
  FCubeShader := TShader.Create(CubeShaderDesc);

  PipDesc.Init;
  PipDesc.Shader := FCubeShader;
  PipDesc.Layout := Layout;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.SampleCount := DISPLAY_SAMPLE_COUNT;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  FDisplayCubePip := TPipeline.Create(PipDesc);

  { 1:1 aspect ration projection matrix for offscreen rendering }
  FOffscreenProj.InitPerspectiveFovRH(Radians(90), 1.0, 0.01, 100.0);
  FLightDir.Init(Vector3(-0.75, 1.0, 0.0).Normalize, 0.0);

  { Setup initial state for the orbiting cubes }
  for var I := 0 to NUM_SHAPES - 1 do
  begin
    FShapes[I].Color.Init(Random(), Random(), Random(), 1.0);
    FShapes[I].Axis := Vector3((Random() * 2) - 1, (Random() * 2) - 1, (Random() * 2) - 1).Normalize;
    FShapes[I].Radius := (Random() * 5) + 5;
    FShapes[I].Angle := Random() * 360;
    FShapes[I].AngularVelocity := (Random() * 35) + 15;
    if (Random(2) = 0) then
      FShapes[I].AngularVelocity := -FShapes[I].AngularVelocity;
  end;
end;

{ TMesh }

const
  VERTICES: array [0..23] of TVertex = (
    (Pos: (X: -1.0; Y: -1.0; Z: -1.0); Norm: (X:  0.0; Y:  0.0; Z: -1.0)),
    (Pos: (X:  1.0; Y: -1.0; Z: -1.0); Norm: (X:  0.0; Y:  0.0; Z: -1.0)),
    (Pos: (X:  1.0; Y:  1.0; Z: -1.0); Norm: (X:  0.0; Y:  0.0; Z: -1.0)),
    (Pos: (X: -1.0; Y:  1.0; Z: -1.0); Norm: (X:  0.0; Y:  0.0; Z: -1.0)),

    (Pos: (X: -1.0; Y: -1.0; Z:  1.0); Norm: (X:  0.0; Y:  0.0; Z:  1.0)),
    (Pos: (X:  1.0; Y: -1.0; Z:  1.0); Norm: (X:  0.0; Y:  0.0; Z:  1.0)),
    (Pos: (X:  1.0; Y:  1.0; Z:  1.0); Norm: (X:  0.0; Y:  0.0; Z:  1.0)),
    (Pos: (X: -1.0; Y:  1.0; Z:  1.0); Norm: (X:  0.0; Y:  0.0; Z:  1.0)),

    (Pos: (X: -1.0; Y: -1.0; Z: -1.0); Norm: (X: -1.0; Y:  0.0; Z:  0.0)),
    (Pos: (X: -1.0; Y:  1.0; Z: -1.0); Norm: (X: -1.0; Y:  0.0; Z:  0.0)),
    (Pos: (X: -1.0; Y:  1.0; Z:  1.0); Norm: (X: -1.0; Y:  0.0; Z:  0.0)),
    (Pos: (X: -1.0; Y: -1.0; Z:  1.0); Norm: (X: -1.0; Y:  0.0; Z:  0.0)),

    (Pos: (X: 1.0;  Y: -1.0; Z: -1.0); Norm: (X:  1.0; Y:  0.0; Z:  0.0)),
    (Pos: (X: 1.0;  Y:  1.0; Z: -1.0); Norm: (X:  1.0; Y:  0.0; Z:  0.0)),
    (Pos: (X: 1.0;  Y:  1.0; Z:  1.0); Norm: (X:  1.0; Y:  0.0; Z:  0.0)),
    (Pos: (X: 1.0;  Y: -1.0; Z:  1.0); Norm: (X:  1.0; Y:  0.0; Z:  0.0)),

    (Pos: (X: -1.0; Y: -1.0; Z: -1.0); Norm: (X:  0.0; Y: -1.0; Z:  0.0)),
    (Pos: (X: -1.0; Y: -1.0; Z:  1.0); Norm: (X:  0.0; Y: -1.0; Z:  0.0)),
    (Pos: (X:  1.0; Y: -1.0; Z:  1.0); Norm: (X:  0.0; Y: -1.0; Z:  0.0)),
    (Pos: (X:  1.0; Y: -1.0; Z: -1.0); Norm: (X:  0.0; Y: -1.0; Z:  0.0)),

    (Pos: (X: -1.0; Y:  1.0; Z: -1.0); Norm: (X:  0.0; Y:  1.0; Z:  0.0)),
    (Pos: (X: -1.0; Y:  1.0; Z:  1.0); Norm: (X:  0.0; Y:  1.0; Z:  0.0)),
    (Pos: (X:  1.0; Y:  1.0; Z:  1.0); Norm: (X:  0.0; Y:  1.0; Z:  0.0)),
    (Pos: (X:  1.0; Y:  1.0; Z: -1.0); Norm: (X:  0.0; Y:  1.0; Z:  0.0)));

const
  INDICES: array [0..35] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20);

procedure TMesh.Free;
begin
  VBuf.Free;
  IBuf.Free;
end;

procedure TMesh.MakeCube;
begin
  var Desc := TBufferDesc.Create;
  Desc.Data := TRange.Create(VERTICES);
  Desc.TraceLabel := 'CubeVertices';
  VBuf := TBuffer.Create(Desc);

  Desc.Init;
  Desc.BufferType := TBufferType.IndexBuffer;
  Desc.Data := TRange.Create(INDICES);
  Desc.TraceLabel := 'CubeIndices';
  IBuf := TBuffer.Create(Desc);

  NumElements := Length(INDICES);
end;

end.

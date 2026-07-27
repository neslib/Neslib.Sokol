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
    { NOTE: cubemaps can't be multisampled, so (OFFSCREEN_SAMPLE_COUNT > 1) will
      be a validation error }
    OFFSCREEN_SAMPLE_COUNT = 1;
    DISPLAY_SAMPLE_COUNT   = 4;
    NUM_SHAPES             = 32;
    NUM_FACES              = 6;
  private
    FCubeMap: TImage;
    FCubeMapTexView: TView;
    FSampler: TSampler;
    FOffscreenColorViews: array [0..NUM_FACES - 1] of TView;
    FOffscreenDepthView: TView;
    FOffscreenPassAction: TPassAction;
    FDisplayPassAction: TPassAction;
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
  System.SysUtils,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue;

{ Offscreen pass which renders the environment cubemap.
  FIXME: these values work for Metal and D3D11, not for GL, because of the
  different handedness of the cubemap coordinate systems }
type
  TCenterAndUp = array [0..TCubeMapRTApp.NUM_FACES - 1, 0..1] of TVector3;
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
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
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

    TGfx.ApplyUniforms(UB_SHAPE_UNIFORMS, TRange.Create(Uniforms));
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
  for var Face := 0 to NUM_FACES - 1 do
  begin
    var Pass := TPass.Create;
    Pass.Action^ := FOffscreenPassAction;
    Pass.Attachments.Colors[0] := FOffscreenColorViews[Face];
    Pass.Attachments.DepthStencil := FOffscreenDepthView;
    TGfx.BeginPass(Pass);

    View.InitLookAtRH(TVector3.Zero, CenterAndUp[Face, 0], CenterAndUp[Face, 1]);
    var ViewProj := FOffscreenProj * View;
    DrawCubes(FOffscreenShapesPip, TVector3.Zero, ViewProj);

    TGfx.EndPass;
  end;

  { Render the default pass }
  var W := FramebufferWidth;
  var H := FramebufferHeight;
  var Pass := TPass.Create;
  Pass.Action^ := FDisplayPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  var EyePos: TVector3;
  var Proj: TMatrix4;
  EyePos.Init(0, 0, 20);
  Proj.InitPerspectiveFovRH(Radians(45), W / H, 0.01, 100.0);
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
  Bind.Views[VIEW_TEX] := FCubeMapTexView;
  Bind.Samplers[SMP_SMP] := FSampler;
  TGfx.ApplyBindings(Bind);

  var Uniforms: TShapeUniforms;
  Uniforms.MVP := ViewProj * Model;
  Uniforms.Model := Model;
  Uniforms.ShapeColor.Init(1, 1, 1, 1);
  Uniforms.LightDir := FLightDir;
  Uniforms.EyePos := Vector4(EyePos, 1);
  TGfx.ApplyUniforms(UB_SHAPE_UNIFORMS, TRange.Create(Uniforms));

  TGfx.Draw(0, FCube.NumElements);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TCubeMapRTApp.Init;
begin
  inherited;

  { Create a cubemap as render target, a texture view, and a matching
    depth-buffer texture }
  var ImageDesc := TImageDesc.Create;
  ImageDesc.ImageType := TImageType.Cube;
  ImageDesc.Usage.ColorAttachment := True;
  ImageDesc.Width := 1024;
  ImageDesc.Height := 1024;
  ImageDesc.SampleCount := OFFSCREEN_SAMPLE_COUNT;
  ImageDesc.TraceLabel := 'CubemapColorRT';
  FCubeMap := TImage.Create(ImageDesc);

  var ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := FCubeMap;
  ViewDesc.TraceLabel := 'CubemapTexview';
  FCubeMapTexView := TView.Create(ViewDesc);

  ImageDesc.Init;
  ImageDesc.ImageType := TImageType.TwoD;
  ImageDesc.Usage.DepthStencilAttachment := True;
  ImageDesc.Width := 1024;
  ImageDesc.Height := 1024;
  ImageDesc.PixelFormat := TPixelFormat.Depth;
  ImageDesc.SampleCount := OFFSCREEN_SAMPLE_COUNT;
  ImageDesc.TraceLabel := 'CubemapDepthRT';
  var DepthImg := TImage.Create(ImageDesc);

  { Create 6 pass objects, one for each cubemap face }
  for var Face := 0 to NUM_FACES - 1 do
  begin
    ViewDesc.Init;
    ViewDesc.ColorAttachment.Image := FCubeMap;
    ViewDesc.ColorAttachment.Slice := Face;
    ViewDesc.TraceLabel := UTF8String(Format('CubemapTexview%d', [Face]));
    FOffscreenColorViews[Face] := TView.Create(ViewDesc);
  end;

  ViewDesc.Init;
  ViewDesc.DepthStencilAttachment.Image := DepthImg;
  ViewDesc.TraceLabel := 'DepthStencilAttachment';
  FOffscreenDepthView := TView.Create(ViewDesc);

  { Pass action for offscreen pass (clear to dark grey) }
  FOffscreenPassAction.Colors[0].Init(TLoadAction.Clear, 0.5, 0.5, 0.5, 1.0);

  { Pass action for default pass (clear to light grey) }
  FDisplayPassAction.Colors[0].Init(TLoadAction.Clear, 0.75, 0.75, 0.75, 1.0);

  { Vertex- and index-buffers for cube }
  FCube.MakeCube;

  { Shader and pipeline objects for offscreen-rendering }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(ShapesShaderDesc);
  PipDesc.Layout.Attrs[ATTR_SHAPES_POS].Offset := 0;
  PipDesc.Layout.Attrs[ATTR_SHAPES_POS].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_SHAPES_NORM].Offset := SizeOf(TVector3);
  PipDesc.Layout.Attrs[ATTR_SHAPES_NORM].Format := TVertexFormat.Float3;
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
  PipDesc.Init;
  PipDesc.Shader := TShader.Create(CubeShaderDesc);
  PipDesc.Layout.Attrs[ATTR_CUBE_POS].Offset := 0;
  PipDesc.Layout.Attrs[ATTR_CUBE_POS].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_CUBE_NORM].Offset := SizeOf(TVector3);
  PipDesc.Layout.Attrs[ATTR_CUBE_NORM].Format := TVertexFormat.Float3;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.SampleCount := DISPLAY_SAMPLE_COUNT;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  FDisplayCubePip := TPipeline.Create(PipDesc);

  { A sampler to sample the cubemap render target as texture }
  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Linear;
  SamplerDesc.MagFilter := TFilter.Linear;
  FSampler := TSampler.Create(SamplerDesc);

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
  Desc.Usage.IndexBuffer := True;
  Desc.Data := TRange.Create(INDICES);
  Desc.TraceLabel := 'CubeIndices';
  IBuf := TBuffer.Create(Desc);

  NumElements := Length(INDICES);
end;

end.

unit Tex3DApp;
{ Test 3D texture rendering. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  Tex3DShader;

const
  TEX3D_DIM = 32;

type
  TTex3DApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
    FShader: TShader;
    FPip: TPipeline;
    FBind: TBindings;
    FRX: Single;
    FRY: Single;
    FT: Single;
    FX: UInt32;
  private
    function XorShift32: UInt32;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue;

const
  { Cube vertex buffer }
  VERTICES: array [0..71] of Single = (
    -1.0, -1.0, -1.0,    1.0, -1.0, -1.0,    1.0,  1.0, -1.0,   -1.0,  1.0, -1.0,
    -1.0, -1.0,  1.0,    1.0, -1.0,  1.0,    1.0,  1.0,  1.0,   -1.0,  1.0,  1.0,
    -1.0, -1.0, -1.0,   -1.0,  1.0, -1.0,   -1.0,  1.0,  1.0,   -1.0, -1.0,  1.0,
     1.0, -1.0, -1.0,    1.0,  1.0, -1.0,    1.0,  1.0,  1.0,    1.0, -1.0,  1.0,
    -1.0, -1.0, -1.0,   -1.0, -1.0,  1.0,    1.0, -1.0,  1.0,    1.0, -1.0, -1.0,
    -1.0,  1.0, -1.0,   -1.0,  1.0,  1.0,    1.0,  1.0,  1.0,    1.0,  1.0, -1.0);

const
  { Index buffer for the cube }
  INDICES: array [0..35] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20);

{ TTex3DApp }

procedure TTex3DApp.Cleanup;
begin
  FPip.Free;
  FShader.Free;
  FBind.IndexBuffer.Free;
  FBind.VertexBuffers[0].Free;
  FBind.Views[VIEW_TEX].Image.Free;
  FBind.Views[VIEW_TEX].Free;
  FBind.Samplers[SMP_SMP].Free;
  inherited;
end;

procedure TTex3DApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := '3D Texture Rendering';
end;

procedure TTex3DApp.Frame;
begin
  { Compute vertex-shader params (mvp and texcoord-scale) }
  var T: Single := FrameDuration * 60;
  FRX := FRX + (1 * T);
  FRY := FRY + (2 * T);
  FT := FT + 0.03 * T;

  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), FramebufferWidth / FramebufferHeight, 0.01, 10.0);
  View.InitLookAtRH(Vector3(0, 1.5, 4), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  var RXM, RYM: TMatrix4;
  RXM.InitRotationX(Radians(FRX));
  RYM.InitRotationY(Radians(FRY));
  var Model := RXM * RYM;
  var VSParams: TVSParams;
  VSParams.MVP := ViewProj * Model;
  VSParams.Scale := (FastSin(FT) + 1) * 0.5;

  { Render the scene }
  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyBindings(FBind);
  TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(0, 36, 1);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TTex3DApp.Init;
var
  Pixels: array [0..TEX3D_DIM - 1, 0..TEX3D_DIM - 1, 0..TEX3D_DIM - 1] of UInt32;
begin
  inherited;
  FX := $12345678;
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0.25, 0.5, 0.75, 1);

  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Usage.VertexBuffer := True;
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'CubeVertices';
  FBind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.Usage.IndexBuffer := True;
  BufferDesc.Data := TRange.Create(INDICES);
  BufferDesc.TraceLabel := 'CubeIndices';
  FBind.IndexBuffer := TBuffer.Create(BufferDesc);

  { Create shader and pipeline object }
  FShader := TShader.Create(CubeShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Attrs[ATTR_CUBE_POSITION].Format := TVertexFormat.Float3;
  PipDesc.Shader := FShader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.TraceLabel := 'CubePipeline';

  FPip := TPipeline.Create(PipDesc);

  { Create a 3d image with random content, and a texture view for binding }
  for var X := 0 to TEX3D_DIM - 1 do
    for var Y := 0 to TEX3D_DIM - 1 do
      for var Z := 0 to TEX3D_DIM - 1 do
        Pixels[X, Y, Z] := XorShift32;

  var ImgDesc := TImageDesc.Create;
  ImgDesc.ImageType := TImageType.ThreeD;
  ImgDesc.Width := TEX3D_DIM;
  ImgDesc.Height := TEX3D_DIM;
  ImgDesc.NumSlices := TEX3D_DIM;
  ImgDesc.NumMipmaps := 1;
  ImgDesc.PixelFormat := TPixelFormat.Rgba8;
  ImgDesc.TraceLabel := '3D Texture';
  ImgDesc.Data.MipLevels[0] := TRange.Create(Pixels);
  var Image := TImage.Create(ImgDesc);

  var ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := Image;
  FBind.Views[VIEW_TEX] := TView.Create(ViewDesc);

  { ...and a sampler object }
  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Linear;
  SamplerDesc.MagFilter := TFilter.Linear;
  SamplerDesc.TraceLabel := 'Sampler';
  FBind.Samplers[SMP_SMP] := TSampler.Create(SamplerDesc);
end;

function TTex3DApp.XorShift32: UInt32;
begin
  var X := FX;
  X := X xor (X shl 13);
  X := X xor (X shr 17);
  X := X xor (X shl 5);
  FX := X;
  Result := X;
end;

end.

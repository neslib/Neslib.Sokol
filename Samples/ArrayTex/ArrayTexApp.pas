unit ArrayTexApp;
{ 2D array texture creation and rendering. }
interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  ArrayTexShader;

type
  TArrayTexApp = class(TSampleApp)
  private const
    IMG_LAYERS = 3;
    IMG_WIDTH  = 16;
    IMG_HEIGHT = 16;
  private
    FPassAction: TPassAction;
    FShader: TShader;
    FPip: TPipeline;
    FBind: TBindings;
    FPixels: array [0..IMG_LAYERS - 1, 0..IMG_HEIGHT - 1, 0..IMG_WIDTH - 1] of UInt32;
    FRX: Single;
    FRY: Single;
  private
    function ComputeVSParams(const AOffset: Single): TVSParams;
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
  VERTICES: array [0..119] of Single = (
  { pos                  uvs }
    -1.0, -1.0, -1.0,    0.0, 0.0,
     1.0, -1.0, -1.0,    1.0, 0.0,
     1.0,  1.0, -1.0,    1.0, 1.0,
    -1.0,  1.0, -1.0,    0.0, 1.0,

    -1.0, -1.0,  1.0,    0.0, 0.0,
     1.0, -1.0,  1.0,    1.0, 0.0,
     1.0,  1.0,  1.0,    1.0, 1.0,
    -1.0,  1.0,  1.0,    0.0, 1.0,

    -1.0, -1.0, -1.0,    0.0, 0.0,
    -1.0,  1.0, -1.0,    1.0, 0.0,
    -1.0,  1.0,  1.0,    1.0, 1.0,
    -1.0, -1.0,  1.0,    0.0, 1.0,

     1.0, -1.0, -1.0,    0.0, 0.0,
     1.0,  1.0, -1.0,    1.0, 0.0,
     1.0,  1.0,  1.0,    1.0, 1.0,
     1.0, -1.0,  1.0,    0.0, 1.0,

    -1.0, -1.0, -1.0,    0.0, 0.0,
    -1.0, -1.0,  1.0,    1.0, 0.0,
     1.0, -1.0,  1.0,    1.0, 1.0,
     1.0, -1.0, -1.0,    0.0, 1.0,

    -1.0,  1.0, -1.0,    0.0, 0.0,
    -1.0,  1.0,  1.0,    1.0, 0.0,
     1.0,  1.0,  1.0,    1.0, 1.0,
     1.0,  1.0, -1.0,    0.0, 1.0);

const
  INDICES: array [0..35] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20);

{ TArrayTexApp }

procedure TArrayTexApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Array Texture';
end;

procedure TArrayTexApp.Init;
const
  LAYER_COLORS: array [0..IMG_LAYERS - 1] of UInt32 = ($0000FF, $00FF00, $FF0000);
begin
  inherited;
  { A default pass action to clear to black }
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0, 0, 0, 1);

  { A 16x16 array image with 3 layers and a checkerboard pattern }
  var EvenOdd := 0;
  for var Layer := 0 to IMG_LAYERS - 1 do
  begin
    for var Y := 0 to IMG_HEIGHT - 1 do
    begin
      for var X := 0 to IMG_HEIGHT - 1 do
      begin
        if ((EvenOdd and 1) <> 0) then
          FPixels[Layer, Y, X] := LAYER_COLORS[Layer];
        Inc(EvenOdd);
      end;
      Inc(EvenOdd);
    end;
  end;

  var ImageDesc := TImageDesc.Create;
  ImageDesc.ImageType := TImageType.&Array;
  ImageDesc.Width := IMG_WIDTH;
  ImageDesc.Height := IMG_HEIGHT;
  ImageDesc.NumSlices := IMG_LAYERS;
  ImageDesc.PixelFormat := TPixelFormat.Rgba8;
  ImageDesc.Data.MipLevels[0] := TRange.Create(FPixels);
  ImageDesc.TraceLabel := 'ArrayTexture';
  var Image := TImage.Create(ImageDesc);

  { A texture view for the image }
  var ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := Image;
  ViewDesc.TraceLabel := 'ArrayTextureView';
  FBind.Views[VIEW_TEX] := TView.Create(ViewDesc);

  { A sampler object }
  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Linear;
  SamplerDesc.MagFilter := TFilter.Linear;
  SamplerDesc.TraceLabel := 'Sampler';
  FBind.Samplers[SMP_SMP] := TSampler.Create(SamplerDesc);

  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'CubeVertices';
  FBind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.Usage.IndexBuffer := True;
  BufferDesc.Data := TRange.Create(INDICES);
  BufferDesc.TraceLabel := 'CubeIndices';
  FBind.IndexBuffer := TBuffer.Create(BufferDesc);

  FShader := TShader.Create(ArrayTexShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Attrs[ATTR_ARRAYTEX_POSITION].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_ARRAYTEX_TEXCOORD0].Format := TVertexFormat.Float2;
  PipDesc.Shader := FShader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.TraceLabel := 'CubePipeline';

  FPip := TPipeline.Create(PipDesc);
end;

procedure TArrayTexApp.Frame;
begin
  var T: Single := FrameDuration * 60;
  var Offset: Single := FrameCount * 0.0001;
  FRX := FRX + 1 * T;
  FRY := FRY + 2 * T;
  var VSParams := ComputeVSParams(Offset);

  { Render the frame }
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

procedure TArrayTexApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

function TArrayTexApp.ComputeVSParams(const AOffset: Single): TVSParams;
begin
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;

  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), W / H, 0.01, 10.0);
  View.InitLookAtRH(Vector3(0, 1.5, 4), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  var RXM, RYM: TMatrix4;
  RXM.InitRotationX(Radians(FRX));
  RYM.InitRotationY(Radians(FRY));
  var Model := RXM * RYM;

  { Model-view-projection matrix for vertex shader }
  Result.MVP := ViewProj * Model;

  { UV offsets }
  Result.Offset0 := Vector2(-AOffset,  AOffset);
  Result.Offset1 := Vector2( AOffset, -AOffset);
  Result.Offset2 := Vector2(       0,        0);
end;

end.

unit DynTexApp;
{ Update dynamic texture with CPU-generated data each frame. }
interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  DynTexShader;

type
  TDynTexApp = class(TSampleApp)
  private const
    IMAGE_WIDTH  = 64;
    IMAGE_HEIGHT = 64;
    LIVING       = $FFFFFFFF;
    DEAD         = $FF000000;
  private
    FPassAction: TPassAction;
    FShader: TShader;
    FPip: TPipeline;
    FImage: TImage;
    FBind: TBindings;
    FPixels: array [0..IMAGE_HEIGHT - 1, 0..IMAGE_WIDTH - 1] of UInt32;
    FUpdateCount: Integer;
    FRX: Single;
    FRY: Single;
  private
    procedure GameOfLifeInit;
    procedure GameOfLifeUpdate;
    function ComputeVSParams: TVSParams;
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
  VERTICES: array [0..215] of Single = (
  { pos                  color                   uvs }
    -1.0, -1.0, -1.0,    1.0, 0.0, 0.0, 1.0,     0.0, 0.0,
     1.0, -1.0, -1.0,    1.0, 0.0, 0.0, 1.0,     1.0, 0.0,
     1.0,  1.0, -1.0,    1.0, 0.0, 0.0, 1.0,     1.0, 1.0,
    -1.0,  1.0, -1.0,    1.0, 0.0, 0.0, 1.0,     0.0, 1.0,

    -1.0, -1.0,  1.0,    0.0, 1.0, 0.0, 1.0,     0.0, 0.0,
     1.0, -1.0,  1.0,    0.0, 1.0, 0.0, 1.0,     1.0, 0.0,
     1.0,  1.0,  1.0,    0.0, 1.0, 0.0, 1.0,     1.0, 1.0,
    -1.0,  1.0,  1.0,    0.0, 1.0, 0.0, 1.0,     0.0, 1.0,

    -1.0, -1.0, -1.0,    0.0, 0.0, 1.0, 1.0,     0.0, 0.0,
    -1.0,  1.0, -1.0,    0.0, 0.0, 1.0, 1.0,     1.0, 0.0,
    -1.0,  1.0,  1.0,    0.0, 0.0, 1.0, 1.0,     1.0, 1.0,
    -1.0, -1.0,  1.0,    0.0, 0.0, 1.0, 1.0,     0.0, 1.0,

     1.0, -1.0, -1.0,    1.0, 0.5, 0.0, 1.0,     0.0, 0.0,
     1.0,  1.0, -1.0,    1.0, 0.5, 0.0, 1.0,     1.0, 0.0,
     1.0,  1.0,  1.0,    1.0, 0.5, 0.0, 1.0,     1.0, 1.0,
     1.0, -1.0,  1.0,    1.0, 0.5, 0.0, 1.0,     0.0, 1.0,

    -1.0, -1.0, -1.0,    0.0, 0.5, 1.0, 1.0,     0.0, 0.0,
    -1.0, -1.0,  1.0,    0.0, 0.5, 1.0, 1.0,     1.0, 0.0,
     1.0, -1.0,  1.0,    0.0, 0.5, 1.0, 1.0,     1.0, 1.0,
     1.0, -1.0, -1.0,    0.0, 0.5, 1.0, 1.0,     0.0, 1.0,

    -1.0,  1.0, -1.0,    1.0, 0.0, 0.5, 1.0,     0.0, 0.0,
    -1.0,  1.0,  1.0,    1.0, 0.0, 0.5, 1.0,     1.0, 0.0,
     1.0,  1.0,  1.0,    1.0, 0.0, 0.5, 1.0,     1.0, 1.0,
     1.0,  1.0, -1.0,    1.0, 0.0, 0.5, 1.0,     0.0, 1.0);

const
  INDICES: array [0..35] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20);

{ TDynTexApp }

procedure TDynTexApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Dynamic Texture';
end;

procedure TDynTexApp.Init;
begin
  inherited;
  var ImageDesc := TImageDesc.Create;
  ImageDesc.Width := IMAGE_WIDTH;
  ImageDesc.Height := IMAGE_HEIGHT;
  ImageDesc.PixelFormat := TPixelFormat.Rgba8;
  ImageDesc.Usage.StreamUpdate := True;
  ImageDesc.TraceLabel := 'DynamicTexture';
  FImage := TImage.Create(ImageDesc);

  var ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := FImage;
  ViewDesc.TraceLabel := 'DynamicTextureView';
  FBind.Views[VIEW_TEX] := TView.Create(ViewDesc);

  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Linear;
  SamplerDesc.MagFilter := TFilter.Linear;
  SamplerDesc.WrapU := TWrap.ClampToEdge;
  SamplerDesc.WrapV := TWrap.ClampToEdge;
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

  FShader := TShader.Create(DynTexShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Attrs[ATTR_DYNTEX_POSITION].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_DYNTEX_COLOR0].Format := TVertexFormat.Float4;
  PipDesc.Layout.Attrs[ATTR_DYNTEX_TEXCOORD0].Format := TVertexFormat.Float2;
  PipDesc.Shader := FShader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.TraceLabel := 'CubePipeline';

  FPip := TPipeline.Create(PipDesc);

  GameOfLifeInit;
end;
procedure TDynTexApp.Frame;
begin
  var T: Single := FrameDuration * 60;
  FRX := FRX + (1 * T);
  FRY := FRY + (2 * T);
  var VSParams := ComputeVSParams;

  { Update game-of-life state }
  GameOfLifeUpdate;

  { Update the texture }
  var ImageData: TImageData;
  ImageData.MipLevels[0] := TRange.Create(FPixels);
  FImage.Update(ImageData);

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

procedure TDynTexApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

function TDynTexApp.ComputeVSParams: TVSParams;
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
  Result.MVP := ViewProj * Model;
end;

procedure TDynTexApp.GameOfLifeInit;
begin
  for var Y := 0 to IMAGE_HEIGHT - 1 do
    for var X := 0 to IMAGE_WIDTH - 1 do
    begin
      if (Random(256) > 230) then
        FPixels[Y, X] := LIVING
      else
        FPixels[Y, X] := DEAD;
    end;
end;

procedure TDynTexApp.GameOfLifeUpdate;
begin
  for var Y := 0 to IMAGE_HEIGHT - 1 do
  begin
    for var X := 0 to IMAGE_WIDTH - 1 do
    begin
      var NumLivingNeighbors := 0;
      for var NY := -1 to 1 do
      begin
        for var NX := -1 to 1 do
        begin
          if (NX = 0) and (NY = 0) then
            Continue;

          if (FPixels[(Y + NY) and (IMAGE_HEIGHT - 1), (X + NX) and (IMAGE_WIDTH - 1)] = LIVING) then
            Inc(NumLivingNeighbors);
        end;
      end;

      { Any live cell... }
      if (FPixels[Y, X] = LIVING) then
      begin
        if (NumLivingNeighbors < 2) then
          { ...with fewer than 2 living neighbours dies, as if caused by
            underpopulation }
          FPixels[Y, X] := DEAD
        else if (NumLivingNeighbors > 3) then
          { ...with more than 3 living neighbours dies, as if caused by
            overpopulation }
          FPixels[Y, X] := DEAD;
      end
      else if (NumLivingNeighbors = 3) then
        { Any dead cell with exactly 3 living neighbours becomes a live cell,
          as if by reproduction }
        FPixels[Y, X] := LIVING;
    end;
  end;

  Inc(FUpdateCount);
  if (FUpdateCount > 240) then
  begin
    GameOfLifeInit;
    FUpdateCount := 0;
  end;
end;

end.

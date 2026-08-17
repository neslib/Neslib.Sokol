unit VertexTexturApp;
{ Render to render target texture, and then use this texture to displace
  vertices in a vertex shader. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  VertexTextureShader;

const
  { Plane number of tiles along edge (don't change this since the value is
    hardcoded in shader) }
  NUM_TILES_ALONG_EDGE = 255;

type
  TVertexTextureApp = class(TSampleApp)
  private type
    TOffscreen = record
    public
      Image: TImage;
      Pip: TPipeline;
      Pass: TPass;
      PlasmaParams: TPlasmaParams;
    public
      procedure Init;
    end;
  private type
    TDisplay = record
    public
      IBuf: TBuffer;
      Pip: TPipeline;
      PassAction: TPassAction;
      Bind: TBindings;
    public
      procedure Init(const AOffscreenImage: TImage);
    end;
  private
    FRY: Single;
    FOffscreen: TOffscreen;
    FDisplay: TDisplay;
  private
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


{ TVertexTextureApp }

procedure TVertexTextureApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Vertex Texture';
end;

procedure TVertexTextureApp.Init;
begin
  inherited;
  FOffscreen.Init;
  FDisplay.Init(FOffscreen.Image);
end;

procedure TVertexTextureApp.Frame;
const
  NUM_ELEMENTS = NUM_TILES_ALONG_EDGE * NUM_TILES_ALONG_EDGE * 6;
begin
  FOffscreen.PlasmaParams.Time := FOffscreen.PlasmaParams.Time + FrameDuration;

  { Offscreen pass to render plasma. This renders an offscreen-triangle with
    vertices synthesized in the vertex shader }
  TGfx.BeginPass(FOffscreen.Pass);
  TGfx.ApplyPipeline(FOffscreen.Pip);
  TGfx.ApplyUniforms(UB_PLASMA_PARAMS, TRange.Create(FOffscreen.PlasmaParams));
  TGfx.Draw(0, 3);
  TGfx.EndPass;

  { Display pass to render vertex-displaced plane }
  var VSParams := ComputeVSParams;
  var Pass := TPass.Create;
  Pass.Action^ := FDisplay.PassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FDisplay.Pip);
  TGfx.ApplyBindings(FDisplay.Bind);
  TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(0, NUM_ELEMENTS);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TVertexTextureApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

function TVertexTextureApp.ComputeVSParams: TVSParams;
begin
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var T: Single := FrameDuration * 60;
  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), W / H, 0.01, 10.0);
  View.InitLookAtRH(Vector3(0, 1, 2.5), TVector3.Zero, TVector3.UnitY);
  var ViewProj := Proj * View;

  FRY := FRY + (0.5 * T);
  var Model: TMatrix4;
  Model.InitRotationY(Radians(FRY));
  Result.MVP := ViewProj * Model;
end;

{ TVertexTextureApp.TOffscreen }

procedure TVertexTextureApp.TOffscreen.Init;
begin
  { Render target texture for GPU-rendered plasma }
  var ImageDesc := TImageDesc.Create;
  ImageDesc.Usage.ColorAttachment := True;
  ImageDesc.Width := 256;
  ImageDesc.Height := 256;
  ImageDesc.PixelFormat := TPixelFormat.Rgba8;
  ImageDesc.SampleCount := 1;
  ImageDesc.TraceLabel := 'PlasmaTexture';
  Image := TImage.Create(ImageDesc);

  { Render-pass attachments and pass action for the offscreen render pass }
  Pass.Action.Colors[0].LoadAction := TLoadAction.DontCare;

  var ViewDesc := TViewDesc.Create;
  ViewDesc.ColorAttachment.Image := Image;
  ViewDesc.TraceLabel := 'PlasmaTextureAttachment';
  Pass.Attachments.Colors[0] := TView.Create(ViewDesc);

  { Pipeline object for offscreen rendering. Vertices will be synthesized in the
    vertex shader, so don't need a vertex buffer or vertex layout }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(PlasmaShaderDesc);
  PipDesc.Colors[0].PixelFormat := TPixelFormat.Rgba8;
  PipDesc.Depth.PixelFormat := TPixelFormat.None;
  PipDesc.SampleCount := 1;
  PipDesc.TraceLabel := 'PlasmaPipeline';
  Pip := TPipeline.Create(PipDesc);
end;

{ TVertexTextureApp.TDisplay }

procedure TVertexTextureApp.TDisplay.Init(const AOffscreenImage: TImage);
begin
  { An index buffer with triangle indices for a 256x256 plane }
  var IBufSize := NUM_TILES_ALONG_EDGE * NUM_TILES_ALONG_EDGE * 6;
  var Indices: TArray<UInt16>;
  SetLength(Indices, IBufSize);
  var Ptr := PWord(Indices);
  for var Y := 0 to NUM_TILES_ALONG_EDGE - 1 do
    for var X := 0 to NUM_TILES_ALONG_EDGE - 1 do
    begin
      var I0 := (Y * (NUM_TILES_ALONG_EDGE + 1)) + X;
      var I1 := I0 + 1;
      var I2 := I0 + NUM_TILES_ALONG_EDGE + 1;
      var I3 := I2 + 1;
      Ptr^ := I0; Inc(Ptr);
      Ptr^ := I1; Inc(Ptr);
      Ptr^ := I3; Inc(Ptr);
      Ptr^ := I0; Inc(Ptr);
      Ptr^ := I3; Inc(Ptr);
      Ptr^ := I2; Inc(Ptr);
    end;

  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Usage.IndexBuffer := True;
  BufferDesc.Data := TRange.Create(Pointer(Indices), IBufSize * SizeOf(UInt16));
  BufferDesc.TraceLabel := 'PlaneIndices';
  IBuf := TBuffer.Create(BufferDesc);

  { A pipeline object for rendering the vertex-displaced plane.
    Vertices will be synthesized in the shader so no vertex buffer or vertex
    layout needed }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(DisplayShaderDesc);
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.None;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.TraceLabel := 'RenderPipeline';
  Pip := TPipeline.Create(PipDesc);

  { Display pass action (clear to black) }
  PassAction.Colors[0].Init(TLoadAction.Clear, 0, 0, 0, 1);

  { A sampler for accessing the render target as texture }
  var SamplerDesc := TSamplerDesc.Create(TFilter.Nearest);
  SamplerDesc.TraceLabel := 'PlasmaSampler';
  var Sampler := TSampler.Create(SamplerDesc);

  { Bindings for the display-pass }
  Bind.IndexBuffer := IBuf;

  var ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := AOffscreenImage;
  ViewDesc.TraceLabel := 'PlasmaTextureView';
  Bind.Views[VIEW_TEX] := TView.Create(ViewDesc);

  Bind.Samplers[SMP_SMP] := Sampler;
end;

end.

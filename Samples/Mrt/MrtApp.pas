unit MrtApp;
{ Rendering with multi-rendertargets, and recreating render targets when window
  size changes. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  MrtShader;

type
  TMrtApp = class(TSampleApp)
  private const
    OFFSCREEN_SAMPLE_COUNT = 4;
    NUM_MRTS               = 3;
  private type
    TOffscreen = record
      Pip: TPipeline;
      Bind: TBindings;
      Pass: TPass;
    end;
  private type
    TDisplay = record
      Pip: TPipeline;
      Bind: TBindings;
      PassAction: TPassAction;
    end;
  private type
    TDbg = record
      Pip: TPipeline;
      Bind: TBindings;
    end;
  private type
    TImages = record
      Color: array [0..NUM_MRTS - 1] of TImage;
      Resolve: array [0..NUM_MRTS - 1] of TImage;
      Depth: TImage;
    end;
  private
    FOffscreen: TOffscreen;
    FDisplay: TDisplay;
    FDbg: TDbg;
    FImages: TImages;
    FRX: Single;
    FRY: Single;
  private
    procedure ReinitAttachments(const AWidth, AHeight: Integer);
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure Resized(const AWindowWidth, AWindowHeight, AFramebufferWidth,
      AFramebufferHeight: Integer); override;
  end;

implementation

uses
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue;

type
  TVertex = record
    X, Y, Z, B: Single;
  end;

const
  { Cube vertex buffer }
  CUBE_VERTICES: array [0..23] of TVertex = (
    { Pos + Brightness }
    (X: -1.0; Y: -1.0; Z: -1.0; B: 1.0),
    (X:  1.0; Y: -1.0; Z: -1.0; B: 1.0),
    (X:  1.0; Y:  1.0; Z: -1.0; B: 1.0),
    (X: -1.0; Y:  1.0; Z: -1.0; B: 1.0),

    (X: -1.0; Y: -1.0; Z:  1.0; B: 0.8),
    (X:  1.0; Y: -1.0; Z:  1.0; B: 0.8),
    (X:  1.0; Y:  1.0; Z:  1.0; B: 0.8),
    (X: -1.0; Y:  1.0; Z:  1.0; B: 0.8),

    (X: -1.0; Y: -1.0; Z: -1.0; B: 0.6),
    (X: -1.0; Y:  1.0; Z: -1.0; B: 0.6),
    (X: -1.0; Y:  1.0; Z:  1.0; B: 0.6),
    (X: -1.0; Y: -1.0; Z:  1.0; B: 0.6),

    (X:  1.0; Y: -1.0; Z: -1.0; B: 0.4),
    (X:  1.0; Y:  1.0; Z: -1.0; B: 0.4),
    (X:  1.0; Y:  1.0; Z:  1.0; B: 0.4),
    (X:  1.0; Y: -1.0; Z:  1.0; B: 0.4),

    (X: -1.0; Y: -1.0; Z: -1.0; B: 0.5),
    (X: -1.0; Y: -1.0; Z:  1.0; B: 0.5),
    (X:  1.0; Y: -1.0; Z:  1.0; B: 0.5),
    (X:  1.0; Y: -1.0; Z: -1.0; B: 0.5),

    (X: -1.0; Y:  1.0; Z: -1.0; B: 0.7),
    (X: -1.0; Y:  1.0; Z:  1.0; B: 0.7),
    (X:  1.0; Y:  1.0; Z:  1.0; B: 0.7),
    (X:  1.0; Y:  1.0; Z: -1.0; B: 0.7));

const
  { Index buffer for the cube }
  CUBE_INDICES: array [0..35] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20);

const
  { A vertex buffer to render a fullscreen rectangle }
  QUAD_VERTICES: array [0..7] of Single = (0, 0, 1, 0, 0, 1, 1, 1);

{ TMrtApp }

procedure TMrtApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'MRT Rendering';
  AConfig.HighDpi := False;
end;

procedure TMrtApp.Init;
begin
  inherited;
  { A pass action for the default render pass }
  FDisplay.PassAction.Colors[0].LoadAction := TLoadAction.DontCare;
  FDisplay.PassAction.Depth.LoadAction := TLoadAction.DontCare;
  FDisplay.PassAction.Stencil.LoadAction := TLoadAction.DontCare;

  { Pre-allocate all image and view handles upfront. The actual initialization
    will then happen in `ReinitAttachments` which both called from Init and when
    the window size changes/

    NOTE: we could just as well call destroy/make on window resize, and in
    reality this wouldn't make much of a difference. In this sample the
    pre-allocate + Teardown/Setup is used for better test coverage }
  for var I := 0 to NUM_MRTS - 1 do
  begin
    FImages.Color[I].Allocate;
    FImages.Resolve[I].Allocate;
    FOffscreen.Pass.Attachments.Colors[I].Allocate;
    FOffscreen.Pass.Attachments.Resolves[I].Allocate;
    FDisplay.Bind.Views[VIEW_TEX0 + I].Allocate;
  end;
  FImages.Depth.Allocate;
  FOffscreen.Pass.Attachments.DepthStencil.Allocate;

  { Initialize pass attachment images and views }
  ReinitAttachments(FramebufferWidth, FramebufferHeight);

  { Vertex- and index-buffer }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(CUBE_VERTICES);
  BufferDesc.TraceLabel := 'Cube Vertices';
  FOffscreen.Bind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.Usage.IndexBuffer := True;
  BufferDesc.Data := TRange.Create(CUBE_INDICES);
  BufferDesc.TraceLabel := 'Cube Indices';
  FOffscreen.Bind.IndexBuffer := TBuffer.Create(BufferDesc);

  { Pipeline and shader object for the offscreen-rendered cube }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(OffscreenShaderDesc);
  PipDesc.Layout.Buffers[0].Stride := SizeOf(TVertex);
  PipDesc.Layout.Attrs[ATTR_OFFSCREEN_POS].Offset := 0;
  PipDesc.Layout.Attrs[ATTR_OFFSCREEN_POS].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_OFFSCREEN_BRIGHT0].Offset := SizeOf(TVector3);
  PipDesc.Layout.Attrs[ATTR_OFFSCREEN_BRIGHT0].Format := TVertexFormat.Float;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.SampleCount := OFFSCREEN_SAMPLE_COUNT;
  PipDesc.Depth.PixelFormat := TPixelFormat.Depth;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.ColorCount := NUM_MRTS;
  PipDesc.TraceLabel := 'Offscreen Pipeline';
  FOffscreen.Pip := TPipeline.Create(PipDesc);

  { a pass action for the offscreen pass (since the MSAA render targets will be
    resolved into a texture their content doesn't need to be stored) }
  FOffscreen.Pass.Action.Colors[0].Init(TLoadAction.Clear, 0.25, 0, 0, 1);
  FOffscreen.Pass.Action.Colors[1].Init(TLoadAction.Clear, 0, 0.25, 0, 1);
  FOffscreen.Pass.Action.Colors[2].Init(TLoadAction.Clear, 0, 0, 0.25, 1);

  { A vertex buffer to render a fullscreen rectangle }
  BufferDesc.Init;
  BufferDesc.Data := TRange.Create(QUAD_VERTICES);
  BufferDesc.TraceLabel := 'Quad Vertices';
  var QuadVBuf := TBuffer.Create(BufferDesc);

  { A pipeline and shader object to render the fullscreen quad }
  PipDesc.Init;
  PipDesc.Shader := TShader.Create(FsqShaderDesc);
  PipDesc.Layout.Attrs[ATTR_FSQ_POS].Format := TVertexFormat.Float2;
  PipDesc.PrimitiveType := TPrimitiveType.TriangleStrip;
  PipDesc.TraceLabel := 'Fullscreen Quad Pipeline';
  FDisplay.Pip := TPipeline.Create(PipDesc);

  { A sampler object to sample the offscreen render targets as textures }
  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Linear;
  SamplerDesc.MagFilter := TFilter.Linear;
  SamplerDesc.WrapU := TWrap.ClampToEdge;
  SamplerDesc.WrapV := TWrap.ClampToEdge;
  SamplerDesc.TraceLabel := 'Sampler';
  var Sampler := TSampler.Create(SamplerDesc);

  { Complete the resource bindings for the fullscreen quad }
  FDisplay.Bind.VertexBuffers[0] := QuadVBuf;
  FDisplay.Bind.Samplers[SMP_SMP] := Sampler;

  { Pipeline and resource bindings to render debug-visualization quads }
  PipDesc.Init;
  PipDesc.Shader := TShader.Create(DbgShaderDesc);
  PipDesc.Layout.Attrs[ATTR_DBG_POS].Format := TVertexFormat.Float2;
  PipDesc.PrimitiveType := TPrimitiveType.TriangleStrip;
  PipDesc.TraceLabel := 'Dbgvis Quad Pipeline';
  FDbg.Pip := TPipeline.Create(PipDesc);

  FDbg.Bind.VertexBuffers[0] := QuadVBuf;
  FDbg.Bind.Samplers[SMP_SMP] := Sampler;

  { Texture views will be filled right before rendering }
end;

procedure TMrtApp.Frame;
begin
  { View-projection matrix }
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var Proj, View, RXM, RYM: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), W / H, 0.01, 10.0);
  View.InitLookAtRH(Vector3(0, 1.5, 4), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  { Shader parameters }
  var T: Single := FrameDuration * 60;

  FRX := FRX + (1 * T);
  FRY := FRY + (2 * T);
  RXM.InitRotationX(Radians(FRX));
  RYM.InitRotationY(Radians(FRY));
  var Model := RXM * RYM;

  var OffscreenParams: TOffscreenParams;
  OffscreenParams.MVP := ViewProj * Model;

  var FsqParams: TFsqParams;
  FsqParams.Offset := Vector2(
    FastSin(FRX * 0.01) * 0.1,
    FastSin(FRY * 0.01) * 0.1);

  { Render cube into MRT offscreen render targets }
  TGfx.BeginPass(FOffscreen.Pass);
  TGfx.ApplyPipeline(FOffscreen.Pip);
  TGfx.ApplyBindings(FOffscreen.Bind);
  TGfx.ApplyUniforms(UB_OFFSCREEN_PARAMS, TRange.Create(OffscreenParams));
  TGfx.Draw(0, 36);
  TGfx.EndPass;

  { Render fullscreen quad with the 'composed image', plus 3 small debug-view
    quads }
  var Pass := TPass.Create;
  Pass.Action^ := FDisplay.PassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);
  TGfx.ApplyPipeline(FDisplay.Pip);
  TGfx.ApplyBindings(FDisplay.Bind);
  TGfx.ApplyUniforms(UB_FSQ_PARAMS, TRange.Create(FsqParams));
  TGfx.Draw(0, 4);

  TGfx.ApplyPipeline(FDbg.Pip);
  for var I := 0 to NUM_MRTS - 1 do
  begin
    TGfx.ApplyViewport(I * 100, 0, 100, 100, False);
    FDbg.Bind.Views[VIEW_TEX] := FDisplay.Bind.Views[VIEW_TEX0 + I];
    TGfx.ApplyBindings(FDbg.Bind);
    TGfx.Draw(0, 4);
  end;

  TGfx.ApplyViewport(0, 0, FramebufferWidth, FramebufferHeight, False);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TMrtApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

procedure TMrtApp.Resized(const AWindowWidth, AWindowHeight, AFramebufferWidth,
  AFramebufferHeight: Integer);
begin
  inherited;
  ReinitAttachments(AFramebufferWidth, AFramebufferHeight);
end;

procedure TMrtApp.ReinitAttachments(const AWidth, AHeight: Integer);
{ Called initially and when window size changes. Will re-initialize the
  offscreen render target images to a new size and then re-initialize the
  associated view objects }
const
  MSAA_IMAGE_LABELS: array [0..NUM_MRTS - 1] of UTF8String = (
    'MsaaImageRed', 'MsaaImageGreen', 'MsaaImageBlue');
  RESOLVE_IMAGE_LABELS: array [0..NUM_MRTS - 1] of UTF8String = (
    'ResolveImageRed', 'ResolveImageGreen', 'ResolveImageBlue');
  COLOR_ATTACHMENT_LABELS: array [0..NUM_MRTS - 1] of UTF8String = (
    'ColorAttachmentRed', 'ColorAttachmentGreen', 'ColorAttachmentBlue');
  RESOLVE_ATTACHMENT_LABELS: array [0..NUM_MRTS - 1] of UTF8String = (
    'ResolveAttachmentRed', 'ResolveAttachmentGreen', 'ResolveAttachmentBlue');
  TEX_VIEW_LABELS: array [0..NUM_MRTS - 1] of UTF8String = (
    'TextureViewRed', 'TextureViewGreen', 'TextureViewBlue');
begin
  { Uninitialize the render target images and associated views (NOTE: it's fine
    to call Teardown on resources in Alloc state) }
  for var I := 0 to NUM_MRTS - 1 do
  begin
    FImages.Color[I].Teardown;
    FImages.Resolve[I].Teardown;
    FOffscreen.Pass.Attachments.Colors[I].Teardown;
    FOffscreen.Pass.Attachments.Resolves[I].Teardown;
    FDisplay.Bind.Views[VIEW_TEX0 + I].Teardown;
  end;
  FImages.Depth.Teardown;
  FOffscreen.Pass.Attachments.DepthStencil.Teardown;

  { ..next initialize images with the new size and re-init their associated
    handles }
  for var I := 0 to NUM_MRTS - 1 do
  begin
    var ImageDesc := TImageDesc.Create;
    ImageDesc.Usage.ColorAttachment := True;
    ImageDesc.Width := AWidth;
    ImageDesc.Height := AHeight;
    ImageDesc.SampleCount := OFFSCREEN_SAMPLE_COUNT;
    ImageDesc.TraceLabel := MSAA_IMAGE_LABELS[I];
    FImages.Color[I] := TImage.Create(ImageDesc);

    ImageDesc.Init;
    ImageDesc.Usage.ResolveAttachment := True;
    ImageDesc.Width := AWidth;
    ImageDesc.Height := AHeight;
    ImageDesc.SampleCount := 1;
    ImageDesc.TraceLabel := RESOLVE_IMAGE_LABELS[I];
    FImages.Resolve[I] := TImage.Create(ImageDesc);

    var ViewDesc := TViewDesc.Create;
    ViewDesc.ColorAttachment.Image := FImages.Color[I];
    ViewDesc.TraceLabel := COLOR_ATTACHMENT_LABELS[I];
    FOffscreen.Pass.Attachments.Colors[I] := TView.Create(ViewDesc);

    ViewDesc.Init;
    ViewDesc.ResolveAttachment.Image := FImages.Resolve[I];
    ViewDesc.TraceLabel := RESOLVE_ATTACHMENT_LABELS[I];
    FOffscreen.Pass.Attachments.Resolves[I] := TView.Create(ViewDesc);

    ViewDesc.Init;
    ViewDesc.Texture.Image := FImages.Resolve[I];
    ViewDesc.TraceLabel := TEX_VIEW_LABELS[I];
    FDisplay.Bind.Views[VIEW_TEX0 + I] := TView.Create(ViewDesc);
  end;

  var ImageDesc := TImageDesc.Create;
  ImageDesc.Usage.DepthStencilAttachment := True;
  ImageDesc.Width := AWidth;
  ImageDesc.Height := AHeight;
  ImageDesc.PixelFormat := TPixelFormat.Depth;
  ImageDesc.SampleCount := OFFSCREEN_SAMPLE_COUNT;
  ImageDesc.TraceLabel := 'DepthImage';
  FImages.Depth := TImage.Create(ImageDesc);

  var ViewDesc := TViewDesc.Create;
  ViewDesc.DepthStencilAttachment.Image := FImages.Depth;
  ViewDesc.TraceLabel := 'DepthAttachment';
  FOffscreen.Pass.Attachments.DepthStencil := TView.Create(ViewDesc);
end;

end.

unit ShadowsApp;
{ Shadow mapping via a regular RGBA8 texture as shadow map. The depth value is
  encoded to RGBA8 in the shadow pass fragment shader, and decoded from RGBA8 in
  the display-pass fragment shader.

  Also see ShadowsDepthTex for a similar sample using a depth-only pass and
  depth-buffer as shadow map. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  ShadowsShader;

type
  TShadow = record
  public
    Pass: TPass;
    Pip: TPipeline;
    Bind: TBindings;
    TexView: TView;
    Sampler: TSampler;
  public
    procedure Init(const AVBuf, AIBuf: TBuffer);
  end;

type
  TDisplay = record
  public
    PassAction: TPassAction;
    Pip: TPipeline;
    Bind: TBindings;
  public
    procedure Init(const AVBuf, AIBuf: TBuffer; const AShadowMapTexView: TView;
      const AShadowSampler: TSampler);
  end;

type
  TDebug = record
  public
    Pip: TPipeline;
    Bind: TBindings;
  public
    procedure Init(const AShadowMapTexView: TView);
  end;

type
  TShadowsApp = class(TSampleApp)
  private
    FVBuf: TBuffer;
    FIBuf: TBuffer;
    FRY: Single;
    FShadow: TShadow;
    FDisplay: TDisplay;
    FDebug: TDebug;
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
  { Vertex buffer for a cube and plane }
  SCENE_VERTICES: array [0..167] of Single = (
  // Pos                 Normal
    -1.0, -1.0, -1.0,    0.0, 0.0, -1.0,  //CUBE BACK FACE
     1.0, -1.0, -1.0,    0.0, 0.0, -1.0,
     1.0,  1.0, -1.0,    0.0, 0.0, -1.0,
    -1.0,  1.0, -1.0,    0.0, 0.0, -1.0,

    -1.0, -1.0,  1.0,    0.0, 0.0, 1.0,   //CUBE FRONT FACE
     1.0, -1.0,  1.0,    0.0, 0.0, 1.0,
     1.0,  1.0,  1.0,    0.0, 0.0, 1.0,
    -1.0,  1.0,  1.0,    0.0, 0.0, 1.0,

    -1.0, -1.0, -1.0,    -1.0, 0.0, 0.0,  //CUBE LEFT FACE
    -1.0,  1.0, -1.0,    -1.0, 0.0, 0.0,
    -1.0,  1.0,  1.0,    -1.0, 0.0, 0.0,
    -1.0, -1.0,  1.0,    -1.0, 0.0, 0.0,

     1.0, -1.0, -1.0,    1.0, 0.0, 0.0,   //CUBE RIGHT FACE
     1.0,  1.0, -1.0,    1.0, 0.0, 0.0,
     1.0,  1.0,  1.0,    1.0, 0.0, 0.0,
     1.0, -1.0,  1.0,    1.0, 0.0, 0.0,

    -1.0, -1.0, -1.0,    0.0, -1.0, 0.0,  //CUBE BOTTOM FACE
    -1.0, -1.0,  1.0,    0.0, -1.0, 0.0,
     1.0, -1.0,  1.0,    0.0, -1.0, 0.0,
     1.0, -1.0, -1.0,    0.0, -1.0, 0.0,

    -1.0,  1.0, -1.0,    0.0, 1.0, 0.0,   //CUBE TOP FACE
    -1.0,  1.0,  1.0,    0.0, 1.0, 0.0,
     1.0,  1.0,  1.0,    0.0, 1.0, 0.0,
     1.0,  1.0, -1.0,    0.0, 1.0, 0.0,

    -5.0,  0.0, -5.0,    0.0, 1.0, 0.0,   //PLANE GEOMETRY
    -5.0,  0.0,  5.0,    0.0, 1.0, 0.0,
     5.0,  0.0,  5.0,    0.0, 1.0, 0.0,
     5.0,  0.0, -5.0,    0.0, 1.0, 0.0);

const
  { And a matching index buffer for the scene }
  SCENE_INDICES: array [0..41] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20,
    26, 25, 24,  27, 26, 24);

const
  { A vertex bufferto render a debug visualization of the shadow map }
  DEBUG_VERTICES: array [0..7] of Single = (
    0.0, 0.0,  1.0, 0.0,  0.0, 1.0,  1.0, 1.0);

{ TShadowsApp }

procedure TShadowsApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Shadow Rendering';
end;

procedure TShadowsApp.Init;
begin
  inherited;
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(SCENE_VERTICES);
  BufferDesc.TraceLabel := 'CubeVertices';
  FVBuf := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.Usage.IndexBuffer := True;
  BufferDesc.Data := TRange.Create(SCENE_INDICES);
  BufferDesc.TraceLabel := 'CubeIndices';
  FIBuf := TBuffer.Create(BufferDesc);

  FShadow.Init(FVBuf, FIBuf);
  FDisplay.Init(FVBuf, FIBuf, FShadow.TexView, FShadow.Sampler);
  FDebug.Init(FShadow.TexView);
end;

procedure TShadowsApp.Frame;
begin
  var T: Single := FrameDuration * 60;
  FRY := FRY + (0.2 * T);

  var EyePos := Vector3(5, 5, 5);
  var PlaneModel := TMatrix4.Identity;
  var CubeModel: TMatrix4;
  CubeModel.InitTranslation(0, 1.5, 0);
  var PlaneColor := Vector3(1, 0.5, 0);
  var CubeColor := Vector3(0.5, 0.5, 1);

  { Calculate matrices for shadow pass }
  var RYM, LightView, LightProj: TMatrix4;
  RYM.InitRotationY(Radians(FRY));
  var LightPos := RYM * Vector4(50, 50, -50, 1);
  LightView.InitLookAtRH(Vector3(LightPos), Vector3(0, 1.5, 0), Vector3(0, 1, 0));
  LightProj.InitOrthoOffCenterRH(-5, 5, 5, -5, 0, 100);
  var LightViewProj := LightProj * LightView;

  var CubeVSShadowParams: TVSShadowParams;
  CubeVSShadowParams.Mvp := LightViewProj * CubeModel;

  { Calculate matrices for display pass }
  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), FramebufferWidth / FramebufferHeight,
    0.01, 100);
  View.InitLookAtRH(EyePos, Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  var FSDisplayParams: TFSDisplayParams;
  FSDisplayParams.LightDir := Vector3(LightPos).Normalize;
  FSDisplayParams.EyePos := EyePos;

  var PlaneVSDisplayParams: TVSDisplayParams;
  PlaneVSDisplayParams.Mvp := ViewProj * PlaneModel;
  PlaneVSDisplayParams.Model := PlaneModel;
  PlaneVSDisplayParams.LightMvp := LightViewProj * PlaneModel;
  PlaneVSDisplayParams.DiffColor := PlaneColor;

  var CubeVSDisplayParams: TVSDisplayParams;
  CubeVSDisplayParams.Mvp := ViewProj * CubeModel;
  CubeVSDisplayParams.Model := CubeModel;
  CubeVSDisplayParams.LightMvp := LightViewProj * CubeModel;
  CubeVSDisplayParams.DiffColor := CubeColor;

  { the shadow map pass, render scene from light source into shadow map texture }
  TGfx.BeginPass(FShadow.Pass);
  TGfx.ApplyPipeline(FShadow.Pip);
  TGfx.ApplyBindings(FShadow.Bind);
  TGfx.ApplyUniforms(UB_VS_SHADOW_PARAMS, TRange.Create(CubeVSShadowParams));
  TGfx.Draw(0, 36);
  TGfx.EndPass;

  { The display pass, render scene from camera and sample the shadow map }
  var Pass := TPass.Create;
  Pass.Action^ := FDisplay.PassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FDisplay.Pip);
  TGfx.ApplyBindings(FDisplay.Bind);
  TGfx.ApplyUniforms(UB_FS_DISPLAY_PARAMS, TRange.Create(FSDisplayParams));

  { Render plane }
  TGfx.ApplyUniforms(UB_VS_DISPLAY_PARAMS, TRange.Create(PlaneVSDisplayParams));
  TGfx.Draw(36, 6, 1);

  { Render cube }
  TGfx.ApplyUniforms(UB_VS_DISPLAY_PARAMS, TRange.Create(CubeVSDisplayParams));
  TGfx.Draw(0, 36, 1);

  { Render debug visualization of shadow-map }
  var DebugSize: Single := 150 * DpiScale;
  TGfx.ApplyPipeline(FDebug.Pip);
  TGfx.ApplyBindings(FDebug.Bind);
  TGfx.ApplyViewport(FramebufferWidth - DebugSize, 0, DebugSize, DebugSize, False);
  TGfx.Draw(0, 4, 1);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TShadowsApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

{ TShadow }

procedure TShadow.Init(const AVBuf, AIBuf: TBuffer);
begin
  { A regular RGBA8 render target image as shadow map  }
  var ImgDesc := TImageDesc.Create;
  ImgDesc.Usage.ColorAttachment := True;
  ImgDesc.Width := 2048;
  ImgDesc.Height := 2048;
  ImgDesc.PixelFormat := TPixelFormat.Rgba8;
  ImgDesc.SampleCount := 1;
  ImgDesc.TraceLabel := 'ShadowMap';
  var ShadowMapImg := TImage.Create(ImgDesc);

  { We also need a separate depth-buffer image for the shadow pass }
  ImgDesc.Usage.ColorAttachment := False;
  ImgDesc.Usage.DepthStencilAttachment := True;
  ImgDesc.PixelFormat := TPixelFormat.Depth;
  ImgDesc.TraceLabel := 'ShadowDepthBuffer';
  var ShadowDepthImg := TImage.Create(ImgDesc);

  { Attachment and texture views}
  var ViewDesc := TViewDesc.Create;
  ViewDesc.ColorAttachment.Image := ShadowMapImg;
  ViewDesc.TraceLabel := 'ShadowMapAttView';
  var ShadowMapAttView := TView.Create(ViewDesc);

  ViewDesc.Init;
  ViewDesc.Texture.Image := ShadowMapImg;
  ViewDesc.TraceLabel := 'ShadowMapTexView';
  TexView := TView.Create(ViewDesc);

  ViewDesc.Init;
  ViewDesc.DepthStencilAttachment.Image := ShadowDepthImg;
  ViewDesc.TraceLabel := 'ShadowDepthAttachment';
  var ShadowDepthAttView := TView.Create(ViewDesc);

  { Shadow render pass descriptor }
  { Clear the shadow map to (1,1,1,1) }
  Pass.Action.Colors[0].Init(TLoadAction.Clear, 1, 1, 1, 1);

  { Attachment views }
  Pass.Attachments.Colors[0] := ShadowMapAttView;
  Pass.Attachments.DepthStencil := ShadowDepthAttView;

  { A regular sampler with nearest filtering to sample the shadow map }
  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Nearest;
  SamplerDesc.MagFilter := TFilter.Nearest;
  SamplerDesc.WrapU := TWrap.ClampToEdge;
  SamplerDesc.WrapV := TWrap.ClampToEdge;
  SamplerDesc.TraceLabel := 'ShadowSampler';
  Sampler := TSampler.Create(SamplerDesc);

  { A pipeline object for the shadow pass }
  var PipDesc := TPipelineDesc.Create;

  { Need to provide stride, because the buffer's normal vector is skipped }
  PipDesc.Layout.Buffers[0].Stride := 6 * SizeOf(Single);

  PipDesc.Layout.Attrs[ATTR_SHADOW_POS].Format := TVertexFormat.Float3;
  PipDesc.Shader := TShader.Create(ShadowShaderDesc);
  PipDesc.IndexType := TIndexType.UInt16;

  { Render back-faces in shadow pass to prevent shadow acne on front-faces }
  PipDesc.CullMode := TCullMode.Front;
  PipDesc.SampleCount := 1;
  PipDesc.Colors[0].PixelFormat := TPixelFormat.Rgba8;
  PipDesc.Depth.PixelFormat := TPixelFormat.Depth;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.TraceLabel := 'ShadowPipeline';
  Pip := TPipeline.Create(PipDesc);

  { Resource bindings to render shadow scene }
  Bind.VertexBuffers[0] := AVBuf;
  Bind.IndexBuffer := AIBuf;
end;

{ TDisplay }

procedure TDisplay.Init(const AVBuf, AIBuf: TBuffer;
  const AShadowMapTexView: TView; const AShadowSampler: TSampler);
begin
  { Default pass action: clear to blue-ish }
  PassAction.Colors[0].Init(TLoadAction.Clear, 0.25, 0.5, 0.25, 1);

  { A pipeline object for the display pass }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Attrs[ATTR_DISPLAY_POS].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_DISPLAY_NORM].Format := TVertexFormat.Float3;
  PipDesc.Shader := TShader.Create(DisplayShaderDesc);
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.TraceLabel := 'DisplayPipeline';
  Pip := TPipeline.Create(PipDesc);

  { Resource bindings to render display scene }
  Bind.VertexBuffers[0] := AVBuf;
  Bind.IndexBuffer := AIBuf;
  Bind.Views[VIEW_SHADOW_MAP] := AShadowMapTexView;
  Bind.Samplers[SMP_SHADOW_SAMPLER] := AShadowSampler;
end;

{ TDebug }

procedure TDebug.Init(const AShadowMapTexView: TView);
begin
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(DEBUG_VERTICES);
  BufferDesc.TraceLabel := 'DebugVertices';
  var VBuf := TBuffer.Create(BufferDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Attrs[ATTR_DBG_POS].Format := TVertexFormat.Float2;
  PipDesc.Shader := TShader.Create(DbgShaderDesc);
  PipDesc.PrimitiveType := TPrimitiveType.TriangleStrip;
  PipDesc.TraceLabel := 'DebugPipeline';
  Pip := TPipeline.Create(PipDesc);

  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Nearest;
  SamplerDesc.MagFilter := TFilter.Nearest;
  SamplerDesc.WrapU := TWrap.ClampToEdge;
  SamplerDesc.WrapV := TWrap.ClampToEdge;
  SamplerDesc.TraceLabel := 'DebugSampler';
  var Sampler := TSampler.Create(SamplerDesc);

  Bind.VertexBuffers[0] := VBuf;
  Bind.Views[VIEW_DBG_TEX] := AShadowMapTexView;
  Bind.Samplers[SMP_DBG_SMP] := Sampler;
end;

end.

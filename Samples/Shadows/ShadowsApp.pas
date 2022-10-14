unit ShadowsApp;
{  Render to an offscreen rendertarget texture, and use this texture
   for rendering shadows to the screen. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  ShadowsShader;

const
  SCREEN_SAMPLE_COUNT = 4;

type
  TShadows = record
  public
    PassAction: TPassAction;
    Pass: TPass;
    Pip: TPipeline;
    Bind: TBindings;
    ColorImg: TImage;
    DepthImg: TImage;
    Shader: TShader;
  public
    procedure Init(const AVBuf, AIBuf: TBuffer);
    procedure Free;
  end;

type
  TDefault = record
  public
    PassAction: TPassAction;
    Pip: TPipeline;
    Bind: TBindings;
    Shader: TShader;
  public
    procedure Init(const AVBuf, AIBuf: TBuffer; const AImage: TImage);
    procedure Free;
  end;

type
  TShadowsApp = class(TSampleApp)
  private
    FShadows: TShadows;
    FDefault: TDefault;
    FVBuf: TBuffer;
    FIBuf: TBuffer;
    FRY: Single;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api;

const
  { cube vertex buffer with positions & normals }
  VERTICES: array [0..167] of Single = (
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

    -1.0,  0.0, -1.0,    0.0, 1.0, 0.0,   //PLANE GEOMETRY
    -1.0,  0.0,  1.0,    0.0, 1.0, 0.0,
     1.0,  0.0,  1.0,    0.0, 1.0, 0.0,
     1.0,  0.0, -1.0,    0.0, 1.0, 0.0);

const
  { Index buffer for the cube }
  INDICES: array [0..41] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20,
    26, 25, 24,  27, 26, 24);

{ TShadowsApp }

procedure TShadowsApp.Cleanup;
begin
  FShadows.Free;
  FDefault.Free;
  FVBuf.Free;
  FIBuf.Free;
  inherited;
end;

procedure TShadowsApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := SCREEN_SAMPLE_COUNT;
  AConfig.WindowTitle := 'Shadow Rendering';
end;

procedure TShadowsApp.Frame;
begin
  var T: Single := FrameDuration * 60;
  FRY := FRY + (0.2 * T);

  { Calculate matrices for shadow pass }
  var RYM, LightView, LightProj, Ortho, Proj, View, Scale, Translate: TMatrix4;
  RYM.InitRotationY(Radians(FRY));
  var LightDir := RYM * Vector4(50, 50, -50, 0);
  LightView.InitLookAtRH(Vector3(LightDir), Vector3(0, 0, 0), Vector3(0, 1, 0));

  { Configure a bias matrix for converting view-space coordinates into uv
    coordinates }
  LightProj.Init(
    0.5, 0.0, 0.0, 0,
    0.0, 0.5, 0.0, 0,
    0.0, 0.0, 0.5, 0,
    0.5, 0.5, 0.5, 1);
  Ortho.InitOrthoOffCenterRH(-4, 4, 4, -4, 0, 200);
  LightProj := LightProj * Ortho;
  var LightViewProj := LightProj * LightView;

  { Calculate matrices for camera pass }
  Proj.InitPerspectiveFovRH(Radians(60), FramebufferHeight / FramebufferWidth,
    0.01, 100, True);
  View.InitLookAtRH(Vector3(5, 5, 5), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  { Calculate transform matrices for plane and cube }
  Scale.InitScaling(5, 0, 5);
  Translate.InitTranslation(0, 1.5, 0);

  { Initialise fragment uniforms for light shader }
  var FSLightParams: TFSLightParams;
  FSLightParams.LightDir := Vector3(LightDir).Normalize;
  FSLightParams.ShadowMapSize.Init(2048, 2048);
  FSLightParams.EyePos.Init(5, 5, 5);

  { The shadow map pass, render the vertices into the depth image }
  TGfx.BeginPass(FShadows.Pass, FShadows.PassAction);
  TGfx.ApplyPipeline(FShadows.Pip);
  TGfx.ApplyBindings(FShadows.Bind);

  { Render the cube into the shadow map }
  var VSShadowParams: TVSShadowParams;
  VSShadowParams.Mvp := LightViewProj * Translate;
  TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_SHADOW_PARAMS,
    TRange.Create(VSShadowParams));
  TGfx.Draw(0, 36);
  TGfx.EndPass;

  { And the display-pass, rendering the scene, using the previously rendered
    shadow map as a texture }
  TGfx.BeginDefaultPass(FDefault.PassAction, FramebufferWidth, FramebufferHeight);
  TGfx.ApplyPipeline(FDefault.Pip);
  TGfx.ApplyBindings(FDefault.Bind);
  TGfx.ApplyUniforms(TShaderStage.FragmentShader, SLOT_FS_LIGHT_PARAMS,
    TRange.Create(FSLightParams));

  { Render the plane in the light pass }
  var VSLightParams: TVSLightParams;
  VSLightParams.Mvp := ViewProj * Scale;
  VSLightParams.LightMVP := LightViewProj * Scale;
  VSLightParams.Model := TMatrix4.Identity;
  VSLightParams.DiffColor.Init(0.5, 0.5, 0.5);
  TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_LIGHT_PARAMS,
    TRange.Create(VSLightParams));
  TGfx.Draw(36, 6, 1);

  { Render the cube in the light pass }
  VSLightParams.LightMVP := LightViewProj * Translate;
  VSLightParams.Model := Translate;
  VSLightParams.Mvp := ViewProj * Translate;
  VSLightParams.DiffColor.Init(1, 1, 1);
  TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_LIGHT_PARAMS,
    TRange.Create(VSLightParams));
  TGfx.Draw(0, 36, 1);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TShadowsApp.Init;
begin
  inherited;
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'CubeVertices';
  FVBuf := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.BufferType := TBufferType.IndexBuffer;
  BufferDesc.Data := TRange.Create(INDICES);
  BufferDesc.TraceLabel := 'CubeIndices';
  FIBuf := TBuffer.Create(BufferDesc);

  FShadows.Init(FVBuf, FIBuf);
  FDefault.Init(FVBuf, FIBuf, FShadows.ColorImg);
end;

{ TShadows }

procedure TShadows.Free;
begin
  Pass.Free;
  Pip.Free;
  ColorImg.Free;
  DepthImg.Free;
  Shader.Free;
end;

procedure TShadows.Init(const AVBuf, AIBuf: TBuffer);
begin
  { Shadow pass action: clear to white }
  PassAction.Colors[0].Init(TAction.Clear, 1, 1, 1, 1);

  { A render pass with one color- and one depth-attachment image  }
  var ImgDesc := TImageDesc.Create;
  ImgDesc.RenderTarget := True;
  ImgDesc.Width := 2048;
  ImgDesc.Height := 2048;
  ImgDesc.PixelFormat := TPixelFormat.Rgba8;
  ImgDesc.MinFilter := TFilter.Linear;
  ImgDesc.MagFilter := TFilter.Linear;
  ImgDesc.SampleCount := 1;
  ImgDesc.TraceLabel := 'ShadowMapColorImage';
  ColorImg := TImage.Create(ImgDesc);

  ImgDesc.PixelFormat := TPixelFormat.Depth;
  ImgDesc.TraceLabel := 'ShadowMapDepthImage';
  DepthImg := TImage.Create(ImgDesc);

  var PassDesc := TPassDesc.Create;
  PassDesc.ColorAttachments[0].Image := ColorImg;
  PassDesc.DepthStencilAttachment.Image := DepthImg;
  PassDesc.TraceLabel := 'ShadowMapPass';
  Pass := TPass.Create(PassDesc);

  Shader := TShader.Create(ShadowShaderDesc);

  var PipDesc := TPipelineDesc.Create;

  { Need to provide stride, because the buffer's normal vector is skipped }
  PipDesc.Layout.Buffers[0].Stride := 6 * SizeOf(Single);

  { But don't need to provide attr offsets, because pos and normal are
    continuous }
  PipDesc.Layout.Attrs[ATTR_SHADOWVS_POSITION].Format := TVertexFormat.Float3;
  PipDesc.Shader := Shader;
  PipDesc.IndexType := TIndexType.UInt16;

  { Cull front faces in the shadow map pass }
  PipDesc.CullMode := TCullMode.Front;
  PipDesc.SampleCount := 1;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.PixelFormat := TPixelFormat.Depth;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Colors[0].PixelFormat := TPixelFormat.Rgba8;
  PipDesc.TraceLabel := 'ShadowMapPipeline';
  Pip := TPipeline.Create(PipDesc);

  { The resource bindings for rendering the cube into the shadow map render
    target }
  Bind.VertexBuffers[0] := AVBuf;
  Bind.IndexBuffer := AIBuf;
end;

{ TDefault }

procedure TDefault.Free;
begin
  Pip.Free;
  Shader.Free;
end;

procedure TDefault.Init(const AVBuf, AIBuf: TBuffer; const AImage: TImage);
begin
  { Default pass action: clear to blue-ish }
  PassAction.Colors[0].Init(TAction.Clear, 0, 0.25, 1, 1);

  Shader := TShader.Create(ColorShaderDesc);

  var PipDesc := TPipelineDesc.Create;

  { Don't need to provide buffer stride or attr offsets, no gaps here }
  PipDesc.Layout.Attrs[ATTR_COLORVS_POSITION].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_COLORVS_NORMAL].Format := TVertexFormat.Float3;
  PipDesc.Shader := Shader;
  PipDesc.IndexType := TIndexType.UInt16;

  { Cull back faces when rendering to the screen }
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.TraceLabel := 'DefaultPipeline';
  Pip := TPipeline.Create(PipDesc);

  { Resource bindings to render the cube, using the shadow map render target as
    texture }
  Bind.VertexBuffers[0] := AVBuf;
  Bind.IndexBuffer := AIBuf;
  Bind.FragmentShaderImages[SLOT_SHADOWMAP] := AImage;
end;

end.

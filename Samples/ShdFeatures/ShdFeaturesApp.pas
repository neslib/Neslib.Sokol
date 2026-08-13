unit ShdFeaturesApp;
{ Demonstrates two sokol-shdc shader-compiler features:

  1. "Stamping out" different shader variations by compiling the same
     shader source with different combinations of preprocessor defines.
     (see the --defines and --module command line options of sokol-shdc)
  2. Query reflection information at runtime instead of using the
     "static" code-generated bind slot constants and uniformblock records
     (see the --reflection command line option of sokol-shdc)

  Together these features are used in this demo for a simple "shader variation
  system", where rendering features can be dynamically enabled and disabled
  with the shader variation system taking care of using the shader,
  pipeline object and uniform data for a specific combination of shader
  features.

  Shader variations can differ as follows:

  - what vertex attributes are used and their vertex-layout-slot
  - what uniform blocks are used, their bind slots and interior layout
  - what images are used and their bind slots

  Keep in mind that the shader variation system in this demo is just one way
  to implement such a feature-based material/shader system, and the demo
  takes some shortcuts which make the whole system less flexible for the
  sake of brevity. Also the code-generated shader-reflection functions
  aren't necessarily set in stone, and may change in the future. }

interface

uses
  Neslib.FastMath,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.GL,
  Neslib.Sokol.Fetch,
  Neslib.OzzAnim,
  Utils,
  Camera,
  OzzUtil,
  SampleApp,
  { Use the code-generated stamped out shader-variation units. Each unit
    represents one combination of shader-feature preprocessor defines }
  ShdFeaturesShader.None, // -
  ShdFeaturesShader.L,    // LIGHTING
  ShdFeaturesShader.M,    // MATERIAL
  ShdFeaturesShader.S,    // SKINNING
  ShdFeaturesShader.SL,   // SKINNING + LIGHTING
  ShdFeaturesShader.SM,   // SKINNING + MATERIAL
  ShdFeaturesShader.LM,   // LIGHTING + MATERIAL
  ShdFeaturesShader.SLM;  // SKINNING + LIGHTING + MATERIAL

type
  { Shader feature flags }
  TShdFeature = (Skinning, Lighting, Material);
  TShdFeatures = set of TShdFeature;

const
  { The max number of shader variations (3 bits => 8, one for each shader unit) }
  MAX_SHADER_VARIATIONS = 1 shl 3;

const
  { See TOzzVertex: Position, Normal, JointIndices, JointWeights }
  MAX_VERTEX_COMPONENTS = 4;

const
  MAX_UNIFORMBLOCK_SIZE = 256;

{ These are 'pointerized uniform-block records' filled at runtime from shader
  reflection information. If a pointer is nil, the uniform block item doesn't
  exist in this shader variation. Valid pointers point into the generic uniform
  upload buffers (TShdFeaturesApp.FVSParamsBuffer and .FPhongParamsBuffer). }

type
  TVSParamsPtr = record
  public
    Valid: Boolean;
    Slot: Integer;
    NumBytes: NativeInt;
    Mvp: PMatrix4;
    Model: PMatrix4;
    JointUV: PVector2;
    JointPixelWidth: PSingle;
  end;
  PVSParamsPtr = ^TVSParamsPtr;

type
  TPhongParamsPtr = record
  public
    Valid: Boolean;
    Slot: Integer;
    NumBytes: NativeInt;
    LightDir: PVector3;
    EyePos: PVector3;
    LightColor: PVector3;
    MatDiffuse: PVector3;
    MatSpecular: PVector3;
    MatSpecPower: PSingle;
  end;
  PPhongParamsPtr = ^TPhongParamsPtr;

type
  { A helper record to describe a dynamically looked up vertex component }
  TVertexComponent = record
  public
    Name: String;
    Format: TVertexFormat;
    Offset: Integer;
  public
    procedure Init(const AName: String; const AFormat: TVertexFormat;
      const AOffset: Integer);
  end;
  PVertexComponent = ^TVertexComponent;

type
  { A record describing a stamped out shader variation }
  TShaderVariation = record
  {$REGION 'Internal Declarations'}
  private
    function UniformPtr(const ABasePtr: PByte; const AExpectedType: TUniformType;
      const AUBName, AUName: String): Pointer;
  {$ENDREGION 'Internal Declarations'}
  public
    Valid: Boolean;

    { Shader and vertex layout differs between variations }
    Pip: TPipeline;

    { Bound images and bind slots may differ between variations }
    Bind: TBindings;

    { Pointerized uniform block records, filled from runtime reflection data.
      A shader variation may not use a uniform block at all, not use specific
      uniform block members, and the offsets of uniforms within their uniform
      block may differ }
    VSParams: TVSParamsPtr;
    PhongParams: TPhongParamsPtr;

    { Function pointers to code-generated runtime-reflection functions }
    ShaderDescFn: function: PNativeShaderDesc;
    AttrSlotFn: function(const AAttrName: String): Integer;
    TextureSlotFn: function(const ATexName: String): Integer;
    SamplerSlotFn: function(const ASmpName: String): Integer;
    UniformBlockSlotFn: function(const AUBName: String): Integer;
    UniformBlockSizeFn: function(const AUBName: String): NativeInt;
    UniformOffsetFn: function(const AUBName, AUName: String): Integer;
    UniformDescFn: function(const AUBName, AUName: String): TGlslShaderUniform;
  public
    function UniformPtrFloat(const ABasePtr: PByte; const AUBName,
      AUName: String): PSingle;
    function UniformPtrVec2(const ABasePtr: PByte; const AUBName,
      AUName: String): PVector2;
    function UniformPtrVec3(const ABasePtr: PByte; const AUBName,
      AUName: String): PVector3;
    function UniformPtrMat4(const ABasePtr: PByte; const AUBName,
      AUName: String): PMatrix4;

    function VertexLayout(const AComponents: PVertexComponent): TVertexLayoutState;
  end;
  PShaderVariation = ^TShaderVariation;

type
  TShdFeaturesApp = class(TSampleApp)
  private type
    TSkinning = record
    public
      Enabled: Boolean;
      Paused: Boolean;
      TimeFactor: Single;
      TimeSec: Double;
    end;
  private type
    TLight = record
    public
      Enabled: Boolean;
      DbgDraw: Boolean;
      Latitude: Single;
      Longitude: Single;
      Dir: TVector3; // Computed from Latitude/Longitude
      Intensity: Single;
      Color: TVector3;
    end;
  private type
    TMaterial = record
    public
      Enabled: Boolean;
      Diffuse: TVector3;
      Specular: TVector3;
      SpecPower: Single;
    end;
  private
    FPassAction: TPassAction;
    FCamera: TCamera;
    FOzz: TOzzInstance;
    FFrameTimeSec: Double;
    FSkinning: TSkinning;
    FLight: TLight;
    FMaterial: TMaterial;
    FVariations: array [0..MAX_SHADER_VARIATIONS - 1] of TShaderVariation;
    FVertexComponents: array [0..MAX_VERTEX_COMPONENTS - 1] of TVertexComponent;

    { Generic uniform data upload buffers }
    FVSParamsBuffer: array [0..MAX_UNIFORMBLOCK_SIZE - 1] of Byte;
    FPhongParamsBuffer: array [0..MAX_UNIFORMBLOCK_SIZE - 1] of Byte;

    { IO buffers for character data (we know the max file sizes upfront) }
    FSkeletonIOBuffer: array [0..(32 * 1024) - 1] of Byte;
    FAnimationIOBuffer: array [0..(96 * 1024) - 1] of Byte;
    FMeshIOBuffer: array [0..(3 * 1024 * 1024) - 1] of Byte;
  private
    procedure SkeletonDataLoaded(const AResponse: TFetchResponse);
    procedure AnimationDataLoaded(const AResponse: TFetchResponse);
    procedure MeshDataLoaded(const AResponse: TFetchResponse);
    procedure DrawLightDebug;
    procedure FillVSParams(var AVar: TShaderVariation);
    procedure FillPhongParams(var AVar: TShaderVariation);
  protected
    class function HasImGui: Boolean; override;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure DrawImGui; override;
  end;

implementation

uses
  System.Classes,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue,
  Neslib.Sokol.ImGui,
  Neslib.OzzAnim.Api,
  Neslib.ImGui;

{ TShdFeaturesApp }

procedure TShdFeaturesApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Shader Features';
end;

procedure TShdFeaturesApp.Init;
begin
  inherited;
  FSkinning.Enabled := True;
  FSkinning.TimeFactor := 1;

  FLight.Enabled := True;
  FLight.Latitude := 45;
  FLight.Longitude := -45;
  FLight.Intensity := 1;
  FLight.Color := Vector3(1, 1, 1);

  FMaterial.Enabled := True;
  FMaterial.Diffuse := Vector3(1, 0, 0);
  FMaterial.Specular := Vector3(1, 1, 1);
  FMaterial.SpecPower := 8;

  { Initialize the shader variation function table and the code-generated
    reflection-functions }
  var Features: TShdFeatures := [];
  var V: PShaderVariation := @FVariations[Byte(Features)];
  V.Valid := True;
  V.ShaderDescFn := NoneProgShaderDesc;
  V.AttrSlotFn := NoneProgAttrSlot;
  V.TextureSlotFn := NoneProgTextureSlot;
  V.SamplerSlotFn := NoneProgSamplerSlot;
  V.UniformBlockSlotFn := NoneProgUniformBlockSlot;
  V.UniformBlockSizeFn := NoneProgUniformBlockSize;
  V.UniformOffsetFn := NoneProgUniformOffset;
  V.UniformDescFn := NoneProgUniformDesc;

  Features := [TShdFeature.Skinning, TShdFeature.Lighting, TShdFeature.Material];
  V := @FVariations[Byte(Features)];
  V.Valid := True;
  V.ShaderDescFn := SlmProgShaderDesc;
  V.AttrSlotFn := SlmProgAttrSlot;
  V.TextureSlotFn := SlmProgTextureSlot;
  V.SamplerSlotFn := SlmProgSamplerSlot;
  V.UniformBlockSlotFn := SlmProgUniformBlockSlot;
  V.UniformBlockSizeFn := SlmProgUniformBlockSize;
  V.UniformOffsetFn := SlmProgUniformOffset;
  V.UniformDescFn := SlmProgUniformDesc;

  Features := [TShdFeature.Skinning, TShdFeature.Lighting];
  V := @FVariations[Byte(Features)];
  V.Valid := True;
  V.ShaderDescFn := SLProgShaderDesc;
  V.AttrSlotFn := SLProgAttrSlot;
  V.TextureSlotFn := SLProgTextureSlot;
  V.SamplerSlotFn := SLProgSamplerSlot;
  V.UniformBlockSlotFn := SLProgUniformBlockSlot;
  V.UniformBlockSizeFn := SLProgUniformBlockSize;
  V.UniformOffsetFn := SLProgUniformOffset;
  V.UniformDescFn := SLProgUniformDesc;

  Features := [TShdFeature.Skinning];
  V := @FVariations[Byte(Features)];
  V.Valid := True;
  V.ShaderDescFn := SProgShaderDesc;
  V.AttrSlotFn := SProgAttrSlot;
  V.TextureSlotFn := SProgTextureSlot;
  V.SamplerSlotFn := SProgSamplerSlot;
  V.UniformBlockSlotFn := SProgUniformBlockSlot;
  V.UniformBlockSizeFn := SProgUniformBlockSize;
  V.UniformOffsetFn := SProgUniformOffset;
  V.UniformDescFn := SProgUniformDesc;

  Features := [TShdFeature.Skinning, TShdFeature.Material];
  V := @FVariations[Byte(Features)];
  V.Valid := True;
  V.ShaderDescFn := SMProgShaderDesc;
  V.AttrSlotFn := SMProgAttrSlot;
  V.TextureSlotFn := SMProgTextureSlot;
  V.SamplerSlotFn := SMProgSamplerSlot;
  V.UniformBlockSlotFn := SMProgUniformBlockSlot;
  V.UniformBlockSizeFn := SMProgUniformBlockSize;
  V.UniformOffsetFn := SMProgUniformOffset;
  V.UniformDescFn := SMProgUniformDesc;

  Features := [TShdFeature.Lighting, TShdFeature.Material];
  V := @FVariations[Byte(Features)];
  V.Valid := True;
  V.ShaderDescFn := LMProgShaderDesc;
  V.AttrSlotFn := LMProgAttrSlot;
  V.TextureSlotFn := LMProgTextureSlot;
  V.SamplerSlotFn := LMProgSamplerSlot;
  V.UniformBlockSlotFn := LMProgUniformBlockSlot;
  V.UniformBlockSizeFn := LMProgUniformBlockSize;
  V.UniformOffsetFn := LMProgUniformOffset;
  V.UniformDescFn := LMProgUniformDesc;

  Features := [TShdFeature.Material];
  V := @FVariations[Byte(Features)];
  V.Valid := True;
  V.ShaderDescFn := MProgShaderDesc;
  V.AttrSlotFn := MProgAttrSlot;
  V.TextureSlotFn := MProgTextureSlot;
  V.SamplerSlotFn := MProgSamplerSlot;
  V.UniformBlockSlotFn := MProgUniformBlockSlot;
  V.UniformBlockSizeFn := MProgUniformBlockSize;
  V.UniformOffsetFn := MProgUniformOffset;
  V.UniformDescFn := MProgUniformDesc;

  Features := [TShdFeature.Lighting];
  V := @FVariations[Byte(Features)];
  V.Valid := True;
  V.ShaderDescFn := LProgShaderDesc;
  V.AttrSlotFn := LProgAttrSlot;
  V.TextureSlotFn := LProgTextureSlot;
  V.SamplerSlotFn := LProgSamplerSlot;
  V.UniformBlockSlotFn := LProgUniformBlockSlot;
  V.UniformBlockSizeFn := LProgUniformBlockSize;
  V.UniformOffsetFn := LProgUniformOffset;
  V.UniformDescFn := LProgUniformDesc;

  { A lookup table for looking up vertex attributes by name.
    The last parameter is the offset of the corresponding field in the
    TOzzVertex record. }
  FVertexComponents[0].Init('position', TVertexFormat.Float3, 0);
  FVertexComponents[1].Init('normal', TVertexFormat.Byte4N, 12);
  FVertexComponents[2].Init('jindices', TVertexFormat.UByte4N, 16);
  FVertexComponents[3].Init('jweights', TVertexFormat.UByte4N, 20);

  { Setup Neslib.Sokol.GL }
  var GLDesc := TGLDesc.Create;
  GLDesc.UseDelphiMemoryManager := True;
  GLDesc.Logger := GLDesc.DefaultLogger;
  sglSetup(GLDesc);

  { Setup Neslib.Sokol.Fetch }
  var FetchDesc := TFetchDesc.Create;
  FetchDesc.MaxRequests := 3;
  FetchDesc.NumChannels := 1;
  FetchDesc.NumLanes := 3;
  FetchDesc.Logger := FetchDesc.DefaultLogger;
  FetchDesc.BaseDirectory := 'Data/ozz';
  TFetch.Setup(FetchDesc);

  { Initialize clear color }
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0.0, 0.0, 0.0);

  { Initialize camera controller }
  var CamDesc := TCameraDesc.Create;
  CamDesc.MinDist := 2;
  CamDesc.MaxDist := 10;
  CamDesc.Center.Y := 1.1;
  CamDesc.Distance := 3;
  CamDesc.Latitude := 20;
  CamDesc.Longitude := 20;
  FCamera := TCamera.Create(CamDesc);

  { Setup ozz-utility wrapper and create a character instance }
  var OzzDesc := TOzzDesc.Create;
  OzzDesc.MaxPaletteJoints := 64;
  OzzDesc.MaxInstances := 1;
  TOzz.Setup(OzzDesc);

  FOzz := TOzzInstance.Create(0);

  { Initialize per-shader-variation resources }
  for var I := 0 to MAX_SHADER_VARIATIONS - 1 do
  begin
    V := @FVariations[I];
    if (not V.Valid) then
      Continue;

    { Check if the shader variation needs the joint texture }
    var TexSlot := V.TextureSlotFn('joint_tex');
    if (TexSlot >= 0) then
    begin
      var SmpSlot := V.SamplerSlotFn('smp');
      V.Bind.Views[TexSlot] := TOzz.JointTextureView;
      V.Bind.Samplers[SmpSlot] := TOzz.JointSampler;
    end;

    { Fill the pointerized uniform-block records. A uniform pointer will be nil
      if the shader variation doesn't use a specific uniform }
    if (V.UniformBlockSlotFn('vs_params') >= 0) then
    begin
      var P: PVSParamsPtr := @V.VSParams;
      var BasePtr: PByte := @FVSParamsBuffer;
      P.Valid := True;
      P.Slot := V.UniformBlockSlotFn('vs_params');
      P.NumBytes := V.UniformBlockSizeFn('vs_params');
      Assert(P.NumBytes <= MAX_UNIFORMBLOCK_SIZE);
      P.Mvp := V.UniformPtrMat4(BasePtr, 'vs_params', 'mvp');
      P.Model := V.UniformPtrMat4(BasePtr, 'vs_params', 'model');
      P.JointUV := V.UniformPtrVec2(BasePtr, 'vs_params', 'joint_uv');
      P.JointPixelWidth := V.UniformPtrFloat(BasePtr, 'vs_params', 'joint_pixel_width');
    end;

    if (V.UniformBlockSlotFn('phong_params') >= 0) then
    begin
      var P: PPhongParamsPtr := @V.PhongParams;
      var BasePtr: PByte := @FPhongParamsBuffer;
      P.Valid := True;
      P.Slot := V.UniformBlockSlotFn('phong_params');
      P.NumBytes := V.UniformBlockSizeFn('phong_params');
      Assert(P.NumBytes <= MAX_UNIFORMBLOCK_SIZE);
      P.LightDir := V.UniformPtrVec3(BasePtr, 'phong_params', 'light_dir');
      P.EyePos := V.UniformPtrVec3(BasePtr, 'phong_params', 'eye_pos');
      P.LightColor := V.UniformPtrVec3(BasePtr, 'phong_params', 'light_color');
      P.MatDiffuse := V.UniformPtrVec3(BasePtr, 'phong_params', 'mat_diffuse');
      P.MatSpecular := V.UniformPtrVec3(BasePtr, 'phong_params', 'mat_specular');
      P.MatSpecPower := V.UniformPtrFloat(BasePtr, 'phong_params', 'mat_spec_power');
    end;

    { Create shader and pipeline object. Note that the shader and vertex layout
      depend on the current shader variation }
    var PipDesc := TPipelineDesc.Create;
    PipDesc.Shader := TShader.Create(V.ShaderDescFn);
    PipDesc.Layout := V.VertexLayout(@FVertexComponents);
    PipDesc.IndexType := TIndexType.UInt16;
    PipDesc.FaceWinding := TFaceWinding.CounterClockWise;
    PipDesc.CullMode := TCullMode.Back;
    PipDesc.Depth.WriteEnabled := True;
    PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
    V.Pip := TPipeline.Create(PipDesc);
  end;

  { Start loading character data }
  var Req := TFetchRequest.Create('ozz_skin_skeleton.ozz', SkeletonDataLoaded,
    TFetchRange.Create(FSkeletonIOBuffer));
  Req.Send;

  Req := TFetchRequest.Create('ozz_skin_animation.ozz', AnimationDataLoaded,
    TFetchRange.Create(FAnimationIOBuffer));
  Req.Send;

  Req := TFetchRequest.Create('ozz_skin_mesh.ozz', MeshDataLoaded,
    TFetchRange.Create(FMeshIOBuffer));
  Req.Send;
end;

procedure TShdFeaturesApp.Frame;
begin
  TFetch.DoWork;

  var FBWidth := FramebufferWidth;
  var FBHeight := FramebufferHeight;

  { Move the viewport is slightly offcenter because the UI is on the left side }
  var VPX: Integer := Trunc(FBWidth * 0.3);
  var VPY := 0;
  var VPWidth: Integer := Trunc(FBWidth * 0.7);
  var VPHeight := FBHeight;

  FFrameTimeSec := FrameDuration;
  FCamera.Update(VPWidth, VPHeight);

  if (FLight.Enabled) then
  begin
    var Lat: Single := Radians(FLight.Latitude);
    var Lng: Single := Radians(FLight.Longitude);
    var SinLat, CosLat, SinLng, CosLng: Single;
    FastSinCos(Lat, SinLat, CosLat);
    FastSinCos(Lng, SinLng, CosLng);
    FLight.Dir := Vector3(CosLat * SinLng, SinLat, CosLat * CosLng);
    if (FLight.DbgDraw) then
      DrawLightDebug;
  end;

  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyViewport(VPX, VPY, VPWidth, VPHeight, True);

  if (FOzz.AllLoaded) then
  begin
    { Update character animation }
    if (FSkinning.Enabled) then
    begin
      if (not FSkinning.Paused) then
        FSkinning.TimeSec := FSkinning.TimeSec + (FFrameTimeSec * FSkinning.TimeFactor);

      FOzz.Update(FSkinning.TimeSec);
      TOzz.UpdateJointTexture;
    end;

    { Build flags/index of currently active shader features }
    var Features: TShdFeatures := [];
    if (FSkinning.Enabled) then
      Include(Features, TShdFeature.Skinning);
    if (FLight.Enabled) then
      Include(Features, TShdFeature.Lighting);
    if (FMaterial.Enabled) then
      Include(Features, TShdFeature.Material);
    Assert(Byte(Features) < MAX_SHADER_VARIATIONS);

    var V: PShaderVariation := @FVariations[Byte(Features)];
    Assert(V.Valid);

    TGfx.ApplyPipeline(V.Pip);
    TGfx.ApplyBindings(V.Bind);

    { Update uniform data as needed by the current shader variation }
    if (V.VSParams.Valid) then
    begin
      FillVSParams(V^);
      TGfx.ApplyUniforms(V.VSParams.Slot, TRange.Create(@FVSParamsBuffer, V.VSParams.NumBytes));
    end;

    if (V.PhongParams.Valid) then
    begin
      FillPhongParams(V^);
      TGfx.ApplyUniforms(V.PhongParams.Slot, TRange.Create(@FPhongParamsBuffer, V.PhongParams.NumBytes));
    end;

    TGfx.Draw(0, FOzz.NumTriangleIndices);
  end;

  sglDraw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TShdFeaturesApp.Cleanup;
begin
  inherited;
  FOzz.Free;
  TOzz.Shutdown;
  TFetch.Shutdown;
  sglShutdown;
  FCamera.Free;
end;

class function TShdFeaturesApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TShdFeaturesApp.AnimationDataLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
    FOzz.LoadAnimation(AResponse.Data.Ptr, AResponse.Data.Size)
  else if (AResponse.Failed) then
    FOzz.SetLoadFailed;
end;

procedure TShdFeaturesApp.MeshDataLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
  begin
    FOzz.LoadMesh(AResponse.Data.Ptr, AResponse.Data.Size);
    for var I := 0 to MAX_SHADER_VARIATIONS - 1 do
    begin
      if (FVariations[I].Valid) then
      begin
        FVariations[I].Bind.VertexBuffers[0] := FOzz.VertexBuffer;
        FVariations[I].Bind.IndexBuffer := FOzz.IndexBuffer;
      end;
    end;
  end
  else if (AResponse.Failed) then
    FOzz.SetLoadFailed;
end;

procedure TShdFeaturesApp.SkeletonDataLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
    FOzz.LoadSkeleton(AResponse.Data.Ptr, AResponse.Data.Size)
  else if (AResponse.Failed) then
    FOzz.SetLoadFailed;
end;

procedure TShdFeaturesApp.FillPhongParams(var AVar: TShaderVariation);
begin
  var P: PPhongParamsPtr := @AVar.PhongParams;
  if (P.LightDir <> nil) then
    P.LightDir^ := FLight.Dir;

  if (P.EyePos <> nil) then
    P.EyePos^ := FCamera.EyePos;

  if (P.LightColor <> nil) then
    P.LightColor^ := FLight.Color * FLight.Intensity;

  if (P.MatDiffuse <> nil) then
    P.MatDiffuse^ := FMaterial.Diffuse;

  if (P.MatSpecular <> nil) then
    P.MatSpecular^ := FMaterial.Specular;

  if (P.MatSpecPower <> nil) then
    P.MatSpecPower^ := FMaterial.SpecPower;
end;

procedure TShdFeaturesApp.FillVSParams(var AVar: TShaderVariation);
begin
  var P: PVSParamsPtr := @AVar.VSParams;
  if (P.Mvp <> nil) then
    P.Mvp^ := FCamera.ViewProj;

  if (P.Model <> nil) then
    P.Model^ := TMatrix4.Identity;

  if (P.JointUV <> nil) then
    P.JointUV^ := FOzz.JointTextureCoord;

  if (P.JointPixelWidth <> nil) then
    P.JointPixelWidth^ := TOzz.JointTexturePixelWidth;
end;

procedure TShdFeaturesApp.DrawImGui;
const
  GREEN = $FF00FF00;
begin
  ImGui.SetNextWindowPos(Vector2(20, 30), TImGuiCond.Once);
  ImGui.SetNextWindowSize(Vector2(220, 150), TImGuiCond.Once);
  if (ImGui.Begin('Controls', nil, [TImGuiWindowFlag.AlwaysAutoResize])) then
  begin
    if (FOzz.LoadFailed) then
      ImGui.Text('Failed loading character data!')
    else
    begin
      ImGui.Text('Camera Controls:');
      ImGui.Text('  LMB + Drag:  Look');
      ImGui.Text('  Mouse wheel: Zoom');

      ImGui.PushID('camera');
      ImGui.SliderFloat('Distance', @FCamera.Distance, FCamera.MinDist, FCamera.MaxDist, '%.1f');
      ImGui.SliderFloat('Latitude', @FCamera.Latitude, FCamera.MinLat, FCamera.MaxLat, '%.1f');
      ImGui.SliderFloat('Longitude', @FCamera.Longitude, 0, 360, '%.1f');
      ImGui.PopID;

      ImGui.Separator;
      ImGui.PushStyleColor(TImGuiCol.CheckMark, GREEN);
      ImGui.Checkbox('Enable Skinning', @FSkinning.Enabled);
      ImGui.PopStyleColor;
      if (FSkinning.Enabled) then
      begin
        ImGui.Separator;
        ImGui.Checkbox('Paused', @FSkinning.Paused);
        ImGui.SliderFloat('Time Factor', @FSkinning.TimeFactor, 0, 10, '%.1f');
      end;

      ImGui.Separator;
      ImGui.PushStyleColor(TImGuiCol.CheckMark, GREEN);
      ImGui.Checkbox('Enable Lighting', @FLight.Enabled);
      ImGui.PopStyleColor;
      if (FLight.Enabled) then
      begin
        ImGui.PushID('light');
        ImGui.Separator;
        ImGui.Checkbox('Draw Light Vector', @FLight.DbgDraw);
        ImGui.SliderFloat('Latitude', @FLight.Latitude, -85, 85, '%.1f');
        ImGui.SliderFloat('Longitude', @FLight.Longitude, 0, 360, '%.1f');
        ImGui.SliderFloat('Intensity', @FLight.Intensity, 0, 10, '%.1f');
        ImGui.ColorEdit3('Color', @FLight.Color);
        ImGui.PopID;
      end;

      ImGui.Separator;
      ImGui.PushStyleColor(TImGuiCol.CheckMark, GREEN);
      ImGui.Checkbox('Enable Material', @FMaterial.Enabled);
      ImGui.PopStyleColor;
      if (FMaterial.Enabled) then
      begin
        ImGui.PushID('material');
        ImGui.Separator;
        ImGui.ColorEdit3('Diffuse', @FMaterial.Diffuse);
        ImGui.ColorEdit3('Specular', @FMaterial.Specular);
        ImGui.SliderFloat('Spec Pwr', @FMaterial.SpecPower, 1, 64, '%.1f');
        ImGui.PopID;
      end;
    end;
  end;
  ImGui.End;
end;

procedure TShdFeaturesApp.DrawLightDebug;
{ Helper function to draw the light vector }
const
  L = 1;
  Y = 1;
begin
  sglDefaults;
  sglMatrixModeProjection;
  sglLoadMatrix(FCamera.Proj);
  sglMatrixModeModelview;
  sglLoadMatrix(FCamera.View);
  sglC3F(FLight.Color.R, FLight.Color.G, FLight.Color.B);
  sglBeginLines;
  sglV3F(0, Y, 0);
  sglV3F(FLight.Dir.X * L, Y + (FLight.Dir.Y * L), FLight.Dir.Z * L);
  sglEnd;
end;

{ TVertexComponent }

procedure TVertexComponent.Init(const AName: String;
  const AFormat: TVertexFormat; const AOffset: Integer);
begin
  Name := AName;
  Format := AFormat;
  Offset := AOffset;
end;

{ TShaderVariation }

function TShaderVariation.UniformPtr(const ABasePtr: PByte;
  const AExpectedType: TUniformType; const AUBName, AUName: String): Pointer;
{ Type-safe helper function to dynamically resolve a pointer to a uniform-block
  item. Returns nil if the item doesn't exist. Asserts if the type doesn't match }
begin
  Assert(Valid);
  Assert(Assigned(ABasePtr));
  var Offset := UniformOffsetFn(AUBName, AUName);
  if (Offset < 0) then
    Exit(nil);

  Assert(UniformDescFn(AUBName, AUName).UniformType = AExpectedType);
  Result := ABasePtr + Offset;
end;

function TShaderVariation.UniformPtrFloat(const ABasePtr: PByte; const AUBName,
  AUName: String): PSingle;
begin
  Result := UniformPtr(ABasePtr, TUniformType.Float, AUBName, AUName);
end;

function TShaderVariation.UniformPtrVec2(const ABasePtr: PByte; const AUBName,
  AUName: String): PVector2;
begin
  Result := UniformPtr(ABasePtr, TUniformType.Float2, AUBName, AUName);
end;

function TShaderVariation.UniformPtrVec3(const ABasePtr: PByte; const AUBName,
  AUName: String): PVector3;
begin
  Result := UniformPtr(ABasePtr, TUniformType.Float3, AUBName, AUName);
end;

function TShaderVariation.UniformPtrMat4(const ABasePtr: PByte; const AUBName,
  AUName: String): PMatrix4;
begin
  Result := UniformPtr(ABasePtr, TUniformType.Mat4, AUBName, AUName);
end;

function TShaderVariation.VertexLayout(const AComponents: PVertexComponent): TVertexLayoutState;
{ Helper function to build a matching vertex layout for a shader variation }
begin
  Assert(Valid);
  FillChar(Result, SizeOf(Result), 0);

  { Buffer stride must be provided, because the vertex layout may have gaps }
  Result.Buffers[0].Stride := SizeOf(TOzzVertex);

  { Populate the vertex attribute description depending on what vertex
    attributes the shader variation requires }
  var Comp := AComponents;
  for var I := 0 to MAX_VERTEX_COMPONENTS - 1 do
  begin
    if (Comp.Name <> '') then
    begin
      var Slot := AttrSlotFn(Comp.Name);
      if (Slot >= 0) then
      begin
        Result.Attrs[Slot].Format := Comp.Format;
        Result.Attrs[Slot].Offset := Comp.Offset;
      end;
    end;
    Inc(Comp);
  end;
end;

end.

unit glTFApp;
{ A simple(!) GLTF viewer. glTF + BasisU + App + Gfx + Fetch.
  Doesn't support all GLTF features.
  https://github.com/jkuhlmann/cgltf }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Fetch,
  Neslib.Sokol.BasisU,
  Neslib.Sokol.DebugText,
  Neslib.Sokol.glTF,
  Neslib.FastMath,
  SampleApp,
  Camera,
  glTFShader;

const
  FILENAME = 'DamagedHelmet.gltf';

const
  SCENE_INVALID_INDEX  = -1;
  SCENE_MAX_BUFFERS    = 16;
  SCENE_MAX_IMAGES     = 16;
  SCENE_MAX_MATERIALS  = 16;
  SCENE_MAX_PIPELINES  = 16;
  SCENE_MAX_PRIMITIVES = 16; // aka submesh
  SCENE_MAX_MESHES     = 16;
  SCENE_MAX_NODES      = 16;

const
  // To configure file downloads
  FETCH_NUM_CHANNELS = 1;
  FETCH_NUM_LANES    = 4;
  MAX_FILE_SIZE      = 1024 * 1024;

type
  { Per-material texture indices into scene.images for metallic material }
  TMetallicImages = record
  public
    BaseColor: Integer;
    MetallicRoughness: Integer;
    Normal: Integer;
    Occlusion: Integer;
    Emissive: Integer;
  end;

type
  { Per-material texture indices into scene.images for specular material }
  TSpecularImages = record
  public
    Diffuse: Integer;
    SpecularGlossiness: Integer;
    Normal: Integer;
    Occlusion: Integer;
    Emissive: Integer;
  end;

type
  { Fragment-shader-params and textures for metallic material }
  TMetallicMaterial = record
  public
    FragmentShaderParams: TMetallicParams;
    Images: TMetallicImages;
  end;
  PMetallicMaterial = ^TMetallicMaterial;

type
  { Everything grouped into a material struct }
  TMaterial = record
  public
    IsMetallic: Boolean;
    Metallic: TMetallicMaterial;
  end;
  PMaterial = ^TMaterial;

type
  { Helper record to map Neslib.Sokol.Gfx buffer bindslots to Scene.Buffers
    indices }
  TVertexBufferMapping = record
  public
    Count: Integer;
    Buffer: array [0..MAX_SHADERSTAGE_BUFFERS - 1] of Integer;
  end;

type
  { A 'primitive' (aka submesh) contains everything needed to issue a draw
    call }
  TPrimitive = record
  public
    Pipeline: Integer;    // index into Scene.Pipelines array
    Material: Integer;    // index into Scene.Materials array
    VertexBuffers: TVertexBufferMapping; // indices into bufferview array by vbuf bind slot
    IndexBuffer: Integer; // index into bufferview array for index buffer, or SCENE_INVALID_INDEX
    BaseElement: Integer; // index of first index or vertex to draw
    NumElements: Integer; // number of vertices or indices to draw
  end;
  PPrimitive = ^TPrimitive;

type
  { A mesh is just a group of primitives (aka submeshes) }
  TMesh = record
  public
    FirstPrimitive: Integer; // index into Scene.Primitives
    NumPrimitives: Integer;
  end;
  PMesh = ^TMesh;

type
  { A node associates a transform with an mesh.
    Currently, the transform matrices are 'baked' upfront into world space }
  TNode = record
  public
    Mesh: Integer; // index into Scene.Meshes
    Transform: TMatrix4;
  end;
  PNode = ^TNode;

type
  { The complete scene }
  TScene = record
  public
    NumBuffers: Integer;
    NumImages: Integer;
    NumPipelines: Integer;
    NumMaterials: Integer;
    NumPrimitives: Integer;
    NumMeshes: Integer;
    NumNodes: Integer;
    Buffers: array [0..SCENE_MAX_BUFFERS - 1] of TBuffer;
    Images: array [0..SCENE_MAX_IMAGES - 1] of TImage;
    Pipelines: array [0..SCENE_MAX_PIPELINES - 1] of TPipeline;
    Materials: array [0..SCENE_MAX_MATERIALS - 1] of TMaterial;
    Primitives: array [0..SCENE_MAX_PRIMITIVES - 1] of TPrimitive;
    Meshes: array [0..SCENE_MAX_MESHES - 1] of TMesh;
    Nodes: array [0..SCENE_MAX_NODES - 1] of TNode;
  public
    procedure Free;
  end;

{ Resource creation helper params. These are stored until the async-loaded
  resources (buffers and images) have been loaded }

type
  TBufferCreationParams = record
  public
    BufferType: TBufferType;
    Offset: Integer;
    Size: Integer;
    glTFBufferIndex: Integer;
  end;
  PBufferCreationParams = ^TBufferCreationParams;

type
  TImageCreationParams = record
  public
    Minfilter: TFilter;
    Magfilter: TFilter;
    WrapS: TWrap;
    WrapT: TWrap;
    gltfImageIndex: Integer;
  end;
  PImageCreationParams = ^TImageCreationParams;

type
  { Pipeline cache helper record to avoid duplicate pipeline-state-objects }
  TPipelineCacheParams = record
  public
    Layout: TLayoutDesc;
    PrimitiveType: TPrimitiveType;
    IndexType: TIndexType;
    Alpha: Boolean;
  public
    class operator Equal(const ALeft, ARight: TPipelineCacheParams): Boolean; static;
  end;

{ Top-level state records }

type
  TPassActions = record
  public
    OK: TPassAction;
    Failed: TPassAction;
  public
    procedure Init;
  end;

type
  TShaders = record
  public
    Metallic: TShader;
    Specular: TShader;
  public
    procedure Init;
    procedure Free;
  end;

type
  TCreationParams = record
  public
    Buffers: array [0..SCENE_MAX_BUFFERS - 1] of TBufferCreationParams;
    Images: array [0..SCENE_MAX_IMAGES - 1] of TImageCreationParams;
  end;

type
  TPipCache = record
  public
    Items: array [0..SCENE_MAX_PIPELINES - 1] of TPipelineCacheParams;
  end;

type
  TPlaceholders = record
  public
    White: TImage;
    Normal: TImage;
    Black: TImage;
  public
    procedure Init;
    procedure Free;
  end;

type
  TglTFApp = class(TSampleApp)
  private
    FFetchBuffers: array [0..FETCH_NUM_CHANNELS - 1, 0..FETCH_NUM_LANES - 1, 0..MAX_FILE_SIZE - 1] of Byte;
    FFailed: Boolean;
    FPassActions: TPassActions;
    FShaders: TShaders;
    FScene: TScene;
    FCamera: TCamera;
    FPointLight: TLightParams; // Code generated from shader
    FRootTransform: TMatrix4;
    FRX: Single;
    FCreationParams: TCreationParams;
    FPipCache: TPipCache;
    FPlaceholders: TPlaceholders;
  private
    procedure FetchCallback(const AResponse: TFetchResponse);
    procedure FetchBufferCallback(const AResponse: TFetchResponse);
    procedure FetchImageCallback(const AResponse: TFetchResponse);
    procedure glTFParse(const ABuffer: Pointer; const ASize: Int64);
    procedure glTFParseBuffers(const AData: PglTFData);
    procedure glTFParseImages(const AData: PglTFData);
    procedure glTFParseMaterials(const AData: PglTFData);
    procedure glTFParseMeshes(const AData: PglTFData);
    procedure glTFParseNodes(const AData: PglTFData);
    procedure CreateGfxBuffersForGlTFBuffer(const AGlTFBufferIndex: Integer;
      const AData: TRange);
    procedure CreateGfxImagesForGlTFImage(const AGlTFImageIndex: Integer;
      const AData: TRange);
    function CreateVertexBufferMappingForGlTFPrimitive(const AData: PglTFData;
      const APrim: PglTFPrimitive): TVertexBufferMapping;
    function CreateGfxPipelineForGlTFPrimitive(const AData: PglTFData;
      const APrim: PglTFPrimitive; var AVBufMap: TVertexBufferMapping): Integer;
    function CreateGfxLayoutForGlTFPrimitive(const AData: PglTFData;
      const APrim: PglTFPrimitive; const AVBufMap: TVertexBufferMapping): TLayoutDesc;
    procedure UpdateScene;
    function VSParamsForNode(const ANodeIndex: Integer): TVSParams;
  private
    class function AttrTypeToVSInputSlot(const AAttrType: TglTFAttributeType): Integer; static;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api,
  Neslib.Cgltf.Api;

{ TScene }

procedure TScene.Free;
begin
  var I: Integer;

  for I := 0 to NumBuffers - 1 do
    Buffers[I].Free;

  for I := 0 to NumImages - 1 do
    Images[I].Free;

  for I := 0 to NumPipelines - 1 do
    Pipelines[I].Free;
end;

{ TPipelineCacheParams }

class operator TPipelineCacheParams.Equal(const ALeft,
  ARight: TPipelineCacheParams): Boolean;
begin
  if (ALeft.PrimitiveType <> ARight.PrimitiveType) then
    Exit(False);

  if (ALeft.Alpha <> ARight.Alpha) then
    Exit(False);

  if (ALeft.IndexType <> ARight.IndexType) then
    Exit(False);

  for var I := 0 to MAX_VERTEX_ATTRIBUTES - 1 do
  begin
    var A0 := PVertexAttrDesc(@ALeft.Layout.Attrs[I]);
    var A1 := PVertexAttrDesc(@ARight.Layout.Attrs[I]);
    if (A0.BufferIndex <> A1.BufferIndex)
      or (A0.Offset <> A1.Offset)
      or (A0.Format <> A1.Format)
    then
      Exit(False);
  end;

  Result := True;
end;

{ TPassActions }

procedure TPassActions.Init;
begin
  OK.Colors[0].Init(TAction.Clear, 0, 0.569, 0.918, 1);
  Failed.Colors[0].Init(TAction.Clear, 1, 0, 0, 1);
end;

{ TShaders }

procedure TShaders.Free;
begin
  Metallic.Free;
end;

procedure TShaders.Init;
begin
  Metallic := TShader.Create(gltfMetallicShaderDesc);
end;

{ TPlaceholders }

procedure TPlaceholders.Free;
begin
  Normal.Free;
  Black.Free;
  White.Free;
end;

procedure TPlaceholders.Init;
var
  Pixels: array [0..63] of Cardinal;
begin
  FillChar(Pixels, SizeOf(Pixels), $FF);
  var Desc := TImageDesc.Create;
  Desc.Width := 8;
  Desc.Height := 8;
  Desc.PixelFormat := TPixelFormat.Rgba8;
  Desc.Data.SubImages[0] := TRange.Create(Pixels);
  White := TImage.Create(Desc);

  for var I := 0 to 63 do
    Pixels[I] := $FF000000;
  Black := TImage.Create(Desc);

  for var I := 0 to 63 do
    Pixels[I] := $FF0000FF;
  Normal := TImage.Create(Desc);
end;

{ TglTFApp }

class function TglTFApp.AttrTypeToVSInputSlot(
  const AAttrType: TglTFAttributeType): Integer;
begin
  case AAttrType of
    TglTFAttributeType.Position:
      Result := ATTR_VS_POSITION;

    TglTFAttributeType.Normal:
      Result := ATTR_VS_NORMAL;

    TglTFAttributeType.TexCoord:
      Result := ATTR_VS_TEXCOORD;
  else
    Result := SCENE_INVALID_INDEX;
  end;
end;

procedure TglTFApp.Cleanup;
begin
  inherited;
  FCamera.Free;
  FScene.Free;
  FPlaceholders.Free;
  FShaders.Free;
  TFetch.Shutdown;
  TDbgText.Shutdown;
  TBasisU.Shutdown;
end;

procedure TglTFApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'glTF Viewer';
end;

procedure TglTFApp.CreateGfxBuffersForGlTFBuffer(
  const AGlTFBufferIndex: Integer; const AData: TRange);
{ Create the Sokol Gfx buffer objects associated with a glTF buffer view }
begin
  for var I := 0 to FScene.NumBuffers - 1 do
  begin
    var P := PBufferCreationParams(@FCreationParams.Buffers[I]);
    if (P.glTFBufferIndex = AGlTFBufferIndex) then
    begin
      Assert((P.Offset + P.Size) <= NativeInt(AData.Size));
      var BufferDesc := TBufferDesc.Create;
      BufferDesc.BufferType := P.BufferType;
      BufferDesc.Data := TRange.Create(PByte(AData.Data) + P.Offset, P.Size);
      FScene.Buffers[I].Init(BufferDesc);
    end;
  end;
end;

procedure TglTFApp.CreateGfxImagesForGlTFImage(const AGlTFImageIndex: Integer;
  const AData: TRange);
{ Create the Sokol Gfx image objects associated with a glTF image }
begin
  for var I := 0 to FScene.NumImages - 1 do
  begin
    var P := PImageCreationParams(@FCreationParams.Images[I]);
    if (P.gltfImageIndex = AGlTFImageIndex) then
      FScene.Images[I] := TBasisU.CreateImage(AData);
  end;
end;

function TglTFApp.CreateGfxLayoutForGlTFPrimitive(const AData: PglTFData;
  const APrim: PglTFPrimitive; const AVBufMap: TVertexBufferMapping): TLayoutDesc;
begin
  Assert(APrim.AttributeCount <= MAX_VERTEX_ATTRIBUTES);
  Result := TLayoutDesc.Create;
  for var AttrIndex := 0 to APrim.AttributeCount - 1 do
  begin
    var Attr := APrim.Attributes[AttrIndex];
    var AttrSlot := AttrTypeToVSInputSlot(Attr.AttrType);
    if (AttrSlot <> SCENE_INVALID_INDEX) then
      Result.Attrs[AttrSlot].Format := Attr.Data.GfxVertexFormat;

    var BufferViewIndex := AData.GetBufferViewIndex(Attr.Data.BufferView);
    for var VBSlot := 0 to AVBufMap.Count - 1 do
    begin
      if (AVBufMap.Buffer[VBSlot] = BufferViewIndex) then
        Result.Attrs[AttrSlot].BufferIndex := VBSlot;
    end;
  end;
end;

function TglTFApp.CreateGfxPipelineForGlTFPrimitive(const AData: PglTFData;
  const APrim: PglTFPrimitive; var AVBufMap: TVertexBufferMapping): Integer;
{ Create a unique Sokol Gfx pipeline object for glTF primitive (aka submesh),
  maintains a cache of shared, unique pipeline objects. Returns an index
  into Scene.Pipelines }
begin
  var PipParams: TPipelineCacheParams;
  PipParams.Layout := CreateGfxLayoutForGlTFPrimitive(AData, APrim, AVBufMap);
  PipParams.PrimitiveType := APrim.GfxPrimitiveType;
  PipParams.IndexType := APrim.GfxIndexType;
  PipParams.Alpha := (APrim.Material.AlphaMode <> TglTFAlphaMode.Opaque);

  var I := 0;
  while (I < FScene.NumPipelines) do
  begin
    if (FPipCache.Items[I] = PipParams) then
    begin
      { An indentical pipeline already exists, reuse this }
      Assert(FScene.Pipelines[I].Id <> INVALID_ID);
      Exit(I);
    end;
    Inc(I);
  end;

  if (I = FScene.NumPipelines) and (FScene.NumPipelines < SCENE_MAX_PIPELINES) then
  begin
    FPipCache.Items[I] := PipParams;
    var IsMetallic := APrim.Material.HasPbrMetallicRoughness;

    var PipDesc := TPipelineDesc.Create;
    PipDesc.Layout := PipParams.Layout;

    if (IsMetallic) then
      PipDesc.Shader := FShaders.Metallic
    else
      PipDesc.Shader := FShaders.Specular;

    PipDesc.PrimitiveType := PipParams.PrimitiveType;
    PipDesc.IndexType := PipParams.IndexType;
    PipDesc.CullMode := TCullMode.Back;
    PipDesc.FaceWinding := TFaceWinding.CounterClockWise;
    PipDesc.Depth.WriteEnabled := not PipParams.Alpha;
    PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;

    if (PipParams.Alpha) then
    begin
      PipDesc.Colors[0].WriteMask := TColorMask.Rgb;
      PipDesc.Colors[0].Blend.Enabled := True;
      PipDesc.Colors[0].Blend.SrcFactorRgb := TBlendFactor.SrcAlpha;
      PipDesc.Colors[0].Blend.DstFactorRgb := TBlendFactor.OneMinusSrcAlpha;
    end;

    FScene.Pipelines[I] := TPipeline.Create(PipDesc);
    Inc(FScene.NumPipelines);
  end;
  Assert(FScene.NumPipelines <= SCENE_MAX_PIPELINES);
  Result := I;
end;

function TglTFApp.CreateVertexBufferMappingForGlTFPrimitive(
  const AData: PglTFData; const APrim: PglTFPrimitive): TVertexBufferMapping;
{ Creates a vertex buffer bind slot mapping for a specific glTF primitive }
begin
  FillChar(Result, SizeOf(Result), 0);
  for var I := 0 to MAX_SHADERSTAGE_BUFFERS - 1 do
    Result.Buffer[I] := SCENE_INVALID_INDEX;

  for var AttrIndex := 0 to APrim.AttributeCount - 1 do
  begin
    var Attr := APrim.Attributes[AttrIndex];
    var Acc := Attr.Data;
    var BufferViewIndex := AData.GetBufferViewIndex(Acc.BufferView);
    var I := 0;
    while (I < Result.Count) do
    begin
      if (Result.Buffer[I] = BufferViewIndex) then
        Break;
      Inc(I);
    end;

    if (I = Result.Count) and (Result.Count < MAX_SHADERSTAGE_BUFFERS) then
    begin
      Result.Buffer[Result.Count] := BufferViewIndex;
      Inc(Result.Count);
    end;

    Assert(Result.Count <= MAX_SHADERSTAGE_BUFFERS);
  end;
end;

procedure TglTFApp.FetchCallback(const AResponse: TFetchResponse);
{ Load-callback for the glTF base file }
begin
  if (AResponse.Dispatched) then
    { Bind buffer to load file into }
    AResponse.Handle.BindBuffer(@FFetchBuffers[AResponse.Channel, AResponse.Lane], MAX_FILE_SIZE)
  else if (AResponse.Fetched) then
    { File has been loaded. Parse as glTF }
    glTFParse(AResponse.BufferPtr, AResponse.FetchedSize);

  if (AResponse.Finished) then
    if (AResponse.Failed) then
      FFailed := True;
end;

procedure TglTFApp.FetchImageCallback(const AResponse: TFetchResponse);
{ Load-callback for glTF image files }
begin
  if (AResponse.Dispatched) then
    { Bind buffer to load file into }
    AResponse.Handle.BindBuffer(@FFetchBuffers[AResponse.Channel, AResponse.Lane], MAX_FILE_SIZE)
  else if (AResponse.Fetched) then
  begin
    { File has been loaded. }
    var UserData: PNativeInt := AResponse.UserData;
    var glTFImageIndex := UserData^;
    CreateGfxImagesForGlTFImage(glTFImageIndex,
      TRange.Create(AResponse.BufferPtr, AResponse.FetchedSize));
  end;

  if (AResponse.Finished) then
    if (AResponse.Failed) then
      FFailed := True;
end;

procedure TglTFApp.FetchBufferCallback(const AResponse: TFetchResponse);
{ Load-callback for glTF buffer files }
begin
  if (AResponse.Dispatched) then
    { Bind buffer to load file into }
    AResponse.Handle.BindBuffer(@FFetchBuffers[AResponse.Channel, AResponse.Lane], MAX_FILE_SIZE)
  else if (AResponse.Fetched) then
  begin
    { File has been loaded. }
    var UserData: PNativeInt := AResponse.UserData;
    var glTFBufferIndex := UserData^;
    CreateGfxBuffersForGlTFBuffer(glTFBufferIndex,
      TRange.Create(AResponse.BufferPtr, AResponse.FetchedSize));
  end;

  if (AResponse.Finished) then
    if (AResponse.Failed) then
      FFailed := True;
end;

procedure TglTFApp.Frame;
begin
  { Pump the Neslib.Sokol.Fetch message queue }
  TFetch.DoWork;

  var FBWidth := FramebufferWidth;
  var FBHeight := FramebufferHeight;

  { Print help text }
  TDbgText.Canvas(FBWidth * 0.5, FBHeight * 0.5);
  TDbgText.Color($FFFFFFFF);
  TDbgText.Origin(1, 2);
  {$IF Defined(IOS) or Defined(ANDROID)}
  TDbgText.WriteAnsiLn('Drag:  rotate');
  TDbgText.WriteAnsiLn('Pinch: zoom');
  {$ELSE}
  TDbgText.WriteAnsiLn('LMB + drag:  rotate');
  TDbgText.WriteAnsiLn('mouse wheel: zoom');
  {$ENDIF}

  UpdateScene;
  FCamera.Update(FBWidth, FBHeight);

  { Render the scene }
  if (FFailed) then
  begin
    TGfx.BeginDefaultPass(FPassActions.Failed, FBWidth, FBHeight);
    DebugFrame;
    TGfx.EndPass;
    TGfx.Commit;
    Exit;
  end;

  TGfx.BeginDefaultPass(FPassActions.OK, FBWidth, FBHeight);
  for var NodeIndex := 0 to FScene.NumNodes - 1 do
  begin
    var Node := PNode(@FScene.Nodes[NodeIndex]);
    var VSParams := VSParamsForNode(NodeIndex);
    var Mesh := PMesh(@FScene.Meshes[Node.Mesh]);

    for var I := 0 to Mesh.NumPrimitives - 1 do
    begin
      var Prim := PPrimitive(@FScene.Primitives[I + Mesh.FirstPrimitive]);
      var Mat := PMaterial(@FScene.Materials[Prim.Material]);
      TGfx.ApplyPipeline(FScene.Pipelines[Prim.Pipeline]);
      var Bind := TBindings.Create;

      for var VBSlot := 0 to Prim.VertexBuffers.Count - 1 do
        Bind.VertexBuffers[VBSlot] := FScene.Buffers[Prim.VertexBuffers.Buffer[VBSlot]];

      if (Prim.IndexBuffer <> SCENE_INVALID_INDEX) then
        Bind.IndexBuffer := FScene.Buffers[Prim.IndexBuffer];

      TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_PARAMS, TRange.Create(VSParams));
      TGfx.ApplyUniforms(TShaderStage.FragmentShader, SLOT_LIGHT_PARAMS, TRange.Create(FPointLight));

      if (Mat.IsMetallic) then
      begin
        var BaseColorTex := FScene.Images[Mat.Metallic.Images.BaseColor];
        var MetallicRoughnessTex := FScene.Images[Mat.Metallic.Images.MetallicRoughness];
        var NormalTex := FScene.Images[Mat.Metallic.Images.Normal];
        var OcclusionTex := FScene.Images[Mat.Metallic.Images.Occlusion];
        var EmissiveTex := FScene.Images[Mat.Metallic.Images.Emissive];

        if (BaseColorTex.Id = 0) then
          BaseColorTex := FPlaceholders.White;

        if (MetallicRoughnessTex.Id = 0) then
          MetallicRoughnessTex := FPlaceholders.White;

        if (NormalTex.Id = 0) then
          NormalTex := FPlaceholders.Normal;

        if (OcclusionTex.Id = 0) then
          OcclusionTex := FPlaceholders.White;

        if (EmissiveTex.Id = 0) then
          EmissiveTex := FPlaceholders.Black;

        Bind.FragmentShaderImages[SLOT_BASE_COLOR_TEXTURE] := BaseColorTex;
        Bind.FragmentShaderImages[SLOT_METALLIC_ROUGHNESS_TEXTURE] := MetallicRoughnessTex;
        Bind.FragmentShaderImages[SLOT_NORMAL_TEXTURE] := NormalTex;
        Bind.FragmentShaderImages[SLOT_OCCLUSION_TEXTURE] := OcclusionTex;
        Bind.FragmentShaderImages[SLOT_EMISSIVE_TEXTURE] := EmissiveTex;

        TGfx.ApplyUniforms(TShaderStage.FragmentShader, SLOT_METALLIC_PARAMS,
          TRange.Create(Mat.Metallic.FragmentShaderParams));
      end;

      TGfx.ApplyBindings(Bind);
      TGfx.Draw(Prim.BaseElement, Prim.NumElements, 1);
    end;
  end;
  TDbgText.Draw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TglTFApp.glTFParse(const ABuffer: Pointer; const ASize: Int64);
begin
  var Options := TglTFOptions.Create;
  var Data: PglTFData := nil;
  var Rslt := TglTF.Parse(Options, ABuffer, ASize, Data);
  if (Rslt = TglTFResult.Success) then
  try
    glTFParseBuffers(Data);
    glTFParseImages(Data);
    glTFParseMaterials(Data);
    glTFParseMeshes(Data);
    glTFParseNodes(Data);
  finally
    Data.Free;
  end;
end;

procedure TglTFApp.glTFParseBuffers(const AData: PglTFData);
{ Parse the glTF buffer definitions and start loading buffer blobs }
begin
  if (AData.BufferViewCount > SCENE_MAX_BUFFERS) then
  begin
    FFailed := True;
    Exit;
  end;

  { Parse the buffer-view attributes }
  FScene.NumBuffers := AData.BufferViewCount;
  for var I := 0 to AData.BufferViewCount - 1 do
  begin
    var glTFBufView := AData.BufferViews[I];
    var P := PBufferCreationParams(@FCreationParams.Buffers[I]);
    P.glTFBufferIndex := AData.GetBufferIndex(glTFBufView.Buffer);
    P.Offset := glTFBufView.Offset;
    P.Size := glTFBufView.Size;

    if (glTFBufView.ViewType = TglTFBufferViewType.Indices) then
      P.BufferType := TBufferType.IndexBuffer
    else
      P.BufferType := TBufferType.VertexBuffer;

    { Allocate a Sokol Gfx buffer handle }
    FScene.Buffers[I].Allocate;
  end;

  { Start loading all buffers }
  for var I := 0 to AData.BufferCount - 1 do
  begin
    var glTFBuf := AData.Buffers[I];
    var UserData: NativeInt := I;
    var Path := String(UTF8String(glTFBuf.Uri));
    var Request := TFetchRequest.Create(Path, FetchBufferCallback);
    Request.UserData := @UserData;
    Request.UserDataSize := SizeOf(UserData);
    Request.Send;
  end;
end;

procedure TglTFApp.glTFParseImages(const AData: PglTFData);
begin
  if (AData.TextureCount > SCENE_MAX_IMAGES) then
  begin
    FFailed := True;
    Exit;
  end;

  { Parse the texture and sampler attributes }
  FScene.NumImages := AData.TextureCount;
  for var I := 0 to FScene.NumImages - 1 do
  begin
    var glTFTex := AData.Textures[I];
    var P := PImageCreationParams(@FCreationParams.Images[I]);
    P.gltfImageIndex := AData.GetImageIndex(glTFTex.Image);
    P.Minfilter := glTFTex.Sampler.GfxMinFilter;
    P.Magfilter := glTFTex.Sampler.GfxMagFilter;
    P.WrapS := glTFTex.Sampler.GfxWrapS;
    P.WrapT := glTFTex.Sampler.GfxWrapT;
    FScene.Images[I].Id := INVALID_ID;
  end;

  { Start loading all images }
  for var I := 0 to AData.ImageCount - 1 do
  begin
    var glTFImg := AData.Images[I];
    var UserData: NativeInt := I;
    var Path := String(UTF8String(glTFImg.Uri));
    var Request := TFetchRequest.Create(Path, FetchImageCallback);
    Request.UserData := @UserData;
    Request.UserDataSize := SizeOf(UserData);
    Request.Send;
  end;
end;

procedure TglTFApp.glTFParseMaterials(const AData: PglTFData);
{ Parse glTF materials into our own material definition }
begin
  if (AData.MaterialCount > SCENE_MAX_MATERIALS) then
  begin
    FFailed := True;
    Exit;
  end;

  FScene.NumMaterials := AData.MaterialCount;
  for var I := 0 to FScene.NumMaterials - 1 do
  begin
    var glTFMat := AData.Materials[I];
    var SceneMat := PMaterial(@FScene.Materials[I]);
    SceneMat.IsMetallic := glTFMat.HasPbrMetallicRoughness;
    if (SceneMat.IsMetallic) then
    begin
      var Src := PglTFPbrMetallicRoughness(@glTFMat.PbrMetallicRoughness);
      var Dst := PMetallicMaterial(@SceneMat.Metallic);
      Dst.FragmentShaderParams.BaseColorFactor := Src.BaseColorFactor;
      Dst.FragmentShaderParams.EmissiveFactor := glTFMat.EmissiveFactor;
      Dst.FragmentShaderParams.MetallicFactor := Src.MetallicFactor;
      Dst.FragmentShaderParams.RoughnessFactor := Src.RoughnessFactor;
      Dst.Images.BaseColor := AData.GetTextureIndex(Src.BaseColorTexture.Texture);
      Dst.Images.MetallicRoughness := AData.GetTextureIndex(Src.MetallicRoughnessTexture.Texture);
      Dst.Images.Normal := AData.GetTextureIndex(glTFMat.NormalTexture.Texture);
      Dst.Images.Occlusion := AData.GetTextureIndex(glTFMat.OcclusionTexture.Texture);
      Dst.Images.Emissive := AData.GetTextureIndex(glTFMat.EmissiveTexture.Texture);
    end;
  end;
end;

procedure TglTFApp.glTFParseMeshes(const AData: PglTFData);
{ Parse glTF meshes into our own mesh and submesh definition }
begin
  if (AData.MeshCount > SCENE_MAX_MESHES) then
  begin
    FFailed := True;
    Exit;
  end;

  FScene.NumMeshes := AData.MeshCount;
  for var MeshIndex := 0 to AData.MeshCount - 1 do
  begin
    var glTFMesh := AData.Meshes[MeshIndex];
    if ((glTFMesh.PrimitiveCount + FScene.NumPrimitives) > SCENE_MAX_PRIMITIVES) then
    begin
      FFailed := True;
      Exit;
    end;

    var Mesh := PMesh(@FScene.Meshes[MeshIndex]);
    Mesh.FirstPrimitive := FScene.NumPrimitives;
    Mesh.NumPrimitives := glTFMesh.PrimitiveCount;

    for var PrimIndex := 0 to glTFMesh.PrimitiveCount - 1 do
    begin
      var glTFPrim := glTFMesh.Primitives[PrimIndex];
      var Prim := PPrimitive(@FScene.Primitives[FScene.NumPrimitives]);
      Inc(FScene.NumPrimitives);

      { A mapping from Sokol Gfx vertex buffer bind slots into the
        Scene.Buffers array }
      Prim.VertexBuffers := CreateVertexBufferMappingForGlTFPrimitive(AData,
        glTFPrim);

      { Create or reuse a matching pipeline state object }
      Prim.Pipeline := CreateGfxPipelineForGlTFPrimitive(AData, glTFPrim,
        Prim.VertexBuffers);

      { The material parameters }
      Prim.Material := AData.GetMaterialIndex(glTFPrim.Material);

      { Index buffer, base element, num elements }
      if (glTFPrim.Indices <> nil) then
      begin
        Prim.IndexBuffer := AData.GetBufferViewIndex(glTFPrim.Indices.BufferView);
        Assert(FCreationParams.Buffers[Prim.IndexBuffer].BufferType = TBufferType.IndexBuffer);
        Assert(glTFPrim.Indices.Stride <> 0);
        Prim.BaseElement := 0;
        Prim.NumElements := glTFPrim.Indices.Count;
      end
      else
      begin
        { Hmm... looking up the number of elements to render from a random
          vertex component accessor looks a bit shady }
        Prim.IndexBuffer := SCENE_INVALID_INDEX;
        Prim.BaseElement := 0;
        Prim.NumElements := glTFPrim.Attributes[0].Data.Count;
      end;
    end;
  end;
end;

procedure TglTFApp.glTFParseNodes(const AData: PglTFData);
begin
  if (AData.NodeCount > SCENE_MAX_NODES) then
  begin
    FFailed := True;
    Exit;
  end;

  for var NodeIndex := 0 to AData.NodeCount - 1 do
  begin
    var glTFNode := AData.Nodes[NodeIndex];

    { Ignore nodes without mesh. Those are not relevant since we bake the
      transform hierarchy into per-node world space transforms }
    if (glTFNode.Mesh <> nil) then
    begin
      var Node := PNode(@FScene.Nodes[FScene.NumNodes]);
      Inc(FScene.NumNodes);
      Node.Mesh := AData.GetMeshIndex(glTFNode.Mesh);
      Node.Transform := AData.BuildTransform(glTFNode);
    end;
  end;
end;

procedure TglTFApp.Init;
begin
  inherited;
  ReportMemoryLeaksOnShutdown := False;

  { Initialize camera helper }
  var CamDesc := TCameraDesc.Create;
  CamDesc.Latitude := -10;
  CamDesc.Longitude := 45;
  Camdesc.Distance := 3;
  FCamera := TCamera.Create(CamDesc);

  { Initialize Basis Universal }
  TBasisU.Setup;

  { Setup Debug Text }
  var DbgTextDesc := TDbgTextDesc.Create;
  DbgTextDesc.Fonts[0] := TDbgTextFont.Oric;
  TDbgText.Setup(DbgTextDesc);

  { Setup Neslib.Sokol.Fetch with 1 channel and 4 lanes per channel.
    We'll use one channel for mesh data and the other for textures. }
  var FetchDesc := TFetchDesc.Create;
  FetchDesc.MaxRequests := 64;
  FetchDesc.NumChannels := FETCH_NUM_CHANNELS;
  FetchDesc.NumLanes := FETCH_NUM_LANES;
  FetchDesc.BaseDirectory := 'Data/glTF';
  TFetch.Setup(FetchDesc);

  { Normal background color, and a "load failed" background color }
  FPassActions.Init;

  { Create shaders }
  FShaders.Init;

  { Setup the point light }
  FPointLight.LightPos.Init(10, 10, 10);
  FPointLight.LightRange := 200;
  FPointLight.LightColor.Init(1, 1.5, 2);
  FPointLight.LightIntensity := 700;

  { Start loading the base gltf file... }
  var Request := TFetchRequest.Create(FILENAME, FetchCallback);
  Request.Send;

  { Create placeholder textures }
  FPlaceholders.Init;
end;

procedure TglTFApp.UpdateScene;
begin
  FRootTransform.InitRotationY(Radians(FRX));
end;

function TglTFApp.VSParamsForNode(const ANodeIndex: Integer): TVSParams;
begin
  Result.Model :=  FRootTransform * FScene.Nodes[ANodeIndex].Transform;
  Result.ViewProj := FCamera.ViewProj;
  Result.EyePos := FCamera.EyePos;
end;

end.

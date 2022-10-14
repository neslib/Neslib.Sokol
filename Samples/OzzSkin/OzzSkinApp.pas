unit OzzSkinApp;
{  Ozz-animation with GPU skinning.

   https://guillaumeblanc.github.io/ozz-animation/
   Joint palette data for vertex skinning is uploaded each frame to a dynamic
   RGBA32F texture and sampled in the vertex shader to perform weighted skinning
   with up to 4 influence joints per vertex.
   Character instance matrices are stored in a vertex buffer.
   Together this enables rendering many independently animated and positioned
   characters in a single draw call via hardware instancing. }

interface

uses
  Neslib.FastMath,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Time,
  Neslib.Sokol.Fetch,
  Neslib.OzzAnim,
  Utils,
  Camera,
  SampleApp;

const
  { The upper limit for joint palette size is 256 (because the mesh joint
    indices are stored in packed byte-size vertex formats), but the example mesh
    only needs less than 64 }
  MAX_PALETTE_JOINTS = 64;

const
  { This defines the size of the instance-buffer and height of the
    joint-texture }
  MAX_INSTANCES = 512;

type
  { A skinned-mesh vertex. We don't need the texcoords and tangents in our
    example renderer so we just drop them. Normals, joint indices and joint
    weights are packed into BYTE4N and UBYTE4N

    NOTE: joint indices are packed as UBYTE4N and not UBYTE4 because of D3D11
    compatibility (see "A note on portable packed vertex formats" in
    Neslib.Sokol.Gfx.md) }
  TVertex = record
  public
    Position: array [0..2] of Single;
    Normal: UInt32;
    JointIndices: UInt32;
    JointWeights: UInt32;
  end;
  PVertex = ^TVertex;

type
  { Per-instance data for hardware-instanced rendering includes the transposed
    4x3 model-to-world matrix, and information where the joint palette is found
    in the joint texture }
  TInstance = record
  public
    XXXX: array [0..3] of Single;
    YYYY: array [0..3] of Single;
    ZZZZ: array [0..3] of Single;
    JointUV: array [0..1] of Single;
  end;
  PInstance = ^TInstance;

type
  TLoaded = record
  public
    Skeleton: Boolean;
    Animation: Boolean;
    Mesh: Boolean;
    Failed: Boolean;
  end;

type
  TTiming = record
  public
    FrameTimeMs: Double;
    FrameTimeSec: Double;
    AbsTimeSec: Double;
    AnimEvalTime: Int64;
    Factor: Single;
    Paused: Boolean;
  end;

type
  TUI = record
  public
    JointTextureShown: Boolean;
    JointTextureScale: Integer;
  end;
type
  TOzzSkinApp = class(TSampleApp)
  private
    FSkeleton: TOzzSkeleton;
    FAnimation: TOzzAnimation;
    FSamplingJob: TOzzSamplingJob;
    FLocalToModelJob: TOzzLocalToModelJob;
    FJointRemaps: TArray<Word>;
    FMeshInverseBindPoses: TArray<TMatrix4>;
    FLocalMatrices: TAlignedArray<TOzzSoaTransform>;
    FModelMatrices: TAlignedArray<TMatrix4>;
    FCache: TOzzSamplingCache;
    FPassAction: TPassAction;
    FShader: TShader;
    FPip: TPipeline;
    FJointTexture: TImage;
    FBind: TBindings;
    FNumInstances: Integer;      // current number of character instances
    FNumTriangleIndices: Integer;
    FNumSkeletonJoints: Integer; // number of joints in the skeleton
    FNumSkinJoints: Integer;     // number of joints actually used by skinned mesh
    FJointTextureWidth: Integer; // in number of pixels
    FJointTextureHeight: Integer;
    FJointTexturePitch: Integer; // in number of floats
    FCamera: TCamera;
    FDrawEnabled: Boolean;
    FLoaded: TLoaded;
    FTime: TTiming;
    FUI: TUI;

    { IO buffers (we know the max file sizes upfront). }
    FSkeletonData: array [0..(32 * 1024) - 1] of Byte;
    FAnimationData: array [0..(96 * 1024) - 1] of Byte;
    FMeshData: array [0..(3 * 1024 * 1024) - 1] of Byte;

    { Instance data buffer }
    FInstanceData: array [0..MAX_INSTANCES - 1] of TInstance;

    { Joint-matrix upload buffer, each joint consists of transposed 4x3 matrix }
    FJointUploadBuffer: array [0..MAX_INSTANCES - 1, 0..MAX_PALETTE_JOINTS - 1, 0..2, 0..3] of Single;
  private
    procedure InitInstanceData;
    procedure SkeletonDataLoaded(const AResponse: TFetchResponse);
    procedure AnimationDataLoaded(const AResponse: TFetchResponse);
    procedure MeshDataLoaded(const AResponse: TFetchResponse);
    procedure UpdateJointTexture;
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
  Neslib.OzzAnim.Api,
  Neslib.ImGui,
  OzzSkinShader;

function PackU32(const AX, AY, AZ, AW: Byte): UInt32;
begin
  Result := (AW shl 24) or (AZ shl 16) or (AY shl 8) or AX;
end;

function PackF4Byte4N(const AX, AY, AZ, AW: Single): UInt32;
begin
  var X8: Int8 := Trunc(AX * 127);
  var Y8: Int8 := Trunc(AY * 127);
  var Z8: Int8 := Trunc(AZ * 127);
  var W8: Int8 := Trunc(AW * 127);
  Result := PackU32(UInt8(X8), UInt8(Y8), UInt8(Z8), UInt8(W8));
end;

function PackF4UByte4N(const AX, AY, AZ, AW: Single): UInt32;
begin
  var X8: UInt8 := Trunc(AX * 255);
  var Y8: UInt8 := Trunc(AY * 255);
  var Z8: UInt8 := Trunc(AZ * 255);
  var W8: UInt8 := Trunc(AW * 255);
  Result := PackU32(X8, Y8, Z8, W8);
end;

{ TOzzSkinApp }

procedure TOzzSkinApp.AnimationDataLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
  begin
    var Archive: TOzzIArchive := nil;
    var Stream := TOzzMemoryStream.Create;
    try
      Stream.Write(AResponse.BufferPtr^, AResponse.FetchedSize);
      Stream.Seek(0, soBeginning);

      Archive := TOzzIArchive.Create(Stream);
      if (Archive.TestTag<TOzzAnimation>) then
      begin
        Archive.Load(FAnimation);
        FLoaded.Animation := True;
      end
      else
        FLoaded.Failed := True;
    finally
      Archive.Free;
      Stream.Free;
    end;
  end
  else if (AResponse.Failed) then
    FLoaded.Failed := True;
end;

procedure TOzzSkinApp.Cleanup;
begin
  inherited;
  FLocalMatrices.Free;
  FModelMatrices.Free;
  FBind.IndexBuffer.Free;
  FBind.VertexBuffers[0].Free;
  FBind.VertexBuffers[1].Free;
  FJointTexture.Free;
  FPip.Free;
  FShader.Free;
  FCamera.Free;
  TFetch.Shutdown;
  FCache.Free;
  FAnimation.Free;
  FSkeleton.Free;
  FSamplingJob.Free;
  FLocalToModelJob.Free;
end;

procedure TOzzSkinApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'Ozz-Skin';
end;

procedure TOzzSkinApp.DrawImGui;
begin
  ImGui.SetNextWindowPos(Vector2(20, 30), TImGuiCond.Once);
  ImGui.SetNextWindowSize(Vector2(220, 150), TImGuiCond.Once);
  ImGui.SetNextWindowBgAlpha(0.35);
  if (ImGui.Begin('Controls', nil, TImGuiWindowFlags.NoDecoration + [TImGuiWindowFlag.AlwaysAutoResize])) then
  begin
    if (FLoaded.Failed) then
      ImGui.Text('Failed loading character data!')
    else
    begin
      if (ImGui.SliderInt('Num Instances', FNumInstances, 1, MAX_INSTANCES)) then
      begin
        var DistStep: Single := (FCamera.MaxDist - FCamera.MinDist) / MAX_INSTANCES;
        FCamera.Distance := FCamera.MinDist + (DistStep * FNumInstances);
      end;

      ImGui.Checkbox('Enable Mesh Drawing', @FDrawEnabled);
      ImGui.Text(ImGui.Format('Frame Time: %.3fms', [FTime.FrameTimeMs]));
      ImGui.Text(ImGui.Format('Anim Eval Time: %.3fms', [TTime.ToMilliSeconds(FTime.AnimEvalTime)]));
      ImGui.Text(ImGui.Format('Num Triangles: %d', [(FNumTriangleIndices div 3) * FNumInstances]));
      ImGui.Text(ImGui.Format('Num Animated Joints: %d', [FNumSkeletonJoints * FNumInstances]));
      ImGui.Text(ImGui.Format('Num Skinning Joints: %d', [FNumSkinJoints * FNumInstances]));

      ImGui.Separator;

      ImGui.Text('Camera Controls:');
      ImGui.Text('  LMB + Drag:  Look');
      ImGui.Text('  Mouse wheel: Zoom');

      ImGui.SliderFloat('Distance', FCamera.Distance, FCamera.MinDist, FCamera.MaxDist, '%.1f');
      ImGui.SliderFloat('Latitude', FCamera.Latitude, FCamera.MinLat, FCamera.MaxLat, '%.1f');
      ImGui.SliderFloat('Longitude', FCamera.Longitude, 0, 360, '%.1f');

      ImGui.Separator;

      ImGui.Text('Time Controls:');
      ImGui.Checkbox('Paused', @FTime.Paused);
      ImGui.SliderFloat('Factor', FTime.Factor, 0, 10, '%.1f');

      ImGui.Separator;

      if (ImGui.Button('Toggle Joint Texture')) then
        FUI.JointTextureShown := not FUI.JointTextureShown;
    end;
  end;

  if (FUI.JointTextureShown) then
  begin
    ImGui.SetNextWindowPos(Vector2(20, 300), TImGuiCond.Once);
    ImGui.SetNextWindowSize(Vector2(600, 300), TImGuiCond.Once);
    if (ImGui.Begin('Joint Texture', @FUI.JointTextureShown)) then
    begin
      ImGui.InputInt('##scale', FUI.JointTextureScale);

      ImGui.SameLine;
      if (ImGui.Button('1x')) then
        FUI.JointTextureScale := 1;

      ImGui.SameLine;
      if (ImGui.Button('2x')) then
        FUI.JointTextureScale := 2;

      ImGui.SameLine;
      if (ImGui.Button('4x')) then
        FUI.JointTextureScale := 4;

      ImGui.BeginChild('##frame', True, [TImGuiWindowFlag.HorizontalScrollbar]);
      ImGui.Image(Pointer(FJointTexture.Id),
        Vector2(FJointTextureWidth * FUI.JointTextureScale, FJointTextureHeight * FUI.JointTextureScale),
        TVector2.Zero, TVector2.One);
      ImGui.EndChild;
    end;
    ImGui.End;
  end;
  ImGui.End;
end;

procedure TOzzSkinApp.Frame;
begin
  TFetch.DoWork;

  var FBWidth := FramebufferWidth;
  var FBHeight := FramebufferHeight;
  FTime.FrameTimeSec := FrameDuration;
  FTime.FrameTimeMs := FTime.FrameTimeSec * 1000;
  FCamera.Update(FBWidth, FBHeight);

  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);

  if (FLoaded.Animation and FLoaded.Skeleton and FLoaded.Mesh) then
  begin
    if (not FTime.Paused) then
      FTime.AbsTimeSec := FTime.AbsTimeSec + (FTime.FrameTimeSec * FTime.Factor);

    UpdateJointTexture;

    var VSParams: TVSParams;
    VSParams.ViewProj := FCamera.ViewProj;
    VSParams.JointPixelWidth := 1 / FJointTextureWidth;

    TGfx.ApplyPipeline(FPip);
    TGfx.ApplyBindings(FBind);
    TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_PARAMS, TRange.Create(VSParams));

    if (FDrawEnabled) then
      TGfx.Draw(0, FNumTriangleIndices, FNumInstances);
  end;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

class function TOzzSkinApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TOzzSkinApp.Init;
begin
  inherited;
  FSkeleton := TOzzSkeleton.Create;
  FAnimation := TOzzAnimation.Create;
  FSamplingJob := TOzzSamplingJob.Create;
  FLocalToModelJob := TOzzLocalToModelJob.Create;
  FCache := TOzzSamplingCache.Create;

  FSamplingJob.Animation := FAnimation;
  FSamplingJob.Cache := FCache;
  FLocalToModelJob.Skeleton := FSkeleton;

  FNumInstances := 1;
  FDrawEnabled := True;
  FTime.Factor := 1;
  FUI.JointTextureScale := 4;

  { Setup Sokol Time }
  TTime.Setup;

  { Setup Sokol Fetch }
  var FetchDesc := TFetchDesc.Create;
  FetchDesc.MaxRequests := 3;
  FetchDesc.NumChannels := 1;
  FetchDesc.NumLanes := 3;
  FetchDesc.BaseDirectory := 'Data/ozz';
  TFetch.Setup(FetchDesc);

  { Initialize pass action for default-pass }
  FPassAction.Colors[0].Init(TAction.Clear, 0.0, 0.0, 0.0);

  { Initialize camera controller }
  var CamDesc := TCameraDesc.Create;
  CamDesc.MinDist := 2;
  CamDesc.MaxDist := 40;
  CamDesc.Center.Y := 1.1;
  CamDesc.Distance := 3;
  CamDesc.Latitude := 20;
  CamDesc.Longitude := 20;
  FCamera := TCamera.Create(CamDesc);

  { Vertex-skinning shader and pipeline object for 3d rendering. Note the
    hardware-instanced vertex layout }
  var Shader := TShader.Create(SkinnedShaderDesc);
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := Shader;
  PipDesc.Layout.Buffers[0].Stride := SizeOf(TVertex);
  PipDesc.Layout.Buffers[1].Stride := SizeOf(TInstance);
  PipDesc.Layout.Buffers[1].StepFunc := TVertexStep.PerInstance;
  PipDesc.Layout.Attrs[ATTR_VS_POSITION].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_VS_NORMAL].Format := TVertexFormat.Byte4N;
  PipDesc.Layout.Attrs[ATTR_VS_JINDICES].Format := TVertexFormat.UByte4N;
  PipDesc.Layout.Attrs[ATTR_VS_JWEIGHTS].Format := TVertexFormat.UByte4N;
  PipDesc.Layout.Attrs[ATTR_VS_INST_XXXX].Init(1, 0, TVertexFormat.Float4);
  PipDesc.Layout.Attrs[ATTR_VS_INST_YYYY].Init(1, 0, TVertexFormat.Float4);
  PipDesc.Layout.Attrs[ATTR_VS_INST_ZZZZ].Init(1, 0, TVertexFormat.Float4);
  PipDesc.Layout.Attrs[ATTR_VS_INST_JOINT_UV].Init(1, 0, TVertexFormat.Float2);
  PipDesc.IndexType := TIndexType.UInt16;

  { ozz mesh data appears to have counter-clock-wise face winding }
  PipDesc.FaceWinding := TFaceWinding.CounterClockWise;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  FPip := TPipeline.Create(PipDesc);

  { Create a dynamic joint-palette texture }
  FJointTextureWidth := MAX_PALETTE_JOINTS * 3;
  FJointTextureHeight := MAX_INSTANCES;
  FJointTexturePitch := FJointTextureWidth * 4;

  var ImgDesc := TImageDesc.Create;
  ImgDesc.Width := FJointTextureWidth;
  ImgDesc.Height := FJointTextureHeight;
  ImgDesc.NumMipmaps := 1;
  ImgDesc.PixelFormat := TPixelFormat.Rgba32F;
  ImgDesc.Usage := TUsage.Stream;
  ImgDesc.MinFilter := TFilter.Nearest;
  ImgDesc.MagFilter := TFilter.Nearest;
  ImgDesc.WrapU := TWrap.ClampToEdge;
  ImgDesc.WrapV := TWrap.ClampToEdge;
  FJointTexture := TImage.Create(ImgDesc);
  FBind.VertexShaderImages[SLOT_JOINT_TEX] := FJointTexture;

  { Create a static instance-data buffer. In this demo, character instances
    don't move around and also are not clipped against the view volume,
    so we can just initialize a static instance data buffer upfront. }
  InitInstanceData;

  var BufDesc := TBufferDesc.Create;
  BufDesc.BufferType := TBufferType.VertexBuffer;
  BufDesc.Data := TRange.Create(FInstanceData);
  FBind.VertexBuffers[1] := TBuffer.Create(BufDesc);

  { Start loading data }
  var Req := TFetchRequest.Create('ozz_skin_skeleton.ozz', SkeletonDataLoaded,
    @FSkeletonData, SizeOf(FSkeletonData));
  Req.Send;

  Req := TFetchRequest.Create('ozz_skin_animation.ozz', AnimationDataLoaded,
    @FAnimationData, SizeOf(FAnimationData));
  Req.Send;

  Req := TFetchRequest.Create('ozz_skin_mesh.ozz', MeshDataLoaded,
    @FMeshData, SizeOf(FMeshData));
  Req.Send;
end;

procedure TOzzSkinApp.InitInstanceData;
{ Initialize the static instance data. Since the character instances don't
  move around or are clipped against the view volume in this demo, the instance
  data is initialized once and lives in an immutable instance buffer }
begin
  Assert((FJointTextureWidth > 0) and (FJointTextureHeight > 0));

  { Initialize the character instance model-to-world matrices }
  var X := 0;
  var Y := 0;
  var DX := 0;
  var DY := 0;
  for var I := 0 to MAX_INSTANCES - 1 do
  begin
    var Inst := PInstance(@FInstanceData[I]);

    { A 3x4 transposed model-to-world matrix (only the x/z position is set) }
    Inst.XXXX[0] := 1; Inst.XXXX[1] := 0; Inst.XXXX[2] := 0; Inst.XXXX[3] := X * 1.5;
    Inst.YYYY[0] := 0; Inst.YYYY[1] := 1; Inst.YYYY[2] := 0; Inst.YYYY[3] := 0;
    Inst.ZZZZ[0] := 0; Inst.ZZZZ[1] := 0; Inst.ZZZZ[2] := 1; Inst.ZZZZ[3] := Y * 1.5;

    { At a corner? }
    if (Abs(X) = Abs(Y)) then
    begin
      if (X >= 0) then
      begin
        if (Y >= 0) then
        begin
          { Top-right corner: start a new ring }
          Inc(X);
          Inc(Y);
          DX := 0;
          DY := -1;
        end
        else
        begin
          { Bottom-right corner }
          DX := -1;
          DY := 0;
        end;
      end
      else
      begin
        if (Y >= 0) then
        begin
          { Top-left corner }
          DX := 1;
          DY := 0;
        end
        else
        begin
          { Bottom-left corner }
          DX := 0;
          DY := 1;
        end;
      end;
    end;

    X := X + DX;
    Y := Y + DY;
  end;

  { The skin_info vertex component contains information about where to find the
    joint palette for this character instance in the joint texture }
  var HalfPixelX: Single := 0.5 / FJointTextureWidth;
  var HalfPixelY: Single := 0.5 / FJointTextureHeight;
  for var I := 0 to MAX_INSTANCES - 1 do
  begin
    var Inst := PInstance(@FInstanceData[I]);
    Inst.JointUV[0] := HalfPixelX;
    Inst.JointUV[1] := HalfPixelY + (I / FJointTextureHeight);
  end;
end;

procedure TOzzSkinApp.MeshDataLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
  begin
    var Mesh: TOzzMesh := nil;
    var Archive: TOzzIArchive := nil;
    var Stream := TOzzMemoryStream.Create;
    try
      Stream.Write(AResponse.BufferPtr^, AResponse.FetchedSize);
      Stream.Seek(0, soBeginning);

      Archive := TOzzIArchive.Create(Stream);
      { Assume one mesh }
      if (Archive.TestTag<TOzzMesh>) then
      begin
        Mesh := TOzzMesh.Create;
        Archive.Load(Mesh);
        FLoaded.Mesh := True;
      end
      else
      begin
        FLoaded.Failed := True;
        Exit;
      end;

      { Assume one submesh }
      Assert(Mesh.PartCount = 1);
      FNumSkinJoints := Mesh.JointCount;
      FNumTriangleIndices := Mesh.TriangleIndexCount;
      FJointRemaps := Mesh.JointRemaps;
      FMeshInverseBindPoses := Mesh.InverseBindPoses;

      { Convert mesh data into packed vertices }
      var Part := Mesh.Parts[0];
      var NumVertices := Part.PositionCount div 3;
      Assert(Part.NormalCount = (NumVertices * 3));
      Assert(Part.JointIndexCount = (NumVertices * 4));
      Assert(Part.JointWeightCount = (NumVertices * 3));

      var Positions := Part.Positions;
      var Normals := Part.Normals;
      var JointIndices := Part.JointIndices;
      var JointWeights := Part.JointWeights;

      var Vertices: TArray<TVertex>;
      SetLength(Vertices, NumVertices);
      for var I := 0 to NumVertices - 1 do
      begin
        var V := PVertex(@Vertices[I]);
        V.Position[0] := Positions^; Inc(Positions);
        V.Position[1] := Positions^; Inc(Positions);
        V.Position[2] := Positions^; Inc(Positions);

        var NX: Single := Normals^; Inc(Normals);
        var NY: Single := Normals^; Inc(Normals);
        var NZ: Single := Normals^; Inc(Normals);
        V.Normal := PackF4Byte4N(NX, NY, NZ, 0);

        var JI0: Byte := JointIndices^; Inc(JointIndices);
        var JI1: Byte := JointIndices^; Inc(JointIndices);
        var JI2: Byte := JointIndices^; Inc(JointIndices);
        var JI3: Byte := JointIndices^; Inc(JointIndices);
        V.JointIndices := PackU32(JI0, JI1, JI2, JI3);

        var JW0: Single := JointWeights^; Inc(JointWeights);
        var JW1: Single := JointWeights^; Inc(JointWeights);
        var JW2: Single := JointWeights^; Inc(JointWeights);
        var JW3: Single := 1 - (JW0 + JW1 + JW2);
        V.JointWeights := PackF4UByte4N(JW0, JW1, JW2, JW3);
      end;

      { Create vertex- and index-buffer }
      var VBufDesc := TBufferDesc.Create;
      VBufDesc.BufferType := TBufferType.VertexBuffer;
      VBufDesc.Data := TRange.Create(Pointer(Vertices), NumVertices * SizeOf(TVertex));
      FBind.VertexBuffers[0] := TBuffer.Create(VBufDesc);

      var IBufDesc := TBufferDesc.Create;
      IBufDesc.BufferType := TBufferType.IndexBuffer;
      IBufDesc.Data := TRange.Create(Mesh.TriangleIndices, FNumTriangleIndices * SizeOf(Word));
      FBind.IndexBuffer := TBuffer.Create(IBufDesc);
    finally
      Mesh.Free;
      Archive.Free;
      Stream.Free;
    end;
  end
  else if (AResponse.Failed) then
    FLoaded.Failed := True;
end;

procedure TOzzSkinApp.SkeletonDataLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
  begin
    var Archive: TOzzIArchive := nil;
    var Stream := TOzzMemoryStream.Create;
    try
      Stream.Write(AResponse.BufferPtr^, AResponse.FetchedSize);
      Stream.Seek(0, soBeginning);

      Archive := TOzzIArchive.Create(Stream);
      if (Archive.TestTag<TOzzSkeleton>) then
      begin
        Archive.Load(FSkeleton);
        FLoaded.Skeleton := True;
        var NumSoaJoints := FSkeleton.NumSoaJoints;
        var NumJoints := FSkeleton.NumJoints;

        FLocalMatrices := TAlignedArray<TOzzSoaTransform>.Create(NumSoaJoints);
        FModelMatrices  := TAlignedArray<TMatrix4>.Create(NumJoints);
        FNumSkeletonJoints := NumJoints;
        FCache.Resize(NumJoints);

        FSamplingJob.Output := TOzzSpan<TOzzSoaTransform>.Create(FLocalMatrices);
        FLocalToModelJob.Input := TOzzSpan<TOzzSoaTransform>.Create(FLocalMatrices);
        FLocalToModelJob.Output := TOzzSpan<TMatrix4>.Create(FModelMatrices);
      end
      else
        FLoaded.Failed := True;
    finally
      Archive.Free;
      Stream.Free;
    end;
  end
  else if (AResponse.Failed) then
    FLoaded.Failed := True;
end;

procedure TOzzSkinApp.UpdateJointTexture;
{ Compute skinning matrices, and upload into joint texture }
begin
  var StartTime := TTime.Now;
  var AnimDuration: Single := FAnimation.Duration;
  for var Instance := 0 to FNumInstances - 1 do
  begin
    { Each character instance evaluates its own animation }
    var AnimRatio := Frac((FTime.AbsTimeSec + (Instance * 0.1)) / AnimDuration);

    { Sample animation.
      NOTE: using one cache per instance versus one cache per animation makes a
      small difference, but not much }
    FSamplingJob.Ratio := AnimRatio;
    FSamplingJob.Run;

    { Convert joint matrices from local to model space }
    FLocalToModelJob.Run;

    { Compute skinning matrices and write to joint texture upload buffer }
    for var I := 0 to FNumSkinJoints - 1 do
    begin
      var SkinMatrix := FModelMatrices[FJointRemaps[I]] * FMeshInverseBindPoses[I];
      var C0: PVector4 := @SkinMatrix.C[0];
      var C1: PVector4 := @SkinMatrix.C[1];
      var C2: PVector4 := @SkinMatrix.C[2];
      var C3: PVector4 := @SkinMatrix.C[3];

      var Ptr: PSingle := @FJointUploadBuffer[Instance, I, 0, 0];
      Ptr^ := C0.X; Inc(Ptr); Ptr^ := C1.X; Inc(Ptr); Ptr^ := C2.X; Inc(Ptr); Ptr^ := C3.X; Inc(Ptr);
      Ptr^ := C0.Y; Inc(Ptr); Ptr^ := C1.Y; Inc(Ptr); Ptr^ := C2.Y; Inc(Ptr); Ptr^ := C3.Y; Inc(Ptr);
      Ptr^ := C0.Z; Inc(Ptr); Ptr^ := C1.Z; Inc(Ptr); Ptr^ := C2.Z; Inc(Ptr); Ptr^ := C3.Z;
    end;
  end;

  FTime.AnimEvalTime := TTime.Since(StartTime);

  var ImgData := TImageData.Create;
  ImgData.SubImages[0] := TRange.Create(FJointUploadBuffer);
  FJointTexture.Update(ImgData);
end;

end.

unit OzzUtil;
{ OzzAnim utilities }

interface

uses
  Neslib.FastMath,
  Neslib.Sokol.Gfx,
  Neslib.OzzAnim.Api,
  Neslib.OzzAnim,
  Utils;

type
  TOzzVertex = packed record
  public
    Position: TVector3;
    Normal: UInt32;
    JointIndices: UInt32;
    JointWeights: UInt32;
  end;
  POzzVertex = ^TOzzVertex;

type
  TOzzDesc = record
  public
    MaxPaletteJoints: Integer;
    MaxInstances: Integer;
  public
    class function Create: TOzzDesc; inline; static;
    procedure Init;
  end;

type
  TOzz = record
  {$REGION 'Internal Declarations'}
  private class var
    GValid: Boolean;
    GDesc: TOzzDesc;
    GJointTextureWidth: Integer;  // In number of pixels
    GJointTextureHeight: Integer; // In number of pixels
    GJointTexturePitch: Integer;  // In number of floats
    GJointTexture: TImage;
    GJointTextureView: TView;
    GSampler: TSampler;
    GJointUpoadBuffer: TArray<Single>;
  private
    class function GetJointTexturePixelWidth: Single; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    class procedure Setup(const ADesc: TOzzDesc); static;
    class procedure Shutdown; static;
    class procedure UpdateJointTexture; static;

    class property JointTextureView: TView read GJointTextureView;
    class property JointSampler: TSampler read GSampler;
    class property JointTexturePixelWidth: Single read GetJointTexturePixelWidth;
  end;

type
  TOzzInstance = class
  {$REGION 'Internal Declarations'}
  private
    FIndex: Integer;
    FSkel: TOzzSkeleton;
    FAnim: TOzzAnimation;
    FJointRemaps: TArray<Word>;
    FMeshInverseBindPoses: TArray<TMatrix4>;
    FLocalMatrices: TAlignedArray<TOzzSoaTransform>;
    FModelMatrices: TAlignedArray<TMatrix4>;
    FCache: TOzzSamplingCache;
    FSamplingJob: TOzzSamplingJob;
    FLocalToModelJob: TOzzLocalToModelJob;
    FVBuf: TBuffer;
    FIBuf: TBuffer;
    FNumSkinJoints: Integer;
    FNumTriangleIndices: Integer;
    FSkelLoaded: Boolean;
    FAnimLoaded: Boolean;
    FMeshLoaded: Boolean;
    FLoadFailed: Boolean;
    function GetAllLoaded: Boolean; inline;
    function GetJointTextureCoord: TVector2; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AIndex: Integer);
    destructor Destroy; override;

    procedure LoadAnimation(const AData: Pointer; const ANumBytes: NativeInt);
    procedure LoadMesh(const AData: Pointer; const ANumBytes: NativeInt);
    procedure LoadSkeleton(const AData: Pointer; const ANumBytes: NativeInt);
    procedure SetLoadFailed;

    procedure Update(const ASeconds: Double);

    property AllLoaded: Boolean read GetAllLoaded;
    property NumTriangleIndices: Integer read FNumTriangleIndices;
    property VertexBuffer: TBuffer read FVBuf;
    property IndexBuffer: TBuffer read FIBuf;
    property JointTextureCoord: TVector2 read GetJointTextureCoord;
    property LoadFailed: Boolean read FLoadFailed;
  end;

implementation

uses
  System.Classes,
  Neslib.Sokol.Api;

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

{ TOzzDesc }

class function TOzzDesc.Create: TOzzDesc;
begin
  Result.Init;
end;

procedure TOzzDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TOzz }

class function TOzz.GetJointTexturePixelWidth: Single;
begin
  Result := 1 / GJointTextureWidth;
end;

class procedure TOzz.Setup(const ADesc: TOzzDesc);
begin
  Assert(not GValid);
  Assert(ADesc.MaxPaletteJoints > 0);
  Assert(ADesc.MaxInstances > 0);

  GValid := True;
  GDesc := ADesc;
  GJointTextureWidth := ADesc.MaxPaletteJoints * 3;
  GJointTextureHeight := ADesc.MaxInstances;
  GJointTexturePitch := GJointTextureWidth * 4;

  var ImgDesc := TImageDesc.Create;
  ImgDesc.Width := GJointTextureWidth;
  ImgDesc.Height := GJointTextureHeight;
  ImgDesc.NumMipmaps := 1;
  ImgDesc.PixelFormat := TPixelFormat.Rgba32F;
  ImgDesc.Usage.StreamUpdate := True;
  ImgDesc.TraceLabel := 'JointTexture';
  GJointTexture := TImage.Create(ImgDesc);

  var ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := GJointTexture;
  ViewDesc.TraceLabel := 'JointTextureView';
  GJointTextureView := TView.Create(ViewDesc);

  var SamplerDesc := TSamplerDesc.Create(TFilter.Nearest, TWrap.ClampToEdge);
  SamplerDesc.TraceLabel := 'JointTextureSampler';
  GSampler := TSampler.Create(SamplerDesc);

  SetLength(GJointUpoadBuffer, GJointTexturePitch * GJointTextureHeight);
end;

class procedure TOzz.Shutdown;
begin
  Assert(GValid);
  GJointUpoadBuffer := nil;
  GSampler.Free;
  GJointTextureView.Free;
  GJointTexture.Free;
  GValid := False;
end;

class procedure TOzz.UpdateJointTexture;
begin
  Assert(GValid);
  Assert(GJointUpoadBuffer <> nil);

  var ImgData := TImageData.Create;
  ImgData.MipLevels[0].Data := Pointer(GJointUpoadBuffer);
  ImgData.MipLevels[0].Size := GJointTexturePitch * GJointTextureHeight * SizeOf(Single);
  GJointTexture.Update(ImgData);
end;

{ TOzzInstance }

constructor TOzzInstance.Create(const AIndex: Integer);
begin
  Assert(TOzz.GValid);
  Assert(Cardinal(AIndex) < Cardinal(TOzz.GDesc.MaxInstances));
  inherited Create;
  FIndex := AIndex;
  FSkel := TOzzSkeleton.Create;
  FAnim := TOzzAnimation.Create;
  FCache := TOzzSamplingCache.Create;
  FSamplingJob := TOzzSamplingJob.Create;
  FLocalToModelJob := TOzzLocalToModelJob.Create;
end;

destructor TOzzInstance.Destroy;
begin
  FIBuf.Free;
  FVBuf.Free;
  FLocalToModelJob.Free;
  FSamplingJob.Free;
  FCache.Free;
  FModelMatrices.Free;
  FLocalMatrices.Free;
  FAnim.Free;
  FSkel.Free;
  inherited;
end;

function TOzzInstance.GetAllLoaded: Boolean;
begin
  Assert(TOzz.GValid);
  Result := FSkelLoaded and FAnimLoaded and FMeshLoaded and (not FLoadFailed);
end;

function TOzzInstance.GetJointTextureCoord: TVector2;
begin
  Assert(TOzz.GValid);
  Result.X := 0.5 / TOzz.GJointTextureWidth;
  Result.Y := (0.5 / TOzz.GJointTextureHeight) + (FIndex / TOzz.GJointTextureHeight);
end;

procedure TOzzInstance.LoadAnimation(const AData: Pointer;
  const ANumBytes: NativeInt);
begin
  Assert(TOzz.GValid and (AData <> nil) and (ANumBytes > 0));
  var Archive: TOzzIArchive := nil;
  var Stream := TOzzMemoryStream.Create;
  try
    Stream.Write(AData^, ANumBytes);
    Stream.Seek(0, soBeginning);

    Archive := TOzzIArchive.Create(Stream);
    if (Archive.TestTag<TOzzAnimation>) then
    begin
      Archive.Load(FAnim);
      FAnimLoaded := True;
    end
    else
      FLoadFailed := True;
  finally
    Archive.Free;
    Stream.Free;
  end;
end;

procedure TOzzInstance.LoadMesh(const AData: Pointer;
  const ANumBytes: NativeInt);
begin
  Assert(TOzz.GValid and (AData <> nil) and (ANumBytes > 0));
  var Mesh: TOzzMesh := nil;
  var Archive: TOzzIArchive := nil;
  var Stream := TOzzMemoryStream.Create;
  try
    Stream.Write(AData^, ANumBytes);
    Stream.Seek(0, soBeginning);

    Archive := TOzzIArchive.Create(Stream);

    { Only load the first part of the first mesh }
    if (Archive.TestTag<TOzzMesh>) then
    begin
      Mesh := TOzzMesh.Create;
      Archive.Load(Mesh);
      FMeshLoaded := True;
    end
    else
    begin
      FLoadFailed := True;
      Exit;
    end;

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

    var Vertices: TArray<TOzzVertex>;
    SetLength(Vertices, NumVertices);
    for var I := 0 to NumVertices - 1 do
    begin
      var V := POzzVertex(@Vertices[I]);
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
    VBufDesc.Usage.VertexBuffer := True;
    VBufDesc.Data := TRange.Create(Pointer(Vertices), NumVertices * SizeOf(TOzzVertex));
    FVBuf := TBuffer.Create(VBufDesc);
    Vertices := nil;

    var IBufDesc := TBufferDesc.Create;
    IBufDesc.Usage.IndexBuffer := True;
    IBufDesc.Data := TRange.Create(Mesh.TriangleIndices, FNumTriangleIndices * SizeOf(Word));
    FIBuf := TBuffer.Create(IBufDesc);
  finally
    Mesh.Free;
    Archive.Free;
    Stream.Free;
  end;
end;

procedure TOzzInstance.LoadSkeleton(const AData: Pointer;
  const ANumBytes: NativeInt);
begin
  Assert(TOzz.GValid and (AData <> nil) and (ANumBytes > 0));
  var Archive: TOzzIArchive := nil;
  var Stream := TOzzMemoryStream.Create;
  try
    Stream.Write(AData^, ANumBytes);
    Stream.Seek(0, soBeginning);

    Archive := TOzzIArchive.Create(Stream);
    if (Archive.TestTag<TOzzSkeleton>) then
    begin
      Archive.Load(FSkel);
      FSkelLoaded := True;
      var NumSoaJoints := FSkel.NumSoaJoints;
      var NumJoints := FSkel.NumJoints;
      FCache.Resize(NumJoints);

      FLocalMatrices := TAlignedArray<TOzzSoaTransform>.Create(NumSoaJoints);
      FModelMatrices  := TAlignedArray<TMatrix4>.Create(NumJoints);
    end
    else
      FLoadFailed := True;
  finally
    Archive.Free;
    Stream.Free;
  end;
end;

procedure TOzzInstance.SetLoadFailed;
begin
  Assert(TOzz.GValid);
  FLoadFailed := True;
end;

procedure TOzzInstance.Update(const ASeconds: Double);
begin
  Assert(TOzz.GValid);
  Assert(TOzz.GJointUpoadBuffer <> nil);

  var AnimDuration: Single := FAnim.Duration;
  var AnimRatio: Single := FMod(ASeconds / AnimDuration, 1);

  FSamplingJob.Animation := FAnim;
  FSamplingJob.Cache := FCache;
  FSamplingJob.Ratio := AnimRatio;
  FSamplingJob.Output := TOzzSpan<TOzzSoaTransform>.Create(FLocalMatrices);
  FSamplingJob.Run;

  FLocalToModelJob.Skeleton := FSkel;
  FLocalToModelJob.Input := TOzzSpan<TOzzSoaTransform>.Create(FLocalMatrices);
  FLocalToModelJob.Output := TOzzSpan<TMatrix4>.Create(FModelMatrices);
  FLocalToModelJob.Run;

  for var I := 0 to FNumSkinJoints - 1 do
  begin
    var SkinMatrix := FModelMatrices[FJointRemaps[I]] * FMeshInverseBindPoses[I];
    var C0: PVector4 := @SkinMatrix.C[0];
    var C1: PVector4 := @SkinMatrix.C[1];
    var C2: PVector4 := @SkinMatrix.C[2];
    var C3: PVector4 := @SkinMatrix.C[3];

    var Ptr: PSingle := @TOzz.GJointUpoadBuffer[(FIndex * TOzz.GJointTexturePitch) + (I * 12)];
    Ptr^ := C0.X; Inc(Ptr); Ptr^ := C1.X; Inc(Ptr); Ptr^ := C2.X; Inc(Ptr); Ptr^ := C3.X; Inc(Ptr);
    Ptr^ := C0.Y; Inc(Ptr); Ptr^ := C1.Y; Inc(Ptr); Ptr^ := C2.Y; Inc(Ptr); Ptr^ := C3.Y; Inc(Ptr);
    Ptr^ := C0.Z; Inc(Ptr); Ptr^ := C1.Z; Inc(Ptr); Ptr^ := C2.Z; Inc(Ptr); Ptr^ := C3.Z;
  end;
end;

end.

unit Neslib.OzzAnim;
{ Quick & Dirty partial C binding and Delphi wrapper for ozz-animation
  (https://github.com/guillaumeblanc/ozz-animation).

  This is a very minimal binding supporting just those features needed to make
  some examples work. }

interface

uses
  System.Classes,
  Neslib.FastMath,
  Neslib.OzzAnim.Api,
  Utils;

type
  TOzzSoaFloat3 = record
  public
    X: TVector4;
    Y: TVector4;
    Z: TVector4;
  end;

type
  TOzzSoaQuaternion = record
  public
    X: TVector4;
    Y: TVector4;
    Z: TVector4;
    W: TVector4;
  end;

type
  TOzzSoaTransform = record
  public
    Translation: TOzzSoaFloat3;
    Rotation: TOzzSoaQuaternion;
    Scale: TOzzSoaFloat3;
  end;
  POzzSoaTransform = ^TOzzSoaTransform;

type
  TOzzSpan<T: record> = record
  {$REGION 'Internal Declarations'}
  private type
    P = ^T;
  private
    FHandle: _ozz_span_t;
    function GetCount: Integer; inline;
    function GetItem(const AIndex: Integer): T; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AValues: TArray<T>); overload;
    constructor Create(const AValues: TAlignedArray<T>); overload;
    procedure Init(const AValues: TArray<T>); overload; inline;
    procedure Init(const AValues: TAlignedArray<T>); overload; inline;

    property Data: Pointer read FHandle.data;
    property Count: Integer read GetCount;
    property Items[const AIndex: Integer]: T read GetItem; default;
  end;

type
  TOzzObject = class abstract
  {$REGION 'Internal Declarations'}
  private
    FHandle: _ozz_handle_t;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  TOzzSkeleton = class(TOzzObject)
  {$REGION 'Internal Declarations'}
  private
    function GetNumJoints: Integer; inline;
    function GetNumSoaJoints: Integer; inline;
    function GetJointParents: TOzzSpan<Int16>; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    property NumJoints: Integer read GetNumJoints;
    property NumSoaJoints: Integer read GetNumSoaJoints;
    property JointParents: TOzzSpan<Int16> read GetJointParents;
  end;

type
  TOzzAnimation = class(TOzzObject)
  {$REGION 'Internal Declarations'}
  private
    function GetDuration: Single; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    property Duration: Single read GetDuration;
  end;

type
  TOzzPart = class(TOzzObject)
  {$REGION 'Internal Declarations'}
  private
    FPositionCount: Integer;
    FPositions: PSingle;
    FNormalCount: Integer;
    FNormals: PSingle;
    FJointIndexCount: Integer;
    FJointIndices: PWord;
    FJointWeightCount: Integer;
    FJointWeights: PSingle;
  private
    constructor Create(const AHandle: _ozz_handle_t);
  {$ENDREGION 'Internal Declarations'}
  public
    property PositionCount: Integer read FPositionCount;
    property Positions: PSingle read FPositions;
    property NormalCount: Integer read FNormalCount;
    property Normals: PSingle read FNormals;
    property JointIndexCount: Integer read FJointIndexCount;
    property JointIndices: PWord read FJointIndices;
    property JointWeightCount: Integer read FJointWeightCount;
    property JointWeights: PSingle read FJointWeights;
  end;

type
  TOzzMesh = class(TOzzObject)
  {$REGION 'Internal Declarations'}
  private
    FPartCount: Integer;
    FTriangleIndexCount: Integer;
    FTriangleIndices: PWord;
    FParts: TArray<TOzzPart>;
    FJointRemaps: TArray<UInt16>;
    FInverseBindPoses: TArray<TMatrix4>;
    function GetPartCount: Integer; inline;
    function GetPart(const AIndex: Integer): TOzzPart;
    function GetJointCount: Integer; inline;
    function GetTriangleIndexCount: Integer; inline;
    function GetTriangleIndices: PWord; inline;
    function GetJointRemaps: TArray<UInt16>; inline;
    function GetInverseBindPoses: TArray<TMatrix4>; inline;
  private
    procedure UpdateJointRemaps;
    procedure UpdateInverseBindPoses;
    procedure UpdateTriangleIndices;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    property PartCount: Integer read GetPartCount;
    property Parts[const AIndex: Integer]: TOzzPart read GetPart;
    property JointCount: Integer read GetJointCount;
    property TriangleIndexCount: Integer read GetTriangleIndexCount;
    property TriangleIndices: PWord read GetTriangleIndices;
    property JointRemaps: TArray<UInt16> read GetJointRemaps;
    property InverseBindPoses: TArray<TMatrix4> read GetInverseBindPoses;
  end;

type
  TOzzSamplingCache = class(TOzzObject)
  public
    constructor Create;
    destructor Destroy; override;

    procedure Resize(const AMaxTracks: Integer); inline;
  end;

type
  TOzzSamplingJob = class(TOzzObject)
  {$REGION 'Internal Declarations'}
  private
    FAnimation: TOzzAnimation; // Reference
    FCache: TOzzSamplingCache; // Reference
    FOutput: TOzzSpan<TOzzSoaTransform>;
    FRatio: Single;
    procedure SetAnimation(const AValue: TOzzAnimation); inline;
    procedure SetCache(const AValue: TOzzSamplingCache); inline;
    procedure SetRatio(const AValue: Single); inline;
    procedure SetOutput(const AValue: TOzzSpan<TOzzSoaTransform>); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;
    procedure Run;

    property Animation: TOzzAnimation read FAnimation write SetAnimation;
    property Cache: TOzzSamplingCache read FCache write SetCache;
    property Ratio: Single read FRatio write SetRatio;
    property Output: TOzzSpan<TOzzSoaTransform> read FOutput write SetOutput;
  end;

type
  TOzzLocalToModelJob = class(TOzzObject)
  {$REGION 'Internal Declarations'}
  private
    FSkeleton: TOzzSkeleton; // Reference
    FInput: TOzzSpan<TOzzSoaTransform>;
    FOutput: TOzzSpan<TMatrix4>;
    procedure SetSkeleton(const AValue: TOzzSkeleton); inline;
    procedure SetInput(const AValue: TOzzSpan<TOzzSoaTransform>); inline;
    procedure SetOutput(const AValue: TOzzSpan<TMatrix4>); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;
    procedure Run;

    property Skeleton: TOzzSkeleton read FSkeleton write SetSkeleton;
    property Input: TOzzSpan<TOzzSoaTransform> read FInput write SetInput;
    property Output: TOzzSpan<TMatrix4> read FOutput write SetOutput;
  end;

type
  TOzzStream = class abstract(TOzzObject)
  public
    function Write(const ABuffer; const ASize: Integer): Integer; inline;
    function Seek(const AOffset: Integer; const AOrigin: TSeekOrigin): Integer;
  end;

type
  TOzzMemoryStream = class(TOzzStream)
  public
    constructor Create;
    destructor Destroy; override;
  end;

type
  TOzzIArchive = class(TOzzObject)
  public
    constructor Create(const AStream: TOzzStream);
    destructor Destroy; override;

    function TestTag<T: TOzzObject>: Boolean;
    procedure Load<T: TOzzObject>(const ATarget: T);
  end;

implementation

{ Ozz-Anim depends on the C++ library }
{$IF Defined(MACOS)}
procedure _Dummy; cdecl; external _LIB_OZZ_ANIM name _PU + 'Skeleton_Create' dependency 'c++';
{$ELSEIF Defined(ANDROID)}
{ NOTE: For some reason, we also need to pass these to the Delphi Linker options. }
procedure _Dummy; cdecl; external _LIB_OZZ_ANIM name _PU + 'Skeleton_Create' dependency 'c++_static' dependency 'c++abi';
{$ENDIF}

{ TOzzSpan<T> }

constructor TOzzSpan<T>.Create(const AValues: TArray<T>);
begin
  Init(AValues);
end;

constructor TOzzSpan<T>.Create(const AValues: TAlignedArray<T>);
begin
  Init(AValues)
end;

function TOzzSpan<T>.GetCount: Integer;
begin
  Result := FHandle.size;
end;

function TOzzSpan<T>.GetItem(const AIndex: Integer): T;
begin
  Assert(Cardinal(AIndex) < FHandle.size);
  {$POINTERMATH ON}
  Result := P(FHandle.data)[AIndex];
  {$POINTERMATH OFF}
end;

procedure TOzzSpan<T>.Init(const AValues: TAlignedArray<T>);
begin
  Assert(not IsManagedType(T));
  FHandle.data := AValues.Data;
  FHandle.size := AValues.Length;
end;

procedure TOzzSpan<T>.Init(const AValues: TArray<T>);
begin
  Assert(not IsManagedType(T));
  FHandle.data := Pointer(AValues);
  FHandle.size := Length(AValues);
end;

{ TOzzSkeleton }

constructor TOzzSkeleton.Create;
begin
  inherited;
  FHandle := _Skeleton_Create;
end;

destructor TOzzSkeleton.Destroy;
begin
  if (FHandle <> nil) then
    _Skeleton_Destroy(FHandle);
  inherited;
end;

function TOzzSkeleton.GetJointParents: TOzzSpan<Int16>;
begin
  _Skeleton_JointParents(FHandle, @Result.FHandle);
end;

function TOzzSkeleton.GetNumJoints: Integer;
begin
  Result := _Skeleton_NumJoints(FHandle);
end;

function TOzzSkeleton.GetNumSoaJoints: Integer;
begin
  Result := _Skeleton_NumSoaJoints(FHandle);
end;

{ TOzzAnimation }

constructor TOzzAnimation.Create;
begin
  inherited;
  FHandle := _Animation_Create;
end;

destructor TOzzAnimation.Destroy;
begin
  if (FHandle <> nil) then
    _Animation_Destroy(FHandle);
  inherited;
end;

function TOzzAnimation.GetDuration: Single;
begin
  Result := _Animation_Duration(FHandle);
end;

{ TOzzPart }

constructor TOzzPart.Create(const AHandle: _ozz_handle_t);
begin
  inherited Create;
  if (AHandle = nil) then
    Exit;

  FHandle := AHandle;
  FPositions := _MeshPart_GetPositions(FHandle, @FPositionCount);
  FNormals := _MeshPart_GetNormals(FHandle, @FNormalCount);
  FJointIndices := PWord(_MeshPart_GetJointIndices(FHandle, @FJointIndexCount));
  FJointWeights := _MeshPart_GetJointWeights(FHandle, @FJointWeightCount);
end;

{ TOzzMesh }

constructor TOzzMesh.Create;
begin
  inherited;
  FHandle := _Mesh_Create;
  FPartCount := -1;
  FTriangleIndexCount := -1;
end;

destructor TOzzMesh.Destroy;
begin
  for var Part in FParts do
    Part.Free;

  if (FHandle <> nil) then
    _Mesh_Destroy(FHandle);
  inherited;
end;

function TOzzMesh.GetInverseBindPoses: TArray<TMatrix4>;
begin
  if (FInverseBindPoses = nil) then
    UpdateInverseBindPoses;
  Result := FInverseBindPoses;
end;

function TOzzMesh.GetJointCount: Integer;
begin
  if (FHandle = nil) then
    Result := 0
  else
    Result := _Mesh_NumJoints(FHandle);
end;

function TOzzMesh.GetJointRemaps: TArray<UInt16>;
begin
  if (FJointRemaps = nil) then
    UpdateJointRemaps;
  Result := FJointRemaps;
end;

function TOzzMesh.GetPart(const AIndex: Integer): TOzzPart;
begin
  if (FHandle = nil) then
    Exit(nil);

  if (FParts = nil) then
    SetLength(FParts, GetPartCount);

  Assert(Cardinal(AIndex) < Cardinal(FPartCount));
  if (FParts[AIndex] = nil) then
    FParts[AIndex] := TOzzPart.Create(_Mesh_GetPart(FHandle, AIndex));

  Result := FParts[AIndex];
end;

function TOzzMesh.GetPartCount: Integer;
begin
  if (FPartCount < 0) then
  begin
    if (FHandle = nil) then
      FPartCount := 0
    else
      FPartCount := _Mesh_NumParts(FHandle);
  end;
  Result := FPartCount;
end;

function TOzzMesh.GetTriangleIndexCount: Integer;
begin
  if (FTriangleIndexCount < 0) then
    UpdateTriangleIndices;

  Result := FTriangleIndexCount;
end;

function TOzzMesh.GetTriangleIndices: PWord;
begin
  if (FTriangleIndices = nil) then
    UpdateTriangleIndices;

  Result := FTriangleIndices;
end;

procedure TOzzMesh.UpdateInverseBindPoses;
begin
  if (FHandle = nil) then
    Exit;

  var Count := 0;
  var Poses := _Mesh_GetInverseBindPoses(FHandle, @Count);
  SetLength(FInverseBindPoses, Count);
  Move(Poses^, FInverseBindPoses[0], Count * SizeOf(TMatrix4));
end;

procedure TOzzMesh.UpdateJointRemaps;
begin
  if (FHandle = nil) then
    Exit;

  var Count := 0;
  var Remaps := _Mesh_GetJointRemaps(FHandle, @Count);
  SetLength(FJointRemaps, Count);
  Move(Remaps^, FJointRemaps[0], Count * SizeOf(UInt16));
end;

procedure TOzzMesh.UpdateTriangleIndices;
begin
  if (FHandle = nil) then
    Exit;

  FTriangleIndices := PWord(_Mesh_GetTriangleIndices(FHandle, @FTriangleIndexCount));
end;

{ TOzzSamplingCache }

constructor TOzzSamplingCache.Create;
begin
  inherited;
  FHandle := _SamplingCache_Create;
end;

destructor TOzzSamplingCache.Destroy;
begin
  _SamplingCache_Destroy(FHandle);
  inherited;
end;

procedure TOzzSamplingCache.Resize(const AMaxTracks: Integer);
begin
  _SamplingCache_Resize(FHandle, AMaxTracks);
end;

{ TOzzSamplingJob }

constructor TOzzSamplingJob.Create;
begin
  inherited;
  FHandle := _SamplingJob_Create;
end;

destructor TOzzSamplingJob.Destroy;
begin
  if (FHandle <> nil) then
    _SamplingJob_Destroy(FHandle);
  inherited;
end;

procedure TOzzSamplingJob.Run;
begin
  _SamplingJob_Run(FHandle);
end;

procedure TOzzSamplingJob.SetAnimation(const AValue: TOzzAnimation);
begin
  FAnimation := AValue;
  if (AValue = nil) then
    _SamplingJob_SetAnimation(FHandle, nil)
  else
    _SamplingJob_SetAnimation(FHandle, AValue.FHandle);
end;

procedure TOzzSamplingJob.SetCache(const AValue: TOzzSamplingCache);
begin
  FCache := AValue;
  if (AValue = nil) then
    _SamplingJob_SetCache(FHandle, nil)
  else
    _SamplingJob_SetCache(FHandle, AValue.FHandle);
end;

procedure TOzzSamplingJob.SetOutput(const AValue: TOzzSpan<TOzzSoaTransform>);
begin
  FOutput := AValue;
  _SamplingJob_SetOutput(FHandle, AValue.FHandle);
end;

procedure TOzzSamplingJob.SetRatio(const AValue: Single);
begin
  FRatio := AValue;
  _SamplingJob_SetRatio(FHandle, AValue);
end;

{ TOzzLocalToModelJob }

constructor TOzzLocalToModelJob.Create;
begin
  inherited;
  FHandle := _LocalToModelJob_Create;
end;

destructor TOzzLocalToModelJob.Destroy;
begin
  if (FHandle <> nil) then
    _LocalToModelJob_Destroy(FHandle);
  inherited;
end;

procedure TOzzLocalToModelJob.Run;
begin
  _LocalToModelJob_Run(FHandle);
end;

procedure TOzzLocalToModelJob.SetInput(const AValue: TOzzSpan<TOzzSoaTransform>);
begin
  FInput := AValue;
  _LocalToModelJob_SetInput(FHandle, AValue.FHandle);
end;

procedure TOzzLocalToModelJob.SetOutput(const AValue: TOzzSpan<TMatrix4>);
begin
  FOutput := AValue;
  _LocalToModelJob_SetOutput(FHandle, AValue.FHandle);
end;

procedure TOzzLocalToModelJob.SetSkeleton(const AValue: TOzzSkeleton);
begin
  FSkeleton := AValue;
  if (AValue = nil) then
    _LocalToModelJob_SetSkeleton(FHandle, nil)
  else
    _LocalToModelJob_SetSkeleton(FHandle, AValue.FHandle);
end;

{ TOzzStream }

function TOzzStream.Seek(const AOffset: Integer;
  const AOrigin: TSeekOrigin): Integer;
const
  ORIGIN_MAP: array [TSeekOrigin] of Integer = (2, 0, 1);
begin
  Result := _Stream_Seek(FHandle, AOffset, ORIGIN_MAP[AOrigin]);
end;

function TOzzStream.Write(const ABuffer; const ASize: Integer): Integer;
begin
  Result := _Stream_Write(FHandle, @ABuffer, ASize);
end;

{ TOzzMemoryStream }

constructor TOzzMemoryStream.Create;
begin
  inherited;
  FHandle := _MemoryStream_Create;
end;

destructor TOzzMemoryStream.Destroy;
begin
  if (FHandle <> nil) then
    _MemoryStream_Destroy(FHandle);
  inherited;
end;

{ TOzzIArchive }

constructor TOzzIArchive.Create(const AStream: TOzzStream);
begin
  inherited Create;
  if (AStream = nil) then
    FHandle := _IArchive_Create(nil)
  else
    FHandle := _IArchive_Create(AStream.FHandle);
end;

destructor TOzzIArchive.Destroy;
begin
  if (FHandle <> nil) then
    _IArchive_Destroy(FHandle);
  inherited;
end;

procedure TOzzIArchive.Load<T>(const ATarget: T);
begin
  var Target: _ozz_handle_t := nil;
  if Assigned(ATarget) then
    Target := ATarget.FHandle;

  if (T.InheritsFrom(TOzzSkeleton)) then
    _IArchive_Load_Skeleton(FHandle, Target)
  else if (T.InheritsFrom(TOzzAnimation)) then
    _IArchive_Load_Animation(FHandle, Target)
  else if (T.InheritsFrom(TOzzMesh)) then
    _IArchive_Load_Mesh(FHandle, Target);
end;

function TOzzIArchive.TestTag<T>: Boolean;
begin
  if (T.InheritsFrom(TOzzSkeleton)) then
    Result := (_IArchive_TestTag_Skeleton(FHandle) <> 0)
  else if (T.InheritsFrom(TOzzAnimation)) then
    Result := (_IArchive_TestTag_Animation(FHandle) <> 0)
  else if (T.InheritsFrom(TOzzMesh)) then
    Result := (_IArchive_TestTag_Mesh(FHandle) <> 0)
  else
    Result := False;
end;

end.

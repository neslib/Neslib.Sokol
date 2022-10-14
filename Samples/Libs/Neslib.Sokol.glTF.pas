unit Neslib.Sokol.glTF;
{ glTF 2.0 parser.

  For documentation, check out the Neslib.Sokol.glTF.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.glTF.md }

{$INCLUDE 'Neslib.Sokol.inc'}
{$MINENUMSIZE 4}

interface

uses
  System.SysUtils,
  Neslib.FastMath,
  Neslib.Cgltf.Api,
  Neslib.Sokol.Gfx;

type
  TglTFFileType = (
    Invalid = _cgltf_file_type_invalid,
    glTF    = _cgltf_file_type_gltf,
    glB     = _cgltf_file_type_glb);

type
  TglTFResult = (
    Success        = _cgltf_result_success,
    DataTooShort   = _cgltf_result_data_too_short,
    UnknownFormat  = _cgltf_result_unknown_format,
    InvalidJson    = _cgltf_result_invalid_json,
    InvalidGltf    = _cgltf_result_invalid_gltf,
    InvalidOptions = _cgltf_result_invalid_options,
    FileNotFound   = _cgltf_result_file_not_found,
    IOError        = _cgltf_result_io_error,
    OutOfMemory    = _cgltf_result_out_of_memory);

type
  TglTFBufferViewType = (
    Invalid  = _cgltf_buffer_view_type_invalid,
    Indices  = _cgltf_buffer_view_type_indices,
    Vertices = _cgltf_buffer_view_type_vertices);

type
  TglTFAttributeType = (
    Invalid  = _cgltf_attribute_type_invalid,
    Position = _cgltf_attribute_type_position,
    Normal   = _cgltf_attribute_type_normal,
    Tangent  = _cgltf_attribute_type_tangent,
    TexCoord = _cgltf_attribute_type_texcoord,
    Color    = _cgltf_attribute_type_color,
    Joints   = _cgltf_attribute_type_joints,
    Weights  = _cgltf_attribute_type_weights);

type
  TglTFComponentType = (
    Invalid = _cgltf_component_type_invalid,
    R8      = _cgltf_component_type_r_8,    // Int8
    R8U     = _cgltf_component_type_r_8u,   // UInt8
    R16     = _cgltf_component_type_r_16,   // Int16
    R16U    = _cgltf_component_type_r_16u,  // UInt16
    R32U    = _cgltf_component_type_r_32u,  // UInt32
    R32F    = _cgltf_component_type_r_32f); // Single

type
  TglTFType = (
    Invalid = _cgltf_type_invalid,
    Scalar  = _cgltf_type_scalar,
    Vec2    = _cgltf_type_vec2,
    Vec3    = _cgltf_type_vec3,
    Vec4    = _cgltf_type_vec4,
    Mat2    = _cgltf_type_mat2,
    Mat3    = _cgltf_type_mat3,
    Mat4    = _cgltf_type_mat4);

type
  TglTFPrimitiveType = (
    Points        = _cgltf_primitive_type_points,
    Lines         = _cgltf_primitive_type_lines,
    LineLoop      = _cgltf_primitive_type_line_loop,
    LineStrip     = _cgltf_primitive_type_line_strip,
    Triangles     = _cgltf_primitive_type_triangles,
    TriangleStrip = _cgltf_primitive_type_triangle_strip,
    TriangleFan   = _cgltf_primitive_type_triangle_fan);

type
  TglTFAlphaMode = (
    Opaque = _cgltf_alpha_mode_opaque,
    Mask   = _cgltf_alpha_mode_mask,
    Blend  = _cgltf_alpha_mode_blend);

type
  TglTFAnimationPathType = (
    Invalid     = _cgltf_animation_path_type_invalid,
    Translation = _cgltf_animation_path_type_translation,
    Rotation    = _cgltf_animation_path_type_rotation,
    Scale       = _cgltf_animation_path_type_scale,
    Weights     = _cgltf_animation_path_type_weights);

type
  TglTFInterpolationType = (
    Linear = _cgltf_interpolation_type_linear,
    Step   = _cgltf_interpolation_type_step,
    Spline = _cgltf_interpolation_type_cubic_spline);

type
  TglTFCameraType = (
    Invalid      = _cgltf_camera_type_invalid,
    Perspective  = _cgltf_camera_type_perspective,
    Orthographic = _cgltf_camera_type_orthographic);

type
  TglTFLightType = (
    Invalid     = _cgltf_light_type_invalid,
    Directional = _cgltf_light_type_directional,
    Point       = _cgltf_light_type_point,
    Spot        = _cgltf_light_type_spot);

type
  TglTFOptions = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _cgltf_options;
    function GetFileType: TglTFFileType; inline;
    procedure SetFileType(const AValue: TglTFFileType); inline;
    function GetUseDelphiMemoryManager: Boolean; inline;
    procedure SetUseDelphiMemoryManager(const AValue: Boolean);
    function GetJsonTokenCount: NativeInt; inline;
    procedure SetJsonTokenCount(const AValue: NativeInt); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    class function Create: TglTFOptions; static;
    procedure Init; inline;

    property FileType: TglTFFileType read GetFileType write SetFileType;
    property JsonTokenCount: NativeInt read GetJsonTokenCount write SetJsonTokenCount;
    property UseDelphiMemoryManager: Boolean read GetUseDelphiMemoryManager write SetUseDelphiMemoryManager;
  end;
  PglTFOptions = ^TglTFOptions;

type
  TglTFExtras = record
  public
    StartOffset: NativeInt;
    EndOffset: NativeInt;
  end;
  PglTFExtras = ^TglTFExtras;

type
  TglTFBuffer = record
  public
    Size: NativeInt;
    Uri: PAnsiChar;
    Data: Pointer;
    Extras: TglTFExtras;
  end;
  PglTFBuffer = ^TglTFBuffer;

type
  TglTFBufferView = record
  public
    Buffer: PglTFBuffer;
    Offset: NativeInt;
    Size: NativeInt;
    Stride: NativeInt;
    ViewType: TglTFBufferViewType;
    Extras: TglTFExtras;
  end;
  PglTFBufferView = ^TglTFBufferView;

type
  TglTFAccessorSparse = record
  public
    Count: NativeInt;
    IndicesBufferView: PglTFBufferView;
    IndicesByteOffset: NativeInt;
    IndicesComponentType: TglTFComponentType;
    ValuesBufferView: PglTFBufferView;
    ValuesByteOffset: NativeInt;
    Extras: TglTFExtras;
    IndicesExtras: TglTFExtras;
    ValuesExtras: TglTFExtras;
  end;
  PglTFAccessorSparse = ^TglTFAccessorSparse;

type
  TglTFAccessor = record
  {$REGION 'Internal Declarations'}
  private
    function GetGfxVertexFormat: TVertexFormat;
  {$ENDREGION 'Internal Declarations'}
  public
    ComponentType: TglTFComponentType;
    Normalized: LongBool;
    DataType: TglTFType;
    Offset: NativeInt;
    Count: NativeInt;
    Stride: NativeInt;
    BufferView: PglTFBufferView;
    HasMin: LongBool;
    Min: array [0..15] of Single;
    HasMax: LongBool;
    Max: array [0..15] of Single;
    IsSparse: LongBool;
    Sparse: TglTFAccessorSparse;
    Extras: TglTFExtras;
  public
    function ReadFloat(const AIndex: NativeInt; out AValue: Single;
      const AElementSize: NativeInt): Boolean; inline;
    function ReadIndex(const AIndex: NativeInt): NativeInt; inline;

    property GfxVertexFormat: TVertexFormat read GetGfxVertexFormat;
  end;
  PglTFAccessor = ^TglTFAccessor;

type
  TglTFAttribute = record
  public
    Name: PAnsiChar;
    AttrType: TglTFAttributeType;
    Index: Integer;
    Data: PglTFAccessor;
  end;
  PglTFAttribute = ^TglTFAttribute;

type
  TglTFImage = record
  public
    Name: PAnsiChar;
    Uri: PAnsiChar;
    BufferView: PglTFBufferView;
    MimeType: PAnsiChar;
    Extras: TglTFExtras;
  end;
  PglTFImage = ^TglTFImage;

type
  TglTFSampler = record
  {$REGION 'Internal Declarations'}
  private
    function GetGfxMagFilter: TFilter;
    function GetGfxMinFilter: TFilter;
    function GetGfxWrapS: TWrap;
    function GetGfxWrapT: TWrap;
  {$ENDREGION 'Internal Declarations'}
  public
    MagFilter: Integer;
    MinFilter: Integer;
    WrapS: Integer;
    WrapT: Integer;
    Extras: TglTFExtras;
  public
    property GfxMagFilter: TFilter read GetGfxMagFilter;
    property GfxMinFilter: TFilter read GetGfxMinFilter;
    property GfxWrapS: TWrap read GetGfxWrapS;
    property GfxWrapT: TWrap read GetGfxWrapT;
  end;
  PglTFSampler = ^TglTFSampler;

type
  TglTFTexture = record
  public
    Name: PAnsiChar;
    Image: PglTFImage;
    Sampler: PglTFSampler;
    Extras: TglTFExtras;
  end;
  PglTFTexture = ^TglTFTexture;

type
  TglTFTextureTransform = record
  public
    Offset: TVector2;
    Rotation: Single;
    Scale: TVector2;
    TexCoord: Integer;
  end;
  PglTFTextureTransform = ^TglTFTextureTransform;

type
  TglTFTextureView = record
  public
    Texture: PglTFTexture;
    TexCoord: Integer;
    Scale: Single;
    HasTransform: LongBool                      ;
    Transform: TglTFTextureTransform;
    Extras: TglTFExtras;
  end;
  PglTFTextureView = ^TglTFTextureView;

type
  TglTFPbrMetallicRoughness = record
  public
    BaseColorTexture: TglTFTextureView;
    MetallicRoughnessTexture: TglTFTextureView;
    BaseColorFactor: TVector4;
    MetallicFactor: Single;
    RoughnessFactor: Single;
    Extras: TglTFExtras;
  end;
  PglTFPbrMetallicRoughness = ^TglTFPbrMetallicRoughness;

type
  TglTFPbrSpecularGlossiness = record
  public
    DiffuseTexture: TglTFTextureView;
    SpecularGlossinessTexture: TglTFTextureView;
    DiffuseFactor: TVector4;
    SpecularFactor: TVector3;
    GlossinessFactor: Single;
  end;
  PglTFPbrSpecularGlossiness = ^TglTFPbrSpecularGlossiness;

type
  TglTFMaterial = record
  public
    Name: PAnsiChar;
    HasPbrMetallicRoughness: LongBool;
    HasPbrSpecularGlossiness: LongBool;
    PbrMetallicRoughness: TglTFPbrMetallicRoughness;
    PbrSpecularGlossiness: TglTFPbrSpecularGlossiness;
    NormalTexture: TglTFTextureView;
    OcclusionTexture: TglTFTextureView;
    EmissiveTexture: TglTFTextureView;
    EmissiveFactor: TVector3;
    AlphaMode: TglTFAlphaMode;
    AlphaCutoff: Single;
    DoubleSided: LongBool;
    Unlit: LongBool;
    Extras: TglTFExtras;
  end;
  PglTFMaterial= ^TglTFMaterial;

type
  TglTFMorphTarget = record
  public
    Attributes: PglTFAttribute;
    AttributeCount: NativeInt;
  end;
  PglTFMorphTarget = ^TglTFMorphTarget;

type
  TglTFPrimitive = record
  {$REGION 'Internal Declarations'}
  private
    function GetAttribute(const AIndex: Integer): PglTFAttribute; inline;
    function GetTarget(const AIndex: Integer): PglTFMorphTarget; inline;
    function GetGfxPrimitiveType: TPrimitiveType; inline;
    function GetGfxIndexType: TIndexType; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    PrimitiveType: TglTFPrimitiveType;
    Indices: PglTFAccessor;
    Material: PglTFMaterial;
    AttributeArray: PglTFAttribute;
    AttributeCount: NativeInt;
    TargetArray: PglTFMorphTarget;
    TargetCount: NativeInt;
    Extras: TglTFExtras;
  public
    property Attributes[const AIndex: Integer]: PglTFAttribute read GetAttribute;
    property Targets[const AIndex: Integer]: PglTFMorphTarget read GetTarget;
    property GfxPrimitiveType: TPrimitiveType read GetGfxPrimitiveType;
    property GfxIndexType: TIndexType read GetGfxIndexType;
  end;
  PglTFPrimitive = ^TglTFPrimitive;

type
  TglTFMesh = record
  {$REGION 'Internal Declarations'}
  private
    function GetPrimitive(const AIndex: Integer): PglTFPrimitive; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    Name: PAnsiChar;
    PrimitiveArray: PglTFPrimitive;
    PrimitiveCount: NativeInt;
    Weights: PSingle;
    WeightCount: NativeInt;
    Extras: TglTFExtras;
  public
    property Primitives[const AIndex: Integer]: PglTFPrimitive read GetPrimitive;
  end;
  PglTFMesh = ^TglTFMesh;

type
  PglTFNode = ^TglTFNode;
  PPglTFNode = ^PglTFNode;

  TglTFSkin = record
  public
    Name: PAnsiChar;
    Joints: PPglTFNode;
    JointCount: NativeInt;
    Skeleton: PglTFNode;
    InverseBindMatrices: PglTFAccessor;
    Extras: TglTFExtras;
  end;
  PglTFSkin = ^TglTFSkin;

  TglTFCameraPerspective = record
  public
    AspectRatio: Single;
    YFov: Single;
    ZFar: Single;
    ZNear: Single;
    Extras: TglTFExtras;
  end;
  PglTFCameraPerspective = ^TglTFCameraPerspective;

  TglTFCameraOrthographic = record
  public
    XMag: Single;
    YMag: Single;
    ZFar: Single;
    ZNear: Single;
    Extras: TglTFExtras;
  end;
  PglTFCameraOrthographic = ^TglTFCameraOrthographic;

  TglTFCam = record
  case Integer of
    0: (Perspective: TglTFCameraPerspective);
    1: (Orthographic: TglTFCameraOrthographic);
  end;

  TglTFCamera = record
  public
    Name: PAnsiChar;
    CameraType: TglTFCameraType;
    Cam: TglTFCam;
    Extras: TglTFExtras;
  end;
  PglTFCamera = ^TglTFCamera;

  TglTFLight = record
  public
    Name: PAnsiChar;
    Color: TVector3;
    Intensity: Single;
    LightType: TglTFLightType;
    Range: Single;
    SpotInnerConeAngle: Single;
    spotOuterCneAgle: Single;
  end;
  PglTFLight = ^TglTFLight;

  TglTFNode = record
  public
    Name: PAnsiChar;
    Parent: PglTFNode;
    Children: PPglTFNode;
    ChildCount: NativeInt;
    Skin: PglTFSkin;
    Mesh: PglTFMesh;
    Camera: PglTFCamera;
    Light: PglTFLight;
    Weights: PSingle;
    WeightCount: NativeInt;
    HasTranslation: LongBool;
    HasRotation: LongBool;
    HasScale: LongBool;
    HasMatrix: LongBool;
    Translation: TVector3;
    Rotation: TQuaternion;
    Scale: TVector3;
    Matrix: TMatrix4;
    Extras: TglTFExtras;
  public
    function TransformLocal: TMatrix4; inline;
    function TransformWorld: TMatrix4; inline;
  end;

type
  TglTFScene = record
  public
    Name: PAnsiChar;
    Nodes: PPglTFNode;
    NodeCount: NativeInt;
    Extras: TglTFExtras;
  end;
  PglTFScene = ^TglTFScene;

type
  TglTFAnimationSampler = record
  public
    Input: PglTFAccessor;
    Output: PglTFAccessor;
    Interpolation: TglTFInterpolationType;
    Extras: TglTFExtras;
  end;
  PglTFAnimationSampler = ^TglTFAnimationSampler;

type
  TglTFAnimationChannel = record
  public
    sampler: PglTFAnimationSampler;
    target_node: PglTFNode;
    target_path: _cgltf_animation_path_type;
    Extras: TglTFExtras;
  end;
  PglTFAnimationChannel = ^TglTFAnimationChannel;

type
  TglTFAnimation = record
  public
    Name: PAnsiChar;
    Samplers: PglTFAnimationSampler;
    SamplerCount: NativeInt;
    channels: _Pcgltf_animation_channel;
    channels_count: NativeInt;
    Extras: TglTFExtras;
  end;
  PglTFAnimation = ^TglTFAnimation;

type
  TglTFAsset = record
  public
    Copyright: PAnsiChar;
    Generator: PAnsiChar;
    Version: PAnsiChar;
    MinVersion: PAnsiChar;
    Extras: TglTFExtras;
  end;
  PglTFAsset = ^TglTFAsset;

type
  TglTFData = record
  {$REGION 'Internal Declarations'}
  private
    function GetAccessor(const AIndex: Integer): PglTFAccessor; inline;
    function GetAnimation(const AIndex: Integer): PglTFAnimation; inline;
    function GetBuffer(const AIndex: Integer): PglTFBuffer; inline;
    function GetBufferView(const AIndex: Integer): PglTFBufferView; inline;
    function GetCamera(const AIndex: Integer): PglTFCamera; inline;
    function GetImage(const AIndex: Integer): PglTFImage; inline;
    function GetLight(const AIndex: Integer): PglTFLight; inline;
    function GetMaterial(const AIndex: Integer): PglTFMaterial; inline;
    function GetMesh(const AIndex: Integer): PglTFMesh; inline;
    function GetNode(const AIndex: Integer): PglTFNode; inline;
    function GetSampler(const AIndex: Integer): PglTFSampler; inline;
    function GetScene(const AIndex: Integer): PglTFScene; inline;
    function GetSkin(const AIndex: Integer): PglTFSkin; inline;
    function GetTexture(const AIndex: Integer): PglTFTexture; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    FileType: TglTFFileType;
    FileData: Pointer;
    Asset: TglTFAsset;
    MeshArray: PglTFMesh;
    MeshCount: NativeInt;
    MaterialArray: PglTFMaterial;
    MaterialCount: NativeInt;
    AccessorArray: PglTFAccessor;
    AccessorCount: NativeInt;
    BufferViewArray: PglTFBufferView;
    BufferViewCount: NativeInt;
    BufferArray: PglTFBuffer;
    BufferCount: NativeInt;
    ImageArray: PglTFImage;
    ImageCount: NativeInt;
    TextureArray: PglTFTexture;
    TextureCount: NativeInt;
    SamplerArray: PglTFSampler;
    SamplerCount: NativeInt;
    SkinArray: PglTFSkin;
    SkinCount: NativeInt;
    CameraArray: PglTFCamera;
    CameraCount: NativeInt;
    LightArray: PglTFLight;
    LightCount: NativeInt;
    NodeArray: PglTFNode;
    NodeCount: NativeInt;
    SceneArray: PglTFScene;
    SceneCount: NativeInt;
    Scene: PglTFScene;
    AnimationArray: PglTFAnimation;
    AnimationCount: NativeInt;
    Extras: TglTFExtras;
    Json: PAnsiChar;
    JsonSize: NativeInt;
    ExtensionsUsed: PPAnsiChar;
    ExtensionsUsedCount: NativeInt;
    ExtensionsRequired: PPAnsiChar;
    ExtensionsRequiredCount: NativeInt;
    Bin: Pointer;
    BinSize: NativeInt;
    MemoryFree: procedure(AUserData, APtr: Pointer); cdecl;
    MemoryUserData: Pointer;
  public
    procedure Free; inline;
    function Validate: TglTFResult; inline;
    function GetExtrasAsJson(const AExtras: TglTFExtras): String;
    function BuildTransform(const ANode: PglTFNode): TMatrix4;

    { Compute indices from element pointers }
    function GetMeshIndex(const AMesh: PglTFMesh): Integer; inline;
    function GetMaterialIndex(const AMaterial: PglTFMaterial): Integer; inline;
    function GetAccessorIndex(const AAccessor: PglTFAccessor): Integer; inline;
    function GetBufferViewIndex(const ABufferView: PglTFBufferView): Integer; inline;
    function GetBufferIndex(const ABuffer: PglTFBuffer): Integer; inline;
    function GetImageIndex(const AImage: PglTFImage): Integer; inline;
    function GetTextureIndex(const ATexture: PglTFTexture): Integer; inline;
    function GetSamplerIndex(const ASampler: PglTFSampler): Integer; inline;
    function GetSkinIndex(const ASkin: PglTFSkin): Integer; inline;
    function GetCameraIndex(const ACamera: PglTFCamera): Integer; inline;
    function GetLightIndex(const ALight: PglTFLight): Integer; inline;
    function GetNodeIndex(const ANode: PglTFNode): Integer; inline;
    function GetSceneIndex(const AScene: PglTFScene): Integer; inline;
    function GetAnimationIndex(const AAnimation: PglTFAnimation): Integer; inline;

    property Meshes[const AIndex: Integer]: PglTFMesh read GetMesh;
    property Materials[const AIndex: Integer]: PglTFMaterial read GetMaterial;
    property Accessors[const AIndex: Integer]: PglTFAccessor read GetAccessor;
    property BufferViews[const AIndex: Integer]: PglTFBufferView read GetBufferView;
    property Buffers[const AIndex: Integer]: PglTFBuffer read GetBuffer;
    property Images[const AIndex: Integer]: PglTFImage read GetImage;
    property Textures[const AIndex: Integer]: PglTFTexture read GetTexture;
    property Samplers[const AIndex: Integer]: PglTFSampler read GetSampler;
    property Skins[const AIndex: Integer]: PglTFSkin read GetSkin;
    property Cameras[const AIndex: Integer]: PglTFCamera read GetCamera;
    property Lights[const AIndex: Integer]: PglTFLight read GetLight;
    property Nodes[const AIndex: Integer]: PglTFNode read GetNode;
    property Scenes[const AIndex: Integer]: PglTFScene read GetScene;
    property Animations[const AIndex: Integer]: PglTFAnimation read GetAnimation;
  end;
  PglTFData = ^TglTFData;

type
  { Entry point }
  TglTF = record // static
  public
    class function Parse(const AOptions: TglTFOptions; const ABuffer: Pointer;
      const ASize: Integer; out AData: PglTFData): TglTFResult; overload; static;
    class function Parse(const AOptions: TglTFOptions; const ABuffer: TBytes;
      out AData: PglTFData): TglTFResult; overload; static;

    class function LoadBuffers(const AOptions: TglTFOptions;
      const AData: TglTFData; const APath: String): TglTFResult; static;
  end;

implementation

{$POINTERMATH ON}

function AllocCallback(UserData: Pointer; Size: NativeUInt): Pointer; cdecl;
begin
  GetMem(Result, Size);
end;

procedure FreeCallback(UserData, Ptr: Pointer); cdecl;
begin
  FreeMem(Ptr);
end;

function ToFilter(const ASrc: Integer): TFilter; inline;
{ https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#samplerminfilter }
begin
  case ASrc of
    9728: Result := TFilter.Nearest;
    9729: Result := TFilter.Linear;
    9984: Result := TFilter.NearestMipmapNearest;
    9985: Result := TFilter.LinearMipmapNearest;
    9986: Result := TFilter.NearestMipmapLinear;
    9987: Result := TFilter.LinearMipmapLinear;
  else
    Result := TFilter.Linear;
  end;
end;

function ToWrap(const ASrc: Integer): TWrap; inline;
{ https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#samplerwraps }
begin
  case ASrc of
    33071: Result := TWrap.ClampToEdge;
    33648: Result := TWrap.MirroredRepeat;
    10497: Result := TWrap.Repeating;
  else
    Result := TWrap.Repeating
  end;
end;

function ToPrimitiveType(const ASrc: TglTFPrimitiveType): TPrimitiveType; inline;
begin
  case ASrc of
    TglTFPrimitiveType.Points       : Result := TPrimitiveType.Points;
    TglTFPrimitiveType.Lines        : Result := TPrimitiveType.Lines;
    TglTFPrimitiveType.LineStrip    : Result := TPrimitiveType.LineStrip;
    TglTFPrimitiveType.Triangles    : Result := TPrimitiveType.Triangles;
    TglTFPrimitiveType.TriangleStrip: Result := TPrimitiveType.TriangleStrip;
  else
    Result := TPrimitiveType.Default;
  end;
end;

{ TglTFOptions }

class function TglTFOptions.Create: TglTFOptions;
begin
  Result.Init;
end;

function TglTFOptions.GetFileType: TglTFFileType;
begin
  Result := TglTFFileType(FHandle.&type);
end;

function TglTFOptions.GetJsonTokenCount: NativeInt;
begin
  Result := FHandle.json_token_count;
end;

function TglTFOptions.GetUseDelphiMemoryManager: Boolean;
begin
  Result := Assigned(FHandle.memory_alloc);
end;

procedure TglTFOptions.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TglTFOptions.SetFileType(const AValue: TglTFFileType);
begin
  FHandle.&type := Ord(AValue);
end;

procedure TglTFOptions.SetJsonTokenCount(const AValue: NativeInt);
begin
  FHandle.json_token_count := AValue;
end;

procedure TglTFOptions.SetUseDelphiMemoryManager(const AValue: Boolean);
begin
  if (AValue) then
  begin
    FHandle.memory_alloc := AllocCallback;
    FHandle.memory_free := FreeCallback;
  end
  else
  begin
    FHandle.memory_alloc := nil;
    FHandle.memory_free := nil;
  end;
end;

{ TglTFAccessor }

function TglTFAccessor.GetGfxVertexFormat: TVertexFormat;
begin
  case ComponentType of
    TglTFComponentType.R8:
      if (DataType = TglTFType.Vec4) then
        if (Normalized) then
          Exit(TVertexFormat.Byte4N)
        else
          Exit(TVertexFormat.Byte4);

    TglTFComponentType.R8U:
      if (DataType = TglTFType.Vec4) then
        if (Normalized) then
          Exit(TVertexFormat.UByte4N)
        else
          Exit(TVertexFormat.UByte4);

    TglTFComponentType.R16:
      case DataType of
        TglTFType.Vec2:
          if (Normalized) then
            Exit(TVertexFormat.Short2N)
          else
            Exit(TVertexFormat.Short2);

        TglTFType.Vec4:
          if (Normalized) then
            Exit(TVertexFormat.Short4N)
          else
            Exit(TVertexFormat.Short4);
      end;

    TglTFComponentType.R32F:
      case DataType of
        TglTFType.Scalar:
          Exit(TVertexFormat.Float);

        TglTFType.Vec2:
          Exit(TVertexFormat.Float2);

        TglTFType.Vec3:
          Exit(TVertexFormat.Float3);

        TglTFType.Vec4:
          Exit(TVertexFormat.Float4);
      end;
  end;
  Result := TVertexFormat.Invalid;
end;

function TglTFAccessor.ReadFloat(const AIndex: NativeInt; out AValue: Single;
  const AElementSize: NativeInt): Boolean;
begin
  Result := (_cgltf_accessor_read_float(@Self, AIndex, @AValue, AElementSize) <> 0);
end;

function TglTFAccessor.ReadIndex(const AIndex: NativeInt): NativeInt;
begin
  Result := _cgltf_accessor_read_index(@Self, AIndex);
end;

{ TglTFSampler }

function TglTFSampler.GetGfxMagFilter: TFilter;
begin
  Result := ToFilter(MagFilter);
end;

function TglTFSampler.GetGfxMinFilter: TFilter;
begin
  Result := ToFilter(MinFilter);
end;

function TglTFSampler.GetGfxWrapS: TWrap;
begin
  Result := ToWrap(WrapS);
end;

function TglTFSampler.GetGfxWrapT: TWrap;
begin
  Result := ToWrap(WrapT);
end;

{ TglTFPrimitive }

function TglTFPrimitive.GetAttribute(const AIndex: Integer): PglTFAttribute;
begin
  Assert(Cardinal(AIndex) < Cardinal(AttributeCount));
  Result := @AttributeArray[AIndex];
end;

function TglTFPrimitive.GetGfxIndexType: TIndexType;
begin
  if (Indices <> nil) then
  begin
    if (Indices.ComponentType = TglTFComponentType.R16U) then
      Result := TIndexType.UInt16
    else
      Result := TIndexType.UInt32
  end
  else
    Result := TIndexType.None;
end;

function TglTFPrimitive.GetGfxPrimitiveType: TPrimitiveType;
begin
  Result := ToPrimitiveType(PrimitiveType);
end;

function TglTFPrimitive.GetTarget(const AIndex: Integer): PglTFMorphTarget;
begin
  Assert(Cardinal(AIndex) < Cardinal(TargetCount));
  Result := @TargetArray[AIndex];
end;

{ TglTFMesh }

function TglTFMesh.GetPrimitive(const AIndex: Integer): PglTFPrimitive;
begin
  Assert(Cardinal(AIndex) < Cardinal(PrimitiveCount));
  Result := @PrimitiveArray[AIndex];
end;

{ TglTFNode }

function TglTFNode.TransformLocal: TMatrix4;
begin
  _cgltf_node_transform_local(@Self, @Result);
end;

function TglTFNode.TransformWorld: TMatrix4;
begin
  _cgltf_node_transform_world(@Self, @Result);
end;

{ TglTFData }

function TglTFData.BuildTransform(const ANode: PglTFNode): TMatrix4;
begin
  var ParentTransform := TMatrix4.Identity;
  if Assigned(ANode.Parent) then
    ParentTransform := BuildTransform(ANode.Parent);

  if (ANode.HasMatrix) then
    { Needs testing, not sure if the element order is correct }
    Exit(ANode.Matrix);

  var Translate := TMatrix4.Identity;
  var Rotate := TMatrix4.Identity;
  var Scale := TMatrix4.Identity;

  if (ANode.HasTranslation) then
    Translate.InitTranslation(ANode.Translation);

  if (ANode.HasRotation) then
    Rotate := ANode.Rotation.ToMatrix;

  if (ANode.HasScale) then
    Scale.InitScaling(ANode.Scale);

  { NOTE: not sure if the multiplication order is correct }
  Result := ParentTransform * ((Scale * Rotate) * Translate);
end;

procedure TglTFData.Free;
begin
  _cgltf_free(@Self);
end;

function TglTFData.GetAccessor(const AIndex: Integer): PglTFAccessor;
begin
  Assert(Cardinal(AIndex) < Cardinal(AccessorCount));
  Result := @AccessorArray[AIndex];
end;

function TglTFData.GetAccessorIndex(const AAccessor: PglTFAccessor): Integer;
begin
  Assert(Assigned(AAccessor));
  Result := AAccessor - AccessorArray;
end;

function TglTFData.GetAnimation(const AIndex: Integer): PglTFAnimation;
begin
  Assert(Cardinal(AIndex) < Cardinal(AnimationCount));
  Result := @AnimationArray[AIndex];
end;

function TglTFData.GetAnimationIndex(const AAnimation: PglTFAnimation): Integer;
begin
  Assert(Assigned(AAnimation));
  Result := AAnimation - AnimationArray;
end;

function TglTFData.GetBuffer(const AIndex: Integer): PglTFBuffer;
begin
  Assert(Cardinal(AIndex) < Cardinal(BufferCount));
  Result := @BufferArray[AIndex];
end;

function TglTFData.GetBufferIndex(const ABuffer: PglTFBuffer): Integer;
begin
  Assert(Assigned(ABuffer));
  Result := ABuffer - BufferArray;
end;

function TglTFData.GetBufferView(const AIndex: Integer): PglTFBufferView;
begin
  Assert(Cardinal(AIndex) < Cardinal(BufferViewCount));
  Result := @BufferViewArray[AIndex];
end;

function TglTFData.GetBufferViewIndex(const ABufferView: PglTFBufferView): Integer;
begin
  Assert(Assigned(ABufferView));
  Result := ABufferView - BufferViewArray;
end;

function TglTFData.GetCamera(const AIndex: Integer): PglTFCamera;
begin
  Assert(Cardinal(AIndex) < Cardinal(CameraCount));
  Result := @CameraArray[AIndex];
end;

function TglTFData.GetCameraIndex(const ACamera: PglTFCamera): Integer;
begin
  Assert(Assigned(ACamera));
  Result := ACamera - CameraArray;
end;

function TglTFData.GetExtrasAsJson(const AExtras: TglTFExtras): String;
begin
  var Size: NativeInt := 0;
  if (_cgltf_copy_extras_json(@Self, @AExtras, nil, @Size) <> _cgltf_result_success)
    or (Size = 0)
  then
    Exit('');

  var Str: UTF8String;
  SetLength(Str, Size);
  _cgltf_copy_extras_json(@Self, @AExtras, Pointer(Str), @Size);
  Result := String(Str);
end;

function TglTFData.GetImage(const AIndex: Integer): PglTFImage;
begin
  Assert(Cardinal(AIndex) < Cardinal(ImageCount));
  Result := @ImageArray[AIndex];
end;

function TglTFData.GetImageIndex(const AImage: PglTFImage): Integer;
begin
  Assert(Assigned(AImage));
  Result := AImage - ImageArray;
end;

function TglTFData.GetLight(const AIndex: Integer): PglTFLight;
begin
  Assert(Cardinal(AIndex) < Cardinal(LightCount));
  Result := @LightArray[AIndex];
end;

function TglTFData.GetLightIndex(const ALight: PglTFLight): Integer;
begin
  Assert(Assigned(ALight));
  Result := ALight - LightArray;
end;

function TglTFData.GetMaterial(const AIndex: Integer): PglTFMaterial;
begin
  Assert(Cardinal(AIndex) < Cardinal(MaterialCount));
  Result := @MaterialArray[AIndex];
end;

function TglTFData.GetMaterialIndex(const AMaterial: PglTFMaterial): Integer;
begin
  Assert(Assigned(AMaterial));
  Result := AMaterial - MaterialArray;
end;

function TglTFData.GetMesh(const AIndex: Integer): PglTFMesh;
begin
  Assert(Cardinal(AIndex) < Cardinal(MeshCount));
  Result := @MeshArray[AIndex];
end;

function TglTFData.GetMeshIndex(const AMesh: PglTFMesh): Integer;
begin
  Assert(Assigned(AMesh));
  Result := AMesh - MeshArray;
end;

function TglTFData.GetNode(const AIndex: Integer): PglTFNode;
begin
  Assert(Cardinal(AIndex) < Cardinal(NodeCount));
  Result := @NodeArray[AIndex];
end;

function TglTFData.GetNodeIndex(const ANode: PglTFNode): Integer;
begin
  Assert(Assigned(ANode));
  Result := ANode - NodeArray;
end;

function TglTFData.GetSampler(const AIndex: Integer): PglTFSampler;
begin
  Assert(Cardinal(AIndex) < Cardinal(SamplerCount));
  Result := @SamplerArray[AIndex];
end;

function TglTFData.GetSamplerIndex(const ASampler: PglTFSampler): Integer;
begin
  Assert(Assigned(ASampler));
  Result := ASampler - SamplerArray;
end;

function TglTFData.GetScene(const AIndex: Integer): PglTFScene;
begin
  Assert(Cardinal(AIndex) < Cardinal(SceneCount));
  Result := @SceneArray[AIndex];
end;

function TglTFData.GetSceneIndex(const AScene: PglTFScene): Integer;
begin
  Assert(Assigned(AScene));
  Result := AScene - SceneArray;
end;

function TglTFData.GetSkin(const AIndex: Integer): PglTFSkin;
begin
  Assert(Cardinal(AIndex) < Cardinal(SkinCount));
  Result := @SkinArray[AIndex];
end;

function TglTFData.GetSkinIndex(const ASkin: PglTFSkin): Integer;
begin
  Assert(Assigned(ASkin));
  Result := ASkin - SkinArray;
end;

function TglTFData.GetTexture(const AIndex: Integer): PglTFTexture;
begin
  Assert(Cardinal(AIndex) < Cardinal(TextureCount));
  Result := @TextureArray[AIndex];
end;

function TglTFData.GetTextureIndex(const ATexture: PglTFTexture): Integer;
begin
  Assert(Assigned(ATexture));
  Result := ATexture - TextureArray;
end;

function TglTFData.Validate: TglTFResult;
begin
  Result := TglTFResult(_cgltf_validate(@Self));
end;

{ TglTF }

class function TglTF.LoadBuffers(const AOptions: TglTFOptions;
  const AData: TglTFData; const APath: String): TglTFResult;
begin
  Result := TglTFResult(_cgltf_load_buffers(@AOptions.FHandle, @AData,
    PUTF8Char(UTF8String(APath))));
end;

class function TglTF.Parse(const AOptions: TglTFOptions; const ABuffer: Pointer;
  const ASize: Integer; out AData: PglTFData): TglTFResult;
begin
  Result := TglTFResult(_cgltf_parse(@AOptions.FHandle, ABuffer, ASize, @AData));
end;

class function TglTF.Parse(const AOptions: TglTFOptions; const ABuffer: TBytes;
  out AData: PglTFData): TglTFResult;
begin
  Result := TglTFResult(_cgltf_parse(@AOptions.FHandle, Pointer(ABuffer),
    Length(ABuffer), @AData));
end;

initialization
  Assert(SizeOf(TglTFExtras) = SizeOf(_cgltf_extras));
  Assert(SizeOf(TglTFBuffer) = SizeOf(_cgltf_buffer));
  Assert(SizeOf(TglTFBufferView) = SizeOf(_cgltf_buffer_view));
  Assert(SizeOf(TglTFAccessorSparse) = SizeOf(_cgltf_accessor_sparse));
  Assert(SizeOf(TglTFAccessor) = SizeOf(_cgltf_accessor));
  Assert(SizeOf(TglTFAttribute) = SizeOf(_cgltf_attribute));
  Assert(SizeOf(TglTFImage) = SizeOf(_cgltf_image));
  Assert(SizeOf(TglTFSampler) = SizeOf(_cgltf_sampler));
  Assert(SizeOf(TglTFTexture) = SizeOf(_cgltf_texture));
  Assert(SizeOf(TglTFTextureTransform) = SizeOf(_cgltf_texture_transform));
  Assert(SizeOf(TglTFTextureView) = SizeOf(_cgltf_texture_view));
  Assert(SizeOf(TglTFPbrMetallicRoughness) = SizeOf(_cgltf_pbr_metallic_roughness));
  Assert(SizeOf(TglTFPbrSpecularGlossiness) = SizeOf(_cgltf_pbr_specular_glossiness));
  Assert(SizeOf(TglTFMaterial) = SizeOf(_cgltf_material));
  Assert(SizeOf(TglTFMorphTarget) = SizeOf(_cgltf_morph_target));
  Assert(SizeOf(TglTFPrimitive) = SizeOf(_cgltf_primitive));
  Assert(SizeOf(TglTFMesh) = SizeOf(_cgltf_mesh));
  Assert(SizeOf(TglTFSkin) = SizeOf(_cgltf_skin));
  Assert(SizeOf(TglTFCameraPerspective) = SizeOf(_cgltf_camera_perspective));
  Assert(SizeOf(TglTFCameraOrthographic) = SizeOf(_cgltf_camera_orthographic));
  Assert(SizeOf(TglTFCamera) = SizeOf(_cgltf_camera));
  Assert(SizeOf(TglTFLight) = SizeOf(_cgltf_light));
  Assert(SizeOf(TglTFNode) = SizeOf(_cgltf_node));
  Assert(SizeOf(TglTFScene) = SizeOf(_cgltf_scene));
  Assert(SizeOf(TglTFAnimationSampler) = SizeOf(_cgltf_animation_sampler));
  Assert(SizeOf(TglTFAnimationChannel) = SizeOf(_cgltf_animation_channel));
  Assert(SizeOf(TglTFAnimation) = SizeOf(_cgltf_animation));
  Assert(SizeOf(TglTFData) = SizeOf(_cgltf_data));

end.

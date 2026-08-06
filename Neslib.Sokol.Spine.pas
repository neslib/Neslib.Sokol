unit Neslib.Sokol.Spine;
{ A renderer for the spine-c runtime (see
  https://github.com/EsotericSoftware/spine-runtimes/tree/4.1/spine-c).

  IMPORTANT: Using this unit for purposes other than evaluation requires a
  Spine License. See https://esotericsoftware.com/spine-purchase

  For a user guide, check out the Neslib.Sokol.Spine.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.Spine.md }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  System.SysUtils,
  Neslib.FastMath,
  Neslib.Sokol.Api,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Types;

const
  SPINE_INVALID_ID        = _SSPINE_INVALID_ID;
  SPINE_MAX_SKINSET_SKINS = _SSPINE_MAX_SKINSET_SKINS;
  SPINE_MAX_STRING_SIZE   = _SSPINE_MAX_STRING_SIZE;

type
  TSpineLogItem = (
    Ok,
    MallocFailed,
    ContextPoolExhausted,
    AtlasPoolExhausted,
    SkeletonPoolExhausted,
    SkinsetPoolExhausted,
    InstancePoolExhausted,
    CannotDestroyDefaultContext,
    AtlasDescNoData,
    SpineAtlasCreationFailed,
    AllocImageFailed,
    AllocViewFailed,
    AllocSamplerFailed,
    SkeletonDescNoData,
    SkeletonDescNoAtlas,
    SkeletonAtlasNotValid,
    CreateSkeletonDataFromJsonFailed,
    CreateSkeletonDataFromBinaryFailed,
    SkinsetDescNoSkeleton,
    SkinsetSkeletonNotValid,
    SkinsetInvalidSkinHandle,
    InstanceDescNoSkeleton,
    InstanceSkeletonNotValid,
    InstanceAtlasNotValid,
    SpineSkeletonCreationFailed,
    SpineAnimationstateCreationFailed,
    SpineSkeletonclippingCreationFailed,
    CommandBufferFull,
    VertexBufferFull,
    IndexBufferFull,
    StringTruncated,
    AddCommitListenerFailed);

type
  _TSpineLogItemHelper = record helper for TSpineLogItem
  public
    function ToString: String;
  end;

type
  { Used in TSpineDesc to provide a logging function. Please be aware that
    without logging function, Neslib.Sokol.Spine will be completely silent, e.g.
    it will not report errors, warnings and validation layer messages. For
    maximum error verbosity, compile in debug mode and provide a compatible
    logger function in the TSpine.Setup call (for instance the standard logging
    function TSpineDesc.DefaultLogger).

    Parameters:
    * ALevel: log level
    * AItem: log item
    * AMessage: the log message corresponding to AItem.
    * ALineNr: line number in original sokol_spine.h file. }
  TSpineLogger = procedure(const ALevel: TLogLevel; const AItem: TSpineLogItem;
    const AMessage: String; const ALineNr: Integer) of object;

type
  TSpineResourceState= (
    Initial = _SSPINE_RESOURCESTATE_INITIAL,
    Alloc   = _SSPINE_RESOURCESTATE_ALLOC,
    Valid   = _SSPINE_RESOURCESTATE_VALID,
    Failed  = _SSPINE_RESOURCESTATE_FAILED,
    Invalid = _SSPINE_RESOURCESTATE_INVALID);

type
  TSpineRange = record
  {$REGION 'Internal Declarations'}
  private
    FBytes: TBytes;
    FHandle: _sspine_range;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a range from a TBytes memory buffer.

      Parameters:
        ABytes: the memory buffer }
    constructor Create(const ABytes: TBytes); overload;

    { Creates a range from a pointer to a memory buffer.

      Parameters:
        APointer: pointer to the memory buffer
        ASize: size of the memory buffer }
    constructor Create(const APointer: Pointer; const ASize: NativeInt); overload;

    { Creates a range from a generic memory buffer.

      Parameters:
        AData: the memory buffer }
    class function Create<T>(const [ref] AData: T): TSpineRange; overload; static;

    { Pointer to the data in the buffer }
    property Data: Pointer read FHandle.ptr write FHandle.ptr;

    { Size of the data in the buffer }
    property Size: NativeUInt read FHandle.size write FHandle.size;
  end;
  PSpineRange = ^TSpineRange;

type
  TSpineVec2 = TVector2;
  PSpineVec2 = PVector2;

type
  TSpineMat4 = TMatrix4;
  PSpineMat4 = PMatrix4;

type
  TSpineColor = TColor;
  PSpineColor = PColor;

type
  TSpineString = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_string;
    function GetLength: Integer; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    class operator Implicit(const ASrc: TSpineString): String; inline; static;
    function ToString: String;
    function ToUtf8: PUTF8Char; inline;

    property Valid: Boolean read FHandle.valid;
    property Truncated: Boolean read FHandle.truncated;
    property Length: Integer read GetLength;
  end;
  PSpineString = ^TSpineString;

type
  TSpineLayerTransform = record
  public
    Size: TSpineVec2;
    Origin: TSpineVec2;
  public
    { Helper function to convert this transform into a projection matrix }
    function ToMatrix: TSpineMat4; inline;
  end;
  PSpineLayerTransform = ^TSpineLayerTransform;

type
  TSpineBoneTransform = record
  public
    Position: TSpineVec2;

    { In degrees }
    Rotation: Single;

    Scale: TSpineVec2;

    { In degrees }
    Shear: TSpineVec2;
  end;
  PSpineBoneTransform = ^TSpineBoneTransform;

type
  TSpineContextDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sspine_context_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    MaxVertices: Integer;
    MaxCommands: Integer;
    ColorFormat: TPixelFormat;
    DepthFormat: TPixelFormat;
    SampleCount: Integer;
    ColorWriteMask: TColorMask;
  public
    { Initializes with default values }
    class function Create: TSpineContextDesc; inline; static;
    procedure Init;
  end;
  PSpineContextDesc = ^TSpineContextDesc;

type
  TSpineContextInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_context_info;
  {$ENDREGION 'Internal Declarations'}
  public
    { Current number of vertices }
    property NumVertices: Integer read FHandle.num_vertices;

    { Current number of indices }
    property NumIndices: Integer read FHandle.num_indices;

    { Current number of commands }
    property NumCommands: Integer read FHandle.num_commands;
  end;
  PSpineContextInfo = ^TSpineContextInfo;

type
  TSpineContext = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_context;
    function GetInfo: TSpineContextInfo; inline;
    function GetResourceState: TSpineResourceState; inline;
    function GetValid: Boolean; inline;
  private
    class function GetDefault: TSpineContext; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const ADesc: TSpineContextDesc);
    procedure Free; inline;

    { Draw a layer in this context (call once per context and frame in
      Neslib.Sokol.Gfx pass).
      Equivalent to TSpine.DrawLayer(AContext, ALayer, ATransform) }
    procedure DrawLayer(const ALayer: Integer;
      const ATransform: TSpineLayerTransform); inline;

    { The resource Id }
    property Id: Cardinal read FHandle.id write FHandle.id;

    { Current resource state }
    property ResourceState: TSpineResourceState read GetResourceState;

    { Shortcut for `ResourceState = TSpineResourceState.Valid` }
    property Valid: Boolean read GetValid;

    property Info: TSpineContextInfo read GetInfo;
  public
    class property Default: TSpineContext read GetDefault;
  end;
  PSpineContext = ^TSpineContext;

type
  TSpineImageInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_image_info;
    function GetFilename: TSpineString; inline;
    function GetImage: TImage; inline;
    function GetMagFilter: TFilter; inline;
    function GetMinFilter: TFilter; inline;
    function GetMipmapFilter: TFilter; inline;
    function GetSampler: TSampler; inline;
    function GetView: TView; inline;
    function GetWrapU: TWrap; inline;
    function GetWrapV: TWrap; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Valid: Boolean read FHandle.valid;
    property Image: TImage read GetImage;
    property View: TView read GetView;
    property Sampler: TSampler read GetSampler;
    property MinFilter: TFilter read GetMinFilter;
    property MagFilter: TFilter read GetMagFilter;
    property MipmapFilter: TFilter read GetMipmapFilter;
    property WrapU: TWrap read GetWrapU;
    property WrapV: TWrap read GetWrapV;
    property Width: Integer read FHandle.width;
    property Height: Integer read FHandle.height;
    property PremulAlpha: Boolean read FHandle.premul_alpha;
    property Filename: TSpineString read GetFilename;
  end;
  PSpineImageInfo = ^TSpineImageInfo;

type
  TSpineAtlasOverrides = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sspine_atlas_overrides);
    procedure InitFrom(const ASrc: _sspine_atlas_overrides);
  {$ENDREGION 'Internal Declarations'}
  public
    MinFilter: TFilter;
    MagFilter: TFilter;
    MipmapFilter: TFilter;
    WrapU: TWrap;
    WrapV: TWrap;
    PremulAlphaEnabled: Boolean;
    PremulAlphaDisabled: Boolean;
  end;
  PSpineAtlasOverrides = ^TSpineAtlasOverrides;

type
  TSpineAtlasDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sspine_atlas_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Data: TSpineRange;
    Overrides: TSpineAtlasOverrides;
  public
    { Initializes with default values }
    class function Create: TSpineAtlasDesc; inline; static;
    procedure Init;
  end;
  PSpineAtlasDesc = ^TSpineAtlasDesc;

type
  TSpineImage = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_image;
    function GetValid: Boolean; inline;
    function GetInfo: TSpineImageInfo; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    class operator Equal(const ALeft, ARight: TSpineImage): Boolean; inline; static;
    class operator NotEqual(const ALeft, ARight: TSpineImage): Boolean; inline; static;

    property Index: Integer read FHandle.index;
    property Valid: Boolean read GetValid;
    property Info: TSpineImageInfo read GetInfo;
  end;
  PSpineImage = ^TSpineImage;

type
  TSpineAtlasPageInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_atlas_page_info;
    function GetImage: TSpineImageInfo; inline;
    function GetOverrides: TSpineAtlasOverrides; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Valid: Boolean read FHandle.valid;
    property Image: TSpineImageInfo read GetImage;
    property Overrides: TSpineAtlasOverrides read GetOverrides;
  end;
  PSpineAtlasPageInfo = ^TSpineAtlasPageInfo;

type
  TSpineAtlasPage = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_atlas_page;
    function GetValid: Boolean; inline;
    function GetInfo: TSpineAtlasPageInfo; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    class operator Equal(const ALeft, ARight: TSpineAtlasPage): Boolean; inline; static;
    class operator NotEqual(const ALeft, ARight: TSpineAtlasPage): Boolean; inline; static;

    property Index: Integer read FHandle.index;
    property Valid: Boolean read GetValid;
    property Info: TSpineAtlasPageInfo read GetInfo;
  end;
  PSpineAtlasPage = ^TSpineAtlasPage;

type
  TSpineAtlas = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_atlas;
    function GetResourceState: TSpineResourceState; inline;
    function GetValid: Boolean; inline;
    function GetImageCount: Integer; inline;
    function GetImage(const AIndex: Integer): TSpineImage; inline;
    function GetPageCount: Integer; inline;
    function GetPage(const AIndex: Integer): TSpineAtlasPage; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const ADesc: TSpineAtlasDesc);
    procedure Free; inline;

    { The resource Id }
    property Id: Cardinal read FHandle.id write FHandle.id;

    { Current resource state }
    property ResourceState: TSpineResourceState read GetResourceState;

    { Shortcut for `ResourceState = TSpineResourceState.Valid` }
    property Valid: Boolean read GetValid;

    property ImageCount: Integer read GetImageCount;
    property Images[const AIndex: Integer]: TSpineImage read GetImage;

    property PageCount: Integer read GetPageCount;
    property Pages[const AIndex: Integer]: TSpineAtlasPage read GetPage;
  end;
  PSpineAtlas = ^TSpineAtlas;

type
  _TSpineImageHelper = record helper for TSpineImage
  {$REGION 'Internal Declarations'}
  private
    function GetAtlas: TSpineAtlas; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Atlas: TSpineAtlas read GetAtlas;
  end;

type
  _TSpineAtlasPageInfoHelper = record helper for TSpineAtlasPageInfo
  {$REGION 'Internal Declarations'}
  private
    function GetAtlas: TSpineAtlas; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Atlas: TSpineAtlas read GetAtlas;
  end;

type
  _TSpineAtlasPageHelper = record helper for TSpineAtlasPage
  {$REGION 'Internal Declarations'}
  private
    function GetAtlas: TSpineAtlas; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Atlas: TSpineAtlas read GetAtlas;
  end;

type
  TSpineAnimInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_anim_info;
    function GetName: TSpineString; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Valid: Boolean read FHandle.valid;
    property Index: Integer read FHandle.index;
    property Duration: Single read FHandle.duration;
    property Name: TSpineString read GetName;
  end;
  PSpineAnimInfo = ^TSpineAnimInfo;

type
  TSpineAnim = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_anim;
    function GetValid: Boolean; inline;
    function GetInfo: TSpineAnimInfo; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    class operator Equal(const ALeft, ARight: TSpineAnim): Boolean; inline; static;
    class operator NotEqual(const ALeft, ARight: TSpineAnim): Boolean; inline; static;

    property Index: Integer read FHandle.index;
    property Valid: Boolean read GetValid;
    property Info: TSpineAnimInfo read GetInfo;
  end;
  PSpineAnim = ^TSpineAnim;

type
  TSpineBoneInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_bone_info;
    function GetColor: TSpineColor; inline;
    function GetPose: TSpineBoneTransform; inline;
    function GetName: TSpineString; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Valid: Boolean read FHandle.valid;
    property Index: Integer read FHandle.index;
    property Length: Single read FHandle.length;
    property Pose: TSpineBoneTransform read GetPose;
    property Color: TSpineColor read GetColor;
    property Name: TSpineString read GetName;
  end;
  PSpineBoneInfo = ^TSpineBoneInfo;

type
  TSpineBone = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_bone;
    function GetInfo: TSpineBoneInfo; inline;
    function GetValid: Boolean; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    class operator Equal(const ALeft, ARight: TSpineBone): Boolean; inline; static;
    class operator NotEqual(const ALeft, ARight: TSpineBone): Boolean; inline; static;

    property Index: Integer read FHandle.index;
    property Valid: Boolean read GetValid;
    property Info: TSpineBoneInfo read GetInfo;
  end;
  PSpineBone = ^TSpineBone;

type
  _TSpineBoneInfoHelper = record helper for TSpineBoneInfo
  {$REGION 'Internal Declarations'}
  private
    function GetParentBone: TSpineBone; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property ParentBone: TSpineBone read GetParentBone;
  end;

type
  TSpineSlotInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_slot_info;
    function GetBone: TSpineBone; inline;
    function GetColor: TSpineColor; inline;
    function GetName: TSpineString; inline;
    function GetAttachmentName: TSpineString; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Valid: Boolean read FHandle.valid;
    property Index: Integer read FHandle.index;
    property Bone: TSpineBone read GetBone;
    property Color: TSpineColor read GetColor;
    property AttachmentName: TSpineString read GetAttachmentName;
    property Name: TSpineString read GetName;
  end;
  PSpineSlotInfo = ^TSpineSlotInfo;

type
  TSpineSlot = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_slot;
    function GetInfo: TSpineSlotInfo; inline;
    function GetValid: Boolean; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    class operator Equal(const ALeft, ARight: TSpineSlot): Boolean; inline; static;
    class operator NotEqual(const ALeft, ARight: TSpineSlot): Boolean; inline; static;

    property Index: Integer read FHandle.index;
    property Valid: Boolean read GetValid;
    property Info: TSpineSlotInfo read GetInfo;
  end;
  PSpineSlot = ^TSpineSlot;

type
  TSpineEventInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_event_info;
    function GetName: TSpineString; inline;
    function GetAudioPath: TSpineString; inline;
    function GetStringValue: TSpineString; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Valid: Boolean read FHandle.valid;
    property Index: Integer read FHandle.index;
    property IntValue: Integer read FHandle.int_value;
    property FloatValue: Single read FHandle.float_value;
    property Volume: Single read FHandle.volume;
    property Balance: Single read FHandle.balance;
    property Name: TSpineString read GetName;
    property StringValue: TSpineString read GetStringValue;
    property AudioPath: TSpineString read GetAudioPath;
  end;
  PSpineEventInfo = ^TSpineEventInfo;

type
  TSpineEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_event;
    function GetInfo: TSpineEventInfo; inline;
    function GetValid: Boolean; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    class operator Equal(const ALeft, ARight: TSpineEvent): Boolean; inline; static;
    class operator NotEqual(const ALeft, ARight: TSpineEvent): Boolean; inline; static;

    property Index: Integer read FHandle.index;
    property Valid: Boolean read GetValid;
    property Info: TSpineEventInfo read GetInfo;
  end;
  PSpineEvent = ^TSpineEvent;

type
  TSpineIKTargetInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_iktarget_info;
    function GetTargetBone: TSpineBone; inline;
    function GetName: TSpineString; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Valid: Boolean read FHandle.valid;
    property Index: Integer read FHandle.index;
    property TargetBone: TSpineBone read GetTargetBone;
    property Name: TSpineString read GetName;
  end;
  PSpineIKTargetInfo = ^TSpineIKTargetInfo;

type
  TSpineIKTarget = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_iktarget;
    function GetInfo: TSpineIKTargetInfo;
    function GetValid: Boolean;
  {$ENDREGION 'Internal Declarations'}
  public
    class operator Equal(const ALeft, ARight: TSpineIKTarget): Boolean; inline; static;
    class operator NotEqual(const ALeft, ARight: TSpineIKTarget): Boolean; inline; static;

    property Index: Integer read FHandle.index;
    property Valid: Boolean read GetValid;
    property Info: TSpineIKTargetInfo read GetInfo;
  end;
  PSpineIKTarget = ^TSpineIKTarget;

type
  TSpineSkinInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_skin_info;
    function GetName: TSpineString; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Valid: Boolean read FHandle.valid;
    property Index: Integer read FHandle.index;
    property Name: TSpineString read GetName;
  end;
  PSpineSkinInfo = ^TSpineSkinInfo;

type
  TSpineSkin = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_skin;
    function GetInfo: TSpineSkinInfo;
    function GetValid: Boolean;
  {$ENDREGION 'Internal Declarations'}
  public
    class operator Equal(const ALeft, ARight: TSpineSkin): Boolean; inline; static;
    class operator NotEqual(const ALeft, ARight: TSpineSkin): Boolean; inline; static;

    property Index: Integer read FHandle.index;
    property Valid: Boolean read GetValid;
    property Info: TSpineSkinInfo read GetInfo;
  end;
  PSpineSkin = ^TSpineSkin;

type
  TSpineSkeletonDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sspine_skeleton_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Atlas: TSpineAtlas;
    Prescale: Single;
    AnimDefaultMix: Single;
    JsonData: UTF8String;
    BinaryData: TSpineRange;
  public
    { Initializes with default values }
    class function Create: TSpineSkeletonDesc; inline; static;
    procedure Init;
  end;
  PSpineSkeletonDesc = ^TSpineSkeletonDesc;

type
  TSpineSkeleton = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_skeleton;
    function GetResourceState: TSpineResourceState; inline;
    function GetValid: Boolean; inline;
    function GetAtlas: TSpineAtlas; inline;
    function GetAnimation(const AIndex: Integer): TSpineAnim; inline;
    function GetAnimationCount: Integer; inline;
    function GetBone(const AIndex: Integer): TSpineBone; inline;
    function GetBoneCount: Integer; inline;
    function GetSlot(const AIndex: Integer): TSpineSlot; inline;
    function GetSlotCount: Integer; inline;
    function GetEvent(const AIndex: Integer): TSpineEvent; inline;
    function GetEventCount: Integer; inline;
    function GetIKTarget(const AIndex: Integer): TSpineIKTarget; inline;
    function GetIKTargetCount: Integer; inline;
    function GetSkin(const AIndex: Integer): TSpineSkin; inline;
    function GetSkinCount: Integer; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const ADesc: TSpineSkeletonDesc);
    procedure Free; inline;

    function AnimByName(const AName: PUTF8Char): TSpineAnim; inline;
    function BoneByName(const AName: PUTF8Char): TSpineBone; inline;
    function SlotByName(const AName: PUTF8Char): TSpineSlot; inline;
    function EventByName(const AName: PUTF8Char): TSpineEvent; inline;
    function IKTargetByName(const AName: PUTF8Char): TSpineIKTarget; inline;
    function SkinByName(const AName: PUTF8Char): TSpineSkin; inline;

    { The resource Id }
    property Id: Cardinal read FHandle.id write FHandle.id;

    { Current resource state }
    property ResourceState: TSpineResourceState read GetResourceState;

    { Shortcut for `ResourceState = TSpineResourceState.Valid` }
    property Valid: Boolean read GetValid;

    property Atlas: TSpineAtlas read GetAtlas;

    { Instance animations }
    property AnimationCount: Integer read GetAnimationCount;
    property Animations[const AIndex: Integer]: TSpineAnim read GetAnimation;

    property BoneCount: Integer read GetBoneCount;
    property Bones[const AIndex: Integer]: TSpineBone read GetBone;

    property SlotCount: Integer read GetSlotCount;
    property Slots[const AIndex: Integer]: TSpineSlot read GetSlot;

    property EventCount: Integer read GetEventCount;
    property Events[const AIndex: Integer]: TSpineEvent read GetEvent;

    property IKTargetCount: Integer read GetIKTargetCount;
    property IKTargets[const AIndex: Integer]: TSpineIKTarget read GetIKTarget;

    property SkinCount: Integer read GetSkinCount;
    property Skins[const AIndex: Integer]: TSpineSkin read GetSkin;
  end;
  PSpineSkeleton = ^TSpineSkeleton;

type
  _TSpineAnimHelper = record helper for TSpineAnim
  {$REGION 'Internal Declarations'}
  private
    function GetSkeleton: TSpineSkeleton; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Skeleton: TSpineSkeleton read GetSkeleton;
  end;

type
  _TSpineBoneHelper = record helper for TSpineBone
  {$REGION 'Internal Declarations'}
  private
    function GetSkeleton: TSpineSkeleton; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Skeleton: TSpineSkeleton read GetSkeleton;
  end;

type
  _TSpineSlotHelper = record helper for TSpineSlot
  {$REGION 'Internal Declarations'}
  private
    function GetSkeleton: TSpineSkeleton; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Skeleton: TSpineSkeleton read GetSkeleton;
  end;

type
  _TSpineEventHelper = record helper for TSpineEvent
  {$REGION 'Internal Declarations'}
  private
    function GetSkeleton: TSpineSkeleton; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Skeleton: TSpineSkeleton read GetSkeleton;
  end;

type
  _TSpineIKTargetHelper = record helper for TSpineIKTarget
  {$REGION 'Internal Declarations'}
  private
    function GetSkeleton: TSpineSkeleton; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Skeleton: TSpineSkeleton read GetSkeleton;
  end;

type
  _TSpineSkinHelper = record helper for TSpineSkin
  {$REGION 'Internal Declarations'}
  private
    function GetSkeleton: TSpineSkeleton; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Skeleton: TSpineSkeleton read GetSkeleton;
  end;

type
  TSpineSkinsetDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sspine_skinset_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Skeleton: TSpineSkeleton;
    Skins: array [0..SPINE_MAX_SKINSET_SKINS - 1] of TSpineSkin;
  public
    { Initializes with default values }
    class function Create: TSpineSkinsetDesc; inline; static;
    procedure Init;
  end;
  PSpineSkinsetDesc = ^TSpineSkinsetDesc;

type
  TSpineSkinset = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_skinset;
    function GetResourceState: TSpineResourceState; inline;
    function GetValid: Boolean; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const ADesc: TSpineSkinsetDesc);
    procedure Free; inline;

    { The resource Id }
    property Id: Cardinal read FHandle.id write FHandle.id;

    { Current resource state }
    property ResourceState: TSpineResourceState read GetResourceState;

    { Shortcut for `ResourceState = TSpineResourceState.Valid` }
    property Valid: Boolean read GetValid;
  end;
  PSpineSkinset = ^TSpineSkinset;

type
  TSpineTriggeredEventInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_triggered_event_info;
    function GetStringValue: TSpineString; inline;
    function GetEvent: TSpineEvent; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Valid: Boolean read FHandle.valid;
    property Event: TSpineEvent read GetEvent;
    property Time: Single read FHandle.time;
    property IntValue: Integer read FHandle.int_value;
    property FloatValue: Single read FHandle.float_value;
    property Volume: Single read FHandle.volume;
    property Balance: Single read FHandle.balance;
    property StringValue: TSpineString read GetStringValue;
  end;
  PSpineTriggeredEventInfo = ^TSpineTriggeredEventInfo;

type
  TSpineInstanceDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sspine_instance_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Skeleton: TSpineSkeleton;
  public
    { Initializes with default values }
    class function Create: TSpineInstanceDesc; inline; static;
    procedure Init;
  end;
  PSpineInstanceDesc = ^TSpineInstanceDesc;

type
  TSpineInstance = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sspine_instance;
    function GetResourceState: TSpineResourceState; inline;
    function GetValid: Boolean; inline;
    function GetTriggeredEvent(const AIndex: Integer): TSpineTriggeredEventInfo; inline;
    function GetTriggeredEventCount: Integer; inline;
    function GetSkeleton: TSpineSkeleton; inline;
    function GetColor: TSpineColor; inline;
    function GetPosition: TSpineVec2; inline;
    function GetScale: TSpineVec2; inline;
    procedure SetColor(const AValue: TSpineColor); inline;
    procedure SetPosition(const AValue: TSpineVec2); inline;
    procedure SetScale(const AValue: TSpineVec2); inline;
    function GetBoneTransform(const ABone: TSpineBone): TSpineBoneTransform; inline;
    procedure SetBoneTransform(const ABone: TSpineBone;
      const AValue: TSpineBoneTransform); inline;
    function GetBonePosition(const ABone: TSpineBone): TSpineVec2; inline;
    procedure SetBonePosition(const ABone: TSpineBone; const AValue: TSpineVec2); inline;
    function GetBoneRotation(const ABone: TSpineBone): Single; inline;
    procedure SetBoneRotation(const ABone: TSpineBone; const AValue: Single); inline;
    function GetBoneScale(const ABone: TSpineBone): TSpineVec2; inline;
    procedure SetBoneScale(const ABone: TSpineBone; const AValue: TSpineVec2); inline;
    function GetBoneShear(const ABone: TSpineBone): TSpineVec2; inline;
    procedure SetBoneShear(const ABone: TSpineBone; const AValue: TSpineVec2); inline;
    function GetBoneWorldPosition(const ABone: TSpineBone): TSpineVec2; inline;
    function GetSlotColor(const ASlot: TSpineSlot): TSpineColor; inline;
    procedure SetSlotColor(const ASlot: TSpineSlot; const AValue: TSpineColor); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const ADesc: TSpineInstanceDesc);
    procedure Free; inline;

    { The resource Id }
    property Id: Cardinal read FHandle.id write FHandle.id;

    { Current resource state }
    property ResourceState: TSpineResourceState read GetResourceState;

    { Shortcut for `ResourceState = TSpineResourceState.Valid` }
    property Valid: Boolean read GetValid;

    { Configure instance appearance via skinsets }
    procedure SetSkinset(const ASkinset: TSpineSkinset); inline;

    { Update instance animations before drawing }
    procedure Update(const ADeltaTime: Single); inline;

    { Draw instance into current or explicit context }
    procedure Draw(const ALayer: Integer = 0); overload; inline;
    procedure Draw(const AContext: TSpineContext;
      const ALayer: Integer = 0); overload; inline;

    { Instance animation functions }
    procedure ClearAnimationTracks; inline;
    procedure ClearAnimationTrack(const ATrackIndex: Integer); inline;
    procedure SetAnimation(const AAnim: TSpineAnim; const ATrackIndex: Integer = 0;
      const ALoop: Boolean = False); inline;
    procedure AddAnimation(const AAnim: TSpineAnim; const ATrackIndex: Integer = 0;
      const ALoop: Boolean = False; const ADelay: Single = 0); inline;
    procedure SetEmptyAnimation(const ATrackIndex: Integer;
      const AMixDuration: Single); inline;
    procedure AddEmptyAnimation(const ATrackIndex: Integer;
      const AMixDuration: Single; const ADelay: Single = 0); inline;

    function BoneLocalToWorld(const ABone: TSpineBone;
      const ALocalPos: TSpineVec2): TSpineVec2; inline;
    function BoneWorldToLocal(const ABone: TSpineBone;
      const AWorldPos: TSpineVec2): TSpineVec2; inline;

    procedure SetIKTargetWorldPos(const AIKTarget: TSpineIKTarget;
      const AWorldPos: TSpineVec2); inline;
    procedure SetSkin(const ASkin: TSpineSkin); inline;

    { Iterate over triggered events after updating an instance }
    property TriggeredEventCount: Integer read GetTriggeredEventCount;
    property TriggeredEvents[const AIndex: Integer]: TSpineTriggeredEventInfo read GetTriggeredEvent;

    property Skeleton: TSpineSkeleton read GetSkeleton;

    { Intance transform }
    property Position: TSpineVec2 read GetPosition write SetPosition;
    property Scale: TSpineVec2 read GetScale write SetScale;
    property Color: TSpineColor read GetColor write SetColor;

    property BoneTransform[const ABone: TSpineBone]: TSpineBoneTransform read GetBoneTransform write SetBoneTransform;
    property BonePosition[const ABone: TSpineBone]: TSpineVec2 read GetBonePosition write SetBonePosition;
    property BoneRotation[const ABone: TSpineBone]: Single read GetBoneRotation write SetBoneRotation;
    property BoneScale[const ABone: TSpineBone]: TSpineVec2 read GetBoneScale write SetBoneScale;
    property BoneShear[const ABone: TSpineBone]: TSpineVec2 read GetBoneShear write SetBoneShear;
    property BoneWorldPosition[const ABone: TSpineBone]: TSpineVec2 read GetBoneWorldPosition;

    property SlotColor[const ASlot: TSpineSlot]: TSpineColor read GetSlotColor write SetSlotColor;
  end;
  PSpineInstance = ^TSpineInstance;

type
  _TSpineContextHelper = record helper for TSpineContext
  public
    { Draw instance into this context.
      Equivalent to TSpineInstance.Draw(AContext, ALayer). }
    procedure DrawInstance(const AInstance: TSpineInstance;
      const ALayer: Integer); inline;
  end;

type
  TSpineDesc = record
  {$REGION 'Internal Declarations'}
  private class var
    GLogger: TSpineLogger;
  private
    procedure Convert(out ADst: _sspine_desc);
  private
    class procedure LogCallback(const ATag: PUTF8Char; ALogLevel,
      ALogItemId: UInt32; const AMessageOrNull: PUTF8Char; ALineNr: UInt32;
      const AFilenameOrNull: PUTF8Char; AUserData: Pointer); cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    MaxVertices: Integer;
    MaxCommands: Integer;
    ContextPoolSize: Integer;
    AtlasPoolSize: Integer;
    SkeletonPoolSize: Integer;
    SkinsetPoolSize: Integer;
    InstancePoolSize: Integer;
    ColorFormat: TPixelFormat;
    DepthFormat: TPixelFormat;
    SampleCount: Integer;
    ColorWriteMask: TColorMask;

    { Whether to use Delphi's memory manager instead of Sokol's internal one.
      When SOKOL_MEM_TRACK is defined, it always uses Delphi's memory manager.
      Default: False }
    UseDelphiMemoryManager: Boolean;

    { Optional log function override }
    Logger: TSpineLogger;
  public
    { Initializes with default values }
    class function Create: TSpineDesc; inline; static;
    procedure Init;

    { A default log function you can assign to the Logger field. }
    procedure DefaultLogger(const ALevel: TLogLevel; const AItem: TSpineLogItem;
      const AMessage: String; const ALineNr: Integer);
  end;
  PSpineDesc = ^TSpineDesc;

type
  { Global Spine functionality. }
  TSpine = record // static
  {$REGION 'Internal Declarations'}
  private
    class function GetContext: TSpineContext; inline; static;
    class procedure SetContext(const AValue: TSpineContext); inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    { Setup and shutdown }
    class procedure Setup(const ADesc: TSpineDesc); static;
    class procedure Shutdown; static;

    { Draw a layer in current context or explicit context (call once per context
      and frame in Neslib.Sokol.Gfx pass) }
    class procedure DrawLayer(const ALayer: Integer;
      const ATransform: TSpineLayerTransform); overload; inline; static;
    class procedure DrawLayer(const AContext: TSpineContext; const ALayer: Integer;
      const ATransform: TSpineLayerTransform); overload; inline; static;

    { Active context }
    class property Context: TSpineContext read GetContext write SetContext;
  end;

implementation

uses
  Neslib.Sokol.Utils;

{ _TSpineLogItemHelper }

function _TSpineLogItemHelper.ToString: String;
const
  STRINGS: array [TSpineLogItem] of String = (
    'Ok',
    'memory allocation failed',
    'context pool exhausted (adjust via TSpineDesc.ContextPoolSize)',
    'atlas pool exhausted (adjust via TSpineDesc.AtlasPoolSize)',
    'skeleton pool exhausted (adjust via TSpineDesc.SkeletonPoolSize)',
    'skinset pool exhausted (adjust via TSpineDesc.SkinsetPoolSize)',
    'instance pool exhausted (adjust via TSpineDesc.InstancePoolSize)',
    'cannot destroy default context',
    'no data provided in TSpineAtlasDesc.Data',
    'TSpineAtlas.Create failed',
    'TImage.Alloc failed',
    'TView.Alloc failed',
    'TSampler.Alloc failed',
    'no data provided in TSpineSkeletonDesc.JsonData or .BinaryData',
    'no atlas object provided in TSpineSkeletonDesc.Atlas',
    'TSpineSkeletonDesc.Atlas is not in valid state',
    'spSkeletonJson_readSkeletonData failed',
    'spSkeletonBinary_readSkeletonData failed',
    'no skeleton object provided in TSpineSkinsetDesc.Skeleton',
    'TSpineSkinsetDesc.Skeleton is not in valid state',
    'invalid skin handle in TSpineSkinsetDesc.Skins[]',
    'no skeleton object provided in TSpineInstanceDesc.Skeleton',
    'TSpineInstanceDesc.Skeleton is not in valid state',
    'skeleton''s atlas object no longer valid via TSpineInstanceDesc.Skeleton',
    'spSkeleton_create failed',
    'spAnimationState_create failed',
    'spSkeletonClipping_create failed',
    'command buffer full (adjust via TSpineDesc.MaxCommands)',
    'vertex buffer (adjust via TSpineDesc.MaxVertices)',
    'index buffer full (adjust via TSpineDesc.MaxVertices)',
    'a string has been truncated',
    'setting TGfx.CommitListener failed');
begin
  Result := STRINGS[Self];
end;

{ TSpineContextDesc }

procedure TSpineContextDesc.Convert(out ADst: _sspine_context_desc);
begin
  ADst.max_vertices := MaxVertices;
  ADst.max_commands := MaxCommands;
  ADst.color_format := Ord(ColorFormat);
  ADst.depth_format := Ord(DepthFormat);
  ADst.sample_count := SampleCount;
  ADst.color_write_mask := Ord(ColorWriteMask);
end;

class function TSpineContextDesc.Create: TSpineContextDesc;
begin
  Result.Init;
end;

procedure TSpineContextDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TSpineImageInfo }

function TSpineImageInfo.GetFilename: TSpineString;
begin
  Result.FHandle := FHandle.filename;
end;

function TSpineImageInfo.GetImage: TImage;
begin
  Result := TImage(FHandle.sgimage);
end;

function TSpineImageInfo.GetMagFilter: TFilter;
begin
  Result := TFilter(FHandle.mag_filter);
end;

function TSpineImageInfo.GetMinFilter: TFilter;
begin
  Result := TFilter(FHandle.min_filter);
end;

function TSpineImageInfo.GetMipmapFilter: TFilter;
begin
  Result := TFilter(FHandle.mipmap_filter);
end;

function TSpineImageInfo.GetSampler: TSampler;
begin
  Result := TSampler(FHandle.sgsampler);
end;

function TSpineImageInfo.GetView: TView;
begin
  Result := TView(FHandle.sgview);
end;

function TSpineImageInfo.GetWrapU: TWrap;
begin
  Result := TWrap(FHandle.wrap_u);
end;

function TSpineImageInfo.GetWrapV: TWrap;
begin
  Result := TWrap(FHandle.wrap_v);
end;

{ TSpineAtlasOverrides }

procedure TSpineAtlasOverrides.Convert(out ADst: _sspine_atlas_overrides);
begin
  ADst.min_filter := Ord(MinFilter);
  ADst.mag_filter := Ord(MagFilter);
  ADst.mipmap_filter := Ord(MipmapFilter);
  ADst.wrap_u := Ord(WrapU);
  ADst.wrap_v := Ord(WrapV);
  ADst.premul_alpha_enabled := PremulAlphaEnabled;
  ADst.premul_alpha_disabled := PremulAlphaDisabled;
end;

procedure TSpineAtlasOverrides.InitFrom(const ASrc: _sspine_atlas_overrides);
begin
  MinFilter := TFilter(ASrc.min_filter);
  MagFilter := TFilter(ASrc.mag_filter);
  MipmapFilter := TFilter(ASrc.mipmap_filter);
  WrapU := TWrap(ASrc.wrap_u);
  WrapV := TWrap(ASrc.wrap_v);
  PremulAlphaEnabled := ASrc.premul_alpha_enabled;
  PremulAlphaDisabled := ASrc.premul_alpha_disabled;
end;

{ TSpineAtlasDesc }

procedure TSpineAtlasDesc.Convert(out ADst: _sspine_atlas_desc);
begin
  ADst.data := Data.FHandle;
  Overrides.Convert(ADst.override);
end;

class function TSpineAtlasDesc.Create: TSpineAtlasDesc;
begin
  Result.Init;
end;

procedure TSpineAtlasDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TSpineAtlasPageInfo }

function TSpineAtlasPageInfo.GetImage: TSpineImageInfo;
begin
  Result.FHandle := FHandle.image;
end;

function TSpineAtlasPageInfo.GetOverrides: TSpineAtlasOverrides;
begin
  Result.InitFrom(FHandle.overrides);
end;

{ TSpineSkeletonDesc }

procedure TSpineSkeletonDesc.Convert(out ADst: _sspine_skeleton_desc);
begin
  ADst.atlas := Atlas.FHandle;
  ADst.prescale := Prescale;
  ADst.anim_default_mix := AnimDefaultMix;
  if (JsonData = '') then
    ADst.json_data := nil
  else
    ADst.json_data := PUTF8Char(JsonData);
  ADst.binary_data := BinaryData.FHandle;
end;

class function TSpineSkeletonDesc.Create: TSpineSkeletonDesc;
begin
  Result.Init;
end;

procedure TSpineSkeletonDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TSpineSkinsetDesc }

procedure TSpineSkinsetDesc.Convert(out ADst: _sspine_skinset_desc);
begin
  ADst.skeleton := Skeleton.FHandle;
  Move(Skins, ADst.skins, SizeOf(Skins));
end;

class function TSpineSkinsetDesc.Create: TSpineSkinsetDesc;
begin
  Result.Init;
end;

procedure TSpineSkinsetDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TSpineAnimInfo }

function TSpineAnimInfo.GetName: TSpineString;
begin
  Result.FHandle := FHandle.name;
end;

{ TSpineBoneInfo }

function TSpineBoneInfo.GetColor: TSpineColor;
begin
  Result := TSpineColor(FHandle.color);
end;

function TSpineBoneInfo.GetName: TSpineString;
begin
  Result.FHandle := FHandle.name;
end;

function TSpineBoneInfo.GetPose: TSpineBoneTransform;
begin
  Result := TSpineBoneTransform(FHandle.pose);
end;

{ TSpineSlotInfo }

function TSpineSlotInfo.GetAttachmentName: TSpineString;
begin
  Result.FHandle := FHandle.attachment_name;
end;

function TSpineSlotInfo.GetBone: TSpineBone;
begin
  Result.FHandle := FHandle.bone;
end;

function TSpineSlotInfo.GetColor: TSpineColor;
begin
  Result := TSpineColor(FHandle.color);
end;

function TSpineSlotInfo.GetName: TSpineString;
begin
  Result.FHandle := FHandle.name;
end;

{ TSpineIKTargetInfo }

function TSpineIKTargetInfo.GetName: TSpineString;
begin
  Result.FHandle := FHandle.name;
end;

function TSpineIKTargetInfo.GetTargetBone: TSpineBone;
begin
  Result.FHandle := FHandle.target_bone;
end;

{ TSpineSkinInfo }

function TSpineSkinInfo.GetName: TSpineString;
begin
  Result.FHandle := FHandle.name;
end;

{ TSpineEventInfo }

function TSpineEventInfo.GetAudioPath: TSpineString;
begin
  Result.FHandle := FHandle.audio_path;
end;

function TSpineEventInfo.GetName: TSpineString;
begin
  Result.FHandle := FHandle.name;
end;

function TSpineEventInfo.GetStringValue: TSpineString;
begin
  Result.FHandle := FHandle.string_value;
end;

{ TSpineTriggeredEventInfo }

function TSpineTriggeredEventInfo.GetEvent: TSpineEvent;
begin
  Result.FHandle := FHandle.event;
end;

function TSpineTriggeredEventInfo.GetStringValue: TSpineString;
begin
  Result.FHandle := FHandle.string_value;
end;

{ TSpineInstanceDesc }

procedure TSpineInstanceDesc.Convert(out ADst: _sspine_instance_desc);
begin
  ADst.skeleton := Skeleton.FHandle;
end;

class function TSpineInstanceDesc.Create: TSpineInstanceDesc;
begin
  Result.Init;
end;

procedure TSpineInstanceDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TSpineDesc }

procedure TSpineDesc.Convert(out ADst: _sspine_desc);
begin
  FillChar(ADst, SizeOf(ADst), 0);
  ADst.max_vertices := MaxVertices;
  ADst.max_commands := MaxCommands;
  ADst.context_pool_size := ContextPoolSize;
  ADst.atlas_pool_size := AtlasPoolSize;
  ADst.skeleton_pool_size := SkeletonPoolSize;
  ADst.skinset_pool_size := SkinsetPoolSize;
  ADst.instance_pool_size := InstancePoolSize;
  ADst.color_format := Ord(ColorFormat);
  ADst.depth_format := Ord(DepthFormat);
  ADst.sample_count := SampleCount;
  ADst.color_write_mask := Ord(ColorWriteMask);

  {$IFDEF SOKOL_MEM_TRACK}
  ADst.allocator.alloc_fn := _MemTrackAlloc;
  ADst.allocator.free_fn := _MemTrackFree;
  {$ELSE}
  if (UseDelphiMemoryManager) then
  begin
    ADst.allocator.alloc_fn := _AllocCallback;
    ADst.allocator.free_fn := _FreeCallback;
  end;
  {$ENDIF}

  if Assigned(Logger) then
  begin
    GLogger := Logger;
    ADst.logger.func := LogCallback;
  end
end;

class function TSpineDesc.Create: TSpineDesc;
begin
  Result.Init;
end;

procedure TSpineDesc.DefaultLogger(const ALevel: TLogLevel;
  const AItem: TSpineLogItem; const AMessage: String; const ALineNr: Integer);
begin
  _LogDefault(ALevel, Ord(AItem), AMessage, ALineNr);
end;

procedure TSpineDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

class procedure TSpineDesc.LogCallback(const ATag: PUTF8Char; ALogLevel,
  ALogItemId: UInt32; const AMessageOrNull: PUTF8Char; ALineNr: UInt32;
  const AFilenameOrNull: PUTF8Char; AUserData: Pointer);
begin
  Assert(Assigned(GLogger));
  var Msg: String;
  if (ALogItemId <= Cardinal(Ord(High(TSpineLogItem)))) then
    Msg := TSpineLogItem(ALogItemId).ToString
  else
    Msg := String(UTF8String(AMessageOrNull));

  GLogger(TLogLevel(ALogLevel), TSpineLogItem(ALogItemId), Msg, ALineNr);
end;

{ TSpine }

class procedure TSpine.DrawLayer(const AContext: TSpineContext;
  const ALayer: Integer; const ATransform: TSpineLayerTransform);
begin
  _sspine_context_draw_layer(AContext.FHandle, ALayer, @ATransform);
end;

class procedure TSpine.DrawLayer(const ALayer: Integer;
  const ATransform: TSpineLayerTransform);
begin
  _sspine_draw_layer(ALayer, @ATransform);
end;

class function TSpine.GetContext: TSpineContext;
begin
  Result.FHandle := _sspine_get_context;
end;

class procedure TSpine.SetContext(const AValue: TSpineContext);
begin
  _sspine_set_context(AValue.FHandle);
end;

class procedure TSpine.Setup(const ADesc: TSpineDesc);
begin
  var Dst: _sspine_desc;
  ADesc.Convert(Dst);
  _sspine_setup(@Dst);
end;

class procedure TSpine.Shutdown;
begin
  _sspine_shutdown;
end;

{ TSpineContext }

constructor TSpineContext.Create(const ADesc: TSpineContextDesc);
begin
  var Dst: _sspine_context_desc;
  ADesc.Convert(Dst);
  FHandle := _sspine_make_context(@Dst);
end;

procedure TSpineContext.DrawLayer(const ALayer: Integer;
  const ATransform: TSpineLayerTransform);
begin
  _sspine_context_draw_layer(FHandle, ALayer, @ATransform);
end;

procedure TSpineContext.Free;
begin
  _sspine_destroy_context(FHandle);
end;

class function TSpineContext.GetDefault: TSpineContext;
begin
  Result.FHandle := _sspine_default_context;
end;

function TSpineContext.GetInfo: TSpineContextInfo;
begin
  Result.FHandle := _sspine_get_context_info(FHandle);
end;

function TSpineContext.GetResourceState: TSpineResourceState;
begin
  Result := TSpineResourceState(_sspine_get_context_resource_state(FHandle));
end;

function TSpineContext.GetValid: Boolean;
begin
  Result := _sspine_context_valid(FHandle);
end;

{ TSpineAtlas }

constructor TSpineAtlas.Create(const ADesc: TSpineAtlasDesc);
begin
  var Dst: _sspine_atlas_desc;
  ADesc.Convert(Dst);
  FHandle := _sspine_make_atlas(@Dst);
end;

procedure TSpineAtlas.Free;
begin
  _sspine_destroy_atlas(FHandle);
end;

function TSpineAtlas.GetImage(const AIndex: Integer): TSpineImage;
begin
  UInt64(Result.FHandle) := _sspine_image_by_index(FHandle, AIndex);
end;

function TSpineAtlas.GetImageCount: Integer;
begin
  Result := _sspine_num_images(FHandle);
end;

function TSpineAtlas.GetPage(const AIndex: Integer): TSpineAtlasPage;
begin
  UInt64(Result.FHandle) := _sspine_atlas_page_by_index(FHandle, AIndex);
end;

function TSpineAtlas.GetPageCount: Integer;
begin
  Result := _sspine_num_atlas_pages(FHandle);
end;

function TSpineAtlas.GetResourceState: TSpineResourceState;
begin
  Result := TSpineResourceState(_sspine_get_atlas_resource_state(FHandle));
end;

function TSpineAtlas.GetValid: Boolean;
begin
  Result := _sspine_atlas_valid(FHandle);
end;

{ TSpineSkeleton }

function TSpineSkeleton.AnimByName(const AName: PUTF8Char): TSpineAnim;
begin
  UInt64(Result.FHandle) := _sspine_anim_by_name(FHandle, AName);
end;

function TSpineSkeleton.BoneByName(const AName: PUTF8Char): TSpineBone;
begin
  UInt64(Result.FHandle) := _sspine_bone_by_name(FHandle, AName);
end;

constructor TSpineSkeleton.Create(const ADesc: TSpineSkeletonDesc);
begin
  var Dst: _sspine_skeleton_desc;
  ADesc.Convert(Dst);
  FHandle := _sspine_make_skeleton(@Dst);
end;

function TSpineSkeleton.EventByName(const AName: PUTF8Char): TSpineEvent;
begin
  UInt64(Result.FHandle) := _sspine_event_by_name(FHandle, AName);
end;

procedure TSpineSkeleton.Free;
begin
  _sspine_destroy_skeleton(FHandle);
end;

function TSpineSkeleton.GetAnimation(const AIndex: Integer): TSpineAnim;
begin
  UInt64(Result.FHandle) := _sspine_anim_by_index(FHandle, AIndex);
end;

function TSpineSkeleton.GetAnimationCount: Integer;
begin
  Result := _sspine_num_anims(FHandle);
end;

function TSpineSkeleton.GetAtlas: TSpineAtlas;
begin
  Result.FHandle := _sspine_get_skeleton_atlas(FHandle);
end;

function TSpineSkeleton.GetBone(const AIndex: Integer): TSpineBone;
begin
  UInt64(Result.FHandle) := _sspine_bone_by_index(FHandle, AIndex);
end;

function TSpineSkeleton.GetBoneCount: Integer;
begin
  Result := _sspine_num_bones(FHandle);
end;

function TSpineSkeleton.GetEvent(const AIndex: Integer): TSpineEvent;
begin
  UInt64(Result.FHandle) := _sspine_event_by_index(FHandle, AIndex);
end;

function TSpineSkeleton.GetEventCount: Integer;
begin
  Result := _sspine_num_events(FHandle);
end;

function TSpineSkeleton.GetIKTarget(const AIndex: Integer): TSpineIKTarget;
begin
  UInt64(Result.FHandle) := _sspine_iktarget_by_index(FHandle, AIndex);
end;

function TSpineSkeleton.GetIKTargetCount: Integer;
begin
  Result := _sspine_num_iktargets(FHandle);
end;

function TSpineSkeleton.GetResourceState: TSpineResourceState;
begin
  Result := TSpineResourceState(_sspine_get_skeleton_resource_state(FHandle));
end;

function TSpineSkeleton.GetSkin(const AIndex: Integer): TSpineSkin;
begin
  UInt64(Result.FHandle) := _sspine_skin_by_index(FHandle, AIndex);
end;

function TSpineSkeleton.GetSkinCount: Integer;
begin
  Result := _sspine_num_skins(FHandle);
end;

function TSpineSkeleton.GetSlot(const AIndex: Integer): TSpineSlot;
begin
  UInt64(Result.FHandle) := _sspine_slot_by_index(FHandle, AIndex);
end;

function TSpineSkeleton.GetSlotCount: Integer;
begin
  Result := _sspine_num_slots(FHandle);
end;

function TSpineSkeleton.GetValid: Boolean;
begin
  Result := _sspine_skeleton_valid(FHandle);
end;

function TSpineSkeleton.IKTargetByName(const AName: PUTF8Char): TSpineIKTarget;
begin
  UInt64(Result.FHandle) := _sspine_iktarget_by_name(FHandle, AName);
end;

function TSpineSkeleton.SkinByName(const AName: PUTF8Char): TSpineSkin;
begin
  UInt64(Result.FHandle) := _sspine_skin_by_name(FHandle, AName);
end;

function TSpineSkeleton.SlotByName(const AName: PUTF8Char): TSpineSlot;
begin
  UInt64(Result.FHandle) := _sspine_slot_by_name(FHandle, AName);
end;

{ TSpineInstance }

procedure TSpineInstance.AddAnimation(const AAnim: TSpineAnim;
  const ATrackIndex: Integer; const ALoop: Boolean; const ADelay: Single);
begin
  _sspine_add_animation(FHandle, AAnim.FHandle, ATrackIndex, ALoop, ADelay);
end;

procedure TSpineInstance.AddEmptyAnimation(const ATrackIndex: Integer;
  const AMixDuration, ADelay: Single);
begin
  _sspine_add_empty_animation(FHandle, ATrackIndex, AMixDuration, ADelay);
end;

function TSpineInstance.BoneLocalToWorld(const ABone: TSpineBone;
  const ALocalPos: TSpineVec2): TSpineVec2;
begin
  Result := TSpineVec2(_sspine_bone_local_to_world(FHandle, ABone.FHandle, _sspine_vec2(ALocalPos)));
end;

function TSpineInstance.BoneWorldToLocal(const ABone: TSpineBone;
  const AWorldPos: TSpineVec2): TSpineVec2;
begin
  Result := TSpineVec2(_sspine_bone_world_to_local(FHandle, ABone.FHandle, _sspine_vec2(AWorldPos)));
end;

procedure TSpineInstance.ClearAnimationTrack(const ATrackIndex: Integer);
begin
  _sspine_clear_animation_track(FHandle, ATrackIndex);
end;

procedure TSpineInstance.ClearAnimationTracks;
begin
  _sspine_clear_animation_tracks(FHandle);
end;

constructor TSpineInstance.Create(const ADesc: TSpineInstanceDesc);
begin
  var Dst: _sspine_instance_desc;
  ADesc.Convert(Dst);
  FHandle := _sspine_make_instance(@Dst);
end;

procedure TSpineInstance.Draw(const AContext: TSpineContext;
  const ALayer: Integer);
begin
  _sspine_context_draw_instance_in_layer(AContext.FHandle, FHandle, ALayer);
end;

procedure TSpineInstance.Draw(const ALayer: Integer);
begin
  _sspine_draw_instance_in_layer(FHandle, ALayer);
end;

procedure TSpineInstance.Free;
begin
  _sspine_destroy_instance(FHandle);
end;

function TSpineInstance.GetBonePosition(const ABone: TSpineBone): TSpineVec2;
begin
  Result := TSpineVec2(_sspine_get_bone_position(FHandle, ABone.FHandle));
end;

function TSpineInstance.GetBoneRotation(const ABone: TSpineBone): Single;
begin
  Result := _sspine_get_bone_rotation(FHandle, ABone.FHandle);
end;

function TSpineInstance.GetBoneScale(const ABone: TSpineBone): TSpineVec2;
begin
  Result := TSpineVec2(_sspine_get_bone_scale(FHandle, ABone.FHandle));
end;

function TSpineInstance.GetBoneShear(const ABone: TSpineBone): TSpineVec2;
begin
  Result := TSpineVec2(_sspine_get_bone_shear(FHandle, ABone.FHandle));
end;

function TSpineInstance.GetBoneTransform(
  const ABone: TSpineBone): TSpineBoneTransform;
begin
  Result := TSpineBoneTransform(_sspine_get_bone_transform(FHandle, ABone.FHandle));
end;

function TSpineInstance.GetBoneWorldPosition(
  const ABone: TSpineBone): TSpineVec2;
begin
  Result := TSpineVec2(_sspine_get_bone_world_position(FHandle, ABone.FHandle));
end;

function TSpineInstance.GetColor: TSpineColor;
begin
  Result := TSpineColor(_sspine_get_color(FHandle));
end;

function TSpineInstance.GetPosition: TSpineVec2;
begin
  Result := TSpineVec2(_sspine_get_position(FHandle));
end;

function TSpineInstance.GetResourceState: TSpineResourceState;
begin
  Result := TSpineResourceState(_sspine_get_instance_resource_state(FHandle));
end;

function TSpineInstance.GetScale: TSpineVec2;
begin
  Result := TSpineVec2(_sspine_get_scale(FHandle));
end;

function TSpineInstance.GetSkeleton: TSpineSkeleton;
begin
  Result.FHandle := _sspine_get_instance_skeleton(FHandle);
end;

function TSpineInstance.GetSlotColor(const ASlot: TSpineSlot): TSpineColor;
begin
  Result := TSpineColor(_sspine_get_slot_color(FHandle, ASlot.FHandle));
end;

function TSpineInstance.GetTriggeredEvent(
  const AIndex: Integer): TSpineTriggeredEventInfo;
begin
  Result.FHandle := _sspine_get_triggered_event_info(FHandle, AIndex);
end;

function TSpineInstance.GetTriggeredEventCount: Integer;
begin
  Result := _sspine_num_triggered_events(FHandle);
end;

function TSpineInstance.GetValid: Boolean;
begin
  Result := _sspine_instance_valid(FHandle);
end;

procedure TSpineInstance.SetAnimation(const AAnim: TSpineAnim;
  const ATrackIndex: Integer; const ALoop: Boolean);
begin
  _sspine_set_animation(FHandle, AAnim.FHandle, ATrackIndex, ALoop);
end;

procedure TSpineInstance.SetBonePosition(const ABone: TSpineBone;
  const AValue: TSpineVec2);
begin
  _sspine_set_bone_position(FHandle, ABone.FHandle, _sspine_vec2(AValue));
end;

procedure TSpineInstance.SetBoneRotation(const ABone: TSpineBone;
  const AValue: Single);
begin
  _sspine_set_bone_rotation(FHandle, ABone.FHandle, AValue);
end;

procedure TSpineInstance.SetBoneScale(const ABone: TSpineBone;
  const AValue: TSpineVec2);
begin
  _sspine_set_bone_scale(FHandle, ABone.FHandle, _sspine_vec2(AValue));
end;

procedure TSpineInstance.SetBoneShear(const ABone: TSpineBone;
  const AValue: TSpineVec2);
begin
  _sspine_set_bone_shear(FHandle, ABone.FHandle, _sspine_vec2(AValue));
end;

procedure TSpineInstance.SetBoneTransform(const ABone: TSpineBone;
  const AValue: TSpineBoneTransform);
begin
  _sspine_set_bone_transform(FHandle, ABone.FHandle, @AValue);
end;

procedure TSpineInstance.SetColor(const AValue: TSpineColor);
begin
  _sspine_set_color(FHandle, _sspine_color(AValue));
end;

procedure TSpineInstance.SetEmptyAnimation(const ATrackIndex: Integer;
  const AMixDuration: Single);
begin
  _sspine_set_empty_animation(FHandle, ATrackIndex, AMixDuration);
end;

procedure TSpineInstance.SetIKTargetWorldPos(const AIKTarget: TSpineIKTarget;
  const AWorldPos: TSpineVec2);
begin
  _sspine_set_iktarget_world_pos(FHandle, AIKTarget.FHandle, _sspine_vec2(AWorldPos));
end;

procedure TSpineInstance.SetPosition(const AValue: TSpineVec2);
begin
  _sspine_set_position(FHandle, _sspine_vec2(AValue));
end;

procedure TSpineInstance.SetScale(const AValue: TSpineVec2);
begin
  _sspine_set_scale(FHandle, _sspine_vec2(AValue));
end;

procedure TSpineInstance.SetSkin(const ASkin: TSpineSkin);
begin
  _sspine_set_skin(FHandle, ASkin.FHandle);
end;

procedure TSpineInstance.SetSkinset(const ASkinset: TSpineSkinset);
begin
  _sspine_set_skinset(FHandle, ASkinset.FHandle);
end;

procedure TSpineInstance.SetSlotColor(const ASlot: TSpineSlot;
  const AValue: TSpineColor);
begin
  _sspine_set_slot_color(FHandle, ASlot.FHandle, _sspine_color(AValue));
end;

procedure TSpineInstance.Update(const ADeltaTime: Single);
begin
  _sspine_update_instance(FHandle, ADeltaTime);
end;

{ _TSpineContextHelper }

procedure _TSpineContextHelper.DrawInstance(const AInstance: TSpineInstance;
  const ALayer: Integer);
begin
  _sspine_context_draw_instance_in_layer(FHandle, AInstance.FHandle, ALayer);
end;

{ TSpineString }

function TSpineString.GetLength: Integer;
begin
  Result := FHandle.len;
end;

class operator TSpineString.Implicit(const ASrc: TSpineString): String;
begin
  Result := ASrc.ToString;
end;

function TSpineString.ToString: String;
begin
  SetLength(Result, FHandle.len);
  for var I := 0 to Result.Length - 1 do
    Result[Low(String) + I] := Char(FHandle.cstr[I]);
end;

function TSpineString.ToUtf8: PUTF8Char;
begin
  Result := @FHandle.cstr;
end;

{ TSpineLayerTransform }

function TSpineLayerTransform.ToMatrix: TSpineMat4;
begin
  Result := TSpineMat4(_sspine_layer_transform_to_mat4(@Self));
end;

{ TSpineSkinset }

constructor TSpineSkinset.Create(const ADesc: TSpineSkinsetDesc);
begin
  var Dst: _sspine_skinset_desc;
  ADesc.Convert(Dst);
  FHandle := _sspine_make_skinset(@Dst);
end;

procedure TSpineSkinset.Free;
begin
  _sspine_destroy_skinset(FHandle);
end;

function TSpineSkinset.GetResourceState: TSpineResourceState;
begin
  Result := TSpineResourceState(_sspine_get_skinset_resource_state(FHandle));
end;

function TSpineSkinset.GetValid: Boolean;
begin
  Result := _sspine_skinset_valid(FHandle);
end;

{ TSpineRange }

constructor TSpineRange.Create(const ABytes: TBytes);
begin
  FBytes := ABytes;
  FHandle.ptr := Pointer(ABytes);
  FHandle.size := Length(ABytes);
end;

constructor TSpineRange.Create(const APointer: Pointer; const ASize: NativeInt);
begin
  FHandle.ptr := APointer;
  FHandle.size := ASize;
end;

class function TSpineRange.Create<T>(const [ref] AData: T): TSpineRange;
begin
  Result.FHandle.ptr := @AData;
  Result.FHandle.size := SizeOf(AData);
end;

{ _TSpineImageHelper }

function _TSpineImageHelper.GetAtlas: TSpineAtlas;
begin
  Result.FHandle.id := FHandle.atlas_id;
end;

{ TSpineImage }

class operator TSpineImage.Equal(const ALeft, ARight: TSpineImage): Boolean;
begin
  Result := _sspine_image_equal(ALeft.FHandle, ARight.FHandle);
end;

function TSpineImage.GetInfo: TSpineImageInfo;
begin
  Result.FHandle := _sspine_get_image_info(FHandle);
end;

function TSpineImage.GetValid: Boolean;
begin
  Result := _sspine_image_valid(FHandle);
end;

class operator TSpineImage.NotEqual(const ALeft, ARight: TSpineImage): Boolean;
begin
  Result := not _sspine_image_equal(ALeft.FHandle, ARight.FHandle);
end;

{ _TSpineAtlasPageInfoHelper }

function _TSpineAtlasPageInfoHelper.GetAtlas: TSpineAtlas;
begin
  Result.FHandle := FHandle.atlas;
end;

{ _TSpineAtlasPageHelper }

function _TSpineAtlasPageHelper.GetAtlas: TSpineAtlas;
begin
  Result.FHandle.id := FHandle.atlas_id;
end;

{ TSpineAtlasPage }

class operator TSpineAtlasPage.Equal(const ALeft,
  ARight: TSpineAtlasPage): Boolean;
begin
  Result := _sspine_atlas_page_equal(ALeft.FHandle, ARight.FHandle);
end;

function TSpineAtlasPage.GetInfo: TSpineAtlasPageInfo;
begin
  Result.FHandle := _sspine_get_atlas_page_info(FHandle);
end;

function TSpineAtlasPage.GetValid: Boolean;
begin
  Result := _sspine_atlas_page_valid(FHandle);
end;

class operator TSpineAtlasPage.NotEqual(const ALeft,
  ARight: TSpineAtlasPage): Boolean;
begin
  Result := not _sspine_atlas_page_equal(ALeft.FHandle, ARight.FHandle);
end;

{ _TSpineAnimHelper }

function _TSpineAnimHelper.GetSkeleton: TSpineSkeleton;
begin
  Result.FHandle.id := FHandle.skeleton_id;
end;

{ TSpineAnim }

class operator TSpineAnim.Equal(const ALeft, ARight: TSpineAnim): Boolean;
begin
  Result := _sspine_anim_equal(ALeft.FHandle, ARight.FHandle);
end;

function TSpineAnim.GetInfo: TSpineAnimInfo;
begin
  Result.FHandle := _sspine_get_anim_info(FHandle);
end;

function TSpineAnim.GetValid: Boolean;
begin
  Result := _sspine_anim_valid(FHandle);
end;

class operator TSpineAnim.NotEqual(const ALeft, ARight: TSpineAnim): Boolean;
begin
  Result := not _sspine_anim_equal(ALeft.FHandle, ARight.FHandle);
end;

{ _TSpineBoneHelper }

function _TSpineBoneHelper.GetSkeleton: TSpineSkeleton;
begin
  Result.FHandle.id := FHandle.skeleton_id;
end;

{ TSpineBone }

class operator TSpineBone.Equal(const ALeft, ARight: TSpineBone): Boolean;
begin
  Result := _sspine_bone_equal(ALeft.FHandle, ARight.FHandle);
end;

function TSpineBone.GetInfo: TSpineBoneInfo;
begin
  Result.FHandle := _sspine_get_bone_info(FHandle);
end;

function TSpineBone.GetValid: Boolean;
begin
  Result := _sspine_bone_valid(FHandle);
end;

class operator TSpineBone.NotEqual(const ALeft, ARight: TSpineBone): Boolean;
begin
  Result := not _sspine_bone_equal(ALeft.FHandle, ARight.FHandle);
end;

{ _TSpineBoneInfoHelper }

function _TSpineBoneInfoHelper.GetParentBone: TSpineBone;
begin
  Result.FHandle := FHandle.parent_bone;
end;

{ _TSpineSlotHelper }

function _TSpineSlotHelper.GetSkeleton: TSpineSkeleton;
begin
  Result.FHandle.id := FHandle.skeleton_id;
end;

{ TSpineSlot }

class operator TSpineSlot.Equal(const ALeft, ARight: TSpineSlot): Boolean;
begin
  Result := _sspine_slot_equal(ALeft.FHandle, ARight.FHandle);
end;

function TSpineSlot.GetInfo: TSpineSlotInfo;
begin
  Result.FHandle := _sspine_get_slot_info(FHandle);
end;

function TSpineSlot.GetValid: Boolean;
begin
  Result := _sspine_slot_valid(FHandle);
end;

class operator TSpineSlot.NotEqual(const ALeft, ARight: TSpineSlot): Boolean;
begin
  Result := not _sspine_slot_equal(ALeft.FHandle, ARight.FHandle);
end;

{ _TSpineEventHelper }

function _TSpineEventHelper.GetSkeleton: TSpineSkeleton;
begin
  Result.FHandle.id := FHandle.skeleton_id;
end;

{ TSpineEvent }

class operator TSpineEvent.Equal(const ALeft, ARight: TSpineEvent): Boolean;
begin
  Result := _sspine_event_equal(ALeft.FHandle, ARight.FHandle);
end;

function TSpineEvent.GetInfo: TSpineEventInfo;
begin
  Result.FHandle := _sspine_get_event_info(FHandle);
end;

function TSpineEvent.GetValid: Boolean;
begin
  Result := _sspine_event_valid(FHandle);
end;

class operator TSpineEvent.NotEqual(const ALeft, ARight: TSpineEvent): Boolean;
begin
  Result := not _sspine_event_equal(ALeft.FHandle, ARight.FHandle);
end;

{ _TSpineIKTargetHelper }

function _TSpineIKTargetHelper.GetSkeleton: TSpineSkeleton;
begin
  Result.FHandle.id := FHandle.skeleton_id;
end;

{ TSpineIKTarget }

class operator TSpineIKTarget.Equal(const ALeft,
  ARight: TSpineIKTarget): Boolean;
begin
  Result := _sspine_iktarget_equal(ALeft.FHandle, ARight.FHandle);
end;

function TSpineIKTarget.GetInfo: TSpineIKTargetInfo;
begin
  Result.FHandle := _sspine_get_iktarget_info(FHandle);
end;

function TSpineIKTarget.GetValid: Boolean;
begin
  Result := _sspine_iktarget_valid(FHandle);
end;

class operator TSpineIKTarget.NotEqual(const ALeft,
  ARight: TSpineIKTarget): Boolean;
begin
  Result := not _sspine_iktarget_equal(ALeft.FHandle, ARight.FHandle);
end;

{ _TSpineSkinHelper }

function _TSpineSkinHelper.GetSkeleton: TSpineSkeleton;
begin
  Result.FHandle.id := FHandle.skeleton_id;
end;

{ TSpineSkin }

class operator TSpineSkin.Equal(const ALeft, ARight: TSpineSkin): Boolean;
begin
  Result := _sspine_skin_equal(ALeft.FHandle, ARight.FHandle);
end;

function TSpineSkin.GetInfo: TSpineSkinInfo;
begin
  Result.FHandle := _sspine_get_skin_info(FHandle);
end;

function TSpineSkin.GetValid: Boolean;
begin
  Result := _sspine_skin_valid(FHandle);
end;

class operator TSpineSkin.NotEqual(const ALeft, ARight: TSpineSkin): Boolean;
begin
  Result := not _sspine_skin_equal(ALeft.FHandle, ARight.FHandle);
end;

end.

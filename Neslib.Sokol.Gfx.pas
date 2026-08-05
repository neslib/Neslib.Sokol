unit Neslib.Sokol.Gfx;
{ A modern and uniform cross-platform wrapper around graphics backend.

  For a user guide, check out the Neslib.Sokol.Gfx.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.Gfx.md }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  System.Types,
  System.UITypes,
  System.SysUtils,
  Neslib.Sokol.Api,
  Neslib.Sokol.Types;

type
  { A memory blob containing either a TBytes memory buffer or a pointer to
    memory stored at another location. }
  TRange = record
  {$REGION 'Internal Declarations'}
  private
    FBytes: TBytes;
    FHandle: _sg_range;
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
    class function Create<T>(const [ref] AData: T): TRange; overload; static;

    { Pointer to the data in the buffer }
    property Data: Pointer read FHandle.ptr write FHandle.ptr;

    { Size of the data in the buffer }
    property Size: NativeUInt read FHandle.size write FHandle.size;
  end;

const
  { Various compile-time constants }
  INVALID_ID                                    = _SG_INVALID_ID;
  NUM_INFLIGHT_FRAMES                           = _SG_NUM_INFLIGHT_FRAMES;
  MAX_COLOR_ATTACHMENTS                         = _SG_MAX_COLOR_ATTACHMENTS;
  MAX_UNIFORMBLOCK_MEMBERS                      = _SG_MAX_UNIFORMBLOCK_MEMBERS;
  MAX_VERTEX_ATTRIBUTES                         = _SG_MAX_VERTEX_ATTRIBUTES;
  MAX_MIPMAPS                                   = _SG_MAX_MIPMAPS;
  MAX_VERTEXBUFFER_BINDSLOTS                    = _SG_MAX_VERTEXBUFFER_BINDSLOTS;
  MAX_UNIFORMBLOCK_BINDSLOTS                    = _SG_MAX_UNIFORMBLOCK_BINDSLOTS;
  MAX_VIEW_BINDSLOTS                            = _SG_MAX_VIEW_BINDSLOTS;
  MAX_SAMPLER_BINDSLOTS                         = _SG_MAX_SAMPLER_BINDSLOTS;
  MAX_TEXTURE_SAMPLER_PAIRS                     = _SG_MAX_TEXTURE_SAMPLER_PAIRS;
  MAX_PORTABLE_COLOR_ATTACHMENTS                = _SG_MAX_PORTABLE_COLOR_ATTACHMENTS;
  MAX_PORTABLE_TEXTURE_BINDINGS_PER_STAGE       = _SG_MAX_PORTABLE_TEXTURE_BINDINGS_PER_STAGE;
  MAX_PORTABLE_STORAGEBUFFER_BINDINGS_PER_STAGE = _SG_MAX_PORTABLE_STORAGEBUFFER_BINDINGS_PER_STAGE;
  MAX_PORTABLE_STORAGEIMAGE_BINDINGS_PER_STAGE  = _SG_MAX_PORTABLE_STORAGEIMAGE_BINDINGS_PER_STAGE;

type
  { A floating-point RGBA color value }
  TColor = TAlphaColorF;
  PColor = PAlphaColorF;

type
  { The active 3D-API backend, use the property TGfx.Backend to get the
    currently active backend. }
  TBackend = (
    { OpenGL }
    GLCore     = _SG_BACKEND_GLCORE,

    { OpenGL-ES3 }
    Gles3      = _SG_BACKEND_GLES3,

    { DirectX 11 (Windows) }
    D3D11      = _SG_BACKEND_D3D11,

    { Metal (iOS) }
    MetalIOS   = _SG_BACKEND_METAL_IOS,

    { Metal (macOS) }
    MetalMacOS = _SG_BACKEND_METAL_MACOS,

    { Vulkan }
    Vulkan     = _SG_BACKEND_VULKAN,

    { Dummy }
    Dummy      = _SG_BACKEND_DUMMY);

type
  { Adds functionality to TBackend }
  _TBackendHelper = record helper for TBackend
  {$REGION 'Internal Declarations'}
  private
    function GetIsGL: Boolean; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Whether this is an OpenGL backend (GLCore or Gles3) }
    property IsGL: Boolean read GetIsGL;
  end;

type
  { This is a common subset of useful and widely supported pixel formats. The
    pixel format enum is mainly used when creating an image object in the
    TImageDesc.PixelFormat member.

    There is a record helper for TPixelFormat that provides information about
    the format (eg. TPixelFormat.Rgba8.ByteSize etc.).

    A pixelformat name consist of three parts:

      - components (R, RG, RGB or RGBA)
      - bit width per component (8, 16 or 32)
      - component data type:
          - unsigned normalized (no postfix)
          - signed normalized (SN postfix)
          - unsigned integer (UI postfix)
          - signed integer (SI postfix)
          - float (F postfix)

    Not all pixel formats can be used for everything. Use the record helper to
    inspect the capabilities of a given pixelformat:

      - Sample       : the pixelformat can be sampled as texture at least with
                       nearest filtering
      - Filter       : the pixelformat can be sampled as texture with linear
                       filtering
      - Render       : the pixelformat can be used as render-pass attachment
      - Blend        : blending is supported when used as render-pass attachment
      - Msaa         : multisample-antialiasing is supported when used as
                       render-pass attachment
      - IsDepth      : the pixelformat can be used for depth-stencil attachments
      - IsCompressed : this is a block-compressed format
      - CanRead      : supports compute shader read access
      - CanWrite     : supports compute shader write access
      - BytesPerPixel: the numbers of bytes in a pixel (0 for compressed
                       formats)

    The default pixel format for texture images is Rgba8.

    The default pixel format for render target images is platform-dependent
    and taken from the TEnvironment record passed into TGfx.Setup. Typically
    the default formats are:
      - for Metal and D3D11 it is Bgra8
      - for GL backends it is Rgba8 }
  TPixelFormat = (
    Default       = __SG_PIXELFORMAT_DEFAULT,
    None          = _SG_PIXELFORMAT_NONE,

    R8            = _SG_PIXELFORMAT_R8,
    R8SN          = _SG_PIXELFORMAT_R8SN,
    R8UI          = _SG_PIXELFORMAT_R8UI,
    R8SI          = _SG_PIXELFORMAT_R8SI,

    R16           = _SG_PIXELFORMAT_R16,
    R16SN         = _SG_PIXELFORMAT_R16SN,
    R16UI         = _SG_PIXELFORMAT_R16UI,
    R16SI         = _SG_PIXELFORMAT_R16SI,
    R16F          = _SG_PIXELFORMAT_R16F,
    Rg8           = _SG_PIXELFORMAT_RG8,
    Rg8SN         = _SG_PIXELFORMAT_RG8SN,
    Rg8UI         = _SG_PIXELFORMAT_RG8UI,
    Rg8SI         = _SG_PIXELFORMAT_RG8SI,

    R32UI         = _SG_PIXELFORMAT_R32UI,
    R32SI         = _SG_PIXELFORMAT_R32SI,
    R32F          = _SG_PIXELFORMAT_R32F,
    Rg16          = _SG_PIXELFORMAT_RG16,
    Rg16SN        = _SG_PIXELFORMAT_RG16SN,
    Rg16UI        = _SG_PIXELFORMAT_RG16UI,
    Rg16SI        = _SG_PIXELFORMAT_RG16SI,
    Rg16F         = _SG_PIXELFORMAT_RG16F,
    Rgba8         = _SG_PIXELFORMAT_RGBA8,
    sRgb8A8       = _SG_PIXELFORMAT_SRGB8A8,
    Rgba8SN       = _SG_PIXELFORMAT_RGBA8SN,
    Rgba8UI       = _SG_PIXELFORMAT_RGBA8UI,
    Rgba8SI       = _SG_PIXELFORMAT_RGBA8SI,
    Bgra8         = _SG_PIXELFORMAT_BGRA8,
    sBgr8A8       = _SG_PIXELFORMAT_SBGR8A8,
    Rgb10A2       = _SG_PIXELFORMAT_RGB10A2,
    Rg11B10F      = _SG_PIXELFORMAT_RG11B10F,
    Rgb9E5        = _SG_PIXELFORMAT_RGB9E5,

    Rg32UI        = _SG_PIXELFORMAT_RG32UI,
    Rg32SI        = _SG_PIXELFORMAT_RG32SI,
    Rg32F         = _SG_PIXELFORMAT_RG32F,
    Rgba16        = _SG_PIXELFORMAT_RGBA16,
    Rgba16SN      = _SG_PIXELFORMAT_RGBA16SN,
    Rgba16UI      = _SG_PIXELFORMAT_RGBA16UI,
    Rgba16SI      = _SG_PIXELFORMAT_RGBA16SI,
    Rgba16F       = _SG_PIXELFORMAT_RGBA16F,

    Rgba32UI      = _SG_PIXELFORMAT_RGBA32UI,
    Rgba32SI      = _SG_PIXELFORMAT_RGBA32SI,
    Rgba32F       = _SG_PIXELFORMAT_RGBA32F,

    Depth         = _SG_PIXELFORMAT_DEPTH,
    DepthStencil  = _SG_PIXELFORMAT_DEPTH_STENCIL,

    Bc1Rgba       = _SG_PIXELFORMAT_BC1_RGBA,
    Bc2Rgba       = _SG_PIXELFORMAT_BC2_RGBA,
    Bc3Rgba       = _SG_PIXELFORMAT_BC3_RGBA,
    Bc3sRgba      = _SG_PIXELFORMAT_BC3_SRGBA,
    Bc4R          = _SG_PIXELFORMAT_BC4_R,
    Bc4RSN        = _SG_PIXELFORMAT_BC4_RSN,
    Bc5Rg         = _SG_PIXELFORMAT_BC5_RG,
    Bc5_RgSN      = _SG_PIXELFORMAT_BC5_RGSN,
    Bc6HRgbF      = _SG_PIXELFORMAT_BC6H_RGBF,
    Bc6HRgbUF     = _SG_PIXELFORMAT_BC6H_RGBUF,
    Bc7Rgba       = _SG_PIXELFORMAT_BC7_RGBA,
    Bc7sRgba      = _SG_PIXELFORMAT_BC7_SRGBA,
    Etc2Rgb8      = _SG_PIXELFORMAT_ETC2_RGB8,
    Etc2sRgb8     = _SG_PIXELFORMAT_ETC2_SRGB8,
    Etc2Rgb8A1    = _SG_PIXELFORMAT_ETC2_RGB8A1,
    Etc2Rgba8     = _SG_PIXELFORMAT_ETC2_RGBA8,
    Etc2sRgb8A8   = _SG_PIXELFORMAT_ETC2_SRGB8A8,
    EacR11        = _SG_PIXELFORMAT_EAC_R11,
    EacR11SN      = _SG_PIXELFORMAT_EAC_R11SN,
    EacRG11       = _SG_PIXELFORMAT_EAC_RG11,
    EacRG11SN     = _SG_PIXELFORMAT_EAC_RG11SN,

    Astc4x4Rgba   = _SG_PIXELFORMAT_ASTC_4x4_RGBA,
    Astc4x4sRgba  = _SG_PIXELFORMAT_ASTC_4x4_SRGBA);

type
  {  Runtime information about a pixel format }
  _TPixelFormatHelper = record helper for TPixelFormat
  {$REGION 'Internal Declarations'}
  private class var
    FInfo: array [TPixelFormat] of _sg_pixelformat_info;
    FHasInfo: Boolean;
  private
    function GetBlend: Boolean; inline;
    function GetDepth: Boolean; inline;
    function GetFilter: Boolean; inline;
    function GetMsaa: Boolean; inline;
    function GetRender: Boolean; inline;
    function GetSample: Boolean; inline;
    function GetIsCompressed: Boolean; inline;
    function GetCanRead: Boolean; inline;
    function GetCanWrite: Boolean; inline;
    function GetBytesPerPixel: Integer; inline;
  private
    class procedure InitInfo; static;
  {$ENDREGION 'Internal Declarations'}
  public
    function RowPitch(const AWidth, ARowAlignBytes: Integer): Integer; inline;
    function SurfacePitch(const AWidth, AHeight, ARowAlignBytes: Integer): Integer; inline;

    { Pixel format can be sampled in shaders at least with nearest filtering }
    property Sample: Boolean read GetSample;

    { Pixel format can be sampled with linear filtering }
    property Filter: Boolean read GetFilter;

    { Pixel format can be used as render-pass attachment }
    property Render: Boolean read GetRender;

    { Pixel format supports alpha-blending when used as render-pass attachment }
    property Blend: Boolean read GetBlend;

    { Pixel format supports MSAA when used as render-pass attachment }
    property Msaa: Boolean read GetMsaa;

    { Pixel format is a depth format }
    property IsDepth: Boolean read GetDepth;

    { True if this is a hardware-compressed format }
    property IsCompressed: Boolean read GetIsCompressed;

    { True if format supports compute shader read access }
    property CanRead: Boolean read GetCanRead;

    { True if format supports compute shader write access }
    property CanWrite: Boolean read GetCanWrite;

    { Number of bytes per pixel. This is 0 for compressed formats. }
    property BytesPerPixel: Integer read GetBytesPerPixel;
  end;

type
  { Runtime information about available optional features, returned by
    TGfx.Features. }
  TFeature = (
    { Framebuffer- and texture-origin is in top left corner }
    OriginTopLeft,

    { Border color and clamp-to-border UV-wrap mode is supported }
    ImageClampToBorder,

    { Multiple-render-target rendering can use per-render-target blend state }
    MrtIndependentBlendState,

    { Multiple-render-target rendering can use per-render-target color write
      masks }
    MrtIndependentWriteMask,

    { Storage buffers and compute shaders are supported }
    Compute,

    { If set, multisampled images can be bound as textures }
    MsaaTextureBindings,

    { Cannot use the same buffer for vertex and indices }
    SeparateBufferTypes,

    { Draw with (base vertex > 0) and (base instance = 0) supported }
    DrawBaseVertex,

    { Draw with (base instance > 0) supported }
    DrawBaseInstance,

    { Dual-source-blending supported }
    DualSourceBlending,

    { TVertexFormat.Int10N2 is supported }
    VertexFormatInt10N2,

    { Supports 'proper' texture views (GL 4.3+) }
    GLTextureViews);
  TFeatures = set of TFeature;

type
  { Runtime information about resource limits, returned by TGfx.Limits }
  TLimits = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_limits;
  {$ENDREGION 'Internal Declarations'}
  public
    { Max width/height of TImageType.TwoD images }
    property MaxImageSize2D: Integer read FHandle.max_image_size_2d;

    { Max width/height of TImageType.Cube images }
    property MaxImageSizeCube: Integer read FHandle.max_image_size_cube;

    { Max width/height/depth of TImageType.ThreeD images }
    property MaxImageSize3D: Integer read FHandle.max_image_size_3d;

    { Max width/height of TImageType.Array images }
    property MaxImageSizeArray: Integer read FHandle.max_image_size_array;

    { Max number of layers in TImageType.Array images }
    property MaxImageArrayLayers: Integer read FHandle.max_image_array_layers;

    { Max number of vertex attributes, clamped to MAX_VERTEX_ATTRIBUTES }
    property MaxVertexAttrs: Integer read FHandle.max_vertex_attrs;

    { Max number of render pass color attachments, clamped to
      MAX_COLOR_ATTACHMENTS }
    property MaxColorAttachments: Integer read FHandle.max_color_attachments;

    { Max number of texture bindings per shader stage, clamped to
      MAX_VIEW_BINDSLOTS }
    property MaxTextureBindingsPerStage: Integer read FHandle.max_texture_bindings_per_stage;

    { Max number of storage buffer bindings per shader stage, clamped to
      MAX_VIEW_BINDSLOTS }
    property MaxStorageBufferBindingsPerStage: Integer read FHandle.max_storage_buffer_bindings_per_stage;

    { Max number of storage image bindings per shader stage, clamped to
      MAX_VIEW_BINDSLOTS }
    property MaxStorageImageBindingsPerStage: Integer read FHandle.max_storage_image_bindings_per_stage;

    { GL_MAX_VERTEX_UNIFORM_COMPONENTS (only on GL backends) }
    property GLMaxVertexUniformComponents: Integer read FHandle.gl_max_vertex_uniform_components;

    { GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS (only on GL backends) }
    property GLMaxCombinedTextureImageUnits: Integer read FHandle.gl_max_combined_texture_image_units;

    { 8 on feature level 11.0, otherwise 32 (clamped to MAX_VIEW_BINDSLOTS) }
    property D3D11MaxUnorderedAccessViews: Integer read FHandle.d3d11_max_unordered_access_views;

    property VKMinUniformBufferOffsetAlignment: Integer read FHandle.vk_min_uniform_buffer_offset_alignment;
  end;
  PLimits = ^TLimits;

type
  { The current state of a resource in its resource pool.
    Resources start in the Initial state, which means the pool slot is
    unoccupied and can be allocated. When a resource is created, first an id is
    allocated, and the resource pool slot is set to state Allocated. After
    allocation, the resource is initialized, which may result in the Valid or
    Failed state. The reason why allocation and initialization are separate is
    because some resource types (e.g. buffers and images) might be
    asynchronously initialized by the user application. If a resource which is
    not in the Valid state is attempted to be used for rendering, rendering
    operations will silently be dropped.

    The special Invalid state is used if no resource object exists for the
    provided resource id. }
  TResourceState = (
    { Initial state (pool slot is unoccupied and can be allocated) }
    Initial   = _SG_RESOURCESTATE_INITIAL,

    { After a resource has been created, but not yet initialized }
    Allocated = _SG_RESOURCESTATE_ALLOC,

    { After the resource has be successfully initialized }
    Valid     = _SG_RESOURCESTATE_VALID,

    { If resource initialization failed }
    Failed    = _SG_RESOURCESTATE_FAILED,

    { if no resource object exists for the provided resource id }
    Invalid   = _SG_RESOURCESTATE_INVALID);

type
  { Indicates whether indexed rendering (fetching vertex-indices from an index
    buffer) is used, and if yes, the index data type (16- or 32-bits).

    This is used in the TPipelineDesc.IndexType member when creating a pipeline
    object.

    The default index type is None. }
  TIndexType = (
    { No indexed rendering is used. }
    None   = _SG_INDEXTYPE_NONE,

    { Uses unsigned 16-bit integer indices. }
    UInt16 = _SG_INDEXTYPE_UINT16,

    { Uses unsigned 32-bit integer indices. }
    UInt32 = _SG_INDEXTYPE_UINT32);

type
  { Indicates the basic type of an image object (2D-texture, cubemap, 3D-texture
    or 2D-array-texture). Used in the TImageDesc.ImageType member when creating
    an image, and in TShaderImageDesc to describe a sampled texture in the
    shader (both must match and will be checked in the validation layer when
    calling TGfx.ApplyBindings).

    The default image type when creating an image is TwoD. }
  TImageType = (
    { A 2D texture }
    TwoD   = _SG_IMAGETYPE_2D,

    { A Cubemap texture }
    Cube   = _SG_IMAGETYPE_CUBE,

    { A 3D texture }
    ThreeD = _SG_IMAGETYPE_3D,

    { A 2D array texture }
    &Array = _SG_IMAGETYPE_ARRAY);

type
  { The basic data type of a texture sample as expected by a shader. Must be
    provided in TShaderImage and used by the validation layer in
    TGfx.ApplyBindings to check if the provided image object is compatible with
    what the shader expects. }
  TImageSampleType = (
    { Floating-point }
    Float             = _SG_IMAGESAMPLETYPE_FLOAT,

    { Depth }
    Depth             = _SG_IMAGESAMPLETYPE_DEPTH,

    { Signed integer }
    SignedInt         = _SG_IMAGESAMPLETYPE_SINT,

    { Unsigned integer }
    UnsignedInt       = _SG_IMAGESAMPLETYPE_UINT);

type
  { The basic type of a texture sampler (sampling vs comparison) as defined in a
    shader. Must be provided in TShaderSamplerDesc.

    TImageSampleType and TSamplerType for a texture/sampler pair must be
    compatible with each other, specifically only the following pairs are allowed:

    - TImageSampleType.Float => TSamplerType.Filtering or TSamplerType.NonFiltering
    - TImageSampleType.SignedInt => TSamplerType.NonFiltering
    - TImageSampleType.UnsignedInt => TSamplerType.NonFiltering
    - TImageSampleType.Depth => TSamplerType.Comparison }
  TSamplerType = (
    Filtering    = _SG_SAMPLERTYPE_FILTERING,
    NonFiltering = _SG_SAMPLERTYPE_NONFILTERING,
    Comparison   = _SG_SAMPLERTYPE_COMPARISON);

type
  { This is the common subset of 3D primitive types supported across all 3D
    APIs. This is used in the TPipelineDesc.PrimitiveType member when creating
    a pipeline object.

    The default primitive type is Triangles. }
  TPrimitiveType = (
    { Default (invalid) }
    Default       = __SG_PRIMITIVETYPE_DEFAULT,

    { A list of points }
    Points        = _SG_PRIMITIVETYPE_POINTS,

    { A list of lines }
    Lines         = _SG_PRIMITIVETYPE_LINES,

    { A line strip }
    LineStrip     = _SG_PRIMITIVETYPE_LINE_STRIP,

    { A list of triangles }
    Triangles     = _SG_PRIMITIVETYPE_TRIANGLES,

    { A triangle strip }
    TriangleStrip = _SG_PRIMITIVETYPE_TRIANGLE_STRIP);

type
  { The filtering mode when sampling a texture image. This is used in the
    TSamplerDesc.MinFilter, TSamplerDesc.MagFilter and TSamplerDesc.MipmapFilter
    members when creating a sampler object.

    The default filter mode is Nearest. }
  TFilter = (
    { Nearest neighbor filtering.
      Fastest, but lowest quality. }
    Nearest              = _SG_FILTER_NEAREST,

    { Linear filtering.
      Slower, but higher quality. }
    Linear               = _SG_FILTER_LINEAR);

type
  { The texture coordinates wrapping mode when sampling a texture image. This is
    used in the TImageDesc.WrapU, .WrapV and .WrapW members when creating an
    image.

    The default wrap mode is Repeating.

    NOTE: ClampToBorder is not supported on all backends and platforms. To check
    for support, use TGfx.Features and check the ImageClampToBorder flag.

    Platforms which don't support ClampToBorder will silently fall back to
    ClampToEdge without a validation error. }
  TWrap = (
    { Repeat texture }
    Repeating      = _SG_WRAP_REPEAT,

    { Repeat and mirror texture }
    MirroredRepeat = _SG_WRAP_MIRRORED_REPEAT,

    { Clamp to edge }
    ClampToEdge    = _SG_WRAP_CLAMP_TO_EDGE,

    { Clamp to border }
    ClampToBorder  = _SG_WRAP_CLAMP_TO_BORDER);

type
  { The border color to use when sampling a texture, and the UV wrap mode is
    TWrap.ClampToBorder.

    The default border color is OpaqueBlack. }
  TBorderColor = (
    { Transparent black }
    TransparentBlack = _SG_BORDERCOLOR_TRANSPARENT_BLACK,

    { Opaque black }
    OpaqueBlack      = _SG_BORDERCOLOR_OPAQUE_BLACK,

    { Opaque white }
    OpaqueWhite      = _SG_BORDERCOLOR_OPAQUE_WHITE);

type
  { The data type of a vertex component. This is used to describe the layout of
    input vertex data when creating a pipeline object.

    NOTE that specific mapping rules exist from the CPU-side vertex formats to
    the vertex attribute base type in the vertex shader code (see doc header
    section 'On Vertex Formats'). }
  TVertexFormat = (
    Invalid  = _SG_VERTEXFORMAT_INVALID,
    Float    = _SG_VERTEXFORMAT_FLOAT,
    Float2   = _SG_VERTEXFORMAT_FLOAT2,
    Float3   = _SG_VERTEXFORMAT_FLOAT3,
    Float4   = _SG_VERTEXFORMAT_FLOAT4,
    Int      = _SG_VERTEXFORMAT_INT,
    Int2     = _SG_VERTEXFORMAT_INT2,
    Int3     = _SG_VERTEXFORMAT_INT3,
    Int4     = _SG_VERTEXFORMAT_INT4,
    UInt     = _SG_VERTEXFORMAT_UINT,
    UInt2    = _SG_VERTEXFORMAT_UINT2,
    UInt3    = _SG_VERTEXFORMAT_UINT3,
    UInt4    = _SG_VERTEXFORMAT_UINT4,
    Byte4    = _SG_VERTEXFORMAT_BYTE4,
    Byte4N   = _SG_VERTEXFORMAT_BYTE4N,
    UByte4   = _SG_VERTEXFORMAT_UBYTE4,
    UByte4N  = _SG_VERTEXFORMAT_UBYTE4N,
    Short2   = _SG_VERTEXFORMAT_SHORT2,
    Short2N  = _SG_VERTEXFORMAT_SHORT2N,
    UShort2  = _SG_VERTEXFORMAT_USHORT2,
    UShort2N = _SG_VERTEXFORMAT_USHORT2N,
    Short4   = _SG_VERTEXFORMAT_SHORT4,
    Short4N  = _SG_VERTEXFORMAT_SHORT4N,
    UShort4  = _SG_VERTEXFORMAT_USHORT4,
    UShort4N = _SG_VERTEXFORMAT_USHORT4N,
    Int10N2  = _SG_VERTEXFORMAT_INT10_N2,
    UInt10N2 = _SG_VERTEXFORMAT_UINT10_N2,
    Half2    = _SG_VERTEXFORMAT_HALF2,
    Half4    = _SG_VERTEXFORMAT_HALF4);

type
  { Defines whether the input pointer of a vertex input stream is advanced
    'per vertex' or 'per instance'. The default step-func is PerVertex.
    PerInstance is used with instanced-rendering.

    The vertex-step is part of the vertex-layout definition when creating
    pipeline objects. }
  TVertexStep = (
    { Per vertex }
    PerVertex   = _SG_VERTEXSTEP_PER_VERTEX,

    { Per instance }
    PerInstance = _SG_VERTEXSTEP_PER_INSTANCE);

type
  { The data type of a uniform block member. This is used to describe the
    internal layout of uniform blocks when creating a shader object. This is
    only required for the GL backend, all other backends will ignore the
    interior layout of uniform blocks.}
  TUniformType = (
    Invalid = _SG_UNIFORMTYPE_INVALID,
    Float   = _SG_UNIFORMTYPE_FLOAT,
    Float2  = _SG_UNIFORMTYPE_FLOAT2,
    Float3  = _SG_UNIFORMTYPE_FLOAT3,
    Float4  = _SG_UNIFORMTYPE_FLOAT4,
    Int     = _SG_UNIFORMTYPE_INT,
    Int2    = _SG_UNIFORMTYPE_INT2,
    Int3    = _SG_UNIFORMTYPE_INT3,
    Int4    = _SG_UNIFORMTYPE_INT4,
    Mat4    = _SG_UNIFORMTYPE_MAT4);

type
  { A hint for the interior memory layout of uniform blocks. This is only
    relevant for the GL backend where the internal layout of uniform blocks must
    be known to Neslib.Sokol.Gfx. For all other backends the internal memory
    layout of uniform blocks doesn't matter, Neslib.Sokol.Gfx will just pass
    uniform data as an opaque memory blob to the 3D backend.

    The default is Native.

    For more information search for 'Uniform Data Layout' in the documentation
    block at the start of the header. }
  TUniformLayout = (
    { Native layout means that a 'backend-native' memory layout is used. For the
      GL backend this means that uniforms are packed tightly in memory (e.g.
      there are no padding bytes). }
    Native = _SG_UNIFORMLAYOUT_NATIVE,

    { The memory layout is a subset of std140. Arrays are only allowed for the
      Float4, Int4 and Mat4 types. Alignment is as is as follows:

        Float, Int:         4 byte alignment
        Float2, Int2:       8 byte alignment
        Float3, Int3:       16 byte alignment(!)
        Float4, Int4:       16 byte alignment
        Mat4:               16 byte alignment
        Float4[], Int4[]:   16 byte alignment

      The overall size of the uniform block must be a multiple of 16. }
    Std140 = _SG_UNIFORMLAYOUT_STD140);

type
  { The face-culling mode, this is used in the TPipelineDesc.CullMode field when
    creating a pipeline object.

    The default cull mode is None }
  TCullMode = (
    { Don't cull }
    None  = _SG_CULLMODE_NONE,

    { Cull front faces }
    Front = _SG_CULLMODE_FRONT,

    { Cull back faces }
    Back  = _SG_CULLMODE_BACK);

type
  { The vertex-winding rule that determines a front-facing primitive. This is
    used in the field TPipelineDesc.FaceWinding when creating a pipeline object.

    The default winding is ClockWise }
  TFaceWinding = (
    { Counter clockwise }
    CounterClockWise = _SG_FACEWINDING_CCW,

    { Clockwise }
    ClockWise        = _SG_FACEWINDING_CW);

type
  { The compare-function for configuring depth- and stencil-ref tests in
    pipeline objects, and for texture samplers which perform a comparison
    instead of regular sampling operation.

    Used in the following records:

    TPipelineDesc
        .Depth
            .Compare
        .Stencil
            .Front.Compare
            .Back.Compare

    TSamplerDesc
        .Compare

    The default compare func for depth- and stencil-tests is Always.
    The default compare func for samplers is Never. }
  TCompareFunc = (
    Never          = _SG_COMPAREFUNC_NEVER,
    Less           = _SG_COMPAREFUNC_LESS,
    Equal          = _SG_COMPAREFUNC_EQUAL,
    LessOrEqual    = _SG_COMPAREFUNC_LESS_EQUAL,
    Greater        = _SG_COMPAREFUNC_GREATER,
    NotEqual       = _SG_COMPAREFUNC_NOT_EQUAL,
    GreaterOrEqual = _SG_COMPAREFUNC_GREATER_EQUAL,
    Always         = _SG_COMPAREFUNC_ALWAYS);

type
  { The operation performed on a currently stored stencil-value when a
    comparison test passes or fails. This is used when creating a pipeline
    object in the following TPipelineDesc members:

    TPipelineDesc
        .Stencil
            .Front
                .FailOp
                .DepthFailOp
                .PassOp
            .Back
                .FailOp
                .DepthFailOp
                .PassOp

    The default value is Keep. }
  TStencilOp = (
    Keep      = _SG_STENCILOP_KEEP,
    Zero      = _SG_STENCILOP_ZERO,
    Replace   = _SG_STENCILOP_REPLACE,
    IncrClamp = _SG_STENCILOP_INCR_CLAMP,
    DecrClamp = _SG_STENCILOP_DECR_CLAMP,
    Invert    = _SG_STENCILOP_INVERT,
    IncrWrap  = _SG_STENCILOP_INCR_WRAP,
    DescWrap  = _SG_STENCILOP_DECR_WRAP);

type
  { The source and destination factors in blending operations.
    This is used in the following members when creating a pipeline object:

    TPipelineDesc
        .Colors[I]
            .Blend
                .SrcFactorRgb
                .DstFactorRgb
                .SrcFactorAlpha
                .DstFactorAlpha

    The default value is One for source factors, and for the destination Zero if
    the associated blend-op is Add, Subtract or ReverseSubtract or One if the
    associated blend-op is Min or Max. }
  TBlendFactor = (
    Zero               = _SG_BLENDFACTOR_ZERO,
    One                = _SG_BLENDFACTOR_ONE,
    SrcColor           = _SG_BLENDFACTOR_SRC_COLOR,
    OneMinusSrcColor   = _SG_BLENDFACTOR_ONE_MINUS_SRC_COLOR,
    SrcAlpha           = _SG_BLENDFACTOR_SRC_ALPHA,
    OneMinusSrcAlpha   = _SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
    DstColor           = _SG_BLENDFACTOR_DST_COLOR,
    OneMinusDstColor   = _SG_BLENDFACTOR_ONE_MINUS_DST_COLOR,
    DstAlpha           = _SG_BLENDFACTOR_DST_ALPHA,
    OneMinusDstAlpha   = _SG_BLENDFACTOR_ONE_MINUS_DST_ALPHA,
    SrcAlphaSaturated  = _SG_BLENDFACTOR_SRC_ALPHA_SATURATED,
    BlendColor         = _SG_BLENDFACTOR_BLEND_COLOR,
    OneMinusBlendColor = _SG_BLENDFACTOR_ONE_MINUS_BLEND_COLOR,
    BlendAlpha         = _SG_BLENDFACTOR_BLEND_ALPHA,
    OneMinusBlendAlpha = _SG_BLENDFACTOR_ONE_MINUS_BLEND_ALPHA,
    Src1Color          = _SG_BLENDFACTOR_SRC1_COLOR,
    OneMinusSrc1Color  = _SG_BLENDFACTOR_ONE_MINUS_SRC1_COLOR,
    Src1Alpha          = _SG_BLENDFACTOR_SRC1_ALPHA,
    OneMinusSrc1Alpha  = _SG_BLENDFACTOR_ONE_MINUS_SRC1_ALPHA);

type
  { Describes how the source and destination values are combined in the
    fragment blending operation. It is used in the following members when
    creating a pipeline object:

    TPipelineDesc
        .Colors[I]
            .Blend
                .OpRgb
                .OpAlpha

    The default value is Add }
  TBlendOp = (
    Default         = __SG_BLENDOP_DEFAULT,
    Add             = _SG_BLENDOP_ADD,
    Subtract        = _SG_BLENDOP_SUBTRACT,
    ReverseSubtract = _SG_BLENDOP_REVERSE_SUBTRACT,
    Min             = _SG_BLENDOP_MIN,
    Max             = _SG_BLENDOP_MAX);

type
  { Selects the active color channels when writing a fragment color to the
    framebuffer. This is used in the members TPipelineDesc.Colors[I].WriteMask
    when creating a pipeline object.

    The default colormask is Rgba (write all colors channels)

    NOTE: since the color mask value 0 is reserved for the default value (Rgba),
    use None if all color channels should be disabled. }
  TColorMask = (
    None = _SG_COLORMASK_NONE,
    R    = _SG_COLORMASK_R,
    G    = _SG_COLORMASK_G,
    Rg   = _SG_COLORMASK_RG,
    B    = _SG_COLORMASK_B,
    Rb   = _SG_COLORMASK_RB,
    Gb   = _SG_COLORMASK_GB,
    Rgb  = _SG_COLORMASK_RGB,
    A    = _SG_COLORMASK_A,
    Ra   = _SG_COLORMASK_RA,
    Ga   = _SG_COLORMASK_GA,
    Rga  = _SG_COLORMASK_RGA,
    Ba   = _SG_COLORMASK_BA,
    Rba  = _SG_COLORMASK_RBA,
    Gba  = _SG_COLORMASK_GBA,
    Rgba = _SG_COLORMASK_RGBA);

type
  { Defines the load action that should be performed at the start of a render
    pass. This is used in the TPassAction record.

    The default load action for all pass attachments is Clear, with the clear
    color Rgba = {0.5, 0.5, 0.5, 1.0], Depth = 1.0 and Stencil = 0.

    If you want to override the default behaviour, it is important to not only
    set the clear color, but the 'action' field as well. }
  {$MINENUMSIZE 4}
  TLoadAction = (
    { The default action for the target }
    Default  = __SG_LOADACTION_DEFAULT,

    { Clear the render target }
    Clear    = _SG_LOADACTION_CLEAR,

    { Load the previous content of the render target }
    Load     = _SG_LOADACTION_LOAD,

    { Leave the render target in an undefined state }
    DontCare = _SG_LOADACTION_DONTCARE);
  {$MINENUMSIZE 1}

type
  { Defines the store action that should be performed at the end of a render
    pass. }
  {$MINENUMSIZE 4}
  TStoreAction = (
    { The default action for the target }
    Default  = __SG_STOREACTION_DEFAULT,

    { Store the rendered content to the color attachment image }
    Store    = _SG_STOREACTION_STORE,

    { Allows the GPU to discard the rendered content }
    DontCare = _SG_STOREACTION_DONTCARE);
  {$MINENUMSIZE 1}

type
  TColorAttachmentAction = record
  public
    { Default: Clear }
    LoadAction: TLoadAction;

    { Default: Store }
    StoreAction: TStoreAction;

    { Default: (0.5, 0.5, 0.5, 1.0) }
    ClearValue: TColor;
  public
    constructor Create(const ALoadAction: TLoadAction;
      const AStoreAction: TStoreAction; const AClearValue: TColor); overload;
    constructor Create(const ALoadAction: TLoadAction;
      const AStoreAction: TStoreAction; const AR, AG, AB: Single;
      const AA: Single = 1); overload;
    constructor Create(const ALoadAction: TLoadAction;
      const AClearValue: TColor); overload;
    constructor Create(const ALoadAction: TLoadAction;
      const AR, AG, AB: Single; const AA: Single = 1); overload;
    constructor Create(const AStoreAction: TStoreAction;
      const AClearValue: TColor); overload;
    constructor Create(const AStoreAction: TStoreAction;
      const AR, AG, AB: Single; const AA: Single = 1); overload;

    procedure Init(const ALoadAction: TLoadAction;
      const AStoreAction: TStoreAction; const AClearValue: TColor); overload; inline;
    procedure Init(const ALoadAction: TLoadAction;
      const AStoreAction: TStoreAction; const AR, AG, AB: Single;
      const AA: Single = 1); overload; inline;
    procedure Init(const ALoadAction: TLoadAction;
      const AClearValue: TColor); overload; inline;
    procedure Init(const ALoadAction: TLoadAction;
      const AR, AG, AB: Single; const AA: Single = 1); overload; inline;
    procedure Init(const AStoreAction: TStoreAction;
      const AClearValue: TColor); overload; inline;
    procedure Init(const AStoreAction: TStoreAction;
      const AR, AG, AB: Single; const AA: Single = 1); overload; inline;
  end;
  PColorAttachmentAction = ^TColorAttachmentAction;

  TDepthAttachmentAction = record
  public
    { Default: Clear }
    LoadAction: TLoadAction;

    { Default: DontCare }
    StoreAction: TStoreAction;

    { Default: 1.0 }
    ClearValue: Single;
  public
    constructor Create(const ALoadAction: TLoadAction;
      const AStoreAction: TStoreAction; const AClearValue: Single); overload;
    constructor Create(const ALoadAction: TLoadAction;
      const AClearValue: Single); overload;
    constructor Create(const AStoreAction: TStoreAction;
      const AClearValue: Single); overload;

    procedure Init(const ALoadAction: TLoadAction;
      const AStoreAction: TStoreAction; const AClearValue: Single); overload; inline;
    procedure Init(const ALoadAction: TLoadAction;
      AClearValue: Single); overload; inline;
    procedure Init(const AStoreAction: TStoreAction;
      const AClearValue: Single); overload; inline;
  end;
  PDepthAttachmentAction = ^TDepthAttachmentAction;

  TStencilAttachmentAction = record
  public
    { Default: Clear }
    LoadAction: TLoadAction;

    { Default: DontCare }
    StoreAction: TStoreAction;

    { Default: 0 }
    ClearValue: Byte;
  public
    constructor Create(const ALoadAction: TLoadAction;
      const AStoreAction: TStoreAction; const AClearValue: Byte); overload;
    constructor Create(const ALoadAction: TLoadAction;
      const AClearValue: Byte); overload;
    constructor Create(const AStoreAction: TStoreAction;
      const AClearValue: Byte); overload;

    procedure Init(const ALoadAction: TLoadAction;
      const AStoreAction: TStoreAction; const AClearValue: Byte); overload; inline;
    procedure Init(const ALoadAction: TLoadAction;
      const AClearValue: Byte); overload; inline;
    procedure Init(const AStoreAction: TStoreAction;
      const AClearValue: Byte); overload; inline;
  end;
  PStencilAttachmentAction = ^TStencilAttachmentAction;

  { TPassAction record defines the actions to be performed at the start of a
    rendering pass.

    - at the start of the pass: whether the render attachments should be
      cleared, loaded with their previous content, or start in an undefined
      state
    - for clear operations: the clear value (color, depth, or stencil values)
    - at the end of the pass: whether the rendering result should be stored back
      into the render attachment or discarded }
  TPassAction = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_pass_action;
    function GetColor(const AIndex: Integer): PColorAttachmentAction; inline;
    function GetDepth: PDepthAttachmentAction; inline;
    function GetStencil: PStencilAttachmentAction; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Initializes with default values }
    class function Create: TPassAction; inline; static;
    procedure Init; inline;

    { Color attachments [0..MAX_COLOR_ATTACHMENTS - 1] }
    property Colors[const AIndex: Integer]: PColorAttachmentAction read GetColor;

    { Depth attachment }
    property Depth: PDepthAttachmentAction read GetDepth;

    { Stencil attachment }
    property Stencil: PStencilAttachmentAction read GetStencil;
  end;
  PPassAction = ^TPassAction;

type
  TMetalSwapchain = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_metal_swapchain;
  {$ENDREGION 'Internal Declarations'}
  public
    { For iOS and macOS, the Object ID of the current Metal drawable
      (CAMetalDrawable, *not* MTLDrawable). }
    property CurrentDrawable: Pointer read FHandle.current_drawable write FHandle.current_drawable;

    { For iOS and macOS, the Object ID of the current Metal depth stencil
      texture (MTLTexture). }
    property DepthStencilTexture: Pointer read FHandle.depth_stencil_texture write FHandle.depth_stencil_texture;

    { For iOS and macOS, the Object ID of the current Metal MSAA color
      texture (MTLTexture). }
    property MsaaColorTexture: Pointer read FHandle.msaa_color_texture write FHandle.msaa_color_texture;
  end;
  PMetalSwapchain = ^TMetalSwapchain;

type
  TD3D11Swapchain = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_d3d11_swapchain;
    function GetDepthStencilView: IInterface; inline;
    procedure SetDepthStencilView(const AValue: IInterface); inline;
    function GetRenderView: IInterface; inline;
    procedure SetRenderView(const AValue: IInterface); inline;
    function GetResolveView: IInterface; inline;
    procedure SetResolveView(const AValue: IInterface); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { ID3D11RenderTargetView }
    property RenderView: IInterface read GetRenderView write SetRenderView;

    { ID3D11RenderTargetView }
    property ResolveView: IInterface read GetResolveView write SetResolveView;

    { ID3D11DepthStencilView }
    property DepthStencilView: IInterface read GetDepthStencilView write SetDepthStencilView;
  end;
  PD3D11Swapchain = ^TD3D11Swapchain;

type
  TVulkanSwapchain = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_vulkan_swapchain;
  {$ENDREGION 'Internal Declarations'}
  public
    { vkImage }
    property RenderImage: Pointer read FHandle.render_image write FHandle.render_image;

    { vkImageView }
    property RenderView: Pointer read FHandle.render_view write FHandle.render_view;

    { vkImage }
    property ResolveImage: Pointer read FHandle.resolve_image write FHandle.resolve_image;

    { vkImageView }
    property ResolveView: Pointer read FHandle.resolve_view write FHandle.resolve_view;

    { vkImage }
    property DepthStencilImage: Pointer read FHandle.depth_stencil_image write FHandle.depth_stencil_image;

    { vkImageView }
    property DepthStencilView: Pointer read FHandle.depth_stencil_view write FHandle.depth_stencil_view;

    { vkSemaphore }
    property RenderFinishedSemaphore: Pointer read FHandle.render_finished_semaphore write FHandle.render_finished_semaphore;

    { vkSemaphore }
    property PresentCompleteSemaphore: Pointer read FHandle.present_complete_semaphore write FHandle.present_complete_semaphore;
  end;
  PVulkanSwapchain = ^TVulkanSwapchain;

type
  TGLSwapchain = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_gl_swapchain;
  {$ENDREGION 'Internal Declarations'}
  public
    { GL framebuffer object }
    property FrameBuffer: Cardinal read FHandle.framebuffer write FHandle.framebuffer;
  end;
  PGLSwapchain = ^TGLSwapchain;

type
  { Used in TGfx.BeginPass to provide details about an external swapchain
    (pixel formats, sample count and backend-API specific render surface
    objects).

    The following information must be provided:

    - the width and height of the swapchain surfaces in number of pixels,
    - the pixel format of the render- and optional msaa-resolve-surface
    - the pixel format of the optional depth- or depth-stencil-surface
    - the MSAA sample count for the render and depth-stencil surface

    If the pixel formats and MSAA sample counts are left zero-initialized,
    their defaults are taken from the TEnvironment record provided in the
    TGfx.Setup call.

    The width and height *must* be > 0.

    The Boolean `TSwapchain.Invalid` is used to communicate an invalid swapchain
    state to Neslib.Sokol.Gfx (for instance the swapchain code outside of
    Neslib.Sokol.Gfx not being able to create swapchain surfaces). When the
    .Invalid Boolean is set to True, all other TSwapchain members must be zeroed
    (checked in the validation layer), and all rendering in this swapchain-pass
    will be silently skipped.

    For valid swapchains, the following backend API specific objects must be
    passed in:

    GL:
      - on all GL backends, a GL framebuffer object must be provided. This can
        be zero for the default framebuffer.

    D3D11:
      - an ID3D11RenderTargetView for the rendering surface, without MSAA
        rendering this surface will also be displayed
      - an optional ID3D11DepthStencilView for the depth- or depth/stencil
        buffer surface
      - when MSAA rendering is used, another ID3D11RenderTargetView which serves
        as MSAA resolve target and will be displayed

    Metal (NOTE that the roles of provided surfaces is slightly different
    than on D3D11 in case of MSAA vs non-MSAA rendering):

      - A current CAMetalDrawable (NOT an MTLDrawable!) which will be presented.
        This will either be rendered to directly (if no MSAA is used), or serve
        as MSAA-resolve target.
      - an optional MTLTexture for the depth- or depth-stencil buffer
      - an optional multisampled MTLTexture which serves as intermediate
        rendering surface which will then be resolved into the CAMetalDrawable.

    On all other backends you shouldn't need to mess with the reference count.

    It's a good practice to write a helper function which returns an initialized
    TSwapchain record, which can then be plugged directly into TPass.Swapchain.

    Consider the Neslib.Sokol.Glue unit which adds a FromAppSwapchain method to
    the TSwapchain record. }
  TSwapchain = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_swapchain;
    function GetColorFormat: TPixelFormat; inline;
    function GetDepthFormat: TPixelFormat; inline;
    function GetMetal: PMetalSwapchain; inline;
    function GetD3D11: PD3D11Swapchain; inline;
    function GetVulkan: PVulkanSwapchain; inline;
    function GetGL: PGLSwapchain; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Invalid: Boolean read FHandle.invalid;
    property Width: Integer read FHandle.width;
    property Height: Integer read FHandle.height;
    property SampleCount: Integer read FHandle.sample_count;
    property ColorFormat: TPixelFormat read GetColorFormat;
    property DepthFormat: TPixelFormat read GetDepthFormat;
    property Metal: PMetalSwapchain read GetMetal;
    property D3D11: PD3D11Swapchain read GetD3D11;
    property Vulkan: PVulkanSwapchain read GetVulkan;
    property GL: PGLSwapchain read GetGL;
  end;
  PSwapchain = ^TSwapchain;

type
  { These records contain various internal resource attributes which might be
    useful for debug-inspection. Please don't rely on the actual content of
    those records too much, as they are quite closely tied to Sokol internals
    and may change more frequently than the other public API elements. }
  TSlotInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_slot_info;
    function GetState: TResourceState; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { The current state of this resource slot }
    property State: TResourceState read GetState;

    { Type-neutral resource id (e.g. TBuffer.Id) }
    property ResourceId: UInt32 read FHandle.res_id;

    property UninitCount: UInt32 read FHandle.uninit_count;
  end;
  PSlotInfo = ^TSlotInfo;

  TBufferInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_buffer_info;
    function GetSlot: TSlotInfo; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Resource pool slot info }
    property Slot: TSlotInfo read GetSlot;

    { Frame index of last TBuffer.Update }
    property UpdateFrameIndex: UInt32 read FHandle.update_frame_index;

    { Frame index of last TBuffer.Append }
    property AppendFrameIndex: UInt32 read FHandle.append_frame_index;

    { Current position in buffer for TBuffer.Append }
    property AppendPos: Integer read FHandle.append_pos;

    { Is buffer in overflow state (due to TBuffer.Append) }
    property AppendOverflow: Boolean read FHandle.append_overflow;

    { Number of renaming-slots for dynamically updated buffers }
    property NumSlots: Integer read FHandle.num_slots;

    { Currently active write-slot for dynamically updated buffers }
    property ActiveSlot: Integer read FHandle.active_slot;
  end;
  PBufferInfo = ^TBufferInfo;

  TImageInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_image_info;
    function GetSlot: TSlotInfo; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Resource pool slot info }
    property Slot: TSlotInfo read GetSlot;

    { Frame index of last TImage.Update }
    property UpdateFrameIndex: UInt32 read FHandle.upd_frame_index;

    { Number of renaming-slots for dynamically updated images }
    property NumSlots: Integer read FHandle.num_slots;

    { Currently active write-slot for dynamically updated images }
    property ActiveSlot: Integer read FHandle.active_slot;
  end;
  PImageInfo = ^TImageInfo;

  TSamplerInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_sampler_info;
    function GetSlot: TSlotInfo; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Resource pool slot info }
    property Slot: TSlotInfo read GetSlot;
  end;
  PSamplerInfo = ^TSamplerInfo;

  TShaderInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_shader_info;
    function GetSlot: TSlotInfo; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Resource pool slot info }
    property Slot: TSlotInfo read GetSlot;
  end;
  PShaderInfo = ^TShaderInfo;

  TPipelineInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_pipeline_info;
    function GetSlot: TSlotInfo; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Resource pool slot info }
    property Slot: TSlotInfo read GetSlot;
  end;
  PPipelineInfo = ^TPipelineInfo;

  TViewInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_view_info;
    function GetSlot: TSlotInfo; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Resource pool slot info }
    property Slot: TSlotInfo read GetSlot;
  end;
  PViewInfo = ^TViewInfo;

type
  TFrameStatsGL = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_frame_stats_gl;
  {$ENDREGION 'Internal Declarations'}
  public
    property NumBindBuffer: Cardinal read FHandle.num_bind_buffer;
    property NumActiveTexture: Cardinal read FHandle.num_active_texture;
    property NumBindTexture: Cardinal read FHandle.num_bind_texture;
    property NumBindSampler: Cardinal read FHandle.num_bind_sampler;
    property NumBindImageTexture: Cardinal read FHandle.num_bind_image_texture;
    property NumUseProgram: Cardinal read FHandle.num_use_program;
    property NumRenderState: Cardinal read FHandle.num_render_state;
    property NumVertexAttribPointer: Cardinal read FHandle.num_vertex_attrib_pointer;
    property NumVertexAttribDivisor: Cardinal read FHandle.num_vertex_attrib_divisor;
    property NumEnableVertexAttribArray: Cardinal read FHandle.num_enable_vertex_attrib_array;
    property NumDisableVertexAttribArray: Cardinal read FHandle.num_disable_vertex_attrib_array;
    property NumUniform: Cardinal read FHandle.num_uniform;
    property NumMemoryBarriers: Cardinal read FHandle.num_memory_barriers;
  end;
  PFrameStatsGL = ^TFrameStatsGL;

type
  TFrameStatsD3D11Pass = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_frame_stats_d3d11_pass;
  {$ENDREGION 'Internal Declarations'}
  public
    property NumOmSetRenderTargets: Cardinal read FHandle.num_om_set_render_targets;
    property NumClearRenderTargetView: Cardinal read FHandle.num_clear_render_target_view;
    property NumClearDepthStencilView: Cardinal read FHandle.num_clear_depth_stencil_view;
    property NumResolveSubresource: Cardinal read FHandle.num_resolve_subresource;
  end;
  PFrameStatsD3D11Pass = ^TFrameStatsD3D11Pass;

type
  TFrameStatsD3D11Pipeline = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_frame_stats_d3d11_pipeline;
  {$ENDREGION 'Internal Declarations'}
  public
    property NumResetState: Cardinal read FHandle.num_rs_set_state;
    property NumOmSetDepthStencilState: Cardinal read FHandle.num_om_set_depth_stencil_state;
    property NumOmSetBlendState: Cardinal read FHandle.num_om_set_blend_state;
    property NumIaSetPrimitiveTopology: Cardinal read FHandle.num_ia_set_primitive_topology;
    property NumIaSetInputLayout: Cardinal read FHandle.num_ia_set_input_layout;
    property NumVsSetShader: Cardinal read FHandle.num_vs_set_shader;
    property NumVsSetConstantBuffers: Cardinal read FHandle.num_vs_set_constant_buffers;
    property NumPsSetShader: Cardinal read FHandle.num_ps_set_shader;
    property NumPsSetConstantBuffers: Cardinal read FHandle.num_ps_set_constant_buffers;
    property NumCsSetShader: Cardinal read FHandle.num_cs_set_shader;
    property NumCsSetConstantBuffers: Cardinal read FHandle.num_cs_set_constant_buffers;
  end;
  PFrameStatsD3D11Pipeline = ^TFrameStatsD3D11Pipeline;

type
  TFrameStatsD3D11Bindings = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_frame_stats_d3d11_bindings;
  {$ENDREGION 'Internal Declarations'}
  public
    property NumIaSetVertexBuffers: Cardinal read FHandle.num_ia_set_vertex_buffers;
    property NumIaSetIndexBuffer: Cardinal read FHandle.num_ia_set_index_buffer;
    property NumVsSetShaderResources: Cardinal read FHandle.num_vs_set_shader_resources;
    property NumVsSetSamplers: Cardinal read FHandle.num_vs_set_samplers;
    property NumPsSetShaderResources: Cardinal read FHandle.num_ps_set_shader_resources;
    property NumPsSetSamplers: Cardinal read FHandle.num_ps_set_samplers;
    property NumCsSetShaderResources: Cardinal read FHandle.num_cs_set_shader_resources;
    property NumCsSetSamplers: Cardinal read FHandle.num_cs_set_samplers;
    property NumCsSetUnorderedAccessViews: Cardinal read FHandle.num_cs_set_unordered_access_views;
  end;
  PFrameStatsD3D11Bindings = ^TFrameStatsD3D11Bindings;

type
  TFrameStatsD3D11Uniforms = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_frame_stats_d3d11_uniforms;
  {$ENDREGION 'Internal Declarations'}
  public
    property NumUpdateSubresource: Cardinal read FHandle.num_update_subresource;
  end;
  PFrameStatsD3D11Uniforms = ^TFrameStatsD3D11Uniforms;

type
  TFrameStatsD3D11Draw = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_frame_stats_d3d11_draw;
  {$ENDREGION 'Internal Declarations'}
  public
    property NumDrawIndexedInstanced: Cardinal read FHandle.num_draw_indexed_instanced;
    property NumDrawIndexed: Cardinal read FHandle.num_draw_indexed;
    property NumDrawInstanced: Cardinal read FHandle.num_draw_instanced;
    property NumDraw: Cardinal read FHandle.num_draw;
  end;
  PFrameStatsD3D11Draw = ^TFrameStatsD3D11Draw;

type
  TFrameStatsD3D11 = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_frame_stats_d3d11;
    function GetPass: PFrameStatsD3D11Pass; inline;
    function GetPipeline: PFrameStatsD3D11Pass; inline;
    function GetBindings: PFrameStatsD3D11Bindings; inline;
    function GetUniforms: PFrameStatsD3D11Uniforms; inline;
    function GetDraw: PFrameStatsD3D11Draw; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Pass: PFrameStatsD3D11Pass read GetPass;
    property Pipeline: PFrameStatsD3D11Pass read GetPipeline;
    property Bindings: PFrameStatsD3D11Bindings read GetBindings;
    property Uniforms: PFrameStatsD3D11Uniforms read GetUniforms;
    property Draw: PFrameStatsD3D11Draw read GetDraw;
    property NumMap: Cardinal read FHandle.num_map;
    property NumUnmap: Cardinal read FHandle.num_unmap;
  end;
  PFrameStatsD3D11 = ^TFrameStatsD3D11;

type
  TFrameStatsMetalIdPool = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_frame_stats_metal_idpool;
  {$ENDREGION 'Internal Declarations'}
  public
    property NumAdded: Cardinal read FHandle.num_added;
    property NumReleased: Cardinal read FHandle.num_released;
    property NumGarbageCollected: Cardinal read FHandle.num_garbage_collected;
  end;
  PFrameStatsMetalIdPool = ^TFrameStatsMetalIdPool;

type
  TFrameStatsMetalPipeline = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_frame_stats_metal_pipeline;
  {$ENDREGION 'Internal Declarations'}
  public
    property NumSetBlendColor: Cardinal read FHandle.num_set_blend_color;
    property NumSetCullMode: Cardinal read FHandle.num_set_cull_mode;
    property NumSetFrontFacingWinding: Cardinal read FHandle.num_set_front_facing_winding;
    property NumSetStencilReferenceValue: Cardinal read FHandle.num_set_stencil_reference_value;
    property NumSetDepthBias: Cardinal read FHandle.num_set_depth_bias;
    property NumSetRenderPipeline_state: Cardinal read FHandle.num_set_render_pipeline_state;
    property NumSetDepthStencilState: Cardinal read FHandle.num_set_depth_stencil_state;
  end;
  PFrameStatsMetalPipeline = ^TFrameStatsMetalPipeline;

type
  TFrameStatsMetalBindings = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_frame_stats_metal_bindings;
  {$ENDREGION 'Internal Declarations'}
  public
    property NumSetVertexBuffer: Cardinal read FHandle.num_set_vertex_buffer;
    property NumSetVertexBufferOffset: Cardinal read FHandle.num_set_vertex_buffer_offset;
    property NumSkipRedundantVertexBuffer: Cardinal read FHandle.num_skip_redundant_vertex_buffer;
    property NumSetVertexTexture: Cardinal read FHandle.num_set_vertex_texture;
    property NumSkipRedundantVertexTexture: Cardinal read FHandle.num_skip_redundant_vertex_texture;
    property NumSetVertexSamplerState: Cardinal read FHandle.num_set_vertex_sampler_state;
    property NumSkipRedundantVertexSamplerState: Cardinal read FHandle.num_skip_redundant_vertex_sampler_state;
    property NumSetFragmentBuffer: Cardinal read FHandle.num_set_fragment_buffer;
    property NumSetFragmentBufferOffset: Cardinal read FHandle.num_set_fragment_buffer_offset;
    property NumSkipRedundantFragmentBuffer: Cardinal read FHandle.num_skip_redundant_fragment_buffer;
    property NumSetFragmentTexture: Cardinal read FHandle.num_set_fragment_texture;
    property NumSkipRedundantFragmentTexture: Cardinal read FHandle.num_skip_redundant_fragment_texture;
    property NumSetFragmentSamplerState: Cardinal read FHandle.num_set_fragment_sampler_state;
    property NumSkipRedundantFragmentSamplerState: Cardinal read FHandle.num_skip_redundant_fragment_sampler_state;
    property NumSetComputeBuffer: Cardinal read FHandle.num_set_compute_buffer;
    property NumSetComputeBufferOffset: Cardinal read FHandle.num_set_compute_buffer_offset;
    property NumSkipRedundantComputeBuffer: Cardinal read FHandle.num_skip_redundant_compute_buffer;
    property NumSetComputeTexture: Cardinal read FHandle.num_set_compute_texture;
    property NumSkipRedundantComputeTexture: Cardinal read FHandle.num_skip_redundant_compute_texture;
    property NumSetComputeSamplerState: Cardinal read FHandle.num_set_compute_sampler_state;
    property NumSkipRedundantComputeSamplerState: Cardinal read FHandle.num_skip_redundant_compute_sampler_state;
  end;
  PFrameStatsMetalBindings = ^TFrameStatsMetalBindings;

type
  TFrameStatsMetalUniforms = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_frame_stats_metal_uniforms;
  {$ENDREGION 'Internal Declarations'}
  public
    property NumSetVertexBufferOffset: Cardinal read FHandle.num_set_vertex_buffer_offset;
    property NumSetFragmentBufferOffset: Cardinal read FHandle.num_set_fragment_buffer_offset;
    property NumSetComputeBufferOffset: Cardinal read FHandle.num_set_compute_buffer_offset;
  end;
  PFrameStatsMetalUniforms = ^TFrameStatsMetalUniforms;

type
  TFrameStatsMetal = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_frame_stats_metal;
    function GetIdPool: PFrameStatsMetalIdPool; inline;
    function GetPipeline: PFrameStatsMetalPipeline; inline;
    function GetBindings: PFrameStatsMetalBindings; inline;
    function GetUniforms: PFrameStatsMetalUniforms; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property IdPool: PFrameStatsMetalIdPool read GetIdPool;
    property Pipeline: PFrameStatsMetalPipeline read GetPipeline;
    property Bindings: PFrameStatsMetalBindings read GetBindings;
    property Uniforms: PFrameStatsMetalUniforms read GetUniforms;
  end;
  PFrameStatsMetal = ^TFrameStatsMetal;

type
  TFrameStatsVulkan = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_frame_stats_vk;
  {$ENDREGION 'Internal Declarations'}
  public
    property NumCmdPipelineBarrier: Cardinal read FHandle.num_cmd_pipeline_barrier;
    property NumAllocateMemory: Cardinal read FHandle.num_allocate_memory;
    property NumFreeMemory: Cardinal read FHandle.num_free_memory;
    property SizeAllocateMemory: Cardinal read FHandle.size_allocate_memory;
    property NumDeleteQueueAdded: Cardinal read FHandle.num_delete_queue_added;
    property NumDeleteQueueCollected: Cardinal read FHandle.num_delete_queue_collected;
    property NumCmdCopyBuffer: Cardinal read FHandle.num_cmd_copy_buffer;
    property NumCmdCopyBufferToImage: Cardinal read FHandle.num_cmd_copy_buffer_to_image;
    property NumCmdSetDescriptorBufferOffsets: Cardinal read FHandle.num_cmd_set_descriptor_buffer_offsets;
    property SizeDescriptorBufferWrites: Cardinal read FHandle.size_descriptor_buffer_writes;
  end;
  PFrameStatsVulkan = ^TFrameStatsVulkan;

type
  TFrameResourceStats = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_frame_resource_stats;
  {$ENDREGION 'Internal Declarations'}
  public
    { Number of allocated objects in current frame }
    property Allocated: Cardinal read FHandle.allocated;

    { Number of deallocated object in current frame }
    property Deallocated: Cardinal read FHandle.deallocated;

    { Number of initialized objects in current frame }
    property Inited: Cardinal read FHandle.inited;

    { Number of deinitialized objects in current frame }
    property Uninited: Cardinal read FHandle.uninited;
  end;
  PFrameResourceStats = ^TFrameResourceStats;

type
  TTotalResourceStats = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_total_resource_stats;
  {$ENDREGION 'Internal Declarations'}
  public
    { Number of live objects in pool }
    property Alive: Cardinal read FHandle.alive;

    { Number of free objects in pool }
    property Free: Cardinal read FHandle.free;

    { Total number of object allocations }
    property Allocated: Cardinal read FHandle.allocated;

    { Total number of object deallocations }
    property Deallocated: Cardinal read FHandle.deallocated;

    { Total number of object initializations }
    property Inited: Cardinal read FHandle.inited;

    { Total number of object deinitializations }
    property Uninited: Cardinal read FHandle.uninited;
  end;
  PTotalResourceStats = ^TTotalResourceStats;

type
  TTotalStats = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_total_stats;
    function GetBuffers: PTotalResourceStats; inline;
    function GetImages: PTotalResourceStats; inline;
    function GetSamplers: PTotalResourceStats; inline;
    function GetViews: PTotalResourceStats; inline;
    function GetShaders: PTotalResourceStats; inline;
    function GetPipelines: PTotalResourceStats; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Buffers: PTotalResourceStats read GetBuffers;
    property Images: PTotalResourceStats read GetImages;
    property Samplers: PTotalResourceStats read GetSamplers;
    property Views: PTotalResourceStats read GetViews;
    property Shaders: PTotalResourceStats read GetShaders;
    property Pipelines: PTotalResourceStats read GetPipelines;
  end;
  PTotalStats = ^TTotalStats;

type
  TFrameStats = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_frame_stats;
    function GetBuffers: PFrameResourceStats; inline;
    function GetImages: PFrameResourceStats; inline;
    function GetSamplers: PFrameResourceStats; inline;
    function GetViews: PFrameResourceStats; inline;
    function GetShaders: PFrameResourceStats; inline;
    function GetPipelines: PFrameResourceStats; inline;
    function GetGL: PFrameStatsGL; inline;
    function GetD3D11: PFrameStatsD3D11; inline;
    function GetMetal: PFrameStatsMetal; inline;
    function GetVulkan: PFrameStatsVulkan; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Current frame counter, starts at 0 }
    property FrameIndex: Cardinal read FHandle.frame_index;

    property NumPasses: Cardinal read FHandle.num_passes;
    property NumApplyViewport: Cardinal read FHandle.num_apply_viewport;
    property NumApplyScissorRect: Cardinal read FHandle.num_apply_scissor_rect;
    property NumApplyPipeline: Cardinal read FHandle.num_apply_pipeline;
    property NumApplyBindings: Cardinal read FHandle.num_apply_bindings;
    property NumApplyUniforms: Cardinal read FHandle.num_apply_uniforms;
    property NumDraw: Cardinal read FHandle.num_draw;
    property NumDrawEx: Cardinal read FHandle.num_draw_ex;
    property NumDispatch: Cardinal read FHandle.num_dispatch;
    property NumUpdateBuffer: Cardinal read FHandle.num_update_buffer;
    property NumAppendBuffer: Cardinal read FHandle.num_append_buffer;
    property NumUpdateImage: Cardinal read FHandle.num_update_image;

    property SizeApplyUniforms: Cardinal read FHandle.size_apply_uniforms;
    property SizeUpdateBuffer: Cardinal read FHandle.size_update_buffer;
    property SizeAppendBuffer: Cardinal read FHandle.size_append_buffer;
    property SizeUpdateImage: Cardinal read FHandle.size_update_image;

    property Buffers: PFrameResourceStats read GetBuffers;
    property Images: PFrameResourceStats read GetImages;
    property Samplers: PFrameResourceStats read GetSamplers;
    property Views: PFrameResourceStats read GetViews;
    property Shaders: PFrameResourceStats read GetShaders;
    property Pipelines: PFrameResourceStats read GetPipelines;

    property GL: PFrameStatsGL read GetGL;
    property D3D11: PFrameStatsD3D11 read GetD3D11;
    property Metal: PFrameStatsMetal read GetMetal;
    property Vulkan: PFrameStatsVulkan read GetVulkan;
  end;
  PFrameStats = ^TFrameStats;

type
  { Allows to track generic and backend-specific rendering stats,
    obtained via TStats.Query }
  TStats = record
  public
    PrevFrame: TFrameStats;
    CurFrame: TFrameStats;
    Total: TTotalStats;
  end;
  PStats = ^TStats;

type
  { Describes how a buffer object is going to be used }
  TBufferUsage = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_buffer_usage;
  {$ENDREGION 'Internal Declarations'}
  public
    { The buffer will be bound as vertex buffer via TBindings.VertexBuffers.
      Default True. }
    property VertexBuffer: Boolean read FHandle.vertex_buffer write FHandle.vertex_buffer;

    { The buffer will be bound as index buffer via TBindings.IndexBuffer.
      Default False. }
    property IndexBuffer: Boolean read FHandle.index_buffer write FHandle.index_buffer;

    { The buffer will be bound as storage buffer via storage-buffer-view in
      TBindings.Views[].
      Default False. }
    property StorageBuffer: Boolean read FHandle.storage_buffer write FHandle.storage_buffer;

    { The buffer content will never be updated from the CPU side (but may be
      written to by a compute shader).
      Default True. }
    property Immutable: Boolean read FHandle.immutable write FHandle.immutable;

    { The buffer content will be infrequently updated from the CPU side.
      Default False. }
    property DynamicUpdate: Boolean read FHandle.dynamic_update write FHandle.dynamic_update;

    { The buffer content will be updated each frame from the CPU side.
      Default False. }
    property StreamUpdate: Boolean read FHandle.stream_update write FHandle.stream_update;
  end;
  PBufferUsage = ^TBufferUsage;

type
  { Creation parameters for TBuffer objects.

    The default configuration is:

    .Size:       0       (*must* be >0 for buffers without data)
    .Usage:      .VertexBuffer = True, .Immutable = True
    .Data        []      (*must* be valid for immutable buffers without storage
                          buffer usage)
    .TraceLabel  ''      (optional string label)

    For immutable buffers which are initialized with initial data, keep the
    .Size field zero-initialized, and set the size together with the pointer to
    the initial data in the .Data field.

    For immutable or mutable buffers without initial data, keep the .Data field
    empty, and set the buffer size in the .Size field instead.

    You can also set both size values, but currently both size values must be
    identical (this may change in the future when the dynamic resource
    management may become more flexible).

    NOTE: Immutable buffers without storage-buffer-usage *must* be created with
    initial content. This restriction doesn't apply to storage buffer usage,
    because storage buffers may also get their initial content by running
    a compute shader on them.

    NOTE: Buffers without initial data will have undefined content, e.g.
    do *not* expect the buffer to be zero-initialized!

    ADVANCED TOPIC: Injecting native 3D-API buffers:

    The following struct members allow to inject your own GL, Metal or D3D11
    buffers:

    .GLBuffers[NUM_INFLIGHT_FRAMES]
    .MtlBuffers[NUM_INFLIGHT_FRAMES]
    .D3D11Buffer

    You must still provide all other record fields except the .Data field, and
    these must match the creation parameters of the native buffers you provide.
    For TBufferDesc.Usage.Immutable buffers, only provide a single native 3D-API
    buffer, otherwise you need to provide NUM_INFLIGHT_FRAMES buffers (only for
    GL and Metal, not D3D11). Providing multiple buffers for GL and Metal is
    necessary because Sokol will rotate through them when calling TBuffer.Update
    to prevent lock-stalls.

    Note that it is expected that immutable injected buffer have already been
    initialized with content, and the .Content field must be 0!

    Also you need to call TGfx.ResetCache after calling native 3D-API
    functions, and before calling any Sokol function. }
  TBufferDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_buffer_desc);
    procedure InitFrom(const ASrc: _sg_buffer_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Size: NativeUInt;
    Usage: TBufferUsage;
    Data: TRange;

    TraceLabel: UTF8String;

    (* Optionally inject backend-specific resources: *)

    { GL specific }
    GLBuffers: array [0..NUM_INFLIGHT_FRAMES - 1] of UInt32;

    { Metal specific }
    MetalBuffers: array [0..NUM_INFLIGHT_FRAMES - 1] of Pointer;

    { D3D11 specific }
    D3D11Buffer: IInterface;
  public
    { Initializes with default values }
    class function Create: TBufferDesc; inline; static;
    procedure Init;
  end;
  PBufferDesc = ^TBufferDesc;

type
  TD3D11BufferInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_d3d11_buffer_info;
    function GetBuffer: IInterface; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { ID3D11Buffer }
    property Buffer: IInterface read GetBuffer;
  end;

type
  TMetalBufferInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_mtl_buffer_info;
    function GetBuffer(const AIndex: Integer): Pointer; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { MTLBuffer ObjectID. AIndex ranges from 0..NUM_INFLIGHT_FRAMES-1 }
    property Buffers[const AIndex: Integer]: Pointer read GetBuffer;

    property ActiveSlot: Integer read FHandle.active_slot;
  end;

type
  TGLBufferInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_gl_buffer_info;
    function GetBuffer(const AIndex: Integer): Cardinal; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { AIndex ranges from 0..NUM_INFLIGHT_FRAMES-1 }
    property Buffers[const AIndex: Integer]: Cardinal read GetBuffer;

    property ActiveSlot: Integer read FHandle.active_slot;
  end;

type
  { Vertex- and index-buffer resource.

    A buffer can be created synchronously or asynchronously.
    For synchronous creation, use Create/Init and Free.
    For asynchronous creation, use Allocate, Setup, Teardown, Deallocate and
    Fail. }
  TBuffer = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_buffer;
    function GetOverflow: Boolean; inline;
    function GetState: TResourceState; inline;
    function GetInfo: TBufferInfo; inline;
    function GetDesc: TBufferDesc; inline;
    function GetSize: NativeInt; inline;
    function GetD3D11BufferInfo: TD3D11BufferInfo; inline;
    function GetMetalBufferInfo: TMetalBufferInfo; inline;
    function GetGLBufferInfo: TGLBufferInfo; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Synchronous setup }
    constructor Create(const ADesc: TBufferDesc);
    procedure Init(const ADesc: TBufferDesc); inline;
    procedure Free; inline;

    { Asynchronous setup }
    procedure Allocate; inline;
    procedure Setup(const ADesc: TBufferDesc); inline;
    procedure Teardown; inline;
    procedure Deallocate; inline;
    procedure Fail; inline;

    { Operations }
    procedure Update(const AData: TBytes); overload; inline;
    procedure Update(const AData: TRange); overload; inline;
    function Append(const AData: TBytes): Integer; overload; inline;
    function Append(const AData: TRange): Integer; overload; inline;
    function WillOverflow(const ASize: NativeInt): Boolean; inline;

    { The resource Id }
    property Id: Cardinal read FHandle.id write FHandle.id;

    { Current resource state }
    property State: TResourceState read GetState;

    { Get runtime information about the buffer }
    property Info: TBufferInfo read GetInfo;

    { Get description record matching the buffer.
      Note: not all creation attributes may be provided. }
    property Desc: TBufferDesc read GetDesc;

    property Overflow: Boolean read GetOverflow;
    property Size: NativeInt read GetSize;

    { D3D11: get internal buffer resource objects }
    property D3D11BufferInfo: TD3D11BufferInfo read GetD3D11BufferInfo;

    { Metal: get internal buffer resource objects }
    property MetalBufferInfo: TMetalBufferInfo read GetMetalBufferInfo;

    { OpenGL: get internal buffer resource objects }
    property GLBufferInfo: TGLBufferInfo read GetGLBufferInfo;
  end;
  PBuffer = ^TBuffer;

type
  { Describes the intended usage of an image object.

    Note that creating a texture view from the image to be used for
    texture-sampling in vertex-, fragment- or compute-shaders is always
    implicitly allowed. }
  TImageUsage = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_image_usage;
  {$ENDREGION 'Internal Declarations'}
  public
    { The image can be used as parent resource of a storage-image-view, which
      allows compute shaders to write to the image in a compute pass (for
      read-only access in compute shaders bind the image via a texture view
      instead.
      Default: False }
    property StorageImage: Boolean read FHandle.storage_image write FHandle.storage_image;

    { The image can be used as parent resource of a color-attachment-view, which
      is then passed into TGfx.BeginPass via TPass.Attachments.Colors[] so that
      fragment shaders can render into the image.
      Default: False }
    property ColorAttachment: Boolean read FHandle.color_attachment write FHandle.color_attachment;

    { The image can be used as parent resource of a resolve-attachment-view,
      which is then passed into TGfx.BeginPass via TPass.Attachments.Resolves[]
      as target for an MSAA-resolve operation in TGfx.EndPass.
      Default: False }
    property ResolveAttachment: Boolean read FHandle.resolve_attachment write FHandle.resolve_attachment;

    { The image can be used as parent resource of a depth-stencil-attachmnet-view
      which is then passes into TGfx.BeginPass via TPass.Attachments.DepthStencil
      as depth-stencil-buffer.
      Default: False }
    property DepthStencilAttachment: Boolean read FHandle.depth_stencil_attachment write FHandle.depth_stencil_attachment;

    { The image content cannot be updated from the CPU side (but may be updated
      by the GPU in a render- or compute-pass).
      Default: True }
    property Immutable: Boolean read FHandle.immutable write FHandle.immutable;

    { The image content is updated infrequently by the CPU via TImage.Update.
      Default: False }
    property DynamicUpdate: Boolean read FHandle.dynamic_update write FHandle.dynamic_update;

    { The image content is updated each frame by the CPU via TImage.Update.
      Default: False }
    property StreamUpdate: Boolean read FHandle.stream_update write FHandle.stream_update;
  end;
  PImageUsage = ^TImageUsage;

type
  { Defines the content of an array of TRange records, each range pointing to
    the pixel data for one mip-level. For array-, cubemap- and 3D-images each
    mip-level contains all slice-surfaces for that mip-level in a single tightly
    packed memory block.

    The size of a single surface in a mip-level for a regular 2D texture
    can be computed via:

      TPixelFormat.SurfacePitch(MipWidth, MipHeight, 1);

    For array- and 3d-images the size of a single miplevel is:

        NumSlices * TPixelFormat.SurfacePitch(MipWidth, MipHeight, 1);

    For cubemap-images the size of a single mip-level is:

        6 * TPixelFormat.SurfacePitchy(MipWidth, MipHeight, 1);

    The order of cubemap-faces is in a mip-level data chunk is:

        [0] => +X
        [1] => -X
        [2] => +Y
        [3] => -Y
        [4] => +Z
        [5] => -Z }
  TImageData = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_image_data);
    procedure InitFrom(const ASrc: _sg_image_data);
  {$ENDREGION 'Internal Declarations'}
  public
    class function Create: TImageData; static;
    procedure Init; inline;
  public
    MipLevels: array [0..MAX_MIPMAPS - 1] of TRange;
  end;
  PImageData = ^TImageData;

type
  { Creation parameters for TImage objects.

    The default configuration is:

    .ImageType:         TwoD
    .Usage:             .Immutable = True
    .Width              0 (must be set to >0)
    .Height             0 (must be set to >0)
    .NumSlices          1 (3D textures: depth; array textures: number of layers)
    .NumMipmaps:        1
    .PixelFormat:       Rgba8 for textures, or TGfxDesc.Environment.Defaults.ColorFormat
                        for render targets
    .SampleCount:       1 for textures, or TGfxDesc.Environment.Defaults.SampleCount
                        for render targets
    .Data               a TImageData record to define the initial content
    .TraceLabel         '' (optional string label for trace hooks)

    Q: Why is the default SampleCount for render targets identical with the
    "default sample count" from TGfxDesc.Environment.Defaults.SampleCount?

    A: So that it matches the default sample count in pipeline objects. Even
    though it is a bit strange/confusing that offscreen render targets by default
    get the same sample count as 'default swapchains', but it's better that an
    offscreen render target created with default parameters matches a pipeline
    object created with default parameters.

    NOTE:

    Regular images used as texture binding with Usage.Immutable must be fully
    initialized by providing a valid .Data member which points to initialization
    data.

    Images with Usage.*Attachment or Usage.StorageImage must *not* be created
    with initial content. Be aware that the initial content of pass attachment
    and storage images is undefined (not guaranteed to be zeroed).

    ADVANCED TOPIC: Injecting native 3D-API textures:

    The following record fields allow to inject your own GL, Metal or D3D11
    textures:

    .GLTextures[0..NUM_INFLIGHT_FRAMES - 1]
    .MtlTextures[0..NUM_INFLIGHT_FRAMES - 1]
    .D3D11Texture

    For GL, you can also specify the texture target or leave it empty to use
    the default texture target for the image type (GL_TEXTURE_2D for
    TImageType.TwoD etc)

    The same rules apply as for injecting native buffers (see TBufferDesc
    documentation for more details). }
  TImageDesc = record
  {$REGION 'Internal Declarations'}
  public
    procedure _Convert(out ADst: _sg_image_desc);
    procedure _InitFrom(const ASrc: _sg_image_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    ImageType: TImageType;
    Usage: TImageUsage;
    Width: Integer;
    Height: Integer;
    NumSlices: Integer;
    NumMipmaps: Integer;
    PixelFormat: TPixelFormat;
    SampleCount: Integer;
    Data: TImageData;
    TraceLabel: UTF8String;

    (* Optionally inject backend-specific resources: *)

    { GL specific }
    GLTextures: array [0..NUM_INFLIGHT_FRAMES - 1] of UInt32;
    GLTextureTarget: UInt32;

    { Metal specific [0..NUM_INFLIGHT_FRAMES - 1] }
    MetalTextures: array [0..NUM_INFLIGHT_FRAMES - 1] of Pointer;

    { D3D11 specific }
    D3D11Texture: IInterface;
  public
    { Initializes with default values }
    class function Create: TImageDesc; inline; static;
    procedure Init;
  end;
  PImageDesc = ^TImageDesc;

type
  TD3D11ImageInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_d3d11_image_info;
    function GetTex2D: IInterface; inline;
    function GetTex3D: IInterface; inline;
    function GetResource: IInterface; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { ID3D11Texture2D }
    property Tex2D: IInterface read GetTex2D;

    { ID3D11Texture3D }
    property Tex3D: IInterface read GetTex3D;

    { ID3D11Resource* (either Tex2D or Tex3D) }
    property Resource: IInterface read GetResource;
  end;

type
  TMetalImageInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_mtl_image_info;
    function GetTexture(const AIndex: Integer): Pointer;
  {$ENDREGION 'Internal Declarations'}
  public
    { MTLTexture ObjectID. AIndex ranges from 0..NUM_INFLIGHT_FRAMES-1 }
    property Textures[const AIndex: Integer]: Pointer read GetTexture;

    property ActiveSlot: Integer read FHandle.active_slot;
  end;

type
  TGLImageInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_gl_image_info;
    function GetTexture(const AIndex: Integer): Cardinal;
  {$ENDREGION 'Internal Declarations'}
  public
    { MTLTexture ObjectID. AIndex ranges from 0..NUM_INFLIGHT_FRAMES-1 }
    property Textures[const AIndex: Integer]: Cardinal read GetTexture;

    property TextureTarget: Cardinal read FHandle.tex_target;
    property ActiveSlot: Integer read FHandle.active_slot;
  end;

type
  { Images used as textures and render-pass attachments.

    An image can be created synchronously or asynchronously.
    For synchronous creation, use Create/Init and Free.
    For asynchronous creation, use Allocate, Setup, Teardown, Deallocate and
    Fail. }
  TImage = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_image;
    function GetState: TResourceState; inline;
    function GetInfo: TImageInfo; inline;
    function GetDesc: TImageDesc; inline;
    function GetImageType: TImageType; inline;
    function GetWidth: Integer; inline;
    function GetHeight: Integer; inline;
    function GetNumSlices: Integer; inline;
    function GetNumMipmaps: Integer; inline;
    function GetPixelFormat: TPixelFormat; inline;
    function GetUsage: TImageUsage; inline;
    function GetSampleCount: Integer; inline;
    function GetD3D11ImageInfo: TD3D11ImageInfo; inline;
    function GetMetalImageInfo: TMetalImageInfo; inline;
    function GetGLImageInfo: TGLImageInfo; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Synchronous setup }
    constructor Create(const ADesc: TImageDesc);
    procedure Init(const ADesc: TImageDesc); inline;
    procedure Free; inline;

    { Asynchronous setup }
    procedure Allocate; inline;
    procedure Setup(const ADesc: TImageDesc); inline;
    procedure Teardown; inline;
    procedure Deallocate; inline;
    procedure Fail; inline;

    { Operations }
    procedure Update(const AData: TImageData); inline;

    { The resource Id }
    property Id: Cardinal read FHandle.id write FHandle.id;

    { Current resource state }
    property State: TResourceState read GetState;

    { Get runtime information about the image }
    property Info: TImageInfo read GetInfo;

    { Get description record matching the image.
      Note: not all creation attributes may be provided. }
    property Desc: TImageDesc read GetDesc;

    property ImageType: TImageType read GetImageType;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    property NumSlices: Integer read GetNumSlices;
    property NumMipmaps: Integer read GetNumMipmaps;
    property PixelFormat: TPixelFormat read GetPixelFormat;
    property Usage: TImageUsage read GetUsage;
    property SampleCount: Integer read GetSampleCount;

    { D3D11: get internal image resource objects }
    property D3D11ImageInfo: TD3D11ImageInfo read GetD3D11ImageInfo;

    { Metal: get internal image resource objects }
    property MetalImageInfo: TMetalImageInfo read GetMetalImageInfo;

    { OpenGL: get internal image resource objects }
    property GLImageInfo: TGLImageInfo read GetGLImageInfo;
  end;
  PImage = ^TImage;

type
  { Creation parameters for TSampler objects. Defaults:

    .MinFilter:         TFilter.Nearest
    .MagFilter:         TFilter.Nearest
    .MipmapFilter:      TFilter.Nearest
    .WrapU:             TWrap.Repeating
    .WrapV:             TWrap.Repeating
    .WrapW:             TWrap.Repeating (only TImageType.ThreeD)
    .MinLod:            0.0
    .MaxLod:            Single.MaxValue
    .BorderColor        OpaqueBlack
    .Compare            TCompareFunc.Never
    .MaxAnisotropy      1 (must be 1..16) }
  TSamplerDesc = record
  {$REGION 'Internal Declarations'}
  public
    procedure _Convert(out ADst: _sg_sampler_desc);
    procedure _InitFrom(const ASrc: _sg_sampler_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    MinFilter: TFilter;
    MagFilter: TFilter;
    MipmapFilter: TFilter;
    WrapU: TWrap;
    WrapV: TWrap;
    WrapW: TWrap;
    MinLod: Single;
    MaxLod: Single;
    BorderColor: TBorderColor;
    Compare: TCompareFunc;
    MaxAnisotropy: Integer;
    TraceLabel: UTF8String;

    (* Optionally inject backend-specific resources: *)

    { GL specific }
    GLSampler: UInt32;

    { Metal specific }
    MtlSampler: Pointer;

    { D3D11 specific }
    D3D11Sampler: IInterface;
  public
    { Initializes with default values }
    class function Create: TSamplerDesc; inline; static;
    procedure Init;
  end;
  PSamplerDesc = ^TSamplerDesc;

type
  TD3D11SamplerInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_d3d11_sampler_info;
    function GetSampler: IInterface; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { ID3D11SamplerState }
    property Sampler: IInterface read GetSampler;
  end;

type
  TMetalSamplerInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_mtl_sampler_info;
  {$ENDREGION 'Internal Declarations'}
  public
    { MTLSamplerState ObjectID }
    property Sampler: Pointer read FHandle.smp;
  end;

type
  TGLSamplerInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_gl_sampler_info;
  {$ENDREGION 'Internal Declarations'}
  public
    property Sampler: Cardinal read FHandle.smp;
  end;

type
  { Sampler objects describing how a texture is sampled in a shader.

    A sampler can be created synchronously or asynchronously.
    For synchronous creation, use Create/Init and Free.
    For asynchronous creation, use Allocate, Setup, Teardown, Deallocate and
    Fail. }
  TSampler = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_sampler;
    function GetState: TResourceState; inline;
    function GetInfo: TSamplerInfo; inline;
    function GetDesc: TSamplerDesc; inline;
    function GetD3D11SamplerInfo: TD3D11SamplerInfo; inline;
    function GetMetalSamplerInfo: TMetalSamplerInfo; inline;
    function GetGLSamplerInfo: TGLSamplerInfo; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Synchronous setup }
    constructor Create(const ADesc: TSamplerDesc);
    procedure Init(const ADesc: TSamplerDesc); inline;
    procedure Free; inline;

    { Asynchronous setup }
    procedure Allocate; inline;
    procedure Setup(const ADesc: TSamplerDesc); inline;
    procedure Teardown; inline;
    procedure Deallocate; inline;
    procedure Fail; inline;

    { The resource Id }
    property Id: Cardinal read FHandle.id write FHandle.id;

    { Current resource state }
    property State: TResourceState read GetState;

    { Get runtime information about the sampler }
    property Info: TSamplerInfo read GetInfo;

    { Get description record matching the sampler.
      Note: not all creation attributes may be provided. }
    property Desc: TSamplerDesc read GetDesc;

    { D3D11: get internal sampler resource objects }
    property D3D11SamplerInfo: TD3D11SamplerInfo read GetD3D11SamplerInfo;

    { Metal: get internal sampler resource objects }
    property MetalSamplerInfo: TMetalSamplerInfo read GetMetalSamplerInfo;

    { OpenGL: get internal sampler resource objects }
    property GLSamplerInfo: TGLSamplerInfo read GetGLSamplerInfo;
  end;
  PSampler = ^TSampler;

type
  { Allows to query the type of a view object via TView.ViewType }
  TViewType = (
    Invalid                = _SG_VIEWTYPE_INVALID,
    StorageBuffer          = _SG_VIEWTYPE_STORAGEBUFFER,
    StorageImage           = _SG_VIEWTYPE_STORAGEIMAGE,
    Texture                = _SG_VIEWTYPE_TEXTURE,
    ColorAttachment        = _SG_VIEWTYPE_COLORATTACHMENT,
    ResolveAttachment      = _SG_VIEWTYPE_RESOLVEATTACHMENT,
    DepthStencilAttachment = _SG_VIEWTYPE_DEPTHSTENCILATTACHMENT);

type
  TBufferViewDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_buffer_view_desc);
    procedure InitFrom(const ASrc: _sg_buffer_view_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Buffer: TBuffer;
    Offset: Integer;
  end;
  PBufferViewDesc = ^TBufferViewDesc;

type
  TImageViewDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_image_view_desc);
    procedure InitFrom(const ASrc: _sg_image_view_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Image: TImage;
    MipLevel: Integer;

    { Cube texture: face;
      Array texture: layer;
      3D texture: depth-slice }
    Slice: Integer;
  end;
  PImageViewDesc = ^TImageViewDesc;

type
  TTextureViewRange = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_texture_view_range;
  {$ENDREGION 'Internal Declarations'}
  public
    property Base: Integer read FHandle.base write FHandle.base;
    property Count: Integer read FHandle.count write FHandle.count;
  end;
  PTextureViewRange = ^TTextureViewRange;

type
  TTextureViewDesc = record
  {$REGION 'Internal Declarations'}
  public
    procedure _Convert(out ADst: _sg_texture_view_desc);
    procedure _InitFrom(const ASrc: _sg_texture_view_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Image: TImage;
    MipLevels: TTextureViewRange;

    { Cube texture: face;
      Array texture: layer;
      3D texture: depth-slice }
    Slices: TTextureViewRange;
  end;
  PTextureViewDesc = ^TTextureViewDesc;

type
  { Creation params for TView objects.

    View objects are passed into TGfx.ApplyBindings (for texture-,
    storage-buffer- and storage-image views), and TGfx.BeginPass (for color-,
    resolve- and depth-stencil-attachment views).

    The view type is determined by initializing one of the sub-records of
    TViewDesc:

    .Texture            a texture-view object will be created
        .Image          the TImage parent resource
        .MipLevels      optional mip-level range, keep zero-initialized for the
                        entire mipmap chain
            .Base       the first mip level
            .Count      number of mip levels, keeping this zero-initialized means
                        'all remaining mip levels'
        .Slices         optional slice range, keep zero-initialized to include
                        all slices
            .Base       the first slice
            .Count      number of slices, keeping this zero-initializied means
                        'all remaining slices'

    .StorageBuffer      a storage-buffer-view object will be created
        .Buffer         the TBuffer parent resource, must have been created
                        with `TBufferDesc.Usage.StorageBuffer = True`
        .Offset         optional 256-byte aligned byte-offset into the buffer

    .StorageImage       a storage-image-view object will be created
        .Image          the TImage parent resource, must have been created
                        with `TImageDesc.Usage.StorageImage = True`
        .MipLevel       selects the mip-level for the compute shader to write
        .Slice          selects the slice for the compute shader to write

    .ColorAttachment    a color-attachment-view object will be created
        .Image          the TImage parent resource, must have been created
                        with `TImageDesc.Usage.ColorAttachment = True`
        .MipLevel       selects the mip-level to render into
        .Slice          selects the slice to render into

    .ResolveAttachment  a resolve-attachment-view object will be created
        .Image          the TImage parent resource, must have been created
                        with `TImageDesc.Usage.ResolveAttachment = True`
        .MipLevel       selects the mip-level to msaa-resolve into
        .Slice          selects the slice to msaa-resolve into

    .DepthStencilAttachment  a depth-stencil-attachment-view object will be created
        .Image          the TImage parent resource, must have been created
                        with `TImageDesc.Usage.DepthStencilAttachment = True`
        .MipLevel       selects the mip-level to render into
        .Slice          selects the slice to render into }
  TViewDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_view_desc);
    procedure InitFrom(const ASrc: _sg_view_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Texture: TTextureViewDesc;
    StorageBuffer: TBufferViewDesc;
    StorageImage: TImageViewDesc;
    ColorAttachment: TImageViewDesc;
    ResolveAttachment: TImageViewDesc;
    DepthStencilAttachment: TImageViewDesc;
    TraceLabel: UTF8String;
  public
    { Initializes with default values }
    class function Create: TViewDesc; inline; static;
    procedure Init;
  end;

type
  TD3D11ViewInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_d3d11_view_info;
    function GetShaderResourceView: IInterface; inline;
    function GetUnorderedAccessView: IInterface; inline;
    function GetRenderTargetView: IInterface; inline;
    function GetDepthStencilView: IInterface; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { ID3D11ShaderResourceView }
    property ShaderResourceView: IInterface read GetShaderResourceView;

    { ID3D11UnorderedAccessView }
    property UnorderedAccessView: IInterface read GetUnorderedAccessView;

    { ID3D11RenderTargetView }
    property RenderTargetView: IInterface read GetRenderTargetView;

    { ID3D11DepthStencilView }
    property DepthStencilView: IInterface read GetDepthStencilView;
  end;

type
  TGLViewInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_gl_view_info;
    function GetTextureView(const AIndex: Integer): Cardinal; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { AIndex ranges from 0..NUM_INFLIGHT_FRAMES-1 }
    property TextureViews[const AIndex: Integer]: Cardinal read GetTextureView;

    property MsaaRenderBuffer: Cardinal read FHandle.msaa_render_buffer;
    property MsaaResolveFrameBuffer: Cardinal read FHandle.msaa_resolve_frame_buffer;
  end;

type
  { A resource view object used for bindings and render-pass attachments.

    A resource view can be created synchronously or asynchronously.
    For synchronous creation, use Create/Init and Free.
    For asynchronous creation, use Allocate, Setup, Teardown, Deallocate and
    Fail. }
  TView = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_view;
    function GetState: TResourceState; inline;
    function GetInfo: TViewInfo; inline;
    function GetDesc: TViewDesc; inline;
    function GetD3D11ViewInfo: TD3D11ViewInfo; inline;
    function GetGLViewInfo: TGLViewInfo; inline;
    function GetViewType: TViewType; inline;
    function GetImage: TImage; inline;
    function GetBuffer: TBuffer; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Synchronous setup }
    constructor Create(const ADesc: TViewDesc);
    procedure Init(const ADesc: TViewDesc); inline;
    procedure Free; inline;

    { Asynchronous setup }
    procedure Allocate; inline;
    procedure Setup(const ADesc: TViewDesc); inline;
    procedure Teardown; inline;
    procedure Deallocate; inline;
    procedure Fail; inline;

    { The resource Id }
    property Id: Cardinal read FHandle.id write FHandle.id;

    { Current resource state }
    property State: TResourceState read GetState;

    { Get runtime information about the view }
    property Info: TViewInfo read GetInfo;

    { Get description record matching the view.
      Note: not all creation attributes may be provided. }
    property Desc: TViewDesc read GetDesc;

    { D3D11: get internal view resource objects }
    property D3D11ViewInfo: TD3D11ViewInfo read GetD3D11ViewInfo;

    { OpenGL: get internal view resource objects }
    property GLViewInfo: TGLViewInfo read GetGLViewInfo;

    property ViewType: TViewType read GetViewType;
    property Image: TImage read GetImage;
    property Buffer: TBuffer read GetBuffer;
  end;
  PView = ^TView;

type
  TShaderStage = (
    None     = _SG_SHADERSTAGE_NONE,
    Vertex   = _SG_SHADERSTAGE_VERTEX,
    Fragment = _SG_SHADERSTAGE_FRAGMENT,
    Compute  = _SG_SHADERSTAGE_COMPUTE);

type
  TShaderFunction = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_shader_function);
    procedure InitFrom(const ASrc: _sg_shader_function);
  {$ENDREGION 'Internal Declarations'}
  public
    Source: AnsiString;
    ByteCode: TRange;
    Entry: AnsiString;

    { Default: 'vs_4_0' or 'ps_4_0' }
    D3D11Target: AnsiString;

    D3D11FilePath: AnsiString;
  end;
  PShaderFunction = ^TShaderFunction;

type
  TShaderAttrBaseType = (
    Undefined   = _SG_SHADERATTRBASETYPE_UNDEFINED,
    Float       = _SG_SHADERATTRBASETYPE_FLOAT,
    SignedInt   = _SG_SHADERATTRBASETYPE_SINT,
    UnsignedInt = _SG_SHADERATTRBASETYPE_UINT);

type
  TShaderVertexAttr = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_shader_vertex_attr);
    procedure InitFrom(const ASrc: _sg_shader_vertex_attr);
  {$ENDREGION 'Internal Declarations'}
  public
    { Default: Undefined (disables validation) }
    BaseType: TShaderAttrBaseType;

    { [optional] GLSL attribute name }
    GlslName: AnsiString;

    { HLSL semantic name }
    HlslSemName: AnsiString;

    { HLSL semantic index }
    HlslSemIndex: Byte;
  end;
  PShaderVertexAttr = ^TShaderVertexAttr;

type
  TGlslShaderUniform = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_glsl_shader_uniform);
    procedure InitFrom(const ASrc: _sg_glsl_shader_uniform);
  {$ENDREGION 'Internal Declarations'}
  public
    UniformType: TUniformType;

    { 0 or 1 for scalars, >1 for arrays }
    ArrayCount: Word;

    { glsl name binding is required on GL 4.1 and GLES 3 }
    GlslName: AnsiString;
  end;
  PGlslShaderUniform = ^TGlslShaderUniform;

type
  TShaderUniformBlock = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_shader_uniform_block);
    procedure InitFrom(const ASrc: _sg_shader_uniform_block);
  {$ENDREGION 'Internal Declarations'}
  public
    Stage: TShaderStage;
    Size: Integer;

    { HLSL register(bn) }
    HlslRegisterBN: Byte;

    { MSL [[buffer(n)]] }
    MslBufferN: Byte;

    { WGSL @group(0) @binding(n) }
    WgslGroup0BindingN: Byte;

    { Vulkan GLSL layout(set=0, binding=n) }
    SpirvSet0BindingN: Byte;

    Layout: TUniformLayout;
    GlslUniforms: array [0..MAX_UNIFORMBLOCK_MEMBERS - 1] of TGlslShaderUniform;
  end;
  PShaderUniformBlock = ^TShaderUniformBlock;

type
  TShaderTextureView = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_shader_texture_view);
    procedure InitFrom(const ASrc: _sg_shader_texture_view);
  {$ENDREGION 'Internal Declarations'}
  public
    Stage: TShaderStage;
    ImageType: TImageType;
    SampleType: TImageSampleType;
    MultiSampled: Boolean;

    { HLSL register(tn) bind slot }
    HlslRegisterTN: Byte;

    { MSL [[texture(n)]] bind slot }
    MslTextureN: Byte;

    { WGSL @group(1) @binding(n) bind slot }
    WgslGroup1BindingN: Byte;

    { Vulkan GLSL layout(set=1, binding=0) }
    SpirvSet1BindingN: Byte;
  end;
  PShaderTextureView = ^TShaderTextureView;

type
  TShaderStorageBufferView = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_shader_storage_buffer_view);
    procedure InitFrom(const ASrc: _sg_shader_storage_buffer_view);
  {$ENDREGION 'Internal Declarations'}
  public
    Stage: TShaderStage;
    ReadOnly: Boolean;

    { HLSL register(tn) bind slot (for readonly access) }
    HlslRegisterTN: Byte;

    { HLSL register(un) bind slot (for read/write access) }
    HlslRegisterUN: Byte;

    { MSL [[buffer(n)]] bind slot }
    MslBufferN: Byte;

    { WGSL @group(1) @binding(n) bind slot }
    WgslGroup1BindingN: Byte;

    { Vulkan GLSL layout(set=1, binding=0) }
    SpirvSet1BindingN: Byte;

    { GLSL layout(binding=n) }
    GlslBindingN: Byte;
  end;
  PShaderStorageBufferView = ^TShaderStorageBufferView;

type
  TShaderStorageImageView = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_shader_storage_image_view);
    procedure InitFrom(const ASrc: _sg_shader_storage_image_view);
  {$ENDREGION 'Internal Declarations'}
  public
    Stage: TShaderStage;
    ImageType: TImageType;

    { Shader-access pixel format }
    AccessFormat: TPixelFormat;

    { False means read/write access }
    WriteOnly: Boolean;

    { HLSL register(un) bind slot}
    HlslRegisterUN: Byte;

    { MSL [[texture(n)]] bind slot }
    MslTextureN: Byte;

    { WGSL @group(2) @binding(n) bind slot }
    WgslGroup1BindingN: Byte;

    { Vulkan GLSL layout(set=1, binding=0) }
    SpirvSet1BindingN: Byte;

    { GLSL layout(binding=n) }
    GlslBindingN: Byte;
  end;
  PShaderStorageImageView = ^TShaderStorageImageView;

type
  TShaderView = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_shader_view);
    procedure InitFrom(const ASrc: _sg_shader_view);
  {$ENDREGION 'Internal Declarations'}
  public
    Texture: TShaderTextureView;
    StorageBuffer: TShaderStorageBufferView;
    StorageImage: TShaderStorageImageView;
  end;
  PShaderView = ^TShaderView;

type
  TShaderSampler = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_shader_sampler);
    procedure InitFrom(const ASrc: _sg_shader_sampler);
  {$ENDREGION 'Internal Declarations'}
  public
    Stage: TShaderStage;
    SamplerType: TSamplerType;

    { HLSL register(sn) bind slot}
    HlslRegisterSN: Byte;

    { MSL [[sampler(n)]] bind slot }
    MslSamplerN: Byte;

    { WGSL @group(1) @binding(n) bind slot }
    WgslGroup1BindingN: Byte;

    { Vulkan GLSL layout(set=1, binding=0) }
    SpirvSet1BindingN: Byte;
  end;
  PShaderSampler = ^TShaderSampler;

type
  TShaderTextureSamplerPair = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_shader_texture_sampler_pair);
    procedure InitFrom(const ASrc: _sg_shader_texture_sampler_pair);
  {$ENDREGION 'Internal Declarations'}
  public
    Stage: TShaderStage;

    { Must be TViewType.Texture }
    ViewSlot: TViewType;

    SamplerSlot: Byte;

    { glsl name binding required because of GL 4.1 and GLES 3 }
    GlslName: AnsiString;
  end;
  PShaderTextureSamplerPair = ^TShaderTextureSamplerPair;

type
  TMetalShaderThreadsPerThreadgroup = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_mtl_shader_threads_per_threadgroup);
    procedure InitFrom(const ASrc: _sg_mtl_shader_threads_per_threadgroup);
  {$ENDREGION 'Internal Declarations'}
  public
    X: Integer;
    Y: Integer;
    Z: Integer;
  end;
  PMetalShaderThreadsPerThreadgroup = ^TMetalShaderThreadsPerThreadgroup;

type
  { Used as parameter of TShader.Create/Init to create a shader object which
    communicates shader source or bytecode and shader interface reflection
    information to Sokol.

    If you use the Sokol shader compilier you can ignore the following
    information since the TShaderDesc record will be code-generated.

    Otherwise you need to provide the following information to the
    TShader.Create/Init call:

    - a vertex- and fragment-shader function:
      - the shader source or bytecode
      - an optional entry point name
      - for D3D11: an optional compile target when source code is provided
        (the defaults are "vs_4_0" and "ps_4_0")

    - ...or alternatively, a compute function:
      - the shader source or bytecode
      - an optional entry point name
      - for D3D11: an optional compile target when source code is provided
        (the default is "cs_5_0")

    - vertex attributes required by some backends (not for compute shaders):
      - the vertex attribute base type (undefined, float, signed int, unsigned int),
        this information is only used in the validation layer to check that the
        pipeline object vertex formats are compatible with the input vertex attribute
        type used in the vertex shader. NOTE that the default base type
        'undefined' skips the validation layer check.
      - for the GL backend: optional vertex attribute names used for name lookup
      - for the D3D11 backend: semantic names and indices

    - only for compute shaders on the Metal backend:
      - the workgroup size aka 'threads per thread-group'

        In other 3D APIs this is declared in the shader code:
        - GLSL: `layout(local_size_x=x, local_size_y=y, local_size_y=z) in;`
        - HLSL: `[numthreads(x, y, z)]`
        - WGSL: `@workgroup_size(x, y, z)`
        ...but in Metal the workgroup size is declared on the CPU side

    - reflection information for each uniform block binding used by the shader:
      - the shader stage the uniform block appears in (TShaderStage.()
      - the size in bytes of the uniform block
      - backend-specific bindslots:
        - HLSL: the constant buffer register `register(b0..7)`
        - MSL: the buffer attribute `[[buffer(0..7)]]`
        - WGSL: the binding in `@group(0) @binding(0..15)`
      - GLSL only: a description of the uniform block interior
        - the memory layout standard (TUniformLayout.*)
        - for each member in the uniform block:
          - the member type (TUniform.*)
          - if the member is an array, the array count
          - the member name

    - reflection information for each texture-, storage-buffer and
      storage-image bindings by the shader, each with an associated
      view type:
      - texture bindings => texture views
      - storage-buffer bindings => storage-buffer views
      - storage-image bindings => storage-image views

    - texture bindings must provide the following information:
      - the shader stage the texture binding appears in (TShaderStage.*)
      - the image type (TImageType.*)
      - the image-sample type (TImageSampleType.*)
      - whether the texture is multisampled
      - backend specific bindslots:
        - HLSL: the texture register `register(t0..31)`
        - MSL: the texture attribute `[[texture(0..31)]]`
        - WGSL: the binding in `@group(1) @binding(0..127)`

    - storage-buffer bindings must provide the following information:
      - the shader stage the storage buffer appears in (TShaderStage.*)
      - whether the storage buffer is readonly
      - backend specific bindslots:
        - HLSL:
          - for storage buffer bindings: `register(t0..31)`
          - for read/write storage buffer bindings: `register(u0..31)`
        - MSL: the buffer attribute `[[buffer(8..23)]]`
        - WGSL: the binding in `@group(1) @binding(0..127)`
        - GL: the binding in `layout(binding=0..TLimits.MaxStorageBufferBindingsPerStage)`

    - storage-image bindings must provide the following information:
      - the shader stage (*must* be TShaderStage.Compute)
      - whether the storage image is writeonly or readwrite (for readonly
        access use a regular texture binding instead)
      - the image type expected by the shader (TImageType.*)
      - the access pixel format expected by the shader (TPixelFormat.*),
        note that only a subset of pixel formats is allowed for storage image
        bindings
      - backend specific bindslots:
        - HLSL: the UAV register `register(u0..31)`
        - MSL: the texture attribute `[[texture(0..31)]]`
        - WGSL: the binding in `@group(1) @binding(0..127)`
        - GLSL: the binding in `layout(binding=0..TLimits.MaxStorageBufferBindingsPerStage, [access_format])`

    - reflection information for each sampler used by the shader:
      - the shader stage the sampler appears in (TShaderStage.*)
      - the sampler type (TSamplerType.*)
      - backend specific bindslots:
        - HLSL: the sampler register `register(s0..11)`
        - MSL: the sampler attribute `[[sampler(0..11)]]`
        - WGSL: the binding in `@group(0) @binding(0..127)`

    - reflection information for each texture-sampler pair used by
      the shader:
      - the shader stage (TShaderStage.*)
      - the texture's array index in the TShaderDesc.Views[] array
      - the sampler's array index in the TShaderDesc.Samplers[] array
      - GLSL only: the name of the combined image-sampler object

    The number and order of items in the TShaderDesc.Attrs[] array corresponds
    to the items in TPipelineDesc.Layout.Attrs.

      - TShaderDesc.Attrs[N] => TPipelineDesc.Layout.Attrs[N]

    NOTE that vertex attribute indices currently cannot have gaps.

    The items index in the TShaderDesc.UniformBlocks[] array corresponds
    to the AUBSlot arg in TGfx.ApplyUniforms:

        - TShaderDesc.UniformBlocks[N] => TGfx.ApplyUniforms(N, ...)

    The items in the TShaderDesc.Views[] array directly map to the views in the
    TBindings.Views[] array!

    For all GL backends, shader source-code must be provided. For D3D11 and
    Metal, either shader source-code or byte-code can be provided.

    NOTE that the uniform-block, view and sampler arrays may have gaps. This
    allows to use the same TBindings struct for different but related
    shader variations.

    For D3D11, if source code is provided, the d3dcompiler_47.dll will be loaded
    on demand. If this fails, shader creation will fail. When compiling HLSL
    source code, you can provide an optional target string via
    TShaderStageDesc.D3D11Target, the default target is "vs_4_0" for the
    vertex shader stage and "ps_4_0" for the pixel shader stage.
    You may optionally provide the file path to enable the default #include
    handler behavior when compiling source code. }
  TShaderDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_shader_desc);
    procedure InitFrom(const ASrc: _sg_shader_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    VertexFunc: TShaderFunction;
    FragmentFunc: TShaderFunction;
    ComputeFunc: TShaderFunction;
    Attrs: array [0..MAX_VERTEX_ATTRIBUTES - 1] of TShaderVertexAttr;
    UniformBlocks: array [0..MAX_UNIFORMBLOCK_BINDSLOTS - 1] of TShaderUniformBlock;
    Views: array [0..MAX_VIEW_BINDSLOTS - 1] of TShaderView;
    Samplers: array [0..MAX_SAMPLER_BINDSLOTS - 1] of TShaderSampler;
    TextureSamplerPairs: array [0..MAX_TEXTURE_SAMPLER_PAIRS - 1] of TShaderTextureSamplerPair;
    MtlThreadsPerThreadgroup: TMetalShaderThreadsPerThreadgroup;
    TraceLabel: UTF8String;
  public
    { Initializes with default values }
    class function Create: TShaderDesc; inline; static;
    procedure Init;
  end;
  PShaderDesc = ^TShaderDesc;

type
  { Helpers for defining native shaders to support the shader source code
    generator. }
  TNativeShaderDesc = _sg_shader_desc;
  PNativeShaderDesc = _Psg_shader_desc;

  _sg_shader_desc_helper = record helper for _sg_shader_desc
  public
    procedure Init;
  end;

type
  TD3D11ShaderInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_d3d11_shader_info;
    function GetVertexShader: IInterface; inline;
    function GetFragmentShader: IInterface; inline;
    function GetConstantBuffer(const AIndex: Integer): IInterface; inline;
  {$REGION 'Internal Declarations'}
  public
    { ID3D11Buffer. AIndex ranges from 0..MAX_UNIFORMBLOCK_BINDSLOTS-1 }
    property ConstantBuffers[const AIndex: Integer]: IInterface read GetConstantBuffer;

    { ID3D11VertexShader }
    property VertexShader: IInterface read GetVertexShader;

    { ID3D11PixelShader }
    property FragmentShader: IInterface read GetFragmentShader;
  end;

type
  TMetalShaderInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_mtl_shader_info;
  {$REGION 'Internal Declarations'}
  public
    { MTLLibrary ObjectID }
    property VertexLib: Pointer read FHandle.vertex_lib;

    { MTLLibrary ObjectID }
    property FragmentLib: Pointer read FHandle.fragment_lib;

    { MTLFunction ObjectID }
    property VertexFunc: Pointer read FHandle.vertex_func;

    { MTLFunction ObjectID }
    property FragmentFunc: Pointer read FHandle.fragment_func;
  end;

type
  TGLShaderInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_gl_shader_info;
  {$REGION 'Internal Declarations'}
  public
    property Prog: Cardinal read FHandle.prog;
  end;

type
  { Vertex- and fragment-shaders and shader interface information.

    An shader can be created synchronously or asynchronously.
    For synchronous creation, use Create/Init and Free.
    For asynchronous creation, use Allocate, Setup, Teardown, Deallocate and
    Fail. }
  TShader = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_shader;
    function GetState: TResourceState; inline;
    function GetInfo: TShaderInfo; inline;
    function GetDesc: TShaderDesc; inline;
    function GetD3D11ShaderInfo: TD3D11ShaderInfo; inline;
    function GetMetalShaderInfo: TMetalShaderInfo; inline;
    function GetGLShaderInfo: TGLShaderInfo; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Synchronous setup }
    constructor Create(const ADesc: TShaderDesc); overload;
    constructor Create(const ADesc: PNativeShaderDesc); overload;
    procedure Init(const ADesc: TShaderDesc); overload; inline;
    procedure Init(const ADesc: PNativeShaderDesc); overload; inline;
    procedure Free; inline;

    { Asynchronous setup }
    procedure Allocate; inline;
    procedure Setup(const ADesc: TShaderDesc); inline;
    procedure Teardown; inline;
    procedure Deallocate; inline;
    procedure Fail; inline;

    { The resource Id }
    property Id: Cardinal read FHandle.id write FHandle.id;

    { Current resource state }
    property State: TResourceState read GetState;

    { Get runtime information about the shader }
    property Info: TShaderInfo read GetInfo;

    { Get description record matching the shader.
      Note: not all creation attributes may be provided. }
    property Desc: TShaderDesc read GetDesc;

    { D3D11: get internal shader resource objects }
    property D3D11ShaderInfo: TD3D11ShaderInfo read GetD3D11ShaderInfo;

    { Metal: get internal shader resource objects }
    property MetalShaderInfo: TMetalShaderInfo read GetMetalShaderInfo;

    { OpenGL: get internal shader resource objects }
    property GLShaderInfo: TGLShaderInfo read GetGLShaderInfo;
  end;
  PShader = ^TShader;

type
  TVertexBufferLayoutState = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_vertex_buffer_layout_state);
    procedure InitFrom(const ASrc: _sg_vertex_buffer_layout_state);
  {$ENDREGION 'Internal Declarations'}
  public
    Stride: Integer;
    StepFunc: TVertexStep;
    StepRate: Integer;
  public
    constructor Create(const AStride: Integer; const AStepFunc: TVertexStep;
      const AStepRate: Integer);
    procedure Init(const AStride: Integer; const AStepFunc: TVertexStep;
      const AStepRate: Integer); inline;
  end;
  PVertexBufferLayoutState = ^TVertexBufferLayoutState;

type
  TVertexAttrState = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_vertex_attr_state);
    procedure InitFrom(const ASrc: _sg_vertex_attr_state);
  {$ENDREGION 'Internal Declarations'}
  public
    BufferIndex: Integer;
    Offset: Integer;
    Format: TVertexFormat;
  public
    constructor Create(const ABufferIndex, AOffset: Integer;
      const AFormat: TVertexFormat);
    procedure Init(const ABufferIndex, AOffset: Integer;
      const AFormat: TVertexFormat); inline;
  end;
  PVertexAttrState = ^TVertexAttrState;

type
  TVertexLayoutState = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_vertex_layout_state);
    procedure InitFrom(const ASrc: _sg_vertex_layout_state);
  {$ENDREGION 'Internal Declarations'}
  public
    Buffers: array [0..MAX_VERTEXBUFFER_BINDSLOTS - 1] of TVertexBufferLayoutState;
    Attrs: array [0..MAX_VERTEX_ATTRIBUTES - 1] of TVertexAttrState;
  public
    class function Create: TVertexLayoutState; static;
    procedure Init; inline;
  end;
  PVertexLayoutState = ^TVertexLayoutState;

type
  TStencilFaceState = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_stencil_face_state);
    procedure InitFrom(const ASrc: _sg_stencil_face_state);
  {$ENDREGION 'Internal Declarations'}
  public
    Compare: TCompareFunc;
    FailOp: TStencilOp;
    DepthFailOp: TStencilOp;
    PassOp: TStencilOp;
  public
    constructor Create(const ACompare: TCompareFunc; const AFailOp,
      ADepthFailOp, APassOp: TStencilOp);
    procedure Init(const ACompare: TCompareFunc; const AFailOp,
      ADepthFailOp, APassOp: TStencilOp); inline;
  end;
  PStencilFaceState = ^TStencilFaceState;

type
  TStencilState = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_stencil_state);
    procedure InitFrom(const ASrc: _sg_stencil_state);
  {$ENDREGION 'Internal Declarations'}
  public
    Enabled: Boolean;
    Front: TStencilFaceState;
    Back: TStencilFaceState;
    ReadMask: Byte;
    WriteMask: Byte;
    Ref: Byte;
  public
    constructor Create(const AEnabled: Boolean; const AReadMask, AWriteMask,
      ARef: Byte);
    procedure Init(const AEnabled: Boolean; const AReadMask, AWriteMask,
      ARef: Byte); inline;
  end;
  PStencilState = ^TStencilState;

type
  TDepthState = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_depth_state);
    procedure InitFrom(const ASrc: _sg_depth_state);
  {$ENDREGION 'Internal Declarations'}
  public
    PixelFormat: TPixelFormat;
    Compare: TCompareFunc;
    WriteEnabled: Boolean;
    Bias: Single;
    BiasSlopeScale: Single;
    BiasClamp: Single;
  public
    constructor Create(const APixelFormat: TPixelFormat;
      const ACompare: TCompareFunc; const AWriteEnabled: Boolean;
      const ABias, ABiasSlopeScale, ABiasClamp: Single);
    procedure Init(const APixelFormat: TPixelFormat;
      const ACompare: TCompareFunc; const AWriteEnabled: Boolean;
      const ABias, ABiasSlopeScale, ABiasClamp: Single); inline;
  end;
  PDepthState = ^TDepthState;

type
  TBlendState = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_blend_state);
    procedure InitFrom(const ASrc: _sg_blend_state);
  {$ENDREGION 'Internal Declarations'}
  public
    Enabled: Boolean;
    SrcFactorRgb: TBlendFactor;
    DstFactorRgb: TBlendFactor;
    OpRgb: TBlendOp;
    SrcFactorAlpha: TBlendFactor;
    DstFactorAlpha: TBlendFactor;
    OpAlpha: TBlendOp;
  public
    constructor Create(const AEnabled: Boolean; const ASrcFactorRgb,
      ADstFactorRgb: TBlendFactor; const AOpRgb: TBlendOp;
      const ASrcFactorAlpha, ADstFactorAlpha: TBlendFactor;
      const AOpAlpha: TBlendOp);
    procedure Init(const AEnabled: Boolean; const ASrcFactorRgb,
      ADstFactorRgb: TBlendFactor; const AOpRgb: TBlendOp;
      const ASrcFactorAlpha, ADstFactorAlpha: TBlendFactor;
      const AOpAlpha: TBlendOp); inline;
  end;
  PBlendState = ^TBlendState;

type
  TColorTargetState = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_color_target_state);
    procedure InitFrom(const ASrc: _sg_color_target_state);
  {$ENDREGION 'Internal Declarations'}
  public
    PixelFormat: TPixelFormat;
    WriteMask: TColorMask;
    Blend: TBlendState;
  public
    constructor Create(const APixelFormat: TPixelFormat;
      const AWriteMask: TColorMask);
    procedure Init(const APixelFormat: TPixelFormat;
      const AWriteMask: TColorMask); inline;
  end;
  PColorTargetState = ^TColorTargetState;

type
  { Defines all creation parameters for a TPipeline object:

    Pipeline objects come in two flavours:

    - render pipelines for use in render passes
    - compute pipelines for use in compute passes

    A compute pipeline only requires a compute shader object but no 'render
    state', while a render pipeline requires a vertex/fragment shader object and
    additional render state declarations:

    - the vertex layout for all input vertex buffers
    - a shader object
    - the 3D primitive type (points, lines, triangles, ...)
    - the index type (none, 16- or 32-bit)
    - all the fixed-function-pipeline state (depth-, stencil-, blend-state,
      etc...)

    If the vertex data has no gaps between vertex components, you can omit
    the .Layout.Buffers[].Stride and Layout.Attrs[].Offset items (leave them
    default-initialized to 0). Sokol will then compute the offsets and strides
    from the vertex component formats (.Layout.Attrs[].Format).
    Please note that ALL vertex attribute offsets must be 0 in order for the
    automatic offset computation to kick in.

    Note that if you use vertex-pulling from storage buffers instead of
    fixed-function vertex input you can simply omit the entire nested .Layout
    record.

    The default configuration is as follows:

    .Compute:               False (must be set to True for a compute pipeline_
    .Shader:                empty (must be initialized with a valid TShader!)
    .Layout:
        .Buffers[]:         vertex buffer layouts
            .Stride:        0 (if no stride is given it will be computed)
            .StepFunc       TVertexStep.PerVertex
            .StepRate       1
        .Attrs[]:           vertex attribute declarations
            .BufferIndex    0 the vertex buffer bind slot
            .Offset         0 (offsets can be omitted if the vertex layout has
                            no gaps)
            .Format         TVertexFormat.Invalid (must be initialized!)
    .Depth:
        .PixelFormat:       TGfxDesc.Context.DepthFormat
        .Compare:           TCompareFunc.Always
        .WriteEnabled:      False
        .Bias:              0.0
        .BiasSlopeScale:    0.0
        .BiasClamp:         0.0
    .Stencil:
        .Enabled:           False
        .Front/Back:
            .Compare:       TCompareFunc.Always
            .FailOp:        TStencilOp.Keep
            .DepthFailOp:   TStencilOp.Keep
            .PassOp:        TStencilOp.Keep
        .ReadMask:          0
        .WriteMask:         0
        .Ref:               0
    .ColorCount             1
    .Colors[0..ColorCount - 1]
        .PixelFormat        TGfxDesc.Context.ColorFormat
        .WriteMask:         TColorMask.Rgba
        .Blend:
            .Enabled:           False
            .SrcFactorRgb:      TBlendFactor.One
            .DstFactorRgb:      TBlendFactor.Zero
            .OpRgb:             TBlendOp.Add
            .SrcFactorAlpha:    TBlendFactor.One
            .DstFactorAlpha:    TBlendFactor.Zero
            .OpAlpha:           TBlendOp.Add
    .PrimitiveType:             TPrimitiveType.Triangles
    .IndexType:                 TIndexType.None
    .CullMode:                  TCullMode.None
    .FaceWinding:               TFaceWinding.ClockWise
    .SampleCount:               TGfxDesc.Context.SampleCount
    .BlendColor:                TAlphaColors.Null
    .AlphaToCoverageEnabled:    False
    .TraceLabel                 '' (optional string label for trace hooks) }
  TPipelineDesc = record
  {$REGION 'Internal Declarations'}
  public
    procedure _Convert(out ADst: _sg_pipeline_desc);
    procedure _InitFrom(const ASrc: _sg_pipeline_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Compute: Boolean;
    Shader: TShader;
    Layout: TVertexLayoutState;
    Depth: TDepthState;
    Stencil: TStencilState;
    ColorCount: Integer;
    Colors: array [0..MAX_COLOR_ATTACHMENTS - 1] of TColorTargetState;
    PrimitiveType: TPrimitiveType;
    IndexType: TIndexType;
    CullMode: TCullMode;
    FaceWinding: TFaceWinding;
    SampleCount: Integer;
    BlendColor: TColor;
    AlphaToCoverageEnabled: Boolean;
    TraceLabel: UTF8String;
  public
    { Initializes with default values }
    class function Create: TPipelineDesc; inline; static;
    procedure Init;
  end;
  PPipelineDesc = ^TPipelineDesc;

type
  TD3D11PipelineInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_d3d11_pipeline_info;
    function GetInputLayout: IInterface; inline;
    function GetRasterizerState: IInterface; inline;
    function GetDepthStencilState: IInterface; inline;
    function GetBlendState: IInterface; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { ID3D11InputLayout }
    property InputLayout: IInterface read GetInputLayout;

    { ID3D11RasterizerState }
    property RasterizerState: IInterface read GetRasterizerState;

    { ID3D11DepthStencilState }
    property DepthStencilState: IInterface read GetDepthStencilState;

    { ID3D11BlendState }
    property BlendState: IInterface read GetBlendState;
  end;

type
  TMetalPipelineInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_mtl_pipeline_info;
  {$ENDREGION 'Internal Declarations'}
  public
    { MTLRenderPipelineState ObjectID }
    property RenderPipelineState: Pointer read FHandle.rps;

    { MTLDepthStencilState ObjectID }
    property DepthStencilState: Pointer read FHandle.dss;
  end;

type
  { Associated shader and vertex-layout and render state resource.

    A pipeline can be created synchronously or asynchronously.
    For synchronous creation, use Create/Init and Free.
    For asynchronous creation, use Allocate, Setup, Teardown, Deallocate and
    Fail. }
  TPipeline = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_pipeline;
    function GetState: TResourceState; inline;
    function GetInfo: TPipelineInfo; inline;
    function GetDesc: TPipelineDesc; inline;
    function GetD3D11PipelineInfo: TD3D11PipelineInfo; inline;
    function GetMetalPipelineInfo: TMetalPipelineInfo; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Synchronous setup }
    constructor Create(const ADesc: TPipelineDesc);
    procedure Init(const ADesc: TPipelineDesc); inline;
    procedure Free; inline;

    { Asynchronous setup }
    procedure Allocate; inline;
    procedure Setup(const ADesc: TPipelineDesc); inline;
    procedure Teardown; inline;
    procedure Deallocate; inline;
    procedure Fail; inline;

    { The resource Id }
    property Id: Cardinal read FHandle.id write FHandle.id;

    { Current resource state }
    property State: TResourceState read GetState;

    { Get runtime information about the pipeline }
    property Info: TPipelineInfo read GetInfo;

    { Get description record matching the pipeline.
      Note: not all creation attributes may be provided. }
    property Desc: TPipelineDesc read GetDesc;

    { D3D11: get internal pipeline resource objects }
    property D3D11PipelineInfo: TD3D11PipelineInfo read GetD3D11PipelineInfo;

    { Metal: get internal pipeline resource objects }
    property MetalPipelineInfo: TMetalPipelineInfo read GetMetalPipelineInfo;
  end;
  PPipeline = ^TPipeline;

type
  { Used in TPass to provide render pass attachment views. Each type of pass
    attachment has it corresponding view type:

    TAttachments.colors[]:
      populate with color-attachment views, e.g.
      TViewDesc.ColorAttachment := ...

    TAttachments.Resolves[]:
      populate with resolve-attachment views, e.g.:
      TViewDesc.ResolveAttachment := ...

    TAttachments.DepthStencil:
      populate with depth-stencil-attachment views, e.g.:
      TViewDesc.DepthStencilAttachment := ... }
  TAttachments = record
  public
    Colors: array [0..MAX_COLOR_ATTACHMENTS - 1] of TView;
    Resolves: array [0..MAX_COLOR_ATTACHMENTS - 1] of TView;
    DepthStencil: TView;
  end;
  PAttachments = ^TAttachments;

type
  { The TPass record is passed as argument into the TGfx.BeginPass method.

    For a swapchain render pass, provide a TPassAction and TSwapchain record
    (for instance via the FromAppSwapchain helper from Neslib.Sokol.Glue):

      var Pass := TPass.Create;
      Pass.Action := ...
      Pass.Swapchain.FromAppSwapchain;
      TGfx.BeginPass(Pass);

    For an offscreen render pass, provide an TPassAction record with attachment
    view objects:

      var Pass := TPass.Create;
      Pass.Action := ...
      Pass.Attachments.Colors := ...
      Pass.Attachments.Resolves := ...
      Pass.Attachments.DepthStencil := ...
      TGfx.BeginPass(Pass);

    You can also omit the .Action member to get default pass action behaviour
    (clear to Color=grey, Depth=1 and Stencil=0).

    For a compute pass, just set the TPass.Compute Boolean to True. }
  TPass = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_pass;
    FTraceLabel: UTF8String;
    function GetAction: PPassAction; inline;
    function GetAttachments: PAttachments; inline;
    function GetSwapchain: PSwapchain; inline;
    procedure SetTraceLabel(const AValue: UTF8String); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    class function Create: TPass; inline; static;
    procedure Init; inline;

    property Compute: Boolean read FHandle.compute write FHandle.compute;
    property Action: PPassAction read GetAction;
    property Attachments: PAttachments read GetAttachments;
    property Swapchain: PSwapchain read GetSwapchain;
    property TraceLabel: UTF8String read FTraceLabel write SetTraceLabel;
  end;
  PPass = ^TPass;

type
  { Defines the resource bindings for the next draw call.

    To update the resource bindings, call TGfx.ApplyBindings with a populated
    TBindings struct. Note that TGfx.ApplyBindings must be called after
    TGfx.ApplyPipeline and that bindings are not preserved across
    TGfx.ApplyPipeline calls, even when the new pipeline uses the same 'bindings
    layout'.

    A resource binding struct contains:

    - 1..N vertex buffers
    - 1..N vertex buffer offsets
    - 0..1 index buffers
    - 0..1 index buffer offsets
    - 0..N resource views (texture-, storage-image, storage-buffer-views)
    - 0..N samplers

    Where 'N' is defined in the following constants:

    - MAX_VERTEXBUFFER_BINDSLOTS
    - MAX_VIEW_BINDSLOTS
    - MAX_SAMPLER_BINDSLOTS

    Note that inside compute passes vertex- and index-buffer-bindings are
    disallowed.

    When using the Sokol shader compiler for shader authoring, the
    `layout(binding=N)` for texture-, storage-image- and storage-buffer-bindings
    directly maps to the views-array index, for instance the following vertex-
    and fragment-shader interface for the Sokol shader compiler:

      @vs vs
      layout(binding=0) uniform vs_params ...;
      layout(binding=0) readonly buffer ssbo  ...;
      layout(binding=1) uniform texture2D vs_tex;
      layout(binding=0) uniform sampler vs_smp;
      ...
      @end

      @fs fs
      layout(binding=1) uniform fs_params ...;
      layout(binding=2) uniform texture2D fs_tex;
      layout(binding=1) uniform sampler fs_smp;
      ...
      @end

    ...would map to the following TBindings record:

      var Bnd: TBindings;
      Bnd.VertexBuffers[0] = ...;
      Bnd.Views[0] = ssbo_view;
      Bnd.Views[1] = vs_tex_view;
      Bnd.Views[2] = fs_tex_view;
      Bnd.Samplers[0] = vs_smp;
      Bnd.Samplers[1] = fs_smp;

    ...alternatively you can use code-generated slot indices:

      var Bnd: TBindings;
      Bnd.VertexBuffers[0] = ...;
      Bnd.Views[VIEW_ssbo] = ssbo_view;
      Bnd.Views[VIEW_vs_tex] = vs_tex_view;
      Bnd.Views[VIEW_fs_tex] = fs_tex_view;
      Bnd.Samplers[SMP_vs_smp] = vs_smp;
      Bnd.Samplers[SMP_fs_smp] = fs_smp;

    Resource bindslots for a specific shader/pipeline may have gaps, and an
    TBindings record may have populated bind slots which are not used by a
    specific shader. This allows to use the same TBindings record across
    different shader variants.

    When not using the Sokol shader compiler, the bindslot indices in the
    TBindings record need to match the per-binding reflection info slot indices
    in the TShaderDesc record (for details about that see the TShaderDesc record
    documentation).

    The optional buffer offsets can be used to put different unrelated
    chunks of vertex- and/or index-data into the same buffer objects. }
  TBindings = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_bindings;
    function GetVertexBuffer(const AIndex: Integer): TBuffer; inline;
    procedure SetVertexBuffer(const AIndex: Integer; const AValue: TBuffer); inline;
    function GetVertexBufferOffset(const AIndex: Integer): Integer; inline;
    procedure SetVertexBufferOffset(const AIndex, AValue: Integer); inline;
    function GetIndexBuffer: TBuffer; inline;
    procedure SetIndexBuffer(const AValue: TBuffer); inline;
    function GetView(const AIndex: Integer): TView; inline;
    procedure SetView(const AIndex: Integer; const AValue: TView); inline;
    function GetSampler(const AIndex: Integer): TSampler; inline;
    procedure SetSampler(const AIndex: Integer; const AValue: TSampler); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    class function Create: TBindings; static;
    procedure Init; inline;

    { Vertex buffers [0..MAX_VERTEXBUFFER_BINDSLOTS - 1] }
    property VertexBuffers[const AIndex: Integer]: TBuffer read GetVertexBuffer write SetVertexBuffer;
    property VertexBufferOffsets[const AIndex: Integer]: Integer read GetVertexBufferOffset write SetVertexBufferOffset;

    { Index buffer }
    property IndexBuffer: TBuffer read GetIndexBuffer write SetIndexBuffer;
    property IndexBufferOffset: Integer read FHandle.index_buffer_offset write FHandle.index_buffer_offset;

    { Views [0..MAX_VIEW_BINDSLOTS - 1] }
    property Views[const AIndex: Integer]: TView read GetView write SetView;

    { Samplers [0..MAX_SAMPLER_BINDSLOTS - 1] }
    property Samplers[const AIndex: Integer]: TSampler read GetSampler write SetSampler;
  end;

type
  { Installable callback functions to keep track of the sokol calls.
    This is useful for debugging, or keeping track of resource creation
    and destruction.

    Trace hooks are installed with TGfx.InstallTraceHooks. This returns
    another TTraceHooks record with the previous set of trace hook function
    pointers. These should be invoked by the new trace hooks to form a proper
    call chain.

    NOTE: This is a low-level C API and works with the underlying C structures
    and *not* with Delphi wrappers. }
  TTraceHooks = record
  public
    { The C API trace hooks }
    Hooks: _sg_trace_hooks;
  end;
  PTraceHooks = ^TTraceHooks;

type
  { An enum with a unique item for each log message, warning, error and
    validation layer message. Note that these messages are only visible when a
    logger function is installed in the TGfx.Setup call. }
  TGfxLogItem = (
    Ok,
    MallocFailed,
    GLTextureFormatNotSupported,
    GL3DTexturesNotSupported,
    GLArrayTexturesNotSupported,
    GLStoragebufferGlslBindingOutOfRange,
    GLStorageimageGlslBindingOutOfRange,
    GLShaderCompilationFailed,
    GLShaderLinkingFailed,
    GLVertexAttributeNotFoundInShader,
    GLUniformblockNameNotFoundInShader,
    GLImageSamplerNameNotFoundInShader,
    GLFramebufferStatusUndefined,
    GLFramebufferStatusIncompleteAttachment,
    GLFramebufferStatusIncompleteMissingAttachment,
    GLFramebufferStatusUnsupported,
    GLFramebufferStatusIncompleteMultisample,
    GLFramebufferStatusUnknown,
    D3D11FeatureLevel0Detected,
    D3D11CreateBufferFailed,
    D3D11CreateBufferSrvFailed,
    D3D11CreateBufferUavFailed,
    D3D11CreateDepthTextureUnsupportedPixelFormat,
    D3D11CreateDepthTextureFailed,
    D3D11Create2DTextureUnsupportedPixelFormat,
    D3D11Create2DTextureFailed,
    D3D11Create2DSrvFailed,
    D3D11Create3DTextureUnsupportedPixelFormat,
    D3D11Create3DTextureFailed,
    D3D11Create3DSrvFailed,
    D3D11CreateMsaaTextureFailed,
    D3D11CreateSamplerStateFailed,
    D3D11UniformblockHlslRegisterBOutOfRange,
    D3D11StoragebufferHlslRegisterTOutOfRange,
    D3D11StoragebufferHlslRegisterUOutOfRange,
    D3D11ImageHlslRegisterTOutOfRange,
    D3D11StorageimageHlslRegisterUOutOfRange,
    D3D11SamplerHlslRegisterSOutOfRange,
    D3D11LoadD3dcompiler47DllFailed,
    D3D11ShaderCompilationFailed,
    D3D11ShaderCompilationOutput,
    D3D11CreateConstantBufferFailed,
    D3D11CreateInputLayoutFailed,
    D3D11CreateRasterizerStateFailed,
    D3D11CreateDepthStencilStateFailed,
    D3D11CreateBlendStateFailed,
    D3D11CreateRtvFailed,
    D3D11CreateDsvFailed,
    D3D11CreateUavFailed,
    D3D11MapForUpdateBufferFailed,
    D3D11MapForAppendBufferFailed,
    D3D11MapForUpdateImageFailed,
    MetalCreateBufferFailed,
    MetalTextureFormatNotSupported,
    MetalCreateTextureFailed,
    MetalCreateSamplerFailed,
    MetalShaderCompilationFailed,
    MetalShaderCreationFailed,
    MetalShaderCompilationOutput,
    MetalShaderEntryNotFound,
    MetalUniformblockMslBufferSlotOutOfRange,
    MetalStoragebufferMslBufferSlotOutOfRange,
    MetalStorageimageMslTextureSlotOutOfRange,
    MetalImageMslTextureSlotOutOfRange,
    MetalSamplerMslSamplerSlotOutOfRange,
    MetalCreateCpsFailed,
    MetalCreateCpsOutput,
    MetalCreateRpsFailed,
    MetalCreateRpsOutput,
    MetalCreateDssFailed,
    WgpuBindgroupsPoolExhausted,
    WgpuBindgroupscacheSizeGreaterOne,
    WgpuBindgroupscacheSizePow2,
    WgpuCreatebindgroupFailed,
    WgpuCreateBufferFailed,
    WgpuCreateTextureFailed,
    WgpuCreateTextureViewFailed,
    WgpuCreateSamplerFailed,
    WgpuCreateShaderModuleFailed,
    WgpuShaderCreateBindgroupLayoutFailed,
    WgpuUniformblockWgslGroup0BindingOutOfRange,
    WgpuTextureWgslGroup1BindingOutOfRange,
    WgpuStoragebufferWgslGroup1BindingOutOfRange,
    WgpuStorageimageWgslGroup1BindingOutOfRange,
    WgpuSamplerWgslGroup1BindingOutOfRange,
    WgpuCreatePipelineLayoutFailed,
    WgpuCreateRenderPipelineFailed,
    WgpuCreateComputePipelineFailed,
    VulkanRequiredExtensionFunctionMissing,
    VulkanAllocDeviceMemoryNoSuitableMemoryType,
    VulkanAllocateMemoryFailed,
    VulkanAllocBufferDeviceMemoryFailed,
    VulkanAllocImageDeviceMemoryFailed,
    VulkanDeleteQueueExhausted,
    VulkanStagingCreateBufferFailed,
    VulkanStagingAllocateMemoryFailed,
    VulkanStagingBindBufferMemoryFailed,
    VulkanStagingStreamBufferOverflow,
    VulkanCreateSharedBufferFailed,
    VulkanAllocateSharedBufferMemoryFailed,
    VulkanBindSharedBufferMemoryFailed,
    VulkanMapSharedBufferMemoryFailed,
    VulkanCreateBufferFailed,
    VulkanBindBufferMemoryFailed,
    VulkanCreateImageFailed,
    VulkanBindImageMemoryFailed,
    VulkanCreateShaderModuleFailed,
    VulkanUniformblockSpirvSet0BindingOutOfRange,
    VulkanTextureSpirvSet1BindingOutOfRange,
    VulkanStoragebufferSpirvSet1BindingOutOfRange,
    VulkanStorageimageSpirvSet1BindingOutOfRange,
    VulkanSamplerSpirvSet1BindingOutOfRange,
    VulkanCreateDescriptorSetLayoutFailed,
    VulkanShaderUniformDescriptorSetSizeVsCacheSize,
    VulkanCreatePipelineLayoutFailed,
    VulkanCreateGraphicsPipelineFailed,
    VulkanCreateComputePipelineFailed,
    VulkanCreateImageViewFailed,
    VulkanViewMaxDescriptorSize,
    VulkanCreateSamplerFailed,
    VulkanSamplerMaxDescriptorSize,
    VulkanWaitForFenceFailed,
    VulkanUniformBufferOverflow,
    VulkanDescriptorBufferOverflow,
    IdenticalCommitListener,
    CommitListenerArrayFull,
    TraceHooksNotEnabled,
    DeallocBufferInvalidState,
    DeallocImageInvalidState,
    DeallocSamplerInvalidState,
    DeallocShaderInvalidState,
    DeallocPipelineInvalidState,
    DeallocViewInvalidState,
    InitBufferInvalidState,
    InitImageInvalidState,
    InitSamplerInvalidState,
    InitShaderInvalidState,
    InitPipelineInvalidState,
    InitViewInvalidState,
    UninitBufferInvalidState,
    UninitImageInvalidState,
    UninitSamplerInvalidState,
    UninitShaderInvalidState,
    UninitPipelineInvalidState,
    UninitViewInvalidState,
    FailBufferInvalidState,
    FailImageInvalidState,
    FailSamplerInvalidState,
    FailShaderInvalidState,
    FailPipelineInvalidState,
    FailViewInvalidState,
    BufferPoolExhausted,
    ImagePoolExhausted,
    SamplerPoolExhausted,
    ShaderPoolExhausted,
    PipelinePoolExhausted,
    ViewPoolExhausted,
    BeginpassTooManyColorAttachments,
    BeginpassTooManyResolveAttachments,
    BeginpassAttachmentsAlive,
    DrawWithoutBindings,
    ShaderdescTooManyVertexstageTextures,
    ShaderdescTooManyFragmentstageTextures,
    ShaderdescTooManyComputestageTextures,
    ShaderdescTooManyVertexstageStoragebuffers,
    ShaderdescTooManyFragmentstageStoragebuffers,
    ShaderdescTooManyComputestageStoragebuffers,
    ShaderdescTooManyVertexstageStorageimages,
    ShaderdescTooManyFragmentstageStorageimages,
    ShaderdescTooManyComputestageStorageimages,
    ShaderdescTooManyVertexstageTexturesamplerpairs,
    ShaderdescTooManyFragmentstageTexturesamplerpairs,
    ShaderdescTooManyComputestageTexturesamplerpairs,
    ValidateBufferdescCanary,
    ValidateBufferdescImmutableDynamicStream,
    ValidateBufferdescSeparateBufferTypes,
    ValidateBufferdescExpectNonzeroSize,
    ValidateBufferdescExpectMatchingDataSize,
    ValidateBufferdescExpectZeroDataSize,
    ValidateBufferdescExpectNoData,
    ValidateBufferdescExpectData,
    ValidateBufferdescStoragebufferSupported,
    ValidateBufferdescStoragebufferSizeMultiple4,
    ValidateImagedataNodata,
    ValidateImagedataDataSize,
    ValidateImagedescCanary,
    ValidateImagedescImmutableDynamicStream,
    ValidateImagedescAttachmentColorDepthStencil,
    ValidateImagedescImagetype2DNumslices,
    ValidateImagedescImagetypeCubeNumslices,
    ValidateImagedescImagetypeArrayNumslices,
    ValidateImagedescImagetype3DNumslices,
    ValidateImagedescNumslices,
    ValidateImagedescWidth,
    ValidateImagedescHeight,
    ValidateImagedescNonrtPixelformat,
    ValidateImagedescMsaaButNoAttachment,
    ValidateImagedescDepth3DImage,
    ValidateImagedescAttachmentExpectImmutable,
    ValidateImagedescAttachmentExpectNoData,
    ValidateImagedescAttachmentPixelformat,
    ValidateImagedescAttachmentResolveExpectNoMsaa,
    ValidateImagedescAttachmentNoMsaaSupport,
    ValidateImagedescAttachmentMsaaNumMipmaps,
    ValidateImagedescAttachmentMsaa3DImage,
    ValidateImagedescAttachmentMsaaCubeImage,
    ValidateImagedescAttachmentMsaaArrayImage,
    ValidateImagedescStorageimagePixelformat,
    ValidateImagedescStorageimageExpectNoMsaa,
    ValidateImagedescInjectedNoData,
    ValidateImagedescDynamicNoData,
    ValidateImagedescCompressedImmutable,
    ValidateSamplerdescCanary,
    ValidateSamplerdescAnistropicRequiresLinearFiltering,
    ValidateShaderdescCanary,
    ValidateShaderdescVertexSource,
    ValidateShaderdescFragmentSource,
    ValidateShaderdescComputeSource,
    ValidateShaderdescVertexSourceOrBytecode,
    ValidateShaderdescFragmentSourceOrBytecode,
    ValidateShaderdescComputeSourceOrBytecode,
    ValidateShaderdescInvalidShaderCombo,
    ValidateShaderdescNoBytecodeSize,
    ValidateShaderdescMetalThreadsPerThreadgroupInitialized,
    ValidateShaderdescMetalThreadsPerThreadgroupMultiple32,
    ValidateShaderdescUniformblockNoContMembers,
    ValidateShaderdescUniformblockSizeIsZero,
    ValidateShaderdescUniformblockMetalBufferSlotCollision,
    ValidateShaderdescUniformblockHlslRegisterBCollision,
    ValidateShaderdescUniformblockWgslGroup0BindingCollision,
    ValidateShaderdescUniformblockSpirvSet0BindingCollision,
    ValidateShaderdescUniformblockNoMembers,
    ValidateShaderdescUniformblockUniformGlslName,
    ValidateShaderdescUniformblockSizeMismatch,
    ValidateShaderdescUniformblockArrayCount,
    ValidateShaderdescUniformblockStd140ArrayType,
    ValidateShaderdescViewStoragebufferMetalBufferSlotCollision,
    ValidateShaderdescViewStoragebufferHlslRegisterTCollision,
    ValidateShaderdescViewStoragebufferHlslRegisterUCollision,
    ValidateShaderdescViewStoragebufferGlslBindingCollision,
    ValidateShaderdescViewStoragebufferWgslGroup1BindingCollision,
    ValidateShaderdescViewStoragebufferSpirvSet1BindingCollision,
    ValidateShaderdescViewStorageimageExpectComputeStage,
    ValidateShaderdescViewStorageimageMetalTextureSlotCollision,
    ValidateShaderdescViewStorageimageHlslRegisterUCollision,
    ValidateShaderdescViewStorageimageGlslBindingCollision,
    ValidateShaderdescViewStorageimageWgslGroup1BindingCollision,
    ValidateShaderdescViewStorageimageSpirvSet1BindingCollision,
    ValidateShaderdescViewTextureMetalTextureSlotCollision,
    ValidateShaderdescViewTextureHlslRegisterTCollision,
    ValidateShaderdescViewTextureWgslGroup1BindingCollision,
    ValidateShaderdescViewTextureSpirvSet1BindingCollision,
    ValidateShaderdescSamplerMetalSamplerSlotCollision,
    ValidateShaderdescSamplerHlslRegisterSCollision,
    ValidateShaderdescSamplerWgslGroup1BindingCollision,
    ValidateShaderdescSamplerSpirvSet1BindingCollision,
    ValidateShaderdescTextureSamplerPairViewSlotOutOfRange,
    ValidateShaderdescTextureSamplerPairSamplerSlotOutOfRange,
    ValidateShaderdescTextureSamplerPairTextureStageMismatch,
    ValidateShaderdescTextureSamplerPairExpectTextureView,
    ValidateShaderdescTextureSamplerPairSamplerStageMismatch,
    ValidateShaderdescTextureSamplerPairGlslName,
    ValidateShaderdescNonfilteringSamplerRequired,
    ValidateShaderdescComparisonSamplerRequired,
    ValidateShaderdescTexviewNotReferencedByTextureSamplerPairs,
    ValidateShaderdescSamplerNotReferencedByTextureSamplerPairs,
    ValidateShaderdescAttrStringTooLong,
    ValidatePipelinedescCanary,
    ValidatePipelinedescShader,
    ValidatePipelinedescComputeShaderExpected,
    ValidatePipelinedescNoComputeShaderExpected,
    ValidatePipelinedescNoContAttrs,
    ValidatePipelinedescAttrBasetypeMismatch,
    ValidatePipelinedescAttrVertexformatInt10N2NotSupported,
    ValidatePipelinedescLayoutStride4,
    ValidatePipelinedescAttrSemantics,
    ValidatePipelinedescShaderReadonlyStoragebuffers,
    ValidatePipelinedescBlendopMinmaxRequiresBlendfactorOne,
    ValidatePipelinedescDualSourceBlendingNotSupported,
    ValidatePipelinedescDepthFormatNoneButDepthWriteEnabled,
    ValidatePipelinedescDepthFormatNoneCompareFuncMismatch,
    ValidateViewdescCanary,
    ValidateViewdescUniqueViewtype,
    ValidateViewdescAnyViewtype,
    ValidateViewdescResourceAlive,
    ValidateViewdescResourceFailed,
    ValidateViewdescStoragebufferOffsetVSBufferSize,
    ValidateViewdescStoragebufferOffsetMultiple256,
    ValidateViewdescStoragebufferUsage,
    ValidateViewdescStorageimageUsage,
    ValidateViewdescColorattachmentUsage,
    ValidateViewdescResolveattachmentUsage,
    ValidateViewdescDepthstencilattachmentUsage,
    ValidateViewdescImageMiplevel,
    ValidateViewdescImage2DSlice,
    ValidateViewdescImageCubemapSlice,
    ValidateViewdescImageArraySlice,
    ValidateViewdescImage3DSlice,
    ValidateViewdescTextureExpectNoMsaa,
    ValidateViewdescTextureMiplevels,
    ValidateViewdescTexture2DSlices,
    ValidateViewdescTextureCubemapSlices,
    ValidateViewdescTextureArraySlices,
    ValidateViewdescTexture3DSlices,
    ValidateViewdescStorageimagePixelformat,
    ValidateViewdescColorattachmentPixelformat,
    ValidateViewdescDepthstencilattachmentPixelformat,
    ValidateViewdescResolveattachmentSamplecount,
    ValidateBeginpassCanary,
    ValidateBeginpassComputepassExpectNoAttachments,
    ValidateBeginpassSwapchainExpectWidth,
    ValidateBeginpassSwapchainExpectWidthNotset,
    ValidateBeginpassSwapchainExpectHeight,
    ValidateBeginpassSwapchainExpectHeightNotset,
    ValidateBeginpassSwapchainExpectSamplecount,
    ValidateBeginpassSwapchainExpectSamplecountNotset,
    ValidateBeginpassSwapchainExpectColorformat,
    ValidateBeginpassSwapchainExpectColorformatNotset,
    ValidateBeginpassSwapchainExpectDepthformatNotset,
    ValidateBeginpassSwapchainMetalExpectCurrentdrawable,
    ValidateBeginpassSwapchainMetalExpectCurrentdrawableNotset,
    ValidateBeginpassSwapchainMetalExpectDepthstenciltexture,
    ValidateBeginpassSwapchainMetalExpectDepthstenciltextureNotset,
    ValidateBeginpassSwapchainMetalExpectMsaacolortexture,
    ValidateBeginpassSwapchainMetalExpectMsaacolortextureNotset,
    ValidateBeginpassSwapchainD3d11ExpectRenderview,
    ValidateBeginpassSwapchainD3d11ExpectRenderviewNotset,
    ValidateBeginpassSwapchainD3d11ExpectResolveview,
    ValidateBeginpassSwapchainD3d11ExpectResolveviewNotset,
    ValidateBeginpassSwapchainD3d11ExpectDepthstencilview,
    ValidateBeginpassSwapchainD3d11ExpectDepthstencilviewNotset,
    ValidateBeginpassSwapchainWgpuExpectRenderview,
    ValidateBeginpassSwapchainWgpuExpectRenderviewNotset,
    ValidateBeginpassSwapchainWgpuExpectResolveview,
    ValidateBeginpassSwapchainWgpuExpectResolveviewNotset,
    ValidateBeginpassSwapchainWgpuExpectDepthstencilview,
    ValidateBeginpassSwapchainWgpuExpectDepthstencilviewNotset,
    ValidateBeginpassSwapchainGLExpectFramebufferNotset,
    ValidateBeginpassSwapchainVulkanExpectRenderimage,
    ValidateBeginpassSwapchainVulkanExpectRenderimageNotset,
    ValidateBeginpassSwapchainVulkanExpectRenderview,
    ValidateBeginpassSwapchainVulkanExpectRenderviewNotset,
    ValidateBeginpassSwapchainVulkanExpectDepthstencilimage,
    ValidateBeginpassSwapchainVulkanExpectDepthstencilimageNotset,
    ValidateBeginpassSwapchainVulkanExpectDepthstencilview,
    ValidateBeginpassSwapchainVulkanExpectDepthstencilviewNotset,
    ValidateBeginpassSwapchainVulkanExpectResolveimage,
    ValidateBeginpassSwapchainVulkanExpectResolveimageNotset,
    ValidateBeginpassSwapchainVulkanExpectResolveview,
    ValidateBeginpassSwapchainVulkanExpectResolveviewNotset,
    ValidateBeginpassSwapchainVulkanExpectRenderfinishedsemaphore,
    ValidateBeginpassSwapchainVulkanExpectRenderfinishedsemaphoreNotset,
    ValidateBeginpassSwapchainVulkanExpectPresentcompletesemaphore,
    ValidateBeginpassSwapchainVulkanExpectPresentcompletesemaphoreNotset,
    ValidateBeginpassColorattachmentviewsContinuous,
    ValidateBeginpassColorattachmentviewAlive,
    ValidateBeginpassColorattachmentviewValid,
    ValidateBeginpassColorattachmentviewType,
    ValidateBeginpassColorattachmentviewImageAlive,
    ValidateBeginpassColorattachmentviewImageValid,
    ValidateBeginpassColorattachmentviewSizes,
    ValidateBeginpassColorattachmentviewSamplecount,
    ValidateBeginpassColorattachmentviewSamplecountsEqual,
    ValidateBeginpassResolveattachmentviewNoColorattachmentview,
    ValidateBeginpassResolveattachmentviewAlive,
    ValidateBeginpassResolveattachmentviewValid,
    ValidateBeginpassResolveattachmentviewType,
    ValidateBeginpassResolveattachmentviewImageAlive,
    ValidateBeginpassResolveattachmentviewImageValid,
    ValidateBeginpassResolveattachmentviewSizes,
    ValidateBeginpassDepthstencilattachmentviewsContinuous,
    ValidateBeginpassDepthstencilattachmentviewAlive,
    ValidateBeginpassDepthstencilattachmentviewValid,
    ValidateBeginpassDepthstencilattachmentviewType,
    ValidateBeginpassDepthstencilattachmentviewImageAlive,
    ValidateBeginpassDepthstencilattachmentviewImageValid,
    ValidateBeginpassDepthstencilattachmentviewSizes,
    ValidateBeginpassDepthstencilattachmentviewSamplecount,
    ValidateBeginpassAttachmentsExpected,
    ValidateAvpRenderpassExpected,
    ValidateAsrRenderpassExpected,
    ValidateApipPipelineValidId,
    ValidateApipPipelineExists,
    ValidateApipPipelineValid,
    ValidateApipPassExpected,
    ValidateApipPipelineShaderAlive,
    ValidateApipPipelineShaderValid,
    ValidateApipComputepassExpected,
    ValidateApipRenderpassExpected,
    ValidateApipSwapchainColorCount,
    ValidateApipSwapchainColorFormat,
    ValidateApipSwapchainDepthFormat,
    ValidateApipSwapchainSampleCount,
    ValidateApipAttachmentsAlive,
    ValidateApipColorattachmentsCount,
    ValidateApipColorattachmentsViewValid,
    ValidateApipColorattachmentsImageValid,
    ValidateApipColorattachmentsFormat,
    ValidateApipDepthstencilattachmentViewValid,
    ValidateApipDepthstencilattachmentImageValid,
    ValidateApipDepthstencilattachmentFormat,
    ValidateApipAttachmentSampleCount,
    ValidateAbndPassExpected,
    ValidateAbndEmptyBindings,
    ValidateAbndNoPipeline,
    ValidateAbndPipelineAlive,
    ValidateAbndPipelineValid,
    ValidateAbndPipelineShaderAlive,
    ValidateAbndPipelineShaderValid,
    ValidateAbndComputeExpectedNoVbufs,
    ValidateAbndComputeExpectedNoIbuf,
    ValidateAbndExpectedVbuf,
    ValidateAbndVBufAlive,
    ValidateAbndVBufUsage,
    ValidateAbndVBufOverflow,
    ValidateAbndExpectedNoIbuf,
    ValidateAbndExpectedIbuf,
    ValidateAbndIBufAlive,
    ValidateAbndIBufUsage,
    ValidateAbndIBufOverflow,
    ValidateAbndExpectedViewBinding,
    ValidateAbndViewAlive,
    ValidateAbndExpectTexview,
    ValidateAbndExpectSbview,
    ValidateAbndExpectSimgview,
    ValidateAbndTexviewImagetypeMismatch,
    ValidateAbndTexviewExpectedMultisampledImage,
    ValidateAbndTexviewExpectedNonMultisampledImage,
    ValidateAbndTexviewExpectedFilterableImage,
    ValidateAbndTexviewExpectedDepthImage,
    ValidateAbndSbviewReadwriteImmutable,
    ValidateAbndSimgviewComputePassExpected,
    ValidateAbndSimgviewImagetypeMismatch,
    ValidateAbndSimgviewAccessformat,
    ValidateAbndExpectedSamplerBinding,
    ValidateAbndUnexpectedSamplerCompareNever,
    ValidateAbndExpectedSamplerCompareNever,
    ValidateAbndExpectedNonfilteringSampler,
    ValidateAbndSamplerAlive,
    ValidateAbndSamplerValid,
    ValidateAbndTextureBindingVsDepthstencilAttachment,
    ValidateAbndTextureBindingVsColorAttachment,
    ValidateAbndTextureBindingVsResolveAttachment,
    ValidateAbndTextureVsStorageimageBinding,
    ValidateAuPassExpected,
    ValidateAuNoPipeline,
    ValidateAuPipelineAlive,
    ValidateAuPipelineValid,
    ValidateAuPipelineShaderAlive,
    ValidateAuPipelineShaderValid,
    ValidateAuNoUniformblockAtSlot,
    ValidateAuSize,
    ValidateDrawRenderpassExpected,
    ValidateDrawBaseelementGEZero,
    ValidateDrawNumelementsGEZero,
    ValidateDrawNuminstancesGEZero,
    ValidateDrawExRenderpassExpected,
    ValidateDrawExBaseelementGEZero,
    ValidateDrawExNumelementsGEZero,
    ValidateDrawExNuminstancesGEZero,
    ValidateDrawExBaseinstanceGEZero,
    ValidateDrawExBasevertexVSIndexed,
    ValidateDrawExBaseinstanceVSInstanced,
    ValidateDrawExBasevertexNotSupported,
    ValidateDrawExBaseinstanceNotSupported,
    ValidateDrawRequiredBindingsOrUniformsMissing,
    ValidateDispatchComputepassExpected,
    ValidateDispatchNumgroupsX,
    ValidateDispatchNumgroupsY,
    ValidateDispatchNumgroupsZ,
    ValidateDispatchRequiredBindingsOrUniformsMissing,
    ValidateUpdatebufUsage,
    ValidateUpdatebufSize,
    ValidateUpdatebufOnce,
    ValidateUpdatebufAppend,
    ValidateAppendbufUsage,
    ValidateAppendbufSize,
    ValidateAppendbufUpdate,
    ValidateUpdimgUsage,
    ValidateUpdimgOnce,
    ValidationFailed);

type
  _TGfxLogItemHelper = record helper for TGfxLogItem
  public
    function ToString: String;
  end;

type
  TEnvironmentDefaults = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_environment_defaults;
    function GetColorFormat: TPixelFormat; inline;
    procedure SetColorFormat(const AValue: TPixelFormat); inline;
    function GetDepthFormat: TPixelFormat; inline;
    procedure SetDepthFormat(const AValue: TPixelFormat); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property ColorFormat: TPixelFormat read GetColorFormat write SetColorFormat;
    property DepthFormat: TPixelFormat read GetDepthFormat write SetDepthFormat;
    property SampleCount: Integer read FHandle.sample_count write FHandle.sample_count;
  end;
  PEnvironmentDefaults = ^TEnvironmentDefaults;

type
  TMetalEnvironment = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_metal_environment;
  {$ENDREGION 'Internal Declarations'}
  public
    property Device: Pointer read FHandle.device write FHandle.device;
  end;
  PMetalEnvironment = ^TMetalEnvironment;

type
  TD3D11Environment = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_d3d11_environment;
    function GetDevice: IInterface; inline;
    procedure SetDevice(const AValue: IInterface); inline;
    function GetDeviceContext: IInterface; inline;
    procedure SetDeviceContext(const AValue: IInterface); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Device: IInterface read GetDevice write SetDevice;
    property DeviceContext: IInterface read GetDeviceContext write SetDeviceContext;
  end;
  PD3D11Environment = ^TD3D11Environment;

type
  TVulkanEnvironment = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_vulkan_environment;
  {$ENDREGION 'Internal Declarations'}
  public
    property Instance: Pointer read FHandle.instance write FHandle.instance;
    property PhysicalDevice: Pointer read FHandle.physical_device write FHandle.physical_device;
    property Device: Pointer read FHandle.device write FHandle.device;
    property Queue: Pointer read FHandle.queue write FHandle.queue;
    property QueueFamilyIndex: Cardinal read FHandle.queue_family_index write FHandle.queue_family_index;
  end;
  PVulkanEnvironment = ^TVulkanEnvironment;

type
  TEnvironment = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_environment;
    function GetDefaults: PEnvironmentDefaults; inline;
    function GetMetal: PMetalEnvironment; inline;
    function GetD3D11: PD3D11Environment; inline;
    function GetVulkan: PVulkanEnvironment; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Defaults: PEnvironmentDefaults read GetDefaults;
    property Metal: PMetalEnvironment read GetMetal;
    property D3D11: PD3D11Environment read GetD3D11;
    property Vulkan: PVulkanEnvironment read GetVulkan;
  end;
  PEnvironment = ^TEnvironment;

type
  { Used with property TGfx.CommitListener to set a callback which will be
    called in TGfx.Commit. This is useful for libraries building on top of
    Neslib.Sokol.Gfx to be notified about when a frame ends (instead of having
    to guess, or add a manual 'new-frame' function. }
  TCommitListener = procedure of object;

type
  { Used in TGfxDesc to provide a logging function. Please be aware that without
    logging function, Neslib.Sokol.Gfx will be completely silent, e.g. it will
    not report errors, warnings and validation layer messages. For maximum error
    verbosity, compile in debug mode and provide a compatible logger function in
    the TGfx.Setup call (for instance the standard logging function
    TGfxDesc.DefaultLogger).

    Parameters:
    * ALevel: log level
    * AItem: log item
    * AMessage: the log message corresponding to AItem.
    * ALineNr: line number in original sokol_gfx.h file. }
  TGfxLogger = procedure(const ALevel: TLogLevel; const AItem: TGfxLogItem;
    const AMessage: String; const ALineNr: Integer) of object;

type
  TD3D11Desc = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_d3d11_desc;
  {$ENDREGION 'Internal Declarations'}
  public
    { If True, HLSL shaders are compiled with D3DCOMPILE_DEBUG or
      D3DCOMPILE_SKIP_OPTIMIZATION }
    property ShaderDebugging: Boolean read FHandle.shader_debugging write FHandle.shader_debugging;
  end;
  PD3D11Desc = ^TD3D11Desc;

type
  TMetalDesc = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_metal_desc;
  {$ENDREGION 'Internal Declarations'}
  public
    { For debugging: use Metal managed storage mode for resources even with UMA }
    property ForceManagedStorageMode: Boolean read FHandle.force_managed_storage_mode write FHandle.force_managed_storage_mode;

    { Metal: use a managed MTLCommandBuffer which ref-counts used resources }
    property UseCommandBufferWithRetainedReferences: Boolean read FHandle.use_command_buffer_with_retained_references write FHandle.use_command_buffer_with_retained_references;
  end;
  PMetalDesc = ^TMetalDesc;

type
  TVulkanDesc = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_vulkan_desc;
  {$ENDREGION 'Internal Declarations'}
  public
    { Size of staging buffer for immutable and dynamic resources (default: 4 MB) }
    property CopyStagingBufferSize: Integer read FHandle.copy_staging_buffer_size write FHandle.copy_staging_buffer_size;

    { Size of per-frame staging buffer for updating streaming resources (default: 16 MB) }
    property StreamStagingBufferSize: Integer read FHandle.stream_staging_buffer_size write FHandle.stream_staging_buffer_size;

    { Size of per-frame descriptor buffer for updating resource bindings (default: 16 MB) }
    property DescriptorBufferSize: Integer read FHandle.descriptor_buffer_size write FHandle.descriptor_buffer_size;
  end;
  PVulkanDesc = ^TVulkanDesc;

type
  { The TGfxDesc record contains configuration values.
    It is used as parameter to the TGfx.Create call.

    The default configuration is:

    .BufferPoolSize                                128
    .ImagePoolSize                                 128
    .SamplerPoolSize                               64
    .ShaderPoolSize                                32
    .PipelinePoolSize                              64
    .ViewPoolSize                                  256
    .UniformBufferSsize                            4 MB (4*1024*1024)
    .MaxCommitListeners                            1024
    .DisableValidation                             False
    .Metal.ForceManagedStorageMode                 False
    .Metal.UseCommandBufferWithRetainedReferences  False
    .Vulkan.CopyStagingBufferSize                  4 MB
    .Vulkan.StreamStagingBufferSize                16 MB
    .Vulkan.DescriptorBufferSize                   16 MB

    .UseDelphiMemoryManager False (instead of using Sokol's internal memory manager)
                            When SOKOL_MEM_TRACK is defined, it always uses
                            Delphi's memory manager.

    .Environment.Defaults.ColorFormat: default value depends on selected backend:
        all GL backends:                 TPixelFormat.Rgba8
        Metal and D3D11:                 TPixelFormat.Bgra8
    .Environment.Defaults.DepthFormat    TPixelFormat.DepthStencil
    .Environment.Defaults.SampleCount    1

    Metal specific:
        (NOTE: All Objective-C object references are transferred through a
        bridged (const Pointer) to Sokol, which will use a unretained bridged
        cast to retrieve the Objective-C references back. Since the bridge cast
        is unretained, the caller must hold a strong reference to the
        Objective-C object until TGfx.Setup returns.

        .Metal.ForceManagedStorageMode
            when enabled, Metal buffers and texture resources are created in
            managed storage mode, otherwise Sokol will decide whether to create
            buffers and textures in managed or shared storage mode (this is
            mainly a debugging option)
        .Metal.UseCommandBufferWithRetainedReferences
            when true, the Sokol Metal backend will use Metal command buffers
            which bump the reference count of resource objects as long as they
            are inflight, this is slower than the default
            command-buffer-with-unretained-references method, this may be a
            workaround when confronted with lifetime validation errors from the
            Metal validation layer until a proper fix has been implemented.
        .Environment.Metal.Device
            a pointer to the MTLDevice object

    D3D11 specific:
        .Environment.D3D11.Device
            a ID3D11Device object. This must have been created before
            TGfx.Create is called
        .Environment.D3D11.DeviceContext
            a ID3D11DeviceContext object
        .D3D11.ShaderDebugging
            set this to true to compile shaders which are provided as HLSL source
            code with debug information and without optimization, this allows
            shader debugging in tools like RenderDoc, to output source code
            instead of byte code from sokol-shdc, omit the `--binary` cmdline
            option

    Vulkan specific:
        .Vulkan.CopyStagingBufferSize
            Size of the staging buffer in bytes for uploading the initial
            content of buffers and images, and for updating
            .Usage.DynamicUpdate resources. The default is 4 MB, bigger resource
            updates are split into multiple chunks of the staging buffer size
        .Vulkan.StreamStagingBufferSize
            Size of the staging buffer in bytes for updating .Usage.StreamUpdate
            resources. The default is 16 MB. The size must be big enough
            to accomodate all update into .Usage.StreamUpdate resources.
            Any additional data will cause an error log message and
            incomplete rendering. Note that the actually allocated size
            will be twice as much because the stream-staging-buffer is
            double-buffered.
        .Vulkan.DescriptorBufferSize
            Size of the descriptor-upload buffer in bytes. The default
            size is 16 bytes. The size must be big enough to accomodate
            all unifrom-block, view- and sampler-bindings in a single
            frame (assume a worst-case of 256 bytes per binding). Note
            that the actually allocated size will be twice as much
            because the descriptor-buffer is double-buffered.

    When using Neslib.Sokol.Gfx and Neslib.Sokol.App together, consider using
    the Neslib.Sokol.Glue unit which adds a FromAppEnvironment method to the
    TEnvironment record. }
  TGfxDesc = record
  {$REGION 'Internal Declarations'}
  private class var
    GLogger: TGfxLogger;
  private
    procedure Convert(out ADst: _sg_desc);
  private
    class procedure LogCallback(const ATag: PUTF8Char; ALogLevel,
      ALogItemId: UInt32; const AMessageOrNull: PUTF8Char; ALineNr: UInt32;
      const AFilenameOrNull: PUTF8Char; AUserData: Pointer); cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    BufferPoolSize: Integer;
    ImagePoolSize: Integer;
    SamplerPoolSize: Integer;
    ShaderPoolSize: Integer;
    PipelinePoolSize: Integer;
    ViewPoolSize: Integer;

    { Max size of all TGfx.ApplyUniform calls per frame, with worst-case 256
      byte alignment }
    UniformBufferSize: Integer;

    { Max number of commit listener hook functions }
    MaxCommitListeners: Integer;

    { Disable validation layer even in debug mode, useful for tests }
    DisableValidation: Boolean;

    { If true, enforce portable resource binding limits (MAX_PORTABLE_*) }
    EnforcePortableLimits: Boolean;

    { Whether to use Delphi's memory manager instead of Sokol's internal one.
      When SOKOL_MEM_TRACK is defined, it always uses Delphi's memory manager.
      Default: False }
    UseDelphiMemoryManager: Boolean;

    { D3D11-specific setup parameters }
    D3D11: TD3D11Desc;

    { Metal-specific setup parameters }
    Metal: TMetalDesc;

    { Vulkan-specific setup parameters }
    Vulkan: TVulkanDesc;

    { Optional log function override }
    Logger: TGfxLogger;

    { Required externally provided runtime objects and defaults }
    Environment: TEnvironment;
  public
    class function Create: TGfxDesc; inline; static;
    procedure Init;

    { A default log function you can assign to the Logger field. }
    procedure DefaultLogger(const ALevel: TLogLevel; const AItem: TGfxLogItem;
      const AMessage: String; const ALineNr: Integer);
  end;
  PGfxDesc = ^TGfxDesc;

type
  { Main entry point to the Sokol graphics library.
    This is a (static) singleton. }
  TGfx = record // static
  {$REGION 'Internal Declarations'}
  private class var
    FCommitListener: TCommitListener;
    FDesc: TGfxDesc;
    FFeatures: TFeatures;
    FFeaturesValid: Boolean;
  private
    class function GetIsValid: Boolean; inline; static;
    class function GetBackend: TBackend; inline; static;
    class function GetFeatures: TFeatures; inline; static;
    class procedure DoGetFeatures; static;
    class function GetLimits: TLimits; inline; static;
    class function GetD3D11Device: IInterface; inline; static;
    class function GetD3D11DeviceContext: IInterface; inline; static;
    class function GetMetalDevice: Pointer; inline; static;
    class function GetMetalRenderCommandEncoder: Pointer; inline; static;
    class function GetMetalComputeCommandEncoder: Pointer; inline; static;
    class function GetMetalCommandQueue: Pointer; inline; static;
    class procedure SetCommitListener(const AValue: TCommitListener); static;
    class function GetStatsEnabled: Boolean; inline; static;
    class procedure SetStatsEnabled(const AValue: Boolean); inline; static;
  private
    class procedure CommitListenerCallback(AUserData: Pointer); cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    { Setup and misc functions }
    class procedure Setup(const ADesc: TGfxDesc); static;
    class procedure Shutdown; static;
    class procedure ResetCache; inline; static;
    class procedure InstallTraceHooks(const ATraceHooks: TTraceHooks); static;
    class procedure PushDebugGroup(const AName: String); inline; static;
    class procedure PopDebugGroup; inline; static;

    class property IsValid: Boolean read GetIsValid;
    class property CommitListener: TCommitListener read FCommitListener write SetCommitListener;
  public
    { Rendering and compute methods }
    class procedure BeginPass(const APass: TPass); inline; static;

    class procedure ApplyViewport(const AX, AY, AWidth, AHeight: Integer;
      const AOriginTopLeft: Boolean); overload; inline; static;
    class procedure ApplyViewport(const AViewport: TRect;
      const AOriginTopLeft: Boolean); overload; inline; static;
    class procedure ApplyViewport(const AX, AY, AWidth, AHeight: Single;
      const AOriginTopLeft: Boolean); overload; inline; static;
    class procedure ApplyViewport(const AViewport: TRectF;
      const AOriginTopLeft: Boolean); overload; inline; static;

    class procedure ApplyScissorRect(const AX, AY, AWidth, AHeight: Integer;
      const AOriginTopLeft: Boolean); overload; inline; static;
    class procedure ApplyScissorRect(const ARect: TRect;
      const AOriginTopLeft: Boolean); overload; inline; static;
    class procedure ApplyScissorRect(const AX, AY, AWidth, AHeight: Single;
      const AOriginTopLeft: Boolean); overload; inline; static;
    class procedure ApplyScissorRect(const ARect: TRectF;
      const AOriginTopLeft: Boolean); overload; inline; static;

    class procedure ApplyPipeline(const APipeline: TPipeline); inline; static;
    class procedure ApplyBindings(const ABindings: TBindings); inline; static;
    class procedure ApplyUniforms(const AUBSlot: Integer;
      const AData: TBytes); overload; inline; static;
    class procedure ApplyUniforms(const AUBSlot: Integer;
      const AData: TRange); overload; inline; static;

    class procedure Draw(const ABaseElement, ANumElements: Integer;
      const ANumInstances: Integer = 1); overload; inline; static;
    class procedure Draw(const ABaseElement, ANumElements, ANumInstances,
      ABaseVertex, ABaseInstance: Integer); overload; inline; static;
    class procedure Dispatch(const ANumGroupsX, ANumGroupsY,
      ANumGroupsZ: Integer); inline; static;
    class procedure EndPass; inline; static;
    class procedure Commit; inline; static;
  public
    { Getting information }
    class property Desc: TGfxDesc read FDesc;
    class property Backend: TBackend read GetBackend;
    class property Features: TFeatures read GetFeatures;
    class property Limits: TLimits read GetLimits;
  public
    { Frame and total stats }
    class procedure EnableStats; inline; static;
    class procedure DisableStats; inline; static;
    class function QueryStats: TStats; inline; static;

    class property StatsEnabled: Boolean read GetStatsEnabled write SetStatsEnabled;
  public
    { Backend-specific helpers. These may come in handy for mixing Sokol
      rendering with 'native backend' rendering functions.

      This group will be expanded as needed. }

    { D3D11: return ID3D11Device }
    class property D3D11Device: IInterface read GetD3D11Device;

    { D3D11: return ID3D11DeviceContext }
    class property D3D11DeviceContext: IInterface read GetD3D11DeviceContext;

    { Metal: return ObjectID of MTLDevice}
    class property MetalDevice: Pointer read GetMetalDevice;

    { Metal: return ObjectID of MTLRenderCommandEncoder when inside render pass
      (or nil otherwise) }
    class property MetalRenderCommandEncoder: Pointer read GetMetalRenderCommandEncoder;

    { Metal: return ObjectID of MTLComputeCommandEncoder when insidde compute
      pass (or nil otherwise) }
    class property MetalComputeCommandEncoder: Pointer read GetMetalComputeCommandEncoder;

    { Metal: return ObjectID of MTLCommandQueue }
    class property MetalCommandQueue: Pointer read GetMetalCommandQueue;
  end;

implementation

uses
  {$IFDEF SOKOL_MEM_TRACK}
  Neslib.Sokol.MemTrack,
  {$ENDIF}
  {$IFDEF MACOS_ONLY}
  Macapi.CoreGraphics,
  {$ENDIF}
  Neslib.Sokol.Utils;

{ TRange }

constructor TRange.Create(const ABytes: TBytes);
begin
  FBytes := ABytes;
  FHandle.ptr := Pointer(ABytes);
  FHandle.size := Length(ABytes);
end;

constructor TRange.Create(const APointer: Pointer; const ASize: NativeInt);
begin
  FHandle.ptr := APointer;
  FHandle.size := ASize;
end;

class function TRange.Create<T>(const [ref] AData: T): TRange;
begin
  Result.FHandle.ptr := @AData;
  Result.FHandle.size := SizeOf(AData);
end;

{ _TBackendHelper }

function _TBackendHelper.GetIsGL: Boolean;
begin
  Result := (Self in [TBackend.GLCore, TBackend.Gles3]);
end;

{ _TPixelFormatHelper }

function _TPixelFormatHelper.GetBlend: Boolean;
begin
  if (not FHasInfo) then
    InitInfo;

  Result := FInfo[Self].blend;
end;

function _TPixelFormatHelper.GetBytesPerPixel: Integer;
begin
  if (not FHasInfo) then
    InitInfo;

  Result := FInfo[Self].bytes_per_pixel;
end;

function _TPixelFormatHelper.GetCanRead: Boolean;
begin
  if (not FHasInfo) then
    InitInfo;

  Result := FInfo[Self].read;
end;

function _TPixelFormatHelper.GetCanWrite: Boolean;
begin
  if (not FHasInfo) then
    InitInfo;

  Result := FInfo[Self].write;
end;

function _TPixelFormatHelper.GetDepth: Boolean;
begin
  if (not FHasInfo) then
    InitInfo;

  Result := FInfo[Self].depth;
end;

function _TPixelFormatHelper.GetFilter: Boolean;
begin
  if (not FHasInfo) then
    InitInfo;

  Result := FInfo[Self].filter;
end;

function _TPixelFormatHelper.GetIsCompressed: Boolean;
begin
  if (not FHasInfo) then
    InitInfo;

  Result := FInfo[Self].compressed;
end;

function _TPixelFormatHelper.GetMsaa: Boolean;
begin
  if (not FHasInfo) then
    InitInfo;

  Result := FInfo[Self].msaa;
end;

function _TPixelFormatHelper.GetRender: Boolean;
begin
  if (not FHasInfo) then
    InitInfo;

  Result := FInfo[Self].render;
end;

function _TPixelFormatHelper.GetSample: Boolean;
begin
  if (not FHasInfo) then
    InitInfo;

  Result := FInfo[Self].sample;
end;

class procedure _TPixelFormatHelper.InitInfo;
begin
  FHasInfo := True;
  for var Fmt := Succ(Succ(Low(TPixelFormat))) to High(TPixelFormat) do
    FInfo[Fmt] := _sg_query_pixelformat(Ord(Fmt));
end;

function _TPixelFormatHelper.RowPitch(const AWidth,
  ARowAlignBytes: Integer): Integer;
begin
  Result := _sg_query_row_pitch(Ord(Self), AWidth, ARowAlignBytes);
end;

function _TPixelFormatHelper.SurfacePitch(const AWidth, AHeight,
  ARowAlignBytes: Integer): Integer;
begin
  Result := _sg_query_surface_pitch(Ord(Self), AWidth, AHeight, ARowAlignBytes);
end;

{ TColorAttachmentAction }

constructor TColorAttachmentAction.Create(const ALoadAction: TLoadAction;
  const AStoreAction: TStoreAction; const AClearValue: TColor);
begin
  LoadAction := ALoadAction;
  StoreAction := AStoreAction;
  ClearValue := AClearValue;
end;

constructor TColorAttachmentAction.Create(const ALoadAction: TLoadAction;
  const AStoreAction: TStoreAction; const AR, AG, AB, AA: Single);
begin
  LoadAction := ALoadAction;
  StoreAction := AStoreAction;
  ClearValue.R := AR;
  ClearValue.G := AG;
  ClearValue.B := AB;
  ClearValue.A := AA;
end;

constructor TColorAttachmentAction.Create(const ALoadAction: TLoadAction;
  const AClearValue: TColor);
begin
  LoadAction := ALoadAction;
  StoreAction := TStoreAction.Default;
  ClearValue := AClearValue;
end;

constructor TColorAttachmentAction.Create(const ALoadAction: TLoadAction;
  const AR, AG, AB, AA: Single);
begin
  LoadAction := ALoadAction;
  StoreAction := TStoreAction.Default;
  ClearValue.R := AR;
  ClearValue.G := AG;
  ClearValue.B := AB;
  ClearValue.A := AA;
end;

constructor TColorAttachmentAction.Create(const AStoreAction: TStoreAction;
  const AR, AG, AB, AA: Single);
begin
  LoadAction := TLoadAction.Default;
  StoreAction := AStoreAction;
  ClearValue.R := AR;
  ClearValue.G := AG;
  ClearValue.B := AB;
  ClearValue.A := AA;
end;

constructor TColorAttachmentAction.Create(const AStoreAction: TStoreAction;
  const AClearValue: TColor);
begin
  LoadAction := TLoadAction.Default;
  StoreAction := AStoreAction;
  ClearValue := AClearValue;
end;

procedure TColorAttachmentAction.Init(const ALoadAction: TLoadAction; const AR,
  AG, AB, AA: Single);
begin
  LoadAction := ALoadAction;
  StoreAction := TStoreAction.Default;
  ClearValue.R := AR;
  ClearValue.G := AG;
  ClearValue.B := AB;
  ClearValue.A := AA;
end;

procedure TColorAttachmentAction.Init(const ALoadAction: TLoadAction;
  const AClearValue: TColor);
begin
  LoadAction := ALoadAction;
  StoreAction := TStoreAction.Default;
  ClearValue := AClearValue;
end;

procedure TColorAttachmentAction.Init(const AStoreAction: TStoreAction;
  const AClearValue: TColor);
begin
  LoadAction := TLoadAction.Default;
  StoreAction := AStoreAction;
  ClearValue := AClearValue;
end;

procedure TColorAttachmentAction.Init(const AStoreAction: TStoreAction;
  const AR, AG, AB, AA: Single);
begin
  LoadAction := TLoadAction.Default;
  StoreAction := AStoreAction;
  ClearValue.R := AR;
  ClearValue.G := AG;
  ClearValue.B := AB;
  ClearValue.A := AA;
end;

procedure TColorAttachmentAction.Init(const ALoadAction: TLoadAction;
  const AStoreAction: TStoreAction; const AClearValue: TColor);
begin
  LoadAction := ALoadAction;
  StoreAction := AStoreAction;
  ClearValue := AClearValue;
end;

procedure TColorAttachmentAction.Init(const ALoadAction: TLoadAction;
  const AStoreAction: TStoreAction; const AR, AG, AB, AA: Single);
begin
  LoadAction := ALoadAction;
  StoreAction := AStoreAction;
  ClearValue.R := AR;
  ClearValue.G := AG;
  ClearValue.B := AB;
  ClearValue.A := AA;
end;

{ TDepthAttachmentAction }

constructor TDepthAttachmentAction.Create(const ALoadAction: TLoadAction;
  const AStoreAction: TStoreAction; const AClearValue: Single);
begin
  LoadAction := ALoadAction;
  StoreAction := AStoreAction;
  ClearValue := AClearValue;
end;

constructor TDepthAttachmentAction.Create(const ALoadAction: TLoadAction;
  const AClearValue: Single);
begin
  LoadAction := ALoadAction;
  StoreAction := TStoreAction.Default;
  ClearValue := AClearValue;
end;

constructor TDepthAttachmentAction.Create(const AStoreAction: TStoreAction;
  const AClearValue: Single);
begin
  LoadAction := TLoadAction.Default;
  StoreAction := AStoreAction;
  ClearValue := AClearValue;
end;

procedure TDepthAttachmentAction.Init(const ALoadAction: TLoadAction;
  const AStoreAction: TStoreAction; const AClearValue: Single);
begin
  LoadAction := ALoadAction;
  StoreAction := AStoreAction;
  ClearValue := AClearValue;
end;

procedure TDepthAttachmentAction.Init(const ALoadAction: TLoadAction;
  AClearValue: Single);
begin
  LoadAction := ALoadAction;
  StoreAction := TStoreAction.Default;
  ClearValue := AClearValue;
end;

procedure TDepthAttachmentAction.Init(const AStoreAction: TStoreAction;
  const AClearValue: Single);
begin
  LoadAction := TLoadAction.Default;
  StoreAction := AStoreAction;
  ClearValue := AClearValue;
end;

{ TStencilAttachmentAction }

constructor TStencilAttachmentAction.Create(const ALoadAction: TLoadAction;
  const AStoreAction: TStoreAction; const AClearValue: Byte);
begin
  LoadAction := ALoadAction;
  StoreAction := AStoreAction;
  ClearValue := AClearValue;
end;

constructor TStencilAttachmentAction.Create(const ALoadAction: TLoadAction;
  const AClearValue: Byte);
begin
  LoadAction := ALoadAction;
  StoreAction := TStoreAction.Default;
  ClearValue := AClearValue;
end;

constructor TStencilAttachmentAction.Create(const AStoreAction: TStoreAction;
  const AClearValue: Byte);
begin
  LoadAction := TLoadAction.Default;
  StoreAction := AStoreAction;
  ClearValue := AClearValue;
end;

procedure TStencilAttachmentAction.Init(const ALoadAction: TLoadAction;
  const AStoreAction: TStoreAction; const AClearValue: Byte);
begin
  LoadAction := ALoadAction;
  StoreAction := AStoreAction;
  ClearValue := AClearValue;
end;

procedure TStencilAttachmentAction.Init(const ALoadAction: TLoadAction;
  const AClearValue: Byte);
begin
  LoadAction := ALoadAction;
  StoreAction := TStoreAction.Default;
  ClearValue := AClearValue;
end;

procedure TStencilAttachmentAction.Init(const AStoreAction: TStoreAction;
  const AClearValue: Byte);
begin
  LoadAction := TLoadAction.Default;
  StoreAction := AStoreAction;
  ClearValue := AClearValue;
end;

{ TPassAction }

class function TPassAction.Create: TPassAction;
begin
  Result.Init;
end;

function TPassAction.GetColor(const AIndex: Integer): PColorAttachmentAction;
begin
  Assert(Cardinal(AIndex) < MAX_COLOR_ATTACHMENTS);
  Result := @FHandle.colors[AIndex];
end;

function TPassAction.GetDepth: PDepthAttachmentAction;
begin
  Result := @FHandle.depth;
end;

function TPassAction.GetStencil: PStencilAttachmentAction;
begin
  Result := @FHandle.stencil;
end;

procedure TPassAction.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TD3D11Swapchain }

function TD3D11Swapchain.GetDepthStencilView: IInterface;
begin
  Result := IInterface(FHandle.depth_stencil_view);
end;

function TD3D11Swapchain.GetRenderView: IInterface;
begin
  Result := IInterface(FHandle.render_view);
end;

function TD3D11Swapchain.GetResolveView: IInterface;
begin
  Result := IInterface(FHandle.resolve_view);
end;

procedure TD3D11Swapchain.SetDepthStencilView(const AValue: IInterface);
begin
  FHandle.depth_stencil_view := Pointer(AValue);
end;

procedure TD3D11Swapchain.SetRenderView(const AValue: IInterface);
begin
  FHandle.render_view := Pointer(AValue);
end;

procedure TD3D11Swapchain.SetResolveView(const AValue: IInterface);
begin
  FHandle.resolve_view := Pointer(AValue);
end;

{ TSwapchain }

function TSwapchain.GetColorFormat: TPixelFormat;
begin
  Result := TPixelFormat(FHandle.color_format);
end;

function TSwapchain.GetD3D11: PD3D11Swapchain;
begin
  Result := @FHandle.d3d11;
end;

function TSwapchain.GetDepthFormat: TPixelFormat;
begin
  Result := TPixelFormat(FHandle.depth_format);
end;

function TSwapchain.GetGL: PGLSwapchain;
begin
  Result := @FHandle.gl;
end;

function TSwapchain.GetMetal: PMetalSwapchain;
begin
  Result := @FHandle.metal;
end;

function TSwapchain.GetVulkan: PVulkanSwapchain;
begin
  Result := @FHandle.vulkan;
end;

{ TD3D11BufferInfo }

function TD3D11BufferInfo.GetBuffer: IInterface;
begin
  Result := IInterface(FHandle.buf);
end;

{ TMetalBufferInfo }

function TMetalBufferInfo.GetBuffer(const AIndex: Integer): Pointer;
begin
  Assert(Cardinal(AIndex) < NUM_INFLIGHT_FRAMES);
  Result := FHandle.buf[AIndex];
end;

{ TGLBufferInfo }

function TGLBufferInfo.GetBuffer(const AIndex: Integer): Cardinal;
begin
  Assert(Cardinal(AIndex) < NUM_INFLIGHT_FRAMES);
  Result := FHandle.buf[AIndex];
end;

{ TBufferDesc }

procedure TBufferDesc.Convert(out ADst: _sg_buffer_desc);
begin
  ADst._start_canary := 0;
  ADst.size := Size;
  ADst.usage := Usage.FHandle;
  ADst.data := Data.FHandle;
  if (TraceLabel = '') then
    ADst.&label := nil
  else
    ADst.&label := PUTF8Char(TraceLabel);
  Move(GLBuffers, ADst.gl_buffers, SizeOf(GLBuffers));
  Move(MetalBuffers, ADst.mtl_buffers, SizeOf(MetalBuffers));
  ADst.d3d11_buffer := Pointer(D3D11Buffer);
  ADst.wgpu_buffer := nil;
  ADst._end_canary := 0;
end;

class function TBufferDesc.Create: TBufferDesc;
begin
  Result.Init;
end;

procedure TBufferDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TBufferDesc.InitFrom(const ASrc: _sg_buffer_desc);
begin
  Size := ASrc.size;
  Usage.FHandle := ASrc.usage;
  Data.FHandle := ASrc.data;
  TraceLabel := UTF8String(ASrc.&label);
  Move(ASrc.gl_buffers, GLBuffers, SizeOf(GLBuffers));
  Move(ASrc.mtl_buffers, MetalBuffers, SizeOf(MetalBuffers));
  D3D11Buffer := IInterface(ASrc.d3d11_buffer);
end;

{ TBuffer }

procedure TBuffer.Allocate;
begin
  FHandle := _sg_alloc_buffer;
end;

function TBuffer.Append(const AData: TBytes): Integer;
begin
  var Data: _sg_range;
  Data.ptr := Pointer(AData);
  Data.size := Length(AData);
  Result := _sg_append_buffer(FHandle, @Data);
end;

function TBuffer.Append(const AData: TRange): Integer;
begin
  Result := _sg_append_buffer(FHandle, @AData.FHandle);
end;

constructor TBuffer.Create(const ADesc: TBufferDesc);
begin
  Init(ADesc);
end;

procedure TBuffer.Deallocate;
begin
  _sg_dealloc_buffer(FHandle);
end;

procedure TBuffer.Fail;
begin
  _sg_fail_buffer(FHandle);
end;

procedure TBuffer.Free;
begin
  _sg_destroy_buffer(FHandle);
  FHandle.id := 0;
end;

function TBuffer.GetD3D11BufferInfo: TD3D11BufferInfo;
begin
  Result.FHandle := _sg_d3d11_buffer_info(FHandle);
end;

function TBuffer.GetDesc: TBufferDesc;
begin
  Result.InitFrom(_sg_query_buffer_desc(FHandle));
end;

function TBuffer.GetGLBufferInfo: TGLBufferInfo;
begin
  Result.FHandle := _sg_gl_query_buffer_info(FHandle);
end;

function TBuffer.GetInfo: TBufferInfo;
begin
  Result.FHandle := _sg_query_buffer_info(FHandle);
end;

function TBuffer.GetMetalBufferInfo: TMetalBufferInfo;
begin
  Result.FHandle := _sg_mtl_query_buffer_info(FHandle);
end;

function TBuffer.GetOverflow: Boolean;
begin
  Result := _sg_query_buffer_overflow(FHandle);
end;

function TBuffer.GetSize: NativeInt;
begin
  Result := _sg_query_buffer_size(FHandle);
end;

function TBuffer.GetState: TResourceState;
begin
  Result := TResourceState(_sg_query_buffer_state(FHandle));
end;

procedure TBuffer.Init(const ADesc: TBufferDesc);
begin
  var Desc: _sg_buffer_desc;
  ADesc.Convert(Desc);
  FHandle := _sg_make_buffer(@Desc);
end;

procedure TBuffer.Setup(const ADesc: TBufferDesc);
begin
  var Desc: _sg_buffer_desc;
  ADesc.Convert(Desc);
  _sg_init_buffer(FHandle, @Desc);
end;

procedure TBuffer.Teardown;
begin
  _sg_uninit_buffer(FHandle);
end;

procedure TBuffer.Update(const AData: TRange);
begin
  _sg_update_buffer(FHandle, @AData.FHandle);
end;

procedure TBuffer.Update(const AData: TBytes);
begin
  var Data: _sg_range;
  Data.ptr := Pointer(AData);
  Data.size := Length(AData);
  _sg_update_buffer(FHandle, @Data);
end;

function TBuffer.WillOverflow(const ASize: NativeInt): Boolean;
begin
  Result := _sg_query_buffer_will_overflow(FHandle, ASize);
end;

{ TImageData }

procedure TImageData.Convert(out ADst: _sg_image_data);
begin
  for var I := 0 to MAX_MIPMAPS - 1 do
    ADst.mip_levels[I] := MipLevels[I].FHandle;
end;

class function TImageData.Create: TImageData;
begin
  Result.Init;
end;

procedure TImageData.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TImageData.InitFrom(const ASrc: _sg_image_data);
begin
  for var I := 0 to MAX_MIPMAPS - 1 do
    MipLevels[I].FHandle := ASrc.mip_levels[I];
end;

{ TD3D11ImageInfo }

function TD3D11ImageInfo.GetResource: IInterface;
begin
  Result := IInterface(FHandle.res);
end;

function TD3D11ImageInfo.GetTex2D: IInterface;
begin
  Result := IInterface(FHandle.tex2d);
end;

function TD3D11ImageInfo.GetTex3D: IInterface;
begin
  Result := IInterface(FHandle.tex3d);
end;

{ TMetalImageInfo }

function TMetalImageInfo.GetTexture(const AIndex: Integer): Pointer;
begin
  Assert(Cardinal(AIndex) < NUM_INFLIGHT_FRAMES);
  Result := FHandle.tex[AIndex];
end;

{ TGLImageInfo }

function TGLImageInfo.GetTexture(const AIndex: Integer): Cardinal;
begin
  Assert(Cardinal(AIndex) < NUM_INFLIGHT_FRAMES);
  Result := FHandle.tex[AIndex];
end;

{ TImageDesc }

procedure TImageDesc._Convert(out ADst: _sg_image_desc);
begin
  ADst._start_canary := 0;
  ADst.&type := Ord(ImageType);
  ADst.usage := Usage.FHandle;
  ADst.width := Width;
  ADst.height := Height;
  ADst.num_slices := NumSlices;
  ADst.num_mipmaps := NumMipmaps;
  ADst.pixel_format := Ord(PixelFormat);
  ADst.sample_count := SampleCount;
  Data.Convert(ADst.data);
  if (TraceLabel = '') then
    ADst.&label := nil
  else
    ADst.&label := PUTF8Char(TraceLabel);
  Move(GLTextures, ADst.gl_textures, SizeOf(GLTextures));
  ADst.gl_texture_target := GLTextureTarget;
  Move(MetalTextures, ADst.mtl_textures, SizeOf(GLTextures));
  ADst.d3d11_texture := Pointer(D3D11Texture);
  ADst.wgpu_texture := nil;
  ADst._end_canary := 0;
end;

procedure TImageDesc._InitFrom(const ASrc: _sg_image_desc);
begin
  ImageType := TImageType(ASrc.&type);
  Usage.FHandle := ASrc.usage;
  Width := ASrc.width;
  Height := ASrc.height;
  NumSlices := ASrc.num_slices;
  NumMipmaps := ASrc.num_mipmaps;
  PixelFormat := TPixelFormat(ASrc.pixel_format);
  SampleCount := ASrc.sample_count;
  Data.InitFrom(ASrc.data);
  TraceLabel := UTF8String(ASrc.&label);
  Move(ASrc.gl_textures, GLTextures, SizeOf(GLTextures));
  GLTextureTarget := ASrc.gl_texture_target;
  Move(ASrc.mtl_textures, MetalTextures, SizeOf(MetalTextures));
  D3D11Texture := IInterface(ASrc.d3d11_texture);
end;

class function TImageDesc.Create: TImageDesc;
begin
  Result.Init;
end;

procedure TImageDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TImage }

procedure TImage.Allocate;
begin
  FHandle := _sg_alloc_image;
end;

constructor TImage.Create(const ADesc: TImageDesc);
begin
  Init(ADesc);
end;

procedure TImage.Deallocate;
begin
  _sg_dealloc_image(FHandle);
end;

procedure TImage.Fail;
begin
  _sg_fail_image(FHandle);
end;

procedure TImage.Free;
begin
  _sg_destroy_image(FHandle);
  FHandle.id := 0;
end;

function TImage.GetD3D11ImageInfo: TD3D11ImageInfo;
begin
  Result.FHandle := _sg_d3d11_query_image_info(FHandle);
end;

function TImage.GetDesc: TImageDesc;
begin
  Result._InitFrom(_sg_query_image_desc(FHandle));
end;

function TImage.GetGLImageInfo: TGLImageInfo;
begin
  Result.FHandle := _sg_gl_query_image_info(FHandle);
end;

function TImage.GetHeight: Integer;
begin
  Result := _sg_query_image_height(FHandle);
end;

function TImage.GetImageType: TImageType;
begin
  Result := TImageType(_sg_query_image_type(FHandle));
end;

function TImage.GetInfo: TImageInfo;
begin
  Result.FHandle := _sg_query_image_info(FHandle);
end;

function TImage.GetMetalImageInfo: TMetalImageInfo;
begin
  Result.FHandle := _sg_mtl_query_image_info(FHandle);
end;

function TImage.GetNumMipmaps: Integer;
begin
  Result := _sg_query_image_num_mipmaps(FHandle);
end;

function TImage.GetNumSlices: Integer;
begin
  Result := _sg_query_image_num_slices(FHandle);
end;

function TImage.GetPixelFormat: TPixelFormat;
begin
  Result := TPixelFormat(_sg_query_image_pixelformat(FHandle));
end;

function TImage.GetSampleCount: Integer;
begin
  Result := _sg_query_image_sample_count(FHandle);
end;

function TImage.GetState: TResourceState;
begin
  Result := TResourceState(_sg_query_image_state(FHandle));
end;

function TImage.GetUsage: TImageUsage;
begin
  Result.FHandle := _sg_query_image_usage(FHandle);
end;

function TImage.GetWidth: Integer;
begin
  Result := _sg_query_image_width(FHandle);
end;

procedure TImage.Init(const ADesc: TImageDesc);
begin
  var Desc: _sg_image_desc;
  ADesc._Convert(Desc);
  FHandle := _sg_make_image(@Desc);
end;

procedure TImage.Setup(const ADesc: TImageDesc);
begin
  var Desc: _sg_image_desc;
  ADesc._Convert(Desc);
  _sg_init_image(FHandle, @Desc);
end;

procedure TImage.Teardown;
begin
  _sg_uninit_image(FHandle);
end;

procedure TImage.Update(const AData: TImageData);
begin
  var Data: _sg_image_data;
  AData.Convert(Data);
  _sg_update_image(FHandle, @Data);
end;

{ TD3D11SamplerInfo }

function TD3D11SamplerInfo.GetSampler: IInterface;
begin
  Result := IInterface(FHandle.smp);
end;

{ TSamplerDesc }

class function TSamplerDesc.Create: TSamplerDesc;
begin
  Result.Init;
end;

procedure TSamplerDesc.Init;
begin
  var Def: _sg_sampler_desc;
  FillChar(Def, SizeOf(Def), 0);
  Def := _sg_query_sampler_defaults(@Def);
  _InitFrom(Def);
end;

procedure TSamplerDesc._Convert(out ADst: _sg_sampler_desc);
begin
  ADst._start_canary := 0;
  ADst.min_filter := Ord(MinFilter);
  ADst.mag_filter := Ord(MagFilter);
  ADst.mipmap_filter := Ord(MipmapFilter);
  ADst.wrap_u := Ord(WrapU);
  ADst.wrap_v := Ord(WrapV);
  ADst.wrap_w := Ord(WrapW);
  ADst.min_lod := MinLod;
  ADst.max_lod := MaxLod;
  ADst.border_color := Ord(BorderColor);
  ADst.compare := Ord(Compare);
  ADst.max_anisotropy := MaxAnisotropy;

  if (TraceLabel = '') then
    ADst.&label := nil
  else
    ADst.&label := PUTF8Char(TraceLabel);

  ADst.gl_sampler := GLSampler;
  ADst.mtl_sampler := MtlSampler;
  ADst.d3d11_sampler := Pointer(D3D11Sampler);
  ADst.wgpu_sampler := nil;
  ADst._end_canary := 0;
end;

procedure TSamplerDesc._InitFrom(const ASrc: _sg_sampler_desc);
begin
  FillChar(Self, SizeOf(Self), 0);
  MinFilter := TFilter(ASrc.min_filter);
  MagFilter := TFilter(ASrc.mag_filter);
  MipmapFilter := TFilter(ASrc.mipmap_filter);
  WrapU := TWrap(ASrc.wrap_u);
  WrapV := TWrap(ASrc.wrap_v);
  WrapW := TWrap(ASrc.wrap_w);
  MinLod := ASrc.min_lod;
  MaxLod := ASrc.max_lod;
  BorderColor := TBorderColor(ASrc.border_color);
  Compare := TCompareFunc(ASrc.compare);
  MaxAnisotropy := ASrc.max_anisotropy;
  TraceLabel := UTF8String(ASrc.&label);
  GLSampler := ASrc.gl_sampler;
  MtlSampler := ASrc.mtl_sampler;
  D3D11Sampler := IInterface(ASrc.d3d11_sampler);
end;

{ TSampler }

procedure TSampler.Allocate;
begin
  FHandle := _sg_alloc_sampler;
end;

constructor TSampler.Create(const ADesc: TSamplerDesc);
begin
  Init(ADesc);
end;

procedure TSampler.Deallocate;
begin
  _sg_dealloc_sampler(FHandle);
end;

procedure TSampler.Fail;
begin
  _sg_fail_sampler(FHandle);
end;

procedure TSampler.Free;
begin
  _sg_destroy_sampler(FHandle);
  FHandle.id := 0;
end;

function TSampler.GetD3D11SamplerInfo: TD3D11SamplerInfo;
begin
  Result.FHandle := _sg_d3d11_query_sampler_info(FHandle);
end;

function TSampler.GetDesc: TSamplerDesc;
begin
  Result._InitFrom(_sg_query_sampler_desc(FHandle));
end;

function TSampler.GetGLSamplerInfo: TGLSamplerInfo;
begin
  Result.FHandle := _sg_gl_query_sampler_info(FHandle);
end;

function TSampler.GetInfo: TSamplerInfo;
begin
  Result.FHandle := _sg_query_sampler_info(FHandle);
end;

function TSampler.GetMetalSamplerInfo: TMetalSamplerInfo;
begin
  Result.FHandle := _sg_mtl_query_sampler_info(FHandle);
end;

function TSampler.GetState: TResourceState;
begin
  Result := TResourceState(_sg_query_sampler_state(FHandle));
end;

procedure TSampler.Init(const ADesc: TSamplerDesc);
begin
  var Desc: _sg_sampler_desc;
  ADesc._Convert(Desc);
  FHandle := _sg_make_sampler(@Desc);
end;

procedure TSampler.Setup(const ADesc: TSamplerDesc);
begin
  var Desc: _sg_sampler_desc;
  ADesc._Convert(Desc);
  _sg_init_sampler(FHandle, @Desc);
end;

procedure TSampler.Teardown;
begin
  _sg_uninit_sampler(FHandle);
end;

{ TBufferViewDesc }

procedure TBufferViewDesc.Convert(out ADst: _sg_buffer_view_desc);
begin
  ADst.buffer := Buffer.FHandle;
  ADst.offset := Offset;
end;

procedure TBufferViewDesc.InitFrom(const ASrc: _sg_buffer_view_desc);
begin
  Buffer.FHandle := ASrc.buffer;
  Offset := ASrc.offset;
end;

{ TImageViewDesc }

procedure TImageViewDesc.Convert(out ADst: _sg_image_view_desc);
begin
  ADst.image := Image.FHandle;
  ADst.mip_level := MipLevel;
  ADst.slice := Slice;
end;

procedure TImageViewDesc.InitFrom(const ASrc: _sg_image_view_desc);
begin
  Image.FHandle := ASrc.image;
  MipLevel := ASrc.mip_level;
  Slice := ASrc.slice;
end;

{ TTextureViewDesc }

procedure TTextureViewDesc._Convert(out ADst: _sg_texture_view_desc);
begin
  ADst.image := Image.FHandle;
  ADst.mip_levels := MipLevels.FHandle;
  ADst.slices := Slices.FHandle;
end;

procedure TTextureViewDesc._InitFrom(const ASrc: _sg_texture_view_desc);
begin
  Image.FHandle := ASrc.image;
  MipLevels.FHandle := ASrc.mip_levels;
  Slices.FHandle := ASrc.slices;
end;

{ TViewDesc }

procedure TViewDesc.Convert(out ADst: _sg_view_desc);
begin
  ADst._start_canary := 0;
  Texture._Convert(ADst.texture);
  StorageBuffer.Convert(ADst.storage_buffer);
  StorageImage.Convert(ADst.storage_image);
  ColorAttachment.Convert(ADst.color_attachment);
  ResolveAttachment.Convert(ADst.resolve_attachment);
  DepthStencilAttachment.Convert(ADst.depth_stencil_attachment);
  if (TraceLabel = '') then
    ADst.&label := nil
  else
    ADst.&label := PUTF8Char(TraceLabel);
  ADst._end_canary := 0;
end;

class function TViewDesc.Create: TViewDesc;
begin
  Result.Init;
end;

procedure TViewDesc.Init;
begin
  var Def: _sg_view_desc;
  FillChar(Def, SizeOf(Def), 0);
  Def := _sg_query_view_defaults(@Def);
  InitFrom(Def);
end;

procedure TViewDesc.InitFrom(const ASrc: _sg_view_desc);
begin
  Texture._InitFrom(ASrc.texture);
  StorageBuffer.InitFrom(ASrc.storage_buffer);
  StorageImage.InitFrom(ASrc.storage_image);
  ColorAttachment.InitFrom(ASrc.color_attachment);
  ResolveAttachment.InitFrom(ASrc.resolve_attachment);
  DepthStencilAttachment.InitFrom(ASrc.depth_stencil_attachment);
  TraceLabel := UTF8String(ASrc.&label);
end;

{ TD3D11ViewInfo }

function TD3D11ViewInfo.GetDepthStencilView: IInterface;
begin
  Result := IInterface(FHandle.dsv);
end;

function TD3D11ViewInfo.GetRenderTargetView: IInterface;
begin
  Result := IInterface(FHandle.rtv);
end;

function TD3D11ViewInfo.GetShaderResourceView: IInterface;
begin
  Result := IInterface(FHandle.srv);
end;

function TD3D11ViewInfo.GetUnorderedAccessView: IInterface;
begin
  Result := IInterface(FHandle.uav);
end;

{ TGLViewInfo }

function TGLViewInfo.GetTextureView(const AIndex: Integer): Cardinal;
begin
  Assert(Cardinal(AIndex) < NUM_INFLIGHT_FRAMES);
  Result := FHandle.tex_view[AIndex];
end;

{ TView }

procedure TView.Allocate;
begin
  FHandle := _sg_alloc_view;
end;

constructor TView.Create(const ADesc: TViewDesc);
begin
  Init(ADesc);
end;

procedure TView.Deallocate;
begin
  _sg_dealloc_view(FHandle);
end;

procedure TView.Fail;
begin
  _sg_fail_view(FHandle);
end;

procedure TView.Free;
begin
  _sg_destroy_view(FHandle);
  FHandle.id := 0;
end;

function TView.GetBuffer: TBuffer;
begin
  Result.FHandle := _sg_query_view_buffer(FHandle);
end;

function TView.GetD3D11ViewInfo: TD3D11ViewInfo;
begin
  Result.FHandle := _sg_d3d11_query_view_info(FHandle);
end;

function TView.GetDesc: TViewDesc;
begin
  Result.InitFrom(_sg_query_view_desc(FHandle));
end;

function TView.GetGLViewInfo: TGLViewInfo;
begin
  Result.FHandle := _sg_gl_query_view_info(FHandle);
end;

function TView.GetImage: TImage;
begin
  Result.FHandle := _sg_query_view_image(FHandle);
end;

function TView.GetInfo: TViewInfo;
begin
  Result.FHandle := _sg_query_view_info(FHandle);
end;

function TView.GetState: TResourceState;
begin
  Result := TResourceState(_sg_query_view_state(FHandle));
end;

function TView.GetViewType: TViewType;
begin
  Result := TViewType(_sg_query_view_type(FHandle));
end;

procedure TView.Init(const ADesc: TViewDesc);
begin
  var Desc: _sg_view_desc;
  ADesc.Convert(Desc);
  FHandle := _sg_make_view(@Desc);
end;

procedure TView.Setup(const ADesc: TViewDesc);
begin
  var Desc: _sg_view_desc;
  ADesc.Convert(Desc);
  _sg_init_view(FHandle, @Desc);
end;

procedure TView.Teardown;
begin
  _sg_uninit_view(FHandle);
end;

{ TShaderFunction }

procedure TShaderFunction.Convert(out ADst: _sg_shader_function);
begin
  ADst.source := PAnsiChar(Source);
  ADst.bytecode := ByteCode.FHandle;
  ADst.entry := PAnsiChar(Entry);
  ADst.d3d11_target := PAnsiChar(D3D11Target);
  ADst.d3d11_filepath := PAnsiChar(D3D11FilePath);
end;

procedure TShaderFunction.InitFrom(const ASrc: _sg_shader_function);
begin
  Source := AnsiString(ASrc.source);
  ByteCode.FHandle := ASrc.bytecode;
  Entry := AnsiString(ASrc.entry);
  D3D11Target := AnsiString(ASrc.d3d11_target);
  D3D11FilePath := AnsiString(ASrc.d3d11_filepath);
end;

{ TShaderVertexAttr }

procedure TShaderVertexAttr.Convert(out ADst: _sg_shader_vertex_attr);
begin
  ADst.base_type := Ord(BaseType);
  ADst.glsl_name := PAnsiChar(GlslName);
  ADst.hlsl_sem_name := PAnsiChar(HlslSemName);
  ADst.hlsl_sem_index := HlslSemIndex;
end;

procedure TShaderVertexAttr.InitFrom(const ASrc: _sg_shader_vertex_attr);
begin
  BaseType := TShaderAttrBaseType(ASrc.base_type);
  GlslName := AnsiString(ASrc.glsl_name);
  HlslSemName := AnsiString(ASrc.hlsl_sem_name);
  HlslSemIndex := ASrc.hlsl_sem_index;
end;

{ TGlslShaderUniform }

procedure TGlslShaderUniform.Convert(out ADst: _sg_glsl_shader_uniform);
begin
  ADst.&type := Ord(UniformType);
  ADst.array_count := ArrayCount;
  ADst.glsl_name := PAnsiChar(GlslName);
end;

procedure TGlslShaderUniform.InitFrom(const ASrc: _sg_glsl_shader_uniform);
begin
  UniformType := TUniformType(ASrc.&type);
  ArrayCount := ASrc.array_count;
  GlslName := AnsiString(ASrc.glsl_name);
end;

{ TShaderUniformBlock }

procedure TShaderUniformBlock.Convert(out ADst: _sg_shader_uniform_block);
begin
  ADst.stage := Ord(Stage);
  ADst.size := Size;
  ADst.hlsl_register_b_n := HlslRegisterBN;
  ADst.msl_buffer_n := MslBufferN;
  ADst.wgsl_group0_binding_n := WgslGroup0BindingN;
  ADst.spirv_set0_binding_n := SpirvSet0BindingN;
  ADst.layout := Ord(Layout);

  for var I := 0 to MAX_UNIFORMBLOCK_MEMBERS - 1 do
    GlslUniforms[I].Convert(ADst.glsl_uniforms[I]);
end;

procedure TShaderUniformBlock.InitFrom(const ASrc: _sg_shader_uniform_block);
begin
  Stage := TShaderStage(ASrc.stage);
  Size := ASrc.Size;
  HlslRegisterBN := ASrc.hlsl_register_b_n;
  MslBufferN := ASrc.msl_buffer_n;
  WgslGroup0BindingN := ASrc.wgsl_group0_binding_n;
  SpirvSet0BindingN := ASrc.spirv_set0_binding_n;
  Layout := TUniformLayout(ASrc.layout);

  for var I := 0 to MAX_UNIFORMBLOCK_MEMBERS - 1 do
    GlslUniforms[I].InitFrom(ASrc.glsl_uniforms[I]);
end;

{ TShaderTextureView }

procedure TShaderTextureView.Convert(out ADst: _sg_shader_texture_view);
begin
  ADst.stage := Ord(Stage);
  ADst.image_type := Ord(ImageType);
  ADst.sample_type := Ord(SampleType);
  ADst.multisampled := MultiSampled;
  ADst.hlsl_register_t_n := HlslRegisterTN;
  ADst.msl_texture_n := MslTextureN;
  ADst.wgsl_group1_binding_n := WgslGroup1BindingN;
  ADst.spirv_set1_binding_n := SpirvSet1BindingN;
end;

procedure TShaderTextureView.InitFrom(const ASrc: _sg_shader_texture_view);
begin
  Stage := TShaderStage(ASrc.stage);
  ImageType := TImageType(ASrc.image_type);
  SampleType := TImageSampleType(ASrc.sample_type);
  MultiSampled := ASrc.multisampled;
  HlslRegisterTN := ASrc.hlsl_register_t_n;
  MslTextureN := ASrc.msl_texture_n;
  WgslGroup1BindingN := ASrc.wgsl_group1_binding_n;
  SpirvSet1BindingN := ASrc.spirv_set1_binding_n;
end;

{ TShaderStorageBufferView }

procedure TShaderStorageBufferView.Convert(
  out ADst: _sg_shader_storage_buffer_view);
begin
  ADst.stage := Ord(Stage);
  ADst.readonly := ReadOnly;
  ADst.hlsl_register_t_n := HlslRegisterTN;
  ADst.hlsl_register_u_n := HlslRegisterUN;
  ADst.msl_buffer_n := MslBufferN;
  ADst.wgsl_group1_binding_n := WgslGroup1BindingN;
  ADst.spirv_set1_binding_n := SpirvSet1BindingN;
  ADst.glsl_binding_n := GlslBindingN;
end;

procedure TShaderStorageBufferView.InitFrom(
  const ASrc: _sg_shader_storage_buffer_view);
begin
  Stage := TShaderStage(ASrc.stage);
  ReadOnly := ASrc.readonly;
  HlslRegisterTN := ASrc.hlsl_register_t_n;
  HlslRegisterUN := ASrc.hlsl_register_u_n;
  MslBufferN := ASrc.msl_buffer_n;
  WgslGroup1BindingN := ASrc.wgsl_group1_binding_n;
  SpirvSet1BindingN := ASrc.spirv_set1_binding_n;
  GlslBindingN := ASrc.glsl_binding_n;
end;

{ TShaderStorageImageView }

procedure TShaderStorageImageView.Convert(
  out ADst: _sg_shader_storage_image_view);
begin
  ADst.stage := Ord(Stage);
  ADst.image_type := Ord(ImageType);
  ADst.access_format := Ord(AccessFormat);
  ADst.writeonly := WriteOnly;
  ADst.hlsl_register_u_n := HlslRegisterUN;
  ADst.msl_texture_n := MslTextureN;
  ADst.wgsl_group1_binding_n := WgslGroup1BindingN;
  ADst.spirv_set1_binding_n := SpirvSet1BindingN;
  ADst.glsl_binding_n := GlslBindingN;
end;

procedure TShaderStorageImageView.InitFrom(
  const ASrc: _sg_shader_storage_image_view);
begin
  Stage := TShaderStage(ASrc.stage);
  ImageType := TImageType(ASrc.image_type);
  AccessFormat := TPixelFormat(ASrc.access_format);
  WriteOnly := ASrc.writeonly;
  HlslRegisterUN := ASrc.hlsl_register_u_n;
  MslTextureN := ASrc.msl_texture_n;
  WgslGroup1BindingN := ASrc.wgsl_group1_binding_n;
  SpirvSet1BindingN := ASrc.spirv_set1_binding_n;
  GlslBindingN := ASrc.glsl_binding_n;
end;

{ TShaderView }

procedure TShaderView.Convert(out ADst: _sg_shader_view);
begin
  Texture.Convert(ADst.texture);
  StorageBuffer.Convert(ADst.storage_buffer);
  StorageImage.Convert(ADst.storage_image);
end;

procedure TShaderView.InitFrom(const ASrc: _sg_shader_view);
begin
  Texture.InitFrom(ASrc.texture);
  StorageBuffer.InitFrom(ASrc.storage_buffer);
  StorageImage.InitFrom(ASrc.storage_image);
end;

{ TShaderSampler }

procedure TShaderSampler.Convert(out ADst: _sg_shader_sampler);
begin
  ADst.stage := Ord(Stage);
  ADst.sampler_type := Ord(SamplerType);
  ADst.hlsl_register_s_n := HlslRegisterSN;
  ADst.msl_sampler_n := MslSamplerN;
  ADst.wgsl_group1_binding_n := WgslGroup1BindingN;
  ADst.spirv_set1_binding_n := SpirvSet1BindingN;
end;

procedure TShaderSampler.InitFrom(const ASrc: _sg_shader_sampler);
begin
  Stage := TShaderStage(ASrc.stage);
  SamplerType := TSamplerType(ASrc.sampler_type);
  HlslRegisterSN := ASrc.hlsl_register_s_n;
  MslSamplerN := ASrc.msl_sampler_n;
  WgslGroup1BindingN := ASrc.wgsl_group1_binding_n;
  SpirvSet1BindingN := ASrc.spirv_set1_binding_n;
end;

{ TShaderTextureSamplerPair }

procedure TShaderTextureSamplerPair.Convert(
  out ADst: _sg_shader_texture_sampler_pair);
begin
  ADst.stage := Ord(Stage);
  ADst.view_slot := Ord(ViewSlot);
  ADst.sampler_slot := SamplerSlot;
  ADst.glsl_name := PAnsiChar(GlslName);
end;

procedure TShaderTextureSamplerPair.InitFrom(
  const ASrc: _sg_shader_texture_sampler_pair);
begin
  Stage := TShaderStage(ASrc.stage);
  ViewSlot := TViewType(ASrc.view_slot);
  SamplerSlot := ASrc.sampler_slot;
  GlslName := AnsiString(ASrc.glsl_name);
end;

{ TMetalShaderThreadsPerThreadgroup }

procedure TMetalShaderThreadsPerThreadgroup.Convert(
  out ADst: _sg_mtl_shader_threads_per_threadgroup);
begin
  ADst.x := X;
  ADst.y := Y;
  ADst.z := Z;
end;

procedure TMetalShaderThreadsPerThreadgroup.InitFrom(
  const ASrc: _sg_mtl_shader_threads_per_threadgroup);
begin
  X := ASrc.x;
  Y := ASrc.y;
  Z := ASrc.z;
end;

{ TShaderDesc }

procedure TShaderDesc.Convert(out ADst: _sg_shader_desc);
begin
  ADst._start_canary := 0;

  VertexFunc.Convert(ADst.vertex_func);
  FragmentFunc.Convert(ADst.fragment_func);
  ComputeFunc.Convert(ADst.compute_func);

  for var I := 0 to MAX_VERTEX_ATTRIBUTES - 1 do
    Attrs[I].Convert(ADst.attrs[I]);

  for var I := 0 to MAX_UNIFORMBLOCK_BINDSLOTS - 1 do
    UniformBlocks[I].Convert(ADst.uniform_blocks[I]);

  for var I := 0 to MAX_VIEW_BINDSLOTS - 1 do
    Views[I].Convert(ADst.views[I]);

  for var I := 0 to MAX_SAMPLER_BINDSLOTS - 1 do
    Samplers[I].Convert(ADst.samplers[I]);

  for var I := 0 to MAX_TEXTURE_SAMPLER_PAIRS - 1 do
    TextureSamplerPairs[I].Convert(ADst.texture_sampler_pairs[I]);

  MtlThreadsPerThreadgroup.Convert(ADst.mtl_threads_per_threadgroup);

  if (TraceLabel = '') then
    ADst.&label := nil
  else
    ADst.&label := PUTF8Char(TraceLabel);

  ADst._end_canary := 0;
end;

class function TShaderDesc.Create: TShaderDesc;
begin
  Result.Init;
end;

procedure TShaderDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);

  var Def: _sg_shader_desc;
  FillChar(Def, SizeOf(Def), 0);
  Def := _sg_query_shader_defaults(@Def);

  VertexFunc.InitFrom(Def.vertex_func);
  FragmentFunc.InitFrom(Def.vertex_func);
  ComputeFunc.InitFrom(Def.vertex_func);

  for var I := 0 to MAX_VERTEX_ATTRIBUTES - 1 do
    Attrs[I].InitFrom(Def.attrs[I]);

  for var I := 0 to MAX_UNIFORMBLOCK_BINDSLOTS - 1 do
    UniformBlocks[I].InitFrom(Def.uniform_blocks[I]);

  for var I := 0 to MAX_VIEW_BINDSLOTS - 1 do
    Views[I].InitFrom(Def.views[I]);

  for var I := 0 to MAX_SAMPLER_BINDSLOTS - 1 do
    Samplers[I].InitFrom(Def.samplers[I]);

  for var I := 0 to MAX_TEXTURE_SAMPLER_PAIRS - 1 do
    TextureSamplerPairs[I].InitFrom(Def.texture_sampler_pairs[I]);

  MtlThreadsPerThreadgroup.InitFrom(Def.mtl_threads_per_threadgroup);

  TraceLabel := UTF8String(Def.&label);
end;

procedure TShaderDesc.InitFrom(const ASrc: _sg_shader_desc);
begin
  VertexFunc.InitFrom(ASrc.vertex_func);
  FragmentFunc.InitFrom(ASrc.fragment_func);
  ComputeFunc.InitFrom(ASrc.compute_func);

  for var I := 0 to MAX_VERTEX_ATTRIBUTES - 1 do
    Attrs[I].InitFrom(ASrc.attrs[I]);

  for var I := 0 to MAX_UNIFORMBLOCK_BINDSLOTS - 1 do
    UniformBlocks[I].InitFrom(ASrc.uniform_blocks[I]);

  for var I := 0 to MAX_VIEW_BINDSLOTS - 1 do
    Views[I].InitFrom(ASrc.views[I]);

  for var I := 0 to MAX_SAMPLER_BINDSLOTS - 1 do
    Samplers[I].InitFrom(ASrc.samplers[I]);

  for var I := 0 to MAX_TEXTURE_SAMPLER_PAIRS - 1 do
    TextureSamplerPairs[I].InitFrom(ASrc.texture_sampler_pairs[I]);

  MtlThreadsPerThreadgroup.InitFrom(ASrc.mtl_threads_per_threadgroup);

  TraceLabel := UTF8String(ASrc.&label);
end;

{ TD3D11ShaderInfo }

function TD3D11ShaderInfo.GetConstantBuffer(const AIndex: Integer): IInterface;
begin
  Assert(Cardinal(AIndex) < MAX_UNIFORMBLOCK_BINDSLOTS);
  Result := IInterface(FHandle.cbufs[AIndex]);
end;

function TD3D11ShaderInfo.GetFragmentShader: IInterface;
begin
  Result := IInterface(FHandle.fs);
end;

function TD3D11ShaderInfo.GetVertexShader: IInterface;
begin
  Result := IInterface(FHandle.vs);
end;

{ TShader }

procedure TShader.Allocate;
begin
  FHandle := _sg_alloc_shader;
end;

constructor TShader.Create(const ADesc: TShaderDesc);
begin
  Init(ADesc);
end;

constructor TShader.Create(const ADesc: PNativeShaderDesc);
begin
  Init(ADesc);
end;

procedure TShader.Deallocate;
begin
  _sg_dealloc_shader(FHandle);
end;

procedure TShader.Fail;
begin
  _sg_fail_shader(FHandle);
end;

procedure TShader.Free;
begin
  _sg_destroy_shader(FHandle);
  FHandle.id := 0;
end;

function TShader.GetD3D11ShaderInfo: TD3D11ShaderInfo;
begin
  Result.FHandle := _sg_d3d11_query_shader_info(FHandle);
end;

function TShader.GetDesc: TShaderDesc;
begin
  Result.InitFrom(_sg_query_shader_desc(FHandle));
end;

function TShader.GetGLShaderInfo: TGLShaderInfo;
begin
  Result.FHandle := _sg_gl_query_shader_info(FHandle);
end;

function TShader.GetInfo: TShaderInfo;
begin
  Result.FHandle := _sg_query_shader_info(FHandle);
end;

function TShader.GetMetalShaderInfo: TMetalShaderInfo;
begin
  Result.FHandle := _sg_mtl_query_shader_info(FHandle);
end;

function TShader.GetState: TResourceState;
begin
  Result := TResourceState(_sg_query_shader_state(FHandle));
end;

procedure TShader.Init(const ADesc: PNativeShaderDesc);
begin
  FHandle := _sg_make_shader(ADesc);
end;

procedure TShader.Init(const ADesc: TShaderDesc);
begin
  var Desc: _sg_shader_desc;
  ADesc.Convert(Desc);
  FHandle := _sg_make_shader(@Desc);
end;

procedure TShader.Setup(const ADesc: TShaderDesc);
begin
  var Desc: _sg_shader_desc;
  ADesc.Convert(Desc);
  _sg_init_shader(FHandle, @Desc);
end;

procedure TShader.Teardown;
begin
  _sg_uninit_shader(FHandle);
end;

{ TVertexBufferLayoutState }

procedure TVertexBufferLayoutState.Convert(
  out ADst: _sg_vertex_buffer_layout_state);
begin
  ADst.stride := Stride;
  ADst.step_func := Ord(StepFunc);
  ADst.step_rate := StepRate;
end;

constructor TVertexBufferLayoutState.Create(const AStride: Integer;
  const AStepFunc: TVertexStep; const AStepRate: Integer);
begin
  Stride := AStride;
  StepFunc := AStepFunc;
  StepRate := AStepRate;
end;

procedure TVertexBufferLayoutState.Init(const AStride: Integer;
  const AStepFunc: TVertexStep; const AStepRate: Integer);
begin
  Stride := AStride;
  StepFunc := AStepFunc;
  StepRate := AStepRate;
end;

procedure TVertexBufferLayoutState.InitFrom(
  const ASrc: _sg_vertex_buffer_layout_state);
begin
  Stride := ASrc.stride;
  StepFunc := TVertexStep(ASrc.step_func);
  StepRate := ASrc.step_rate;
end;

{ TVertexAttrState }

procedure TVertexAttrState.Convert(out ADst: _sg_vertex_attr_state);
begin
  ADst.buffer_index := BufferIndex;
  ADst.offset := Offset;
  ADst.format := Ord(Format);
end;

constructor TVertexAttrState.Create(const ABufferIndex, AOffset: Integer;
  const AFormat: TVertexFormat);
begin
  BufferIndex := ABufferIndex;
  Offset := AOffset;
  Format := AFormat;
end;

procedure TVertexAttrState.Init(const ABufferIndex, AOffset: Integer;
  const AFormat: TVertexFormat);
begin
  BufferIndex := ABufferIndex;
  Offset := AOffset;
  Format := AFormat;
end;

procedure TVertexAttrState.InitFrom(const ASrc: _sg_vertex_attr_state);
begin
  BufferIndex :=  ASrc.buffer_index;
  Offset := ASrc.offset;
  Format := TVertexFormat(ASrc.format);
end;

{ TVertexLayoutState }

procedure TVertexLayoutState.Convert(out ADst: _sg_vertex_layout_state);
begin
  for var I := 0 to MAX_VERTEXBUFFER_BINDSLOTS - 1 do
    Buffers[I].Convert(ADst.buffers[I]);

  for var I := 0 to MAX_VERTEX_ATTRIBUTES - 1 do
    Attrs[I].Convert(ADst.attrs[I]);
end;

class function TVertexLayoutState.Create: TVertexLayoutState;
begin
  Result.Init;
end;

procedure TVertexLayoutState.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TVertexLayoutState.InitFrom(const ASrc: _sg_vertex_layout_state);
begin
  for var I := 0 to MAX_VERTEXBUFFER_BINDSLOTS - 1 do
    Buffers[I].InitFrom(ASrc.buffers[I]);

  for var I := 0 to MAX_VERTEX_ATTRIBUTES - 1 do
    Attrs[I].InitFrom(ASrc.attrs[I]);
end;

{ _sg_shader_desc_helper }

procedure _sg_shader_desc_helper.Init;
begin
  Self := _sg_query_shader_defaults(@Self);
end;

{ TStencilFaceState }

procedure TStencilFaceState.Convert(out ADst: _sg_stencil_face_state);
begin
  ADst.compare := Ord(Compare);
  ADst.fail_op := Ord(FailOp);
  ADst.depth_fail_op := Ord(DepthFailOp);
  ADst.pass_op := Ord(PassOp);
end;

constructor TStencilFaceState.Create(const ACompare: TCompareFunc;
  const AFailOp, ADepthFailOp, APassOp: TStencilOp);
begin
  Init(ACompare, AFailOp, ADepthFailOp, APassOp);
end;

procedure TStencilFaceState.Init(const ACompare: TCompareFunc; const AFailOp,
  ADepthFailOp, APassOp: TStencilOp);
begin
  Compare := ACompare;
  FailOp := AFailOp;
  DepthFailOp := ADepthFailOp;
  PassOp := APassOp;
end;

procedure TStencilFaceState.InitFrom(const ASrc: _sg_stencil_face_state);
begin
  Compare := TCompareFunc(ASrc.compare);
  FailOp := TStencilOp(ASrc.fail_op);
  DepthFailOp := TStencilOp(ASrc.depth_fail_op);
  PassOp := TStencilOp(ASrc.pass_op);
end;

{ TStencilState }

procedure TStencilState.Convert(out ADst: _sg_stencil_state);
begin
  ADst.enabled := Enabled;
  Front.Convert(ADst.front);
  Back.Convert(ADst.back);
  ADst.read_mask := ReadMask;
  ADst.write_mask := WriteMask;
  ADst.ref := Ref;
end;

constructor TStencilState.Create(const AEnabled: Boolean; const AReadMask,
  AWriteMask, ARef: Byte);
begin
  Init(AEnabled, AReadMask, AWriteMask, ARef);
end;

procedure TStencilState.Init(const AEnabled: Boolean; const AReadMask,
  AWriteMask, ARef: Byte);
begin
  FillChar(Self, SizeOf(Self), 0);
  Enabled := AEnabled;
  ReadMask := AReadMask;
  WriteMask := AWriteMask;
  Ref := ARef;
end;

procedure TStencilState.InitFrom(const ASrc: _sg_stencil_state);
begin
  Enabled := ASrc.enabled;
  Front.InitFrom(ASrc.front);
  Back.InitFrom(ASrc.back);
  ReadMask := ASrc.read_mask;
  WriteMask := ASrc.write_mask;
  Ref := ASrc.ref;
end;

{ TDepthState }

procedure TDepthState.Convert(out ADst: _sg_depth_state);
begin
  ADst.pixel_format := Ord(PixelFormat);
  ADst.compare := Ord(Compare);
  ADst.write_enabled := WriteEnabled;
  ADst.bias := Bias;
  ADst.bias_slope_scale := BiasSlopeScale;
  ADst.bias_clamp := BiasClamp;
end;

constructor TDepthState.Create(const APixelFormat: TPixelFormat;
  const ACompare: TCompareFunc; const AWriteEnabled: Boolean; const ABias,
  ABiasSlopeScale, ABiasClamp: Single);
begin
  Init(APixelFormat, ACompare, AWriteEnabled, ABias, ABiasSlopeScale, ABiasClamp);
end;

procedure TDepthState.Init(const APixelFormat: TPixelFormat;
  const ACompare: TCompareFunc; const AWriteEnabled: Boolean; const ABias,
  ABiasSlopeScale, ABiasClamp: Single);
begin
  PixelFormat := APixelFormat;
  Compare := ACompare;
  WriteEnabled := AWriteEnabled;
  Bias := ABias;
  BiasSlopeScale := ABiasSlopeScale;
  BiasClamp := ABiasClamp;
end;

procedure TDepthState.InitFrom(const ASrc: _sg_depth_state);
begin
  PixelFormat := TPixelFormat(ASrc.pixel_format);
  Compare := TCompareFunc(ASrc.compare);
  WriteEnabled := ASrc.write_enabled;
  Bias := ASrc.bias;
  BiasSlopeScale := ASrc.bias_slope_scale;
  BiasClamp := ASrc.bias_clamp;
end;

{ TBlendState }

procedure TBlendState.Convert(out ADst: _sg_blend_state);
begin
  ADst.enabled := Enabled;
  ADst.src_factor_rgb := Ord(SrcFactorRgb);
  ADst.dst_factor_rgb := Ord(DstFactorRgb);
  ADst.op_rgb := Ord(OpRgb);
  ADst.src_factor_alpha := Ord(SrcFactorAlpha);
  ADst.dst_factor_alpha := Ord(DstFactorAlpha);
  ADst.op_alpha := Ord(OpAlpha);
end;

constructor TBlendState.Create(const AEnabled: Boolean; const ASrcFactorRgb,
  ADstFactorRgb: TBlendFactor; const AOpRgb: TBlendOp; const ASrcFactorAlpha,
  ADstFactorAlpha: TBlendFactor; const AOpAlpha: TBlendOp);
begin
  Init(AEnabled, ASrcFactorRgb, ADstFactorRgb, AOpRgb, ASrcFactorAlpha,
    ADstFactorAlpha, AOpAlpha);
end;

procedure TBlendState.Init(const AEnabled: Boolean; const ASrcFactorRgb,
  ADstFactorRgb: TBlendFactor; const AOpRgb: TBlendOp; const ASrcFactorAlpha,
  ADstFactorAlpha: TBlendFactor; const AOpAlpha: TBlendOp);
begin
  Enabled := AEnabled;
  SrcFactorRgb := ASrcFactorRgb;
  DstFactorRgb := ADstFactorRgb;
  OpRgb := AOpRgb;
  SrcFactorAlpha := ASrcFactorAlpha;
  DstFactorAlpha := ADstFactorAlpha;
  OpAlpha := AOpAlpha;
end;

procedure TBlendState.InitFrom(const ASrc: _sg_blend_state);
begin
  Enabled := ASrc.enabled;
  SrcFactorRgb := TBlendFactor(ASrc.src_factor_rgb);
  DstFactorRgb := TBlendFactor(ASrc.dst_factor_rgb);
  OpRgb := TBlendOp(ASrc.op_rgb);
  SrcFactorAlpha := TBlendFactor(ASrc.src_factor_alpha);
  DstFactorAlpha := TBlendFactor(ASrc.dst_factor_alpha);
  OpAlpha := TBlendOp(ASrc.op_alpha);
end;

{ TColorTargetState }

procedure TColorTargetState.Convert(out ADst: _sg_color_target_state);
begin
  ADst.pixel_format := Ord(PixelFormat);
  ADst.write_mask := Ord(WriteMask);
  Blend.Convert(ADst.blend);
end;

constructor TColorTargetState.Create(const APixelFormat: TPixelFormat;
  const AWriteMask: TColorMask);
begin
  PixelFormat := APixelFormat;
  WriteMask := AWriteMask;
  FillChar(Blend, SizeOf(Blend), 0);
end;

procedure TColorTargetState.Init(const APixelFormat: TPixelFormat;
  const AWriteMask: TColorMask);
begin
  PixelFormat := APixelFormat;
  WriteMask := AWriteMask;
  FillChar(Blend, SizeOf(Blend), 0);
end;

procedure TColorTargetState.InitFrom(const ASrc: _sg_color_target_state);
begin
  PixelFormat := TPixelFormat(ASrc.pixel_format);
  WriteMask := TColorMask(ASrc.write_mask);
  Blend.InitFrom(ASrc.blend);
end;

{ TPipelineDesc }

procedure TPipelineDesc._Convert(out ADst: _sg_pipeline_desc);
begin
  FillChar(ADst, SizeOf(ADst), 0);
  ADst.shader.id := Shader.FHandle.id;
  Layout.Convert(ADst.layout);
  Depth.Convert(ADst.depth);
  Stencil.Convert(ADst.stencil);

  ADst.color_count := ColorCount;
  for var I := 0 to MAX_COLOR_ATTACHMENTS - 1 do
    Colors[I].Convert(ADst.colors[I]);

  ADst.primitive_type := Ord(PrimitiveType);
  ADst.index_type := Ord(IndexType);
  ADst.cull_mode := Ord(CullMode);
  ADst.face_winding := Ord(FaceWinding);
  ADst.sample_count := SampleCount;
  ADst.blend_color := _sg_color(BlendColor);
  ADst.alpha_to_coverage_enabled := AlphaToCoverageEnabled;
  if (TraceLabel <> '') then
    ADst.&label := PUTF8Char(TraceLabel);
end;

procedure TPipelineDesc._InitFrom(const ASrc: _sg_pipeline_desc);
begin
  Shader.FHandle.id := ASrc.shader.id;
  Layout.InitFrom(ASrc.layout);
  Depth.InitFrom(ASrc.depth);
  Stencil.InitFrom(ASrc.stencil);

  ColorCount := ASrc.color_count;
  for var I := 0 to MAX_COLOR_ATTACHMENTS - 1 do
    Colors[I].InitFrom(ASrc.colors[I]);

  PrimitiveType := TPrimitiveType(ASrc.primitive_type);
  IndexType := TIndexType(ASrc.index_type);
  CullMode := TCullMode(ASrc.cull_mode);
  FaceWinding := TFaceWinding(ASrc.face_winding);
  SampleCount := ASrc.sample_count;
  BlendColor := TColor(ASrc.blend_color);
  AlphaToCoverageEnabled := ASrc.alpha_to_coverage_enabled;
  TraceLabel := UTF8String(ASrc.&label);
end;

class function TPipelineDesc.Create: TPipelineDesc;
begin
  Result.Init;
end;

procedure TPipelineDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);

{  var Def: _sg_pipeline_desc;
  FillChar(Def, SizeOf(Def), 0);
  Def := _sg_query_pipeline_defaults(@Def);

  PrimitiveType := TPrimitiveType(Def.primitive_type);
  IndexType := TIndexType(Def.index_type);
  CullMode := TCullMode(Def.cull_mode);
  FaceWinding := TFaceWinding(Def.face_winding);
  SampleCount := Def.sample_count;

  Stencil.Front.Compare := TCompareFunc(Def.stencil.front.compare);
  Stencil.Front.FailOp := TStencilOp(Def.stencil.front.fail_op);
  Stencil.Front.DepthFailOp := TStencilOp(Def.stencil.front.depth_fail_op);
  Stencil.Front.PassOp := TStencilOp(Def.stencil.front.pass_op);

  Stencil.Back.Compare := TCompareFunc(Def.stencil.back.compare);
  Stencil.Back.FailOp := TStencilOp(Def.stencil.back.fail_op);
  Stencil.Back.DepthFailOp := TStencilOp(Def.stencil.back.depth_fail_op);
  Stencil.Back.PassOp := TStencilOp(Def.stencil.back.pass_op);

  Depth.Compare := TCompareFunc(Def.depth.compare);
  Depth.PixelFormat := TPixelFormat(Def.depth.pixel_format);
  ColorCount := Def.color_count;

  for var I := 0 to ColorCount - 1 do
  begin
    var Src: _Psg_color_state := @Def.colors[I];
    var Dst: PColorState := @Colors[I];

    Dst.PixelFormat := TPixelFormat(Src.pixel_format);
    Dst.WriteMask := TColorMask(Src.write_mask);

    var SrcBS: _Psg_blend_state := @Src.blend;
    var DstBS: PBlendState := @Dst.Blend;

    DstBS.SrcFactorRgb := TBlendFactor(SrcBS.src_factor_rgb);
    DstBS.DstFactorRgb := TBlendFactor(SrcBS.dst_factor_rgb);
    DstBS.OpRgb := TBlendOp(SrcBS.op_rgb);
    DstBS.SrcFactorAlpha := TBlendFactor(SrcBS.src_factor_alpha);
    DstBS.DstFactorAlpha := TBlendFactor(SrcBS.dst_factor_alpha);
    DstBS.OpAlpha := TBlendOp(SrcBS.op_alpha);
  end;

  for var I := 0 to MAX_SHADERSTAGE_BUFFERS - 1 do
  begin
    Layout.Buffers[I].Stride := Def.layout.buffers[I].stride;
    Layout.Buffers[I].StepFunc := TVertexStep(Def.layout.buffers[I].step_func);
    Layout.Buffers[I].StepRate := Def.layout.buffers[I].step_rate;
  end;

  for var I := 0 to MAX_VERTEX_ATTRIBUTES - 1 do
  begin
    Layout.Attrs[I].Offset := Def.layout.attrs[I].offset;
  end;}
end;

{ TD3D11PipelineInfo }

function TD3D11PipelineInfo.GetBlendState: IInterface;
begin
  Result := IInterface(FHandle.bs);
end;

function TD3D11PipelineInfo.GetDepthStencilState: IInterface;
begin
  Result := IInterface(FHandle.dss);
end;

function TD3D11PipelineInfo.GetInputLayout: IInterface;
begin
  Result := IInterface(FHandle.il);
end;

function TD3D11PipelineInfo.GetRasterizerState: IInterface;
begin
  Result := IInterface(FHandle.rs);
end;

{ TPipeline }

procedure TPipeline.Allocate;
begin
  FHandle := _sg_alloc_pipeline;
end;

constructor TPipeline.Create(const ADesc: TPipelineDesc);
begin
  Init(ADesc);
end;

procedure TPipeline.Deallocate;
begin
  _sg_dealloc_pipeline(FHandle);
end;

procedure TPipeline.Fail;
begin
  _sg_fail_pipeline(FHandle);
end;

procedure TPipeline.Free;
begin
  _sg_destroy_pipeline(FHandle);
  FHandle.id := 0;
end;

function TPipeline.GetD3D11PipelineInfo: TD3D11PipelineInfo;
begin
  Result.FHandle := _sg_d3d11_query_pipeline_info(FHandle);
end;

function TPipeline.GetDesc: TPipelineDesc;
begin
  Result._InitFrom(_sg_query_pipeline_desc(FHandle));
end;

function TPipeline.GetInfo: TPipelineInfo;
begin
  Result.FHandle := _sg_query_pipeline_info(FHandle);
end;

function TPipeline.GetMetalPipelineInfo: TMetalPipelineInfo;
begin
  Result.FHandle := _sg_mtl_query_pipeline_info(FHandle);
end;

function TPipeline.GetState: TResourceState;
begin
  Result := TResourceState(_sg_query_pipeline_state(FHandle));
end;

procedure TPipeline.Init(const ADesc: TPipelineDesc);
begin
  var Desc: _sg_pipeline_desc;
  ADesc._Convert(Desc);
  FHandle := _sg_make_pipeline(@Desc);
end;

procedure TPipeline.Setup(const ADesc: TPipelineDesc);
begin
  var Desc: _sg_pipeline_desc;
  ADesc._Convert(Desc);
  _sg_init_pipeline(FHandle, @Desc);
end;

procedure TPipeline.Teardown;
begin
  _sg_uninit_pipeline(FHandle);
end;

{ TPass }

class function TPass.Create: TPass;
begin
  Result.Init;
end;

function TPass.GetAction: PPassAction;
begin
  Result := @FHandle.action;
end;

function TPass.GetAttachments: PAttachments;
begin
  Result := @FHandle.attachments;
end;

function TPass.GetSwapchain: PSwapchain;
begin
  Result := @FHandle.swapchain;
end;

procedure TPass.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TPass.SetTraceLabel(const AValue: UTF8String);
begin
  FTraceLabel := AValue;
  if (AValue = '') then
    FHandle.&label := nil
  else
    FHandle.&label := PUTF8Char(TraceLabel);
end;

{ TBindings }

class function TBindings.Create: TBindings;
begin
  Result.Init;
end;

function TBindings.GetIndexBuffer: TBuffer;
begin
  Result := TBuffer(FHandle.index_buffer);
end;

function TBindings.GetSampler(const AIndex: Integer): TSampler;
begin
  Assert(Cardinal(AIndex) < MAX_SAMPLER_BINDSLOTS);
  Result.FHandle := FHandle.samplers[AIndex];
end;

function TBindings.GetVertexBuffer(const AIndex: Integer): TBuffer;
begin
  Assert(Cardinal(AIndex) < MAX_VERTEXBUFFER_BINDSLOTS);
  Result := TBuffer(FHandle.vertex_buffers[AIndex]);
end;

function TBindings.GetVertexBufferOffset(const AIndex: Integer): Integer;
begin
  Assert(Cardinal(AIndex) < MAX_VERTEXBUFFER_BINDSLOTS);
  Result := FHandle.vertex_buffer_offsets[AIndex];
end;

function TBindings.GetView(const AIndex: Integer): TView;
begin
  Assert(Cardinal(AIndex) < MAX_VIEW_BINDSLOTS);
  Result.FHandle := FHandle.views[AIndex];
end;

procedure TBindings.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TBindings.SetIndexBuffer(const AValue: TBuffer);
begin
  FHandle.index_buffer := _sg_buffer(AValue);
end;

procedure TBindings.SetSampler(const AIndex: Integer; const AValue: TSampler);
begin
  Assert(Cardinal(AIndex) < MAX_SAMPLER_BINDSLOTS);
  FHandle.samplers[AIndex] := AValue.FHandle;
end;

procedure TBindings.SetVertexBuffer(const AIndex: Integer;
  const AValue: TBuffer);
begin
  Assert(Cardinal(AIndex) < MAX_VERTEXBUFFER_BINDSLOTS);
  FHandle.vertex_buffers[AIndex] := _sg_buffer(AValue);
end;

procedure TBindings.SetVertexBufferOffset(const AIndex, AValue: Integer);
begin
  Assert(Cardinal(AIndex) < MAX_VERTEXBUFFER_BINDSLOTS);
  FHandle.vertex_buffer_offsets[AIndex] := AValue;
end;

procedure TBindings.SetView(const AIndex: Integer; const AValue: TView);
begin
  Assert(Cardinal(AIndex) < MAX_VIEW_BINDSLOTS);
  FHandle.views[AIndex] := AValue.FHandle;
end;

{ TSlotInfo }

function TSlotInfo.GetState: TResourceState;
begin
  Result := TResourceState(FHandle.state);
end;

{ TBufferInfo }

function TBufferInfo.GetSlot: TSlotInfo;
begin
  Result.FHandle := FHandle.slot;
end;

{ TImageInfo }

function TImageInfo.GetSlot: TSlotInfo;
begin
  Result.FHandle := FHandle.slot;
end;

{ TSamplerInfo }

function TSamplerInfo.GetSlot: TSlotInfo;
begin
  Result.FHandle := FHandle.slot;
end;

{ TShaderInfo }

function TShaderInfo.GetSlot: TSlotInfo;
begin
  Result.FHandle := FHandle.slot;
end;

{ TPipelineInfo }

function TPipelineInfo.GetSlot: TSlotInfo;
begin
  Result.FHandle := FHandle.slot;
end;

{ TViewInfo }

function TViewInfo.GetSlot: TSlotInfo;
begin
  Result.FHandle := FHandle.slot;
end;

{ TFrameStatsD3D11 }

function TFrameStatsD3D11.GetBindings: PFrameStatsD3D11Bindings;
begin
  Result := @FHandle.bindings;
end;

function TFrameStatsD3D11.GetDraw: PFrameStatsD3D11Draw;
begin
  Result := @FHandle.draw;
end;

function TFrameStatsD3D11.GetPass: PFrameStatsD3D11Pass;
begin
  Result := @FHandle.pass;
end;

function TFrameStatsD3D11.GetPipeline: PFrameStatsD3D11Pass;
begin
  Result := @FHandle.pipeline;
end;

function TFrameStatsD3D11.GetUniforms: PFrameStatsD3D11Uniforms;
begin
  Result := @FHandle.uniforms;
end;

{ TFrameStatsMetal }

function TFrameStatsMetal.GetBindings: PFrameStatsMetalBindings;
begin
  Result := @FHandle.bindings;
end;

function TFrameStatsMetal.GetIdPool: PFrameStatsMetalIdPool;
begin
  Result := @FHandle.idpool;
end;

function TFrameStatsMetal.GetPipeline: PFrameStatsMetalPipeline;
begin
  Result := @FHandle.pipeline;
end;

function TFrameStatsMetal.GetUniforms: PFrameStatsMetalUniforms;
begin
  Result := @FHandle.uniforms;
end;

{ TTotalStats }

function TTotalStats.GetBuffers: PTotalResourceStats;
begin
  Result := @FHandle.buffers;
end;

function TTotalStats.GetImages: PTotalResourceStats;
begin
  Result := @FHandle.images;
end;

function TTotalStats.GetPipelines: PTotalResourceStats;
begin
  Result := @FHandle.pipelines;
end;

function TTotalStats.GetSamplers: PTotalResourceStats;
begin
  Result := @FHandle.samplers;
end;

function TTotalStats.GetShaders: PTotalResourceStats;
begin
  Result := @FHandle.shaders;
end;

function TTotalStats.GetViews: PTotalResourceStats;
begin
  Result := @FHandle.views;
end;

{ TFrameStats }

function TFrameStats.GetBuffers: PFrameResourceStats;
begin
  Result := @FHandle.buffers;
end;

function TFrameStats.GetD3D11: PFrameStatsD3D11;
begin
  Result := @FHandle.d3d11;
end;

function TFrameStats.GetGL: PFrameStatsGL;
begin
  Result := @FHandle.gl;
end;

function TFrameStats.GetImages: PFrameResourceStats;
begin
  Result := @FHandle.images;
end;

function TFrameStats.GetMetal: PFrameStatsMetal;
begin
  Result := @FHandle.metal;
end;

function TFrameStats.GetPipelines: PFrameResourceStats;
begin
  Result := @FHandle.pipelines;
end;

function TFrameStats.GetSamplers: PFrameResourceStats;
begin
  Result := @FHandle.samplers;
end;

function TFrameStats.GetShaders: PFrameResourceStats;
begin
  Result := @FHandle.shaders;
end;

function TFrameStats.GetViews: PFrameResourceStats;
begin
  Result := @FHandle.views;
end;

function TFrameStats.GetVulkan: PFrameStatsVulkan;
begin
  Result := @FHandle.vk;
end;

{ _TGfxLogItemHelper }

function _TGfxLogItemHelper.ToString: String;
const
  STRINGS: array [TGfxLogItem] of String = (
    'Ok',
    'memory allocation failed',
    'pixel format not supported for texture (GL)',
    '3d textures not supported (GL)',
    'array textures not supported (GL)',
    'GLSL storage buffer bindslot is out of range (TLimits.MaxStorageBufferBindingsPerStage) (GL)',
    'GLSL storage image bindslot is out of range (TLimits.MaxStorageImageBindingsPerStage) (GL)',
    'shader compilation failed (GL)',
    'shader linking failed (GL)',
    'vertex attribute not found in shader; NOTE: may be caused by GL driver''s GLSL compiler removing unused globals',
    'uniform block name not found in shader; NOTE: may be caused by GL driver''s GLSL compiler removing unused globals',
    'image-sampler name not found in shader; NOTE: may be caused by GL driver''s GLSL compiler removing unused globals',
    'framebuffer completeness check failed with GL_FRAMEBUFFER_UNDEFINED (GL)',
    'framebuffer completeness check failed with GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT (GL)',
    'framebuffer completeness check failed with GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT (GL)',
    'framebuffer completeness check failed with GL_FRAMEBUFFER_UNSUPPORTED (GL)',
    'framebuffer completeness check failed with GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE (GL)',
    'framebuffer completeness check failed (unknown reason) (GL)',
    'D3D11 Feature Level 0 device detected, this restricts the number of UAV slots to 8! (D3D11)',
    'CreateBuffer() failed (D3D11)',
    'CreateShaderResourceView() failed for storage buffer (D3D11)',
    'CreateUnorderedAccessView() failed for storage buffer (D3D11)',
    'pixel format not supported for depth-stencil texture (D3D11)',
    'CreateTexture2D() failed for depth-stencil texture (D3D11)',
    'pixel format not supported for 2d-, cube- or array-texture (D3D11)',
    'CreateTexture2D() failed for 2d-, cube- or array-texture (D3D11)',
    'CreateShaderResourceView() failed for 2d-, cube- or array-texture (D3D11)',
    'pixel format not supported for 3D texture (D3D11)',
    'CreateTexture3D() failed (D3D11)',
    'CreateShaderResourceView() failed for 3d texture (D3D11)',
    'CreateTexture2D() failed for MSAA render target texture (D3D11)',
    'CreateSamplerState() failed (D3D11)',
    'TShaderDesc.UniformBlocks[].HlslRegisterBN is out of range (must be 0..7)',
    'TShaderDesc.Views[].StorageBuffer.HlslRegisterTN is out of range (must be 0..31)',
    'TShaderDesc.Views[].StorageBuffer.HlslRegisterUN is out of range (must be 0..31)',
    'TShaderDesc.Views[].Texture.HlslRegisterTN is out of range (must be 0..31)',
    'TShaderDesc.Views[].StorageImage.HlslRegisterUN is out of range (must be 0..31)',
    'sampler ''HlslRegisterSN'' is out of rang (must be 0..11)',
    'loading d3dcompiler_47.dll failed (D3D11)',
    'shader compilation failed (D3D11)',
    '',
    'CreateBuffer() failed for uniform constant buffer (D3D11)',
    'CreateInputLayout() failed (D3D11)',
    'CreateRasterizerState() failed (D3D11)',
    'CreateDepthStencilState() failed (D3D11)',
    'CreateBlendState() failed (D3D11)',
    'CreateRenderTargetView() failed (D3D11)',
    'CreateDepthStencilView() failed (D3D11)',
    'CreateUnorderedAccessView() failed (D3D11)',
    'Map() failed when updating buffer (D3D11)',
    'Map() failed when appending to buffer (D3D11)',
    'Map() failed when updating image (D3D11)',
    'failed to create buffer object (Metal)',
    'pixel format not supported for texture (Metal)',
    'failed to create texture object (Metal)',
    'failed to create sampler object (Metal)',
    'shader compilation failed (Metal)',
    'shader creation failed (Metal)',
    '',
    'shader entry function not found (Metal)',
    'uniform block ''MslBufferN'' is out of range (must be 0..7)',
    'storage buffer ''MslBufferN'' is out of range (must be 8..23)',
    'storage image ''MslTextureN'' is out of range (must be 0..31)',
    'image ''MslTextureN'' is out of range (must be 0..31)',
    'sampler ''MslSamplerN'' is out of range (must be 0..11)',
    'failed to create compute pipeline state (Metal)',
    '',
    'failed to create render pipeline state (Metal)',
    '',
    'failed to create depth stencil state (Metal)',
    'bindgroups pool exhausted (increase TGfxDesc.bindgroups_cache_size) (Wgpu)',
    'TGfxDesc.Wgpu.BindgroupsCacheSize must be > 1 (Wgpu)',
    'TGfxDesc.Wgpu.BindgroupsCacheSize must be a power of 2 (Wgpu)',
    'wgpuDeviceCreateBindGroup failed',
    'wgpuDeviceCreateBuffer() failed',
    'wgpuDeviceCreateTexture() failed',
    'wgpuTextureCreateView() failed',
    'wgpuDeviceCreateSampler() failed',
    'wgpuDeviceCreateShaderModule() failed',
    'wgpuDeviceCreateBindGroupLayout() for shader stage failed',
    'uniform block ''WgslGroup0BindingN'' is out of range (must be 0..15)',
    'texture ''WgslGroup1BindingN'' is out of range (must be 0..127)',
    'storage buffer ''WgslGroup1BindingN'' is out of range (must be 0..127)',
    'storage image ''WgslGroup1BindingN'' is out of range (must be 0..127)',
    'sampler ''WgslGroup1BindingN'' is out of range (must be 0..127)',
    'wgpuDeviceCreatePipelineLayout() failed',
    'wgpuDeviceCreateRenderPipeline() failed',
    'wgpuDeviceCreateComputePipeline() failed',
    'vulkan: could not look up a required extension function pointer',
    'vulkan: could not find suitable memory type',
    'vulkan: vkAllocateMemory() failed!',
    'vulkan: allocating buffer device memory failed',
    'vulkan: allocating image device memory failed',
    'vulkan: internal delete queue exhausted (too many objects destroyed per frame)',
    'vulkan: vkCreateBuffer() failed for staging buffer',
    'vulkan: allocating device memory for staging buffer failed',
    'vulkan: vkBindBufferMemory() failed for staging buffer',
    'vulkan: per-frame stream staging buffer has overflown (TGfxDesc.Vulkan.StreamStagingBufferSize)',
    'vulkan: vkCreateBuffer() failed for cpu/gpu-shared buffer',
    'vulkan: allocating device memory for cpu/gpu-shared buffer failed',
    'vulkan: vkBindBufferMemory() failed for cpu/gpu-shared buffer',
    'vulkan: vkMapMemory() failed on cpu/gpu-shared buffer',
    'vulkan: vkCreateBuffer() failed!',
    'vulkan: vkBindBufferMemory() failed!',
    'vulkan: vkCreateImage() failed!',
    'vulkan: vkBindImageMemory() failed!',
    'vukan: vkCreateShaderModule() failed!',
    'vulkan: uniform block ''SpirvSet0BindingN'' is out of range (must be 0..15)',
    'vulkan: texture ''SpirvSet1BindingN'' is out of range (must be 0..127)',
    'vulkan: storage buffer ''SpirvSet1BindingN'' is out of range (must be 0..127)',
    'vulkan: storage image ''SpirvSet1BindingN'' is out of range (must be 0..127)',
    'vulkan: sampler ''SpirvSet1BindingN'' is out of range (must be 0..127)',
    'vulkan: vkCreateDescriptorSetLayout() failed!',
    'vulkan: shader uniform descriptor set is too big for the descriptor set cache (please write a Github issue)',
    'vulkan: vkCreatePipelineLayout() failed!',
    'vulkan: vkCreateGraphicsPipelines() failed!',
    'vulkan: vkCreateComputePipelines() failed!',
    'vulkan: vkCreateImageView() failed!',
    'vulkan: required view descriptor size is greater than VK_MAX_DESCRIPTOR_DATA_SIZE',
    'vulkan: vkCreateSampler() failed!',
    'vulkan: required sampler descriptor size is greater than VK_MAX_DESCRIPTOR_DATA_SIZE',
    'vulkan: vkWaitForFence() failed!',
    'vulkan: uniform buffer has overflown (increase TGfxDesc.UniformBufferSize)',
    'vulkan: descriptor buffer has overflown (increase TGfxDesc.Vulkan.DescriptorBufferSize)',
    'attempting to add identical commit listener',
    'commit listener array full',
    'TGfx.InstallTraceHooks called, but SOKOL_TRACE_HOOKS is not defined',
    'TBuffer.Deallocate(): buffer must be in ALLOC state',
    'TImage.Deallocate(): image must be in alloc state',
    'TSampler.Deallocate(): sampler must be in alloc state',
    'TShader.Deallocate(): shader must be in ALLOC state',
    'TPipeline.Deallocate(): pipeline must be in ALLOC state',
    'TView.Deallocate(): view must be in ALLOC state',
    'TBuffer.Setup(): buffer must be in ALLOC state',
    'TImage.Setup(): image must be in ALLOC state',
    'TSampler.Setup(): sampler must be in ALLOC state',
    'TShader.Setup(): shader must be in ALLOC state',
    'TPipeline.Setup(): pipeline must be in ALLOC state',
    'TView.Setup(): view must be in ALLOC state',
    'TBuffer.Teardown(): buffer must be in VALID, FAILED or ALLOC state',
    'TImage.Teardown(): image must be in VALID, FAILED or ALLOC state',
    'TSampler.Teardown(): sampler must be in VALID, FAILED or ALLOC state',
    'TShader.Teardown(): shader must be in VALID, FAILED or ALLOC state',
    'TPipeline.Teardown(): pipeline must be in VALID, FAILED or ALLOC state',
    'TView.Teardown(): view must be in VALID, FAILED or ALLOC state',
    'TBuffer.Fail(): buffer must be in ALLOC state',
    'TImage.Fail(): image must be in ALLOC state',
    'TSampler.Fail(): sampler must be in ALLOC state',
    'TShader.Fail(): shader must be in ALLOC state',
    'TPipeline.Fail(): pipeline must be in ALLOC state',
    'TView.Fail(): view must be in ALLOC state',
    'buffer pool exhausted',
    'image pool exhausted',
    'sampler pool exhausted',
    'shader pool exhausted',
    'pipeline pool exhausted',
    'view pool exhausted',
    'TGfx.BeginPass: too many color attachments (TLimits.MaxColorAttachments)',
    'TGfx.BeginPass: too many resolve attachments (TLimits.MaxColorAttachments)',
    'TGfx.BeginPass: an attachment was provided that no longer exists',
    'attempting to draw without resource bindings',
    'TShaderDesc: too many texture bindings on vertex shader stage (TLimits.MaxTextureBindingsPerStage)',
    'TShaderDesc: too many texture bindings on fragment shader stage (TLimits.MaxTextureBindingsPerStage)',
    'TShaderDesc: too many texture bindings on compute shader stage (TLimits.MaxTextureBindingsPerStage)',
    'TShaderDesc: too many storage buffer bindings on vertex shader stage (TLimits.MaxStorageBufferBindingsPerStage)',
    'TShaderDesc: too many storage buffer bindings on fragment shader stage (TLimits.MaxStorageBufferBindingsPerStage)',
    'TShaderDesc: too many storage buffer bindings on compute shader stage (TLimits.MaxStorageBufferBindingsPerStage)',
    'TShaderDesc: too many storage image bindings on vertex shader stage (TLimits.MaxStorageImageBindingsPerStage)',
    'TShaderDesc: too many storage image bindings on fragment shader stage (TLimits.MaxStorageImageBindingsPerStage)',
    'TShaderDesc: too many storage image bindings on compute shader stage (TLimits.MaxStorageImageBindingsPerStage)',
    'TShaderDesc: too many texture-sampler-pairs on vertex shader stage (TLimits.MaxTextureBindingsPerStage)',
    'TShaderDesc: too many texture-sampler-pairs on fragment shader stage (TLimits.MaxTextureBindingsPerStage)',
    'TShaderDesc: too many texture-sampler-pairs on compute shader stage (TLimits.MaxTextureBindingsPerStage)',
    'TBufferDesc not initialized',
    'TBufferDesc.Usage: only one of .Immutable, .DynamicUpdate, .StreamUpdate can be True',
    'TBufferDesc.Usage: on WebGL2, only one of .VertexBuffer or .IndexBuffer can be True (check TFeatures.SeparateBufferTypes)',
    'TBufferDesc.Size must be greater zero',
    'TBufferDesc.Size and .Data.Size must be equal',
    'TBufferDesc.Data.Size expected to be zero',
    'TBufferDesc.Data.Ptr must be nil for dynamic/stream buffers',
    'TBufferDesc: initial content data must be provided for immutable buffers without storage buffer usage',
    'storage buffers not supported by the backend 3D API (requires OpenGL >= 4.3)',
    'size of storage buffers must be a multiple of 4',
    'TImageData: no data (.Ptr and/or .Size is zero)',
    'TImageData: data size doesn''t match expected surface size',
    'TImageDesc not initialized',
    'TImageDesc.Usage: only one of .Immutable, .DynamicUpdate, .StreamUpdate can be True',
    'TImageDesc.Usage: only one of .ColorAttachment and .DepthStencilAttachment can be True',
    'TImageDesc.NumSlices must be exactly 1 for TImageType.TwoD',
    'TImageDesc.NumSlices must be exactly 6 for TImageType.Cube',
    'TImageDesc.NumSlices must be ((>= 1) and (<= TLimits.MaxImageArrayLayers)) for TImageType.Array',
    'TImageDesc.NumSlices must be ((>= 1) and (<= TLimits.MaxImageSize3D)) for TImageType.Array',
    'TImageDesc.NumSlices must be > 0',
    'TImageDesc.Width must be > 0',
    'TImageDesc.Height must be > 0',
    'invalid pixel format for non-render-target image',
    'non-attachment images cannot be multisampled',
    '3D images cannot have a depth/stencil image format',
    'attachment and storage images must be TImageUsage.Immutable',
    'render/storage attachment images cannot be initialized with data',
    'invalid pixel format for render attachment image',
    'resolve attachment images cannot be multisampled',
    'multisampling not supported for this pixel format',
    'multisample images must have NumMipmaps = 1',
    '3D images cannot have a SampleCount > 1',
    'cube images cannot have SampleCount > 1',
    'array images cannot have SampleCount > 1',
    'invalid pixel format for storage image',
    'storage images cannot be multisampled',
    'images with injected textures cannot be initialized with data',
    'dynamic/stream-update images cannot be initialized with data',
    'compressed images must be immutable',
    'TSamplerDesc not initialized',
    'TSamplerDesc.MaxAnisotropy > 1 requires min/mag/mipmap_filter to be TFilter.Linear',
    'TShaderDesc not initialized',
    'vertex shader source code expected',
    'fragment shader source code expected',
    'compute shader source code expected',
    'vertex shader source or byte code expected',
    'fragment shader source or byte code expected',
    'compute shader source or byte code expected',
    'cannot combine compute shaders with vertex or fragment shaders',
    'shader byte code length (in bytes) required',
    'TShaderDesc.MtlThreadsPerThreadgroup must be initialized for compute shaders (Metal)',
    'TShaderDesc.MtlThreadsPerThreadgroup (X * Y * Z) must be a multiple of 32 (Metal)',
    'TShaderDesc.UniformBlocks[].GlslUniforms[]: items must occupy continuous slots',
    'TShaderDesc.UniformBlocks[].Size cannot be zero',
    'TShaderDesc.UniformBlocks[].MslBufferN must be unique across uniform blocks and storage buffers in same shader stage',
    'TShaderDesc.UniformBlocks[].HlslRegisterBN must be unique across uniform blocks in same shader stage',
    'TShaderDesc.UniformBlocks[].WgslGroup0BindingN must be unique across all uniform blocks',
    'TShaderDesc.UniformBlocks[].SpirvSet0BindingN must be unique across all uniform blocks',
    'TShaderDesc.UniformBlocks[].GlslUniforms[]: GL backend requires uniform block member declarations',
    'TShaderDesc.UniformBlocks[].GlslUniforms[].GlslName missing',
    'TShaderDesc.UniformBlocks[].GlslUniforms[]: size of uniform block members doesn''t match uniform block size',
    'TShaderDesc.UniformBlocks[].GlslUniforms[].ArrayCount must be >= 1',
    'TShaderDesc.UniformBlocks[].GlslUniforms[].UniformType: uniform arrays only allowed for Float4, Int4, Mat4 in Std140 layout',
    'TShaderDesc.Views[].StorageBuffer.StoragemslBufferN must be unique across uniform blocks and storage buffer in same shader stage',
    'TShaderDesc.Views[].StorageBuffer.HlslRegisterTN must be unique across read-only storage buffers and images in same shader stage',
    'TShaderDesc.Views[].StorageBuffer.HlslRegisterUN must be unique across read/write storage buffers and storage images in same shader stage',
    'TShaderDesc.Views[].StorageBuffer.GlslBindingN must be unique across shader stages',
    'TShaderDesc.Views[].StorageBuffer.WgslGroup1BindingN must be unique across all view and sampler bindings',
    'TShaderDesc.Views[].StorageBuffer.SpirvSet1BindingN must be unique across all view and sampler bindings',
    'TShaderDesc.Views[].StorageImage: storage images are allowed on the compute stage',
    'TShaderDesc.Views[].StorageImage.MslTextureN must be unique across images and storage images in same shader stage',
    'TShaderDesc.Views[].StorageImage.HlslRegisterUN must be unique across storage images and read/write storage buffers in same shader stage',
    'TShaderDesc.Views[].StorageImage.GlslBindingN must be unique across shader stages',
    'TShaderDesc.Views[].StorageImage.WgslGroup1BindingN must be unique across all view and sampler bindings',
    'TShaderDesc.Views[].StorageImage.SpirvSet1BindingN must be unique across all view and sampler bindings',
    'TShaderDesc.Views[].Texture.MslTextureN must be unique across textures and storage images in same shader stage',
    'TShaderDesc.Views[].Texture.HlslRegisterTN must be unique across textures and storage buffers in same shader stage',
    'TShaderDesc.Views[].Texture.WgslGroup1BindingN must be unique across all view and sampler bindings',
    'TShaderDesc.Views[].Texture.SpirvSet1BindingN must be unique across all view and sampler bindings',
    'TShaderDesc.Samplers[].MslSamplerN must be unique in same shader stage',
    'TShaderDesc.Samplers[].HlslRegisterSN must be unique in same shader stage',
    'TShaderDesc.Samplers[].WgslGroup1BindingN must be unique across all view and sampler bindings',
    'TShaderDesc.Samplers[].SpirvSet1BindingN must be unique across all view and sampler bindings',
    'texture-sampler-pair view slot index is out of range (TShaderDesc.TextureSamplerPairs[].ViewSlot)',
    'texture-sampler-pair sampler slot index is out of range (TShaderDesc.TextureSamplerPairs[].SamplerSlot)',
    'texture-sampler-pair stage doesn''t match referenced texture stage',
    'texture-sampler-pair view must be a texture view (TShaderDesc.TextureSamplerPairs[].ViewSlot => TShaderDesc.Views[i].Texture)',
    'texture-sampler-pair stage doesn''t match referenced sampler stage',
    'texture-sampler-pair ''GlslName'' missing',
    'image sample type UnfilterableFloat, UnsignedInt, SignedInt can only be used with NonFiltering sampler',
    'image sample type Depth can only be used with Comparison sampler',
    'one or more texture views are not referenced by by texture-sampler-pairs (TShaderDesc.TextureSamplerPairs[].ViewSlot)',
    'one or more samplers are not referenced by texture-sampler-pairs (TShaderDesc.TextureSamplerPairs[].SamplerSlot)',
    'vertex attribute name/semantic string too long (max len 16)',
    'TPipelineDesc not initialized',
    'TPipelineDesc.Shader missing or invalid',
    'TPipelineDesc.Shader must be a compute shader',
    'TPipelineDesc.Compute is False, but shader is a compute shader',
    'TPipelineDesc.Layout.Attrs is not continuous',
    'TPipelineDesc.Layout.Attrs[].Format is incompatible with TShaderDesc.Attrs[].BaseType',
    'TPipelineDesc.Layout.Attrs[].Format: TVertexFormat.Int10N2 not supported on this platform',
    'TPipelineDesc.Layout.Buffers[].Stride must be multiple of 4',
    'D3D11 missing vertex attribute semantics in shader',
    'TPipelineDesc.Shader: only readonly storage buffer bindings allowed in render pipelines',
    'TBlendOp.Min/Max requires all blend factors to be TBlendFactor.One',
    'dual source blending not supported (TFeatures.DualSourceBlending)',
    'TPipelineDesc.Depth.Write_enabled cannot be True when TPipelineDesc.Depth.PixelFormat is TPixelFormat.None',
    'TPipelineDesc.Depth.Compare must be TCompareFunc.Always or TCompareFunc.Never when TPipelineDesc.PixelFormat is TPixelFormat.None',
    'TViewDesc not initialized',
    'TViewDesc: only one view type can be active',
    'TViewDesc: exactly one view type must be active',
    'TViewDesc: resource object is no longer alive (.Buffer or .Image)',
    'TViewDesc: resource object cannot be in FAILED state (.Buffer or .Image)',
    'TViewDesc.StorageBuffer.Offset is >= buffer size',
    'TViewDesc.StorageBuffer.Offset must be a multiple of 256',
    'TViewDesc.StorageBuffer.Buffer must have been created with TBufferDesc.Usage.StorageBuffer = True',
    'TViewDesc.StorageImage.Image must have been created with TImageDesc.Usage.StorageImage = True',
    'TViewDesc.ColorAttachment.Image must have been created with TImageDesc.Usage.ColorAttachment = True',
    'TViewDesc.ResolveAttachment.Image must have been created with TImageDesc.Usage.ResolveAttachment = True',
    'TViewDesc.DepthStencilAttachment.image must have been created with TImageDesc.Usage.DepthStencilAttachment = True',
    'TViewDesc: image/attachment view mip level is out of range (must be >=0 and <Image.NumMiplevels)',
    'TViewDesc: image/attachment view slice is out of range for 2D image (must be 0)',
    'TViewDesc: image/attachment view slice is out of range for cubemap image (must be >=0 and <6)',
    'TViewDesc: image/attachment view slice is out of range for 2D array image (must be >=0 and <Image.NumSlices)',
    'TViewDesc: image/attachment view slice is out of range for 3D image (must be 0)',
    'TViewDesc: MSAA texture bindings not allowed on this backend (TFeatures.MsaaTextureBindings)',
    'TViewDesc: texture view mip levels are out of range (must be >=0 and <Image.NumMiplevels)',
    'TViewDesc: texture view slices are out of range for 2D image (must be 0)',
    'TViewDesc: texture view slices are out of range for cubemap image (must be 0)',
    'TViewDesc: texture view slices are out of range for 2D array image (must be >=0 and <Image.NumSlices)',
    'TViewDesc: texture view slices are out of range for 3D image (must be 0)',
    'TViewDesc.StorageImageBinding: image pixel format must be GPU readable or writable (TPixelFormat.CanRead/CanWrite)',
    'TViewDesc.ColorAttachment: pixel format of image must be renderable (TPixelFormat.Render)',
    'TViewDesc.DepthStencilAttachment: pixel format of image must be a depth or depth-stencil format (TPixelFormat.Depth)',
    'TViewDesc.ResolveAttachment: image cannot be multisampled',
    'TGfx.BeginPass: pass struct not initialized',
    'TGfx.BeginPass: compute passes cannot have attachments',
    'TGfx.BeginPass: expected Pass.Swapchain.Width > 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Width = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Height > 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Height = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.SampleCount > 0',
    'TGfx.BeginPass: expected Pass.Swapchain.SampleCount = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.ColorFormat to be valid',
    'TGfx.BeginPass: expected Pass.Swapchain.ColorFormat to be unset',
    'TGfx.BeginPass: expected Pass.Swapchain.DepthFormat to be unset',
    'TGfx.BeginPass: expected Pass.Swapchain.Metal.CurrentDrawable <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Metal.CurrentDrawable = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Metal.DepthStencilTexture <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Metal.DepthStencilTexture = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Metal.MsaaColorTexture <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Metal.MsaaColorTexture = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.D3D11.RenderView <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.D3D11.RenderView = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.D3D11.ResolveView <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.D3D11.ResolveView = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.D3D11.DepthStencilView <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.D3D11.DepthStencilView = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Wgpu.RenderView <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Wgpu.RenderView = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Wgpu.ResolveView <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Wgpu.ResolveView = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Wgpu.DepthStencilView <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Wgpu.DepthStencilView = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.GL.Framebuffer = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Vulkan.RenderImage <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Vulkan.RenderImage = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Vulkan.RenderView <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Vulkan.RenderView = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Vulkan.DepthStencilImage <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Vulkan.DepthStencilImage = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Vulkan.DepthStencilView <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Vulkan.DepthStencilView = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Vulkan.ResolveImage <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Vulkan.ResolveImage = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Vulkan.ResolveView <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Vulkan.ResolveView = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Vulkan.RenderFinishedSemaphore <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Vulkan.RenderFinishedSemaphore = 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Vulkan.PresentCompleteSemaphore <> 0',
    'TGfx.BeginPass: expected Pass.Swapchain.Vulkan.PresentCompleteSemaphore = 0',
    'TGfx.BeginPass: color attachment view array must be continuous',
    'TGfx.BeginPass: color attachment view no longer alive',
    'TGfx.BeginPass: color attachment view not in valid state (TResourceState.Valid)',
    'TGfx.BeginPass: color attachment view has wrong type (must be TViewDesc.ColorAttachment)',
    'TGfx.BeginPass: color attachment view''s image object is uninitialized or no longer alive',
    'TGfx.BeginPass: color attachment view''s image is not in valid state (TResourceState.Valid)',
    'TGfx.BeginPass: all color attachments must have the same width and height',
    'TGfx.BeginPass: when resolve attachments are provided, the color attachment sample count must be > 1',
    'TGfx.BeginPass: all color attachments must have the same sample count',
    'TGfx.BeginPass: a resolve attachment view must have an associated color attachment view at the same index',
    'TGfx.BeginPass: resolve attachment view no longer alive',
    'TGfx.BeginPass: resolve attachment view not in valid state (TResourceState.Valid)',
    'TGfx.BeginPass: resolve attachment view has wrong type (must be TViewDesc.ResolveAttachment)',
    'TGfx.BeginPass: resolve attachment view''s image object is uninitialized or no longer alive',
    'TGfx.BeginPass: resolve attachment view''s image is not in valid state (TResourceState.Valid)',
    'TGfx.BeginPass: all attachments must have the same width and height',
    'TGfx.BeginPass: color attachment view array must be continuous',
    'TGfx.BeginPass: depth-stencil attachment view no longer alive',
    'TGfx.BeginPass: depth-stencil attachment view not in valid state (TResourceState.Valid)',
    'TGfx.BeginPass: depth-stencil attachment view has wrong type (must be TViewDesc.DepthStencilAttachment)',
    'TGfx.BeginPass: depth-stencil attachment view''s image object is uninitialized or no longer alive',
    'TGfx.BeginPass: depth-stencil attachment view''s image is not in valid state (TResourceState.Valid)',
    'TGfx.BeginPass: attachments must have the same width and height',
    'TGfx.BeginPass: all color attachments must have the same sample count',
    'TGfx.BeginPass: offscreen render passes must have at least one color- or depth-stencil attachment',
    'TGfx.ApplyViewport: must be called in a render pass',
    'TGfx.ApplyScissorRect: must be called in a render pass',
    'TGfx.ApplyPipeline: invalid pipeline id provided',
    'TGfx.ApplyPipeline pipeline object no longer alive',
    'TGfx.ApplyPipeline pipeline object not in valid state (TResourceState.Valid)',
    'TGfx.ApplyPipeline must be called in a pass',
    'TGfx.ApplyPipeline shader object associated with pipeline no longer alive',
    'TGfx.ApplyPipeline shader object associated with pipeline not in valid state',
    'TGfx.ApplyPipeline trying to apply compute pipeline in render pass',
    'TGfx.ApplyPipeline trying to apply render pipeline in compute pass',
    'TGfx.ApplyPipeline the pipeline .ColorCcount must be 1 in swapchain render passes',
    'TGfx.ApplyPipeline the pipeline .Colors[0].PixelFormat doesn''t match the TPass.Swapchain.ColorFormat',
    'TGfx.ApplyPipeline the pipeline .Depth.PixelFormat doesn''t match the TPass.Swapchain.DepthFormat',
    'TGfx.ApplyPipeline the pipeline .SampleCount doesn''t match the TPass.Swapchain.SampleCount',
    'TGfx.ApplyPipeline at least one pass attachment view or base image object is no longer alive',
    'TGfx.ApplyPipeline the pipeline .ColorCount doesn''t match the number of render pass color attachments',
    'TGfx.ApplyPipeline a pass color attachment view is not in valid state (TResourceState.Valid)',
    'TGfx.ApplyPipeline a pass color attachment view''s image object is not in valid state (TResourceState.Valid)',
    'TGfx.ApplyPipeline a pipeline .Colors[n].PixelFormat doesn''t match TPass.Attachments.Colors[n] image pixel format',
    'TGfx.ApplyPipeline the pass depth-stencil attachment view is not in valid state (TResourceState.Valid)',
    'TGfx.ApplyPipeline the pass depth-stencil attachment view''s image object is not in valid state (TResourceState.Valid)',
    'TGfx.ApplyPipeline pipeline .Depth.PixelFormat doesn''t match TPass.Attachments.DepthStencil image pixel format',
    'TGfx.ApplyPipeline pipeline MSAA sample count doesn''t match pass attachment sample count',
    'TGfx.ApplyBindings: must be called in a pass',
    'TGfx.ApplyBindings: the provided TBindings struct is empty',
    'TGfx.ApplyBindings: must be called after TGfx.ApplyPipeline',
    'TGfx.ApplyBindings: currently applied pipeline object no longer alive',
    'TGfx.ApplyBindings: currently applied pipeline object not in valid state',
    'TGfx.ApplyBindings: shader associated with currently applied pipeline is no longer alive',
    'TGfx.ApplyBindings: shader associated with currently applied pipeline is not in valid state',
    'TGfx.ApplyBindings: vertex buffer bindings not allowed in a compute pass',
    'TGfx.ApplyBindings: index buffer binding not allowed in compute pass',
    'TGfx.ApplyBindings: vertex buffer binding is missing or buffer handle is invalid',
    'TGfx.ApplyBindings: vertex buffer no longer alive',
    'TGfx.ApplyBindings: buffer in vertex buffer bind slot must have Usage.VertexBuffer',
    'TGfx.ApplyBindings: buffer in vertex buffer bind slot is overflown',
    'TGfx.ApplyBindings: pipeline object defines non-indexed rendering, but index buffer binding provided',
    'TGfx.ApplyBindings: pipeline object defines indexed rendering, but no index buffer binding provided',
    'TGfx.ApplyBindings: index buffer no longer alive',
    'TGfx.ApplyBindings: buffer in index buffer bind slot must have Usage.IndexBuffer',
    'TGfx.ApplyBindings: buffer in index buffer slot is overflown',
    'TGfx.ApplyBindings: view binding is missing or the view handle is invalid',
    'TGfx.ApplyBindings: view no longer alive',
    'TGfx.ApplyBindings: view type mismatch in bindslot (shader expects a texture view)',
    'TGfx.ApplyBindings: view type mismatch in bindslot (shader expects a storage buffer view)',
    'TGfx.ApplyBindings: view type mismatch in bindslot (shader expects a storage image view)',
    'TGfx.ApplyBindings: image type of bound texture doesn''t match shader desc',
    'TGfx.ApplyBindings: texture bindings expects image with SampleCcount > 1',
    'TGfx.ApplyBindings: texture bindings expects image with SampleCount = 1',
    'TGfx.ApplyBindings: filterable image expected',
    'TGfx.ApplyBindings: depth image expected',
    'TGfx.ApplyBindings: storage buffers bound as read/write must have usage immutable',
    'TGfx.ApplyBindings: storage image bindings can only appear on compute passes',
    'TGfx.ApplyBindings: image type of bound storage image doesn''t match shader desc',
    'TGfx.ApplyBindings: pixel format of storage image view doesn''t match access format in shader desc',
    'TGfx.ApplyBindings: sampler binding is missing or the sampler handle is invalid',
    'TGfx.ApplyBindings: shader expects TSamplerType.Comparison but sampler has TCompareFunc.Never',
    'TGfx.ApplyBindings: shader expects TSamplerType.Filtering or TSamplerType.NonFiltering but sampler doesn''t have TCompareFunc.Never',
    'TGfx.ApplyBindings: shader expected TSamplerType.NonFiltering, but sampler has TFilter.Linear filters',
    'TGfx.ApplyBindings: bound sampler no longer alive',
    'TGfx.ApplyBindings: bound sampler not in valid state',
    'TGfx.ApplyBindings: cannot bind texture in the same pass it is used as depth-stencil attachment',
    'TGfx.ApplyBindings: cannot bind texture in the same pass it is used as color attachment',
    'TGfx.ApplyBindings: cannot bind texture in the same pass it is used as resolve attachment',
    'TGfx.ApplyBindings: an image cannot be bound as a texture and storage image at the same time',
    'TGfx.ApplyUniforms: must be called in a pass',
    'TGfx.ApplyUniforms: must be called after TGfx.ApplyPipeline()',
    'TGfx.ApplyUniforms: currently applied pipeline object no longer alive',
    'TGfx.ApplyUniforms: currently applied pipeline object not in valid state',
    'TGfx.ApplyUniforms: shader associated with currently applied pipeline is no longer alive',
    'TGfx.ApplyUniforms: shader associated with currently applied pipeline is not in valid state',
    'TGfx.ApplyUniforms: no uniform block declaration at this shader stage UB slot',
    'TGfx.ApplyUniforms: data size doesn''t match declared uniform block size',
    'TGfx.Draw: must be called in a render pass',
    'TGfx.Draw: BaseElement cannot be < 0',
    'TGfx.Draw: NumElements cannot be < 0',
    'TGfx.Draw: NumInstances cannot be < 0',
    'TGfx.Draw: must be called in a render pass',
    'TGfx.DrawEx: BaseElement cannot be < 0',
    'TGfx.DrawEx: NumElements cannot be < 0',
    'TGfx.DrawEx: NumInstances cannot be < 0',
    'TGfx.DrawEx: BaseInstance cannot be < 0',
    'TGfx.DrawEx(): BaseVertex must be 0 for non-indexed rendering',
    'TGfx.DrawEx(): BaseInstance must be 0 for non-instanced rendering',
    'TGfx.DrawEx(): BaseVertex <> 0 not supported on this backend (TFeatures.DrawBaseVertex)',
    'TGfx.DrawEx(): BaseInstance > 0 not supported on this backend (TFeatures.DrawBaseInstance)',
    'TGfx.Draw: call to TGfx.ApplyBindings() and/or TGfx.ApplyUniforms() missing after TGfx.ApplyPipeline()',
    'TGfx.Dispatch: must be called in a compute pass',
    'TGfx.Dispatch: NumGroupsX must be >=0 and <65536',
    'TGfx.Dispatch: NumGroupsY must be >=0 and <65536',
    'TGfx.Dispatch: NumGroupsZ must be >=0 and <65536',
    'TGfx.Dispatch: call to TGfx.ApplyBindings() and/or TGfx.ApplyUniforms() missing after TGfx.ApplyPipeline()',
    'TBuffer.Update: cannot update immutable buffer',
    'TBuffer.Update: update size is bigger than buffer size',
    'TBuffer.Update: only one update allowed per buffer and frame',
    'TBuffer.Update: cannot call TBuffer.Update and TBuffer.Append in same frame',
    'TBuffer.Append: cannot append to immutable buffer',
    'TBuffer.Append: overall appended size is bigger than buffer size',
    'TBuffer.Append: cannot call TBuffer.Append and TBuffer.Update in same frame',
    'TImage.Update: cannot update immutable image',
    'TImage.Update: only one update allowed per image and frame',
    'validation layer checks failed');
begin
  Result := STRINGS[Self];
end;

{ TEnvironmentDefaults }

function TEnvironmentDefaults.GetColorFormat: TPixelFormat;
begin
  Result := TPixelFormat(FHandle.color_format);
end;

function TEnvironmentDefaults.GetDepthFormat: TPixelFormat;
begin
  Result := TPixelFormat(FHandle.depth_format);
end;

procedure TEnvironmentDefaults.SetColorFormat(const AValue: TPixelFormat);
begin
  FHandle.color_format := Ord(AValue);
end;

procedure TEnvironmentDefaults.SetDepthFormat(const AValue: TPixelFormat);
begin
  FHandle.depth_format := Ord(AValue);
end;

{ TD3D11Environment }

function TD3D11Environment.GetDevice: IInterface;
begin
  Result := IInterface(FHandle.device);
end;

function TD3D11Environment.GetDeviceContext: IInterface;
begin
  Result := IInterface(FHandle.device_context);
end;

procedure TD3D11Environment.SetDevice(const AValue: IInterface);
begin
  FHandle.device := Pointer(AValue);
end;

procedure TD3D11Environment.SetDeviceContext(const AValue: IInterface);
begin
  FHandle.device_context := Pointer(AValue);
end;

{ TEnvironment }

function TEnvironment.GetD3D11: PD3D11Environment;
begin
  Result := @FHandle.d3d11;
end;

function TEnvironment.GetDefaults: PEnvironmentDefaults;
begin
  Result := @FHandle.defaults;
end;

function TEnvironment.GetMetal: PMetalEnvironment;
begin
  Result := @FHandle.metal;
end;

function TEnvironment.GetVulkan: PVulkanEnvironment;
begin
  Result := @FHandle.vulkan;
end;

{ TGfxDesc }

procedure TGfxDesc.Convert(out ADst: _sg_desc);
begin
  ADst._start_canary := 0;
  ADst.buffer_pool_size := BufferPoolSize;
  ADst.image_pool_size := ImagePoolSize;
  ADst.sampler_pool_size := SamplerPoolSize;
  ADst.shader_pool_size := ShaderPoolSize;
  ADst.pipeline_pool_size := PipelinePoolSize;
  ADst.view_pool_size := ViewPoolSize;
  ADst.uniform_buffer_size := UniformBufferSize;
  ADst.max_commit_listeners := MaxCommitListeners;
  ADst.disable_validation := DisableValidation;
  ADst.enforce_portable_limits := EnforcePortableLimits;
  ADst.d3d11 := D3D11.FHandle;
  ADst.metal := Metal.FHandle;
  FillChar(ADst.wgpu, SizeOf(ADst.wgpu), 0);
  ADst.vulkan := Vulkan.FHandle;
  {$IFDEF SOKOL_MEM_TRACK}
  ADst.allocator.alloc_fn := _MemTrackAlloc;
  ADst.allocator.free_fn := _MemTrackFree;
  {$ELSE}
  if (UseDelphiMemoryManager) then
  begin
    ADst.allocator.alloc_fn := _AllocCallback;
    ADst.allocator.free_fn := _FreeCallback;
  end
  else
  begin
    ADst.allocator.alloc_fn := nil;
    ADst.allocator.free_fn := nil;
  end;
  {$ENDIF}
  ADst.allocator.user_data := nil;

  if Assigned(Logger) then
  begin
    GLogger := Logger;
    ADst.logger.func := LogCallback;
  end
  else
    ADst.logger.func := nil;

  ADst.logger.user_data := nil;

  ADst.environment := Environment.FHandle;
  ADst._end_canary := 0;
end;

class function TGfxDesc.Create: TGfxDesc;
begin
  Result.Init;
end;

procedure TGfxDesc.DefaultLogger(const ALevel: TLogLevel;
  const AItem: TGfxLogItem; const AMessage: String; const ALineNr: Integer);
begin
  _LogDefault(ALevel, Ord(AItem), AMessage, ALineNr);
end;

procedure TGfxDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

class procedure TGfxDesc.LogCallback(const ATag: PUTF8Char; ALogLevel,
  ALogItemId: UInt32; const AMessageOrNull: PUTF8Char; ALineNr: UInt32;
  const AFilenameOrNull: PUTF8Char; AUserData: Pointer);
begin
  Assert(Assigned(GLogger));
  var Msg: String;
  if (Cardinal(ALogItemId) <= Ord(High(TGfxLogItem))) then
    Msg := TGfxLogItem(ALogItemId).ToString
  else
    Msg := String(UTF8String(AMessageOrNull));

  GLogger(TLogLevel(ALogLevel), TGfxLogItem(ALogItemId), Msg, ALineNr);
end;

{ TGfx }

class procedure TGfx.ApplyBindings(const ABindings: TBindings);
begin
  _sg_apply_bindings(@ABindings.FHandle);
end;

class procedure TGfx.ApplyPipeline(const APipeline: TPipeline);
begin
  _sg_apply_pipeline(APipeline.FHandle);
end;

class procedure TGfx.ApplyScissorRect(const AX, AY, AWidth, AHeight: Integer;
  const AOriginTopLeft: Boolean);
begin
  _sg_apply_scissor_rect(AX, AY, AWidth, AHeight, AOriginTopLeft);
end;

class procedure TGfx.ApplyScissorRect(const ARect: TRect;
  const AOriginTopLeft: Boolean);
begin
  _sg_apply_scissor_rect(ARect.Left, ARect.Top, ARect.Width, ARect.Height,
    AOriginTopLeft);
end;

class procedure TGfx.ApplyScissorRect(const AX, AY, AWidth, AHeight: Single;
  const AOriginTopLeft: Boolean);
begin
  _sg_apply_scissor_rectf(AX, AY, AWidth, AHeight, AOriginTopLeft);
end;

class procedure TGfx.ApplyScissorRect(const ARect: TRectF;
  const AOriginTopLeft: Boolean);
begin
  _sg_apply_scissor_rectf(ARect.Left, ARect.Top, ARect.Width, ARect.Height,
    AOriginTopLeft);
end;

class procedure TGfx.ApplyUniforms(const AUBSlot: Integer; const AData: TRange);
begin
  _sg_apply_uniforms(AUBSlot, @AData.FHandle);
end;

class procedure TGfx.ApplyUniforms(const AUBSlot: Integer; const AData: TBytes);
begin
  var Data: _sg_range;
  Data.ptr := Pointer(AData);
  Data.size := Length(AData);
  _sg_apply_uniforms(AUBSlot, @Data);
end;

class procedure TGfx.ApplyViewport(const AX, AY, AWidth, AHeight: Integer;
  const AOriginTopLeft: Boolean);
begin
  _sg_apply_viewport(AX, AY, AWidth, AHeight, AOriginTopLeft);
end;

class procedure TGfx.ApplyViewport(const AViewport: TRect;
  const AOriginTopLeft: Boolean);
begin
  _sg_apply_viewport(AViewport.Left, AViewport.Top, AViewport.Width,
    AViewport.Height, AOriginTopLeft);
end;

class procedure TGfx.ApplyViewport(const AX, AY, AWidth, AHeight: Single;
  const AOriginTopLeft: Boolean);
begin
  _sg_apply_viewportf(AX, AY, AWidth, AHeight, AOriginTopLeft);
end;

class procedure TGfx.ApplyViewport(const AViewport: TRectF;
  const AOriginTopLeft: Boolean);
begin
  _sg_apply_viewportf(AViewport.Left, AViewport.Top, AViewport.Width,
    AViewport.Height, AOriginTopLeft);
end;

class procedure TGfx.BeginPass(const APass: TPass);
begin
  _sg_begin_pass(@APass.FHandle);
end;

class procedure TGfx.Commit;
begin
  _sg_commit;
end;

class procedure TGfx.CommitListenerCallback(AUserData: Pointer);
begin
  Assert(Assigned(FCommitListener));
  FCommitListener();
end;

class procedure TGfx.DisableStats;
begin
  _sg_disable_stats();
end;

class procedure TGfx.Dispatch(const ANumGroupsX, ANumGroupsY,
  ANumGroupsZ: Integer);
begin
  _sg_dispatch(ANumGroupsX, ANumGroupsY, ANumGroupsZ);
end;

class procedure TGfx.DoGetFeatures;
begin
  var Features := _sg_query_features;
  if (Features.origin_top_left) then
    Include(FFeatures, TFeature.OriginTopLeft);
  if (Features.image_clamp_to_border) then
    Include(FFeatures, TFeature.ImageClampToBorder);
  if (Features.mrt_independent_blend_state) then
    Include(FFeatures, TFeature.MrtIndependentBlendState);
  if (Features.mrt_independent_write_mask) then
    Include(FFeatures, TFeature.MrtIndependentWriteMask);
  if (Features.compute) then
    Include(FFeatures, TFeature.Compute);
  if (Features.msaa_texture_bindings) then
    Include(FFeatures, TFeature.MsaaTextureBindings);
  if (Features.separate_buffer_types) then
    Include(FFeatures, TFeature.SeparateBufferTypes);
  if (Features.draw_base_vertex) then
    Include(FFeatures, TFeature.DrawBaseVertex);
  if (Features.draw_base_instance) then
    Include(FFeatures, TFeature.DrawBaseInstance);
  if (Features.dual_source_blending) then
    Include(FFeatures, TFeature.DualSourceBlending);
  if (Features.vertexformat_int10_n2) then
    Include(FFeatures, TFeature.VertexFormatInt10N2);
  if (Features.gl_texture_views) then
    Include(FFeatures, TFeature.GLTextureViews);
end;

class procedure TGfx.Draw(const ABaseElement, ANumElements, ANumInstances,
  ABaseVertex, ABaseInstance: Integer);
begin
  _sg_draw_ex(ABaseElement, ANumElements, ANumInstances, ABaseElement, ABaseInstance);
end;

class procedure TGfx.Draw(const ABaseElement, ANumElements,
  ANumInstances: Integer);
begin
  _sg_draw(ABaseElement, ANumElements, ANumInstances);
end;

class procedure TGfx.EnableStats;
begin
  _sg_enable_stats();
end;

class procedure TGfx.EndPass;
begin
  _sg_end_pass;
end;

class function TGfx.GetBackend: TBackend;
begin
  Result := TBackend(_sg_query_backend);
end;

class function TGfx.GetD3D11Device: IInterface;
begin
  Result := IInterface(_sg_d3d11_device);
end;

class function TGfx.GetD3D11DeviceContext: IInterface;
begin
  Result := IInterface(_sg_d3d11_device_context);
end;

class function TGfx.GetFeatures: TFeatures;
begin
  if (not FFeaturesValid) then
    DoGetFeatures;

  Result := FFeatures;
end;

class function TGfx.GetIsValid: Boolean;
begin
  Result := _sg_isvalid;
end;

class function TGfx.GetLimits: TLimits;
begin
  Result.FHandle := _sg_query_limits;
end;

class function TGfx.GetMetalCommandQueue: Pointer;
begin
  Result := _sg_mtl_command_queue;
end;

class function TGfx.GetMetalComputeCommandEncoder: Pointer;
begin
  Result := _sg_mtl_compute_command_encoder;
end;

class function TGfx.GetMetalDevice: Pointer;
begin
  Result := _sg_mtl_device;
end;

class function TGfx.GetMetalRenderCommandEncoder: Pointer;
begin
  Result := _sg_mtl_render_command_encoder;
end;

class function TGfx.GetStatsEnabled: Boolean;
begin
  Result := _sg_stats_enabled();
end;

class procedure TGfx.InstallTraceHooks(const ATraceHooks: TTraceHooks);
begin
  _sg_install_trace_hooks(@ATraceHooks.Hooks);
end;

class procedure TGfx.PopDebugGroup;
begin
  _sg_pop_debug_group;
end;

class procedure TGfx.PushDebugGroup(const AName: String);
begin
  _sg_push_debug_group(PUTF8Char(UTF8String(AName)));
end;

class function TGfx.QueryStats: TStats;
begin
  Result := TStats(_sg_query_stats());
end;

class procedure TGfx.ResetCache;
begin
  _sg_reset_state_cache;
end;

class procedure TGfx.SetCommitListener(const AValue: TCommitListener);
begin
  FCommitListener := AValue;

  var Listener: _sg_commit_listener;
  Listener.func := CommitListenerCallback;
  Listener.user_data := nil;

  if Assigned(AValue) then
    _sg_add_commit_listener(Listener)
  else
    _sg_remove_commit_listener(Listener);
end;

class procedure TGfx.SetStatsEnabled(const AValue: Boolean);
begin
  if (AValue) then
    _sg_enable_stats()
  else
    _sg_disable_stats()
end;

class procedure TGfx.Setup(const ADesc: TGfxDesc);
begin
  var Desc: _sg_desc;
  ADesc.Convert(Desc);
  _sg_setup(@Desc);
end;

class procedure TGfx.Shutdown;
begin
  _sg_shutdown;
end;

initialization
  Assert(SizeOf(TColorAttachmentAction) = SizeOf(_sg_color_attachment_action));
  Assert(SizeOf(TDepthAttachmentAction) = SizeOf(_sg_depth_attachment_action));
  Assert(SizeOf(TStencilAttachmentAction) = SizeOf(_sg_stencil_attachment_action));
  Assert(SizeOf(TStats) = SizeOf(_sg_stats));

end.

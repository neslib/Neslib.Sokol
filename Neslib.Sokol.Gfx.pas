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
  Neslib.Sokol.Api;

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
    property Data: Pointer read FHandle.ptr;

    { Size of the data in the buffer }
    property Size: NativeUInt read FHandle.size;
  end;

const
  { Various compile-time constants }
  INVALID_ID              = _SG_INVALID_ID;
  NUM_SHADER_STAGES       = _SG_NUM_SHADER_STAGES;
  NUM_INFLIGHT_FRAMES     = _SG_NUM_INFLIGHT_FRAMES;
  MAX_COLOR_ATTACHMENTS   = _SG_MAX_COLOR_ATTACHMENTS;
  MAX_SHADERSTAGE_BUFFERS = _SG_MAX_SHADERSTAGE_BUFFERS;
  MAX_SHADERSTAGE_IMAGES  = _SG_MAX_SHADERSTAGE_IMAGES;
  MAX_SHADERSTAGE_UBS     = _SG_MAX_SHADERSTAGE_UBS;
  MAX_UB_MEMBERS          = _SG_MAX_UB_MEMBERS;
  MAX_VERTEX_ATTRIBUTES   = _SG_MAX_VERTEX_ATTRIBUTES;
  MAX_MIPMAPS             = _SG_MAX_MIPMAPS;
  MAX_TEXTUREARRAY_LAYERS = _SG_MAX_TEXTUREARRAY_LAYERS;

type
  { A floating-point RGBA color value }
  TColor = TAlphaColorF;
  PColor = PAlphaColorF;

type
  { The active 3D-API backend, use the property TGfx.Backend to get the
    currently active backend.

    Note that Gles2 will be returned on Android if Gles3 was requested, but the
    runtime platform doesn't support GLES3 and we had to fallback to GLES2. }
  TBackend = (
    { Windows: OpenGL 3.3 (currently not used in favor of D3D11) }
    GLCore33   = _SG_BACKEND_GLCORE33,

    { Android: GLES-2 }
    Gles2      = _SG_BACKEND_GLES2,

    { Android: GLES-3 }
    Gles3      = _SG_BACKEND_GLES3,

    { Windows: DirectX 11 }
    D3D11      = _SG_BACKEND_D3D11,

    { iOS: Metal }
    MetalIOS   = _SG_BACKEND_METAL_IOS,

    { macOS: Metal }
    MetalMacOS = _SG_BACKEND_METAL_MACOS);

type
  { Adds functionality to TBackend }
  _TBackendHelper = record helper for TBackend
  {$REGION 'Internal Declarations'}
  private
    function GetIsGL: Boolean; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Whether this is an OpenGL backend (GLCore33, Gles2 or Gles3) }
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

        - Sample: the pixelformat can be sampled as texture at least with
                  nearest filtering
        - Filter: the pixelformat can be sampled as texture with linear
                  filtering
        - Render: the pixelformat can be used for render targets
        - Blend:  blending is supported when using the pixelformat for
                  render targets
        - Msaa:   multisample-antialiasing is supported when using the
                  pixelformat for render targets
        - Depth:  the pixelformat can be used for depth-stencil attachments

    When targeting GLES2, the only safe formats to use as texture are R8 and
    Rgba8. For rendering in GLES2, only Rgba8 is safe. All other formats must be
    checked using the record helper.

    The default pixel format for texture images is Rgba8.

    The default pixel format for render target images is platform-dependent:
        - for Metal and D3D11 it is Bgra8
        - for GL backends it is Rgba8

    This is mainly because of the default framebuffer which is setup outside
    of this unit. On some backends, using BGRA for the default frame buffer
    allows more efficient frame flips. For your own offscreen-render-targets,
    use whatever renderable pixel format is convenient for you. }
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
    Rgba8SN       = _SG_PIXELFORMAT_RGBA8SN,
    Rgba8UI       = _SG_PIXELFORMAT_RGBA8UI,
    Rgba8SI       = _SG_PIXELFORMAT_RGBA8SI,
    Bgra8         = _SG_PIXELFORMAT_BGRA8,
    Rgb10A2       = _SG_PIXELFORMAT_RGB10A2,
    Rg11B10F      = _SG_PIXELFORMAT_RG11B10F,

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
    Bc4R          = _SG_PIXELFORMAT_BC4_R,
    Bc4RSN        = _SG_PIXELFORMAT_BC4_RSN,
    Bc5Rg         = _SG_PIXELFORMAT_BC5_RG,
    Bc5_RgSN      = _SG_PIXELFORMAT_BC5_RGSN,
    Bc6HRgbF      = _SG_PIXELFORMAT_BC6H_RGBF,
    Bc6HRgbUF     = _SG_PIXELFORMAT_BC6H_RGBUF,
    Bc7Rgba       = _SG_PIXELFORMAT_BC7_RGBA,
    PvrtcRgb2Bpp  = _SG_PIXELFORMAT_PVRTC_RGB_2BPP,
    PvrtcRgb4Bpp  = _SG_PIXELFORMAT_PVRTC_RGB_4BPP,
    PvrtcRgba2Bpp = _SG_PIXELFORMAT_PVRTC_RGBA_2BPP,
    PvrtcRgba4Bpp = _SG_PIXELFORMAT_PVRTC_RGBA_4BPP,
    Etc2Rgb8      = _SG_PIXELFORMAT_ETC2_RGB8,
    Etc2Rgb8A1    = _SG_PIXELFORMAT_ETC2_RGB8A1,
    Etc2Rgba8     = _SG_PIXELFORMAT_ETC2_RGBA8,
    Etc2Rg11      = _SG_PIXELFORMAT_ETC2_RG11,
    Etc2Rg11SN    = _SG_PIXELFORMAT_ETC2_RG11SN);

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
  private
    class procedure InitInfo; static;
  {$ENDREGION 'Internal Declarations'}
  public
    { Pixel format can be sampled in shaders }
    property Sample: Boolean read GetSample;

    { Pixel format can be sampled with filtering }
    property Filter: Boolean read GetFilter;

    { Pixel format can be used as render target }
    property Render: Boolean read GetRender;

    { Alpha-blending is supported }
    property Blend: Boolean read GetBlend;

    { Pixel format can be used as MSAA render target }
    property Msaa: Boolean read GetMsaa;

    { Pixel format is a depth format }
    property IsDepth: Boolean read GetDepth;
  end;

type
  { Runtime information about available optional features, returned by
    TGfx.Features. }
  TFeature = (
    { Hardware instancing supported }
    Instancing,

    { Framebuffer and texture origin is in top left corner }
    OriginTopLeft,

    { Offscreen render passes can have multiple render targets attached }
    MultipleRenderTargets,

    { Offscreen render passes support MSAA antialiasing }
    MsaaRenderTargets,

    { Creation of TImageType.ThreeD images is supported }
    ImageType3D,

    { Creation of TImageType.Array images is supported }
    ImageTypeArray,

    { Border color and clamp-to-border UV-wrap mode is supported }
    ImageClampToBorder,

    { Multiple-render-target rendering can use per-render-target blend state }
    MrtIndependentBlendState,

    { Multiple-render-target rendering can use per-render-target color write
      masks }
    MrtIndependentWriteMask);
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

    { Maximum number of vertex attributes (<= MAX_VERTEX_ATTRIBUTES on some
      GLES2 implementations) }
    property MaxVertexAttrs: Integer read FHandle.max_vertex_attrs;

    { Maximum number of vertex uniform vectors (GLES2/3 only) }
    property MaxVertexUniformVectors: Integer read FHandle.gl_max_vertex_uniform_vectors;
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
  { A resource usage hint describing the update strategy of buffers and images.
    This is used in the TBufferDesc.Usage and TImageDesc.Usage fields when
    creating buffers and images.

    The rendering backends use this hint to prevent that the CPU needs to wait
    for the GPU when attempting to update a resource that might be currently
    accessed by the GPU.

    Resource content is updated with the functions TBuffer.Update or
    TBuffer.Append for buffer objects, and TImage.Update for image objects. For
    the Update methods, only one update is allowed per frame and resource
    object, while TBuffer.Append can be called multiple times per frame on the
    same buffer. The application must update all data required for rendering
    (this means that the update data can be smaller than the resource size, if
    only a part of the overall resource size is used for rendering, you only
    need to make sure that the data that *is* used is valid).

    The default usage is Immutable. }
  TUsage = (
    { The resource will never be updated with new data, instead the content of
      the resource must be provided on creation. }
    Immutable = _SG_USAGE_IMMUTABLE,

    { The resource will be updated infrequently with new data (this could range
      from "once after creation", to "quite often but not every frame"). }
    &Dynamic   = _SG_USAGE_DYNAMIC,

    { The resource will be updated each frame with new content. }
    Stream     = _SG_USAGE_STREAM);

type
  { Indicates whether a buffer contains vertex- or index-data, used in the
    TBufferDesc.BufferType member when creating a buffer.

    The default value is VertexBuffer. }
  TBufferType = (
    { For vertex buffers }
    VertexBuffer = _SG_BUFFERTYPE_VERTEXBUFFER,

    { For index buffers }
    IndexBuffer  = _SG_BUFFERTYPE_INDEXBUFFER);

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
    or 2D-array-texture). 3D- and array-textures are not supported on the GLES2
    backend (use TGfx.Features to check for support). The image type is used
    in the TImageDesc.ImageType member when creating an image, and in
    TShaderImageDesc when describing a shader's texture sampler binding.

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
  { Indicates the basic data type of a shader's texture sampler which can be
    float, unsigned integer or signed integer. The sampler type is used in the
    TShaderImageDesc to describe the sampler type of a shader's texture sampler
    binding.

    The default sampler type is Float. }
  TSamplerType = (
    { Floating-point }
    Float       = _SG_SAMPLERTYPE_FLOAT,

    { Signed integer }
    SignedInt   = _SG_SAMPLERTYPE_SINT,

    { Unsigned integer }
    UnsignedInt = _SG_SAMPLERTYPE_UINT);

type
  { The cubemap faces. Use these as indices in the TImageDesc.Content array. }
  TCubeFace = (
    { Positive X-axis }
    PosX = _SG_CUBEFACE_POS_X,

    { Negative X-axis }
    NegX = _SG_CUBEFACE_NEG_X,

    { Positive Y-axis }
    PosY = _SG_CUBEFACE_POS_Y,

    { Negative Y-axis }
    NegY = _SG_CUBEFACE_NEG_Y,

    { Positive Z-axis }
    PosZ = _SG_CUBEFACE_POS_Z,

    { Negative Z-axis }
    NegZ = _SG_CUBEFACE_NEG_Z);

type
  { There are 2 shader stages: vertex- and fragment-shader-stage.
    Each shader stage consists of:

    - one slot for a shader function (provided as source- or byte-code)
    - MAX_SHADERSTAGE_UBS slots for uniform blocks
    - MAX_SHADERSTAGE_IMAGES slots for images used as textures by the shader
      function }
  TShaderStage = (
    { Vertex shader }
    VertexShader   = _SG_SHADERSTAGE_VS,

    { Fragment shader }
    FragmentShader = _SG_SHADERSTAGE_FS);

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
    TImageDesc.MinFilter and TImageDesc.MagFilter fields when creating an image
    object.

    The default filter mode is Nearest. }
  TFilter = (
    { Nearest neighbor filtering.
      Fastest, but lowest quality. }
    Nearest              = _SG_FILTER_NEAREST,

    { Linear filtering.
      Slower, but higher quality. }
    Linear               = _SG_FILTER_LINEAR,

    { When mipmaps are used, uses nearest filtering for each mipmap level,
      and nearest filtering between mipmap levels. }
    NearestMipmapNearest = _SG_FILTER_NEAREST_MIPMAP_NEAREST,

    { When mipmaps are used, uses nearest filtering for each mipmap level,
      and linear filtering between mipmap levels. }
    NearestMipmapLinear  = _SG_FILTER_NEAREST_MIPMAP_LINEAR,

    { When mipmaps are used, uses linear filtering for each mipmap level,
      and nearest filtering between mipmap levels. }
    LinearMipmapNearest  = _SG_FILTER_LINEAR_MIPMAP_NEAREST,

    { When mipmaps are used, uses linear filtering for each mipmap level,
      and linear filtering between mipmap levels. }
    LinearMipmapLinear   = _SG_FILTER_LINEAR_MIPMAP_LINEAR);

type
  { The texture coordinates wrapping mode when sampling a texture image. This is
    used in the TImageDesc.WrapU, .WrapV and .WrapW members when creating an
    image.

    The default wrap mode is Repeating.

    NOTE: ClampToBorder is not supported on all backends and platforms. To check
    for support, use TGfx.Features and check the ImageClampToBorder flag.

    Platforms which don't support ClampToBorder will silently fall back to
    ClampToEdge without a validation error.

    Platforms which support clamp-to-border are:

        - Metal on macOS
        - D3D11 on Windows

    Platforms which do not support clamp-to-border:

        - GLES2/3 on Android
        - Metal on iOS }
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
    vertex data when creating a pipeline object. }
  TVertexFormat = (
    Invalid  = _SG_VERTEXFORMAT_INVALID,
    Float    = _SG_VERTEXFORMAT_FLOAT,
    Float2   = _SG_VERTEXFORMAT_FLOAT2,
    Float3   = _SG_VERTEXFORMAT_FLOAT3,
    Float4   = _SG_VERTEXFORMAT_FLOAT4,
    Byte4    = _SG_VERTEXFORMAT_BYTE4,
    Byte4N   = _SG_VERTEXFORMAT_BYTE4N,
    UByte4   = _SG_VERTEXFORMAT_UBYTE4,
    UByte4N  = _SG_VERTEXFORMAT_UBYTE4N,
    Short2   = _SG_VERTEXFORMAT_SHORT2,
    Short2N  = _SG_VERTEXFORMAT_SHORT2N,
    UShort2N = _SG_VERTEXFORMAT_USHORT2N,
    Short4   = _SG_VERTEXFORMAT_SHORT4,
    Short4N  = _SG_VERTEXFORMAT_SHORT4N,
    UShort4N = _SG_VERTEXFORMAT_USHORT4N,
    UInt10N2 = _SG_VERTEXFORMAT_UINT10_N2);

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
    internal layout of uniform blocks when creating a shader object. }
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
  { A hint for the interior memory layout of uniform blocks. This is only really
    relevant for the GLES backend where the internal layout of uniform blocks
    must be known. For all other backends the internal memory layout of uniform
    blocks doesn't matter; this unit will just pass uniform data as a single
    memory blob to the 3D backend.

    The default is Native.

    SG_UNIFORMLAYOUT_STD140
        The memory layout is a subset of std140. Arrays are only
        allowed for the FLOAT4, INT4 and MAT4. Alignment is as
        is as follows:

            FLOAT, INT:         4 byte alignment
            FLOAT2, INT2:       8 byte alignment
            FLOAT3, INT3:       16 byte alignment(!)
            FLOAT4, INT4:       16 byte alignment
            MAT4:               16 byte alignment
            FLOAT4[], INT4[]:   16 byte alignment

        The overall size of the uniform block must be a multiple
        of 16.

    For more information search for 'UNIFORM DATA LAYOUT' in the documentation block
    at the start of the header. }
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
  { The compare-function for depth- and stencil-ref tests. This is used when
    creating pipeline objects in the members:

    TPipelineDesc
        .Depth
            .Compare
        .Stencil
            .Front.Compare
            .Back.Compare

    The default compare func for depth- and stencil-tests is Always. }
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
    object in the members:

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

    The default value is One for source factors, and Zero for destination
    factors. }
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
    OneMinusBlendAlpha = _SG_BLENDFACTOR_ONE_MINUS_BLEND_ALPHA);

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
    ReverseSubtract = _SG_BLENDOP_REVERSE_SUBTRACT);

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
  { Defines what action should be performed at the start of a render pass.

    This is used in the TPassAction record.

    The default action for all pass attachments is Clear, with the clear color
    Rgba = {0.5, 0.5, 0.5, 1.0], Depth = 1.0 and Stencil = 0.

    If you want to override the default behaviour, it is important to not only
    set the clear color, but the 'action' field as well. }
  {$MINENUMSIZE 4}
  TAction = (
    { Clear the render target image }
    Clear    = _SG_ACTION_CLEAR,

    { Load the previous content of the render target image }
    Load     = _SG_ACTION_LOAD,

    { Leave the render target image content undefined }
    DontCare = _SG_ACTION_DONTCARE);
  {$MINENUMSIZE 1}

type
  { TPassAction record defines the actions to be performed at the start of a
    rendering pass in the methods TGfx.BeginPass and TGfx.BeginDefaultPass.
    A separate action and clear values can be defined for each color attachment,
    and for the depth-stencil attachment.

    The default clear values are:
      - Red:    0.5
      - Green:  0.5
      - Blue:   0.5
      - Alpha:  1.0
      - Depth:  1.0
      - Stencil: 0 }
  TColorAttachmentAction = record
  public
    Action: TAction;
    Value: TColor;
  public
    constructor Create(const AAction: TAction; const AValue: TColor); overload;
    constructor Create(const AAction: TAction; const AR, AG, AB: Single;
      const AA: Single = 1); overload;

    procedure Init(const AAction: TAction; const AValue: TColor); overload; inline;
    procedure Init(const AAction: TAction; const AR, AG, AB: Single;
      const AA: Single = 1); overload; inline;
  end;
  PColorAttachmentAction = ^TColorAttachmentAction;

  TDepthAttachmentAction = record
  public
    Action: TAction;
    Value: Single;
  public
    constructor Create(const AAction: TAction; const AValue: Single);
    procedure Init(const AAction: TAction; const AValue: Single); inline;
  end;
  PDepthAttachmentAction = ^TDepthAttachmentAction;

  TStencilAttachmentAction = record
  public
    Action: TAction;
    Value: Byte;
  public
    constructor Create(const AAction: TAction; const AValue: Byte);
    procedure Init(const AAction: TAction; const AValue: Byte); inline;
  end;
  PStencilAttachmentAction = ^TStencilAttachmentAction;

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

    { The context this resource belongs to }
    property ContextId: UInt32 read FHandle.ctx_id;
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

    { Image width }
    property Width: Integer read FHandle.width;

    { Image height }
    property Height: Integer read FHandle.height;
  end;
  PImageInfo = ^TImageInfo;

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

  TPassInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_pass_info;
    function GetSlot: TSlotInfo; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Resource pool slot info }
    property Slot: TSlotInfo read GetSlot;
  end;
  PPassInfo = ^TPassInfo;

type
  { Creation parameters for TBuffer objects.

    The default configuration is:

    .Size:       0       (*must* be >0 for buffers without data)
    .BufferType: VertexBuffer
    .Usage:      Immutable
    .Data        []      (*must* be valid for immutable buffers)
    .TraceLabel  ''      (optional string label for trace hooks)

    The label will be ignored. It is only useful when hooking into
    TBuffer.Create or TBuffer.Init via the TGfx.InstallTraceHooks method.

    For immutable buffers which are initialized with initial data, keep the
    .Size field zero-initialized, and set the size together with the pointer to
    the initial data in the .Data field.

    For mutable buffers without initial data, keep the .Data field empty, and
    set the buffer size in the .Size field instead.

    You can also set both size values, but currently both size values must be
    identical (this may change in the future when the dynamic resource
    management may become more flexible).

    ADVANCED TOPIC: Injecting native 3D-API buffers:

    The following struct members allow to inject your own GL, Metal or D3D11
    buffers:

    .GLBuffers[NUM_INFLIGHT_FRAMES]
    .MtlBuffers[NUM_INFLIGHT_FRAMES]
    .D3D11Buffer

    You must still provide all other record fields except the .Data field, and
    these must match the creation parameters of the native buffers you provide.
    For TUsage.Immutable, only provide a single native 3D-API buffer, otherwise
    you need to provide NUM_INFLIGHT_FRAMES buffers (only for GL and Metal, not
    D3D11). Providing multiple buffers for GL and Metal is necessary because
    Sokol will rotate through them when calling TBuffer.Update to prevent
    lock-stalls.

    Note that it is expected that immutable injected buffer have already been
    initialized with content, and the .Content field must be 0!

    Also you need to call TGfx.ResetCache after calling native 3D-API
    functions, and before calling any Sokol function. }
  TBufferDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_buffer_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Size: NativeUInt;
    BufferType: TBufferType;
    Usage: TUsage;
    Data: TRange;

    TraceLabel: String;

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
  {$ENDREGION 'Internal Declarations'}
  public
    { Synchronous setup }
    constructor Create(const ADesc: TBufferDesc);
    procedure Init(const ADesc: TBufferDesc); inline;
    procedure Free; inline;

    { Asynchronous setup }
    procedure Allocate; inline;
    procedure Setup(const ADesc: TBufferDesc); inline;
    function Teardown: Boolean; inline;
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

    property Overflow: Boolean read GetOverflow;
  end;
  PBuffer = ^TBuffer;

type
  { Defines the content of an image through a 2D array TBytes buffers.
    The first array dimension is the cubemap face, and the second array
    dimension the mipmap level. }
  TImageData = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_image_data);
    procedure InitFrom(const ASrc: _sg_image_data);
    function GetSubImage(const AMipmapLevel: Integer): TRange; inline;
    procedure SubImage(const AMipmapLevel: Integer; const AValue: TRange); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    class function Create: TImageData; static;
    procedure Init; inline;
  public
    SubImagesCube: array [TCubeFace, 0..MAX_MIPMAPS - 1] of TRange;

    { Same sub images, but for 2D images }
    property SubImages[const AMipmapLevel: Integer]: TRange read GetSubImage write SubImage; default;
  end;
  PImageData = ^TImageData;

type
  { Creation parameters for TImage objects.

    The default configuration is:

    .ImageType:         TwoD
    .RenderTarget:      False
    .Width              0 (must be set to >0)
    .Height             0 (must be set to >0)
    .NumSlices          1 (3D textures: depth; array textures: number of layers)
    .NumMipmaps:        1
    .Usage:             Immutable
    .PixelFormat:       Rgba8 for textures, or TGfxDesc.Context.ColorFormat for render targets
    .SampleCount:       1 for textures, or TGfxDesc.Context.SampleCount for render targets
    .MinFilter:         Nearest
    .MagFilter:         Nearest
    .WrapU:             Repeating
    .WrapV:             Repeating
    .WrapW:             Repeating
    .BorderColor        OpaqueBlack
    .MaxAnisotropy      1 (must be 1..16)
    .MinLod             0.0
    .MaxLod             Single.MaxValue
    .Data               a TImageData record to define the initial content
    .TraceLabel         '' (optional string label for trace hooks)

    Q: Why is the default SampleCount for render targets identical with the
    "default sample count" from TGfxDesc.Context.SampleCount?

    A: So that it matches the default sample count in pipeline objects. Even
    though it is a bit strange/confusing that offscreen render targets by default
    get the same sample count as the default framebuffer, but it's better that
    an offscreen render target created with default parameters matches
    a pipeline object created with default parameters.

    NOTE:

    TImageType.Array and TImageType.ThreeD are not supported on GLES2.
    Use TGfx.Features at runtime to check if array- and 3D-textures are
    supported.

    Images with usage Immutable must be fully initialized by providing a valid
    .Data field with the initialization data.

    ADVANCED TOPIC: Injecting native 3D-API textures:

    The following record fields allow to inject your own GL, Metal or D3D11
    textures:

    .GLTextures[0..NUM_INFLIGHT_FRAMES - 1]
    .MtlTextures[0..NUM_INFLIGHT_FRAMES - 1]
    .D3D11Texture
    .D3D11ShaderResourceView

    For GL, you can also specify the texture target or leave it empty to use
    the default texture target for the image type (GL_TEXTURE_2D for
    TImageType.TwoD etc)

    For D3D11, you can provide either a D3D11 texture, or a
    shader-resource-view, or both. If only a texture is provided, a matching
    shader-resource-view will be created. If only a shader-resource-view is
    provided, the texture will be looked up from the shader-resource-view.

    The same rules apply as for injecting native buffers (see TBufferDesc
    documentation for more details). }
  TImageDesc = record
  {$REGION 'Internal Declarations'}
  public
    procedure _Convert(out ADst: _sg_image_desc);
    procedure _InitFrom(out ASrc: _sg_image_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    ImageType: TImageType;
    RenderTarget: Boolean;
    Width: Integer;
    Height: Integer;
    NumSlices: Integer;
    NumMipmaps: Integer;
    Usage: TUsage;
    PixelFormat: TPixelFormat;
    SampleCount: Integer;
    MinFilter: TFilter;
    MagFilter: TFilter;
    WrapU: TWrap;
    WrapV: TWrap;
    WrapW: TWrap;
    BorderColor: TBorderColor;
    MaxAnisotropy: UInt32;
    MinLod: Single;
    MaxLod: Single;
    Data: TImageData;
    TraceLabel: String;

    { GL specific }
    GLTextures: array [0..NUM_INFLIGHT_FRAMES - 1] of UInt32;
    GLTextureTarget: UInt32;

    { Metal specific [0..NUM_INFLIGHT_FRAMES - 1] }
    MetalTextures: array [0..NUM_INFLIGHT_FRAMES - 1] of Pointer;

    { D3D11 specific }
    D3D11Texture: IInterface;
    D3D11ShaderResourceView: IInterface;
  public
    { Initializes with default values }
    class function Create: TImageDesc; inline; static;
    procedure Init;
  end;
  PImageDesc = ^TImageDesc;

type
  { Texture and render target resource.

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
  {$ENDREGION 'Internal Declarations'}
  public
    { Synchronous setup }
    constructor Create(const ADesc: TImageDesc);
    procedure Init(const ADesc: TImageDesc); inline;
    procedure Free; inline;

    { Asynchronous setup }
    procedure Allocate; inline;
    procedure Setup(const ADesc: TImageDesc); inline;
    function Teardown: Boolean; inline;
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
  end;
  PImage = ^TImage;

type
  { Defines all creation parameters for shader programs, used as input to
    TShader:

    - reflection information for vertex attributes (vertex shader inputs):
        - vertex attribute name (required for GLES2, optional for GLES3 and GL)
        - a semantic name and index (required for D3D11)
    - for each shader-stage (vertex and fragment):
        - the shader source or bytecode
        - an optional entry function name
        - an optional compile target (only for D3D11 when source is provided,
          defaults are "vs_4_0" and "ps_4_0")
        - reflection info for each uniform block used by the shader stage:
            - the size of the uniform block in bytes
            - a memory layout hint (native vs std140, only required for GL
              backends)
            - reflection info for each uniform block member (only required for
              GL backends):
                - member name
                - member type (TUniformType)
                - if the member is an array, the number of array items
        - reflection info for the texture images used by the shader stage:
            - the image type (TImageType)
            - the sampler type (TSamplerType default is TSamplerType.Float)
            - the name of the texture sampler (required for GLES2, optional
              everywhere else)

    For all GL backends, shader source-code must be provided. For D3D11 and
    Metal, either shader source-code or byte-code can be provided.

    For D3D11, if source code is provided, the d3dcompiler_47.dll will be loaded
    on demand. If this fails, shader creation will fail. When compiling HLSL
    source code, you can provide an optional target string via
    TShaderStageDesc.D3D11Target. The default target is 'vs_5_0' for the
    vertex shader stage and 'ps_5_0' for the pixel shader stage. }
  TShaderAttrDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_shader_attr_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    { GLSL vertex attribute name (only strictly required for GLES2) }
    Name: String;

    { HLSL semantic name }
    SemanticName: String;

    { HLSL semantic index }
    SemanticIndex: Integer;
  public
    constructor Create(const AName, ASemanticName: String;
      const ASemanticIndex: Integer);
    procedure Init(const AName, ASemanticName: String;
      const ASemanticIndex: Integer); inline;
  end;
  PShaderAttrDesc = ^TShaderAttrDesc;

  TShaderUniformDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_shader_uniform_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Name: String;
    UniformType: TUniformType;
    ArrayCount: Integer;
  public
    constructor Create(const AName: String; const AUniformType: TUniformType;
      const AArrayCount: Integer);
    procedure Init(const AName: String; const AUniformType: TUniformType;
      const AArrayCount: Integer); inline;
  end;
  PShaderUniformDesc = ^TShaderUniformDesc;

  TShaderUniformBlockDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_shader_uniform_block_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Size: NativeUInt;
    Layout: TUniformLayout;
    Uniforms: array [0..MAX_UB_MEMBERS - 1] of TShaderUniformDesc;
  public
    constructor Create(const ASize: NativeUInt; const ALayout: TUniformLayout);
    procedure Init(const ASize: NativeUInt; const ALayout: TUniformLayout); inline;
  end;
  PShaderUniformBlockDesc = ^TShaderUniformBlockDesc;

  TShaderImageDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_shader_image_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Name: String;
    ImageType: TImageType;
    SamplerType: TSamplerType;
  public
    constructor Create(const AName: String; const AImageType: TImageType;
      const ASamplerType: TSamplerType);
    procedure Init(const AName: String; const AImageType: TImageType;
      const ASamplerType: TSamplerType); inline;
  end;
  PShaderImageDesc = ^TShaderImageDesc;

  TShaderStageDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_shader_stage_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Source: String;
    Bytecode: TRange;
    Entry: String;
    D3D11Target: String;
    UniformBlocks: array [0..MAX_SHADERSTAGE_UBS - 1] of TShaderUniformBlockDesc;
    Images: array [0..MAX_SHADERSTAGE_IMAGES - 1] of TShaderImageDesc;
  public
    constructor Create(const ASource: String; const ABytecode: TRange;
      const AEntry, AD3D11Target: String);
    procedure Init(const ASource: String; const ABytecode: TRange;
      const AEntry, AD3D11Target: String); inline;
  end;
  PShaderStageDesc = ^TShaderStageDesc;

  TShaderDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_shader_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Attrs: array [0..MAX_VERTEX_ATTRIBUTES - 1] of TShaderAttrDesc;
    VertexShader: TShaderStageDesc;
    FragmentShader: TShaderStageDesc;
    TraceLabel: String;
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

  _sg_shader_attr_desc_helper = record helper for _sg_shader_attr_desc
  public
    procedure Init(const AName, ASemanticName: PUTF8Char;
      const ASemanticIndex: Integer); inline;
  end;

  _sg_shader_desc_helper = record helper for _sg_shader_desc
  public
    procedure Init;
  end;

  _sg_shader_image_desc_helper = record helper for _sg_shader_image_desc
  public
    procedure Init(const AName: PUTF8Char; const AImageType: _sg_image_type;
      const ASamplerType: _sg_sampler_type); inline;
  end;

  _sg_shader_uniform_desc_helper = record helper for _sg_shader_uniform_desc
  public
    procedure Init(const AName: PUTF8Char; const AType: _sg_uniform_type;
      const AArrayCount: Integer); inline;
  end;

type
  { Vertex- and fragment-shader and uniform block resource.

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
    function Teardown: Boolean; inline;
    procedure Deallocate; inline;
    procedure Fail; inline;

    { The resource Id }
    property Id: Cardinal read FHandle.id write FHandle.id;

    { Current resource state }
    property State: TResourceState read GetState;

    { Get runtime information about the shader }
    property Info: TShaderInfo read GetInfo;
  end;
  PShader = ^TShader;

type
  { Defines all creation parameters for a TPipeline object:

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

    The default configuration is as follows:

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
            .DepthFailOp:   TStencilOp.Keep
            .PassOp:        TStencilOp.Keep
            .Compare:       TCompareFunc.Always
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
  TBufferLayoutDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_buffer_layout_desc);
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
  PBufferLayoutDesc = ^TBufferLayoutDesc;

  TVertexAttrDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_vertex_attr_desc);
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
  PVertexAttrDesc = ^TVertexAttrDesc;

  TLayoutDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_layout_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Buffers: array [0..MAX_SHADERSTAGE_BUFFERS - 1] of TBufferLayoutDesc;
    Attrs: array [0..MAX_VERTEX_ATTRIBUTES - 1] of TVertexAttrDesc;
  public
    class function Create: TLayoutDesc; static;
    procedure Init; inline;
  end;
  PLayoutDesc = ^TLayoutDesc;

  TStencilFaceState = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_stencil_face_state);
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

  TStencilState = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_stencil_state);
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

  TDepthState = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_depth_state);
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

  TBlendState = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_blend_state);
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

  TColorState = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_color_state);
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
  PColorState = ^TColorState;

  TPipelineDesc = record
  {$REGION 'Internal Declarations'}
  public
    procedure _Convert(out ADst: _sg_pipeline_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Shader: TShader;
    Layout: TLayoutDesc;
    Depth: TDepthState;
    Stencil: TStencilState;
    ColorCount: Integer;
    Colors: array [0..MAX_COLOR_ATTACHMENTS - 1] of TColorState;
    PrimitiveType: TPrimitiveType;
    IndexType: TIndexType;
    CullMode: TCullMode;
    FaceWinding: TFaceWinding;
    SampleCount: Integer;
    BlendColor: TColor;
    AlphaToCoverageEnabled: Boolean;
    TraceLabel: String;
  public
    { Initializes with default values }
    class function Create: TPipelineDesc; inline; static;
    procedure Init;
  end;
  PPipelineDesc = ^TPipelineDesc;

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
  {$ENDREGION 'Internal Declarations'}
  public
    { Synchronous setup }
    constructor Create(const ADesc: TPipelineDesc);
    procedure Init(const ADesc: TPipelineDesc); inline;
    procedure Free; inline;

    { Asynchronous setup }
    procedure Allocate; inline;
    procedure Setup(const ADesc: TPipelineDesc); inline;
    function Teardown: Boolean; inline;
    procedure Deallocate; inline;
    procedure Fail; inline;

    { The resource Id }
    property Id: Cardinal read FHandle.id write FHandle.id;

    { Current resource state }
    property State: TResourceState read GetState;

    { Get runtime information about the pipeline }
    property Info: TPipelineInfo read GetInfo;
  end;
  PPipeline = ^TPipeline;

type
  { Creation parameters for a TPass object.

    A pass object contains 1..4 color-attachments and none, or one,
    depth-stencil-attachment. Each attachment consists of an image, and two
    additional indices describing which subimage the pass will render to: one
    mipmap index, and if the image is a cubemap, array-texture or 3D-texture,
    the face-index, array-layer or depth-slice.

    Pass images must fulfill the following requirements:

    All images must have:
    - been created as render target (TImageDesc.RenderTarget = True)
    - the same size
    - the same sample count

    In addition, all color-attachment images must have the same pixel format. }
  TPassAttachmentDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_pass_attachment_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    Image: TImage;
    MipLevel: Integer;

    { Cube texture:  face
      Array texture: layer
      3D texture:    slice }
    Slice: Integer;
  public
    constructor Create(const AMipLevel, ASlice: Integer);
    procedure Init(const AMipLevel, ASlice: Integer); inline;
  end;
  PPassAttachmentDesc = ^TPassAttachmentDesc;

  TPassDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_pass_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    ColorAttachments: array [0..MAX_COLOR_ATTACHMENTS - 1] of TPassAttachmentDesc;
    DepthStencilAttachment: TPassAttachmentDesc;
    TraceLabel: String;
  public
    { Initializes with default values }
    class function Create: TPassDesc; inline; static;
    procedure Init;
  end;
  PPassDesc = ^TPassDesc;

type
  { A bundle of render targets and actions on them.

    A pass can be created synchronously or asynchronously.
    For synchronous creation, use Create/Init and Free.
    For asynchronous creation, use Allocate, Setup, Teardown, Deallocate and
    Fail. }
  TPass = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_pass;
    function GetState: TResourceState; inline;
    function GetInfo: TPassInfo;
  {$ENDREGION 'Internal Declarations'}
  public
    { Synchronous setup }
    constructor Create(const ADesc: TPassDesc);
    procedure Init(const ADesc: TPassDesc); inline;
    procedure Free; inline;

    { Asynchronous setup }
    procedure Allocate; inline;
    procedure Setup(const ADesc: TPassDesc); inline;
    function Teardown: Boolean; inline;
    procedure Deallocate; inline;
    procedure Fail; inline;

    { The resource Id }
    property Id: Cardinal read FHandle.id write FHandle.id;

    { Current resource state }
    property State: TResourceState read GetState;

    { Get runtime information about the pass }
    property Info: TPassInfo read GetInfo;
  end;
  PPass = ^TPass;

type
  { A 'context handle' for switching between 3D-API contexts.
    This is an optional type. }
  TContext = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_context;
  {$ENDREGION 'Internal Declarations'}
  public
    class function Create: TContext; inline; static;
    procedure Init;
    procedure Free; inline;

    { Operations }
    procedure Activate; inline;

    { The resource Id }
    property Id: Cardinal read FHandle.id write FHandle.id;
  end;
  PContext = ^TContext;

type
  { Defines the resource binding slots of the render pipeline, used as argument
    to the TGfx.ApplyBindings method.

    A resource binding struct contains:

    - 1..N vertex buffers
    - 0..N vertex buffer offsets
    - 0..1 index buffers
    - 0..1 index buffer offsets
    - 0..N vertex shader stage images
    - 0..N fragment shader stage images

    The max number of vertex buffer and shader stage images are defined by the
    MAX_SHADERSTAGE_BUFFERS and MAX_SHADERSTAGE_IMAGES configuration constants.

    The optional buffer offsets can be used to put different unrelated chunks of
    vertex- and/or index-data into the same buffer objects. }
  TBindings = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sg_bindings;
    function GetFragmentShaderImage(const AIndex: Integer): TImage; inline;
    procedure SetGetFragmentShaderImage(const AIndex: Integer;
      const AValue: TImage); inline;
    function GetIndexBuffer: TBuffer; inline;
    procedure SetIndexBuffer(const AValue: TBuffer); inline;
    function GetVertexBuffer(const AIndex: Integer): TBuffer; inline;
    procedure SetVertexBuffer(const AIndex: Integer; const AValue: TBuffer); inline;
    function GetVertexBufferOffset(const AIndex: Integer): Integer; inline;
    function GetVertexShaderImage(const AIndex: Integer): TImage; inline;
    procedure SetGetVertexShaderImage(const AIndex: Integer;
      const AValue: TImage); inline;
    procedure SetVertexBufferOffset(const AIndex, AValue: Integer); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    class function Create: TBindings; static;
    procedure Init; inline;

    { Vertex buffers [0..MAX_SHADERSTAGE_BUFFERS - 1] }
    property VertexBuffers[const AIndex: Integer]: TBuffer read GetVertexBuffer write SetVertexBuffer;
    property VertexBufferOffsets[const AIndex: Integer]: Integer read GetVertexBufferOffset write SetVertexBufferOffset;

    { Index buffer }
    property IndexBuffer: TBuffer read GetIndexBuffer write SetIndexBuffer;
    property IndexBufferOffset: Integer read FHandle.index_buffer_offset write FHandle.index_buffer_offset;

    { Vertex- and fragment shader images [0..MAX_SHADERSTAGE_IMAGES - 1] }
    property VertexShaderImages[const AIndex: Integer]: TImage read GetVertexShaderImage write SetGetVertexShaderImage;
    property FragmentShaderImages[const AIndex: Integer]: TImage read GetFragmentShaderImage write SetGetFragmentShaderImage;
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
  { The TGfxDesc record contains configuration values.
    It is used as parameter to the TGfx.Create call.

    NOTE that all callback function pointers come in two versions, one that can
    be implemented in a global function (with a Callback suffix), and one that
    can be implemented in a class (with an Event suffix). You would either
    initialize one or the other.

    FIXME: explain the various configuration options

    The default configuration is:

    .BufferPoolSize         128
    .ImagePoolSize          128
    .ShaderPoolSize         32
    .PipelinePoolSize       64
    .PassPoolSize           16
    .ContextPoolSize        16
    .SamplerCacheSize       64
    .UniformBufferSsize     4 MB (4*1024*1024)
    .StagingBufferSize      8 MB (8*1024*1024)

    .UseDelphiMemoryManager False (instead of using Sokol's internal memory manager)
                            When SOKOL_MEM_TRACK is defined, it always uses
                            Delphi's memory manager.

    .Context.ColorFormat: default value depends on selected backend:
        all GL backends:    TPixelFormat.Rgba8
        Metal and D3D11:    TPixelFormat.Bgra8
    .Context.DepthFormat    TPixelFormat.DepthStencil
    .Context.SampleCount    1

    GL specific:
        .Context.GL.ForceGles2
            if this is True the GL backend will act in "GLES2 fallback mode"
            even when compiled for GLES3.

    Metal specific:
        (NOTE: All Objective-C object references are transferred through a
        bridged (const Pointer) to Sokol, which will use a unretained bridged
        cast to retrieve the Objective-C references back. Since the bridge cast
        is unretained, the caller must hold a strong reference to the
        Objective-C object for the duration of the Sokol call!

        .Context.Metal.Device
            a pointer to the MTLDevice object
        .Context.Metal.RenderpassDescriptorCallback
        .Context.Metal.RenderpassDescriptorEvent
            a callback function to obtain the MTLRenderPassDescriptor for the
            current frame when rendering to the default framebuffer, will be
            called in TGfx.BeginDefaultPass.
        .Context.Metal.DrawableCallback
        .context.Metal.DrawableEvent
            a callback function to obtain a MTLDrawable for the current frame
            when rendering to the default framebuffer, will be called in
            TGfx.EndPass of the default pass

    D3D11 specific:
        .Context.D3D11.Device
            a ID3D11Device object. This must have been created before
            TGfx.Create is called
        .Context.D3D11.DeviceContext
            a ID3D11DeviceContext object
        .Context.D3D11.RenderTargetViewCallback
        .Context.D3D11.RenderTargetViewEvent
            a callback function to obtain the current ID3D11RenderTargetView
            object of the default framebuffer.
            This function will be called in TGfx.BeginPass when rendering
            to the default framebuffer
        .Context.D3D11.DepthStencilViewCallback
        .Context.D3D11.DepthStencilViewEvent
            a callback function to obtain the current ID3D11DepthStencilView
            object of the default framebuffer.
            This function will be called in TGfx.BeginPass when rendering
            to the default framebuffer

    When using Neslib.Sokol.Gfx and Neslib.Sokol.App together, consider using
    the Neslib.Sokol.Glue unit which adds a Context property to the TApplication
    class, which returns TContextDesc record for use with TApplication. }
  TGLContextDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_gl_context_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    ForceGles2: Boolean;
  public
    constructor Create(const AForceGles2: Boolean);
    procedure Init(const AForceGles2: Boolean); inline;
  end;
  PGLContextDesc = ^TGLContextDesc;

  TMetalContextDesc = record
  {$REGION 'Internal Declarations'}
  private class var
    FRenderpassDescriptorCallback: function: Pointer;
    FRenderpassDescriptorEvent: function: Pointer of object;
    FDrawableCallback: function: Pointer;
    FDrawableEvent: function: Pointer of object;
  private
    procedure Convert(out ADst: _sg_metal_context_desc);
  private
    class function StaticRenderPassDescriptorCallback: Pointer; cdecl; static;
    class function StaticDrawableCallback: Pointer; cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    Device: Pointer;
    RenderpassDescriptorCallback: function: Pointer;
    RenderpassDescriptorEvent: function: Pointer of object;
    DrawableCallback: function: Pointer;
    DrawableEvent: function: Pointer of object;
  public
    constructor Create(const ADevice: Pointer);
    procedure Init(const ADevice: Pointer); inline;
  end;
  PMetalContextDesc = ^TMetalContextDesc;

  TD3D11ContextDesc = record
  {$REGION 'Internal Declarations'}
  private class var
    FRenderTargetViewCallback: function: IInterface;
    FRenderTargetViewEvent: function: IInterface of object;
    FDepthStencilViewCallback: function: IInterface;
    FDepthStencilViewEvent: function: IInterface of object;
  private
    procedure Convert(out ADst: _sg_d3d11_context_desc);
  private
    class function StaticRenderTargetViewCallback: Pointer; cdecl; static;
    class function StaticDepthStencilViewCallback: Pointer; cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    Device: IInterface;
    DeviceContext: IInterface;
    RenderTargetViewCallback: function: IInterface;
    RenderTargetViewEvent: function: IInterface of object;
    DepthStencilViewCallback: function: IInterface;
    DepthStencilViewEvent: function: IInterface of object;
  public
    constructor Create(const ADevice, ADeviceContext: IInterface);
    procedure Init(const ADevice, ADeviceContext: IInterface); inline;
  end;
  PD3D11ContextDesc = ^TD3D11ContextDesc;

  TContextDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_context_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    ColorFormat: TPixelFormat;
    DepthFormat: TPixelFormat;
    SampleCount: Integer;
    GL: TGLContextDesc;
    Metal: TMetalContextDesc;
    D3D11: TD3D11ContextDesc;
  public
    constructor Create(const AColorFormat, ADepthFormat: TPixelFormat;
      const ASampleCount: Integer);
    procedure Init(const AColorFormat, ADepthFormat: TPixelFormat;
      const ASampleCount: Integer); inline;
  end;
  PContextDesc = ^TContextDesc;

  TGfxDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sg_desc);
  {$ENDREGION 'Internal Declarations'}
  public
    BufferPoolSize: Integer;
    ImagePoolSize: Integer;
    ShaderPoolSize: Integer;
    PipelinePoolSize: Integer;
    PassPoolSize: Integer;
    ContextPoolSize: Integer;
    UniformBufferSize: Integer;
    StagingBufferSize: Integer;
    SamplerCacheSize: Integer;
    UseDelphiMemoryManager: Boolean;
    Context: TContextDesc;
  public
    class function Create: TGfxDesc; inline; static;
    procedure Init;
  end;
  PGfxDesc = ^TGfxDesc;

type
  { Main entry point to the Sokol graphics library.
    This is a (static) singleton. }
  TGfx = record // static
  {$REGION 'Internal Declarations'}
  private class var
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
    class function GetMetalDevice: Pointer; inline; static;
    class function GetMetalRenderCommandEncoder: Pointer; inline; static;
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
  public
    { Rendering methods }
    class procedure BeginDefaultPass(const APassAction: TPassAction;
      const AWidth, AHeight: Integer); overload; inline; static;
    class procedure BeginDefaultPass(const APassAction: TPassAction;
      const AWidth, AHeight: Single); overload; inline; static;
    class procedure BeginPass(const APass: TPass;
      const APassAction: TPassAction); inline; static;

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
    class procedure ApplyUniforms(const AStage: TShaderStage;
      const AUBIndex: Integer; const AData: TBytes); overload; inline; static;
    class procedure ApplyUniforms(const AStage: TShaderStage;
      const AUBIndex: Integer; const AData: TRange); overload; inline; static;

    class procedure Draw(const ABaseElement, ANumElements: Integer;
      const ANumInstances: Integer = 1); inline; static;
    class procedure EndPass; inline; static;
    class procedure Commit; inline; static;
  public
    { Getting information }
    class property Desc: TGfxDesc read FDesc;
    class property Backend: TBackend read GetBackend;
    class property Features: TFeatures read GetFeatures;
    class property Limits: TLimits read GetLimits;
  public
    { Backend-specific helpers. These may come in handy for mixing Sokol
      rendering with 'native backend' rendering functions.

      This group will be expanded as needed. }

    { D3D11: return ID3D11Device }
    class property D3D11Device: IInterface read GetD3D11Device;

    { Metal: return ObjectID of MTLDevice}
    class property MetalDevice: Pointer read GetMetalDevice;

    { Metal: return ObjectID of MTLRenderCommandEncoder in current pass (or nil
      if outside pass) }
    class property MetalRenderCommandEncoder: Pointer read GetMetalRenderCommandEncoder;
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
  Result := (Self in [TBackend.GLCore33, TBackend.Gles2, TBackend.Gles3]);
end;

{ _TPixelFormatHelper }

function _TPixelFormatHelper.GetBlend: Boolean;
begin
  if (not FHasInfo) then
    InitInfo;

  Result := FInfo[Self].blend;
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

{ TColorAttachmentAction }

constructor TColorAttachmentAction.Create(const AAction: TAction;
  const AValue: TColor);
begin
  Action := AAction;
  Value := AValue;
end;

constructor TColorAttachmentAction.Create(const AAction: TAction; const AR, AG,
  AB, AA: Single);
begin
  Action := AAction;
  Value.R := AR;
  Value.G := AG;
  Value.B := AB;
  Value.A := AA;
end;

procedure TColorAttachmentAction.Init(const AAction: TAction;
  const AValue: TColor);
begin
  Action := AAction;
  Value := AValue;
end;

procedure TColorAttachmentAction.Init(const AAction: TAction; const AR, AG, AB,
  AA: Single);
begin
  Action := AAction;
  Value.R := AR;
  Value.G := AG;
  Value.B := AB;
  Value.A := AA;
end;

{ TDepthAttachmentAction }

constructor TDepthAttachmentAction.Create(const AAction: TAction;
  const AValue: Single);
begin
  Action := AAction;
  Value := AValue;
end;

procedure TDepthAttachmentAction.Init(const AAction: TAction;
  const AValue: Single);
begin
  Action := AAction;
  Value := AValue;
end;

{ TStencilAttachmentAction }

constructor TStencilAttachmentAction.Create(const AAction: TAction;
  const AValue: Byte);
begin
  Action := AAction;
  Value := AValue;
end;

procedure TStencilAttachmentAction.Init(const AAction: TAction;
  const AValue: Byte);
begin
  Action := AAction;
  Value := AValue;
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

{ TBufferDesc }

procedure TBufferDesc.Convert(out ADst: _sg_buffer_desc);
begin
  ADst._start_canary := 0;
  ADst.size := Size;
  ADst.&type := Ord(BufferType);
  ADst.usage := Ord(Usage);
  ADst.data := Data.FHandle;
  if (TraceLabel = '') then
    ADst.&label := nil
  else
    ADst.&label := PUTF8Char(UTF8String(TraceLabel));
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

  var Def: _sg_buffer_desc;
  FillChar(Def, SizeOf(Def), 0);
  Def := _sg_query_buffer_defaults(@Def);

  Size := Def.size;
  BufferType := TBufferType(Def.&type);
  Usage := TUsage(Def.usage);
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

function TBuffer.GetInfo: TBufferInfo;
begin
  Result.FHandle := _sg_query_buffer_info(FHandle);
end;

function TBuffer.GetOverflow: Boolean;
begin
  Result := _sg_query_buffer_overflow(FHandle);
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

function TBuffer.Teardown: Boolean;
begin
  Result := _sg_uninit_buffer(FHandle);
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
  for var Face := Low(TCubeface) to High(TCubeface) do
    for var Mipmap := 0 to MAX_MIPMAPS - 1 do
      ADst.subimage[Ord(Face), Mipmap] := SubImagesCube[Face, Mipmap].FHandle;
end;

class function TImageData.Create: TImageData;
begin
  Result.Init;
end;

function TImageData.GetSubImage(const AMipmapLevel: Integer): TRange;
begin
  Result := SubImagesCube[TCubeFace.PosX, AMipmapLevel];
end;

procedure TImageData.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TImageData.InitFrom(const ASrc: _sg_image_data);
begin
  for var Face := Low(TCubeface) to High(TCubeface) do
    for var Mipmap := 0 to MAX_MIPMAPS - 1 do
      SubImagesCube[Face, Mipmap].FHandle := ASrc.subimage[Ord(Face), Mipmap];
end;

procedure TImageData.SubImage(const AMipmapLevel: Integer; const AValue: TRange);
begin
  SubImagesCube[TCubeFace.PosX, AMipmapLevel] := AValue;
end;

{ TImageDesc }

procedure TImageDesc._Convert(out ADst: _sg_image_desc);
begin
  ADst._start_canary := 0;
  ADst.&type := Ord(ImageType);
  ADst.render_target := RenderTarget;
  ADst.width := Width;
  ADst.height := Height;
  ADst.num_slices := NumSlices;
  ADst.num_mipmaps := NumMipmaps;
  ADst.usage := Ord(Usage);
  ADst.pixel_format := Ord(PixelFormat);
  ADst.sample_count := SampleCount;
  ADst.min_filter := Ord(MinFilter);
  ADst.mag_filter := Ord(MagFilter);
  ADst.wrap_u := Ord(WrapU);
  ADst.wrap_v := Ord(WrapV);
  ADst.wrap_w := Ord(WrapW);
  ADst.border_color := Ord(BorderColor);
  ADst.max_anisotropy := MaxAnisotropy;
  ADst.min_lod := MinLod;
  ADst.max_lod := MaxLod;
  Data.Convert(ADst.data);
  if (TraceLabel = '') then
    ADst.&label := nil
  else
    ADst.&label := PUTF8Char(UTF8String(TraceLabel));
  Move(GLTextures, ADst.gl_textures, SizeOf(GLTextures));
  ADst.gl_texture_target := GLTextureTarget;
  Move(MetalTextures, ADst.mtl_textures, SizeOf(GLTextures));
  ADst.d3d11_texture := Pointer(D3D11Texture);
  ADst.d3d11_shader_resource_view := Pointer(D3D11ShaderResourceView);
  ADst.wgpu_texture := nil;
  ADst._end_canary := 0;
end;

procedure TImageDesc._InitFrom(out ASrc: _sg_image_desc);
begin
  ImageType := TImageType(ASrc.&type);
  RenderTarget := ASrc.render_target;
  Width := ASrc.width;
  Height := ASrc.height;
  NumSlices := ASrc.num_slices;
  NumMipmaps := ASrc.num_mipmaps;
  Usage := TUsage(ASrc.usage);
  PixelFormat := TPixelFormat(ASrc.pixel_format);
  SampleCount := ASrc.sample_count;
  MinFilter := TFilter(ASrc.min_filter);
  MagFilter := TFilter(ASrc.mag_filter);
  WrapU := TWrap(ASrc.wrap_u);
  WrapV := TWrap(ASrc.wrap_v);
  WrapW := TWrap(ASrc.wrap_w);
  BorderColor := TBorderColor(ASrc.border_color);
  MaxAnisotropy := ASrc.max_anisotropy;
  MinLod := ASrc.min_lod;
  MaxLod := ASrc.max_lod;
  Data.InitFrom(ASrc.data);
  TraceLabel := String(UTF8String(ASrc.&label));
  Move(ASrc.gl_textures, GLTextures, SizeOf(GLTextures));
  GLTextureTarget := ASrc.gl_texture_target;
  Move(ASrc.mtl_textures, MetalTextures, SizeOf(MetalTextures));
  D3D11Texture := IInterface(ASrc.d3d11_texture);
  D3D11ShaderResourceView := IInterface(ASrc.d3d11_shader_resource_view);
end;

class function TImageDesc.Create: TImageDesc;
begin
  Result.Init;
end;

procedure TImageDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);

  var Def: _sg_image_desc;
  FillChar(Def, SizeOf(Def), 0);
  Def := _sg_query_image_defaults(@Def);

  ImageType := TImageType(Def.&type);
  RenderTarget := Def.render_target;
  Width := Def.width;
  Height := Def.height;
  NumSlices := Def.num_slices;
  NumMipmaps := Def.num_mipmaps;
  Usage := TUsage(Def.usage);
//  PixelFormat := TPixelFormat(Def.pixel_format); // Will be set to default later
//  SampleCount := Def.sample_count; // Will be set to default later
  MinFilter := TFilter(Def.min_filter);
  MagFilter := TFilter(Def.mag_filter);
  WrapU := TWrap(Def.wrap_u);
  WrapV := TWrap(Def.wrap_v);
  WrapW := TWrap(Def.wrap_w);
  BorderColor := TBorderColor(Def.border_color);
  MaxAnisotropy := Def.max_anisotropy;
  MinLod := Def.min_lod;
  MaxLod := Def.max_lod;
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

function TImage.GetInfo: TImageInfo;
begin
  Result.FHandle := _sg_query_image_info(FHandle);
end;

function TImage.GetState: TResourceState;
begin
  Result := TResourceState(_sg_query_image_state(FHandle));
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

function TImage.Teardown: Boolean;
begin
  Result := _sg_uninit_image(FHandle);
end;

procedure TImage.Update(const AData: TImageData);
begin
  var Data: _sg_image_data;
  AData.Convert(Data);
  _sg_update_image(FHandle, @Data);
end;

{ TShaderAttrDesc }

procedure TShaderAttrDesc.Convert(out ADst: _sg_shader_attr_desc);
begin
  ADst.name := PUTF8Char(UTF8String(Name));
  ADst.sem_name := PUTF8Char(UTF8String(SemanticName));
  ADst.sem_index := SemanticIndex;
end;

constructor TShaderAttrDesc.Create(const AName, ASemanticName: String;
  const ASemanticIndex: Integer);
begin
  Init(AName, ASemanticName, ASemanticIndex);
end;

procedure TShaderAttrDesc.Init(const AName, ASemanticName: String;
  const ASemanticIndex: Integer);
begin
  Name := AName;
  SemanticName := ASemanticName;
  SemanticIndex := ASemanticIndex;
end;

{ TShaderUniformDesc }

procedure TShaderUniformDesc.Convert(out ADst: _sg_shader_uniform_desc);
begin
  ADst.name := PUTF8Char(UTF8String(Name));
  ADst.&type := Ord(UniformType);
  ADst.array_count := ArrayCount;
end;

constructor TShaderUniformDesc.Create(const AName: String;
  const AUniformType: TUniformType; const AArrayCount: Integer);
begin
  Init(AName, AUniformType, AArrayCount);
end;

procedure TShaderUniformDesc.Init(const AName: String;
  const AUniformType: TUniformType; const AArrayCount: Integer);
begin
  Name := AName;
  UniformType := AUniformType;
  ArrayCount := AArrayCount;
end;

{ TShaderUniformBlockDesc }

procedure TShaderUniformBlockDesc.Convert(
  out ADst: _sg_shader_uniform_block_desc);
begin
  ADst.size := Size;
  ADst.layout := Ord(Layout);
  for var I := 0 to MAX_UB_MEMBERS - 1 do
    Uniforms[I].Convert(ADst.uniforms[I]);
end;

constructor TShaderUniformBlockDesc.Create(const ASize: NativeUInt;
  const ALayout: TUniformLayout);
begin
  Init(ASize, ALayout);
end;

procedure TShaderUniformBlockDesc.Init(const ASize: NativeUInt;
  const ALayout: TUniformLayout);
begin
  Size := ASize;
  Layout := ALayout;
end;

{ TShaderImageDesc }

procedure TShaderImageDesc.Convert(out ADst: _sg_shader_image_desc);
begin
  ADst.name := PUTF8Char(UTF8String(Name));
  ADst.image_type := Ord(ImageType);
  ADst.sampler_type := Ord(SamplerType);
end;

constructor TShaderImageDesc.Create(const AName: String;
  const AImageType: TImageType; const ASamplerType: TSamplerType);
begin
  Init(AName, AImageType, ASamplerType);
end;

procedure TShaderImageDesc.Init(const AName: String;
  const AImageType: TImageType; const ASamplerType: TSamplerType);
begin
  Name := AName;
  ImageType := AImageType;
  SamplerType := ASamplerType;
end;

{ TShaderStageDesc }

procedure TShaderStageDesc.Convert(out ADst: _sg_shader_stage_desc);
begin
  ADst.source := PUTF8Char(UTF8String(Source));
  ADst.bytecode := Bytecode.FHandle;
  ADst.entry := PUTF8Char(UTF8String(Entry));
  ADst.d3d11_target := PUTF8Char(UTF8String(D3D11Target));

  for var I := 0 to MAX_SHADERSTAGE_UBS - 1 do
    UniformBlocks[I].Convert(ADst.uniform_blocks[I]);

  for var I := 0 to MAX_SHADERSTAGE_IMAGES - 1 do
    Images[I].Convert(ADst.images[I]);
end;

constructor TShaderStageDesc.Create(const ASource: String;
  const ABytecode: TRange; const AEntry, AD3D11Target: String);
begin
  Init(ASource, ABytecode, AEntry, AD3D11Target);
end;

procedure TShaderStageDesc.Init(const ASource: String; const ABytecode: TRange;
  const AEntry, AD3D11Target: String);
begin
  Source := ASource;
  Bytecode := ABytecode;
  Entry := AEntry;
  D3D11Target := AD3D11Target;
end;

{ TShaderDesc }

procedure TShaderDesc.Convert(out ADst: _sg_shader_desc);
begin
  ADst._start_canary := 0;

  for var I := 0 to MAX_VERTEX_ATTRIBUTES - 12 do
    Attrs[I].Convert(ADst.attrs[I]);

  VertexShader.Convert(ADst.vs);
  FragmentShader.Convert(ADst.fs);
  if (TraceLabel = '') then
    ADst.&label := nil
  else
    ADst.&label := PUTF8Char(UTF8String(TraceLabel));
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

  var SrcStage: _Psg_shader_stage_desc := @Def.vs;
  var DstStage: PShaderStageDesc := @VertexShader;
  for var StageIdx := 0 to 1 do
  begin
    DstStage.Entry := String(UTF8String(SrcStage.entry));
    DstStage.D3D11Target := String(UTF8String(SrcStage.d3d11_target));

    for var UBIdx := 0 to MAX_SHADERSTAGE_UBS - 1 do
    begin
      DstStage.UniformBlocks[UBIdx].Size := SrcStage.uniform_blocks[UBIdx].size;
      DstStage.UniformBlocks[UBIdx].Layout := TUniformLayout(SrcStage.uniform_blocks[UBIdx].layout);

      for var UIdx := 0 to MAX_UB_MEMBERS - 1 do
        DstStage.UniformBlocks[UBIdx].Uniforms[UIdx].ArrayCount := SrcStage.uniform_blocks[UBIdx].uniforms[UIdx].array_count;
    end;

    for var ImgIdx := 0 to MAX_SHADERSTAGE_IMAGES - 1 do
      DstStage.Images[ImgIdx].SamplerType := TSamplerType(SrcStage.images[ImgIdx].sampler_type);

    SrcStage := @Def.fs;
    DstStage := @FragmentShader;
  end;
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

function TShader.GetInfo: TShaderInfo;
begin
  Result.FHandle := _sg_query_shader_info(FHandle);
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

function TShader.Teardown: Boolean;
begin
  Result := _sg_uninit_shader(FHandle);
end;

{ _sg_shader_attr_desc_helper }

procedure _sg_shader_attr_desc_helper.Init(const AName, ASemanticName: PUTF8Char;
  const ASemanticIndex: Integer);
begin
  name := AName;
  sem_name := ASemanticName;
  sem_index := ASemanticIndex;
end;

{ _sg_shader_desc_helper }

procedure _sg_shader_desc_helper.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
  if (TGfx.Backend in [TBackend.MetalIOS, TBackend.MetalMacOS]) then
  begin
    vs.entry := 'main0';
    fs.entry := 'main0';
  end
  else
  begin
    vs.entry := 'main';
    fs.entry := 'main';
  end;

  if (TGfx.Backend = TBackend.D3D11) then
  begin
    vs.d3d11_target := 'vs_5_0';
    fs.d3d11_target := 'ps_5_0';
  end;
end;

{ _sg_shader_image_desc_helper }

procedure _sg_shader_image_desc_helper.Init(const AName: PUTF8Char;
  const AImageType: _sg_image_type; const ASamplerType: _sg_sampler_type);
begin
  name := AName;
  image_type := AImageType;
  sampler_type := ASamplerType;
end;

{ _sg_shader_uniform_desc_helper }

procedure _sg_shader_uniform_desc_helper.Init(const AName: PUTF8Char;
  const AType: _sg_uniform_type; const AArrayCount: Integer);
begin
  name := AName;
  &type := AType;
  array_count := AArrayCount;
end;

{ TBufferLayoutDesc }

procedure TBufferLayoutDesc.Convert(out ADst: _sg_buffer_layout_desc);
begin
  ADst.stride := Stride;
  ADst.step_func := Ord(StepFunc);
  ADst.step_rate := StepRate;
end;

constructor TBufferLayoutDesc.Create(const AStride: Integer;
  const AStepFunc: TVertexStep; const AStepRate: Integer);
begin
  Init(AStride, AStepFunc, AStepRate);
end;

procedure TBufferLayoutDesc.Init(const AStride: Integer;
  const AStepFunc: TVertexStep; const AStepRate: Integer);
begin
  Stride := AStride;
  StepFunc := AStepFunc;
  StepRate := AStepRate;
end;

{ TVertexAttrDesc }

procedure TVertexAttrDesc.Convert(out ADst: _sg_vertex_attr_desc);
begin
  ADst.buffer_index := BufferIndex;
  ADst.offset := Offset;
  ADst.format := Ord(Format);
end;

constructor TVertexAttrDesc.Create(const ABufferIndex, AOffset: Integer;
  const AFormat: TVertexFormat);
begin
  Init(ABufferIndex, AOffset, AFormat);
end;

procedure TVertexAttrDesc.Init(const ABufferIndex, AOffset: Integer;
  const AFormat: TVertexFormat);
begin
  BufferIndex := ABufferIndex;
  Offset := AOffset;
  Format := AFormat;
end;

{ TLayoutDesc }

procedure TLayoutDesc.Convert(out ADst: _sg_layout_desc);
begin
  for var I := 0 to MAX_SHADERSTAGE_BUFFERS - 1 do
    Buffers[I].Convert(ADst.buffers[I]);

  for var I := 0 to MAX_VERTEX_ATTRIBUTES - 1 do
    Attrs[I].Convert(ADst.attrs[I]);
end;

class function TLayoutDesc.Create: TLayoutDesc;
begin
  Result.Init;
end;

procedure TLayoutDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
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

{ TColorState }

procedure TColorState.Convert(out ADst: _sg_color_state);
begin
  ADst.pixel_format := Ord(PixelFormat);
  ADst.write_mask := Ord(WriteMask);
  Blend.Convert(ADst.blend);
end;

constructor TColorState.Create(const APixelFormat: TPixelFormat;
  const AWriteMask: TColorMask);
begin
  Init(APixelFormat, AWriteMask);
end;

procedure TColorState.Init(const APixelFormat: TPixelFormat;
  const AWriteMask: TColorMask);
begin
  PixelFormat := APixelFormat;
  WriteMask := AWriteMask;
  FillChar(Blend, SizeOf(Blend), 0);
end;

{ TPipelineDesc }

procedure TPipelineDesc._Convert(out ADst: _sg_pipeline_desc);
begin
  ADst._start_canary := 0;
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
  if (TraceLabel = '') then
    ADst.&label := nil
  else
    ADst.&label := PUTF8Char(UTF8String(TraceLabel));
  ADst._end_canary := 0;
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

function TPipeline.GetInfo: TPipelineInfo;
begin
  Result.FHandle := _sg_query_pipeline_info(FHandle);
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

function TPipeline.Teardown: Boolean;
begin
  Result := _sg_uninit_pipeline(FHandle);
end;

{ TPassAttachmentDesc }

procedure TPassAttachmentDesc.Convert(out ADst: _sg_pass_attachment_desc);
begin
  ADst.image := Image.FHandle;
  ADst.mip_level := MipLevel;
  ADst.slice := Slice;
end;

constructor TPassAttachmentDesc.Create(const AMipLevel, ASlice: Integer);
begin
  Init(AMipLevel, ASlice);
end;

procedure TPassAttachmentDesc.Init(const AMipLevel, ASlice: Integer);
begin
  MipLevel := AMipLevel;
  Slice := ASlice;
end;

{ TPassDesc }

procedure TPassDesc.Convert(out ADst: _sg_pass_desc);
begin
  ADst._start_canary := 0;
  for var I := 0 to MAX_COLOR_ATTACHMENTS - 1 do
    ColorAttachments[I].Convert(ADst.color_attachments[I]);

  DepthStencilAttachment.Convert(ADst.depth_stencil_attachment);
  if (TraceLabel = '') then
    ADst.&label := nil
  else
    ADst.&label := PUTF8Char(UTF8String(TraceLabel));
  ADst._end_canary := 0;
end;

class function TPassDesc.Create: TPassDesc;
begin
  Result.Init;
end;

procedure TPassDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);

  { All defaults are currently 0
  var Def: _sg_pass_desc;
  FillChar(Def, SizeOf(Def), 0);
  Def := _sg_query_pass_defaults(@Def); }
end;

{ TPass }

procedure TPass.Allocate;
begin
  FHandle := _sg_alloc_pass;
end;

constructor TPass.Create(const ADesc: TPassDesc);
begin
  Init(ADesc);
end;

procedure TPass.Deallocate;
begin
  _sg_dealloc_pass(FHandle);
end;

procedure TPass.Fail;
begin
  _sg_fail_pass(FHandle);
end;

procedure TPass.Free;
begin
  _sg_destroy_pass(FHandle);
  FHandle.id := 0;
end;

function TPass.GetInfo: TPassInfo;
begin
  Result.FHandle := _sg_query_pass_info(FHandle);
end;

function TPass.GetState: TResourceState;
begin
  Result := TResourceState(_sg_query_pass_state(FHandle));
end;

procedure TPass.Init(const ADesc: TPassDesc);
begin
  var Desc: _sg_pass_desc;
  ADesc.Convert(Desc);
  FHandle := _sg_make_pass(@Desc);
end;

procedure TPass.Setup(const ADesc: TPassDesc);
begin
  var Desc: _sg_pass_desc;
  ADesc.Convert(Desc);
  _sg_init_pass(FHandle, @Desc);
end;

function TPass.Teardown: Boolean;
begin
  Result := _sg_uninit_pass(FHandle);
end;

{ TContext }

procedure TContext.Activate;
begin
  _sg_activate_context(FHandle);
end;

class function TContext.Create: TContext;
begin
  Result.Init;
end;

procedure TContext.Free;
begin
  _sg_discard_context(FHandle);
  FHandle.id := 0;
end;

procedure TContext.Init;
begin
  FHandle := _sg_setup_context;
end;

{ TBindings }

class function TBindings.Create: TBindings;
begin
  Result.Init;
end;

function TBindings.GetFragmentShaderImage(const AIndex: Integer): TImage;
begin
  Assert(Cardinal(AIndex) < MAX_SHADERSTAGE_IMAGES);
  Result := TImage(FHandle.fs_images[AIndex]);
end;

function TBindings.GetIndexBuffer: TBuffer;
begin
  Result := TBuffer(FHandle.index_buffer);
end;

function TBindings.GetVertexBuffer(const AIndex: Integer): TBuffer;
begin
  Assert(Cardinal(AIndex) < MAX_SHADERSTAGE_BUFFERS);
  Result := TBuffer(FHandle.vertex_buffers[AIndex]);
end;

function TBindings.GetVertexBufferOffset(const AIndex: Integer): Integer;
begin
  Assert(Cardinal(AIndex) < MAX_SHADERSTAGE_BUFFERS);
  Result := FHandle.vertex_buffer_offsets[AIndex];
end;

function TBindings.GetVertexShaderImage(const AIndex: Integer): TImage;
begin
  Assert(Cardinal(AIndex) < MAX_SHADERSTAGE_IMAGES);
  Result := TImage(FHandle.vs_images[AIndex]);
end;

procedure TBindings.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TBindings.SetGetFragmentShaderImage(const AIndex: Integer;
  const AValue: TImage);
begin
  Assert(Cardinal(AIndex) < MAX_SHADERSTAGE_IMAGES);
  FHandle.fs_images[AIndex] := _sg_image(AValue);
end;

procedure TBindings.SetGetVertexShaderImage(const AIndex: Integer;
  const AValue: TImage);
begin
  Assert(Cardinal(AIndex) < MAX_SHADERSTAGE_IMAGES);
  FHandle.vs_images[AIndex] := _sg_image(AValue);
end;

procedure TBindings.SetIndexBuffer(const AValue: TBuffer);
begin
  FHandle.index_buffer := _sg_buffer(AValue);
end;

procedure TBindings.SetVertexBuffer(const AIndex: Integer;
  const AValue: TBuffer);
begin
  Assert(Cardinal(AIndex) < MAX_SHADERSTAGE_BUFFERS);
  FHandle.vertex_buffers[AIndex] := _sg_buffer(AValue);
end;

procedure TBindings.SetVertexBufferOffset(const AIndex, AValue: Integer);
begin
  Assert(Cardinal(AIndex) < MAX_SHADERSTAGE_BUFFERS);
  FHandle.vertex_buffer_offsets[AIndex] := AValue;
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

{ TPassInfo }

function TPassInfo.GetSlot: TSlotInfo;
begin
  Result.FHandle := FHandle.slot;
end;

{ TGLContextDesc }

procedure TGLContextDesc.Convert(out ADst: _sg_gl_context_desc);
begin
  ADst.force_gles2 := ForceGles2;
end;

constructor TGLContextDesc.Create(const AForceGles2: Boolean);
begin
  Init(AForceGles2);
end;

procedure TGLContextDesc.Init(const AForceGles2: Boolean);
begin
  ForceGles2 := AForceGles2;
end;

{ TMetalContextDesc }

procedure TMetalContextDesc.Convert(out ADst: _sg_metal_context_desc);
begin
  ADst.device := Device;

  if Assigned(RenderpassDescriptorCallback) or Assigned(RenderpassDescriptorEvent) then
  begin
    FRenderpassDescriptorCallback := RenderpassDescriptorCallback;
    FRenderpassDescriptorEvent := RenderpassDescriptorEvent;
    ADst.renderpass_descriptor_cb := StaticRenderPassDescriptorCallback;
  end
  else
    ADst.renderpass_descriptor_cb := nil;
  ADst.renderpass_descriptor_userdata_cb := nil;

  if Assigned(DrawableCallback) or Assigned(DrawableEvent) then
  begin
    FDrawableCallback := DrawableCallback;
    FDrawableEvent := DrawableEvent;
    ADst.drawable_cb := StaticDrawableCallback;
  end
  else
    ADst.drawable_cb := nil;
  ADst.drawable_userdata_cb := nil;
  ADst.user_data := nil;
end;

constructor TMetalContextDesc.Create(const ADevice: Pointer);
begin
  Init(ADevice);
end;

procedure TMetalContextDesc.Init(const ADevice: Pointer);
begin
  FillChar(Self, SizeOf(Self), 0);
  Device := ADevice;
end;

class function TMetalContextDesc.StaticDrawableCallback: Pointer;
begin
  if Assigned(FDrawableCallback) then
    Result := FDrawableCallback()
  else
  begin
    Assert(Assigned(FDrawableEvent));
    Result := FDrawableEvent();
  end;
end;

class function TMetalContextDesc.StaticRenderPassDescriptorCallback: Pointer;
begin
  if Assigned(FRenderpassDescriptorCallback) then
    Result := FRenderpassDescriptorCallback()
  else
  begin
    Assert(Assigned(FRenderpassDescriptorEvent));
    Result := FRenderpassDescriptorEvent();
  end;
end;

{ TD3D11ContextDesc }

procedure TD3D11ContextDesc.Convert(out ADst: _sg_d3d11_context_desc);
begin
  ADst.device := Pointer(Device);
  ADst.device_context := Pointer(DeviceContext);

  if Assigned(RenderTargetViewCallback) or Assigned(RenderTargetViewEvent) then
  begin
    FRenderTargetViewCallback := RenderTargetViewCallback;
    FRenderTargetViewEvent := RenderTargetViewEvent;
    ADst.render_target_view_cb := StaticRenderTargetViewCallback;
  end
  else
    ADst.render_target_view_cb := nil;
  ADst.render_target_view_userdata_cb := nil;

  if Assigned(DepthStencilViewCallback) or Assigned(DepthStencilViewEvent) then
  begin
    FDepthStencilViewCallback := DepthStencilViewCallback;
    FDepthStencilViewEvent := DepthStencilViewEvent;
    ADst.depth_stencil_view_cb := StaticDepthStencilViewCallback;
  end
  else
    ADst.depth_stencil_view_cb := nil;
  ADst.depth_stencil_view_userdata_cb := nil;
  ADst.user_data := nil;
end;

constructor TD3D11ContextDesc.Create(const ADevice, ADeviceContext: IInterface);
begin
  Init(ADevice, ADeviceContext);
end;

procedure TD3D11ContextDesc.Init(const ADevice, ADeviceContext: IInterface);
begin
  FillChar(Self, SizeOf(Self), 0);
  Device := ADevice;
  DeviceContext := ADeviceContext;
end;

class function TD3D11ContextDesc.StaticDepthStencilViewCallback: Pointer;
begin
  if Assigned(FDepthStencilViewCallback) then
    Result := FDepthStencilViewCallback()
  else
  begin
    Assert(Assigned(FDepthStencilViewEvent));
    Result := FDepthStencilViewEvent();
  end;
end;

class function TD3D11ContextDesc.StaticRenderTargetViewCallback: Pointer;
begin
  if Assigned(FRenderTargetViewCallback) then
    Result := FRenderTargetViewCallback()
  else
  begin
    Assert(Assigned(FRenderTargetViewEvent));
    Result := FRenderTargetViewEvent();
  end;
end;

{ TContextDesc }

procedure TContextDesc.Convert(out ADst: _sg_context_desc);
begin
  ADst.color_format := Ord(ColorFormat);
  ADst.depth_format := Ord(DepthFormat);
  ADst.sample_count := SampleCount;
  GL.Convert(ADst.gl);
  Metal.Convert(ADst.metal);
  D3D11.Convert(ADst.d3d11);
end;

constructor TContextDesc.Create(const AColorFormat, ADepthFormat: TPixelFormat;
  const ASampleCount: Integer);
begin
  Init(AColorFormat, ADepthFormat, ASampleCount);
end;

procedure TContextDesc.Init(const AColorFormat, ADepthFormat: TPixelFormat;
  const ASampleCount: Integer);
begin
  FillChar(Self, SizeOf(Self), 0);
  ColorFormat := AColorFormat;
  DepthFormat := ADepthFormat;
  SampleCount := ASampleCount;
end;

{ TGfxDesc }

procedure TGfxDesc.Convert(out ADst: _sg_desc);
begin
  ADst._start_canary := 0;
  ADst.buffer_pool_size := BufferPoolSize;
  ADst.image_pool_size := ImagePoolSize;
  ADst.shader_pool_size := ShaderPoolSize;
  ADst.pipeline_pool_size := PipelinePoolSize;
  ADst.pass_pool_size := PassPoolSize;
  ADst.context_pool_size := ContextPoolSize;
  ADst.uniform_buffer_size := UniformBufferSize;
  ADst.staging_buffer_size := StagingBufferSize;
  ADst.sampler_cache_size := SamplerCacheSize;
  {$IFDEF SOKOL_MEM_TRACK}
  ADst.allocator.alloc := _MemTrackAlloc;
  ADst.allocator.free := _MemTrackFree;
  {$ELSE}
  if (UseDelphiMemoryManager) then
  begin
    ADst.allocator.alloc := _AllocCallback;
    ADst.allocator.free := _FreeCallback;
  end
  else
  begin
    ADst.allocator.alloc := nil;
    ADst.allocator.free := nil;
  end;
  {$ENDIF}
  ADst.allocator.user_data := nil;
  Context.Convert(ADst.context);
  ADst._end_canary := 0;
end;

class function TGfxDesc.Create: TGfxDesc;
begin
  Result.Init;
end;

procedure TGfxDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
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

class procedure TGfx.ApplyUniforms(const AStage: TShaderStage;
  const AUBIndex: Integer; const AData: TRange);
begin
  _sg_apply_uniforms(Ord(AStage), AUBIndex, @AData.FHandle);
end;

class procedure TGfx.ApplyUniforms(const AStage: TShaderStage;
  const AUBIndex: Integer; const AData: TBytes);
begin
  var Data: _sg_range;
  Data.ptr := Pointer(AData);
  Data.size := Length(AData);
  _sg_apply_uniforms(Ord(AStage), AUBIndex, @Data);
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

class procedure TGfx.BeginDefaultPass(const APassAction: TPassAction;
  const AWidth, AHeight: Integer);
begin
  _sg_begin_default_pass(@APassAction.FHandle, AWidth, AHeight);
end;

class procedure TGfx.BeginDefaultPass(const APassAction: TPassAction;
  const AWidth, AHeight: Single);
begin
  _sg_begin_default_passf(@APassAction.FHandle, AWidth, AHeight);
end;

class procedure TGfx.BeginPass(const APass: TPass;
  const APassAction: TPassAction);
begin
  _sg_begin_pass(APass.FHandle, @APassAction.FHandle);
end;

class procedure TGfx.Commit;
begin
  _sg_commit;
end;

class procedure TGfx.DoGetFeatures;
begin
  var Features := _sg_query_features;
  if (Features.instancing) then
    Include(FFeatures, TFeature.Instancing);
  if (Features.origin_top_left) then
    Include(FFeatures, TFeature.OriginTopLeft);
  if (Features.multiple_render_targets) then
    Include(FFeatures, TFeature.MultipleRenderTargets);
  if (Features.msaa_render_targets) then
    Include(FFeatures, TFeature.MsaaRenderTargets);
  if (Features.imagetype_3d) then
    Include(FFeatures, TFeature.ImageType3D);
  if (Features.imagetype_array) then
    Include(FFeatures, TFeature.ImageTypeArray);
  if (Features.image_clamp_to_border) then
    Include(FFeatures, TFeature.ImageClampToBorder);
  if (Features.mrt_independent_blend_state) then
    Include(FFeatures, TFeature.MrtIndependentBlendState);
  if (Features.mrt_independent_write_mask) then
    Include(FFeatures, TFeature.MrtIndependentWriteMask);
end;

class procedure TGfx.Draw(const ABaseElement, ANumElements,
  ANumInstances: Integer);
begin
  _sg_draw(ABaseElement, ANumElements, ANumInstances);
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

class function TGfx.GetMetalDevice: Pointer;
begin
  Result := _sg_mtl_device;
end;

class function TGfx.GetMetalRenderCommandEncoder: Pointer;
begin
  Result := _sg_mtl_render_command_encoder;
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

class procedure TGfx.ResetCache;
begin
  _sg_reset_state_cache;
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
  Assert(SizeOf(TAction) = 4);
  Assert(SizeOf(TColorAttachmentAction) = SizeOf(_sg_color_attachment_action));
  Assert(SizeOf(TDepthAttachmentAction) = SizeOf(_sg_depth_attachment_action));
  Assert(SizeOf(TStencilAttachmentAction) = SizeOf(_sg_stencil_attachment_action));

end.

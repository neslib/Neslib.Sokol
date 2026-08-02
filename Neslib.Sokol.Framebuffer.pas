unit Neslib.Sokol.Framebuffer;
{ Pixel framebuffer for CPU rendering.

  For a user guide, check out the Neslib.Sokol.Framebuffer.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.Framebuffer.md }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.Sokol.Api,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Types;

type
  { The state of a framebuffer object, obtainable via TFramebuffer.State }
  TFramebufferResourceState = (
    Initial = _SFB_RESOURCESTATE_INITIAL,
    Valid   = _SFB_RESOURCESTATE_VALID,
    Failed  = _SFB_RESOURCESTATE_FAILED);

type
  { The framebuffer pixel format. Either RGBA8 direct color where each pixel is
    an UInt32, or paletted format with UInt8 pixels as index into a 256 entry
    color palette. }
  TFramebufferFormat = (
    Default  = __SFB_FORMAT_DEFAULT,
    Rgba8    = _SFB_FORMAT_RGBA8,
    Palette8 = _SFB_FORMAT_PALETTE8);

type
  { Used as clipping rectangle in TFramebufferDesc and TFramebufferResizeDesc. }
  TFramebufferRect = record
  public
    X: Integer;
    Y: Integer;
    Width: Integer;
    Height: Integer;
  end;
  PFramebufferRect = ^TFramebufferRect;

type
  { Describes render pass properties in a TFramebufferDesc (color- and depth-
    pixel-format, sample count). This is used to create the TPipeline objects
    applied in the render functions. When rendering to a default swapchain all
    the values can remain at default (zero). }
  TFramebufferRenderPassDesc = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sfb_render_pass_desc;
    function GetColorFormat: TPixelFormat;
    function GetDepthFormat: TPixelFormat;
    procedure SetColorFormat(const AValue: TPixelFormat);
    procedure SetDepthFormat(const AValue: TPixelFormat);
  {$ENDREGION 'Internal Declarations'}
  public
    { Initialize with default values }
    class function Create: TFramebufferRenderPassDesc; static;
    procedure Init; inline;

    property ColorFormat: TPixelFormat read GetColorFormat write SetColorFormat;
    property DepthFormat: TPixelFormat read GetDepthFormat write SetDepthFormat;
    property SampleCount: Integer read FHandle.sample_count write FHandle.sample_count;
  end;
  PFramebufferRenderPassDesc = ^TFramebufferRenderPassDesc;

type
  { Creation parameters for a framebuffer object.
    Passed into TFramebuffer.Create. }
  TFramebufferDesc = record
  public
    { Width in pixels, must be provided }
    Width: Integer;

    { Height in pixels, must be provided }
    Height: Integer;

    { Bilinear-prefiltered prescale factor.
      Default: 1 }
    Prescale: Integer;

    { Framebuffer pixel format.
      Default: Rgba8 }
    Format: TFramebufferFormat;

    { An optional sub-rectangle of the framebuffer with the visible data }
    Cliprect: TFramebufferRect;

    { When true, framebuffer is rotated 90 degree during TFramebuffer.Render }
    Rotate90: Boolean;

    { Pixel formats and sample count of Neslib.Sokol.Gfx render pass.
      Defaults: use Neslib.Sokol.Gfx defaults }
    RenderPass: TFramebufferRenderPassDesc;
  public
    { Initialize with default values }
    class function Create: TFramebufferDesc; static;
    procedure Init; inline;
  end;
  PFramebufferDesc = ^TFramebufferDesc;

type
  { Parameters for TFramebuffer.Resize. Needs to be called before
    TFramebuffer.Update in a frame with potentially new framebuffer size
    parameters or clipping rectangle. Note that the TFramebuffer.Resize method
    can be called even when no resizing needs to happen. In that case the method
    will be a silent no-op and return False. When the method returns True this
    means that internal image objects had been recreated and need to be
    repopulated again via TFramebuffer.Update.

    Resizing is slightly cheaper than destroying and creating the frambuffer
    because only image objects needs to be re-created, but no pipeline objects. }
  TFramebufferResizeDesc = record
  public
    Width: Integer;
    Height: Integer;
    Prescale: Integer;
    Cliprect: TFramebufferRect;
  public
    { Initialize with default values }
    class function Create: TFramebufferResizeDesc; static;
    procedure Init; inline;
  end;
  PFramebufferResizeDesc = ^TFramebufferResizeDesc;

type
  { Passed into TFramebuffer.Update to update the pixel-date and/or
    color-palette-data. The Update method should only be called when any of the
    above actually changes, at most once per frame, and outside any
    Neslib.Sokol.Gfx pass. }
  TFramebufferUpdateDesc = record
  public
    { Pointer to and size-in-bytes of the updated pixel data }
    Pixels: TRange;

    { Pointer to and size-in-bytes of the updated color palette }
    Palette: TRange;
  public
    { Initialize with default values }
    class function Create: TFramebufferUpdateDesc; static;
    procedure Init; inline;
  end;
  PFramebufferUpdateDesc = ^TFramebufferUpdateDesc;

type
  { Passed into TFramebuffer.Render to override the default shader. Mainly
    useful to inject custom shaders (like CRT shaders). }
  TFramebufferRenderDesc = record
  public
    { Use nearest filtering instead of the default linear filtering }
    UseNearestFilter: Boolean;

    { Override the TPipeline object (and implicitly: shader object) }
    Pip: TPipeline;

    { Provide additional view bindings }
    Views: array [0..MAX_VIEW_BINDSLOTS - 1] of TView;

    { Provide additional samplers }
    Samplers: array [0..MAX_SAMPLER_BINDSLOTS - 1] of TSampler;

    { Provide additional uniform data }
    Uniforms: array [0..MAX_UNIFORMBLOCK_BINDSLOTS - 1] of TRange;
  public
    { Initialize with default values }
    class function Create: TFramebufferRenderDesc; static;
    procedure Init; inline;
  end;
  PFramebufferRenderDesc = ^TFramebufferRenderDesc;

type
  { Nested record in TFramebufferInfo to describe the properties of an internal
    image/view pair. }
  TFramebufferTextureInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sfb_texture_info;
    function GetImage: TImage; inline;
    function GetPixelFormat: TPixelFormat; inline;
    function GetTexView: TView; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    property Width: Integer read FHandle.width;
    property Height: Integer read FHandle.Height;
    property PixelFormat: TPixelFormat read GetPixelFormat;
    property Image: TImage read GetImage;
    property TexView: TView read GetTexView;
  end;
  PFramebufferTextureInfo = ^TFramebufferTextureInfo;

type
  { Result of TFramebuffer.Info. Returns handles to the internally managed
    images, texture views and samplers, image sizes and pixel formats. This is
    mostly useful when completely replacing the TFramebuffer.Render method with
    a complete custom implementation (like a CRT shader which requires multiple
    render passes). }
  TFramebufferInfo = record
  public
    { Properties of the internal update texture }
    Update: TFramebufferTextureInfo;

    { Properties of the internal offscreen texture }
    Offscreen: TFramebufferTextureInfo;

    { Properties of the internal palette texture }
    Palette: TFramebufferTextureInfo;

    { Internal sampler for nearest-filtering }
    NearestSampler: TSampler;

    { Internal sampler for linear-filtering }
    LinearSampler: TSampler;
  end;
  PFramebufferInfo = ^TFramebufferInfo;

type
  { An enum with a unique item for each log message, warning, error and
    validation layer message. Note that these messages are only visible when a
    logger function is installed in the TFramebuffer.Setup call. }
  TFramebufferLogItem = (
    Ok,
    MallocFailed,
    FramebufferPoolExhausted,
    InvalidFramebufferWidth,
    InvalidFramebufferHeight,
    UpdateInvalidFramebufferHandle,
    UpdateFramebufferResourceStateNotValid,
    UpdatePaletteRangeIgnored,
    UpdatePixelRangeSizeRgba8,
    UpdatePixelRangeSizePalette8,
    UpdatePaletteRangeSize,
    RenderInvalidFramebufferHandle,
    RenderFramebufferResourceStateInvalid);

type
  _TFramebufferLogItemHelper = record helper for TFramebufferLogItem
  public
    function ToString: String;
  end;

type
  { Used in TFramebufferSetupDesc to provide a logging function. Please be aware
    that without logging function, Neslib.Sokol.Framebuffer will be completely
    silent, e.g. it will not report errors and warnings. For maximum error
    verbosity, compile in debug mode and provide a compatible logger function in
    the TFramebuffer.Setup call (for instance the standard logging function
    TFramebufferSetupDesc.DefaultLogger).

    Parameters:
    * ALevel: log level
    * AItem: log item
    * AMessage: the log message corresponding to AItem.
    * ALineNr: line number in original sokol_framebuffer.h file. }
  TFramebufferLogger = procedure(const ALevel: TLogLevel;
    const AItem: TFramebufferLogItem; const AMessage: String;
    const ALineNr: Integer) of object;

type
  { Initialization parameters passed into TFramebuffer.Setup. }
  TFramebufferSetupDesc = record
  {$REGION 'Internal Declarations'}
  private class var
    GLogger: TFramebufferLogger;
  private
    class procedure LogCallback(const ATag: PUTF8Char; ALogLevel,
      ALogItemId: UInt32; const AMessageOrNull: PUTF8Char; ALineNr: UInt32;
      const AFilenameOrNull: PUTF8Char; AUserData: Pointer); cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    { Default: 8 }
    FramebufferPoolSize: Integer;

    { Whether to use Delphi's memory manager instead of Sokol's internal one.
      When SOKOL_MEM_TRACK is defined, it always uses Delphi's memory manager.
      Default: False }
    UseDelphiMemoryManager: Boolean;

    { Optional log function override }
    Logger: TFramebufferLogger;
  public
    { Initialize with default values }
    class function Create: TFramebufferSetupDesc; static;
    procedure Init; inline;

    { A default log function you can assign to the Logger field. }
    procedure DefaultLogger(const ALevel: TLogLevel;
      const AItem: TFramebufferLogItem; const AMessage: String;
      const ALineNr: Integer);
  end;
  PFramebufferSetupDesc = ^TFramebufferSetupDesc;

type
  { Framebuffer object }
  TFramebuffer = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sfb_framebuffer;
    function GetState: TFramebufferResourceState; inline;
    function GetInfo: TFramebufferInfo; inline;
    function GetDesc: TFramebufferDesc; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Global setup of Neslib.Sokol.Framebuffer }
    class procedure Setup(const ADesc: TFramebufferSetupDesc); static;

    { Global shutdown of Neslib.Sokol.Framebuffer }
    class procedure Shutdown; static;
  public
    { Create a framebuffer object }
    constructor Create(const ADesc: TFramebufferDesc);
    procedure Init(const ADesc: TFramebufferDesc); inline;

    { Destroy framebuffer object }
    procedure Free; inline;

    { Resize internal images (no-op if resize isn't needed). Return True when
      images had to be re-created }
    function Resize(const ADesc: TFramebufferResizeDesc): Boolean; inline;

    { Update framebuffer and/or color palette content (must be called outside
      any Neslib.Sokol.Gfx pass) }
    procedure Update(const ADesc: TFramebufferUpdateDesc); inline;

    { Draw framebuffer content with default shader (must be called inside a
      Neslib.Sokol.Gfx render pass) }
    procedure Render; overload; inline;

    { Draw framebuffer content with injected shader (must be called inside a
      Neslib.Sokol.Gfx render pass) }
    procedure Render(const ADesc: TFramebufferRenderDesc); overload; inline;

    { The resource Id }
    property Id: Cardinal read FHandle.id write FHandle.id;

    { Framebuffer resource state (Valid or Failed) }
    property State: TFramebufferResourceState read GetState;

    { Current framebuffer properties }
    property Info: TFramebufferInfo read GetInfo;

    { The framebuffer desc, with default values patched in }
    property Desc: TFramebufferDesc read GetDesc;
  end;
  PFramebuffer = ^TFramebuffer;

implementation

uses
  Neslib.Sokol.Utils;

{ TFramebufferRenderPassDesc }

class function TFramebufferRenderPassDesc.Create: TFramebufferRenderPassDesc;
begin
  Result.Init;
end;

function TFramebufferRenderPassDesc.GetColorFormat: TPixelFormat;
begin
  Result := TPixelFormat(FHandle.color_format);
end;

function TFramebufferRenderPassDesc.GetDepthFormat: TPixelFormat;
begin
  Result := TPixelFormat(FHandle.depth_format);
end;

procedure TFramebufferRenderPassDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

procedure TFramebufferRenderPassDesc.SetColorFormat(const AValue: TPixelFormat);
begin
  FHandle.color_format := Ord(AValue);
end;

procedure TFramebufferRenderPassDesc.SetDepthFormat(const AValue: TPixelFormat);
begin
  FHandle.depth_format := Ord(AValue);
end;

{ TFramebufferDesc }

class function TFramebufferDesc.Create: TFramebufferDesc;
begin
  Result.Init;
end;

procedure TFramebufferDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TFramebufferResizeDesc }

class function TFramebufferResizeDesc.Create: TFramebufferResizeDesc;
begin
  Result.Init;
end;

procedure TFramebufferResizeDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TFramebufferUpdateDesc }

class function TFramebufferUpdateDesc.Create: TFramebufferUpdateDesc;
begin
  Result.Init;
end;

procedure TFramebufferUpdateDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TFramebufferRenderDesc }

class function TFramebufferRenderDesc.Create: TFramebufferRenderDesc;
begin
  Result.Init;
end;

procedure TFramebufferRenderDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TFramebufferTextureInfo }

function TFramebufferTextureInfo.GetImage: TImage;
begin
  Result := TImage(FHandle.image);
end;

function TFramebufferTextureInfo.GetPixelFormat: TPixelFormat;
begin
  Result := TPixelFormat(FHandle.pixel_format);
end;

function TFramebufferTextureInfo.GetTexView: TView;
begin
  Result := TView(FHandle.tex_view);
end;

{ _TFramebufferLogItemHelper }

function _TFramebufferLogItemHelper.ToString: String;
const
  STRINGS: array [TFramebufferLogItem] of String = (
    'Ok',
    'memory allocation failed',
    'framebuffer pool exhausted (TFramebufferSetupDesc.FramebufferPoolSize)',
    'TFramebufferDesc.Width must be > 0',
    'TFramebufferDesc.Height must be > 0',
    'TFramebuffer.Update: framebuffer handle not valid',
    'TFramebuffer.Update: framebuffer not in valid resource state',
    'TFramebuffer.Update: TFramebufferUpdateDesc.Palette is ignored for non-paletted framebuffer',
    'TFramebuffer.Update: unexpected TFramebufferUpdateDesc.Pixels.Size; must be (width * height * 4) bytes',
    'TFramebuffer.Update: unexpected TFramebufferUpdateDesc.Pixels.Size; must be (width * height) bytes',
    'TFramebuffer.Update: unexpected TFramebufferUpdateDesc.Palette.Size; must be 256 * 4 bytes',
    'TFramebuffer.Render: framebuffer handle not valid',
    'TFramebuffer.Render: framebuffer not in valid resource state');
begin
  Result := STRINGS[Self];
end;

{ TFramebufferSetupDesc }

class function TFramebufferSetupDesc.Create: TFramebufferSetupDesc;
begin
  Result.Init;
end;

procedure TFramebufferSetupDesc.DefaultLogger(const ALevel: TLogLevel;
  const AItem: TFramebufferLogItem; const AMessage: String;
  const ALineNr: Integer);
begin
  _LogDefault(ALevel, Ord(AItem), AMessage, ALineNr);
end;

procedure TFramebufferSetupDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

class procedure TFramebufferSetupDesc.LogCallback(const ATag: PUTF8Char;
  ALogLevel, ALogItemId: UInt32; const AMessageOrNull: PUTF8Char;
  ALineNr: UInt32; const AFilenameOrNull: PUTF8Char; AUserData: Pointer);
begin
  Assert(Assigned(GLogger));
  var Msg: String;
  if (ALogItemId <= Cardinal(Ord(High(TFramebufferLogItem)))) then
    Msg := TFramebufferLogItem(ALogItemId).ToString
  else
    Msg := String(UTF8String(AMessageOrNull));

  GLogger(TLogLevel(ALogLevel), TFramebufferLogItem(ALogItemId), Msg, ALineNr);
end;

{ TFramebuffer }

constructor TFramebuffer.Create(const ADesc: TFramebufferDesc);
begin
  Init(ADesc);
end;

procedure TFramebuffer.Free;
begin
  _sfb_destroy_framebuffer(FHandle);
  FHandle.id := 0;
end;

function TFramebuffer.GetDesc: TFramebufferDesc;
begin
  var Src := _sfb_query_framebuffer_desc(FHandle);
  Result.Width := Src.width;
  Result.Height := Src.height;
  Result.Prescale := Src.prescale;
  Result.Format := TFramebufferFormat(Src.format);
  Result.Cliprect := TFramebufferRect(Src.cliprect);
  Result.Rotate90 := Src.rotate90;
  Result.RenderPass.FHandle := Src.render_pass;
end;

function TFramebuffer.GetInfo: TFramebufferInfo;
begin
  var Src := _sfb_query_framebuffer_info(FHandle);
  Result.Update.FHandle := Src.update;
  Result.Offscreen.FHandle := Src.offscreen;
  Result.Palette.FHandle := Src.palette;
  Result.NearestSampler := TSampler(Src.nearest_sampler);
  Result.LinearSampler := TSampler(Src.linear_sampler);
end;

function TFramebuffer.GetState: TFramebufferResourceState;
begin
  Result := TFramebufferResourceState(_sfb_query_framebuffer_state(FHandle));
end;

procedure TFramebuffer.Init(const ADesc: TFramebufferDesc);
begin
  var Dst: _sfb_framebuffer_desc;
  FillChar(Dst, SizeOf(Dst), 0);
  Dst.width := ADesc.Width;
  Dst.height := ADesc.Height;
  Dst.prescale := ADesc.Prescale;
  Dst.format := Ord(ADesc.Format);
  Dst.cliprect := _sfb_rect(ADesc.Cliprect);
  Dst.rotate90 := ADesc.Rotate90;
  Dst.render_pass := ADesc.RenderPass.FHandle;
  FHandle := _sfb_make_framebuffer(@Dst);
end;

procedure TFramebuffer.Render;
begin
  _sfb_render(FHandle);
end;

procedure TFramebuffer.Render(const ADesc: TFramebufferRenderDesc);
begin
  var Dst: _sfb_render_desc;
  Dst.use_nearest_filter := ADesc.UseNearestFilter;
  Dst.pip := _sg_pipeline(ADesc.Pip);
  Move(ADesc.Views, Dst.views, SizeOf(ADesc.Views));
  Move(ADesc.Samplers, Dst.samplers, SizeOf(ADesc.Samplers));
  for var I := 0 to MAX_UNIFORMBLOCK_BINDSLOTS - 1 do
  begin
    Dst.uniforms[I].ptr := ADesc.Uniforms[I].Data;
    Dst.uniforms[I].size := ADesc.Uniforms[I].Size;
  end;
  _sfb_render_ex(FHandle, @Dst);
end;

function TFramebuffer.Resize(const ADesc: TFramebufferResizeDesc): Boolean;
begin
  var Dst: _sfb_resize_desc;
  Dst.width := ADesc.Width;
  Dst.height := ADesc.Height;
  Dst.prescale := ADesc.Prescale;
  Dst.cliprect := _sfb_rect(ADesc.Cliprect);
  Result := _sfb_resize(FHandle, @Dst);
end;

class procedure TFramebuffer.Setup(const ADesc: TFramebufferSetupDesc);
begin
  var Dst: _sfb_desc;
  FillChar(Dst, SizeOf(Dst), 0);
  Dst.framebuffer_pool_size := ADesc.FramebufferPoolSize;
  {$IFDEF SOKOL_MEM_TRACK}
  Dst.allocator.alloc_fn := _MemTrackAlloc;
  Dst.allocator.free_fn := _MemTrackFree;
  {$ELSE}
  if (ADesc.UseDelphiMemoryManager) then
  begin
    Dst.allocator.alloc_fn := _AllocCallback;
    Dst.allocator.free_fn := _FreeCallback;
  end;
  {$ENDIF}

  if Assigned(ADesc.Logger) then
  begin
    TFramebufferSetupDesc.GLogger := ADesc.Logger;
    Dst.logger.func := TFramebufferSetupDesc.LogCallback;
  end;

  _sfb_setup(@Dst);
end;

class procedure TFramebuffer.Shutdown;
begin
  _sfb_shutdown();
end;

procedure TFramebuffer.Update(const ADesc: TFramebufferUpdateDesc);
begin
  var Dst: _sfb_update_desc;
  Dst.pixels.ptr := ADesc.Pixels.Data;
  Dst.pixels.size := ADesc.Pixels.Size;
  Dst.palette.ptr := ADesc.Palette.Data;
  Dst.palette.size := ADesc.Palette.Size;
  _sfb_update(FHandle, @Dst);
end;

end.

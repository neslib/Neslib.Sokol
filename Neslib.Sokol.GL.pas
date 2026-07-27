unit Neslib.Sokol.GL;
{ OpenGL 1.x style rendering on top of Neslib.Sokol.Gfx.

  For a user guide, check out the Neslib.Sokol.GL.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.GL.md }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.FastMath,
  Neslib.Sokol.Api,
  Neslib.Sokol.Types,
  Neslib.Sokol.Gfx;

type
  { An enum with a unique item for each log message, warning, error and
    validation layer message. Note that these messages are only visible when a
    logger function is installed in the sglSetup call. }
  TGLLogItem = (
    Ok,
    MallocFailed,
    MakePipelineFailed,
    PipelinePoolExhausted,
    AddCommitListenerFailed,
    ContextPoolExhausted,
    CannotDestroyDefaultContext);

type
  _TGLLogItemHelper = record helper for TGLLogItem
  public
    function ToString: String;
  end;

type
  { Used in TGLDesc to provide a logging function. Please be aware that without
    logging function, Neslib.Sokol.GL will be completely silent, e.g. it will
    not report errors and warnings. For maximum error verbosity, compile in
    debug mode and provide a compatible logger function in the sglSetup call (
    for instance the standard logging function TGLDesc.DefaultLogger).

    Parameters:
    * ALevel: log level
    * AItem: log item
    * AMessage: the log message corresponding to AItem.
    * ALineNr: line number in original sokol_gl.h file. }
  TGLLogger = procedure(const ALevel: TLogLevel; const AItem: TGLLogItem;
    const AMessage: String; const ALineNr: Integer) of object;

type
  { Errors are reset each frame after calling sglDraw().
    Get the last error code with sglError(). }
  TGLError = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sgl_error_t;
  {$ENDREGION 'Internal Declarations'}
  public
    property Any: Boolean read FHandle.any;
    property VerticesFull: Boolean read FHandle.vertices_full;
    property UniformsFull: Boolean read FHandle.uniforms_full;
    property CommandsFull: Boolean read FHandle.commands_full;
    property StackOverflow: Boolean read FHandle.stack_overflow;
    property StackUnderflow: Boolean read FHandle.stack_underflow;
    property NoContext: Boolean read FHandle.no_context;
  end;

type
  { Describes the initialization parameters of a rendering context.
    Creating additional contexts is useful if you want to render in separate
    Neslib.Sokol.Gfx passes. }
  TGLContextDesc = record
  {$REGION 'Internal Declarations'}
  private
    procedure Convert(out ADst: _sgl_context_desc_t);
  {$ENDREGION 'Internal Declarations'}
  public
    { Default: 64k }
    MaxVertices: Integer;

    { Default: 16k }
    MaxCommands: Integer;

    ColorFormat: TPixelFormat;
    DepthFormat: TPixelFormat;
    SampleCount: Integer;
  public
    class function Create: TGLContextDesc; static;
    procedure Init; inline;
  end;
  PGLContextDesc = ^TGLContextDesc;

type
  TGLDesc = record
  {$REGION 'Internal Declarations'}
  private class var
    GLogger: TGLLogger;
  private
    procedure Convert(out ADst: _sgl_desc_t);
  private
    class procedure LogCallback(const ATag: PUTF8Char; ALogLevel,
      ALogItemId: UInt32; const AMessageOrNull: PUTF8Char; ALineNr: UInt32;
      const AFilenameOrNull: PUTF8Char; AUserData: Pointer); cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    { Default: 64k }
    MaxVertices: Integer;

    { Default: 16k }
    MaxCommands: Integer;

    { Max number of contexts (including default context).
      Default: 4 }
    ContextPoolSize: Integer;

    { Size of internal pipeline pool.
      Default: 64 }
    PipelinePoolSize: Integer;

    ColorFormat: TPixelFormat;
    DepthFormat: TPixelFormat;
    SampleCount: Integer;

    { Default: TFaceWinding.CounterClockWise }
    FaceWinding: TFaceWinding;

    { Whether to use Delphi's memory manager instead of Sokol's internal one.
      When SOKOL_MEM_TRACK is defined, it always uses Delphi's memory manager.
      Default: False }
    UseDelphiMemoryManager: Boolean;

    { Optional log function override }
    Logger: TGLLogger;
  public
    class function Create: TGLDesc; static;
    procedure Init; inline;

    { A default log function you can assign to the Logger field. }
    procedure DefaultLogger(const ALevel: TLogLevel; const AItem: TGLLogItem;
      const AMessage: String; const ALineNr: Integer);
  end;
  PGLDesc = ^TGLDesc;

type
  TGLContext = record
  {$REGION 'Internal Declarations'}
  private class var
    FDefault: TGLContext;
  private
    FHandle: _sgl_context;
    class function GetCurrent: TGLContext; inline; static;
    class procedure SetCurrent(const AValue: TGLContext); inline; static;
  public
    class constructor Create;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const ADesc: TGLContextDesc);
    procedure Init(const ADesc: TGLContextDesc); inline;
    procedure Free; inline;

    procedure MakeCurrent; inline;

    { Draw recorded commands (call inside a Neslib.Sokol.Gfx render pass) }
    procedure Draw; inline;
    procedure DrawLayer(const ALayerId: Integer); inline;

    class property Current: TGLContext read GetCurrent write SetCurrent;
    class property Default: TGLContext read FDefault;
    property Id: Cardinal read FHandle.id;
  end;

type
  TGLPipeline = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sgl_pipeline;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const ADesc: TPipelineDesc); overload;
    constructor Create(const ACtx: TGLContext;
      const ADesc: TPipelineDesc); overload;
    procedure Init(const ADesc: TPipelineDesc); overload; inline;
    procedure Init(const ACtx: TGLContext;
      const ADesc: TPipelineDesc); overload; inline;
    procedure Free; inline;

    property Id: Cardinal read FHandle.id;
  end;

{ Setup/shutdown/misc }

procedure sglSetup(const ADesc: TGLDesc); inline;

procedure sglShutdown(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_shutdown';

function sglRad(ADeg: Single): Single; cdecl;
  external _LIB_SOKOL name _PU + 'sgl_rad';

function sglDeg(ARad: Single): Single; cdecl;
  external _LIB_SOKOL name _PU + 'sgl_deg';

function sglError(): TGLError; overload; cdecl;
  external _LIB_SOKOL name _PU + 'sgl_error';

function sglError(const ACtx: TGLContext): TGLError; overload; inline;

{ Context functions }

function sglGetContext: TGLContext; inline;
procedure sglSetContext(const ACtx: TGLContext); inline;
procedure sglSetDefaultContext; inline;

{ Get information about recorded vertices and commands in current context }

function sglNumVertices: Integer; cdecl;
  external _LIB_SOKOL name _PU + 'sgl_num_vertices';

function sglNumCommands: Integer; cdecl;
  external _LIB_SOKOL name _PU + 'sgl_num_commands';

{ Draw recorded commands (call inside a Neslib.Sokol.Gfx render pass) }

procedure sglDraw; overload; cdecl;
  external _LIB_SOKOL name _PU + 'sgl_draw';

procedure sglDrawLayer(const ALayerId: Integer); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_draw_layer';

procedure sglDraw(const ACtx: TGLContext); overload; inline;

{ Render state functions }

procedure sglDefaults(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_defaults';

procedure sglViewport(AX, AY, AW, AH: Integer; AOriginTopLeft: Boolean); overload; cdecl;
  external _LIB_SOKOL name _PU + 'sgl_viewport';

procedure sglViewport(AX, AY, AW, AH: Single; AOriginTopLeft: Boolean); overload; cdecl;
  external _LIB_SOKOL name _PU + 'sgl_viewportf';

procedure sglScissorRect(AX, AY, AW, AH: Integer; AOriginTopLeft: Boolean); overload; cdecl;
  external _LIB_SOKOL name _PU + 'sgl_scissor_rect';

procedure sglScissorRect(AX, AY, AW, AH: Single; AOriginTopLeft: Boolean); overload; cdecl;
  external _LIB_SOKOL name _PU + 'sgl_scissor_rectf';

procedure sglEnableTexture(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_enable_texture';

procedure sglDisableTexture(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_disable_texture';

procedure sglTexture(const ATexView: TView; const ASampler: TSampler); inline;

procedure sglLayer(const ALayerId: Integer); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_layer';

{ Pipeline stack functions }

procedure sglLoadDefaultPipeline(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_load_default_pipeline';

procedure sglLoadPipeline(const APip: TGLPipeline); inline;

procedure sglPushPipeline(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_push_pipeline';

procedure sglPopPipeline(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_pop_pipeline';

{ Matrix stack functions }

procedure sglMatrixModeModelview(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_matrix_mode_modelview';

procedure sglMatrixModeProjection(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_matrix_mode_projection';

procedure sglMatrixModeTexture(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_matrix_mode_texture';

procedure sglLoadIdentity(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_load_identity';

procedure sglLoadMatrix(const [ref] AMatrix: TMatrix4); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_load_matrix';

procedure sglLoadTransposeMatrix(const [ref] AMatrix: TMatrix4); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_load_transpose_matrix';

procedure sglMultMatrix(const [ref] AMatrix: TMatrix4); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_mult_matrix';

procedure sglMultTransposeMatrix(const [ref] AMatrix: TMatrix4); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_mult_transpose_matrix';

procedure sglRotate(AAngleRad, AX, AY, AZ: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_rotate';

procedure sglScale(AX, AY, AZ: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_scale';

procedure sglTranslate(AX, AY, AZ: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_translate';

procedure sglFrustum(ALeft, ARight, ABottom, ATop, ANear, AFar: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_frustum';

procedure sglOrtho(ALeft, ARight, ABottom, ATop, ANear, AFar: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_ortho';

procedure sglPerspective(AFovY, AAspect, AZNear, AZFar: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_perspective';

procedure sglLookAt(AEyeX, AEyeY, AEyeZ, ACenterX, ACenterY, ACenterZ, AUpX, AUpY, AUpZ: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_lookat';

procedure sglPushMatrix(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_push_matrix';

procedure sglPopMatrix(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_pop_matrix';

{ These functions only set the internal 'current texcoord / color / point size'
  (valid inside or outside sglBegin/sglEnd) }

procedure sglT2F(AU, AV: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_t2f';

procedure sglC3F(AR, AG, AB: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_c3f';

procedure sglC4F(AR, AG, AB, AA: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_c4f';

procedure sglC3B(AR, AG, AB: UInt8); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_c3b';

procedure sglC4B(AR, AG, AB, AA: UInt8); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_c4b';

procedure sglC1I(ARgba: UInt32); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_c1i';

procedure sglPointSize(ASize: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_point_size';

{ Define primitives, each begin/end is one draw command }

procedure sglBeginPoints(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_begin_points';

procedure sglBeginLines(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_begin_lines';

procedure sglBeginLineStrip(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_begin_line_strip';

procedure sglBeginTriangles(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_begin_triangles';

procedure sglBeginTriangleStrip(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_begin_triangle_strip';

procedure sglBeginQuads(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_begin_quads';

procedure sglV2F(AX, AY: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v2f';

procedure sglV3F(AX, AY, AZ: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v3f';

procedure sglV2F_T2F(AX, AY, AU, AV: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v2f_t2f';

procedure sglV3F_T2F(AX, AY, AZ, AU, AV: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v3f_t2f';

procedure sglV2F_C3Ff(AX, AY, AR, AG, AB: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v2f_c3f';

procedure sglV2F_C3B(AX, AY: Single; AR, AG, AB: UInt8); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v2f_c3b';

procedure sglV2F_C4F(AX, AY, AR, AG, AB, AA: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v2f_c4f';

procedure sglV2F_C4B(AX, AY: Single; AR, AG, AB, AA: UInt8); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v2f_c4b';

procedure sglV2F_C1I(AX, AY: Single; ARgba: UInt32); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v2f_c1i';

procedure sglV3F_C3F(AX, AY, AZ, AR, AG, AB: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v3f_c3f';

procedure sglV3F_C3B(AX, AY, AZ: Single; AR, AG, AB: UInt8); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v3f_c3b';

procedure sglV3F_C4F(AX, AY, AZ, AR, AG, AB, AA: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v3f_c4f';

procedure sglV3F_C4B(AX, AY, AZ: Single; AR, AG, AB, AA: UInt8); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v3f_c4b';

procedure sglV3F_C1I(AX, AY, AZ: Single; ARgba: UInt32); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v3f_c1i';

procedure sglV2F_T2F_C3F(AX, AY, AU, AV, AR, AG, AB: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v2f_t2f_c3f';

procedure sglV2F_T2F_C3B(AX, AY, AU, AV: Single; AR, AG, AB: UInt8); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v2f_t2f_c3b';

procedure sglV2F_T2F_C4F(AX, AY, AU, AV, AR, AG, AB, AA: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v2f_t2f_c4f';

procedure sglV2F_T2F_C4B(AX, AY, AU, AV: Single; AR, AG, AB, AA: UInt8); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v2f_t2f_c4b';

procedure sglV2F_T2F_C1I(AX, AY, AU, AV: Single; ARgba: UInt32); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v2f_t2f_c1i';

procedure sglV3F_T2F_C3F(AX, AY, AZ, AU, AV, AR, AG, AB: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v3f_t2f_c3f';

procedure sglV3F_T2F_C3B(AX, AY, AZ, AU, AV: Single; AR, AG, AB: UInt8); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v3f_t2f_c3b';

procedure sglV3F_T2F_C4F(AX, AY, AZ, AU, AV, AR, AG, AB, AA: Single); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v3f_t2f_c4f';

procedure sglV3F_T2F_C4Bb(AX, AY, AZ, AU, AV: Single; AR, AG, AB, AA: UInt8); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v3f_t2f_c4b';

procedure sglV3F_T2F_C1I(AX, AY, AZ, AU, AV: Single; ARgba: UInt32); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_v3f_t2f_c1i';

procedure sglEnd(); cdecl;
  external _LIB_SOKOL name _PU + 'sgl_end';

implementation

uses
  {$IFDEF SOKOL_MEM_TRACK}
  Neslib.Sokol.MemTrack;
  {$ELSE}
  Neslib.Sokol.Utils;
  {$ENDIF}

procedure sglSetup(const ADesc: TGLDesc);
begin
  var Desc: _sgl_desc_t;
  ADesc.Convert(Desc);
  _sgl_setup(@Desc);
end;

function sglError(const ACtx: TGLContext): TGLError;
begin
  Result := TGLError(_sgl_context_error(ACtx.FHandle));
end;

function sglGetContext: TGLContext;
begin
  Result.FHandle := _sgl_get_context;
end;

procedure sglSetContext(const ACtx: TGLContext);
begin
  _sgl_set_context(ACtx.FHandle);
end;

procedure sglSetDefaultContext;
begin
  _sgl_set_context(_sgl_default_context);
end;

procedure sglTexture(const ATexView: TView; const ASampler: TSampler); inline;
begin
  _sgl_texture(_sg_view(ATexView), _sg_sampler(ASampler));
end;

procedure sglLoadPipeline(const APip: TGLPipeline);
begin
  _sgl_load_pipeline(_sgl_pipeline(APip));
end;

procedure sglDraw(const ACtx: TGLContext);
begin
  _sgl_context_draw(ACtx.FHandle);
end;

{ _TGLLogItemHelper }

function _TGLLogItemHelper.ToString: String;
const
  STRINGS: array [TGLLogItem] of String = (
    'Ok',
    'memory allocation failed',
    'TGLPipeline.Create failed',
    'pipeline pool exhausted (use TGLDesc.PipelinePoolSize to adjust)',
    'setting TGfx.CommitListener failed',
    'context pool exhausted (use TGLDesc.ContextPoolSize to adjust)',
    'cannot destroy default context');
begin
  Result := STRINGS[Self];
end;

{ TGLContextDesc }

procedure TGLContextDesc.Convert(out ADst: _sgl_context_desc_t);
begin
  ADst.max_vertices := MaxVertices;
  ADst.max_commands := MaxCommands;
  ADst.color_format := Ord(ColorFormat);
  ADst.depth_format := Ord(DepthFormat);
  ADst.sample_count := SampleCount;
end;

class function TGLContextDesc.Create: TGLContextDesc;
begin
  Result.Init;
end;

procedure TGLContextDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

{ TGLDesc }

procedure TGLDesc.Convert(out ADst: _sgl_desc_t);
begin
  FillChar(ADst, SizeOf(ADst), 0);
  ADst.max_vertices := MaxVertices;
  ADst.max_commands := MaxCommands;
  ADst.context_pool_size := ContextPoolSize;
  ADst.pipeline_pool_size := PipelinePoolSize;
  ADst.color_format := Ord(ColorFormat);
  ADst.depth_format := Ord(DepthFormat);
  ADst.sample_count := SampleCount;
  ADst.face_winding := Ord(FaceWinding);
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

class function TGLDesc.Create: TGLDesc;
begin
  Result.Init;
end;

procedure TGLDesc.DefaultLogger(const ALevel: TLogLevel;
  const AItem: TGLLogItem; const AMessage: String; const ALineNr: Integer);
begin
  _LogDefault(ALevel, Ord(AItem), AMessage, ALineNr);
end;

procedure TGLDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

class procedure TGLDesc.LogCallback(const ATag: PUTF8Char; ALogLevel,
  ALogItemId: UInt32; const AMessageOrNull: PUTF8Char; ALineNr: UInt32;
  const AFilenameOrNull: PUTF8Char; AUserData: Pointer);
begin
  Assert(Assigned(GLogger));
  var Msg: String;
  if (ALogItemId <= Cardinal(Ord(High(TGLLogItem)))) then
    Msg := TGLLogItem(ALogItemId).ToString
  else
    Msg := String(UTF8String(AMessageOrNull));

  GLogger(TLogLevel(ALogLevel), TGLLogItem(ALogItemId), Msg, ALineNr);
end;

{ TGLContext }

constructor TGLContext.Create(const ADesc: TGLContextDesc);
begin
  Init(ADesc);
end;

procedure TGLContext.Draw;
begin
  _sgl_context_draw(FHandle);
end;

procedure TGLContext.DrawLayer(const ALayerId: Integer);
begin
  _sgl_context_draw_layer(FHandle, ALayerId);
end;

class constructor TGLContext.Create;
begin
  FDefault.FHandle := _sgl_default_context;
end;

procedure TGLContext.Free;
begin
  _sgl_destroy_context(FHandle);
end;

class function TGLContext.GetCurrent: TGLContext;
begin
  Result.FHandle := _sgl_get_context;
end;

procedure TGLContext.Init(const ADesc: TGLContextDesc);
begin
  var Desc: _sgl_context_desc_t;
  ADesc.Convert(Desc);
  FHandle := _sgl_make_context(@Desc);
end;

procedure TGLContext.MakeCurrent;
begin
  _sgl_set_context(FHandle);
end;

class procedure TGLContext.SetCurrent(const AValue: TGLContext);
begin
  _sgl_set_context(AValue.FHandle);
end;

{ TGLPipeline }

constructor TGLPipeline.Create(const ADesc: TPipelineDesc);
begin
  Init(ADesc);
end;

constructor TGLPipeline.Create(const ACtx: TGLContext;
  const ADesc: TPipelineDesc);
begin
  Init(ACtx, ADesc);
end;

procedure TGLPipeline.Free;
begin
  _sgl_destroy_pipeline(FHandle);
end;

procedure TGLPipeline.Init(const ACtx: TGLContext; const ADesc: TPipelineDesc);
begin
  var Desc: _sg_pipeline_desc;
  ADesc._Convert(Desc);
  FHandle := _sgl_context_make_pipeline(ACtx.FHandle, @Desc);
end;

procedure TGLPipeline.Init(const ADesc: TPipelineDesc);
begin
  var Desc: _sg_pipeline_desc;
  ADesc._Convert(Desc);
  FHandle := _sgl_make_pipeline(@Desc);
end;

end.

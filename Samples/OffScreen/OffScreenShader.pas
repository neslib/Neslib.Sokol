unit OffScreenShader;
{ #version:1# (machine generated, don't edit!)

  Generated by sokol-shdc (https://github.com/floooh/sokol-tools)
  With Delphi modifications (https://github.com/neslib/Neslib.Sokol.Tools)

  Cmdline: sokol-shdc --input OffScreenShader.glsl --output OffScreenShader.pas

  Overview:

    Shader program 'default':
      Get shader desc: DefaultShaderDesc()
      Vertex shader: vs_default
        Attribute slots:
          ATTR_VS_DEFAULT_POSITION = 0
          ATTR_VS_DEFAULT_NORMAL = 1
          ATTR_VS_DEFAULT_TEXCOORD0 = 2
        Uniform block 'vs_params':
          Delphi record: TVSParams
          Bind slot: SLOT_VS_PARAMS = 0
      Fragment shader: fs_default
        Image 'tex':
          Type: _SG_IMAGETYPE_2D
          Component Type: _SG_SAMPLERTYPE_FLOAT
          Bind slot: SLOT_TEX = 0

    Shader program 'offscreen':
      Get shader desc: OffscreenShaderDesc()
      Vertex shader: vs_offscreen
        Attribute slots:
          ATTR_VS_OFFSCREEN_POSITION = 0
          ATTR_VS_OFFSCREEN_NORMAL = 1
        Uniform block 'vs_params':
          Delphi record: TVSParams
          Bind slot: SLOT_VS_PARAMS = 0
      Fragment shader: fs_offscreen


  Shader descriptor records:

    var DefaultShader := TShader.Create(DefaultShaderDesc);
    var OffscreenShader := TShader.Create(OffscreenShaderDesc);

  Vertex attribute locations for vertex shader 'vs_offscreen':

    var PipDesc: TPipelineDesc;
    PipDesc.Init;
    PipDesc.Attrs[ATTR_VS_OFFSCREEN_POSITION]. ...
    PipDesc.Attrs[ATTR_VS_OFFSCREEN_NORMAL]. ...
    PipDesc. ...
    var Pip := TPipeline.Create(PipDesc);

  Vertex attribute locations for vertex shader 'vs_default':

    var PipDesc: TPipelineDesc;
    PipDesc.Init;
    PipDesc.Attrs[ATTR_VS_DEFAULT_POSITION]. ...
    PipDesc.Attrs[ATTR_VS_DEFAULT_NORMAL]. ...
    PipDesc.Attrs[ATTR_VS_DEFAULT_TEXCOORD0]. ...
    PipDesc. ...
    var Pip := TPipeline.Create(PipDesc);

  Image bind slots, use as index in TBindings.VSImages[] or .FSImages[]:

    SLOT_TEX = 0;

  Bind slot and Delphi record for uniform block 'VSParams':

    VSParams: TVSParams;
    VSParams.Mvp := ...;
    TGfx.ApplyUniforms(TShaderStage.[VertexShader|FragmentShader], SLOT_VS_PARAMS, TRange.Create(VSParams));

}

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.FastMath,
  Neslib.Sokol.Gfx;

const
  ATTR_VS_OFFSCREEN_POSITION = 0;
  ATTR_VS_OFFSCREEN_NORMAL = 1;
  ATTR_VS_DEFAULT_POSITION = 0;
  ATTR_VS_DEFAULT_NORMAL = 1;
  ATTR_VS_DEFAULT_TEXCOORD0 = 2;

const
  SLOT_TEX = 0;

const
  SLOT_VS_PARAMS = 0;

type
  TVSParams = packed record
  public
    Mvp: TMatrix4;
  end;

function DefaultShaderDesc: PNativeShaderDesc;
function OffscreenShaderDesc: PNativeShaderDesc;

implementation

uses
  Neslib.Sokol.Api;

{$IFDEF SOKOL_GLCORE33}
const
  VS_OFFSCREEN_SOURCE_GLSL330 =
    '#version 330'#10+

    'uniform vec4 vs_params[4];'#10+
    'layout(location = 0) in vec4 position;'#10+
    'out vec4 nrm;'#10+
    'layout(location = 1) in vec4 normal;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_Position = mat4(vs_params[0], vs_params[1], vs_params[2], vs_params[3]) * position;'#10+
    '    nrm = normal;'#10+
    '}';

const
  FS_OFFSCREEN_SOURCE_GLSL330 =
    '#version 330'#10+

    'layout(location = 0) out vec4 frag_color;'#10+
    'in vec4 nrm;'#10+

    'void main()'#10+
    '{'#10+
    '    frag_color = vec4((nrm.xyz * 0.5) + vec3(0.5), 1.0);'#10+
    '}';

const
  VS_DEFAULT_SOURCE_GLSL330 =
    '#version 330'#10+

    'uniform vec4 vs_params[4];'#10+
    'layout(location = 0) in vec4 position;'#10+
    'out vec2 uv;'#10+
    'layout(location = 2) in vec2 texcoord0;'#10+
    'out vec4 nrm;'#10+
    'layout(location = 1) in vec4 normal;'#10+

    'void main()'#10+
    '{'#10+
    '    mat4 _24 = mat4(vs_params[0], vs_params[1], vs_params[2], vs_params[3]);'#10+
    '    gl_Position = _24 * position;'#10+
    '    uv = texcoord0;'#10+
    '    nrm = _24 * normal;'#10+
    '}';

const
  FS_DEFAULT_SOURCE_GLSL330 =
    '#version 330'#10+

    'uniform sampler2D tex;'#10+

    'in vec2 uv;'#10+
    'in vec4 nrm;'#10+
    'layout(location = 0) out vec4 frag_color;'#10+

    'void main()'#10+
    '{'#10+
    '    frag_color = vec4(texture(tex, uv * vec2(20.0, 10.0)).xyz * ((clamp(dot(nrm.xyz, vec3(0.57735025882720947265625, 0.57735025882720947265625, -0.57735025882720947265625)), 0.0, 1.0) * 2.0) + 0.25), '+
      '1.0);'#10+
    '}';

{$ENDIF !SOKOL_GLCORE33}

{$IFDEF SOKOL_GLES2}
const
  VS_OFFSCREEN_SOURCE_GLSL100 =
    '#version 100'#10+

    'uniform vec4 vs_params[4];'#10+
    'attribute vec4 position;'#10+
    'varying vec4 nrm;'#10+
    'attribute vec4 normal;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_Position = mat4(vs_params[0], vs_params[1], vs_params[2], vs_params[3]) * position;'#10+
    '    nrm = normal;'#10+
    '}';

const
  FS_OFFSCREEN_SOURCE_GLSL100 =
    '#version 100'#10+
    'precision mediump float;'#10+
    'precision highp int;'#10+

    'varying highp vec4 nrm;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_FragData[0] = vec4((nrm.xyz * 0.5) + vec3(0.5), 1.0);'#10+
    '}';

const
  VS_DEFAULT_SOURCE_GLSL100 =
    '#version 100'#10+

    'uniform vec4 vs_params[4];'#10+
    'attribute vec4 position;'#10+
    'varying vec2 uv;'#10+
    'attribute vec2 texcoord0;'#10+
    'varying vec4 nrm;'#10+
    'attribute vec4 normal;'#10+

    'void main()'#10+
    '{'#10+
    '    mat4 _24 = mat4(vs_params[0], vs_params[1], vs_params[2], vs_params[3]);'#10+
    '    gl_Position = _24 * position;'#10+
    '    uv = texcoord0;'#10+
    '    nrm = _24 * normal;'#10+
    '}';

const
  FS_DEFAULT_SOURCE_GLSL100 =
    '#version 100'#10+
    'precision mediump float;'#10+
    'precision highp int;'#10+

    'uniform highp sampler2D tex;'#10+

    'varying highp vec2 uv;'#10+
    'varying highp vec4 nrm;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_FragData[0] = vec4(texture2D(tex, uv * vec2(20.0, 10.0)).xyz * ((clamp(dot(nrm.xyz, vec3(0.57735025882720947265625, 0.57735025882720947265625, -0.57735025882720947265625)), 0.0, 1.0) * 2.0) + '+
      '0.25), 1.0);'#10+
    '}';

{$ENDIF !SOKOL_GLES2}

{$IFDEF SOKOL_GLES3}
const
  VS_OFFSCREEN_SOURCE_GLSL300ES =
    '#version 300 es'#10+

    'uniform vec4 vs_params[4];'#10+
    'layout(location = 0) in vec4 position;'#10+
    'out vec4 nrm;'#10+
    'layout(location = 1) in vec4 normal;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_Position = mat4(vs_params[0], vs_params[1], vs_params[2], vs_params[3]) * position;'#10+
    '    nrm = normal;'#10+
    '}';

const
  FS_OFFSCREEN_SOURCE_GLSL300ES =
    '#version 300 es'#10+
    'precision mediump float;'#10+
    'precision highp int;'#10+

    'layout(location = 0) out highp vec4 frag_color;'#10+
    'in highp vec4 nrm;'#10+

    'void main()'#10+
    '{'#10+
    '    frag_color = vec4((nrm.xyz * 0.5) + vec3(0.5), 1.0);'#10+
    '}';

const
  VS_DEFAULT_SOURCE_GLSL300ES =
    '#version 300 es'#10+

    'uniform vec4 vs_params[4];'#10+
    'layout(location = 0) in vec4 position;'#10+
    'out vec2 uv;'#10+
    'layout(location = 2) in vec2 texcoord0;'#10+
    'out vec4 nrm;'#10+
    'layout(location = 1) in vec4 normal;'#10+

    'void main()'#10+
    '{'#10+
    '    mat4 _24 = mat4(vs_params[0], vs_params[1], vs_params[2], vs_params[3]);'#10+
    '    gl_Position = _24 * position;'#10+
    '    uv = texcoord0;'#10+
    '    nrm = _24 * normal;'#10+
    '}';

const
  FS_DEFAULT_SOURCE_GLSL300ES =
    '#version 300 es'#10+
    'precision mediump float;'#10+
    'precision highp int;'#10+

    'uniform highp sampler2D tex;'#10+

    'in highp vec2 uv;'#10+
    'in highp vec4 nrm;'#10+
    'layout(location = 0) out highp vec4 frag_color;'#10+

    'void main()'#10+
    '{'#10+
    '    frag_color = vec4(texture(tex, uv * vec2(20.0, 10.0)).xyz * ((clamp(dot(nrm.xyz, vec3(0.57735025882720947265625, 0.57735025882720947265625, -0.57735025882720947265625)), 0.0, 1.0) * 2.0) + 0.25), '+
      '1.0);'#10+
    '}';

{$ENDIF !SOKOL_GLES3}

{$IFDEF SOKOL_D3D11}
const
  VS_OFFSCREEN_SOURCE_HLSL5 =
    'cbuffer vs_params : register(b0)'#10+
    '{'#10+
    '    row_major float4x4 _21_mvp : packoffset(c0);'#10+
    '};'#10+


    'static float4 gl_Position;'#10+
    'static float4 position;'#10+
    'static float4 nrm;'#10+
    'static float4 normal;'#10+

    'struct SPIRV_Cross_Input'#10+
    '{'#10+
    '    float4 position : TEXCOORD0;'#10+
    '    float4 normal : TEXCOORD1;'#10+
    '};'#10+

    'struct SPIRV_Cross_Output'#10+
    '{'#10+
    '    float4 nrm : TEXCOORD0;'#10+
    '    float4 gl_Position : SV_Position;'#10+
    '};'#10+

    'void vert_main()'#10+
    '{'#10+
    '    gl_Position = mul(position, _21_mvp);'#10+
    '    nrm = normal;'#10+
    '}'#10+

    'SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)'#10+
    '{'#10+
    '    position = stage_input.position;'#10+
    '    normal = stage_input.normal;'#10+
    '    vert_main();'#10+
    '    SPIRV_Cross_Output stage_output;'#10+
    '    stage_output.gl_Position = gl_Position;'#10+
    '    stage_output.nrm = nrm;'#10+
    '    return stage_output;'#10+
    '}';

const
  FS_OFFSCREEN_SOURCE_HLSL5 =
    'static float4 frag_color;'#10+
    'static float4 nrm;'#10+

    'struct SPIRV_Cross_Input'#10+
    '{'#10+
    '    float4 nrm : TEXCOORD0;'#10+
    '};'#10+

    'struct SPIRV_Cross_Output'#10+
    '{'#10+
    '    float4 frag_color : SV_Target0;'#10+
    '};'#10+

    'void frag_main()'#10+
    '{'#10+
    '    frag_color = float4((nrm.xyz * 0.5f) + 0.5f.xxx, 1.0f);'#10+
    '}'#10+

    'SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)'#10+
    '{'#10+
    '    nrm = stage_input.nrm;'#10+
    '    frag_main();'#10+
    '    SPIRV_Cross_Output stage_output;'#10+
    '    stage_output.frag_color = frag_color;'#10+
    '    return stage_output;'#10+
    '}';

const
  VS_DEFAULT_SOURCE_HLSL5 =
    'cbuffer vs_params : register(b0)'#10+
    '{'#10+
    '    row_major float4x4 _21_mvp : packoffset(c0);'#10+
    '};'#10+


    'static float4 gl_Position;'#10+
    'static float4 position;'#10+
    'static float2 uv;'#10+
    'static float2 texcoord0;'#10+
    'static float4 nrm;'#10+
    'static float4 normal;'#10+

    'struct SPIRV_Cross_Input'#10+
    '{'#10+
    '    float4 position : TEXCOORD0;'#10+
    '    float4 normal : TEXCOORD1;'#10+
    '    float2 texcoord0 : TEXCOORD2;'#10+
    '};'#10+

    'struct SPIRV_Cross_Output'#10+
    '{'#10+
    '    float4 nrm : TEXCOORD0;'#10+
    '    float2 uv : TEXCOORD1;'#10+
    '    float4 gl_Position : SV_Position;'#10+
    '};'#10+

    'void vert_main()'#10+
    '{'#10+
    '    gl_Position = mul(position, _21_mvp);'#10+
    '    uv = texcoord0;'#10+
    '    nrm = mul(normal, _21_mvp);'#10+
    '}'#10+

    'SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)'#10+
    '{'#10+
    '    position = stage_input.position;'#10+
    '    texcoord0 = stage_input.texcoord0;'#10+
    '    normal = stage_input.normal;'#10+
    '    vert_main();'#10+
    '    SPIRV_Cross_Output stage_output;'#10+
    '    stage_output.gl_Position = gl_Position;'#10+
    '    stage_output.uv = uv;'#10+
    '    stage_output.nrm = nrm;'#10+
    '    return stage_output;'#10+
    '}';

const
  FS_DEFAULT_SOURCE_HLSL5 =
    'Texture2D<float4> tex : register(t0);'#10+
    'SamplerState _tex_sampler : register(s0);'#10+

    'static float2 uv;'#10+
    'static float4 nrm;'#10+
    'static float4 frag_color;'#10+

    'struct SPIRV_Cross_Input'#10+
    '{'#10+
    '    float4 nrm : TEXCOORD0;'#10+
    '    float2 uv : TEXCOORD1;'#10+
    '};'#10+

    'struct SPIRV_Cross_Output'#10+
    '{'#10+
    '    float4 frag_color : SV_Target0;'#10+
    '};'#10+

    'void frag_main()'#10+
    '{'#10+
    '    frag_color = float4(tex.Sample(_tex_sampler, uv * float2(20.0f, 10.0f)).xyz * ((clamp(dot(nrm.xyz, float3(0.57735025882720947265625f, 0.57735025882720947265625f, -0.57735025882720947265625f)), '+
      '0.0f, 1.0f) * 2.0f) + 0.25f), 1.0f);'#10+
    '}'#10+

    'SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)'#10+
    '{'#10+
    '    uv = stage_input.uv;'#10+
    '    nrm = stage_input.nrm;'#10+
    '    frag_main();'#10+
    '    SPIRV_Cross_Output stage_output;'#10+
    '    stage_output.frag_color = frag_color;'#10+
    '    return stage_output;'#10+
    '}';

{$ENDIF !SOKOL_D3D11}

{$IFDEF SOKOL_METAL}
const
  VS_OFFSCREEN_SOURCE_METAL_MACOS =
    '#include <metal_stdlib>'#10+
    '#include <simd/simd.h>'#10+

    'using namespace metal;'#10+

    'struct vs_params'#10+
    '{'#10+
    '    float4x4 mvp;'#10+
    '};'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float4 nrm [[user(locn0)]];'#10+
    '    float4 gl_Position [[position]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float4 position [[attribute(0)]];'#10+
    '    float4 normal [[attribute(1)]];'#10+
    '};'#10+

    'vertex main0_out main0(main0_in in [[stage_in]], constant vs_params& _21 [[buffer(0)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.gl_Position = _21.mvp * in.position;'#10+
    '    out.nrm = in.normal;'#10+
    '    return out;'#10+
    '}';

const
  FS_OFFSCREEN_SOURCE_METAL_MACOS =
    '#include <metal_stdlib>'#10+
    '#include <simd/simd.h>'#10+

    'using namespace metal;'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float4 frag_color [[color(0)]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float4 nrm [[user(locn0)]];'#10+
    '};'#10+

    'fragment main0_out main0(main0_in in [[stage_in]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.frag_color = float4((in.nrm.xyz * 0.5) + float3(0.5), 1.0);'#10+
    '    return out;'#10+
    '}';

const
  VS_DEFAULT_SOURCE_METAL_MACOS =
    '#include <metal_stdlib>'#10+
    '#include <simd/simd.h>'#10+

    'using namespace metal;'#10+

    'struct vs_params'#10+
    '{'#10+
    '    float4x4 mvp;'#10+
    '};'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float4 nrm [[user(locn0)]];'#10+
    '    float2 uv [[user(locn1)]];'#10+
    '    float4 gl_Position [[position]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float4 position [[attribute(0)]];'#10+
    '    float4 normal [[attribute(1)]];'#10+
    '    float2 texcoord0 [[attribute(2)]];'#10+
    '};'#10+

    'vertex main0_out main0(main0_in in [[stage_in]], constant vs_params& _21 [[buffer(0)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.gl_Position = _21.mvp * in.position;'#10+
    '    out.uv = in.texcoord0;'#10+
    '    out.nrm = _21.mvp * in.normal;'#10+
    '    return out;'#10+
    '}';

const
  FS_DEFAULT_SOURCE_METAL_MACOS =
    '#include <metal_stdlib>'#10+
    '#include <simd/simd.h>'#10+

    'using namespace metal;'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float4 frag_color [[color(0)]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float4 nrm [[user(locn0)]];'#10+
    '    float2 uv [[user(locn1)]];'#10+
    '};'#10+

    'fragment main0_out main0(main0_in in [[stage_in]], texture2d<float> tex [[texture(0)]], sampler texSmplr [[sampler(0)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.frag_color = float4(tex.sample(texSmplr, (in.uv * float2(20.0, 10.0))).xyz * ((fast::clamp(dot(in.nrm.xyz, float3(0.57735025882720947265625, 0.57735025882720947265625, '+
      '-0.57735025882720947265625)), 0.0, 1.0) * 2.0) + 0.25), 1.0);'#10+
    '    return out;'#10+
    '}';

{$ENDIF !SOKOL_METAL}

{$IFDEF SOKOL_METAL}
const
  VS_OFFSCREEN_SOURCE_METAL_IOS =
    '#include <metal_stdlib>'#10+
    '#include <simd/simd.h>'#10+

    'using namespace metal;'#10+

    'struct vs_params'#10+
    '{'#10+
    '    float4x4 mvp;'#10+
    '};'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float4 nrm [[user(locn0)]];'#10+
    '    float4 gl_Position [[position]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float4 position [[attribute(0)]];'#10+
    '    float4 normal [[attribute(1)]];'#10+
    '};'#10+

    'vertex main0_out main0(main0_in in [[stage_in]], constant vs_params& _21 [[buffer(0)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.gl_Position = _21.mvp * in.position;'#10+
    '    out.nrm = in.normal;'#10+
    '    return out;'#10+
    '}';

const
  FS_OFFSCREEN_SOURCE_METAL_IOS =
    '#include <metal_stdlib>'#10+
    '#include <simd/simd.h>'#10+

    'using namespace metal;'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float4 frag_color [[color(0)]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float4 nrm [[user(locn0)]];'#10+
    '};'#10+

    'fragment main0_out main0(main0_in in [[stage_in]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.frag_color = float4((in.nrm.xyz * 0.5) + float3(0.5), 1.0);'#10+
    '    return out;'#10+
    '}';

const
  VS_DEFAULT_SOURCE_METAL_IOS =
    '#include <metal_stdlib>'#10+
    '#include <simd/simd.h>'#10+

    'using namespace metal;'#10+

    'struct vs_params'#10+
    '{'#10+
    '    float4x4 mvp;'#10+
    '};'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float4 nrm [[user(locn0)]];'#10+
    '    float2 uv [[user(locn1)]];'#10+
    '    float4 gl_Position [[position]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float4 position [[attribute(0)]];'#10+
    '    float4 normal [[attribute(1)]];'#10+
    '    float2 texcoord0 [[attribute(2)]];'#10+
    '};'#10+

    'vertex main0_out main0(main0_in in [[stage_in]], constant vs_params& _21 [[buffer(0)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.gl_Position = _21.mvp * in.position;'#10+
    '    out.uv = in.texcoord0;'#10+
    '    out.nrm = _21.mvp * in.normal;'#10+
    '    return out;'#10+
    '}';

const
  FS_DEFAULT_SOURCE_METAL_IOS =
    '#include <metal_stdlib>'#10+
    '#include <simd/simd.h>'#10+

    'using namespace metal;'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float4 frag_color [[color(0)]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float4 nrm [[user(locn0)]];'#10+
    '    float2 uv [[user(locn1)]];'#10+
    '};'#10+

    'fragment main0_out main0(main0_in in [[stage_in]], texture2d<float> tex [[texture(0)]], sampler texSmplr [[sampler(0)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.frag_color = float4(tex.sample(texSmplr, (in.uv * float2(20.0, 10.0))).xyz * ((fast::clamp(dot(in.nrm.xyz, float3(0.57735025882720947265625, 0.57735025882720947265625, '+
      '-0.57735025882720947265625)), 0.0, 1.0) * 2.0) + 0.25), 1.0);'#10+
    '    return out;'#10+
    '}';

{$ENDIF !SOKOL_METAL}

var
  GDefaultShaderDesc: TNativeShaderDesc;

procedure InitDefaultShaderDesc;
begin
  GDefaultShaderDesc.Init;
  GDefaultShaderDesc.Attrs[0].Init('position', 'TEXCOORD', 0);
  GDefaultShaderDesc.Attrs[1].Init('normal', 'TEXCOORD', 1);
  GDefaultShaderDesc.Attrs[2].Init('texcoord0', 'TEXCOORD', 2);

  case TGfx.Backend of
    {$IFDEF SOKOL_GLCORE33}
    TBackend.GLCore33:
      begin
        GDefaultShaderDesc.VS.Source := VS_DEFAULT_SOURCE_GLSL330;
        GDefaultShaderDesc.FS.Source := FS_DEFAULT_SOURCE_GLSL330;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_GLES2}
    TBackend.Gles2:
      begin
        GDefaultShaderDesc.VS.Source := VS_DEFAULT_SOURCE_GLSL100;
        GDefaultShaderDesc.FS.Source := FS_DEFAULT_SOURCE_GLSL100;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_GLES3}
    TBackend.Gles3:
      begin
        GDefaultShaderDesc.VS.Source := VS_DEFAULT_SOURCE_GLSL300ES;
        GDefaultShaderDesc.FS.Source := FS_DEFAULT_SOURCE_GLSL300ES;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_D3D11}
    TBackend.D3D11:
      begin
        GDefaultShaderDesc.VS.Source := VS_DEFAULT_SOURCE_HLSL5;
        GDefaultShaderDesc.FS.Source := FS_DEFAULT_SOURCE_HLSL5;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_METAL}
    TBackend.MetalMacOS:
      begin
        GDefaultShaderDesc.VS.Source := VS_DEFAULT_SOURCE_METAL_MACOS;
        GDefaultShaderDesc.FS.Source := FS_DEFAULT_SOURCE_METAL_MACOS;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_METAL}
    TBackend.MetalIOS:
      begin
        GDefaultShaderDesc.VS.Source := VS_DEFAULT_SOURCE_METAL_IOS;
        GDefaultShaderDesc.FS.Source := FS_DEFAULT_SOURCE_METAL_IOS;
      end;
    {$ENDIF}
  else
    Assert(False)
  end;

  GDefaultShaderDesc.vs.uniform_blocks[0].size := 64;
  GDefaultShaderDesc.vs.uniform_blocks[0].layout := _SG_UNIFORMLAYOUT_STD140;
  if (TGfx.Backend.IsGL) then
    GDefaultShaderDesc.vs.uniform_blocks[0].uniforms[0].Init('vs_params', _SG_UNIFORMTYPE_FLOAT4, 4);
  GDefaultShaderDesc.fs.images[0].Init('tex', _SG_IMAGETYPE_2D, _SG_SAMPLERTYPE_FLOAT);
  GDefaultShaderDesc.&label := 'DefaultShader';
end;

function DefaultShaderDesc: PNativeShaderDesc;
begin
  if (GDefaultShaderDesc.VS.Entry = nil) then
    InitDefaultShaderDesc;

  Result := @GDefaultShaderDesc;
end;


var
  GOffscreenShaderDesc: TNativeShaderDesc;

procedure InitOffscreenShaderDesc;
begin
  GOffscreenShaderDesc.Init;
  GOffscreenShaderDesc.Attrs[0].Init('position', 'TEXCOORD', 0);
  GOffscreenShaderDesc.Attrs[1].Init('normal', 'TEXCOORD', 1);

  case TGfx.Backend of
    {$IFDEF SOKOL_GLCORE33}
    TBackend.GLCore33:
      begin
        GOffscreenShaderDesc.VS.Source := VS_OFFSCREEN_SOURCE_GLSL330;
        GOffscreenShaderDesc.FS.Source := FS_OFFSCREEN_SOURCE_GLSL330;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_GLES2}
    TBackend.Gles2:
      begin
        GOffscreenShaderDesc.VS.Source := VS_OFFSCREEN_SOURCE_GLSL100;
        GOffscreenShaderDesc.FS.Source := FS_OFFSCREEN_SOURCE_GLSL100;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_GLES3}
    TBackend.Gles3:
      begin
        GOffscreenShaderDesc.VS.Source := VS_OFFSCREEN_SOURCE_GLSL300ES;
        GOffscreenShaderDesc.FS.Source := FS_OFFSCREEN_SOURCE_GLSL300ES;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_D3D11}
    TBackend.D3D11:
      begin
        GOffscreenShaderDesc.VS.Source := VS_OFFSCREEN_SOURCE_HLSL5;
        GOffscreenShaderDesc.FS.Source := FS_OFFSCREEN_SOURCE_HLSL5;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_METAL}
    TBackend.MetalMacOS:
      begin
        GOffscreenShaderDesc.VS.Source := VS_OFFSCREEN_SOURCE_METAL_MACOS;
        GOffscreenShaderDesc.FS.Source := FS_OFFSCREEN_SOURCE_METAL_MACOS;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_METAL}
    TBackend.MetalIOS:
      begin
        GOffscreenShaderDesc.VS.Source := VS_OFFSCREEN_SOURCE_METAL_IOS;
        GOffscreenShaderDesc.FS.Source := FS_OFFSCREEN_SOURCE_METAL_IOS;
      end;
    {$ENDIF}
  else
    Assert(False)
  end;

  GOffscreenShaderDesc.vs.uniform_blocks[0].size := 64;
  GOffscreenShaderDesc.vs.uniform_blocks[0].layout := _SG_UNIFORMLAYOUT_STD140;
  if (TGfx.Backend.IsGL) then
    GOffscreenShaderDesc.vs.uniform_blocks[0].uniforms[0].Init('vs_params', _SG_UNIFORMTYPE_FLOAT4, 4);
  GOffscreenShaderDesc.&label := 'OffscreenShader';
end;

function OffscreenShaderDesc: PNativeShaderDesc;
begin
  if (GOffscreenShaderDesc.VS.Entry = nil) then
    InitOffscreenShaderDesc;

  Result := @GOffscreenShaderDesc;
end;

end.

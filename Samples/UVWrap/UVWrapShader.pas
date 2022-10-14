unit UVWrapShader;
{ #version:1# (machine generated, don't edit!)

  Generated by sokol-shdc (https://github.com/floooh/sokol-tools)
  With Delphi modifications (https://github.com/neslib/Neslib.Sokol.Tools)

  Cmdline: sokol-shdc --input UVWrapShader.glsl --output UVWrapShader.pas

  Overview:

    Shader program 'uvwrap':
      Get shader desc: UvwrapShaderDesc()
      Vertex shader: vs
        Attribute slots:
          ATTR_VS_POS = 0
        Uniform block 'vs_params':
          Delphi record: TVSParams
          Bind slot: SLOT_VS_PARAMS = 0
      Fragment shader: fs
        Image 'tex':
          Type: _SG_IMAGETYPE_2D
          Component Type: _SG_SAMPLERTYPE_FLOAT
          Bind slot: SLOT_TEX = 0


  Shader descriptor records:

    var UvwrapShader := TShader.Create(UvwrapShaderDesc);

  Vertex attribute locations for vertex shader 'vs':

    var PipDesc: TPipelineDesc;
    PipDesc.Init;
    PipDesc.Attrs[ATTR_VS_POS]. ...
    PipDesc. ...
    var Pip := TPipeline.Create(PipDesc);

  Image bind slots, use as index in TBindings.VSImages[] or .FSImages[]:

    SLOT_TEX = 0;

  Bind slot and Delphi record for uniform block 'VSParams':

    VSParams: TVSParams;
    VSParams.Offset := ...;
    VSParams.Scale := ...;
    TGfx.ApplyUniforms(TShaderStage.[VertexShader|FragmentShader], SLOT_VS_PARAMS, TRange.Create(VSParams));

}

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.FastMath,
  Neslib.Sokol.Gfx;

const
  ATTR_VS_POS = 0;

const
  SLOT_TEX = 0;

const
  SLOT_VS_PARAMS = 0;

type
  TVSParams = packed record
  public
    Offset: TVector2;
    Scale: TVector2;
  end;

function UvwrapShaderDesc: PNativeShaderDesc;

implementation

uses
  Neslib.Sokol.Api;

{$IFDEF SOKOL_GLCORE33}
const
  VS_SOURCE_GLSL330 =
    '#version 330'#10+

    'uniform vec4 vs_params[1];'#10+
    'layout(location = 0) in vec4 pos;'#10+
    'out vec2 uv;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_Position = vec4((pos.xy * vs_params[0].zw) + vs_params[0].xy, 0.5, 1.0);'#10+
    '    uv = pos.xy + vec2(0.5);'#10+
    '}';

const
  FS_SOURCE_GLSL330 =
    '#version 330'#10+

    'uniform sampler2D tex;'#10+

    'layout(location = 0) out vec4 frag_color;'#10+
    'in vec2 uv;'#10+

    'void main()'#10+
    '{'#10+
    '    frag_color = texture(tex, uv);'#10+
    '}';

{$ENDIF !SOKOL_GLCORE33}

{$IFDEF SOKOL_GLES2}
const
  VS_SOURCE_GLSL100 =
    '#version 100'#10+

    'uniform vec4 vs_params[1];'#10+
    'attribute vec4 pos;'#10+
    'varying vec2 uv;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_Position = vec4((pos.xy * vs_params[0].zw) + vs_params[0].xy, 0.5, 1.0);'#10+
    '    uv = pos.xy + vec2(0.5);'#10+
    '}';

const
  FS_SOURCE_GLSL100 =
    '#version 100'#10+
    'precision mediump float;'#10+
    'precision highp int;'#10+

    'uniform highp sampler2D tex;'#10+

    'varying highp vec2 uv;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_FragData[0] = texture2D(tex, uv);'#10+
    '}';

{$ENDIF !SOKOL_GLES2}

{$IFDEF SOKOL_GLES3}
const
  VS_SOURCE_GLSL300ES =
    '#version 300 es'#10+

    'uniform vec4 vs_params[1];'#10+
    'layout(location = 0) in vec4 pos;'#10+
    'out vec2 uv;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_Position = vec4((pos.xy * vs_params[0].zw) + vs_params[0].xy, 0.5, 1.0);'#10+
    '    uv = pos.xy + vec2(0.5);'#10+
    '}';

const
  FS_SOURCE_GLSL300ES =
    '#version 300 es'#10+
    'precision mediump float;'#10+
    'precision highp int;'#10+

    'uniform highp sampler2D tex;'#10+

    'layout(location = 0) out highp vec4 frag_color;'#10+
    'in highp vec2 uv;'#10+

    'void main()'#10+
    '{'#10+
    '    frag_color = texture(tex, uv);'#10+
    '}';

{$ENDIF !SOKOL_GLES3}

{$IFDEF SOKOL_D3D11}
const
  VS_SOURCE_HLSL5 =
    'cbuffer vs_params : register(b0)'#10+
    '{'#10+
    '    float2 _25_offset : packoffset(c0);'#10+
    '    float2 _25_scale : packoffset(c0.z);'#10+
    '};'#10+


    'static float4 gl_Position;'#10+
    'static float4 pos;'#10+
    'static float2 uv;'#10+

    'struct SPIRV_Cross_Input'#10+
    '{'#10+
    '    float4 pos : TEXCOORD0;'#10+
    '};'#10+

    'struct SPIRV_Cross_Output'#10+
    '{'#10+
    '    float2 uv : TEXCOORD0;'#10+
    '    float4 gl_Position : SV_Position;'#10+
    '};'#10+

    'void vert_main()'#10+
    '{'#10+
    '    gl_Position = float4((pos.xy * _25_scale) + _25_offset, 0.5f, 1.0f);'#10+
    '    uv = pos.xy + 0.5f.xx;'#10+
    '}'#10+

    'SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)'#10+
    '{'#10+
    '    pos = stage_input.pos;'#10+
    '    vert_main();'#10+
    '    SPIRV_Cross_Output stage_output;'#10+
    '    stage_output.gl_Position = gl_Position;'#10+
    '    stage_output.uv = uv;'#10+
    '    return stage_output;'#10+
    '}';

const
  FS_SOURCE_HLSL5 =
    'Texture2D<float4> tex : register(t0);'#10+
    'SamplerState _tex_sampler : register(s0);'#10+

    'static float4 frag_color;'#10+
    'static float2 uv;'#10+

    'struct SPIRV_Cross_Input'#10+
    '{'#10+
    '    float2 uv : TEXCOORD0;'#10+
    '};'#10+

    'struct SPIRV_Cross_Output'#10+
    '{'#10+
    '    float4 frag_color : SV_Target0;'#10+
    '};'#10+

    'void frag_main()'#10+
    '{'#10+
    '    frag_color = tex.Sample(_tex_sampler, uv);'#10+
    '}'#10+

    'SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)'#10+
    '{'#10+
    '    uv = stage_input.uv;'#10+
    '    frag_main();'#10+
    '    SPIRV_Cross_Output stage_output;'#10+
    '    stage_output.frag_color = frag_color;'#10+
    '    return stage_output;'#10+
    '}';

{$ENDIF !SOKOL_D3D11}

{$IFDEF SOKOL_METAL}
const
  VS_SOURCE_METAL_MACOS =
    '#include <metal_stdlib>'#10+
    '#include <simd/simd.h>'#10+

    'using namespace metal;'#10+

    'struct vs_params'#10+
    '{'#10+
    '    float2 offset;'#10+
    '    float2 scale;'#10+
    '};'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float2 uv [[user(locn0)]];'#10+
    '    float4 gl_Position [[position]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float4 pos [[attribute(0)]];'#10+
    '};'#10+

    'vertex main0_out main0(main0_in in [[stage_in]], constant vs_params& _25 [[buffer(0)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.gl_Position = float4((in.pos.xy * _25.scale) + _25.offset, 0.5, 1.0);'#10+
    '    out.uv = in.pos.xy + float2(0.5);'#10+
    '    return out;'#10+
    '}';

const
  FS_SOURCE_METAL_MACOS =
    '#include <metal_stdlib>'#10+
    '#include <simd/simd.h>'#10+

    'using namespace metal;'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float4 frag_color [[color(0)]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float2 uv [[user(locn0)]];'#10+
    '};'#10+

    'fragment main0_out main0(main0_in in [[stage_in]], texture2d<float> tex [[texture(0)]], sampler texSmplr [[sampler(0)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.frag_color = tex.sample(texSmplr, in.uv);'#10+
    '    return out;'#10+
    '}';

{$ENDIF !SOKOL_METAL}

{$IFDEF SOKOL_METAL}
const
  VS_SOURCE_METAL_IOS =
    '#include <metal_stdlib>'#10+
    '#include <simd/simd.h>'#10+

    'using namespace metal;'#10+

    'struct vs_params'#10+
    '{'#10+
    '    float2 offset;'#10+
    '    float2 scale;'#10+
    '};'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float2 uv [[user(locn0)]];'#10+
    '    float4 gl_Position [[position]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float4 pos [[attribute(0)]];'#10+
    '};'#10+

    'vertex main0_out main0(main0_in in [[stage_in]], constant vs_params& _25 [[buffer(0)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.gl_Position = float4((in.pos.xy * _25.scale) + _25.offset, 0.5, 1.0);'#10+
    '    out.uv = in.pos.xy + float2(0.5);'#10+
    '    return out;'#10+
    '}';

const
  FS_SOURCE_METAL_IOS =
    '#include <metal_stdlib>'#10+
    '#include <simd/simd.h>'#10+

    'using namespace metal;'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float4 frag_color [[color(0)]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float2 uv [[user(locn0)]];'#10+
    '};'#10+

    'fragment main0_out main0(main0_in in [[stage_in]], texture2d<float> tex [[texture(0)]], sampler texSmplr [[sampler(0)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.frag_color = tex.sample(texSmplr, in.uv);'#10+
    '    return out;'#10+
    '}';

{$ENDIF !SOKOL_METAL}

var
  GUvwrapShaderDesc: TNativeShaderDesc;

procedure InitUvwrapShaderDesc;
begin
  GUvwrapShaderDesc.Init;
  GUvwrapShaderDesc.Attrs[0].Init('pos', 'TEXCOORD', 0);

  case TGfx.Backend of
    {$IFDEF SOKOL_GLCORE33}
    TBackend.GLCore33:
      begin
        GUvwrapShaderDesc.VS.Source := VS_SOURCE_GLSL330;
        GUvwrapShaderDesc.FS.Source := FS_SOURCE_GLSL330;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_GLES2}
    TBackend.Gles2:
      begin
        GUvwrapShaderDesc.VS.Source := VS_SOURCE_GLSL100;
        GUvwrapShaderDesc.FS.Source := FS_SOURCE_GLSL100;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_GLES3}
    TBackend.Gles3:
      begin
        GUvwrapShaderDesc.VS.Source := VS_SOURCE_GLSL300ES;
        GUvwrapShaderDesc.FS.Source := FS_SOURCE_GLSL300ES;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_D3D11}
    TBackend.D3D11:
      begin
        GUvwrapShaderDesc.VS.Source := VS_SOURCE_HLSL5;
        GUvwrapShaderDesc.FS.Source := FS_SOURCE_HLSL5;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_METAL}
    TBackend.MetalMacOS:
      begin
        GUvwrapShaderDesc.VS.Source := VS_SOURCE_METAL_MACOS;
        GUvwrapShaderDesc.FS.Source := FS_SOURCE_METAL_MACOS;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_METAL}
    TBackend.MetalIOS:
      begin
        GUvwrapShaderDesc.VS.Source := VS_SOURCE_METAL_IOS;
        GUvwrapShaderDesc.FS.Source := FS_SOURCE_METAL_IOS;
      end;
    {$ENDIF}
  else
    Assert(False)
  end;

  GUvwrapShaderDesc.vs.uniform_blocks[0].size := 16;
  GUvwrapShaderDesc.vs.uniform_blocks[0].layout := _SG_UNIFORMLAYOUT_STD140;
  if (TGfx.Backend.IsGL) then
    GUvwrapShaderDesc.vs.uniform_blocks[0].uniforms[0].Init('vs_params', _SG_UNIFORMTYPE_FLOAT4, 1);
  GUvwrapShaderDesc.fs.images[0].Init('tex', _SG_IMAGETYPE_2D, _SG_SAMPLERTYPE_FLOAT);
  GUvwrapShaderDesc.&label := 'UvwrapShader';
end;

function UvwrapShaderDesc: PNativeShaderDesc;
begin
  if (GUvwrapShaderDesc.VS.Entry = nil) then
    InitUvwrapShaderDesc;

  Result := @GUvwrapShaderDesc;
end;

end.

unit PLMpegShader;
{ #version:1# (machine generated, don't edit!)

  Generated by sokol-shdc (https://github.com/floooh/sokol-tools)
  With Delphi modifications (https://github.com/neslib/Neslib.Sokol.Tools)

  Cmdline: sokol-shdc --input PLMpegShader.glsl --output PLMpegShader.pas

  Overview:

    Shader program 'plmpeg':
      Get shader desc: PlmpegShaderDesc()
      Vertex shader: vs
        Attribute slots:
          ATTR_VS_POS = 0
          ATTR_VS_NORMAL = 1
          ATTR_VS_TEXCOORD = 2
        Uniform block 'vs_params':
          Delphi record: TVSParams
          Bind slot: SLOT_VS_PARAMS = 0
      Fragment shader: fs
        Image 'tex_y':
          Type: _SG_IMAGETYPE_2D
          Component Type: _SG_SAMPLERTYPE_FLOAT
          Bind slot: SLOT_TEX_Y = 0
        Image 'tex_cb':
          Type: _SG_IMAGETYPE_2D
          Component Type: _SG_SAMPLERTYPE_FLOAT
          Bind slot: SLOT_TEX_CB = 1
        Image 'tex_cr':
          Type: _SG_IMAGETYPE_2D
          Component Type: _SG_SAMPLERTYPE_FLOAT
          Bind slot: SLOT_TEX_CR = 2


  Shader descriptor records:

    var PlmpegShader := TShader.Create(PlmpegShaderDesc);

  Vertex attribute locations for vertex shader 'vs':

    var PipDesc: TPipelineDesc;
    PipDesc.Init;
    PipDesc.Attrs[ATTR_VS_POS]. ...
    PipDesc.Attrs[ATTR_VS_NORMAL]. ...
    PipDesc.Attrs[ATTR_VS_TEXCOORD]. ...
    PipDesc. ...
    var Pip := TPipeline.Create(PipDesc);

  Image bind slots, use as index in TBindings.VSImages[] or .FSImages[]:

    SLOT_TEX_Y = 0;
    SLOT_TEX_CB = 1;
    SLOT_TEX_CR = 2;

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
  ATTR_VS_POS = 0;
  ATTR_VS_NORMAL = 1;
  ATTR_VS_TEXCOORD = 2;

const
  SLOT_TEX_Y = 0;
  SLOT_TEX_CB = 1;
  SLOT_TEX_CR = 2;

const
  SLOT_VS_PARAMS = 0;

type
  TVSParams = packed record
  public
    Mvp: TMatrix4;
  end;

function PlmpegShaderDesc: PNativeShaderDesc;

implementation

uses
  Neslib.Sokol.Api;

{$IFDEF SOKOL_GLCORE33}
const
  VS_SOURCE_GLSL330 =
    '#version 330'#10+

    'uniform vec4 vs_params[4];'#10+
    'layout(location = 0) in vec4 pos;'#10+
    'layout(location = 1) in vec3 normal;'#10+
    'out vec2 uv;'#10+
    'layout(location = 2) in vec2 texcoord;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_Position = mat4(vs_params[0], vs_params[1], vs_params[2], vs_params[3]) * ((pos * vec4(1.7599999904632568359375, 1.0, 1.7599999904632568359375, 1.0)) + vec4(normal * 0.5, 0.0));'#10+
    '    uv = texcoord;'#10+
    '}';

const
  FS_SOURCE_GLSL330 =
    '#version 330'#10+

    'uniform sampler2D tex_y;'#10+
    'uniform sampler2D tex_cb;'#10+
    'uniform sampler2D tex_cr;'#10+

    'in vec2 uv;'#10+
    'layout(location = 0) out vec4 frag_color;'#10+
    'mat4 rec601;'#10+

    'void main()'#10+
    '{'#10+
    '    rec601 = mat4(vec4(1.16437995433807373046875, 0.0, 1.5960299968719482421875, -0.870790004730224609375), vec4(1.16437995433807373046875, -0.39175999164581298828125, -0.812969982624053955078125, '+
      '0.52959001064300537109375), vec4(1.16437995433807373046875, 2.01723003387451171875, 0.0, -1.08139002323150634765625), vec4(0.0, 0.0, 0.0, 1.0));'#10+
    '    frag_color = vec4(texture(tex_y, uv).x, texture(tex_cb, uv).x, texture(tex_cr, uv).x, 1.0) * rec601;'#10+
    '}';

{$ENDIF !SOKOL_GLCORE33}

{$IFDEF SOKOL_GLES2}
const
  VS_SOURCE_GLSL100 =
    '#version 100'#10+

    'uniform vec4 vs_params[4];'#10+
    'attribute vec4 pos;'#10+
    'attribute vec3 normal;'#10+
    'varying vec2 uv;'#10+
    'attribute vec2 texcoord;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_Position = mat4(vs_params[0], vs_params[1], vs_params[2], vs_params[3]) * ((pos * vec4(1.7599999904632568359375, 1.0, 1.7599999904632568359375, 1.0)) + vec4(normal * 0.5, 0.0));'#10+
    '    uv = texcoord;'#10+
    '}';

const
  FS_SOURCE_GLSL100 =
    '#version 100'#10+
    'precision mediump float;'#10+
    'precision highp int;'#10+

    'uniform highp sampler2D tex_y;'#10+
    'uniform highp sampler2D tex_cb;'#10+
    'uniform highp sampler2D tex_cr;'#10+

    'varying highp vec2 uv;'#10+
    'highp mat4 rec601;'#10+

    'void main()'#10+
    '{'#10+
    '    rec601 = mat4(vec4(1.16437995433807373046875, 0.0, 1.5960299968719482421875, -0.870790004730224609375), vec4(1.16437995433807373046875, -0.39175999164581298828125, -0.812969982624053955078125, '+
      '0.52959001064300537109375), vec4(1.16437995433807373046875, 2.01723003387451171875, 0.0, -1.08139002323150634765625), vec4(0.0, 0.0, 0.0, 1.0));'#10+
    '    gl_FragData[0] = vec4(texture2D(tex_y, uv).x, texture2D(tex_cb, uv).x, texture2D(tex_cr, uv).x, 1.0) * rec601;'#10+
    '}';

{$ENDIF !SOKOL_GLES2}

{$IFDEF SOKOL_GLES3}
const
  VS_SOURCE_GLSL300ES =
    '#version 300 es'#10+

    'uniform vec4 vs_params[4];'#10+
    'layout(location = 0) in vec4 pos;'#10+
    'layout(location = 1) in vec3 normal;'#10+
    'out vec2 uv;'#10+
    'layout(location = 2) in vec2 texcoord;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_Position = mat4(vs_params[0], vs_params[1], vs_params[2], vs_params[3]) * ((pos * vec4(1.7599999904632568359375, 1.0, 1.7599999904632568359375, 1.0)) + vec4(normal * 0.5, 0.0));'#10+
    '    uv = texcoord;'#10+
    '}';

const
  FS_SOURCE_GLSL300ES =
    '#version 300 es'#10+
    'precision mediump float;'#10+
    'precision highp int;'#10+

    'uniform highp sampler2D tex_y;'#10+
    'uniform highp sampler2D tex_cb;'#10+
    'uniform highp sampler2D tex_cr;'#10+

    'in highp vec2 uv;'#10+
    'layout(location = 0) out highp vec4 frag_color;'#10+
    'highp mat4 rec601;'#10+

    'void main()'#10+
    '{'#10+
    '    rec601 = mat4(vec4(1.16437995433807373046875, 0.0, 1.5960299968719482421875, -0.870790004730224609375), vec4(1.16437995433807373046875, -0.39175999164581298828125, -0.812969982624053955078125, '+
      '0.52959001064300537109375), vec4(1.16437995433807373046875, 2.01723003387451171875, 0.0, -1.08139002323150634765625), vec4(0.0, 0.0, 0.0, 1.0));'#10+
    '    frag_color = vec4(texture(tex_y, uv).x, texture(tex_cb, uv).x, texture(tex_cr, uv).x, 1.0) * rec601;'#10+
    '}';

{$ENDIF !SOKOL_GLES3}

{$IFDEF SOKOL_D3D11}
const
  VS_SOURCE_HLSL5 =
    'cbuffer vs_params : register(b0)'#10+
    '{'#10+
    '    row_major float4x4 _21_mvp : packoffset(c0);'#10+
    '};'#10+


    'static float4 gl_Position;'#10+
    'static float4 pos;'#10+
    'static float3 normal;'#10+
    'static float2 uv;'#10+
    'static float2 texcoord;'#10+

    'struct SPIRV_Cross_Input'#10+
    '{'#10+
    '    float4 pos : TEXCOORD0;'#10+
    '    float3 normal : TEXCOORD1;'#10+
    '    float2 texcoord : TEXCOORD2;'#10+
    '};'#10+

    'struct SPIRV_Cross_Output'#10+
    '{'#10+
    '    float2 uv : TEXCOORD0;'#10+
    '    float4 gl_Position : SV_Position;'#10+
    '};'#10+

    'void vert_main()'#10+
    '{'#10+
    '    gl_Position = mul((pos * float4(1.7599999904632568359375f, 1.0f, 1.7599999904632568359375f, 1.0f)) + float4(normal * 0.5f, 0.0f), _21_mvp);'#10+
    '    uv = texcoord;'#10+
    '}'#10+

    'SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)'#10+
    '{'#10+
    '    pos = stage_input.pos;'#10+
    '    normal = stage_input.normal;'#10+
    '    texcoord = stage_input.texcoord;'#10+
    '    vert_main();'#10+
    '    SPIRV_Cross_Output stage_output;'#10+
    '    stage_output.gl_Position = gl_Position;'#10+
    '    stage_output.uv = uv;'#10+
    '    return stage_output;'#10+
    '}';

const
  FS_SOURCE_HLSL5 =
    'Texture2D<float4> tex_y : register(t0);'#10+
    'SamplerState _tex_y_sampler : register(s0);'#10+
    'Texture2D<float4> tex_cb : register(t1);'#10+
    'SamplerState _tex_cb_sampler : register(s1);'#10+
    'Texture2D<float4> tex_cr : register(t2);'#10+
    'SamplerState _tex_cr_sampler : register(s2);'#10+

    'static float2 uv;'#10+
    'static float4 frag_color;'#10+

    'struct SPIRV_Cross_Input'#10+
    '{'#10+
    '    float2 uv : TEXCOORD0;'#10+
    '};'#10+

    'struct SPIRV_Cross_Output'#10+
    '{'#10+
    '    float4 frag_color : SV_Target0;'#10+
    '};'#10+

    'static float4x4 rec601;'#10+

    'void frag_main()'#10+
    '{'#10+
    '    rec601 = float4x4(float4(1.16437995433807373046875f, 0.0f, 1.5960299968719482421875f, -0.870790004730224609375f), float4(1.16437995433807373046875f, -0.39175999164581298828125f, '+
      '-0.812969982624053955078125f, 0.52959001064300537109375f), float4(1.16437995433807373046875f, 2.01723003387451171875f, 0.0f, -1.08139002323150634765625f), float4(0.0f, 0.0f, 0.0f, 1.0f));'#10+
    '    frag_color = mul(rec601, float4(tex_y.Sample(_tex_y_sampler, uv).x, tex_cb.Sample(_tex_cb_sampler, uv).x, tex_cr.Sample(_tex_cr_sampler, uv).x, 1.0f));'#10+
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
    '    float4x4 mvp;'#10+
    '};'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float2 uv [[user(locn0)]];'#10+
    '    float4 gl_Position [[position]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float4 pos [[attribute(0)]];'#10+
    '    float3 normal [[attribute(1)]];'#10+
    '    float2 texcoord [[attribute(2)]];'#10+
    '};'#10+

    'vertex main0_out main0(main0_in in [[stage_in]], constant vs_params& _21 [[buffer(0)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.gl_Position = _21.mvp * ((in.pos * float4(1.7599999904632568359375, 1.0, 1.7599999904632568359375, 1.0)) + float4(in.normal * 0.5, 0.0));'#10+
    '    out.uv = in.texcoord;'#10+
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

    'fragment main0_out main0(main0_in in [[stage_in]], texture2d<float> tex_y [[texture(0)]], texture2d<float> tex_cb [[texture(1)]], texture2d<float> tex_cr [[texture(2)]], sampler tex_ySmplr '+
      '[[sampler(0)]], sampler tex_cbSmplr [[sampler(1)]], sampler tex_crSmplr [[sampler(2)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    float4x4 rec601 = float4x4(float4(1.16437995433807373046875, 0.0, 1.5960299968719482421875, -0.870790004730224609375), float4(1.16437995433807373046875, -0.39175999164581298828125, '+
      '-0.812969982624053955078125, 0.52959001064300537109375), float4(1.16437995433807373046875, 2.01723003387451171875, 0.0, -1.08139002323150634765625), float4(0.0, 0.0, 0.0, 1.0));'#10+
    '    out.frag_color = float4(tex_y.sample(tex_ySmplr, in.uv).x, tex_cb.sample(tex_cbSmplr, in.uv).x, tex_cr.sample(tex_crSmplr, in.uv).x, 1.0) * rec601;'#10+
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
    '    float4x4 mvp;'#10+
    '};'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float2 uv [[user(locn0)]];'#10+
    '    float4 gl_Position [[position]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float4 pos [[attribute(0)]];'#10+
    '    float3 normal [[attribute(1)]];'#10+
    '    float2 texcoord [[attribute(2)]];'#10+
    '};'#10+

    'vertex main0_out main0(main0_in in [[stage_in]], constant vs_params& _21 [[buffer(0)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.gl_Position = _21.mvp * ((in.pos * float4(1.7599999904632568359375, 1.0, 1.7599999904632568359375, 1.0)) + float4(in.normal * 0.5, 0.0));'#10+
    '    out.uv = in.texcoord;'#10+
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

    'fragment main0_out main0(main0_in in [[stage_in]], texture2d<float> tex_y [[texture(0)]], texture2d<float> tex_cb [[texture(1)]], texture2d<float> tex_cr [[texture(2)]], sampler tex_ySmplr '+
      '[[sampler(0)]], sampler tex_cbSmplr [[sampler(1)]], sampler tex_crSmplr [[sampler(2)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    float4x4 rec601 = float4x4(float4(1.16437995433807373046875, 0.0, 1.5960299968719482421875, -0.870790004730224609375), float4(1.16437995433807373046875, -0.39175999164581298828125, '+
      '-0.812969982624053955078125, 0.52959001064300537109375), float4(1.16437995433807373046875, 2.01723003387451171875, 0.0, -1.08139002323150634765625), float4(0.0, 0.0, 0.0, 1.0));'#10+
    '    out.frag_color = float4(tex_y.sample(tex_ySmplr, in.uv).x, tex_cb.sample(tex_cbSmplr, in.uv).x, tex_cr.sample(tex_crSmplr, in.uv).x, 1.0) * rec601;'#10+
    '    return out;'#10+
    '}';

{$ENDIF !SOKOL_METAL}

var
  GPlmpegShaderDesc: TNativeShaderDesc;

procedure InitPlmpegShaderDesc;
begin
  GPlmpegShaderDesc.Init;
  GPlmpegShaderDesc.Attrs[0].Init('pos', 'TEXCOORD', 0);
  GPlmpegShaderDesc.Attrs[1].Init('normal', 'TEXCOORD', 1);
  GPlmpegShaderDesc.Attrs[2].Init('texcoord', 'TEXCOORD', 2);

  case TGfx.Backend of
    {$IFDEF SOKOL_GLCORE33}
    TBackend.GLCore33:
      begin
        GPlmpegShaderDesc.VS.Source := VS_SOURCE_GLSL330;
        GPlmpegShaderDesc.FS.Source := FS_SOURCE_GLSL330;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_GLES2}
    TBackend.Gles2:
      begin
        GPlmpegShaderDesc.VS.Source := VS_SOURCE_GLSL100;
        GPlmpegShaderDesc.FS.Source := FS_SOURCE_GLSL100;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_GLES3}
    TBackend.Gles3:
      begin
        GPlmpegShaderDesc.VS.Source := VS_SOURCE_GLSL300ES;
        GPlmpegShaderDesc.FS.Source := FS_SOURCE_GLSL300ES;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_D3D11}
    TBackend.D3D11:
      begin
        GPlmpegShaderDesc.VS.Source := VS_SOURCE_HLSL5;
        GPlmpegShaderDesc.FS.Source := FS_SOURCE_HLSL5;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_METAL}
    TBackend.MetalMacOS:
      begin
        GPlmpegShaderDesc.VS.Source := VS_SOURCE_METAL_MACOS;
        GPlmpegShaderDesc.FS.Source := FS_SOURCE_METAL_MACOS;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_METAL}
    TBackend.MetalIOS:
      begin
        GPlmpegShaderDesc.VS.Source := VS_SOURCE_METAL_IOS;
        GPlmpegShaderDesc.FS.Source := FS_SOURCE_METAL_IOS;
      end;
    {$ENDIF}
  else
    Assert(False)
  end;

  GPlmpegShaderDesc.vs.uniform_blocks[0].size := 64;
  GPlmpegShaderDesc.vs.uniform_blocks[0].layout := _SG_UNIFORMLAYOUT_STD140;
  if (TGfx.Backend.IsGL) then
    GPlmpegShaderDesc.vs.uniform_blocks[0].uniforms[0].Init('vs_params', _SG_UNIFORMTYPE_FLOAT4, 4);
  GPlmpegShaderDesc.fs.images[0].Init('tex_y', _SG_IMAGETYPE_2D, _SG_SAMPLERTYPE_FLOAT);
  GPlmpegShaderDesc.fs.images[1].Init('tex_cb', _SG_IMAGETYPE_2D, _SG_SAMPLERTYPE_FLOAT);
  GPlmpegShaderDesc.fs.images[2].Init('tex_cr', _SG_IMAGETYPE_2D, _SG_SAMPLERTYPE_FLOAT);
  GPlmpegShaderDesc.&label := 'PlmpegShader';
end;

function PlmpegShaderDesc: PNativeShaderDesc;
begin
  if (GPlmpegShaderDesc.VS.Entry = nil) then
    InitPlmpegShaderDesc;

  Result := @GPlmpegShaderDesc;
end;

end.

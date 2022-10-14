unit Tex3DShader;
{ #version:1# (machine generated, don't edit!)

  Generated by sokol-shdc (https://github.com/floooh/sokol-tools)
  With Delphi modifications (https://github.com/neslib/Neslib.Sokol.Tools)

  Cmdline: sokol-shdc --input Tex3DShader.glsl --output Tex3DShader.pas

  Overview:

    Shader program 'cube':
      Get shader desc: CubeShaderDesc()
      Vertex shader: vs
        Attribute slots:
          ATTR_VS_POSITION = 0
        Uniform block 'vs_params':
          Delphi record: TVSParams
          Bind slot: SLOT_VS_PARAMS = 0
      Fragment shader: fs
        Image 'tex':
          Type: _SG_IMAGETYPE_3D
          Component Type: _SG_SAMPLERTYPE_FLOAT
          Bind slot: SLOT_TEX = 0


  Shader descriptor records:

    var CubeShader := TShader.Create(CubeShaderDesc);

  Vertex attribute locations for vertex shader 'vs':

    var PipDesc: TPipelineDesc;
    PipDesc.Init;
    PipDesc.Attrs[ATTR_VS_POSITION]. ...
    PipDesc. ...
    var Pip := TPipeline.Create(PipDesc);

  Image bind slots, use as index in TBindings.VSImages[] or .FSImages[]:

    SLOT_TEX = 0;

  Bind slot and Delphi record for uniform block 'VSParams':

    VSParams: TVSParams;
    VSParams.Mvp := ...;
    VSParams.Scale := ...;
    TGfx.ApplyUniforms(TShaderStage.[VertexShader|FragmentShader], SLOT_VS_PARAMS, TRange.Create(VSParams));

}

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.FastMath,
  Neslib.Sokol.Gfx;

const
  ATTR_VS_POSITION = 0;

const
  SLOT_TEX = 0;

const
  SLOT_VS_PARAMS = 0;

type
  TVSParams = packed record
  public
    Mvp: TMatrix4;
    Scale: Single;
    _Pad68: array [0..11] of UInt8;
  end;

function CubeShaderDesc: PNativeShaderDesc;

implementation

uses
  Neslib.Sokol.Api;

{$IFDEF SOKOL_GLCORE33}
const
  VS_SOURCE_GLSL330 =
    '#version 330'#10+

    'uniform vec4 vs_params[5];'#10+
    'layout(location = 0) in vec4 position;'#10+
    'out vec3 uvw;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_Position = mat4(vs_params[0], vs_params[1], vs_params[2], vs_params[3]) * position;'#10+
    '    uvw = ((position.xyz * vs_params[4].x) + vec3(1.0)) * 0.5;'#10+
    '}';

const
  FS_SOURCE_GLSL330 =
    '#version 330'#10+

    'uniform sampler3D tex;'#10+

    'layout(location = 0) out vec4 frag_color;'#10+
    'in vec3 uvw;'#10+

    'void main()'#10+
    '{'#10+
    '    frag_color = texture(tex, uvw);'#10+
    '}';

{$ENDIF !SOKOL_GLCORE33}

{$IFDEF SOKOL_GLES2}
const
  VS_SOURCE_GLSL100 =
    '#version 100'#10+

    'uniform vec4 vs_params[5];'#10+
    'attribute vec4 position;'#10+
    'varying vec3 uvw;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_Position = mat4(vs_params[0], vs_params[1], vs_params[2], vs_params[3]) * position;'#10+
    '    uvw = ((position.xyz * vs_params[4].x) + vec3(1.0)) * 0.5;'#10+
    '}';

const
  FS_SOURCE_GLSL100 =
    '#version 100'#10+
    'precision mediump float;'#10+
    'precision highp int;'#10+

    'uniform highp sampler3D tex;'#10+

    'varying highp vec3 uvw;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_FragData[0] = texture3D(tex, uvw);'#10+
    '}';

{$ENDIF !SOKOL_GLES2}

{$IFDEF SOKOL_GLES3}
const
  VS_SOURCE_GLSL300ES =
    '#version 300 es'#10+

    'uniform vec4 vs_params[5];'#10+
    'layout(location = 0) in vec4 position;'#10+
    'out vec3 uvw;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_Position = mat4(vs_params[0], vs_params[1], vs_params[2], vs_params[3]) * position;'#10+
    '    uvw = ((position.xyz * vs_params[4].x) + vec3(1.0)) * 0.5;'#10+
    '}';

const
  FS_SOURCE_GLSL300ES =
    '#version 300 es'#10+
    'precision mediump float;'#10+
    'precision highp int;'#10+

    'uniform highp sampler3D tex;'#10+

    'layout(location = 0) out highp vec4 frag_color;'#10+
    'in highp vec3 uvw;'#10+

    'void main()'#10+
    '{'#10+
    '    frag_color = texture(tex, uvw);'#10+
    '}';

{$ENDIF !SOKOL_GLES3}

{$IFDEF SOKOL_D3D11}
const
  VS_SOURCE_HLSL5 =
    'cbuffer vs_params : register(b0)'#10+
    '{'#10+
    '    row_major float4x4 _21_mvp : packoffset(c0);'#10+
    '    float _21_scale : packoffset(c4);'#10+
    '};'#10+


    'static float4 gl_Position;'#10+
    'static float4 position;'#10+
    'static float3 uvw;'#10+

    'struct SPIRV_Cross_Input'#10+
    '{'#10+
    '    float4 position : TEXCOORD0;'#10+
    '};'#10+

    'struct SPIRV_Cross_Output'#10+
    '{'#10+
    '    float3 uvw : TEXCOORD0;'#10+
    '    float4 gl_Position : SV_Position;'#10+
    '};'#10+

    'void vert_main()'#10+
    '{'#10+
    '    gl_Position = mul(position, _21_mvp);'#10+
    '    uvw = ((position.xyz * _21_scale) + 1.0f.xxx) * 0.5f;'#10+
    '}'#10+

    'SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)'#10+
    '{'#10+
    '    position = stage_input.position;'#10+
    '    vert_main();'#10+
    '    SPIRV_Cross_Output stage_output;'#10+
    '    stage_output.gl_Position = gl_Position;'#10+
    '    stage_output.uvw = uvw;'#10+
    '    return stage_output;'#10+
    '}';

const
  FS_SOURCE_HLSL5 =
    'Texture3D<float4> tex : register(t0);'#10+
    'SamplerState _tex_sampler : register(s0);'#10+

    'static float4 frag_color;'#10+
    'static float3 uvw;'#10+

    'struct SPIRV_Cross_Input'#10+
    '{'#10+
    '    float3 uvw : TEXCOORD0;'#10+
    '};'#10+

    'struct SPIRV_Cross_Output'#10+
    '{'#10+
    '    float4 frag_color : SV_Target0;'#10+
    '};'#10+

    'void frag_main()'#10+
    '{'#10+
    '    frag_color = tex.Sample(_tex_sampler, uvw);'#10+
    '}'#10+

    'SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)'#10+
    '{'#10+
    '    uvw = stage_input.uvw;'#10+
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
    '    float scale;'#10+
    '};'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float3 uvw [[user(locn0)]];'#10+
    '    float4 gl_Position [[position]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float4 position [[attribute(0)]];'#10+
    '};'#10+

    'vertex main0_out main0(main0_in in [[stage_in]], constant vs_params& _21 [[buffer(0)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.gl_Position = _21.mvp * in.position;'#10+
    '    out.uvw = ((in.position.xyz * _21.scale) + float3(1.0)) * 0.5;'#10+
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
    '    float3 uvw [[user(locn0)]];'#10+
    '};'#10+

    'fragment main0_out main0(main0_in in [[stage_in]], texture3d<float> tex [[texture(0)]], sampler texSmplr [[sampler(0)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.frag_color = tex.sample(texSmplr, in.uvw);'#10+
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
    '    float scale;'#10+
    '};'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float3 uvw [[user(locn0)]];'#10+
    '    float4 gl_Position [[position]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float4 position [[attribute(0)]];'#10+
    '};'#10+

    'vertex main0_out main0(main0_in in [[stage_in]], constant vs_params& _21 [[buffer(0)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.gl_Position = _21.mvp * in.position;'#10+
    '    out.uvw = ((in.position.xyz * _21.scale) + float3(1.0)) * 0.5;'#10+
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
    '    float3 uvw [[user(locn0)]];'#10+
    '};'#10+

    'fragment main0_out main0(main0_in in [[stage_in]], texture3d<float> tex [[texture(0)]], sampler texSmplr [[sampler(0)]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.frag_color = tex.sample(texSmplr, in.uvw);'#10+
    '    return out;'#10+
    '}';

{$ENDIF !SOKOL_METAL}

var
  GCubeShaderDesc: TNativeShaderDesc;

procedure InitCubeShaderDesc;
begin
  GCubeShaderDesc.Init;
  GCubeShaderDesc.Attrs[0].Init('position', 'TEXCOORD', 0);

  case TGfx.Backend of
    {$IFDEF SOKOL_GLCORE33}
    TBackend.GLCore33:
      begin
        GCubeShaderDesc.VS.Source := VS_SOURCE_GLSL330;
        GCubeShaderDesc.FS.Source := FS_SOURCE_GLSL330;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_GLES2}
    TBackend.Gles2:
      begin
        GCubeShaderDesc.VS.Source := VS_SOURCE_GLSL100;
        GCubeShaderDesc.FS.Source := FS_SOURCE_GLSL100;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_GLES3}
    TBackend.Gles3:
      begin
        GCubeShaderDesc.VS.Source := VS_SOURCE_GLSL300ES;
        GCubeShaderDesc.FS.Source := FS_SOURCE_GLSL300ES;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_D3D11}
    TBackend.D3D11:
      begin
        GCubeShaderDesc.VS.Source := VS_SOURCE_HLSL5;
        GCubeShaderDesc.FS.Source := FS_SOURCE_HLSL5;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_METAL}
    TBackend.MetalMacOS:
      begin
        GCubeShaderDesc.VS.Source := VS_SOURCE_METAL_MACOS;
        GCubeShaderDesc.FS.Source := FS_SOURCE_METAL_MACOS;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_METAL}
    TBackend.MetalIOS:
      begin
        GCubeShaderDesc.VS.Source := VS_SOURCE_METAL_IOS;
        GCubeShaderDesc.FS.Source := FS_SOURCE_METAL_IOS;
      end;
    {$ENDIF}
  else
    Assert(False)
  end;

  GCubeShaderDesc.vs.uniform_blocks[0].size := 80;
  GCubeShaderDesc.vs.uniform_blocks[0].layout := _SG_UNIFORMLAYOUT_STD140;
  if (TGfx.Backend.IsGL) then
    GCubeShaderDesc.vs.uniform_blocks[0].uniforms[0].Init('vs_params', _SG_UNIFORMTYPE_FLOAT4, 5);
  GCubeShaderDesc.fs.images[0].Init('tex', _SG_IMAGETYPE_3D, _SG_SAMPLERTYPE_FLOAT);
  GCubeShaderDesc.&label := 'CubeShader';
end;

function CubeShaderDesc: PNativeShaderDesc;
begin
  if (GCubeShaderDesc.VS.Entry = nil) then
    InitCubeShaderDesc;

  Result := @GCubeShaderDesc;
end;

end.
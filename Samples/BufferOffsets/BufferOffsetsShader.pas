unit BufferOffsetsShader;
{ #version:1# (machine generated, don't edit!)

  Generated by sokol-shdc (https://github.com/floooh/sokol-tools)
  With Delphi modifications (https://github.com/neslib/Neslib.Sokol.Tools)

  Cmdline: sokol-shdc --input BufferOffsetsShader.glsl --output BufferOffsetsShader.pas

  Overview:

    Shader program 'bufferoffsets':
      Get shader desc: BufferoffsetsShaderDesc()
      Vertex shader: vs
        Attribute slots:
          ATTR_VS_POSITION = 0
          ATTR_VS_COLOR0 = 1
      Fragment shader: fs


  Shader descriptor records:

    var BufferoffsetsShader := TShader.Create(BufferoffsetsShaderDesc);

  Vertex attribute locations for vertex shader 'vs':

    var PipDesc: TPipelineDesc;
    PipDesc.Init;
    PipDesc.Attrs[ATTR_VS_POSITION]. ...
    PipDesc.Attrs[ATTR_VS_COLOR0]. ...
    PipDesc. ...
    var Pip := TPipeline.Create(PipDesc);

  Image bind slots, use as index in TBindings.VSImages[] or .FSImages[]:


}

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.FastMath,
  Neslib.Sokol.Gfx;

const
  ATTR_VS_POSITION = 0;
  ATTR_VS_COLOR0 = 1;

function BufferoffsetsShaderDesc: PNativeShaderDesc;

implementation

uses
  Neslib.Sokol.Api;

{$IFDEF SOKOL_GLCORE33}
const
  VS_SOURCE_GLSL330 =
    '#version 330'#10+

    'layout(location = 0) in vec4 position;'#10+
    'out vec4 color;'#10+
    'layout(location = 1) in vec4 color0;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_Position = position;'#10+
    '    color = color0;'#10+
    '}';

const
  FS_SOURCE_GLSL330 =
    '#version 330'#10+

    'layout(location = 0) out vec4 frag_color;'#10+
    'in vec4 color;'#10+

    'void main()'#10+
    '{'#10+
    '    frag_color = color;'#10+
    '}';

{$ENDIF !SOKOL_GLCORE33}

{$IFDEF SOKOL_GLES2}
const
  VS_SOURCE_GLSL100 =
    '#version 100'#10+

    'attribute vec4 position;'#10+
    'varying vec4 color;'#10+
    'attribute vec4 color0;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_Position = position;'#10+
    '    color = color0;'#10+
    '}';

const
  FS_SOURCE_GLSL100 =
    '#version 100'#10+
    'precision mediump float;'#10+
    'precision highp int;'#10+

    'varying highp vec4 color;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_FragData[0] = color;'#10+
    '}';

{$ENDIF !SOKOL_GLES2}

{$IFDEF SOKOL_GLES3}
const
  VS_SOURCE_GLSL300ES =
    '#version 300 es'#10+

    'layout(location = 0) in vec4 position;'#10+
    'out vec4 color;'#10+
    'layout(location = 1) in vec4 color0;'#10+

    'void main()'#10+
    '{'#10+
    '    gl_Position = position;'#10+
    '    color = color0;'#10+
    '}';

const
  FS_SOURCE_GLSL300ES =
    '#version 300 es'#10+
    'precision mediump float;'#10+
    'precision highp int;'#10+

    'layout(location = 0) out highp vec4 frag_color;'#10+
    'in highp vec4 color;'#10+

    'void main()'#10+
    '{'#10+
    '    frag_color = color;'#10+
    '}';

{$ENDIF !SOKOL_GLES3}

{$IFDEF SOKOL_D3D11}
const
  VS_SOURCE_HLSL5 =
    'static float4 gl_Position;'#10+
    'static float4 position;'#10+
    'static float4 color;'#10+
    'static float4 color0;'#10+

    'struct SPIRV_Cross_Input'#10+
    '{'#10+
    '    float4 position : TEXCOORD0;'#10+
    '    float4 color0 : TEXCOORD1;'#10+
    '};'#10+

    'struct SPIRV_Cross_Output'#10+
    '{'#10+
    '    float4 color : TEXCOORD0;'#10+
    '    float4 gl_Position : SV_Position;'#10+
    '};'#10+

    'void vert_main()'#10+
    '{'#10+
    '    gl_Position = position;'#10+
    '    color = color0;'#10+
    '}'#10+

    'SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)'#10+
    '{'#10+
    '    position = stage_input.position;'#10+
    '    color0 = stage_input.color0;'#10+
    '    vert_main();'#10+
    '    SPIRV_Cross_Output stage_output;'#10+
    '    stage_output.gl_Position = gl_Position;'#10+
    '    stage_output.color = color;'#10+
    '    return stage_output;'#10+
    '}';

const
  FS_SOURCE_HLSL5 =
    'static float4 frag_color;'#10+
    'static float4 color;'#10+

    'struct SPIRV_Cross_Input'#10+
    '{'#10+
    '    float4 color : TEXCOORD0;'#10+
    '};'#10+

    'struct SPIRV_Cross_Output'#10+
    '{'#10+
    '    float4 frag_color : SV_Target0;'#10+
    '};'#10+

    'void frag_main()'#10+
    '{'#10+
    '    frag_color = color;'#10+
    '}'#10+

    'SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)'#10+
    '{'#10+
    '    color = stage_input.color;'#10+
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

    'struct main0_out'#10+
    '{'#10+
    '    float4 color [[user(locn0)]];'#10+
    '    float4 gl_Position [[position]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float4 position [[attribute(0)]];'#10+
    '    float4 color0 [[attribute(1)]];'#10+
    '};'#10+

    'vertex main0_out main0(main0_in in [[stage_in]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.gl_Position = in.position;'#10+
    '    out.color = in.color0;'#10+
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
    '    float4 color [[user(locn0)]];'#10+
    '};'#10+

    'fragment main0_out main0(main0_in in [[stage_in]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.frag_color = in.color;'#10+
    '    return out;'#10+
    '}';

{$ENDIF !SOKOL_METAL}

{$IFDEF SOKOL_METAL}
const
  VS_SOURCE_METAL_IOS =
    '#include <metal_stdlib>'#10+
    '#include <simd/simd.h>'#10+

    'using namespace metal;'#10+

    'struct main0_out'#10+
    '{'#10+
    '    float4 color [[user(locn0)]];'#10+
    '    float4 gl_Position [[position]];'#10+
    '};'#10+

    'struct main0_in'#10+
    '{'#10+
    '    float4 position [[attribute(0)]];'#10+
    '    float4 color0 [[attribute(1)]];'#10+
    '};'#10+

    'vertex main0_out main0(main0_in in [[stage_in]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.gl_Position = in.position;'#10+
    '    out.color = in.color0;'#10+
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
    '    float4 color [[user(locn0)]];'#10+
    '};'#10+

    'fragment main0_out main0(main0_in in [[stage_in]])'#10+
    '{'#10+
    '    main0_out out = {};'#10+
    '    out.frag_color = in.color;'#10+
    '    return out;'#10+
    '}';

{$ENDIF !SOKOL_METAL}

var
  GBufferoffsetsShaderDesc: TNativeShaderDesc;

procedure InitBufferoffsetsShaderDesc;
begin
  GBufferoffsetsShaderDesc.Init;
  GBufferoffsetsShaderDesc.Attrs[0].Init('position', 'TEXCOORD', 0);
  GBufferoffsetsShaderDesc.Attrs[1].Init('color0', 'TEXCOORD', 1);

  case TGfx.Backend of
    {$IFDEF SOKOL_GLCORE33}
    TBackend.GLCore33:
      begin
        GBufferoffsetsShaderDesc.VS.Source := VS_SOURCE_GLSL330;
        GBufferoffsetsShaderDesc.FS.Source := FS_SOURCE_GLSL330;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_GLES2}
    TBackend.Gles2:
      begin
        GBufferoffsetsShaderDesc.VS.Source := VS_SOURCE_GLSL100;
        GBufferoffsetsShaderDesc.FS.Source := FS_SOURCE_GLSL100;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_GLES3}
    TBackend.Gles3:
      begin
        GBufferoffsetsShaderDesc.VS.Source := VS_SOURCE_GLSL300ES;
        GBufferoffsetsShaderDesc.FS.Source := FS_SOURCE_GLSL300ES;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_D3D11}
    TBackend.D3D11:
      begin
        GBufferoffsetsShaderDesc.VS.Source := VS_SOURCE_HLSL5;
        GBufferoffsetsShaderDesc.FS.Source := FS_SOURCE_HLSL5;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_METAL}
    TBackend.MetalMacOS:
      begin
        GBufferoffsetsShaderDesc.VS.Source := VS_SOURCE_METAL_MACOS;
        GBufferoffsetsShaderDesc.FS.Source := FS_SOURCE_METAL_MACOS;
      end;
    {$ENDIF}

    {$IFDEF SOKOL_METAL}
    TBackend.MetalIOS:
      begin
        GBufferoffsetsShaderDesc.VS.Source := VS_SOURCE_METAL_IOS;
        GBufferoffsetsShaderDesc.FS.Source := FS_SOURCE_METAL_IOS;
      end;
    {$ENDIF}
  else
    Assert(False)
  end;

  GBufferoffsetsShaderDesc.&label := 'BufferoffsetsShader';
end;

function BufferoffsetsShaderDesc: PNativeShaderDesc;
begin
  if (GBufferoffsetsShaderDesc.VS.Entry = nil) then
    InitBufferoffsetsShaderDesc;

  Result := @GBufferoffsetsShaderDesc;
end;

end.
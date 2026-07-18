# Shader Cross Compilation

Shader code generate for [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md).

## Feature Overview

sokol-shdc is a shader-cross-compiler and -code-generator command line tool which translates an 'annotated GLSL' source file into a Delphi unit (or other output formats) for use with Neslib.Sokol.Gfx.

Note that these generated files depend on the Neslib.FastMath unit, which provides very fast hand-optimized SIMD assembly routines for vector and matrix math. You can find it on GitHub: https://github.com/neslib/FastMath.

IMPORTANT: You *must* add the `FM_COLUMN_MAJOR` define to your project for matrix calculations to work correctly with Neslib.Sokol.Gfx!

Shaders are written in 'Vulkan-style GLSL' (version 450 with separate texture and sampler uniforms) and translated into the following shader dialects:

- GLSL v300es (for GLES3.0 and WebGL2 without compute shader support)
- GLSL v310es (for GLES3.1 with compute shader support)
- GLSL v410 (for desktop GL 4.1 without compute shader support)
- GLSL v430 (for desktop GL 4.3+ with compute shader support)
- HLSL4 or HLSL5 (for D3D11), optionally as bytecode
- Metal (for macOS and iOS), optionally as bytecode

This cross-compilation happens via existing Khronos and Google open source projects:

- [glslang](https://github.com/KhronosGroup/glslang): for compiling GLSL to SPIR-V
- [SPIRV-Tools](https://github.com/KhronosGroup/SPIRV-Tools): the SPIR-V optimizer is used to run optimization passes on the intermediate SPIRV (mainly for dead-code elimination)
- [SPIRV-Cross](https://github.com/KhronosGroup/SPIRV-Cross): for translating the SPIRV bytecode to GLSL dialects, HLSL and Metal

In addition to outputting a Delphi unit, sokol-shdc also supports output formats for C (and some other languages), as well as 'raw' output files in GLSL, MSL and HLSL along with reflection info in YAML files.

Input shader files are 'annotated' with custom **@-tags** which add meta-information to the GLSL source files. This is used for packing vertex- and fragment-shaders into the same source file, wrap and include reusable code blocks, and provide additional information for the C code-generation (note the `@vs`, `@fs`, `@end` and `@program` tags):

```glsl
@vs vs
layout(binding=0) uniform vs_params {
    mat4 mvp;
};

in vec4 position;
in vec2 texcoord0;

out vec2 uv;

void main() {
    gl_Position = mvp * position;
    uv = texcoord0;
}
@end

@fs fs
layout(binding=0) uniform texture2D tex;
layout(binding=0) uniform sampler smp;

in vec2 uv;
out vec4 frag_color;

void main() {
    frag_color = texture(sampler2D(tex,smp), uv);
}
@end

@program texcube vs fs
```

Note: For compatibility with other tools which parse GLSL, `#pragma sokol` may be used to prefix the tags. For example, the final line above could have also been written as:

```glsl
#pragma sokol @program texcube vs fs
```

A generated Delphi unit contains:

- human-readable reflection info in a comment block
- a Delphi record for each shader uniform block and storage buffer binding
- constants for vertex attribute locations, uniform block and resource view binding indices
- for each shader program, a Delphi function which returns `PNativeShaderDesc` which can be passed directly into `TShader.Create`
- optionally a set of Delphi functions for runtime inspection of the generated vertex attributes, image bind slots and uniform-block structs

For instance, creating a shader and pipeline object for the above simple *texcube* shader program looks like this:

```pascal
{ Create a shader object from generated TShaderDesc }
var Shader := TShader.Create(TexCubeShaderDesc);

{ Create a pipeline object with this shader, and 
  code-generated vertex attribute location constants }
var PipDesc := TPipelineDesc.Create;
PipDesc.Shader := FShader;
PipDesc.Layout.Attrs[ATTR_TEXCUBE_POSITION].Format := TVertexFormat.Float3;
PipDesc.Layout.Attrs[ATTR_TEXCUBE_COLOR0].Format := TVertexFormat.Float2;
FPip := TPipeline.Create(PipDesc);
```

...and then applying resource bindings and uniform updates looks like this:

```pascal
var Bindings := TBindings.Create;
Bindings.VertexBuffers[0] := VBuf;
Bindings.View[VIEW_TEX] := TexView;
Bindings.Samplers[SMP_SMP] := Smp;
TGfx.ApplyBindings;
```

## Build Integration
For easy build integration, you can run the sokol-shdc tool as part of your build process by adding a pre-build event in Delphi:
* Open your project options
* Navigate to "Building | Build Events"
* Under Target, select "All Configuration - All Platforms"
* Set the Commands for the Pre-build events to:
  
    ```
    sokol-shdc.exe --input MyShader.glsl --output MyShader.pas
    ```
* Leave the "Cancel on error" checkbox checked

Make sure that sokol-shdc is somewhere in the path, or use an absolute or relative path wherer you refer to it (see the various sample projects for examples).

When the tool encounters an error, it will report this to the Delphi Build log and stop the Delphi build process. For the full error message, look in the Output tab of the Messages window (View | Tool Windows | Messages).

## Command Line Parameters
sokol-shdc command line parameters:

* `-h --help`: Print usage information and exit

* `-i --input=[GLSL file]`: The path to the input shader file in sokol-shdc's "annotated GLSL" format, this must be either relative to the current working directory, or an absolute path.

* `-o --output=[path]`: The path to the generated output source file, either relative to the current working directory, or as absolute path. The target directory must exist. Note that some output generators may generate more than one output file, in that case the `-o` argument is used as the base path.

* `-t --tmpdir=[path]`: Optional path to a directory used for storing intermediate files when generating Metal bytecode. If no separate temporary directory is provided, intermediate files will be written to the same directory as the generated C header defined via `--output`. In both cases, the target directory must exist.

* `-l --slang=[shader languages]`: One or multiple output shader languages. If multiple languages are provided, they must be separated by a **colon**. Valid shader language names are:
  * `glsl410`: desktop GL 4.1 (e.g. macOS: no SSBOs and compute shaders)
    
     * `glsl430`: desktop GL 4.3
     * `glsl300es`: GLES3.0 / WebGL2
     * `glsl310es`: GLES3.1 (currently not supported by Neslib.Sokol.Gfx)
     * `hlsl4`: D3D11
  * `hlsl5`: D3D11
  * `metal_macos`: Metal on macOS
  * `metal_ios`: Metal on iOS device
  * `metal_sim`: Metal on iOS simulator
  * `wgsl`: WebGPU
  * `spirv_vk`: Vulkan-flavoured SPIRV

  For instance, to generate a header with support for Metal on macOS and desktop GL: `--slang glsl430:metal_macos`

* `-b --bytecode`: If possible, compile shaders to bytecode instead of embedding source code. The restrictions to generate shader bytecode are as follows:

  - target language must be `hlsl4`, `hlsl5`, `metal_macos` or `metal_ios`
  - sokol-shdc must run on the respective platforms:
    - `hlsl4, hlsl5`: only possible when sokol-shdc is running on Windows
    - `metal_macos, metal_ios`: only possible when sokol-shdc is running on macOS

  ...if these restrictions are not met, sokol-shdc will fall back to generating shader source code without returning an error. Note that the `metal_sim` target for the iOS simulator doesn't support generating bytecode, this will always emit Metal source code.

- `-f --format=[sokol,sokol_impl,...]`: set output backend (default: `sokol-delphi`)

  - `sokol-delphi`: Generate a Delphi unit
  - `sokol`: Generate a C header where data is declared as `static` and functions are declared as `static inline`. If this header is included multiple times, you should be aware that the executable may contain duplicate data.
  - `sokol_impl`: This generates an STB-style header. In exactly one place where the header is included, the define `SOKOL_SHDC_IMPL` must be defined to compile the implementation, all other places, only the declarations will be included.
  - `sokol_decl`: This is a special backward-compatible mode and shouldn't be used. In this mode, data is declared `static` and functions are declared `static inline`, and the implementation is included when the `SOKOL_SHDC_DECL` is *not* defined
  - `bare`: compiled shader code is written as plain text or binary files. For each combination of shader program and target language, a file name based on `--output` is written.
  - `bare_yaml`: like bare, but also creates a YAML file with shader reflection information.
  - `sokol_zig`: generates output for the [sokol-zig bindings](https://github.com/floooh/sokol-zig/)
  - `sokol_odin`: generates output for the [sokol-odin bindings](https://github.com/floooh/sokol-odin)
  - `sokol_nim`: generates output for the [sokol-nim bindings](https://github.com/floooh/sokol-nim)
  - `sokol_rust`: generates output for the [sokol-rust bindings](https://github.com/floooh/sokol-rust)
  - `sokol_d`: generates output for the [sokol-d bindings](https://github.com/kassane/sokol-d)
  - `sokol_c3`: generates output for the [sokol-c3 bindings](https://github.com/floooh/sokol-c3)
  - `sokol_c2`: generates output for the [sokol-c2 bindings](https://github.com/floooh/sokol-c2)
  - `sokol_jai`: generates output for the [sokol-jai bindings](https://github.com/colinbellino/sokol-jai)

  Note that some options and features of sokol-shdc can be contradictory to (and thus, ignored by) backends. For example, the `bare` backend only writes shader code, and disregards all other information.

- `-e --errfmt=[gcc,msvc]`: set the error message format to be either GCC-compatible or Visual-Studio-compatible, the default is `gcc`

- `-g --genver=[integer]`: set a version number to embed in the generated header, this is useful to detect whether all shader files need to be recompiled because the tooling has been updated (sokol-shdc will not check this though, this must be done in the build-system-integration)

- `--ifdef`: this tells the code generator to wrap 3D-backend-specific code into `{$IFDEF}..{$ENDIF}` pairs using the backend-selection defines:

  - SOKOL_GLCORE
  - SOKOL_GLES3
  - SOKOL_D3D11
  - SOKOL_METAL
  - SOKOL_VULKAN

- `-d --dump`: Enable verbose debug output, this basically dumps all internal information to stdout. Useful for debugging and understanding how sokol-shdc works, but not much else :)

- `--defines=[define1:define2:define3]`: a colon-separated list of preprocessor defines for the initial GLSL-to-SPIRV compilation pass

- `--module=[name]`: a command-line override for the `@module` keyword

- `--reflection`: if present, code-generate additional runtime-inspection functions (not that this is not supported by all code generation backends)

- `--save-intermediate-spirv`: debug feature to save out the intermediate SPIRV blob, useful for debug inspection

- `--no-log-cmdline`: don't log the command line to the output file (useful when the output is committed to version control and sokol-shdc is called with absolute input/output paths)

- `--dependency-file=[path]`: generate a Clang/GCC style dep-file for use with build systems

## Shader Tags reference

The following `@-tags` can be used in *annotated GLSL* source files:

### @vs [name]

Starts a named vertex shader code block. The code between the `@vs` and the next `@end` will be compiled as a vertex shader.

Example:

```glsl
@vs my_vertex_shader
layout(binding=0) uniform vs_params {
    mat4 mvp;
};

in vec4 position;
in vec4 color0;

out vec4 color;

void main() {
    gl_Position = mvp * position;
    color = color0;
}
@end
```

### @fs [name]

Starts a named fragment shader code block. The code between the `@fs` and the next `@end` will be compiled as a fragment shader.

Example:

```glsl
@fs my_fragment_shader
in vec4 color;
out vec4 frag_color;

void main() {
    frag_color = color;
}
@end
```

### @cs [name]

Starts a named compute shader code block. The code between `@cs` and the next `@end` will be compiled as a compute shader.

Example:

```glsl
@cs my_compute_shader

layout(binding=0) uniform cs_params {
    float dt;
    int num_particles;
};

struct particle {
    vec4 pos;
    vec4 vel;
};

layout(binding=0) buffer cs_ssbo {
    particle prt[];
};

layout(local_size_x=64, local_size_y=1, local_size_z=1) in;

void main() {
    uint idx = gl_GlobalInvocationID.x;
    if (idx >= num_particles) {
        return;
    }
    vec4 pos = prt[idx].pos;
    vec4 vel = prt[idx].vel;
    vel.y -= dt;
    pos += vel * dt;
    prt[idx].pos = pos;
    prt[idx].vel = vel;
}
@end
```

### @program [name] [vs] [fs]

### @program [name] [cs]

The `@program` tag links stage shader functions into a shader program consisting of either a vertex- and fragment-shader, or just a compute-shader.

The program name will be used for naming the generated `TShaderDesc` Delphi record struct and a Delphi function to get a pointer to the generated shader desc.

At least one `@program` tag must exist in an annotated GLSL source file.

Example for the above shader snippets:

```glsl
// vertex- and fragment-shader
@program my_program my_vertex_shader my_fragment_shader
// ...or just a compute shader
@program my_program my_compute_shader
```

This will generate a Delphi function:

```pascal
function MyProgramShaderDesc: PNativeShaderDesc;
```

### @block [name]

The `@block` tag starts a named code block which can be included in other `@vs`, `@fs`, `@cs` or `@block` code blocks. This is useful for sharing code between shaders.

Example for having a common lighting function shared between two fragment shaders:

```glsl
@block lighting
vec3 light(vec3 base_color, vec3 eye_vec, vec3 normal, vec3 light_vec) {
    ...
}
@end

@fs fs_1
@include_block lighting

out vec4 frag_color;
void main() {
    frag_color = vec4(light(...), 1.0);
}
@end

@fs fs_2
@include_block lighting

out vec4 frag_color;
void main() {
    frag_color = vec4(0.5 * light(...), 1.0);
}
@end
```

### @end

The `@end` tag closes a `@vs`, `@fs`, `@cs` or `@block` code block.

### @include_block [name]

`@include_block` includes a `@block` into another code block. This is useful for sharing code snippets between different shaders.

### @include [path]

Include a file from the files system. `@include` takes one argument: the path of the file to be included. The path must be relative to the directory where the top-level source file is located and must not contain whitespace or quotes. The `@include` tag can appear inside or outside a code block:

```glsl
@vs vs
@include bla/vs.glsl
@end

@include fs.glsl

@program cube vs fs
```

### @module [name]

The optional `@module` tag defines a 'namespace prefix' for all generated Delphi types, values, defines and functions:

```glsl
@module bla

@vs my_vs
layout(binding=0) uniform shape_uniforms {
    mat4 mvp;
    mat4 model;
    vec4 shape_color;
    vec4 light_dir;
    vec4 eye_pos;
};
@end
```

...the generated Delphi uniform block struct (allong with all other identifiers) would get a prefix `Bla`:

```pascal
type
  TBlaShapeUniforms = record
  public
    Mvp: TMatrix4;
    ...
  end;
```

Note that some output languages ignore the module tag.

### @glsl_options, @hlsl_options, @msl_options

These tags can be used to define per-shader/per-language options for SPIRV-Cross when compiling SPIR-V to GLSL, HLSL or MSL.

GL, D3D and Metal have different opinions where the origin of an image is, or whether clipspace-z goes from 0..+1 or from -1..+1, and the option-tags allow fine-control over those aspects with the following arguments:

* `fixup_clipspace`:
  - GLSL: In vertex shaders, rewrite [0, w] depth (Vulkan/D3D style) to [-w, w] depth (GL style).
  - HLSL: In vertex shaders, rewrite [-w, w] depth (GL style) to [0, w] depth.
  - MSL: In vertex shaders, rewrite [-w, w] depth (GL style) to [0, w] depth.
* `flip_vert_y`: Inverts `gl_Position.y` or equivalent. (all shader languages)

Currently, `@glsl_option`, `@hlsl_option` and `@msl_option` are only allowed inside `@vs`, `@end` blocks.

## Shader Authoring Considerations

### Target Shader Language Defines
In the input GLSL source, use the following checks to conditionally compile code for the different target shader languages:

```glsl
  #if SOKOL_GLSL
      // target shader language is a GLSL dialect
  #endif

  #if SOKOL_HLSL
      // target shader language is HLSL
  #endif

  #if SOKOL_MSL
      // target shader language is MetalSL
  #endif
```

Normally, SPIRV-Cross does its best to 'normalize' the differences between GLSL, HLSL and MSL, but sometimes it's still necessary to write different code for different target languages.

These checks are evaluated by the initial compiler pass which compiles GLSL v450 to SPIR-V, and only make sense inside `@vs`, `@fs` and `@block` code-blocks.

### Creating shaders and pipeline objects
The generated Delphi unit will contain one function for each shader program which returns a pointer to a completely initialized `TShaderDesc` record, so creating a shader object becomes a one-liner.

For instance, with the following `@program` in the GLSL file:

```glsl
  @program shape vs fs
```

The following code would be used to create the shader object:

```pascal
  var Shader := TShader.Create(ShapeShaderDesc);
```

When creating a pipeline object, the shader code generator will provide integer constants for the vertex attribute locations.

Consider the following vertex shader inputs in the GLSL source code:

```glsl
  @vs vs
  in vec4 position;
  in vec3 normal;
  in vec2 texcoords;
  ...
  @end
```

The vertex attribute description in the `TPipelineDesc` record could look like this (note the attribute indices names `ATTR_VS_POSITION`, etc...):

```pascal
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := Shader;
  PipDesc.Layout.Attrs[ATTR_VS_POSITION].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_VS_NORMAL].Format := TVertexFormat.Byte4N;
  PipDesc.Layout.Attrs[ATTR_VS_TEXCOORDS].Format := TVertexFormat.Short2;
  var Pip := TPipeline.Create(PipDesc);
```

It's also possible to provide explicit vertex attribute location in the shader code:

```glsl
  @vs vs
  layout(location=0) in vec4 position;
  layout(location=1) in vec3 normal;
  layout(location=2) in vec2 texcoords;
  ...
  @end
```

When the shader code uses explicit location, the generated location constants can be ignored on the Pascal side:

```pascal
  PipDesc.Layout.Attrs[0].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[1].Format := TVertexFormat.Byte4N;
  PipDesc.Layout.Attrs[2].Format := TVertexFormat.Short2;
```

### Defining resource bind slots

All GLSL resource types (uniform blocks, textures, samplers, storage images and storage buffers) must be annotated with explicit bind slots via `layout(binding=N)`, which are split into 3 separate binding spaces:

- uniform blocks (all shader stages):
  - `layout(binding=N) uniform { ... }` where `(N >= 0) && (N < 8)`
  - N maps to to the ub_slot params in `TGfx.ApplyUniforms(N, ...)`
- textures, storage-images and storage-buffers (all shader stages):
  - `layout(binding=N) texture2D tex;`
  - `layout(binding=N) readonly buffer ssbo { ... }`
  - `layout(binding=N, rgba8) uniform writeonly image2D img`
  - ...where `(N >= 0) && (N < 32)`
  - N maps to the view index in `TBindings.Views[N]`
- samplers (all shader stages):
  - `layout(binding=N) sampler smp;` where `(N >= 0) && (N < 12)`
  - N maps to the sampler index in `TBindings.Samplers[N]`

Bindings must be unique within their bindings space with a shader `@program` across shader stages, and all resources of the same type and name across all programs in a shader source file must have matching bindings.

Violations against these rules are checked by sokol-shdc and will result in compilation errors.

Note that bind slots are allowed to have gaps. This allows to map specific types of resources (like diffuse vs normal-map textures) to specific bindslots even if a shader only uses a subset of those resources. This allows to use the same `TBindings` record for different related shaders (like the different shader variants of the same material).

### Binding uniforms blocks

Uniform blocks must be annotated with `layout(binding=N)` where `(N >=0) && (N < 8)`. Those bindings directly map to the `AUBSlot` parameter in `TGfx.ApplyUniforms(AUBSlot: Integer; ...)`. Uniform block bindings must be unique across shader stages of a `@program`.

The sokol-shdc code generation will create a bind slot constant for each uniquely named uniform block in a shader source file.

Consider the following uniform blocks in the vertex and fragment shader:

```glsl
@vs
layout(binding=0) uniform vs_params {
    mat4 mvp;
};
...
@end

@fs
layout(binding=1) uniform fs_params {
    vec4 color;
};
...
@end
```

The Pascal code generator will create a record and a 'bind slot' constant for the uniform block:

```pascal
const
  UB_VS_PARAMS = 0;
  UB_FS_PARAMS = 1;

type
  TVSParams = packed record
  public
    Mvp: TMatrix4;
  end;
  
type
  TFSParams = packed record
  public
    Mvp: TMatrix4;
  end;
```

...which both are used in the `TGfx.ApplyUniforms` call like this:

```pascal
var VSParams: TVSParams;
VSParams.Mvp := ...
var FSParams: TFSParams;
FSParams.Mvp := ...
TGfx.ApplyUniforms(UB_VS_PARAMS, VSParams);
TGfx.ApplyUniforms(UB_FS_PARAMS, FSParams);
```

### Binding textures and samplers

Textures and samplers must be defined separately in the input GLSL (this is also known as 'Vulkan-style GLSL'). Just as with uniform blocks, you must define explicit bind slots via `layout(binding=N)`. Textures share their bindslot space with storage images and storage buffers with a range of `(N >= 0) && (N < 32)` while samplers have their own bindslot space with a range of `(N >= 0) && (N < 12)`.

```glsl
layout(binding=0) uniform texture2D tex;
layout(binding=0) uniform sampler smp;
```

The resource binding slot for texture and sampler uniforms is available as code-generated constant:

```pascal
const
  VIEW_TEX = 0;
  SMP_SMP = 0;
```

This is used in the `TBindings` record as index into the `.Views[]`, and `.Samplers[]` arrays:

```pascal
var Bindings := TBindings.Create;
Bindings.VertexBuffers[0] := VBuf;
Bindings.Views[VIEW_TEX] := TexView;
Bindings.Samplers[SMP_SMP] := Smp;
TGfx.ApplyBindings(Bindings);
```

### Binding storage buffers

Note the following restrictions:

- storage buffers are not supported for the output formats `glsl300es` and `glsl410`
- in vertex- and fragment-shaders, only `readonly` bindings are supported

In the input GLSL, define a storage buffer like this:

```glsl
struct sb_vertex {
    vec4 pos;
    vec4 color;
};

// a readonly 'input buffer'
layout(binding=0) readonly buffer in_ssbo {
    sb_vertex vtx[];
};

// a read/write 'output buffer'
layout(binding=1) buffer out_ssbo {
    sb_vertex vtx[];
};
```

Storage-buffer-bindings share their bindings space with texture- and storage-image-bindings with a range of `(N >= 0) && (N < 32)` across all shader stages. `N` directly corresponds to the index into the `TBindings.Views[]` array.

A binding constant will be generated for each uniquely named storage buffer in a shader source file:

```pascal
const
  VIEW_IN_SSBO = 0;
  VIEW_OUT_SSBO = 1;
```

Storage-buffer-bindings share their bindings space with texture- and storage-image-bindings with a range of `(N >= 0) && (N < 32)` across all shader stages. `N` directly corresponds to the index into the `sg_bindings.views[]` array.

A binding constant will be generated for each uniquely named storage buffer in a shader source file:

```pascal
var Bindings := TBindings.Create;
Bindings.VertexBuffers[0] := VBuf;
Bindings.Views[VIEW_IN_SSBO] := SBufViewIn;
Bindings.Views[VIEW_OUT_SSBO] := SBufViewIn;
TGfx.ApplyBindings(Bindings);
```

In the shader code, the buffer content can be accessed like this (for instance using `gl_VertexIndex`):

```glsl
vec4 pos = vtx[gl_VertexIndex].pos;
vec4 color = vtx[gl_VertexIndex].color;
```

Only one flexible array member is allowed inside a `buffer`. Note that the name `vertex` cannot be used for a struct because it is a reserved keyword in MSL.

On the C side, `sokol-shdc` will create a Delphi record `TSBVertex` with the required alignment and padding (according to `std430` layout) and a `VIEW_*` constant which can be used in the `TBindings` record to index into the `.Views[]` array.

**An important OpenGL caveat**: OpenGL has a shared bindslot space for storage buffers across all shader stages. Because of this backend-specific detail, sokol-shdc directly assigns the `layout(binding=N)` value from the GLSL source code as OpenGL storage buffer bindslot. This means that on limited GL implementations you should put the storage buffer bindings first before other resource type bindslots to make the best use of the limited shared bindslot space for storage buffer bindings on OpenGL.

### Binding storage images

Note that storage-image-bindings are only allowed in compute shaders and only in `writeonly` and `readwrite` access mode. For `readonly` access use a regular texture binding instead.

Storage-image-bindings share the bindings space with texture- and storage-buffer-bindings with a range of `(N >= 0) && (N < 32)`.

In a compute shader, first define a storage image binding as `writeonly` or `readwrite` and then access it via the `imageLoad()` or `imageStore()` GLSL builtins:

```glsl
@cs cs
layout(binding=0, rgba8) uniform writeonly image2D cs_outp_tex;

void main() {
    //...
    imageStore(cs_outp_tex, coord, value);
    //...
}
@end
```

On the CPU side, call `TGfx.ApplyBindings` to apply storage-image-bindings, just as for texture- or storage-buffer-bindings:

```pascal
var Bindings := TBindings.Create;
Bindings.VertexBuffers[0] := VBuf;
Bindings.Views[VIEW_CS_OUTP_TEX] := SImgView;
TGfx.ApplyBindings(Bindings);
```

### GLSL uniform blocks and Pascal records
There are a few caveats to be aware of with uniform blocks:
* The memory layout of uniform blocks on the CPU side must be compatible across all sokol-gfx backends. To achieve this, uniform block content is restricted to a subset of the std140 packing rule that's compatible with the `glUniform()` functions.
* Member types are currently restricted to:
  - `float` (represented by `Single` in Delphi)
  - `vec2` (represented by `TVector2` in Delphi)
  - `vec3` (represented by `TVector3` in Delphi)
  - `vec4` (represented by `TVector4` in Delphi)
  - `int`  (represented by `Integer` in Delphi)
  - `ivec2` (represented by `TIVector2` in Delphi)
  - `ivec3` (represented by `TIVector3` in Delphi)
  - `ivec4` (represented by `TIVector4` in Delphi)
  - `mat4` (represented by `TMatrix4` in Delphi)

  This restriction exists so that the uniform data is compatible with all Neslib.Sokol.Gfx backends down to GLES2 and WebGL.
* Arrays are only allowed for the following types:

  - `vec4`
  - `int4`
  - `mat4`

  This restriction exists because the element stride must be the same as the element width so that the uniform data is compatible both with the std140 layout and `glUniformNfv()` calls.
* Uniform block member alignment is as follows (compatible with std140):

  - `float`, `int`: 4 bytes
  - `vec2`, `ivec2`: 8 bytes
  - `vec3`, `ivec3`: 16 bytes
  - `vec4`, `ivec4`: 16 bytes
  - `mat4`: 16 bytes
  - `vec4`[] 16 bytes
  - `ivec4`[] 16 bytes
  - `mat4`[] 16 bytes

* For the GLSL outputs, uniform blocks will be flattened into a single `vec4` arrays if all elements in the uniform block have the same 'base type' (`float` or `int`):

  - `float` base type: `float`, `vec2`, `vec3`, `vec4`, `mat4`
  - `int` base type: `int`, `ivec2`, `ivec3`, `ivec4`

  The advantage of flattened uniform blocks is that they can be updated with a single `glUniform4fv()` call.

  Mixed-base-type uniform blocks are allowed, but will not be flattened, this means that such mixed uniform blocks require multiple `glUniform()` calls.

  If the performance of uniform block updates matters in the GL backends, it may make sense to split complex uniform blocks into two separate blocks with the same base type (e.g. all 'float-y' members into one uniform block, and all 'int-y' members into another).

  In the non-GL backends (D3D11, Metal), uniform block updates are always a a single operation.

### Storage buffer content restrictions

- in vertex- and fragment-shaders, storage buffer bindings must be declared as `readonly`: `layout(binding=N) readonly buffer [name] { ... }`
- in compute-shaders, storage buffers bindings which are not modified by the shader code must be defined as `readonly` (otherwise the hazard tracking code in Sokol will assume that the storage buffer content is modified by the shader)
- the storage buffer content must be a single flexible struct array member
- structs used in storage buffers have fewer type restrictions than uniform blocks, but please note that a lot of type combinations are little tested, when in doubt stick to the same restrictions as in uniform blocks

s
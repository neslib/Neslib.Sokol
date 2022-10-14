# Neslib.Sokol.Gfx

A modern and uniform cross-platform wrapper around graphics backend.

This is a light-weight OOP layer on top of [sokol_gfx.h](https://github.com/floooh/sokol).

## Features
* simple, modern and uniform wrapper around OpenGL-ES 2/3, Direct3D 11 and Metal.
* buffers, images, shaders, pipeline-state-objects and render-passes
* does *not* handle window creation or 3D API context initialization. You can use [Neslib.Sokol.App](Neslib.Sokol.App.md) for this, or a 3rd party library like SDL.
* does *not* provide shader dialect cross-translation, but there is a shader-cross-compiler solution which seamlessly integrates with Neslib.Sokol.Gfx (more on this later).

This unit does not have any dependencies. You can use it stand-alone, in combination with SDL, SFML, GLFW etc., or in combination with [Neslib.Sokol.App](Neslib.Sokol.App.md).

Note that Neslib.Sokol.Gfx is still relatively low-level; it is only a thin layer on top of the actual graphics backend. You may want to build your own higher level layer on top of this one.

The graphics backend that is used depends on the platform:
* Windows: DirectX 11
* iOS/macOS: Metal
* Android: OpenGL-ES 2/3

## Example
To render a triangle using [Neslib.Sokol.App](Neslib.Sokol.App.md):

```pascal
  uses
    Neslib.Sokol.App,
    Neslib.Sokol.Gfx,
    TriangleShader;

  type
    TMyApp = class(TApplication)
    private
      FPassAction: TPassAction;
      FVB: TBuffer;
      FShader: TShader;
      FPip: TPipeline;
      FBind: TBindings;
    protected
      procedure Configure(var AConfig: TAppConfig); override;
      procedure Init; override;
      procedure Frame; override;
      procedure Cleanup; override;
    end;

  const
    VERTICES: array [0..20] of Single = (
    { Positions            Colors }
       0.0,  0.5, 0.5,     1.0, 0.0, 0.0, 1.0,
       0.5, -0.5, 0.5,     0.0, 1.0, 0.0, 1.0,
      -0.5, -0.5, 0.5,     0.0, 0.0, 1.0, 1.0);

  procedure TMyApp.Configure(var AConfig: TAppConfig);
  begin
    inherited;
    AConfig.WindowTitle := 'Triangle';
    AConfig.Width := 800;
    AConfig.Height := 600;
    ...
  end;

  procedure TMyApp.Init;
  begin
    inherited;
    var Desc := TGfxDesc.Create;
    Desc.Context := Context;
    TGfx.Setup(Desc);

    FPassAction.Colors[0].Init(TAction.Clear, 0, 0, 0, 1);
    
    var BufferDesc := TBufferDesc.Create;
    BufferDesc.Data := TRange.Create(VERTICES);
    BufferDesc.DebugLabel := 'TriangleVertices';
    FVB := TBuffer.Create(BufferDesc);
    FBind.VertexBuffers[0] := FVB;
    
    FShader := TShader.Create(TriangleShaderDesc^);
    
    var PipDesc := TPipelineDesc.Create;
    PipDesc.Shader := FShader;
    PipDesc.Layout.Attrs[ATTR_VS_POSITION].Format := TVertexFormat.Float3;
    PipDesc.Layout.Attrs[ATTR_VS_COLOR0].Format := TVertexFormat.Float4;
    PipDesc.DebugLabel := 'TrianglePipeline';
    FPip := TPipeline.Create(PipDesc);

  end;

  procedure TMyApp.Frame;
  begin
    TGfx.BeginDefaultPass(FPassAction, Width, Height);
    TGfx.ApplyPipeline(FPip);
    TGfx.ApplyBindings(FBind);

    TGfx.Draw(0, 3);
    
    TGfx.EndPass;
    TGfx.Commit;

  end;

  procedure TMyApp.Cleanup;
  begin
    FPip.Free;
    FShader.Free;
    FVB.Free;
    inherited;
  end;
```

As mentioned earlier, you don't have to use [Neslib.Sokol.App](Neslib.Sokol.App.md); you can use your application and window manager or a 3rd party library like SDL or SFML.

## Step-by-Step
* To initialize Neslib.Sokol.Gfx, after creating a window and a 3D-API context/device, call:
  
  ```pascal
    var Desc := TGfxDesc.Create;
    Desc.Context := Context;
    TGfx.Setup(Desc);
  ```
  
* Create resource objects (at least buffers, shaders and pipelines, and optionally images and passes):
  
  ```pascal
    constructor TBuffer.Create(const ADesc: TBufferDesc);
    constructor TImage.Create(const ADesc: TImageDesc);
    constructor TShader.Create(const ADesc: TShaderDesc);
    constructor TPipeline.Create(const ADesc: TPipelineDesc);
    constructor TPass.Create(const ADesc: TPassDesc);
  ```
  
* Start rendering to the default framebuffer with:

    ```pascal
    class procedure TGfx.BeginDefaultPass(const AAction: TPassAction; const AWidth, AHeight: Integer); static;
    ```

* Or start rendering to an offscreen framebuffer with:

    ```pascal
    class procedure TGfx.BeginPass(const APass: TPass; const AAction: TPassAction); static;
    ```

* Set the pipeline state for the next draw call with:

    ```pascal
    class procedure TGfx.ApplyPipeline(const APipeline: TPipeline);
    ```

* Fill an `TBindings` record with the resource bindings for the next draw call (1..N vertex buffers, 0 or 1 index buffer, 0..N image objects to use as textures each on the vertex-shader- and fragment-shader-stage) and then call:
  
  ```pascal
  class procedure TGfx.ApplyBindings(const ABindings: TBindings);
  ```
  
  to update the resource bindings.
  
* Optionally update shader uniform data with:

  ```pascal
  class procedure TGfx.ApplyUniforms(const AStage: TShaderStage; const AUBIndex: Integer; const AData: TRange);
  ```

  Read the section [Uniform Data Layout](#uniform-data-layout) to learn about the expected memory layout of the uniform data passed into `ApplyUniforms`.

* Kick off a draw call with:

  ```pascal
  class procedure TGfx.Draw(const ABaseElement, ANumElements: Integer; const ANumInstances: Integer = 1);
  ```

  The `Draw` method unifies all the different ways to render primitives in a single call (indexed vs non-indexed rendering, and instanced vs non-instanced rendering). In case of indexed rendering, `ABaseElement` and `ANumElements` specify indices in the currently bound index buffer. In case of non-indexed rendering `ABaseElement` and `ANumElements` specify vertices in the currently bound vertex-buffer(s). To perform instanced rendering,  the rendering pipeline must be setup for instancing (see `TPipelineDesc` below), a separate vertex buffer containing per-instance data must be  bound, and the `ANumInstances` parameter must be > 1.

* Finish the current rendering pass with:

    ```pascal
    class procedure TGfx.EndPass;
    ```

* When done with the current frame, call:

    ```pascal
    class procedure TGfx.Commit;
    ```

* At the end of your program, shutdown Neslib.Sokol.Gfx with:

    ```pascal
    class procedure TGfx.Shutdown;
    ```

* If you need to destroy resources before `Shutdown`, call:

    ```pascal
    procedure TBuffer.Free;
    procedure TImage.Free;
    procedure TShader.Free;
    procedure TPipeline.Free;
    procedure TPass.Free;
    ```

* To set a new viewport rectangle, call:

    ```pascal
    class procedure TGfx.ApplyViewport(const AX, AY, AWidth, AHeight: Integer; const AOriginTopLeft: Boolean);
    ```

* To set a new scissor rect, call:

  ```pascal
  class procedure TGfx.ApplyScissorRect(const AX, AY, AWidth, AHeight: Integer; const AOriginTopLeft: Boolean);
  ```

  Both `ApplyViewport` and `ApplyScissorRect` must be called inside a rendering pass.

  Note that `TGfx.BeginDefaultPass` and `TGfx.BeginPass` will reset both the viewport and scissor rectangles to cover the entire framebuffer.

* To update (overwrite) the content of buffer and image resources, call:

  ```pascal
  procedure TBuffer.Update(const AData: TRange);
  procedure TImage.Update(const AData: TImageData);
  ```

  Buffers and images to be updated must have been created with `TUsage.Dynamic` or `TUsage.Stream`.

  Only one update per frame is allowed for buffer and image resources when using the `Update` methods. The rationale is to have a simple countermeasure to avoid the CPU scribbling over data the GPU is currently using, or the CPU having to wait for the GPU.

  Buffer and image updates can be partial, as long as a rendering operation only references the valid (updated) data in the buffer or image.

* To append a chunk of data to a buffer resource, call:

  ```pascal
  function TBuffer.Append(const AData: TRange): Integer;
  ```

  The difference to `TBuffer.Update` and `TBuffer.Append` is that `Append` can be called multiple times per frame to append new data to the buffer piece by piece, optionally interleaved with draw calls referencing the previously written data.

  `Append` returns a byte offset to the start of the written data. This offset can be assigned to `TBindings.VertexBufferOffsets[N]` or `TBindings.IndexBufferOffset`.

  If the application appends more data to the buffer then fits into the buffer, the buffer will go into the "overflow" state for the rest of the frame.

  Any draw calls attempting to render an overflown buffer will be silently dropped (in debug mode this will also result in a validation error).

  You can also check manually if a buffer is in overflow-state by checking the `TBuffer.Overflow` property.

  You can manually check to see if an overflow would occur before adding any data to a buffer by calling:

  ```pascal
  function TBuffer.WillOverflow(const ASize: NativeInt): Boolean;
  ```

  Note: Due to restrictions in underlying 3D-APIs, appended chunks of data will be 4-byte aligned in the destination buffer. This means that there will be gaps in index buffers containing 16-bit indices when the number of indices in a call to Append is odd. This isn't a problem when each call to `Append` is associated with one draw call, but will be problematic when a single indexed draw call spans several appended chunks of indices.

* To check at runtime for optional features, limits and pixelformat support,use:
  
  * `TBuffer.Features`
  
  * `TGfx.Limits`
  
  * The record helper for `TPixelFormat`
  
* If you need to call into the underlying 3D-API directly, you must call:

  ```pascal
  class procedure TGfx.ResetCache;
  ```

  ...before calling Neslib.Sokol.Gfx methods functions again.

* You can inspect various internal resource attributes via:

  * `TBuffer.Info`

  * `TImage.Info`

  * `TShader.Info`

  * `TPipeline.Info`

  * `TPass.Info`


  ...please note that the returned info-records are tied quite closely to internals, and may change more often than other public API functions and records.

* You can ask at runtime what backend is currently in use using the `Backend` property.

## On Initialization
When calling `TGfx.Setup`, a `TGfxDesc` record must be provided which contains initialization options. These options provide two types of information:

1. Upper bounds and limits needed to allocate various internal data structures:
    - the max number of resources of each type that can be alive at the same time, this is used for allocating internal pools.
    - the max overall size of uniform data that can be updated per frame, including a worst-case alignment per uniform update (this worst-case
      alignment is 256 bytes)
    - the max size of all dynamic resource updates (`TBuffer.Update`, `TBuffer.Append` and `TImage.Update`) per frame
    - the max number of entries in the texture sampler cache (how many unique texture sampler can exist at the same time).
    

    Not all of those limit values are used by all backends, but it is good practice to provide them none-the-less.

2. 3D-API "context information" (sometimes also called "bindings"). This unit doesn't create or initialize 3D API objects which are closely related to the presentation layer (this includes the "rendering device", the swapchain, and any objects which depend on the swapchain). These API objects (or  callback functions to obtain them, if those objects might change between frames), must be provided in a nested `TContextDesc` record inside the `TGfxDesc` record. If Neslib.Sokol.Gfx is used together with [Neslib.Sokol.App](Neslib.Sokol.App.md), then this is handled automatically.

See the documention block of the `TGfxDesc` record for more information.

## Uniform Data Layout
NOTE: if you use the sokol-shdc shader compiler tool, you don't need to worry about the following details and you can skip to the next section (more about this tool later).

The data that's passed into the `TGfx.ApplyUniforms` method must adhere to specific layout rules so that the GPU shader finds the uniform block items at the right offset.

For the D3D11 and Metal backends, this unit only cares about the size of uniform blocks, but not about the internal layout. The data will just be copied into a uniform/constant buffer in a single operation and it's up you to arrange the CPU-side layout so that it matches the GPU side layout. This also means that with the D3D11 and Metal backends you are not limited to a 'cross-platform' subset of uniform variable types.

If you ever only use the D3D11 or Metal backend, you can stop reading here.

For the OpenGL-ES backends, the internal layout of uniform blocks matters though, and you are limited to a small number of uniform variable types. This is because Neslib.Sokol.Gfx must be able to locate the uniform block members in order to upload them to the GPU with `glUniformXXX()` calls.

To describe the uniform block layout, the following information must be passed to the `TShader.Create` call in the `TShaderDesc` record:

* a hint about the used packing rule (either `SG_UNIFORMLAYOUT_NATIVE` or `SG_UNIFORMLAYOUT_STD140`)
* a list of the uniform block members types in the correct order they appear on the CPU side

With this information Neslib.Sokol.Gfx can now compute the correct offsets of the data items within the uniform block struct.

## Working with Contexts
Neslib.Sokol.Gfx allows to switch between different rendering contexts and associate resource objects with contexts. This is useful to create GL applications that render into multiple windows.

A rendering context keeps track of all resources created while the context is active. When the context is destroyed, all resources "belonging to the context" are destroyed as well.

A default context will be created and activated implicitly in `TGfx.Setup` and destroyed in `TGfx.Shutdown`. So for a typical application which *doesn't* use multiple contexts, nothing changes, and calling the context methods isn't necessary.

The `TContext` record has been added to work with contexts.

* `TContext.Create/Init`: This must be called once after a GL context has been created and made active.
* `TContext.Activate`: This must be called after making a different GL context active. Apart from 3D-API-specific actions, the call to Activate will internally call `TGfx.ResetCache`.
* `TContext.Free`: This must be called right before a GL context is destroyed and will destroy all resources associated with the context (that have been created while the context was active) The GL context must be active at the time `Free` is called.

Also note that resources (buffers, images, shaders and pipelines) must only be used or destroyed while the same GL context is active that was also active while the resource was created (an exception is resource sharing on GL, such resources can be used while another context is active, but must still be destroyed under the same context that was active during creation).

For more information, check out the MultiWindow sample.

## Trace Hooks
Neslib.Sokol.Gfx optionally allows to install "trace hook" callbacks for each public API. When a public API function is called, and a trace hook callback has been installed for this function, the callback will be invoked with the parameters and result of the function. This is useful for things like debugging- and profiling-tools, or keeping track of resource creation and destruction.

For performance reasons, there is no Delphi wrapper around the trace hook functionality, but you can use the C API directly to install trace hooks:

* Setup a `TTraceHooks` record with your callback functions (note that these are C-style functions with the cdecl calling convention). Keep all callbacks you're not interested in zero-initialized). Optionally set the `user_data` field in the `TTraceHooks._sg_trace_hooks` record.
  
* Install the trace hooks by calling `TGfx.InstallTraceHooks`.

As an example of how trace hooks are used, compile the sample projects using the DebugUI or ReleaseUI configurations. This uses trace hooks and Dear  ImGui to display a debug UI to inspect Neslib.Sokol.Gfx resources in real time.

## A note on portable packed vertex formats
There are two things to consider when using packed vertex formats like UByte4, Short2, etc which need to work across all backends:

* D3D11 can only convert *normalized* vertex formats to floating point during vertex fetch. Normalized formats have a trailing 'N', and are "normalized" to a range -1.0..+1.0 (for the signed formats) or 0.0..1.0 (for the unsigned formats):
  
    - `TVertexFormat.Byte4N`
    - `TVertexFormat.UByte4N`
    - `TVertexFormat.Short2N`
    - `TVertexFormat.UShort2N`
    - `TVertexFormat.Short4N`
    - `TVertexFormat.UShort4N`
    
    
  
  D3D11 will not convert *non-normalized* vertex formats to floating point vertex shader inputs, those can only be uses with the *ivecn* vertex shader input types when D3D11 is used as backend (GL and Metal can use both formats).
  
    - `TVertexFormat.Byte4`
    - `TVertexFormat.UByte4`
    - `TVertexFormat.Short2`
    - `TVertexFormat.Short4`
  
* OpenGL ES-2/3 cannot use integer vertex shader inputs (int or ivecn)

* `TVertexFormat.UInt10N2` is not supported on GLES2

So for a vertex input layout which works on all platforms, only use the following vertex formats, and if needed "expand" the normalized vertex shader inputs in the vertex shader by multiplying with 127.0, 255.0, 32767.0 or 65535.0:

- `TVertexFormat.Float`
- `TVertexFormat.Float2`
- `TVertexFormat.Float3`
- `TVertexFormat.Float4`
- `TVertexFormat.Byte4N`
- `TVertexFormat.UByte4N`
- `TVertexFormat.Short2N`
- `TVertexFormat.UShort2N`
- `TVertexFormat.Short4N`
- `TVertexFormat.UShort4N`

## Shader Cross Compilation
If you look at the example at the top of this unit, you will see that it uses a unit called TriangleShader, which contains a function called `TriangleShaderDesc` that returns a shader description. That unit is automatically generated from the shader source file TriangleShader.glsl:

```glsl
  @vs vs
  in vec4 position;
  in vec4 color0;

  out vec4 color;

  void main() {
      gl_Position = position;
      color = color0;
  }
  @end

  @fs fs
  in vec4 color;
  out vec4 frag_color;

  void main() {
      frag_color = color;
  }
  @end

  @program triangle vs fs
```

This source file contains a vertex shader and fragment shader written in the OpenGL Shader Language (GLSL v450), with some custom annotations (@-tags) that add meta-information for use with the shader-cross-compiler "sokol-shdc.exe".

### Cross Compiler Tool
This tool can be found in the Tools directory, and is a modified version of the original sokol-shdc tool, but generates Pascal source code instead of C code. It translates the given GLSL code into the following shader dialects:

* GLSL v100 (for OpenGL-ES 2)
* GLSL v300es (for OpenGL-ES 3)
* HLSL5 (for Direct3D 11)
* Metal (for macOS and iOS)

The result is stored in a generated .pas file that also contains a function that returns the corresponding shader description that is used to create a `TShader` object.

Note that these generated files depend on the Neslib.FastMath unit, which provides very fast hand-optimized SIMD assembly routines for vector and matrix math. You can find it on GitHub: https://github.com/neslib/FastMath.

IMPORTANT: You *must* add the `FM_COLUMN_MAJOR` define to your project for matrix calculations to work correctly with Neslib.Sokol.Gfx!

### Build Integration
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

### Command Line Parameters
sokol-shdc command line parameters:

* `--input=[GLSL file]`: the path to the input GLSL file, this must be either relative to the current working directory, or an absolute path. You can also use `-i` instead.

* `--output=[Pas file]`: the path to the generated Pascal file, either relative to the current working directory, or as absolute path. The target directory must exist. You can also use `-o` instead.

* `--slang=[shader languages]`: optional one or multiple output shader languages. If this parameter is missing, the shader will be converted to all shader languages. If multiple languages are provided, they must be separated by a colon. Valid shader language names are:

     * `glsl100`: GLES2 / WebGL
     * `glsl300es`: GLES3 / WebGL2
     * `hlsl5`: D3D11
     * `metal_macos`: Metal on macOS
     * `metal_ios`: Metal on iOS device

  You can also use -l instead.

### Shader Tags reference

The following @-tags can be used in annotated GLSL source files:

#### @vs [name]

Starts a named vertex shader code block. The code between the `@vs` and the next `@end` will be compiled as a vertex shader.

#### @fs [name]

Starts a named fragment shader code block. The code between the `@fs` and the next `@end` will be compiled as a fragment shader.

#### @program [name] [vs] [fs]

The `@program` tag links a vertex- and fragment-shader into a named shader program. The program name will be used for naming the generated `TShaderDesc` record and a Pascal function to get a pointer to the generated shader desc. At least one `@program` tag must exist in an annotated GLSL source file. For example:

```glsl
    @program triangle vs fs
```

  This will generate the Pascal function:

```pascal
    function TriangleShaderDesc: PShaderDesc;
```

#### @block [name]

The `@block` tag starts a named code block which can be included in other `@vs`, `@fs` or `@block` code blocks. This is useful for sharing code between shaders.

#### @end

The `@end` tag closes a `@vs`, `@fs` or `@block` code block.

#### @include_block [name]

`@include_block` includes a `@block` into another code block. This is useful for sharing code snippets between different shaders.

#### @glsl_options, @hlsl_options, @msl_options

These tags can be used to define per-shader/per-language options for SPIRV-Cross when compiling SPIR-V to GLSL, HLSL or MSL.

GL, D3D and Metal have different opinions where the origin of an image is, or whether clipspace-z goes from 0..+1 or from -1..+1, and the option-tags allow fine-control over those aspects with the following arguments:

* `fixup_clipspace`:
  - GLSL: In vertex shaders, rewrite [0, w] depth (Vulkan/D3D style) to [-w, w] depth (GL style).
  - HLSL: In vertex shaders, rewrite [-w, w] depth (GL style) to [0, w] depth.
  - MSL: In vertex shaders, rewrite [-w, w] depth (GL style) to [0, w] depth.
* `flip_vert_y`: Inverts `gl_Position.y` or equivalent. (all shader languages)

  Currently, `@glsl_option`, `@hlsl_option` and `@msl_option` are only allowed inside `@vs`, `@end` blocks.

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
The generated Pascal file will contain one function for each shader program which returns a pointer to a completely initialized `TShaderDesc` record, so creating a shader object becomes a one-liner.

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

### Binding uniforms blocks
Similar to the vertex attribute location constants, the Pascal code generator also provides bind slot constants for images and uniform blocks.

Consider the following uniform block in GLSL:

```glsl
  uniform vs_params {
      mat4 mvp;
  };
```

The Pascal code generator will create a record and a 'bind slot' constant for the uniform block:

```pascal
  const
    SLOT_VS_PARAMS = 0;

  type
    TVSParams = packed record
    public
      Mvp: TMatrix4;
    end;
```

...which both are used in the State.ApplyUniforms call like this:

```pascal
  var VSParams: TVSParams;
  VSParams.Mvp := ...
  State.ApplyUniforms(TShaderStage.VS, SLOT_VS_PARAMS, VSParams);
```

The GLSL uniform block can have an explicit bind slot:

```glsl
  layout(binding=0) uniform vs_params {
      mat4 mvp;
  };
```

In this case the generated bind slot constant can be ignored since it has been explicitely defined as 0:

```pascal
  State.ApplyUniforms(TShaderStage.VS, 0, TRange.Create(VSParams));
```

### Binding images
When using a texture sampler in a GLSL vertex- or fragment-shader like this:

```glsl
  uniform sampler2D tex;
  ...
```

The Pascal code generator will create bind-slot constants with the same naming convention as uniform blocks:

```pascal
  const
    SLOT_TEX = 0;
```

This is used in the `TBindings` record as index into the `VertexShaderImages` or `FragmentShaderImages` bind slot array:

```pascal
  var Bind: TBindings;
  Bind.FragmentShaderImages[SLOT_TEX] := MyImage;
  State.ApplyBindings(Bind);
```

Just like with uniform blocks, texture sampler bind slots can be defined explicitely in the GLSL shader:

```glsl
  layout(binding=0) uniform sampler2D tex;
  ...
```

in this case the code-generated bind-slot constant can be ignored:

```pascal
  Bind.FragmentShaderImages[0] := MyImage;
```

### Uniform blocks and Pascal records
There are a few caveats with uniform blocks:
* Member types are currently restricted to:
  - `float` (represented by `Single` in Delphi)
  - `vec2` (represented by `TVector2` in Delphi)
  - `vec3` (represented by `TVector3` in Delphi)
  - `vec4` (represented by `TVector4` in Delphi)
  - `mat4` (represented by `TMatrix4` in Delphi)
* This limitation is currently also present in Neslib.Sokol.Gfx itself (see `TUniformType`). More float-based types like `mat2` and `mat3` will most likely be added in the future, but there's currently no portable way to support integer types across all backends.
* In GL, uniform blocks will be 'flattened' to arrays of `vec4`, this allows to update uniform data with a single call to `glUniform4v` per uniform block, no matter how many members a uniform block actually has.
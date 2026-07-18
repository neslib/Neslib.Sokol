# Neslib.Sokol.Gfx

A modern and uniform cross-platform wrapper around graphics backend.

This is a light-weight OOP layer on top of [sokol_gfx.h](https://github.com/floooh/sokol).

## Features
* simple, modern and uniform wrapper around OpenGL-ES 2/3, Direct3D 11, Metal and Vulkan.
* buffers, images, shaders, pipeline-state-objects and render-passes.
* does *not* handle window creation or 3D API context initialization. You can use [Neslib.Sokol.App](Neslib.Sokol.App.md) for this, or a 3rd party library like SDL.
* does *not* provide shader dialect cross-translation, but there is a shader-cross-compiler solution which seamlessly integrates with Neslib.Sokol.Gfx (more on this later).

This unit does not have any dependencies. You can use it stand-alone, in combination with SDL, SFML, GLFW etc., or in combination with [Neslib.Sokol.App](Neslib.Sokol.App.md).

Note that Neslib.Sokol.Gfx is still relatively low-level; it is only a thin layer on top of the actual graphics backend. You may want to build your own higher level layer on top of this one.

The graphics backend that is used depends on the platform:
* Windows: OpenGL, Vulkan, DirectX 11
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
    AConfig.WindowTitle := 'MyApp';
    AConfig.Width := 800;
    AConfig.Height := 600;
    AConfig.Logger := DefaultLogger;
    ...
  end;

  procedure TMyApp.Init;
  begin
    inherited;
    var Desc := TGfxDesc.Create;
    Desc.Environment.FromAppEnvironment;
    Desc.Logger := Desc.DefaultLogger;
    TGfx.Setup(Desc);
   
    { Create view for binding vertex buffer }
    var BufferDesc := TBufferDesc.Create;
    BufferDesc.Data := TRange.Create(VERTICES);
    BufferDesc.TraceLabel := 'VertexBuffer';
    FVB := TBuffer.Create(BufferDesc);
    FBind.VertexBuffers[0] := FVB;
    
    { Create shader from code-generated shader desc}
    FShader := TShader.Create(TriangleShaderDesc);
    
    { Create a pipeline object (default render states are fine for triangle).
      If the vertex layout doesn't have gaps, don't need to provide strides and
      offsets }
    var PipDesc := TPipelineDesc.Create;
    PipDesc.Shader := FShader;
    PipDesc.Layout.Attrs[ATTR_TRIANGLE_POSITION].Format := TVertexFormat.Float3;
    PipDesc.Layout.Attrs[ATTR_TRIANGLE_COLOR0].Format := TVertexFormat.Float4;
    PipDesc.TraceLabel := 'TrianglePipeline';
    FPip := TPipeline.Create(PipDesc);
    
    { A pass action to clear framebuffer to black }
    FPassAction.Colors[0].Init(TLoadAction.Clear, TStoreAction.Default, 0, 0, 0, 1);
  end;

  procedure TMyApp.Frame;
  begin
    var Pass := TPass.Create;
    Pass.Action^ := FPassAction;
    Pass.Swapchain.FromAppSwapchain;
    TGfx.BeginPass(Pass);
    
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
    TGfx.Setup(Desc);
  ```
  Depending on the selected 3D backend, Neslib.Sokol.Gfx requires some information about its runtime environment, like a GPU device pointer, default swapchain, pixel formats and so on. If you are using Neslib.Sokol.App for the window system glue, you can use a helper function provided in the Neslib.Sokol.Glue unit:
  ```pascal
    var Desc := TGfxDesc.Create;
    Desc.Environment := TApplication.Environment;
    TGfx.Setup(Desc);
  ```
  To get any logging output for errors and from the validation layer, you need to provide a logging callback. Easiest way is to use the default logger:
  ```pascal
    var Desc := TGfxDesc.Create;
    Desc.Logger := Desc.DefaultLogger;
    TGfx.Setup(Desc);
  ```

* Create resource objects (buffers, images, views, samplers, shaders and pipeline objects):

  ```pascal
    constructor TBuffer.Create(const ADesc: TBufferDesc);
    constructor TImage.Create(const ADesc: TImageDesc);
    constructor TView.Create(const ADesc: TViewDesc);
    constructor TSampler.Create(const ADesc: TSamplerDesc);
    constructor TShader.Create(const ADesc: TShaderDesc);
    constructor TPipeline.Create(const ADesc: TPipelineDesc);
  ```

* Start a render- or compute-pass:

  ```pascal
  class procedure TGfx.BeginPass(const APass: TPass); static;
  ```
  Typically, render passes render into an externally provided swapchain which presents the rendering result on the display. Such a 'swapchain pass' is started like this:

    ```pascal
    var Pass := TPass.Create;
    Pass.Action....;
    Pass.Swapchain.FromAppSwapchain;
    class procedure TGfx.BeginPass(const APass: TPass); static;
    ```
  ...where `.Action` is an `TPassAction` record struct containing actions to be performed at the start and end of a render pass (such as clearing the render surfaces to a specific color), and `.Swapchain` is a `TSwapchain` record with all the required information to render into the swapchain's surfaces.

  To start an 'offscreen render pass' into Neslib.Sokol.Gfx image objects, populate the TPass.Attachments nested record with attachment view objects (1..4 color-attachment-views for to render into, a depth-stencil-attachment-view to provide the depth-stencil-buffer, and optionally 1..4 resolve-attachment-views for an MSAA-resolve operation:
    ```pascal
    var Pass := TPass.Create;
    Pass.Action....;
    Pass.Attachments.Colors[0] := ColorAttachmentView;
    Pass.Attachments.Resolves[0] := OptionalResolveAttachmentView;
    Pass.Attachments.DepthStencil := DepthStencilAttachmentView;
    class procedure TGfx.BeginPass(const APass: TPass); static;
    ```
  To start a compute-pass, just set the `.Compute` item to true:

    ```pascal
    var Pass := TPass.Create;
    Pass.Compute := True;
    class procedure TGfx.BeginPass(const APass: TPass); static;
    ```

* Set the pipeline state for the next draw call with:

    ```pascal
    class procedure TGfx.ApplyPipeline(const APipeline: TPipeline);
    ```

* Fill an `TBindings` record with the resource bindings for the next draw- or dispatch-call (0..N vertex buffers, 0 or 1 index buffer, 0..N views, 0..N samplers), and call:

  ```pascal
  class procedure TGfx.ApplyBindings(const ABindings: TBindings);
  ```

  ...to update the resource bindings. Note that in a compute pass, no vertex- or index-buffer bindings can be used, and in render passes, no storage-image bindings are allowed. Those restrictions will be checked by the Neslib.Sokol.Gfx validation layer.

* Optionally update shader uniform data with:

  ```pascal
  class procedure TGfx.ApplyUniforms(const ASlot: Integer; const AData: TRange);
  ```

  Read the section [Uniform Data Layout](#uniform-data-layout) to learn about the expected memory layout of the uniform data passed into `ApplyUniforms`.

* Kick off a draw call with:

  ```pascal
  class procedure TGfx.Draw(const ABaseElement, ANumElements: Integer; const ANumInstances: Integer = 1); 
  ```

  The `Draw` method unifies all the different ways to render primitives in a single call (indexed vs non-indexed rendering, and instanced vs non-instanced rendering). In case of indexed rendering, `ABaseElement` and `ANumElements` specify indices in the currently bound index buffer. In case of non-indexed rendering `ABaseElement` and `ANumElements` specify vertices in the currently bound vertex-buffer(s). To perform instanced rendering,  the rendering pipeline must be setup for instancing (see `TPipelineDesc` below), a separate vertex buffer containing per-instance data must be  bound, and the `ANumInstances` parameter must be > 1.

  Alternatively, call another `Draw` overload to provide a base-vertex and/or base-instance which allows to render from different sections of a vertex buffer without rebinding the vertex buffer with a different offset. Note that this overload only has limited portability on OpenGL, check the `TLimits` record members `.DrawBaseVertex` and `.DrawBaseInstance` for runtime support, those are generally True on non-GL-backends, and on GL the feature flags are set according to the GL version:
  - on GL `BaseInstance <> 0` is only supported since GL 4.2
  - on GLES3.x, `BaseInstance != 0` is not supported
  - on GLES3.x, `BaseVertex` is only supported since GLES3.2

* ...or kick of a dispatch call to invoke a compute shader workload:
  ```pascal
  class procedure TGfx.Dispatch(const ANumGroupsX, ANumGroupsY, ANumGroupsZ: Integer); 
  ```
  The dispatch args define the number of 'compute workgroups' processed by the currently applied compute shader.

* Finish the current pass with:

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
    procedure TSampler.Free;
    procedure TShader.Free;
    procedure TPipeline.Free;
    procedure TView.Free;
    ```

* To set a new viewport rectangle, call:

    ```pascal
    class procedure TGfx.ApplyViewport(const AX, AY, AWidth, AHeight: Integer; const AOriginTopLeft: Boolean);
    ```

* To set a new scissor rect, call:

  ```pascal
  class procedure TGfx.ApplyScissorRect(const AX, AY, AWidth, AHeight: Integer; const AOriginTopLeft: Boolean);
  ```

  Both `ApplyViewport` and `ApplyScissorRect` must be called inside a rendering pass (e.g. not in a compute pass, or outside a pass).

  Note that `TGfx.BeginPass` will reset both the viewport and scissor rectangles to cover the entire framebuffer.

* To update (overwrite) the content of buffer and image resources, call:

  ```pascal
  procedure TBuffer.Update(const AData: TRange);
  procedure TImage.Update(const AData: TImageData);
  ```

  Buffers and images to be updated must have been created with `TBufferDesc.Usage.DynamicUpdate` or `.StreamUpdate`.

  Only one update per frame is allowed for buffer and image resources when using the `Update` methods. The rationale is to have a simple protection from the CPU scribbling over data the GPU is currently using, or the CPU having to wait for the GPU.

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

* You can inspect the original desc record handed to TGfx.Setup using TGfx.Desc.

* You can get a desc record matching the creation attributes of a specific resource object via:

  * `TBuffer.Desc`

  * `TImage.Desc`

  * `TSampler.Desc`

  * `TShader.Desc`

  * `TPipeline.Desc`

  * `TView.Desc`

  ...but *note* that the returned desc records may be incomplete, only creation attributes that are kept around internally after resource creation will be filled in, and in some cases (like shaders) that's very little. Any missing attributes will be set to zero. The returned desc records might still be useful as partial blueprint for creating  similar resources if filled up with the missing attributes.

  Using `.Desc` on an invalid resource will return completely zeroed records (it makes sense to check the resource state first).

* You can create the default resource creation parameters through the `Create` or `Init` methods of the specific resources:

  * `TBufferDesc.Create/Init`
  * `TImageDesc.Create/Init`
  * `TSamplerDesc.Create/Init`
  * `TShaderDesc.Create/Init`
  * `TPipelineDesc.Create/Init`
  * `TViewDesc.Create/Init`

* You can inspect various internal resource runtime values via:

  * `TBuffer.Info`

  * `TImage.Info`

  * `TSampler.Info`

  * `TShader.Info`

  * `TPipelineInfoDesc`

  * `TView.Info`

  ...please note that the returned info-structs are tied quite closely Sokol internals, and may change more often than other public API functions and records.

* You can query the type/flavor and parent resource of a view:

  * `TView.ViewType`
  * `TView.Image`
  * `TView.Buffer`

* You can query stats and control stats collection via:

    * `TGfx.QueryStats`

    * `TGfx.EnableStats`

    * `TGfx.DisableStats`

    * `TGfx.StatsEnabled`

* You can ask at runtime what backend is currently in use using the `Backend` property.

* Call the following `TPixelFormat` helper functions to compute the number of  bytes in a texture row or surface for a specific pixel format. These functions might be helpful when preparing image data for consumption by `TImage.Init/Setup` or `TImage.Update`:

    * `function TPixelFormat.RowPitch(const AWidth, ARowAlignBytes: Integer): Integer;`

    * `function TPixelFormat.SurfacePitch(const AWidth, AHeight, ARowAlignBytes: Integer): Integer;` 

  `AWidth` and `AHeight` are generally in number of pixels, but note that 'row' has different meaning for uncompressed vs compressed pixel formats: for uncompressed formats, a row is identical with a single line if pixels, while in compressed formats, one row is a line of *compression blocks*.
  
  This is why calling `TPixelFormat.SurfacePitch` for a compressed pixel format and height N, N+1, N+2, ... may return the same result.

  The `ARowAlignBytes` parameter is for added flexibility. For image data that goes into the `TImage.Init/Setup` or `TImage.Update` this should generally be 1, because these functions take tightly packed image data as input no matter what alignment restrictions exist in the backend 3D APIs.


## On Initialization
When calling `TGfx.Setup`, a `TGfxDesc` record must be provided which contains initialization options. These options provide two types of information:

1. Upper bounds and limits needed to allocate various internal data structures:
    - the max number of resources of each type that can be alive at the same time, this is used for allocating internal pools.
    - the max overall size of uniform data that can be updated per frame, including a worst-case alignment per uniform update (this worst-case
      alignment is 256 bytes)
    - the max size of all dynamic resource updates (`TBuffer.Update`, `TBuffer.Append` and `TImage.Update`) per frame
    - the max number of compute-dispatch calls in a compute pass.

    Not all of those limit values are used by all backends, but it is good practice to provide them none-the-less.

2. 3D backend "environment information" in a nested `TEnvironment` record:
    - Backend-specific context- or device-objects (for instance the D3D11 or Metal device objects)
    - Defaults for external swapchain pixel formats and sample counts, these will be used as default values in image and pipeline objects, and the `TSwapchain` record passed into TGfx.BeginPass.

    Usually you provide a complete `TEnvironment` record through a helper function, such as `TEnvironment.FromAppEnvironment` in the Neslib.Sokol.Glue unit.

See the documention block of the `TGfxDesc` record for more information.

## On Render Passes

Relevant samples (in the Samples directory:

* OffScreen
* OffScreenMsaa
* Mrt
* MrtPixelFormats

A render pass groups rendering commands into a set of render target images (called 'render pass attachments'). Render target images can be used in subsequent passes as textures (it is invalid to use the same image both as render target and as texture in the same pass).

The following methods must only be called inside a render-pass:

* `TGfx.ApplyViewport`
* `TGfx.ApplyScissorRect`
* `TGfx.Draw`

The following functions may be called inside a render- or compute-pass, but not outside a pass:

* `TGfx.ApplyPipeline`
* `TGfx.ApplyBindings`
* `TGfx.ApplyUniforms`

A frame must have at least one 'swapchain render pass' which renders into an externally provided swapchain provided as an sg_swapchain struct to the `TGfx.BeginPass` function. If you use Neslib.Sokol.Gfx together with Neslib.Sokol.App, just call `TSwapchain.FromAppSwapchain` from the Neslib.Sokol.Glue unit to provide the swapchain information. Otherwise the following information must be provided:

  - The color pixel-format of the swapchain's render surface
  - An optional depth/stencil pixel format if the swapchain has a depth/stencil buffer
  - An optional sample-count for MSAA rendering
  - NOTE: the above three values can be zero-initialized, in that case the defaults from the sg_environment struct will be used thathad been passed to the `TGfx.Setup` function.
  - a number of backend specific objects:
    - GL/GLES3: just a GL framebuffer handle
    - D3D11:
      - An ID3D11RenderTargetView for the rendering surface
      - If MSAA is used, an ID3D11RenderTargetView as MSAA resolve-target
      - An optional ID3D11DepthStencilView for the depth/stencil buffer
    - Metal (NOTE that the roles of provided surfaces is slightly different in Metal than in D3D11, notably, the CAMetalDrawable is either rendered to directly, or serves as MSAA resolve target):
      - A CAMetalDrawable object which is either rendered into directly, or in case of MSAA rendering, serves as MSAA-resolve-target
      - If MSAA is used, an multisampled MTLTexture where rendering goes into
      - An optional MTLTexture for the depth/stencil buffer

A `TSwapchain` record provided to `TGfx.BeginPass` can indicate that the swapchain is in an 'invalid state' via the Boolean `TSwapchain.Invalid`. When this flag is set, all other `TSwapchain` members must be zeroed. An invalid swapchain will cause all rendering operations in that pass to be silently skipped.

It's recommended that you create a helper function which returns an initialized `TSwapchain` record. This can then be plugged into the `TGfx.BeginPass` function like this:

```pascal
var Pass := TPass.Create;
Pass.Swapchain.FromAppSwapchain;
TGfx.BeginPass(Pass);
```

As an example for such a helper function check out the method `TSwapchain.FromAppSwapchain` in the Neslib.Sokol.Glue unit.

For offscreen render passes, the render target images used in a render pass must be provided as sg_view objects specialized for the specific pass-attachment types:

  - color-attachment-views for color-rendering
  - depth-stencil-attachment-views for the depth-stencil-buffer surface
  - resolve-attachment-views for MSAA-resolve operations

For a simple offscreen scenario with one color-, one depth-stencil-render target and without multisampling, setting up the required image- and view-objects looks like this:

First create two render target images, one with a color pixel format, and one with the depth- or depth-stencil pixel format. Both images must have the same dimensions. Also not the usage flags:

```pascal
var ImageDesc := TImageDesc.Create;
ImageDesc.Usage.ColorAttachment := True;
ImageDesc.Width := 256;
ImageDesc.Height := 256;
ImageDesc.PixelFormat := TPixelFormat.Rgba8;
ImageDesc.SampleCount := 1;
var ColorImage := TImage.Create(ImageDesc);

ImageDesc := TImageDesc.Create;
ImageDesc.Usage.DepthStencilAttachment := True;
ImageDesc.Width := 256;
ImageDesc.Height := 256;
ImageDesc.PixelFormat := TPixelFormat.Depth;
ImageDesc.SampleCount := 1;
var DepthImage := TImage.Create(ImageDesc);
```

Note: when creating render target images, have in mind that some default values are aligned with the default environment attributes in the `TEnvironment` struct that was passed into `TGfx.Setup` call:

  - The default value for `TImageDesc.PixelFormat` is taken from `TEnvironment.Defaults.ColorFormat`
  - The default value for `TImageDesc.SampleCount` is taken from `TEnvironment.Defaults.SampleCount`
  - The default value for `TImageDesc.NumMipmaps` always 1

Next, create two view objects, one color-attachment-view and one depth-stencil-attachment view:

```pascal
var ViewDesc := TViewDesc.Create;
ViewDesc.ColorAttachment.Image := ColorImage;
var ColorAttView := TView.Create(ViewDesc);

ViewDesc := TViewDesc.Create;
ViewDesc.DepthStencilAttachment.Image := DepthImage;
var DepthAttView := TView.Create(ViewDesc);
```

You'll typically also want to create a texture-view on the color image to sample the color attachment image as texture in a later pass:

```pascal
var ViewDesc := TViewDesc.Create;
ViewDesc.Texture.Image := ColorImage;
var TexView := TView.Create(ViewDesc);
```

The attachment-view objects are then passed into the `TGfx.BeginPass` function in place of the nested swapchain struct:

```pascal
var Pass := TPass.Create;
Pass.Attachments.Colors[0] := ColorAttView;
Pass.Attachments.DepthStencil := DepthAttView;
TGfx.BeginPass(Pass);
```

...in a later pass when you want to sample the color attachment image as texture, use the texture view in the `TGfx.ApplyBindings` call:

```pascal
var Bindings := TBindings.Create;
Bindings.VertexBuffers[0] := ...;
Bindings.IndexBuffers := ...;
Bindings.Views[VIEW_TEX] := TexView;
Bindings.Samplers[SMP_SMP] := Smp;
TGfx.ApplyBindings(Bindings);
```

Swapchain and offscreen passes form dependency trees with a swapchain pass at the root, offscreen passes as nodes, and attachment images as dependencies between passes.

`TPassAction` records are used to define actions that should happen at the start and end of render passes (such as clearing pass attachments to a specific color or depth-value, or performing an MSAA resolve operation at the end of a pass).

A typical `TPassAction` record which clears the color attachment to black might look like this:

```pascal
var PassAction := TPassAction.Create;
PassAction.Colors[0].Init(TLoadAction.Clear, 0, 0, 0, 1);
```

This omits the defaults for the color attachment store action, and the depth-stencil-attachments actions. The same pass action with the defaults explicitly filled in would look like this:

```pascal
var PassAction := TPassAction.Create;
PassAction.Colors[0].Init(TLoadAction.Clear, TStoreAction.Store, 0, 0, 0, 1);
PassAction.Depth.Init(TLoadAction.Clear, TStoreAction.DontCare, 1);
PassAction.Stencil.Init(TLoadAction.Clear, TStoreAction.DontCare, 0);
```

With the `TPass` object and `TPassAction` record in place everything is ready now for the actual render pass.

Using such this prepared `TPassAction` in a swapchain pass looks like this:

```pascal
var Pass := TPass.Create;
Pass.Action^ := PassAction;
Pass.Swapchain.FromAppSwapchain;
TGfx.BeginPass(Pass);
...
TGfx.EndPass;
```

...of alternatively in one offscreen pass:

```pascal
var Pass := TPass.Create;
Pass.Action^ := PassAction;
Pass.Attachments.Colors[0] := ColorAttView;
Pass.Attachments.DepthStencil := DepthAttView;
TGfx.BeginPass(Pass);
...
TGfx.EndPass;
```

Offscreen rendering can also go into a mipmap, or a slice/face of a cube-, array- or 3d-image (which some restrictions, for instance it's not possible to create a 3D image with a depth/stencil pixel format, these exceptions are generally caught by the Sokol validation layer).

The mipmap/slice selection is baked into the attachment-view objects, for instance to create a color-attachment-view for rendering into mip-level 2 and slice 3 of an array texture:

```pascal
var ViewDesc := TViewDesc.Create;
ViewDesc.ColorAttachment.Image := ColorImg;
ViewDesc.ColorAttachment.MipLevel := 2;
ViewDesc.ColorAttachment.Slice := 3;
var ColorAttView := TView.Create(ViewDesc);
```

If MSAA offscreen rendering is desired, the multi-sample rendering result must be 'resolved' into a separate 'resolve image', before that image can be used as texture.

Setting up MSAA offscreen 3D rendering requires three image objects (one color-attachment image with a sample count > 1), a resolve-attachment image with a sample count of 1, and a depth-stencil-attachment image with the same sample count as the color-attachment image:

```pascal
var ImageDesc := TImageDesc.Create;
ImageDesc.Usage.ColorAttachment := True;
ImageDesc.Width := 256;
ImageDesc.Height := 256;
ImageDesc.PixelFormat := TPixelFormat.Rgba8;
ImageDesc.SampleCount := 4;
var ColorImage := TImage.Create(ImageDesc);

ImageDesc := TImageDesc.Create;
ImageDesc.Usage.ResolveAttachment := True;
ImageDesc.Width := 256;
ImageDesc.Height := 256;
ImageDesc.PixelFormat := TPixelFormat.Rgba8;
ImageDesc.SampleCount := 1;
var ResolveImage := TImage.Create(ImageDesc);

ImageDesc := TImageDesc.Create;
ImageDesc.Usage.DepthStencilAttachment := True;
ImageDesc.Width := 256;
ImageDesc.Height := 256;
ImageDesc.PixelFormat := TPixelFormat.Depth;
ImageDesc.SampleCount := 4;
var DepthImage := TImage.Create(ImageDesc);
```

Next you'll need the corresponding attachment-view objects:

```pascal
var ViewDesc := TViewDesc.Create;
ViewDesc.ColorAttachment.Image := ColorImage;
var ColorAttView := TView.Create(ViewDesc);

ViewDesc := TViewDesc.Create;
ViewDesc.ResolveAttachment.Image := ResolveImage;
var ResolveAttView := TView.Create(ViewDesc);

ViewDesc := TViewDesc.Create;
ViewDesc.DepthStencilAttachment.Image := DepthImage;
var DepthAttView := TView.Create(ViewDesc);
```

To sample the rendered image as a texture in a later pass you'll also need a texture-view on the resolve-attachment-image (not the color-attachment-image!):

```pascal
var ViewDesc := TViewDesc.Create;
ViewDesc.Texture.Image := ResolveImage;
var TexAttView := TView.Create(ViewDesc);
```

Next start the render pass with all attachment-views, as soon as a resolve-attachment-view is provided, an MSAA resolve operation will happen at the end of the pass. Also note that the content of the MSAA color-attachment-image doesn't need to be preserved, since it's only needed until the MSAA-resolve at the end of the pass, so the `.StoreAction` should be set to `DontCare`:

```pascal
var Pass := TPass.Create;
Pass.Attachments.Colors[0] := ColorAttView;
Pass.Attachments.Resolves[0] := ResolveAttView;
Pass.Attachments.DepthStencil := DepthAttView;
Pass.Action.Colors[0].Init(TLoadAction.Clear, TStoreAction.DontCare, 0, 0, 0, 1);
TGfx.BeginPass(Pass);
```

...in a later pass, use the texture-view that had been created on the resolve-image to use the rendering result as texture:

```pascal
var Bindings := TBindings.Create;
Bindings.VertexBuffers[0] := ...;
Bindings.IndexBuffers := ...;
Bindings.Views[VIEW_TEX] := TexView;
Bindings.Samplers[SMP_SMP] := Smp;
TGfx.ApplyBindings(Bindings);
```

## On Compute Passes

Compute passes are used to update the content of storage buffers and storage images by running compute shader code on the GPU. Updating storage resources with a compute shader will almost always be more efficient than computing the same data on the CPU and then uploading it via `TBuffer.Update` or `TImage.Update`.

Note: compute passes are only supported on the following platforms and backends:

  - macOS and iOS with Metal
  - Windows with D3D11 and OpenGL
  - Android with GLES3.1+

...this means compute shaders can't be used on the following platform/backend combos (the same restrictions apply to using storage buffers without compute shaders):

  - macOS with GL
  - iOS with GLES3

A compute pass is started with:

```pascal
var Pass := TPass.Create;
Pass.Compute := True;
TGfx.BeginPass(Pass);
```

...and finished with a regular `TGfx.EndPass`.

Typically the following functions will be called inside a compute pass:

* `TGfx.ApplyPipeline`
* `TGfx.ApplyBindings`
* `TGfx.ApplyUniforms`
* `TGfx.Dispatch`

The following functions are disallowed inside a compute pass and will cause validation layer errors:

* `TGfx.ApplyViewport`
* `TGfx.ApplyScissorRect`
* `TGfx.Draw`

Only special 'compute shaders' and 'compute pipelines' can be used in compute passes. A compute shader only has a compute-function instead of a vertex- and fragment-function pair, and it doesn't accept vertex- and index-buffers as bindings, only storage-buffer-views (readable and writable), storage-image-views (read/write or writeonly) and texture-views (read-only).

A compute pipeline is created by providing a compute shader object, setting the .compute creation parameter to true and not defining any 'render state':

```pascal
var PipDesc := TPipelineDesc.Create;
PipDesc.Compute := True;
PipDesc.Shader := ComputeShader;
var Pip := TPipeline.Create(PipDesc);
```

The `TGfx.ApplyBindings` and `TGfx.ApplyUniforms` calls are the same as in render passes, with the exception that no vertex- and index-buffers can be bound in the `TGfx.ApplyBindings` call.

Finally to kick off a compute workload, call `TGfx.Dispatch` with the number of workgroups in the x, y and z-dimension.

Also see the following compute-shader samples (in the Samples directory):

* InstancingCompute
* ComputeBoids
* ImageBlur

## On Shader Creation

Sokol doesn't come with an integrated shader cross-compiler. Instead backend-specific shader sources or binary blobs need to be provided when creating a shader object, along with reflection information about the shader resource binding interface needed to bind Sokol resources to the proper shader inputs.

The easiest way to provide all this shader creation data is to use the sokol-shdc shader compiler tool to compile shaders from a common GLSL syntax into backend-specific sources or binary blobs, along with shader interface information and uniform blocks and storage buffer array items mapped to Delphi records.

To create a shader using a Delphi unit which has been code-generated by sokol-shdc:

```pascal
uses
  { Include unit code-generated by sokol-shdc }
  MyShader;
  
{ Create shader using a code-generated helper function from the MyShader unit }
var Shader := TShader.Create(MyShaderDesc);
```

The samples in the Samples directory use the sokol-shdc approach.

See the [Shader Cross Compilation](Neslib.Sokol.Shader.md) document for information about sokol-shdc.

## On Vertex Formats

Sokol implements the same strict mapping rules from CPU-side vertex component formats to GPU-side vertex input data types:

- float and packed normalized CPU-side formats must be used as floating point base type in the vertex shader
- packed signed-integer CPU-side formats must be used as signed integer base type in the vertex shader
- packed unsigned-integer CPU-side formats must be used as unsigned integer base type in the vertex shader

These mapping rules are enforced by the Sokol validation layer, but only when sufficient reflection information is provided in `TShaderDesc.Attrs[].BaseType`. This is the case when sokol-shdc is used, otherwise the default base_type will be `TShaderAttrBaseType.Undefined` which causes the Sokol validation check to be skipped (of course you can also provide the per-attribute base type information manually when not using sokol-shdc).

The detailed mapping rules from TVertexFormat to GLSL data types are as follows:

- Float* => float, vec*
- Byte4N => vec* (scaled to -1.0 .. +1.0)
- UByte4N => vec* (scaled to 0.0 .. +1.0)
- Short\*N => vec* (scaled to -1.0 .. +1.0)
- UShort\*N => vec* (scaled to 0.0 .. +1.0)
- Int* => int, ivec*
- UInt* => uint, uvec*
- Byte4 => int*
- UByte4 => uint*
- Short* => int*
- UShort* => uint*

Note that Sokol only provides vertex formats with sizes of a multiple of 4 (e.g. Byte4N but not Byte2N). This is because vertex components must be 4-byte aligned anyway.

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

## On Storage Buffers

The two main purpose of storage buffers are:

  - to be populated by compute shaders with dynamically generated data
  - for providing random-access data to all shader stages

Storage buffers can be used to pass large amounts of random access structured data from the CPU side to the shaders. They are similar to data textures, but are more convenient to use both on the CPU and shader side since they can be accessed in shaders as as a 1-dimensional array of struct items.

Storage buffers are *not* supported on the following platform/backend combos:

- macOS+GL (because storage buffers require GL 4.3, while macOS only goes up to GL 4.1)
- platforms which only support a GLES3.0 context

To use storage buffers, the following steps are required:

  - write a shader which uses storage buffers (vertex- and fragment-shaders can only read from storage buffers, while compute-shaders can both read and write storage buffers)
  - create one or more storage buffers via `TBuffer.Create` with the `.Usage.StorageBuffer := True`
  - when creating a shader, populate the `TShaderDesc` record with binding info (when using sokol-shdc, this step will be taken care of automatically)
    - which storage buffer bind slots on the vertex-, fragment- or compute-stage are occupied
    - whether the storage buffer on that bind slot is readonly (readonly bindings are required for vertex- and fragment-shaders, and in compute shaders the readonly flag is used to control hazard tracking in some 3D backends)
  - when calling `TGfx.ApplyBindings`, apply the matching bind slots with the previously created storage buffers
  - ...and that's it.

For more details, see the following backend-agnostic samples (in the Samples directory):

- simple vertex pulling from a storage buffer (VertexPull sample)
- instanced rendering via storage buffers (vertex- and instance-pulling, InstancingPull sample)
- storage buffers both on the vertex- and fragment-stage (StorageBufTex sample)
- the Ozz animation sample rewritten to pull all rendering data from storage buffers (OzzStorageBuffer sample)
- the instancing sample modified to use compute shaders (InstancingCompute sample)
- the Compute Boids sample ported to Sokol (ComputeBoids sample)

...also see the following backend-specific vertex pulling samples (those also don't use sokol-shdc):

- D3D11: VertexPullingD3D11 sample
- desktop GL: VertexPullingGlfw sample
- Metal: VertexPullingMetal sample

...and the backend specific compute shader samples:

- D3D11: InstancingComputeD3D11 sample
- desktop GL: InstancingComputeGlfw sample
- Metal: InstancingComputeMetal sample

Storage buffer shader authoring caveats when using sokol-shdc:

  - declare a read-only storage buffer interface block with `layout(binding=N) readonly buffer [name] { ... }` (where 'N' is the index in `TBindings.StorageBuffers[N]`)
  - ...or a read/write storage buffer interface block with `layout(binding=N) buffer [name] { ... }`
  - declare a struct which describes a single array item in the storage buffer interface block
  - only put a single flexible array member into the storage buffer interface block

E.g. a complete example in 'sokol-shdc GLSL':

```glsl
@vs
// declare a struct:
struct sb_vertex {
    vec3 pos;
    vec4 color;
}
// declare a buffer interface block with a single flexible struct array:
layout(binding=0) readonly buffer vertices {
    sb_vertex vtx[];
}
// in the shader function, access the storage buffer like this:
void main() {
    vec3 pos = vtx[gl_VertexIndex].pos;
    ...
}
@end
```

In a compute shader you can read and write the same item in the same storage buffer (but you'll have to be careful for random access since many threads of the same compute function run in parallel):

```glsl
@cs
struct sb_item {
    vec3 pos;
    vec3 vel;
}
layout(binding=0) buffer items_ssbo {
    sb_item items[];
}
layout(local_size_x=64, local_size_y=1, local_size_z=1) in;
void main() {
    uint idx = gl_GlobalInvocationID.x;
    vec3 pos = items[idx].pos;
    ...
    items[idx].pos = pos;
}
@end
```

## On Storage Images

To write pixel data to texture objects in compute shaders, first an image object must be created with `StorageImage` usage:

```pascal
var Desc := TImageDesc.Create;
Desc.Usage.StoreImage := True;
Desc.Width := ...;
Desc.Height := ...;
Desc.PixelFormat := ...;
var StorageImage := TImage.Create(Desc);
```

Next a storage-image-view object is required which also allows to pick a specific mip-level or slice for the compute-shader to access:

```pascal
var Desc := TViewDesc.Create;
Desc.StorageImage.Image := StorageImage;
Desc.StorageImage.MipLevel := ...;
Desc.StorageImage.Slice := ...;
var StorageImgView := TView.Create(Desc);
```

Finally 'bind' the storage-image-view via a regular `TGfx.ApplyBindings` call inside a compute pass:

```pascal
var Pass := TPass.Create;
Pass.Compute := True;
TGfx.ApplyPipeline(...);

var Bindings := TBindings.Create;
Bindings.View[VIEW_SIMG] := StorageImgView;
TGfx.ApplyBindings(Bindings);

TGfx.Dispatch;
TGfx.EndPass;
```

Currently, storage images can only be used with `readwrite` or `writeonly` access in shaders. For readonly access use a regular texture binding instead.

For an example of using storage images in compute shaders see the ImageBlur sample in the Samples directory.

## Trace Hooks
Neslib.Sokol.Gfx optionally allows to install "trace hook" callbacks for each public API. When a public API function is called, and a trace hook callback has been installed for this function, the callback will be invoked with the parameters and result of the function. This is useful for things like debugging- and profiling-tools, or keeping track of resource creation and destruction.

For performance reasons, there is no Delphi wrapper around the trace hook functionality, but you can use the C API directly to install trace hooks:

* Setup a `TTraceHooks` record with your callback functions (note that these are C-style functions with the cdecl calling convention). Keep all callbacks you're not interested in zero-initialized). Optionally set the `user_data` field in the `TTraceHooks._sg_trace_hooks` record.
  
* Install the trace hooks by calling `TGfx.InstallTraceHooks`.

As an example of how trace hooks are used, compile the sample projects using the DebugUI or ReleaseUI configurations. This uses trace hooks and Dear  ImGui to display a debug UI to inspect Neslib.Sokol.Gfx resources in real time.

## Memory Allocation Override

You can use Delphi's memory manager instead of the system memory manager by settings `TGfxDesc.UseDelphiMemoryManager` to `True`.  This only affects memory allocation calls done by Neslib.Sokol.Gfx itself though, not any allocations in OS libraries.

## Error reporting and logging

To get any logging information at all you need to provide a logging callback in the `TGfxDesc` record. The easiest way is using the DefaultLogger provided by Sokol:

```pascal
  var Desc := TGfxDesc.Create;
  Desc.Logger := Desc.DefaultLogger;
  ...
  TGfx.Setup(Desc);
```

## Commit Listener

It's possible to hook a callback function into `TGfx` which is called from inside `TGfx.Commit`. This is mainly useful for libraries that build on top of Neslib.Sokol.Gfx to be notified about the end/start of a frame.

To set a commit listener:

```pascal
TGfx.CommitListener := MyCommitListener;

procedure TMyApp.MyCommitListener;
begin
  ...
end;
```

`TMyApp.MyCommitListener` will be called each frame from inside `TGfx.Commit`.

To remove the commit listener set `TGfx.CommitListener` to `nil`.

## Resource Creation and Destruction in detail

The 'vanilla' way to create resource objects is with the Create functions:

* `TBuffer.Create(const ADesc: TBufferDesc)`
* `TImage.Create(const ADesc: TImageDesc)`
* `TSampler.Create(const ADesc: TSamplerDesc)`
* `TShader.Create(const ADesc: TShaderDesc)`
* `TPipeline.Create(const ADesc: TPipelineDesc)`
* `TView.Create(const ADesc: TViewDesc)`

This will result in one of three cases:

1. The returned object is invalid. This happens when there are no more free slots in the resource pool for this resource type. An invalid object is associated with the `.Invalid` resource state, for instance:

   ```pascal
   var Buffer := TBuffer.Create(...);
   if (Buffer.State = TResourceState.Invalid) then
     // Buffer pool exhausted
   ```

2. The returned object is valid, but creating the underlying resource has failed for some reason. This results in a resource object in the `.Failed` state. The reason *why* resource creation has failed differ by resource type. Look for log messages with more details. A failed resource state can be checked with:

   ```pascal
   var Buffer := TBuffer.Create(...);
   if (Buffer.State = TResourceState.Failed) then
     // Creating the resource has failed
   ```

3. And finally, if everything goes right, the returned resource is in resource state `.Valid` and ready to use. This can be checked with:

   ```pascal
   var Buffer := TBuffer.Create(...);
   if (Buffer.State = TResourceState.Valid) then
     // Creating the resource has succeeded
   ```

When calling the `Create`, the created resource goes through a number of states:

  - `TResourceState.Initial`: the resource slot associated with the new resource is currently free (technically, there is no resource yet, just an empty pool slot)
  - `TResourceState.Alloc`: the new resource has been allocated, this just means a pool slot has been reserved.
  - `TResourceState.Valid` or `TResourceState.Failed`: in `.Valid` state any 3D API backend resource objects have been successfully created, otherwise if anything went wrong, the resource will be in `.Failed` state.

Sometimes it makes sense to first allocate the object, but initialize the underlying resource at a later time. For instance when loading data asynchronously from a slow data source, you may know what buffers and textures are needed at an early stage of the loading process, but actually loading the buffer or texture content can only be completed at a later time.

For such situations, Sokol resource objects can be created in two steps. You can allocate a handle upfront with the `Allocate` method:

* `TBuffer.Allocate`
* `TImage.Allocate`
* `TSampler.Allocate`
* `TShader.Allocate`
* `TPipeline.Allocate`
* `TView.Allocate`

This will return an object with the underlying resource object in the `.Alloc` state:

```pascal
var Buffer: TBuffer;
Buffer.Allocate;
if (Buffer.State = TResourceState.Alloc) then
  // Allocating an image handle has succeeded, otherwise the image pool is full
```

Such an 'incomplete' object can be used in most Sokol rendering functions without doing any harm; Sokol will simply skip any rendering operation that involve resources which are not in `.Valid` state.

At a later time (for instance once the texture has completed loading asynchronously), the resource creation can be completed by calling the `Setup` method, passing a description record:

* `TBuffer.Setup(const ADesc: TBufferDesc)`
* `TImage.Setup(const ADesc: TImageDesc)`
* `TSampler.Setup(const ADesc: TSamplerDesc)`
* `TShader.Setup(const ADesc: TShaderDesc)`
* `TPipeline.Setup(const ADesc: TPipelineDesc)`
* `TView.Setup(const ADesc: TViewDesc)`

The `Setup` methods expect a resource in `.Alloc` state, and after the function returns, the resource will be either in `.Valid` or `.Failed` state. Calling an `Allocate` method followed by the matching `Setup` method is fully equivalent with calling the `Create` method alone.

Destruction can also happen as a two-step process. The `TearDown` methods will put a resource object from the `.Valid` or `.Failed` state back into the `.Alloc` state:

* `TBuffer.TearDown`
* `TImage.TearDown`
* `TSampler.TearDown`
* `TShader.TearDown`
* `TPipeline.TearDown`
* `TView.TearDown`

Calling the `TearDown` methods with a resource that is not in the `.Valid` or `.Failed` state is a no-op.

To finally free the pool slot for recycling call the `Deallocate` methods:

* `TBuffer.Deallocate`
* `TImage.Deallocate`
* `TSampler.Deallocate`
* `TShader.Deallocate`
* `TPipeline.Deallocate`
* `TView.Deallocate`

Calling the `Deallocate` methods on a resource that's not in `.Alloc` state is a no-op, but will generate a warning log message.

Calling a `TearDown` method and `Deallocate` method in sequence is equivalent with calling the associated `Free` method:

* `TBuffer.Free`
* `TImage.Free`
* `TSampler.Free`
* `TShader.Free`
* `TPipeline.Free`
* `TView.Free`

The `Free` methods can be called on resources in any state and generally do the right thing (for instance if the resource is in `.Alloc` state, the destroy function will be equivalent to the `Deallocate` method and skip the `TearDown` part).

And finally to close the circle, the `Fail` methods can be called to manually put a resource in `.Alloc` state into the `.Failed` state:

* `TBuffer.Fail`
* `TImage.Fail`
* `TSampler.Fail`
* `TShader.Fail`
* `TPipeline.Fail`
* `TView.Fail`

This is recommended if anything went wrong outside of Sokol during asynchronous resource setup (for instance a file loading operation failed). In this case, the `Fail` method should be called instead of the `Setup` method.

Calling a `Fail` method on a resource that's not in `.Alloc` state is a no-op, but will generate a warning log message.

Note that two-step resource creation usually only makes sense for buffers, images and views, but not for samplers, shaders or pipelines. Most notably, trying to create a pipeline object with a shader that's not in `.Valid` state will trigger a validation layer error, or if the validation layer is disabled, result in a pipeline object in `.Failed` state.
# Neslib.Sokol.GL

OpenGL 1.x style rendering on top of [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md).

This is a light-weight OOP layer on top of [sokol_gl.h](https://github.com/floooh/sokol).

## Feature Overview

This unit implements a subset of the OpenGLES 1.x feature set useful for when you just want to quickly render a bunch of colored triangles or lines without having to mess with buffers and shaders.

The current feature set is mostly useful for debug visualizations and simple UI-style 2D rendering:

What's implemented:
* vertex components:
  - position (x, y, z)
  - 2D texture coords (u, v)
  - color (r, g, b, a)
* primitive types:
  - triangle list and strip
  - line list and strip
  - quad list (TODO: quad strips)
  - point list
* one texture layer (no multi-texturing)
* viewport and scissor-rect with selectable origin (top-left or bottom-left)
* all GL 1.x matrix stack functions, and additionally equivalent functions for gluPerspective and gluLookat

Notable GLES 1.x features that are *NOT* implemented:
* vertex lighting (this is the most likely GL feature that might be added later)
* vertex arrays (although providing whole chunks of vertex data at once might be a useful feature for a later version)
* texture coordinate generation
* line width
* all pixel store functions
* no ALPHA_TEST
* no clear functions (clearing is handled by the sokol-gfx render pass)
* fog

Notable differences to GL:
* No "enum soup" for render states etc. Instead there's a 'pipeline stack', this is similar to GL's matrix stack, but for pipeline-state-objects. The pipeline object at the top of the pipeline stack defines the active set of render states
- All angles are in radians, not degrees
- No enable/disable state for scissor test, this is always enabled

## Step-by-Step

* To initialize, call:

  ```pascal
    class procedure sglSetup(const ADesc: TGLDesc);
  ```

  Note that `sglSetup` must be called *after* initializing [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md) (via `TGfx.Setup`). This is because `sglSetup` needs to create Gfx resource objects.

  If you're intending to render to the default pass, and also don't want to tweak memory usage, you can just keep `TGLDesc` zero-initialized:

  ```pascal
    var Desc := TGDDesc.Create;
  ```

  In this case, this unit will create internal `TPipeline` objects that are compatible with the [Neslib.Sokol.App](Neslib.Sokol.App.md) default framebuffer. If you want to render into a framebuffer with different pixel-format and MSAA attributes you need to provide the matching attributes in the `sglSetup` call:

  ```pascal
    var Desc := TGDDesc.Create;
    Desc.ColorFormat := TPixelFormat....
    Desc.DepthFormat := TPixelFormat....
    Desc.SampleCount := ...
  ```

  To reduce memory usage, or if you need to create more then the default number of contexts, pipelines, vertices or draw commands, set the following `TGLDesc` fields:

  * `.ContextPoolSize` (default: 4)
  * `.PipelinePoolSize` (default: 64)
  * `.MaxVertices` (default: 64k)
  * `.MaxCommands` (default: 16k)

  Finally you can change the face winding for front-facing triangles and quads:

  * `.FaceWinding` (default: TFaceWinding.CounterClockWise)

  The default winding for front faces is counter-clock-wise. This is the same as OpenGL's default, but different from [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md).

* Optionally create additional context objects if you want to render into multiple Gfx render passes (or generally if you want to use multiple independent GL "state buckets")
  
  ```pascal
    constructor TGLContext.Create(const ADesc: TGLContextDesc);
  ```

  For details on rendering with GL contexts, see the section [Working with contexts](#working-with-contexts).
  
* Optionally, create pipeline-state-objects if you need render state that differs from GL's default state:
  
  ```pascal
    constructor TGLPipeline.Create(const ADesc: TPipelineDesc);
  ```
  
  This creates a pipeline object that's compatible with the currently active context. Alternatively call:

  ```pascal
    constructor TGLPipeline.Create(const ACtx:TGLContext; const ADesc: TPipelineDesc);
  ```
  
  To create a pipeline object that's compatible with an explicitly provided context.

  The similarity with Gfx's `TPipeline` is intended. `TGLPipeline.Create` also takes a standard Gfx `TPipelineDesc` record to describe the render state, but without:
  - shader
  - vertex layout
  - color- and depth-pixel-formats
  - primitive type (lines, triangles, ...)
  - MSAA sample count
  
  Those will be filled in by `TGLPipeline.Create`. Note that each call to `TGLPipeline.Create` needs to create several Gfx pipeline objects (one for each primitive type).

  `Depth.WriteEnabled` will be forced to `False` if the context this pipeline object is intended for has its depth pixel format set to `TPixelFormat.None` (which means the framebuffer this context is used with doesn't have a depth-stencil surface).
  
* If you need to destroy `TGLPipeline` objects before `sglShutdown`:

    ```pascal
    destructor TGLPipeline.Destroy;
    ```

* After `sglSetup` you can call any of the Sokol GL functions anywhere in a frame, *except* `sglDraw`. The 'vanilla' functions will only change internal Sokol GL state, and not call any Sokol Gfx functions.
  
* Unlike OpenGL, Sokol GL has a method to reset internal state to a known default. This is useful at the start of a sequence of rendering operations:
  
  ```pascal
    procedure sglDefaults;
  ```
  
  This will set the following default state:
  - current texture coordinate to u=0.0, v=0.0
  - current color to white (rgba all 1.0)
  - current point size to 1.0
  - unbind the current texture and texturing will be disabled
  - *all* matrices will be set to identity (also the projection matrix)
  - the default render state will be set by loading the 'default pipeline' into the top of the pipeline stack
    
  
  The current matrix- and pipeline-stack-depths will not be changed by `sglDefaults`.

* Change the currently active renderstate through the pipeline-stack methods. This works similar to the traditional GL matrix stack:
  
  ...load the default pipeline state on the top of the pipeline stack:
  
  ```pascal
  procedure sglLoadDefaultPipeline;
  ```
  
  ...load a specific pipeline on the top of the pipeline stack:
  
  ```pascal
  procedure sglLoadPipeline(const APip: TGLPipeline);
  ```
  
  ...push and pop the pipeline stack:
  
  * `sglPushPipeline`
  * `sglPopPipeline`
  
* Control texturing with:

    * `sglEnableTexture`

    * `sglDisableTexture`

    * `sglTexture(const AImg: TImage)`

* Set the current viewport and scissor rect with:

  * `sglViewport(const AX, AY, AW, AH: Integer; const AOriginTopLeft: Boolean)`

  * `sglScissorRect(const AX, AY, AW, AH: Integer; const AOriginTopLeft: Boolean)`


  ...or call these alternatives which take float arguments (this might allow to avoid casting between float and integer in more strongly typed languages when floating point pixel coordinates are used):

  * `sglViewport(const AX, AY, AW, AH: Single; const AOriginTopLeft: Boolean)`
  * `sglScissorRect(const AX, AY, AW, AH: Single; const AOriginTopLeft: Boolean)`

  ...these calls add a new command to the internal command queue, so that the viewport or scissor rect are set at the right time relative to other Sokol GL calls.

* Adjust the transform matrices, matrix manipulation works just like the OpenGL matrix stack:

  ...set the current matrix mode:

  * `sglMatrixModeModelView`
  * `sglMatrixModeProjection`
  * `sglMatrixModeTexture`

  ...load the identity matrix into the current matrix:

  * `sglLoadIdentity`

  ...translate, rotate and scale the current matrix:

  * `sglTranslate(AX, AY, AZ: Single)`
  * `sglRotate(AAngleRad, AX, AY, AZ: Single)`
  * `sglScale(AX, AY, AZ: Single)`

  Note that all angles in Sokol GL are in radians, not in degrees. Convert between radians and degree with the helper functions:

  * `sglRad(const ADeg: Single): Single;` - degrees to radians
  * `sglDeg(ARad: Single): Single;` - radians to degrees

  ...directly load the current matrix from a `TMatrix4` record:

  * `sglLoadMatrix(const AMatrix: TMatrix4);`
  * `sglLoadTransposeMatrix(const AMatrix: TMatrix4);`

  ...directly multiply the current matrix from a `TMatrix4` record:

  * `sglMultMatrix(const AMatrix: TMatrix4);`
  * `sglMultTransposeMatrix(const AMatrix: TMatrix4);`

  ...more matrix functions:

  * `sglFrustum(ALeft, ARight, ABottom, ATop, ANear, AFar: Single);`
  * `sglOrtho(ALeft, ARight, ABottom, ATop, ANear, AFar: Single);`
  * `sglPerspective(AFovY, AAspect, ANear, AFar: Single);`
  * `sglLookAt(AEyex, AEyeY, AEyeZ, ACenterX, ACenterY, ACenterZ, AUpX, AUpY, AUpZ: Single);`

  These functions work the same as `glFrustum()`, `glOrtho()`, `gluPerspective()` and `gluLookAt()`.

  ...and finally to push / pop the current matrix stack:

  * `sglPushMatrix`
  * `sglPopMatrix`

  Again, these work the same as `glPushMatrix()` and `glPopMatrix()`.

* Perform primitive rendering:

  ...set the current texture coordinate and color 'registers' with or point size with:

  * `sglT2f(AU, AV: Single)` - set current texture coordinate
  * `sglC*(...)` - set current color
  * `sglPointSize(ASize: Single)` - set current point size

  There are several functions for setting the color (as float values, unsigned byte values, packed as unsigned 32-bit integer, with and without alpha).

  Note that these are the only functions that can be called both inside `sglBegin*()` / `sglEnd()` and outside.

  Also note that point size is currently hardwired to 1.0 if the D3D11 backend is used.

  ...start a primitive vertex sequence with:

  * `sglBeginPoints`
  * `sglBeginLines`
  * `sglBeginLineStrip`
  * `sglBeginTriangles`
  * `sglBeginTriangleStrip`
  * `sglBeginQuads`

  ...after `sglBegin*()` specify vertices:

  * `sglV*(...)`
  * `sglV*_T*(...)`
  * `sglV*_C*(...)`
  * `sglV*_T*_C*(...)`

  These functions write a new vertex to Sokol GL's internal vertex buffer, optionally with texture-coords and color. If the texture coordinate and/or color is missing, it will be taken from the current texture-coord and color 'register'.
  
  ...finally, after specifying vertices, call:
  
  * `sglEnd`
  
  This will record a new draw command in Sokol GL's internal command list, or it will extend the previous draw command if no relevant state has  changed since the last `sglBegin`/`sglEnd` pair.
  
* Inside a Sokol Gfx rendering pass, call the `sglDraw` function to render the currently active context:
  
  * `sglDraw`
  
  ...or alternatively call:
  
  * `sglDraw(ACtx: TGLContext)`
  
  ...to render an explicitly provided context.
  
  This will render everything that has been recorded in the context since the last call to sglDraw through Sokol Gfx, and will 'rewind' the internal vertex-, uniform- and command-buffers.
  
* Each Sokol GL context tracks an internal error code, to query the current error code for the currently active context call:
  
  * `sglError: TGLError;`
  
  ...alternatively with an explicit context argument:
  
  * `sglError(const ACtx: TGLContext): TGLError;`
  
  ...which can return the following error codes:
  
  * `.NoError` - all OK, no error occurred since last `sglDraw`
  * `.ErrorVerticesFull` - internal vertex buffer is full (checked in `sglEnd`)
  * `.ErrorUniformsFull` - the internal uniforms buffer is full (checked in `sglEnd`)
  * `.ErrorCommandsFull` - the internal command buffer is full (checked in `sglEnd`)
  * `.ErrorStackOverflow` - matrix- or pipeline-stack overflow
  * `.ErrorStackUnderflow` - matrix- or pipeline-stack underflow
  * `.ErrorNoContext` - the active context no longer exists
  
  ...if Sokol GL is in an error-state, `sglDraw` will skip any rendering, and reset the error code to `TGLError.NoError`.

## Working with Contexts

If you want to render to more than one Sokol Gfx render pass you need to work with additional context objects (one context object for each offscreen rendering pass, in addition to the implicitly created 'default context').

All Sokol GL state is tracked per context, and there is always a "current context" (with the notable exception that the currently set context is destroyed, more on that later).

Using multiple contexts can also be useful if you only render in a single pass, but want to maintain multiple independent "state buckets".

To create new context object, call:

```pascal
  var Desc := TGLContextDesc.Create;
  Desc.MaxVertices  := ... // default: 64k
  Desc.MaxCommands  := ... // default: 16k
  Desc.ColorFormat  := ...
  Desc.DepthFormat  := ...
  Desc.SampleCount  := ...
  var Ctx := TGLContext.Create(Desc);
```

The `ColorFormat`, `DepthFormat` and `SampleCount` items must be compatible with the render pass the `sglDraw` function will be called in.

Creating a context does *not* make the context current. To do this, call:

```pascal
  Ctx.MakeCurrent;
```

...or

```pascal
  TGLContext.Current := Ctx;
```

...or

```pascal
  sglSetContext(Ctx);
```

The currently active context will implicitely be used by most Sokol GL functions which don't take an explicit context handle as argument.

To switch back to the default context, call:

```pascal
  TGLContext.Default.MakeCurrent;
```

...or

```pascal
  TGLContext.Current := TGLContext.Default;
```

...or

```pascal
  sglSetDefaultContext();
```

To get the currently active context, call:

```pascal
  var CurCtx := TGLContext.Current;
```

or...

```pascal
  var CurCtx := sglGetContext;
```

The following functions exist in two overloads, one which use the currently active context (set with `sglSetContext`), and another version which takes an explicit context handle instead:

* `sglMakePipeline`
* `sglError`
* `sglDraw`

Except for using the currently active context versus a provided context handle, the two variants are exactly identical.

Destroying the currently active context is a 'soft error'. All following calls which require a currently active context will silently fail, and `sglError` will return `TGLError.NoContext`.
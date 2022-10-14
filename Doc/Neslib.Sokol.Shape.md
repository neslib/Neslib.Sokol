# Neslib.Sokol.Shape

Create simple primitive shapes for [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md).

This is a light-weight OOP layer on top of [sokol_shape.h](https://github.com/floooh/sokol).

## Feature Overview

Neslib.Sokol.Shape creates vertices and indices for simple shapes and builds records which can be plugged into Sokol Gfx resource creation functions.

The following shape types are supported:
* plane
* cube
* sphere (with poles, not geodesic)
* cylinder
* torus (donut)

Generated vertices look like this:

```pascal
  TShapeVertex = record
  public
    X, Y, Z: Single;
    Normal: UInt32; // packed normal as Byte4N
    U, V: UInt16;   // packed uv coords as UShort2N
    Color: UInt32;  // packed color as UByte4N (r,g,b,a)
  end;
```

Indices are generally 16-bits wide (`TIndexType.UInt16`) and the indices are written as triangle-lists (`TPrimitiveType.Triangles`).

## Examples

The Shapes demo app creates multiple shapes into the same vertex- and index-buffer and renders them with separate draw calls.

The ShapesTransform demo app does the same, but pre-transforms shapes and merges them into a single shape that's rendered with a single draw call.

## Step-by-Step

Setup a `TShapeBuffer` record with memory buffers where generated vertices and indices will be written to:

```pascal
  var Vertices: array [0..511] of TShapeVertex;
  var Indices: array [0..4095] of UInt16;
  var Buf := TShapeBuffer.Create(
    TRange.Create(Vertices),
    TRange.Create(Indices));
```

To find out how big those memory buffers must be (in case you want to allocate dynamically) call the following (static) functions:

```pascal
  function TShapeBuffer.PlaneSizes(const ATiles: Integer): TShapeSizes;
  function TShapeBuffer.BoxSizes(const ATiles: Integer): TShapeSizes;
  function TShapeBuffer.SphereSizes(const ASlices, AStacks: Integer): TShapeSizes;
  function TShapeBuffer.CylinderSizes(const ASlices, AStacks): TShapeSizes;
  function TShapeBuffer.TorusSizes(const ASides, ARings): TShapeSizes;
```

The returned `TShapeSizes` record contains vertex- and index-counts as well as the equivalent buffer sizes in bytes. For instance:

```pascal
  var Sizes := TShapeBuffer.SphereSizes(36, 12);
  var NumVertices := Sizes.Vertices.Count;
  var NumIndices := Sizes.Indices.Count;
  var VertexBufferSize := Sizes.Vertices.Size;
  var IndexBufferSize := Sizes.Indices.Size;
```

With the `TShapeBuffer` record that was setup earlier, call any of the shape-builder methods:

```pascal
  function TShapeBuffer.Build(const AParams: TShapePlane): TShapeBuffer;
  function TShapeBuffer.Build(const AParams: TShapeBox): TShapeBuffer;
  function TShapeBuffer.Build(const AParams: TShapeSphere): TShapeBuffer;
  function TShapeBuffer.Build(const AParams: TShapeCylinder): TShapeBuffer;
  function TShapeBuffer.Build(const AParams: TShapeTorus): TShapeBuffer;
```

Note how these methods also return a `TShapeBuffer` record. This can be used to append multiple shapes into the same vertex- and index-buffers (more  on this later).

The second argument is a record which holds creation parameters.

For instance to build a sphere with radius 2, 36 "cake slices" and 12 stacks:

```pascal
  var Buf := TShapeBuffer.Create(...);
  Buf := Buf.Build(TShapeSphere.Create(2.0, 36, 12));
```

If the provided buffers are big enough to hold all generated vertices and indices, then the `Valid` field in the result will be `True`:

```pascal
  Assert(Buf.Valid);
```

The shape creation parameters have "useful defaults", refer to the actual record declarations below to look up those defaults.

You can also provide additional creation parameters, like a common vertex color, a debug-helper to randomize colors, tell the shape builder method to merge the new shape with the previous shape into the same draw-element-range, or a 4x4 transform matrix to move, rotate and scale the generated vertices:

```pascal
  var Buf := TShapeBuffer.Create(...);
  var Sphere := TShapeSphere.Create;
  Sphere.Radius := 2.0;
  Sphere.Slices := 36;
  Sphere.Stacks := 12;
  // merge with previous shape into a single element-range
  Sphere.Merge := True;
  // set vertex color to red+opaque
  Sphere.Color := TAlphaColors.Red;
  // set position to y = 2.0
  Sphere.Transform.InitTranslation(0, 2, 0);
  Buf := Buf.BuildSphere(Sphere);
  Assert(Buf.Valid);
```

After the shape builder method has been called, the following methods are used to extract the build result for plugging into [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md):

```pascal
  function TShapeBuffer.ElementRange: TShapeElementRange;
  function TShapeBuffer.VertexBufferDesc: TBufferDesc;
  function TShapeBuffer.IndexBufferDesc: TBufferDesc;
  function TShapeBuffer.BufferLayoutDesc: TBufferLayoutDesc;
  function TShapeBuffer.PositionAttrDesc: TVertexAttrDesc;
  function TShapeBuffer.NormalAttrDesc: TVertexAttrDesc;
  function TShapeBuffer.TexCoordAttrDesc: TVertexAttrDesc;
  function TShapeBuffer.ColorAttrDesc: TVertexAttrDesc;
```

The `TShapeElementRange` record struct contains the base-index and number of indices which can be plugged into the `TGfx.Draw` call:

```pascal
  var Elems := Buf.ElementRange;
  ...
  TGfx.Draw(Elems.BaseElement, Elems.NumElements);
```

To create vertex- and index-buffers from the generated shape data:

```pascal
  // create vertex buffer
  var VBuf := TBuffer.Create(Buf.VertexBufferDesc);

  // create index buffer
  var IBuf := TBuffer.Create(Buf.IndexBufferDesc);
```

The remaining methods are used to populate the vertex-layout item in `TPipelineDesc`. Note that these methods don't depend on the created geometry; They always return the same result:

```pascal
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Buffers[0] := Buf.BufferLayoutDesc;
  PipDesc.Layout.Attrs[0] := Buf.PositionAttrDesc;
  PipDesc.Layout.Attrs[1] := Buf.NormalAttrDesc;
  PipDesc.Layout.Attrs[2] := Buf.TexCoordAttrDesc;
  PipDesc.Layout.Attrs[3] := Buf.ColorAttrDesc;
  ...
```

Note that you don't have to use all generated vertex attributes in the pipeline's vertex layout; The `TBufferLayoutDesc` record returned by `TShapeBuffer.BufferLayoutDesc` contains the correct vertex stride to skip vertex components.

## Writing multiple shapes into the same buffer

You can merge multiple shapes into the same vertex- and index-buffers and either render them as a single shape, or in separate draw calls.

To build a single shape made of two cubes which can be rendered in a single draw-call:

```pascal
  var Vertices: array [0..127] of TShapeVertex;
  var Indices: array [0..15] of UInt16;
  var Buf := TShapeBuffer.Create(
    TRange.Create(Vertices),
    TRange.Create(Indices));

  // first cube at pos x=-2.0 (with default size of 1x1x1)
  var Box := TShapeBox.Create;
  var Matrix: TMatrix4;
  Matrix.InitTranslation(-2, 0, 0);
  Box.Transform := Matrix;
  Buf := Buf.BuildCube(Box);

  // ...and append another cube at pos x=+1.0
  // NOTE the .Merge = true. This tells the shape builder method to not
  // advance the current shape start offset
  var Box := TShapeBox.Create;
  Box.Merge := True;
  Box.Transform.InitTranslation(1, 0, 0);
  Buf := Buf.BuildCube(Box);
  Assert(Buf.Valid);

  // skipping buffer- and pipeline-creation...

  var Elems := Buf.ElementRange;
  TGfx.Draw(Elems.BaseElements, Elems.NumElements);
```

To render the two cubes in separate draw-calls, the element-ranges used in the `TGfx.Draw` calls must be captured right after calling the builder methods:

```pascal
  var Vertices: array [0..127] of TShapeVertex;
  var Indices: array [0..15] of UInt16;
  var Buf := TShapeBuffer.Create(
    TRange.Create(Vertices),
    TRange.Create(Indices));

  // build a red cube...
  var Box := TShapeBox.Create;
  Box.Color := TAlphaColors.Red;
  Buf := Buf.BuildCube(Box);
  var RedCube := Buf.ElementRange;

  // append a green cube to the same vertex-/index-buffer:
  var Box := TShapeBox.Create;
  Box.Color := TAlphaColors.Green;
  Buf := Buf.BuildCube(Box);
  var GreenCube := Buf.ElementRange;

  // skipping buffer- and pipeline-creation...
  TGfx.Draw(RedCube.BaseElements, RedCube.NumElements);
  TGfx.Draw(GreenCube.BaseElements, GreenCube.NumElements);
```


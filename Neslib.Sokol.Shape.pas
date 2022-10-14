unit Neslib.Sokol.Shape;
{ Create simple primitive shapes for Neslib.Sokol.Gfx.

  For a user guide, check out the Neslib.Sokol.Shape.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.Shape.md }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  System.UITypes,
  System.SysUtils,
  Neslib.FastMath,
  Neslib.Sokol.Api,
  Neslib.Sokol.Gfx;

type
  { Vertex layout of the generated geometry }
  TShapeVertex = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sshape_vertex_t;
  {$ENDREGION 'Internal Declarations'}
  public
    { Position }
    property X: Single read FHandle.x;
    property Y: Single read FHandle.y;
    property Z: Single read FHandle.z;

    { Packed normal as Byte4N }
    property Normal: UInt32 read FHandle.normal;

    { Packed uv coords as UShort2N }
    property U: UInt16 read FHandle.u;
    property V: UInt16 read FHandle.v;

    { Packed color as UByte4N (r,g,b,a) }
    property Color: UInt32 read FHandle.color;
  end;
  PShapeVertex = ^TShapeVertex;

type
  { A range of draw-elements (for TGfx.Draw) }
  TShapeElementRange = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sshape_element_range_t;
  {$ENDREGION 'Internal Declarations'}
  public
    { Base element }
    property BaseElement: Integer read FHandle.base_element;

    { Number of elements }
    property NumElements: Integer read FHandle.num_elements;
  end;
  PShapeElementRange = ^TShapeElementRange;

type
  { Number of elements and byte size of build actions }
  TShapeSizesItem = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: _sshape_sizes_item_t;
    function GetCount: Integer; inline;
    function GetSize: Integer; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Number of elements }
    property Count: Integer read GetCount;

    { Total size in bytes }
    property Size: Integer read GetSize;
  end;
  PShapeSizesItem = ^TShapeSizesItem;

type
  { Sizes of vertex and index buffers }
  TShapeSizes = record
  public
    { Size of vertex buffer }
    Vertices: TShapeSizesItem;

    { Size of index buffer }
    Indices: TShapeSizesItem;
  end;
  PShapeSizes = ^TShapeSizes;

type
  { Creation parameters for a plane }
  TShapePlane = record
  public
    { Dimensions. Default 1.0. }
    Width: Single;
    Depth: Single;

    { Number of tiles. Default 1. }
    Tiles: Word;

    { Color. Default White. }
    Color: TAlphaColor;

    { Whether to use random colors. Default False. }
    RandomColors: Boolean;

    { Whether to merge with previous shape. Default False. }
    Merge: Boolean;

    { Transform matrix. Defaults to identity matrix. }
    Transform: TMatrix4;
  public
    class function Create(const AWidth: Single = 1; const ADepth: Single = 1;
      const ATiles: Word = 1; const AColor: TAlphaColor = $FFFFFFFF;
      const AMerge: Boolean = False): TShapePlane; static;
    procedure Init(const AWidth: Single = 1; const ADepth: Single = 1;
      const ATiles: Word = 1; const AColor: TAlphaColor = $FFFFFFFF;
      const AMerge: Boolean = False); inline;
  end;
  PShapePlane = ^TShapePlane;

type
  { Creation parameters for a cube/box }
  TShapeBox = record
  public
    { Dimensions. Default 1.0. }
    Width: Single;
    Height: Single;
    Depth: Single;

    { Number of tiles. Default 1. }
    Tiles: Word;

    { Color. Default White. }
    Color: TAlphaColor;

    { Whether to use random colors. Default False. }
    RandomColors: Boolean;

    { Whether to merge with previous shape. Default False. }
    Merge: Boolean;

    { Transform matrix. Defaults to identity matrix. }
    Transform: TMatrix4;
  public
    class function Create(const AWidth: Single = 1; const AHeight: Single = 1;
      const ADepth: Single = 1; const ATiles: Word = 1;
      const AColor: TAlphaColor = $FFFFFFFF; const AMerge: Boolean = False): TShapeBox; static;
    procedure Init(const AWidth: Single = 1; const AHeight: Single = 1;
      const ADepth: Single = 1; const ATiles: Word = 1;
      const AColor: TAlphaColor = $FFFFFFFF; const AMerge: Boolean = False); inline;
  end;
  PShapeBox = ^TShapeBox;

type
  { Creation parameters for a sphere (with poles, not geodesic) }
  TShapeSphere = record
  public
    { Radius. Default 0.5. }
    Radius: Single;

    { Number of slices. Default 5. }
    Slices: Word;

    { Number of stacks. Default 4. }
    Stacks: Word;

    { Color. Default White. }
    Color: TAlphaColor;

    { Whether to use random colors. Default False. }
    RandomColors: Boolean;

    { Whether to merge with previous shape. Default False. }
    Merge: Boolean;

    { Transform matrix. Defaults to identity matrix. }
    Transform: TMatrix4;
  public
    class function Create(const ARadius: Single = 0.5; const ASlices: Word = 5;
      const AStacks: Word = 4; const AColor: TAlphaColor = $FFFFFFFF;
      const AMerge: Boolean = False): TShapeSphere; static;
    procedure Init(const ARadius: Single = 0.5; const ASlices: Word = 5;
      const AStacks: Word = 4; const AColor: TAlphaColor = $FFFFFFFF;
      const AMerge: Boolean = False); inline;
  end;
  PShapeSphere = ^TShapeSphere;

type
  { Creation parameters for a cylinder }
  TShapeCylinder = record
  public
    { Radius. Default 0.5. }
    Radius: Single;

    { Height. Default 1.0. }
    Height: Single;

    { Number of slices. Default 5. }
    Slices: Word;

    { Number of stacks. Default 1. }
    Stacks: Word;

    { Color. Default White. }
    Color: TAlphaColor;

    { Whether to use random colors. Default False. }
    RandomColors: Boolean;

    { Whether to merge with previous shape. Default False. }
    Merge: Boolean;

    { Transform matrix. Defaults to identity matrix. }
    Transform: TMatrix4;
  public
    class function Create(const ARadius: Single = 0.5;
      const AHeight: Single = 1; const ASlices: Word = 5;
      const AStacks: Word = 1; const AColor: TAlphaColor = $FFFFFFFF;
      const AMerge: Boolean = False): TShapeCylinder; static;
    procedure Init(const ARadius: Single = 0.5;
      const AHeight: Single = 1; const ASlices: Word = 5;
      const AStacks: Word = 1; const AColor: TAlphaColor = $FFFFFFFF;
      const AMerge: Boolean = False); inline;
  end;
  PShapeCylinder = ^TShapeCylinder;

type
  { Creation parameters for a torus/donut }
  TShapeTorus = record
  public
    { Radius. Default 0.5. }
    Radius: Single;

    { Ring radius. Default 0.2. }
    RingRadius: Single;

    { Number of sides. Default 5. }
    Sides: Word;

    { Number of rings. Default 5. }
    Rings: Word;

    { Color. Default White. }
    Color: TAlphaColor;

    { Whether to use random colors. Default False. }
    RandomColors: Boolean;

    { Whether to merge with previous shape. Default False. }
    Merge: Boolean;

    { Transform matrix. Defaults to identity matrix. }
    Transform: TMatrix4;
  public
    class function Create(const ARadius: Single = 0.5;
      const ARingRadius: Single = 0.2; const ASides: Word = 5;
      const ARings: Word = 5; const AColor: TAlphaColor = $FFFFFFFF;
      const AMerge: Boolean = False): TShapeTorus; static;
    procedure Init(const ARadius: Single = 0.5;
      const ARingRadius: Single = 0.2; const ASides: Word = 5;
      const ARings: Word = 5; const AColor: TAlphaColor = $FFFFFFFF;
      const AMerge: Boolean = False); inline;
  end;
  PShapeTorus = ^TShapeTorus;

type
  { Mesh builder and buffer }
  TShapeBuffer = record
  {$REGION 'Internal Declarations'}
  private class var
    FHasDescs: Boolean;
    FBufferLayoutDesc: TBufferLayoutDesc;
    FPositionAttrDesc: TVertexAttrDesc;
    FNormalAttrDesc: TVertexAttrDesc;
    FTexCoordAttrDesc: TVertexAttrDesc;
    FColorAttrDesc: TVertexAttrDesc;
  private
    FHandle: _sshape_buffer_t;
    function GetElementRange: TShapeElementRange;
    function GetVertexBufferDesc: TBufferDesc; inline;
    function GetIndexBufferDesc: TBufferDesc; inline;
    class function GetBufferLayoutDesc: TBufferLayoutDesc; inline; static;
    class function GetColorAttrDesc: TVertexAttrDesc; inline; static;
    class function GetNormalAttrDesc: TVertexAttrDesc; inline; static;
    class function GetPositionAttrDesc: TVertexAttrDesc; inline; static;
    class function GetTexCoordAttrDesc: TVertexAttrDesc; inline; static;
  private
    class procedure ConvertBufferDesc(const ASrc: _sg_buffer_desc;
      out ADst: TBufferDesc); static;
    class procedure ConvertAttrDesc(const ASrc: _sg_vertex_attr_desc;
      out ADst: TVertexAttrDesc); static;
    class procedure GetDescs; static;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a shape buffer.

      Parameters:
        AVertices: vertex buffer data (an array of type TShapeVertex)
        AIndices: index buffer data (an array of type UInt16) }
    constructor Create(const AVertices, AIndices: TRange);
    procedure Init(const AVertices, AIndices: TRange); inline;

    { Shape builder methods }
    function Build(const AParams: TShapePlane): TShapeBuffer; overload; inline;
    function Build(const AParams: TShapeBox): TShapeBuffer; overload; inline;
    function Build(const AParams: TShapeSphere): TShapeBuffer; overload; inline;
    function Build(const AParams: TShapeCylinder): TShapeBuffer; overload; inline;
    function Build(const AParams: TShapeTorus): TShapeBuffer; overload; inline;

    { Query required vertex- and index-buffer sizes }
    class function PlaneSizes(const ATiles: Integer): TShapeSizes; inline; static;
    class function BoxSizes(const ATiles: Integer): TShapeSizes; inline; static;
    class function SphereSizes(const ASlices, AStacks: Integer): TShapeSizes; inline; static;
    class function CylinderSizes(const ASlices, AStacks: Integer): TShapeSizes; inline; static;
    class function TorusSizes(const ASides, ARings: Integer): TShapeSizes; inline; static;

    { Extract Neslib.Sokol.Gfx description records and primitive ranges }
    property ElementRange: TShapeElementRange read GetElementRange;
    property VertexBufferDesc: TBufferDesc read GetVertexBufferDesc;
    property IndexBufferDesc: TBufferDesc read GetIndexBufferDesc;
    class property BufferLayoutDesc: TBufferLayoutDesc read GetBufferLayoutDesc;
    class property PositionAttrDesc: TVertexAttrDesc read GetPositionAttrDesc;
    class property NormalAttrDesc: TVertexAttrDesc read GetNormalAttrDesc;
    class property TexCoordAttrDesc: TVertexAttrDesc read GetTexCoordAttrDesc;
    class property ColorAttrDesc: TVertexAttrDesc read GetColorAttrDesc;

    { Whether the buffer is valid }
    property Valid: Boolean read FHandle.valid;
  end;

implementation

{ The original _sshape_element_range API returns an 8-byte struct, which Delphi
  doesn't support. So we modifed the API to return an UInt64 instead, and unpack
  it ourselves. }
function __sshape_element_range(const buf: _Psshape_buffer_t): UInt64; cdecl;
  external _LIB_SOKOL name _PU + 'sshape_element_range';

{ TShapeSizesItem }

function TShapeSizesItem.GetCount: Integer;
begin
  Result := FHandle.num;
end;

function TShapeSizesItem.GetSize: Integer;
begin
  Result := FHandle.size;
end;

{ TShapePlane }

class function TShapePlane.Create(const AWidth, ADepth: Single;
  const ATiles: Word; const AColor: TAlphaColor;
  const AMerge: Boolean): TShapePlane;
begin
  Result.Init(AWidth, ADepth, ATiles, AColor, AMerge);
end;

procedure TShapePlane.Init(const AWidth, ADepth: Single; const ATiles: Word;
  const AColor: TAlphaColor; const AMerge: Boolean);
begin
  Width := AWidth;
  Depth := ADepth;
  Tiles := ATiles;
  Color := AColor;
  RandomColors := False;
  Merge := AMerge;
  Transform.Init;
end;

{ TShapeBox }

class function TShapeBox.Create(const AWidth, AHeight, ADepth: Single;
  const ATiles: Word; const AColor: TAlphaColor;
  const AMerge: Boolean): TShapeBox;
begin
  Result.Init(AWidth, AHeight, ADepth, ATiles, AColor, AMerge);
end;

procedure TShapeBox.Init(const AWidth, AHeight, ADepth: Single;
  const ATiles: Word; const AColor: TAlphaColor; const AMerge: Boolean);
begin
  Width := AWidth;
  Height := AHeight;
  Depth := ADepth;
  Tiles := ATiles;
  Color := AColor;
  RandomColors := False;
  Merge := AMerge;
  Transform.Init;
end;

{ TShapeSphere }

class function TShapeSphere.Create(const ARadius: Single; const ASlices,
  AStacks: Word; const AColor: TAlphaColor;
  const AMerge: Boolean): TShapeSphere;
begin
  Result.Init(ARadius, ASlices, AStacks, AColor, AMerge);
end;

procedure TShapeSphere.Init(const ARadius: Single; const ASlices, AStacks: Word;
  const AColor: TAlphaColor; const AMerge: Boolean);
begin
  Radius := ARadius;
  Slices := ASlices;
  Stacks := AStacks;
  Color := AColor;
  RandomColors := False;
  Merge := AMerge;
  Transform.Init;
end;

{ TShapeCylinder }

class function TShapeCylinder.Create(const ARadius, AHeight: Single;
  const ASlices, AStacks: Word; const AColor: TAlphaColor;
  const AMerge: Boolean): TShapeCylinder;
begin
  Result.Init(ARadius, AHeight, ASlices, AStacks, AColor, AMerge);
end;

procedure TShapeCylinder.Init(const ARadius, AHeight: Single; const ASlices,
  AStacks: Word; const AColor: TAlphaColor; const AMerge: Boolean);
begin
  Radius := ARadius;
  Height := AHeight;
  Slices := ASlices;
  Stacks := AStacks;
  Color := AColor;
  RandomColors := False;
  Merge := AMerge;
  Transform.Init;
end;

{ TShapeTorus }

class function TShapeTorus.Create(const ARadius, ARingRadius: Single;
  const ASides, ARings: Word; const AColor: TAlphaColor;
  const AMerge: Boolean): TShapeTorus;
begin
  Result.Init(ARadius, ARingRadius, ASides, ARings, AColor, AMerge);
end;

procedure TShapeTorus.Init(const ARadius, ARingRadius: Single; const ASides,
  ARings: Word; const AColor: TAlphaColor; const AMerge: Boolean);
begin
  Radius := ARadius;
  RingRadius := ARingRadius;
  Sides := ASides;
  Rings := ARings;
  Color := AColor;
  RandomColors := False;
  Merge := AMerge;
  Transform.Init;
end;

{ TShapeBuffer }

class function TShapeBuffer.BoxSizes(const ATiles: Integer): TShapeSizes;
begin
  Result := TShapeSizes(_sshape_box_sizes(ATiles));
end;

function TShapeBuffer.Build(const AParams: TShapeBox): TShapeBuffer;
begin
  Result.FHandle := _sshape_build_box(@FHandle, @AParams);
end;

function TShapeBuffer.Build(
  const AParams: TShapeCylinder): TShapeBuffer;
begin
  Result.FHandle := _sshape_build_cylinder(@FHandle, @AParams);
end;

function TShapeBuffer.Build(const AParams: TShapePlane): TShapeBuffer;
begin
  Result.FHandle := _sshape_build_plane(@FHandle, @AParams);
end;

function TShapeBuffer.Build(const AParams: TShapeSphere): TShapeBuffer;
begin
  Result.FHandle := _sshape_build_sphere(@FHandle, @AParams);
end;

function TShapeBuffer.Build(const AParams: TShapeTorus): TShapeBuffer;
begin
  Result.FHandle := _sshape_build_torus(@FHandle, @AParams);
end;

class procedure TShapeBuffer.ConvertAttrDesc(const ASrc: _sg_vertex_attr_desc;
  out ADst: TVertexAttrDesc);
begin
  ADst.BufferIndex := ASrc.buffer_index;
  ADst.Offset := ASrc.offset;
  ADst.Format := TVertexFormat(ASrc.format);
end;

class procedure TShapeBuffer.ConvertBufferDesc(const ASrc: _sg_buffer_desc;
  out ADst: TBufferDesc);
begin
  ADst.Size := ASrc.size;
  ADst.BufferType := TBufferType(ASrc.&type);
  ADst.Usage := TUsage(ASrc.usage);
  ADst.Data := TRange.Create(ASrc.data.ptr, ASrc.data.size);
  if (ASrc.&label = nil) then
    ADst.TraceLabel := ''
  else
    ADst.TraceLabel := String(UTF8String(ASrc.&label));
  Move(ASrc.gl_buffers, ADst.GLBuffers, SizeOf(ADst.GLBuffers));
  Move(ASrc.mtl_buffers, ADst.MetalBuffers, SizeOf(ADst.MetalBuffers));
  ADst.D3D11Buffer := IInterface(ASrc.d3d11_buffer);
end;

constructor TShapeBuffer.Create(const AVertices, AIndices: TRange);
begin
  Init(AVertices, AIndices);
end;

class function TShapeBuffer.CylinderSizes(const ASlices, AStacks: Integer): TShapeSizes;
begin
  Result := TShapeSizes(_sshape_cylinder_sizes(ASlices, AStacks));
end;

class function TShapeBuffer.GetBufferLayoutDesc: TBufferLayoutDesc;
begin
  if (not FHasDescs) then
    GetDescs;
  Result := FBufferLayoutDesc;
end;

class function TShapeBuffer.GetColorAttrDesc: TVertexAttrDesc;
begin
  if (not FHasDescs) then
    GetDescs;
  Result := FColorAttrDesc;
end;

class procedure TShapeBuffer.GetDescs;
begin
  var Desc := _sshape_buffer_layout_desc;
  FBufferLayoutDesc.Stride := Desc.stride;
  FBufferLayoutDesc.StepFunc := TVertexStep(Desc.step_func);
  FBufferLayoutDesc.StepRate := Desc.step_rate;

  TShapeBuffer.ConvertAttrDesc(_sshape_position_attr_desc, FPositionAttrDesc);
  TShapeBuffer.ConvertAttrDesc(_sshape_normal_attr_desc, FNormalAttrDesc);
  TShapeBuffer.ConvertAttrDesc(_sshape_texcoord_attr_desc, FTexCoordAttrDesc);
  TShapeBuffer.ConvertAttrDesc(_sshape_color_attr_desc, FColorAttrDesc);

  FHasDescs := True;
end;

function TShapeBuffer.GetElementRange: TShapeElementRange;
begin
  {$IFDEF ANDROID32}
  Result.FHandle := _sshape_element_range(@FHandle);
  {$ELSE}
  var Res := __sshape_element_range(@FHandle);
  Result.FHandle.base_element := Integer(Res);
  Result.FHandle.num_elements := Integer(Res shr 32);
  {$ENDIF}
end;

function TShapeBuffer.GetIndexBufferDesc: TBufferDesc;
begin
  ConvertBufferDesc(_sshape_index_buffer_desc(@FHandle), Result);
end;

class function TShapeBuffer.GetNormalAttrDesc: TVertexAttrDesc;
begin
  if (not FHasDescs) then
    GetDescs;
  Result := FNormalAttrDesc;
end;

class function TShapeBuffer.GetPositionAttrDesc: TVertexAttrDesc;
begin
  if (not FHasDescs) then
    GetDescs;
  Result := FPositionAttrDesc;
end;

class function TShapeBuffer.GetTexCoordAttrDesc: TVertexAttrDesc;
begin
  if (not FHasDescs) then
    GetDescs;
  Result := FTexCoordAttrDesc;
end;

function TShapeBuffer.GetVertexBufferDesc: TBufferDesc;
begin
  ConvertBufferDesc(_sshape_vertex_buffer_desc(@FHandle), Result);
end;

procedure TShapeBuffer.Init(const AVertices, AIndices: TRange);
begin
  FillChar(FHandle, SizeOf(FHandle), 0);
  FHandle.vertices.buffer.ptr := AVertices.Data;
  FHandle.vertices.buffer.size := AVertices.Size;
  FHandle.indices.buffer.ptr := AIndices.Data;
  FHandle.indices.buffer.size := AIndices.Size;
end;

class function TShapeBuffer.PlaneSizes(const ATiles: Integer): TShapeSizes;
begin
  Result := TShapeSizes(_sshape_plane_sizes(ATiles));
end;

class function TShapeBuffer.SphereSizes(const ASlices, AStacks: Integer): TShapeSizes;
begin
  Result := TShapeSizes(_sshape_sphere_sizes(ASlices, AStacks));
end;

class function TShapeBuffer.TorusSizes(const ASides, ARings: Integer): TShapeSizes;
begin
  Result := TShapeSizes(_sshape_torus_sizes(ASides, ARings));
end;

initialization
  Assert(SizeOf(TShapeSizes) = SizeOf(_sshape_sizes_t));
  Assert(SizeOf(TShapePlane) = SizeOf(_sshape_plane_t));
  Assert(SizeOf(TShapeBox) = SizeOf(_sshape_box_t));
  Assert(SizeOf(TShapeSphere) = SizeOf(_sshape_sphere_t));
  Assert(SizeOf(TShapeCylinder) = SizeOf(_sshape_cylinder_t));
  Assert(SizeOf(TShapeTorus) = SizeOf(_sshape_torus_t));

end.

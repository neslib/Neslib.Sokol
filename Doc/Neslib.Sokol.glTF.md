# Neslib.Sokol.glTF

glTF 2.0 parser.

This is a light-weight OOP layer on top of [cgltf](https://github.com/jkuhlmann/cgltf).

## Reference

The main entry point is the static `TglTF` record.

### TglTF.Parse

```pascal
class function TglTF.Parse(const AOptions: TglTFOptions;
  const ABuffer: TBytes; out AData: PglTFData): TglTFResult; overload; static;
  
class function TglTF.Parse(const AOptions: TglTFOptions; const ABuffer: Pointer;
  const ASize: Integer; out AData: PglTFData): TglTFResult; overload; static;
```

Parses both glTF and GLB data. If this function returns `TglTFResult.Success`, you have to call `AData.Free` when you are done with the data.

Note that contents of external files for buffers and images are not automatically loaded. You'll need to read these files yourself using URIs in the `TglTFData` record.

### TglTFOptions

`TglTFOptions` is the record passed to `TglTF.Parse` to control parts of the parsing process. You can use it to force the file type and specify a memory manager. Should be zero-initialized to trigger default behavior:

```pascal
var Options := TglTFOptions.Create;
```

### TglTFData

`TglTFData` is the record allocated and filled by `TglTF.Parse`. It generally mirrors the glTF format as described by the [glTF specification](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0).

```pascal
procedure TglTFData.Free; 
function TglTFData.Validate: TglTFResult; 
function TglTFData.GetExtrasAsJson(const AExtras: TglTFExtras): String;
```

`TglTFData.Free` frees the allocated data.

`TglTFData.Validate` can be used to do additional checks to make sure the parsed glTF data is valid.

`TglTFData.GetExtrasAsJson` allows to retrieve the "extras" data that can be attached to many glTF objects (which can be arbitrary JSON data). The `TglTFExtras` record stores the offsets of the start and end of the extras JSON data as it appears in the complete glTF JSON data. You can then parse this data using your own JSON parser (plug: try [Neslib.Json](https://github.com/neslib/Neslib.Json)).

### TglTF.LoadBuffers

```pascal
class function TglTF.LoadBuffers(const AOptions: TglTFOptions;
  const AData: TglTFData; const APath: String): TglTFResult; static;
```

Can be optionally called to open and read buffer files. The `APath` argument is the path to the original glTF file, which allows the parser to resolve the path to buffer files.

### TglTFNode

```pascal
function TglTFNode.TransformLocal: TMatrix4;
function TglTFNode.TransformWorld: TMatrix4;
```

`TglTFNode.TransformLocal` converts the translation / rotation / scale properties of the node into a `TMatrix4`.

`TglTFNode.TransformWorld` calls `TglTFNode.TransformLocal` on every ancestor in order to compute the root-to-node transformation.

### TglTFAccessor

```pascal
function TglTFAccessor.ReadFloat(const AIndex: NativeInt; out AValue: Single;
  const AElementSize: NativeInt): Boolean;
function TglTFAccessor.ReadIndex(const AIndex: NativeInt): NativeInt;
```

`TglTFAccessor.ReadFloat` reads a certain element from an accessor and converts it to floating point, assuming that `TglTF.LoadBuffers` has already been called. The passed-in element size is the number of floats in the output buffer, which should be in the range [1, 16]. Returns `False` if the passed-in element size is too small, or if the accessor is sparse.

`TglTFAccessor.ReadIndex` is similar to its floating-point counterpart, but it returns a `NativeInt` and only works with single-component data types.
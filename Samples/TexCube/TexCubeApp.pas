unit TexCubeApp;
{ Texture creation, rendering with texture, packed vertex components. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  TexCubeShader;

type
  TTexCubeApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
    FShader: TShader;
    FPip: TPipeline;
    FBind: TBindings;
    FRX: Single;
    FRY: Single;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api;

type
  TVertex = record
    X, Y, Z: Single;
    Color: UInt32;
    U, V: Int16;
  end;

const
  { Cube vertex buffer with packed vertex formats for color and texture coords.
    Note that a vertex format which must be portable across all backends must
    only use the normalized integer formats, which can be converted to floating
    point formats in the vertex shader inputs.

    The reason is that D3D11 cannot convert from non-normalized formats to
    floating point inputs (only to integer inputs), and GLES2 doesn't support
    integer vertex shader inputs. }
  VERTICES: array [0..23] of TVertex = (
    (X: -1.0; Y: -1.0; Z: -1.0; Color: $FF0000FF; U:     0; V:     0),
    (X:  1.0; Y: -1.0; Z: -1.0; Color: $FF0000FF; U: 32767; V:     0),
    (X:  1.0; Y:  1.0; Z: -1.0; Color: $FF0000FF; U: 32767; V: 32767),
    (X: -1.0; Y:  1.0; Z: -1.0; Color: $FF0000FF; U:     0; V: 32767),

    (X: -1.0; Y: -1.0; Z:  1.0; Color: $FF00FF00; U:     0; V:     0),
    (X:  1.0; Y: -1.0; Z:  1.0; Color: $FF00FF00; U: 32767; V:     0),
    (X:  1.0; Y:  1.0; Z:  1.0; Color: $FF00FF00; U: 32767; V: 32767),
    (X: -1.0; Y:  1.0; Z:  1.0; Color: $FF00FF00; U:     0; V: 32767),

    (X: -1.0; Y: -1.0; Z: -1.0; Color: $FFFF0000; U:     0; V:     0),
    (X: -1.0; Y:  1.0; Z: -1.0; Color: $FFFF0000; U: 32767; V:     0),
    (X: -1.0; Y:  1.0; Z:  1.0; Color: $FFFF0000; U: 32767; V: 32767),
    (X: -1.0; Y: -1.0; Z:  1.0; Color: $FFFF0000; U:     0; V: 32767),

    (X:  1.0; Y: -1.0; Z: -1.0; Color: $FFFF007F; U:     0; V:     0),
    (X:  1.0; Y:  1.0; Z: -1.0; Color: $FFFF007F; U: 32767; V:     0),
    (X:  1.0; Y:  1.0; Z:  1.0; Color: $FFFF007F; U: 32767; V: 32767),
    (X:  1.0; Y: -1.0; Z:  1.0; Color: $FFFF007F; U:     0; V: 32767),

    (X: -1.0; Y: -1.0; Z: -1.0; Color: $FFFF7F00; U:     0; V:     0),
    (X: -1.0; Y: -1.0; Z:  1.0; Color: $FFFF7F00; U: 32767; V:     0),
    (X:  1.0; Y: -1.0; Z:  1.0; Color: $FFFF7F00; U: 32767; V: 32767),
    (X:  1.0; Y: -1.0; Z: -1.0; Color: $FFFF7F00; U:     0; V: 32767),

    (X: -1.0; Y:  1.0; Z: -1.0; Color: $FF007FFF; U:     0; V:     0),
    (X: -1.0; Y:  1.0; Z:  1.0; Color: $FF007FFF; U: 32767; V:     0),
    (X:  1.0; Y:  1.0; Z:  1.0; Color: $FF007FFF; U: 32767; V: 32767),
    (X:  1.0; Y:  1.0; Z: -1.0; Color: $FF007FFF; U:     0; V: 32767));

const
  { Index buffer for the cube }
  INDICES: array [0..35] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20);

const
  { Create a checkerboard texture }
  PIXELS: array [0..4 * 4 - 1] of UInt32 = (
    $FFFFFFFF, $FF000000, $FFFFFFFF, $FF000000,
    $FF000000, $FFFFFFFF, $FF000000, $FFFFFFFF,
    $FFFFFFFF, $FF000000, $FFFFFFFF, $FF000000,
    $FF000000, $FFFFFFFF, $FF000000, $FFFFFFFF);

{ TTexCubeApp }

procedure TTexCubeApp.Cleanup;
begin
  FPip.Free;
  FShader.Free;
  FBind.FragmentShaderImages[SLOT_TEX].Free;
  FBind.IndexBuffer.Free;
  FBind.VertexBuffers[0].Free;
  inherited;
end;

procedure TTexCubeApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Textured Cube';
end;

procedure TTexCubeApp.Frame;
begin
  { Compute model-view-projection matrix for vertex shader }
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var T: Single := FrameDuration * 60;

  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), H / W, 0.01, 10.0, True);
  View.InitLookAtRH(Vector3(0, 1.5, 6), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  FRX := FRX + (1 * T);
  FRY := FRY + (2 * T);
  var RXM, RYM: TMatrix4;
  RXM.InitRotationX(Radians(FRX));
  RYM.InitRotationY(Radians(FRY));
  var Model := RXM * RYM;
  var VSParams: TVSParams;
  VSParams.MVP := ViewProj * Model;

  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyBindings(FBind);
  TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(0, 36, 1);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TTexCubeApp.Init;
begin
  inherited;
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'CubeVertices';
  FBind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.BufferType := TBufferType.IndexBuffer;
  BufferDesc.Data := TRange.Create(INDICES);
  BufferDesc.TraceLabel := 'CubeIndices';
  FBind.IndexBuffer := TBuffer.Create(BufferDesc);

  { NOTE: SLOT_TEX is provided by shader code generation }
  var ImageDesc := TImageDesc.Create;
  ImageDesc.Width := 4;
  ImageDesc.Height := 4;
  ImageDesc.Data.SubImages[0] := TRange.Create(PIXELS);
  ImageDesc.TraceLabel := 'CubeTexture';
  FBind.FragmentShaderImages[SLOT_TEX] := TImage.Create(ImageDesc);

  FShader := TShader.Create(TexCubeShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Attrs[ATTR_VS_POS].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_VS_COLOR0].Format := TVertexFormat.UByte4N;
  PipDesc.Layout.Attrs[ATTR_VS_TEXCOORD0].Format := TVertexFormat.Short2N;
  PipDesc.Shader := FShader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PiPDesc.TraceLabel := 'CubePipeline';

  FPip := TPipeline.Create(PipDesc);

  FPassAction.Colors[0].Init(TAction.Clear, 0.25, 0.5, 0.75, 1);
end;

end.

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
  private
    function ComputeVSParams: TVSParams;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue;

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

procedure TTexCubeApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Textured Cube';
end;

procedure TTexCubeApp.Init;
begin
  inherited;
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'TexCubeVertices';
  FBind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.Usage.IndexBuffer := True;
  BufferDesc.Data := TRange.Create(INDICES);
  BufferDesc.TraceLabel := 'TexCubeIndices';
  FBind.IndexBuffer := TBuffer.Create(BufferDesc);

  { Create a checkerboard texture and view }
  var ImageDesc := TImageDesc.Create;
  ImageDesc.Width := 4;
  ImageDesc.Height := 4;
  ImageDesc.Data.MipLevels[0] := TRange.Create(PIXELS);
  ImageDesc.TraceLabel := 'TexCubeImage';
  var Image := TImage.Create(ImageDesc);

  var ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := Image;
  ViewDesc.TraceLabel := 'TexCubeTextureView';
  FBind.Views[VIEW_TEX] := TView.Create(ViewDesc);

  { Create a sampler object with default attributes }
  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.TraceLabel := 'TexCubeSampler';
  FBind.Samplers[SMP_SMP] := TSampler.Create(SamplerDesc);

  FShader := TShader.Create(TexCubeShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Attrs[ATTR_TEXCUBE_POS].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_TEXCUBE_COLOR0].Format := TVertexFormat.UByte4N;
  PipDesc.Layout.Attrs[ATTR_TEXCUBE_TEXCOORD0].Format := TVertexFormat.Short2N;
  PipDesc.Shader := FShader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PiPDesc.TraceLabel := 'TexCubePipeline';

  FPip := TPipeline.Create(PipDesc);

  FPassAction.Colors[0].Init(TLoadAction.Clear, 0.25, 0.5, 0.75, 1);
end;

procedure TTexCubeApp.Frame;
begin
  var T: Single := FrameDuration * 60;
  FRX := FRX + (1 * T);
  FRY := FRY + (2 * T);
  var VSParams := ComputeVSParams;

  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyBindings(FBind);
  TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(0, 36, 1);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TTexCubeApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

function TTexCubeApp.ComputeVSParams: TVSParams;
begin
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), W / H, 0.01, 10.0);
  View.InitLookAtRH(Vector3(0, 1.5, 4), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  var RXM, RYM: TMatrix4;
  RXM.InitRotationX(Radians(FRX));
  RYM.InitRotationY(Radians(FRY));
  var Model := RXM * RYM;
  Result.MVP := ViewProj * Model;
end;

end.

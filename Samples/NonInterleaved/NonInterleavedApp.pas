unit NonInterleavedApp;
{ How to use non-interleaved vertex data (vertex components in separate
  non-interleaved chunks in the same vertex buffers). Note that only 4 separate
  chunks are currently possible because there are 4 vertex buffer bind slots in
  TBindings, but you can keep several related vertex components interleaved in
  the same chunk. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  NonInterleavedShader;

type
  TNonInterleavedApp = class(TSampleApp)
  private
    FShader: TShader;
    FPip: TPipeline;
    FBind: TBindings;
    FPassAction: TPassAction;
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

const
  { Cube vertex buffer }
  VERTICES: array [0..167] of Single = (
    { Positions }
    -1.0, -1.0, -1.0,   1.0, -1.0, -1.0,   1.0,  1.0, -1.0,  -1.0,  1.0, -1.0,
    -1.0, -1.0,  1.0,   1.0, -1.0,  1.0,   1.0,  1.0,  1.0,  -1.0,  1.0,  1.0,
    -1.0, -1.0, -1.0,  -1.0,  1.0, -1.0,  -1.0,  1.0,  1.0,  -1.0, -1.0,  1.0,
     1.0, -1.0, -1.0,   1.0,  1.0, -1.0,   1.0,  1.0,  1.0,   1.0, -1.0,  1.0,
    -1.0, -1.0, -1.0,  -1.0, -1.0,  1.0,   1.0, -1.0,  1.0,   1.0, -1.0, -1.0,
    -1.0,  1.0, -1.0,  -1.0,  1.0,  1.0,   1.0,  1.0,  1.0,   1.0,  1.0, -1.0,

    { Colors }
     1.0, 0.5, 0.0, 1.0,  1.0, 0.5, 0.0, 1.0,  1.0, 0.5, 0.0, 1.0,  1.0, 0.5, 0.0, 1.0,
     0.5, 1.0, 0.0, 1.0,  0.5, 1.0, 0.0, 1.0,  0.5, 1.0, 0.0, 1.0,  0.5, 1.0, 0.0, 1.0,
     0.5, 0.0, 1.0, 1.0,  0.5, 0.0, 1.0, 1.0,  0.5, 0.0, 1.0, 1.0,  0.5, 0.0, 1.0, 1.0,
     1.0, 0.5, 1.0, 1.0,  1.0, 0.5, 1.0, 1.0,  1.0, 0.5, 1.0, 1.0,  1.0, 0.5, 1.0, 1.0,
     0.5, 1.0, 1.0, 1.0,  0.5, 1.0, 1.0, 1.0,  0.5, 1.0, 1.0, 1.0,  0.5, 1.0, 1.0, 1.0,
     1.0, 1.0, 0.5, 1.0,  1.0, 1.0, 0.5, 1.0,  1.0, 1.0, 0.5, 1.0,  1.0, 1.0, 0.5, 1.0);

const
  { Index buffer for the cube }
  INDICES: array [0..35] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20);

{ TNonInterleavedApp }

procedure TNonInterleavedApp.Cleanup;
begin
  FPip.Free;
  FShader.Free;
  FBind.IndexBuffer.Free;
  FBind.VertexBuffers[0].Free;
  inherited;
end;

procedure TNonInterleavedApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Non-interleaved';
end;

procedure TNonInterleavedApp.Frame;
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

procedure TNonInterleavedApp.Init;
begin
  inherited;
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  FBind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.BufferType := TBufferType.IndexBuffer;
  BufferDesc.Data := TRange.Create(INDICES);
  FBind.IndexBuffer := TBuffer.Create(BufferDesc);

  FShader := TShader.Create(NonInterleavedShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := FShader;

  { Note how the vertex components are pulled from different buffer bind slots.
    Positions come from vertex buffer slot 0 }
  PipDesc.Layout.Attrs[ATTR_VS_POSITION].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_VS_POSITION].BufferIndex := 0;

  { Colors come from vertex buffer slot 1 }
  PipDesc.Layout.Attrs[ATTR_VS_COLOR0].Format := TVertexFormat.Float4;
  PipDesc.Layout.Attrs[ATTR_VS_COLOR0].BufferIndex := 1;

  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.Less;

  FPip := TPipeline.Create(PipDesc);

  { Fill the resource bindings. Note how the same vertex buffer is bound to the
    first two slots, and the vertex-buffer-offsets are used to point to the
    position- and color-components. }
  FBind.VertexBuffers[1] := FBind.VertexBuffers[0];

  { Position components are at start of buffer }
  FBind.VertexBufferOffsets[0] := 0;

  { Byte offset of color components in buffer }
  FBind.VertexBufferOffsets[1] := 24 * 3 * SizeOf(Single);
end;

end.

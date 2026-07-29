unit UVWrapApp;
{ Demonstrates and tests texture coordinate wrapping modes. }

interface

uses
  System.UITypes,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  UVWrapShader;

type
  TUVWrapApp = class(TSampleApp)
  private
    FVBuf: TBuffer;
    FTexView: TView;
    FSmp: array [TWrap] of TSampler;
    FPip: TPipeline;
    FPassAction: TPassAction;
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

const
  VERTICES: array [0..7] of Single = (
    -1.0,  1.0,
     1.0,  1.0,
    -1.0, -1.0,
     1.0, -1.0);

{ TUVWrapApp }

procedure TUVWrapApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.DepthFormat := TAppPixelFormat.None;
  AConfig.WindowTitle := 'UV Wrap Modes';
end;

procedure TUVWrapApp.Init;
const
  o = $FF555555;
  W = $FFFFFFFF;
  R = $FF0000FF;
  G = $FF00FF00;
  B = $FFFF0000;
const
  TEST_PIXELS: array [0..7, 0..7] of UInt32 = (
    (R, R, R, R, G, G, G, G),
    (R, o, o, o, o, o, o, G),
    (R, o, o, o, o, o, o, G),
    (R, o, o, W, W, o, o, G),
    (B, o, o, W, W, o, o, R),
    (B, o, o, o, o, o, o, R),
    (B, o, o, o, o, o, o, R),
    (B, B, B, B, R, R, R, R));
begin
  inherited;
  { A quad vertex buffer }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  FVBuf := TBuffer.Create(BufferDesc);

  var ImgDesc := TImageDesc.Create;
  ImgDesc.Width := 8;
  ImgDesc.Height := 8;
  ImgDesc.Data.MipLevels[0] := TRange.Create(TEST_PIXELS);
  var Img := TImage.Create(ImgDesc);

  var ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := Img;
  FTexView := TView.Create(ViewDesc);

  { One sampler per uv wrap mode }
  for var I := Low(TWrap) to High(TWrap) do
  begin
    var SamplerDesc := TSamplerDesc.Create;
    SamplerDesc.WrapU := I;
    SamplerDesc.WrapV := I;
    SamplerDesc.BorderColor := TBorderColor.OpaqueBlack;
    FSmp[I] := TSampler.Create(SamplerDesc);
  end;

  { A pipeline state object }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(UvwrapShaderDesc);
  PipDesc.Layout.Attrs[ATTR_UVWRAP_POS].Format := TVertexFormat.Float2;
  PipDesc.PrimitiveType := TPrimitiveType.TriangleStrip;
  FPip := TPipeline.Create(PipDesc);

  { Pass action to clear to a background color }
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0, 0.5, 0.7, 1);
end;

procedure TUVWrapApp.Frame;
begin
  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);
  TGfx.ApplyPipeline(FPip);

  var Bind := TBindings.Create;
  Bind.VertexBuffers[0] := FVBuf;
  Bind.Views[VIEW_TEX] := FTexView;
  for var I := Low(TWrap) to High(TWrap) do
  begin
    Bind.Samplers[SMP_SMP] := FSmp[I];
    TGfx.ApplyBindings(Bind);

    var XOffset: Single := 0;
    var YOffset: Single := 0;
    case I of
      TWrap.Repeating:
        begin
          XOffset := -0.5;
          YOffset :=  0.5;
        end;

      TWrap.ClampToEdge:
        begin
          XOffset :=  0.5;
          YOffset :=  0.5;
        end;

      TWrap.ClampToBorder:
        begin
          XOffset := -0.5;
          YOffset := -0.5;
        end;

      TWrap.MirroredRepeat:
        begin
          XOffset :=  0.5;
          YOffset := -0.5;
        end;
    end;

    var VSParams: TVSParams;
    VSParams.Offset.Init(XOffset, YOffset);
    VSParams.Scale.Init(0.4, 0.4);
    TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(VSParams));
    TGfx.Draw(0, 4, 1);
  end;

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TUVWrapApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

end.

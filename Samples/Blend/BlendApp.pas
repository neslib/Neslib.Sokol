unit BlendApp;
{ Test/demonstrate blend modes. }

interface

uses
  System.UITypes,
  Neslib.FastMath,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  SampleApp,
  BlendShader;

type
  TBlendApp = class(TSampleApp)
  private const
    NUM_BLEND_FACTORS = 15;
  private
    FPassAction: TPassAction;
    FBGShader: TShader;
    FQuadShader: TShader;
    FBGFSParams: TBGFSParams;
    FQuadVSParams: TQuadVSParams;
    FPips: array [0..NUM_BLEND_FACTORS - 1, 0..NUM_BLEND_FACTORS - 1] of TPipeline;
    FBGPip: TPipeline;
    FBind: TBindings;
    FR: Single;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  protected
    procedure ConfigureGfx(var ADesc: TGfxDesc); override;
  end;

implementation

uses
  Neslib.Sokol.Api;

const
  { A quad vertex buffer }
  VERTICES: array [0..27] of Single = (
  { Positions         Colors }
    -1.0, -1.0, 0.0,  1.0, 0.0, 0.0, 0.5,
    +1.0, -1.0, 0.0,  0.0, 1.0, 0.0, 0.5,
    -1.0, +1.0, 0.0,  0.0, 0.0, 1.0, 0.5,
    +1.0, +1.0, 0.0,  1.0, 1.0, 0.0, 0.5);

{ TBlendApp }

procedure TBlendApp.Cleanup;
begin
  for var Src := 0 to NUM_BLEND_FACTORS - 1 do
    for var Dst := 0 to NUM_BLEND_FACTORS - 1 do
      FPips[Src, Dst].Free;
  FBGPip.Free;
  FBGShader.Free;
  FQuadShader.Free;
  FBind.VertexBuffers[0].Free;
  inherited;
end;

procedure TBlendApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'Blend Modes';
end;

procedure TBlendApp.ConfigureGfx(var ADesc: TGfxDesc);
begin
  inherited;
  ADesc.PipelinePoolSize := NUM_BLEND_FACTORS * NUM_BLEND_FACTORS + 1;
end;

procedure TBlendApp.Frame;
begin
  { view-projection matrix }
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var Proj, View, RM, Translate, Model: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(90), H / W, 0.01, 100.0, True);
  View.InitLookAtRH(Vector3(0, 0, 25), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  { Start rendering }
  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);

  { Draw a background quad }
  TGfx.ApplyPipeline(FBGPip);
  TGfx.ApplyBindings(FBind);
  TGfx.ApplyUniforms(TShaderStage.FragmentShader, SLOT_BG_FS_PARAMS,
    TRange.Create(FBGFSParams));
  TGfx.Draw(0, 4);

  { Draw the blended quads }
  var R0 := FR;
  for var Src := 0 to NUM_BLEND_FACTORS - 1 do
  begin
    for var Dst := 0 to NUM_BLEND_FACTORS - 1 do
    begin
      if (FPips[Src, Dst].Id <> INVALID_ID) then
      begin
        { Compute new model-view-proj matrix }
        RM.InitRotationY(Radians(R0));
        var X: Single := (Dst - (NUM_BLEND_FACTORS div 2)) * 3.0;
        var Y: Single := (Src - (NUM_BLEND_FACTORS div 2)) * 2.2;
        Translate.InitTranslation(X, Y, 0);
        Model := Translate * RM;
        FQuadVSParams.MVP := ViewProj * Model;

        TGfx.ApplyPipeline(FPips[Src, Dst]);
        TGfx.ApplyBindings(FBind);
        TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_QUAD_VS_PARAMS,
          TRange.Create(FQuadVSParams));
        TGfx.Draw(0, 4);
      end;
      R0 := R0 + 0.6;
    end;
  end;

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;

  var T: Single := FrameDuration * 60;
  FR := FR + (0.6 * T);
  FBGFSParams.Tick := FBGFSParams.Tick + T;
end;

procedure TBlendApp.Init;
begin
  inherited;
  { A default pass action which does not clear, since the entire screen is
    overwritten anyway. }
  FPassAction.Colors[0].Action := TAction.DontCare;
  FPassAction.Depth.Action := TAction.DontCare;
  FPassAction.Stencil.Action := TAction.DontCare;

  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  FBind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  { A shader for the fullscreen background quad }
  FBGShader := TShader.Create(BGShaderDesc);

  { A pipeline state object for rendering the background quad }
  var PipDesc := TPipelineDesc.Create;

  { We use the same vertex buffer as for the colored 3D quads, but only the
    first two floats from the position, need to provide a stride to skip the gap
    to the next vertex. }
  PipDesc.Layout.Buffers[0].Stride := 28;
  PipDesc.Layout.Attrs[ATTR_VS_BG_POSITION].Format := TVertexFormat.Float2;
  PipDesc.Shader := FBGShader;
  PipDesc.PrimitiveType := TPrimitiveType.TriangleStrip;
  FBGPip := TPipeline.Create(PipDesc);

  { A shader for the blended quads }
  FQuadShader := TShader.Create(QuadShaderDesc);

  { One pipeline object per blend-factor combination }
  PipDesc.Init;
  PipDesc.Layout.Attrs[ATTR_VS_QUAD_POSITION].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_VS_QUAD_COLOR0].Format := TVertexFormat.Float4;
  PipDesc.Shader := FQuadShader;
  PipDesc.PrimitiveType := TPrimitiveType.TriangleStrip;
  PipDesc.BlendColor := TColor.Create(1, 0, 0, 1);

  for var Src := 0 to NUM_BLEND_FACTORS - 1 do
  begin
    var SrcBlend := TBlendFactor(Src + 1);
    for var Dst := 0 to NUM_BLEND_FACTORS - 1 do
    begin
      var DstBlend := TBlendFactor(Dst + 1);
      var Valid := True;

      if (DstBlend = TBlendFactor.SrcAlphaSaturated) then
        Valid := False
      else if (SrcBlend in [TBlendFactor.BlendColor, TBlendFactor.OneMinusBlendColor]) then
      begin
        if (DstBlend in [TBlendFactor.BlendAlpha, TBlendFactor.OneMinusBlendAlpha]) then
          Valid := False;
      end
      else if (SrcBlend in [TBlendFactor.BlendAlpha, TBlendFactor.OneMinusBlendAlpha]) then
      begin
        if (DstBlend in [TBlendFactor.BlendColor, TBlendFactor.OneMinusBlendColor]) then
          Valid := False;
      end;

      if (Valid) then
      begin
        PipDesc.Colors[0].Blend.Init(True, SrcBlend, DstBlend, TBlendOp.Default,
          TBlendFactor.One, TBlendFactor.Zero, TBlendOp.Default);
        FPips[Src, Dst] := TPipeline.Create(PipDesc);
        Assert(FPips[Src, Dst].Id <> INVALID_ID);
      end;
    end;
  end;
end;

end.

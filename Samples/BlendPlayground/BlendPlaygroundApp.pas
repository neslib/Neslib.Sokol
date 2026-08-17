unit BlendPlaygroundApp;
{ Test/demonstrate blend state configuration. }

interface

uses
  System.UITypes,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Fetch,
  Neslib.FastMath,
  SampleApp,
  BlendPlaygroundShader;

const
  MAX_FILE_SIZE = 768 * 1024;
  MIN_SCALE     = 0.25;
  MAX_SCALE     = 4;

type
  TBlendPlaygroundApp = class(TSampleApp)
  private type
    TShaderKind = (Std, DualSrc);
  private type
    TImageEx = record
    public
      Valid: Boolean;
      Image: TImage;
      TexView: TView;
      Sampler: TSampler;
      Pip: TPipeline;
      Shaders: array [TShaderKind] of TShader;
      Width: Single;
      Height: Single;
    end;
  private type
    TCompose = record
    public
      Image: TImage;
      AttView: TView;
      TexView: TView;
      Sampler: TSampler;
      Pip: TPipeline;
    end;
  private type
    TControl = record
    public
      Scale: Single;
      Offset: TVector2;
    public
      procedure Reset;
      procedure Move(const ADX, ADY: Single);
      procedure Zoom(const ADS: Single);
    end;
  private type
    TUI = record
    public
      AlphaScale: Single;
      PremultipliedAlpha: Boolean;
      SrcFactorRgbSel: Integer;
      DstFactorRgbSel: Integer;
      OpRgbSel: Integer;
      SrcFactorAlphaSel: Integer;
      DstFactorAlphaSel: Integer;
      OpAlphaSel: Integer;
      Msg: UTF8String;
    end;
  private type
    TFile = record
    public
      Error: TFetchError;
      QoiDecodeFailed: Boolean;
      Buf: array [0..MAX_FILE_SIZE - 1] of Byte;
    end;
  private
    FBGPip: TPipeline;
    FBlend: TBlendState;
    FBlendColor: TColor;
    FSrc1Color: TColor;
    FImage: TImageEx;
    FCompose: TCompose;
    FControl: TControl;
    FUI: TUI;
    FFile: TFile;
    FPipDirty: Boolean;
  private
    procedure SetSrcFactorRgb(const AFactor: TBlendFactor);
    procedure SetDstFactorRgb(const AFactor: TBlendFactor);
    procedure SetOpRgb(const AOp: TBlendOp);
    procedure SetSrcFactorAlpha(const AFactor: TBlendFactor);
    procedure SetDstFactorAlpha(const AFactor: TBlendFactor);
    procedure SetOpAlpha(const AOp: TBlendOp);
    procedure ValidateRgb;
    procedure ValidateAlpha;
    function IsDualSrcBlend: Boolean;
    procedure RecreatePipeline;
    procedure RecreateComposeImageAndViews;
    procedure CreateImage(const AQoiData: Pointer;
      const AQoiSize: Integer);
    procedure FetchCallback(const AResponse: TFetchResponse);
    function ImageVSParams: TImgVSParams;
    function ImageFSParams: TImgFSParams;
  protected
    class function HasImGui: Boolean; override;
  protected
    procedure Resized(const AWindowWidth, AWindowHeight, AFramebufferWidth,
      AFramebufferHeight: Integer); override;
    procedure KeyDown(const AKey: TKeyCode; const AModifiers: TModifiers;
      const AKeyRepeat: Boolean); override;
    procedure MouseMove(const AX, AY, ADX, ADY: Single;
      const AModifiers: TModifiers); override;
    procedure MouseScroll(const AX, AY, AWheelDeltaX, AWheelDeltaY: Single;
      const AModifiers: TModifiers); override;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure DrawImGui; override;
  end;

implementation

uses
  Neslib.Qoi,
  Neslib.ImGui,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue;

const
  BLEND_FACTOR_NAMES: array [TBlendFactor] of PUTF8Char = (
    '(Default)',
    'Zero',
    'One',
    'SrcColor',
    'OneMinusSrcColor',
    'SrcAlpha',
    'OneMinusSrcAlpha',
    'DstColor',
    'OneMinusDstColor',
    'DstAlpha',
    'OneMinusDstAlpha',
    'SrcAlphaSaturated',
    'BlendColor',
    'OneMinusBlendColor',
    'BlendAlpha',
    'OneMinusBlendAlpha',
    'Src1Color',
    'OneMinusSrc1Color',
    'Src1Alpha',
    'OneMinusSrc1Alpha');

const
  BLEND_OP_NAMES: array [TBlendOp] of PUTF8Char = (
    '(Default)',
    'Add',
    'Subtract',
    'ReverseSubtract',
    'Min',
    'Max');

function IsDualSrcBlendFactor(const AFactor: TBlendFactor): Boolean;
begin
  Result := (AFactor in [TBlendFactor.Src1Alpha, TBlendFactor.Src1Color,
    TBlendFactor.OneMinusSrc1Color, TBlendFactor.OneMinusSrc1Alpha]);
end;

function IsBlendColor(const AFactor: TBlendFactor): Boolean;
begin
  Result := (AFactor in [TBlendFactor.BlendColor, TBlendFactor.OneMinusBlendColor]);
end;

function IsBlendAlpha(const AFactor: TBlendFactor): Boolean;
begin
  Result := (AFactor in [TBlendFactor.BlendAlpha, TBlendFactor.OneMinusBlendAlpha]);
end;

{ TBlendPlaygroundApp }

procedure TBlendPlaygroundApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 1;
  AConfig.DepthFormat := TAppPixelFormat.None;
  AConfig.WindowTitle := 'Blend Playground';
end;

procedure TBlendPlaygroundApp.Init;
begin
  inherited;
  var FetchDesc := TFetchDesc.Create;
  FetchDesc.BaseDirectory := 'Data/Qoi';
  FetchDesc.MaxRequests := 1;
  FetchDesc.NumChannels := 1;
  FetchDesc.NumLanes := 1;
  FetchDesc.Logger := FetchDesc.DefaultLogger;
  TFetch.Setup(FetchDesc);

  { Initial UI state }
  FControl.Reset;
  FBlend.Enabled := True;
  FBlendColor := TColor.Create(1, 1, 1, 1);
  FSrc1Color := TColor.Create(1, 1, 1, 1);
  FUI.AlphaScale := 1;
  SetSrcFactorRgb(TBlendFactor.SrcAlpha);
  SetDstFactorRgb(TBlendFactor.OneMinusSrcAlpha);
  SetOpRgb(TBlendOp.Add);
  SetSrcFactorAlpha(TBlendFactor.Zero);
  SetDstFactorAlpha(TBlendFactor.One);
  SetOpAlpha(TBlendOp.Add);

  { Create pipeline and shader to draw a bufferless fullscreen triangle as
    background }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(BGShaderDesc);
  PipDesc.Depth.WriteEnabled := False;
  PipDesc.Depth.PixelFormat := TPixelFormat.None;
  PipDesc.Colors[0].PixelFormat := TPixelFormat.Rgba8;
  PipDesc.TraceLabel := 'BackgroundPipeline';
  FBGPip := TPipeline.Create(PipDesc);

  { Create sampler and pipeline for the alpha-test image }
  FImage.Shaders[TShaderKind.Std] := TShader.Create(ImgStdShaderDesc);
  if (TFeature.DualSourceBlending in TGfx.Features) then
    FImage.Shaders[TShaderKind.DualSrc] := TShader.Create(ImgDualsrcShaderDesc);

  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Linear;
  SamplerDesc.MagFilter := TFilter.Linear;
  SamplerDesc.WrapU := TWrap.ClampToEdge;
  SamplerDesc.WrapV := TWrap.ClampToEdge;
  SamplerDesc.TraceLabel := 'ImgSampler';
  FImage.Sampler := TSampler.Create(SamplerDesc);

  RecreatePipeline;

  { Create resources for rendering offscreen render target into canvas }
  RecreateComposeImageAndViews;

  SamplerDesc.MinFilter := TFilter.Nearest;
  SamplerDesc.MagFilter := TFilter.Nearest;
  SamplerDesc.TraceLabel := 'OffscreenSampler';
  FCompose.Sampler := TSampler.Create(SamplerDesc);

  PipDesc.Init;
  PipDesc.Shader := TShader.Create(ComposeShaderDesc);
  PipDesc.PrimitiveType := TPrimitiveType.TriangleStrip;
  PipDesc.ColorCount := 1;
  PipDesc.Colors[0].Blend.Enabled := True;
  PipDesc.Colors[0].Blend.SrcFactorRgb := TBlendFactor.SrcAlpha;
  PipDesc.Colors[0].Blend.DstFactorRgb := TBlendFactor.OneMinusSrcAlpha;
  PipDesc.Colors[0].Blend.SrcFactorAlpha := TBlendFactor.Zero;
  PipDesc.Colors[0].Blend.DstFactorAlpha := TBlendFactor.One;
  PipDesc.TraceLabel := 'OffscreenPipeline';
  FCompose.Pip := TPipeline.Create(PipDesc);

  { Start loading example texture }
  FFile.Error := TFetchError.NoError;
  var Request := TFetchRequest.Create('dice.qoi', FetchCallback,
    TFetchRange.Create(FFile.Buf));
  Request.Send;
end;

function TBlendPlaygroundApp.IsDualSrcBlend: Boolean;
begin
  Result := IsDualSrcBlendFactor(FBlend.SrcFactorRgb)
         or IsDualSrcBlendFactor(FBlend.DstFactorRgb)
         or IsDualSrcBlendFactor(FBlend.SrcFactorAlpha)
         or IsDualSrcBlendFactor(FBlend.DstFactorAlpha);
end;

procedure TBlendPlaygroundApp.KeyDown(const AKey: TKeyCode;
  const AModifiers: TModifiers; const AKeyRepeat: Boolean);
begin
  inherited;
  if (AKey = TKeyCode.Space) then
    FControl.Reset;
end;

procedure TBlendPlaygroundApp.MouseMove(const AX, AY, ADX, ADY: Single;
  const AModifiers: TModifiers);
begin
  inherited;
  if (TModifier.LeftMouseButton in AModifiers) then
    FControl.Move(ADX, ADY);
end;

procedure TBlendPlaygroundApp.MouseScroll(const AX, AY, AWheelDeltaX,
  AWheelDeltaY: Single; const AModifiers: TModifiers);
begin
  inherited;
  FControl.Zoom(AWheelDeltaY * 0.25);
end;

procedure TBlendPlaygroundApp.Frame;
begin
  TFetch.DoWork;
  if (FPipDirty) then
    RecreatePipeline;

  { Offscreen pass to render blended test-image }
  var Pass := TPass.Create;
  Pass.Action.Colors[0].LoadAction := TLoadAction.DontCare;
  Pass.Attachments.Colors[0] := FCompose.AttView;
  TGfx.BeginPass(Pass);

  { Draw background }
  var BGParams: TBGParams;
  BGParams.Dark := 0.4;
  BGParams.Light := 0.6;
  TGfx.ApplyPipeline(FBGPip);
  TGfx.ApplyUniforms(UB_BG_PARAMS, TRange.Create(BGParams));
  TGfx.Draw(0, 3);

  { Draw image }
  if (FImage.Valid) then
  begin
    var ImgVSParams := ImageVSParams();
    var ImgFSParams := ImageFSParams();
    TGfx.ApplyPipeline(FImage.Pip);

    var Bindings := TBindings.Create;
    Bindings.Views[VIEW_TEX] := FImage.TexView;
    Bindings.Samplers[SMP_SMP] := FImage.Sampler;
    TGfx.ApplyBindings(Bindings);

    TGfx.ApplyUniforms(UB_IMG_VS_PARAMS, TRange.Create(ImgVSParams));
    TGfx.ApplyUniforms(UB_IMG_FS_PARAMS, TRange.Create(ImgFSParams));
    TGfx.Draw(0, 4);
  end;
  TGfx.EndPass;

  { Display-pass to compose the offscreen image with a test-color-cleared canvas }
  Pass.Init;
  Pass.Action.Colors[0].Init(TLoadAction.Clear, 1, 0, 1, 1);
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FCompose.Pip);

  var Bindings := TBindings.Create;
  Bindings.Views[VIEW_TEX] := FCompose.TexView;
  Bindings.Samplers[SMP_SMP] := FCompose.Sampler;
  TGfx.ApplyBindings(Bindings);

  TGfx.Draw(0, 3, 1);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TBlendPlaygroundApp.Cleanup;
begin
  inherited;
  TFetch.Shutdown;
end;

class function TBlendPlaygroundApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TBlendPlaygroundApp.DrawImGui;
begin
  FPipDirty := False;
  ImGui.SetNextWindowPos(Vector2(20, 30), TImGuiCond.Once);
  if (ImGui.Begin('Controls', nil, [TImGuiWindowFlag.AlwaysAutoResize])) then
  begin
    if (FFile.Error <> TFetchError.NoError) then
      ImGui.Text('Failed to load image.')
    else if (not FImage.Valid) then
      ImGui.Text('Loading image...')
    else
    begin
      ImGui.SeparatorText('Camera');
      ImGui.SliderFloat('Zoom', @FControl.Scale, MIN_SCALE, MAX_SCALE);
      ImGui.SliderFloat2('Pan', @FControl.Offset, -FramebufferWidth * 0.5, FramebufferWidth * 0.5);

      if (ImGui.Button('Reset')) then
        FControl.Reset;

      ImGui.SeparatorText('Texture Properties');
      ImGui.SliderFloat('Alpha Scale', @FUI.AlphaScale, 0, 1);
      ImGui.Checkbox('Premultiplied Alpha', @FUI.PremultipliedAlpha);

      ImGui.SeparatorText('RGB Blend State');

      if (ImGui.Combo('Src Factor##RGB', @FUI.SrcFactorRgbSel,
        PPUTF8Char(@BLEND_FACTOR_NAMES), Length(BLEND_FACTOR_NAMES))) then
      begin
        SetSrcFactorRgb(TBlendFactor(FUI.SrcFactorRgbSel));
        ValidateRgb;
        FPipDirty := True;
      end;

      if (ImGui.Combo('Blend Op##RGB', @FUI.OpRgbSel,
        PPUTF8Char(@BLEND_OP_NAMES), Length(BLEND_OP_NAMES))) then
      begin
        SetOpRgb(TBlendOp(FUI.OpRgbSel));
        ValidateRgb;
        FPipDirty := True;
      end;

      if (ImGui.Combo('Dst Factor##RGB', @FUI.DstFactorRgbSel,
        PPUTF8Char(@BLEND_FACTOR_NAMES), Length(BLEND_FACTOR_NAMES))) then
      begin
        SetDstFactorRgb(TBlendFactor(FUI.DstFactorRgbSel));
        ValidateRgb;
        FPipDirty := True;
      end;

      ImGui.SeparatorText('Alpha Blend State');

      if (ImGui.Combo('Src Factor##Alpha', @FUI.SrcFactorAlphaSel,
        PPUTF8Char(@BLEND_FACTOR_NAMES), Length(BLEND_FACTOR_NAMES))) then
      begin
        SetSrcFactorAlpha(TBlendFactor(FUI.SrcFactorAlphaSel));
        ValidateAlpha;
        FPipDirty := True;
      end;

      if (ImGui.Combo('Blend Op##Alpha', @FUI.OpAlphaSel,
        PPUTF8Char(@BLEND_OP_NAMES), Length(BLEND_OP_NAMES))) then
      begin
        SetOpAlpha(TBlendOp(FUI.OpAlphaSel));
        ValidateAlpha;
        FPipDirty := True;
      end;

      if (ImGui.Combo('Dst Factor##Alpha', @FUI.DstFactorAlphaSel,
        PPUTF8Char(@BLEND_FACTOR_NAMES), Length(BLEND_FACTOR_NAMES))) then
      begin
        SetDstFactorAlpha(TBlendFactor(FUI.DstFactorAlphaSel));
        ValidateAlpha;
        FPipDirty := True;
      end;

      ImGui.SeparatorText('Input Colors');

      if (ImGui.ColorEdit4('Blend Color', @FBlendColor, [TImGuiColorEditFlag.AlphaBar])) then
        FPipDirty := True;

      ImGui.ColorEdit4('Src1 Color', @FSrc1Color, [TImGuiColorEditFlag.AlphaBar]);

      ImGui.SeparatorText('Validation');
      if (FUI.Msg = '') then
        ImGui.Text('All ok.')
      else
        ImGui.Text(PUTF8Char(FUI.Msg));
    end;
  end;
  ImGui.End;
end;

procedure TBlendPlaygroundApp.CreateImage(const AQoiData: Pointer;
  const AQoiSize: Integer);
begin
  if (FImage.Image.Id <> INVALID_ID) then
  begin
    FImage.Image.Free;
    FImage.Image.Id := INVALID_ID;
  end;

  if (FImage.TexView.Id <> INVALID_ID) then
  begin
    FImage.TexView.Free;
    FImage.TexView.Id := INVALID_ID;
  end;

  FImage.Valid := False;
  var Qoi: TQoiDesc;
  var Pixels := QoiDecode(AQoiData, AQoiSize, Qoi, TQoiChannels.RGBA);
  if (Pixels = nil) then
  begin
    FFile.QoiDecodeFailed := True;
    Exit;
  end;

  try
    FImage.Width := Qoi.Width;
    FImage.Height := Qoi.Height;

    var ImgDesc := TImageDesc.Create;
    ImgDesc.PixelFormat := TPixelFormat.Rgba8;
    ImgDesc.Width := Qoi.Width;
    ImgDesc.Height := Qoi.Height;
    ImgDesc.Data.MipLevels[0] := TRange.Create(Pixels, Qoi.Width * Qoi.Height * 4);
    ImgDesc.TraceLabel := 'QoiImage';
    FImage.Image := TImage.Create(ImgDesc);
  finally
    FreeMem(Pixels);
  end;

  var ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := FImage.Image;
  ViewDesc.TraceLabel := 'QoiImageView';
  FImage.TexView := TView.Create(ViewDesc);

  FImage.Valid := True;
end;

function TBlendPlaygroundApp.ImageFSParams: TImgFSParams;
begin
  Result.AlphaScale := FUI.AlphaScale;
  Result.PremultipliedAlpha := Ord(FUI.PremultipliedAlpha);
  Result.Src1Color.Init(FSrc1Color.R, FSrc1Color.G, FSrc1Color.B, FSrc1Color.A);
end;

function TBlendPlaygroundApp.ImageVSParams: TImgVSParams;
begin
  Result.Offset.Init(
     FControl.Offset.X / (0.5 * FramebufferWidth),
    -FControl.Offset.Y / (0.5 * FramebufferHeight));

  Result.Scale.Init(
    (FImage.Width / FramebufferWidth) * FControl.Scale * DpiScale,
    (FImage.Height / FramebufferHeight) * FControl.Scale * DpiScale);
end;

procedure TBlendPlaygroundApp.FetchCallback(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
  begin
    FFile.Error := TFetchError.NoError;
    CreateImage(AResponse.Data.Ptr, AResponse.Data.Size);
  end
  else if (AResponse.Failed) then
    FFile.Error := AResponse.ErrorCode;
end;

procedure TBlendPlaygroundApp.RecreateComposeImageAndViews;
begin
  if (FCompose.Image.Id <> INVALID_ID) then
  begin
    FCompose.Image.Free;
    FCompose.Image.Id := INVALID_ID;
  end;

  if (FCompose.AttView.Id <> INVALID_ID) then
  begin
    FCompose.AttView.Free;
    FCompose.AttView.Id := INVALID_ID;
  end;

  if (FCompose.TexView.Id <> INVALID_ID) then
  begin
    FCompose.TexView.Free;
    FCompose.TexView.Id := INVALID_ID;
  end;

  var ImgDesc := TImageDesc.Create;
  ImgDesc.Usage.ColorAttachment := True;
  ImgDesc.Width := FramebufferWidth;
  ImgDesc.Height := FramebufferHeight;
  ImgDesc.PixelFormat := TPixelFormat.Rgba8;
  ImgDesc.TraceLabel := 'ComposeImage';
  FCompose.Image := TImage.Create(ImgDesc);

  var ViewDesc := TViewDesc.Create;
  ViewDesc.ColorAttachment.Image := FCompose.Image;
  ViewDesc.TraceLabel := 'ComposeColorAttachment';
  FCompose.AttView := TView.Create(ViewDesc);

  ViewDesc.Init;
  ViewDesc.Texture.Image := FCompose.Image;
  ViewDesc.TraceLabel := 'ComposeTexView';
  FCompose.TexView := TView.Create(ViewDesc);
end;

procedure TBlendPlaygroundApp.RecreatePipeline;
begin
  if (FImage.Pip.Id <> INVALID_ID) then
  begin
    FImage.Pip.Free;
    FImage.Pip.Id := INVALID_ID;
  end;

  var Kind := TShaderKind.Std;
  if (TFeature.DualSourceBlending in TGfx.Features) then
    Kind := TShaderKind.DualSrc;

  { Synthesize vertices in vertex shader }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := FImage.Shaders[Kind];
  PipDesc.PrimitiveType := TPrimitiveType.TriangleStrip;
  PipDesc.Depth.PixelFormat := TPixelFormat.None;
  PipDesc.Depth.WriteEnabled := False;
  PipDesc.ColorCount := 1;
  PipDesc.Colors[0].PixelFormat := TPixelFormat.Rgba8;
  PipDesc.Colors[0].Blend := FBlend;
  PipDesc.BlendColor := FBlendColor;
  PipDesc.TraceLabel := 'ImgPipeline';
  FImage.Pip := TPipeline.Create(PipDesc);
end;

procedure TBlendPlaygroundApp.Resized(const AWindowWidth, AWindowHeight,
  AFramebufferWidth, AFramebufferHeight: Integer);
begin
  inherited;
  RecreateComposeImageAndViews;
end;

procedure TBlendPlaygroundApp.SetDstFactorAlpha(const AFactor: TBlendFactor);
begin
  FBlend.DstFactorAlpha := AFactor;
  FUI.DstFactorAlphaSel := Ord(AFactor);
end;

procedure TBlendPlaygroundApp.SetDstFactorRgb(const AFactor: TBlendFactor);
begin
  FBlend.DstFactorRgb := AFactor;
  FUI.DstFactorRgbSel := Ord(AFactor);
end;

procedure TBlendPlaygroundApp.SetOpAlpha(const AOp: TBlendOp);
begin
  FBlend.OpAlpha := AOp;
  FUI.OpAlphaSel := Ord(AOp);
end;

procedure TBlendPlaygroundApp.SetOpRgb(const AOp: TBlendOp);
begin
  FBlend.OpRgb := AOp;
  FUI.OpRgbSel := Ord(AOp);
end;

procedure TBlendPlaygroundApp.SetSrcFactorAlpha(const AFactor: TBlendFactor);
begin
  FBlend.SrcFactorAlpha := AFactor;
  FUI.SrcFactorAlphaSel := Ord(AFactor);
end;

procedure TBlendPlaygroundApp.SetSrcFactorRgb(const AFactor: TBlendFactor);
begin
  FBlend.SrcFactorRgb := AFactor;
  FUI.SrcFactorRgbSel := Ord(AFactor);
end;

procedure TBlendPlaygroundApp.ValidateAlpha;
begin
  FUI.Msg := '';
  var SrcA := FBlend.SrcFactorAlpha;
  var DstA := FBlend.DstFactorAlpha;
  var OpA := FBlend.OpAlpha;

  if (OpA in [TBlendOp.Min, TBlendOp.Max]) then
  begin
    if (SrcA <> TBlendFactor.One) or (DstA <> TBlendFactor.One) then
    begin
      SetSrcFactorAlpha(TBlendFactor.One);
      SetDstFactorAlpha(TBlendFactor.One);
      FUI.Msg := 'Blend op min/max requires src/dst factor one/one';
    end;
  end
  else if (IsDualSrcBlend) and (not (TFeature.DualSourceBlending in TGfx.Features)) then
  begin
    SetSrcFactorAlpha(TBlendFactor.Zero);
    SetDstFactorAlpha(TBlendFactor.One);
    FUI.Msg := 'Dual source blending not supported';
  end;
end;

procedure TBlendPlaygroundApp.ValidateRgb;
begin
  FUI.Msg := '';
  var SrcRgb := FBlend.SrcFactorRgb;
  var DstRgb := FBlend.DstFactorRgb;
  var OpRgb := FBlend.OpRgb;

  if (OpRgb in [TBlendOp.Min, TBlendOp.Max]) then
  begin
    if (SrcRgb <> TBlendFactor.One) or (DstRgb <> TBlendFactor.One) then
    begin
      SetSrcFactorRgb(TBlendFactor.One);
      SetDstFactorRgb(TBlendFactor.One);
      FUI.Msg := 'Blend op min/max requires src/dst factor one/one';
    end;
  end;

  if (IsDualSrcBlend) and (not (TFeature.DualSourceBlending in TGfx.Features)) then
  begin
    SetSrcFactorRgb(TBlendFactor.SrcAlpha);
    SetDstFactorRgb(TBlendFactor.OneMinusSrcAlpha);
    SetOpRgb(TBlendOp.Add);
    FUI.Msg := 'Dual source blending not supported';
  end;

  if (TGfx.Backend = TBackend.Gles3) then
  begin
    if (IsBlendColor(SrcRgb) and IsBlendAlpha(DstRgb)) or
       (IsBlendAlpha(SrcRgb) and IsBlendColor(DstRgb)) then
    begin
      SetSrcFactorRgb(TBlendFactor.SrcAlpha);
      SetDstFactorRgb(TBlendFactor.OneMinusSrcAlpha);
      SetOpRgb(TBlendOp.Add);
      FUI.Msg := 'Invalid blend combo on GLES-3';
    end;
  end;
end;

{ TBlendPlaygroundApp.TControl }

procedure TBlendPlaygroundApp.TControl.Move(const ADX, ADY: Single);
begin
  Offset.X := Offset.X + ADX;
  Offset.Y := Offset.Y + ADY;
end;

procedure TBlendPlaygroundApp.TControl.Reset;
begin
  Scale := 0.75;
  Offset := TVector2.Zero;
end;

procedure TBlendPlaygroundApp.TControl.Zoom(const ADS: Single);
begin
  Scale := Scale * Exp(ADS);
  Scale := EnsureRange(Scale, MIN_SCALE, MAX_SCALE);
end;

end.

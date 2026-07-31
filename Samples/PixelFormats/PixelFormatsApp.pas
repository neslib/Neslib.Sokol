unit PixelFormatsApp;
{ Test pixelformat capabilities. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  PixelFormatsShader;

type
  TImageAndViews = record
  public
    Image: TImage;
    TexView: TView;
    AttView: TView;
  public
    procedure Init(const AImgDesc: TImageDesc; const AHasTexView: Boolean;
      const AAttViewType: TViewType);
  end;

type
  TFormat = record
  private class var
    FPixels: array [0..(8 * 8 * 16) - 1] of Byte;
  private
    class function GenPixels(const AFmt: TPixelFormat): TRange; static;
    class function GenPixels8(const AVal: Byte): TRange; static;
    class function GenPixels16(const AVal: Word): TRange; static;
    class function GenPixels32(const AVal: Cardinal): TRange; static;
    class function GenPixels64(const AVal: UInt64): TRange; static;
    class function GenPixels128(const AHi, ALo: UInt64): TRange; static;
  public
    Valid: Boolean;
    PixelFormat: TPixelFormat;
    DefImageId: Cardinal;
    Unfiltered: TImageAndViews;
    Filtered: TImageAndViews;
    Render: TImageAndViews;
    Blend: TImageAndViews;
    MsaaRender: TImageAndViews;
    MsaaResolve: TImageAndViews;
    CubeRenderPip: TPipeline;
    CubeBlendPip: TPipeline;
    CubeMsaaPip: TPipeline;
    BGRenderPip: TPipeline;
    BGMsaaPip: TPipeline;
  public
    procedure Init(const APixFmt: TPixelFormat; const ADefImage: TImageAndViews;
      ADepthAttView, AMsaaDepthAttView: TView; var ACubeRenderPipDesc,
      ABGRenderPipDesc, ACubeBlendPipDesc, ACubeMsaaPipDesc,
      ABGMsaaPipDesc: TPipelineDesc);

    procedure Draw(const ADepthAttView, AMsaaDepthAttView: TView;
      const ABGBindings, ACubeBindings: TBindings;
      const ABGFsParams: TBGFsParams; const ACubeVsParams: TCubeVsParams);

    procedure DrawImGui(const ASampler: TSampler);
  end;

type
  TPixelFormatsApp = class(TSampleApp)
  private
    FFormat: array [TPixelFormat.R8..TPixelFormat.Depth] of TFormat;
    FDepthAttView: TView;
    FMsaaDepthAttView: TView;
    FSmpLinear: TSampler;
    FCubeBindings: TBindings;
    FBGBindings: TBindings;
    FCubeVsParams: TCubeVsParams;
    FBGFsParams: TBGFsParams;
    FRX: Single;
    FRY: Single;
  protected
    class function HasImGui: Boolean; override;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure ConfigureGfx(var ADesc: TGfxDesc); override;
    procedure Init; override;
    procedure Frame; override;
    procedure DrawImGui; override;
    procedure Cleanup; override;
  end;

implementation

uses
  System.UITypes,
  Neslib.ImGui,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue,
  Neslib.Sokol.ImGui;

{ A 'disabled' texture pattern with a cross }
const
  X = $FF0000FF;
  o = $FFCCCCCC;

const
  DISABLED_TEXTURE_PIXELS: array [0..(8 * 8) - 1] of UInt32 = (
    X, o, o, o, o, o, o, X,
    o, X, o, o, o, o, X, o,
    o, o, X, o, o, X, o, o,
    o, o, o, X, X, o, o, o,
    o, o, o, X, X, o, o, o,
    o, o, X, o, o, X, o, o,
    o, X, o, o, o, o, X, o,
    X, o, o, o, o, o, o, X);

const
  { Cube vertex buffer }
  VERTICES: array [0..167] of Single = (
    -1.0, -1.0, -1.0,   0.7, 0.3, 0.3, 1.0,
     1.0, -1.0, -1.0,   0.7, 0.3, 0.3, 1.0,
     1.0,  1.0, -1.0,   0.7, 0.3, 0.3, 1.0,
    -1.0,  1.0, -1.0,   0.7, 0.3, 0.3, 1.0,

    -1.0, -1.0,  1.0,   0.3, 0.7, 0.3, 1.0,
     1.0, -1.0,  1.0,   0.3, 0.7, 0.3, 1.0,
     1.0,  1.0,  1.0,   0.3, 0.7, 0.3, 1.0,
    -1.0,  1.0,  1.0,   0.3, 0.7, 0.3, 1.0,

    -1.0, -1.0, -1.0,   0.3, 0.3, 0.7, 1.0,
    -1.0,  1.0, -1.0,   0.3, 0.3, 0.7, 1.0,
    -1.0,  1.0,  1.0,   0.3, 0.3, 0.7, 1.0,
    -1.0, -1.0,  1.0,   0.3, 0.3, 0.7, 1.0,

    1.0, -1.0, -1.0,    0.7, 0.5, 0.3, 1.0,
    1.0,  1.0, -1.0,    0.7, 0.5, 0.3, 1.0,
    1.0,  1.0,  1.0,    0.7, 0.5, 0.3, 1.0,
    1.0, -1.0,  1.0,    0.7, 0.5, 0.3, 1.0,

    -1.0, -1.0, -1.0,   0.3, 0.5, 0.7, 1.0,
    -1.0, -1.0,  1.0,   0.3, 0.5, 0.7, 1.0,
     1.0, -1.0,  1.0,   0.3, 0.5, 0.7, 1.0,
     1.0, -1.0, -1.0,   0.3, 0.5, 0.7, 1.0,

    -1.0,  1.0, -1.0,   0.7, 0.3, 0.5, 1.0,
    -1.0,  1.0,  1.0,   0.7, 0.3, 0.5, 1.0,
     1.0,  1.0,  1.0,   0.7, 0.3, 0.5, 1.0,
     1.0,  1.0, -1.0,   0.7, 0.3, 0.5, 1.0);

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
  QUAD_VERTICES: array [0..7] of Single = (
    -1.0, -1.0, +1.0, -1.0, -1.0, +1.0, +1.0, +1.0);

procedure TPixelFormatsApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Pixelformat Test';
end;

procedure TPixelFormatsApp.Init;
begin
  inherited;
  { Create all the textures, samplers and render targets }
  var ImgDesc := TImageDesc.Create;
  ImgDesc.Usage.DepthStencilAttachment := True;
  ImgDesc.Width := 64;
  ImgDesc.Height := 64;
  ImgDesc.PixelFormat := TPixelFormat.Depth;
  ImgDesc.SampleCount := 1;

  var ViewDesc := TViewDesc.Create;
  ViewDesc.DepthStencilAttachment.Image := TImage.Create(ImgDesc);
  FDepthAttView := TView.Create(ViewDesc);

  ImgDesc.SampleCount := 4;
  ViewDesc.DepthStencilAttachment.Image := TImage.Create(ImgDesc);
  FMsaaDepthAttView := TView.Create(ViewDesc);

  var InvalidImage: TImageAndViews;
  ImgDesc.Init;
  ImgDesc.Width := 8;
  ImgDesc.Height := 8;
  ImgDesc.Data.MipLevels[0] := TRange.Create(DISABLED_TEXTURE_PIXELS);
  InvalidImage.Init(ImgDesc, True, TViewType.Invalid);

  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Linear;
  SamplerDesc.MagFilter := TFilter.Linear;
  FSmpLinear := TSampler.Create(SamplerDesc);

  var CubeRenderPipDesc := TPipelineDesc.Create;
  CubeRenderPipDesc.Layout.Attrs[ATTR_CUBE_POS].Format := TVertexFormat.Float3;
  CubeRenderPipDesc.Layout.Attrs[ATTR_CUBE_COLOR0].Format := TVertexFormat.Float4;
  CubeRenderPipDesc.Shader := TShader.Create(CubeShaderDesc);
  CubeRenderPipDesc.IndexType := TIndexType.UInt16;
  CubeRenderPipDesc.CullMode := TCullMode.Back;
  CubeRenderPipDesc.SampleCount := 1;
  CubeRenderPipDesc.Depth.WriteEnabled := True;
  CubeRenderPipDesc.Depth.PixelFormat := TPixelFormat.Depth;
  CubeRenderPipDesc.Depth.Compare := TCompareFunc.LessOrEqual;

  var BGRenderPipDesc := TPipelineDesc.Create;
  BGRenderPipDesc.Layout.Attrs[ATTR_BG_POSITION].Format := TVertexFormat.Float2;
  BGRenderPipDesc.Shader := TShader.Create(BgShaderDesc);
  BGRenderPipDesc.PrimitiveType := TPrimitiveType.TriangleStrip;
  BGRenderPipDesc.SampleCount := 1;
  BGRenderPipDesc.Depth.PixelFormat := TPixelFormat.Depth;

  var CubeBlendPipDesc := CubeRenderPipDesc;
  CubeBlendPipDesc.Colors[0].Blend.Enabled := True;
  CubeBlendPipDesc.Colors[0].Blend.SrcFactorRgb := TBlendFactor.One;
  CubeBlendPipDesc.Colors[0].Blend.DstFactorRgb := TBlendFactor.One;

  var CubeMsaaPipDesc := CubeRenderPipDesc;
  CubeMsaaPipDesc.SampleCount := 4;

  var BGMsaaPipDesc := BGRenderPipDesc;
  BGMsaaPipDesc.SampleCount := 4;

  for var PixFmt := TPixelFormat.R8 to TPixelFormat.Depth do
  begin
    FFormat[PixFmt].Init(PixFmt, InvalidImage, FDepthAttView, FMsaaDepthAttView,
      CubeRenderPipDesc, BGRenderPipDesc, CubeBlendPipDesc, CubeMsaaPipDesc,
      BGMsaaPipDesc);
  end;

  { Cube vertex and index buffer }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  FCubeBindings.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.Usage.IndexBuffer := True;
  BufferDesc.Data := TRange.Create(INDICES);
  FCubeBindings.IndexBuffer := TBuffer.Create(BufferDesc);

  { Background quad vertices }
  BufferDesc.Init;
  BufferDesc.Data := TRange.Create(QUAD_VERTICES);
  FBGBindings.VertexBuffers[0] := TBuffer.Create(BufferDesc);
end;

procedure TPixelFormatsApp.Frame;
begin
  { Compute model-view-projection matrix for vertex shader }
  var T: Single := FrameDuration * 60;

  { Compute the model-view-proj matrix for rendering to render targets }
  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), 1, 0.01, 10.0);
  View.InitLookAtRH(Vector3(0, 1.5, 6), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  FRX := FRX + (1 * T);
  FRY := FRY + (2 * T);
  var RXM, RYM: TMatrix4;
  RXM.InitRotationX(Radians(FRX));
  RYM.InitRotationY(Radians(FRY));
  var Model := RXM * RYM;
  FCubeVsParams.Mvp := ViewProj * Model;
  FBGFsParams.Tick := FBGFsParams.Tick + T;

  { Render into all the offscreen render targets }
  for var PixFmt := TPixelFormat.R8 to TPixelFormat.Depth do
  begin
    FFormat[PixFmt].Draw(FDepthAttView, FMsaaDepthAttView, FBGBindings,
      FCubeBindings, FBGFsParams, FCubeVsParams);
  end;

  var PassAction := TPassAction.Create;
  PassAction.Colors[0].Init(TLoadAction.Clear, 0, 0.5, 0.7, 1);

  var Pass := TPass.Create;
  Pass.Action^ := PassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TPixelFormatsApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

class function TPixelFormatsApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TPixelFormatsApp.ConfigureGfx(var ADesc: TGfxDesc);
begin
  inherited;
  ADesc.PipelinePoolSize := 256;
  ADesc.ImagePoolSize := 256;
  ADesc.ViewPoolSize := 512;
end;

procedure TPixelFormatsApp.DrawImGui;
begin
  ImGui.SetNextWindowSize(Vector2(640, 480), TImGuiCond.Once);
  if (ImGui.Begin('Pixel Formats (without UINT and SINT formats)')) then
  begin
    ImGui.Text('format');
    ImGui.SameLine(114, 0);
    ImGui.Text('sample');
    ImGui.SameLine(114 + (1 * 66), 0);
    ImGui.Text('filter');
    ImGui.SameLine(114 + (2 * 66), 0);
    ImGui.Text('render');
    ImGui.SameLine(114 + (3 * 66), 0);
    ImGui.Text('blend');
    ImGui.SameLine(114 + (4 * 66), 0);
    ImGui.Text('msaa');

    ImGui.Separator;

    ImGui.BeginChild('#scrollregion');
    for var PixFmt := TPixelFormat.R8 to TPixelFormat.Depth do
      FFormat[PixFmt].DrawImGui(FSmpLinear);
    ImGui.EndChild;
  end;
  ImGui.End;
end;

{ TImageAndViews }

procedure TImageAndViews.Init(const AImgDesc: TImageDesc;
  const AHasTexView: Boolean; const AAttViewType: TViewType);
begin
  Image := TImage.Create(AImgDesc);

  var ViewDesc: TViewDesc;

  if (AHasTexView) then
  begin
    ViewDesc.Init;
    ViewDesc.Texture.Image := Image;
    TexView := TView.Create(ViewDesc);
  end;

  if (AAttViewType = TViewType.ColorAttachment) then
  begin
    ViewDesc.Init;
    ViewDesc.ColorAttachment.Image := Image;
    AttView := TView.Create(ViewDesc);
  end
  else if (AAttViewType = TViewType.ResolveAttachment) then
  begin
    ViewDesc.Init;
    ViewDesc.ResolveAttachment.Image := Image;
    AttView := TView.Create(ViewDesc);
  end;
end;

{ TFormat }

procedure TFormat.Draw(const ADepthAttView, AMsaaDepthAttView: TView;
  const ABGBindings, ACubeBindings: TBindings; const ABGFsParams: TBGFsParams;
  const ACubeVsParams: TCubeVsParams);
begin
  if (not Valid) then
    Exit;

  var Pass: TPass;

  if (PixelFormat.Render) then
  begin
    Pass.Init;
    Pass.Attachments.Colors[0] := Render.AttView;
    Pass.Attachments.DepthStencil := ADepthAttView;
    TGfx.BeginPass(Pass);

    TGfx.ApplyPipeline(BGRenderPip);
    TGfx.ApplyBindings(ABGBindings);
    TGfx.ApplyUniforms(UB_BG_FS_PARAMS, TRange.Create(ABGFsParams));
    TGfx.Draw(0, 4);

    TGfx.ApplyPipeline(CubeRenderPip);
    TGfx.ApplyBindings(ACubeBindings);
    TGfx.ApplyUniforms(UB_CUBE_VS_PARAMS, TRange.Create(ACubeVsParams));
    TGfx.Draw(0, 36);

    TGfx.EndPass;
  end;

  if (PixelFormat.Blend) then
  begin
    Pass.Init;
    Pass.Attachments.Colors[0] := Blend.AttView;
    Pass.Attachments.DepthStencil := ADepthAttView;
    TGfx.BeginPass(Pass);

    TGfx.ApplyPipeline(BGRenderPip);
    TGfx.ApplyBindings(ABGBindings);
    TGfx.ApplyUniforms(UB_BG_FS_PARAMS, TRange.Create(ABGFsParams));
    TGfx.Draw(0, 4);

    TGfx.ApplyPipeline(CubeBlendPip);
    TGfx.ApplyBindings(ACubeBindings);
    TGfx.ApplyUniforms(UB_CUBE_VS_PARAMS, TRange.Create(ACubeVsParams));
    TGfx.Draw(0, 36);

    TGfx.EndPass;
  end;

  if (PixelFormat.Msaa) then
  begin
    Pass.Init;
    Pass.Attachments.Colors[0] := MsaaRender.AttView;
    Pass.Attachments.Resolves[0] := MsaaResolve.AttView;
    Pass.Attachments.DepthStencil := AMsaaDepthAttView;
    Pass.Action.Colors[0].StoreAction := TStoreAction.DontCare;
    TGfx.BeginPass(Pass);

    TGfx.ApplyPipeline(BGMsaaPip);
    TGfx.ApplyBindings(ABGBindings);
    TGfx.ApplyUniforms(UB_BG_FS_PARAMS, TRange.Create(ABGFsParams));
    TGfx.Draw(0, 4);

    TGfx.ApplyPipeline(CubeMsaaPip);
    TGfx.ApplyBindings(ACubeBindings);
    TGfx.ApplyUniforms(UB_CUBE_VS_PARAMS, TRange.Create(ACubeVsParams));
    TGfx.Draw(0, 36);

    TGfx.EndPass;
  end;
end;

procedure TFormat.DrawImGui(const ASampler: TSampler);
const
  PIXEL_FORMAT_STRINGS: array [TPixelFormat.R8..TPixelFormat.Depth] of PUTF8Char = (
    'R8',
    'R8SN',
    'R8UI',
    'R8SI',
    'R16',
    'R16SN',
    'R16UI',
    'R16SI',
    'R16F',
    'Rg8',
    'Rg8SN',
    'Rg8UI',
    'Rg8SI',
    'R32UI',
    'R32SI',
    'R32F',
    'Rg16',
    'Rg16SN',
    'Rg16UI',
    'Rg16SI',
    'Rg16F',
    'Rgba8',
    'sRgb8A8',
    'Rgba8SN',
    'Rgba8UI',
    'Rgba8SI',
    'Bgra8',
    'sBgr8A8',
    'Rgb10A2',
    'Rg11B10F',
    'Rgb9E5',
    'Rg32UI',
    'Rg32SI',
    'Rg32F',
    'Rgba16',
    'Rgba16SN',
    'Rgba16UI',
    'Rgba16SI',
    'Rgba16F',
    'Rgba32UI',
    'Rgba32SI',
    'Rgba32F',
    'Depth');
begin
  if (not Valid) then
    Exit;

  if (ImGui.BeginChild(PIXEL_FORMAT_STRINGS[PixelFormat], Vector2(0, 80), [],
    [TImGuiWindowFlag.NoMouseInputs, TImGuiWindowFlag.NoScrollbar])) then
  begin
    var TexRef: TImTextureRef;
    TexRef.TexData := nil;

    ImGui.Text(PIXEL_FORMAT_STRINGS[PixelFormat]);

    ImGui.SameLine(256, 0);
    TexRef.TexID := SokolImGui.ImTextureId(Unfiltered.TexView);
    ImGui.Image(TexRef, Vector2(64));

    ImGui.SameLine;
    TexRef.TexID := SokolImGui.ImTextureId(Filtered.TexView, ASampler);
    ImGui.Image(TexRef, Vector2(64));

    ImGui.SameLine;
    TexRef.TexID := SokolImGui.ImTextureId(Render.TexView);
    ImGui.Image(TexRef, Vector2(64));

    ImGui.SameLine;
    TexRef.TexID := SokolImGui.ImTextureId(Blend.TexView);
    ImGui.Image(TexRef, Vector2(64));

    ImGui.SameLine;
    TexRef.TexID := SokolImGui.ImTextureId(MsaaResolve.TexView);
    ImGui.Image(TexRef, Vector2(64));
  end;
  ImGui.EndChild;
end;

class function TFormat.GenPixels(const AFmt: TPixelFormat): TRange;
{ Generate checkerboard pixel values.
  NOTE: the UI and SI (unsigned/signed) formats are not renderable with the
  ImGui shader, since that expects a texture which can be sampled into a float }
begin
  case AFmt of
    TPixelFormat.R8      : Result := GenPixels8($FF);
    TPixelFormat.R8SN    : Result := GenPixels8($7F);
    TPixelFormat.R16     : Result := GenPixels16($FFFF);
    TPixelFormat.R16SN   : Result := GenPixels16($7FFF);
    TPixelFormat.R16F    : Result := GenPixels16($3C00);
    TPixelFormat.Rg8     : Result := GenPixels16($FFFF);
    TPixelFormat.Rg8SN   : Result := GenPixels16($7F7F);
    TPixelFormat.R32F    : Result := GenPixels32($3F800000);
    TPixelFormat.Rg16    : Result := GenPixels32($FFFFFFFF);
    TPixelFormat.Rg16SN  : Result := GenPixels32($7FFF7FFF);
    TPixelFormat.Rg16F   : Result := GenPixels32($3C003C00);
    TPixelFormat.Rgba8   : Result := GenPixels32($FFFFFFFF);
    TPixelFormat.sRgb8A8 : Result := GenPixels32($FFFFFFFF);
    TPixelFormat.Rgba8SN : Result := GenPixels32($7F7F7F7F);
    TPixelFormat.sBgr8A8 : Result := GenPixels32($FFFFFFFF);
    TPixelFormat.Bgra8   : Result := GenPixels32($FFFFFFFF);
    TPixelFormat.Rgb10A2 : Result := GenPixels32(Cardinal($3 shl 30) or ($3FF shl 20) or ($3FF shl 10) or $3FF);
    TPixelFormat.Rg11B10F: Result := GenPixels32(Cardinal($1E0 shl 22) or ($3C0 shl 11) or $3C0);
    TPixelFormat.Rg32F   : Result := GenPixels64($3F8000003F800000);
    TPixelFormat.Rgba16  : Result := GenPixels64($FFFFFFFFFFFFFFFF);
    TPixelFormat.Rgba16SN: Result := GenPixels64($7FFF7FFF7FFF7FFF);
    TPixelFormat.Rgba16F : Result := GenPixels64($3C003C003C003C00);
    TPixelFormat.Rgba32F : Result := GenPixels128($3F8000003F800000, $3F8000003F800000);
  else
    Result := TRange.Create(nil, 0);
  end;
end;

class function TFormat.GenPixels128(const AHi, ALo: UInt64): TRange;
begin
  var Ptr := PUInt64(@FPixels);
  for var Y := 0 to 7 do
    for var X := 0 to 7 do
    begin
      if (((X xor Y) and 1) <> 0) then
      begin
        Ptr^ := ALo;
        Inc(Ptr);
        Ptr^ := AHi;
      end
      else
      begin
        Ptr^ := 0;
        Inc(Ptr);
        Ptr^ := 0;
      end;
      Inc(Ptr);
    end;
  Result := TRange.Create(@FPixels, 8 * 8 * 16);
end;

class function TFormat.GenPixels16(const AVal: Word): TRange;
begin
  var Ptr := PWord(@FPixels);
  for var Y := 0 to 7 do
    for var X := 0 to 7 do
    begin
      if (((X xor Y) and 1) <> 0) then
        Ptr^ := AVal
      else
        Ptr^ := 0;
      Inc(Ptr);
    end;
  Result := TRange.Create(@FPixels, 8 * 8 * 2);
end;

class function TFormat.GenPixels32(const AVal: Cardinal): TRange;
begin
  var Ptr := PCardinal(@FPixels);
  for var Y := 0 to 7 do
    for var X := 0 to 7 do
    begin
      if (((X xor Y) and 1) <> 0) then
        Ptr^ := AVal
      else
        Ptr^ := 0;
      Inc(Ptr);
    end;
  Result := TRange.Create(@FPixels, 8 * 8 * 4);
end;

class function TFormat.GenPixels64(const AVal: UInt64): TRange;
begin
  var Ptr := PUInt64(@FPixels);
  for var Y := 0 to 7 do
    for var X := 0 to 7 do
    begin
      if (((X xor Y) and 1) <> 0) then
        Ptr^ := AVal
      else
        Ptr^ := 0;
      Inc(Ptr);
    end;
  Result := TRange.Create(@FPixels, 8 * 8 * 8);
end;

class function TFormat.GenPixels8(const AVal: Byte): TRange;
begin
  var Ptr := PByte(@FPixels);
  for var Y := 0 to 7 do
    for var X := 0 to 7 do
    begin
      if (((X xor Y) and 1) <> 0) then
        Ptr^ := AVal
      else
        Ptr^ := 0;
      Inc(Ptr);
    end;
  Result := TRange.Create(@FPixels, 8 * 8 * 1);
end;

procedure TFormat.Init(const APixFmt: TPixelFormat;
  const ADefImage: TImageAndViews; ADepthAttView, AMsaaDepthAttView: TView;
  var ACubeRenderPipDesc, ABGRenderPipDesc, ACubeBlendPipDesc, ACubeMsaaPipDesc,
  ABGMsaaPipDesc: TPipelineDesc);
begin
  PixelFormat := APixFmt;
  Valid := False;

  //DefImageId := ADefImage.Id;
  Unfiltered := ADefImage;
  Filtered := ADefImage;
  Render := ADefImage;
  Blend := ADefImage;
  MsaaResolve := ADefImage;

  var ImgData := GenPixels(APixFmt);
  if (ImgData.Data <> nil) then
  begin
    Valid := True;

    var ImgDesc: TImageDesc;

    { Create unfiltered and filtered texture and associated views }
    if (APixFmt.Sample) then
    begin
      ImgDesc.Init;
      ImgDesc.Width := 8;
      ImgDesc.Height := 8;
      ImgDesc.PixelFormat := APixFmt;
      ImgDesc.Data.MipLevels[0] := ImgData;
      Unfiltered.Init(ImgDesc, True, TViewType.Invalid);

      if (APixFmt.Filter) then
        Filtered := Unfiltered;
    end;

    { Create non-MSAA render target, pipeline state and pass-attachments }
    if (APixFmt.Render) then
    begin
      ImgDesc.Init;
      ImgDesc.Usage.ColorAttachment := True;
      ImgDesc.Width := 64;
      ImgDesc.Height := 64;
      ImgDesc.PixelFormat := APixFmt;
      ImgDesc.SampleCount := 1;
      Render.Init(ImgDesc, True, TViewType.ColorAttachment);

      ACubeRenderPipDesc.Colors[0].PixelFormat := APixFmt;
      CubeRenderPip := TPipeline.Create(ACubeRenderPipDesc);

      ABGRenderPipDesc.Colors[0].PixelFormat := APixFmt;
      BGRenderPip := TPipeline.Create(ABGRenderPipDesc);
    end;

    { Create non-MSAA blend render target, pipeline states and pass-attachments }
    if (APixFmt.Blend) then
    begin
      ImgDesc.Init;
      ImgDesc.Usage.ColorAttachment := True;
      ImgDesc.Width := 64;
      ImgDesc.Height := 64;
      ImgDesc.PixelFormat := APixFmt;
      ImgDesc.SampleCount := 1;
      Blend.Init(ImgDesc, True, TViewType.ColorAttachment);

      ACubeBlendPipDesc.Colors[0].PixelFormat := APixFmt;
      CubeBlendPip := TPipeline.Create(ACubeBlendPipDesc);
    end;

    { Create MSAA render target and matching pipeline state }
    if (APixFmt.Msaa) then
    begin
      ImgDesc.Init;
      ImgDesc.Usage.ColorAttachment := True;
      ImgDesc.Width := 64;
      ImgDesc.Height := 64;
      ImgDesc.PixelFormat := APixFmt;
      ImgDesc.SampleCount := 4;
      MsaaRender.Init(ImgDesc, False, TViewType.ColorAttachment);

      ImgDesc.Init;
      ImgDesc.Usage.ResolveAttachment := True;
      ImgDesc.Width := 64;
      ImgDesc.Height := 64;
      ImgDesc.PixelFormat := APixFmt;
      ImgDesc.SampleCount := 1;
      MsaaResolve.Init(ImgDesc, True, TViewType.ResolveAttachment);

      ACubeMsaaPipDesc.Colors[0].PixelFormat := APixFmt;
      CubeMsaaPip := TPipeline.Create(ACubeMsaaPipDesc);

      ABGMsaaPipDesc.Colors[0].PixelFormat := APixFmt;
      BGMsaaPip := TPipeline.Create(ABGMsaaPipDesc);
    end;
  end;
end;

end.

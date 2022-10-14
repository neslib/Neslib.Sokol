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
    Sample: TImage;
    Filter: TImage;
    Render: TImage;
    Blend: TImage;
    Msaa: TImage;
    CubeRenderPip: TPipeline;
    CubeBlendPip: TPipeline;
    CubeMsaaPip: TPipeline;
    BGRenderPip: TPipeline;
    BGMsaaPip: TPipeline;
    RenderPass: TPass;
    BlendPass: TPass;
    MsaaPass: TPass;
  public
    procedure Init(const APixFmt: TPixelFormat; const ADefImage,
      ARenderDepthImage, AMsaaDepthImage: TImage; var ACubeRenderPipDesc,
      ABGRenderPipDesc, ACubeBlendPipDesc, ACubeMsaaPipDesc,
      ABGMsaaPipDesc: TPipelineDesc);
    procedure Free;

    procedure Draw(const ABGBindings, ACubeBindings: TBindings;
      const ABGFsParams: TBGFsParams; const ACubeVsParams: TCubeVsParams);
    procedure DrawImGui;
  end;

type
  TPixelFormatsApp = class(TSampleApp)
  private
    FFormat: array [TPixelFormat.R8..TPixelFormat.Depth] of TFormat;
    FCubeBindings: TBindings;
    FBGBindings: TBindings;
    FCubeVsParams: TCubeVsParams;
    FBGFsParams: TBGFsParams;
    FCubeShader: TShader;
    FBGShader: TShader;
    FRenderDepthImg: TImage;
    FMsaaDepthImg: TImage;
    FInvalidImg: TImage;
    FRX: Single;
    FRY: Single;
  private
    class function SetupInvalidTexture: TImage; static;
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
  Neslib.Sokol.Api;

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

procedure TPixelFormatsApp.Cleanup;
begin
  FRenderDepthImg.Free;
  FMsaaDepthImg.Free;
  FInvalidImg.Free;
  FCubeShader.Free;
  FBGShader.Free;
  FCubeBindings.VertexBuffers[0].Free;
  FCubeBindings.IndexBuffer.Free;
  FBGBindings.VertexBuffers[0].Free;

  for var PixFmt := TPixelFormat.R8 to TPixelFormat.Depth do
    FFormat[PixFmt].Free;
  inherited;
end;

procedure TPixelFormatsApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Pixelformat Test';
end;

procedure TPixelFormatsApp.ConfigureGfx(var ADesc: TGfxDesc);
begin
  inherited;
  ADesc.PipelinePoolSize := 256;
  ADesc.PassPoolSize := 128;
end;

procedure TPixelFormatsApp.DrawImGui;
begin
  ImGui.SetNextWindowSize(Vector2(500, 480), TImGuiCond.Once);
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
      FFormat[PixFmt].DrawImGui;
    ImGui.EndChild;
  end;
  ImGui.End;
end;

procedure TPixelFormatsApp.Frame;
begin
  { Compute model-view-projection matrix for vertex shader }
  var W := FramebufferWidth;
  var H := FramebufferHeight;
  var T: Single := FrameDuration * 60;

  { Compute the model-view-proj matrix for rendering to render targets }
  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), 1, 0.01, 10.0, True);
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
    FFormat[PixFmt].Draw(FBGBindings, FCubeBindings, FBGFsParams, FCubeVsParams);

  var PassAction := TPassAction.Create;
  PassAction.Colors[0].Init(TAction.Clear, 0, 0.5, 0.7, 1);

  TGfx.BeginDefaultPass(PassAction, W, H);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

class function TPixelFormatsApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TPixelFormatsApp.Init;
begin
  inherited;
  { Create all the textures and render targets }
  var ImgDesc := TImageDesc.Create;
  ImgDesc.RenderTarget := True;
  ImgDesc.Width := 64;
  ImgDesc.Height := 64;
  ImgDesc.PixelFormat := TPixelFormat.Depth;
  FRenderDepthImg := TImage.Create(ImgDesc);

  ImgDesc.SampleCount := 4;
  FMsaaDepthImg := TImage.Create(ImgDesc);

  FInvalidImg := SetupInvalidTexture;

  FCubeShader := TShader.Create(CubeShaderDesc);
  var CubeRenderPipDesc := TPipelineDesc.Create;
  CubeRenderPipDesc.Layout.Attrs[ATTR_VS_CUBE_POS].Format := TVertexFormat.Float3;
  CubeRenderPipDesc.Layout.Attrs[ATTR_VS_CUBE_COLOR0].Format := TVertexFormat.Float4;
  CubeRenderPipDesc.Shader := FCubeShader;
  CubeRenderPipDesc.IndexType := TIndexType.UInt16;
  CubeRenderPipDesc.CullMode := TCullMode.Back;
  CubeRenderPipDesc.Depth.WriteEnabled := True;
  CubeRenderPipDesc.Depth.PixelFormat := TPixelFormat.Depth;
  CubeRenderPipDesc.Depth.Compare := TCompareFunc.LessOrEqual;

  FBGShader := TShader.Create(BgShaderDesc);
  var BGRenderPipDesc := TPipelineDesc.Create;
  BGRenderPipDesc.Layout.Attrs[ATTR_VS_BG_POSITION].Format := TVertexFormat.Float2;
  BGRenderPipDesc.Shader := FBGShader;
  BGRenderPipDesc.PrimitiveType := TPrimitiveType.TriangleStrip;
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
    FFormat[PixFmt].Init(PixFmt, FInvalidImg, FRenderDepthImg, FMsaaDepthImg,
      CubeRenderPipDesc, BGRenderPipDesc, CubeBlendPipDesc, CubeMsaaPipDesc,
      BGMsaaPipDesc);
  end;

  { Cube vertex and index buffer }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  FCubeBindings.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.BufferType := TBufferType.IndexBuffer;
  BufferDesc.Data := TRange.Create(INDICES);
  FCubeBindings.IndexBuffer := TBuffer.Create(BufferDesc);

  { Background quad vertices }
  BufferDesc.Init;
  BufferDesc.Data := TRange.Create(QUAD_VERTICES);
  FBGBindings.VertexBuffers[0] := TBuffer.Create(BufferDesc);
end;

class function TPixelFormatsApp.SetupInvalidTexture: TImage;
{ Create a texture for "feature disabled" }
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
begin
  var ImgDesc := TImageDesc.Create;
  ImgDesc.Width := 8;
  ImgDesc.Height := 8;
  ImgDesc.Data.SubImages[0] := TRange.Create(DISABLED_TEXTURE_PIXELS);
  Result := TImage.Create(ImgDesc);
end;

{ TFormat }

procedure TFormat.Draw(const ABGBindings, ACubeBindings: TBindings;
  const ABGFsParams: TBGFsParams; const ACubeVsParams: TCubeVsParams);
begin
  if (not Valid) then
    Exit;

  var PassAction := TPassAction.Create;

  if (PixelFormat.Render) then
  begin
    TGfx.BeginPass(RenderPass, PassAction);

    TGfx.ApplyPipeline(BGRenderPip);
    TGfx.ApplyBindings(ABGBindings);
    TGfx.ApplyUniforms(TShaderStage.FragmentShader, SLOT_BG_FS_PARAMS,
      TRange.Create(ABGFsParams));
    TGfx.Draw(0, 4);

    TGfx.ApplyPipeline(CubeRenderPip);
    TGfx.ApplyBindings(ACubeBindings);
    TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_CUBE_VS_PARAMS,
      TRange.Create(ACubeVsParams));
    TGfx.Draw(0, 36);

    TGfx.EndPass;
  end;

  if (PixelFormat.Blend) then
  begin
    TGfx.BeginPass(BlendPass, PassAction);

    TGfx.ApplyPipeline(BGRenderPip);
    TGfx.ApplyBindings(ABGBindings);
    TGfx.ApplyUniforms(TShaderStage.FragmentShader, SLOT_BG_FS_PARAMS,
      TRange.Create(ABGFsParams));
    TGfx.Draw(0, 4);

    TGfx.ApplyPipeline(CubeBlendPip);
    TGfx.ApplyBindings(ACubeBindings);
    TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_CUBE_VS_PARAMS,
      TRange.Create(ACubeVsParams));
    TGfx.Draw(0, 36);

    TGfx.EndPass;
  end;

  if (PixelFormat.Msaa) then
  begin
    TGfx.BeginPass(MsaaPass, PassAction);

    TGfx.ApplyPipeline(BGMsaaPip);
    TGfx.ApplyBindings(ABGBindings);
    TGfx.ApplyUniforms(TShaderStage.FragmentShader, SLOT_BG_FS_PARAMS,
      TRange.Create(ABGFsParams));
    TGfx.Draw(0, 4);

    TGfx.ApplyPipeline(CubeMsaaPip);
    TGfx.ApplyBindings(ACubeBindings);
    TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_CUBE_VS_PARAMS,
      TRange.Create(ACubeVsParams));
    TGfx.Draw(0, 36);

    TGfx.EndPass;
  end;
end;

procedure TFormat.DrawImGui;
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
    'Rgba8SN',
    'Rgba8UI',
    'Rgba8SI',
    'Bgra8',
    'Rgb10A2',
    'Rg11B10F',
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
const
  WHITE: TAlphaColorF = (R: 1; G: 1; B: 1; A: 1);
begin
  if (not Valid) then
    Exit;

  if (ImGui.BeginChild(PIXEL_FORMAT_STRINGS[PixelFormat], Vector2(0, 80), False,
    [TImGuiWindowFlag.NoMouseInputs, TImGuiWindowFlag.NoScrollbar])) then
  begin
    ImGui.Text(PIXEL_FORMAT_STRINGS[PixelFormat]);
    ImGui.SameLine(106, 0);
    ImGui.Image(TImTextureID(Sample.Id), Vector2(64), White, White);
    ImGui.SameLine(0, 0);
    ImGui.Image(TImTextureID(Filter.Id), Vector2(64), White, White);
    ImGui.SameLine(0, 0);
    ImGui.Image(TImTextureID(Render.Id), Vector2(64), White, White);
    ImGui.SameLine(0, 0);
    ImGui.Image(TImTextureID(Blend.Id), Vector2(64), White, White);
    ImGui.SameLine(0, 0);
    ImGui.Image(TImTextureID(Msaa.Id), Vector2(64), White, White);
  end;
  ImGui.EndChild;
end;

procedure TFormat.Free;
begin
  if (Sample.Id <> DefImageId) then
    Sample.Free;

  if (Filter.Id <> DefImageId) then
    Filter.Free;

  if (Render.Id <> DefImageId) then
    Render.Free;

  if (Blend.Id <> DefImageId) then
    Blend.Free;

  if (Msaa.Id <> DefImageId) then
    Msaa.Free;

  CubeRenderPip.Free;
  BGRenderPip.Free;
  CubeBlendPip.Free;
  CubeMsaaPip.Free;
  BGMsaaPip.Free;

  RenderPass.Free;
  BlendPass.Free;
  MsaaPass.Free;
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
    TPixelFormat.Rgba8SN : Result := GenPixels32($7F7F7F7F);
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

procedure TFormat.Init(const APixFmt: TPixelFormat; const ADefImage,
  ARenderDepthImage, AMsaaDepthImage: TImage; var ACubeRenderPipDesc,
  ABGRenderPipDesc, ACubeBlendPipDesc, ACubeMsaaPipDesc,
  ABGMsaaPipDesc: TPipelineDesc);
begin
  PixelFormat := APixFmt;
  Valid := False;

  DefImageId := ADefImage.Id;
  Sample := ADefImage;
  Filter := ADefImage;
  Render := ADefImage;
  Blend := ADefImage;
  Msaa := ADefImage;

  var ImgData := GenPixels(APixFmt);
  if (ImgData.Data <> nil) then
  begin
    Valid := True;

    var ImgDesc: TImageDesc;
    var PassDesc: TPassDesc;

    { Create unfiltered texture }
    if APixFmt.Sample then
    begin
      ImgDesc := TImageDesc.Create;
      ImgDesc.Width := 8;
      ImgDesc.Height := 8;
      ImgDesc.PixelFormat := APixFmt;
      ImgDesc.Data.SubImages[0] := ImgData;
      Sample := TImage.Create(ImgDesc);
    end;

    { Create filtered texture }
    if APixFmt.Filter then
    begin
      ImgDesc := TImageDesc.Create;
      ImgDesc.Width := 8;
      ImgDesc.Height := 8;
      ImgDesc.PixelFormat := APixFmt;
      ImgDesc.MinFilter := TFilter.Linear;
      ImgDesc.MagFilter := TFilter.Linear;
      ImgDesc.Data.SubImages[0] := ImgData;
      Filter := TImage.Create(ImgDesc);
    end;

    { Create non-MSAA render target, pipeline state and pass }
    if APixFmt.Render then
    begin
      ImgDesc := TImageDesc.Create;
      ImgDesc.RenderTarget := True;
      ImgDesc.Width := 64;
      ImgDesc.Height := 64;
      ImgDesc.PixelFormat := APixFmt;
      Render := TImage.Create(ImgDesc);

      ACubeRenderPipDesc.Colors[0].PixelFormat := APixFmt;
      CubeRenderPip := TPipeline.Create(ACubeRenderPipDesc);

      ABGRenderPipDesc.Colors[0].PixelFormat := APixFmt;
      BGRenderPip := TPipeline.Create(ABGRenderPipDesc);

      PassDesc := TPassDesc.Create;
      PassDesc.ColorAttachments[0].Image := Render;
      PassDesc.DepthStencilAttachment.Image := ARenderDepthImage;
      RenderPass := TPass.Create(PassDesc);
    end;

    { Create non-MSAA blend render target, pipeline states and pass }
    if APixFmt.Blend then
    begin
      ImgDesc := TImageDesc.Create;
      ImgDesc.RenderTarget := True;
      ImgDesc.Width := 64;
      ImgDesc.Height := 64;
      ImgDesc.PixelFormat := APixFmt;
      Blend := TImage.Create(ImgDesc);

      ACubeBlendPipDesc.Colors[0].PixelFormat := APixFmt;
      CubeBlendPip := TPipeline.Create(ACubeBlendPipDesc);

      PassDesc := TPassDesc.Create;
      PassDesc.ColorAttachments[0].Image := Blend;
      PassDesc.DepthStencilAttachment.Image := ARenderDepthImage;
      BlendPass := TPass.Create(PassDesc);
    end;

    { Create MSAA render target and matching pipeline state }
    if APixFmt.Msaa then
    begin
      ImgDesc := TImageDesc.Create;
      ImgDesc.RenderTarget := True;
      ImgDesc.Width := 64;
      ImgDesc.Height := 64;
      ImgDesc.PixelFormat := APixFmt;
      ImgDesc.SampleCount := 4;
      Msaa := TImage.Create(ImgDesc);

      ACubeMsaaPipDesc.Colors[0].PixelFormat := APixFmt;
      CubeMsaaPip := TPipeline.Create(ACubeMsaaPipDesc);

      ABGMsaaPipDesc.Colors[0].PixelFormat := APixFmt;
      BGMsaaPip := TPipeline.Create(ABGMsaaPipDesc);

      PassDesc := TPassDesc.Create;
      PassDesc.ColorAttachments[0].Image := Msaa;
      PassDesc.DepthStencilAttachment.Image := AMsaaDepthImage;
      MsaaPass := TPass.Create(PassDesc);
    end;
  end;
end;

end.

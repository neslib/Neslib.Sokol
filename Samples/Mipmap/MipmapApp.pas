unit MipmapApp;
{ Demonstrate all the mipmapping filters. }
interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  MipmapShader;

type
  TPixels = record
  public
    Mip0: array [0..(256 * 256) - 1] of UInt32;
    Mip1: array [0..(128 * 128) - 1] of UInt32;
    Mip2: array [0..(64 * 64) - 1] of UInt32;
    Mip3: array [0..(32 * 32) - 1] of UInt32;
    Mip4: array [0..(16 * 16) - 1] of UInt32;
    Mip5: array [0..(8 * 8) - 1] of UInt32;
    Mip6: array [0..(4 * 4) - 1] of UInt32;
    Mip7: array [0..(2 * 2) - 1] of UInt32;
    Mip8: array [0..(1 * 1) - 1] of UInt32;
  end;

type
  TMipmapApp = class(TSampleApp)
  private
    FPip: TPipeline;
    FVBuf: TBuffer;
    FTexView: TView;
    FShader: TShader;
    FSmp: array [0..11] of TSampler;
    FPixels: TPixels;
    FR: Single;
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
  { A plane vertex buffer }
  VERTICES: array [0..19] of Single = (
    -1.0, -1.0, 0.0,  0.0, 0.0,
    +1.0, -1.0, 0.0,  1.0, 0.0,
    -1.0, +1.0, 0.0,  0.0, 1.0,
    +1.0, +1.0, 0.0,  1.0, 1.0);

const
  MIP_COLORS: array [0..8] of UInt32 = (
    $FF0000FF,     { red }
    $FF00FF00,     { green }
    $FFFF0000,     { blue }
    $FFFF00FF,     { magenta }
    $FFFFFF00,     { cyan }
    $FF00FFFF,     { yellow }
    $FFFF00A0,     { violet }
    $FFFFA0FF,     { orange }
    $FFA000FF);    { purple }

const
  FILTERS: array [0..1] of TFilter = (
    TFilter.Nearest,
    TFilter.Linear);

const
  MIPMAP_FILTERS: array [0..1] of TFilter = (
    TFilter.Nearest,
    TFilter.Linear);

{ TMipmapApp }

procedure TMipmapApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Mipmaps';
  AConfig.HighDpi := False;
end;

procedure TMipmapApp.Init;
begin
  inherited;
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  FVBuf := TBuffer.Create(BufferDesc);

  { Initialize mipmap content, different colors and checkboard pattern }
  var ImgData: TImageData;
  var Ptr := PCardinal(@FPixels.Mip0);
  var EvenOdd := False;
  for var MipIndex := 0 to 8 do
  begin
    var Dim := 1 shl (8 - MipIndex);
    ImgData.MipLevels[MipIndex] := TRange.Create(Ptr, Dim * Dim * 4);
    for var Y := 0 to Dim - 1 do
    begin
      for var X := 0 to Dim - 1 do
      begin
        if (EvenOdd) then
          Ptr^ := MIP_COLORS[MipIndex]
        else
          Ptr^ := $FF000000;

        Inc(Ptr);
        EvenOdd := not EvenOdd;
      end;
      EvenOdd := not EvenOdd;
    end;
  end;

  var ImgDesc := TImageDesc.Create;
  ImgDesc.Width := 256;
  ImgDesc.Height := 256;
  ImgDesc.NumMipmaps := 9;
  ImgDesc.PixelFormat := TPixelFormat.Rgba8;
  ImgDesc.Data := ImgData;
  var Img := TImage.Create(ImgDesc);

  { ...and a texture view for the image }
  var ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := Img;
  FTexView := TView.Create(ViewDesc);

  { The first 4 samplers are just different min-filters }
  var SmpDesc := TSamplerDesc.Create;
  SmpDesc.MagFilter := TFilter.Linear;

  var SmpIndex := 0;
  for var I := 0 to 1 do
    for var J := 0 to 1 do
    begin
      SmpDesc.MinFilter := FILTERS[I];
      SmpDesc.MipmapFilter := MIPMAP_FILTERS[J];
      FSmp[SmpIndex] := TSampler.Create(SmpDesc);
      Inc(SmpIndex);
    end;

  { The next 4 samplers use MinLod/MaxLod }
  SmpDesc.MinLod := 2;
  SmpDesc.MaxLod := 4;
  for var I := 0 to 1 do
    for var J := 0 to 1 do
    begin
      SmpDesc.MinFilter := FILTERS[I];
      SmpDesc.MipmapFilter := MIPMAP_FILTERS[J];
      FSmp[SmpIndex] := TSampler.Create(SmpDesc);
      Inc(SmpIndex);
    end;

  { The last 4 samplers use different anistropy levels }
  SmpDesc.MinLod := 0;
  SmpDesc.MaxLod := 0; { MaxLod = 0 means Single.MaxValue }
  SmpDesc.MinFilter := TFilter.Linear;
  SmpDesc.MagFilter := TFilter.Linear;
  for var I := 0 to 3 do
  begin
    SmpDesc.MaxAnisotropy := 1 shl I;
    FSmp[SmpIndex] := TSampler.Create(SmpDesc);
    Inc(SmpIndex);
  end;
  Assert(SmpIndex = 12);

  FShader := TShader.Create(MipmapShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Attrs[ATTR_MIPMAP_POS].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_MIPMAP_UV0].Format := TVertexFormat.Float2;
  PipDesc.Shader := FShader;
  PipDesc.PrimitiveType := TPrimitiveType.TriangleStrip;

  FPip := TPipeline.Create(PipDesc);
end;

procedure TMipmapApp.Frame;
begin
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var Proj, View, RM, Translate, Model: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(90), W / H, 0.01, 10.0);
  View.InitLookAtRH(Vector3(0, 0, 3.5), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  FR := FR + (0.1 * 60 * FrameDuration);
  RM.InitRotationX(Radians(FR));

  var Bind := TBindings.Create;
  Bind.VertexBuffers[0] := FVBuf;
  Bind.Views[VIEW_TEX] := FTexView;

  var Pass := TPass.Create;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FPip);

  for var I := 0 to 11 do
  begin
    var X: Single := ((I and 3) - 1.5) *  2.0;
    var Y: Single := ((I shr 2) - 1.0) * -2.0;
    Translate.InitTranslation(X, Y, 0);
    Model := Translate * RM;
    var VSParams: TVSParams;
    VSParams.MVP := ViewProj * Model;

    Bind.Samplers[SMP_SMP] := FSmp[I];
    TGfx.ApplyBindings(Bind);
    TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(VSParams));
    TGfx.Draw(0, 4);
  end;

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TMipmapApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

end.

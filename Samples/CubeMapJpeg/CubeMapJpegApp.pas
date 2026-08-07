unit CubeMapJpegApp;
{ Load and render cubemap from individual jpeg files. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Fetch,
  Neslib.FastMath,
  Camera,
  SampleApp,
  CubeMapJpegShader;

type
  TCubeMapJpegApp = class(TSampleApp)
  private const
    { Room for loading all cubemap faces in parallel }
    NUM_FACES      = 6;
    FACE_WIDTH     = 2048;
    FACE_HEIGHT    = 2048;
    FACE_NUM_BYTES = (FACE_WIDTH * FACE_HEIGHT * 4);
  private
    FPassAction: TPassAction;
    FPip: TPipeline;
    FBind: TBindings;
    FCamera: TCamera;
    FLoadCount: Integer;
    FLoadFailed: Boolean;
    FPixels: TRange;
  private
    function CubefaceRange(const AFaceIndex: Integer): TFetchRange;
    procedure FetchCallback(const AResponse: TFetchResponse);
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  System.SysUtils,
  Neslib.Stb.Image,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue,
  Neslib.Sokol.DebugText;

const
  VERTICES: array [0..71] of Single = (
    -1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,
     1.0,  1.0, -1.0,
    -1.0,  1.0, -1.0,

    -1.0, -1.0,  1.0,
     1.0, -1.0,  1.0,
     1.0,  1.0,  1.0,
    -1.0,  1.0,  1.0,

    -1.0, -1.0, -1.0,
    -1.0,  1.0, -1.0,
    -1.0,  1.0,  1.0,
    -1.0, -1.0,  1.0,

     1.0, -1.0, -1.0,
     1.0,  1.0, -1.0,
     1.0,  1.0,  1.0,
     1.0, -1.0,  1.0,

    -1.0, -1.0, -1.0,
    -1.0, -1.0,  1.0,
     1.0, -1.0,  1.0,
     1.0, -1.0, -1.0,

    -1.0,  1.0, -1.0,
    -1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0, -1.0);

const
  INDICES: array [0..35] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20);

{ TCubeMapJpegApp }

procedure TCubeMapJpegApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 1;
  AConfig.WindowTitle := 'Cube Jpeg';
end;

procedure TCubeMapJpegApp.Init;
const
  FILENAMES: array [0..NUM_FACES - 1] of String = (
    'nb2_posx.jpg', 'nb2_negx.jpg',
    'nb2_posy.jpg', 'nb2_negy.jpg',
    'nb2_posz.jpg', 'nb2_negz.jpg');
begin
  inherited;
  var DbgTextDesc := TDbgTextDesc.Create;
  DbgTextDesc.Fonts[0] := TDbgTextFont.Oric;
  DbgTextDesc.UseDelphiMemoryManager := True;
  DbgTextDesc.Logger := DbgTextDesc.DefaultLogger;
  TDbgText.Setup(DbgTextDesc);

  { Setup Neslib.Sokol.Fetch to load 6 faces in parallel }
  var FetchDesc := TFetchDesc.Create;
  FetchDesc.MaxRequests := 6;
  FetchDesc.NumChannels := 1;
  FetchDesc.NumLanes := NUM_FACES;
  FetchDesc.BaseDirectory := 'Data/NissiBeach2';
  FetchDesc.Logger := FetchDesc.DefaultLogger;
  TFetch.Setup(FetchDesc);

  { Setup camera helper }
  var CameraDesc := TCameraDesc.Create;
  CameraDesc.Latitude := 0;
  CameraDesc.Longitude := 0;
  CameraDesc.Distance := 0.1;
  CameraDesc.MinDist := 0.1;
  CameraDesc.MaxDist := 0.1;
  FCamera := TCamera.Create(CameraDesc);

  { Allocate memory for pixel data (both as io buffer for JPEG data, and for the
    decoded pixel data) }
  var PixelData: TBytes;
  SetLength(PixelData, NUM_FACES * FACE_NUM_BYTES);
  FPixels := TRange.Create(PixelData);

  { Pass action, clear to black }
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0, 0, 0, 1);

  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'CubeMapVertices';
  FBind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.Usage.IndexBuffer := True;
  BufferDesc.Data := TRange.Create(INDICES);
  BufferDesc.TraceLabel := 'CubeMapIndices';
  FBind.IndexBuffer := TBuffer.Create(BufferDesc);

  { Allocate a (texture) view handle, but only set it up later once the texture
    data has been asynchronously loaded. This allows us to write a regular
    render loop without having to explicitly skip rendering as long as the
    texture isn't loaded yet }
  var View: TView;
  View.Allocate;
  FBind.Views[VIEW_TEX] := View;

  { A sampler object }
  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Linear;
  SamplerDesc.MagFilter := TFilter.Linear;
  SamplerDesc.TraceLabel := 'CubeMapSampler';
  FBind.Samplers[SMP_SMP] := TSampler.Create(SamplerDesc);

  { A pipeline object }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Attrs[ATTR_CUBEMAP_POS].Format := TVertexFormat.Float3;
  PipDesc.Shader := TShader.Create(CubemapShaderDesc);
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.TraceLabel := 'CubeMapPipeline';
  FPip := TPipeline.Create(PipDesc);

  { Load 6 cubemap face image files. Note that the faces must be in order
    +X, -X, +Y, -Y, +Z, -Z }
  for var I := 0 to NUM_FACES - 1 do
  begin
    var FetchRequest := TFetchRequest.Create(FILENAMES[I], FetchCallback,
      CubefaceRange(I));
    FetchRequest.Send;
  end;
end;

procedure TCubeMapJpegApp.Frame;
begin
  TFetch.DoWork;
  FCamera.Update(FramebufferWidth, FramebufferHeight);

  var VSParams: TVSParams;
  VSParams.Mvp := FCamera.ViewProj;

  TDbgText.Canvas(FramebufferWidth * 0.5, FramebufferHeight * 0.5);
  TDbgText.Origin(1, 3);
  if (FLoadFailed) then
    TDbgText.Write('LOAD FAILED!')
  else if (FLoadCount < 6) then
    TDbgText.Write('LOADING...')
  else
    TDbgText.Write('Drag to look around');

  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyBindings(FBind);
  TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(VSParams));

  TGfx.Draw(0, 36);
  TDbgText.Draw;

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TCubeMapJpegApp.Cleanup;
begin
  inherited;
  TFetch.Shutdown;
  TDbgText.Shutdown;
  FCamera.Free;
end;

function TCubeMapJpegApp.CubefaceRange(const AFaceIndex: Integer): TFetchRange;
begin
  Assert(Cardinal(AFaceIndex) < Cardinal(NUM_FACES));
  var Offset := AFaceIndex * FACE_NUM_BYTES;
  Assert(Cardinal(Offset + FACE_NUM_BYTES) <= FPixels.Size);
  Result := TFetchRange.Create(PByte(FPixels.Data) + Offset, FACE_NUM_BYTES);
end;

procedure TCubeMapJpegApp.FetchCallback(const AResponse: TFetchResponse);
const
  DESIRED_CHANNELS = 4;
begin
  if (AResponse.Fetched) then
  begin
    { Decode loaded JPEG data via Neslib.Stb.Image }
    var StbImage := TStbImage.Create;
    try
      if (StbImage.Load(AResponse.Data.Ptr, AResponse.Data.Size, DESIRED_CHANNELS)) then
      begin
        Assert(StbImage.Width = FACE_WIDTH);
        Assert(StbImage.Height = FACE_HEIGHT);

        { Overwrite JPEG data with decoded pixel data }
        Move(StbImage.Data^, AResponse.Data.Ptr^, FACE_NUM_BYTES);

      end
    finally
      StbImage.Free;
    end;

    { All 6 faces loaded? }
    Inc(FLoadCount);
    if (FLoadCount = NUM_FACES) then
    begin
      { Create a cubemap image }
      var ImgDesc := TImageDesc.Create;
      ImgDesc.ImageType := TImageType.Cube;
      ImgDesc.Width := FACE_WIDTH;
      ImgDesc.Height := FACE_HEIGHT;
      ImgDesc.PixelFormat := TPixelFormat.Rgba8;
      ImgDesc.Data.MipLevels[0] := FPixels;
      ImgDesc.TraceLabel := 'CubeMapImage';
      var Image := TImage.Create(ImgDesc);

      { Don't need pixel data anymore }
      FPixels := TRange.Create(nil, 0);

      { ...and setup the pre-allocated view }
      var ViewDesc := TViewDesc.Create;
      ViewDesc.Texture.Image := Image;
      ViewDesc.TraceLabel := 'CubeMapView';
      FBind.Views[VIEW_TEX].Setup(ViewDesc);
    end;
  end
  else if (AResponse.Failed) then
    FLoadFailed := True;
end;

end.

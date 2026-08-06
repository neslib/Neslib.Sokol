unit SpineLayersApp;
{ Use layered rendering to mix Neslib.Sokol.Spine and Neslib.Sokol.GL rendering. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Spine,
  Neslib.Sokol.Fetch,
  Neslib.FastMath,
  SampleApp;

const
  NUM_INSTANCES = 3;

type
  TSpineLayersApp = class(TSampleApp)
  private type
    TStatus = record
    public
      Loaded: Boolean;
      Data: TSpineRange;
    end;
  private type
    TLoadStatus = record
    public
      Atlas: TStatus;
      Skeleton: TStatus;
      Failed: Boolean;
    end;
  private type
    TBuffers = record
    public
      Atlas: array [0..(16 * 1024) - 1] of Byte;
      Skeleton: array [0..(512 * 1024) - 1] of Byte;
      Image: array [0..(512 * 1024) - 1] of Byte;
    end;
  private
    FAtlas: TSpineAtlas;
    FSkeleton: TSpineSkeleton;
    FInstances: array [0..NUM_INSTANCES - 1] of TSpineInstance;
    FPassAction: TPassAction;
    FLoadStatus: TLoadStatus;
    FBuffers: TBuffers;
  private
    procedure AtlasDataLoaded(const AResponse: TFetchResponse);
    procedure SkeletonDataLoaded(const AResponse: TFetchResponse);
    procedure ImageDataLoaded(const AResponse: TFetchResponse);
    procedure CreateSpineObjects;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Stb.Image,
  Neslib.Sokol.Api,
  Neslib.Sokol.GL,
  Neslib.Sokol.Glue;

{ TSpineLayersApp }

procedure TSpineLayersApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 1024;
  AConfig.Height := 768;
  AConfig.WindowTitle := 'Spine - Layers';
end;

procedure TSpineLayersApp.Init;
begin
  inherited;
  var SpineDesc := TSpineDesc.Create;
  SpineDesc.UseDelphiMemoryManager := True;
  SpineDesc.Logger := SpineDesc.DefaultLogger;
  TSpine.Setup(SpineDesc);

  var GLDesc := TGLDesc.Create;
  GLDesc.UseDelphiMemoryManager := True;
  GLDesc.Logger := GLDesc.DefaultLogger;
  sglSetup(GLDesc);

  var FetchDesc := TFetchDesc.Create;
  FetchDesc.MaxRequests := 3;
  FetchDesc.NumChannels := 2;
  FetchDesc.NumLanes := 1;
  FetchDesc.Logger := FetchDesc.DefaultLogger;
  FetchDesc.BaseDirectory := 'Data/Spine';
  TFetch.Setup(FetchDesc);

  { Setup a pass action to clear the screen }
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0, 0, 0, 1);

  { Start loading the spine atlas and skeleton file. }
  var Request := TFetchRequest.Create('speedy-pma.atlas', AtlasDataLoaded,
    TFetchRange.Create(FBuffers.Atlas));
  Request.Channel := 0;
  Request.Send;

  Request := TFetchRequest.Create('speedy-ess.skel', SkeletonDataLoaded,
    TFetchRange.Create(FBuffers.Skeleton));
  Request.Channel := 1;
  Request.Send;
end;

procedure TSpineLayersApp.Frame;
const
  NUM_BARS = 30;
  BAR_WIDTH_HALF = 0.0075;
begin
  var DeltaTime: Single := FrameDuration;
  TFetch.DoWork;

  { Use a fixed 'virtual' canvas size for the spine layer transform so that the
    spine scene scales with the window size }
  var LayerTransform: TSpineLayerTransform;
  LayerTransform.Size := Vector2(1024, 768);
  LayerTransform.Origin := Vector2(512, 384);

  { Draw 3 layers of vertical bars with Neslib.Sokol.GL. Note how the order how
    we handle Neslib.Sokol.GL vs Neslib.Sokol.Spine rendering doesn't matter
    outside the Neslib.Sokol.Gfx render pass }
  sglDefaults;
  for var LayerIndex := 0 to 2 do
  begin
    sglLayer(LayerIndex);
    case LayerIndex of
      0: sglC3F(0, 0, 1);
      1: sglC3F(0, 1, 0);
      2: sglC3F(1, 0, 0);
    end;
    sglBeginQuads;
    var BarOffsetX: Single := LayerIndex * 0.02;
    for var I := 0 to NUM_BARS do
    begin
      var X: Single := BarOffsetX + ((I * (1 / NUM_BARS)) * 2 - 1);
      var X0: Single := X - BAR_WIDTH_HALF;
      var X1: Single := X + BAR_WIDTH_HALF;
      sglV2F(X0, -1);
      sglV2F(X1, -1);
      sglV2F(X1,  1);
      sglV2F(X0,  1);
    end;
    sglEnd;
  end;

  { Draw spine instances into different layers }
  FInstances[0].Position := Vector2(-225, 128);
  FInstances[0].Update(DeltaTime);
  FInstances[0].Draw(0);

  FInstances[1].Position := Vector2(0, 128);
  FInstances[1].Update(DeltaTime);
  FInstances[1].Draw(1);

  FInstances[2].Position := Vector2(225, 128);
  FInstances[2].Update(DeltaTime);
  FInstances[2].Draw(2);

  { Neslib.Sokol.Gfx render pass. Draw the Neslib.Sokol.GL and
    Neslib.Sokol.Spine layers interleaved }

  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  for var LayerIndex := 0 to 2 do
  begin
    TSpine.DrawLayer(LayerIndex, LayerTransform);
    sglDrawLayer(LayerIndex);
  end;

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TSpineLayersApp.Cleanup;
begin
  TFetch.Shutdown;
  sglShutdown;
  TSpine.Shutdown;
  inherited;
end;

procedure TSpineLayersApp.SkeletonDataLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
  begin
    { Skeleton data was successfully loaded }
    FLoadStatus.Skeleton.Loaded := True;
    FLoadStatus.Skeleton.Data := TSpineRange.Create(AResponse.Data.Ptr, AResponse.Data.Size);

    { When both atlas and skeleton files have finished loading, create the spine objects }
    if (FLoadStatus.Atlas.Loaded) then
      CreateSpineObjects;
  end
  else if (AResponse.Failed) then
    { Loading the skeleton data failed }
    FLoadStatus.Failed := True;
end;

procedure TSpineLayersApp.AtlasDataLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
  begin
    { Atlas data was successfully loaded }
    FLoadStatus.Atlas.Loaded := True;
    FLoadStatus.Atlas.Data := TSpineRange.Create(AResponse.Data.Ptr, AResponse.Data.Size);

    { When both atlas and skeleton files have finished loading, create the spine objects }
    if (FLoadStatus.Skeleton.Loaded) then
      CreateSpineObjects;
  end
  else if (AResponse.Failed) then
    { Loading the atlas failed }
    FLoadStatus.Failed := True;
end;

procedure TSpineLayersApp.CreateSpineObjects;
{ This function is called when both the spine atlas and skeleton file has been
  loaded. First an atlas object is created from the loaded atlas data, and then
  a skeleton object (which requires an atlas object as dependency), then a spine
  instance object. Finally any images required by the atlas object are loaded }
begin
  { Create spine atlas object from loaded atlas data. }
  var AtlasDesc := TSpineAtlasDesc.Create;
  AtlasDesc.Data := FLoadStatus.Atlas.Data;
  FAtlas := TSpineAtlas.Create(AtlasDesc);
  Assert(FAtlas.Valid);

  { Next create a spine skeleton object. }
  var SkeletonDesc := TSpineSkeletonDesc.Create;
  SkeletonDesc.Atlas := FAtlas;
  SkeletonDesc.BinaryData := FLoadStatus.Skeleton.Data;
  SkeletonDesc.AnimDefaultMix := 0.2;
  FSkeleton := TSpineSkeleton.Create(SkeletonDesc);
  Assert(FSkeleton.Valid);

  { Create the spine instance objects. }
  for var I := 0 to NUM_INSTANCES - 1 do
  begin
    var InstanceDesc := TSpineInstanceDesc.Create;
    InstanceDesc.Skeleton := FSkeleton;
    FInstances[I] := TSpineInstance.Create(InstanceDesc);
    Assert(FInstances[I].Valid);
    FInstances[I].SetAnimation(FSkeleton.AnimByName('run-linear'), 0, True);
  end;

  { Finally start loading any atlas image files. }
  for var ImgIndex := 0 to FAtlas.ImageCount - 1 do
  begin
    var Img := FAtlas.Images[ImgIndex];
    var ImgInfo := Img.Info;
    Assert(ImgInfo.Valid);
    var Request := TFetchRequest.Create(ImgInfo.Filename, ImageDataLoaded,
      TFetchRange.Create(FBuffers.Image));
    Request.Channel := 0;
    Request.UserData := TFetchRange.Create(Img);
    Request.Send;
  end;
end;

procedure TSpineLayersApp.ImageDataLoaded(const AResponse: TFetchResponse);
{ This is the image-data fetch callback. The loaded image data will be decoded
  via Neslib.Stb.Image and a Neslib.Sokol.Gfx image object will be created. }
const
  DESIRED_CHANNELS = 4;
begin
  { Retrieve the TSpineImage handle from user data and look up image info with
    image setup parameters. }
  var Img := PSpineImage(AResponse.UserData)^;
  var ImgInfo := Img.Info;
  if (AResponse.Fetched) then
  begin
    { Decode pixels via Neslib.Stb.Image }
    var StbImage := TStbImage.Create;
    try
      if (StbImage.Load(AResponse.Data.Ptr, AResponse.Data.Size, DESIRED_CHANNELS)) then
      begin
        { Neslib.Sokol.Spine has already allocated an image, view and sampler
          handle. Just need to call Setup on these to complete setup. }
        var ImgDesc := TImageDesc.Create;
        ImgDesc.Width := StbImage.Width;
        ImgDesc.Height := StbImage.Height;
        ImgDesc.PixelFormat := TPixelFormat.Rgba8;
        ImgDesc.TraceLabel := UTF8String(ImgInfo.Filename.ToString);
        ImgDesc.Data.MipLevels[0] := TRange.Create(StbImage.Data,
          StbImage.Width * StbImage.Height * 4);
        ImgInfo.Image.Setup(ImgDesc);

        var ViewDesc := TViewDesc.Create;
        ViewDesc.Texture.Image := ImgInfo.Image;
        ImgInfo.View.Setup(ViewDesc);

        var SamplerDesc := TSamplerDesc.Create;
        SamplerDesc.MinFilter := ImgInfo.MinFilter;
        SamplerDesc.MagFilter := ImgInfo.MagFilter;
        SamplerDesc.MipmapFilter := ImgInfo.MipmapFilter;
        SamplerDesc.WrapU := ImgInfo.WrapU;
        SamplerDesc.WrapV := ImgInfo.WrapV;
        SamplerDesc.TraceLabel := UTF8String(ImgInfo.Filename.ToString);
        ImgInfo.Sampler.Setup(SamplerDesc);
      end
      else
      begin
        FLoadStatus.Failed := True;
        ImgInfo.Image.Fail;
      end;
    finally
      StbImage.Free;
    end;
  end
  else
  begin
    FLoadStatus.Failed := True;
    ImgInfo.Image.Fail;
  end;
end;

end.

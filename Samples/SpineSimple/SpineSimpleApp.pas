unit SpineSimpleApp;
{ An annotated 'simplest possible' Neslib.Sokol.Spline sample. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Spine,
  Neslib.Sokol.Fetch,
  Neslib.FastMath,
  SampleApp;

type
  TSpineSimpleApp = class(TSampleApp)
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
      Atlas: array [0..(4 * 1024) - 1] of Byte;
      Skeleton: array [0..(128 * 1024) - 1] of Byte;
      Image: array [0..(512 * 1024) - 1] of Byte;
    end;
  private
    FAtlas: TSpineAtlas;
    FSkeleton: TSpineSkeleton;
    FInstance: TSpineInstance;
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
  Neslib.Sokol.Glue;

{ TSpineSimpleApp }

procedure TSpineSimpleApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 1024;
  AConfig.Height := 768;
  AConfig.DepthFormat := TAppPixelFormat.None;
  AConfig.WindowTitle := 'Spine - Simple';
end;

procedure TSpineSimpleApp.Init;
begin
  inherited;

  { Setup Neslib.Sokol.Spine. Must be done *after* Neslib.Sokol.Gfx setup (which
    is done in the inherited Init). If desired, memory usage can be tuned by
    setting the max number of vertices, draw commands and pool sizes. }
  var SpineDesc := TSpineDesc.Create;
  SpineDesc.MaxVertices := 6 * 1024;
  SpineDesc.MaxCommands := 16;
  SpineDesc.AtlasPoolSize := 1;
  SpineDesc.SkeletonPoolSize := 1;
  SpineDesc.SkinsetPoolSize := 1;
  SpineDesc.InstancePoolSize := 1;
  SpineDesc.UseDelphiMemoryManager := True;
  SpineDesc.Logger := SpineDesc.DefaultLogger;
  TSpine.Setup(SpineDesc);

  { We'll use Neslib.Sokol.Fetch for data loading because this gives us
    asynchronous file loading. The only downside is that spine initialization is
    spread over a couple of callbacks and frames.
    Configure Neslib.Sokol.Fetch so that atlas and skeleton file data are loaded
    in parallel across 2 channels. }
  var FetchDesc := TFetchDesc.Create;
  FetchDesc.MaxRequests := 3;
  FetchDesc.NumChannels := 2;
  FetchDesc.NumLanes := 1;
  FetchDesc.Logger := FetchDesc.DefaultLogger;
  FetchDesc.BaseDirectory := 'Data/Spine';
  TFetch.Setup(FetchDesc);

  { Setup a pass action to clear the default framebuffer to black (used in
    TGfx.BeginPass down in the Frame method) }
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0, 0, 0, 1);

  { Start loading the spine atlas and skeleton file. This happens asynchronously
    and in undefined finish-order. The 'fetch callbacks' will be called when the
    data has finished loading (or an error occurs).
    Neslib.Sokol.Spine itself doesn't care about how the data is loaded, it
    expects all data in memory chunks.

    Note: the callbacks are called in undefined order, but the spine atlas must
    be created before the skeleton (because the skeleton creation functions
    needs an atlas handle). This ordering problem is solved by both callbacks
    checking whether the other callback has already finished, and if yes a
    common function 'CreateSpineObjects' is called. }
  var Request := TFetchRequest.Create('raptor-pma.atlas', AtlasDataLoaded,
    TFetchRange.Create(FBuffers.Atlas));
  Request.Channel := 0;
  Request.Send;

  Request := TFetchRequest.Create('raptor-pro.skel', SkeletonDataLoaded,
    TFetchRange.Create(FBuffers.Skeleton));
  Request.Channel := 1;
  Request.Send;
end;

procedure TSpineSimpleApp.Frame;
begin
  { Need to call TFetch.DoWork once per frame, otherwise data loading will
    appear to be stuck. }
  TFetch.DoWork;

  { The frame duration in seconds is needed for advancing the spine animations }
  var DeltaTime: Single := FrameDuration;

  { Use the window size for the spine canvas. This means that 'spine pixels'
    will map 1:1 to framebuffer pixels, with [0,0] in the center }
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var LayerTransform: TSpineLayerTransform;
  LayerTransform.Size := Vector2(W, H);
  LayerTransform.Origin := Vector2(W * 0.5, H * 0.5);

  { Advance the instance animation and draw the instance.
    Important to note here is that no actual Neslib.Sokol.Gfx rendering happens
    yet. Instead Neslib.Sokol.Spine will only record vertices, indices and draw
    commands. Also, all spine functions can be called with invalid or 'incomplete'
    handles. That way we don't need to care about whether the spine objects
    have actually been created yet (because their data might still be loading) }
  FInstance.Update(DeltaTime);
  FInstance.Draw;

  { The actual Neslib.Sokol.Gfx render pass. Here we also don't need to care
    about if the atlas image have already been loaded yet. If the image handles
    recorded by Neslib.Sokol.Spine for rendering are not yet valid, rendering
    operations will silently be skipped. }
  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TSpine.DrawLayer(0, LayerTransform);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TSpineSimpleApp.Cleanup;
begin
  TFetch.Shutdown;

  { Shutdown Spine before shutting down TGfx }
  TSpine.Shutdown;
  inherited;
end;

procedure TSpineSimpleApp.SkeletonDataLoaded(const AResponse: TFetchResponse);
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

procedure TSpineSimpleApp.AtlasDataLoaded(const AResponse: TFetchResponse);
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

procedure TSpineSimpleApp.CreateSpineObjects;
{ This function is called when both the spine atlas and skeleton file has been
  loaded. First an atlas object is created from the loaded atlas data, and then
  a skeleton object (which requires an atlas object as dependency), then a spine
  instance object. Finally any images required by the atlas object are loaded }
begin
  { Create spine atlas object from loaded atlas data. }
  var AtlasDesc := TSpineAtlasDesc.Create;
  AtlasDesc.Data := FLoadStatus.Atlas.Data;
  FAtlas := TSpineAtlas.Create(AtlasDesc);

  { Next create a spine skeleton object. Skeleton data files can be either
    text (JSON) or binary (in our case, 'raptor-pro.skel' is a binary skeleton
    file). In case of JSON data, make sure that the data is 0-terminated! }
  var SkeletonDesc := TSpineSkeletonDesc.Create;
  SkeletonDesc.Atlas := FAtlas;
  SkeletonDesc.BinaryData := FLoadStatus.Skeleton.Data;
  { We can pre-scale the skeleton }
  SkeletonDesc.Prescale := 0.5;
  { And set the default animation mixing/cross-fading time }
  SkeletonDesc.AnimDefaultMix := 0.2;
  FSkeleton := TSpineSkeleton.Create(SkeletonDesc);

  { Create a spine instance object. That's the thing that's actually rendered }
  var InstanceDesc := TSpineInstanceDesc.Create;
  InstanceDesc.Skeleton := FSkeleton;
  FInstance := TSpineInstance.Create(InstanceDesc);

  { Since the spine instance doesn't move, its position can be set once. The
    coordinate units depends on the TSpineLayerTransform record that's passed to
    TSpine.DrawLayer during rendering (in our case it's simply framebuffer
    pixels, with the origin in the center) }
  FInstance.Position := Vector2(-100, 200);

  { Configure a simple animation sequence (jump => roar => walk) }
  FInstance.SetAnimation(FSkeleton.AnimByName('jump'));
  FInstance.AddAnimation(FSkeleton.AnimByName('roar'));
  FInstance.AddAnimation(FSkeleton.AnimByName('walk'), 0, True);

  { Finally start loading any atlas image files. One image file seems to be
    common, but apparently atlases can also reference multiple images.
    Image loading also happens asynchronously via Neslib.Sokol.Fetch, and the
    actual image creation happens in the fetch-callback. }
  for var ImgIndex := 0 to FAtlas.ImageCount - 1 do
  begin
    var Img := FAtlas.Images[ImgIndex];
    var ImgInfo := Img.Info;

    { We'll store the TSpineImage handle in the fetch request's user data blob,
      because we need the image info again later in the fetch callback in order
      to initialize the Neslib.Sokol.Gfx image with the right parameters.

      Also important to note: all image fetch requests load their data into the
      same buffer. This is fine because Neslib.Sokol.Fetch has been configured
      with NumLanes=1. This will cause all requests on the same channel to be
      serialized (not run in parallel). That way the same buffer can be reused
      even if there are multiple atlas images. The downside is that loading
      multiple images would take longer. }
    var Request := TFetchRequest.Create(ImgInfo.Filename, ImageDataLoaded,
      TFetchRange.Create(FBuffers.Image));
    Request.Channel := 0;
    Request.UserData := TFetchRange.Create(Img);
    Request.Send;
  end;
end;

procedure TSpineSimpleApp.ImageDataLoaded(const AResponse: TFetchResponse);
{ This is the image-data fetch callback. The loaded image data will be decoded
  via Neslib.Stb.Image and a Neslib.Sokol.Gfx image object will be created.

  What's interesting here is that we're using Gfx's multi-step image setup.
  Neslib.Sokol.Spine has already allocated an image handle for each atlas image
  in TSpineAtlas.Create via TImage.Alloc.

  The fetch callback just needs to finish the image setup by calling
  TImage.Setup, or if loading has failed, put the image object into the 'failed'
  resource state. }
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
        { Decoding has failed }
        FLoadStatus.Failed := True;

        { It's not strictly necessary, but it's better here to put the
          Gfx image object into the 'failed' resource state (otherwise it would
          be stuck in the 'alloc' state) }
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

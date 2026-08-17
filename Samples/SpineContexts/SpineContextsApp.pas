unit SpineContextsApp;
{ Test/demonstrate Spine rendering into Neslib.Sokol.Gfx offscreen passes
  Neslib.Sokol.Spine contexts. }

interface

uses
  System.UITypes,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Spine,
  Neslib.Sokol.Fetch,
  Neslib.FastMath,
  SampleApp;

type
  TSpineContextsApp = class(TSampleApp)
  private type
    TOffscreen = record
    public
      Context: TSpineContext;
      Image: TImage;
      TexView: TView;
      AttView: TView;
      Pass: TPass;
    public
      procedure Setup(const AFormat: TPixelFormat; const AWidthHeight: Integer;
        const AClearColor: TColor);
    end;
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
    FOffscreen: array [0..1] of TOffscreen;
    FSampler: TSampler;
    FAtlas: TSpineAtlas;
    FSkeleton: TSpineSkeleton;
    FInstances: array [0..1] of TSpineInstance;
    FLayerTransform: TSpineLayerTransform;
    FAngleDeg: Single;
    FLoadStatus: TLoadStatus;
    FBuffers: TBuffers;
  private
    procedure AtlasDataLoaded(const AResponse: TFetchResponse);
    procedure SkeletonDataLoaded(const AResponse: TFetchResponse);
    procedure ImageDataLoaded(const AResponse: TFetchResponse);
    procedure CreateSpineObjects;
    procedure DrawQuad(const APos, AScale: TVector2; const ARot: Single;
      const AView: TView);
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Stb.Image,
  Neslib.Sokol.GL,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue;

{ TSpineContextsApp }

procedure TSpineContextsApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 1024;
  AConfig.Height := 768;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Spine - Contexts';
end;

procedure TSpineContextsApp.Init;
begin
  inherited;
  var GLDesc := TGLDesc.Create;
  GLDesc.UseDelphiMemoryManager := True;
  GLDesc.Logger := GLDesc.DefaultLogger;
  sglSetup(GLDesc);

  var SpineDesc := TSpineDesc.Create;
  SpineDesc.UseDelphiMemoryManager := True;
  SpineDesc.Logger := SpineDesc.DefaultLogger;
  TSpine.Setup(SpineDesc);

  var FetchDesc := TFetchDesc.Create;
  FetchDesc.MaxRequests := 3;
  FetchDesc.NumChannels := 2;
  FetchDesc.NumLanes := 1;
  FetchDesc.Logger := FetchDesc.DefaultLogger;
  FetchDesc.BaseDirectory := 'Data/Spine';
  TFetch.Setup(FetchDesc);

  { Create 2 sspine contexts for rendering into offscreen render targets }
  FOffscreen[0].Setup(TPixelFormat.Rgba8, 512, TColor.Create(1, 1, 1, 1));
  FOffscreen[1].Setup(TPixelFormat.Rg8, 64, TColor.Create(1, 1, 1, 1));

  { Create a texture sampler for sampling the offscreen render targets as
    texture }
  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Nearest;
  SamplerDesc.MagFilter := TFilter.Nearest;
  FSampler := TSampler.Create(SamplerDesc);

  { Common fixed-size spine layer transform }
  FLayerTransform.Size.Init(512, 512);
  FLayerTransform.Origin.Init(256, 256);

  { Start loading the spine atlas and skeleton. }
  var Request := TFetchRequest.Create('speedy-pma.atlas', AtlasDataLoaded,
    TFetchRange.Create(FBuffers.Atlas));
  Request.Channel := 0;
  Request.Send;

  Request := TFetchRequest.Create('speedy-ess.skel', SkeletonDataLoaded,
    TFetchRange.Create(FBuffers.Skeleton));
  Request.Channel := 1;
  Request.Send;
end;

procedure TSpineContextsApp.Frame;
begin
  var DeltaTime: Single := FrameDuration;
  TFetch.DoWork;

  { Render spine objects in separate contexts. First one by setting the current
    context, second one by calling function with Context arg }
  FInstances[0].Update(DeltaTime);
  TSpine.Context := FOffscreen[0].Context;
  FInstances[0].Draw(0);

  FInstances[1].Update(DeltaTime);
  FInstances[1].Draw(FOffscreen[1].Context, 0);

  { Draw two quads via Neslib.Sokol.GL which use the offscreen-rendered spine
    scenes as textures }
  var DW: Single := FramebufferWidth;
  var DH: Single := FramebufferHeight;
  var Aspect: Single := DH / DW;
  FAngleDeg := FAngleDeg + (DeltaTime * 60);
  sglDefaults;
  sglEnableTexture;
  sglMatrixModeProjection;
  sglOrtho(-1, 1, Aspect, -Aspect, -1, 1);
  sglMatrixModeModelview;
  DrawQuad(Vector2(-0.425, 0), Vector2(0.4, 0.4),  sglrad(FAngleDeg), FOffscreen[0].TexView);
  DrawQuad(Vector2( 0.425, 0), Vector2(0.4, 0.4), -sglrad(FAngleDeg), FOffscreen[1].TexView);

  { Do all the Neslib.Sokol.Gfx rendering:
    - two offscreen pass, rendering spine instances into render target textures
      (one is setting the current spine context, other is calling draw function
      with context arg)
    - the default pass which renders the previously recorded Neslib.Sokol.GL
      scene using the two render targets as textures }
  TGfx.BeginPass(FOffscreen[0].Pass);
  TSpine.Context := FOffscreen[0].Context;
  TSpine.DrawLayer(0, FLayerTransform);
  TGfx.EndPass;

  TGfx.BeginPass(FOffscreen[1].Pass);
  TSpine.DrawLayer(FOffscreen[1].Context, 0, FLayerTransform);
  TGfx.EndPass;

  var Pass := TPass.Create;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);
  sglDraw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TSpineContextsApp.Cleanup;
begin
  TFetch.Shutdown;
  TSpine.Shutdown;
  sglShutdown;
  inherited;
end;

procedure TSpineContextsApp.SkeletonDataLoaded(const AResponse: TFetchResponse);
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

procedure TSpineContextsApp.AtlasDataLoaded(const AResponse: TFetchResponse);
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

procedure TSpineContextsApp.CreateSpineObjects;
{ This function is called when both the spine atlas and skeleton file has been
  loaded. First an atlas object is created from the loaded atlas data, and then
  a skeleton object (which requires an atlas object as dependency), then a spine
  instance object. Finally any images required by the atlas object are loaded }
begin
  { Create spine atlas object from loaded atlas data. }
  var AtlasDesc := TSpineAtlasDesc.Create;
  AtlasDesc.Data := FLoadStatus.Atlas.Data;
  FAtlas := TSpineAtlas.Create(AtlasDesc);

  { Next create a spine skeleton object. }
  var SkeletonDesc := TSpineSkeletonDesc.Create;
  SkeletonDesc.Atlas := FAtlas;
  SkeletonDesc.BinaryData := FLoadStatus.Skeleton.Data;
  SkeletonDesc.AnimDefaultMix := 0.2;
  FSkeleton := TSpineSkeleton.Create(SkeletonDesc);

  { Create two instance objects }
  for var I := 0 to 1 do
  begin
    var InstanceDesc := TSpineInstanceDesc.Create;
    InstanceDesc.Skeleton := FSkeleton;
    FInstances[I] := TSpineInstance.Create(InstanceDesc);
    Assert(FInstances[I].Valid);
    FInstances[I].Position := Vector2(0, 128);
  end;
  FInstances[0].SetAnimation(FSkeleton.AnimByName('run'), 0, True);
  FInstances[1].SetAnimation(FSkeleton.AnimByName('run-linear'), 0, True);

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

procedure TSpineContextsApp.DrawQuad(const APos, AScale: TVector2;
  const ARot: Single; const AView: TView);
begin
  sglTexture(AView, FSampler);
  sglPushMatrix;
  sglTranslate(APos.X, APos.Y, 0);
  sglScale(AScale.X, AScale.Y, 0);
  sglRotate(ARot, 0, 0, 1);
  sglBeginQuads;
  sglV2F_T2F(-1, -1, 0, 0);
  sglV2F_T2F( 1, -1, 1, 0);
  sglV2F_T2F( 1,  1, 1, 1);
  sglV2F_T2F(-1,  1, 0, 1);
  sglEnd;
  sglPopMatrix;
end;

procedure TSpineContextsApp.ImageDataLoaded(const AResponse: TFetchResponse);
{ Load spine atlas image data and create a Neslib.Sokol.Gfx image object. }
const
  DESIRED_CHANNELS = 4;
begin
  var Img := PSpineImage(AResponse.UserData)^;
  var ImgInfo := Img.Info;
  Assert(ImgInfo.Valid);
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

{ TSpineContextsApp.TOffscreen }

procedure TSpineContextsApp.TOffscreen.Setup(const AFormat: TPixelFormat;
  const AWidthHeight: Integer; const AClearColor: TColor);
{ Helper to create offscreen pass resources and a matching spine context }
begin
  var ImageDesc := TImageDesc.Create;
  ImageDesc.Usage.ColorAttachment := True;
  ImageDesc.Width := AWidthHeight;
  ImageDesc.Height := AWidthHeight;
  ImageDesc.PixelFormat := AFormat;
  ImageDesc.SampleCount := 1;
  Image := TImage.Create(ImageDesc);

  var ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := Image;
  TexView := TView.Create(ViewDesc);

  ViewDesc.Init;
  ViewDesc.ColorAttachment.Image := Image;
  AttView := TView.Create(ViewDesc);

  var ContextDesc := TSpineContextDesc.Create;
  ContextDesc.ColorFormat := AFormat;
  ContextDesc.DepthFormat := TPixelFormat.None;
  ContextDesc.SampleCount := 1;
  Context := TSpineContext.Create(ContextDesc);

  Pass.Action.Colors[0].Init(TLoadAction.Clear, AClearColor);
  Pass.Attachments.Colors[0] := AttView;
end;

end.

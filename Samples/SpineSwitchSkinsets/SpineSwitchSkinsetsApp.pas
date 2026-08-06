unit SpineSwitchSkinsetsApp;
{ Test if switching skinsets on the same instance works. }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Spine,
  Neslib.Sokol.Fetch,
  Neslib.FastMath,
  SampleApp;

const
  NUM_SKINSETS          = 3;
  NUM_SKINS_PER_SKINSET = 8;

type
  TSpineSwitchSkinsetsApp = class(TSampleApp)
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
    end;
  private type
    TBuffers = record
    public
      Atlas: array [0..(16 * 1024) - 1] of Byte;
      Skeleton: array [0..(300 * 1024) - 1] of Byte;
      Image: array [0..(512 * 1024) - 1] of Byte;
    end;
  private
    FAtlas: TSpineAtlas;
    FSkeleton: TSpineSkeleton;
    FInstance: TSpineInstance;
    FSkinsets: array [0..NUM_SKINSETS - 1] of TSpineSkinset;
    FPassAction: TPassAction;
    FLoadStatus: TLoadStatus;
    FBuffers: TBuffers;
    FSkinsetIndex: Integer;
  private
    procedure AtlasDataLoaded(const AResponse: TFetchResponse);
    procedure SkeletonDataLoaded(const AResponse: TFetchResponse);
    procedure ImageDataLoaded(const AResponse: TFetchResponse);
    procedure LoadFailed;
    procedure CreateSpineObjects;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure KeyDown(const AKey: TKeyCode; const AModifiers: TModifiers;
      const AKeyRepeat: Boolean); override;
    procedure TouchesBegan(const ATouches: TTouches); override;
  end;

implementation

uses
  Neslib.Stb.Image,
  Neslib.Sokol.Api,
  Neslib.Sokol.DebugText,
  Neslib.Sokol.Glue;

const
  SKINS: array [0..NUM_SKINSETS - 1, 0..NUM_SKINS_PER_SKINSET - 1] of PUTF8Char = (
    ('skin-base',
     'accessories/backpack',
     'clothes/dress-blue',
     'eyelids/girly',
     'eyes/eyes-blue',
     'hair/blue',
     'legs/boots-pink',
     'nose/long'),
    ('skin-base',
     'accessories/bag',
     'clothes/dress-green',
     'eyelids/semiclosed',
     'eyes/green',
     'hair/brown',
     'legs/boots-red',
     'nose/short'),
    ('skin-base',
     'accessories/cape-blue',
     'clothes/hoodie-blue-and-scarf',
     'eyelids/girly',
     'eyes/violet',
     'hair/pink',
     'legs/pants-green',
     'nose/long'));

{ TSpineSwitchSkinsetsApp }

procedure TSpineSwitchSkinsetsApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.DepthFormat := TAppPixelFormat.None;
  AConfig.WindowTitle := 'Spine - Switch Skinsets';
end;

procedure TSpineSwitchSkinsetsApp.Init;
begin
  inherited;
  var DbgTextDesc := TDbgTextDesc.Create;
  DbgTextDesc.Fonts[0] := TDbgTextFont.KC854;
  DbgTextDesc.UseDelphiMemoryManager := True;
  DbgTextDesc.Logger := DbgTextDesc.DefaultLogger;
  TDbgText.Setup(DbgTextDesc);

  var FetchDesc := TFetchDesc.Create;
  FetchDesc.MaxRequests := 3;
  FetchDesc.NumChannels := 2;
  FetchDesc.NumLanes := 1;
  FetchDesc.Logger := FetchDesc.DefaultLogger;
  FetchDesc.BaseDirectory := 'Data/Spine';
  TFetch.Setup(FetchDesc);

  var SpineDesc := TSpineDesc.Create;
  SpineDesc.UseDelphiMemoryManager := True;
  SpineDesc.Logger := SpineDesc.DefaultLogger;
  TSpine.Setup(SpineDesc);

  FPassAction.Colors[0].Init(TLoadAction.Clear, 0, 0, 0, 1);

  var Request := TFetchRequest.Create('mix-and-match-pma.atlas', AtlasDataLoaded,
    TFetchRange.Create(FBuffers.Atlas));
  Request.Channel := 0;
  Request.Send;

  Request := TFetchRequest.Create('mix-and-match-pro.skel', SkeletonDataLoaded,
    TFetchRange.Create(FBuffers.Skeleton));
  Request.Channel := 1;
  Request.Send;
end;

procedure TSpineSwitchSkinsetsApp.KeyDown(const AKey: TKeyCode;
  const AModifiers: TModifiers; const AKeyRepeat: Boolean);
begin
  case AKey of
    TKeyCode._1:
      FInstance.SetSkinset(FSkinsets[0]);

    TKeyCode._2:
      FInstance.SetSkinset(FSkinsets[1]);

    TKeyCode._3:
      FInstance.SetSkinset(FSkinsets[2]);
  end;
end;

procedure TSpineSwitchSkinsetsApp.Frame;
begin
  TFetch.DoWork;
  var DeltaTime: Single := FrameDuration;
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;

  var LayerTransform: TSpineLayerTransform;
  LayerTransform.Size.Init(W, H);
  LayerTransform.Origin.Init(W * 0.5, H * 0.5);

  { Debug text }
  TDbgText.Canvas(W * 0.5, H * 0.5);
  TDbgText.Origin(2, 3);
  TDbgText.Home;
  {$IFDEF DESKTOP}
  TDbgText.Write('Press 1, 2 or 3 to switch skin sets!');
  {$ELSE}
  TDbgText.Write('Tap to switch skin sets!');
  {$ENDIF}

  FInstance.Update(DeltaTime);
  FInstance.Draw;

  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TSpine.DrawLayer(0, LayerTransform);
  TDbgText.Draw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TSpineSwitchSkinsetsApp.Cleanup;
begin
  TSpine.Shutdown;
  TDbgText.Shutdown;
  TFetch.Shutdown;
  inherited;
end;

procedure TSpineSwitchSkinsetsApp.LoadFailed;
begin
  FPassAction.Colors[0].ClearValue := TColor.Create(1, 0, 0, 1);
end;

procedure TSpineSwitchSkinsetsApp.SkeletonDataLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
  begin
    FLoadStatus.Skeleton.Loaded := True;
    FLoadStatus.Skeleton.Data := TSpineRange.Create(AResponse.Data.Ptr, AResponse.Data.Size);

    if (FLoadStatus.Atlas.Loaded) then
      CreateSpineObjects;
  end
  else if (AResponse.Failed) then
    LoadFailed;
end;

procedure TSpineSwitchSkinsetsApp.TouchesBegan(const ATouches: TTouches);
begin
  inherited;
  FSkinsetIndex := (FSkinsetIndex + 1) mod NUM_SKINSETS;
  FInstance.SetSkinset(FSkinsets[FSkinsetIndex]);
end;

procedure TSpineSwitchSkinsetsApp.AtlasDataLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
  begin
    FLoadStatus.Atlas.Loaded := True;
    FLoadStatus.Atlas.Data := TSpineRange.Create(AResponse.Data.Ptr, AResponse.Data.Size);

    if (FLoadStatus.Skeleton.Loaded) then
      CreateSpineObjects;
  end
  else if (AResponse.Failed) then
    LoadFailed;
end;

procedure TSpineSwitchSkinsetsApp.CreateSpineObjects;
begin
  var AtlasDesc := TSpineAtlasDesc.Create;
  AtlasDesc.Data := FLoadStatus.Atlas.Data;
  FAtlas := TSpineAtlas.Create(AtlasDesc);
  Assert(FAtlas.Valid);

  var SkeletonDesc := TSpineSkeletonDesc.Create;
  SkeletonDesc.Atlas := FAtlas;
  SkeletonDesc.BinaryData := FLoadStatus.Skeleton.Data;
  SkeletonDesc.Prescale := DpiScale;
  FSkeleton := TSpineSkeleton.Create(SkeletonDesc);
  Assert(FSkeleton.Valid);

  var InstanceDesc := TSpineInstanceDesc.Create;
  InstanceDesc.Skeleton := FSkeleton;
  FInstance := TSpineInstance.Create(InstanceDesc);
  Assert(FInstance.Valid);
  FInstance.Scale := Vector2(0.75);
  FInstance.Position := Vector2(0, 220 * DpiScale);
  FInstance.SetAnimation(FSkeleton.AnimByName('walk'), 0, True);

  { Start loading any atlas image files. }
  for var ImgIndex := 0 to FAtlas.ImageCount - 1 do
  begin
    var Img := FAtlas.Images[ImgIndex];
    var ImgInfo := Img.Info;

    var Request := TFetchRequest.Create(ImgInfo.Filename, ImageDataLoaded,
      TFetchRange.Create(FBuffers.Image));
    Request.Channel := 0;
    Request.UserData := TFetchRange.Create(Img);
    Request.Send;
  end;

  { Create skinsets }
  for var SkinsetIndex := 0 to NUM_SKINSETS - 1 do
  begin
    var SkinsetDesc := TSpineSkinsetDesc.Create;
    SkinsetDesc.Skeleton := FSkeleton;

    for var SkinIndex := 0 to NUM_SKINS_PER_SKINSET - 1 do
      SkinsetDesc.Skins[SkinIndex] := FSkeleton.SkinByName(SKINS[SkinsetIndex, SkinIndex]);

    FSkinsets[SkinsetIndex] := TSpineSkinset.Create(SkinsetDesc);
  end;

  { Set the first skinset as visible }
  FInstance.SetSkinset(FSkinsets[0]);
end;

procedure TSpineSwitchSkinsetsApp.ImageDataLoaded(const AResponse: TFetchResponse);
const
  DESIRED_CHANNELS = 4;
begin
  var Img := PSpineImage(AResponse.UserData)^;
  var ImgInfo := Img.Info;
  if (AResponse.Fetched) then
  begin
    var StbImage := TStbImage.Create;
    try
      if (StbImage.Load(AResponse.Data.Ptr, AResponse.Data.Size, DESIRED_CHANNELS)) then
      begin
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
        ImgInfo.Image.Fail;
        LoadFailed;
      end;
    finally
      StbImage.Free;
    end;
  end
  else
  begin
    ImgInfo.Image.Fail;
    LoadFailed;
  end;
end;

end.

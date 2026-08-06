unit SpineSkinsetsApp;
{ Test/demonstrate skinset usage and draw call merging. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Spine,
  Neslib.Sokol.Fetch,
  Neslib.FastMath,
  SampleApp;

const
  NUM_INSTANCES_X = 16;
  NUM_INSTANCES_Y = 8;
  NUM_INSTANCES   = NUM_INSTANCES_X * NUM_INSTANCES_Y;
  NUM_SKINS       = 8;
  PRESCALE        = 0.15;
  GRID_DX         = 64;
  GRID_DY         = 96;

type
  TSpineSkinsetsApp = class(TSampleApp)
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
    TGridCell = record
    public
      Pos: TVector2;
      Vec: TVector2;
    end;
    PGridCell = ^TGridCell;
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
    FInstances: array [0..NUM_INSTANCES - 1] of TSpineInstance;
    FPassAction: TPassAction;
    FT: Single; // Time interval 0..1
    FTCount: Integer; // Bumped each time FT goes over 1
    FGrid: array [0..NUM_INSTANCES - 1] of TGridCell;
    FLoadStatus: TLoadStatus;
    FBuffers: TBuffers;
    FX: UInt32;
  private
    procedure AtlasDataLoaded(const AResponse: TFetchResponse);
    procedure SkeletonDataLoaded(const AResponse: TFetchResponse);
    procedure ImageDataLoaded(const AResponse: TFetchResponse);
    procedure CreateSpineObjects;
    function RandomSkinIndex: Integer;
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
  Neslib.Sokol.Time,
  Neslib.Sokol.DebugText,
  Neslib.Sokol.Glue;

const
  ACCESSORIES: array [0..NUM_SKINS - 1] of PUTF8Char = (
    'accessories/backpack',
    'accessories/bag',
    'accessories/cape-blue',
    'accessories/cape-red',
    'accessories/hat-pointy-blue-yellow',
    'accessories/hat-red-yellow',
    'accessories/scarf',
    'accessories/backpack');

const
  CLOTHES: array [0..NUM_SKINS - 1] of PUTF8Char = (
    'clothes/dress-blue',
    'clothes/dress-green',
    'clothes/hoodie-blue-and-scarf',
    'clothes/hoodie-orange',
    'clothes/dress-blue',
    'clothes/dress-green',
    'clothes/hoodie-blue-and-scarf',
    'clothes/hoodie-orange');

const
  EYELIDS: array [0..NUM_SKINS - 1] of PUTF8Char = (
    'eyelids/girly',
    'eyelids/semiclosed',
    'eyelids/girly',
    'eyelids/semiclosed',
    'eyelids/girly',
    'eyelids/semiclosed',
    'eyelids/girly',
    'eyelids/semiclosed');

const
  EYES: array [0..NUM_SKINS - 1] of PUTF8Char = (
    'eyes/eyes-blue',
    'eyes/green',
    'eyes/violet',
    'eyes/yellow',
    'eyes/eyes-blue',
    'eyes/green',
    'eyes/violet',
    'eyes/yellow');

const
  HAIR: array [0..NUM_SKINS - 1] of PUTF8Char = (
    'hair/blue',
    'hair/brown',
    'hair/long-blue-with-scarf',
    'hair/pink',
    'hair/short-red',
    'hair/blue',
    'hair/brown',
    'hair/long-blue-with-scarf');

const
  LEGS: array [0..NUM_SKINS - 1] of PUTF8Char = (
    'legs/boots-pink',
    'legs/boots-red',
    'legs/pants-green',
    'legs/pants-jeans',
    'legs/boots-pink',
    'legs/boots-red',
    'legs/pants-green',
    'legs/pants-jeans');

const
  NOSE: array [0..NUM_SKINS - 1] of PUTF8Char = (
    'nose/long',
    'nose/short',
    'nose/long',
    'nose/short',
    'nose/long',
    'nose/short',
    'nose/long',
    'nose/short');

{ TSpineSkinsetsApp }

procedure TSpineSkinsetsApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 1024;
  AConfig.Height := 768;
  AConfig.DepthFormat := TAppPixelFormat.None;
  AConfig.WindowTitle := 'Spine - Skinsets';
end;

procedure TSpineSkinsetsApp.Init;
begin
  inherited;
  FX := $87654321;
  TTime.Setup;

  var DbgTextDesc := TDbgTextDesc.Create;
  DbgTextDesc.Fonts[0] := TDbgTextFont.Oric;
  DbgTextDesc.UseDelphiMemoryManager := True;
  DbgTextDesc.Logger := DbgTextDesc.DefaultLogger;
  TDbgText.Setup(DbgTextDesc);

  var SpineDesc := TSpineDesc.Create;
  SpineDesc.SkinsetPoolSize := NUM_INSTANCES;
  SpineDesc.InstancePoolSize := NUM_INSTANCES;
  SpineDesc.MaxVertices := 256 * 1024;
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

  { Setup a pass action to clear to blue-ish }
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0, 0.5, 0.7, 1);

  { Start loading the spine atlas and skeleton file. }
  var Request := TFetchRequest.Create('mix-and-match-pma.atlas', AtlasDataLoaded,
    TFetchRange.Create(FBuffers.Atlas));
  Request.Channel := 0;
  Request.Send;

  Request := TFetchRequest.Create('mix-and-match-pro.skel', SkeletonDataLoaded,
    TFetchRange.Create(FBuffers.Skeleton));
  Request.Channel := 1;
  Request.Send;

  { Setup position- and motion-vector-grid }
  var DX: Single := GRID_DX;
  var DY: Single := GRID_DY;
  var Y: Single := -DY * (NUM_INSTANCES_Y div 2) + DY;
  for var IY := 0 to NUM_INSTANCES_Y - 1 do
  begin
    var X: Single := -DX * (NUM_INSTANCES_X div 2) + (DX * 0.5);
    for var IX := 0 to NUM_INSTANCES_X - 1 do
    begin
      var Cell: PGridCell := @FGrid[(IY * NUM_INSTANCES_X) + IX];
      if ((IY and 1) = 0) then
      begin
        Cell.Pos.Init(X + (IX * DX), Y + (IY * DY));
        if (IX = (NUM_INSTANCES_X - 1)) then
          Cell.Vec.Init(0, 1)
        else
          Cell.Vec.Init(1, 0);
      end
      else
      begin
        Cell.Pos.Init(X + ((NUM_INSTANCES_X - 1 - IX) * DX), Y + (IY * DY));
        if (IX = (NUM_INSTANCES_X - 1)) then
          Cell.Vec.Init(0, 1)
        else
          Cell.Vec.Init(-1, 0);
      end;
    end;
  end;
end;

procedure TSpineSkinsetsApp.Frame;
begin
  var DeltaTime: Single := FrameDuration;
  var Width: Single := FramebufferWidth;
  var Height: Single := FramebufferHeight;
  var Aspect: Single := Width / Height;
  FT := FT + DeltaTime;
  if (FT > 1) then
  begin
    Inc(FTCount);
    FT := FT - 1;
  end;
  TFetch.DoWork;

  { Use a fixed 'virtual resolution' for the spine rendering, but keep the same
    aspect as the window/display }
  var VirtSize := Vector2(1024 * Aspect, 1024);
  var LayerTransform: TSpineLayerTransform;
  LayerTransform.Size := VirtSize;
  LayerTransform.Origin := VirtSize * 0.5;

  { Update and draw Spine objects }
  var StartTime := TTime.Now;
  for var I := 0 to NUM_INSTANCES - 1 do
  begin
    var GridIndex := (I + FTCount) mod NUM_INSTANCES;
    var Pos := FGrid[GridIndex].Pos;
    var Vec := FGrid[GridIndex].Vec;
    var P := Vector2(Pos.X + (Vec.X * GRID_DX * FT),
                     Pos.Y + (Vec.Y * GRID_DY * FT));
    FInstances[I].Position := P;
    FInstances[I].Update(DeltaTime);
    FInstances[I].Draw;
  end;
  var EvalTime: Double := TTime.ToMilliSeconds(TTime.Since(StartTime));

  { Debug text }
  var CtxInfo := TSpineContext.Default.Info;
  TDbgText.Canvas(Width * 0.25, Height * 0.25);
  TDbgText.Origin(2, 2);
  TDbgText.Home;
  TDbgText.Color(0, 0, 0);
  TDbgText.WriteLn('spine eval time: %.3fms', [EvalTime]);
  TDbgText.MoveY(0.5);
  TDbgText.WriteLn('vert:%d ind:%d draws:%d',
    [CtxInfo.NumVertices, CtxInfo.NumIndices, CtxInfo.NumCommands]);

  { The actual Neslib.Sokol.Gfx render pass. }
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

procedure TSpineSkinsetsApp.Cleanup;
begin
  TFetch.Shutdown;
  TSpine.Shutdown;
  TDbgText.Shutdown;
  inherited;
end;

procedure TSpineSkinsetsApp.SkeletonDataLoaded(const AResponse: TFetchResponse);
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

procedure TSpineSkinsetsApp.AtlasDataLoaded(const AResponse: TFetchResponse);
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

function TSpineSkinsetsApp.RandomSkinIndex: Integer;
begin
  FX := FX xor (FX shl 13);
  FX := FX xor (FX shr 17);
  FX := FX xor (FX shl 5);
  Result := FX and (NUM_SKINS - 1);
end;

procedure TSpineSkinsetsApp.CreateSpineObjects;
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
  SkeletonDesc.Prescale := PRESCALE;
  SkeletonDesc.AnimDefaultMix := 0.2;
  FSkeleton := TSpineSkeleton.Create(SkeletonDesc);
  Assert(FSkeleton.Valid);

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

  { Create many spine instances }
  var InitialTime: Single := 0;
  for var I := 0 to NUM_INSTANCES - 1 do
  begin
    var InstanceDesc := TSpineInstanceDesc.Create;
    InstanceDesc.Skeleton := FSkeleton;
    FInstances[I] := TSpineInstance.Create(InstanceDesc);
    Assert(FInstances[I].Valid);

    var AnimName: PUTF8Char;
    if ((I and 1) <> 0) then
      AnimName := 'walk'
    else
      AnimName := 'dance';
    FInstances[I].SetAnimation(FSkeleton.AnimByName(AnimName), 0, True);

    { Create s skin set }
    var SkinsetDesc := TSpineSkinsetDesc.Create;
    SkinsetDesc.Skeleton := FSkeleton;
    SkinsetDesc.Skins[0] := FSkeleton.SkinByName('skin-base');
    SkinsetDesc.Skins[1] := FSkeleton.SkinByName(ACCESSORIES[RandomSkinIndex]);
    SkinsetDesc.Skins[2] := FSkeleton.SkinByName(CLOTHES[RandomSkinIndex]);
    SkinsetDesc.Skins[3] := FSkeleton.SkinByName(EYELIDS[RandomSkinIndex]);
    SkinsetDesc.Skins[4] := FSkeleton.SkinByName(EYES[RandomSkinIndex]);
    SkinsetDesc.Skins[5] := FSkeleton.SkinByName(HAIR[RandomSkinIndex]);
    SkinsetDesc.Skins[6] := FSkeleton.SkinByName(LEGS[RandomSkinIndex]);
    SkinsetDesc.Skins[7] := FSkeleton.SkinByName(NOSE[RandomSkinIndex]);
    var Skinset := TSpineSkinset.Create(SkinsetDesc);
    Assert(Skinset.Valid);
    FInstances[I].SetSkinset(Skinset);
    FInstances[I].Update(InitialTime);
    InitialTime := InitialTime + 0.1;
  end;
end;

procedure TSpineSkinsetsApp.ImageDataLoaded(const AResponse: TFetchResponse);
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

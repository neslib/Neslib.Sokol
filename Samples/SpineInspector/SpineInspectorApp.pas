unit SpineInspectorApp;
{ Spine sample with inspector UI. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Spine,
  Neslib.Sokol.Fetch,
  Neslib.FastMath,
  SampleApp;

const
  MAX_TRIGGERED_EVENTS = 16;

type
  TSpineInspectorApp = class(TSampleApp)
  private type
    TLoadStatus = record
    public
      SceneIndex: Integer;
      PendingCount: Integer;
      Failed: Boolean;
      AtlasData: TSpineRange;
      SkelData: TSpineRange;
      SkelDataIsBinary: Boolean;
    end;
  private type
    TUI = record
    private type
      TSelected = record
      public
        Bone: TSpineBone;
        Slot: TSpineSlot;
        Anim: TSpineAnim;
        Event: TSpineEvent;
        Skin: TSpineSkin;
        IKTarget: TSpineIKTarget;
      end;
    private type
      TLastTriggeredEvent = record
      public
        Time: Double;
        Event: TSpineEvent;
      end;
    public
      DrawBonesEnabled: Boolean;
      AtlasOpen: Boolean;
      BonesOpen: Boolean;
      SlotsOpen: Boolean;
      AnimsOpen: Boolean;
      EventsOpen: Boolean;
      SkinsOpen: Boolean;
      IKTargetsOpen: Boolean;
      Selected: TSelected;
      CurTime: Double;
      LastTriggeredEvent: TLastTriggeredEvent;
      Theme: Integer;
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
    FInstance: TSpineInstance;
    FPassAction: TPassAction;
    FLayerTransform: TSpineLayerTransform;
    FIKTargetPos: TVector2;
    FLoadStatus: TLoadStatus;
    FUI: TUI;
    FBuffers: TBuffers;
  private
    function LoadSpineScene(const ASceneIndex: Integer): Boolean;
    procedure AtlasDataLoaded(const AResponse: TFetchResponse);
    procedure SkeletonDataLoaded(const AResponse: TFetchResponse);
    procedure ImageDataLoaded(const AResponse: TFetchResponse);
    procedure CreateSpineObjects;
    procedure DrawBones;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure MouseMove(const AX, AY, ADX, ADY: Single;
      const AModifiers: TModifiers); override;
    procedure DrawImGuiMainMenuItems; override;
  end;

implementation

uses
  Neslib.Stb.Image,
  Neslib.ImGui,
  Neslib.Sokol.GL,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue;

{ Describe Spine scenes available for loading }

const
  MAX_SPINE_SCENES     = 5;
  MAX_QUEUE_ANIMS      = 4;

type
  TAnim = record
  public
    Name: PUTF8Char;
    Looping: Boolean;
    Delay: Single;
  end;
  PAnim = ^TAnim;

type
  TScene = record
  public
    UIName: PUTF8Char;
    AtlasFile: String;
    SkelFileJson: String;
    SkelFileBinary: String;
    Skin: PUTF8Char;
    Prescale: Single;
    AtlasOverrides: TSpineAtlasOverrides;
    AnimQueue: array [0..MAX_QUEUE_ANIMS - 1] of TAnim;
  end;

const
  SPINE_SCENES: array [0..MAX_SPINE_SCENES - 1] of TScene = (
    (UIName: 'Spine Boy';
     AtlasFile: 'spineboy.atlas';
     SkelFileJson: 'spineboy-pro.json';
     Prescale: 0.75;
     AtlasOverrides: (
       MinFilter: TFilter.Nearest;
       MagFilter: TFilter.Nearest);
     AnimQueue: (
       (Name: 'portal'),
       (Name: 'run'; Looping: True),
       (), ())),

    (UIName: 'Raptor';
     AtlasFile: 'raptor-pma.atlas';
     SkelFileBinary: 'raptor-pro.skel';
     Prescale: 0.5;
     AnimQueue: (
       (Name: 'jump'),
       (Name: 'roar'),
       (Name: 'walk'; Looping: True),
       ())),

    (UIName: 'Alien';
     AtlasFile: 'alien-pma.atlas';
     SkelFileBinary: 'alien-pro.skel';
     Prescale: 0.5;
     AnimQueue: (
       (Name: 'run'; Looping: True),
       (Name: 'death'; Looping: False; Delay: 5),
       (Name: 'run'; Looping: True),
       (Name: 'death'; Looping: True; Delay: 5))),

    (UIName: 'Speedy';
     AtlasFile: 'speedy-pma.atlas';
     SkelFileBinary: 'speedy-ess.skel';
     AnimQueue: (
       (Name: 'run'; Looping: True),
       (), (), ())),

    (UIName: 'Mix & Match';
     AtlasFile: 'mix-and-match-pma.atlas';
     SkelFileBinary: 'mix-and-match-pro.skel';
     Skin: 'full-skins/girl';
     Prescale: 0.5;
     AnimQueue: (
       (Name: 'walk'; Looping: True),
       (), (), ())));

{ TSpineInspectorApp }

procedure TSpineInspectorApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Spine - Inspector';
end;

procedure TSpineInspectorApp.Init;
begin
  inherited;
  { Setup Neslib.Sokol.GL }
  var GLDesc := TGLDesc.Create;
  GLDesc.UseDelphiMemoryManager := True;
  GLDesc.Logger := GLDesc.DefaultLogger;
  sglSetup(GLDesc);

  { Setup Neslib.Sokol.Fetch }
  var FetchDesc := TFetchDesc.Create;
  FetchDesc.MaxRequests := 3;
  FetchDesc.NumChannels := 2;
  FetchDesc.NumLanes := 1;
  FetchDesc.Logger := FetchDesc.DefaultLogger;
  FetchDesc.BaseDirectory := 'Data/Spine';
  TFetch.Setup(FetchDesc);

  { Setup Neslib.Sokol.Spine with default attributes. }
  var SpineDesc := TSpineDesc.Create;
  SpineDesc.UseDelphiMemoryManager := True;
  SpineDesc.Logger := SpineDesc.DefaultLogger;
  TSpine.Setup(SpineDesc);

  { Start loading Spine atlas and skeleton file asynchronously }
  LoadSpineScene(0);
end;

procedure TSpineInspectorApp.Frame;
begin
  var DeltaTime: Double := FrameDuration;
  FUI.CurTime := FUI.CurTime + DeltaTime;

  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  FLayerTransform.Size.Init(W, H);
  FLayerTransform.Origin.Init(W * 0.5, H * 0.8);

  TFetch.DoWork;

  { Link IK target to mouse (no-op if there's no selected iktarget) }
  FInstance.SetIKTargetWorldPos(FUI.Selected.IKTarget, FIKTargetPos);

  { Update instance animation and bone state }
  FInstance.Update(DeltaTime);

  { Draw instance to layer 0 }
  FInstance.Draw;

  { Keep track of triggered events }
  for var I := 0 to FInstance.TriggeredEventCount - 1 do
  begin
    FUI.LastTriggeredEvent.Time := FUI.CurTime;
    FUI.LastTriggeredEvent.Event := FInstance.TriggeredEvents[I].Event;
  end;

  { Draw spine bones via Neslib.Sokol.GL }
  if (FUI.DrawBonesEnabled) then
    DrawBones;

  { When loading has failed, change the clear color to red }
  if (FLoadStatus.Failed) then
    FPassAction.Colors[0].Init(TLoadAction.Clear, 1, 0, 0, 1)
  else
    FPassAction.Colors[0].Init(TLoadAction.Clear, 0, 0.5, 0.7, 1);

  { The actual Neslib.Sokol.Gfx render pass. }
  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  { Note: using the display width/height here means the Spine rendering
    is mapped to pixels and doesn't scale with window size }
  TSpine.DrawLayer(0, FLayerTransform);
  sglDraw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TSpineInspectorApp.Cleanup;
begin
  TSpine.Shutdown;
  TFetch.Shutdown;
  sglShutdown;
  inherited;
end;

procedure TSpineInspectorApp.MouseMove(const AX, AY, ADX, ADY: Single;
  const AModifiers: TModifiers);
begin
  FIKTargetPos.X := AX - FLayerTransform.Origin.X;
  FIKTargetPos.Y := AY - FLayerTransform.Origin.Y;
end;

function TSpineInspectorApp.LoadSpineScene(const ASceneIndex: Integer): Boolean;
{ Start loading a spine scene asynchronously }
begin
  Assert(Cardinal(ASceneIndex) < MAX_SPINE_SCENES);
  Assert(SPINE_SCENES[ASceneIndex].AtlasFile <> '');
  Assert((SPINE_SCENES[ASceneIndex].SkelFileJson <> '') or (SPINE_SCENES[ASceneIndex].SkelFileBinary <> ''));

  { Don't disturb any in-progress scene loading }
  if (FLoadStatus.PendingCount > 0) then
    Exit(False);

  FLoadStatus.SceneIndex := ASceneIndex;
  FLoadStatus.PendingCount := 0;
  FLoadStatus.Failed := False;
  FLoadStatus.AtlasData := TSpineRange.Create(nil, 0);
  FLoadStatus.SkelData := TSpineRange.Create(nil, 0);
  FLoadStatus.SkelDataIsBinary := False;

  { Discard previous spine scene (functions can be called with invalid handles) }
  FInstance.Free;
  FSkeleton.Free;
  FAtlas.Free;

  { Start loading the atlas file }
  var Request := TFetchRequest.Create(SPINE_SCENES[ASceneIndex].AtlasFile,
    AtlasDataLoaded, TFetchRange.Create(FBuffers.Atlas));
  Request.Channel := 0;
  Request.Send;
  Inc(FLoadStatus.PendingCount);

  { Start loading the skeleton file, this can either be provided as JSON or as
    binary data }
  var SkelFile := SPINE_SCENES[ASceneIndex].SkelFileJson;
  if (SkelFile = '') then
  begin
    SkelFile := SPINE_SCENES[ASceneIndex].SkelFileBinary;
    FLoadStatus.SkelDataIsBinary := True;
  end;

  Request.Init(SkelFile, SkeletonDataLoaded,
    { In case the skeleton file is JSON text data, make sure we have room for a
      terminating zero }
    TFetchRange.Create(@FBuffers.Skeleton, SizeOf(FBuffers.Skeleton) - 1));
  Request.Channel := 1;
  Request.Send;
  Inc(FLoadStatus.PendingCount);

  Result := True;
end;

procedure TSpineInspectorApp.SkeletonDataLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched or AResponse.Failed) then
  begin
    Assert(FLoadStatus.PendingCount > 0);
    Dec(FLoadStatus.PendingCount);
  end;

  if (AResponse.Fetched) then
  begin
    FLoadStatus.SkelData := TSpineRange.Create(AResponse.Data.Ptr,
      AResponse.Data.Size);

    { In case the loaded data file is JSON text, make sure it's zero terminated }
    Assert(AResponse.Data.Size < SizeOf(FBuffers.Skeleton));
    FBuffers.Skeleton[AResponse.Data.Size] := 0;

    { If both the atlas and skeleton file had been loaded, create the atlas and
      skeleton spine objects }
    if (FLoadStatus.PendingCount = 0) then
      CreateSpineObjects;
  end
  else if (AResponse.Failed) then
    FLoadStatus.Failed := True;
end;

procedure TSpineInspectorApp.AtlasDataLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched or AResponse.Failed) then
  begin
    Assert(FLoadStatus.PendingCount > 0);
    Dec(FLoadStatus.PendingCount);
  end;

  if (AResponse.Fetched) then
  begin
    FLoadStatus.AtlasData := TSpineRange.Create(AResponse.Data.Ptr,
      AResponse.Data.Size);

    { If both the atlas and skeleton file had been loaded, create the atlas and
      skeleton spine objects }
    if (FLoadStatus.PendingCount = 0) then
      CreateSpineObjects;
  end
  else if (AResponse.Failed) then
    FLoadStatus.Failed := True;
end;

procedure TSpineInspectorApp.CreateSpineObjects;
{ Called when both the Spine atlas and skeleton file has finished loading }
begin
  var SceneIndex := FLoadStatus.SceneIndex;

  { Create atlas from file data. }
  var AtlasDesc := TSpineAtlasDesc.Create;
  AtlasDesc.Data := FLoadStatus.AtlasData;
  AtlasDesc.Overrides := SPINE_SCENES[SceneIndex].AtlasOverrides;
  FAtlas := TSpineAtlas.Create(AtlasDesc);
  Assert(FAtlas.Valid);

  { Create a skeleton object, the skeleton data might be either JSON or binary. }
  var SkeletonDesc := TSpineSkeletonDesc.Create;
  SkeletonDesc.Atlas := FAtlas;
  SkeletonDesc.Prescale := SPINE_SCENES[SceneIndex].Prescale * DpiScale;
  SkeletonDesc.AnimDefaultMix := 0.2;
  if (FLoadStatus.SkelDataIsBinary) then
    SkeletonDesc.BinaryData := FLoadStatus.SkelData
  else
    SkeletonDesc.JsonData := UTF8String(PUTF8Char(FLoadStatus.SkelData.Data));
  FSkeleton := TSpineSkeleton.Create(SkeletonDesc);
  Assert(FSkeleton.Valid);

  { Create a skeleton instance }
  var InstanceDesc := TSpineInstanceDesc.Create;
  InstanceDesc.Skeleton := FSkeleton;
  FInstance := TSpineInstance.Create(InstanceDesc);
  Assert(FInstance.Valid);

  { Set initial skin if requested }
  if (SPINE_SCENES[SceneIndex].Skin <> nil) then
    FInstance.SetSkin(FSkeleton.SkinByName(SPINE_SCENES[SceneIndex].Skin));

  { Populate animation queue }
  for var AnimIndex := 0 to MAX_QUEUE_ANIMS - 1 do
  begin
    var QueueAnim := PAnim(@SPINE_SCENES[SceneIndex].AnimQueue[AnimIndex]);
    if (QueueAnim.Name <> nil) then
    begin
      var Anim := FSkeleton.AnimByName(QueueAnim.Name);
      if (AnimIndex = 0) then
        FInstance.SetAnimation(Anim, 0, QueueAnim.Looping)
      else
        FInstance.AddAnimation(Anim, 0, QueueAnim.Looping, QueueAnim.Delay);
    end;
  end;

  { Asynchronously load atlas images. }
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
    Inc(FLoadStatus.PendingCount);
  end;
end;

procedure TSpineInspectorApp.ImageDataLoaded(const AResponse: TFetchResponse);
{ Called when atlas image data has finished loading. }
const
  DESIRED_CHANNELS = 4;
begin
  if (AResponse.Fetched or AResponse.Failed) then
  begin
    Assert(FLoadStatus.PendingCount > 0);
    Dec(FLoadStatus.PendingCount);
  end;

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

procedure TSpineInspectorApp.DrawImGuiMainMenuItems;
const
  TRIGGERED_EVENT_FADE_TIME = 1.0;
  BOOL_STR: array [Boolean] of String = ('No', 'Yes');
  FILTER_STR: array [TFilter] of String = ('Default', 'Nearest', 'Linear');
  WRAP_STR: array [TWrap] of String = ('Default', 'Repeat', 'ClampToEdge', 'ClampToBorder', 'MirroredRepeat');
begin
  if (ImGui.BeginMenu('Sokol.Spine')) then
  begin
    if (ImGui.BeginMenu('Load')) then
    begin
      for var I := 0 to MAX_SPINE_SCENES - 1 do
      begin
        if (SPINE_SCENES[I].UIName <> nil) then
        begin
          if (ImGui.MenuItem(SPINE_SCENES[I].UIName, nil, (I = FLoadStatus.SceneIndex))) then
            LoadSpineScene(I);
        end;
      end;
      ImGui.EndMenu;
    end;

    ImGui.MenuItem('Draw Bones', nil, @FUI.DrawBonesEnabled);
    ImGui.MenuItem('Atlas...', nil, @FUI.AtlasOpen);
    ImGui.MenuItem('Bones...', nil, @FUI.BonesOpen);
    ImGui.MenuItem('Slots...', nil, @FUI.SlotsOpen);
    ImGui.MenuItem('Anims...', nil, @FUI.AnimsOpen);
    ImGui.MenuItem('Events...', nil, @FUI.EventsOpen);
    ImGui.MenuItem('Skins...', nil, @FUI.SkinsOpen);
    ImGui.MenuItem('IK Targets...', nil, @FUI.IKTargetsOpen);
    ImGui.EndMenu;
  end;

  if (ImGui.BeginMenu('Options')) then
  begin
    if (ImGui.RadioButton('Dark Theme', @FUI.Theme, 0)) then
      ImGui.StyleColorsDark;

    if (ImGui.RadioButton('Light Theme', @FUI.Theme, 1)) then
      ImGui.StyleColorsLight;

    if (ImGui.RadioButton('Classic Theme', @FUI.Theme, 2)) then
      ImGui.StyleColorsClassic;

    ImGui.EndMenu;
  end;

  var Pos := Vector2(30, 30);
  if (FUI.AtlasOpen) then
  begin
    ImGui.SetNextWindowSize(Vector2(300, 330), TImGuiCond.Once);
    ImGui.SetNextWindowPos(Pos, TImGuiCond.Once);
    if (ImGui.Begin('Spine Atlas', @FUI.AtlasOpen)) then
    begin
      if (not FAtlas.Valid) then
        ImGui.Text('No Spine data loaded.')
      else
      begin
        var NumAtlasPages := FAtlas.PageCount;
        ImGui.Text(ImGui.Format('Num Pages: %d', [NumAtlasPages]));
        for var I := 0 to NumAtlasPages - 1 do
        begin
          var Info := FAtlas.Pages[I].Info;
          Assert(Info.Valid);
          ImGui.Separator;
          ImGui.Text(ImGui.Format('Filename: %s', [Info.Image.Filename.ToString]));
          ImGui.Text(ImGui.Format('Width: %d', [Info.Image.Width]));
          ImGui.Text(ImGui.Format('Height: %d', [Info.Image.Height]));
          ImGui.Text(ImGui.Format('Premul Alpha: %s', [BOOL_STR[Info.Image.PremulAlpha]]));
          ImGui.Text('Original Spine params:');
          ImGui.Text(ImGui.Format('  Min Filter: %s', [FILTER_STR[Info.Image.MinFilter]]));
          ImGui.Text(ImGui.Format('  Mag Filter: %s', [FILTER_STR[Info.Image.MagFilter]]));
          ImGui.Text(ImGui.Format('  Mipmap Filter: %s', [FILTER_STR[Info.Image.MipmapFilter]]));
          ImGui.Text(ImGui.Format('  Wrap U: %s', [WRAP_STR[Info.Image.WrapU]]));
          ImGui.Text(ImGui.Format('  Wrap V: %s', [WRAP_STR[Info.Image.WrapV]]));
          ImGui.Text('Overrides:');
          ImGui.Text(ImGui.Format('  Min Filter: %s', [FILTER_STR[Info.Overrides.MinFilter]]));
          ImGui.Text(ImGui.Format('  Mag Filter: %s', [FILTER_STR[Info.Overrides.MagFilter]]));
          ImGui.Text(ImGui.Format('  Mipmap Filter: %s', [FILTER_STR[Info.Overrides.MipmapFilter]]));
          ImGui.Text(ImGui.Format('  Wrap U: %s', [WRAP_STR[Info.Overrides.WrapU]]));
          ImGui.Text(ImGui.Format('  Wrap V: %s', [WRAP_STR[Info.Overrides.WrapV]]));
          ImGui.Text(ImGui.Format('  Premul Alpha Enabled: %s', [BOOL_STR[Info.Overrides.PremulAlphaEnabled]]));
          ImGui.Text(ImGui.Format('  Premul Alpha Disabled: %s', [BOOL_STR[Info.Overrides.PremulAlphaDisabled]]));
        end;
      end;
    end;
    ImGui.End;
  end;

  Pos.Offset(20, 20);
  if (FUI.BonesOpen) then
  begin
    ImGui.SetNextWindowSize(Vector2(300, 300), TImGuiCond.Once);
    ImGui.SetNextWindowPos(Pos, TImGuiCond.Once);
    if (ImGui.Begin('Bones', @FUI.BonesOpen)) then
    begin
      if (not FInstance.Valid) then
        ImGui.Text('No Spine data loaded.')
      else
      begin
        var NumBones := FSkeleton.BoneCount;
        ImGui.Text(ImGui.Format('Num Bones: %d', [NumBones]));
        ImGui.BeginChild('BonesList', Vector2(128, 0), [TImGuiChildFlag.Borders]);
        for var I := 0 to NumBones - 1 do
        begin
          var Bone := FSkeleton.Bones[I];
          var Info := Bone.Info;
          Assert(Info.Valid);
          ImGui.PushID(Bone.Index);
          if (ImGui.Selectable(Info.Name.ToUtf8, (FUI.Selected.Bone = Bone))) then
            FUI.Selected.Bone := Bone;
          ImGui.PopID;
        end;
        ImGui.EndChild;

        ImGui.SameLine;
        if (FUI.Selected.Bone.Valid) then
        begin
          var Info := FUI.Selected.Bone.Info;
          Assert(Info.Valid);
          ImGui.BeginChild('BoneInfo');
          ImGui.Text(ImGui.Format('Index: %d', [Info.Index]));
          if (Info.ParentBone.Valid) then
            ImGui.Text(ImGui.Format('Parent Bone: %s', [Info.ParentBone.Info.Name.ToUtf8]))
          else
            ImGui.Text('Parent Bone: ---');
          ImGui.Text(ImGui.Format('Name: %s', [Info.Name.ToUtf8]));
          ImGui.Text(ImGui.Format('Length: %.3f', [Info.Length]));

          ImGui.Text('Pose Transform:');
          ImGui.Text(ImGui.Format('  Position: %.3f, %.3f', [Info.Pose.Position.X, Info.Pose.Position.Y]));
          ImGui.Text(ImGui.Format('  Rotation: %.3f', [Info.Pose.Rotation]));
          ImGui.Text(ImGui.Format('  Scale: %.3f, %.3f', [Info.Pose.Scale.X, Info.Pose.Scale.Y]));
          ImGui.Text(ImGui.Format('  Shear: %.3f, %.3f', [Info.Pose.Shear.X, Info.Pose.Shear.Y]));

          ImGui.Text(ImGui.Format('Color: %.2f, %.2f,%.2f, %.2f', [Info.Color.R, Info.Color.G, Info.Color.B, Info.Color.A]));
          ImGui.Text('Current Transform:');
          var CurTForm := FInstance.BoneTransform[FUI.Selected.Bone];
          ImGui.Text(ImGui.Format('  Position: %.3f, %.3f', [CurTForm.Position.X, CurTForm.Position.Y]));
          ImGui.Text(ImGui.Format('  Rotation: %.3f', [CurTForm.Rotation]));
          ImGui.Text(ImGui.Format('  Scale: %.3f, %.3f', [CurTForm.Scale.X, CurTForm.Scale.Y]));
          ImGui.Text(ImGui.Format('  Shear: %.3f, %.3f', [CurTForm.Shear.X, CurTForm.Shear.Y]));

          ImGui.EndChild;
        end;
      end;
    end;
    ImGui.End;
  end;

  Pos.Offset(20, 20);
  if (FUI.SlotsOpen) then
  begin
    ImGui.SetNextWindowSize(Vector2(300, 300), TImGuiCond.Once);
    ImGui.SetNextWindowPos(Pos, TImGuiCond.Once);
    if (ImGui.Begin('Slots', @FUI.SlotsOpen)) then
    begin
      if (not FInstance.Valid) then
        ImGui.Text('No Spine data loaded.')
      else
      begin
        var NumSlots := FSkeleton.SlotCount;
        ImGui.Text(ImGui.Format('Num Slots: %d', [NumSlots]));
        ImGui.BeginChild('SlotList', Vector2(128, 0), [TImGuiChildFlag.Borders]);
        for var I := 0 to NumSlots - 1 do
        begin
          var Slot := FSkeleton.Slots[I];
          var Info := Slot.Info;
          Assert(Info.Valid);
          ImGui.PushID(Slot.Index);
          if (ImGui.Selectable(Info.Name.ToUtf8, (FUI.Selected.Slot = Slot))) then
            FUI.Selected.Slot := Slot;
          ImGui.PopID;
        end;
        ImGui.EndChild;

        ImGui.SameLine;
        if (FUI.Selected.Slot.Valid) then
        begin
          var SlotInfo := FUI.Selected.Slot.Info;
          Assert(SlotInfo.Valid);
          var BoneInfo := SlotInfo.Bone.Info;
          Assert(BoneInfo.Valid);
          ImGui.BeginChild('SlotInfo');
          ImGui.Text(ImGui.Format('Index: %d', [SlotInfo.Index]));
          ImGui.Text(ImGui.Format('Name: %s', [SlotInfo.Name.ToUtf8]));
          if (SlotInfo.AttachmentName.Valid) then
            ImGui.Text(ImGui.Format('Attachment: %s', [SlotInfo.AttachmentName.ToUtf8]))
          else
            ImGui.Text('Attachment: -');
          ImGui.Text(ImGui.Format('Bone Name: %s', [BoneInfo.Name.ToUtf8]));
          ImGui.Text(ImGui.Format('Color: %.2f, %.2f,%.2f, %.2f', [SlotInfo.Color.R, SlotInfo.Color.G, SlotInfo.Color.B, SlotInfo.Color.A]));

          ImGui.EndChild;
        end;
      end;
    end;
    ImGui.End;
  end;

  Pos.Offset(20, 20);
  if (FUI.AnimsOpen) then
  begin
    ImGui.SetNextWindowSize(Vector2(300, 300), TImGuiCond.Once);
    ImGui.SetNextWindowPos(Pos, TImGuiCond.Once);
    if (ImGui.Begin('Anims', @FUI.AnimsOpen)) then
    begin
      if (not FInstance.Valid) then
        ImGui.Text('No Spine data loaded.')
      else
      begin
        var NumAnims := FSkeleton.AnimationCount;
        ImGui.Text(ImGui.Format('Num Anims: %d', [NumAnims]));
        ImGui.BeginChild('AnimList', Vector2(128, 0), [TImGuiChildFlag.Borders]);
        for var I := 0 to NumAnims - 1 do
        begin
          var Anim := FSkeleton.Animations[I];
          var Info := Anim.Info;
          Assert(Info.Valid);
          ImGui.PushID(Anim.Index);
          if (ImGui.Selectable(Info.Name.ToUtf8, (FUI.Selected.Anim = Anim))) then
          begin
            FUI.Selected.Anim := Anim;
            FInstance.SetAnimation(Anim, 0, True);
          end;
          ImGui.PopID;
        end;
        ImGui.EndChild;

        ImGui.SameLine;
        if (FUI.Selected.Anim.Valid) then
        begin
          var Info := FUI.Selected.Anim.Info;
          Assert(Info.Valid);
          ImGui.BeginChild('AnimInfo');
          ImGui.Text(ImGui.Format('Index: %d', [Info.Index]));
          ImGui.Text(ImGui.Format('Name: %s', [Info.Name.ToUtf8]));
          ImGui.Text(ImGui.Format('Duration: %.3f', [Info.Duration]));

          ImGui.EndChild;
        end;
      end;
    end;
    ImGui.End;
  end;

  Pos.Offset(20, 20);
  if (FUI.EventsOpen) then
  begin
    ImGui.SetNextWindowSize(Vector2(300, 300), TImGuiCond.Once);
    ImGui.SetNextWindowPos(Pos, TImGuiCond.Once);
    if (ImGui.Begin('Events', @FUI.EventsOpen)) then
    begin
      if (not FSkeleton.Valid) then
        ImGui.Text('No Spine data loaded.')
      else
      begin
        var NumEvents := FSkeleton.EventCount;
        ImGui.Text(ImGui.Format('Num Events: %d', [NumEvents]));
        ImGui.BeginChild('EventList', Vector2(128, 0), [TImGuiChildFlag.Borders]);
        for var I := 0 to NumEvents - 1 do
        begin
          var Event := FSkeleton.Events[I];
          var Info := Event.Info;
          Assert(Info.Valid);
          ImGui.PushID(Event.Index);
          if (ImGui.Selectable(Info.Name.ToUtf8, (FUI.Selected.Event = Event))) then
            FUI.Selected.Event := Event;
          ImGui.PopID;
        end;
        ImGui.EndChild;

        ImGui.SameLine;
        if (FUI.Selected.Event.Valid) then
        begin
          var Info := FUI.Selected.Event.Info;
          Assert(Info.Valid);
          ImGui.BeginChild('EventInfo');
          ImGui.Text(ImGui.Format('Index: %d', [Info.Index]));
          ImGui.Text(ImGui.Format('Name: %s', [Info.Name.ToUtf8]));
          ImGui.Text(ImGui.Format('Int Value: %d', [Info.IntValue]));
          ImGui.Text(ImGui.Format('Float Value: %.3f', [Info.FloatValue]));

          if (Info.StringValue.Valid) then
            ImGui.Text(ImGui.Format('String Value: %s', [Info.StringValue.ToUtf8]))
          else
            ImGui.Text('String Value: (none)');

          if (Info.AudioPath.Valid) then
            ImGui.Text(ImGui.Format('Audio Path: %s', [Info.AudioPath.ToUtf8]))
          else
            ImGui.Text('String Value: (none)');

          ImGui.Text(ImGui.Format('Volume: %.3f', [Info.Volume]));
          ImGui.Text(ImGui.Format('Balance: %.3f', [Info.Balance]));

          ImGui.EndChild;
        end;
      end;
    end;
    ImGui.End;
  end;

  Pos.Offset(20, 20);
  if (FUI.SkinsOpen) then
  begin
    ImGui.SetNextWindowSize(Vector2(300, 300), TImGuiCond.Once);
    ImGui.SetNextWindowPos(Pos, TImGuiCond.Once);
    if (ImGui.Begin('Skins', @FUI.SkinsOpen)) then
    begin
      if (not FSkeleton.Valid) then
        ImGui.Text('No Spine data loaded.')
      else
      begin
        var NumSkins := FSkeleton.SkinCount;
        ImGui.Text(ImGui.Format('Num Skins: %d', [NumSkins]));
        ImGui.BeginChild('SkinList', Vector2(128, 0), [TImGuiChildFlag.Borders]);
        for var I := 0 to NumSkins - 1 do
        begin
          var Skin := FSkeleton.Skins[I];
          var Info := Skin.Info;
          Assert(Info.Valid);
          ImGui.PushID(Skin.Index);
          if (ImGui.Selectable(Info.Name.ToUtf8, (FUI.Selected.Skin = Skin))) then
          begin
            FUI.Selected.Skin := Skin;
            FInstance.SetSkin(Skin);
          end;
          ImGui.PopID;
        end;
        ImGui.EndChild;

        ImGui.SameLine;
        if (FUI.Selected.Skin.Valid) then
        begin
          var Info := FUI.Selected.Skin.Info;
          Assert(Info.Valid);
          ImGui.BeginChild('SkinInfo');
          ImGui.Text(ImGui.Format('Index: %d', [Info.Index]));
          ImGui.Text(ImGui.Format('Name: %s', [Info.Name.ToUtf8]));

          ImGui.EndChild;
        end;
      end;
    end;
    ImGui.End;
  end;

  Pos.Offset(20, 20);
  if (FUI.IKTargetsOpen) then
  begin
    ImGui.SetNextWindowSize(Vector2(300, 300), TImGuiCond.Once);
    ImGui.SetNextWindowPos(Pos, TImGuiCond.Once);
    if (ImGui.Begin('IK Targets', @FUI.IKTargetsOpen)) then
    begin
      if (not FSkeleton.Valid) then
        ImGui.Text('No Spine data loaded.')
      else
      begin
        var NumIKTargets := FSkeleton.IKTargetCount;
        ImGui.Text(ImGui.Format('Num IK Targets: %d', [NumIKTargets]));
        ImGui.BeginChild('IKTargetList', Vector2(128, 0), [TImGuiChildFlag.Borders]);
        for var I := 0 to NumIKTargets - 1 do
        begin
          var IKTarget := FSkeleton.IKTargets[I];
          var Info := IKTarget.Info;
          Assert(Info.Valid);
          ImGui.PushID(IKTarget.Index);
          if (ImGui.Selectable(Info.Name.ToUtf8, (FUI.Selected.IKTarget = IKTarget))) then
            FUI.Selected.IKTarget := IKTarget;
          ImGui.PopID;
        end;
        ImGui.EndChild;

        ImGui.SameLine;
        if (FUI.Selected.IKTarget.Valid) then
        begin
          var Info := FUI.Selected.IKTarget.Info;
          Assert(Info.Valid);
          ImGui.BeginChild('IKTargetInfo');
          ImGui.Text(ImGui.Format('Index: %d', [Info.Index]));
          ImGui.Text(ImGui.Format('Name: %s', [Info.Name.ToUtf8]));
          ImGui.Text(ImGui.Format('Target Bone: %s', [Info.TargetBone.Info.Name.ToUtf8]));

          ImGui.EndChild;
        end;
      end;
    end;
    ImGui.End;
  end;

  { Display triggered events }
  if (FUI.LastTriggeredEvent.Event.Valid) and
    ((FUI.LastTriggeredEvent.Time + TRIGGERED_EVENT_FADE_TIME) > FUI.CurTime) then
  begin
    var Event := FUI.LastTriggeredEvent.Event;
    var EventInfo := Event.Info;
    var EventTime: Double := FUI.LastTriggeredEvent.Time;
    if (EventInfo.Valid) then
    begin
      var Alpha: Single := 1 - ((FUI.CurTime - EventTime) / TRIGGERED_EVENT_FADE_TIME);
      ImGui.SetNextWindowBgAlpha(Alpha);
      ImGui.SetNextWindowPos(
        Vector2((FramebufferWidth / DpiScale) * 0.5, (FramebufferHeight / DpiScale) - 50),
        TImGuiCond.Always, Vector2(0.5));
      ImGui.PushStyleColor(TImGuiCol.WindowBg, $FF0000FF);

      if (ImGui.Begin('Triggered Events', nil, TImGuiWindowFlags.NoDecoration +
        TImGuiWindowFlags.NoNav + [TImGuiWindowFlag.AlwaysAutoResize,
        TImGuiWindowFlag.NoFocusOnAppearing])) then
      begin
        ImGui.Text(ImGui.Format('%s: %.3f (age: %.3f)', [EventInfo.Name.ToUtf8,
          EventTime, FUI.CurTime - EventTime]));
      end;
      ImGui.End;
      ImGui.PopStyleColor;
    end;
  end;
end;

procedure TSpineInspectorApp.DrawBones;
begin
  if (not FInstance.Valid) then
    Exit;

  var Proj := FLayerTransform.ToMatrix;
  sglDefaults;
  sglMatrixModeProjection;
  sglLoadMatrix(Proj);
  sglC3F(0, 1, 0);
  sglBeginLines;
  for var I := 0 to FSkeleton.BoneCount - 1 do
  begin
    var Bone := FSkeleton.Bones[I];
    var ParentBone := Bone.Info.ParentBone;
    if (ParentBone.Valid) then
    begin
      var P0 := FInstance.BoneWorldPosition[ParentBone];
      var P1 := FInstance.BoneWorldPosition[Bone];
      sglV2F(P0.X, P0.Y);
      sglV2F(P1.X, P1.Y);
    end;
  end;
  sglEnd;
end;

end.

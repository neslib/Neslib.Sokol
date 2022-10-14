unit OzzAnimApp;
{ https://guillaumeblanc.github.io/ozz-animation/

  Port of the ozz-animation "Animation Playback" sample. Use Neslib.Sokol.GL
  for debug-rendering the animated character skeleton (no skinning). }

interface

uses
  Neslib.FastMath,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Fetch,
  Neslib.Sokol.GL,
  Neslib.OzzAnim,
  Utils,
  Camera,
  SampleApp;

type
  TLoaded = record
  public
    Skeleton: Boolean;
    Animation: Boolean;
    Failed: Boolean;
  end;

type
  TTime = record
  public
    Frame: Double;
    Absolut: Double;
    Factor: Single;
    AnimRatio: Single;
    AnimRatioUIOverride: Boolean;
    Paused: Boolean;
  end;

type
  TOzzAnimApp = class(TSampleApp)
  private
    FSkeleton: TOzzSkeleton;
    FAnimation: TOzzAnimation;
    FCache: TOzzSamplingCache;
    FSamplingJob: TOzzSamplingJob;
    FLocalToModelJob: TOzzLocalToModelJob;
    FLocalMatrices: TAlignedArray<TOzzSoaTransform>;
    FModelMatrices: TAlignedArray<TMatrix4>;
    FPassAction: TPassAction;
    FCamera: TCamera;
    FLoaded: TLoaded;
    FTime: TTime;

    { IO buffers for skeleton and animation data files.
      We know the max file size upfront. }
    FSkeletonData: array [0..(4 * 1024) - 1] of Byte;
    FAnimationData: array [0..(32 * 1024) - 1] of Byte;
  private
    procedure SkeletonDataLoaded(const AResponse: TFetchResponse);
    procedure AnimationDataLoaded(const AResponse: TFetchResponse);
    procedure EvalAnimation;
    procedure DrawSkeleton;
    procedure DrawJoint(const AJointIndex, AParentJointIndex: Integer);
  private
    class procedure DrawLine(const AV0, AV1: TVector4); static;
    class procedure DrawVec(const AVec: TVector4); static;
  protected
    class function HasImGui: Boolean; override;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure DrawImGui; override;
  end;

implementation

uses
  System.Classes,
  Neslib.Sokol.Api,
  Neslib.OzzAnim.Api,
  Neslib.ImGui;

{ TOzzAnimApp }

procedure TOzzAnimApp.AnimationDataLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
  begin
    var Archive: TOzzIArchive := nil;
    var Stream := TOzzMemoryStream.Create;
    try
      Stream.Write(AResponse.BufferPtr^, AResponse.FetchedSize);
      Stream.Seek(0, soBeginning);

      Archive := TOzzIArchive.Create(Stream);
      if (Archive.TestTag<TOzzAnimation>) then
      begin
        Archive.Load(FAnimation);
        FLoaded.Animation := True;
      end
      else
        FLoaded.Failed := True;
    finally
      Archive.Free;
      Stream.Free;
    end;
  end
  else if (AResponse.Failed) then
    FLoaded.Failed := True;
end;

procedure TOzzAnimApp.Cleanup;
begin
  inherited;
  FLocalMatrices.Free;
  FModelMatrices.Free;
  FCamera.Free;
  sglShutdown;
  TFetch.Shutdown;
  FLocalToModelJob.Free;
  FSamplingJob.Free;
  FCache.Free;
  FAnimation.Free;
  FSkeleton.Free;
end;

procedure TOzzAnimApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'Ozz-Anim';
end;

procedure TOzzAnimApp.DrawImGui;
begin
  ImGui.SetNextWindowPos(Vector2(20, 30), TImGuiCond.Once);
  ImGui.SetNextWindowSize(Vector2(220, 150), TImGuiCond.Once);
  ImGui.SetNextWindowBgAlpha(0.35);
  if (ImGui.Begin('Controls', nil, TImGuiWindowFlags.NoDecoration + [TImGuiWindowFlag.AlwaysAutoResize])) then
  begin
    if (FLoaded.Failed) then
      ImGui.Text('Failed loading character data!')
    else
    begin
      ImGui.Text('Camera Controls:');
      ImGui.Text('  LMB + Drag:  Look');
      ImGui.Text('  Mouse wheel: Zoom');

      ImGui.SliderFloat('Distance', FCamera.Distance, FCamera.MinDist, FCamera.MaxDist, '%.1f');
      ImGui.SliderFloat('Latitude', FCamera.Latitude, FCamera.MinLat, FCamera.MaxLat, '%.1f');
      ImGui.SliderFloat('Longitude', FCamera.Longitude, 0, 360, '%.1f');

      ImGui.Separator;

      ImGui.Text('Time Controls:');
      ImGui.Checkbox('Paused', @FTime.Paused);
      ImGui.SliderFloat('Factor', FTime.Factor, 0, 10, '%.1f');
      if (ImGui.SliderFloat('Ratio', FTime.AnimRatio, 0, 1)) then
        FTime.AnimRatioUIOverride := True;
      if (ImGui.IsItemDeactivatedAfterEdit) then
        FTime.AnimRatioUIOverride := False;
    end;
  end;
  ImGui.End;
end;

procedure TOzzAnimApp.DrawJoint(const AJointIndex, AParentJointIndex: Integer);
{ This draws a wireframe 3d rhombus between the current and parent joints }
begin
  if (AParentJointIndex < 0) then
    Exit;

  var M0: PMatrix4 := FModelMatrices.ItemPtrs[AJointIndex];
  var M1: PMatrix4 := FModelMatrices.ItemPtrs[AParentJointIndex];

  var P0 := M0.C[3];
  var P1 := M1.C[3];
  var NY := M1.C[1];
  var NZ := M1.C[2];

  var DiffP := P1 - P0;
  var Diff3 := Vector3(DiffP.X, DiffP.Y, DiffP.Z);
  var Len := Vector4(Diff3.Length * 0.1);

  var PMid := P0 + ((P1 - P0) * Vector4(0.66));
  var P2 := PMid + (NY * Len);
  var P3 := PMid + (NZ * Len);
  var P4 := PMid - (NY * Len);
  var P5 := PMid - (NY * Len);

  sglC3F(1, 1, 0);
  DrawLine(P0, P2); DrawLine(P0, P3); DrawLine(P0, P4); DrawLine(P0, P5);
  DrawLine(P1, P2); DrawLine(P1, P3); DrawLine(P1, P4); DrawLine(P1, P5);
  DrawLine(P2, P3); DrawLine(P3, P4); DrawLine(P4, P5); DrawLine(P5, P2);
end;

class procedure TOzzAnimApp.DrawLine(const AV0, AV1: TVector4);
begin
  DrawVec(AV0);
  DrawVec(AV1);
end;

procedure TOzzAnimApp.DrawSkeleton;
begin
  sglDefaults;
  sglMatrixModeProjection;
  sglLoadMatrix(FCamera.Proj);
  sglMatrixModeModelview;
  sglLoadMatrix(FCamera.View);

  var NumJoints := FSkeleton.NumJoints;
  var JointParents := FSkeleton.JointParents;
  sglBeginLines;

  for var JointIndex := 0 to NumJoints - 1 do
    DrawJoint(JointIndex, JointParents[JointIndex]);

  sglEnd;
end;

class procedure TOzzAnimApp.DrawVec(const AVec: TVector4);
begin
  sglV3F(AVec.X, AVec.Y, AVec.Z);
end;

procedure TOzzAnimApp.EvalAnimation;
begin
  { Convert current time to animation ration (0.0 .. 1.0) }
  var AnimDuration: Single := FAnimation.Duration;
  if (not FTime.AnimRatioUIOverride) then
    FTime.AnimRatio := Frac(FTime.Absolut / AnimDuration);

  { Sample animation }
  FSamplingJob.Ratio := FTime.AnimRatio;
  FSamplingJob.Run;

  { Convert joint matrices from local to model space }
  FLocalToModelJob.Run;
end;

procedure TOzzAnimApp.Frame;
begin
  TFetch.DoWork;

  var FBWidth := FramebufferWidth;
  var FBHeight := FramebufferHeight;
  FTime.Frame := FrameDuration;
  FCamera.Update(FBWidth, FBHeight);

  if (FLoaded.Animation and FLoaded.Skeleton) then
  begin
    if (not FTime.Paused) then
      FTime.Absolut := FTime.Absolut + (FTime.Frame * FTime.Factor);

    EvalAnimation;
    DrawSkeleton;
  end;

  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  sglDraw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

class function TOzzAnimApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TOzzAnimApp.Init;
begin
  inherited;
  FSkeleton := TOzzSkeleton.Create;
  FAnimation := TOzzAnimation.Create;
  FCache := TOzzSamplingCache.Create;
  FSamplingJob := TOzzSamplingJob.Create;
  FLocalToModelJob := TOzzLocalToModelJob.Create;
  FTime.Factor := 1;

  FSamplingJob.Animation := FAnimation;
  FSamplingJob.Cache := FCache;

  FLocalToModelJob.Skeleton := FSkeleton;

  { Setup Sokol Fetch }
  var FetchDesc := TFetchDesc.Create;
  FetchDesc.MaxRequests := 2;
  FetchDesc.NumChannels := 1;
  FetchDesc.NumLanes := 2;
  FetchDesc.BaseDirectory := 'Data/ozz';
  TFetch.Setup(FetchDesc);

  { Setup Sokol GL }
  var GLDesc := TGLDesc.Create;
  GLDesc.SampleCount := SampleCount;
  sglSetup(GLDesc);

  { Initialize pass action for default-pass }
  FPassAction.Colors[0].Init(TAction.Clear, 0.0, 0.1, 0.2);

  { Initialize camera helper }
  var CamDesc := TCameraDesc.Create;
  CamDesc.MinDist := 1;
  CamDesc.MaxDist := 10;
  CamDesc.Center.Y := 1;
  CamDesc.Distance := 3;
  CamDesc.Latitude := 10;
  CamDesc.Longitude := 20;
  FCamera := TCamera.Create(CamDesc);

  { Start loading the skeleton and animation files }
  var Req := TFetchRequest.Create('ozz_anim_skeleton.ozz', SkeletonDataLoaded,
    @FSkeletonData, SizeOf(FSkeletonData));
  Req.Send;

  Req := TFetchRequest.Create('ozz_anim_animation.ozz', AnimationDataLoaded,
    @FAnimationData, SizeOf(FAnimationData));
  Req.Send;
end;

procedure TOzzAnimApp.SkeletonDataLoaded(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
  begin
    var Archive: TOzzIArchive := nil;
    var Stream := TOzzMemoryStream.Create;
    try
      Stream.Write(AResponse.BufferPtr^, AResponse.FetchedSize);
      Stream.Seek(0, soBeginning);

      Archive := TOzzIArchive.Create(Stream);
      if (Archive.TestTag<TOzzSkeleton>) then
      begin
        Archive.Load(FSkeleton);
        FLoaded.Skeleton := True;
        var NumSoaJoints := FSkeleton.NumSoaJoints;
        var NumJoints := FSkeleton.NumJoints;

        FLocalMatrices := TAlignedArray<TOzzSoaTransform>.Create(NumSoaJoints);
        FModelMatrices  := TAlignedArray<TMatrix4>.Create(NumJoints);
        FCache.Resize(NumJoints);

        FSamplingJob.Output := TOzzSpan<TOzzSoaTransform>.Create(FLocalMatrices);

        FLocalToModelJob.Input := TOzzSpan<TOzzSoaTransform>.Create(FLocalMatrices);
        FLocalToModelJob.Output := TOzzSpan<TMatrix4>.Create(FModelMatrices);
      end
      else
        FLoaded.Failed := True;
    finally
      Archive.Free;
      Stream.Free;
    end;
  end
  else if (AResponse.Failed) then
    FLoaded.Failed := True;
end;

end.

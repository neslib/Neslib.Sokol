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
  var Pass := TPass.Create;
  Pass.Action.Colors[0].Init(TLoadAction.DontCare, 0, 0, 0);
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TSpineSimpleApp.Cleanup;
begin
  inherited;
end;

procedure TSpineSimpleApp.SkeletonDataLoaded(const AResponse: TFetchResponse);
begin
  Assert(False);
end;

procedure TSpineSimpleApp.AtlasDataLoaded(const AResponse: TFetchResponse);
begin
  Assert(False);
end;

end.

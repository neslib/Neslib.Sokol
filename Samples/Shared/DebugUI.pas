unit DebugUI;

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx.ImGui;

type
  TDebugUI = class
  private
    FDebugContext: TImGuiDebugContext;
    function EventHandler(const AEvent: TEvent): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Draw;
  end;

implementation

uses
  Neslib.ImGui,
  Neslib.Sokol.Api,
  Neslib.Sokol.ImGui,
  SampleApp;

type
  TSampleAppAccess = class(TSampleApp);

{ TDebugUI }

constructor TDebugUI.Create;
begin
  inherited Create;
  TApplication.AddEventHandler(EventHandler);

  FDebugContext.Init;

  var Desc := TSokolImGuiDesc.Create;
  Desc.SampleCount := TApplication.SampleCount;

  Assert(TApplication.Instance is TSampleApp);
  TSampleAppAccess(TApplication.Instance).ConfigureSokolImGui(Desc);

  SokolImGui.Setup(Desc);
end;

destructor TDebugUI.Destroy;
begin
  SokolImGui.Shutdown;
  FDebugContext.Free;
  TApplication.RemoveEventHandler(EventHandler);
  inherited;
end;

procedure TDebugUI.Draw;
begin
  var Desc: TSokolImGuiFrameDesc;
  Desc.Width := TApplication.FramebufferWidth;
  Desc.Height := TApplication.FramebufferHeight;
  Desc.DeltaTime := TApplication.FrameDuration;
  Desc.DpiScale := TApplication.DpiScale;
  SokolImGui.NewFrame(Desc);

  if ImGui.BeginMainMenuBar then
  begin
    if ImGui.BeginMenu('Neslib.Sokol.Gfx') then
    begin
      ImGui.MenuItem('Capabilities', nil, FDebugContext.CapabilitiesOpen);
      ImGui.MenuItem('Buffers', nil, FDebugContext.BuffersOpen);
      ImGui.MenuItem('Images', nil, FDebugContext.ImagesOpen);
      ImGui.MenuItem('Shaders', nil, FDebugContext.ShadersOpen);
      ImGui.MenuItem('Pipelines', nil, FDebugContext.PipelinesOpen);
      ImGui.MenuItem('Passes', nil, FDebugContext.PassesOpen);
      ImGui.MenuItem('Calls', nil, FDebugContext.CaptureOpen);
      ImGui.EndMenu;
    end;
    ImGui.EndMainMenuBar;
  end;

  Assert(TApplication.Instance is TSampleApp);
  TSampleAppAccess(TApplication.Instance).DrawImGui;

  FDebugContext.Draw;
  SokolImGui.Render;
end;

function TDebugUI.EventHandler(const AEvent: TEvent): Boolean;
begin
  if (AEvent.Kind >= TEventKind.Resized) and (AEvent.Kind <> TEventKind.ClipboardPasted) then
    { These events should not be handled by the Debug UI }
    Result := False
  else
    Result := _simgui_handle_event(@AEvent);
end;

end.

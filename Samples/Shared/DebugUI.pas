unit DebugUI;

interface

uses
  Neslib.Sokol.App;

type
  TDebugUI = class
  private
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
  Neslib.Sokol.App.ImGui,
  Neslib.Sokol.Gfx.ImGui,
  Neslib.Sokol.Utils,
  {$IFDEF SOKOL_MEM_TRACK}
  Neslib.Sokol.MemTrack,
  {$ENDIF}
  SampleApp;

type
  TSampleAppAccess = class(TSampleApp);

{ TDebugUI }

constructor TDebugUI.Create;
begin
  inherited Create;
  TApplication.AddEventHandler(EventHandler);

  TAppImGui.Setup;

  var GfxDesc := TGfxImGuiDesc.Create;
  GfxDesc.UseDelphiMemoryManager := True;
  TGfxImGui.Setup(GfxDesc);

  var ImGuiDesc := TSokolImGuiDesc.Create;
  ImGuiDesc.SampleCount := TApplication.SampleCount;
  ImGuiDesc.Logger := ImGuiDesc.DefaultLogger;
  ImGuiDesc.WriteAlphaChannel := True;
  ImGuiDesc.UseDelphiMemoryManager := True;

  Assert(TApplication.Instance is TSampleApp);
  TSampleAppAccess(TApplication.Instance).ConfigureSokolImGui(ImGuiDesc);

  SokolImGui.Setup(ImGuiDesc);
end;

destructor TDebugUI.Destroy;
begin
  SokolImGui.Shutdown;
  TAppImGui.Shutdown;
  TGfxImGui.Shutdown;
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
  TAppImGui.TrackFrame;

  Assert(TApplication.Instance is TSampleApp);
  if (ImGui.BeginMainMenuBar) then
  begin
    TGfxImGui.DrawMenu('Sokol.Gfx');
    TAppImGui.DrawMenu('Sokol.App');
    TSampleAppAccess(TApplication.Instance).DrawImGuiMainMenuItems;
    ImGui.EndMainMenuBar;
  end;

  TSampleAppAccess(TApplication.Instance).DrawImGui;

  TAppImGui.Draw;
  TGfxImGui.Draw;
  SokolImGui.Render;
end;

function TDebugUI.EventHandler(const AEvent: TEvent): Boolean;
begin
  TAppImGui.TrackEvent(AEvent);
  if (AEvent.Kind >= TEventKind.Resized) and (AEvent.Kind <> TEventKind.ClipboardPasted) then
    { These events should not be handled by the Debug UI }
    Result := False
  else
    Result := SokolImGui.HandleEvent(@AEvent);
end;

end.

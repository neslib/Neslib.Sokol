unit SettingsUI;

interface

uses
  Neslib.Sokol.App;

type
  TSettingsUI = class
  private
    function EventHandler(const AEvent: TEvent): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Draw;
  end;

implementation

uses
  Neslib.Sokol.Api,
  Neslib.Sokol.ImGui,
  SampleApp;

type
  TSampleAppAccess = class(TSampleApp);

{ TSettingsUI }

constructor TSettingsUI.Create;
begin
  inherited Create;
  TApplication.AddEventHandler(EventHandler);

  var Desc := TSokolImGuiDesc.Create;
  Desc.SampleCount := TApplication.SampleCount;

  Assert(TApplication.Instance is TSampleApp);
  TSampleAppAccess(TApplication.Instance).ConfigureSokolImGui(Desc);

  SokolImGui.Setup(Desc);
end;

destructor TSettingsUI.Destroy;
begin
  SokolImGui.Shutdown;
  TApplication.RemoveEventHandler(EventHandler);
  inherited;
end;

procedure TSettingsUI.Draw;
begin
  var Desc: TSokolImGuiFrameDesc;
  Desc.Width := TApplication.FramebufferWidth;
  Desc.Height := TApplication.FramebufferHeight;
  Desc.DeltaTime := TApplication.FrameDuration;
  Desc.DpiScale := TApplication.DpiScale;
  SokolImGui.NewFrame(Desc);

  Assert(TApplication.Instance is TSampleApp);
  TSampleAppAccess(TApplication.Instance).DrawImGui;

  SokolImGui.Render;
end;

function TSettingsUI.EventHandler(const AEvent: TEvent): Boolean;
begin
  Result := _simgui_handle_event(@AEvent);
end;

end.

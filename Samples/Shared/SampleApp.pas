unit SampleApp;

{$INCLUDE 'Neslib.Sokol.inc'}
{$IFDEF MOBILE}
  {$UNDEF USE_DBG_UI}
{$ENDIF}

interface

uses
  {$IFDEF USE_DBG_UI}
  DebugUI,
  {$ELSE}
  SettingsUI,
  {$ENDIF}
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.ImGui;

type
  TSampleApp = class abstract(TApplication)
  private
    {$IFDEF USE_DBG_UI}
    FDebugUI: TDebugUI;
    {$ELSE}
    FSettingsUI: TSettingsUI;
    {$ENDIF}
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Cleanup; override;
  protected
    class function HasImGui: Boolean; virtual;
  protected
    procedure ConfigureGfx(var ADesc: TGfxDesc); virtual;
    procedure ConfigureSokolImGui(var ADesc: TSokolImGuiDesc); virtual;
    procedure DrawImGui; virtual;
  protected
    procedure DebugFrame;
  public
    destructor Destroy; override;
  end;

implementation

uses
  Neslib.Sokol.Glue;

{ TSampleApp }

procedure TSampleApp.DebugFrame;
begin
  {$IFDEF USE_DBG_UI}
  FDebugUI.Draw;
  {$ELSE}
  if Assigned(FSettingsUI) then
    FSettingsUI.Draw;
  {$ENDIF}
end;

destructor TSampleApp.Destroy;
begin
  TGfx.Shutdown;
  inherited;
end;

procedure TSampleApp.DrawImGui;
begin
  { No default implementation }
end;

procedure TSampleApp.Cleanup;
begin
  {$IFDEF USE_DBG_UI}
  FDebugUI.Free;
  {$ELSE}
  FSettingsUI.Free;
  {$ENDIF}
end;

procedure TSampleApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.HighDpi := True;
  AConfig.SampleCount := 4;
end;

procedure TSampleApp.ConfigureGfx(var ADesc: TGfxDesc);
begin
  { No default implementation }
end;

procedure TSampleApp.ConfigureSokolImGui(var ADesc: TSokolImGuiDesc);
begin
  { No default implementation }
end;

class function TSampleApp.HasImGui: Boolean;
begin
  Result := False;
end;

procedure TSampleApp.Init;
begin
  var Desc := TGfxDesc.Create;
  ConfigureGfx(Desc);
  Desc.Context := Context;
  TGfx.Setup(Desc);

  {$IF Defined(USE_DBG_UI)}
  FDebugUI := TDebugUI.Create;
  {$ELSEIF not Defined(MOBILE)}
  if (HasImGui) then
    FSettingsUI := TSettingsUI.Create;
  {$ENDIF}
end;

end.

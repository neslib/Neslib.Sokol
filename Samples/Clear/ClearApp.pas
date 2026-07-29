unit ClearApp;

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  SampleApp;

type
  TClearApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
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

{ TClearApp }

procedure TClearApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 400;
  AConfig.Height := 300;
  AConfig.WindowTitle := 'Clear';
end;

procedure TClearApp.Init;
begin
  inherited;
  FPassAction.Colors[0].Init(TLoadAction.Clear, 1, 0, 0);
end;

procedure TClearApp.Frame;
begin
  var G: Single := FPassAction.Colors[0].ClearValue.G + 0.01;
  if (G > 1) then
    G := 0;
  FPassAction.Colors[0].ClearValue.G := G;

  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  DebugFrame;

  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TClearApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

end.

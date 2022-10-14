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
  Neslib.Sokol.Api;

{ TClearApp }

procedure TClearApp.Cleanup;
begin
  inherited;
end;

procedure TClearApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 400;
  AConfig.Height := 300;
  AConfig.AndroidForceGles2 := True;
  AConfig.WindowTitle := 'Clear';
end;

procedure TClearApp.Frame;
begin
  var G: Single := FPassAction.Colors[0].Value.G + 0.01;
  if (G > 1) then
    G := 0;
  FPassAction.Colors[0].Value.G := G;

  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);

  DebugFrame;

  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TClearApp.Init;
begin
  inherited;
  FPassAction.Colors[0].Init(TAction.Clear, 1, 0, 0);
end;

end.

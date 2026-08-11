unit HdrApp;
{ Test rendering into a HDR framebuffer. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  SampleApp;

type
  THdrApp = class(TSampleApp)
  private
    FPip: TPipeline;
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
  Neslib.Sokol.Glue,
  HdrShader;

{ THdrApp }

procedure THdrApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.WindowTitle := 'HDR Framebuffer';
  AConfig.Width := 640;
  AConfig.Height := 480;
  AConfig.Hdr := True;
  AConfig.DepthFormat := TAppPixelFormat.None;
end;

procedure THdrApp.Init;
begin
  inherited;
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(TriangleShaderDesc);
  FPip := TPipeline.Create(PipDesc);

  FPassAction.Colors[0].Init(TLoadAction.Clear, 0, 0, 0, 1);
end;

procedure THdrApp.Frame;
begin
  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);
  TGfx.ApplyPipeline(FPip);
  TGfx.Draw(0, 6);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure THdrApp.Cleanup;
begin
  { Not needed in this example since TGfx.Shutdown cleans up and frees all
    GFX resources }
  inherited;
end;

end.

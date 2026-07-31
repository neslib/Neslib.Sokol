unit FrameBufferApp;
{ Simple Neslib.Sokol.FrameBuffer sample.
  Plasma effect taken from shadertoy https://www.shadertoy.com/view/MdXGDH }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Framebuffer,
  Neslib.FastMath,
  SampleApp;

type
  TFrameBufferApp = class(TSampleApp)
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

{ TFrameBufferApp }

procedure TFrameBufferApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.WindowTitle := 'Framebuffer';
end;

procedure TFrameBufferApp.Init;
begin
  inherited;
end;

procedure TFrameBufferApp.Frame;
begin
  var Pass := TPass.Create;
  Pass.Action.Colors[0].Init(TLoadAction.DontCare, 0, 0, 0);
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TFrameBufferApp.Cleanup;
begin
  inherited;
end;

end.

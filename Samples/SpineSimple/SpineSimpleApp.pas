unit SpineSimpleApp;
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
  TSpineSimpleApp = class(TSampleApp)
  private const
    FB_WIDTH  = 320;
    FB_HEIGHT = 256;
  private
    FFramebuffer: TFramebuffer;
    FTime: Single;
    FPixels: array [0..FB_HEIGHT - 1, 0..FB_WIDTH - 1] of UInt32;
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
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 1;
  AConfig.WindowTitle := 'Framebuffer';
end;

procedure TSpineSimpleApp.Init;
begin
  inherited;
  var SetupDesc := TFramebufferSetupDesc.Create;
  SetupDesc.UseDelphiMemoryManager := True;
  SetupDesc.Logger := SetupDesc.DefaultLogger;
  TFramebuffer.Setup(SetupDesc);

  var Desc := TFramebufferDesc.Create;
  Desc.Width := FB_WIDTH;
  Desc.Height := FB_HEIGHT;
  FFramebuffer := TFramebuffer.Create(Desc);
end;

procedure TSpineSimpleApp.Frame;
begin
  { Update framebuffer pixels with plasma effect }
  FTime := FMod(FTime + FrameDuration, 3600);
  var T3: Single := FTime * 0.6;
  for var Y := 0 to FB_HEIGHT - 1 do
  begin
    for var X := 0 to FB_WIDTH - 1 do
    begin
      var Coord := Vector2(X * 2, Y * 2);
      var S, C: Single;

      FastSinCos(T3, S, C);
      var Color1: Single := (Sin(Coord.Dot(Vector2(S, C)) * 0.02 + T3) + 1) * 0.5;

      FastSinCos(-T3, S, C);
      var Center := Vector2(320, 180) + Vector2(320 * S, 180 * C);

      var Color2: Single := (FastCos((Coord - Center).Length * 0.03) + 1) * 0.5;
      var Color: Single := Color1 + Color2;

      FastSinCos((PI * Color) + T3, S, C);
      var RF: Single := (C + 1) * 0.5;
      var GF: Single := (S + 1) * 0.5;
      var BF: Single := (FastSin(T3) + 1) * 0.5;

      var RB: Byte := Trunc(RF * 255);
      var GB: Byte := Trunc(GF * 255);
      var BB: Byte := Trunc(BF * 255);

      FPixels[Y, X] := $FF000000 or (BB shl 16) or (GB shl 8) or RB;
    end;
  end;

  { Update framebuffer with plasma pixels outside a Neslib.Sokol.Gfx pass }
  var UpdateDesc := TFramebufferUpdateDesc.Create;
  UpdateDesc.Pixels := TRange.Create(FPixels);
  FFramebuffer.Update(UpdateDesc);

  { Draw framebuffer in Neslib.Sokol.Gfx render pass }
  var Pass := TPass.Create;
  Pass.Action.Colors[0].Init(TLoadAction.DontCare, 0, 0, 0);
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  FFramebuffer.Render;

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TSpineSimpleApp.Cleanup;
begin
  TFramebuffer.Shutdown;
  inherited;
end;

end.

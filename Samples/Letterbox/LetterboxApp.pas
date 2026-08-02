unit LetterboxApp;
{ Demonstrate Neslib.Sokol.Letterbox. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Letterbox,
  Neslib.FastMath,
  SampleApp;

type
  TLetterboxApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
    FLetterbox: TLetterboxDesc;
    FLinkLRBorder: Boolean;
    FLinkTBBorder: Boolean;
  private
    class procedure MainQuad; static;
    class procedure CornerQuad(const AX, AY: Single); static;
  protected
    class function HasImGui: Boolean; override;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure DrawImGui; override;
  end;

implementation

uses
  Neslib.ImGui,
  Neslib.Sokol.Api,
  Neslib.Sokol.GL,
  Neslib.Sokol.Glue;

const
  ANCHORS: array [TLetterboxAnchor] of PUTF8Char = (
    'Center', 'Top', 'Bottom', 'Left', 'Right');

{ TLetterboxApp }

procedure TLetterboxApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.WindowTitle := 'Letterbox';
end;

procedure TLetterboxApp.Init;
begin
  inherited;
  var GLDesc := TGLDesc.Create;
  GLDesc.UseDelphiMemoryManager := True;
  GLDesc.Logger := GLDesc.DefaultLogger;
  sglSetup(GLDesc);

  FPassAction.Colors[0].Init(TLoadAction.Clear, 0, 0, 0, 1);
  FLinkLRBorder := True;
  FLinkTBBorder := True;
  FLetterbox.ContentAspectRatio := 4 / 3;
end;

procedure TLetterboxApp.Frame;
begin
  var Width := FramebufferWidth;
  var Height := FramebufferHeight;

  { Draw a letterboxed fullscreen quad via sgl }
  sglDefaults;
  var VP := Letterbox(Width, Height, FLetterbox);
  sglViewport(VP.X, VP.Y, VP.Width, VP.Height, True);

  sglBeginQuads;
  MainQuad;
  CornerQuad(-0.9,  0.9);
  CornerQuad( 0.9,  0.9);
  CornerQuad( 0.9, -0.9);
  CornerQuad(-0.9, -0.9);
  sglEnd;
  sglViewport(0, 0, Width, Height, True);

  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  sglDraw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TLetterboxApp.Cleanup;
begin
  sglShutdown;
  inherited;
end;

class procedure TLetterboxApp.MainQuad;
begin
  sglV2F_C3B(-1.0,  1.0, 255, 0, 0);
  sglV2F_C3B( 1.0,  1.0, 255, 255, 0);
  sglV2F_C3B( 1.0, -1.0, 0, 255, 0);
  sglV2F_C3B(-1.0, -1.0, 0, 255, 255);
end;

class procedure TLetterboxApp.CornerQuad(const AX, AY: Single);
const
  S = 0.05;
  R = 255;
  G = 128;
  B = 255;
begin
  sglV2F_C3B(AX - S, AY + S, R, G, B);
  sglV2F_C3B(AX + S, AY + S, R, G, B);
  sglV2F_C3B(AX + S, AY - S, R, G, B);
  sglV2F_C3B(AX - S, AY - S, R, G, B);
end;

class function TLetterboxApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TLetterboxApp.DrawImGui;
begin
  inherited;
  ImGui.SetNextWindowPos(Vector2(30, 50), TImGuiCond.Once);
  ImGui.SetNextWindowBgAlpha(0.75);

  if (ImGui.Begin('Controls', nil, TImGuiWindowFlags.NoDecoration + [TImGuiWindowFlag.AlwaysAutoResize])) then
  begin
    ImGui.Text('Resize app window!'#10);

    ImGui.SliderFloat('Content Aspect Ratio', @FLetterBox.ContentAspectRatio, 0.5, 2);
    ImGui.Combo('Anchor', @FLetterBox.Anchor, PPUTF8Char(@ANCHORS), Length(ANCHORS));

    ImGui.SeparatorText('Border');

    ImGui.Checkbox('Link Left/Right', @FLinkLRBorder);
    if (ImGui.SliderInt('Left', @FLetterBox.Border.Left, -50, 50)) and (FLinkLRBorder) then
      FLetterbox.Border.Right := FLetterbox.Border.Left;
    if (ImGui.SliderInt('Right', @FLetterBox.Border.Right, -50, 50)) and (FLinkLRBorder) then
      FLetterbox.Border.Left := FLetterbox.Border.Right;

    ImGui.Checkbox('Link Top/Bottom', @FLinkTBBorder);
    if (ImGui.SliderInt('Top', @FLetterBox.Border.Top, -50, 50)) and (FLinkTBBorder) then
      FLetterbox.Border.Bottom := FLetterbox.Border.Top;
    if (ImGui.SliderInt('Bottom', @FLetterBox.Border.Bottom, -50, 50)) and (FLinkTBBorder) then
      FLetterbox.Border.Top := FLetterbox.Border.Bottom;
  end;
  ImGui.End;
end;

end.

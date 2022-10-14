unit ImGuiHighDpiApp;
{ Demonstrates Dear ImGui UI rendering via Neslib.Sokol.Gfx and
  Neslib.Sokol.ImGui, with HighDPI rendering and a custom embedded font. }

interface

uses
  System.UITypes,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.ImGui,
  SampleApp;

type
  TImGuiHighDpiApp = class(TSampleApp)
  private
    FShowTestWindow: Boolean;
    FShowAnotherWindow: Boolean;
    FShowQuitDialog: Boolean;
    FPassAction: TPassAction;
    FFontAtlas: TImage;
    FFloatVal: Single;
  protected
    class function HasImGui: Boolean; override;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure ConfigureSokolImGui(var ADesc: TSokolImGuiDesc); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure DrawImGui; override;
    procedure QuitRequested(var ACanQuit: Boolean); override;
  end;

implementation

uses
  Neslib.FastMath,
  Neslib.Sokol.Api,
  Neslib.ImGui,
  ImGuiFont;

{ TImGuiHighDpiApp }

procedure TImGuiHighDpiApp.Cleanup;
begin
  inherited;
  FFontAtlas.Free;
end;

procedure TImGuiHighDpiApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 1024;
  AConfig.Height := 768;
  AConfig.WindowTitle := 'Dear ImGui HighDpi';
  AConfig.FullScreen := True;
  AConfig.HighDpi := True;
  AConfig.iOSKeyboardResizesCanvas := False;
  AConfig.EnableClipboard := True;
end;

procedure TImGuiHighDpiApp.ConfigureSokolImGui(var ADesc: TSokolImGuiDesc);
begin
  inherited;
  { We provide our own font }
  ADesc.NoDefaultFont := True;
end;

procedure TImGuiHighDpiApp.DrawImGui;
begin
  { Show a simple window.
    Tip: if we don't call ImGui.Begin/ImGui.End, the widgets appears in a window
    automatically called "Debug" }
  ImGui.Text('Hello, world!');
  ImGui.SliderFloat('float', FFloatVal, 0, 1, '%.3f');
  ImGui.ColorEdit3('clear color', FPassAction.Colors[0].Value);
  ImGui.Text(ImGui.Format('width: %d, height: %d, DPI scale: %.1f',
    [FramebufferWidth, FramebufferHeight, DpiScale]));

  if (ImGui.Button('Test Window')) then
    FShowTestWindow := not FShowTestWindow;

  if (ImGui.Button('Another Window')) then
    FShowAnotherWindow := not FShowAnotherWindow;

  if (ImGui.Button('Soft Quit')) then
    RequestQuit;

  if (ImGui.Button('Hard Quit')) then
    Quit;

  if (FullScreen) then
  begin
    if (ImGui.Button('Switch to windowed')) then
      FullScreen := False;
  end
  else
  begin
    if (ImGui.Button('Switch to fullscreen')) then
      FullScreen := True;
  end;

  ImGui.Text(ImGui.Format('Application average %.3f ms/frame (%.1f FPS)',
    [1000 / ImGui.GetIO.Framerate, ImGui.GetIO.Framerate]));

  { 2. Show another simple window, this time using an explicit Begin/End pair }
  if (FShowAnotherWindow) then
  begin
    ImGui.SetNextWindowSize(Vector2(200, 100), TImGuiCond.FirstUseEver);
    ImGui.&Begin('Another Window', @FShowAnotherWindow);
    ImGui.Text('Hello');
    ImGui.&End;
  end;

  { 3. Show the built-in ImGui test window. }
  if (FShowTestWindow) then
  begin
    ImGui.SetNextWindowPos(Vector2(460, 20), TImGuiCond.FirstUseEver);
    ImGui.ShowDemoWindow;
  end;

  { 4. Prepare and conditionally open the "Really Quit?" popup }
  if (ImGui.BeginPopupModal('Really Quit?', nil, [TImGuiWindowFlag.AlwaysAutoResize])) then
  begin
    ImGui.Text('Do you really want to quit?');
    ImGui.Separator;
    if (ImGui.Button('OK', Vector2(120, 0))) then
    begin
      Quit;
      ImGui.CloseCurrentPopup;
    end;

    ImGui.SetItemDefaultFocus;
    ImGui.SameLine;
    if (ImGui.Button('Cancel', Vector2(120, 0))) then
      ImGui.CloseCurrentPopup;

    ImGui.EndPopup;
  end;

  if (FShowQuitDialog) then
  begin
    ImGui.OpenPopup('Really Quit?');
    FShowQuitDialog := False;
  end;
end;

procedure TImGuiHighDpiApp.Frame;
begin
  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

class function TImGuiHighDpiApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TImGuiHighDpiApp.Init;
begin
  inherited;
  FShowTestWindow := True;

  { Configure Dear ImGui with our own embedded font }
  var IO := ImGui.GetIO;
  var FontCfg := TImFontConfig.Create;
  try
    FontCfg.FontDataOwnedByAtlas := False;
    FontCfg.OversampleH := 2;
    FontCfg.OversampleV := 2;
    FontCfg.RasterizerMultiply := 1.5;
    IO.Fonts.AddFontFromMemoryTTF(@DUMP_FONT, SizeOf(DUMP_FONT), 16, FontCfg);
  finally
    FontCfg.Free;
  end;

  { Create font texture for the custom font }
  var FontPixels: PByte;
  var FontWidth, FontHeight: Integer;
  IO.Fonts.GetTexDataAsRGBA32(FontPixels, FontWidth, FontHeight);

  var ImgDesc := TImageDesc.Create;
  ImgDesc.Width := FontWidth;
  ImgDesc.Height := FontHeight;
  ImgDesc.PixelFormat := TPixelFormat.Rgba8;
  ImgDesc.WrapU := TWrap.ClampToEdge;
  ImgDesc.WrapV := TWrap.ClampToEdge;
  ImgDesc.MinFilter := TFilter.Linear;
  ImgDesc.MagFilter := TFilter.Linear;
  ImgDesc.Data.SubImages[0] := TRange.Create(FontPixels, FontWidth * FontHeight * 4);
  FFontAtlas := TImage.Create(ImgDesc);
  IO.Fonts.TexID := TImTextureID(FFontAtlas.Id);

  FPassAction.Colors[0].Init(TAction.Clear, 0.3, 0.7, 0, 1);
  Include(ImGui.GetIO.ConfigFlags, TImGuiConfigFlag.DockingEnable);
end;

procedure TImGuiHighDpiApp.QuitRequested(var ACanQuit: Boolean);
begin
  inherited;
  FShowQuitDialog := True;
  ACanQuit := False;
end;

end.

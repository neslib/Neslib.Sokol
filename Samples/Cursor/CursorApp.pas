unit CursorApp;
{ Showcases support for system built-in and custom mouse cursor images }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.ImGui,
  SampleApp;

type
  TCursorApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
    FCursors: array [0..3] of TMouseCursor;
    FCursorHotspotTL: TMouseCursor;
    FCursorHotspotTR: TMouseCursor;
    FCursorHotspotBL: TMouseCursor;
    FCursorHotspotBR: TMouseCursor;
    FCursorsAnim: array [0..7] of TMouseCursor;

    { To keep track of which 'system' cursor is currently bound to a custom image. }
    FCustomized: array [TMouseCursor] of Boolean;
  private
    class function GenerateImage(const ADim, AColorOffset: Integer;
      const AHighlightX: Integer = -1; const AHighlightY: Integer = -1): TAppImageDesc; static;
    class function DrawCursorPanel(const AText: PUTF8Char; const APanelWidth,
      APanelHeight: Single): Boolean; static;
  protected
    class function HasImGui: Boolean; override;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure ConfigureSokolImGui(var ADesc: TSokolImGuiDesc); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure DrawImGui; override;
  end;

implementation

uses
  Neslib.ImGui,
  Neslib.FastMath,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue;

function MouseCursorToStr(const ACursor: TMouseCursor): PUTF8Char;
const
  CURSORS: array [TMouseCursor] of PUTF8Char = (
    'Default', 'Arrow', 'IBeam', 'Crosshair', 'PointingHand', 'ResizeEW',
    'ResizeNS', 'ResizeNWSE', 'ResizeNESW', 'ResizeAll', 'NotAllowed',
    'Custom0', 'Custom1', 'Custom2', 'Custom3', 'Custom4', 'Custom5', 'Custom6',
    'Custom7', 'Custom8', 'Custom9', 'Custom10', 'Custom11', 'Custom12',
    'Custom13', 'Custom14', 'Custom15');
begin
  Result := CURSORS[ACursor];
end;

{ TCursorApp }

procedure TCursorApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 832;
  AConfig.Height := 615;
  AConfig.DepthFormat := TAppPixelFormat.None;
  AConfig.WindowTitle := 'Cursor';
end;

procedure TCursorApp.ConfigureSokolImGui(var ADesc: TSokolImGuiDesc);
begin
  inherited;
  { We want to have control over the cursor, that's the point of this sample }
  ADesc.DisableSetMouseCursor := True;
end;

procedure TCursorApp.Init;
begin
  inherited;
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0, 0.5, 0.7, 1);

  var Image16 := GenerateImage(16, 0);
  Image16.CursorHotspotX := 8;
  Image16.CursorHotspotY := 8;

  var Image32 := GenerateImage(32, 0);
  Image32.CursorHotspotX := 16;
  Image32.CursorHotspotY := 16;

  var Image64 := GenerateImage(64, 0);
  Image64.CursorHotspotX := 32;
  Image64.CursorHotspotY := 32;

  var Image128 := GenerateImage(128, 0);
  Image128.CursorHotspotX := 64;
  Image128.CursorHotspotY := 64;

  FCursors[0] := BindMouseCursorImage(TMouseCursor.Custom0, Image16);
  FCursors[1] := BindMouseCursorImage(TMouseCursor.Custom1, Image32);
  FCursors[2] := BindMouseCursorImage(TMouseCursor.Custom2, Image64);
  FCursors[3] := BindMouseCursorImage(TMouseCursor.Custom3, Image128);

  var ImageTL := GenerateImage(32, 0, 0, 0);
  ImageTL.CursorHotspotX := 0;
  ImageTL.CursorHotspotY := 0;
  FCursorHotspotTL := BindMouseCursorImage(TMouseCursor.Custom4, ImageTL);

  var ImageTR := GenerateImage(32, 0, 30, 0);
  ImageTR.CursorHotspotX := 30;
  ImageTR.CursorHotspotY := 0;
  FCursorHotspotTR := BindMouseCursorImage(TMouseCursor.Custom5, ImageTR);

  var ImageBL := GenerateImage(32, 0, 0, 30);
  ImageBL.CursorHotspotX := 0;
  ImageBL.CursorHotspotY := 30;
  FCursorHotspotBL := BindMouseCursorImage(TMouseCursor.Custom6, ImageBL);

  var ImageBR := GenerateImage(32, 0, 30, 30);
  ImageBR.CursorHotspotX := 30;
  ImageBR.CursorHotspotY := 30;
  FCursorHotspotBR := BindMouseCursorImage(TMouseCursor.Custom7, ImageBR);

  FreeMem(Image16.Data);
  FreeMem(Image32.Data);
  FreeMem(Image64.Data);
  FreeMem(Image128.Data);

  FreeMem(ImageTL.Data);
  FreeMem(ImageTR.Data);
  FreeMem(ImageBL.Data);
  FreeMem(ImageBR.Data);

  for var I := 0 to 7 do
  begin
    Image32 := GenerateImage(32, I);
    Image32.CursorHotspotX := 15;
    Image32.CursorHotspotY := 15;
    FCursorsAnim[I] := BindMouseCursorImage(TMouseCursor(Ord(TMouseCursor.Custom8) + I), Image32);
    FreeMem(Image32.Data);
  end;
end;

procedure TCursorApp.Frame;
begin
  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TCursorApp.Cleanup;
begin
  { NOTE: No need to unbind mouse cursors on shutdown.
    It is done automatically by Neslib.Sokol.App. }
  inherited;
end;

class function TCursorApp.GenerateImage(const ADim, AColorOffset, AHighlightX,
  AHighlightY: Integer): TAppImageDesc;
const
  { Amstrad CPC font 'S' }
  TILE: array [0..7] of Byte = (
    $3C, $66, $60, $3C, $06, $66, $3C, $00);
const
  { Rainbow colors }
  COLORS: array [0..7] of Cardinal = (
    $FF4370FF, $FF26A7FF, $FF58EEFF, $FF57E1D4,
    $FF65CC9C, $FF6ABB66, $FFF5A542, $FFC2577E);
const
  BLANK     = $00FFFFFF;
  SHADOW    = $FF000000;
  HIGHLIGHT = $FF0000FF;
  W         = 2;
begin
  var NumPixels := ADim * ADim;
  var Size := NumPixels * SizeOf(Cardinal);
  Result.Width := ADim;
  Result.Height := ADim;
  GetMem(Result.Data, Size);
  FillChar(Result.Data^, Size, 0);
  Result.Size := Size;

  var Dst := PCardinal(Result.Data);
  Assert((ADim mod 8) = 0);
  var Scale := ADim div 8;
  for var TY := 0 to 7 do
  begin
    var Color := COLORS[(TY + (8 - AColorOffset)) mod 8];
    for var SY := 0 to Scale - 1 do
    begin
      var Bits: Byte := TILE[TY];
      for var TX := 0 to 7 do
      begin
        var Pixel: Cardinal;
        if ((Bits and $80) = 0) then
          Pixel := BLANK
        else
          Pixel := Color;

        for var SX := 0 to Scale - 1 do
        begin
          Dst^ := Pixel;
          Inc(Dst);
        end;

        Bits := (Bits and $7F) shl 1;
      end;
    end;
  end;

  {$POINTERMATH ON}
  { Right shadow }
  Dst := PCardinal(Result.Data);
  for var Y := 0 to ADim - 1 do
  begin
    var PrevColor: Cardinal := BLANK;
    for var X := 0 to ADim - 1 do
    begin
      var DstIndex := (Y * ADim) + X;
      var CurColor := Dst[DstIndex];
      if (CurColor = BLANK) and (PrevColor <> BLANK) then
        Dst[DstIndex] := SHADOW;
      PrevColor := CurColor;
    end;
  end;

  { Bottom shadow }
  for var X := 0 to ADim - 1 do
  begin
    var PrevColor: Cardinal := BLANK;
    for var Y := 0 to ADim - 1 do
    begin
      var DstIndex := (Y * ADim) + X;
      var CurColor := Dst[DstIndex];
      if (CurColor = BLANK) and (PrevColor <> BLANK) then
        Dst[DstIndex] := SHADOW;
      PrevColor := CurColor;
    end;
  end;

  { Hotspot highlight }
  if (AHighlightX <> -1) and (AHighlightY <> -1) then
  begin
    for var X := 0 to ADim - 1 do
      for var Y := 0 to ADim - 1 do
      begin
        if (X > (AHighlightX - W)) and (X <= (AHighlightX + W)) and
           (Y > (AHighlightY - W)) and (Y <= (AHighlightY + W))
        then
          Dst[(Y * ADim) + X] := HIGHLIGHT;
      end;
  end;
  {$POINTERMATH OFF}
end;

class function TCursorApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TCursorApp.DrawImGui;
const
  PAD = 5;
  PAD_Y = 20;
begin
  var PanelWidth: Single := 140 - ImGui.GetStyle.FramePadding.X;
  var PanelHeight: Single := 70;
  var PaddedSize := ImGui.GetIO.DisplaySize;
  PaddedSize.Offset(-PAD * 2, -PAD * 2 - PAD_Y);
  ImGui.SetNextWindowPos(Vector2(PAD, PAD + PAD_Y), TImGuiCond.Always);
  ImGui.SetNextWindowSize(PaddedSize, TImGuiCond.Always);

  var CursorToSet := TMouseCursor.Default;
  if (ImGui.Begin('Cursors', nil, [TImGuiWindowFlag.NoResize, TImGuiWindowFlag.NoCollapse])) then
  begin
    ImGui.Text('System cursors:');
    for var I := TMouseCursor.Default to TMouseCursor.NotAllowed do
    begin
      if ((Ord(I) mod 5) <> 0) then
        ImGui.SameLine;

      if (DrawCursorPanel(MouseCursorToStr(I), PanelWidth, PanelHeight)) then
        CursorToSet := I;
    end;

    ImGui.Separator;
    ImGui.Text('Custom image cursors:');

    if (DrawCursorPanel('16x16', PanelWidth, PanelHeight)) then
      CursorToSet := FCursors[0];

    ImGui.SameLine;
    if (DrawCursorPanel('32x32', PanelWidth, PanelHeight)) then
      CursorToSet := FCursors[1];

    ImGui.SameLine;
    if (DrawCursorPanel('64x64', PanelWidth, PanelHeight)) then
      CursorToSet := FCursors[2];

    ImGui.SameLine;
    if (DrawCursorPanel('128x128', PanelWidth, PanelHeight)) then
      CursorToSet := FCursors[3];

    if (DrawCursorPanel('Hotspot'#10'Top-Left', PanelWidth, PanelHeight)) then
      CursorToSet := FCursorHotspotTL;

    ImGui.SameLine;
    if (DrawCursorPanel('Hotspot'#10'Top-Right', PanelWidth, PanelHeight)) then
      CursorToSet := FCursorHotspotTR;

    ImGui.SameLine;
    if (DrawCursorPanel('Hotspot'#10'Bottom-Left', PanelWidth, PanelHeight)) then
      CursorToSet := FCursorHotspotBL;

    ImGui.SameLine;
    if (DrawCursorPanel('Hotspot'#10'Bottom-Right', PanelWidth, PanelHeight)) then
      CursorToSet := FCursorHotspotBR;

    if (DrawCursorPanel('Animated', PanelWidth, PanelHeight)) then
      CursorToSet := FCursorsAnim[(FrameCount div 15) mod 8];

    ImGui.Separator;
    ImGui.Text('Overriding "system" cursors with custom images:');

    var Cursor := TMouseCursor.Default;
    var Customized := PBoolean(@FCustomized[Cursor]);
    var Caption: PUTF8Char;
    if (Customized^) then
      Caption := 'Restore TMouseCursor.Default'
    else
      Caption := 'Customize TMouseCursor.Default';
    if (ImGui.Button(Caption)) then
    begin
      if (not Customized^) then
      begin
        var Image32 := GenerateImage(32, 0);
        Image32.CursorHotspotX := 16;
        Image32.CursorHotspotY := 16;
        BindMouseCursorImage(Cursor, Image32);
        FreeMem(Image32.Data);
      end
      else
        UnbindMouseCursorImage(Cursor);

      Customized^ := not Customized^;
    end;

    Cursor := TMouseCursor.IBeam;
    Customized := PBoolean(@FCustomized[Cursor]);
    if (Customized^) then
      Caption := 'Restore TMouseCursor.IBeam'
    else
      Caption := 'Customize TMouseCursor.IBeam';
    if (ImGui.Button(Caption)) then
    begin
      if (not Customized^) then
      begin
        var Image32 := GenerateImage(32, 0);
        Image32.CursorHotspotX := 16;
        Image32.CursorHotspotY := 16;
        BindMouseCursorImage(Cursor, Image32);
        FreeMem(Image32.Data);
      end
      else
        UnbindMouseCursorImage(Cursor);

      Customized^ := not Customized^;
    end;

    if (Customized^) then
    begin
      ImGui.SameLine;
      ImGui.Text('"To see the effect, hover the IBeam rectangle higher up!');
    end;
  end;
  ImGui.End;
  Self.MouseCursor := CursorToSet;
end;

class function TCursorApp.DrawCursorPanel(const AText: PUTF8Char;
  const APanelWidth, APanelHeight: Single): Boolean;
begin
  ImGui.Button(AText, Vector2(APanelWidth, APanelHeight));
  Result := ImGui.IsItemHovered;
end;

end.

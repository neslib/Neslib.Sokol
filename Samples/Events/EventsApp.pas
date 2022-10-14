unit EventsApp;
{ Inspect Neslib.Sokol.App events via Dear ImGui. }

interface

uses
  System.UITypes,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  SampleApp;

const
  MAX_DROPPED_FILES = 4;

type
  TEventsApp = class(TSampleApp)
  private
    FEvents: array [TEventKind] of TEvent;
    FPassAction: TPassAction;
    FDroppedFiles: TArray<String>;
  private
    function EventHandler(const AEvent: TEvent): Boolean;
    procedure DrawEventInfoPanel(const AKind: TEventKind; const AWidth,
      AHeight: Single);
  protected
    class function HasImGui: Boolean; override;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure FilesDropped(const AX, AY: Single;
      const AFilePaths: TArray<String>); override;
    procedure DrawImGui; override;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Neslib.ImGui,
  Neslib.FastMath,
  Neslib.Sokol.Api;

function EventKindToString(const AKind: TEventKind): String;
begin
  case AKind of
    TEventKind.KeyDown: Result := 'KeyDown';
    TEventKind.KeyUp: Result := 'KeyUp';
    TEventKind.Char: Result := 'Char';
    TEventKind.MouseDown: Result := 'MouseDown';
    TEventKind.MouseUp: Result := 'MouseUp';
    TEventKind.MouseScroll: Result := 'MouseScroll';
    TEventKind.MouseMove: Result := 'MouseMove';
    TEventKind.MouseEnter: Result := 'MouseEnter';
    TEventKind.MouseLeave: Result := 'MouseLeave';
    TEventKind.TouchesBegan: Result := 'TouchesBegan';
    TEventKind.TouchesMoved: Result := 'TouchesMoved';
    TEventKind.TouchesEnded: Result := 'TouchesEnded';
    TEventKind.TouchesCancelled: Result := 'TouchesCancelled';
    TEventKind.Resized: Result := 'Resized';
    TEventKind.Iconified: Result := 'Iconified';
    TEventKind.Restored: Result := 'Restored';
    TEventKind.Focused: Result := 'Focused';
    TEventKind.Unfocused: Result := 'Unfocused';
    TEventKind.Suspended: Result := 'Suspended';
    TEventKind.Resumed: Result := 'Resumed';
    TEventKind.QuitRequested: Result := 'QuitRequested';
    TEventKind.ClipboardPasted: Result := 'ClipboardPasted';
    TEventKind.FilesDropped: Result := 'FilesDropped';
  else
    Result := '???';
  end;
end;

function KeyCodeToString(const AKeyCode: TKeyCode): String;
begin
  case AKeyCode of
    TKeyCode.Invalid: Result := 'Invalid';
    TKeyCode.Space: Result := 'Space';
    TKeyCode.Apostrophe: Result := 'Apostrophe';
    TKeyCode.Comma: Result := 'Comma';
    TKeyCode.Minus: Result := 'Minus';
    TKeyCode.Period: Result := 'Period';
    TKeyCode.Slash: Result := 'Slash';
    TKeyCode._0: Result := '0';
    TKeyCode._1: Result := '1';
    TKeyCode._2: Result := '2';
    TKeyCode._3: Result := '3';
    TKeyCode._4: Result := '4';
    TKeyCode._5: Result := '5';
    TKeyCode._6: Result := '6';
    TKeyCode._7: Result := '7';
    TKeyCode._8: Result := '8';
    TKeyCode._9: Result := '9';
    TKeyCode.Semicolon: Result := 'Semicolon';
    TKeyCode.Equal: Result := 'Equal';
    TKeyCode.A: Result := 'A';
    TKeyCode.B: Result := 'B';
    TKeyCode.C: Result := 'C';
    TKeyCode.D: Result := 'D';
    TKeyCode.E: Result := 'E';
    TKeyCode.F: Result := 'F';
    TKeyCode.G: Result := 'G';
    TKeyCode.H: Result := 'H';
    TKeyCode.I: Result := 'I';
    TKeyCode.J: Result := 'J';
    TKeyCode.K: Result := 'K';
    TKeyCode.L: Result := 'L';
    TKeyCode.M: Result := 'M';
    TKeyCode.N: Result := 'N';
    TKeyCode.O: Result := 'O';
    TKeyCode.P: Result := 'P';
    TKeyCode.Q: Result := 'Q';
    TKeyCode.R: Result := 'R';
    TKeyCode.S: Result := 'S';
    TKeyCode.T: Result := 'T';
    TKeyCode.U: Result := 'U';
    TKeyCode.V: Result := 'V';
    TKeyCode.W: Result := 'W';
    TKeyCode.X: Result := 'X';
    TKeyCode.Y: Result := 'Y';
    TKeyCode.Z: Result := 'Z';
    TKeyCode.LeftBracket: Result := 'LeftBracket';
    TKeyCode.BackSlash: Result := 'BackSlash';
    TKeyCode.RightBracket: Result := 'RightBracket';
    TKeyCode.GraveAccent: Result := 'GraveAccent';
    TKeyCode.World1: Result := 'World1';
    TKeyCode.World2: Result := 'World2';
    TKeyCode.Escape: Result := 'Escape';
    TKeyCode.Enter: Result := 'Enter';
    TKeyCode.Tab: Result := 'Tab';
    TKeyCode.Backspace: Result := 'Backspace';
    TKeyCode.Insert: Result := 'Insert';
    TKeyCode.Delete: Result := 'Delete';
    TKeyCode.Right: Result := 'Right';
    TKeyCode.Left: Result := 'Left';
    TKeyCode.Down: Result := 'Down';
    TKeyCode.Up: Result := 'Up';
    TKeyCode.PageUp: Result := 'PageUp';
    TKeyCode.PageDown: Result := 'PageDown';
    TKeyCode.Home: Result := 'Home';
    &TKeyCode.End: Result := 'End';
    TKeyCode.CapsLock: Result := 'CapsLock';
    TKeyCode.ScrollLock: Result := 'ScrollLock';
    TKeyCode.NumLock: Result := 'NumLock';
    TKeyCode.PrintScreen: Result := 'PrintScreen';
    TKeyCode.Pause: Result := 'Pause';
    TKeyCode.F1: Result := 'F1';
    TKeyCode.F2: Result := 'F2';
    TKeyCode.F3: Result := 'F3';
    TKeyCode.F4: Result := 'F4';
    TKeyCode.F5: Result := 'F5';
    TKeyCode.F6: Result := 'F6';
    TKeyCode.F7: Result := 'F7';
    TKeyCode.F8: Result := 'F8';
    TKeyCode.F9: Result := 'F9';
    TKeyCode.F10: Result := 'F10';
    TKeyCode.F11: Result := 'F11';
    TKeyCode.F12: Result := 'F12';
    TKeyCode.F13: Result := 'F13';
    TKeyCode.F14: Result := 'F14';
    TKeyCode.F15: Result := 'F15';
    TKeyCode.F16: Result := 'F16';
    TKeyCode.F17: Result := 'F17';
    TKeyCode.F18: Result := 'F18';
    TKeyCode.F19: Result := 'F19';
    TKeyCode.F20: Result := 'F20';
    TKeyCode.F21: Result := 'F21';
    TKeyCode.F22: Result := 'F22';
    TKeyCode.F23: Result := 'F23';
    TKeyCode.F24: Result := 'F24';
    TKeyCode.F25: Result := 'F25';
    TKeyCode.KP0: Result := 'KP0';
    TKeyCode.KP1: Result := 'KP1';
    TKeyCode.KP2: Result := 'KP2';
    TKeyCode.KP3: Result := 'KP3';
    TKeyCode.KP4: Result := 'KP4';
    TKeyCode.KP5: Result := 'KP5';
    TKeyCode.KP6: Result := 'KP6';
    TKeyCode.KP7: Result := 'KP7';
    TKeyCode.KP8: Result := 'KP8';
    TKeyCode.KP9: Result := 'KP9';
    TKeyCode.KPDecimal: Result := 'KPDecimal';
    TKeyCode.KPDivide: Result := 'KPDivide';
    TKeyCode.KPMultiply: Result := 'KPMultiply';
    TKeyCode.KPSubtract: Result := 'KPSubtract';
    TKeyCode.KPAdd: Result := 'KPAdd';
    TKeyCode.KPEnter: Result := 'KPEnter';
    TKeyCode.KPEqual: Result := 'KPEqual';
    TKeyCode.LeftShift: Result := 'LeftShift';
    TKeyCode.LeftControl: Result := 'LeftControl';
    TKeyCode.LeftAlt: Result := 'LeftAlt';
    TKeyCode.LeftSuper: Result := 'LeftSuper';
    TKeyCode.RightShift: Result := 'RightShift';
    TKeyCode.RightControl: Result := 'RightControl';
    TKeyCode.RightAlt: Result := 'RightAlt';
    TKeyCode.RightSuper: Result := 'RightSuper';
    TKeyCode.Menu: Result := 'Menu';
  else
    Result := '???';
  end;
end;

function MouseButtonToString(const AMouseButton: TMouseButton): String;
begin
  case AMouseButton of
    TMouseButton.Left: Result := 'Left';
    TMouseButton.Right: Result := 'Right';
    TMouseButton.Middle: Result := 'Middle';
    TMouseButton.Invalid: Result := 'Invalid';
  else
    Result := '???';
  end;
end;

{ TEventsApp }

procedure TEventsApp.Cleanup;
begin
  inherited;
  RemoveEventHandler(EventHandler);
end;

procedure TEventsApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 832;
  AConfig.Height := 600;
  AConfig.AndroidForceGles2 := True;
  AConfig.WindowTitle := 'Events';
  AConfig.EnableClipboard := True;
  AConfig.EnableDragDrop := True;
  AConfig.MaxDroppedFiles := MAX_DROPPED_FILES;
end;

procedure TEventsApp.DrawEventInfoPanel(const AKind: TEventKind; const AWidth,
  AHeight: Single);
begin
  var Event: PEvent := @FEvents[AKind];
  var FrameAge: Single := FrameCount - Event.FrameCount;
  var FlashIntensity: Single := EnsureRange((20 - FrameAge) / 20, 0.25, 1);

  var V: _ImVec4;
  V.x := 1;
  V.y := 0;
  V.z := 0;
  V.w := 1;
  ImGui.PushStyleColor(TImGuiCol.Border, TColor.Create(FlashIntensity, 0.25, 0.25, 1));
  ImGui.PushID(Ord(AKind));

  ImGui.BeginChild('event_panel', Vector2(AWidth, AHeight), True);
  ImGui.Text(ImGui.Format('kind:         %s', [EventKindToString(AKind)]));
  ImGui.Text(ImGui.Format('frame:        %d', [Event.FrameCount]));
  ImGui.Text('modifiers:   ');
  if (Event.Modifiers = []) then
  begin
    ImGui.SameLine;
    ImGui.Text('None');
  end
  else
  begin
    if (TModifier.Shift in Event.Modifiers) then
    begin
      ImGui.SameLine;
      ImGui.Text('Shift');
    end;

    if (TModifier.Ctrl in Event.Modifiers) then
    begin
      ImGui.SameLine;
      ImGui.Text('Ctrl');
    end;

    if (TModifier.Alt in Event.Modifiers) then
    begin
      ImGui.SameLine;
      ImGui.Text('Alt');
    end;

    if (TModifier.Super in Event.Modifiers) then
    begin
      ImGui.SameLine;
      ImGui.Text('Super');
    end;

    if (TModifier.LeftMouseButton in Event.Modifiers) then
    begin
      ImGui.SameLine;
      ImGui.Text('LMB');
    end;

    if (TModifier.RightMouseButton in Event.Modifiers) then
    begin
      ImGui.SameLine;
      ImGui.Text('RMB');
    end;

    if (TModifier.MiddleMouseButton in Event.Modifiers) then
    begin
      ImGui.SameLine;
      ImGui.Text('MMB');
    end;
  end;

  if (AKind in [TEventKind.KeyDown, TEventKind.KeyUp, TEventKind.Char]) then
  begin
    ImGui.Text(ImGui.Format('key code:     %s', [KeyCodeToString(Event.KeyCode)]));
    ImGui.Text(ImGui.Format('char code:    $%.5x', [Event.CharCode]));
    ImGui.Text(ImGui.Format('key repeat:   %s', [BoolToStr(Event.KeyRepeat, True)]));
  end
  else if (AKind in [TEventKind.MouseDown, TEventKind.MouseUp,
    TEventKind.MouseScroll, TEventKind.MouseMove, TEventKind.MouseEnter,
    TEventKind.MouseLeave, TEventKind.FilesDropped]) then
  begin
    ImGui.Text(ImGui.Format('mouse button: %s', [MouseButtonToString(Event.MouseButton)]));
    ImGui.Text(ImGui.Format('mouse pos:    %4.2f, %4.2f', [Event.MouseX, Event.MouseY]));
    ImGui.Text(ImGui.Format('mouse delta:  %4.2f, %4.2f', [Event.MouseDX, Event.MouseDY]));
    ImGui.Text(ImGui.Format('scrolling:    %4.2f, %4.2f', [Event.ScrollX, Event.ScrollY]));
  end
  else if (AKind in [TEventKind.TouchesBegan, TEventKind.TouchesMoved,
    TEventKind.TouchesEnded, TEventKind.TouchesCancelled]) then
  begin
    ImGui.Text(ImGui.Format('touch count:  %d', [Event.TouchCount]));
    for var I := 0 to Event.TouchCount - 1 do
    begin
      var Touch := Event.Touches[I];
      ImGui.Text(ImGui.Format(' %d id:      $%x', [I, Touch.Identifier]));
      ImGui.Text(ImGui.Format(' %d pos:     %4.2f, %4.2f', [I, Touch.X, Touch.Y]));
      ImGui.Text(ImGui.Format(' %d changed: %s', [I, BoolToStr(Touch.Changed, True)]));
    end;
  end
  else if (AKind = TEventKind.ClipboardPasted) then
    ImGui.Text(ImGui.Format('clipboard:    %s', [ClipboardString]));

  ImGui.Text(ImGui.Format('window size:  %d %d', [Event.WindowWidth, Event.WindowHeight]));
  ImGui.Text(ImGui.Format('fb size:      %d %d', [Event.FramebufferWidth, Event.FramebufferHeight]));

  ImGui.EndChild;
  ImGui.PopID;
  ImGui.PopStyleColor;
end;

procedure TEventsApp.DrawImGui;
const
  PanelHeight = 170;
  Pad         = 5;
begin
  inherited;
  var Style := ImGui.GetStyle;
  var PanelWidth: Single := 240 - Style.FramePadding.X;
  var PanelWidthWithPadding: Single := PanelWidth + Style.FramePadding.X;
  var PosX: Single := Style.WindowPadding.X;
  var PaddedSize := ImGui.GetIO.DisplaySize;
  PaddedSize := PaddedSize - (2 * Pad);
  var WindowPos := Vector2(Pad, Pad);

  {$IFDEF USE_DBG_UI}
  WindowPos.Y := WindowPos.Y + 19;
  PaddedSize.Y := PaddedSize.Y - 19;
  {$ENDIF}

  ImGui.SetNextWindowPos(WindowPos, TImGuiCond.Always);
  ImGui.SetNextWindowSize(PaddedSize, TImGuiCond.Always);

  if (ImGui.Begin('Event Inspector', nil, [TImGuiWindowFlag.NoResize, TImGuiWindowFlag.NoCollapse])) then
  begin
    if (MouseCursorVisible) then
      ImGui.Text('Press SPACE key to show/hide the mouse cursor (current status: SHOWN)!')
    else
      ImGui.Text('Press SPACE key to show/hide the mouse cursor (current status: HIDDEN)!');

    if (MouseLocked) then
      ImGui.Text('Press M key to lock/unlock the mouse cursor (current status: LOCKED)!')
    else
      ImGui.Text('Press M key to lock/unlock the mouse cursor (current status: UNLOCKED)!');

    ImGui.Text(ImGui.Format('dropped filed (%d/%d)', [Length(FDroppedFiles), MAX_DROPPED_FILES]));
    for var I := 0 to Length(FDroppedFiles) - 1 do
      ImGui.Text(ImGui.Format('    %d: %s', [I, FDroppedFiles[I]]));

    for var Kind := Low(TEventKind) to High(TEventKind) do
    begin
      DrawEventInfoPanel(Kind, PanelWidth, PanelHeight);
      PosX := PosX + PanelWidthWithPadding;
      if ((PosX + PanelWidthWithPadding) < ImGui.GetContentRegionAvail.X) then
        ImGui.SameLine
      else
        PosX := Style.WindowPadding.X;
    end;
  end;
  ImGui.End;
end;

function TEventsApp.EventHandler(const AEvent: TEvent): Boolean;
begin
  FEvents[AEvent.Kind] := AEvent;

  { Handle show/hide mouse cursor and mouse locking }
  case AEvent.Kind of
    TEventKind.KeyDown:
      if (not AEvent.KeyRepeat) then
      begin
        case AEvent.KeyCode of
          TKeyCode.Space:
            MouseCursorVisible := False;

          TKeyCode.M:
            MouseLocked := True;
        end;
      end;

    TEventKind.KeyUp:
      case AEvent.KeyCode of
        TKeyCode.Space:
          MouseCursorVisible := True;

        TKeyCode.M:
          MouseLocked := False;
      end;
  end;
  Result := False; { Pass on event }
end;

procedure TEventsApp.FilesDropped(const AX, AY: Single;
  const AFilePaths: TArray<String>);
begin
  inherited;
  FDroppedFiles := AFilePaths;
end;

procedure TEventsApp.Frame;
begin
  WindowTitle := Format('Events (FrameCount=%d, Duration=%.3fms)',
    [FrameCount, FrameDuration * 1000]);

  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

class function TEventsApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TEventsApp.Init;
begin
  inherited;
  FPassAction.Colors[0].Init(TAction.Clear, 0, 0.5, 0.7);

  { We want our event handler to be called first, so we can log events }
  var CurrentEventHandlers := GetEventHandlers;
  for var Handler in CurrentEventHandlers do
    RemoveEventHandler(Handler);

  AddEventHandler(EventHandler);

  for var Handler in CurrentEventHandlers do
    AddEventHandler(Handler);
end;

end.

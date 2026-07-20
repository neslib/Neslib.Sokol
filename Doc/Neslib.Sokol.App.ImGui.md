# Neslib.Sokol.App.ImGui

Debug-inspection UI for [Neslib.Sokol.App](Neslib.Sokol.App.md) using Dear ImGui.

This is a light-weight OOP layer on top of [sokol_app_imgui.h](https://github.com/floooh/sokol).

## Step by Step
* Call `TAppImGui.Setup` before any other `TAppImGui` methods:

  ```pascal
  TAppImGui.Setup;
  ```

* Add an event handler using `TApplication.AddEventHandler` and in the event handler callback, pass the event to `TAppImGui.TrackEvent`:

  ```pascal
  TApplication.AddEventHandler(MyEventHandler);
  
  function TMyApp.MyEventHandler(const AEvent: TEvent): Boolean;
  begin
    TAppImGui.TrackEvent(AEvent);
    Result := False;
  end;
  ```

* Somewhere at the start of your Neslib.Sokol.App frame callback, this records the frame duration for the debug hud:

  ```pascal
  TAppImGui.TrackFrame;
  ```

* Inside Dear ImGui's `BeginMainMenuBar`/`EndMainMenuBar`:

  ```pascal
  TAppImGui.DrawMenu('Neslib.Sokol.App');
  ```

* And somewhere in your Dear ImGui top-level rendering code:

  ```pascal
  TAppImGui.Draw;
  ```
  
  

## Alternative Drawing Functions

Instead of the convenient but all-in-one `TAppImGui.Draw` method, you can also use the following granular functions which might allow
better integration with your existing UI:

The following functions only render the window *content* (so you can integrate the UI into you own windows):

* `TAppImGui.DrawHudWindowContent`
* `TAppImGui.DrawPublicStateWindowContent`
* `TAppImGui.DrawEventWindowContent`

And these are the 'full window' drawing functions:

* `TAppImGui.DrawHudWindow(const ATitle: PUTF8Char)`
* `TAppImGui.DrawPublicStateWindow(const ATitle: PUTF8Char)`
* `TAppImGui.DrawEventWindow(const ATitle: PUTF8Char)`

To draw individual menu items:

* `TAppImGui.DrawHudMenuItem(const ALabel: PUTF8Char)`
* `TAppImGui.DrawPublicStateMenuItem(const ALabel: PUTF8Char)`
* `TAppImGui.DrawEventMenuItem(const ALabel: PUTF8Char)`
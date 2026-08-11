# Delphi Bindings Generator for ImGui

Using [Dear Bindings](https://github.com/dearimgui/dear_bindings) for [ImGui 1.92.8, *docking* branch](https://github.com/dearimgui/dear_bindings/releases/tag/DearBindings_v0.21_ImGui_v1.92.8-docking).

Creates bindings only for the main imgui.h header file (from dcimgui.json), *not* for extensions or internal headers (like imgui_internal.h).

To determine the version of ImGui used by Sokol, build the Sokol Samples as described [here](../../C/Readme.md). Then look at the imgui.h file in the ".fibs\\imports\\dcimgui\\src" directory for the version number.
@echo off

REM Run this from the "VS x64 Native Tools Command Prompt"

REM /GL    enables while program optimization
REM /LD    creates a DLL
REM /MT    creates multithreaded output that doesn't require MSVCRT
REM /Ox    full optimization
REM /sdl-  disable additional security checks
REM /wd    ignore specific warnings
REM /W4    displays level 1 (severe), 2 (significant), 3 (production quality) and 4 (informational) warnings
REM /WX    treat all warnings as errors
set ARGS=/sdl- /Ox /D_CRT_SECURE_NO_WARNINGS /wd4100 /wd4244 /wd4706 /W4 /WX /MT /GL /LD /Isokol /Fe"sokol.dll" /DEF sokol.def sokol.c sokol/deps/cimgui.cpp sokol/deps/imgui/imgui.cpp sokol/deps/imgui/imgui_widgets.cpp sokol/deps/imgui/imgui_draw.cpp sokol/deps/imgui/imgui_tables.cpp sokol/deps/imgui/imgui_demo.cpp sokol/libs/basisu/sokol_basisu.cpp

cl /DNDEBUG  %ARGS%
copy /Y sokol.dll "../Samples/Bin/sokol64.dll"
del *.obj
del sokol.exp
del sokol.lib
del sokol.dll

cl %ARGS%
copy /Y sokol.dll "../Samples/Bin/sokold64.dll"
del *.obj
del sokol.exp
del sokol.lib
del sokol.dll
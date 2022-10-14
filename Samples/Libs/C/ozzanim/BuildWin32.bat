@echo off

REM Run this from the "VS x86 Native Tools Command Prompt"

cl /sdl- /Ox /DNDEBUG /D_CRT_SECURE_NO_WARNINGS /W4 /WX /MT /GL /LD /EHsc /arch:SSE2 /Iinclude /Fe"ozzanim.dll" ozzanim.cpp src/ozz_animation.cc src/ozz_base.cc src/mesh.cc

copy /Y ozzanim.dll "../../../Bin/ozzanim32.dll"
del *.obj
del ozzanim.exp
del ozzanim.lib
del ozzanim.dll
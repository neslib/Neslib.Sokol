@echo off

REM Run this from the "VS x64 Native Tools Command Prompt"

cl /sdl- /Ox /DNDEBUG /D_CRT_SECURE_NO_WARNINGS /wd4100 /wd4201 /wd4244 /wd4706 /wd4267 /W4 /WX /MT /GL /LD /EHsc /Iinclude /Fe"ozzanim.dll" ozzanim.cpp src/ozz_animation.cc src/ozz_base.cc src/mesh.cc

copy /Y ozzanim.dll "../../../Bin/ozzanim64.dll"
del *.obj
del ozzanim.exp
del ozzanim.lib
del ozzanim.dll
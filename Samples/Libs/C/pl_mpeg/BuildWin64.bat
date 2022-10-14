@echo off

REM Run this from the "VS x64 Native Tools Command Prompt"

cl /sdl- /Ox /DNDEBUG /D_CRT_SECURE_NO_WARNINGS /wd4100 /wd4201 /wd4244 /wd4706 /W4 /WX /MT /GL /LD /Fe"pl_mpeg.dll" /DEF pl_mpeg.def pl_mpeg.c
copy /Y pl_mpeg.dll "../../../Bin/pl_mpeg64.dll"
del *.obj
del pl_mpeg.exp
del pl_mpeg.lib
del pl_mpeg.dll
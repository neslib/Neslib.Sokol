@echo off

REM Run this from the "VS x64 Native Tools Command Prompt"

cl /sdl- /Ox /DNDEBUG /D_CRT_SECURE_NO_WARNINGS /wd4100 /wd4201 /wd4244 /wd4706 /W4 /WX /MT /GL /LD /Fe"stb.dll" /DEF stb.def stb.c
copy /Y stb.dll "../../../Bin/stb64.dll"
del *.obj
del stb.exp
del stb.lib
del stb.dll
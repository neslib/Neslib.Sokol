@echo off

REM Run this from the "VS x64 Native Tools Command Prompt"

cl /sdl- /Ox /DNDEBUG /D_CRT_SECURE_NO_WARNINGS /wd4100 /wd4201 /wd4244 /wd4706 /W4 /WX /MT /GL /LD /Fe"cgltf.dll" /DEF cgltf.def cgltf.c
copy /Y cgltf.dll "../../../Bin/cgltf64.dll"
del *.obj
del cgltf.exp
del cgltf.lib
del cgltf.dll
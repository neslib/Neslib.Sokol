@echo off

REM Run this from the "VS x86 Native Tools Command Prompt"

cl /sdl- /Ox /DNDEBUG /D_CRT_SECURE_NO_WARNINGS /DMODPLUG_BUILD /DDLL_EXPORT /DHAVE_STDINT_H /wd4100 /wd4201 /wd4244 /wd4706 /wd4018 /wd4702 /wd4701 /W4 /WX /MT /GL /LD /arch:SSE2 /I"src/libmodplug" /Fe"modplug.dll" "src/fastmix.cpp" "src/load_669.cpp" "src/load_abc.cpp" "src/load_amf.cpp" "src/load_ams.cpp" "src/load_dbm.cpp" "src/load_dmf.cpp" "src/load_dsm.cpp" "src/load_far.cpp" "src/load_it.cpp" "src/load_j2b.cpp" "src/load_mdl.cpp" "src/load_med.cpp" "src/load_mid.cpp" "src/load_mod.cpp" "src/load_mt2.cpp" "src/load_mtm.cpp" "src/load_okt.cpp" "src/load_pat.cpp" "src/load_psm.cpp" "src/load_ptm.cpp" "src/load_s3m.cpp" "src/load_stm.cpp" "src/load_ult.cpp" "src/load_umx.cpp" "src/load_wav.cpp" "src/load_xm.cpp" "src/mmcmp.cpp" "src/modplug.cpp" "src/sndfile.cpp" "src/sndmix.cpp" "src/snd_dsp.cpp" "src/snd_flt.cpp" "src/snd_fx.cpp" /link /DYNAMICBASE "user32.lib"

copy /Y modplug.dll "../../../Bin/modplug32.dll"
del *.obj
del modplug.exp
del modplug.lib
del modplug.dll
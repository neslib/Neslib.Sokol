@echo off

REM Name of generated static library
set LIB32=obj\local\armeabi-v7a\libpl_mpeg.a
set LIB64=obj\local\arm64-v8a\libpl_mpeg.a

REM Location of NDK tools
set NDK_BUILD=c:\Users\Public\Documents\Embarcadero\Studio\22.0\CatalogRepository\AndroidNDK-21-22.0.44500.8973\android-ndk-r21\ndk-build.cmd
set NDK_STRIP32=c:\Users\Public\Documents\Embarcadero\Studio\22.0\CatalogRepository\AndroidNDK-21-22.0.44500.8973\android-ndk-r21\toolchains\arm-linux-androideabi-4.9\prebuilt\windows-x86_64\bin\arm-linux-androideabi-strip.exe
set NDK_STRIP64=c:\Users\Public\Documents\Embarcadero\Studio\22.0\CatalogRepository\AndroidNDK-21-22.0.44500.8973\android-ndk-r21\toolchains\aarch64-linux-android-4.9\prebuilt\windows-x86_64\bin\aarch64-linux-android-strip.exe

if not exist %NDK_BUILD% (
  echo Cannot find ndk-build. Should be installed in: %NDK_BUILD%
  exit /b
)

if not exist %NDK_STRIP32% (
  echo Cannot find ndk-strip. Should be installed in: %NDK_STRIP32%
  exit /b
)

if not exist %NDK_STRIP64% (
  echo Cannot find ndk-strip. Should be installed in: %NDK_STRIP64%
  exit /b
)

REM Run ndk-build to build static library
call %NDK_BUILD%

if not exist %LIB32% (
  echo Cannot find static library %LIB32%
  exit /b
)

%NDK_STRIP32% -g -X %LIB32%

REM Copy static library to directory with Delphi source code
copy %LIB32% ..\..\libpl_mpeg_android32.a
if %ERRORLEVEL% NEQ 0 (
  echo Cannot copy static library. Make sure it is not write protected
)

%NDK_STRIP64% -g -X %LIB64%

if not exist %LIB64% (
  echo Cannot find static library %LIB64%
  exit /b
)

REM Copy static library to directory with Delphi source code
copy %LIB64% ..\..\libpl_mpeg_android64.a
if %ERRORLEVEL% NEQ 0 (
  echo Cannot copy static library. Make sure it is not write protected
)

REM Remove temprary files
rd obj /s /q
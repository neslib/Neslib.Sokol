@echo off

REM Name of generated static library
set LIB32=obj\local\armeabi-v7a\libsokol.a
set LIB64=obj\local\arm64-v8a\libsokol.a

REM Location of NDK tools
set NDK_BUILD=C:\Users\Public\Documents\Embarcadero\Studio\37.0\CatalogRepository\AndroidSDK-37.0.59082.6021\ndk\27.1.12297006\ndk-build.cmd
set NDK_STRIP=C:\Users\Public\Documents\Embarcadero\Studio\37.0\CatalogRepository\AndroidSDK-37.0.59082.6021\ndk\27.1.12297006\toolchains\llvm\prebuilt\windows-x86_64\bin\llvm-strip.exe

if not exist %NDK_BUILD% (
  echo Cannot find ndk-build. Should be installed in: %NDK_BUILD%
  exit /b
)

if not exist %NDK_STRIP% (
  echo Cannot find ndk-strip. Should be installed in: %NDK_STRIP%
  exit /b
)

REM Run ndk-build to build static library
call %NDK_BUILD%

if not exist %LIB32% (
  echo Cannot find static library %LIB32%
  exit /b
)

%NDK_STRIP% -g %LIB32%

REM Copy static library to directory with Delphi source code
copy %LIB32% ..\libsokol_android32.a
if %ERRORLEVEL% NEQ 0 (
  echo Cannot copy static library. Make sure it is not write protected
)

%NDK_STRIP% -g %LIB64%

if not exist %LIB64% (
  echo Cannot find static library %LIB64%
  exit /b
)

REM Copy static library to directory with Delphi source code
copy %LIB64% ..\libsokol_android64.a
if %ERRORLEVEL% NEQ 0 (
  echo Cannot copy static library. Make sure it is not write protected
)

REM Remove temprary files
rd obj /s /q
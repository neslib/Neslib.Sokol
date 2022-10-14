# Neslib.Sokol

Simple libraries for creating cross-platform applications with Delphi without the VLC or FMX frameworks.

These are language bindings and OOP-style wrappers of the excellent [sokol C libraries](https://github.com/floooh/sokol) by [Andre Weissflog](https://github.com/floooh).

It consists of the following independent modules (units):

## Core units

* [Neslib.Sokol.App](Doc/Neslib.Sokol.App.md): application framework that takes care of window creation, 3D-context creation, keyboard-, mouse- and touch-input and operating system events.
* [Neslib.Sokol.Gfx](Doc/Neslib.Sokol.Gfx.md): 3D-API abstraction layer that uses Direct3D 11 on Windows, OpenGL ES-2/3 on Android and Metal on macOS and iOS.
* [Neslib.Sokol.Audio](Doc/Neslib.Sokol.Audio.md): minimal buffer-streaming audio playback that uses WASAPI on Windows, OpenSLES on Android and CoreAudio on macOS and iOS.
* [Neslib.Sokol.Fetch](Doc/Neslib.Sokol.Fetch.md): asynchronous data streaming from the local filesystem.
* [Neslib.Sokol.Time](Doc/Neslib.Sokol.Time.md): high precision time measurement.

## Utility units

* [Neslib.ImGui](Doc/Neslib.ImGui.md): Delphi wrapper for the immediate-mode user interface library [Dear ImGui](https://github.com/ocornut/imgui).
* [Neslib.Sokol.ImGui](Doc/Neslib.Sokol.ImGui.md): drop-in Dear ImGui renderer and event handler for Neslib.Sokol.App and Neslib.Sokol.Gfx.
* [Neslib.Sokol.Gfx.ImGui](Doc/Neslib.Sokol.Gfx.ImGui.md): debug-inspection UI for Neslib.Sokol.Gfx using Dear ImGui.
* [Neslib.Sokol.GL](Doc/Neslib.Sokol.GL.md): OpenGL 1.x style rendering on top of Neslib.Sokol.Gfx.
* [Neslib.Sokol.Shape](Doc/Neslib.Sokol.Shape.md): create simple primitive shapes for Neslib.Sokol.Gfx.
* [Neslib.FontStash](Doc/Neslib.FontStash.md): Delphi wrapper for [FontStash](https://github.com/memononen/fontstash), a font texture atlas builder.
* [Neslib.Sokol.FontStash](Doc/Neslib.Sokol.FontStash.md): Neslib.Sokol.GL rendering backend for FontStash.
* [Neslib.Sokol.DebugText](Doc/Neslib.Sokol.DebugText.md): simple ASCII debug text rendering on top of Neslib.Sokol.Gfx.
* [Neslib.Sokol.MemTrack](Doc/Neslib.Sokol.MemTrack.md): memory allocation wrapper to track memory usage of Sokol libraries.

## Additional modules used in some samples

These units are not part of the core Sokol framework, but are used by some Sokol sample applications. They come with their own static and dynamic libraries. The source code of these units can be found inside the "Samples/Libs" subdirectory.

* [Neslib.Sokol.glTF](Doc/Neslib.Sokol.glTF.md): glTF 2.0 parser and light-weight OOP layer on top of [cgltf](https://github.com/jkuhlmann/cgltf).
* [Neslib.Sokol.BasisU](Doc/Neslib.Sokol.BasisU.md): minimal wrapper for [Basis Universal](https://github.com/BinomialLLC/basis_universal) texture support.
* Neslib.ModPlug: Delphi wrapper for [libmodplug](https://github.com/Konstanty/libmodplug) for decoding various types of mod- and mod-like music files.
* Neslib.PLMpeg: Delphi wrapper for [PL_MPEG](https://github.com/phoboslab/pl_mpeg), a simple MPEG-1 video decoder, MP2 audio decoder and MPEG-PS demuxer.
* Neslib.OzzAnim: Quick & Dirty partial C binding and Delphi wrapper for [ozz-animation](https://github.com/guillaumeblanc/ozz-animation).
* Neslib.Stb.Image: Delphi wrapper for [stb_image.h](https://github.com/nothings/stb), for decoding images in various formats.

## Dependencies

Neslib.Sokol only depends on the [FastMath](https://github.com/neslib/FastMath) library. Make sure the FastMath\FastMath subdirectory is in your Delphi library path or add it to the search path of your Sokol projects. It's recommended to put the FastMath directory at the same level as the Neslib.Sokol directory, so the Sokol example projects compile without modifications.

Note that Sokol used column-major order for matrix calculations. You **must** add the `FM_COLUMN_MAJOR` to your projects so that FastMath operates in column-major mode as well.

Note that the original C header files are translated to Delphi code using [Chet](https://github.com/neslib/Chet). But you don't need Chet to use this library.

## Deployment

On all platforms except Windows, the Sokol libraries are linked into the executable and no additional files need to be deployed.

On Windows, you need to deploy the sokol32.dll or sokol64.dll file, depending on whether your application is a 32-bit or 64-bit executable. You can find these DLLs in the Samples\Bin subdirectory. If you are running in debug mode, you need to deploy the file sokold32.dll or sokold64.dll instead. If you use some of these optional modules, than you need to deploy the corresponding DLLs as well:

* Neslib.Sokol.glTF: cgltf32.dll or cglft64.dll
* Neslib.ModPlug: modplug32.dll or modplug64.dll
* Neslib.PLMpeg: pl_mpeg32.dll or pl_mpeg64.dll
* Neslib.OzzAnim: ozzanim32.dll or ozzanim64.dll
* Neslib.Stb.Image: stb32.dll or stb64.dll

## Samples

Neslib.Sokol ships with a number of sample projects. With a couple of exceptions, they run on all supported platforms (Windows, macOS, iOS and Android).

You can find these sample projects in the Samples subdirectory. There is also a convenient SokolSamples.groupproj file that contains all simples in a simple group project.

## Debugging

A lot of the code is contained in the Sokol C libraries, which you cannot easily debug with Delphi. These C libraries do not use exceptions or error codes for most APIs. Instead, it uses assertions and logging. In release builds, these assertions are turned off to improve performance. If some Sokol APIs are not working as expected, then you can use the following steps to get more information about any issues that Sokol encountered (this only works on Windows):

* Build a Debug configuration of your project. 
* Make sure you deploy the sokold32.dll or sokold64.dll file (instead of sokol32.dll or sokol64.dll).
* In Delphi, open the Project Options and navigate to "Build | Delphi Compiler | Linking". 
* Tick the "Generate console application" checkbox.
* Run the application.

This will also open a console window. When the Sokol C library encounters any issues, these will be logged to the console window so you can take the appropriate steps to fix them. Also, when the C library raises an assertion, this will cause a break in the Delphi IDE and you can inspect the assertion message there.

## License

Both the original Sokol C libraries and the Neslib.Sokol Delphi language bindings and OOP-style wrappers are licensed under the ZLib license. See the LICENSE file for details.

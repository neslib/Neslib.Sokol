# Updating the Sokol libraries
The current version is based on these commits of the Sokol and Sokol-Samples repositories from October 12, 2022:

* https://github.com/floooh/sokol/tree/a2f1113e391228962f1f9c23ffa74f3d02349fa4
* https://github.com/floooh/sokol-samples/tree/44d24f27ff96119c0e1892f7a0228735d7af51c8

To update Neslib.Sokol:

1. Put the latest versions of the Sokol headers in the "sokol" directory, including the "util" subdirectory.
    **Note**: we don't use the "sokol_nuklear.h" file since it conflicts with "sokol_fontstash.h" and since we already include the ImGui library. 
    **Note**: check if the cimgui.h includes docking functionality (eg. search for DockContext). If not, download a version of [cimgui](https://github.com/cimgui/cimgui) that does (which I think the default branch currently does)
2. Update the "sokol\deps" directory with the dependencies that ship with Sokol.
3. If there are new or renamed APIs in sokol\deps\fontstash.h or sokol\libs\basisu\sokol_basisu.h, then update the "sokol.def" accordingly.
4. Open deps\fontstash.h. It contains a `fonsAddFontMem` API that only appears in the implementation part, but should be a public API. Copy the declaration to the beginning of the header file to make it available.
5. Clone the Sokol-Samples repository and build it using these commands:

    * `> fips set config sapp-d3d11-win64-vstudio-debug`

    * `> fips build`

6. Update the "sokol" directory with new source files from the Samples repository.
7. Update the subdirectories in the "chet" directory accordingly, but only with those header files we want to translate to be accessible from Delphi.
8. Rebuild the header translations by opening the "sokol.chet" file in [Chet](https://github.com/neslib/Chet) and running the translator.
9. Compare the old and new header files and update the Delphi OOP-wrappers accordingly.

## Building for Windows
This requires Visual Studio (the Community edition suffices).

* Open the "x86 Native Tools Command Prompt"
* `cd` to the directory with this Readme file
* Enter `> BuildWin32`
* Open the "x64 Native Tools Command Prompt"
* `cd` to the directory with this Readme file
* Enter `> BuildWin64`

## Building for Android
* Open a command prompt
* Enter `> BuildAndroid.bat`

## Building for macOS/iOS
* Open a terminal window on macOS
* Enter `> ./BuildMacOSIntel.sh`
* Enter `> ./BuildIOS.sh`

# About the original samples

The original C Sokol samples use the HandmadeMath library for matrix calculations. Neslib.Sokol uses [FastMath](https://github.com/neslib/FastMath) instead. The following table lists some conversions from HandmadeMath to FastMath:

| HandmadeMath                             | FastMath                                                     |
| ---------------------------------------- | ------------------------------------------------------------ |
| `HHM_Perspective(POV, W / H, Near, Far)` | `TMatrix4.InitPerspectiveFovRH(Radians(POV), H / W, Near, Far, True)` |
| `HMM_LookAt(...)`                        | `TMatrix4.InitLookAtRH(...)`                                 |
| `HMM_MultiplyMat4(A, B)`                 | `A * B`                                                      |
| `HMM_Rotate(Angle, HMM_Vec3(1, 0, 0))`   | `TMatrix4.InitRotationX(Radians(Angle))`                     |
| `HMM_Rotate(Angle, HMM_Vec3(0, 1, 0))`   | `TMatrix4.InitRotationY(Radians(Angle))`                     |
| `HMM_Rotate(Angle, HMM_Vec3(0, 0, 1))`   | `TMatrix4.InitRotationZ(Radians(Angle))`                     |


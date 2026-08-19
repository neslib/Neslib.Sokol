# Updating the Sokol libraries
The current version is based on these commits of the Sokol and Sokol-Samples repositories:

* https://github.com/floooh/sokol/tree/d299f70423dcf3c72355715131b22fb2b8232914
* https://github.com/floooh/sokol-samples/tree/a4e148e81675c8f6fe2ccdec29357cedfe78bc72

To update Neslib.Sokol:

1. Install Deno if not done so already, by starting Windows PowerShell and entering:
    `> irm https://deno.land/install.ps1 | iex`
2. Clone the Sokol-Samples repository and build it using these commands:

    * `> fibs config sapp-d3d11-win-vstudio-debug`

    * `> fibs build`
3. Put the latest versions of the Sokol headers in the "sokol" directory, including the "util" subdirectory.
    **Note**: we don't use the "sokol_nuklear.h" file since it conflicts with "sokol_fontstash.h" and since we already include the ImGui library. 
    **Note**: we don't use "sokol_fetch.h" since we use a pure Delphi implementation of this.
4. Update the "libs\\basisu" subdirectory with the contents from the "libs" directory of the samples repo.
5. Update the "deps" subdirectory with the contents from the "libs\\fontstash" and ".fibs\\imports\\dcimgui\\src" directories of the samples repo.
6. Update "deps\\stb_image.h" from ".fibs\\imports\\stb\\stb_image.h".
7. Update the "spine" subdirectory with the contents from the "libs\\spine-c\\include\\spine" directory of the samples repo.
8. Update the "spine\\src" subdirectory with the contents from the "libs\\spine-c\\src\\spine" directory of the samples repo.
9. Both FontStash and ImGui use "stb_truetype.h", however ImGui uses a slightly customized (and new) version named "imstb_truetype.h". To avoid duplication:

    * open "fontstash.h" 
    * replace "stb_truetype.h" with "imstb_truetype.h"
    * comment out the 6 lines above that (from `#define STB_TRUETYPE_IMPLEMENTATION` through `#define STBTT_free(x,u) fons__tmpfree(x,u)`)
    * you should delete any "stb_truetype.h" files
10. If there are new or renamed APIs in sokol\deps\fontstash.h or sokol\libs\basisu\sokol_basisu.h, then update the "sokol.def" accordingly.
11. Update the subdirectories in the "chet" directory accordingly, but only with those header files we want to translate to be accessible from Delphi.
12. Open the "chet\\sokol\\deps\\fontstash.h" file and copy the `fonsAddFontMem` signature in the "implementation" section to the "interface" section (under the `fonsDrawDebug` signature). Make sure the line ends with a semicolon.
13. Rebuild the header translations by opening the "sokol.chet" file in [Chet](https://github.com/neslib/Chet) and running the translator.
14. Compare the old and new header files and update the Delphi OOP-wrappers and documentation (in the Doc folder) accordingly.

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
* In the following files, comment out the line `#include <stddef.h>`
  * util/sokol_app_imgui.h
  * util/sokol_gfx_imgui.h
  * util/sokol_imgui.h
  * util/sokol_fontstash.h
  * util/sokol_shape.h
  * util/sokol_spine.h
  * deps/stb_image.h
  
* Open a terminal window on macOS
* Enter `> ./BuildMacOSIntel.sh`
* Enter `> ./BuildMacOSArm.sh`
* Enter `> ./BuildIOS.sh`

# About the original samples

The original C Sokol samples use the Vecmath library for matrix calculations. Neslib.Sokol uses [FastMath](https://github.com/neslib/FastMath) instead. The following table lists some conversions from Vecmath to FastMath:

| Vecmath                                           | FastMath                                                     |
| ------------------------------------------------- | ------------------------------------------------------------ |
| `mat44_perspective_fov_rh(POV, W / H, Near, Far)` | `TMatrix4.InitPerspectiveFovRH(POV, W / H, Near, Far)`       |
| `mat44_look_at_rh(...)`                           | `TMatrix4.InitLookAtRH(...)`                                 |
| `mat44_ortho_off_center_rh(L, R, B, T, ZN, ZF)`   | `TMatrix4.InitOrthoOffCenterRH(L, T, R, B, ZN, ZF)` (move 4th to 2nd) |
| `vm_mul(A, B)`                                    | `B * A` (reversed!)                                          |
| `mat44_rotation_*(Angle)`                         | `TMatrix4.InitRotation*(Angle)`                              |
| `vec4_transform(Vec, Mat)`                        | `Mat * Vec`                                                  |


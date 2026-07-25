# Sokol Shader Compiler - Delphi Version

Based on commit: https://github.com/floooh/sokol-tools/tree/55c313a2bb91756e9d2b5856db5d6dce72b0b8c3

Note: the Sokol developer is currently in the process of building a [DLL version](https://github.com/floooh/sokol-tools/issues/34) so we can consume it from a Delphi tool. Until then, we create a quick & dirty hacked version to add Delphi output support.

## Install and build

```sh
git clone --recursive https://github.com/floooh/sokol-tools.git
fibs config win-vstudio-release
```

This will create a Visual Studio solution in the ".fibs\build\win-vstudio-release" directory.

## Add Delphi output support

* Add the files "sokoldelphi.h" and "sokoldelphi.cc" to the "src\\shdc\\generators" directory.
* In the Visual Studio solution, under the "sokol-shdc-lib" project, add these 2 new files to the "generators" filter.

* Edit "src\\shdc\\types\\format.h":

  * Add a `SOKOL_DELPHI` option to the `Format` enum.

  * Update the `Format::to_str` and `Format::from_str` functions accordingly using the string `"sokol_delphi"`.

* Edit "src\\shdc\\args.h":

  * In the `Args` struct set the default value of the `output_format` field to `Format::SOKOL_DELPHI`.

* Edit "src\\shdc\\args.cc":

  * Locate the validate function and add the following code at the beginning of the function:

    ```c++
    if (args.output_format == Format::SOKOL_DELPHI)
    {
        if (args.slang == 0)
            args.slang = Slang::bit(Slang::GLSL410)
            | Slang::bit(Slang::GLSL300ES)
            | Slang::bit(Slang::HLSL5)
            | Slang::bit(Slang::METAL_MACOS)
            | Slang::bit(Slang::METAL_IOS)
            | Slang::bit(Slang::SPIRV_VK);
    
        args.ifdef = true;
    }
    ```

* Edit "src\\shdc\\generators\\generate.cc":

  * Add an `#include "sokoldelphi.h"` line.
  * Add the following `case` to the `switch` statement:

    ```c++
    case Format::SOKOL_DELPHI:
       return std::make_unique<SokolDelphiGenerator>();


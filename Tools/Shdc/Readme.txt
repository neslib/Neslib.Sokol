Quick & Dirty hacked of Sokol's shdc tool that outputs Delphi source code.

Based on this commit:

https://github.com/floooh/sokol-tools/tree/de40c8523f9277baf63984208c3a25bdff37b8a9

The "Original" subdirectory contains the original source code (of this commit).
The "Modified" subdirectory contains the modifications to produce Delphi output.

To build the tool, follow the instructions here: https://github.com/floooh/sokol-tools

In short:

> git clone --recursive --recursive git@github.com:floooh/sokol-tools.git
> cd sokol-tools
> fips set config win64-vstudio-release
> fips gen
> fips open

Modify the source code based in the files in the "Modified" subdirectory and build.

NOTE: We should add more "official" support for Delphi. 
The shdc tool currently contains exporters for other languages (Nim, Zig etc.).
We should add a Delphi exporter using the same methodology.
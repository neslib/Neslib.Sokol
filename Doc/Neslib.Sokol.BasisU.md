# Neslib.Sokol.BasisU

Minimal wrapper for [Basis Universal](https://github.com/BinomialLLC/basis_universal) texture support.

This is a light-weight OOP layer on top of [sokol_basisu.h](https://github.com/floooh/sokol).

## TBasisU

This static record contains the Basic Universal APIs:

### TBasisU.Setup

Must be called at application startup, before using any Basis Universal APIs.

### TBasisU.Shutdown

Must be called at application shutdown to release Basis Universal resources.

### TBasisU.CreateImage

All-in-one image creation function. Creates a [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md) `TImage` from data in Basis Universal format. The returned image can be treated like any other `TImage`, and must be Free'd when you are done with it.

### TBasisU.Transcode and TBasisU.FreeImageDesc

These methods can be used instead of `TBasisU.CreateImage` if you need finer control. `TBasisU.Transcode` takes a buffer in Basis Universal format and returns an `TImageDesc` record that can be used to create a `TImage` object. The returned record must then be released using `TBasisU.FreeImageDesc`.

### TBasisU.PixelFormat

Returns the (GPU compressed) pixel format into which Basis Universal textures will transcoded on the system the app is running on. It has a single `AAlpha` parameter to indicate the kind of pixel format you want.
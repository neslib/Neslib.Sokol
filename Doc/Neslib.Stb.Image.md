# Neslib.Stb.Image

Delphi wrapper for [stb_image.h](https://github.com/nothings/stb).

## TStbImage

The main class for loading images in a variety of formats from files, memory buffers or custom IO callbacks. The following formats are supported:

* JPEG baseline & progressive (12 bpc/arithmetic not supported, same as stock IJG lib)
* PNG 1/2/4/8/16-bit-per-channel
* TGA (not sure what subset, if a subset)
* BMP non-1bpp, non-RLE
* PSD (composited view only, no extra channels, 8/16 bit-per-channel)
* GIF (always decodes using 4 channels)
* HDR (radiance rgbE format)
* PIC (Softimage PIC)
* PNM (PPM and PGM binary only)

## Example

```pascal
var Image := TStbImage.Create;
try
  if (Image.Load('image.png', 4)) then
  begin
    var ImgDesc := TImageDesc.Create;
    ImgDesc.Width := Image.Width;
    ImgDesc.Height := Image.Height;
    ImgDesc.PixelFormat := TPixelFormat.Rgba8;
    ImgDesc.Data.MipLevels[0] := TRange.Create(Image.Data, Image.Width * Image.Height * 4);
    ImgDesc.TraceLabel := 'PngImage';
    var Image := TImage.Create(ImgDesc);
  end;
finally
  Image.Free;
end;
```

The `Data` property points to the loaded image data, or is nil if the image is corrupt, invalid or in an unsupported format. The pixel data consists of `Height` scanlines of `Width` pixels, with each pixel consisting of `NumChannels` (1-4) interleaved 8-bit components; the first pixel pointed to is top-left-most in the image. There is no padding between image scanlines or between pixels, regardless of format. `NumChannels` is `ADesiredChannels` if specified or `ChannelsInFile` otherwise. If `ADesiredChannels` is specified, `ChannelsInFile` has the number of components that *would* have been output otherwise. E.g. if you set `ADesiredChannels` to 4, you will always get RGBA output, but you can check `CannelsInFile` to see if it's trivially opaque because e.g. there were only 3 channels in the source image.

An output image with N components has the following components interleaved in this order in each pixel:

```
   NumChannels   Components
     1           grey
     2           grey, alpha
     3           red, green, blue
     4           red, green, blue, alpha
```

If image loading fails for any reason, the `Data` property will be `nil`, and `Width`, `Height`, `NumChannels` and `ChannelsInFile` will be 0. The `FailureReason` property can be queried for an extremely brief, end-user unfriendly explanation of why the load failed.

Paletted PNG, BMP, GIF, and PIC images are automatically depalettized.

To query the width, height and component count of an image without having to decode the full file, you can use one of the `GetInfo` methods:

```Delphi
var Width, Height: Integer;
var NumChannels: TStbChannelCount;
if (TStbImage.GetInfo('SomeFile.png', Width, Height, NumChannels)) then
  ...
```

## I/O Callbacks
I/O callbacks allow you to read from arbitrary sources, like packaged files or some other source. Data read from callbacks are processed through a small internal buffer (currently 128 bytes) to try to reduce overhead.

To use callbacks, you must implement the `IStbIO` interface and pass it to an image loading method.   

## HDR Image Support
`TStbImage` supports loading HDR images in general, and currently the Radiance .HDR file format specifically. You can still load any file through the existing interface; if you attempt to load an HDR file, it will be automatically remapped to LDR, assuming gamma 2.2 and an arbitrary scale factor defaulting to 1; both of these constants can be reconfigured through the methods `SetHdrToLdrGamma` (default 2.2) and `SetHdrToLdrScale` (default 1.0).

Additionally, there are `LoadFloat` methods for loading files as (linear) floats to preserve the full dynamic range. If you load LDR images through this interface, those images will be promoted  to floating point values, run through the inverse of constants corresponding to the above, which can be customized with `SetLdrToHdrScale` (default 1.0) and `SetLdrToHdrGamma` (default 2.2).

Finally, given a filename containing image data, you can query for the "most appropriate" interface to use (that is, whether the image is HDR or not) using the `IsHdr` method.
## iOS PNG support
We optionally support converting iPhone-formatted PNGs (which store premultiplied BGRA) back to RGB, even though they're internally encoded differently. To enable this conversion, call `TStbImage.SetConvertIOSPngToRgb(True)`.

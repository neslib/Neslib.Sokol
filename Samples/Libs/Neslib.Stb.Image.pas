unit Neslib.Stb.Image;
{ Delphi wrapper for stb_image.h (https://github.com/nothings/stb) }

interface

uses
  System.SysUtils,
  Neslib.Stb.Api;

type
  TStbChannelCount = 0..4;

type
  { Interface that you can implement to load image files from arbitrary sources
    that are not navtively supported by TStbImage. }
  IStbIO = interface
  ['{E6697D88-5A96-418E-8A21-CF16589E9F4C}']
    { Read ASize bytes into the provided buffer and return the number of bytes
      read. }
    function Read(var ABuffer; const ASize: Integer): Integer;

    { Skips ACount bytes. ACount can be negative to 'unget' the last -ACount
      bytes. }
    procedure Skip(const ACount: Integer);

    { Must return True if we are at the end of the file/data }
    function Eof: Boolean;
  end;

type
  { An image that can be loaded from different file formats:
    * JPEG baseline & progressive (12 bpc/arithmetic not supported, same as
      stock IJG lib)
    * PNG 1/2/4/8/16-bit-per-channel

    * TGA (not sure what subset, if a subset)
    * BMP non-1bpp, non-RLE
    * PSD (composited view only, no extra channels, 8/16 bit-per-channel)

    * GIF (ANumComponents always reports as 4-channel)
    * HDR (radiance rgbE format)
    * PIC (Softimage PIC)
    * PNM (PPM and PGM binary only)

    The Data property points to the loaded image data, or is nil if the image is
    corrupt, invalid or in an unsupported format. The pixel data consists of
    Height scanlines of Width pixels, with each pixel consisting of NumChannels
    (1-4) interleaved 8-bit components; the first pixel pointed to is
    top-left-most in the image. There is no padding between image scanlines or
    between pixels, regardless of format. NumChannels is ADesiredChannels if
    specified or ChannelsInFile otherwise. If ADesiredChannels is specified,
    ChannelsInFile has the number of components that *would* have been output
    otherwise. E.g. if you set ADesiredChannels to 4, you will always get RGBA
    output, but you can check CannelsInFile to see if it's trivially opaque
    because e.g. there were only 3 channels in the source image.

    An output image with N components has the following components interleaved
    in this order in each pixel:

       NumChannels   Components
         1           grey
         2           grey, alpha
         3           red, green, blue
         4           red, green, blue, alpha

    If image loading fails for any reason, the Data property will be nil, and
    Width, Height, NumChannels and ChannelsInFile will be 0. The FailureReason
    property can be queried for an extremely brief, end-user unfriendly
    explanation of why the load failed.

    Paletted PNG, BMP, GIF, and PIC images are automatically depalettized.

    I/O Callbacks
    -------------
    I/O callbacks allow you to read from arbitrary sources, like packaged
    files or some other source. Data read from callbacks are processed through a
    small internal buffer (currently 128 bytes) to try to reduce overhead.

    To use callbacks, you must implement the IStbIO interface and pass it to an
    image loading method.

    HDR Image Support
    -----------------
    TStbImage supports loading HDR images in general, and currently the Radiance
    .HDR file format specifically. You can still load any file through the
    existing interface; if you attempt to load an HDR file, it will be
    automatically remapped to LDR, assuming gamma 2.2 and an arbitrary scale
    factor defaulting to 1; both of these constants can be reconfigured through
    the methods SetHdrToLdrGamma (default 2.2) and SetHdrToLdrScale (default
    1.0).
    Additionally, there are LoadFloat methods for loading files as (linear)
    floats to preserve the full dynamic range.
    If you load LDR images through this interface, those images will be promoted
    to floating point values, run through the inverse of constants corresponding
    to the above, which can be customized with SetLdrToHdrScale (default 1.0)
    and SetLdrToHdrGamma (default 2.2).
    Finally, given a filename containing image data, you can query for the "most
    appropriate" interface to use (that is, whether the image is HDR or not)
    using the IsHdr method.
    iOS PNG support
    ---------------
    By default we convert iOS-formatted PNGs back to RGB, even though they are
    internally encoded differently. You can disable this conversion by calling
    SetConvertIOSPngToRgb(False), in which case you will always just get the
    native iOS "format" through (which is BGR stored in RGB).
    Call SetUnpremultiplyOnLoad(True) as well to force a divide per pixel to
    remove any premultiplied alpha *only* if the image file explicitly says
    there's premultiplied data (currently only happens in iOS images, and only
    if iOS ConvertToRgb processing is on). }
  TStbImage = class
  {$REGION 'Internal Declarations'}
  private class var
    FNativeCallbacks: _stbi_io_callbacks;
  private
    FData: Pointer;
    FWidth: Integer;
    FHeight: Integer;
    FNumChannels: TStbChannelCount;
    FChannelsInFile: TStbChannelCount;
    FCallbacks: IStbIO;
    FFailureReason: String;
  private
    procedure Clear;
    procedure UpdateFailureReason;
  private
    class function ReadCallback(User: Pointer; Data: PUTF8Char; Size: Integer): Integer; cdecl; static;
    class procedure SkipCallback(User: Pointer; N: Integer); cdecl; static;
    class function EofCallback(User: Pointer): Integer; cdecl; static;
  public
    class constructor Create;
  {$ENDREGION 'Internal Declarations'}
  public
    destructor Destroy; override;

    { 8-bits-per-channel interface.
      Loads and image and converts to 8 bits per channel if needed.
      Returns False on failure. }
    function Load(const AFilename: String;
      const ADesiredChannels: TStbChannelCount = 0): Boolean; overload;
    function Load(const ABuffer: TBytes;
      const ADesiredChannels: TStbChannelCount = 0): Boolean; overload; inline;
    function Load(const ABuffer: Pointer; const ABufferSize: Integer;
      const ADesiredChannels: TStbChannelCount = 0): Boolean; overload;
    function Load(const ACallbacks: IStbIO;
      const ADesiredChannels: TStbChannelCount = 0): Boolean; overload;

    { 16-bits-per-channel interface.
      Loads and image and converts to 16 bits per channel if needed.
      Returns False on failure. }
    function Load16(const AFilename: String;
      const ADesiredChannels: TStbChannelCount = 0): Boolean; overload;
    function Load16(const ABuffer: TBytes;
      const ADesiredChannels: TStbChannelCount = 0): Boolean; overload; inline;
    function Load16(const ABuffer: Pointer; const ABufferSize: Integer;
      const ADesiredChannels: TStbChannelCount = 0): Boolean; overload;
    function Load16(const ACallbacks: IStbIO;
      const ADesiredChannels: TStbChannelCount = 0): Boolean; overload;

    { Float-per-channel interface (to preserve HDR content).
      Loads and image and converts to pixels in single-precision floating-point
      format if needed.
      Returns False on failure. }
    function LoadFloat(const AFilename: String;
      const ADesiredChannels: TStbChannelCount = 0): Boolean; overload;
    function LoadFloat(const ABuffer: TBytes;
      const ADesiredChannels: TStbChannelCount = 0): Boolean; overload; inline;
    function LoadFloat(const ABuffer: Pointer; const ABufferSize: Integer;
      const ADesiredChannels: TStbChannelCount = 0): Boolean; overload;
    function LoadFloat(const ACallbacks: IStbIO;
      const ADesiredChannels: TStbChannelCount = 0): Boolean; overload;

    { Customize the scale factor for HDR-to-LDR and LDR-to-HDR conversion.
      These are global values that must be set *before* loading a file.
      These values default to 1.0 }
    class procedure SetHdrToLdrScale(const AScale: Single); static;
    class procedure SetLdrToHdrScale(const AScale: Single); static;

    { Customize the gamma factor for HDR-to-LDR and LDR-to-HDR conversion.
      These are global values that must be set *before* loading a file.
      These values default to 2.2 }
    class procedure SetHdrToLdrGamma(const AGamma: Single); static;
    class procedure SetLdrToHdrGamma(const AGamma: Single); static;

    { For image formats that explicitly notate that they have premultiplied
      alpha, we just return the colors as stored in the file. Set AUnpremultiply
      to True to force unpremultiplication. Results are undefined if the
      unpremultiply overflows.
      This is a global value that must be set *before* loading a file. }
    class procedure SetUnpremultiplyOnLoad(const AUnpremultiply: Boolean); static;

    { Indicate whether we should process iOS images back to canonical format,
      or just pass them through "as-is".
      This is a global value that must be set *before* loading a file. }
    class procedure SetConvertIOSPngToRgb(const AConvert: Boolean); static;

    { Flip the image vertically, so the first pixel in the output array is the
      bottom left.
      This is a global value that must be set *before* loading a file. }
    class procedure SetFlipVerticallyOnLoad(const AFlip: Boolean); static;

    { Checks whether an image file is in HDR format.
      You can use the result to select the appropriate Load* function. }
    class function IsHdr(const AFilename: String): Boolean; overload; static;
    class function IsHdr(const ABuffer: TBytes): Boolean; overload; inline; static;
    class function IsHdr(const ABuffer: Pointer;
      const ABufferSize: Integer): Boolean; overload; static;

    { Checks whether an image file is in 16-bit format.
      You can use the result to select the appropriate Load* function. }
    class function Is16Bit(const AFilename: String): Boolean; overload; static;
    class function Is16Bit(const ABuffer: TBytes): Boolean; overload; inline; static;
    class function Is16Bit(const ABuffer: Pointer;
      const ABufferSize: Integer): Boolean; overload; static;

    { Get image dimensions & components without fully decoding }
    class function GetInfo(const AFilename: String; out AWidth, AHeight: Integer;
      out ANumChannels: TStbChannelCount): Boolean; overload; static;
    class function GetInfo(const ABuffer: TBytes; out AWidth, AHeight: Integer;
      out ANumChannels: TStbChannelCount): Boolean; overload; static;
    class function GetInfo(const ABuffer: Pointer; const ABufferSize: Integer;
      out AWidth, AHeight: Integer; out ANumChannels: TStbChannelCount): Boolean; overload; static;

    { Pointer to loaded image data, or nil if the image is corrupt, invalid or
      in an unsupported format.

      The each pixels consists of NumChannels values, where each value is either
      an 8- or 16-bit unsigned integer or a single-precision floating-point
      value (depending on whether Load, Load16 or LoadFloat is used). }
    property Data: Pointer read FData;

    { Width of the image, or 0 in case of failure. }
    property Width: Integer read FWidth;

    { Height of the image, or 0 in case of failure. }
    property Height: Integer read FHeight;

    { Number of channels in the image Data (1-4), or 0 in case of failure. }
    property NumChannels: TStbChannelCount read FNumChannels;

    { Original number of channels in the file, or 0 in case of failure. }
    property ChannelsInFile: TStbChannelCount read FChannelsInFile;

    { A *very* brief reason for failure. Not thread-safe. }
    property FailureReason: String read FFailureReason;
  end;

implementation

{ TStbImage }

procedure TStbImage.Clear;
begin
  if (FData <> nil) then
    _stbi_image_free(FData);
  FData := nil;
  FWidth := 0;
  FHeight := 0;
  FNumChannels := 0;
  FChannelsInFile := 0;
  FCallbacks := nil;
  FFailureReason := '';
end;

class constructor TStbImage.Create;
begin
  FNativeCallbacks.read := ReadCallback;
  FNativeCallbacks.skip := SkipCallback;
  FNativeCallbacks.eof := EofCallback;
end;

destructor TStbImage.Destroy;
begin
  Clear;
  inherited;
end;

class function TStbImage.EofCallback(User: Pointer): Integer;
var
  Img: TStbImage absolute User;
begin
  Assert(Assigned(User) and Assigned(Img.FCallbacks));
  Result := Ord(Img.FCallbacks.Eof);
end;

class function TStbImage.GetInfo(const AFilename: String; out AWidth,
  AHeight: Integer; out ANumChannels: TStbChannelCount): Boolean;
begin
  Result := (_stbi_info(PUTF8Char(UTF8String(AFilename)), @AWidth, @AHeight,
    @ANumChannels) <> 0);
  if (not Result) then
  begin
    AWidth := 0;
    AHeight := 0;
    ANumChannels := 0;
  end;
end;

class function TStbImage.GetInfo(const ABuffer: TBytes; out AWidth,
  AHeight: Integer; out ANumChannels: TStbChannelCount): Boolean;
begin
  Result := GetInfo(Pointer(ABuffer), Length(ABuffer), AWidth, AHeight,
    ANumChannels);
end;

class function TStbImage.GetInfo(const ABuffer: Pointer;
  const ABufferSize: Integer; out AWidth, AHeight: Integer;
  out ANumChannels: TStbChannelCount): Boolean;
begin
  Result := (_stbi_info_from_memory(ABuffer, ABufferSize, @AWidth, @AHeight,
    @ANumChannels) <> 0);
  if (not Result) then
  begin
    AWidth := 0;
    AHeight := 0;
    ANumChannels := 0;
  end;
end;

class function TStbImage.Is16Bit(const AFilename: String): Boolean;
begin
  Result := (_stbi_is_16_bit(PUTF8Char(UTF8String(AFilename))) <> 0);
end;

class function TStbImage.Is16Bit(const ABuffer: TBytes): Boolean;
begin
  Result := Is16Bit(Pointer(ABuffer), Length(ABuffer));
end;

class function TStbImage.Is16Bit(const ABuffer: Pointer;
  const ABufferSize: Integer): Boolean;
begin
  Result := (_stbi_is_16_bit_from_memory(ABuffer, ABufferSize) <> 0);
end;

class function TStbImage.IsHdr(const AFilename: String): Boolean;
begin
  Result := (_stbi_is_hdr(PUTF8Char(UTF8String(AFilename))) <> 0);
end;

class function TStbImage.IsHdr(const ABuffer: TBytes): Boolean;
begin
  Result := IsHdr(Pointer(ABuffer), Length(ABuffer));
end;

class function TStbImage.IsHdr(const ABuffer: Pointer;
  const ABufferSize: Integer): Boolean;
begin
  Result := (_stbi_is_hdr_from_memory(ABuffer, ABufferSize) <> 0);
end;

function TStbImage.Load(const ACallbacks: IStbIO;
  const ADesiredChannels: TStbChannelCount): Boolean;
begin
  Clear;
  FCallbacks := ACallbacks; // Keep alive
  FData := _stbi_load_from_callbacks(@FNativeCallbacks, Self, @FWidth, @FHeight,
    @FChannelsInFile, ADesiredChannels);
  UpdateFailureReason;
  Result := (FData <> nil);
end;

function TStbImage.Load(const ABuffer: Pointer; const ABufferSize: Integer;
  const ADesiredChannels: TStbChannelCount): Boolean;
begin
  Clear;
  FData := _stbi_load_from_memory(ABuffer, ABufferSize, @FWidth, @FHeight,
    @FChannelsInFile, ADesiredChannels);
  UpdateFailureReason;
  Result := (FData <> nil);
end;

function TStbImage.Load(const ABuffer: TBytes;
  const ADesiredChannels: TStbChannelCount): Boolean;
begin
  Result := Load(Pointer(ABuffer), Length(ABuffer), ADesiredChannels);
end;

function TStbImage.Load(const AFilename: String;
  const ADesiredChannels: TStbChannelCount): Boolean;
begin
  Clear;
  FData := _stbi_load(PUTF8Char(UTF8String(AFilename)), @FWidth, @FHeight,
    @FChannelsInFile, ADesiredChannels);
  UpdateFailureReason;
  Result := (FData <> nil);
end;

function TStbImage.Load16(const AFilename: String;
  const ADesiredChannels: TStbChannelCount): Boolean;
begin
  Clear;
  FData := _stbi_load_16(PUTF8Char(UTF8String(AFilename)), @FWidth, @FHeight,
    @FChannelsInFile, ADesiredChannels);
  UpdateFailureReason;
  Result := (FData <> nil);
end;

function TStbImage.Load16(const ABuffer: TBytes;
  const ADesiredChannels: TStbChannelCount): Boolean;
begin
  Result := Load16(Pointer(ABuffer), Length(ABuffer), ADesiredChannels);
end;

function TStbImage.Load16(const ABuffer: Pointer; const ABufferSize: Integer;
  const ADesiredChannels: TStbChannelCount): Boolean;
begin
  Clear;
  FData := _stbi_load_16_from_memory(ABuffer, ABufferSize, @FWidth, @FHeight,
    @FChannelsInFile, ADesiredChannels);
  UpdateFailureReason;
  Result := (FData <> nil);
end;

function TStbImage.Load16(const ACallbacks: IStbIO;
  const ADesiredChannels: TStbChannelCount): Boolean;
begin
  Clear;
  FCallbacks := ACallbacks; // Keep alive
  FData := _stbi_load_16_from_callbacks(@FNativeCallbacks, Self, @FWidth,
    @FHeight, @FChannelsInFile, ADesiredChannels);
  UpdateFailureReason;
  Result := (FData <> nil);
end;

function TStbImage.LoadFloat(const AFilename: String;
  const ADesiredChannels: TStbChannelCount): Boolean;
begin
  Clear;
  FData := _stbi_loadf(PUTF8Char(UTF8String(AFilename)), @FWidth, @FHeight,
    @FChannelsInFile, ADesiredChannels);
  UpdateFailureReason;
  Result := (FData <> nil);
end;

function TStbImage.LoadFloat(const ABuffer: TBytes;
  const ADesiredChannels: TStbChannelCount): Boolean;
begin
  Result := LoadFloat(Pointer(ABuffer), Length(ABuffer), ADesiredChannels);
end;

function TStbImage.LoadFloat(const ABuffer: Pointer; const ABufferSize: Integer;
  const ADesiredChannels: TStbChannelCount): Boolean;
begin
  Clear;
  FData := _stbi_loadf_from_memory(ABuffer, ABufferSize, @FWidth, @FHeight,
    @FChannelsInFile, ADesiredChannels);
  UpdateFailureReason;
  Result := (FData <> nil);
end;

function TStbImage.LoadFloat(const ACallbacks: IStbIO;
  const ADesiredChannels: TStbChannelCount): Boolean;
begin
  Clear;
  FCallbacks := ACallbacks; // Keep alive
  FData := _stbi_loadf_from_callbacks(@FNativeCallbacks, Self, @FWidth,
    @FHeight, @FChannelsInFile, ADesiredChannels);
  UpdateFailureReason;
  Result := (FData <> nil);
end;

class function TStbImage.ReadCallback(User: Pointer; Data: PUTF8Char;
  Size: Integer): Integer;
var
  Img: TStbImage absolute User;
begin
  Assert(Assigned(User) and Assigned(Img.FCallbacks));
  Result := Img.FCallbacks.Read(Data^, Size);
end;

class procedure TStbImage.SetConvertIOSPngToRgb(const AConvert: Boolean);
begin
  _stbi_convert_iphone_png_to_rgb(Ord(AConvert));
end;

class procedure TStbImage.SetFlipVerticallyOnLoad(const AFlip: Boolean);
begin
  _stbi_set_flip_vertically_on_load(Ord(AFlip));
end;

class procedure TStbImage.SetHdrToLdrGamma(const AGamma: Single);
begin
  _stbi_hdr_to_ldr_gamma(AGamma);
end;

class procedure TStbImage.SetHdrToLdrScale(const AScale: Single);
begin
  _stbi_hdr_to_ldr_scale(AScale);
end;

class procedure TStbImage.SetLdrToHdrGamma(const AGamma: Single);
begin
  _stbi_ldr_to_hdr_gamma(AGamma);
end;

class procedure TStbImage.SetLdrToHdrScale(const AScale: Single);
begin
  _stbi_ldr_to_hdr_scale(AScale);
end;

class procedure TStbImage.SetUnpremultiplyOnLoad(const AUnpremultiply: Boolean);
begin
  _stbi_set_unpremultiply_on_load(Ord(AUnpremultiply));
end;

class procedure TStbImage.SkipCallback(User: Pointer; N: Integer);
var
  Img: TStbImage absolute User;
begin
  Assert(Assigned(User) and Assigned(Img.FCallbacks));
  Img.FCallbacks.Skip(N);
end;

procedure TStbImage.UpdateFailureReason;
begin
  if (FData = nil) then
    FFailureReason := String(UTF8String(_stbi_failure_reason));
end;

end.

unit Neslib.Qoi;
{ Platform- and framework-indepentend implementation of the Quite OK Image
  format (https://qoiformat.org/).

  Based on commit: https://github.com/phoboslab/qoi/tree/f6dffaf1e8170cdd79945a4fb60f6403e447e020

  About
  -----

  QOI encodes and decodes images in a lossless format. Compared to stb_image and
  stb_image_write QOI offers 20x-50x faster encoding, 3x-4x faster decoding and
  20% better compression.

  Synopsis
  --------

  // Encode and store an RGBA buffer to the file system. The TQoiDesc describes
  // the input pixel data.
  var Desc := TQoiDesc.Create(1920, 1080, TQoiChannels.RGBA);
  QoiWrite('image_new.qoi', RgbaPixels, Desc);

  // Load and decode a QOI image from the file system into a 32bbp RGBA buffer.
  // The TQoiDesc record will be filled with the width, height, number of
  // channels and colorspace read from the file header.
  var Desc: TQoiDesc;
  var Pixels := QoiRead('image.qoi', Desc);
  try
    ...use image data in Pixels
  finally
    FreeMem(Pixels);
  end;

  Documentation
  -------------

  This library provides the following functions;
   - QoiRead    -- read and decode a QOI file
   - QoiDecode  -- decode the raw bytes of a QOI image from memory
   - QoiWrite   -- encode and write a QOI file
   - QoiEncode  -- encode an rgba buffer into a QOI image in memory

  See the function declaration below for the signature and more information.

  Data Format
  -----------

  A QOI file has a 14 byte header, followed by any number of data "chunks" and
  an 8-byte end marker:
   - Magic: array [0..3] of AnsiChar; // magic bytes 'qoif'
   - Width: Integer;                  // image width in pixels (BE)
   - Height: Integer;                 // image height in pixels (BE)
   - Channels: Byte;                  // 3 = RGB, 4 = RGBA
   - Colorspace: Byte;                // 0 = sRGB with linear alpha, 1 = all channels linear

  Images are encoded row by row, left to right, top to bottom. The decoder and
  encoder start with R=G=B=0 and A=255 as the previous pixel value. An image is
  complete when all pixels specified by Width * Height have been covered.

  Pixels are encoded as
   - a run of the previous pixel
   - an index into an array of previously seen pixels
   - a difference to the previous pixel value in R,G,B
   - full R,G,B or R,G,B,A values

  The color channels are assumed to not be premultiplied with the alpha channel
  ("un-premultiplied alpha").

  A running array[64] (zero-initialized) of previously seen pixel values is
  maintained by the encoder and decoder. Each pixel that is seen by the encoder
  and decoder is put into this array at the position formed by a hash function of
  the color value. In the encoder, if the pixel value at the index matches the
  current pixel, this index position is written to the stream as QOI_OP_INDEX.
  The hash function for the index is:

    IndexPosition := (R * 3 + G * 5 + B * 7 + A * 11) mod 64

  Each chunk starts with a 2- or 8-bit tag, followed by a number of data bits.
  The bit length of chunks is divisible by 8 - i.e. all chunks are byte aligned.
  All values encoded in these data bits have the most significant bit on the
  left.

  The 8-bit tags have precedence over the 2-bit tags. A decoder must check for
  the presence of an 8-bit tag first.

  The byte stream's end is marked with 7 $00 bytes followed a single $01 byte.

  The possible chunks are:


  .- QOI_OP_INDEX ----------.
  |         Byte[0]         |
  |  7  6  5  4  3  2  1  0 |
  |-------+-----------------|
  |  0  0 |     Index       |
  `-------------------------`
  2-bit tag b00
  6-bit Index into the color index array: 0..63

  A valid encoder must not issue 2 or more consecutive QOI_OP_INDEX chunks to
  the same index. QOI_OP_RUN should be used instead.


  .- QOI_OP_DIFF -----------.
  |         Byte[0]         |
  |  7  6  5  4  3  2  1  0 |
  |-------+-----+-----+-----|
  |  0  1 |  DR |  DG |  DB |
  `-------------------------`
  2-bit tag b01
  2-bit   red channel difference from the previous pixel between -2..1
  2-bit green channel difference from the previous pixel between -2..1
  2-bit  blue channel difference from the previous pixel between -2..1

  The difference to the current channel values are using a wraparound operation,
  so "1 - 2" will result in 255, while "255 + 1" will result in 0.

  Values are stored as unsigned integers with a bias of 2. E.g. -2 is stored as
  0 (b00). 1 is stored as 3 (b11).

  The alpha value remains unchanged from the previous pixel.


  .- QOI_OP_LUMA -------------------------------------.
  |         Byte[0]         |         Byte[1]         |
  |  7  6  5  4  3  2  1  0 |  7  6  5  4  3  2  1  0 |
  |-------+-----------------+-------------+-----------|
  |  1  0 |  Green Diff     |   DR - DG   |  DB - DG  |
  `---------------------------------------------------`
  2-bit tag b10
  6-bit green channel difference from the previous pixel -32..31
  4-bit   red channel difference minus green channel difference -8..7
  4-bit  blue channel difference minus green channel difference -8..7

  The green channel is used to indicate the general direction of change and is
  encoded in 6 bits. The red and blue channels (DR and DB) base their diffs off
  of the green channel difference and are encoded in 4 bits. I.e.:
    DR_DG = (CurPx.R - PrevPx.R) - (CurPx.G - PrevPx.G)
    DB_DG = (CurPx.B - PrevPx.B) - (CurPx.G - PrevPx.G)

  The difference to the current channel values are using a wraparound operation,
  so "10 - 13" will result in 253, while "250 + 7" will result in 1.

  Values are stored as unsigned integers with a bias of 32 for the green channel
  and a bias of 8 for the red and blue channel.

  The alpha value remains unchanged from the previous pixel.


  .- QOI_OP_RUN ------------.
  |         Byte[0]         |
  |  7  6  5  4  3  2  1  0 |
  |-------+-----------------|
  |  1  1 |       Run       |
  `-------------------------`
  2-bit tag b11
  6-bit run-length repeating the previous pixel: 1..62

  The run-length is stored with a bias of -1. Note that the run-lengths 63 and
  64 (b111110 and b111111) are illegal as they are occupied by the QOI_OP_RGB
  and QOI_OP_RGBA tags.


  .- QOI_OP_RGB ------------------------------------------.
  |         Byte[0]         | Byte[1] | Byte[2] | Byte[3] |
  |  7  6  5  4  3  2  1  0 | 7 .. 0  | 7 .. 0  | 7 .. 0  |
  |-------------------------+---------+---------+---------|
  |  1  1  1  1  1  1  1  0 |   Red   |  Green  |  Blue   |
  `-------------------------------------------------------`
  8-bit tag b11111110
  8-bit   red channel value
  8-bit green channel value
  8-bit  blue channel value

  The alpha value remains unchanged from the previous pixel.


  .- QOI_OP_RGBA ---------------------------------------------------.
  |         Byte[0]         | Byte[1] | Byte[2] | Byte[3] | Byte[4] |
  |  7  6  5  4  3  2  1  0 | 7 .. 0  | 7 .. 0  | 7 .. 0  | 7 .. 0  |
  |-------------------------+---------+---------+---------+---------|
  |  1  1  1  1  1  1  1  1 |   Red   |  Green  |  Blue   |  Alpha  |
  `-----------------------------------------------------------------`
  8-bit tag b11111111
  8-bit   red channel value
  8-bit green channel value
  8-bit  blue channel value
  8-bit alpha channel value }

{$SCOPEDENUMS ON}

interface

uses
  System.Classes;

const
  { File extension for QOI images }
  SQOIImageExtension = '.qoi'; // do not localize

resourcestring
  { Short description of the QOI file extension }
  SVQOIImages = 'QOI Images';

type
  { Number of channels in a QOI image. }
  TQoiChannels = (
    { Automatic, based on the header of a QOI image.
      Should only be used when reading a QOI image.
      When writing a QOI image, you must specify the channels explicitly
      (either RGB or RGBA) }
    Auto = 0,

    { 3 channels, in R,G,B order }
    RGB  = 3,

    { 4 channels, in R,G,B,A order, where A is the alpha value (or opacity).
      The color channels are assumed to not be premultiplied with the alpha
      channel ("un-premultiplied alpha"). }
    RGBA = 4);

type
  { The colorspace of the QOI image. This value is added to the QOI image
    header for informational purposes. }
  TQoiColorspace = (
    { sRGB, i.e. gamma scaled RGB channels and a linear alpha channel }
    sRGB   = 0,

    { All channels are linear }
    Linear = 1);

type
  { QOI image description }
  TQoiDesc = record
  public
    { Image width in pixels }
    Width: Integer;

    { Image height in pixels }
    Height: Integer;

    { The channels in the picture.
      When reading a QOI image, this can be set to Auto to use the channel
      information from the QOI file. Otherwise, you must set this to either
      RGB or RGBA }
    Channels: TQoiChannels;

    { The colorspace of the image }
    Colorspace: TQoiColorspace;
  public
    { Creates a new image description.

      Parameters:
        AWidth: Image width in pixels
        AHeight: Image height in pixels
        AChannels: The channels in the picture
        AColorspace: (optional) colorspace. Defaults to sRGB }
    constructor Create(const AWidth, AHeight: Integer;
      const AChannels: TQoiChannels;
      const AColorspace: TQoiColorspace = TQoiColorspace.sRGB);
  end;

{ Encode raw RGB or RGBA pixels into a QOI image and write it to a file or
  stream. The ADesc record must be filled with the image width, height, channels
  and optional colorspace.

  Returns 0 on failure or the number of bytes written on success. }
function QoiWrite(const AFilename: String; const AData: Pointer;
  const ADesc: TQoiDesc): Integer; overload;
function QoiWrite(const AStream: TStream; const AData: Pointer;
  const ADesc: TQoiDesc): Integer; overload;

{ Read and decode a QOI image from a file or stream. If ADesc.Channels is Auto,
  the number of channels from the file header is used. Otherwise the output
  format will be forced into this number of channels.

  The function either returns nil on failure or a pointer to the decoded pixels.
  On success, ADesc record struct will be filled with the description from the
  file header.

  The returned pixel data should be freed after use (using FreeMem). }
function QoiRead(const AFilename: String; out ADesc: TQoiDesc;
  const AChannels: TQoiChannels = TQoiChannels.Auto): Pointer; overload;
function QoiRead(const AStream: TStream; out ADesc: TQoiDesc;
  const AChannels: TQoiChannels = TQoiChannels.Auto): Pointer; overload;

{ Read the QOI header from a file or stream.

  The function returns False on failure (for example, when the file is not a
  QOI file. On success, ADesc record struct will be filled with the description
  from the file header. }
function QoiReadDesc(const AFilename: String; out ADesc: TQoiDesc): Boolean; overload;
function QoiReadDesc(const AStream: TStream; out ADesc: TQoiDesc): Boolean; overload;

{ Encode raw RGB or RGBA pixels into a QOI image in memory.

  The function either returns nil on failure or a pointer to the encoded data on
  success. On success the ASize parameter is set to the size in bytes of the
  encoded data.

  The returned qoi data should be freed after use (using FreeMem).  }
function QoiEncode(const AData: Pointer; const ADesc: TQoiDesc;
  out ASize: Integer): Pointer;

{ Decode a QOI image from memory.

  The function either returns nil on failure or a pointer to the decoded pixels.
  On success, the ADesc record is filled with the description from the file
  header.

  The returned pixel data should be freed after use (using FreeMem). }
function QoiDecode(const AData: Pointer; const ASize: Integer;
  out ADesc: TQoiDesc; const AChannels: TQoiChannels = TQoiChannels.Auto): Pointer;

{ Read the QOI header from memory.

  The function returns False on failure (for example, when the memory buffer
  does not contain a QOI image. On success, ADesc record struct will be filled
  with the description from the file header. }
function QoiDecodeDesc(const AData: Pointer; const ASize: Integer;
  out ADesc: TQoiDesc): Boolean;

implementation

uses
  System.SysUtils;

{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}

const
  QOI_OP_INDEX = $00; // 00xxxxxx
  QOI_OP_DIFF  = $40; // 01xxxxxx
  QOI_OP_LUMA  = $80; // 10xxxxxx
  QOI_OP_RUN   = $C0; // 11xxxxxx
  QOI_OP_RGB   = $FE; // 11111110
  QOI_OP_RGBA  = $FF; // 11111111

  QOI_MASK_2   = $C0; // 11000000

const
  QOI_MAGIC = (Ord('q') shl 24) or (Ord('o') shl 16) or (Ord('i') shl 8) or Ord('f');

const
  QOI_HEADER_SIZE = 14;

const
  { 2GB is the max file size that this implementation can safely handle. We
    guard against anything larger than that, assuming the worst case with
    5 bytes per pixel, rounded down to a nice clean value. 400 million pixels
    ought to be enough for anybody. }
  QOI_PIXELS_MAX = 400000000;

const
  QOI_PADDING: array [0..7] of Byte = (0, 0, 0, 0, 0, 0, 0, 1);

type
  TQoiRgba = packed record
  public
    procedure Init(const AR, AG, AB, AA: Byte); inline;
    function Hash: Cardinal; inline;
  public
    case Byte of
      0: (R, G, B, A: Byte);
      1: (V: Cardinal);
  end;

{ TQoiDesc }

constructor TQoiDesc.Create(const AWidth, AHeight: Integer;
  const AChannels: TQoiChannels; const AColorspace: TQoiColorspace);
begin
  Width := AWidth;
  Height := AHeight;
  Channels := AChannels;
  Colorspace := AColorspace;
end;

{ TQoiRgba }

function TQoiRgba.Hash: Cardinal;
begin
  Result := (R * 3) + (G * 5) + (B * 7) + (A * 11);
end;

procedure TQoiRgba.Init(const AR, AG, AB, AA: Byte);
begin
  R := AR;
  G := AG;
  B := AB;
  A := AA;
end;

{ Helpers }

procedure QoiWrite32(var ABytes: PByte; const AValue: Cardinal);
begin
  ABytes[0] := AValue shr 24;
  ABytes[1] := AValue shr 16;
  ABytes[2] := AValue shr 8;
  ABytes[3] := AValue;
  Inc(ABytes, 4);
end;

function QoiRead32(var ABytes: PByte): Cardinal;
begin
  Result := (ABytes[0] shl 24)
         or (ABytes[1] shl 16)
         or (ABytes[2] shl 8)
         or  ABytes[3];
  Inc(ABytes, 4);
end;

{ API }

function QoiEncode(const AData: Pointer; const ADesc: TQoiDesc;
  out ASize: Integer): Pointer;
var
  Index: array [0..63] of TQoiRgba;
begin
  if (AData = nil) or (ADesc.Width <= 0) or (ADesc.Height <= 0)
    or (ADesc.Height >= (QOI_PIXELS_MAX div ADesc.Width))
    or (ADesc.Channels = TQoiChannels.Auto)
  then
    Exit(nil);

  var MaxSize := (ADesc.Width * ADesc.Height * (Ord(ADesc.Channels) + 1))
               + QOI_HEADER_SIZE + SizeOf(QOI_PADDING);

  var Bytes: PByte;
  GetMem(Bytes, MaxSize);
  Result := Bytes;

  QoiWrite32(Bytes, QOI_MAGIC);
  QoiWrite32(Bytes, ADesc.Width);
  QoiWrite32(Bytes, ADesc.Height);
  Bytes^ := Ord(ADesc.Channels);
  Inc(Bytes);
  Bytes^ := Ord(ADesc.Colorspace);
  Inc(Bytes);

  var Pixels := PByte(AData);
  FillChar(Index, SizeOf(Index), 0);

  var Run := 0;
  var Px, PxPrev: TQoiRgba;
  PxPrev.Init(0, 0, 0, 255);
  Px := PxPrev;

  var Channels := Ord(ADesc.Channels);
  var PxEnd := Pixels + (ADesc.Width * ADesc.Height * Channels);

  while (Pixels < PxEnd) do
  begin
    Px.R := Pixels^;
    Inc(Pixels);
    Px.G := Pixels^;
    Inc(Pixels);
    Px.B := Pixels^;
    Inc(Pixels);

    if (Channels = 4) then
    begin
      Px.A := Pixels^;
      Inc(Pixels);
    end;

    if (Px.V = PxPrev.V) then
    begin
      Inc(Run);
      if (Run = 62) or (Pixels = PxEnd) then
      begin
        Bytes^ := QOI_OP_RUN or (Run - 1);
        Inc(Bytes);
        Run := 0;
      end;
    end
    else
    begin
      if (Run > 0) then
      begin
        Bytes^ := QOI_OP_RUN or (Run - 1);
        Inc(Bytes);
        Run := 0;
      end;

      var IndexPos := Px.Hash and 63;

      if (Index[IndexPos].V = Px.V) then
      begin
        Bytes^ := QOI_OP_INDEX or IndexPos;
        Inc(Bytes);
      end
      else
      begin
        Index[IndexPos] := Px;

        if (Px.A = PxPrev.A) then
        begin
          var VR := PX.R - PxPrev.R;
          var VG := PX.G - PxPrev.G;
          var VB := PX.B - PxPrev.B;

          if (VR > -3) and (VR < 2) and
             (VG > -3) and (VG < 2) and
             (VG > -3) and (VG < 2) and
             (VB > -3) and (VB < 2) then
          begin
            Bytes^ := QOI_OP_DIFF or ((VR + 2) shl 4) or ((VG + 2) shl 2) or (VB + 2);
            Inc(Bytes);
          end
          else
          begin
            var VGR := VR - VG;
            var VGB := VB - VG;

            if (VGR >  -9) and (VGR <  8) and
               (VG  > -33) and (VG  < 32) and
               (VGB >  -9) and (VGB <  8) then
            begin
              Bytes^ := QOI_OP_LUMA or (VG + 32);
              Inc(Bytes);
              Bytes^ := ((VGR + 8) shl 4) or (VGB + 8);
              Inc(Bytes);
            end
            else
            begin
              Bytes^ := QOI_OP_RGB;
              Inc(Bytes);
              Bytes^ := Px.R;
              Inc(Bytes);
              Bytes^ := Px.G;
              Inc(Bytes);
              Bytes^ := Px.B;
              Inc(Bytes);
            end;
          end;
        end
        else
        begin
          Bytes^ := QOI_OP_RGBA;
          Inc(Bytes);
          Bytes^ := Px.R;
          Inc(Bytes);
          Bytes^ := Px.G;
          Inc(Bytes);
          Bytes^ := Px.B;
          Inc(Bytes);
          Bytes^ := Px.A;
          Inc(Bytes);
        end;
      end;

      PxPrev := Px;
    end;
  end;

  Move(QOI_PADDING, Bytes^, SizeOf(QOI_PADDING));
  Inc(Bytes, SizeOf(QOI_PADDING));

  ASize := Bytes - PByte(Result);
end;

function QoiDecode(const AData: Pointer; const ASize: Integer;
  out ADesc: TQoiDesc; const AChannels: TQoiChannels): Pointer;
var
  Index: array [0..63] of TQoiRgba;
begin
  if (AData = nil) or (ASize < (QOI_HEADER_SIZE + SizeOf(QOI_PADDING))) then
    Exit(nil);

  var Bytes := PByte(AData);

  var HeaderMagic := QoiRead32(Bytes);
  ADesc.Width:= QoiRead32(Bytes);
  ADesc.Height:= QoiRead32(Bytes);
  ADesc.Channels:= TQoiChannels(Bytes^);
  Inc(Bytes);
  ADesc.Colorspace:= TQoiColorspace(Bytes^);
  Inc(Bytes);

  if (ADesc.Width <= 0) or (ADesc.Height <= 0)
    or ((ADesc.Channels <> TQoiChannels.RGB) and (ADesc.Channels <> TQoiChannels.RGBA))
    or (ADesc.Colorspace > TQoiColorspace.Linear) or (HeaderMagic <> QOI_MAGIC)
    or (ADesc.Height >= (QOI_PIXELS_MAX div ADesc.Width))
  then
    Exit(nil);

  var Channels := Ord(AChannels);
  if (Channels = 0) then
    Channels := Ord(ADesc.Channels);

  var PxLen := ADesc.Width * ADesc.Height * Channels;
  var Pixels: PByte;
  GetMem(Pixels, PxLen);
  Result := Pixels;

  var PxEnd := Pixels + PxLen;
  var BytesEnd := Bytes + ASize - SizeOf(QOI_PADDING);

  FillChar(Index, SizeOf(Index), 0);

  var Px: TQoiRgba;
  Px.Init(0, 0, 0, 255);
  var Run := 0;

  while (Pixels < PxEnd) do
  begin
    if (Run > 0) then
      Dec(Run)
    else if (Bytes < BytesEnd) then
    begin
      var B1: Integer := Bytes^;
      Inc(Bytes);

      if (B1 = QOI_OP_RGB) then
      begin
        Px.R := Bytes^;
        Inc(Bytes);
        Px.G := Bytes^;
        Inc(Bytes);
        Px.B := Bytes^;
        Inc(Bytes);
      end
      else if (B1 = QOI_OP_RGBA) then
      begin
        Px.R := Bytes^;
        Inc(Bytes);
        Px.G := Bytes^;
        Inc(Bytes);
        Px.B := Bytes^;
        Inc(Bytes);
        Px.A := Bytes^;
        Inc(Bytes);
      end
      else
      begin
        var B := B1 and QOI_MASK_2;
        if (B = QOI_OP_INDEX) then
          Px := Index[B1]
        else if (B = QOI_OP_DIFF) then
        begin
          Inc(Px.R, ((B1 shr 4) and $03) - 2);
          Inc(Px.G, ((B1 shr 2) and $03) - 2);
          Inc(Px.B, ( B1        and $03) - 2);
        end
        else if (B = QOI_OP_LUMA) then
        begin
          var B2: Integer := Bytes^;
          Inc(Bytes);
          var VG := (B1 and $3F) - 32;

          Inc(Px.R, VG - 8 + ((B2 shr 4) and $0F));
          Inc(Px.G, VG);
          Inc(Px.B, VG - 8 +  (B2        and $0F));
        end
        else if (B = QOI_OP_RUN) then
          Run := B1 and $3F;
      end;
      Index[Px.Hash and 63] := Px;
    end;

    Pixels^ := Px.R;
    Inc(Pixels);
    Pixels^ := Px.G;
    Inc(Pixels);
    Pixels^ := Px.B;
    Inc(Pixels);

    if (Channels = 4) then
    begin
      Pixels^ := Px.A;
      Inc(Pixels);
    end;
  end;
end;

function QoiDecodeDesc(const AData: Pointer; const ASize: Integer;
  out ADesc: TQoiDesc): Boolean;
begin
  if (AData = nil) or (ASize < QOI_HEADER_SIZE) then
    Exit(False);

  var Bytes := PByte(AData);

  var HeaderMagic := QoiRead32(Bytes);
  ADesc.Width:= QoiRead32(Bytes);
  ADesc.Height:= QoiRead32(Bytes);
  ADesc.Channels:= TQoiChannels(Bytes^);
  Inc(Bytes);
  ADesc.Colorspace:= TQoiColorspace(Bytes^);

  if (ADesc.Width <= 0) or (ADesc.Height <= 0)
    or ((ADesc.Channels <> TQoiChannels.RGB) and (ADesc.Channels <> TQoiChannels.RGBA))
    or (ADesc.Colorspace > TQoiColorspace.Linear) or (HeaderMagic <> QOI_MAGIC)
    or (ADesc.Height >= (QOI_PIXELS_MAX div ADesc.Width))
  then
    Exit(False);

  Result := True;
end;

function QoiWrite(const AFilename: String; const AData: Pointer;
  const ADesc: TQoiDesc): Integer; overload;
begin
  try
    var Stream := TFileStream.Create(AFilename, fmCreate or fmShareDenyWrite);
    try
      Result := QoiWrite(Stream, AData, ADesc);
    finally
      Stream.Free;
    end;
  except
    Result := 0;
  end;
end;

function QoiWrite(const AStream: TStream; const AData: Pointer;
  const ADesc: TQoiDesc): Integer; overload;
begin
  if (AStream = nil) then
    Exit(0);

  var Encoded := QoiEncode(AData, ADesc, Result);
  if (Encoded = nil) then
    Exit(0);

  try
    if (AStream.Write(Encoded^, Result) <> Result) then
      Result := 0;
  finally
    FreeMem(Encoded);
  end;
end;

function QoiRead(const AFilename: String; out ADesc: TQoiDesc;
  const AChannels: TQoiChannels): Pointer; overload;
begin
  Result := nil;
  try
    var Stream := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyWrite);
    try
      Result := QoiRead(Stream, ADesc, AChannels);
    finally
      Stream.Free;
    end;
  except
    FreeMem(Result);
    Result := nil;
  end;
end;

function QoiRead(const AStream: TStream; out ADesc: TQoiDesc;
  const AChannels: TQoiChannels): Pointer; overload;
begin
  if (AStream = nil) then
    Exit(nil);

  var Size := AStream.Size - AStream.Position;
  if (Size <= 0) then
    Exit(nil);

  var Data: Pointer;
  GetMem(Data, Size);
  try
    if (AStream.Read(Data^, Size) <> Size) then
      Exit(nil);

    Result := QoiDecode(Data, Size, ADesc, AChannels);
  finally
    FreeMem(Data);
  end;
end;

function QoiReadDesc(const AFilename: String; out ADesc: TQoiDesc): Boolean; overload;
begin
  try
    var Stream := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyWrite);
    try
      Result := QoiReadDesc(Stream, ADesc);
    finally
      Stream.Free;
    end;
  except
    Result := False;
  end;
end;

function QoiReadDesc(const AStream: TStream; out ADesc: TQoiDesc): Boolean; overload;
var
  Header: array [0..QOI_HEADER_SIZE - 1] of Byte;
begin
  if (AStream = nil) then
    Exit(False);

  var Size := AStream.Size - AStream.Position;
  if (Size < QOI_HEADER_SIZE) then
    Exit(False);

  if (AStream.Read(Header, QOI_HEADER_SIZE) <> QOI_HEADER_SIZE) then
    Exit(False);

  Result := QoiDecodeDesc(@Header, QOI_HEADER_SIZE, ADesc);
end;

end.

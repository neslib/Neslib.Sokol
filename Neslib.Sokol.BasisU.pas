unit Neslib.Sokol.BasisU;
{ Minimal wrapper for Basis Universal texture support.

  For documentation, check out the Neslib.Sokol.BasisU.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.BasisU.md }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.Sokol.Gfx;

type
  { Entry point }
  TBasisU = record // static
  public
    class procedure Setup; static;
    class procedure Shutdown; static;

    { All in one image creation function }
    class function CreateImage(const ABasisUData: TRange): TImage; static;

    { Optional for finer control }
    class function Transcode(const ABasisUData: TRange): TImageDesc; static;
    class procedure FreeImageDesc(const ADesc: TImageDesc); static;

    { Query supported pixel format }
    class function PixelFormat(const AHasAlpha: Boolean): TPixelFormat; static;
  end;

implementation

uses
  Neslib.Sokol.Api;

function _sbasisu_make_image(basisu_data: _sg_range): _sg_image; cdecl;
  external _LIB_SOKOL name _PU + 'sbasisu_make_image' {$IFDEF MACOS64}dependency 'c++'{$ENDIF};

{ TBasisU }

class function TBasisU.CreateImage(const ABasisUData: TRange): TImage;
begin
  var Range: _sg_range;
  Range.ptr := ABasisUData.Data;
  Range.size := ABasisUData.Size;
  Result := TImage(_sbasisu_make_image(Range));
end;

class procedure TBasisU.FreeImageDesc(const ADesc: TImageDesc);
begin
  var Desc: _sg_image_desc;
  ADesc._Convert(Desc);
  _sbasisu_free(@Desc);
end;

class function TBasisU.PixelFormat(const AHasAlpha: Boolean): TPixelFormat;
begin
  Result := TPixelFormat(_sbasisu_pixelformat(AHasAlpha));
end;

class procedure TBasisU.Setup;
begin
  _sbasisu_setup;
end;

class procedure TBasisU.Shutdown;
begin
  _sbasisu_shutdown;
end;

class function TBasisU.Transcode(const ABasisUData: TRange): TImageDesc;
begin
  var Range: _sg_range;
  Range.ptr := ABasisUData.Data;
  Range.size := ABasisUData.Size;
  var Desc := _sbasisu_transcode(Range);
  Result._InitFrom(Desc);
end;

end.

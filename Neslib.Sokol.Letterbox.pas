unit Neslib.Sokol.Letterbox;
{ Provide fixed-aspect viewport for random-aspect framebuffer.

  For a user guide, check out the Neslib.Sokol.Letterbox.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.Letterbox.md }

{$INCLUDE 'Neslib.Sokol.inc'}
{$MINENUMSIZE 4}

interface

uses
  Neslib.Sokol.Api;

type
  { Defines a 'safe border' in pixels. Used as nested record in TLetterboxDesc. }
  TLetterboxBorder = record
  public
    Left: Integer;
    Right: Integer;
    Top: Integer;
    Bottom: Integer;
  end;

type
  { Anchor the content to a side. The default is to center the content.
    Used in TLetterboxDesc. }
  TLetterboxAnchor = (
    Center,
    Top,
    Bottom,
    Left,
    Right);

type
  { The content letterbox description. Used as input to the Letterbox function. }
  TLetterboxDesc = record
  public
    { Width / Height. Default 1.0 }
    ContentAspectRatio: Single;
    Anchor: TLetterboxAnchor;
    Border: TLetterboxBorder;
  public
    { Initialize with default values }
    class function Create: TLetterboxDesc; static;
    procedure Init; inline;
  end;
  PLetterboxDesc = ^TLetterboxDesc;

type
  { The resulting viewport. Return value the Letterboxfunction }
  TLetterboxViewport = record
  public
    X: Integer;
    Y: Integer;
    Width: Integer;
    Height: Integer;
  end;

{ Compute viewport for 'letterboxing' fixed-aspect content in a variable-aspect
  framebuffer }
function Letterbox(const AWidth, AHeight: Integer;
  const ADesc: TLetterboxDesc): TLetterboxViewport; inline;

implementation

function Letterbox(const AWidth, AHeight: Integer;
  const ADesc: TLetterboxDesc): TLetterboxViewport;
begin
  Result := TLetterboxViewport(_slbx_letterbox(AWidth, AHeight, @ADesc));
end;

{ TLetterboxDesc }

class function TLetterboxDesc.Create: TLetterboxDesc;
begin
  Result.Init;
end;

procedure TLetterboxDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
end;

initialization
  Assert(SizeOf(TLetterboxDesc) = SizeOf(_slbx_letterbox_desc));

end.

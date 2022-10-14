unit Neslib.Sokol.FontStash;
{ Renderer for https://github.com/memononen/fontstash on top of Neslib.Sokol.GL.

  For a user guide, check out the Neslib.Sokol.FontStash.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.FontStash.md }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.FontStash;

type
  TSokolFontStash = record // static
  public
    { Creates a TFontStash object for use with Sokol.

      Parameters:
        AWidth: initial width of font atlas texture (default: 512, must be power
          of 2).
        AHeight: initial height of font atlas texture (default: 512, must be
          power of 2).
        AUseDelphiMemoryManager: whether to use Delphi's memory manager instead
          of the default memory manager used by the Sokol library (default False)
          When SOKOL_MEM_TRACK is defined, it always uses Delphi's memory
          manager. }
    class function Create(const AWidth: Integer = 512; const AHeight: Integer = 512;
      const AUseDelphiMemoryManager: Boolean = False): TFontStash; static;
    class procedure Free(const AContext: TFontStash); static;
    class procedure Flush(const AContext: TFontStash); inline; static;
  end;

implementation

uses
  {$IFDEF SOKOL_MEM_TRACK}
  Neslib.Sokol.MemTrack,
  {$ELSE}
  Neslib.Sokol.Utils,
  {$ENDIF}
  Neslib.Sokol.Api;

{ TSokolFontStash }

class function TSokolFontStash.Create(const AWidth, AHeight: Integer;
  const AUseDelphiMemoryManager: Boolean): TFontStash;
begin
  var Desc: _sfons_desc_t;
  Desc.width := AWidth;
  Desc.height := AHeight;
  {$IFDEF SOKOL_MEM_TRACK}
  ADst.allocator.alloc := _MemTrackAlloc;
  ADst.allocator.free := _MemTrackFree;
  {$ELSE}
  if (AUseDelphiMemoryManager) then
  begin
    Desc.allocator.alloc := _AllocCallback;
    Desc.allocator.free := _FreeCallback;
  end
  else
  begin
    Desc.allocator.alloc := nil;
    Desc.allocator.free := nil;
  end;
  {$ENDIF}
  Desc.allocator.user_data := nil;
  Result._Init(_sfons_create(@Desc));
end;

class procedure TSokolFontStash.Flush(const AContext: TFontStash);
begin
  _sfons_flush(AContext.Handle);
end;

class procedure TSokolFontStash.Free(const AContext: TFontStash);
begin
  _sfons_destroy(AContext.Handle);
end;

end.

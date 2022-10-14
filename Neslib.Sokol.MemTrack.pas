unit Neslib.Sokol.MemTrack;
{ Memory allocation wrapper to track memory usage of Sokol libraries.

  For a user guide, check out the Neslib.Sokol.MemTrack.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.MemTrack.md }

{$IFNDEF SOKOL_MEM_TRACK}
  {$MESSAGE Warn 'This unit should only be used when the SOKOL_MEM_TRACK is set'}
{$ENDIF}

{$INCLUDE 'Neslib.Sokol.inc'}

interface

type
  { Information about the memory currently allocated by Sokol libraries }
  TMemoryAllocations = record
  public
    { Number of allocation operations }
    NumAllocations: Integer;

    { Total number of bytes currently allocations }
    NumBytes: Integer;
  end;

type
  TMemTrack = record // static
  public
    { Returns information about the current memory allocations inside the
      Sokol libraries }
    class function GetAllocations: TMemoryAllocations; static;
  end;

{$REGION 'Internal Declarations'}
function _MemTrackAlloc(Size: NativeUInt; UserData: Pointer): Pointer; cdecl;
procedure _MemTrackFree(Ptr, UserData: Pointer); cdecl;
{$ENDREGION 'Internal Declarations'}

implementation

var
  GAllocations: TMemoryAllocations = (
    NumAllocations: 0;
    NumBytes: 0);

const
  { Per-allocation header used to keep track of the allocation size }
  MEMTRACK_HEADER_SIZE = 16;

function _MemTrackAlloc(Size: NativeUInt; UserData: Pointer): Pointer; cdecl;
begin
  GetMem(Result, Size + MEMTRACK_HEADER_SIZE);

  { Store allocation size (for allocation size tracking) }
  PNativeUInt(Result)^ := Size;

  Inc(GAllocations.NumAllocations);
  Inc(GAllocations.NumBytes, Size);

  { Adjust pointer }
  Inc(PByte(Result), MEMTRACK_HEADER_SIZE);
end;

procedure _MemTrackFree(Ptr, UserData: Pointer); cdecl;
begin
  if (Ptr <> nil) then
  begin
    var AllocPtr := PByte(Ptr) - MEMTRACK_HEADER_SIZE;
    var Size := PNativeUInt(AllocPtr)^;
    Dec(GAllocations.NumAllocations);
    Dec(GAllocations.NumBytes, Size);
    FreeMem(AllocPtr);
  end;
end;

{ TMemTrack }

class function TMemTrack.GetAllocations: TMemoryAllocations;
begin
  Result := GAllocations;
end;

end.

unit Neslib.Sokol.Utils;
{ Internal utilities }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

function _AllocCallback(Size: NativeUInt; UserData: Pointer): Pointer; cdecl;
procedure _FreeCallback(Ptr, UserData: Pointer); cdecl;

implementation

function _AllocCallback(Size: NativeUInt; UserData: Pointer): Pointer; cdecl;
begin
  GetMem(Result, Size);
end;

procedure _FreeCallback(Ptr, UserData: Pointer); cdecl;
begin
  FreeMem(Ptr);
end;

end.

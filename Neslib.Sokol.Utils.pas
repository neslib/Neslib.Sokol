unit Neslib.Sokol.Utils;
{ Internal utilities }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.Sokol.Types;

function _AllocCallback(Size: NativeUInt; UserData: Pointer): Pointer; cdecl;
procedure _FreeCallback(Ptr, UserData: Pointer); cdecl;

procedure _LogDefault(const ALevel: TLogLevel; const AItem: Integer;
  const AMessage: String; const ALineNr: Integer);

implementation

uses
  Neslib.Sokol.Api;

function _AllocCallback(Size: NativeUInt; UserData: Pointer): Pointer; cdecl;
begin
  GetMem(Result, Size);
end;

procedure _FreeCallback(Ptr, UserData: Pointer); cdecl;
begin
  FreeMem(Ptr);
end;

procedure _LogDefault(const ALevel: TLogLevel; const AItem: Integer;
  const AMessage: String; const ALineNr: Integer);
begin
  _slog_func(nil, Ord(ALevel), AItem, PAnsiChar(AnsiString(AMessage)), ALineNr, nil, nil);
end;

end.

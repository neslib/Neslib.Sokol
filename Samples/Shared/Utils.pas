unit Utils;

interface

type
  { A dynamic array that is aligned on a 16-byte boundary for SIMD operations. }
  TAlignedArray<T: record> = record
  {$REGION 'Internal Declarations'}
  private type
    P = ^T;
  private
    FItems: Pointer;
    FLength: Integer;
    function GetItem(const AIndex: Integer): T; inline;
    function GetItemPtr(const AIndex: Integer): Pointer; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const ALength: Integer);
    procedure Free;

    property Data: Pointer read FItems;
    property Length: Integer read FLength;
    property Items[const AIndex: Integer]: T read GetItem; default;
    property ItemPtrs[const AIndex: Integer]: Pointer read GetItemPtr;
  end;

implementation

{ TAlignedArray<T> }

constructor TAlignedArray<T>.Create(const ALength: Integer);
{ When using a regular dynamic array, Delphi already aligns memory on 16-byte
  boundaries. On 32-bit systems however, the first 8 bytes contain the length
  and reference count, so the actual items start on an 8-byte boundary. }
begin
  Assert(not IsManagedType(T));
  Assert((SizeOf(T) and 15) = 0, 'Elements should be a multiple of 16 bytes in size');

  GetMem(FItems, ALength * SizeOf(T));
  Assert((UIntPtr(FItems) and 15) = 0);
  FillChar(FItems^, ALength * SizeOf(T), 0);
  FLength := ALength;
end;

procedure TAlignedArray<T>.Free;
begin
  FreeMem(FItems);
  FItems := nil;
  FLength := 0;
end;

function TAlignedArray<T>.GetItem(const AIndex: Integer): T;
begin
  Assert(Cardinal(AIndex) < Cardinal(FLength));
  {$POINTERMATH ON}
  Result := P(FItems)[AIndex];
  {$POINTERMATH OFF}
end;

function TAlignedArray<T>.GetItemPtr(const AIndex: Integer): Pointer;
begin
  Assert(Cardinal(AIndex) < Cardinal(FLength));
  {$POINTERMATH ON}
  Result := P(FItems) + AIndex;
  {$POINTERMATH OFF}
end;

end.

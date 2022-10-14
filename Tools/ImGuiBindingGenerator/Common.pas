unit Common;

interface

function IsPowerOfTwo(const AValue: Int64): Boolean;
function LogTwo(const AValue: Int64): Integer;
function ToDelphiType(const AContext, ACType: String;
  const AForParameter: Boolean;
  const ATemplateTypeName: String = ''): String;
function ToPascalCase(const ASource: String): String;
function ToValidId(const ASource: String; const AToPascalCase: Boolean): String;

implementation

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults;

var
  ReservedWords: TDictionary<String, Integer>;
  TypeMap: TDictionary<String, String>;

function IsPowerOfTwo(const AValue: Int64): Boolean;
begin
  Result := (AValue <> 0) and ((AValue and (AValue - 1)) = 0);
end;

function LogTwo(const AValue: Int64): Integer;
{ Slow, but who cares for this tool }
begin
  var Value := AValue;
  Result := 0;
  while (Value > 1) do
  begin
    Inc(Result);
    Value := Value shr 1;
  end;
end;

function ToDelphiType(const AContext, ACType: String; const AForParameter: Boolean;
  const ATemplateTypeName: String): String;
var
  StarCount, I, J: Integer;
  MappedType: String;

  function IsTemplate(var AStr: String; const AType: String): Boolean;
  begin
    Result := AStr.StartsWith(AType + '_');
    if (Result) then begin
      if (ATemplateTypeName = '') then
        AStr := 'T' + AType + '<' + ToDelphiType(AContext, AStr.Substring(AType.Length + 1), AForParameter) + '>'
      else
        AStr := 'T' + AType + '<' + ToDelphiType(AContext, ATemplateTypeName, AForParameter) + '>';

      if (StarCount > 0) then
      begin
        Assert(StarCount = 1);
        AStr := '*' + AStr;
      end;
    end
  end;

begin
  Result := ACType.Trim;

  StarCount := 0;
  if (AForParameter) then
  begin
    while True do
    begin
      I := Result.IndexOf('[');
      if (I < 0) then
        Break;

      { Convert array parameter to pointer }
      Inc(StarCount);
      J := Result.IndexOf(']');
      Assert(J > I);
      Result := Result.Remove(I, J - I + 1);
    end;
  end;

  if (Result.StartsWith('const ')) then
    Result := Result.Substring(6);

  if (Result.EndsWith(' const')) then
    Result := Result.Substring(0, Result.Length - 6);

  while (Result.EndsWith('*')) or (Result.EndsWith('&')) do
  begin
    Inc(StarCount);
    Result := Result.Substring(0, Result.Length - 1).Trim;
    if (Result.EndsWith(' const')) then
      Result := Result.Substring(0, Result.Length - 6);
  end;

  if (Result.EndsWith(' const')) then
    Result := Result.Substring(0, Result.Length - 6);

  if (IsTemplate(Result, 'ImVector') or IsTemplate(Result, 'ImPool'))
    or IsTemplate(Result, 'ImSpan') then
    Exit;

  if (TypeMap.TryGetValue(Result, MappedType)) then
    Result := MappedType;

  if (Result = 'TVector4') then
  begin
    { This can also be a TRectF or a TAlphaColorF }
    var Context := AContext.ToLower;
    if (Context.IndexOf('rect') >= 0) then
      Result := 'TRectF'
    else if (Context.IndexOf('col') >= 0) then
      Result := 'TAlphaColorF';
  end;

  if (StarCount > 0) then
  begin
{    if (Result = 'char') then
    begin
      if (StarCount = 1) then
        Exit('MarshaledAString')
      else
        Exit(String.Create('P', StarCount - 1) + 'MarshaledAString');
    end;}

    if (Result.StartsWith('T')) then
      Exit(String.Create('P', StarCount) + Result.Substring(1))
    else
      Exit(String.Create('P', StarCount) + Result);
  end;

  if (MappedType = '') then
  begin
    Result := 'T' + Result;
    if (Result.EndsWith('_')) then
      SetLength(Result, Result.Length - 1);
  end;
end;

function ToPascalCase(const ASource: String): String;
var
  I: Integer;
begin
  Result := ASource;
  if (Result.Length > 0) then
  begin
    Result[Low(String)] := UpCase(Result[Low(String)]);
    while True do
    begin
      I := Result.IndexOf('_');
      if (I < 0) then
        Break;

      Result := Result.Remove(I, 1);
      if (I < Result.Length) then
        Result[Low(String) + I] := UpCase(Result[Low(String) + I]);
    end;
  end;
end;

function ToValidId(const ASource: String; const AToPascalCase: Boolean): String;
begin
  Result := ASource;
  if (AToPascalCase) then
    Result := ToPascalCase(Result);

  if (ReservedWords.ContainsKey(Result)) then
    Result := '&' + Result
  else if (Result <> '') then
  begin
    var C := AnsiChar(Result.Chars[0]);
    if (C >= '0') and (C <= '9') then
      Result := '_' + Result;
  end;
end;

procedure SetupReservedWords;
begin
  ReservedWords.Add('and', 0);
  ReservedWords.Add('end', 0);
  ReservedWords.Add('interface', 0);
  ReservedWords.Add('record', 0);
  ReservedWords.Add('var', 0);
  ReservedWords.Add('array', 0);
  ReservedWords.Add('except', 0);
  ReservedWords.Add('is', 0);
  ReservedWords.Add('repeat', 0);
  ReservedWords.Add('while', 0);
  ReservedWords.Add('as', 0);
  ReservedWords.Add('exports', 0);
  ReservedWords.Add('label', 0);
  ReservedWords.Add('resourcestring', 0);
  ReservedWords.Add('with', 0);
  ReservedWords.Add('asm', 0);
  ReservedWords.Add('file', 0);
  ReservedWords.Add('library', 0);
  ReservedWords.Add('set', 0);
  ReservedWords.Add('xor', 0);
  ReservedWords.Add('begin', 0);
  ReservedWords.Add('finalization', 0);
  ReservedWords.Add('mod', 0);
  ReservedWords.Add('shl', 0);
  ReservedWords.Add('case', 0);
  ReservedWords.Add('finally', 0);
  ReservedWords.Add('nil', 0);
  ReservedWords.Add('shr', 0);
  ReservedWords.Add('class', 0);
  ReservedWords.Add('for', 0);
  ReservedWords.Add('not', 0);
  ReservedWords.Add('string', 0);
  ReservedWords.Add('const', 0);
  ReservedWords.Add('function', 0);
  ReservedWords.Add('object', 0);
  ReservedWords.Add('then', 0);
  ReservedWords.Add('constructor', 0);
  ReservedWords.Add('goto', 0);
  ReservedWords.Add('of', 0);
  ReservedWords.Add('threadvar', 0);
  ReservedWords.Add('destructor', 0);
  ReservedWords.Add('if', 0);
  ReservedWords.Add('or', 0);
  ReservedWords.Add('to', 0);
  ReservedWords.Add('dispinterface', 0);
  ReservedWords.Add('implementation', 0);
  ReservedWords.Add('packed', 0);
  ReservedWords.Add('try', 0);
  ReservedWords.Add('div', 0);
  ReservedWords.Add('in', 0);
  ReservedWords.Add('procedure', 0);
  ReservedWords.Add('type', 0);
  ReservedWords.Add('do', 0);
  ReservedWords.Add('inherited', 0);
  ReservedWords.Add('program', 0);
  ReservedWords.Add('unit', 0);
  ReservedWords.Add('downto', 0);
  ReservedWords.Add('initialization', 0);
  ReservedWords.Add('property', 0);
  ReservedWords.Add('until', 0);
  ReservedWords.Add('else', 0);
  ReservedWords.Add('inline', 0);
  ReservedWords.Add('raise', 0);
  ReservedWords.Add('uses', 0);

  ReservedWords.Add('byte', 0);
  ReservedWords.Add('shortint', 0);
  ReservedWords.Add('smallint', 0);
  ReservedWords.Add('word', 0);
  ReservedWords.Add('cardinal', 0);
  ReservedWords.Add('integer', 0);

  ReservedWords.Add('absolute', 0);
  ReservedWords.Add('export', 0);
  ReservedWords.Add('public', 0);
  ReservedWords.Add('stdcall', 0);
  ReservedWords.Add('abstract', 0);
  ReservedWords.Add('external', 0);
  ReservedWords.Add('near', 0);
  ReservedWords.Add('published', 0);
  ReservedWords.Add('strict', 0);
  ReservedWords.Add('assembler', 0);
  ReservedWords.Add('far', 0);
  ReservedWords.Add('automated', 0);
  ReservedWords.Add('final', 0);
  ReservedWords.Add('operator', 0);
  ReservedWords.Add('unsafe', 0);
  ReservedWords.Add('cdecl', 0);
  ReservedWords.Add('forward', 0);
  ReservedWords.Add('out', 0);
  ReservedWords.Add('varargs', 0);
  ReservedWords.Add('overload', 0);
  ReservedWords.Add('register', 0);
  ReservedWords.Add('virtual', 0);
  ReservedWords.Add('override', 0);
  ReservedWords.Add('reintroduce', 0);
  ReservedWords.Add('deprecated', 0);
  ReservedWords.Add('pascal', 0);
  ReservedWords.Add('dispid', 0);
  ReservedWords.Add('platform', 0);
  ReservedWords.Add('safecall', 0);
  ReservedWords.Add('dynamic', 0);
  ReservedWords.Add('private', 0);
  ReservedWords.Add('sealed', 0);
  ReservedWords.Add('experimental', 0);
  ReservedWords.Add('message', 0);
  ReservedWords.Add('protected', 0);
  ReservedWords.Add('static', 0);
end;

procedure SetupTypeMap;
begin
  { Convert "void" to "Pointer". The initial "P" is handled by converting a '*'. }
  TypeMap.Add('void', 'ointer');

  TypeMap.Add('bool', 'Boolean');
  TypeMap.Add('int', 'Integer');
  TypeMap.Add('unsigned int', 'Cardinal');
  TypeMap.Add('short', 'Smallint');
  TypeMap.Add('unsigned short', 'Word');
  TypeMap.Add('char', 'UTF8Char');
  TypeMap.Add('unsigned char', 'Byte');
  TypeMap.Add('signed char', 'Int8');
  TypeMap.Add('float', 'Single');
  TypeMap.Add('double', 'Double');
  TypeMap.Add('ImS8', 'Int8');
  TypeMap.Add('ImS16', 'Int16');
  TypeMap.Add('ImS32', 'Int32');
  TypeMap.Add('ImS64', 'Int64');
  TypeMap.Add('ImU8', 'UInt8');
  TypeMap.Add('ImU16', 'UInt16');
  TypeMap.Add('ImU32', 'UInt32');
  TypeMap.Add('ImU64', 'UInt64');
  TypeMap.Add('ImVec2', 'TVector2');
  TypeMap.Add('ImVec4', 'TVector4');
  TypeMap.Add('ImWchar', 'WideChar');
  TypeMap.Add('ImWchar16', 'WideChar');
  TypeMap.Add('ImColor_Simple', 'TImColor');
  TypeMap.Add('ImVec2_Simple', 'TVector2');
  TypeMap.Add('ImVec4_Simple', 'TVector4');
  TypeMap.Add('va_list', 'Pointer');
  TypeMap.Add('size_t', 'NativeUInt');
end;

procedure Initialize;
begin
  ReservedWords := TDictionary<String, Integer>.Create(TIStringComparer.Ordinal);
  TypeMap := TDictionary<String, String>.Create;
  SetupReservedWords;
  SetupTypeMap;
end;

procedure Finalize;
begin
  TypeMap.Free;
  ReservedWords.Free;
end;

initialization
  Initialize;

finalization
  Finalize;

end.

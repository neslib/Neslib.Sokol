unit Utils;

interface

function IsPowerOfTwo(const AValue: Int64): Boolean;
function LogTwo(const AValue: Int64): Integer;
function ToDelphiType(const ACType: String): String;
function ToPascalCase(const ASource: String): String;
function ToValidId(const ASource: String; const AToPascalCase: Boolean): String;

implementation

uses
  System.SysUtils,
  System.Generics.Defaults,
  System.Generics.Collections;

var
  GReservedWords: TDictionary<String, Integer>;
  GTypeMap: TDictionary<String, String>;


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

function ToDelphiType(const ACType: String): String;
begin
  var CType := ACType.Trim;

  if (GTypeMap.TryGetValue(CType, Result)) then
    Exit;

  Result := 'T' + CType;
//  if (Result.EndsWith('_')) then
//    Result := Result.Substring(0, Result.Length - 1);
end;

function ToPascalCase(const ASource: String): String;
begin
  Result := ASource;
  if (Result.Length > 0) then
  begin
    Result[Low(String)] := UpCase(Result[Low(String)]);
    while True do
    begin
      var I := Result.IndexOf('_');
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

  if (GReservedWords.ContainsKey(Result)) then
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
  GReservedWords.Add('and', 0);
  GReservedWords.Add('end', 0);
  GReservedWords.Add('interface', 0);
  GReservedWords.Add('record', 0);
  GReservedWords.Add('var', 0);
  GReservedWords.Add('array', 0);
  GReservedWords.Add('except', 0);
  GReservedWords.Add('is', 0);
  GReservedWords.Add('repeat', 0);
  GReservedWords.Add('while', 0);
  GReservedWords.Add('as', 0);
  GReservedWords.Add('exports', 0);
  GReservedWords.Add('label', 0);
  GReservedWords.Add('resourcestring', 0);
  GReservedWords.Add('with', 0);
  GReservedWords.Add('asm', 0);
  GReservedWords.Add('file', 0);
  GReservedWords.Add('library', 0);
  GReservedWords.Add('set', 0);
  GReservedWords.Add('xor', 0);
  GReservedWords.Add('begin', 0);
  GReservedWords.Add('finalization', 0);
  GReservedWords.Add('mod', 0);
  GReservedWords.Add('shl', 0);
  GReservedWords.Add('case', 0);
  GReservedWords.Add('finally', 0);
  GReservedWords.Add('nil', 0);
  GReservedWords.Add('shr', 0);
  GReservedWords.Add('class', 0);
  GReservedWords.Add('for', 0);
  GReservedWords.Add('not', 0);
  GReservedWords.Add('string', 0);
  GReservedWords.Add('const', 0);
  GReservedWords.Add('function', 0);
  GReservedWords.Add('object', 0);
  GReservedWords.Add('then', 0);
  GReservedWords.Add('constructor', 0);
  GReservedWords.Add('goto', 0);
  GReservedWords.Add('of', 0);
  GReservedWords.Add('threadvar', 0);
  GReservedWords.Add('destructor', 0);
  GReservedWords.Add('if', 0);
  GReservedWords.Add('or', 0);
  GReservedWords.Add('to', 0);
  GReservedWords.Add('dispinterface', 0);
  GReservedWords.Add('implementation', 0);
  GReservedWords.Add('packed', 0);
  GReservedWords.Add('try', 0);
  GReservedWords.Add('div', 0);
  GReservedWords.Add('in', 0);
  GReservedWords.Add('procedure', 0);
  GReservedWords.Add('type', 0);
  GReservedWords.Add('do', 0);
  GReservedWords.Add('inherited', 0);
  GReservedWords.Add('program', 0);
  GReservedWords.Add('unit', 0);
  GReservedWords.Add('downto', 0);
  GReservedWords.Add('initialization', 0);
  GReservedWords.Add('property', 0);
  GReservedWords.Add('until', 0);
  GReservedWords.Add('else', 0);
  GReservedWords.Add('inline', 0);
  GReservedWords.Add('raise', 0);
  GReservedWords.Add('uses', 0);

  GReservedWords.Add('byte', 0);
  GReservedWords.Add('shortint', 0);
  GReservedWords.Add('smallint', 0);
  GReservedWords.Add('word', 0);
  GReservedWords.Add('cardinal', 0);
  GReservedWords.Add('integer', 0);

  GReservedWords.Add('absolute', 0);
  GReservedWords.Add('export', 0);
  GReservedWords.Add('public', 0);
  GReservedWords.Add('stdcall', 0);
  GReservedWords.Add('abstract', 0);
  GReservedWords.Add('external', 0);
  GReservedWords.Add('near', 0);
  GReservedWords.Add('published', 0);
  GReservedWords.Add('strict', 0);
  GReservedWords.Add('assembler', 0);
  GReservedWords.Add('far', 0);
  GReservedWords.Add('automated', 0);
  GReservedWords.Add('final', 0);
  GReservedWords.Add('operator', 0);
  GReservedWords.Add('unsafe', 0);
  GReservedWords.Add('cdecl', 0);
  GReservedWords.Add('forward', 0);
  GReservedWords.Add('out', 0);
  GReservedWords.Add('varargs', 0);
  GReservedWords.Add('overload', 0);
  GReservedWords.Add('register', 0);
  GReservedWords.Add('virtual', 0);
  GReservedWords.Add('override', 0);
  GReservedWords.Add('reintroduce', 0);
  GReservedWords.Add('deprecated', 0);
  GReservedWords.Add('pascal', 0);
  GReservedWords.Add('dispid', 0);
  GReservedWords.Add('platform', 0);
  GReservedWords.Add('safecall', 0);
  GReservedWords.Add('dynamic', 0);
  GReservedWords.Add('private', 0);
  GReservedWords.Add('sealed', 0);
  GReservedWords.Add('experimental', 0);
  GReservedWords.Add('message', 0);
  GReservedWords.Add('protected', 0);
  GReservedWords.Add('static', 0);
end;

procedure SetupTypeMap;
begin
  GTypeMap.Add('bool', 'Boolean');
  GTypeMap.Add('int', 'Integer');
  GTypeMap.Add('unsigned int', 'Cardinal');
  GTypeMap.Add('short', 'Smallint');
  GTypeMap.Add('unsigned short', 'Word');
  GTypeMap.Add('char', 'UTF8Char');
  GTypeMap.Add('unsigned char', 'Byte');
  GTypeMap.Add('signed char', 'Int8');
  GTypeMap.Add('float', 'Single');
  GTypeMap.Add('double', 'Double');
  GTypeMap.Add('ImVec2', 'TVector2');
  GTypeMap.Add('ImVec4', 'TVector4');
end;

procedure Initialize;
begin
  GReservedWords := TDictionary<String, Integer>.Create(TIStringComparer.Ordinal);
  SetupReservedWords;

  GTypeMap := TDictionary<String, String>.Create;
  SetupTypeMap;
end;

procedure Finalize;
begin
  GTypeMap.Free;
  GReservedWords.Free;
end;

initialization
  Initialize;

finalization
  Finalize;

end.

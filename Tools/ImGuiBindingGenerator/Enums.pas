unit Enums;

interface

uses
  Neslib.Json,
  Neslib.Collections,
  SourceWriter;

type
  { A value in a TEnum definition }
  TEnumValue = class
  {$REGION 'Internal Declarations'}
  private
    FName: String;
    FStringValue: String;
    FCalculatedValue: Int64;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const APrefix: String; const AValue: TJsonValue);

    procedure Write(const AWriter: TSourceWriter; const AIsFlag: Boolean);

    { The name of the enum value (without any enum name prefix) }
    property Name: String read FName;

    { The value as a string (this is a C expression, and as such can contain
      "<<" operators for enum flags. }
    property StringValue: String read FStringValue;

    { The value as calculated by executing the StringValue expression. }
    property CalculatedValue: Int64 read FCalculatedValue;
  end;

type
  { A single C Enum definition }
  TEnum = class
  {$REGION 'Internal Declarations'}
  private
    FName: String;
    FValues: TObjectList<TEnumValue>;
    FIsInternal: Boolean;
  private
    procedure WriteSet(const AWriter: TSourceWriter; const AName: String);
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AElement: PJsonElement);
    destructor Destroy; override;

    procedure Write(const AWriter: TSourceWriter);

    function GetEnumValue(const AOrdValue: Int64): TEnumValue;
    function GetMaxValue: Int64;

    { The name of the enum. }
    property Name: String read FName;

    property IsInternal: Boolean read FIsInternal write FIsInternal;
  end;

type
  { Represents the "enums" node in the "structs_and_enums.json" file }
  TEnums = class
  {$REGION 'Internal Declarations'}
  private class var
    FInstance: TEnums;
  private
    FEnums: TObjectList<TEnum>;
    FEnumsByName: TDictionary<String, TEnum>;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load(const AValue: TJsonValue);
    procedure Write(const AWriter: TSourceWriter);

    function GetEnumByName(const AName: String): TEnum;

    class property Instance: TEnums read FInstance;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  DelphiCustomizations,
  Common;

{ TEnumValue }

constructor TEnumValue.Create(const APrefix: String; const AValue: TJsonValue);
begin
  inherited Create;
  Assert(AValue.IsDictionary);
  FName := AValue.Values['name'].ToString;
  if (FName.StartsWith(APrefix)) then
    FName := FName.Substring(APrefix.Length)
  else if (APrefix.EndsWith('Private_')) then
  begin
    var Prefix := APrefix.Substring(0, APrefix.Length - 8);
    if (FName.StartsWith(Prefix)) then
      FName := FName.Substring(Prefix.Length)
  end;

  if (FName.StartsWith('_')) then
    FName := FName.Substring(1);

  FStringValue := AValue.Values['value'].ToString;
  FCalculatedValue := AValue.Values['calc_value'].ToInt64;
end;

procedure TEnumValue.Write(const AWriter: TSourceWriter;
  const AIsFlag: Boolean);
begin
  AWriter.Write(ToValidId(FName, True));
  AWriter.Write(' = ');
  if (AIsFlag) then
    AWriter.Write(LogTwo(FCalculatedValue).ToString)
  else
    AWriter.Write(FCalculatedValue.ToString);
end;

{ TEnum }

constructor TEnum.Create(const AElement: PJsonElement);
begin
  inherited Create;
  FValues := TObjectList<TEnumValue>.Create;

  var Prefix := AElement.Name;
  FName := Prefix;
  if (FName.EndsWith('_')) then
    SetLength(FName, FName.Length - 1);

  var Values := AElement.Value;
  Assert(Values.IsArray);
  for var I := 0 to Values.Count - 1 do
  begin
    var Value := TEnumValue.Create(Prefix, Values.Items[I]);
    FValues.Add(Value);
  end;
end;

destructor TEnum.Destroy;
begin
  FValues.Free;
  inherited;
end;

function TEnum.GetEnumValue(const AOrdValue: Int64): TEnumValue;
begin
  var NoneValue: TEnumValue := nil;
  for Result in FValues do
  begin
    if (Result.CalculatedValue = AOrdValue) then
    begin
      if (Result.Name = 'None') then
        NoneValue := Result
      else
        Exit;
    end;
  end;
  Result := NoneValue;
end;

function TEnum.GetMaxValue: Int64;
begin
  Result := 0;
  for var Value in FValues do
  begin
    if (not Value.Name.EndsWith('_')) then
      Result := Max(Result, Value.CalculatedValue);
  end;
end;

procedure TEnum.Write(const AWriter: TSourceWriter);
begin
  var Name := ToDelphiType('', FName, False);
  if {(Name = 'TImGuiCond') or} (Name.EndsWith('Flags')) or  (Name.EndsWith('FlagsPrivate')) then
  begin
    WriteSet(AWriter, Name);
    Exit;
  end;

  AWriter.StartSection('type');
  AWriter.Write(Name);
  AWriter.WriteLn(' = (');
  AWriter.Indent;
  for var I := 0 to FValues.Count - 1 do
  begin
    var Value := FValues[I];
    if (Value.Name <> 'COUNT') then
    begin
      if (I > 0) then
        AWriter.WriteLn(',');

      Value.Write(AWriter, False);
    end;
  end;
  AWriter.WriteLn(');');
  AWriter.Outdent;
  AWriter.WriteLn('P%s = ^%s;', [Name.Substring(1), Name]);
  AWriter.EndSection;
end;

procedure TEnum.WriteSet(const AWriter: TSourceWriter; const AName: String);
begin
  var Customization := TDelphiCustomizations.Instance.EnumFlags.Get(AName);
  AWriter.StartSection('type');

  var IsTextFlags := (AName = 'TImGuiInputTextFlags');

  { If AName = 'TImDrawFlags', then set BaseName to 'TImDrawFlag',
    If AName = 'TImGuiButtonFlagsPrivate', then set BaseName to 'TImGuiButtonFlagPrivate' }
  var BaseName: String;
{  if (AName = 'TImGuiCond') then
    BaseName := 'TImGuiCondition'
  else} if (AName.EndsWith('Flags')) then
    BaseName := AName.Substring(0, AName.Length - 1)
  else
  begin
    Assert(AName.EndsWith('FlagsPrivate'));
    BaseName := AName.Remove(AName.Length - 8, 1);
  end;
  AWriter.Write(BaseName);
  AWriter.WriteLn(' = (');
  AWriter.Indent;

  { Write all flag values }
  var All: TArray<String> := nil;
  var First := True;
  var HasFlagCombinations := False;
  var MaxValue: Int64 := 0;
  for var Value in FValues do
  begin
    if (Value.Name.EndsWith('_')) then
      Continue;

    if (IsTextFlags) and (Value.Name.StartsWith('Callback')) then
      { We don't currently support text callbacks since we already implement
        a callback manually. }
      Continue;

    if IsPowerOfTwo(Value.CalculatedValue) then
    begin
      { This is a single flag }
      if (not First) then
        AWriter.WriteLn(',');
      First := False;

      Value.Write(AWriter, True);
      MaxValue := Max(MaxValue, LogTwo(Value.CalculatedValue));
      All := All + [Value.Name];
    end
    else
      { This is a combination of flags }
      HasFlagCombinations := True;
  end;

  if (MaxValue < 24) then
  begin
    { Even with MINENUMSIZE 4, sets are not guaranteed to be at least 4 bytes
      in size. So we need to add a dummy value to make sure it is. }
    if (not First) then
      AWriter.WriteLn(',');

    AWriter.Write('_ = 31');
  end;

  AWriter.WriteLn(');');
  AWriter.Outdent;

  AWriter.WriteLn('%s = set of %s;', [AName, BaseName]);

  if (HasFlagCombinations) then
  begin
    AWriter.WriteLn;
    AWriter.WriteLn('_%sHelper = record helper for %0:s', [AName]);
    AWriter.WriteLn('public const');
    AWriter.Indent;

    for var Value in FValues do
    begin
      if (not IsPowerOfTwo(Value.CalculatedValue)) and (not Value.Name.EndsWith('_')) then
      begin
        { This a combination of flags }
        var Replacement := '';
        if Assigned(Customization) and Customization.Get(Value.Name, Replacement) then
        begin
          { This is a Delphi customization }
          if (Replacement <> '') then
          begin
            AWriter.Write(Value.Name);
            AWriter.Write(' = ');
            AWriter.Write(Replacement);
            AWriter.WriteLn(';');
          end;
        end
        else
        begin
          { Default handling }
          AWriter.Write(Value.Name);
          AWriter.Write(' = ');

          if {(Value.Name.EndsWith('None')) and} (Value.CalculatedValue = 0) then
            AWriter.WriteLn('[];')
          else if (Value.Name.EndsWith('All')) and (Value.CalculatedValue > 0) and (All <> nil) then
          begin
            AWriter.Write('[');
            for var I := 0 to Length(All) - 1 do
            begin
              if (I > 0) then
                AWriter.Write(', ');

              AWriter.Write(BaseName);
              AWriter.Write('.');
              AWriter.Write(All[I]);
            end;
            AWriter.WriteLn('];');
          end
          else
          begin
            AWriter.Write('[');
            var Names := Value.StringValue.Split(['|']);
            for var I := 0 to Length(Names) - 1 do
            begin
              if (I > 0) then
                AWriter.Write(', ');

              var Name := Names[I].Trim;
              var J := Name.IndexOf('_');
              if (J > 0) then
                Name := Name.Substring(J + 1);

              AWriter.Write(BaseName);
              AWriter.Write('.');
              AWriter.Write(Name);
            end;
            AWriter.WriteLn('];');
          end;
        end;
      end;
    end;

    AWriter.Outdent;
    AWriter.WriteLn('end;');
  end;

  AWriter.EndSection;
end;

{ TEnums }

constructor TEnums.Create;
begin
  inherited;
  Assert(FInstance = nil);
  FInstance := Self;

  FEnums := TObjectList<TEnum>.Create;
  FEnumsByName := TDictionary<String, TEnum>.Create;
end;

destructor TEnums.Destroy;
begin
  Assert(FInstance = Self);
  FInstance := nil;

  FEnumsByName.Free;
  FEnums.Free;
  inherited;
end;

function TEnums.GetEnumByName(const AName: String): TEnum;
begin
  FEnumsByName.TryGetValue(AName, Result);
end;

procedure TEnums.Load(const AValue: TJsonValue);
begin
  Assert(AValue.IsDictionary);
  FEnums.Clear;

  for var I := 0 to AValue.Count - 1 do
  begin
    var Enum := TEnum.Create(AValue.Elements[I]);
    FEnums.Add(Enum);
    FEnumsByName.Add(Enum.Name, Enum);
  end;
end;

procedure TEnums.Write(const AWriter: TSourceWriter);
begin
  for var Enum in FEnums do
    Enum.Write(AWriter);
end;

end.

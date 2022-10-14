unit Structs;

interface

uses
  Neslib.Json,
  Neslib.Collections,
  DelphiCustomizations,
  SourceWriter;

type
  { A member in a C TStruct }
  TMember = class
  {$REGION 'Internal Declarations'}
  private
    FName: String;
    FTypeName: String;
    FTemplateTypeName: String;
    FArrayLength: Integer;
    FBitFieldWidth: Integer;
    FIgnore: Boolean;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AValue: TJsonValue);
    constructor CreateIgnoreable(const ATypeName: String);

    procedure Write(const AWriter: TSourceWriter;
      const ACustomization: TCustomization);

    { The name of the member }
    property Name: String read FName;

    { The C name of the type of the member (can include '*' for pointer
      types). }
    property TypeName: String read FTypeName;

    { If the type is a template argument, then this is the name of the type
      argument. For example, if TypeName = 'ImVector_ImDrawCmd', then
      TemplateTypeName = 'ImDrawCmd'. }
    property TemplateTypeName: String read FTemplateTypeName;

    { If the member is an array, this returns the number of elements in the
      array, otherwise 0 }
    property ArrayLength: Integer read FArrayLength;

    { If the member is a bit field, returns the bit field width, otherwise 0 }
    property BitFieldWidth: Integer read FBitFieldWidth;
  end;

type
  { A single C struct definition }
  TStruct = class
  {$REGION 'Internal Declarations'}
  private
    FMembers: TObjectList<TMember>;
    FName: String;
    FDelphiName: String;
    FIsInternal: Boolean;
  private
    procedure AddIgnorableMemberTypes(const ATypeNames: array of String);
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create; overload;
    constructor Create(const AElement: PJsonElement); overload;
    destructor Destroy; override;

    procedure WriteForwardDeclarations(const AWriter: TSourceWriter);
    procedure WriteInterface(const AWriter: TSourceWriter);
    procedure WriteImplementation(const AWriter: TSourceWriter);
    procedure WriteSizeAssertion(const AWriter: TSourceWriter);

    { The C name of the struct }
    property Name: String read FName;

    { The Delphi name of the struct }
    property DelphiName: String read FDelphiName;

    property IsInternal: Boolean read FIsInternal write FIsInternal;
  end;

type
  { Represents the "structs" node in the "structs_and_enums.json" file }
  TStructs = class
  {$REGION 'Internal Declarations'}
  private
    FStructs: TList<TStruct>;
    FStructsByName: TDictionary<String, TStruct>;
  private
    procedure ClearStructs;
    procedure Reorder(const ASource: TList<TStruct>);
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load(const AValue: TJsonValue);

    function GetStructByName(const AName: String): TStruct;

    procedure WriteForwardDeclarations(const AWriter: TSourceWriter);
    procedure WriteInterfaces(const AWriter: TSourceWriter);
    procedure WriteImGuiInterface(const AWriter: TSourceWriter);
    procedure WriteImplementations(const AWriter: TSourceWriter);
  end;

implementation

uses
  System.SysUtils,
  Definitions,
  Common;

{ TMember }

constructor TMember.Create(const AValue: TJsonValue);
begin
  inherited Create;
  FName := AValue.Values['name'].ToString;
  FTypeName := AValue.Values['type'].ToString;
  FTemplateTypeName := AValue.Values['template_type'].ToString;
  FArrayLength := AValue.Values['size'].ToInteger;
  FBitFieldWidth := AValue.Values['bitfield'].ToInteger;
end;

constructor TMember.CreateIgnoreable(const ATypeName: String);
begin
  inherited Create;
  FTypeName := ATypeName;
  FIgnore := True;
end;

procedure TMember.Write(const AWriter: TSourceWriter;
  const ACustomization: TCustomization);

  function WriteCustomization(const AName: String): Boolean;
  begin
    var Value: String;
    if (ACustomization <> nil) and (ACustomization.Get(AName, Value)) then
    begin
      if (not (Value.EndsWith(';'))) then
        Value := Value + ';';

      if (AName = '') then
        AWriter.WriteLn('Value: %s', [Value])
      else
        AWriter.WriteLn('%s: %s', [AName, Value]);
      Result := True;
    end
    else
      Result := False;
  end;

begin
  if (FIgnore) then
    Exit;

  var Name: String;
  if (FArrayLength = 0) then
  begin
    Name := ToValidId(FName, True);
    if WriteCustomization(Name) then
      Exit;

    AWriter.WriteLn('%s: %s;', [Name, ToDelphiType(Name, FTypeName, False, FTemplateTypeName)]);
  end
  else
  begin
    Name := FName;
    var I := Name.IndexOf('[');
    if (I > 0) then
      SetLength(Name, I);

    Name := ToValidId(Name, True);
    if WriteCustomization(Name) then
      Exit;

    AWriter.WriteLn('%s: array [0..%d] of %s;', [Name, FArrayLength - 1,
      ToDelphiType(Name, FTypeName, False, FTemplateTypeName)]);
  end;
end;

{ TStruct }

procedure TStruct.AddIgnorableMemberTypes(const ATypeNames: array of String);
begin
  for var Typename in ATypeNames do
  begin
    var Member := TMember.CreateIgnoreable(Typename);
    FMembers.Add(Member);
  end;
end;

constructor TStruct.Create(const AElement: PJsonElement);
begin
  inherited Create;
  FMembers := TObjectList<TMember>.Create;
  FName := AElement.Name;
  if (FName = '') then
    FDelphiName := 'ImGui'
  else
    FDelphiName := 'T' + ToValidId(FName, False);

  var Members := AElement.Value;
  Assert(Members.IsArray);
  for var I := 0 to Members.Count - 1 do
  begin
    var Member := TMember.Create(Members.Items[I]);
    FMembers.Add(Member);
  end;

  if (FDelphiName = 'TImGuiInputEvent') then
  begin
    { The DelphiCustomizations.json file adds some field types that we need
      for proper reordering.
      TODO : Add this functionality to the json file. }
    AddIgnorableMemberTypes(['ImGuiInputEventMousePos',
      'ImGuiInputEventMouseWheel', 'ImGuiInputEventMouseButton',
      'ImGuiInputEventMouseViewport', 'ImGuiInputEventKey',
      'ImGuiInputEventText', 'ImGuiInputEventAppFocused']);
  end;
end;

constructor TStruct.Create;
begin
  inherited;
  { This is the global ImGui namespace }
  FDelphiName := 'ImGui';
end;

destructor TStruct.Destroy;
begin
  FMembers.Free;
  inherited;
end;

procedure TStruct.WriteForwardDeclarations(const AWriter: TSourceWriter);
begin
  if (not FIsInternal) and (FName <> '') then
  begin
    AWriter.WriteLn('P%s = ^T%0:s;', [FName]);
    AWriter.WriteLn('PP%s = ^P%0:s;', [FName]);
  end;
end;

procedure TStruct.WriteImplementation(const AWriter: TSourceWriter);
begin
  if (FIsInternal) then
    Exit;

  var Functions := TDefinitions.Instance.GetFunctionsForStruct(FName);
  if (Functions <> nil) and (Functions.Count > 0) then
  begin
    AWriter.WriteLn;
    AWriter.WriteLn('{ %s }', [FDelphiName]);

    { Write constructor and destructor first, followed by others }
    for var Func in Functions do
    begin
      if (Func.IsConstructor) then
        Func.Write(AWriter, True);
    end;

    for var Func in Functions do
    begin
      if (Func.IsDestructor or Func.IsDeleter) then
        Func.Write(AWriter, True);
    end;

    for var Func in Functions do
    begin
      if (not (Func.IsConstructor or Func.IsDestructor or Func.IsDeleter)) then
        Func.Write(AWriter, True);
    end;
  end;
end;

procedure TStruct.WriteInterface(const AWriter: TSourceWriter);
begin
  if (FIsInternal) then
    Exit;

  var Customization := TDelphiCustomizations.Instance.StructMembers.Get(FDelphiName);

  AWriter.WriteLn;
  AWriter.WriteLn('%s = record', [FDelphiName]);

  if (FName <> '') and (FMembers.Count > 0) then
  begin
    AWriter.WriteLn('public');
    AWriter.Indent;
    for var Member in FMembers do
      Member.Write(AWriter, Customization);
    AWriter.Outdent;
  end;

  var Functions := TDefinitions.Instance.GetFunctionsForStruct(FName);
  if (Functions <> nil) and (Functions.Count > 0) then
  begin
    AWriter.WriteLn('public');
    AWriter.Indent;

    { Write constructor and destructor first, followed by others }
    for var Func in Functions do
    begin
      Func.DelphiStructName := FDelphiName;

      if (Func.IsConstructor) then
        Func.Write(AWriter, False);
    end;

    for var Func in Functions do
    begin
      if (Func.IsDestructor or Func.IsDeleter) then
        Func.Write(AWriter, False);
    end;

    for var Func in Functions do
    begin
      if (not (Func.IsConstructor or Func.IsDestructor or Func.IsDeleter)) then
        Func.Write(AWriter, False);
    end;

    AWriter.Outdent;
  end;
  AWriter.WriteLn('end;');
end;

procedure TStruct.WriteSizeAssertion(const AWriter: TSourceWriter);
begin
  if (not FIsInternal) and (FName <> '') then
    AWriter.WriteLn('Assert(SizeOf(%s) = SizeOf(_%s));', [FDelphiName, FName]);
end;

{ TStructs }

procedure TStructs.ClearStructs;
begin
  for var Struct in FStructs do
    Struct.Free;
  FStructs.Clear;
  FStructsByName.Clear;
end;

constructor TStructs.Create;
begin
  inherited;
  FStructs := TList<TStruct>.Create;
  FStructsByName := TDictionary<String, TStruct>.Create;
end;

destructor TStructs.Destroy;
begin
  ClearStructs;
  FStructsByName.Free;
  FStructs.Free;
  inherited;
end;

function TStructs.GetStructByName(const AName: String): TStruct;
begin
  FStructsByName.TryGetValue(AName, Result);
end;

procedure TStructs.Load(const AValue: TJsonValue);
begin
  Assert(AValue.IsDictionary);
  ClearStructs;

  var Structs := TList<TStruct>.Create;
  try
    for var I := 0 to AValue.Count - 1 do
    begin
      var Struct := TStruct.Create(AValue.Elements[I]);
      if (Struct.Name = 'ImColor') or (Struct.Name = 'ImVec2') or (Struct.Name = 'ImVec4') then
        { Handled specifically }
        Struct.Free
      else
        Structs.Add(Struct);
    end;

    Reorder(Structs);
  finally
    Structs.Free;
  end;

  { Add global ImGui namespace }
  var Struct := TStruct.Create;
  FStructs.Add(Struct);

  for Struct in FStructs do
    FStructsByName.Add(Struct.FName, Struct);
end;

procedure TStructs.Reorder(const ASource: TList<TStruct>);
{ Reorder structs based on their inner dependencies }

  function FindStruct(const ATypeName: String): Integer;
  begin
    for var I := 0 to FStructs.Count - 1 do
    begin
      if (FStructs[I].Name = ATypeName) then
        Exit(I);
    end;
    Result := -1;
  end;

  procedure AnalyzeType(const ASrcIndex: Integer; const ATypeName: String);
  begin
    var TypeName := ATypeName;
    { Remove any qualifiers (like "const") }
    var I := TypeName.LastIndexOf(' ');
    if (I > 0) then
      TypeName := TypeName.Substring(I + 1);

    var DstIndex := FindStruct(TypeName);
    if (DstIndex > ASrcIndex) then
    begin
      var Dst := FStructs[DstIndex];
      FStructs.Delete(DstIndex);
      FStructs.Insert(ASrcIndex, Dst);
    end;
  end;

  procedure AnalyzeStruct(const ASrc: TStruct);
  begin
    var Funcs := TDefinitions.Instance.GetFunctionsForStruct(ASrc.Name);
    if (Funcs = nil) and (ASrc.FMembers.Count = 0) then
      Exit;

    var SrcIndex := FindStruct(ASrc.Name);
    Assert(SrcIndex >= 0);

    for var Member in ASrc.FMembers do
    begin
      var TypeName := Member.TypeName;
      if (TypeName.StartsWith('ImVector_')) then
        TypeName := TypeName.Substring(9)
      else if (TypeName.StartsWith('ImPool_')) then
        TypeName := TypeName.Substring(7)
      else if (TypeName.StartsWith('ImSpan_')) then
        TypeName := TypeName.Substring(7);

      AnalyzeType(SrcIndex, TypeName);
    end;

    if (Funcs = nil) then
      Exit;

    for var Func in Funcs do
    begin
      for var FuncOverload in Func.Overloads do
      begin
        for var I := 0 to FuncOverload.Arguments.Count - 1 do
        begin
          var TypeName := FuncOverload.Arguments[I].TypeName;

          { For NonUTD functions, the first argument is a pointer to the
            function result. }
          if (FuncOverload.NonUDT) and (I = 0) then
          begin
            Assert(TypeName.EndsWith('*'));
            SetLength(TypeName, TypeName.Length - 1);
          end;

          AnalyzeType(SrcIndex, TypeName);
        end;

        if (FuncOverload.ReturnTypeName <> '') then
          AnalyzeType(SrcIndex, FuncOverload.ReturnTypeName);
      end;
    end;
  end;

begin
  for var Struct in ASource do
    FStructs.Add(Struct);

  for var Struct in ASource do
    AnalyzeStruct(Struct);
end;

procedure TStructs.WriteForwardDeclarations(const AWriter: TSourceWriter);
begin
  AWriter.Indent(True);

  for var Struct in FStructs do
    Struct.WriteForwardDeclarations(AWriter);

  AWriter.Outdent;
end;

procedure TStructs.WriteImGuiInterface(const AWriter: TSourceWriter);
begin
  AWriter.Indent(True);

  Assert(FStructs.Last.Name = '');
  FStructs.Last.WriteInterface(AWriter);

  AWriter.Outdent;
end;

procedure TStructs.WriteImplementations(const AWriter: TSourceWriter);
begin
  for var Struct in FStructs do
    Struct.WriteImplementation(AWriter);

  AWriter.WriteLn;
  AWriter.WriteLn('initialization');
  AWriter.Indent;
  for var Struct in FStructs do
    Struct.WriteSizeAssertion(AWriter);
end;

procedure TStructs.WriteInterfaces(const AWriter: TSourceWriter);
begin
  AWriter.Indent(True);

  { Skip last struct (the ImGui namespace) }
  for var I := 0 to FStructs.Count - 2 do
    FStructs[I].WriteInterface(AWriter);

  AWriter.Outdent;
end;

end.

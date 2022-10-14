unit Definitions;

interface

uses
  Neslib.Json,
  Neslib.Collections,
  SourceWriter;

type
  { An argument in a function TOverload }
  TArgument = class
  {$REGION 'Internal Declarations'}
  private
    FName: String;
    FTypeName: String;
    FDelphiTypeName: String;
    FDefaultValue: String;
    FIsOutOrVar: Boolean;
    FHasDefaultValue: Boolean;
    FHasUnsupportedDefaultValue: Boolean;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AValue: TJsonValue);

    procedure ConvertDefaultValueToDelphi;

    procedure WriteInterface(const AWriter: TSourceWriter;
      const AForImplementation: Boolean);
    procedure WriteImplementation(const AWriter: TSourceWriter);

    { The name of the argument }
    property Name: String read FName;

    { The C name of the type of the argument (can include '*' for pointer
      types). }
    property TypeName: String read FTypeName;

    { The default value of the argument (if not empty) in C format (eg. '1.0f'
      for a floating-point value of 1) }
    property DefaultValue: String read FDefaultValue;
  end;

type
  { An single overload of a TFunction }
  TFunctionOverload = class
  {$REGION 'Internal Declarations'}
  private
    FDelphiStructName: String;
    FName: String;
    FCImGuiName: String;
    FArguments: TObjectList<TArgument>;
    FReturnTypeName: String;
    FManual: Boolean;
    FIsOverloaded: Boolean;
    FIsStatic: Boolean;
    FIsVarArg: Boolean;
    FIsConstructor: Boolean;
    FIsDeleter: Boolean;
    FIsDestructor: Boolean;
    FNonUDT: Boolean;
  private
    procedure SetDefaultValue(const AElement: PJsonElement);
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const ACImgGuiName: String; const AValue: TJsonValue);
    destructor Destroy; override;

    procedure Write(const AWriter: TSourceWriter;
      const AForImplementation: Boolean);

    { The name of the cimgui API }
    property CImGuiName: String read FCImGuiName;

    { The arguments to the function }
    property Arguments: TObjectList<TArgument> read FArguments;

    { The C name of the return type (can include '*' for pointer types).
      Empty for procedures. }
    property ReturnTypeName: String read FReturnTypeName;

    { True if the function should be hand-written instead of automatically
      generated. }
    property Manual: Boolean read FManual;

    { True if this function is overloaded. }
    property IsOverloaded: Boolean read FIsOverloaded;

    { True if this is a static function. }
    property IsStatic: Boolean read FIsStatic;

    { True if the function ends with a variable number of arguments. }
    property IsVarArg: Boolean read FIsVarArg;

    { True if this is a constructor function. }
    property IsConstructor: Boolean read FIsConstructor;

    { True if this is a deleter function.
      This function just frees a heap-allocated version of the object
      (see ImColor_Destroy for an example). }
    property IsDeleter: Boolean read FIsDeleter;

    { True if this is a destructor function.
      This function both calls the underlying C++ destructor and frees the
      object on the heap (see ImDrawListSplitter_destroy for an example). }
    property IsDestructor: Boolean read FIsDestructor;

    { True if the original C++ function retured a User Defined Type (struct),
      which is not supported by all C compilers. So the C API uses the first
      argument to return the value (which must be a of pointer type).
      (See ImColor_HSV for an example). }
    property NonUDT: Boolean read FNonUDT;
  end;

type
  { A C function in the "definitions.json" file }
  TFunction = class
  {$REGION 'Internal Declarations'}
  private
    FStructName: String;
    FDelphiStructName: String;
    FName: String;
    FOverloads: TObjectList<TFunctionOverload>;
    FIsInternal: Boolean;
    function GetIsConstructor: Boolean;
    function GetIsDestructor: Boolean;
    function GetIsDeleter: Boolean;
    procedure SetDelphiStructName(const AValue: String);
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const ACImgGuiName: String; const AValue: TJsonValue);
    destructor Destroy; override;

    procedure Write(const AWriter: TSourceWriter;
      const AForImplementation: Boolean);

    { The name of the C++ struct this function belongs to, or '' for the
      top-level ImGui namespace }
    property StructName: String read FStructName;

    { The name of the struct as used by Delphi }
    property DelphiStructName: String read FDelphiStructName write SetDelphiStructName;

    { The original name of the function in the C++ struct (or top-level ImGui
      namespace }
    property Name: String read FName;

    { The overloads of this function. If the list contains just a single item,
      then there are no additional overloads and that single item *is* the
      function. }
    property Overloads: TObjectList<TFunctionOverload> read FOverloads;

    { True if this is a constructor function. }
    property IsConstructor: Boolean read GetIsConstructor;

    { True if this is a deleter function.
      This function just frees a heap-allocated version of the object
      (see ImColor_Destroy for an example). }
    property IsDeleter: Boolean read GetIsDeleter;

    { True if this is a destructor function.
      This function both calls the underlying C++ destructor and frees the
      object on the heap (see ImDrawListSplitter_destroy for an example). }
    property IsDestructor: Boolean read GetIsDestructor;
  end;

type
  TFunctions = TList<TFunction>;

type
  { Represents the "definitions.json" file. }
  TDefinitions = class
  {$REGION 'Internal Declarations'}
  private class var
    FInstance: TDefinitions;
  private
    FFunctions: TObjectList<TFunction>;
    FFunctionsByStruct: TObjectDictionary<String, TFunctions>;
  private
    procedure LoadFunction(const AElement: PJsonElement);
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load;
    function GetFunctionsForStruct(const AStructName: String): TFunctions;

    class property Instance: TDefinitions read FInstance;
  end;

implementation

uses
  System.SysUtils,
  System.Character,
  DelphiCustomizations,
  DelphiOverloads,
  BindingGenerator,
  Common,
  Enums;

function WriteEnumCast(const AWriter: TSourceWriter; const ACType,
  ADelphiType: String): Boolean;
begin
  Result := (ADelphiType.EndsWith('Flags')){ or (ADelphiType = 'TImGuiCond')};
  if (Result) then
  begin
//    var EnumName := ADelphiType;
//    if (EnumName.EndsWith('Flags')) then
//      SetLength(EnumName, EnumName.Length - 1)
//    else
//      EnumName := 'TImGuiCondition';

//    var Enum := TEnums.Instance.GetEnumByName(ACType);
//    Assert(Assigned(Enum));
//    var MaxValue := Enum.GetMaxValue;
//    if (MaxValue < $100) then
//      AWriter.Write('Byte(')
//    else if (MaxValue < $10000) then
//      AWriter.Write('Word(')
//    else
      AWriter.Write('Cardinal(');
  end
end;

{ TArgument }

procedure TArgument.ConvertDefaultValueToDelphi;
begin
  if (not FHasDefaultValue) then
    Exit;

  var IntValue: Int64 := 0;
  if (FDelphiTypeName = 'Single') or (FDelphiTypeName = 'Double') then
  begin
    if (FDefaultValue = 'FLT_MAX') then
      FDefaultValue := 'MaxSingle'
    else if (FDefaultValue.EndsWith('f')) then
      FDefaultValue := FDefaultValue.Substring(0, FDefaultValue.Length - 1);
  end
  else if (FDelphiTypeName = 'Boolean') then
  begin
    if (FDefaultValue <> '') then
      FDefaultValue[Low(String)] := FDefaultValue[Low(String)].ToUpper;
  end
  else if (FDelphiTypeName = 'PUTF8Char') then
  begin
    { Delphi only allows nil for this. }
    FDefaultValue := 'nil';
  end
  else if (FDelphiTypeName = 'Pointer') then
  begin
    { Delphi only allows nil for this. }
    FDefaultValue := 'nil';
  end
  else if (FDelphiTypeName.Chars[0] = 'P') and (FDelphiTypeName.Length > 1)
    and (FDelphiTypeName.Chars[1].IsUpper) then
  begin
    { Assume this is a pointer type }
    FDefaultValue := 'nil';
  end
  else if (FDelphiTypeName = 'TVector2') or (FDelphiTypeName = 'TVector4') then
  begin
    { Not supported }
    FHasUnsupportedDefaultValue := True;
    FHasDefaultValue := False;
    FDefaultValue := '';
  end
  else if (FDelphiTypeName.EndsWith('Flags')) {or (FDelphiTypeName = 'TImGuiCond')} then
  begin
    if (FDefaultValue = '0') or (FDefaultValue.EndsWith('_None')) then
      FDefaultValue := '[]'
//      else if (FDefaultValue.EndsWith('_All')) then
//        FDefaultValue := FDelphiTypeName + '.All'
    else
    begin
      var EnumName := FDelphiTypeName;
      if (EnumName.EndsWith('Flags')) then
        SetLength(EnumName, EnumName.Length - 1);
//      else
//        EnumName := 'TImGuiCondition';

      var I := FDefaultValue.IndexOf('_');
      if (I > 0) then
        FDefaultValue := '[' + EnumName + '.' + FDefaultValue.Substring(I + 1) + ']'
      else if TryStrToInt64(FDefaultValue, IntValue) then
      begin
        var Enum := TEnums.Instance.GetEnumByName(FTypeName);
        Assert(Assigned(Enum));
        FDefaultValue := '';

        for var Bit := 0 to 63 do
        begin
          if ((IntValue and 1) <> 0) then
          begin
            if (FDefaultValue <> '') then
              FDefaultValue := FDefaultValue + ', ';

            var EnumVal := Enum.GetEnumValue(1 shl Bit);
            if (EnumVal = nil) then
              FDefaultValue := FDefaultValue + '?'
            else
              FDefaultValue := FDefaultValue + EnumName + '.' + ToValidId(EnumVal.Name, True);
          end;

          IntValue := IntValue shr 1;
          if (IntValue = 0) then
            Break;
        end;

        FDefaultValue := '[' + FDefaultValue + ']';
      end;
    end;
  end
  else if (FDelphiTypeName = 'Integer') or (FDelphiTypeName = 'Cardinal')
    or (FDelphiTypeName = 'Smallint') or (FDelphiTypeName = 'Word')
    or (FDelphiTypeName = 'Byte') or (FDelphiTypeName = 'Int8')
    or (FDelphiTypeName = 'Int16') or (FDelphiTypeName = 'Int32')
    or (FDelphiTypeName = 'Int64') or (FDelphiTypeName = 'UInt8')
    or (FDelphiTypeName = 'UInt16') or (FDelphiTypeName = 'UInt32')
    or (FDelphiTypeName = 'UInt64') or (FDelphiTypeName = 'NativeUInt') then
  begin
    {if (FDefaultValue = '(((ImU32)(255)<<24)|((ImU32)(255)<<16)|((ImU32)(255)<<8)|((ImU32)(255)<<0))') then
      FDefaultValue := '$FFFFFFFF'
    else} if (FDefaultValue.StartsWith('sizeof(')) then
    begin
      var I := FDefaultValue.IndexOf(')');
      Assert(I > 0);
      FDefaultValue := FDefaultValue.Substring(7, I - 7);
      FDefaultValue := 'SizeOf(' + ToDelphiType(FName, FDefaultValue, False) + ')';
    end;
  end
//    else if (FDefaultValue = '((void*)0)') then
//      FDefaultValue := 'nil'
  else if (FDelphiTypeName.StartsWith('TImGui')) and (TryStrToInt64(FDefaultValue, IntValue)) then
    FDefaultValue := FDelphiTypeName + '(' + FDefaultValue + ')'
  else if (FDefaultValue = 'NULL') then
    FDefaultValue := 'nil'
  else
  begin
    FHasUnsupportedDefaultValue := True;
    FHasDefaultValue := False;
    FDefaultValue := '';
  end;
end;

constructor TArgument.Create(const AValue: TJsonValue);
begin
  inherited Create;
  FName := AValue.Values['name'].ToString;
  FTypeName := AValue.Values['type'].ToString;

  if (FName = 'fmt') and (FTypeName.Contains('char*')) then
    FName := 'text';

  FDelphiTypeName := TDelphiCustomizations.Instance.GetDelphiType(FTypeName);
  if (FDelphiTypeName = '') then
    FDelphiTypeName := ToDelphiType(FName, FTypeName, True);

  if (FDelphiTypeName.StartsWith('*')) then
  begin
    FIsOutOrVar := True;
    FDelphiTypeName := FDelphiTypeName.Substring(1);
  end;
end;

procedure TArgument.WriteImplementation(const AWriter: TSourceWriter);
begin
  var IsTypeCast := True;
  if (FIsOutOrVar) then
  begin
    AWriter.Write('@');
    IsTypeCast := False;
  end
  else if (FDelphiTypeName = 'TVector2') then
    AWriter.Write('_ImVec2(')
  else if (FDelphiTypeName = 'TVector4') or (FDelphiTypeName = 'TRectF') or (FDelphiTypeName = 'TAlphaColorF') then
    AWriter.Write('_ImVec4(')
  else if (FDelphiTypeName = 'TImColor') then
    AWriter.Write('_ImColor(')
  else if (FDelphiTypeName = 'WideChar') then
    AWriter.Write('Word(')
  else if (FDelphiTypeName.StartsWith('P')) then
    AWriter.Write('Pointer(')
  else if (FDelphiTypeName.StartsWith('TIm')) then
  begin
    if (not WriteEnumCast(AWriter, FTypeName, FDelphiTypeName)) then
      AWriter.Write('_' + FDelphiTypeName.Substring(1) + '(');
  end
  else
    IsTypeCast := False;

  AWriter.Write(ToValidId('A' + ToPascalCase(FName), False));

  if (IsTypeCast) then
    AWriter.Write(')');
end;

procedure TArgument.WriteInterface(const AWriter: TSourceWriter;
  const AForImplementation: Boolean);
begin
  if (not FHasDefaultValue) and
    ((FDelphiTypeName = 'PInteger') or (FDelphiTypeName = 'PCardinal') or
     (FDelphiTypeName = 'PInt64') or (FDelphiTypeName = 'PUInt64') or
     (FDelphiTypeName = 'PSingle') or (FDelphiTypeName = 'PDouble') or
     (FDelphiTypeName = 'PPByte') {or (FDelphiTypeName = 'PBoolean')}) then
  begin
    FIsOutOrVar := True;
    FDelphiTypeName := FDelphiTypeName.Substring(1);
  end;

  if (FIsOutOrVar) then
  begin
    { Eg. *TImVector<WideChar>.
      Since we cannot have pointers to generic types like this, we use a
      "var" or "out" parameter instead. }
    if (FName.StartsWith('out', True)) then
      AWriter.Write('out ')
    else
      AWriter.Write('var ');
  end
  else
    AWriter.Write('const ');

  AWriter.Write(ToValidId('A' + ToPascalCase(FName), False));
  AWriter.Write(': ');

  AWriter.Write(FDelphiTypeName);

  if (not AForImplementation) and (FHasDefaultValue) then
  begin
    AWriter.Write(' = ');
    AWriter.Write(FDefaultValue);
  end;
end;

{ TFunctionOverload }

constructor TFunctionOverload.Create(const ACImgGuiName: String;
  const AValue: TJsonValue);
begin
  inherited Create;
  FArguments := TObjectList<TArgument>.Create;

  FCImGuiName := AValue.Values['ov_cimguiname'].ToString;
  if (FCImGuiName = '') then
  begin
    FCImGuiName := AValue.Values['cimguiname'].ToString;
    if (FCImGuiName = '') then
      FCImGuiName := ACImgGuiName;
  end;

  var Args := AValue.Values['argsT'];
  if (not Args.IsNull) then
  begin
    Assert(Args.IsArray);
    for var I := 0 to Args.Count - 1 do
    begin
      var Arg := TArgument.Create(Args.Items[I]);
      FArguments.Add(Arg);
    end;
  end;

  var Defaults := AValue.Values['defaults'];
  if (not Defaults.IsNull) then
  begin
    Assert(Defaults.IsDictionary);
    for var I := 0 to Defaults.Count - 1 do
      SetDefaultValue(Defaults.Elements[I]);
  end;

  FReturnTypeName := AValue.Values['ret'].ToString;
  if (FReturnTypeName = 'void') then
    FReturnTypeName := '';

  FManual := AValue.Values['manual'].ToBoolean;
  FIsStatic := AValue.Values['is_static_function'].ToBoolean;
  FIsVarArg := (AValue.Values['isvararg'].ToString <> '');
  FIsConstructor := AValue.Values['constructor'].ToBoolean;
  FIsDeleter := AValue.Values['destructor'].ToBoolean;
  FIsDestructor := AValue.Values['realdestructor'].ToBoolean;
  FNonUDT := AValue.Values['nonUDT'].ToBoolean;
end;

destructor TFunctionOverload.Destroy;
begin
  FArguments.Free;
  inherited;
end;

procedure TFunctionOverload.SetDefaultValue(const AElement: PJsonElement);
begin
  var ArgName := AElement.Name;
  for var Arg in FArguments do
  begin
    if (Arg.Name = ArgName) then
    begin
      Arg.FHasDefaultValue := True;
      Arg.FDefaultValue := AElement.Value.ToString;
      Exit;
    end;
  end;
  Assert(False, 'Argument not found');
end;

procedure TFunctionOverload.Write(const AWriter: TSourceWriter;
  const AForImplementation: Boolean);
begin
  var CustomOverloads := TDelphiOverloads.Instance.Get(FCImGuiName);

  { Skip regular version if the first custom overload (if any) starts with '*' }
  var Skip := (CustomOverloads <> nil) and (CustomOverloads[0].Intf.StartsWith('*'));

  { Skip overloads as well if custom overload is just a '*' }
  if (Skip) and (CustomOverloads[0].Intf = '*') then
    Exit;

  var DelphiReturnType := '';
  var ArgCount := 0;
  var ArgOffset := 0;

  if (not Skip) then
  begin
    if (AForImplementation) then
      AWriter.WriteLn;

    if (FIsConstructor) then
      AWriter.Write('class function ')
    else
    begin
      if (FIsStatic) then
        AWriter.Write('class ');

      if (FReturnTypeName = '') and (not FNonUDT) then
        AWriter.Write('procedure ')
      else
        AWriter.Write('function ');
    end;

    if (AForImplementation) then
    begin
      AWriter.Write(FDelphiStructName);
      AWriter.Write('.');
    end;

    if (FIsConstructor) then
      AWriter.Write('Create')
    else if (FIsDestructor or FIsDeleter) then
      AWriter.Write('Free')
    else
      AWriter.Write(ToValidId(FName, True));

    ArgCount := FArguments.Count;
    ArgOffset := 0;

    if (FNonUDT) then
    begin
      { First argument is the function result }
      Inc(ArgOffset);
      Dec(ArgCount);
    end;

    if (not FIsStatic) and (not FIsConstructor) then
    begin
      { Skip Self argument }
      Inc(ArgOffset);
      Dec(ArgCount);
    end;

    if (FIsVarArg) then
      { We treat VarArgs functions as functions without VarArgs for now.
        Skip the last "..." VarArg parameter. }
      Dec(ArgCount);

    if (ArgCount > 0) then
    begin
      if (not AForImplementation) then
      begin
        { First, update all default values to make sure they can be used in Delphi
          code. This is needed because some default values (eg. for records) are
          not valid in Delphi. In that case, any arguments that follow after it
          cannot have a default value either. }
        var HasUnsupportedDefaultValue := False;
        for var I := 0 to ArgCount - 1 do
        begin
          FArguments[ArgOffset + I].ConvertDefaultValueToDelphi;
          HasUnsupportedDefaultValue := HasUnsupportedDefaultValue or FArguments[ArgOffset + I].FHasUnsupportedDefaultValue;
        end;

        if (HasUnsupportedDefaultValue) and (CustomOverloads = nil) then
        begin
          if (not TBindingGenerator.HasWarnings) then
          begin
            WriteLn('Unsupported default values for the following C API(s):');
            TBindingGenerator.HasWarnings := True;
          end;
          WriteLn(FCImGuiName);
        end;

        { Find last argument that does not have a default value (anymore).
          All arguments before that also cannot have default values. }
        for var I := ArgCount - 1 downto 1 do
        begin
          if (not FArguments[ArgOffset + I].FHasDefaultValue) then
          begin
            for var J := 0 to I - 1 do
              FArguments[ArgOffset + J].FHasDefaultValue := False;

            Break;
          end;
        end;
      end;

      AWriter.Write('(');
      for var I := 0 to ArgCount - 1 do
      begin
        if (I > 0) then
          AWriter.Write('; ');

        var Arg := FArguments[ArgOffset + I];
        Arg.WriteInterface(AWriter, AForImplementation);
      end;
      AWriter.Write(')');
    end;

    var IsOverloaded := FIsOverloaded or (CustomOverloads <> nil);
    if (FIsConstructor) then
    begin
      AWriter.Write(': P');
      AWriter.Write(FDelphiStructName.Substring(1));
      if (not AForImplementation) then
      begin
        if (IsOverloaded) then
        begin
          AWriter.Write('; overload');
          IsOverloaded := False;
        end;
        AWriter.Write('; static');
      end;
    end
    else if (FReturnTypeName <> '') then
    begin
      AWriter.Write(': ');
      DelphiReturnType := ToDelphiType(FName, FReturnTypeName, True);
      AWriter.Write(DelphiReturnType);
    end
    else if (FNonUDT) then
    begin
      { Convert first argument to function result.
        The first argument should be a pointer type (eg. ImVec2*), which must be
        converted to the base type. }
      AWriter.Write(': ');
      Assert(FArguments.Count > 0);
      var TypeName := FArguments[0].TypeName;
      Assert(TypeName.EndsWith('*'));
      SetLength(TypeName, TypeName.Length - 1);
      AWriter.Write(ToDelphiType(FArguments[0].Name, TypeName, True));
    end;

    if (not AForImplementation) then
    begin
      if (IsOverloaded) then
        AWriter.Write('; overload');

      if (IsStatic) then
        AWriter.Write('; static');

      AWriter.Write('; inline');
    end;
    AWriter.WriteLn(';');
  end;

  if (not AForImplementation) then
  begin
    for var CustomOverload in CustomOverloads do
    begin
      var Intf := CustomOverload.Intf;
      if (Intf.StartsWith('*')) then
        Intf := Intf.Substring(1);

      AWriter.WriteLn(Intf);
    end;

    Exit;
  end;

  if (not Skip) then
  begin
    { Write method body }
    AWriter.WriteLn('begin');
    AWriter.Write('  ');

    var IsTypeCast := False;
    if (FIsConstructor) then
    begin
      AWriter.Write('Result := P%s(', [FDelphiStructName.Substring(1)]);
      IsTypeCast := True;
    end
    else if (FReturnTypeName <> '') then
    begin
      if (WriteEnumCast(AWriter, FReturnTypeName, DelphiReturnType)) then
        AWriter.Write('Result) := ')
      else
      begin
        AWriter.Write('Result := ');
        if (DelphiReturnType.StartsWith('P')) then
        begin
          AWriter.Write('Pointer(');
          IsTypeCast := True;
        end
        else if (DelphiReturnType.StartsWith('TIm')) then
        begin
          AWriter.Write(DelphiReturnType);
          AWriter.Write('(');
          IsTypeCast := True;
        end;
      end;
    end;

    { Write C-API }
    AWriter.Write('_');
    AWriter.Write(FCImGuiName);

    { Write arguments }
    AWriter.Write('(');

    var FirstArg := True;

    if (FNonUDT) then
    begin
      { First argument is pointer to result }
      AWriter.Write('@Result');
      FirstArg := False;
    end;

    if (not FIsStatic) and (not FIsConstructor) then
    begin
      { Self argument }
      if (not FirstArg) then
        AWriter.Write(', ');

  //    AWriter.Write('@FHandle');
      AWriter.Write('@Self');
      FirstArg := False;
    end;

    { Remaining arguments }
    for var I := 0 to ArgCount - 1 do
    begin
      if (not FirstArg) then
        AWriter.Write(', ');

      var Arg := FArguments[ArgOffset + I];
      Arg.WriteImplementation(AWriter);

      FirstArg := False;
    end;

    AWriter.Write(')');

    if (IsTypeCast) then
      AWriter.Write(')');

    AWriter.WriteLn(';');
    AWriter.WriteLn('end;');
  end;

  for var CustomOverload in CustomOverloads do
  begin
    var IsFunction := False;
    var Intf := CustomOverload.Intf;
    if (Intf.StartsWith('*')) then
      Intf := Intf.Substring(1);

    var I := Intf.IndexOf('procedure ');
    if (I >= 0) then
      Inc(I, 10)
    else
    begin
      I := Intf.IndexOf('function ');
      Assert(I >= 0);
      Inc(I, 9);
      IsFunction := True;
    end;
    Intf := Intf.Insert(I, FDelphiStructName + '.');

    I := Intf.LastIndexOf(')');
    if (IsFunction) then
    begin
      I := Intf.IndexOf(';', I + 1);
      Assert(I > 0);
      SetLength(Intf, I + 1);
    end
    else
      SetLength(Intf, I + 2);

    AWriter.WriteLn;
    AWriter.WriteLn(Intf);
    AWriter.WriteLn('begin');
    AWriter.WriteLn('  ' + CustomOverload.Impl);
    AWriter.WriteLn('end;');
  end;
end;

{ TFunction }

constructor TFunction.Create(const ACImgGuiName: String;
  const AValue: TJsonValue);
begin
  inherited Create;
  FOverloads := TObjectList<TFunctionOverload>.Create;

  for var I := 0 to AValue.Count - 1 do
  begin
    var Item := AValue.Items[I];
    var FunctionOverload := TFunctionOverload.Create(ACImgGuiName, Item);
    FOverloads.Add(FunctionOverload);

    var S := Item.Values['stname'];
    Assert((FStructName = '') or (FStructName = S));
    FStructName := S;
    if (S = '') then
      { Global ImGui namespace functions are converted to static functions. }
      FunctionOverload.FIsStatic := True;

    S := Item.Values['funcname'];
    Assert((FName = '') or (FName = S));
    FunctionOverload.FName := S;
    FName := S;

    var Location := Item.Values['location'].ToString;
    FIsInternal := (Location <> '') and (not Location.StartsWith('imgui:'));
  end;

  if (FOverloads.Count > 1) then
    for var FunctionOverload in FOverloads do
      FunctionOverload.FIsOverloaded := True;
end;

destructor TFunction.Destroy;
begin
  FOverloads.Free;
  inherited;
end;

function TFunction.GetIsConstructor: Boolean;
begin
  if (FOverloads.Count > 0) then
    Result := FOverloads[0].IsConstructor
  else
    Result := False;
end;

function TFunction.GetIsDeleter: Boolean;
begin
  if (FOverloads.Count > 0) then
    Result := FOverloads[0].IsDeleter
  else
    Result := False;
end;

function TFunction.GetIsDestructor: Boolean;
begin
  if (FOverloads.Count > 0) then
    Result := FOverloads[0].IsDestructor
  else
    Result := False;
end;

procedure TFunction.SetDelphiStructName(const AValue: String);
begin
  if (AValue <> FDelphiStructName) then
  begin
    FDelphiStructName := AValue;
    for var FunctionOverload in FOverloads do
      FunctionOverload.FDelphiStructName := AValue;
  end;
end;

procedure TFunction.Write(const AWriter: TSourceWriter;
  const AForImplementation: Boolean);
begin
  if (FIsInternal) then
    Exit;

  for var FunctionOverload in FOverloads do
    FunctionOverload.Write(AWriter, AForImplementation);
end;

{ TDefinitions }

constructor TDefinitions.Create;
begin
  inherited;
  Assert(FInstance = nil);
  FInstance := Self;

  FFunctions := TObjectList<TFunction>.Create;
  FFunctionsByStruct := TObjectDictionary<String, TFunctions>.Create([doOwnsValues]);
end;

destructor TDefinitions.Destroy;
begin
  Assert(FInstance = Self);
  FInstance := nil;

  FFunctionsByStruct.Free;
  FFunctions.Free;
  inherited;
end;

function TDefinitions.GetFunctionsForStruct(
  const AStructName: String): TFunctions;
begin
  FFunctionsByStruct.TryGetValue(AStructName, Result);
end;

procedure TDefinitions.Load;
begin
  FFunctions.Clear;

  var Doc := TJsonDocument.Load('definitions.json');
  var Root := Doc.Root;
  Assert(Root.IsDictionary);

  for var I := 0 to Root.Count - 1 do
    LoadFunction(Root.Elements[I]);
end;

procedure TDefinitions.LoadFunction(const AElement: PJsonElement);
begin
  var Value := AElement.Value;
  Assert(Value.IsArray);
  if (Value.Count = 0) then
    Exit;

  var Func := TFunction.Create(AElement.Name, Value);
  FFunctions.Add(Func);

  var Funcs: TFunctions;
  if (not FFunctionsByStruct.TryGetValue(Func.StructName, Funcs)) then
  begin
    Funcs := TFunctions.Create;
    FFunctionsByStruct.Add(Func.StructName, Funcs);
  end;
  Funcs.Add(Func);
end;

end.

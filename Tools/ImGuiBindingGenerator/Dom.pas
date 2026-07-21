unit Dom;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Neslib.Json,
  SourceWriter;

type
  TDataTypeKind = (Builtin, User, Pointer, &Type, &Function, &Array);
  TBuiltinType = (Void, Char, UnsignedChar, Short, UnsignedShort, Int,
    UnsignedInt, LongLong, UnsignedLongLong, Float, Double, Bool);
  TTypeFlavor = (FunctionPointer);
  TStructKind = (Struct, Union);
  TStorageClass = (&Const);
  TStorageClasses = set of TStorageClass;
  TCondition = (IfDef, IfNDef, &If, IfNot);

type
  _TBuiltinTypeHelper = record helper for TBuiltinType
  public
    function ToDelphiType: String;
  end;


type
  TConditional = record
  public
    Condition: TCondition;
    Expression: String;
  end;

type
  TDomNode = class abstract
  {$REGION 'Internal Declarations'}
  private
    FParent: TDomNode;
    FConditionals: TArray<TConditional>;
  protected
    procedure LoadChildren(const AParent: TJsonValue);
    procedure LoadChild(const AName: String; const AValue: TJsonValue); virtual;
    procedure LoadConditionals(const AValue: TJsonValue);
    function LoadConditional(const AValue: TJsonValue): TConditional;
    function Ignore: Boolean; virtual;
    procedure Loaded; virtual;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create; overload;
    constructor Create(const AParent: TDomNode); overload;
  end;

type
  TNamedNode = class abstract(TDomNode)
  {$REGION 'Internal Declarations'}
  private
    FName: String;
    FPrecedingComments: TArray<String>;
    FAttachedComment: String;
    FIsInternal: Boolean;
    procedure LoadComments(const AValue: TJsonValue);
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
  {$ENDREGION 'Internal Declarations'}
  public
    { The name of the declaration }
    property Name: String read FName;

    { Comments which appear immediately before an element in the source code }
    property PrecedingComments: TArray<String> read FPrecedingComments;

    { Comments which appear immediately after the element (on the same line }
    property AttachedComment: String read FAttachedComment;

    property IsInternal: Boolean read FIsInternal;
  end;

type
  TListNode<T: TNamedNode, constructor> = class abstract(TDomNode)
  {$REGION 'Internal Declarations'}
  private
    FItems: TObjectList<T>;
    FItemsByName: TDictionary<String, T>;
  protected
    procedure Clear;
    procedure Load(const AArray: TJsonValue);
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AParent: TDomNode);
    destructor Destroy; override;

    function GetEnumerator: TEnumerator<T>;
  end;

type
  TDataType = class;
  TTypeDescription = class;

  TArgument = class(TNamedNode)
  {$REGION 'Internal Declarations'}
  private
    FDataType: TDataType;
    FDefaultValue: String;
    FArrayBounds: String;
    FIsArray: Boolean;
    FIsVarArgs: Boolean;
    FIsInstancePointer: Boolean;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    function IsSimple: Boolean;
    function IsTypeCompatibleWith(const AOther: TArgument): Boolean;

    { The argument type }
    property DataType: TDataType read FDataType;

    { The default value, if present }
    property DefaultValue: String read FDefaultValue;

    { Array bounds, if this is an array argument }
    property ArrayBounds: String read FArrayBounds;

    { Is this an array argument? }
    property IsArray: Boolean read FIsArray;

    { Is this a varargs argument? }
    property IsVarArgs: Boolean read FIsVarArgs;

    { Is this the instance pointer? (i.e. the 'this' pointer for a class function) }
    property IsInstancePointer: Boolean read FIsInstancePointer;
  end;

  TArguments = class(TListNode<TArgument>)
  {$REGION 'Internal Declarations'}
  private
    FIsVarArgs: Boolean;
  protected
    procedure WriteCApi(const AWriter: TSourceWriter);
  {$ENDREGION 'Internal Declarations'}
  public
    property IsVarArgs: Boolean read FIsVarArgs;
  end;

  TTypeDetails = class(TDomNode)
  {$REGION 'Internal Declarations'}
  private
    FReturnType: TDataType;
    FArguments: TArguments;
    FFlavor: TTypeFlavor;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
  {$ENDREGION 'Internal Declarations'}
  public
    destructor Destroy; override;

    { The "flavour" (variant) of the type for which the details are supplied }
    property Flavor: TTypeFlavor read FFlavor;

    { Optional. For Flavor=TTypeFlavor.FunctionPointer.
      The function return type }
    property ReturnType: TDataType read FReturnType;

    { Optional. For Flavor=TTypeFlavor.FunctionPointer.
      A list of function arguments (see "function arguments") }
    property Arguments: TArguments read FArguments;
  end;

  TParameter = class(TNamedNode)
  {$REGION 'Internal Declarations'}
  private
    FDataType: TTypeDescription;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    function IsTypeCompatibleWith(const AOther: TParameter): Boolean;

    property DataType: TTypeDescription read FDataType;
  end;

  TParameters = class(TListNode<TParameter>)
  public
    procedure WriteCApi(const AWriter: TSourceWriter);
  end;

  { Type descriptions (or "type comprehensions" as they are sometimes referred
    to in the Dear Bindings code) provide an alternative mechanism for binding
    tools to understand the nature of a C type. Dear Bindings parses the C type
    data and constructs a tree representing those elements. For binding to
    languages that cannot easily consume C-like declaration syntax this is
    likely an easier starting point than the raw textual 'declaration' field. }
  TTypeDescription = class(TDomNode)
  {$REGION 'Internal Declarations'}
  private
    FName: String;
    FBounds: String;
    FInnerType: TTypeDescription;
    FReturnType: TTypeDescription;
    FParameters: TParameters;
    FBuiltinType: TBuiltinType;
    FKind: TDataTypeKind;
    FStorageClasses: TStorageClasses;
    FIsNullable: Boolean;
    FIsReference: Boolean;
    function GetIsVoid: Boolean; inline;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
    procedure LoadStorageClasses(const AValue: TJsonValue);
    procedure WriteCApi(const AWriter: TSourceWriter);
  {$ENDREGION 'Internal Declarations'}
  public
    destructor Destroy; override;

    function IsCompatibleWith(const AOther: TTypeDescription): Boolean;

    property Kind: TDataTypeKind read FKind;

    { For Kind=TDataTypeKind.Builtin }
    property BuiltinType: TBuiltinType read FBuiltinType;

    { For Kind=TDataTypeKind.User/Pointer }
    property Name: String read FName;

    { For Kind=TDataTypeKind.Array }
    property Bounds: String read FBounds;

    { For Kind=TDataTypeKind.Pointer }
    property IsNullable: Boolean read FIsNullable;

    { For Kind=TDataTypeKind.Pointer }
    property IsReference: Boolean read FIsReference;

    { Optional. For Kind=TDataTypeKind.Pointer/Type }
    property InnerType: TTypeDescription read FInnerType;

    { Optional. For Kind=TDataTypeKind.Function }
    property ReturnType: TTypeDescription read FReturnType;

    { Optional. For Kind=TDataTypeKind.Function }
    property Parameters: TParameters read FParameters;

    { For arguments }
    property StorageClasses: TStorageClasses read FStorageClasses;

    property IsVoid: Boolean read GetIsVoid;
  end;

  TDataType = class(TDomNode)
  {$REGION 'Internal Declarations'}
  private
    FDeclaration: String;
    FDescription: TTypeDescription;
    FDetails: TTypeDetails;
    function GetIsVoid: Boolean; inline;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
    procedure WriteCApi(const AWriter: TSourceWriter);
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AParent: TDomNode);
    destructor Destroy; override;

    function IsCompatibleWith(const AOther: TDataType): Boolean;

    { The C-style declaration of the type }
    property Declaration: String read FDeclaration;

    { Description of the type in machine-readable terms }
    property Description: TTypeDescription read FDescription;

    { Optional. For Kind=TDataTypeKind.&Type
      Parsed details of the type (where applicable) }
    property Details: TTypeDetails read FDetails;

    property IsVoid: Boolean read GetIsVoid;
  end;

type
  { Represent a single define in the root "defines" node. }
  TDefine = class(TNamedNode)
  {$REGION 'Internal Declarations'}
  private
    FContent: String;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
    function Ignore: Boolean; override;
  {$ENDREGION 'Internal Declarations'}
  public
    { The textual content of the define }
    property Content: String read FContent;
  end;

type
  { Represents the root "defines" node. }
  TDefines = class(TListNode<TDefine>)
  end;

type
  { Represent a single enum element in the "elements" node of an enum. }
  TEnumElement = class(TNamedNode)
  {$REGION 'Internal Declarations'}
  private
    FValueExpression: String;
    FValue: Int64;
    FIsCount: Boolean;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
  {$ENDREGION 'Internal Declarations'}
  public
    { The value of the element as it originally appeared in the source.
      May not be present in the case where an enum element uses an implicit
      value (i.e. enum auto-numbering) }
    property ValueExpression: String read FValueExpression;

    { The calculated value of the element as an integer.
      Always present, even if ValueExpression = '' }
    property Value: Int64 read FValue;

    { Indicates that the value is used to store the count of items in the enum.
      Is used in cases where an enum has a final element that is used to store
      the count of items in that enum (for array sizing and similar). In some
      languages it may make sense not to expose these to the user if there are
      other more appropriate idiomatic methods to determine this. }
    property IsCount: Boolean read FIsCount;
  end;

type
  { Represents the "elements" node in an enum. }
  TEnumElements = class(TListNode<TEnumElement>)
  end;

type
  { Represent a single enum in the root "enums" node. }
  TEnum = class(TNamedNode)
  {$REGION 'Internal Declarations'}
  private
    FElements: TEnumElements;
    FStorageType: TDataType;
    FOriginalFullyQualifiedName: String;
    FIsFlags: Boolean;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    procedure WriteCountConst(const AWriter: TSourceWriter);
    procedure WriteCApi(const AWriter: TSourceWriter);

    { List of elements }
    property Elements: TEnumElements read FElements;

    { The name of the enum as it appeared in the original C++ API }
    property OriginalFullyQualifiedName: String read FOriginalFullyQualifiedName;

    { Is this enum a bitfield composed of multiple flags? }
    property IsFlags: Boolean read FIsFlags;

    { The storage type of the enum (if specified) }
    property StorageType: TDataType read FStorageType;
  end;

type
  { Represents the root "enums" node. }
  TEnums = class(TListNode<TEnum>)
  end;

type
  { Represent a single typedef in the root "typedefs" node. }
  TTypedef = class(TNamedNode)
  {$REGION 'Internal Declarations'}
  private
    FDataType: TDataType;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    procedure WriteCApi(const AWriter: TSourceWriter);

    { The defined type (as a generic type element) }
    property DataType: TDataType read FDataType;
  end;

type
  { Represents the root "typedefs" node. }
  TTypedefs = class(TListNode<TTypedef>)
  end;

type
  TField = class(TNamedNode)
  {$REGION 'Internal Declarations'}
  private
    FFieldType: TDataType;
    FArrayBounds: String;
    FWidth: Integer;
    FIsArray: Boolean;
    FIsAnonymous: Boolean;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
    procedure WriteCApi(const AWriter: TSourceWriter);
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    { Is this field declared as an array? }
    property IsArray: Boolean read FIsArray;

    { Is this field anonymous? }
    property IsAnonymous: Boolean read FIsAnonymous;

    { The type of the field }
    property FieldType: TDataType read FFieldType;

    { The array bounds, if the field is an array }
    property ArrayBounds: String read FArrayBounds;

    { If >0, this is a bitfield with a width of this value }
    property Width: Integer read FWidth;
  end;

type
  TFields = class(TListNode<TField>)
  end;

type
  { Represent a single struct in the root "structs" node. }
  TStruct = class(TNamedNode)
  {$REGION 'Internal Declarations'}
  private
    FFields: TFields;
    FOriginalFullyQualifiedName: String;
    FKind: TStructKind;
    FByValue: Boolean;
    FForwardDeclaration: Boolean;
    FIsAnonymous: Boolean;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    procedure WriteCApi(const AWriter: TSourceWriter);

    { List of contained fields }
    property Fields: TFields read FFields;

    { The original C++ name of the structure }
    property OriginalFullyQualifiedName: String read FOriginalFullyQualifiedName;

    { The type of the structure (either `struct` or `union`) }
    property Kind: TStructKind read FKind;

    { Is this structure normally pass-by-value? }
    property ByValue: Boolean read FByValue;

    { Is this a forward-declaration of the structure? }
    property ForwardDeclaration: Boolean read FForwardDeclaration;

    { Is this an anonymous struct? }
    property IsAnonymous: Boolean read FIsAnonymous;
  end;

type
  { Represents the root "structs" node. }
  TStructs = class(TListNode<TStruct>)
  {$REGION 'Internal Declarations'}
  private
    procedure Reorder(const ASource: TArray<TStruct>);
  protected
    procedure Loaded; override;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { Represent a single function in the root "functions" node. }
  TFunction = class(TNamedNode)
  {$REGION 'Internal Declarations'}
  private
    FOriginalFullyQualifiedName: String;
    FOriginalClass: String;
    FReturnType: TDataType;
    FArguments: TArguments;
    FIsDefaultArgumentHelper: Boolean;
    FIsManualHelper: Boolean;
    FIsImStrHelper: Boolean;
    FHasImStrHelper: Boolean;
    FIsUnformattedHelper: Boolean;
    FIsStatic: Boolean;
    function GetHasReturnType: Boolean; inline;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
    procedure Loaded; override;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    procedure WriteCApi(const AWriter: TSourceWriter);

    { The original C++ name of the function }
    property OriginalFullyQualifiedName: String read FOriginalFullyQualifiedName;

    { The name of the class this method originally belonged to, if any }
    property OriginalClass: String read FOriginalClass;

    { The return type of the function }
    property ReturnType: TDataType read FReturnType;

    { Whether the function has a non-void return type }
    property HasReturnType: Boolean read GetHasReturnType;

    { A list of the function arguments }
    property Arguments: TArguments read FArguments;

    { Is this function a variant generated to simulate default arguments? }
    property IsDefaultArgumentHelper: Boolean read FIsDefaultArgumentHelper;

    { Is this a manually added function that doesn't exist in the original C++
      API but was added specially to the C API? (at present only
      `ImVector_Construct` and `ImVector_Destruct`) }
    property IsManualHelper: Boolean read FIsManualHelper;

    { Is this function a helper variant added that takes `const char*` instead
      of `ImStr` arguments? }
    property IsImStrHelper: Boolean read FIsImStrHelper;

    { Is this function one which takes `ImStr` arguments and has had a
      `const char*` helper variant generated? }
    property HasImStrHelper: Boolean read FHasImStrHelper;

    { Is this function a helper variant of a format string accepting function
      that accepts an pre-formatted string instead }
    property IsUnformattedHelper: Boolean read FIsUnformattedHelper;

    { Was this function originally static? }
    property IsStatic: Boolean read FIsStatic;
  end;

type
  { Represents the root "functions" node. }
  TFunctions = class(TListNode<TFunction>)
  end;

type
  { Represents the "dcimgui.json" file. }
  TDom = class(TDomNode)
  {$REGION 'Internal Declarations'}
  private
    FDefines: TDefines;
    FEnums: TEnums;
    FTypedefs: TTypedefs;
    FStructs: TStructs;
    FFunctions: TFunctions;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load;

    property Defines: TDefines read FDefines;
    property Enums: TEnums read FEnums;
    property Typedefs: TTypedefs read FTypedefs;
    property Structs: TStructs read FStructs;
    property Functions: TFunctions read FFunctions;
  end;

implementation

{ _TBuiltinTypeHelper }

function _TBuiltinTypeHelper.ToDelphiType: String;
const
  STRINGS: array [TBuiltinType] of String = (
    '<void>', 'UTF8Char', 'UInt8', 'Int16', 'UInt16', 'Int32', 'UInt32',
    'Int64', 'UInt64', 'Single', 'Double', 'Boolean');
begin
  Result := STRINGS[Self];
end;

{ TDomNode }

constructor TDomNode.Create(const AParent: TDomNode);
begin
  inherited Create;
  FParent := AParent;
end;

function TDomNode.Ignore: Boolean;
begin
  { Ignore declarations that depend on certain defines that ImGui for Sokol does
    not have set) }
  for var C in FConditionals do
  begin
    if (C.Condition = TCondition.IfDef) then
    begin
      if (C.Expression = 'IMGUI_USE_WCHAR32') or
         (C.Expression = 'IMGUI_USE_BGRA_PACKED_COLOR')
      then
        Exit(True);
    end
    else if (C.Condition = TCondition.IfNDef) then
    begin
      if (C.Expression = 'IMGUI_DISABLE_OBSOLETE_FUNCTIONS') then
        Exit(True);
    end;
  end;
  Result := False;
end;

constructor TDomNode.Create;
begin
  inherited;
end;

procedure TDomNode.LoadChild(const AName: String; const AValue: TJsonValue);
begin
  if (AName = 'conditionals') then
    LoadConditionals(AValue)
  else
    Assert(False, Format('Unsupported JSON key: "%s"', [AName]));
end;

procedure TDomNode.LoadChildren(const AParent: TJsonValue);
begin
  Assert(AParent.IsDictionary);
  for var I := 0 to AParent.Count - 1 do
  begin
    var E := AParent.Elements[I];
    LoadChild(E.Name, E.Value);
  end;
end;

function TDomNode.LoadConditional(const AValue: TJsonValue): TConditional;
begin
  Assert(AValue.IsDictionary);
  for var I := 0 to AValue.Count - 1 do
  begin
    var E := AValue.Elements[I];
    var S := E.Value.ToString;

    if (E.Name = 'condition') then
    begin
      if (S = 'ifdef') then
        Result.Condition := TCondition.IfDef
      else if (S = 'ifndef') then
        Result.Condition := TCondition.IfNDef
      else if (S = 'if') then
        Result.Condition := TCondition.&If
      else if (S = 'ifnot') then
        Result.Condition := TCondition.IfNot
      else
        Assert(False, 'Invalid condition: ' + S);
    end
    else if (E.Name = 'expression') then
      Result.Expression := S
    else
      Assert(False, Format('Unsupported JSON key: "%s" in "conditionals" node', [E.Name]));
  end;
end;

procedure TDomNode.LoadConditionals(const AValue: TJsonValue);
begin
  Assert(AValue.IsArray);
  SetLength(FConditionals, AValue.Count);
  for var I := 0 to AValue.Count - 1 do
    FConditionals[I] := LoadConditional(AValue[I]);
end;

procedure TDomNode.Loaded;
begin
  { No default implementation }
end;

{ TNamedNode }

procedure TNamedNode.LoadChild(const AName: String; const AValue: TJsonValue);
begin
  if (AName = 'name') then
    FName := AValue.ToString
  else if (AName = 'is_internal') then
    FIsInternal := AValue.ToBoolean
  else if (AName = 'comments') then
    LoadComments(AValue)
  else if (AName <> 'source_location') then
    inherited;
end;

procedure TNamedNode.LoadComments(const AValue: TJsonValue);
begin
  Assert(AValue.IsDictionary);
  for var I := 0 to AValue.Count - 1 do
  begin
    var E := AValue.Elements[I];
    if (E.Name = 'attached') then
      FAttachedComment := E.Value.ToString
    else if (E.Name = 'preceding') then
    begin
      Assert(E.Value.IsArray);
      SetLength(FPrecedingComments, E.Value.Count);
      for var J := 0 to E.Value.Count - 1 do
        FPrecedingComments[J] := E.Value[J].ToString;
    end
    else
      Assert(False, Format('Unsupported JSON key: "%s" in "comments" node', [E.Name]));
  end;
end;

{ TListNode<T> }

procedure TListNode<T>.Clear;
begin
  FItems.Clear;
  FItemsByName.Clear;
end;

constructor TListNode<T>.Create(const AParent: TDomNode);
begin
  inherited;
  FItems := TObjectList<T>.Create;
  FItemsByName := TDictionary<String, T>.Create;
end;

destructor TListNode<T>.Destroy;
begin
  FItemsByName.Free;
  FItems.Free;
  inherited;
end;

function TListNode<T>.GetEnumerator: TEnumerator<T>;
begin
  Result := FItems.GetEnumerator;
end;

procedure TListNode<T>.Load(const AArray: TJsonValue);
begin
  Clear;
  Assert(AArray.IsArray);
  for var I := 0 to AArray.Count - 1 do
  begin
    var Item := T.Create;
    Item.FParent := Self;
    Item.LoadChildren(AArray[I]);

    if (Item.Ignore) then
      Item.Free
    else
    begin
      Assert(Item.Name <> '');
      Item.Loaded;
      FItems.Add(Item);

      if (FItemsByName.ContainsKey(Item.Name)) then
        Assert(False, Format('Item "%s" already exists', [Item.Name]));
      FItemsByName.Add(Item.Name, Item);
    end;
  end;
  Loaded;
end;

{ TArgument }

constructor TArgument.Create;
begin
  inherited;
  FDataType := TDataType.Create(Self);
end;

destructor TArgument.Destroy;
begin
  FDataType.Free;
  inherited;
end;

function TArgument.IsSimple: Boolean;
begin
  Result := (FDefaultValue = '') and (not FIsArray) and (not FIsVarArgs)
    and (not FIsInstancePointer);
end;

function TArgument.IsTypeCompatibleWith(const AOther: TArgument): Boolean;
begin
  if (not IsSimple) or (not AOther.IsSimple) then
    Exit(False);

  Result := FDataType.IsCompatibleWith(AOther.FDataType);
end;

procedure TArgument.LoadChild(const AName: String; const AValue: TJsonValue);
begin
  if (AName = 'type') then
    FDataType.LoadChildren(AValue)
  else if (AName = 'default_value') then
    FDefaultValue := AValue.ToString
  else if (AName = 'array_bounds') then
    FArrayBounds := AValue.ToString
  else if (AName = 'is_array') then
    FIsArray := AValue.ToBoolean
  else if (AName = 'is_varargs') then
    FIsVarArgs := AValue.ToBoolean
  else if (AName = 'is_instance_pointer') then
    FIsInstancePointer := AValue.ToBoolean
  else
    inherited;
end;

{ TArguments }

procedure TArguments.WriteCApi(const AWriter: TSourceWriter);
begin
  for var I := 0 to FItems.Count - 1 do
  begin
    var Arg := FItems[I];
    if (I < (FItems.Count - 1)) and (Arg.IsTypeCompatibleWith(FItems[I + 1])) then
    begin
      AWriter.Write('_');
      AWriter.Write(Arg.FName);
      AWriter.Write(', ');
    end
    else if (Arg.IsVarArgs) then
    begin
      Assert(I = (FItems.Count - 1));
      FIsVarArgs := True;
      Break;
    end
    else
    begin
      if (I > 0) then
        AWriter.Write('; ');

      AWriter.Write('_');
      AWriter.Write(Arg.FName);
      AWriter.Write(': ');

      if (Arg.FIsArray) then
        Assert(False, 'TODO');

      Arg.FDataType.WriteCApi(AWriter);
    end;
  end;
end;

{ TTypeDetails }

destructor TTypeDetails.Destroy;
begin
  FArguments.Free;
  FReturnType.Free;
  inherited;
end;

procedure TTypeDetails.LoadChild(const AName: String; const AValue: TJsonValue);
begin
  if (AName = 'flavour') then
  begin
    var S := AValue.ToString;
    if (S = 'function_pointer') then
      FFlavor := TTypeFlavor.FunctionPointer
    else
      Assert(False, Format('Unsupported type flavor: "%s" in "type" node', [S]));
  end
  else if (AName = 'return_type') then
  begin
    Assert(FReturnType = nil);
    FReturnType := TDataType.Create(Self);
    FReturnType.LoadChildren(AValue);
  end
  else if (AName = 'arguments') then
  begin
    Assert(FArguments = nil);
    FArguments := TArguments.Create(Self);
    FArguments.Load(AValue);
  end
  else
    inherited;
end;

{ TParameter }

constructor TParameter.Create;
begin
  inherited;
  FDataType := TTypeDescription.Create(Self);
end;

destructor TParameter.Destroy;
begin
  FDataType.Free;
  inherited;
end;

function TParameter.IsTypeCompatibleWith(const AOther: TParameter): Boolean;
begin
  Result := FDataType.IsCompatibleWith(AOther.FDataType);
end;

procedure TParameter.LoadChild(const AName: String; const AValue: TJsonValue);
begin
  FDataType.LoadChild(AName, AValue);
  if (AName = 'name') then
    FName := AValue.ToString;
end;

{ TParameters }

procedure TParameters.WriteCApi(const AWriter: TSourceWriter);
begin
  for var I := 0 to FItems.Count - 1 do
  begin
    var Param := FItems[I];
    if (I < (FItems.Count - 1)) and (Param.IsTypeCompatibleWith(FItems[I + 1])) then
    begin
      AWriter.Write(Param.FName);
      AWriter.Write(', ');
    end
    else
    begin
      if (I > 0) then
        AWriter.Write('; ');

      AWriter.Write(Param.FName);
      AWriter.Write(': ');

      Param.FDataType.WriteCApi(AWriter);
    end;
  end;
end;

{ TTypeDescription }

destructor TTypeDescription.Destroy;
begin
  FParameters.Free;
  FReturnType.Free;
  FInnerType.Free;
  inherited;
end;

function TTypeDescription.GetIsVoid: Boolean;
begin
  Result := (FKind = TDataTypeKind.Builtin) and (FBuiltinType = TBuiltinType.Void);
end;

function TTypeDescription.IsCompatibleWith(
  const AOther: TTypeDescription): Boolean;
begin
  if (FName <> AOther.FName)
    or (FBounds <> AOther.FBounds)
    or (FBuiltinType <> AOther.FBuiltinType)
    or (FKind <> AOther.FKind)
    or (FStorageClasses <> AOther.FStorageClasses)
    or (FParameters <> nil) or (AOther.FParameters <> nil)
  then
    Exit(False);

  if (FInnerType <> nil) then
  begin
    if (AOther.FInnerType = nil) or (not FInnerType.IsCompatibleWith(AOther.FInnerType)) then
      Exit(False);
  end
  else if (AOther.FInnerType <> nil) then
    Exit(False);

  if (FReturnType <> nil) then
  begin
    if (AOther.FReturnType = nil) or (not FReturnType.IsCompatibleWith(AOther.FReturnType)) then
      Exit(False);
  end
  else if (AOther.FReturnType <> nil) then
    Exit(False);

  Result := True;
end;

procedure TTypeDescription.LoadChild(const AName: String;
  const AValue: TJsonValue);
var
  S: String;
begin
  if (AName = 'builtin_type') then
  begin
    S := AValue.ToString;
    if (S = 'void') then
      FBuiltinType := TBuiltinType.Void
    else if (S = 'char') then
      FBuiltinType := TBuiltinType.Char
    else if (S = 'unsigned_char') then
      FBuiltinType := TBuiltinType.UnsignedChar
    else if (S = 'short') then
      FBuiltinType := TBuiltinType.Short
    else if (S = 'unsigned_short') then
      FBuiltinType := TBuiltinType.UnsignedShort
    else if (S = 'int') then
      FBuiltinType := TBuiltinType.Int
    else if (S = 'unsigned_int') then
      FBuiltinType := TBuiltinType.UnsignedInt
    else if (S = 'long_long') then
      FBuiltinType := TBuiltinType.LongLong
    else if (S = 'unsigned_long_long') then
      FBuiltinType := TBuiltinType.UnsignedLongLong
    else if (S = 'float') then
      FBuiltinType := TBuiltinType.Float
    else if (S = 'double') then
      FBuiltinType := TBuiltinType.Double
    else if (S = 'bool') then
      FBuiltinType := TBuiltinType.Bool
    else
      Assert(False, Format('Unsupported built in type: "%s" in "type.description" node', [S]));
  end
  else if (AName = 'name') then
    FName := AValue.ToString
  else if (AName = 'bounds') then
    FBounds := AValue.ToString
  else if (AName = 'is_nullable') then
    FIsNullable := AValue.ToBoolean
  else if (AName = 'is_reference') then
    FIsReference := AValue.ToBoolean
  else if (AName = 'kind') then
  begin
    S := AValue.ToString;
    if (S = 'Builtin') then
      FKind := TDataTypeKind.Builtin
    else if (S = 'User') then
      FKind := TDataTypeKind.User
    else if (S = 'Pointer') then
      FKind := TDataTypeKind.Pointer
    else if (S = 'Type') then
      FKind := TDataTypeKind.&Type
    else if (S = 'Function') then
      FKind := TDataTypeKind.&Function
    else if (S = 'Array') then
      FKind := TDataTypeKind.&Array
    else
      Assert(False, Format('Unsupported data type kind: "%s" in "type.description" node', [S]));
  end
  else if (AName = 'inner_type') then
  begin
    Assert(FInnerType = nil);
    FInnerType := TTypeDescription.Create(Self);
    FInnerType.LoadChildren(AValue);
  end
  else if (AName = 'return_type') then
  begin
    Assert(FReturnType = nil);
    FReturnType := TTypeDescription.Create(Self);
    FReturnType.LoadChildren(AValue);
  end
  else if (AName = 'parameters') then
  begin
    Assert(FParameters = nil);
    FParameters := TParameters.Create(Self);
    FParameters.Load(AValue);
  end
  else if (AName = 'storage_classes') then
    LoadStorageClasses(AValue)
  else
    Assert(False, Format('Unsupported JSON key: "%s" in type description node', [AName]));
end;

procedure TTypeDescription.LoadStorageClasses(const AValue: TJsonValue);
begin
  Assert(AValue.IsArray);
  for var I := 0 to AValue.Count - 1 do
  begin
    var S := AValue[I].ToString;
    if (S = 'const') then
      Include(FStorageClasses, TStorageClass.Const)
    else
    Assert(False, 'Invalid storage class: ' + S);
  end;
end;

procedure TTypeDescription.WriteCApi(const AWriter: TSourceWriter);
begin
  case FKind of
    TDataTypeKind.Builtin:
      AWriter.Write(FBuiltinType.ToDelphiType);

    TDataTypeKind.User:
      begin
        Assert(FName <> '');
        AWriter.Write('_');
        AWriter.Write(FName);
      end;

    TDataTypeKind.Pointer:
      if (FInnerType <> nil) and (FInnerType.Kind = TDataTypeKind.Function) then
        FInnerType.WriteCApi(AWriter)
      else
        AWriter.Write('Pointer');

    TDataTypeKind.&Type:
      begin
        Assert(Assigned(FInnerType));
        FInnerType.WriteCApi(AWriter);
      end;

    TDataTypeKind.Function:
      begin
        Assert(Assigned(FReturnType));
        if (FReturnType.IsVoid) then
          AWriter.Write('procedure(')
        else
          AWriter.Write('function(');
        FParameters.WriteCApi(AWriter);
        AWriter.Write(')');
        if (not FReturnType.IsVoid) then
        begin
          AWriter.Write(': ');
          FReturnType.WriteCApi(AWriter);
        end;
        AWriter.Write('; cdecl');
      end;

    TDataTypeKind.Array:
      begin
        Assert(Assigned(FInnerType));
        AWriter.Write('array [0..');

        var Count: Integer;
        if (TryStrToInt(FBounds, Count)) then
          AWriter.Write((Count - 1).ToString)
        else
        begin
          var C := FBounds.Chars[0];
          if (C < '0') or (C > '9') then
            AWriter.Write('_');
          AWriter.Write(FBounds);
          AWriter.Write(' - 1');
        end;
        AWriter.Write('] of ');
        FInnerType.WriteCApi(AWriter);
      end;
  else
    Assert(False, 'TODO');
  end;
end;

{ TDataType }

constructor TDataType.Create(const AParent: TDomNode);
begin
  inherited;
  FDescription := TTypeDescription.Create(Self);
end;

destructor TDataType.Destroy;
begin
  FDetails.Free;
  FDescription.Free;
  inherited;
end;

function TDataType.GetIsVoid: Boolean;
begin
  Result := FDescription.IsVoid;
end;

function TDataType.IsCompatibleWith(const AOther: TDataType): Boolean;
begin
  Result := (FDetails = nil)
        and (AOther.FDetails = nil)
        and (FDeclaration = AOther.FDeclaration);
end;

procedure TDataType.LoadChild(const AName: String; const AValue: TJsonValue);
begin
  if (AName = 'declaration') then
    FDeclaration := AValue.ToString
  else if (AName = 'description') then
    FDescription.LoadChildren(AValue)
  else if (AName = 'type_details') then
  begin
    Assert(FDetails = nil);
    FDetails := TTypeDetails.Create(Self);
    FDetails.LoadChildren(AValue);
  end
  else
    inherited;
end;

procedure TDataType.WriteCApi(const AWriter: TSourceWriter);
begin
  FDescription.WriteCApi(AWriter);
end;

{ TDefine }

function TDefine.Ignore: Boolean;
begin
  { Ignore defines without content, or which look like functions. }
  Result := inherited or (FContent = '') or (FContent.IndexOf('(') >= 0);
end;

procedure TDefine.LoadChild(const AName: String; const AValue: TJsonValue);
begin
  if (AName = 'content') then
    FContent := AValue.ToString
  else
    inherited;
end;

{ TEnumElement }

procedure TEnumElement.LoadChild(const AName: String; const AValue: TJsonValue);
begin
  if (AName = 'value_expression') then
    FValueExpression := AValue.ToString
  else if (AName = 'value') then
    FValue := AValue.ToInt64
  else if (AName = 'is_count') then
    FIsCount := AValue.ToBoolean
  else
    inherited;
end;

{ TEnum }

constructor TEnum.Create;
begin
  inherited;
  FElements := TEnumElements.Create(Self);
end;

destructor TEnum.Destroy;
begin
  FElements.Free;
  FStorageType.Free;
  inherited;
end;

procedure TEnum.LoadChild(const AName: String; const AValue: TJsonValue);
begin
  if (AName = 'original_fully_qualified_name') then
    FOriginalFullyQualifiedName := AValue.ToString
  else if (AName = 'is_flags_enum') then
    FIsFlags := AValue.ToBoolean
  else if (AName = 'elements') then
    FElements.Load(AValue)
  else if (AName = 'storage_type') then
  begin
    Assert(FStorageType = nil);
    FStorageType := TDataType.Create(Self);
    FStorageType.LoadChildren(AValue);
  end
  else
    inherited;
end;

procedure TEnum.WriteCApi(const AWriter: TSourceWriter);
begin
  AWriter.Write('_');
  AWriter.Write(FName);
  AWriter.WriteLn(' = Integer;');
end;

procedure TEnum.WriteCountConst(const AWriter: TSourceWriter);
begin
  for var I := FElements.FItems.Count - 1 downto 0 do
  begin
    var E := FElements.FItems[I];
    if (E.IsCount) then
    begin
      AWriter.Write('_');
      AWriter.Write(E.FName);
      AWriter.WriteLn(' = %d;', [E.FValue]);
      Break;
    end;
  end;
end;

{ TTypedef }

constructor TTypedef.Create;
begin
  inherited;
  FDataType := TDataType.Create(Self);
end;

destructor TTypedef.Destroy;
begin
  FDataType.Free;
  inherited;
end;

procedure TTypedef.LoadChild(const AName: String; const AValue: TJsonValue);
begin
  if (AName = 'type') then
    FDataType.LoadChildren(AValue)
  else
    inherited;
end;

procedure TTypedef.WriteCApi(const AWriter: TSourceWriter);
begin
  AWriter.Write('_');
  AWriter.Write(FName);
  AWriter.Write(' = ');
  FDataType.WriteCApi(AWriter);
  AWriter.WriteLn(';');
end;

{ TField }

constructor TField.Create;
begin
  inherited;
  FFieldType := TDataType.Create(Self);
end;

destructor TField.Destroy;
begin
  FFieldType.Free;
  inherited;
end;

procedure TField.LoadChild(const AName: String; const AValue: TJsonValue);
begin
  if (AName = 'is_array') then
    FIsArray := AValue.ToBoolean
  else if (AName = 'is_anonymous') then
    FIsAnonymous := AValue.ToBoolean
  else if (AName = 'type') then
    FFieldType.LoadChildren(AValue)
  else if (AName = 'array_bounds') then
    FArrayBounds := AValue.ToString
  else if (AName = 'width') then
    FWidth := AValue.ToInteger
  else
    inherited;
end;

procedure TField.WriteCApi(const AWriter: TSourceWriter);
begin
//  if (FIsAnonymous) then
//    Assert(False, 'TODO');
  if (FWidth > 0) then
    Assert(False, 'TODO');

  AWriter.Write('_');
  AWriter.Write(FName);
  AWriter.Write(': ');

  FFieldType.WriteCApi(AWriter);
end;

{ TStruct }

constructor TStruct.Create;
begin
  inherited;
  FFields := TFields.Create(Self);
end;

destructor TStruct.Destroy;
begin
  FFields.Free;
  inherited;
end;

procedure TStruct.LoadChild(const AName: String; const AValue: TJsonValue);
begin
  if (AName = 'original_fully_qualified_name') then
    FOriginalFullyQualifiedName := AValue.ToString
  else if (AName = 'kind') then
  begin
    var S := AValue.ToString;
    if (S = 'struct') then
      FKind := TStructKind.Struct
    else if (S = 'union') then
      FKind := TStructKind.Union
    else
      Assert(False, 'Invalid struct kind: ' + S);
  end
  else if (AName = 'by_value') then
    FByValue := AValue.ToBoolean
  else if (AName = 'forward_declaration') then
    FForwardDeclaration := AValue.ToBoolean
  else if (AName = 'is_anonymous') then
    FIsAnonymous := AValue.ToBoolean
  else if (AName = 'fields') then
    FFields.Load(AValue)
  else
    inherited;
end;

procedure TStruct.WriteCApi(const AWriter: TSourceWriter);
begin
  AWriter.Write('_');
  AWriter.Write(FName);
  AWriter.WriteLn(' = record');

  if (FKind = TStructKind.Union) then
    AWriter.WriteLn('case Byte of');

  AWriter.Indent;
  for var I := 0 to FFields.FItems.Count - 1 do
  begin
    var Field := FFields.FItems[I];

    if (FKind = TStructKind.Union) then
      AWriter.Write('%d: (', [I]);

    Field.WriteCApi(AWriter);

    if (FKind = TStructKind.Union) then
      AWriter.Write(')');

    AWriter.WriteLn(';');
  end;
  AWriter.Outdent;

  AWriter.WriteLn('end;');
  AWriter.WriteLn;
end;

{ TStructs }

procedure TStructs.Loaded;
begin
  inherited;
  var Unordered := FItems.ToArray;
  FItems.OwnsObjects := False;
  try
    Reorder(Unordered);
  finally
    FItems.OwnsObjects := True;
  end;
end;

procedure TStructs.Reorder(const ASource: TArray<TStruct>);
{ Reorder structs based on their inner dependencies }

  function FindStruct(const AName: String): Integer;
  begin
    for var I := 0 to FItems.Count - 1 do
    begin
      if (FItems[I].Name = AName) then
        Exit(I);
    end;
    Result := -1;
  end;

  procedure AnalyzeType(const ASrcIndex: Integer; const AName: String);
  begin
//    var Name := AName;
//    { Remove any qualifiers (like "const") }
//    var I := Name.LastIndexOf(' ');
//    if (I > 0) then
//      Name := Name.Substring(I + 1);

    var DstIndex := FindStruct(AName);
    if (DstIndex > ASrcIndex) then
    begin
      var Dst := FItems[DstIndex];
      FItems.Delete(DstIndex);
      FItems.Insert(ASrcIndex, Dst);
    end;
  end;

  procedure AnalyzeStruct(const ASrc: TStruct);
  begin
//    var Funcs := TDefinitions.Instance.GetFunctionsForStruct(ASrc.Name);
//    if (Funcs = nil) and (ASrc.FMembers.Count = 0) then
//      Exit;

    var SrcIndex := FindStruct(ASrc.Name);
    Assert(SrcIndex >= 0);

    for var Field in ASrc.FFields do
    begin
      var Name := Field.Name;
//      if (TypeName.StartsWith('ImVector_')) then
//        TypeName := TypeName.Substring(9)
//      else if (TypeName.StartsWith('ImPool_')) then
//        TypeName := TypeName.Substring(7)
//      else if (TypeName.StartsWith('ImSpan_')) then
//        TypeName := TypeName.Substring(7);

      AnalyzeType(SrcIndex, Name);
    end;

//    if (Funcs = nil) then
//      Exit;

//    for var Func in Funcs do
//    begin
//      for var FuncOverload in Func.Overloads do
//      begin
//        for var I := 0 to FuncOverload.Arguments.Count - 1 do
//        begin
//          var TypeName := FuncOverload.Arguments[I].TypeName;
//
//          { For NonUTD functions, the first argument is a pointer to the
//            function result. }
//          if (FuncOverload.NonUDT) and (I = 0) then
//          begin
//            Assert(TypeName.EndsWith('*'));
//            SetLength(TypeName, TypeName.Length - 1);
//          end;
//
//          AnalyzeType(SrcIndex, TypeName);
//        end;
//
//        if (FuncOverload.ReturnTypeName <> '') then
//          AnalyzeType(SrcIndex, FuncOverload.ReturnTypeName);
//      end;
//    end;
  end;

begin
  for var Struct in ASource do
    AnalyzeStruct(Struct);
end;

{ TFunction }

constructor TFunction.Create;
begin
  inherited;
  FReturnType := TDataType.Create(Self);
  FArguments := TArguments.Create(Self);
end;

destructor TFunction.Destroy;
begin
  FArguments.Free;
  FReturnType.Free;
  inherited;
end;

function TFunction.GetHasReturnType: Boolean;
begin
  Result := (not FReturnType.IsVoid);
end;

procedure TFunction.LoadChild(const AName: String; const AValue: TJsonValue);
begin
  if (AName = 'original_fully_qualified_name') then
    FOriginalFullyQualifiedName := AValue.ToString
  else if (AName = 'original_class') then
    FOriginalClass := AValue.ToString
  else if (AName = 'return_type') then
    FReturnType.LoadChildren(AValue)
  else if (AName = 'arguments') then
    FArguments.Load(AValue)
  else if (AName = 'is_default_argument_helper') then
    FIsDefaultArgumentHelper := AValue.ToBoolean
  else if (AName = 'is_manual_helper') then
    FIsManualHelper := AValue.ToBoolean
  else if (AName = 'is_imstr_helper') then
    FIsImStrHelper := AValue.ToBoolean
  else if (AName = 'has_imstr_helper') then
    FHasImStrHelper := AValue.ToBoolean
  else if (AName = 'is_unformatted_helper') then
    FIsUnformattedHelper := AValue.ToBoolean
  else if (AName = 'is_static') then
    FIsStatic := AValue.ToBoolean
  else
    inherited;
end;

procedure TFunction.Loaded;
begin
  { Sokol still uses the "ig" prefix from the legacy cimgui bindings, instead
    of the new "ImGui" prefix. }
  if (FName.StartsWith('ImGui_')) then
    FName := 'ig' + FName.Substring(6);
end;

procedure TFunction.WriteCApi(const AWriter: TSourceWriter);
begin
//  if (FIsDefaultArgumentHelper) then
//    Assert(False, 'TODO');
  if (FIsManualHelper) then
    Assert(False, 'TODO');
  if (FIsImStrHelper) then
    Assert(False, 'TODO');
  if (FHasImStrHelper) then
    Assert(False, 'TODO');
  if (FIsUnformattedHelper) then
    Assert(False, 'TODO');
  if (FIsStatic) then
    Assert(False, 'TODO');

  if (HasReturnType) then
    AWriter.Write('function _')
  else
    AWriter.Write('procedure _');

  AWriter.Write(FName);
  AWriter.Write('(');
  FArguments.WriteCApi(AWriter);
  AWriter.Write(')');

  if (HasReturnType) then
  begin
    AWriter.Write(': ');
    FReturnType.WriteCApi(AWriter);
  end;

  AWriter.Write('; ');

  if (FArguments.IsVarArgs) then
    AWriter.Write('varargs; ');

  AWriter.WriteLn('cdecl;');
  AWriter.Write('  external _LIB_SOKOL name _PU + ''');
  AWriter.Write(FName);
  AWriter.WriteLn(''';');
  AWriter.WriteLn;
end;

{ TDom }

constructor TDom.Create;
begin
  inherited;
  FDefines := TDefines.Create(Self);
  FEnums := TEnums.Create(Self);
  FTypedefs := TTypedefs.Create(Self);
  FStructs := TStructs.Create(Self);
  FFunctions := TFunctions.Create(Self);
end;

destructor TDom.Destroy;
begin
  FFunctions.Free;
  FStructs.Free;
  FTypedefs.Free;
  FEnums.Free;
  FDefines.Free;
  inherited;
end;

procedure TDom.Load;
begin
  FDefines.Clear;
  FEnums.Clear;
  FTypedefs.Clear;
  FStructs.Clear;
  FFunctions.Clear;

  var Doc := TJsonDocument.Load('dcimgui.json');
  LoadChildren(Doc.Root);
end;

procedure TDom.LoadChild(const AName: String; const AValue: TJsonValue);
begin
  if (AName = 'defines') then
    FDefines.Load(AValue)
  else if (AName = 'enums') then
    FEnums.Load(AValue)
  else if (AName = 'typedefs') then
    FTypedefs.Load(AValue)
  else if (AName = 'structs') then
    FStructs.Load(AValue)
  else if (AName = 'functions') then
    FFunctions.Load(AValue)
  else
    inherited;
end;

end.

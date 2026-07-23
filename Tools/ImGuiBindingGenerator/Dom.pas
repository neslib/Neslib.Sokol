unit Dom;

interface

uses
  System.SysUtils,
  System.Generics.Defaults,
  System.Generics.Collections,
  Neslib.Json,
  SourceWriter;

type
  TDataTypeKind = (Builtin, User, Pointer, &Type, &Function, &Array);
  TBuiltinType = (Void, Char, UnsignedChar, Short, UnsignedShort, Int,
    UnsignedInt, LongLong, UnsignedLongLong, Float, Double, Bool, WChar16,
    WChar32, SizeT);
  TTypeFlavor = (None, FunctionPointer);
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
    procedure LoadChildren(const AParent: TJsonValue); virtual;
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
    procedure WriteCommentBefore(const AWriter: TSourceWriter);
    procedure WriteCommentAfter(const AWriter: TSourceWriter);
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
    function GetCount: Integer; inline;
    function GetItem(const AIndex: Integer): T; inline;
  protected
    procedure Clear;
    procedure Load(const AArray: TJsonValue);
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AParent: TDomNode);
    destructor Destroy; override;

    function GetEnumerator: TEnumerator<T>;
    function Has(const AName: String): Boolean;
    function Get(const AName: String): T;

    property Count: Integer read GetCount;
    property Items[const AIndex: Integer]: T read GetItem; default;
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
    FHasDefaultValue: Boolean;
    FHasUnsupportedDefaultValue: Boolean;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
    procedure ConvertDefaultValueToDelphi;
    procedure WriteSource(const AWriter: TSourceWriter);
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
    procedure WriteSource(const AWriter: TSourceWriter;
      const AStartIndex, ACount: Integer; const AForImplementation: Boolean);
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
    procedure LoadChildren(const AParent: TJsonValue); override;
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
    procedure LoadStorageClasses(const AValue: TJsonValue);
    procedure WriteCApi(const AWriter: TSourceWriter);
    procedure WriteSource(const AWriter: TSourceWriter;
      const AForArgument: Boolean = False);
    procedure WriteFunction(const AWriter: TSourceWriter);
    procedure WriteArray(const AWriter: TSourceWriter; const AForCApi: Boolean);
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
  private class var
    GCustomTypes: TDictionary<String, String>;
  private
    FDeclaration: String;
    FDelphiTypeName: String;
    FDescription: TTypeDescription;
    FDetails: TTypeDetails;
    function GetIsVoid: Boolean; inline;
  protected
    procedure LoadChildren(const AParent: TJsonValue); override;
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
    procedure WriteCApi(const AWriter: TSourceWriter);
    procedure WriteSource(const AWriter: TSourceWriter;
      const AForArgument: Boolean = False);
  public
    class constructor Create;
    class destructor Destroy;
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
    procedure WriteCApi(const AWriter: TSourceWriter);
    procedure WriteSource(const AWriter: TSourceWriter);

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
    FNameWithoutPrefix: String;
    FValue: Int64;
    FIsCount: Boolean;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
    procedure WriteSource(const AWriter: TSourceWriter; const AIsFlag: Boolean);
    procedure Loaded; override;
  {$ENDREGION 'Internal Declarations'}
  public
    { The value of the element as it originally appeared in the source.
      May not be present in the case where an enum element uses an implicit
      value (i.e. enum auto-numbering) }
    property ValueExpression: String read FValueExpression;

    { The name of the enum element without the enum prefix }
    property NameWithoutPrefix: String read FNameWithoutPrefix;

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
    procedure WriteSource(const AWriter: TSourceWriter);
    procedure WriteSetSource(const AWriter: TSourceWriter);
    procedure Loaded; override;
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
  public
    procedure WriteSource(const AWriter: TSourceWriter);
  end;

type
  { Represent a single typedef in the root "typedefs" node. }
  TTypedef = class(TNamedNode)
  {$REGION 'Internal Declarations'}
  private type
    TCustomization = record
    public
      UserType: String;
      BuiltinType: TBuiltinType;
    end;
  private class var
    GCustomizations: TDictionary<String, TCustomization>;
  private
    FDataType: TDataType;
    function GetIsBuiltinType: Boolean; inline;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
    procedure WriteSource(const AWriter: TSourceWriter);
    procedure FixupSource;
  public
    class constructor Create;
    class destructor Destroy;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    procedure WriteCApi(const AWriter: TSourceWriter);

    { The defined type (as a generic type element) }
    property DataType: TDataType read FDataType;

    { Whether this is a Delphi builtin type }
    property IsBuiltinType: Boolean read GetIsBuiltinType;
  end;

type
  { Represents the root "typedefs" node. }
  TTypedefs = class(TListNode<TTypedef>)
  public
    procedure Fixup;
    procedure FixupSource;
    procedure WriteSource(const AWriter: TSourceWriter);
  end;

type
  TField = class(TNamedNode)
  {$REGION 'Internal Declarations'}
  private
    FFieldType: TDataType;
    FArrayBounds: String;
    FCombinedType: String;
    FFlagsField: TField;
    FWidth: Integer;
    FBitOffset: Integer;
    FIsArray: Boolean;
    FIsAnonymous: Boolean;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
    procedure WriteCApi(const AWriter: TSourceWriter);
    procedure WriteSource(const AWriter: TSourceWriter);
    procedure WriteAnonymous(const AWriter: TSourceWriter);
    procedure WriteGetter(const AWriter: TSourceWriter; const AStructName: String);
    procedure WriteSetter(const AWriter: TSourceWriter; const AStructName: String);
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
    FCApiOnly: Boolean;
    FHasFields: Boolean;
    FHasBitFields: Boolean;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
    procedure Loaded; override;
    procedure WriteForwardDeclarations(const AWriter: TSourceWriter);
    procedure WriteInterface(const AWriter: TSourceWriter);
    procedure WriteImplementation(const AWriter: TSourceWriter);
    procedure WriteInitialization(const AWriter: TSourceWriter);
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

    { Whether this struct is only used for the C-API.
      For example, ImVec2 is translated to TVector2 in Delphi, so it is only
      used for the C-API.
      Likewise, generic C++ types like ImVector<char> are handled specifically
      so are only used for the C-API as well. }
    property CApiOnly: Boolean read FCApiOnly;
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
  public
    procedure WriteForwardDeclarations(const AWriter: TSourceWriter);
    procedure WriteInterfaces(const AWriter: TSourceWriter);
    procedure WriteImGuiInterface(const AWriter: TSourceWriter);
    procedure WriteImplementations(const AWriter: TSourceWriter);
    procedure WriteImGuiImplementation(const AWriter: TSourceWriter);
    procedure WriteInitialization(const AWriter: TSourceWriter);
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
    FIsOverload: Boolean;
    function GetHasReturnType: Boolean; inline;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
    procedure Loaded; override;
    function Ignore: Boolean; override;
    procedure WriteSource(const AWriter: TSourceWriter;
      const AStructName: String; const AForImplementation, AFirst: Boolean);
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
  private class var
    GInstance: TDom;
  private
    FDefines: TDefines;
    FEnums: TEnums;
    FTypedefs: TTypedefs;
    FStructs: TStructs;
    FFunctions: TFunctions;
    FFunctionsByStruct: TObjectDictionary<String, TList<TFunction>>;
  protected
    procedure LoadChild(const AName: String; const AValue: TJsonValue); override;
    procedure AddFunctionForStruct(const AStructName: String;
      const AFunction: TFunction);
    function GetFunctionsForStruct(const AStructName: String;
      const ACheckOverloads: Boolean): TArray<TFunction>;
    class property Instance: TDom read GInstance;
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

uses
  System.Math,
  BindingGenerator,
  DelphiOverloads,
  Utils;

{ _TBuiltinTypeHelper }

function _TBuiltinTypeHelper.ToDelphiType: String;
const
  STRINGS: array [TBuiltinType] of String = (
    'ointer', 'UTF8Char', 'UInt8', 'Int16', 'UInt16', 'Int32', 'UInt32',
    'Int64', 'UInt64', 'Single', 'Double', 'Boolean', 'Char', 'UCS4Char',
    'NativeUInt');
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
    case C.Condition of
      TCondition.IfDef,
      TCondition.If:
        if (C.Expression = 'IMGUI_USE_WCHAR32') or
           (C.Expression = 'IMGUI_USE_BGRA_PACKED_COLOR') or
           (C.Expression = 'IMGUI_HAS_IMSTR')
        then
          Exit(True);

      TCondition.IfNDef:
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
      FAttachedComment := E.Value.ToString.Trim
    else if (E.Name = 'preceding') then
    begin
      Assert(E.Value.IsArray);
      SetLength(FPrecedingComments, E.Value.Count);
      for var J := 0 to E.Value.Count - 1 do
        FPrecedingComments[J] := E.Value[J].ToString.Trim;
    end
    else
      Assert(False, Format('Unsupported JSON key: "%s" in "comments" node', [E.Name]));
  end;
end;

procedure TNamedNode.WriteCommentAfter(const AWriter: TSourceWriter);
begin
  if (FAttachedComment <> '') then
    AWriter.WriteAlignedComment(FAttachedComment)
  else
    AWriter.WriteLn(' ');
end;

procedure TNamedNode.WriteCommentBefore(const AWriter: TSourceWriter);
begin
  for var Comment in FPrecedingComments do
    AWriter.WriteLn(Comment);
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

function TListNode<T>.Get(const AName: String): T;
begin
  FItemsByName.TryGetValue(AName, Result);
end;

function TListNode<T>.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TListNode<T>.GetEnumerator: TEnumerator<T>;
begin
  Result := FItems.GetEnumerator;
end;

function TListNode<T>.GetItem(const AIndex: Integer): T;
begin
  Result := FItems[AIndex];
end;

function TListNode<T>.Has(const AName: String): Boolean;
begin
  Result := FItemsByName.ContainsKey(AName);
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

procedure TArgument.ConvertDefaultValueToDelphi;

  procedure NotSupported;
  begin
    FHasUnsupportedDefaultValue := True;
    FHasDefaultValue := False;
    FDefaultValue := '';
  end;

begin
  if (not FHasDefaultValue) then
    Exit;

  var Desc := FDataType.FDescription;
  case Desc.Kind of
    TDataTypeKind.Builtin:
      case Desc.FBuiltinType of
        TBuiltinType.Char,
        TBuiltinType.UnsignedChar,
        TBuiltinType.Short,
        TBuiltinType.UnsignedShort,
        TBuiltinType.Int,
        TBuiltinType.UnsignedInt,
        TBuiltinType.LongLong,
        TBuiltinType.UnsignedLongLong:
          if (FDefaultValue.StartsWith('sizeof(')) then
          begin
            var I := FDefaultValue.IndexOf(')');
            Assert(I > 0);
            FDefaultValue := FDefaultValue.Substring(7, I - 7);
            FDefaultValue := 'SizeOf(' + ToDelphiType(FDefaultValue) + ')';
          end;

        TBuiltinType.Float:
          if (FDefaultValue = 'FLT_MAX') then
            FDefaultValue := 'Single.MaxValue'
          else if (FDefaultValue.EndsWith('f')) then
            FDefaultValue := FDefaultValue.Substring(0, FDefaultValue.Length - 1);
      end;

    TDataTypeKind.User:
      if (FDataType.FDeclaration = 'ImDrawTextFlags') then
      begin
        { This is an internal enum, exposed as an Integer }
      end
      else if (FDataType.FDeclaration.EndsWith('Flags')) then
      begin
        if (FDefaultValue = '0') then
          FDefaultValue := '[]';
      end
      else if (Desc.Name = 'ImVec2') or (Desc.Name = 'ImVec4') then
        NotSupported
      else if (Desc.Name.EndsWith('Callback')) then
      begin
        { Callbacks can only have a NULL default value }
        if (FDefaultValue = 'NULL') then
          FDefaultValue := 'nil'
        else
          NotSupported;
      end
      else if (Desc.Name.StartsWith('ImGui')) then
      begin
        var IntValue: Int64;
        if (TryStrToInt64(FDefaultValue, IntValue)) then
          FDefaultValue := 'T' + Desc.Name + '(' + FDefaultValue + ')';
      end;

    TDataTypeKind.Pointer:
      { For character pointers and other types of pointers.
        Only valid default value is NULL (even for PUTF8Char). }
      if (FDefaultValue = 'NULL') then
        FDefaultValue := 'nil'
      else
        NotSupported;
  end;
end;

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

  if (FHasDefaultValue) or (AOther.FHasDefaultValue) then
    Exit(False);

  Result := FDataType.IsCompatibleWith(AOther.FDataType);
end;

procedure TArgument.LoadChild(const AName: String; const AValue: TJsonValue);
begin
  if (AName = 'type') then
    FDataType.LoadChildren(AValue)
  else if (AName = 'default_value') then
  begin
    FDefaultValue := AValue.ToString;
    FHasDefaultValue := True;
  end
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

procedure TArgument.WriteSource(const AWriter: TSourceWriter);
begin
  var IsTypeCast := False;
  if (FDataType.FDelphiTypeName = '') then
  begin
    var TypeName := FDataType.FDescription.Name;
    if (TypeName.StartsWith('Im')) then
    begin
      if (TypeName.EndsWith('Flags')) then
        AWriter.Write('Cardinal(')
      else
        AWriter.Write('_' + TypeName + '(');
      IsTypeCast := True;
    end;
  end
  else
    { Custom types (currently) are always function pointers }
    AWriter.Write('@');

  AWriter.Write(ToValidId('A' + ToPascalCase(FName), False));

  if (IsTypeCast) then
    AWriter.Write(')');
end;

{ TArguments }

procedure TArguments.WriteCApi(const AWriter: TSourceWriter);
begin
  var CombinesWithNext := False;
  var NeedSemicolon := False;
  for var I := 0 to Count - 1 do
  begin
    var Arg := Items[I];
    if (I < (Count - 1)) and (Arg.IsTypeCompatibleWith(Items[I + 1])) then
    begin
      if (not CombinesWithNext) and (NeedSemicolon) then
      begin
        AWriter.Write('; ');
        NeedSemicolon := False;
      end;

      AWriter.Write('_');
      AWriter.Write(Arg.FName);
      AWriter.Write(', ');
      CombinesWithNext := True;
    end
    else if (Arg.IsVarArgs) then
    begin
      Assert(I = (Count - 1));
      FIsVarArgs := True;
      Break;
    end
    else
    begin
      if (I > 0) and (not CombinesWithNext) then
        AWriter.Write('; ');
      CombinesWithNext := False;

      AWriter.Write('_');
      AWriter.Write(Arg.FName);
      AWriter.Write(': ');

      if (Arg.FIsArray) then
        AWriter.Write('Pointer')
      else if (Arg.FDataType.FDetails <> nil) and (Arg.FDataType.FDetails.FFlavor = TTypeFlavor.FunctionPointer) then
        AWriter.Write('Pointer')
      else
        Arg.FDataType.WriteCApi(AWriter);

      NeedSemicolon := True;
    end;
  end;
end;

procedure TArguments.WriteSource(const AWriter: TSourceWriter;
  const AStartIndex, ACount: Integer; const AForImplementation: Boolean);
begin
  var CombinesWithNext := False;
  var NeedSemicolon := False;
  for var I := 0 to ACount - 1 do
  begin
    var Arg := Items[AStartIndex + I];
    Assert(not Arg.IsVarArgs);
    if (I < (ACount - 1)) and (Arg.IsTypeCompatibleWith(Items[AStartIndex + I + 1])) then
    begin
      if (not CombinesWithNext) then
      begin
        if (NeedSemicolon) then
        begin
          AWriter.Write('; ');
          NeedSemicolon := False;
        end;
        AWriter.Write('const ');
      end;

      AWriter.Write(ToValidId('A' + ToPascalCase(Arg.FName), False));
      AWriter.Write(', ');
      CombinesWithNext := True;
    end
    else
    begin
      if (I = 0) then
        AWriter.Write('const ')
      else if (not CombinesWithNext) then
        AWriter.Write('; const ');
      CombinesWithNext := False;

      AWriter.Write(ToValidId('A' + ToPascalCase(Arg.FName), False));
      AWriter.Write(': ');

      Arg.FDataType.WriteSource(AWriter, True);

      if (not AForImplementation) and (Arg.FHasDefaultValue) then
      begin
        AWriter.Write(' = ');
        AWriter.Write(Arg.FDefaultValue);
      end;

      NeedSemicolon := True;
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
  for var I := 0 to Count - 1 do
  begin
    var Param := Items[I];
    if (I < (Count - 1)) and (Param.IsTypeCompatibleWith(Items[I + 1])) then
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

procedure TTypeDescription.LoadChildren(const AParent: TJsonValue);
begin
  inherited;
  if (FKind = TDataTypeKind.User) and (FName = 'size_t') then
  begin
    FKind := TDataTypeKind.Builtin;
    FBuiltinType := TBuiltinType.SizeT;
  end;
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

procedure TTypeDescription.WriteArray(const AWriter: TSourceWriter;
  const AForCApi: Boolean);
begin
  Assert(Assigned(FInnerType));
  AWriter.Write('array [0..');

  var Count: Integer;
  if (TryStrToInt(FBounds, Count)) then
    AWriter.Write((Count - 1).ToString)
  else
  begin
    var S := FBounds;
    var I := 0;
    while (I < S.Length) do
    begin
      var C := S.Chars[I];
      if (C >= 'A') and (C <= 'Z') then
      begin
        S := S.Insert(I, '_');
        var J := I + 2;
        while (J < S.Length) do
        begin
          C := S.Chars[J];
          if (C <> '_') and ((C < 'A') or (C > 'Z')) and ((C < 'a') or (C > 'z')) then
            Break;
          Inc(J);
        end;
        I := J;
      end
      else if (C = '/') then
      begin
        S := S.Remove(I, 1);
        S := S.Insert(I, ' div ');
        Inc(I, 4);
      end;
      Inc(I);
    end;
    AWriter.Write(S);
    AWriter.Write(' - 1');
  end;
  AWriter.Write('] of ');

  if (AForCApi) then
    FInnerType.WriteCApi(AWriter)
  else
    FInnerType.WriteSource(AWriter);
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
      WriteFunction(AWriter);

    TDataTypeKind.Array:
      WriteArray(AWriter, True);
  else
    Assert(False);
  end;
end;

procedure TTypeDescription.WriteFunction(const AWriter: TSourceWriter);
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

procedure TTypeDescription.WriteSource(const AWriter: TSourceWriter;
  const AForArgument: Boolean);
begin
  case FKind of
    TDataTypeKind.Builtin:
      AWriter.Write(FBuiltinType.ToDelphiType);

    TDataTypeKind.User:
      begin
        var Typedef := TDom.Instance.Typedefs.Get(FName);

        if (Typedef <> nil) and (Typedef.IsBuiltinType) then
          TypeDef.DataType.Description.WriteSource(AWriter)
        else
        begin
          var IsPointer := (FParent is TTypeDescription) and (TTypeDescription(FParent).Kind = TDataTypeKind.Pointer);
          if (not IsPointer) then
            AWriter.Write('T');

          if (FName = 'ImVec2') then
            AWriter.Write('Vector2')
          else if (FName = 'ImVec4') then
            AWriter.Write('Vector4')
          else if (FName.StartsWith('ImVector_')) then
          begin
            var GenericTypeName := FName.Substring(9, FName.Length - 9);
            if (IsPointer) then
            begin
              AWriter.Write('ImVector');
              AWriter.Write(GenericTypeName);
            end
            else
            begin
              AWriter.Write('ImVector<');
              var GenericTypedef := TDom.Instance.Typedefs.Get(GenericTypeName);
              if (GenericTypedef <> nil) then
                GenericTypedef.DataType.WriteSource(AWriter)
              else
                AWriter.Write(ToDelphiType(GenericTypeName));
              AWriter.Write('>');
            end;
          end
          else
            AWriter.Write(FName)
        end;
      end;

    TDataTypeKind.Pointer:
      if (FInnerType = nil) then
        AWriter.Write('Pointer')
      else
      begin
        if (FInnerType.Kind <> TDataTypeKind.Function) then
          AWriter.Write('P');
        FInnerType.WriteSource(AWriter);
      end;

    TDataTypeKind.&Type:
      begin
        Assert(Assigned(FInnerType));
        FInnerType.WriteSource(AWriter);
      end;

    TDataTypeKind.Function:
      WriteFunction(AWriter);

    TDataTypeKind.Array:
      if (AForArgument) then
      begin
        AWriter.Write('P');
        Assert(FInnerType <> nil);
        FInnerType.WriteSource(AWriter, True);
      end
      else
        WriteArray(AWriter, False);
  else
    Assert(False);
  end;
end;

{ TDataType }

constructor TDataType.Create(const AParent: TDomNode);
begin
  inherited;
  FDescription := TTypeDescription.Create(Self);
end;

class constructor TDataType.Create;
begin
  GCustomTypes := TDictionary<String, String>.Create;
  GCustomTypes.Add('const char* (*getter)(void* user_data, int idx)', 'TImGuiStringGetter');
  GCustomTypes.Add('float (*values_getter)(void* data, int idx)', 'TImGuiValueGetter');
end;

destructor TDataType.Destroy;
begin
  FDetails.Free;
  FDescription.Free;
  inherited;
end;

class destructor TDataType.Destroy;
begin
  GCustomTypes.Free;
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

procedure TDataType.LoadChildren(const AParent: TJsonValue);
begin
  inherited;
  if (FDetails <> nil) and (FDetails.FFlavor = TTypeFlavor.FunctionPointer) then
    GCustomTypes.TryGetValue(FDeclaration, FDelphiTypeName);
end;

procedure TDataType.WriteCApi(const AWriter: TSourceWriter);
begin
  FDescription.WriteCApi(AWriter);
end;

procedure TDataType.WriteSource(const AWriter: TSourceWriter;
  const AForArgument: Boolean);
begin
  if (FDelphiTypeName = '') then
    FDescription.WriteSource(AWriter, AForArgument)
  else
    AWriter.Write(FDelphiTypeName);
end;

{ TDefine }

function TDefine.Ignore: Boolean;
begin
  { Ignore defines without content, or which look like functions. }
  Result := inherited or (FContent = '') or (FContent.IndexOf('(') >= 0);
  if (not Result) then
  begin
    { Ignore defines that are identifiers }
    var C := FContent.Chars[0];
    Result := (C = '_') or ((C >= 'A') and (C <= 'Z')) or ((C >= 'a') and (C <= 'z'));
  end;
end;

procedure TDefine.LoadChild(const AName: String; const AValue: TJsonValue);
begin
  if (AName = 'content') then
    FContent := AValue.ToString
  else
    inherited;
end;

procedure TDefine.WriteCApi(const AWriter: TSourceWriter);
begin
  AWriter.Write('_');
  WriteSource(AWriter);
end;

procedure TDefine.WriteSource(const AWriter: TSourceWriter);
begin
  AWriter.Write(FName);
  AWriter.Write(' = ');
  if (FContent <> '') and (FContent.Chars[0] = '"') then
  begin
    Assert(FContent.Chars[FContent.Length - 1] = '"');
    AWriter.Write('''');
    AWriter.Write(FContent.Substring(1, FContent.Length - 2));
    AWriter.Write('''');
  end
  else if (FContent.StartsWith('0x', True)) then
  begin
    AWriter.Write('$');
    AWriter.Write(FContent.Substring(2));
  end
  else
    AWriter.Write(FContent);
  AWriter.WriteLn(';');
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

procedure TEnumElement.Loaded;
begin
  inherited;
  Assert((FParent <> nil) and (FParent.FParent is TEnum));
  var Prefix := TEnum(FParent.FParent).Name;
  if (FName.StartsWith(Prefix)) then
    FNameWithoutPrefix := FName.Substring(Length(Prefix))
  else
    FNameWithoutPrefix := FName;
end;

procedure TEnumElement.WriteSource(const AWriter: TSourceWriter;
  const AIsFlag: Boolean);
begin
  AWriter.Write(ToValidId(FNameWithoutPrefix, True));
  AWriter.Write(' = ');
  if (AIsFlag) then
    AWriter.Write(LogTwo(FValue).ToString)
  else
    AWriter.Write(FValue.ToString);
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

procedure TEnum.Loaded;
begin
  inherited;
  if (FName.EndsWith('_')) then
    FName := FName.Substring(0, FName.Length - 1);
end;

procedure TEnum.WriteCApi(const AWriter: TSourceWriter);
begin
  AWriter.Write('_');
  AWriter.Write(FName);
  AWriter.WriteLn(' = Integer;');
end;

procedure TEnum.WriteCountConst(const AWriter: TSourceWriter);
begin
  for var I := FElements.Count - 1 downto 0 do
  begin
    var E := FElements[I];
    if (E.IsCount) then
    begin
      AWriter.Write('_');
      AWriter.Write(E.FName);
      AWriter.WriteLn(' = %d;', [E.FValue]);
      Break;
    end;
  end;
end;

procedure TEnum.WriteSetSource(const AWriter: TSourceWriter);
begin
  var Name := ToDelphiType(FName);
  if (not Name.EndsWith('Flags')) then
    Assert(False, 'Enum set name must end with "Flags"');

  var BaseName := Name.Substring(0, Name.Length - 1);

  AWriter.StartSection('type');
  WriteCommentBefore(AWriter);
  AWriter.Write(BaseName);
  AWriter.WriteLn(' = (');
  AWriter.Indent;

  { Write all flag values }
  var All: TArray<String> := nil;
  var PrevElement: TEnumElement := nil;
  var HasFlagCombinations := False;
  var MaxValue: Int64 := 0;
  AWriter.StartCommentAlignment;
  for var Element in FElements do
  begin
    if (Element.IsCount) or (Element.IsInternal) then
      Continue;

    if IsPowerOfTwo(Element.Value) then
    begin
      { This is a single flag }
      if (PrevElement <> nil) then
      begin
        AWriter.Write(',');
        PrevElement.WriteCommentAfter(AWriter);
      end;

      Element.WriteCommentBefore(AWriter);
      Element.WriteSource(AWriter, True);
      MaxValue := Max(MaxValue, LogTwo(Element.Value));
      All := All + [Element.Name];
      PrevElement := Element;
    end
    else
      { This is a combination of flags }
      HasFlagCombinations := True;
  end;

  if (MaxValue < 24) then
  begin
    { Even with MINENUMSIZE 4, sets are not guaranteed to be at least 4 bytes
      in size. So we need to add a dummy value to make sure it is. }
    if (PrevElement <> nil) then
    begin
      AWriter.Write(',');
      PrevElement.WriteCommentAfter(AWriter);
      PrevElement := nil;
    end;

    AWriter.Write('_ = 31');
  end;

  AWriter.Write(');');
  if (PrevElement = nil) then
    WriteCommentAfter(AWriter)
  else
    PrevElement.WriteCommentAfter(AWriter);
  AWriter.EndCommentAlignment;

  AWriter.Outdent;

  AWriter.WriteLn('%s = set of %s;', [Name, BaseName]);

  if (HasFlagCombinations) then
  begin
    AWriter.WriteLn;
    AWriter.WriteLn('_%sHelper = record helper for %0:s', [Name]);
    AWriter.WriteLn('public const');
    AWriter.Indent;

    for var Element in FElements do
    begin
      if (Element.IsCount) or (Element.IsInternal) then
        Continue;

      if (not IsPowerOfTwo(Element.Value)) then
      begin
        { This a combination of flags }
        var Replacement := '';

        { Default handling }
        AWriter.Write(Element.NameWithoutPrefix);
        AWriter.Write(' = ');

        if (Element.Value = 0) then
          AWriter.Write('[];')
        else
        begin
          AWriter.Write('[');

          var First := True;
          var TotalValue: Int64 := 0;
          for var Other in FElements do
          begin
            if (Other <> Element) and (IsPowerOfTwo(Other.Value)) and ((Element.Value and Other.Value) = Other.Value) then
            begin
              if (First) then
                First := False
              else
                AWriter.Write(', ');

              AWriter.Write(BaseName);
              AWriter.Write('.');
              AWriter.Write(Other.NameWithoutPrefix);
              TotalValue := TotalValue or Other.Value;
            end;
          end;
          if (TotalValue <> Element.Value) then
            Assert(False, 'Invalid flags element: total value doesn''t add up');

          AWriter.Write('];');
        end;
        Element.WriteCommentAfter(AWriter);
      end;
    end;

    AWriter.Outdent;
    AWriter.WriteLn('end;');
  end;

  AWriter.EndSection;
end;

procedure TEnum.WriteSource(const AWriter: TSourceWriter);
begin
  if (FIsInternal) then
    Exit;

  if (FIsFlags) then
  begin
    WriteSetSource(AWriter);
    Exit;
  end;

  AWriter.StartSection('type');
  WriteCommentBefore(AWriter);
  AWriter.Write(ToDelphiType(Name));
  AWriter.WriteLn(' = (');
  AWriter.Indent;
  AWriter.StartCommentAlignment;
  var LastElement: TEnumElement := nil;
  for var I := 0 to FElements.Count - 1 do
  begin
    var Element := FElements[I];
    if (Element.IsCount) or (Element.IsInternal) then
      Continue;

    if (LastElement <> nil) then
    begin
      AWriter.Write(',');
      LastElement.WriteCommentAfter(AWriter);
    end;

    Element.WriteCommentBefore(AWriter);
    Element.WriteSource(AWriter, False);
    LastElement := Element;
  end;
  AWriter.Write(');');
  if (LastElement <> nil) then
    LastElement.WriteCommentAfter(AWriter)
  else
    WriteCommentAfter(AWriter);
  AWriter.EndCommentAlignment;

  AWriter.Outdent;
  AWriter.EndSection;
end;

{ TEnums }

procedure TEnums.WriteSource(const AWriter: TSourceWriter);
begin
  for var Enum in Self do
    Enum.WriteSource(AWriter);
end;

{ TTypedef }

constructor TTypedef.Create;
begin
  inherited;
  FDataType := TDataType.Create(Self);
end;

class constructor TTypedef.Create;

  procedure AddBuiltin(const AName: String; const AType: TBuiltinType);
  begin
    var Customization: TCustomization;
    Customization.UserType := '';
    Customization.BuiltinType := AType;
    GCustomizations.Add(AName, Customization);
  end;

  procedure AddUser(const AName, AUserType: String;
    const ABuiltinType: TBuiltinType);
  begin
    var Customization: TCustomization;
    Customization.UserType := AUserType;
    Customization.BuiltinType := ABuiltinType;
    GCustomizations.Add(AName, Customization);
  end;

begin
  GCustomizations := TDictionary<String, TCustomization>.Create;

  { Change these to Builtin types so they get expanded to their Delphi type (and
    they won't show up as type definitions at the top of the unit. }
  AddBuiltin('ImWchar16', TBuiltinType.WChar16);
  AddBuiltin('ImWchar32', TBuiltinType.WChar32);
  AddBuiltin('ImWchar', TBuiltinType.WChar16);

  { Change these to User types so they do NOT get expanded to their Delphi type
    (and they WILL show up as type definitions at the top of the unit.
    NOTE: We can skip enums here }
  AddUser('ImDrawIdx', 'ImU16', TBuiltinType.UnsignedShort);
  AddUser('ImGuiID', 'ImU32', TBuiltinType.UnsignedInt);
  AddUser('ImGuiKeyChord', 'ImS32', TBuiltinType.Int);
  AddUser('ImFontAtlasRectId', 'ImS32', TBuiltinType.Int);
end;

destructor TTypedef.Destroy;
begin
  FDataType.Free;
  inherited;
end;

procedure TTypedef.FixupSource;
begin
  var Customization: TCustomization;
  if (GCustomizations.TryGetValue(FName, Customization)) then
  begin
    var Desc := FDataType.FDescription;
    if (Customization.UserType = '') then
    begin
      { Change these to Builtin types so they get expanded to their Delphi type
        (and they won't show up as type definitions at the top of the unit. }
      Desc.FKind := TDataTypeKind.Builtin;
      Desc.FBuiltinType := Customization.BuiltinType;
    end
    else
    begin
      { Change these to User types so they do NOT get expanded to their Delphi
        type (and they WILL show up as type definitions at the top of the unit. }
      Assert(Desc.FKind = TDataTypeKind.Builtin);
      Assert(Desc.FBuiltinType = Customization.BuiltinType);
      Desc.FKind := TDataTypeKind.User;
      Desc.FName := Customization.UserType;
    end;
  end;
end;

class destructor TTypedef.Destroy;
begin
  GCustomizations.Free;
end;

function TTypedef.GetIsBuiltinType: Boolean;
begin
  Result := (FDataType.Description.Kind = TDataTypeKind.Builtin);
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

procedure TTypedef.WriteSource(const AWriter: TSourceWriter);
begin
  if (IsBuiltinType) then
    Exit;

  WriteCommentBefore(AWriter);
  AWriter.Write('T');
  AWriter.Write(FName);
  AWriter.Write(' = ');
  FDataType.WriteSource(AWriter);
  AWriter.Write(';');
  WriteCommentAfter(AWriter);

  AWriter.WriteLn('P%s = ^T%0:s;', [FName]);
end;

{ TTypedefs }

procedure TTypedefs.Fixup;
{ Remove typedefs that have a corresponding enum }
begin
  var Dom := TDom.Instance;
  for var I := Count - 1 downto 0 do
  begin
    var Typedef := Items[I];
    if (Dom.Enums.Has(Typedef.Name)) or (Dom.Enums.Has(Typedef.Name + '_')) then
    begin
      FItemsByName.Remove(Typedef.Name);
      FItems.Delete(I);
    end;
  end;
end;

procedure TTypedefs.FixupSource;
begin
  for var Typedef in Self do
    Typedef.FixupSource;
end;

procedure TTypedefs.WriteSource(const AWriter: TSourceWriter);
begin
  AWriter.StartSection('type');
  for var Typedef in Self do
    Typedef.WriteSource(AWriter);
  AWriter.EndSection;
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

procedure TField.WriteAnonymous(const AWriter: TSourceWriter);
begin
  var Name := FName;
  for var I := Name.Length - 1 downto 0 do
  begin
    var C := Name.Chars[I];
    if (C < '0') or (C > '9') then
    begin
      Name := 'A' + Name.Substring(I + 1);
      Break;
    end;
  end;

  AWriter.Write(Name);
  AWriter.WriteLn(': record case Byte of');

  var Union := TDom.Instance.Structs.Get(FFieldType.Declaration);
  Assert((Union <> nil) and (Union.FKind = TStructKind.Union));

  for var I := 0 to Union.Fields.Count - 1 do
  begin
    var Field := Union.Fields[I];
    if (Field.FWidth > 0) then
      Continue;

    AWriter.Write('      %d: (', [I]);
    Field.WriteSource(AWriter);
    AWriter.WriteLn(');');
  end;
  AWriter.Write('    end');
end;

procedure TField.WriteCApi(const AWriter: TSourceWriter);
begin
  Assert(FWidth = 0, 'Fields with bit widths are handled elsewhere');

  AWriter.Write('_');
  AWriter.Write(FName);
  AWriter.Write(': ');

  if (FCombinedType <> '') then
    AWriter.Write(FCombinedType)
  else
    FFieldType.WriteCApi(AWriter);
end;

procedure TField.WriteGetter(const AWriter: TSourceWriter;
  const AStructName: String);
begin
  Assert(FFlagsField <> nil);
  var FlagsName := '_' + ToValidId(FFlagsField.FName, True);

  AWriter.WriteLn;
  AWriter.WriteLn('function T%s.Get%s: Cardinal;', [AStructName, FName]);
  AWriter.WriteLn('begin');
  AWriter.Indent;

  AWriter.Write('Result := ');
  if (FBitOffset = 0) then
    AWriter.Write(FlagsName)
  else
    AWriter.Write('(%s shr %d)', [FlagsName, FBitOffset]);

  AWriter.WriteLn(' and $%x;', [(1 shl FWidth) - 1]);
  AWriter.Outdent;
  AWriter.WriteLn('end;');
end;

procedure TField.WriteSetter(const AWriter: TSourceWriter;
  const AStructName: String);
begin
  Assert(FFlagsField <> nil);
  var FlagsName := '_' + ToValidId(FFlagsField.FName, True);

  AWriter.WriteLn;
  AWriter.WriteLn('procedure T%s.Set%s(const AValue: Cardinal);', [AStructName, FName]);
  AWriter.WriteLn('begin');
  AWriter.Indent;

  AWriter.Write('%s := (%0:s and $%x)', [FlagsName, not (((1 shl FWidth) - 1) shl FBitOffset)]);
  if (FBitOffset = 0) then
    AWriter.WriteLn(' or (AValue and $%x);', [(1 shl FWidth) - 1])
  else
    AWriter.WriteLn(' or ((AValue and $%x) shl %d);', [(1 shl FWidth) - 1, FBitOffset]);

  AWriter.Outdent;
  AWriter.WriteLn('end;');
end;

procedure TField.WriteSource(const AWriter: TSourceWriter);
begin
  Assert(FWidth = 0);
  WriteCommentBefore(AWriter);
  if (FIsAnonymous) then
  begin
    WriteAnonymous(AWriter);
    Exit;
  end;

  if (FCombinedType <> '') then
    AWriter.Write('_');

  AWriter.Write(ToValidId(FName, True));
  AWriter.Write(': ');
  if (FCombinedType <> '') then
    AWriter.Write(FCombinedType)
  else
    FFieldType.WriteSource(AWriter);
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

procedure TStruct.Loaded;
{ Check for bitfields and add a combined field for sequences of bitfields }
begin
  inherited;
  FCApiOnly := (FName = 'ImColor') or (FName = 'ImVec2') or (FName = 'ImVec4')
    or (FOriginalFullyQualifiedName.IndexOf('<') > 0);

  var I := FName.IndexOf('_');
  if (I > 0) and (FOriginalFullyQualifiedName.IndexOf('::') = I) then
    FName := FName.Substring(I + 1);

  I := 0;
  while (I < FFields.Count) do
  begin
    var Field := FFields[I];
    if (Field.FWidth > 0) then
    begin
      var BitCount := Field.FWidth;
      var J := I + 1;
      while (J < FFields.Count) do
      begin
        Field := FFields[J];
        if (Field.FWidth <= 0) then
          Break;

        Inc(BitCount, Field.FWidth);
        Inc(J);
      end;

      var FlagsField := TField.Create;
      FlagsField.FParent := Self;
      FlagsField.FName := Format('flags%d', [I]);

      if (BitCount <= 8) then
        FlagsField.FCombinedType := 'UInt8'
      else if (BitCount <= 16) then
        FlagsField.FCombinedType := 'UInt16'
      else if (BitCount <= 24) then
      else if (BitCount <= 32) then
        FlagsField.FCombinedType := 'UInt32';

      if (FlagsField.FCombinedType = '') then
        Assert(False, Format('Unsupported combined bitcount: %d', [BitCount]));

      BitCount := 0;
      J := I;
      while (J < FFields.Count) do
      begin
        Field := FFields[J];
        if (Field.FWidth <= 0) then
          Break;

        Field.FFlagsField := FlagsField;
        Field.FBitOffset := BitCount;
        Inc(BitCount, Field.FWidth);
        Inc(J);
      end;

      FFields.FItems.Insert(I, FlagsField);
      I := J;
    end;
    Inc(I);
  end;
end;

procedure TStruct.WriteCApi(const AWriter: TSourceWriter);
begin
  AWriter.Write('_');
  AWriter.Write(FName);
  AWriter.WriteLn(' = record');

  if (FKind = TStructKind.Union) then
    AWriter.WriteLn('case Byte of');

  AWriter.Indent;
  for var I := 0 to FFields.Count - 1 do
  begin
    var Field := FFields[I];
    if (Field.FWidth > 0) then
      Continue;

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

procedure TStruct.WriteForwardDeclarations(const AWriter: TSourceWriter);
begin
  if (FCApiOnly) or (FIsAnonymous) then
    Exit;

  AWriter.WriteLn('T%sPtr = ^T%0:s;', [FName]);
  AWriter.WriteLn('P%s = ^T%0:s;', [FName]);
  AWriter.WriteLn('PP%s = ^P%0:s;', [FName]);
end;

procedure TStruct.WriteImplementation(const AWriter: TSourceWriter);
begin
  if (FCApiOnly) or (FIsAnonymous) then
    Exit;

  Assert(FKind = TStructKind.Struct);

  var Functions := TDom.Instance.GetFunctionsForStruct(FName, False);
  if (Functions = nil) and (not FHasFields) then
    Exit;

  AWriter.WriteLn;
  if (FName = '') then
    AWriter.WriteLn('{ ImGui }')
  else
    AWriter.WriteLn('{ T%s }', [FName]);

  if (FName <> '') and (FHasFields) then
  begin
    AWriter.WriteLn;
    AWriter.WriteLn('procedure T%s.Initialize;', [FName]);
    AWriter.WriteLn('begin');
    AWriter.Indent;
    AWriter.WriteLn('FillChar(Self, SizeOf(Self), 0);');
    AWriter.Outdent;
    AWriter.WriteLn('end;');
  end;

  if (FHasBitFields) then
  begin
    for var Field in FFields do
    begin
      if (Field.FWidth <= 0) then
        Continue;

      Field.WriteGetter(AWriter, FName);
      Field.WriteSetter(AWriter, FName);
    end;
  end;

  for var Func in Functions do
    Func.WriteSource(AWriter, FName, True, False);
end;

procedure TStruct.WriteInitialization(const AWriter: TSourceWriter);
begin
  if (FCApiOnly) or (FIsAnonymous) then
    Exit;

  Assert(FKind = TStructKind.Struct);
  AWriter.WriteLn('Assert(SizeOf(T%s) = SizeOf(_%0:s));', [FName]);
end;

procedure TStruct.WriteInterface(const AWriter: TSourceWriter);
begin
  if (FCApiOnly) or (FIsAnonymous) then
    Exit;

  Assert(FKind = TStructKind.Struct);
  WriteCommentBefore(AWriter);
  if (FName = '') then
  begin
    AWriter.WriteLn('// Main ImGui interface');
    AWriter.WriteLn('ImGui = record');
  end
  else
    AWriter.WriteLn('T%s = record', [FName]);

  FHasFields := False;
  FHasBitFields := False;
  if (FFields.Count > 0) then
  begin
    AWriter.WriteLn('public');
    AWriter.Indent;
    AWriter.StartCommentAlignment;
    for var Field in FFields do
    begin
      if (Field.FWidth > 0) then
      begin
        FHasBitFields := True;
        Continue;
      end;

      Field.WriteSource(AWriter);
      AWriter.Write(';');
      Field.WriteCommentAfter(AWriter);
      FHasFields := True;
    end;
    AWriter.EndCommentAlignment;
    AWriter.Outdent;
  end;

  if (FHasBitFields) then
  begin
    AWriter.WriteLn('{$REGION ''Internal Declarations''}');
    AWriter.WriteLn('private');
    AWriter.Indent;
    for var Field in FFields do
    begin
      if (Field.FWidth <= 0) then
        Continue;

      AWriter.WriteLn('function Get%s: Cardinal; inline;', [Field.Name]);
      AWriter.WriteLn('procedure Set%s(const AValue: Cardinal); inline;', [Field.Name]);
    end;
    AWriter.Outdent;
    AWriter.WriteLn('{$ENDREGION ''Internal Declarations''}');

    AWriter.WriteLn('public');
    AWriter.Indent;
    for var Field in FFields do
    begin
      if (Field.FWidth <= 0) then
        Continue;

      AWriter.Write('property %s: Cardinal read Get%0:s write Set%0:s;', [Field.Name]);
      Field.WriteCommentAfter(AWriter);
    end;
    AWriter.Outdent;
    FHasFields := True;
  end;

  var Functions := TDom.Instance.GetFunctionsForStruct(FName, True);
  if (FHasFields) or (Functions <> nil) then
  begin
    AWriter.WriteLn('public');
    AWriter.Indent;

    if (FName <> '') then
    begin
      AWriter.WriteLn('// Zero-initializes all fields');
      AWriter.WriteLn('procedure Initialize; inline;');
    end;

    if (Functions <> nil) then
    begin
      if (FName <> '') then
        AWriter.WriteLn;

      for var I := 0 to Length(Functions) - 1 do
        Functions[I].WriteSource(AWriter, FName, False, (I = 0));
    end;
    AWriter.Outdent;
  end;

  AWriter.Write('end;');
  WriteCommentAfter(AWriter);
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
    for var I := 0 to Count - 1 do
    begin
      if (Items[I].Name = AName) then
        Exit(I);
    end;
    Result := -1;
  end;

  procedure AnalyzeType(const ASrcIndex: Integer; const AName: String);
  begin
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
    var SrcIndex := FindStruct(ASrc.Name);
    Assert(SrcIndex >= 0);

    for var Field in ASrc.FFields do
    begin
      var TypeName := Field.FieldType.Declaration;
      if (TypeName.StartsWith('ImVector_')) then
        TypeName := TypeName.Substring(9);

      AnalyzeType(SrcIndex, TypeName);
    end;
  end;

begin
  for var Struct in ASource do
    AnalyzeStruct(Struct);
end;

procedure TStructs.WriteForwardDeclarations(const AWriter: TSourceWriter);
begin
  AWriter.Indent;

  for var Struct in Self do
    Struct.WriteForwardDeclarations(AWriter);

  AWriter.Outdent;
end;

procedure TStructs.WriteImGuiImplementation(const AWriter: TSourceWriter);
begin
  var Struct := TStruct.Create;
  try
    Struct.WriteImplementation(AWriter);
  finally
    Struct.Free;
  end;
end;

procedure TStructs.WriteImGuiInterface(const AWriter: TSourceWriter);
begin
  AWriter.Indent(True);

  var Struct := TStruct.Create;
  try
    Struct.WriteInterface(AWriter);
  finally
    Struct.Free;
  end;

  AWriter.Outdent;
end;

procedure TStructs.WriteImplementations(const AWriter: TSourceWriter);
begin
  for var Struct in Self do
    Struct.WriteImplementation(AWriter);
end;

procedure TStructs.WriteInitialization(const AWriter: TSourceWriter);
begin
  AWriter.Indent;

  for var Struct in Self do
    Struct.WriteInitialization(AWriter);

  AWriter.Outdent;
end;

procedure TStructs.WriteInterfaces(const AWriter: TSourceWriter);
begin
  AWriter.Indent(True);

  for var Struct in Self do
    Struct.WriteInterface(AWriter);

  AWriter.Outdent;
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

function TFunction.Ignore: Boolean;
begin
  { Ignore some special helper functions that are not exported }
  Result := inherited or FIsUnformattedHelper or FIsManualHelper;
  if (not Result) then
  begin
    { Ignore functions with a "va_list" argument }
    for var Arg in FArguments do
    begin
      if (Arg.FDataType.FDeclaration = 'va_list') then
        Exit(True);
    end;
  end;
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

  if (FOriginalClass = '') then
    { ImGui methods are always static }
    FIsStatic := True;

  TDom.Instance.AddFunctionForStruct(FOriginalClass, Self);
end;

procedure TFunction.WriteCApi(const AWriter: TSourceWriter);
begin
  Assert(not FIsUnformattedHelper, 'Should be ignored');

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

procedure TFunction.WriteSource(const AWriter: TSourceWriter;
  const AStructName: String; const AForImplementation,
  AFirst: Boolean);
begin
  var CustomOverloads := TDelphiOverloads.Instance.Get(FName);

  if (AForImplementation) then
    AWriter.WriteLn
  else
  begin
    if ((FPrecedingComments <> nil) or (FAttachedComment <> '')) and (not AFirst) then
      AWriter.WriteLn;

    WriteCommentBefore(AWriter);
    if (FAttachedComment <> '') then
      AWriter.WriteLn(FAttachedComment);
  end;

  if (FIsStatic) then
    AWriter.Write('class ');

  if (HasReturnType) then
    AWriter.Write('function ')
  else
    AWriter.Write('procedure ');

  if (AForImplementation) then
  begin
    if (FOriginalClass = '') then
      AWriter.Write('ImGui')
    else
    begin
      AWriter.Write('T');
      AWriter.Write(FOriginalClass);
    end;
    AWriter.Write('.');
  end;

  var Name := FOriginalFullyQualifiedName;
  if (Name = '') then
    Name := FName
  else
  begin
    var I := Name.LastIndexOf('::');
    if (I > 0) then
      Name := Name.Substring(I + 2);
  end;

  AWriter.Write(ToValidId(Name, True));

  var ArgCount := FArguments.Count;
  var ArgOffset := 0;
  if (not FIsStatic) and (FOriginalClass <> '') then
  begin
    { Skip Self argument }
    Assert(ArgCount > 0);
    Assert(FArguments[0].Name = 'self');
    Inc(ArgOffset);
    Dec(ArgCount);
  end;

  if (FArguments.IsVarArgs) then
  begin
    { We treat VarArgs functions as functions without VarArgs for now.
      Skip the last "..." VarArg parameter. }
    Assert(ArgCount > 0);
    Dec(ArgCount);
  end;

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
        WriteLn(FName);
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
    FArguments.WriteSource(AWriter, ArgOffset, ArgCount, AForImplementation);
    AWriter.Write(')');
  end;

  if (HasReturnType) then
  begin
    AWriter.Write(': ');
    FReturnType.WriteSource(AWriter);
  end;

  if (not AForImplementation) then
  begin
    if (FIsOverload) or (CustomOverloads <> nil) then
      AWriter.Write('; overload');

    AWriter.Write('; inline');

    if (FIsStatic) then
      AWriter.Write('; static');
  end;
  AWriter.WriteLn(';');

  if (not AForImplementation) then
  begin
    for var CustomOverload in CustomOverloads do
    begin
      var Intf := CustomOverload.Intf;
      if (Intf <> '*') then
        AWriter.WriteLn(CustomOverload.Intf);
    end;

    Exit;
  end;

  { Write method body }
  AWriter.WriteLn('begin');
  AWriter.Indent;

  var IsTypeCast := False;
  if (HasReturnType) then
  begin
    AWriter.Write('Result := ');
    var ReturnTypeName := FReturnType.FDescription.Name;
    if (ReturnTypeName.StartsWith('Im')) then
    begin
      FReturnType.WriteSource(AWriter);
      AWriter.Write('(');
      IsTypeCast := True;
    end;
  end;

  { Write C-API }
  AWriter.Write('_');
  AWriter.Write(FName);

  { Write arguments }
  var FirstArg := True;
  AWriter.Write('(');

  if (not FIsStatic) and (FOriginalClass <> '') then
  begin
    { Self argument }
    AWriter.Write('@Self');
    FirstArg := False;
  end;

  for var I := 0 to ArgCount - 1 do
  begin
    if (not FirstArg) then
      AWriter.Write(', ');

    var Arg := FArguments[ArgOffset + I];
    Arg.WriteSource(AWriter);

    FirstArg := False;
  end;

  AWriter.Write(')');

  if (IsTypeCast) then
    AWriter.Write(')');

  AWriter.WriteLn(';');

  AWriter.Outdent;
  AWriter.WriteLn('end;');

  for var CustomOverload in CustomOverloads do
  begin
    var Intf := CustomOverload.Intf;
    if (Intf = '*') then
      Continue;

    var IsFunction := False;

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
    if (AStructName = '') then
      Intf := Intf.Insert(I, 'ImGui.')
    else
      Intf := Intf.Insert(I, 'T' + AStructName + '.');

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

{ TDom }

procedure TDom.AddFunctionForStruct(const AStructName: String;
  const AFunction: TFunction);
begin
  var Functions: TList<TFunction>;
  if (not FFunctionsByStruct.TryGetValue(AStructName, Functions)) then
  begin
    Functions := TList<TFunction>.Create;
    FFunctionsByStruct.Add(AStructName, Functions);
  end;
  Functions.Add(AFunction);
end;

constructor TDom.Create;
begin
  inherited;
  GInstance := Self;
  FDefines := TDefines.Create(Self);
  FEnums := TEnums.Create(Self);
  FTypedefs := TTypedefs.Create(Self);
  FStructs := TStructs.Create(Self);
  FFunctions := TFunctions.Create(Self);
  FFunctionsByStruct := TObjectDictionary<String, TList<TFunction>>.Create([doOwnsValues]);
end;

destructor TDom.Destroy;
begin
  GInstance := nil;
  FFunctionsByStruct.Free;
  FFunctions.Free;
  FStructs.Free;
  FTypedefs.Free;
  FEnums.Free;
  FDefines.Free;
  inherited;
end;

function TDom.GetFunctionsForStruct(const AStructName: String;
  const ACheckOverloads: Boolean): TArray<TFunction>;
begin
  var Functions: TList<TFunction>;
  if (not FFunctionsByStruct.TryGetValue(AStructName, Functions)) then
    Exit(nil);

  if (ACheckOverloads) then
  begin
    { Check for overloaded functions }
    var SortedFunctions := Functions.ToArray;
    TArray.Sort<TFunction>(SortedFunctions, TComparer<TFunction>.Construct(
      function(const ALeft, ARight: TFunction): Integer
      begin
        Result := CompareText(ALeft.FOriginalFullyQualifiedName, ARight.FOriginalFullyQualifiedName);
      end));
    for var I := 0 to Length(SortedFunctions) - 2 do
    begin
      if (SortedFunctions[I].FOriginalFullyQualifiedName = SortedFunctions[I + 1].FOriginalFullyQualifiedName) then
      begin
        SortedFunctions[I].FIsOverload := True;
        SortedFunctions[I + 1].FIsOverload := True;
      end;
    end;
  end;

  Result := Functions.ToArray;
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
  FTypedefs.Fixup;
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

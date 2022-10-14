unit DelphiCustomizations;

interface

uses
  Neslib.Collections,
  Neslib.Json,
  SourceWriter;

type
  TCustomization = class
  {$REGION 'Internal Declarations'}
  private
    FName: String;
    FItems: TDictionary<String, String>;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AElement: PJsonElement);
    destructor Destroy; override;

    function Get(const AKey: String; out AValue: String): Boolean;

    { The name of the declaration to apply the customization too. }
    property Name: String read FName;
  end;

type
  TCustomizations = class
  {$REGION 'Internal Declarations'}
  private
    FItems: TObjectDictionary<String, TCustomization>;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load(const AValue: TJsonValue);
    function Get(const AName: String): TCustomization; inline;
  end;

type
  { Represents the "DelphiCustomizations.json" file. }
  TDelphiCustomizations = class
  {$REGION 'Internal Declarations'}
  private class var
    FInstance: TDelphiCustomizations;
  private
    FEnumFlags: TCustomizations;
    FTypes: TCustomizations;
    FStructMembers: TCustomizations;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load;
    procedure WriteCustomTypes(const AWriter: TSourceWriter);

    function GetDelphiType(const ACType: String): String;

    class property Instance: TDelphiCustomizations read FInstance;

    property EnumFlags: TCustomizations read FEnumFlags;
    property Types: TCustomizations read FTypes;
    property StructMembers: TCustomizations read FStructMembers;
  end;

implementation

uses
  System.SysUtils;

{ TCustomization }

constructor TCustomization.Create(const AElement: PJsonElement);
begin
  inherited Create;
  FItems := TDictionary<String, String>.Create;

  FName := AElement.Name;
  var Value := AElement.Value;
  Assert(Value.IsDictionary);

  for var I := 0 to Value.Count - 1 do
  begin
    var Element := Value.Elements[I];
    FItems.Add(Element.Name, Element.Value.ToString);
  end;
end;

destructor TCustomization.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TCustomization.Get(const AKey: String;
  out AValue: String): Boolean;
begin
  Result := FItems.TryGetValue(AKey, AValue);
end;

{ TCustomizations }

constructor TCustomizations.Create;
begin
  inherited;
  FItems := TObjectDictionary<String, TCustomization>.Create([doOwnsValues]);
end;

destructor TCustomizations.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TCustomizations.Get(const AName: String): TCustomization;
begin
  FItems.TryGetValue(AName, Result);
end;

procedure TCustomizations.Load(const AValue: TJsonValue);
begin
  Assert(AValue.IsDictionary);
  FItems.Clear;
  for var I := 0 to AValue.Count - 1 do
  begin
    var Customization := TCustomization.Create(AValue.Elements[I]);
    FItems.Add(Customization.Name, Customization);
  end;
end;

{ TDelphiCustomizations }

constructor TDelphiCustomizations.Create;
begin
  inherited;
  Assert(FInstance = nil);
  FInstance := Self;

  FEnumFlags := TCustomizations.Create;
  FTypes := TCustomizations.Create;
  FStructMembers := TCustomizations.Create;
end;

destructor TDelphiCustomizations.Destroy;
begin
  Assert(FInstance = Self);
  FInstance := nil;

  FStructMembers.Free;
  FTypes.Free;
  FEnumFlags.Free;
  inherited;
end;

function TDelphiCustomizations.GetDelphiType(const ACType: String): String;
begin
  var Typ := FTypes.Get(ACType);
  if (Typ = nil) then
    Exit('');

  Typ.Get('Name', Result);
end;

procedure TDelphiCustomizations.Load;
begin
  var Doc := TJsonDocument.Load('DelphiCustomizations.json');
  var Root := Doc.Root;
  Assert(Root.IsDictionary);

  for var I := 0 to Root.Count - 1 do
  begin
    var Element := Root.Elements[I];
    var Customizations: TCustomizations := nil;
    if (Element.Name = 'EnumFlags') then
      Customizations := FEnumFlags
    else if (Element.Name = 'Types') then
      Customizations := FTypes
    else if (Element.Name = 'StructMembers') then
      Customizations := FStructMembers
    else
      Assert(False, 'Unknown element');

    if (Customizations <> nil) then
      Customizations.Load(Element.Value);
  end;
end;

procedure TDelphiCustomizations.WriteCustomTypes(const AWriter: TSourceWriter);
begin
  AWriter.Indent(True);

  for var Typ in FTypes.FItems.Values do
  begin
    var Name, Value: String;
    if (not Typ.Get('Name', Name)) then
      Assert(False, 'Custom type must have a "Name" element');
    if (not Typ.Get('Value', Value)) then
      Assert(False, 'Custom type must have a "Value" element');

    if (not Value.EndsWith(';')) then
      Value := Value + ';';

    AWriter.Write(Name);
    AWriter.Write(' = ');
    AWriter.WriteLn(Value);
  end;
  AWriter.Outdent;
end;

end.

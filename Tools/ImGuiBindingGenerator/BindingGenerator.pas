unit BindingGenerator;

interface

uses
  {$IFDEF TEST_OUTPUT}
  Neslib.ImGui,
  Neslib.Sokol.Api,
  {$ENDIF}
  Neslib.Json,
  Definitions,
  Enums,
  Structs,
  DelphiCustomizations,
  DelphiOverloads,
  SourceWriter;

type
  TBindingGenerator = class
  public class var
    HasWarnings: Boolean;
  {$REGION 'Internal Declarations'}
  private
    FDefinitions: TDefinitions;
    FEnums: TEnums;
    FStructs: TStructs;
    FCustomizations: TDelphiCustomizations;
    FOverloads: TDelphiOverloads;
  private
    procedure LoadLocations(const AValue: TJsonValue);
    procedure WritePascalSource;
  private
    procedure WriteTemplateSection(const ASectionName: String;
      const AWriter: TSourceWriter);
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    procedure Run;
  end;

implementation

uses
  System.SysUtils,
  TemplateHandler;

{ TBindingGenerator }

constructor TBindingGenerator.Create;
begin
  inherited;
  FDefinitions := TDefinitions.Create;
  FEnums := TEnums.Create;
  FStructs := TStructs.Create;
  FCustomizations := TDelphiCustomizations.Create;
  FOverloads := TDelphiOverloads.Create;
  HasWarnings := False;
end;

destructor TBindingGenerator.Destroy;
begin
  FOverloads.Free;
  FCustomizations.Free;
  FStructs.Free;
  FEnums.Free;
  FDefinitions.Free;
  inherited;
end;

procedure TBindingGenerator.LoadLocations(const AValue: TJsonValue);
begin
  Assert(AValue.IsDictionary);
  for var I := 0 to AValue.Count - 1 do
  begin
    var Element := AValue.Elements[I];
    var Location := Element.Value.ToString;
    if (Location <> '') and (not Location.StartsWith('imgui:')) then
    begin
      { This is an internal declaration }
      var Decl := Element.Name;
      if (Decl.EndsWith('_')) then
        SetLength(Decl, Decl.Length - 1);

      var Struct := FStructs.GetStructByName(Decl);
      if (Struct <> nil) then
        Struct.IsInternal := True
      else
      begin
        var Enum := FEnums.GetEnumByName(Decl);
        Assert(Assigned(Enum));
        Enum.IsInternal := True;
      end;
    end;
  end;
end;

procedure TBindingGenerator.Run;
begin
  FCustomizations.Load;
  FOverloads.Load;
  FDefinitions.Load;

  var Doc := TJsonDocument.Load('structs_and_enums.json');
  var Root := Doc.Root;
  FEnums.Load(Root.Values['enums']);
  FStructs.Load(Root.Values['structs']);
  LoadLocations(Root.Values['locations']);

  WritePascalSource;
end;

procedure TBindingGenerator.WritePascalSource;
begin
  var TemplateHandler := TTemplateHandler.Create(
    'Neslib.ImGui.Template.pas',
    '..\..\..\Neslib.ImGui.pas',
    WriteTemplateSection);
  try
    TemplateHandler.Run;
  finally
    TemplateHandler.Free;
  end;
end;

procedure TBindingGenerator.WriteTemplateSection(const ASectionName: String;
  const AWriter: TSourceWriter);
begin
  if (ASectionName = 'enums') then
    FEnums.Write(AWriter)
  else if (ASectionName = 'forwardstructdeclarations') then
    FStructs.WriteForwardDeclarations(AWriter)
  else if (ASectionName = 'customtypes') then
    FCustomizations.WriteCustomTypes(AWriter)
  else if (ASectionName = 'structinterfaces') then
    FStructs.WriteInterfaces(AWriter)
  else if (ASectionName = 'imguiinterface') then
    FStructs.WriteImGuiInterface(AWriter)
  else if (ASectionName = 'structimplementations') then
    FStructs.WriteImplementations(AWriter)
  else
    Assert(False, 'Unknown template section: ' + ASectionName);
end;

end.

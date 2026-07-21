unit IncludeFileGenerator;

interface

uses
  Dom,
  SourceWriter;

type
  TIncludeFileGenerator = class
  {$REGION 'Internal Declarations'}
  private
    FDom: TDom; // Reference
    FWriter: TSourceWriter;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const ADom: TDom);
    destructor Destroy; override;

    procedure Run;
  end;

implementation

uses
  IOUtils;

{ TIncludeFileGenerator }

constructor TIncludeFileGenerator.Create(const ADom: TDom);
begin
  inherited Create;
  FDom := ADom;
  FWriter := TSourceWriter.Create;
  Run;
end;

destructor TIncludeFileGenerator.Destroy;
begin
  FWriter.Free;
  inherited;
end;

procedure TIncludeFileGenerator.Run;
begin
  try
    FWriter.StartSection('type');
    FWriter.WriteLn('_size_t = NativeUInt;');
    for var TypeDef in FDom.Typedefs do
      TypeDef.WriteCApi(FWriter);
    FWriter.EndSection;

    FWriter.StartSection('type');
    for var Enum in FDom.Enums do
      Enum.WriteCApi(FWriter);
    FWriter.EndSection;

    FWriter.StartSection('const');
    for var Enum in FDom.Enums do
      Enum.WriteCountConst(FWriter);
    FWriter.EndSection;

    FWriter.StartSection('type');
    for var Struct in FDom.Structs do
      Struct.WriteCApi(FWriter);
    FWriter.EndSection;

    for var Func in FDom.Functions do
      Func.WriteCApi(FWriter);
  finally
    TFile.WriteAllText('..\..\..\Neslib.ImGui.inc', FWriter.ToString);
  end;
end;

end.

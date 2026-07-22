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
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const ADom: TDom);

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
  Run;
end;

procedure TIncludeFileGenerator.Run;
begin
  var Writer := TSourceWriter.Create;
  try
    try
      Writer.StartSection('type');
      Writer.WriteLn('// Typedefs');
      Writer.WriteLn('_size_t = NativeUInt;');
      for var TypeDef in FDom.Typedefs do
        TypeDef.WriteCApi(Writer);
      Writer.EndSection;

      Writer.StartSection('type');
      Writer.WriteLn('// Enums');
      for var Enum in FDom.Enums do
        Enum.WriteCApi(Writer);
      Writer.EndSection;

      Writer.StartSection('const');
      Writer.WriteLn('// Enum counts');
      for var Enum in FDom.Enums do
        Enum.WriteCountConst(Writer);
      Writer.EndSection;

      Writer.StartSection('const');
      Writer.WriteLn('// Defines');
      for var Define in FDom.Defines do
        Define.WriteCApi(Writer);
      Writer.EndSection;

      Writer.StartSection('type');
      Writer.WriteLn('// Structs');
      for var Struct in FDom.Structs do
        Struct.WriteCApi(Writer);
      Writer.EndSection;

      Writer.WriteLn('// APIs');
      for var Func in FDom.Functions do
        Func.WriteCApi(Writer);
    finally
      TFile.WriteAllText('..\..\..\Neslib.ImGui.inc', Writer.ToString);
    end;
  finally
    Writer.Free;
  end;
end;

end.

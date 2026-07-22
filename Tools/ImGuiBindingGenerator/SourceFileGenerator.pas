unit SourceFileGenerator;

interface

uses
  Dom;

type
  TSourceFileGenerator = class
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
  System.IOUtils,
  System.SysUtils,
  SourceWriter;

{ TSourceFileGenerator }

constructor TSourceFileGenerator.Create(const ADom: TDom);
begin
  inherited Create;
  FDom := ADom;
  Run;
end;

procedure TSourceFileGenerator.Run;
begin
  var Source := TFile.ReadAllText('Neslib.ImGui.Template.pas');
  try
    while (True) do
    begin
      var I := Source.IndexOf('<%');
      if (I < 0) then
        Break;

      var J := Source.IndexOf('%>', I);
      Assert((J > I) and ((J - I) < 50));

      var Section := Source.Substring(I + 2, J - I - 2).ToLower;
      Source := Source.Remove(I, J - I + 2);

      var Writer := TSourceWriter.Create;
      try
        if (Section = 'typedefs') then
          FDom.Typedefs.WriteSource(Writer)
        else if (Section = 'enums') then
          FDom.Enums.WriteSource(Writer)
        else if (Section = 'forwardstructdeclarations') then
          FDom.Structs.WriteForwardDeclarations(Writer)
        else if (Section = 'customtypes') then
          Assert(False, 'TODO')
        else if (Section = 'structinterfaces') then
          FDom.Structs.WriteInterfaces(Writer)
        else if (Section = 'imguiinterface') then
          Assert(False, 'TODO')
        else if (Section = 'structimplementations') then
          Assert(False, 'TODO')
        else
          Assert(False, 'Unknown template section: ' + Section);

        Section := Writer.ToString.TrimRight;
      finally
        Writer.Free;
      end;

      Source := Source.Insert(I, Section);
    end;
  finally
    TFile.WriteAllText('..\..\..\Neslib.ImGui.pas', Source);
  end;
end;

end.

unit TemplateHandler;

interface

uses
  SourceWriter;

type
  TWriteTemplateSectionEvent = procedure(const ASectionName: String;
    const AWriter: TSourceWriter) of object;

type
  TTemplateHandler = class
  {$REGION 'Internal Declarations'}
  private
    FSource: String;
    FOutputFilename: String;
    FOnWriteSection: TWriteTemplateSectionEvent;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const ATemplateFilename, AOututFilename: String;
      const AOnWriteSection: TWriteTemplateSectionEvent);

    procedure Run;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils;

{ TTemplateHandler }

constructor TTemplateHandler.Create(const ATemplateFilename,
  AOututFilename: String; const AOnWriteSection: TWriteTemplateSectionEvent);
begin
  Assert(Assigned(AOnWriteSection));
  inherited Create;
  FSource := TFile.ReadAllText(ATemplateFilename);
  FOutputFilename := AOututFilename;
  FOnWriteSection := AOnWriteSection;
end;

procedure TTemplateHandler.Run;
begin
  while (True) do
  begin
    var I := FSource.IndexOf('<%');
    if (I < 0) then
      Break;

    var J := FSource.IndexOf('%>', I);
    Assert((J > I) and ((J - I) < 50));

    var Section := FSource.Substring(I + 2, J - I - 2).ToLower;
    FSource := FSource.Remove(I, J - I + 2);

    var Writer := TSourceWriter.Create;
    try
      FOnWriteSection(Section, Writer);
      Section := Writer.ToString.TrimRight;
    finally
      Writer.Free;
    end;

    FSource := FSource.Insert(I, Section);
  end;
  TFile.WriteAllText(FOutputFilename, FSource);
end;

end.

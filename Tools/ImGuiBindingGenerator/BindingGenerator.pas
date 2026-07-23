unit BindingGenerator;

interface

uses
  {$IFDEF TEST_OUTPUT}
  Neslib.ImGui,
  {$ENDIF}
  DelphiOverloads,
  Dom;

type
  TBindingGenerator = class
  {$REGION 'Internal Declarations'}
  private class var
    GHasWarnings: Boolean;
  private
    FDom: TDom;
    FOverloads: TDelphiOverloads;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    procedure Run;

    class property HasWarnings: Boolean read GHasWarnings write GHasWarnings;
  end;

implementation

uses
  IncludeFileGenerator,
  SourceFileGenerator;

{ TBindingGenerator }

constructor TBindingGenerator.Create;
begin
  inherited Create;
  FDom := TDom.Create;
  FOverloads := TDelphiOverloads.Create;
  GHasWarnings := False;
end;

destructor TBindingGenerator.Destroy;
begin
  FOverloads.Free;
  FDom.Free;
  inherited;
end;

procedure TBindingGenerator.Run;
begin
  FOverloads.Load;
  FDom.Load;

  TIncludeFileGenerator.Create(FDom).Free;
  TSourceFileGenerator.Create(FDom).Free;
end;

end.

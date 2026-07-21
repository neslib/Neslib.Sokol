unit BindingGenerator;

interface

uses
  {$IFDEF TEST_OUTPUT}
  Neslib.ImGui,
  {$ENDIF}
  Dom;

type
  TBindingGenerator = class
  {$REGION 'Internal Declarations'}
  private class var
    GHasWarnings: Boolean;
  private
    FDom: TDom;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    procedure Run;

    class property HasWarnings: Boolean read GHasWarnings;
  end;

implementation

uses
  IncludeFileGenerator;

{ TBindingGenerator }

constructor TBindingGenerator.Create;
begin
  inherited Create;
  FDom := TDom.Create;
  GHasWarnings := False;
end;

destructor TBindingGenerator.Destroy;
begin
  FDom.Free;
  inherited;
end;

procedure TBindingGenerator.Run;
begin
  FDom.Load;

  TIncludeFileGenerator.Create(FDom).Free;
end;

end.

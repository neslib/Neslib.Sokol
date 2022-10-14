unit DelphiOverloads;

interface

uses
  Neslib.Collections,
  Neslib.Json;

type
  TOverload = record
  public
    Intf: String;
    Impl: String;
  end;

type
  TOverloads = TArray<TOverload>;

type
  TDelphiOverloads = class
  {$REGION 'Internal Declarations'}
  private class var
    FInstance: TDelphiOverloads;
  private
    FItems: TDictionary<String, TOverloads>;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load;
    function Get(const AName: String): TOverloads; inline;

    class property Instance: TDelphiOverloads read FInstance;
  end;

implementation

{ TDelphiOverloads }

constructor TDelphiOverloads.Create;
begin
  inherited;
  Assert(FInstance = nil);
  FInstance := Self;

  FItems := TDictionary<String, TOverloads>.Create;
end;

destructor TDelphiOverloads.Destroy;
begin
  Assert(FInstance = Self);
  FInstance := nil;

  FItems.Free;
  inherited;
end;

function TDelphiOverloads.Get(const AName: String): TOverloads;
begin
  FItems.TryGetValue(AName, Result);
end;

procedure TDelphiOverloads.Load;
begin
  var Doc := TJsonDocument.Load('DelphiOverloads.json');
  var Root := Doc.Root;
  Assert(Root.IsDictionary);

  for var I := 0 to Root.Count - 1 do
  begin
    var Element := Root.Elements[I];
    var CApiName := Element.Name;
    var SrcOverloads := Element.Value;
    Assert(SrcOverloads.IsArray);

    var DstOverloads: TOverloads;
    SetLength(DstOverloads, SrcOverloads.Count);

    for var J := 0 to Length(DstOverloads) - 1 do
    begin
      var SrcOverload := SrcOverloads.Items[J];
      Assert(SrcOverload.IsDictionary);

      var DstOverload: TOverload;
      DstOverload.Intf := SrcOverload.Values['intf'].ToString;
      Assert(DstOverload.Intf <> '');
      DstOverload.Impl := SrcOverload.Values['impl'].ToString;
      Assert(DstOverload.Impl <> '');

      DstOverloads[J] := DstOverload;
    end;

    FItems.Add(CApiName, DstOverloads);
  end;
end;

end.

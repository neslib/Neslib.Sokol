unit  SourceWriter;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections;

type
  { Class for writing Pascal source code }
  TSourceWriter = class
  {$REGION 'Internal Declarations'}
  private type
    TComment = record
    public
      Text: String;
      Position: Integer;
      Column: Integer;
    end;
  private
    FMainWriter: TStringWriter;
    FCommentWriter: TStringWriter;
    FWriter: TStringWriter;
    FIndent: String;
    FSection: String;
    FComments: TList<TComment>;
    FColumn: Integer;
    FPosition: Integer;
    FMaxColumn: Integer;
    FNeedIndent: Boolean;
    FLastLineEmpty: Boolean;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    { Starts a section with grouped declarations, such as a 'const', 'type'
      or 'uses' section.

      Parameters:
        ASection: name of the section.

      The section will actually only be started if any text is written before
      EndSection is called. }
    procedure StartSection(const ASection: String);

    { Ends a section started with StartSection. }
    procedure EndSection;

    { Increases indentation level with two spaces. }
    procedure Indent(const AImmediately: Boolean = False);

    { Decreases indentation level by two spaces. }
    procedure Outdent;

    { Writes a string.

      Parameters:
        AValue: the string to write.
        AArgs: (optional) arguments in case AValue is a format string. }
    procedure Write(const AValue: String); overload;
    procedure Write(const AValue: String; const AArgs: array of const); overload;

    { Writes a single new line. }
    procedure WriteLn; overload;

    { Writes a string followed by a new line.

      Parameters:
        AValue: the string to write.
        AArgs: (optional) arguments in case AValue is a format string. }
    procedure WriteLn(const AValue: String); overload;
    procedure WriteLn(const AValue: String; const AArgs: array of const); overload;

    { Whether the writer is currently at the start of a section. }
    function IsAtSectionStart: Boolean;

    procedure StartCommentAlignment;
    procedure WriteAlignedComment(const AComment: String);
    procedure EndCommentAlignment;
    procedure LineBreakIfNeeded;

    { Returns the output }
    function ToString: String; override;

    { The current indentation level. }
    property CurrentIndent: String read FIndent;
  end;

implementation

{ TSourceWriter }

constructor TSourceWriter.Create;
begin
  inherited Create;
  FComments := TList<TComment>.Create;
  FMainWriter := TStringWriter.Create;
  FWriter := FMainWriter;
end;

destructor TSourceWriter.Destroy;
begin
  FMainWriter.Free;
  FComments.Free;
  inherited;
end;

procedure TSourceWriter.EndCommentAlignment;
begin
  Assert(FCommentWriter <> nil);

  var Source := FCommentWriter.ToString;
  for var I := FComments.Count - 1 downto 0 do
  begin
    var Comment := FComments[I];
    var Indent := FMaxColumn - Comment.Column + 1;
    var Text := String.Create(' ', Indent) + Comment.Text;
    Source := Source.Insert(Comment.Position, Text);
  end;

  FMainWriter.Write(Source);
  FCommentWriter.Free;
  FCommentWriter := nil;
  FWriter := FMainWriter;
end;

procedure TSourceWriter.EndSection;
begin
  if (FSection = '') then
  begin
    { We did write the section }
    WriteLn;
    FIndent := '';
    FNeedIndent := False;
  end;
end;

procedure TSourceWriter.Indent(const AImmediately: Boolean);
begin
  FIndent := FIndent + '  ';
  if (AImmediately) then
    FNeedIndent := True;
end;

function TSourceWriter.IsAtSectionStart: Boolean;
begin
  Result := (FSection <> '');
end;

procedure TSourceWriter.LineBreakIfNeeded;
begin
  if (FColumn >= 80) then
  begin
    WriteLn;
    Write('  ');
    FNeedIndent := True;
  end;
end;

procedure TSourceWriter.Outdent;
begin
  if (FIndent <> '') then
    FIndent := FIndent.Substring(2);
end;

procedure TSourceWriter.StartCommentAlignment;
begin
  Assert(FCommentWriter = nil);
  FCommentWriter := TStringWriter.Create;
  FWriter := FCommentWriter;
  FComments.Clear;
  FColumn := 0;
  FPosition := 0;
  FMaxColumn := 0;
end;

procedure TSourceWriter.StartSection(const ASection: String);
begin
  FSection := ASection;
end;

function TSourceWriter.ToString: String;
begin
  Result := FWriter.ToString;
end;

procedure TSourceWriter.WriteLn;
begin
  if (not FLastLineEmpty) then
  begin
    FWriter.WriteLine;
    FColumn := 0;
    Inc(FPosition, Length(sLineBreak));
  end;

  FLastLineEmpty := True;
end;

procedure TSourceWriter.Write(const AValue: String;
  const AArgs: array of const);
begin
  Write(Format(AValue, AArgs));
end;

procedure TSourceWriter.WriteAlignedComment(const AComment: String);
begin
  if (FCommentWriter = nil) then
  begin
    Write(' ');
    WriteLn(AComment);
    Exit;
  end;

  var Comment: TComment;
  Comment.Text := AComment;
  Comment.Position := FPosition;
  Comment.Column := FColumn;
  if (FColumn > FMaxColumn) then
    FMaxColumn := FColumn;
  FComments.Add(Comment);
  WriteLn(' ');
end;

procedure TSourceWriter.Write(const AValue: String);
begin
  if (FSection <> '') then
  begin
    FWriter.WriteLine(FSection);
    FColumn := 0;
    Inc(FPosition, Length(sLineBreak) + FSection.Length);
    FSection := '';
    FIndent := '  ';
    FNeedIndent := True;
  end;

  if (FNeedIndent) and (FIndent <> '') then
  begin
    FWriter.Write(FIndent);
    Inc(FColumn, FIndent.Length);
    Inc(FPosition, FIndent.Length);
    FNeedIndent := False;
  end;

  FWriter.Write(AValue);
  Inc(FColumn, AValue.Length);
  Inc(FPosition, AValue.Length);
  FLastLineEmpty := False;
end;

procedure TSourceWriter.WriteLn(const AValue: String;
  const AArgs: array of const);
begin
  Write(Format(AValue, AArgs));
  Write(sLineBreak);
  FColumn := 0;
  FNeedIndent := True;
end;

procedure TSourceWriter.WriteLn(const AValue: String);
begin
  Write(AValue);
  Write(sLineBreak);
  FColumn := 0;
  FNeedIndent := True;
end;

end.

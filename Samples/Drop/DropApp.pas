unit DropApp;
{ Test drag'n'drop file loading. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Fetch,
  SampleApp;

const
  MAX_FILE_SIZE = 1024 * 1024;

type
  TLoadState = (Unknown, Success, Failed, FileTooBig);

type
  TDropApp = class(TSampleApp)
  private
    FLoadState: TLoadState;
    FSize: Integer;
    FDroppedFile: UTF8String;
    FBuffer: array [0..MAX_FILE_SIZE - 1] of Byte;
  private
    procedure RenderFileContent;
    procedure FetchCallback(const AResponse: TFetchResponse);
  protected
    class function HasImGui: Boolean; override;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure DrawImGui; override;
    procedure FilesDropped(const AX, AY: Single;
      const AFilePaths: TArray<String>); override;
  end;

implementation

uses
  Neslib.FastMath,
  Neslib.Sokol.Api,
  Neslib.ImGui;

{ TDropApp }

procedure TDropApp.Cleanup;
begin
  inherited;
  TFetch.Shutdown;
end;

procedure TDropApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.EnableDragDrop := True;
  AConfig.MaxDroppedFiles := 1;
  AConfig.WindowTitle := 'Drop Test';
end;

procedure TDropApp.DrawImGui;
begin
  ImGui.SetNextWindowPos(Vector2(10, 30), TImGuiCond.Once, Vector2(0, 0));
  ImGui.SetNextWindowSize(Vector2(600, 500), TImGuiCond.Once);
  ImGui.Begin('Drop a file!');
  if (FLoadState <> TLoadState.Unknown) then
    ImGui.Text(PUTF8Char(FDroppedFile));

  case FLoadState of
    TLoadState.Failed:
      ImGui.Text('LOAD FAILED!');

    TLoadState.FileTooBig:
      ImGui.Text('FILE TOO BIG!');

    TLoadState.Success:
      begin
        ImGui.Separator;
        RenderFileContent;
      end;
  end;
  ImGui.End;
end;

procedure TDropApp.FetchCallback(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
  begin
    FLoadState := TLoadState.Success;
    FSize := AResponse.FetchedSize;
  end
  else if (AResponse.ErrorCode = TFetchError.BufferTooSmall) then
    FLoadState := TLoadState.FileTooBig
  else
    FLoadState := TLoadState.Failed;
end;

procedure TDropApp.FilesDropped(const AX, AY: Single;
  const AFilePaths: TArray<String>);
begin
  inherited;
  Assert(Length(AFilePaths) = 1);
  FDroppedFile := UTF8String(AFilePaths[0]);
  var Request := TFetchRequest.Create(AFilePaths[0], FetchCallback, @FBuffer,
    SizeOf(FBuffer));
  Request.Send;
end;

procedure TDropApp.Frame;
begin
  TFetch.DoWork;

  var PassAction := TPassAction.Create;
  TGfx.BeginDefaultPass(PassAction, FramebufferWidth, FramebufferHeight);
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

class function TDropApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TDropApp.Init;
begin
  inherited;
  var FetchDesc := TFetchDesc.Create;
  FetchDesc.NumChannels := 1;
  FetchDesc.NumLanes := 1;
  TFetch.Setup(FetchDesc);
end;

procedure TDropApp.RenderFileContent;
{ Render the loaded file content as hex view }
const
  BYTES_PER_LINE = 16;
var
  C: array [0..1] of UTF8Char;
begin
  var NumLines := (FSize + (BYTES_PER_LINE - 1)) div BYTES_PER_LINE;

  ImGui.BeginChild('##scrolling', Vector2(0, 0), False,
    [TImGuiWindowFlag.NoMove, TImGuiWindowFlag.NoNavInputs, TImGuiWindowFlag.NoNavFocus]);

  var Clipper: TImGuiListClipper;
  FillChar(Clipper, SizeOf(Clipper), 0);

  Clipper.&Begin(NumLines, ImGui.GetTextLineHeight);
  Clipper.Step;
  C[1] := #0;
  for var LineI := Clipper.DisplayStart to Clipper.DisplayEnd - 1 do
  begin
    var StartOffset := LineI * BYTES_PER_LINE;
    var EndOffset := StartOffset + BYTES_PER_LINE;
    if (EndOffset >= FSize) then
      EndOffset := FSize;

    ImGui.Text(ImGui.Format('%.4x: ', [StartOffset]));
    for var I := StartOffset to EndOffset - 1 do
    begin
      ImGui.SameLine(0, 0);
      ImGui.Text(ImGui.Format('%.2x ', [FBuffer[I]]));
    end;

    ImGui.SameLine((6 * 7) + (BYTES_PER_LINE * 3 * 7) + (2 * 7), 0);
    for var I := StartOffset to EndOffset - 1 do
    begin
      if (I <> StartOffset) then
        ImGui.SameLine(0, 0);

      C[0] := UTF8Char(FBuffer[I]);
      if (C[0] < #32) or (C[0] > #127) then
        C[0] := '.';

      ImGui.Text(@C);
    end;
  end;
  ImGui.Text('EOF'#10);
  Clipper.&End;
  ImGui.EndChild;
end;

end.

unit AudioApp;

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Audio,
  SampleApp;

const
  NUM_SAMPLES = 32;

type
  TAudioApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
    FEvenOdd: Cardinal;
    FSamplePos: Integer;
    FSamples: array [0..NUM_SAMPLES - 1] of Single;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api;

{ TAudioApp }

procedure TAudioApp.Cleanup;
begin
  inherited;
  TAudio.Shutdown;
end;

procedure TAudioApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 400;
  AConfig.Height := 300;
  AConfig.AndroidForceGles2 := True;
  AConfig.WindowTitle := 'Sokol Audio Test';
end;

procedure TAudioApp.Frame;
begin
  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);

  var NumFrames := TAudio.Expect;
  var S: Single;
  for var I := 0 to NumFrames - 1 do
  begin
    if ((FEvenOdd and (1 shl 5)) <> 0) then
      S := 0.05
    else
      S := -0.05;
    Inc(FEvenOdd);

    FSamples[FSamplePos] := S;
    Inc(FSamplePos);
    if (FSamplePos = NUM_SAMPLES) then
    begin
      FSamplePos := 0;
      TAudio.Push(@FSamples, NUM_SAMPLES);
    end;
  end;

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TAudioApp.Init;
begin
  inherited;
  FPassAction.Colors[0].Init(TAction.Clear, 1, 0.5, 0);

  var AudioDesc := TAudioDesc.Create;
  TAudio.Setup(AudioDesc);
end;

end.

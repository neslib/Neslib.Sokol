unit UniformTypesApp;
{ Test Neslib.Sokol.Gfx uniform types and uniform block memory layout. }

interface

uses
  System.UITypes,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.DebugText,
  Neslib.FastMath,
  SampleApp,
  UniformTypesShader;

const
  NUM_COLORS = 10;

const
  PALETTE: array [0..NUM_COLORS - 1] of TColor = (
    (R: 1;           G: 0;           B: 0;           A: 1),
    (R: 0;           G: 1;           B: 0;           A: 1),
    (R: 0;           G: 0;           B: 1;           A: 1),
    (R: 1;           G: 1;           B: 0;           A: 1),
    (R: 0.250980392; G: 0.878431373; B: 0.815686275; A: 1),
    (R: 0.933333333; G: 0.509803922; B: 0.933333333; A: 1),
    (R: 0.752941176; G: 0.752941176; B: 0.752941176; A: 1),
    (R: 0.980392157; G: 0.501960784; B: 0.447058824; A: 1),
    (R: 0.803921569; G: 0.521568627; B: 0.247058824; A: 1),
    (R: 1;           G: 0;           B: 1;           A: 1));

const
  NAMES: array [0..NUM_COLORS - 1] of AnsiString = (
    'RED', 'GREEN', 'BLUE', 'YELLOW', 'TURQOISE',
    'VIOLET', 'SILVER', 'SALMON', 'PERU', 'MAGENTA');

type
  TUniformTypesApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
    FShader: TShader;
    FPip: TPipeline;
    FBind: TBindings;
    FVSParams: TVSParams;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api;

const
  VERTICES: array [0..7] of Single = (
    0.0, 0.0,
    1.0, 0.0,
    1.0, 1.0,
    0.0, 1.0);

const
  INDICES: array [0..5] of UInt16 = (
    0, 1, 2,
    0, 2, 3);

{ TUniformTypesApp }

procedure TUniformTypesApp.Cleanup;
begin
  FPip.Free;
  FShader.Free;
  FBind.IndexBuffer.Free;
  FBind.VertexBuffers[0].Free;
  inherited;
end;

procedure TUniformTypesApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'Cube';
end;

procedure TUniformTypesApp.Frame;
begin
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var CW: Single := W * 0.5;
  var CH: Single := H * 0.5;
  var GlyphW: Single := 8 / CW;
  var GlyphH: Single := 8 / CH;

  TDbgText.Canvas(CW, CH);
  TDbgText.Origin(3, 3);
  TDbgText.ColorF(1, 1, 1);
  TDbgText.WriteAnsiLn('Color names must match'#10'Quad color on sane line:');
  TDbgText.NewLine;
  TDbgText.NewLine;

  for var I := 0 to NUM_COLORS - 1 do
  begin
    TDbgText.ColorF(PALETTE[I].R, PALETTE[I].G, PALETTE[I].B);
    TDbgText.WriteAnsi(NAMES[I]);
    TDbgText.NewLine;
    TDbgText.NewLine;
  end;

  TGfx.BeginDefaultPass(FPassAction, W, H);
  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyBindings(FBind);
  var X0: Single := -1 + (28 * GlyphW);
  var Y0: Single :=  1 - (16 * GlyphH);
  FVSParams.Scale.Init(5 * GlyphW, 2 * GlyphH);

  for var I := 0 to NUM_COLORS - 1 do
  begin
    FVSParams.Sel := I;
    FVSParams.Offset.Init(X0, Y0);
    TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_PARAMS,
      TRange.Create(FVSParams));
    TGfx.Draw(0, 6, 1);
    Y0 := Y0 - (4 * GlyphH);
  end;

  TDbgText.Draw;
  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TUniformTypesApp.Init;
begin
  inherited;
  var DbgTextDesc := TDbgTextDesc.Create;
  DbgTextDesc.ContextPoolSize := 1;
  DbgTextDesc.Fonts[0] := TDbgTextFont.Oric;
  TDbgText.Setup(DbgTextDesc);

  { Setup vertex shader uniform block }
  FVSParams.Scale.Init(1, 1);
  FVSParams.I1 := 0;
  FVSParams.I2.Init(1, 2);
  FVSParams.I3.Init(3, 4, 5);
  FVSParams.I4.Init(6, 7, 8, 9);
  for var I := 0 to NUM_COLORS - 1 do
    FVSParams.Pal[I].Init(PALETTE[I].R, PALETTE[I].G, PALETTE[I].B, 1);

  { A quad vertex buffer, index buffer and pipeline object }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  FBind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.BufferType := TBufferType.IndexBuffer;
  BufferDesc.Data := TRange.Create(INDICES);
  FBind.IndexBuffer := TBuffer.Create(BufferDesc);

  FShader := TShader.Create(UniformtypesShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Attrs[ATTR_VS_POSITION].Format := TVertexFormat.Float2;
  PipDesc.Shader := FShader;
  PipDesc.IndexType := TIndexType.UInt16;

  FPip := TPipeline.Create(PipDesc);

  { Default pass action to clear background to black }
  FPassAction.Colors[0].Init(TAction.Clear, 0, 0, 0, 1);
end;

end.

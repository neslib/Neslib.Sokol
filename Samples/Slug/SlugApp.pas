unit SlugApp;
{ Demonstrates Eric Lyengel's Slug text rendering algorithm.
  Ported from sokol-slug-odin: https://tangled.org/dosha.dev/sokol-slug-odin/

  Also see: https://terathon.com/blog/decade-slug.html

  Main differences from above demo:
  - 4x reduced band texture size (RGBA32UI => RG16UI)
  - batched glyph rendering via hardware-instancing instead of one draw call per
    glyph where each glyph is a triangle-strip, with the corner vertices
    synthesized in the vertex shader
  - the pixel size multiplier isn't baked into the preprocessed Slug font data
  - add `@image_sample_type` and `@sampler_type` annotations to shader to
    silence validation layer warnings

  Knowsn issues:
  - currently no kerning
  - TTF-to-Slug data preprocessing should be moved into an offline tool
  - more optimizations would be possible when switching to storage buffers
    (both for the curve+band data and the glyph 'vertices')
  - shader seems to be the Slug 'v1' shader, not the most recent one which has
    improvements in the vertex shader(?)
  - in general, also check against the BGFX slug sample, this does a couple of
    things differently: https://github.com/bkaradzic/bgfx/tree/master/examples/51-gpufont }

interface

uses
  System.Generics.Collections,
  Neslib.FastMath,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Fetch,
  SampleApp,
  SlugUtil;

const
  MAX_FONTS         = 3;
  MAX_TTF_FILE_SIZE = 2 * 1024 * 1024;
  MAX_DRAWN_GLYPHS  = 16 * 1024;
  MAX_DRAW_COMMANDS = 128;
  TOTAL_LINES       = 6;
  FONT_SIZE         = 48;
  MIN_ZOOM          = 0.1;
  MAX_ZOOM          = 50;

type
  { Per-glyph data in glyph buffer, expanded 4x via hardware-instancing }
  TGlyphVertex = packed record
  public
    DrawRect: TVector4;
    GlyphBBox: TVector4;
    BandTransform: TVector4;
    GlyphParams: array [0..3] of Int16;
    Color: UInt32;
  end;

type
  TDrawCommand = record
  public
    BaseInstance: Integer;
    NumInstances: Integer;
    CurveTexView: TView;
    BandTexView: TView;
  end;
  PDrawCommand = ^TDrawCommand;

type
  TSlugApp = class(TSampleApp)
  private type
    TInput = record
    public
      Zoom: Single;
      PanX: Single;
      PanY: Single;
      Dragging: Boolean;
    end;
  private type
    TFonts = record
    public
      Cairo: TSlugFont;
      Lucide: TSlugFont;
      Twemoji: TSlugFont;
    public
      procedure Init;
      procedure Free;
    end;
  private type
    TDraw = record
    public
      StartGlyphVertex: Integer;
      CurGlyphVertex: Integer;
      CurDrawCommand: Integer;
      CurFont: TSlugFont;
    end;
  private type
    TLine = array [0..127] of UInt32;
  private
    FPassAction: TPassAction;
    FBuf: TBuffer;
    FPip: TPipeline;
    FSampler: TSampler;
    FInput: TInput;
    FFonts: TFonts;
    FDraw: TDraw;
    FFontSize: Single;
    FLine: array [0..5] of TLine;
    FFileBuffers: array [0..MAX_FONTS - 1, 0..MAX_TTF_FILE_SIZE - 1] of Byte;
    FGlyphVertices: array [0..MAX_DRAWN_GLYPHS - 1] of TGlyphVertex;
    FDrawCommands: array [0..MAX_DRAW_COMMANDS - 1] of TDrawCommand;
  private
    procedure CairoFetchCallback(const AResponse: TFetchResponse);
    procedure LucideFetchCallback(const AResponse: TFetchResponse);
    procedure TwemojiFetchCallback(const AResponse: TFetchResponse);
    procedure BeginPushGlyphs;
    procedure PushCenteredLine(const AFont: TSlugFont; const AText: TLine;
      const ALineNr: Integer);
    procedure PushCenteredLineEmoji(const AFont: TSlugFont; const AText: TLine;
      const ALineNr: Integer);
    procedure PushLine(const AFont: TSlugFont; const AText: TLine;
      const AX, AY: Single);
    procedure PushLineEmoji(const AFont: TSlugFont; const AText: TLine;
      const AX, AY: Single);
    procedure PushGlyph(const AFont: TSlugFont; const AGlyph: PSlugGlyph;
      const AX, AY: Single; const AColor: TVector4);
    procedure PushEmoji(const AFont: TSlugFont; const ACodepoint: UInt32;
      const AX, AY: Single);
    procedure PushGlyphVertex(const AV: TGlyphVertex);
    procedure PushDrawCommand;
    function MeasureLine(const AFont: TSlugFont; const AText: TLine): Single;
    procedure EndPushGlyphs;
  protected
    class function HasImGui: Boolean; override;
  protected
    procedure MouseScroll(const AX, AY, AWheelDeltaX, AWheelDeltaY: Single;
      const AModifiers: TModifiers); override;
    procedure MouseDown(const AButton: TMouseButton; const AX, AY: Single;
      const AModifiers: TModifiers); override;
    procedure MouseUp(const AButton: TMouseButton; const AX, AY: Single;
      const AModifiers: TModifiers); override;
    procedure MouseEnter(const AX, AY: Single;
      const AModifiers: TModifiers); override;
    procedure MouseMove(const AX, AY, ADX, ADY: Single;
      const AModifiers: TModifiers); override;
    procedure Unfocused; override;
    procedure Suspended; override;
    procedure Iconified; override;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure DrawImGui; override;
  end;

implementation

uses
  Neslib.ImGui,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue,
  SlugShader;

function PackColorU32(const AColor: TVector4): UInt32;
begin
  var R: UInt32 := Trunc(AColor.R * 255);
  var G: UInt32 := Trunc(AColor.G * 255);
  var B: UInt32 := Trunc(AColor.B * 255);
  var A: UInt32 := Trunc(AColor.A * 255);
  Result := (A shl 24) or (B shl 16) or (G shl 8) or R;
end;

{ TSlugApp }

procedure TSlugApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.WindowTitle := 'Slug';
  AConfig.Width := 900;
  AConfig.Height := 500;
  AConfig.SampleCount := 1;
  AConfig.HighDpi := True;
  AConfig.DepthFormat := TAppPixelFormat.None;
end;

procedure TSlugApp.Init;
begin
  inherited;
  var FetchDesc := TFetchDesc.Create;
  FetchDesc.NumChannels := 1;
  FetchDesc.NumLanes := 3;
  FetchDesc.MaxRequests := 3;
  FetchDesc.Logger := FetchDesc.DefaultLogger;
  FetchDesc.BaseDirectory := 'Data';
  TFetch.Setup(FetchDesc);

  FPassAction.Colors[0].Init(TLoadAction.Clear, 0.1, 0.1, 0.1, 1);
  FInput.Zoom := 1;
  FFontSize := FONT_SIZE;

  { Populate unicode lines, first the latin characters }
  for var I := 0 to 31 do
  begin
    FLine[0, I] := $40 + I;   // Uppercase

    if (I <> 31) then
      FLine[1, I] := $60 + I; // Lowercase

    FLine[2, I] := $20 + I;   // Digits and symbols
  end;

  { The Arabic alphabet }
  var I := 0;
  for var CP := $0627 to $064A do
  begin
    if (CP < $063B) or (CP > $063F) then
    begin
      FLine[3, I] := CP;
      Inc(I);
    end;
  end;

  { Icons from Lucide font. Note that the unicode assignment of icons is very
    messy; it has gaps and duplicates. The range picked here is somewhat
    'orderly'.}
  I := 0;
  for var CP := $E29A to $E2BA do
  begin
    FLine[4, I] := CP;
    Inc(I);
  end;

  { Emojis }
  FLine[5, 0] := $1F600;   // grinning face
  FLine[5, 1] := $1F60D;   // heart eyes
  FLine[5, 2] := $1F60E;   // sunglasses
  FLine[5, 3] := $1F525;   // fire
  FLine[5, 4] := $1F44D;   // thumbs up
  FLine[5, 5] := $1F389;   // party popper
  FLine[5, 6] := $1F680;   // rocket
  FLine[5, 7] := $2764;    // red heart
  FLine[5, 8] := $1F308;   // rainbow
  FLine[5, 9] := $1F31F;   // glowing star
  FLine[5, 10] := $1F3B5;  // musical note
  FLine[5, 11] := $1F40D;  // snake
  FLine[5, 12] := $1F436;  // dog face
  FLine[5, 13] := $1F431;  // cat face
  FLine[5, 14] := $1F34E;  // red apple
  FLine[5, 15] := $1F370;  // shortcake

  { A stream-update buffer which holds one TGlyphVertex per glyph. This is
    expanded 4x via hardware instancing with the 4 corner vertex positions
    synthesized in the vertex shader.
    Another option (probably more efficient) might be to place this data
    in a storage buffer. }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Usage.StreamUpdate := True;
  BufferDesc.Size := MAX_DRAWN_GLYPHS * SizeOf(TGlyphVertex);
  BufferDesc.TraceLabel := 'SlugGlyphBuffer';
  FBuf := TBuffer.Create(BufferDesc);

  { The pipeline is configured with a single instance-stepped buffer which
    provides the per-glyph data. Also note that rendering is non-indexed and
    each glyph is rendered as a 4-vertex triangle-strip }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(SlugShaderDesc);
  PipDesc.Layout.Buffers[0].StepFunc := TVertexStep.PerInstance;
  PipDesc.Layout.Attrs[ATTR_SLUG_DRAW_RECT].Format := TVertexFormat.Float4;
  PipDesc.Layout.Attrs[ATTR_SLUG_GLYPH_BBOX].Format := TVertexFormat.Float4;
  PipDesc.Layout.Attrs[ATTR_SLUG_IN_BAND_TRANSFORM].Format := TVertexFormat.Float4;
  PipDesc.Layout.Attrs[ATTR_SLUG_IN_GLYPH_PARAMS].Format := TVertexFormat.Short4;
  PipDesc.Layout.Attrs[ATTR_SLUG_IN_TEXT_COLOR].Format := TVertexFormat.UByte4N;
  PipDesc.IndexType := TIndexType.None;
  PipDesc.PrimitiveType := TPrimitiveType.TriangleStrip;
  PipDesc.Colors[0].Blend.Enabled := True;
  PipDesc.Colors[0].Blend.SrcFactorRgb := TBlendFactor.One;
  PipDesc.Colors[0].Blend.DstFactorRgb := TBlendFactor.OneMinusSrcAlpha;
  PipDesc.Colors[0].Blend.SrcFactorAlpha := TBlendFactor.One;
  PipDesc.Colors[0].Blend.DstFactorAlpha := TBlendFactor.OneMinusSrcAlpha;
  PipDesc.TraceLabel := 'SligPipeline';
  FPip := TPipeline.Create(PipDesc);

  var SamplerDesc := TSamplerDesc.Create(TFilter.Nearest, TWrap.ClampToEdge);
  SamplerDesc.TraceLabel := 'SlugSampler';
  FSampler := TSampler.Create(SamplerDesc);

  { Start loading fonts }
  FFonts.Init;
  var Req := TFetchRequest.Create('Cairo.ttf', CairoFetchCallback,
    TFetchRange.Create(FFileBuffers[0]));
  Req.Send;

  Req := TFetchRequest.Create('lucide.ttf', LucideFetchCallback,
    TFetchRange.Create(FFileBuffers[1]));
  Req.Send;

  Req := TFetchRequest.Create('twemoji.ttf', TwemojiFetchCallback,
    TFetchRange.Create(FFileBuffers[2]));
  Req.Send;
end;

procedure TSlugApp.Frame;
begin
  TFetch.DoWork;

  var SX: Single := 2 / (FramebufferWidth / FInput.Zoom);
  var SY: Single := 2 / (FramebufferHeight / FInput.Zoom);
  var TX: Single := -1 - (FInput.PanX * SX);
  var TY: Single := -1 - (FInput.PanY * SY);

  var VSParams: TVSParams;
  VSParams.Mvp.V[0].Init(SX, 0, 0, 0);
  VSParams.Mvp.V[1].Init(0, SY, 0, 0);
  VSParams.Mvp.V[2].Init(0, 0, -1, 0);
  VSParams.Mvp.V[3].Init(TX, TY, 0, 1);

  { Record text into glyph buffer and draw commands }
  var AnyValid := FFonts.Cairo.Valid or FFonts.Lucide.Valid or FFonts.Twemoji.Valid;
  if (AnyValid) then
  begin
    BeginPushGlyphs;

    if (FFonts.Cairo.Valid) then
    begin
      for var I := 0 to 3 do
        PushCenteredLine(FFonts.Cairo, FLine[I], I);
    end;

    if (FFonts.Lucide.Valid) then
      PushCenteredLine(FFonts.Lucide, FLine[4], 4);

    if (FFonts.Twemoji.Valid) then
      PushCenteredLineEmoji(FFonts.Twemoji, FLine[5], 5);

    EndPushGlyphs;
  end;

  { Render the recorded draw commands }
  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  if (AnyValid) then
  begin
    TGfx.ApplyPipeline(FPip);
    TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(VSParams));

    var Cmd := PDrawCommand(@FDrawCommands);
    var Bindings := TBindings.Create;
    Bindings.VertexBuffers[0] := FBuf;
    Bindings.Samplers[SMP_POINT_SAMPLER] := FSampler;
    for var I := 0 to FDraw.CurDrawCommand - 1 do
    begin
      Bindings.VertexBufferOffsets[0] := Cmd.BaseInstance * SizeOf(TGlyphVertex);
      Bindings.Views[VIEW_BAND_TEX] := Cmd.BandTexView;
      Bindings.Views[VIEW_CURVE_TEX] := Cmd.CurveTexView;
      TGfx.ApplyBindings(Bindings);
      TGfx.Draw(0, 6, Cmd.NumInstances);

      Inc(Cmd);
    end;
  end;

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TSlugApp.Cleanup;
begin
  inherited;
  FFonts.Free;
  TFetch.Shutdown;
end;

procedure TSlugApp.CairoFetchCallback(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
    FFonts.Cairo.Load(TSlugRange.Create(AResponse.Data.Ptr, AResponse.Data.Size));
end;

procedure TSlugApp.LucideFetchCallback(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
    FFonts.Lucide.Load(TSlugRange.Create(AResponse.Data.Ptr, AResponse.Data.Size));
end;

procedure TSlugApp.TwemojiFetchCallback(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
    FFonts.Twemoji.Load(TSlugRange.Create(AResponse.Data.Ptr, AResponse.Data.Size));
end;

function TSlugApp.MeasureLine(const AFont: TSlugFont;
  const AText: TLine): Single;
begin
  Result := 0;
  for var I := 0 to Length(AText) - 1 do
  begin
    var UCP := AText[I];
    if (UCP = 0) then
      Break;

    var Glyph := AFont.GetGlyph(UCP);
    if (Glyph <> nil) then
      Result := Result + (Glyph.Advance * FFontSize);
  end;
end;

procedure TSlugApp.BeginPushGlyphs;
begin
  FDraw.StartGlyphVertex := 0;
  FDraw.CurGlyphVertex := 0;
  FDraw.CurDrawCommand := 0;
  FDraw.CurFont := nil;
end;

procedure TSlugApp.PushCenteredLine(const AFont: TSlugFont; const AText: TLine;
  const ALineNr: Integer);
begin
  var LineHeight: Single := FFontSize * 1.5;
  var BlockHeight: Single := TOTAL_LINES * LineHeight;
  var LineWidth: Single := MeasureLine(AFont, AText);
  var BaseX: Single := (FramebufferWidth - LineWidth) * 0.5;
  var BaseY: Single := ((FramebufferHeight + BlockHeight) * 0.5) - (ALineNr * LineHeight);
  PushLine(AFont, AText, BaseX, BaseY);
end;

procedure TSlugApp.PushCenteredLineEmoji(const AFont: TSlugFont;
  const AText: TLine; const ALineNr: Integer);
begin
  var LineHeight: Single := FFontSize * 1.5;
  var BlockHeight: Single := TOTAL_LINES * LineHeight;
  var LineWidth: Single := MeasureLine(AFont, AText);
  var BaseX: Single := (FramebufferWidth - LineWidth) * 0.5;
  var BaseY: Single := ((FramebufferHeight + BlockHeight) * 0.5) - (ALineNr * LineHeight);
  PushLineEmoji(AFont, AText, BaseX, BaseY);
end;

procedure TSlugApp.PushLine(const AFont: TSlugFont; const AText: TLine;
  const AX, AY: Single);
begin
  var X: Single := AX;
  for var I := 0 to Length(AText) - 1 do
  begin
    var CP := AText[I];
    if (CP = 0) then
      Break;

    var Glyph := AFont.GetGlyph(CP);
    if (Glyph <> nil) then
    begin
      PushGlyph(AFont, Glyph, X, AY, TVector4.One);
      X := X + (Glyph.Advance * FFontSize);
    end;
  end;
end;

procedure TSlugApp.PushLineEmoji(const AFont: TSlugFont; const AText: TLine;
  const AX, AY: Single);
begin
  var X: Single := AX;
  for var I := 0 to Length(AText) - 1 do
  begin
    var CP := AText[I];
    if (CP = 0) then
      Break;

    var Glyph := AFont.GetGlyph(CP);
    if (Glyph <> nil) then
    begin
      PushEmoji(AFont, CP, X, AY);
      X := X + (Glyph.Advance * FFontSize);
    end;
  end;
end;

procedure TSlugApp.PushGlyph(const AFont: TSlugFont; const AGlyph: PSlugGlyph;
  const AX, AY: Single; const AColor: TVector4);
begin
  if (AGlyph.MaxBandX < 0) or (AGlyph.MaxBandY < 0) then
    Exit;

  if (AFont <> FDraw.CurFont) then
  begin
    if (FDraw.CurFont <> nil) then
      PushDrawCommand;

    FDraw.CurFont := AFont;
  end;

  var GlyphVertex: TGlyphVertex;
  GlyphVertex.DrawRect.Init(
    AX + (AGlyph.BBox.X0 * FFontSize),
    AY + (AGlyph.BBox.Y0 * FFontSize),
    (AGlyph.BBox.X1 - AGlyph.BBox.X0) * FFontSize,
    (AGlyph.BBox.Y1 - AGlyph.BBox.Y0) * FFontSize);

  GlyphVertex.GlyphBBox.Init(
    AGlyph.BBox.X0,
    AGlyph.BBox.Y0,
    AGlyph.BBox.X1,
    AGlyph.BBox.Y1);

  GlyphVertex.BandTransform.Init(
    AGlyph.BandScale.X,
    AGlyph.BandScale.Y,
    AGlyph.BandOffset.X,
    AGlyph.BandOffset.Y);

  GlyphVertex.GlyphParams[0] := AGlyph.GlyphLoc[0];
  GlyphVertex.GlyphParams[1] := AGlyph.GlyphLoc[1];
  GlyphVertex.GlyphParams[2] := AGlyph.MaxBandX;
  GlyphVertex.GlyphParams[3] := AGlyph.MaxBandY;

  GlyphVertex.Color := PackColorU32(AColor);
  PushGlyphVertex(GlyphVertex);
end;

procedure TSlugApp.PushEmoji(const AFont: TSlugFont; const ACodepoint: UInt32;
  const AX, AY: Single);
begin
  var ColorBase := AFont.FindColorBase(ACodepoint);
  if (ColorBase = nil) then
    Exit;

  { Draw each layer as its own glyph }
  var GlyphCount := AFont.GlyphCount;
  for var I := 0 to Integer(ColorBase.NumLayers) - 1 do
  begin
    var Layer := AFont.ColorLayers[ColorBase.FirstLayer + I];
    if (Layer.GlyphId >= GlyphCount) then
      Continue;

    var Glyph := AFont.Glyphs[Layer.GlyphId];
    var Color: TVector4;
    if (Layer.PaletteIndex < AFont.PaletteColorCount) then
      Color := AFont.PaletteColors[Layer.PaletteIndex]
    else
      Color := TVector4.One;

    PushGlyph(AFont, Glyph, AX, AY, Color);
  end;
end;

procedure TSlugApp.PushGlyphVertex(const AV: TGlyphVertex);
begin
  if (FDraw.CurGlyphVertex < MAX_DRAWN_GLYPHS) then
  begin
    FGlyphVertices[FDraw.CurGlyphVertex] := AV;
    Inc(FDraw.CurGlyphVertex);
  end;
end;

procedure TSlugApp.PushDrawCommand;
begin
  if (FDraw.CurDrawCommand < MAX_DRAW_COMMANDS) and (FDraw.CurGlyphVertex > FDraw.StartGlyphVertex) then
  begin
    Assert(FDraw.CurFont <> nil);

    var I := FDraw.CurDrawCommand;
    Inc(FDraw.CurDrawCommand);

    FDrawCommands[I].BaseInstance := FDraw.StartGlyphVertex;
    FDrawCommands[I].NumInstances := FDraw.CurGlyphVertex - FDraw.StartGlyphVertex;
    FDrawCommands[I].CurveTexView := FDraw.CurFont.CurveTexView;
    FDrawCommands[I].BandTexView := FDraw.CurFont.BandTexView;

    FDraw.StartGlyphVertex := FDraw.CurGlyphVertex;
  end;
end;

procedure TSlugApp.EndPushGlyphs;
begin
  { Push final draw command }
  PushDrawCommand;

  { Update the glyph instance buffer }
  FBuf.Update(TRange.Create(@FGlyphVertices, FDraw.CurGlyphVertex * SizeOf(TGlyphVertex)));
end;

class function TSlugApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TSlugApp.DrawImGui;
begin
  ImGui.SetNextWindowPos(Vector2(30, 50), TImGuiCond.Once);
  ImGui.SetNextWindowBgAlpha(0.75);
  if (ImGui.Begin('Controls', nil, TImGuiWindowFlags.NoDecoration + [TImGuiWindowFlag.AlwaysAutoResize])) then
  begin
    ImGui.Text('Left mouse button and move mouse to pan.');
    ImGui.Text('Mouse wheel to zoom.');
    ImGui.Separator;
    ImGui.SliderFloat('Font Size', @FFontSize, 5, 256);
  end;
  ImGui.End;
end;

procedure TSlugApp.MouseScroll(const AX, AY, AWheelDeltaX, AWheelDeltaY: Single;
  const AModifiers: TModifiers);
begin
  var H: Single := FramebufferHeight;
  var MouseWorldX: Single := FInput.PanX + (AX / FInput.Zoom);
  var MouseWorldY: Single := FInput.PanY + ((H - AY) / FInput.Zoom);
  FInput.Zoom := FInput.Zoom * (1 + (AWheelDeltaY * 0.1));
  FInput.Zoom := EnsureRange(FInput.Zoom, MIN_ZOOM, MAX_ZOOM);

  { Adjust pan so the world point under the mouse stays fixed }
  FInput.PanX := MouseWorldX - (AX / FInput.Zoom);
  FInput.PanY := MouseWorldY - ((H - AY) / FInput.Zoom);
end;

procedure TSlugApp.MouseMove(const AX, AY, ADX, ADY: Single;
  const AModifiers: TModifiers);
begin
  if (FInput.Dragging) then
  begin
    FInput.PanX := FInput.PanX - (ADX / FInput.Zoom);
    FInput.PanY := FInput.PanY + (ADY / FInput.Zoom);
  end;
end;

procedure TSlugApp.MouseDown(const AButton: TMouseButton; const AX, AY: Single;
  const AModifiers: TModifiers);
begin
  if (AButton = TMouseButton.Left) then
    FInput.Dragging := True;
end;

procedure TSlugApp.MouseUp(const AButton: TMouseButton; const AX, AY: Single;
  const AModifiers: TModifiers);
begin
  if (AButton = TMouseButton.Left) then
    FInput.Dragging := False;
end;

procedure TSlugApp.MouseEnter(const AX, AY: Single;
  const AModifiers: TModifiers);
begin
  FInput.Dragging := False;
end;

procedure TSlugApp.Iconified;
begin
  FInput.Dragging := False;
end;

procedure TSlugApp.Suspended;
begin
  FInput.Dragging := False;
end;

procedure TSlugApp.Unfocused;
begin
  FInput.Dragging := False;
end;

{ TSlugApp.TFonts }

procedure TSlugApp.TFonts.Free;
begin
  Twemoji.Free;
  Lucide.Free;
  Cairo.Free;
end;

procedure TSlugApp.TFonts.Init;
begin
  Cairo := TSlugFont.Create;
  Lucide := TSlugFont.Create;
  Twemoji := TSlugFont.Create;
end;

end.

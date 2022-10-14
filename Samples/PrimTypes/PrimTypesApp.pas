unit PrimTypesApp;
{ Test/demonstrate the various primitive types. }

interface

uses
  System.UITypes,
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.FastMath,
  SampleApp,
  PrimTypesShader;

const
  NUM_X                      = 32;
  NUM_Y                      = 32;
  NUM_VERTS                  = NUM_X * NUM_Y;
  NUM_LINE_INDICES           = NUM_X * (NUM_Y - 1) * 2;
  NUM_LINE_STRIP_INDICES     = NUM_X * (NUM_Y - 1);
  NUM_TRIANGLE_INDICES       = (NUM_X - 1) * (NUM_Y - 1) * 3;
  NUM_TRIANGLE_STRIP_INDICES = ((NUM_X - 1) * (NUM_Y - 1) * 2) + ((NUM_Y - 1) * 2);

type
  TVertex = record
  public
    X, Y: Single;
    Color: TAlphaColor;
  end;

type
  TPrimitiveData = record
  public
    IBuf: TBuffer;
    Pip: TPipeline;
    NumElements: Integer;
  end;

type
  TVertices = record
  public
    Verts: array [0..NUM_VERTS - 1] of TVertex;
  public
    procedure Setup;
  end;

type
  TIndices = record
  public
    Lines: array [0..NUM_LINE_INDICES - 1] of UInt16;
    LineStrip: array [0..NUM_LINE_STRIP_INDICES - 1] of UInt16;
    Triangles: array [0..NUM_TRIANGLE_INDICES - 1] of UInt16;
    TriangleStrip: array [0..NUM_TRIANGLE_STRIP_INDICES - 1] of UInt16;
  public
    procedure Setup;
  end;

type
  TPrimTypesApp = class(TSampleApp)
  private
    FCurPrimType: TPrimitiveType;
    FPassAction: TPassAction;
    FShader: TShader;
    FVBuf: TBuffer;
    FPrim: array [TPrimitiveType] of TPrimitiveData;
    FRX: Single;
    FRY: Single;
    FPointSize: Single;
    FVertices: TVertices;
    FIndices: TIndices;
  private
    function ComputeVSParams(const ADispW, ADispH: Single): TVSParams;
  protected
    class function HasImGui: Boolean; override;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
    procedure DrawImGui; override;
    procedure TouchesBegan(const ATouches: TTouches); override;
  end;

implementation

uses
  Neslib.Sokol.Api,
  Neslib.ImGui;

{ TPrimTypesApp }

procedure TPrimTypesApp.Cleanup;
begin
  FVBuf.Free;
  for var PrimType := TPrimitiveType.Lines to TPrimitiveType.TriangleStrip do
  begin
    FPrim[PrimType].IBuf.Free;
    FPrim[PrimType].Pip.Free;
  end;
  FShader.Free;
  inherited;
end;

function TPrimTypesApp.ComputeVSParams(const ADispW, ADispH: Single): TVSParams;
begin
  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), ADispH / ADispW, 0.01, 10.0, True);
  View.InitLookAtRH(Vector3(0, 0, 1.5), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  var RXM, RYM: TMatrix4;
  RXM.InitRotationX(Radians(FRX));
  RYM.InitRotationY(Radians(FRY));
  var Model := RXM * RYM;
  Result.MVP := ViewProj * Model;
  Result.PointSize := FPointSize;
end;

procedure TPrimTypesApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Primitive Types';
end;

procedure TPrimTypesApp.DrawImGui;
begin
  inherited;
  { Use ImGui to allow user to change settings.
    This is only used on desktop platforms.
    On mobile platforms, we change the primitive type on a touch event
    (see TouchesBegan). }
  ImGui.SetNextWindowSize(Vector2(300, 0));
  if (ImGui.&Begin('Settings', nil, [TImGuiWindowFlag.NoResize])) then
  begin
    ImGui.SliderFloat('Point Size', FPointSize, 1, 50);

    if (ImGui.RadioButton('Point List', FCurPrimType = TPrimitiveType.Points)) then
      FCurPrimType := TPrimitiveType.Points;

    if (ImGui.RadioButton('Line List', FCurPrimType = TPrimitiveType.Lines)) then
      FCurPrimType := TPrimitiveType.Lines;

    if (ImGui.RadioButton('Line Strip', FCurPrimType = TPrimitiveType.LineStrip)) then
      FCurPrimType := TPrimitiveType.LineStrip;

    if (ImGui.RadioButton('Triangle List', FCurPrimType = TPrimitiveType.Triangles)) then
      FCurPrimType := TPrimitiveType.Triangles;

    if (ImGui.RadioButton('Triangle Strip', FCurPrimType = TPrimitiveType.TriangleStrip)) then
      FCurPrimType := TPrimitiveType.TriangleStrip;
  end;
  ImGui.&End;
end;

procedure TPrimTypesApp.Frame;
begin
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var T: Single := FrameDuration * 60;

  FRX := FRX + (0.3 * T);
  FRY := FRY + (0.2 * T);

  var VSParams := ComputeVSParams(W, H);

  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  TGfx.ApplyPipeline(FPrim[FCurPrimType].Pip);

  var Bind := TBindings.Create;
  Bind.VertexBuffers[0] := FVBuf;
  Bind.IndexBuffer := FPrim[FCurPrimType].IBuf;
  TGfx.ApplyBindings(Bind);

  TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(0, FPrim[FCurPrimType].NumElements);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

class function TPrimTypesApp.HasImGui: Boolean;
begin
  Result := True;
end;

procedure TPrimTypesApp.Init;
var
  IndexData: array [TPrimitiveType] of TRange;
begin
  inherited;
  FCurPrimType := TPrimitiveType.Points;
  FPointSize := 4;
  FVertices.Setup;
  FIndices.Setup;

  { Vertex- and index-buffers }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(FVertices);
  FVBuf := TBuffer.Create(BufferDesc);

  IndexData[TPrimitiveType.Lines] := TRange.Create(FIndices.Lines);
  IndexData[TPrimitiveType.LineStrip] := TRange.Create(FIndices.LineStrip);
  IndexData[TPrimitiveType.Triangles] := TRange.Create(FIndices.Triangles);
  IndexData[TPrimitiveType.TriangleStrip] := TRange.Create(FIndices.TriangleStrip);

  BufferDesc.BufferType := TBufferType.IndexBuffer;
  for var PrimType := TPrimitiveType.Lines to TPrimitiveType.TriangleStrip do
  begin
    BufferDesc.Data := IndexData[PrimType];
    FPrim[PrimType].IBuf := TBuffer.Create(BufferDesc);
  end;

  { Create pipeline state objects for each primitive type }
  FShader := TShader.Create(PrimtypesShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Attrs[ATTR_VS_POSITION].Format := TVertexFormat.Float2;
  PipDesc.Layout.Attrs[ATTR_VS_COLOR0].Format := TVertexFormat.UByte4N;
  PipDesc.IndexType := TIndexType.None; { No indices for point lists }
  PipDesc.Shader := FShader;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;

  for var PrimType := TPrimitiveType.Points to TPrimitiveType.TriangleStrip do
  begin
    PipDesc.PrimitiveType := PrimType;
    FPrim[PrimType].Pip := TPipeline.Create(PipDesc);

    { Following primitive types use indices }
    PipDesc.IndexType := TIndexType.UInt16;
  end;

  { The number of elements (vertices or indices) to render }
  FPrim[TPrimitiveType.Points].NumElements := NUM_VERTS;
  FPrim[TPrimitiveType.Lines].NumElements := NUM_LINE_INDICES;
  FPrim[TPrimitiveType.LineStrip].NumElements := NUM_LINE_STRIP_INDICES;
  FPrim[TPrimitiveType.Triangles].NumElements := NUM_TRIANGLE_INDICES;
  FPrim[TPrimitiveType.TriangleStrip].NumElements := NUM_TRIANGLE_STRIP_INDICES;

  { Pass action for clearing the framebuffer }
  FPassAction.Colors[0].Init(TAction.Clear, 0, 0.2, 0.4, 1);
end;

procedure TPrimTypesApp.TouchesBegan(const ATouches: TTouches);
begin
  inherited;
  if (FCurPrimType = TPrimitiveType.TriangleStrip) then
    FCurPrimType := TPrimitiveType.Points
  else
    FCurPrimType := Succ(FCurPrimType);
end;

{ TVertices }

procedure TVertices.Setup;
const
  DX       = 1 / NUM_X;
  DY       = 1 / NUM_Y;
  OFFSET_X = -DX * (NUM_X / 2);
  OFFSET_Y = -DY * (NUM_Y / 2);       // Red        Green      Yellow
  COLORS: array [0..2] of TAlphaColor = ($FF0000DD, $FF00DD00, $FF00DDDD);
begin
  var I := 0;
  for var Y := 0 to NUM_Y - 1 do
    for var X := 0 to NUM_X - 1 do
    begin
      Assert(I < NUM_VERTS);
      Verts[I].X := (X * DX) + OFFSET_X;
      Verts[I].Y := (Y * DY) + OFFSET_Y;
      Verts[I].Color := COLORS[I mod 3];
      Inc(I);
    end;
  Assert(I = NUM_VERTS);
end;

{ TIndices }

procedure TIndices.Setup;
var
  I, X, Y: Integer;
  I0, I1, I2: UInt16;
begin
  // Line List
  I := 0;
  for Y := 0 to NUM_Y - 2 do
    for X := 0 to NUM_X - 1 do
    begin
      if Odd(X) then
      begin
        I0 := (Y * NUM_X) + X - 1;
        I1 := I0 + NUM_X + 1;
      end
      else
      begin
        I0 := (Y * NUM_X) + X + 1;
        I1 := I0 + NUM_X - 1;
      end;
      Assert(I < (NUM_LINE_INDICES - 1));
      Assert((I0 < NUM_VERTS) and (I1 < NUM_VERTS));
      Lines[I] := I0;
      Lines[I + 1] := I1;
      Inc(I, 2);
    end;
  Assert(I = NUM_LINE_INDICES);

  // Line Strip
  I := 0;
  for Y := 0 to NUM_Y - 2 do
    for X := 0 to NUM_X - 1 do
    begin
      if Odd(X) then
        I0 := (Y * NUM_X) + X
      else
        I0 := ((Y + 1) * NUM_X) + X;
      Assert(I < NUM_LINE_STRIP_INDICES);
      Assert(I0 < NUM_VERTS);
      LineStrip[I] := I0;
      Inc(I);
    end;
  Assert(I = NUM_LINE_STRIP_INDICES);

  // Triangle List
  I := 0;
  for Y := 0 to NUM_Y - 2 do
    for X := 0 to NUM_X - 2 do
    begin
      I0 := X + (Y * NUM_X);
      if Odd(X) then
      begin
        I1 := I0 + NUM_X;
        I2 := I1 + 1;
      end
      else
      begin
        I1 := I0 + 1;
        I2 := I0 + NUM_X;
      end;
      Assert(I < (NUM_TRIANGLE_INDICES - 2));
      Assert((I0 < NUM_VERTS) and (I1 < NUM_VERTS) and (I2 < NUM_VERTS));
      Triangles[I] := I0;
      Triangles[I + 1] := I1;
      Triangles[I + 2] := I2;
      Inc(I, 3);
    end;
  Assert(I = NUM_TRIANGLE_INDICES);

  // Triangle String
  I := 0;
  for Y := 0 to NUM_Y - 2 do
  begin
    for X := 0 to NUM_X - 2 do
    begin
      I0 := X + (Y * NUM_X);
      I1 := I0 + NUM_X;
      Assert(I < (NUM_TRIANGLE_STRIP_INDICES - 1));
      Assert((I0 < NUM_VERTS) and (I1 < NUM_VERTS));
      TriangleStrip[I] := I0;
      TriangleStrip[I + 1] := I1;
      Inc(I, 2);
    end;

    { Add a degenerate triangle at the end of each 'line' }
    I0 := (Y + 1) * NUM_X;
    Assert(I < (NUM_TRIANGLE_STRIP_INDICES - 1));
    Assert((I0 < NUM_VERTS) and (I1 < NUM_VERTS));
    TriangleStrip[I] := I1;
    TriangleStrip[I + 1] := I0;
    Inc(I, 2);
  end;
  Assert(I = NUM_TRIANGLE_STRIP_INDICES);
end;

end.

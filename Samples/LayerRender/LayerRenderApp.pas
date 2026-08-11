unit LayerRenderApp;

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Shape,
  Neslib.FastMath,
  SampleApp,
  LayerRenderShader;

const
  IMG_WIDTH      = 512;
  IMG_HEIGHT     = 512;
  IMG_NUM_LAYERS = 3;

type
  TShapeType = (Box, Donut, Cylinder);

type
  TLayerRenderApp = class(TSampleApp)
  private type
    TOffscreen = record
    public
      Pip: TPipeline;
      PassAction: TPassAction;
      Bindings: TBindings;
      ColorAttViews: array [0..IMG_NUM_LAYERS - 1] of TView;
      DepthAttView: TView;
      Shapes: array [TShapeType] of TShapeElementRange;
    end;
  private type
    TDisplay = record
    public
      Pip: TPipeline;
      PassAction: TPassAction;
      Bindings: TBindings;
      Plane: TShapeElementRange;
    end;
  private
    FRX: Single;
    FRY: Single;
    FTime: Single;
    FVBuf: TBuffer;
    FIBuf: TBuffer;
    FTexView: TView;
    FSampler: TSampler;
    FOffscreen: TOffscreen;
    FDisplay: TDisplay;
  private
    function ComputeDisplayVSParams: TVSParams;
    function ComputeOffscreenVSParams(const ARX, ARY: Single): TVSParams;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  System.SysUtils,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue;

{ TLayerRenderApp }

procedure TLayerRenderApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 1;
  AConfig.WindowTitle := 'Layer Render';
end;

procedure TLayerRenderApp.Init;
var
  Vertices: array [0..(4 * 1024) - 1] of TShapeVertex;
  Indices: array [0..(12 * 1024) - 1] of UInt16;
begin
  inherited;

  { Setup a couple of shape geometries }
  var Buf := TShapeBuffer.Create(TRange.Create(Vertices), TRange.Create(Indices));

  var Box := TShapeBox.Create(1.5, 1.5, 1.5);
  Buf := Buf.Build(Box);
  FOffscreen.Shapes[TShapeType.Box] := Buf.ElementRange;

  var Torus := TShapeTorus.Create(1, 0.3, 18, 36);
  Buf := Buf.Build(Torus);
  FOffscreen.Shapes[TShapeType.Donut] := Buf.ElementRange;

  var Cylinder := TShapeCylinder.Create(0.5, 1.5, 36, 1);
  Buf := Buf.Build(Cylinder);
  FOffscreen.Shapes[TShapeType.Cylinder] := Buf.ElementRange;

  var Plane := TShapePlane.Create(2, 2);
  Buf := Buf.Build(Plane);
  FDisplay.Plane := Buf.ElementRange;
  Assert(Buf.Valid);

  { Create one vertex- and one index-buffer for all shapes }
  var VBufDesc := Buf.VertexBufferDesc;
  VBufDesc.TraceLabel := 'ShapeVertices';

  var IBufDesc := Buf.IndexBufferDesc;
  IBufDesc.TraceLabel := 'ShapeIndices';

  FVBuf := TBuffer.Create(VBufDesc);
  FIBuf := TBuffer.Create(IBufDesc);

  { Create an array-texture as render target }
  var ImgDesc := TImageDesc.Create;
  ImgDesc.Usage.ColorAttachment := True;
  ImgDesc.ImageType := TImageType.Array;
  ImgDesc.Width := IMG_WIDTH;
  ImgDesc.Height := IMG_HEIGHT;
  ImgDesc.NumSlices := IMG_NUM_LAYERS;
  ImgDesc.NumMipmaps := 1;
  ImgDesc.PixelFormat := TPixelFormat.Rgba8;
  ImgDesc.SampleCount := 1;
  ImgDesc.TraceLabel := 'ColorImage';
  var ColorImg := TImage.Create(ImgDesc);

  { ...and a matching depth buffer image }
  ImgDesc.Init;
  ImgDesc.Usage.DepthStencilAttachment := True;
  ImgDesc.Width := IMG_WIDTH;
  ImgDesc.Height := IMG_HEIGHT;
  ImgDesc.NumMipmaps := 1;
  ImgDesc.PixelFormat := TPixelFormat.Depth;
  ImgDesc.SampleCount := 1;
  ImgDesc.TraceLabel := 'DepthImage';
  var DepthImg := TImage.Create(ImgDesc);

  { A sampler for sampling the array texture }
  var SamplerDesc := TSamplerDesc.Create(TFilter.Linear, TWrap.ClampToEdge);
  SamplerDesc.TraceLabel := 'Sampler';
  FSampler := TSampler.Create(SamplerDesc);

  { View objects (one color attachment per texture layer, one depth-stencil
    attachment, one texture view) }
  for var I := 0 to IMG_NUM_LAYERS - 1 do
  begin
    var ViewDesc := TViewDesc.Create;
    ViewDesc.ColorAttachment.Image := ColorImg;
    ViewDesc.ColorAttachment.Slice := I;
    ViewDesc.TraceLabel := UTF8String(Format('ColorAttachmentSlice%d', [I]));
    FOffscreen.ColorAttViews[I] := TView.Create(ViewDesc);
  end;

  var ViewDesc := TViewDesc.Create;
  ViewDesc.DepthStencilAttachment.Image := DepthImg;
  ViewDesc.TraceLabel := 'DepthAttachment';
  FOffscreen.DepthAttView := TView.Create(ViewDesc);

  ViewDesc.Init;
  ViewDesc.Texture.Image := ColorImg;
  ViewDesc.TraceLabel := 'TextureView';
  FTexView := TView.Create(ViewDesc);

  { A pipeline object for the offscreen pass }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Buffers[0].Stride := SizeOf(TShapeVertex);
  PipDesc.Layout.Attrs[ATTR_OFFSCREEN_IN_POS] := TShapeBuffer.PositionVertexAttrState;
  PipDesc.Layout.Attrs[ATTR_OFFSCREEN_IN_NRM] := TShapeBuffer.NormalVertexAttrState;
  PipDesc.Shader := TShader.Create(OffscreenShaderDesc);
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.SampleCount := 1;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.PixelFormat := TPixelFormat.Depth;
  PipDesc.Colors[0].PixelFormat := TPixelFormat.Rgba8;
  PipDesc.TraceLabel := 'OffscreenPipeline';
  FOffscreen.Pip := TPipeline.Create(PipDesc);

  { ...and a pipeline object for the display pass }
  PipDesc.Init;
  PipDesc.Layout.Buffers[0].Stride := SizeOf(TShapeVertex);
  PipDesc.Layout.Attrs[ATTR_DISPLAY_IN_POS] := TShapeBuffer.PositionVertexAttrState;
  PipDesc.Layout.Attrs[ATTR_DISPLAY_IN_UV] := TShapeBuffer.TexCoordVertexAttrState;
  PipDesc.Shader := TShader.Create(DisplayShaderDesc);
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;
  PipDesc.SampleCount := 1;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.TraceLabel := 'DisplayPipeline';
  FDisplay.Pip := TPipeline.Create(PipDesc);

  { Initialize resource bindings }
  FOffscreen.Bindings.VertexBuffers[0] := FVBuf;
  FOffscreen.Bindings.IndexBuffer := FIBuf;

  FDisplay.Bindings.VertexBuffers[0] := FVBuf;
  FDisplay.Bindings.IndexBuffer := FIBuf;
  FDisplay.Bindings.Views[VIEW_TEX] := FTexView;
  FDisplay.Bindings.Samplers[SMP_SMP] := FSampler;

  { initialize pass actions }
  FOffscreen.PassAction.Colors[0].Init(TLoadAction.Clear, 0.5, 0.5, 0.5, 1);
  FDisplay.PassAction.Colors[0].Init(TLoadAction.Clear, 0, 0, 0, 1);
end;

procedure TLayerRenderApp.Frame;
begin
  var DT: Single := FrameDuration;
  FTime := FTime + DT;
  FRX := FRX + (DT * 20);
  FRY := FRY + (DT * 40);

  var DisplayVSParams := ComputeDisplayVSParams;

  { Render different shapes into each texture array layer }
  for var I := 0 to IMG_NUM_LAYERS - 1 do
  begin
    var Pass := TPass.Create;
    Pass.Action^ := FOffscreen.PassAction;
    Pass.Attachments.Colors[0] := FOffscreen.ColorAttViews[I];
    Pass.Attachments.DepthStencil := FOffscreen.DepthAttView;
    TGfx.BeginPass(Pass);
    TGfx.ApplyPipeline(FOffscreen.Pip);
    TGfx.ApplyBindings(FOffscreen.Bindings);

    var RX: Single := FRX;
    var RY: Single := FRY;
    if (I = 1) then
      RX := -RX
    else if (I = 2) then
      RY := -RY;

    var OffscreenVSParams := ComputeOffscreenVSParams(RX, RY);
    TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(OffscreenVSParams));

    var Shape := FOffscreen.Shapes[TShapeType(I)];
    TGfx.Draw(Shape.BaseElement, Shape.NumElements, 1);
    TGfx.EndPass;
  end;

  { Default pass: render a textured plane which accesses all texture layers in
    the fragment shader }
  var Pass := TPass.Create;
  Pass.Action^ := FDisplay.PassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FDisplay.Pip);
  TGfx.ApplyBindings(FDisplay.Bindings);
  TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(DisplayVSParams));
  TGfx.Draw(FDisplay.Plane.BaseElement, FDisplay.Plane.NumElements, 1);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TLayerRenderApp.Cleanup;
begin
  inherited;
end;

function TLayerRenderApp.ComputeDisplayVSParams: TVSParams;
begin
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var Proj, View, Rotate: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(40), W / H, 0.01, 10.0);
  View.InitLookAtRH(Vector3(0, 0, 4), TVector3.Zero, TVector3.UnitY);
  var ViewProj := Proj * View;
  Rotate.InitRotationX(Radians(90));
  Result.Mvp := ViewProj * Rotate;
end;

function TLayerRenderApp.ComputeOffscreenVSParams(const ARX,
  ARY: Single): TVSParams;
begin
  var Proj, View, RXM, RYM: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), 1, 0.01, 10.0);
  View.InitLookAtRH(Vector3(0, 0, 3), TVector3.Zero, TVector3.UnitY);
  var ViewProj := Proj * View;
  RXM.InitRotationX(Radians(ARX));
  RYM.InitRotationZ(Radians(ARY));
  var Model := RXM * RYM;
  Result.Mvp := ViewProj * Model;
end;

end.

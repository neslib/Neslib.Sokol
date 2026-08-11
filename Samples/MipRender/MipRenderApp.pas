unit MipRenderApp;

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Shape,
  Neslib.FastMath,
  SampleApp,
  MipRenderShader;

const
  IMG_WIDTH       = 512;
  IMG_HEIGHT      = 512;
  IMG_NUM_MIPMAPS = 9;

type
  TShapeType = (Box, Donut, Cylinder);

type
  TMipRenderApp = class(TSampleApp)
  private type
    TAttView = record
    public
      Color: TView;
      Depth: TView;
    end;
  private type
    TOffscreen = record
    public
      Pip: TPipeline;
      PassAction: TPassAction;
      Bindings: TBindings;
      AttViews: array [0..IMG_NUM_MIPMAPS - 1] of TAttView;
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
    function ComputeOffscreenVSParams: TVSParams;
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

{ TMipRenderApp }

procedure TMipRenderApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 1;
  AConfig.HighDpi := False;
  AConfig.WindowTitle := 'Mip Render';
end;

procedure TMipRenderApp.Init;
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

  { Create an offscreen render target with a complete mipmap chain }
  var ImgDesc := TImageDesc.Create;
  ImgDesc.Usage.ColorAttachment := True;
  ImgDesc.Width := IMG_WIDTH;
  ImgDesc.Height := IMG_HEIGHT;
  ImgDesc.NumMipmaps := IMG_NUM_MIPMAPS;
  ImgDesc.PixelFormat := TPixelFormat.Rgba8;
  ImgDesc.SampleCount := 1;
  ImgDesc.TraceLabel := 'ColorImage';
  var ColorImg := TImage.Create(ImgDesc);

  { We also need a matching depth buffer image }
  ImgDesc.Init;
  ImgDesc.Usage.DepthStencilAttachment := True;
  ImgDesc.Width := IMG_WIDTH;
  ImgDesc.Height := IMG_HEIGHT;
  ImgDesc.NumMipmaps := IMG_NUM_MIPMAPS;
  ImgDesc.PixelFormat := TPixelFormat.Depth;
  ImgDesc.SampleCount := 1;
  ImgDesc.TraceLabel := 'DepthImage';
  var DepthImg := TImage.Create(ImgDesc);

  { Create a sampler which smoothly blends between mipmaps }
  var SamplerDesc := TSamplerDesc.Create(TFilter.Linear, TWrap.ClampToEdge);
  SamplerDesc.MipmapFilter := TFilter.Linear;
  SamplerDesc.TraceLabel := 'Sampler';
  FSampler := TSampler.Create(SamplerDesc);

  { Create a single texture view for the color attachment image }
  var ViewDesc := TViewDesc.Create;
  ViewDesc.Texture.Image := ColorImg;
  ViewDesc.TraceLabel := 'ColorTextureView';
  FTexView := TView.Create(ViewDesc);

  { Create pass attachment views for each miplevel }
  for var MipLevel := 0 to IMG_NUM_MIPMAPS - 1 do
  begin
    ViewDesc.Init;
    ViewDesc.ColorAttachment.Image := ColorImg;
    ViewDesc.ColorAttachment.MipLevel := MipLevel;
    ViewDesc.TraceLabel := UTF8String(Format('ColorAttachmentMip%d', [MipLevel]));
    FOffscreen.AttViews[MipLevel].Color := TView.Create(ViewDesc);

    ViewDesc.Init;
    ViewDesc.DepthStencilAttachment.Image := DepthImg;
    ViewDesc.DepthStencilAttachment.MipLevel := MipLevel;
    ViewDesc.TraceLabel := UTF8String(Format('DepthAttachmentMip%d', [MipLevel]));
    FOffscreen.AttViews[MipLevel].Depth := TView.Create(ViewDesc);
  end;

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

procedure TMipRenderApp.Frame;
begin
  var DT: Single := FrameDuration;
  FTime := FTime + DT;
  FRX := FRX + (DT * 20);
  FRY := FRY + (DT * 40);

  var OffscreenVSParams := ComputeOffscreenVSParams;
  var DisplayVSParams := ComputeDisplayVSParams;

  { Render different shapes into each mipmap level }
  for var I := 0 to IMG_NUM_MIPMAPS - 1 do
  begin
    var Pass := TPass.Create;
    Pass.Action^ := FOffscreen.PassAction;
    Pass.Attachments.Colors[0] := FOffscreen.AttViews[I].Color;
    Pass.Attachments.DepthStencil := FOffscreen.AttViews[I].Depth;
    TGfx.BeginPass(Pass);
    TGfx.ApplyPipeline(FOffscreen.Pip);
    TGfx.ApplyBindings(FOffscreen.Bindings);
    TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(OffscreenVSParams));

    var Shape := FOffscreen.Shapes[TShapeType(I mod 3)];
    TGfx.Draw(Shape.BaseElement, Shape.NumElements, 1);
    TGfx.EndPass;
  end;

  { Default pass: render a textured plane that moves back and forth to use
    different mipmap levels }
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

procedure TMipRenderApp.Cleanup;
begin
  inherited;
end;

function TMipRenderApp.ComputeDisplayVSParams: TVSParams;
begin
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var Proj, View, Rotate, Scale: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(40), W / H, 0.01, 10.0);
  View.InitLookAtRH(Vector3(0, 0, 2.5), TVector3.Zero, TVector3.UnitY);
  var ViewProj := Proj * View;
  Rotate.InitRotationX(Radians(90));
  Scale.InitScaling((FastSin(FTime) + 1) * 0.5);
  var Model := Scale * Rotate;
  Result.Mvp := ViewProj * Model;
end;

function TMipRenderApp.ComputeOffscreenVSParams: TVSParams;
begin
  var Proj, View, RXM, RYM: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), 1, 0.01, 10.0);
  View.InitLookAtRH(Vector3(0, 0, 3), TVector3.Zero, TVector3.UnitY);
  var ViewProj := Proj * View;
  RXM.InitRotationX(Radians(FRX));
  RYM.InitRotationZ(Radians(FRY));
  var Model := RXM * RYM;
  Result.Mvp := ViewProj * Model;
end;

end.

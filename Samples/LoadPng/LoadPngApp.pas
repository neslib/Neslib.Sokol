unit LoadPngApp;
{ Asynchronously load a png file via Neslib.Sokol.Fetch, decode via
  Neslib.Stb.Image (this is non-perfect since it happens on the main thread)
  and create a Neslib.Sokol.Gfx texture from the decoded pixel data.
  This is a modified version of the TexCube sample. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Fetch,
  Neslib.FastMath,
  SampleApp,
  LoadPngShader;

type
  TLoadPngApp = class(TSampleApp)
  private
    FPassAction: TPassAction;
    FView: TView;
    FPip: TPipeline;
    FBind: TBindings;
    FRX: Single;
    FRY: Single;
    FFileBuffer: array [0..(256 * 1024) - 1] of Byte;
  private
    procedure FetchCallback(const AResponse: TFetchResponse);
    function ComputeVSParams: TVSParams;
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Stb.Image,
  Neslib.Sokol.Api,
  Neslib.Sokol.Glue;

type
  TVertex = record
    X, Y, Z: Single;
    U, V: Int16;
  end;

const
  { Cube vertex buffer with packed texcoords. }
  VERTICES: array [0..23] of TVertex = (
  // Pos                        UVs
    (X: -1.0; Y: -1.0; Z: -1.0; U:     0; V:     0),
    (X:  1.0; Y: -1.0; Z: -1.0; U: 32767; V:     0),
    (X:  1.0; Y:  1.0; Z: -1.0; U: 32767; V: 32767),
    (X: -1.0; Y:  1.0; Z: -1.0; U:     0; V: 32767),

    (X: -1.0; Y: -1.0; Z:  1.0; U:     0; V:     0),
    (X:  1.0; Y: -1.0; Z:  1.0; U: 32767; V:     0),
    (X:  1.0; Y:  1.0; Z:  1.0; U: 32767; V: 32767),
    (X: -1.0; Y:  1.0; Z:  1.0; U:     0; V: 32767),

    (X: -1.0; Y: -1.0; Z: -1.0; U:     0; V:     0),
    (X: -1.0; Y:  1.0; Z: -1.0; U: 32767; V:     0),
    (X: -1.0; Y:  1.0; Z:  1.0; U: 32767; V: 32767),
    (X: -1.0; Y: -1.0; Z:  1.0; U:     0; V: 32767),

    (X:  1.0; Y: -1.0; Z: -1.0; U:     0; V:     0),
    (X:  1.0; Y:  1.0; Z: -1.0; U: 32767; V:     0),
    (X:  1.0; Y:  1.0; Z:  1.0; U: 32767; V: 32767),
    (X:  1.0; Y: -1.0; Z:  1.0; U:     0; V: 32767),

    (X: -1.0; Y: -1.0; Z: -1.0; U:     0; V:     0),
    (X: -1.0; Y: -1.0; Z:  1.0; U: 32767; V:     0),
    (X:  1.0; Y: -1.0; Z:  1.0; U: 32767; V: 32767),
    (X:  1.0; Y: -1.0; Z: -1.0; U:     0; V: 32767),

    (X: -1.0; Y:  1.0; Z: -1.0; U:     0; V:     0),
    (X: -1.0; Y:  1.0; Z:  1.0; U: 32767; V:     0),
    (X:  1.0; Y:  1.0; Z:  1.0; U: 32767; V: 32767),
    (X:  1.0; Y:  1.0; Z: -1.0; U:     0; V: 32767));

const
  { Index buffer for the cube }
  INDICES: array [0..35] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20);

const
  { Create a checkerboard texture }
  PIXELS: array [0..4 * 4 - 1] of UInt32 = (
    $FFFFFFFF, $FF000000, $FFFFFFFF, $FF000000,
    $FF000000, $FFFFFFFF, $FF000000, $FFFFFFFF,
    $FFFFFFFF, $FF000000, $FFFFFFFF, $FF000000,
    $FF000000, $FFFFFFFF, $FF000000, $FFFFFFFF);

{ TLoadPngApp }

procedure TLoadPngApp.Cleanup;
begin
  TFetch.Shutdown;
  inherited;
end;

function TLoadPngApp.ComputeVSParams: TVSParams;
begin
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;
  var Proj, View: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), W / H, 0.01, 10.0);
  View.InitLookAtRH(Vector3(0, 1.5, 4), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  var RXM, RYM: TMatrix4;
  RXM.InitRotationX(Radians(FRX));
  RYM.InitRotationY(Radians(FRY));
  var Model := RXM * RYM;
  Result.MVP := ViewProj * Model;
end;

procedure TLoadPngApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 800;
  AConfig.Height := 600;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Async PNG Loading';
end;

procedure TLoadPngApp.FetchCallback(const AResponse: TFetchResponse);
{ This method is called by Neslib.Sokol.Fetchh when the data is loaded, or when
  an error has occurred. }
begin
  if (AResponse.Fetched) then
  begin
    { The file data has been fetched. Since we provided a big-enough buffer we
      can be sure that all data has been loaded here. }
    var Image := TStbImage.Create;
    try
      if (Image.Load(AResponse.Data.Ptr, AResponse.Data.Size, 4)) then
      begin
        { OK, time to actually initialize the Sokol Gfx texture }
        var ImgDesc := TImageDesc.Create;
        ImgDesc.Width := Image.Width;
        ImgDesc.Height := Image.Height;
        ImgDesc.PixelFormat := TPixelFormat.Rgba8;
        ImgDesc.Data.MipLevels[0] := TRange.Create(Image.Data, Image.Width * Image.Height * 4);
        ImgDesc.TraceLabel := 'PngImage';

        var ViewDesc := TViewDesc.Create;
        ViewDesc.Texture.Image := TImage.Create(ImgDesc);
        ViewDesc.TraceLabel := 'PngTextureView';
        FView.Setup(ViewDesc);
      end;
    finally
      Image.Free;
    end;
  end
  else if (AResponse.Failed) then
  begin
    { If loading the file failed, set clear color to red }
    FPassAction.Colors[0].Init(TLoadAction.Clear, 1, 0, 0, 1);
  end;
end;

procedure TLoadPngApp.Frame;
{ The frame-function is fairly boring. Note that no special handling is needed
  for the case where the texture isn't loaded yet.
  Also note the TFetch.DoWork call. This is usually called once a frame to pump
  the Neslib.Sokol.Fetch message queues. }
begin
  { Pump the Fetch message queues, and invoke response callbacks }
  TFetch.DoWork;

  { Compute model-view-projection matrix for vertex shader }
  var T: Single := FrameDuration * 60;
  FRX := FRX + (1 * T);
  FRY := FRY + (2 * T);
  var VSParams := ComputeVSParams;

  var Pass := TPass.Create;
  Pass.Action^ := FPassAction;
  Pass.Swapchain.FromAppSwapchain;
  TGfx.BeginPass(Pass);

  TGfx.ApplyPipeline(FPip);
  TGfx.ApplyBindings(FBind);
  TGfx.ApplyUniforms(UB_VS_PARAMS, TRange.Create(VSParams));
  TGfx.Draw(0, 36, 1);

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TLoadPngApp.Init;
begin
  inherited;
  { Setup Neslib.Sokol.Fetch with the minimal "resource limits" }
  var FetchDesc := TFetchDesc.Create;
  FetchDesc.MaxRequests := 1;
  FetchDesc.NumChannels := 1;
  FetchDesc.NumLanes := 1;
  FetchDesc.BaseDirectory := 'Data';
  FetchDesc.Logger := FetchDesc.DefaultLogger;
  TFetch.Setup(FetchDesc);

  { Pass action for clearing the framebuffer to some color }
  FPassAction.Colors[0].Init(TLoadAction.Clear, 0.125, 0.25, 0.35, 1);

  { Allocate a view handle, but don't actually initialize it yet. This happens
    later when the asynchronous file load has finished. Any draw calls
    containing such an "incomplete" view handle will be silently dropped. }
  FView.Allocate;
  FBind.Views[VIEW_TEX] := FView;

  { A sampler object }
  var SamplerDesc := TSamplerDesc.Create;
  SamplerDesc.MinFilter := TFilter.Linear;
  SamplerDesc.MagFilter := TFilter.Linear;
  SamplerDesc.TraceLabel := 'PngSampler';
  FBind.Samplers[SMP_SMP] := TSampler.Create(SamplerDesc);

  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  BufferDesc.TraceLabel := 'CubeVertices';
  FBind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.Usage.IndexBuffer := True;
  BufferDesc.Data := TRange.Create(INDICES);
  BufferDesc.TraceLabel := 'CubeIndices';
  FBind.IndexBuffer := TBuffer.Create(BufferDesc);

  { A pipeline state object }
  var PipDesc := TPipelineDesc.Create;
  PipDesc.Shader := TShader.Create(LoadpngShaderDesc);
  PipDesc.Layout.Attrs[ATTR_LOADPNG_POS].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_LOADPNG_TEXCOORD0].Format := TVertexFormat.Short2N;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.Back;;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  PipDesc.Depth.WriteEnabled := True;
  PiPDesc.TraceLabel := 'CubePipeline';
  FPip := TPipeline.Create(PipDesc);

  { Start loading the PNG file. We don't need the returned handle since we can
    also get that inside the fetch-callback from the response structure. }
  var Request := TFetchRequest.Create('baboon.png', FetchCallback,
    TFetchRange.Create(FFileBuffer));
  Request.Send;
end;

end.

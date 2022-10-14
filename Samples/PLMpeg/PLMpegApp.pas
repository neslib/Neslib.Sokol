unit PLMpegApp;
{ Video streaming via Neslib.PL.Mpeg and Neslib.Sokol.Fetch for streaming the
  video data.

  The video file is streamed in fixed-size blocks via Sokol Fetch, decoded into
  3 per-channel images and audio samples, and rendered via Sokol Gfx and Sokol
  Audio.

  Download buffers are organized in a circular queue, buffers with downloaded
  data are enqueued, and the video decoder dequeues buffers as needed.

  Downloading will be paused if the circular buffer queue is full, and decoding
  will be paused if the queue is empty.

  KNOWN ISSUES:
  - If you get bad audio playback artefacts, the reason is most likely that the
    audio playback device doesn't support the video's audio sample rate
    (44.1 kHz). This example doesn't contain a sample-rate converter. }

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx,
  Neslib.Sokol.Fetch,
  Neslib.Sokol.Audio,
  Neslib.PLMpeg,
  Neslib.FastMath,
  SampleApp,
  PLMpegShader;

const
  BUFFER_SIZE    = 512 * 1024;
  CHUNK_SIZE     = 128 * 1024;
  NUM_BUFFERS    = 4;
  RING_NUM_SLOTS = NUM_BUFFERS + 1;

type
  { A simple ring buffer for the circular buffer queue }
  TRing = record
  private
    FHead: Integer;
    FTail: Integer;
    FBuf: array [0..RING_NUM_SLOTS - 1] of Integer;
  private
    class function Wrap(const AValue: Integer): Integer; inline; static;
  public
    function IsEmpty: Boolean; inline;
    function IsFull: Boolean; inline;
    function Count: Integer;

    procedure Enqueue(const AValue: Integer);
    function Dequeue: Integer;
  end;

type
  TImageAttr = record
  public
    Width: Integer;
    Height: Integer;
    LastUpdFrame: Int64;
  end;

type
  TPLMpegApp = class(TSampleApp)
  private
    FBuffer: array [0..NUM_BUFFERS - 1, 0..BUFFER_SIZE - 1] of Byte;
    FMpeg: TMpeg;
    FMpegBuffer: TMpegBuffer;
    FShader: TShader;
    FPip: TPipeline;
    FBind: TBindings;
    FPassAction: TPassAction;
    FImageAttrs: array [0..2] of TImageAttr;
    FFreeBuffers: TRing;
    FFullBuffers: TRing;
    FCurDownloadBuffer: Integer;
    FCurReadBuffer: Integer;
    FCurReadPos: Integer;
    FRY: Single;
    FCurFrame: Int64;
  private
    procedure FetchCallback(const AResponse: TFetchResponse);
    procedure MpegLoad(const ABuffer: TMpegBuffer);
    procedure MpegVideoDecode(const AMpeg: TMpeg; const AFrame: TMpegFrame);
    procedure MpegAudioDecode(const AMpeg: TMpeg; const ASamples: TMpegSamples);
    procedure ValidateTexture(const ASlot: Integer; const APlane: TMpegPlane);
  protected
    procedure Configure(var AConfig: TAppConfig); override;
    procedure Init; override;
    procedure Frame; override;
    procedure Cleanup; override;
  end;

implementation

uses
  Neslib.Sokol.Api,
  Neslib.PLMpeg.Api;

type
  { A vertex with position, normal and texcoords }
  TVertex = record
  public
    X, Y, Z: Single;
    NX, NY, NZ: Single;
    U, V: Single;
  end;

const
  VERTICES: array [0..127] of Single = (
  // pos          normal    uvs
     -1, -1, -1,  0, 0,-1,  1, 1,
      1, -1, -1,  0, 0,-1,  0, 1,
      1,  1, -1,  0, 0,-1,  0, 0,
     -1,  1, -1,  0, 0,-1,  1, 0,

     -1, -1,  1,  0, 0, 1,  0, 1,
      1, -1,  1,  0, 0, 1,  1, 1,
      1,  1,  1,  0, 0, 1,  1, 0,
     -1,  1,  1,  0, 0, 1,  0, 0,

     -1, -1, -1, -1, 0, 0,  0, 1,
     -1,  1, -1, -1, 0, 0,  0, 0,
     -1,  1,  1, -1, 0, 0,  1, 0,
     -1, -1,  1, -1, 0, 0,  1, 1,

      1, -1, -1,  1, 0, 0,  1, 1,
      1,  1, -1,  1, 0, 0,  1, 0,
      1,  1,  1,  1, 0, 0,  0, 0,
      1, -1,  1,  1, 0, 0,  0, 1);

const
  INDICES: array [0..23] of UInt16 = (
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12);

{ TPLMpegApp }

procedure TPLMpegApp.Cleanup;
begin
  FMpeg.Free;
  FMpegBuffer.Free;
  FPip.Free;
  FShader.Free;
  FBind.VertexBuffers[0].Free;
  for var I := 0 to 2 do
    FBind.FragmentShaderImages[I].Free;
  FBind.IndexBuffer.Free;
  TFetch.Shutdown;
  TAudio.Shutdown;
  inherited;
end;

procedure TPLMpegApp.Configure(var AConfig: TAppConfig);
begin
  inherited;
  AConfig.Width := 960;
  AConfig.Height := 540;
  AConfig.SampleCount := 4;
  AConfig.WindowTitle := 'Mpeg Demo';
end;

procedure TPLMpegApp.FetchCallback(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
  begin
    { Current download buffer has been filled with data.
      Fut the download buffer into the FFullBuffers queue. }
    FFullBuffers.Enqueue(FCurDownloadBuffer);
    if (FFullBuffers.IsFull) or (FFreeBuffers.IsEmpty) then
      { All buffers in use. Need to wait for the video decoding to catch up }
      AResponse.Handle.Pause
    else
    begin
      { ...otherwise start streaming into the next free buffer }
      FCurDownloadBuffer := FFreeBuffers.Dequeue;
      AResponse.Handle.UnbindBuffer;
      AResponse.Handle.BindBuffer(@FBuffer[FCurDownloadBuffer], BUFFER_SIZE);
    end;
  end
  else if (AResponse.Paused) then
  begin
    { This handles a paused download, and continues it once the video decoding
      has caught up }
    if (not FFreeBuffers.IsEmpty) then
    begin
      FCurDownloadBuffer := FFreeBuffers.Dequeue;
      AResponse.Handle.UnbindBuffer;
      AResponse.Handle.BindBuffer(@FBuffer[FCurDownloadBuffer], BUFFER_SIZE);
      AResponse.Handle.Continue;
    end;
  end;
end;

procedure TPLMpegApp.Frame;
begin
  Inc(FCurFrame);

  { Pump the Sokol Fetch message queues }
  TFetch.DoWork;

  { Stop decoding if there's not at least one buffer of downloaded data ready,
    to allow slow downloads to catch up }
  if (FMpeg <> nil) then
  begin
    if (not FFullBuffers.IsEmpty) then
      FMpeg.Decode(FrameDuration);
  end
  else if (FFreeBuffers.Count = 2) then
  begin
    Assert((FMpeg = nil) and (FMpegBuffer = nil));
    FMpegBuffer := TMpegBuffer.Create(BUFFER_SIZE);
    FMpegBuffer.OnLoad := MpegLoad;

    FMpeg := TMpeg.Create(FMpegBuffer);
    FMpeg.OnVideoDecode := MpegVideoDecode;
    FMpeg.OnAudioDecode := MpegAudioDecode;
    FMpeg.Looping := True;
    FMpeg.AudioEnabled := True;
    FMpeg.AudioStreamIndex := 0;
    FMpeg.AudioLeadTime := 0.25;
    if (FMpeg.NumberOfAudioStreams > 0) then
    begin
      var AudioDesc := TAudioDesc.Create;
      AudioDesc.SampleRate := FMpeg.SampleRate;
      AudioDesc.BufferFrames := 4096;
      AudioDesc.NumPackets := 256;
      AudioDesc.NumChannels := 2;
      TAudio.Setup(AudioDesc);
    end;
  end;

  { Compute model-view-projection matrix for vertex shader }
  var W: Single := FramebufferWidth;
  var H: Single := FramebufferHeight;

  var Proj, View, Model: TMatrix4;
  Proj.InitPerspectiveFovRH(Radians(60), H / W, 0.01, 10.0, True);
  View.InitLookAtRH(Vector3(0, 0, 6), Vector3(0, 0, 0), Vector3(0, 1, 0));
  var ViewProj := Proj * View;

  FRY := FRY - (0.1 * 60 * FrameDuration);
  Model.InitRotationY(Radians(FRY));

  var VSParams: TVSParams;
  VSParams.MVP := ViewProj * Model;

  { Start rendering, but not before the first video frame has been decoded into
    textures }
  TGfx.BeginDefaultPass(FPassAction, FramebufferWidth, FramebufferHeight);
  if (FBind.FragmentShaderImages[0].Id <> INVALID_ID) then
  begin
    TGfx.ApplyPipeline(FPip);
    TGfx.ApplyBindings(FBind);
    TGfx.ApplyUniforms(TShaderStage.VertexShader, SLOT_VS_PARAMS, TRange.Create(VSParams));
    TGfx.Draw(0, 24);
  end;

  DebugFrame;
  TGfx.EndPass;
  TGfx.Commit;
end;

procedure TPLMpegApp.Init;
begin
  inherited;
  { Setup circular queues of "free" and "full" buffers }
  for var I := 0 to NUM_BUFFERS - 1 do
    FFreeBuffers.Enqueue(I);

  FCurDownloadBuffer := FFreeBuffers.Dequeue;
  FCurReadBuffer := -1;

  { Setup Sokol Fetch and start fetching the file. Once the first two buffers
    have been filled with data, setup TMpeg (this happens down in the frame
    callback) }
  var FetchDesc := TFetchDesc.Create;
  FetchDesc.MaxRequests := 1;
  FetchDesc.NumChannels := 1;
  FetchDesc.NumLanes := 1;
  FetchDesc.BaseDirectory := 'Data';
  TFetch.Setup(FetchDesc);

  var Request := TFetchRequest.Create('bjork-all-is-full-of-love.mpg',
    FetchCallback, @FBuffer[FCurDownloadBuffer], BUFFER_SIZE);
  Request.ChunkSize := CHUNK_SIZE;
  Request.Send;

  { Initialize Sokol Gfx }
  var BufferDesc := TBufferDesc.Create;
  BufferDesc.Data := TRange.Create(VERTICES);
  FBind.VertexBuffers[0] := TBuffer.Create(BufferDesc);

  BufferDesc.Init;
  BufferDesc.BufferType := TBufferType.IndexBuffer;
  BufferDesc.Data := TRange.Create(INDICES);
  FBind.IndexBuffer := TBuffer.Create(BufferDesc);

  FShader := TShader.Create(PlmpegShaderDesc);

  var PipDesc := TPipelineDesc.Create;
  PipDesc.Layout.Attrs[ATTR_VS_POS].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_VS_NORMAL].Format := TVertexFormat.Float3;
  PipDesc.Layout.Attrs[ATTR_VS_TEXCOORD].Format := TVertexFormat.Float2;
  PipDesc.Shader := FShader;
  PipDesc.IndexType := TIndexType.UInt16;
  PipDesc.CullMode := TCullMode.None;
  PipDesc.Depth.WriteEnabled := True;
  PipDesc.Depth.Compare := TCompareFunc.LessOrEqual;
  FPip := TPipeline.Create(PipDesc);

  FPassAction.Colors[0].Init(TAction.Clear, 0, 0.569, 0.918, 1);

  { Note: texture creation is deferred until first frame is decoded }
end;

procedure TPLMpegApp.MpegAudioDecode(const AMpeg: TMpeg;
  const ASamples: TMpegSamples);
{ Forward decoded audio samples to Sokol Audio }
begin
  TAudio.Push(@ASamples.Samples, ASamples.Count);
end;

procedure TPLMpegApp.MpegLoad(const ABuffer: TMpegBuffer);
{ This is called when TMpeg needs new data. This takes buffers loaded with video
  data from the "full-queue" as needed }
begin
  if (FCurReadBuffer = -1) then
  begin
    FCurReadBuffer := FFullBuffers.Dequeue;
    FCurReadPos := 0;
  end;

  var BytesWritten := ABuffer.Write(FBuffer[FCurReadBuffer, FCurReadPos],
    BUFFER_SIZE - FCurReadPos);

  Inc(FCurReadPos, BytesWritten);
  if (FCurReadPos = BUFFER_SIZE) then
  begin
    FFreeBuffers.Enqueue(FCurReadBuffer);
    FCurReadBuffer := -1;
  end;
end;

procedure TPLMpegApp.MpegVideoDecode(const AMpeg: TMpeg;
  const AFrame: TMpegFrame);
{ Copy decoded video data into textures }
begin
  ValidateTexture(SLOT_TEX_Y, AFrame.Y);
  ValidateTexture(SLOT_TEX_CB, AFrame.Cb);
  ValidateTexture(SLOT_TEX_CR, AFrame.Cr);
end;

procedure TPLMpegApp.ValidateTexture(const ASlot: Integer;
  const APlane: TMpegPlane);
{ (Re-)create a video plane texture on demand, and update it with decoded
  video-plane data. }
begin
  if (FImageAttrs[ASlot].Width <> APlane.Width)
    or (FImageAttrs[ASlot].Height <> APlane.Height) then
  begin
    FImageAttrs[ASlot].Width := APlane.Width;
    FImageAttrs[ASlot].Height := APlane.Height;

    { Note: it's OK to call TImage.Free on nil images }
    FBind.FragmentShaderImages[ASlot].Free;

    var ImgDesc := TImageDesc.Create;
    ImgDesc.Width := APlane.Width;
    ImgDesc.Height := APlane.Height;
    ImgDesc.PixelFormat := TPixelFormat.R8;
    ImgDesc.Usage := TUsage.Stream;
    ImgDesc.MinFilter := TFilter.Linear;
    ImgDesc.MagFilter := TFilter.Linear;
    ImgDesc.WrapU := TWrap.ClampToEdge;
    ImgDesc.WrapV := TWrap.ClampToEdge;

    FBind.FragmentShaderImages[ASlot] := TImage.Create(ImgDesc);
  end;

  { Copy decoded plane pixels into texture. Need to prevent that TImage.Update
    is called more than once per frame. }
  if (FImageAttrs[ASlot].LastUpdFrame <> FCurFrame) then
  begin
    FImageAttrs[ASlot].LastUpdFrame := FCurFrame;
    var ImgData := TImageData.Create;
    ImgData.SubImages[0] := TRange.Create(APlane.Data, APlane.Width * APlane.Height);
    FBind.FragmentShaderImages[ASlot].Update(ImgData);
  end;
end;

{ TRing }

function TRing.Count: Integer;
begin
  if (FHead >= FTail) then
    Result := FHead - FTail
  else
    Result := (FHead + RING_NUM_SLOTS) - FTail;
end;

function TRing.Dequeue: Integer;
begin
  Assert(not IsEmpty);
  Result := FBuf[FTail];
  FTail := Wrap(FTail + 1);
end;

procedure TRing.Enqueue(const AValue: Integer);
begin
  Assert(not IsFull);
  FBuf[FHead] := AValue;
  FHead := Wrap(FHead + 1);
end;

function TRing.IsEmpty: Boolean;
begin
  Result := (FHead = FTail);
end;

function TRing.IsFull: Boolean;
begin
  Result := (Wrap(FHead + 1) = FTail);
end;

class function TRing.Wrap(const AValue: Integer): Integer;
begin
  Result := AValue mod RING_NUM_SLOTS;
end;

end.

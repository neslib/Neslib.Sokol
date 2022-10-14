# Neslib.Sokol.Fetch

Asynchronous data loading/streaming.

## Feature Overview

- Asynchronously load complete files, or stream files incrementally from the local file system.
  
- Request / response-callback model: User code sends a request to initiate a file-load and Neslib.Sokol.Fetch calls the response callback on the same thread when data is ready or user-code needs to respond otherwise.
  
- Not limited to the main-thread or a single thread: A fetch "context" can live on any thread, and multiple contexts can operate side-by-side on different threads.
  
- Memory management for data buffers is under full control of user code. Neslib.Sokol.Fetch won't allocate memory after it has been setup.
  
- Automatic rate-limiting guarantees that only a maximum number of requests is processed at any one time, allowing a zero-allocation model, where all data is streamed into fixed-size, pre-allocated buffers.
  
- Active Requests can be paused, continued and cancelled from anywhere in the user-thread which sent this request.

## TL;DR Example Code

This is the most-simple example code to load a single data file with a known maximum size:

1. Initialize Neslib.Sokol.Fetch with default parameters (but note that the default setup parameters provide a safe-but-slow "serialized" operation):

   ```pascal
   var Desc := TFetchDesc.Create;
   Desc.BaseDirectory := 'Data';
   TFetch.Setup(Desc);
   ```
2. Send a fetch-request to load a file from the current directory into a buffer big enough to hold the entire file content:

   ```pascal
   var Buf: array [0..MAX_FILE_SIZE - 1] of Byte;
   var Request := TFetchRequest.Create;
   Request.Path := 'MyFile.txt';
   Request.Callback := ResponseCallback;
   Request.BufferPtr := @Buf;
   Request.BufferSize := SizeOf(Buf);
   Request.Send;
   ```

3. Write a 'response-callback' method, this will be called whenever the user-code must respond to state changes of the request (most importantly when data has been loaded):

   ```pascal
   procedure TMyApp.ResponseCallback(const AResponse: TFetchResponse);
   begin
     if (AResponse.Fetched) then
     begin
       // Data has been loaded
       var Data: Pointer := AResponse.BufferPtr;
       var NumBytes: Int64 := AResponse.FetchedSize;/
     end;
     if (AResponse.Finished) then
     begin
       // The Finished-flag is a catch-all flag for when the request
       // is finished, no matter if loading was successful or failed.
       // So any cleanup-work should happen here...
       ...
       if (AResponse.Failed) then
       begin
         // Failed is True (in addition to Finished) if something
         // went wrong (file doesn't exist, or less bytes could be
         // read from the file than expected).
       end;
     end;
   end;
   ```

4. Pump the Sokol Fetch message queues, and invoke response callbacks by calling:

   ```pascal
   TFetch.DoWork();
   ```

   In an event-driven app this should be called in the event loop. If you use [Neslib.Sokol.App](Neslib.Sokol.App.md), then this would be in your overridden `TApplication.Frame` method.

5. Finally, call `TFetch.Shutdown` at the end of the application.

There's many other loading-scenarios, for instance one doesn't have to provide a buffer upfront, this can also happen in the response callback.

Or it's possible to stream huge files into small fixed-size buffer, complete with pausing and continuing the download.

It's also possible to improve the 'pipeline throughput' by fetching multiple files in parallel, but at the same time limit the maximum number of requests that can be 'in-flight'.

For how this all works, please read the following documentation sections.

## Api Documentation

### procedure TFetch.Setup(const ADesc: TFetchDesc);

First call `TFetch.Setup(const ADesc: TFetchDesc)` on any thread before calling any other sokol-fetch functions on the same thread.

`TFetch.Setup` takes a TFetchDesc argument with setup parameters. Parameters which should use their default values must be zero-initialized.

* `.MaxRequests`: The maximum number of requests that can be alive at any time. The default is 128.
* `.NumChannels`: The number of "IO channels" used to parallelize and prioritize requests. The default is 1.
* `.NumLanes`:  The number of "lanes" on a single channel. Each request which is currently 'inflight' on a channel occupies one lane until the request is finished. This is used for automatic rate-limiting (see the [Channels and Lanes](#channels-and-lanes) section below for more details). The default number of lanes is 1.
* `.BaseDirectory`: The base directory containing the files you want to fetch. You don't need to set this if you always use absolute paths for the `TFetchRequest.Path` field, or if the files are available in the current directory. The `BaseDirectory` can either be an absolute or relative directory. You usually want to specify a relative directory since this works best on all platforms. In that case, the actual directory will be resolved as follows, depending on the platform:
  * **Windows**: relative to the application directory. Eg. if the application is in "C:\\MyApp\\MyApp.exe" and `BaseDirectory` is set to 'Data', then the files will be read from the "C:\\MyApp\\Data\" directory.
  * **macOS**: relative to the "Contents\\Resources\\" directory. Eg. if `BaseDirectory` is set to 'Data' then you must set the Remote Path in Delphi's Deployment Manager to "Contents\\Resources\\Data\\" for all files you want to fetch.
  * **iOS**: relative to the bundle directory (".\\"). Eg. if `BaseDirectory` is set to 'Data' then you must set the Remote Path in Delphi's Deployment Manager to ".\\Data\\" for all files you want to fetch.
  * **Android**: relative to the "assets\\internal\\" directory. Eg. if `BaseDirectory` is set to 'Data' then you must set the Remote Path in Delphi's Deployment Manager to "assets\\internal\\Data\\" for all files you want to fetch.


For example, to setup sokol-fetch for max 1024 active requests, 4 channels, and 8 lanes per channel in C99:

```pascal
var Desc := TFetchDesc.Create;
Desc.MaxRequests := 1024;
Desc.NumChannels := 4;
Desc.NumLanes := 8;
TFetch.Setup(Desc);
```

`TFetch.Setup` is the only place where Neslib.Sokol.Fetch will allocate memory.

Note that the default setup parameters of 1 channel and 1 lane per channel has a very poor 'pipeline throughput' since this essentially serializes IO  requests (a new request will only be processed when the last one has finished), and since each request needs at least one roundtrip between the user- and IO-thread the throughput will be at most one request per frame. See the [Latency and Throughput](#latency-and-throughput) section below for more information on how to increase throughput.

Note that you can call `TFetch.Setup` on multiple threads. Each thread will get its own thread-local sokol-fetch instance, which will work independently from sokol-fetch instances on other threads.

### procedure TFetch.Shutdown;

Call `TFetch.Shutdown` at the end of the application to stop any IO threads and free all memory that was allocated in `TFetch.Setup`.

### function TFetchRequest.Send: TFetchHandle;

Call `TFetchRequest.Send` to start loading data. The `TFetchRequest` record contains the request parameters and the method returns a `TFetchHandle` identifying the request for later calls. At least a path/URL and callback must be provided:

```pascal
var Request := TFetchRequest.Create;
Request.Path := 'MyFile.txt';
Request.Callback := MyResponseCallback;
```

`TFetchRequest.Send` will return an invalid handle if no request can be allocated rom the internal pool because all available request items are 'in-flight'.

The `TFetchRequest` record contains the following parameters (optional parameters that are not provided must be zero-initialized):

* `.Path` (required): The filesystem path. The maximum length of the string is defined by the `FETCH_MAX_PATH` configuration constant. The default is 1024 bytes after UTF8-conversion, including the 0-terminator byte.
* `.Callback` (required): A response-callback function which is called when the request needs "user code attention". See the [Request States and the Response Callback](#request-states-and-the-response-callback) below for detailed information about handling responses in the response callback.
* `.Channel` (optional): Index of the IO channel where the request should be processed. Channels are used to parallelize and prioritize requests relative to each other. See the [Channels and Lanes](#channels-and-lanes) section below for more information. The default channel is 0.
* `.ChunkSize` (optional): The `ChunkSize` field is used for streaming data incrementally in small chunks. After `ChunkSize` bytes have been loaded into to the streaming buffer, the response callback will be called with the buffer containing the fetched data for the current chunk. If `ChunkSize` is 0 (the default), than the whole file will be loaded. 
* `.BufferPtr, .BufferSize` (optional): This is an optional pointer/size pair describing a chunk of memory where data will be loaded into (if no buffer is provided upfront, this must happen in the response callback). If a buffer is provided, it must be big enough to either hold the entire file (if `ChunkSize` is zero), or the *uncompressed* data for one downloaded chunk (if `ChunkSize` is > 0).
* `.UserData, .UserDataSize` (optional):  POD (plain-old-data) associated with the request, which will be copied(!) into an internal memory block. The maximum size of this memory  block is 128 bytes. Since this block is copied, you must *not* put any managed data in here (like strings or object interfaces).

Note that request handles are strictly thread-local and only unique within the thread the handle was created on, and all function calls involving a request handle must happen on that same thread.

### function TFetchHandle.Valid: Boolean;

This checks if the request handle is valid, and is associated with a currently active request. It will return False if:

* `TFetchRequest.Send` returned an invalid handle because it couldn't allocate a new request from the internal request pool (because they're all in flight).
* The request associated with the handle is no longer alive (because it either finished successfully, or the request failed for some reason).

### procedure TFetch.DoWork;

Call `TFetch.DoWork` in regular intervals (for instance once per frame) on the same thread as `TFetch.Setup` to "turn the gears". If you are sending requests but never hear back from them in the response callback function, then the most likely reason is that you forgot to add the call to `TFetch.DoWork` in the per-frame function.

`TFetch.DoWork` roughly performs the following work:

* Any new requests that have been sent with `TFetchRequest.Send` since the last call to `TFetch.DoWork` will be dispatched to their IO channels and assigned a free lane. If all lanes on that channel are occupied by requests 'in flight', incoming requests must wait until a lane becomes available.
* For all new requests which have been enqueued on a channel which don't already have a buffer assigned the response callback will be called with (`AResponse.Dispatched = True`) so that the response callback can inspect the dynamically assigned lane and bind a buffer to the request (see the [Channels and Lanes](#channels-and-lanes) section below for more info).
* A state transition from "user side" to "IO thread side" happens for each new request that has been dispatched to a channel.
* Requests dispatched to a channel are either forwarded into that channel's worker thread.
* For all requests which have finished their current IO operation, a state transition from "IO thread side" to "user side" happens, and the response callback is called so that the fetched data can be processed.
* Requests which are completely finished (either because the entire file content has been loaded, or they are in the `TFetchState.Failed` state) are freed (this just changes their state in the 'request pool', no actual memory is freed).
* Requests which are not yet finished are fed back into the 'incoming' queue of their channel, and the cycle starts again, this only happens for requests which perform data streaming (not load the entire file at once).

### procedure TFetchHandle.Cancel;

This cancels the request in the next `TFetch.DoWork` call and invokes the response callback with (`AResponse.Failed = True`) and (`AResponse.Finished`
`= True`) to give user-code a chance to do any cleanup work for the request. If `TFetchHandle.Cancel` is called for a request that is no longer alive, nothing bad will happen (the call will simply do nothing).

### procedure TFetchHandle.Pause;

This pauses the active request in the next `TFetch.DoWork` call and puts it into the `TFetchState.Paused` state. For all requests in `TFetchState.Paused` state, the response callback will be called in each call to `TFetch.DoWork` to give user-code a chance to continue the request (by calling `TFetchHandle.Continue`). Pausing a request makes sense for dynamic rate-limiting in streaming scenarios (like video/audio streaming with a fixed number of streaming buffers). As soon as all available buffers are filled with download data, downloading more data must be prevented to allow video/audio playback to catch up and free up empty buffers for new download data.

### procedure TFetchHandle.Continue;

Continues the paused request. Counterpart to the `TFetchHandle.Pause` method.

### procedure TFetchHandle.BindBuffer(const ABuffer: Pointer; const ABufferSize: Int64);

This "binds" a new buffer (pointer/size pair) to the active request. The function *must* be called from inside the response-callback, and there must not already be another buffer bound.

### function TFetchHandle.UnbindBuffer: Pointer;

This removes the current buffer binding from the request and returns a pointer to the previous buffer (useful if the buffer was dynamically allocated and it must be freed).

`TFetchHandle.UnbindBuffer` *must* be called from inside the response callback.

The usual code sequence to bind a different buffer in the response callback might look like this:

```pascal
procedure TMyApp.ResponseCallback(const AResponse: TFetchResponse);
begin
  if (AResponse.Fetched) then
  begin
    ...
    // Switch to a different buffer (in the FETCHED state it is
    // guaranteed that the request has a buffer. Otherwise, it
    // would have gone into the FAILED state.
    var OldBufPtr := AResponse.Handle.UnbindBuffer;
    FreeMem(OldBufPtr);
    var NewBufPtr: Pointer;
    GetMem(NewBufPtr, NewBufSize);
    AResponse.Handle.BindBuffer(NewBufPtr, NewBufSize);
  end;
  if (AResponse.Finished) then
  begin
    // Unbind and free the currently associated buffer.
    // The buffer pointer could be nil if the request has failed
    // Note that it is legal to call FreeMem with a nil pointer.
    // This happens if the request failed to open its file
    // and never goes into the OPENED state.
    var BufPtr := AResponse.Handle.UnbindBuffer;
    FreeMem(BufPtr);
  end;
end;
```

### function TFetch.Desc: TFetchDesc

Returns a copy of the `TFetchDesc` record passed to `TFetch.Setup`, with zero-initialized values replaced with their default values.

### property TFetch.MaxPath: Integer;

Returns the value of the `FETCH_MAX_PATH` config constant.

## Request States and the Response Callback

A request goes through a number of states during its lifetime. Depending on the current state of a request, it will be 'owned' either by the "user-thread" (where the request was sent) or an IO thread.

You can think of a request as "ping-ponging" between the IO thread and user thread, any actual IO work is done on the IO thread, while invocations of the response-callback happen on the user-thread.

All state transitions and callback invocations happen inside the `TFetch.DoWork` method.

An active request goes through the following states:

* `TFetchState.Allocated` (user-thread): The request has been allocated in TFetchRequest.Send and is waiting to be dispatched into its IO channel.  When this happens, the request will transition into the `TFetchState.Dispatched` state.
* `TFetchState.Dispatched` (IO thread): The request has been dispatched into its IO channel, and a lane has been assigned to the request.
    If a buffer was provided in `TFetchRequest.Send`, the request will immediately transition into the `TFetchState.Fetching` state and start loading data into the buffer.
    If no buffer was provided in `TFetchRequest.Send`, the response callback will be called with `(AResponse.Dispatched = True)`, so that the response callback can bind a buffer to the request. Binding the buffer in the response callback makes sense if the buffer isn't dynamically allocated, but instead a pre-allocated buffer must be selected from the request's channel and lane.
    Note that it isn't possible to get a file size in the response callback which would help with allocating a buffer of the right size.
    If opening the file failed, the request will transition into the `TFetchState.Failed` state with the error code `TFetchError.FileNotFound`.
* `TFetchState.Fetching` (IO thread): While a request is in the `TFetchState.Fetching` state, data will be loaded into the user-provided buffer.
    If no buffer was provided, the request will go into the `TFetchState.Failed` state with the error code `TFetchError.NoBuffer`.
    If a buffer was provided, but it is too small to contain the fetched data, the request will go into the `TFetchState.Failed` state with error code `TFetchError.BufferTooSmall`.
    If less data can be read from the file than expected, the request will go into the `TFetchState.Failed` state with error code `TFetchError.UnexpectedEof`.
    If loading data into the provided buffer works as expected, the request will go into the `TFetchState.Fetched` state.
* `TFetchState.Fetched` (user thread): The request goes into the TFetchState.Fetched state either when the entire file has been loaded into the provided buffer (when `Request.ChunkSize = 0`), or a chunk has been loaded (and optionally decompressed) into the buffer (when `Request.ChunkSize > 0`).
    The response callback will be called so that the user-code can process the loaded data using the following `TFetchResponse` record members:
    
    * `.FetchedSize`: the number of bytes in the provided buffer
    * `.BufferPtr`: pointer to the start of fetched data
    * `.FetchedOffset`: the byte offset of the loaded data chunk in the overall file (this is only set to a non-zero value in a streaming scenario)
    
    Once all file data has been loaded, the `Finished` flag will be set in the response callback's `TFetchResponse` argument.
    After the user callback returns, and all file data has been loaded (`AResponse.Finished` flag is set) the request has reached its end-of-life and will recycled.
    Otherwise, if there's still data to load (because streaming was requested by providing a non-zero `Request.ChunkSize`), the request will switch back to the `TFetchState.Fetching` state to load the next chunk of data.
    Note that it is ok to associate a different buffer or buffer-size with the request by calling `TFetchHandle.BindBuffer` in the response-callback.
    To check in the response callback for the `TFetchState.Fetched` state, and independently whether the request is finished:
    
    ```pascal
    procedure TMyApp.ResponseCallback(const AResponse: TFetchResponse);
    begin
      if (AResponse.Fetched) then
      begin
        // Request is in Fetched state. The loaded data is available
        // in .BufferPtr, and the number of bytes that have been
        // loaded in .FetchedSize:
        var Data := AResponse.BufferPtr;
        var NumBytes := AResponse.FetchedSize;
      end;
      if (AResponse.Finished) then
      begin
        // The finishedFflag is set either when all data
        // has been loaded, the request has been cancelled,
        // or the file operation has failed, this is where
        // any required per-request cleanup work should happen
      end;
    end;
    ```

* `TFetchState.Failed` (user thread): A request will transition into the `TFetchState.Failed` state in the following situations:
      
        * if the file doesn't exist or couldn't be opened for other reasons (`TFetchError.FileNotFound`)
        * if no buffer is associated with the request in the `TFetchState.Fetching` state (`TFetchError.NoBuffer`)
        * if the provided buffer is too small to hold the entire file (if `Request.ChunkSize = 0`), or the (potentially decompressed) partial data chunk (`TFetchError.BufferTooSmall`)
        * if less bytes could be read from the file then expected (`TFetchError.UnexpectedEof`)
        * if a request has been cancelled via `TFetchHandle.Cancel` (`TFetchError.Cancelled`)
    
      The response callback will be called once after a request goes into the `TFetchState.Failed` state, with the `Response.Finished` and
      `Response.Failed` flags set to `True`.
      This gives the user-code a chance to cleanup any resources associated with the request.
    To check for the failed state in the response callback:
    
    ```pascal
    procedure TMyApp.ResponseCallback(const AResponse: TFetchResponse);
    begin
      if (AResponse.Failed) then
      begin
        // Specifically check for the failed state...
      end;
    
      // Or you can do a catch-all check via theFfinished-flag:
      if (AResponse.Finished) then
      begin
        if (AResponse.Failed) then
        begin
          // If more detailed error handling is needed:
          case AResponse.ErrorCode of
            ...
          end;
        end;
      end;
    end;
    ```
    
* `TFetchState.Paused` (user thread): A request will transition into the `TFetchState.Pauses` state after user-code calls `TFetchHandle.Pause`. Usually
    this happens from within the response-callback in streaming scenarios when the data streaming needs to wait for a data decoder (like a video/audio player) to catch up.
    While a request is in `TFetchHandle.Paused` state, the response-callback will be called in each `TFetch.DoWork`, so that the user-code can either continue the request by calling `TFetchHandle.Continue`, or cancel the request by calling `TFetchHandle.Cancel`.
    When calling `TFetchHandle.Continue` on a paused request, the request will transition into the `TFetchState.Fetching` state. Otherwise if `TFetchHandle.Cancel` is called, the request will switch into the TFetchState.Failed state.
    To check for the `TFetchState.Paused` state in the response callback:
    
    ```pascal
    procedure TMyApp.ResponseCallback(const AResponse: TFetchResponse);
    begin
      if (AResponse.Paused) then
      begin
        // We can check here whether the request should
        // continue to load data:
        if (ShouldContinue(AResponse.Handle)) then
          AResponse.Handle.Continue;
      end;
    end;
    ```

## Channels and Lanes

Channels and lanes are (somewhat artificial) concepts to manage parallelization, prioritization and rate-limiting.

Channels can be used to parallelize message processing for better 'pipeline throughput', and to prioritize requests: user-code could reserve one channel for streaming downloads which need to run in parallel to other requests, another channel for "regular" downloads and yet another high-priority channel  which would only be used for small files which need to start loading immediately.

Each channel comes with its own IO thread and message queues for pumping messages in and out of the thread. The channel where a request is processed is selected manually when sending a message:

```pascal
var Request := TFetchRequest.Create;
Request.Path := 'MyFile.txt';
Request.Callback := MyResponseCallback;
Request.Channel := 2;
Request.Send;
```

The number of channels is configured at startup in `TFetch.Setup` and cannot be changed afterwards.

Channels are completely separate from each other, and a request will never "hop" from one channel to another.

Each channel consists of a fixed number of "lanes" for automatic rate limiting:

When a request is sent to a channel via `TFetchRequest.Send`, a "free lane" will be picked and assigned to the request. The request will occupy this lane for its entire life time (also while it is paused). If all lanes of a channel are currently occupied, new requests will need to wait until a lane becomes unoccupied.

Since the number of channels and lanes is known upfront, it is guaranteed that there will never be more than `NumChannels * NumLanes` requests in flight at any one time.

This guarantee eliminates unexpected load- and memory-spikes when many requests are sent in very short time, and it allows to pre-allocate a fixed number of memory buffers which can be reused for the entire "lifetime" of a Sokol Fetch context.

In the most simple scenario - when a maximum file size is known - buffers can be statically allocated like this:

```pascal
var Buffer: array [0..NUM_CHANNELS - 1, 0..NUM_LANES - 1, 0..MAX_FILE_SIZE - 1] of Byte;
```

Then in the user callback pick a buffer by channel and lane, and associate it with the request like this:

```pascal
procedure TMyApp.ResponseCallback(const AResponse: TFetchResponse);
begin
  if (AResponse.Dispatched) then
  begin
    var Ptr := @Buffer[AResponse.Channel, AResponse.Lane];
    AResponse.Handle.BindBuffer(Ptr, MAX_FILE_SIZE);
  end;
end;
```

## Notes on Optimizing Pipeline Latency and Throughput

With the default configuration of 1 channel and 1 lane per channel, Neslib.Sokol.Fetch will appear to have a shockingly bad loading performance if several files are loaded.

This has two reasons:
1. all parallelization when loading data has been disabled. A new request will only be processed, when the last request has finished.
2. every invocation of the response-callback adds one frame of latency to the request, because callbacks will only be called from within `TFetch.DoWork`.

Neslib.Sokol.Fetch takes a few shortcuts to improve step (2) and reduce the 'inherent latency' of a request:

* if a buffer is provided upfront, the response-callback won't be called in the `TFetchState.Dispatched` state, but start right with the `TFetchState.Fetched` state where data has already been loaded into the buffer.
* there is no separate `TFetchedState.Closed` state where the callback is invoked separately when loading has finished (or the request has failed). Instead the finished and failed flags will be set as part of the last Fetched invocation.

This means providing a big-enough buffer to fit the entire file is the best case, the response callback will only be called once, ideally in the next frame (or two calls to `TFetch.DoWork`).

If no buffer is provided upfront, one frame of latency is added because the response callback needs to be invoked in the `TFetchState.Dispatched` state so that the user code can bind a buffer.

This means the best case for a request without an upfront-provided buffer is 2 frames (or 3 calls to `TFetch.DoWork`).

That's about what can be done to improve the latency for a single request, but the really important step is to improve overall throughput. If you need to load thousands of files you don't want that to be completely serialized.

The most important action to increase throughput is to increase the number of lanes per channel. This defines how many requests can be 'in flight' on a single channel at the same time. The guiding decision factor for how many lanes you can "afford" is the memory size you want to set aside for buffers. Each lane needs its own buffer so that the data loaded for one request doesn't scribble over the data loaded for another request.

Here's a simple example of sending 4 requests without upfront buffer on a channel with 1, 2 and 4 lanes, each line is one frame:

    1 LANE (8 frames):
        Lane 0:
        -------------
        REQ 0 DISPATCHED
        REQ 0 FETCHED
        REQ 1 DISPATCHED
        REQ 1 FETCHED
        REQ 2 DISPATCHED
        REQ 2 FETCHED
        REQ 3 DISPATCHED
        REQ 3 FETCHED

Note how the request don't overlap, so they can all use the same buffer.

    2 LANES (4 frames):
        Lane 0:             Lane 1:
        ------------------------------------
        REQ 0 DISPATCHED    REQ 1 DISPATCHED
        REQ 0 FETCHED       REQ 1 FETCHED
        REQ 2 DISPATCHED    REQ 3 DISPATCHED
        REQ 2 FETCHED       REQ 3 FETCHED

This reduces the overall time to 4 frames, but now you need 2 buffers so that requests don't scribble over each other.

    4 LANES (2 frames):
        Lane 0:             Lane 1:             Lane 2:             Lane 3:
        ----------------------------------------------------------------------------
        REQ 0 DISPATCHED    REQ 1 DISPATCHED    REQ 2 DISPATCHED    REQ 3 DISPATCHED
        REQ 0 FETCHED       REQ 1 FETCHED       REQ 2 FETCHED       REQ 3 FETCHED

Now we're down to the same 'best-case' latency as sending a single request.

Apart from the memory requirements for the streaming buffers (which is under your control), you can be generous with the number of lanes, they don't add any processing overhead.

The last option for tweaking latency and throughput is channels. Each channel works independently from other channels, so while one channel is busy working through a large number of requests (or one very long streaming download), you can set aside a high-priority channel for requests that need to start as soon as possible.

On platforms with threading support, each channel runs on its own thread, but this is mainly an implementation detail to work around the blocking traditional file IO functions, not for performance reasons.

# Neslib.Sokol.Audio

Cross-platform audio-streaming API.

This is a light-weight OOP layer on top of [sokol_audio.h](https://github.com/floooh/sokol).

## Feature Overview

You provide a mono- or stereo-stream of 32-bit float samples, which Sokol Audio feeds into platform-specific audio backends:

- Windows: WASAPI
- macOS: CoreAudio
- iOS: CoreAudio + AVAudioSession
- Android: OpenSLES

Sokol Audio will not do any buffer mixing or volume control. If you have multiple independent input streams of sample data you need to perform the mixing yourself before forwarding the data to Sokol Audio.

There are two mutually exclusive ways to provide the sample data:

1. Callback model: You provide a callback event, which will be called when Sokol Audio needs new samples. This event is called from a separate thread.
2. Push model: Your code pushes small blocks of sample data from your main loop or a thread you created. The pushed data is stored in a ring buffer where it is pulled by the backend code when needed.

The callback model is preferred because it is the most direct way to feed sample data into the audio backends and also has less moving parts (there is no ring buffer between your code and the audio backend).

Sometimes it is not possible to generate the audio stream directly in a callback event running in a separate thread. For such cases Sokol Audio provides the push-model as a convenience.

## Sokol Audio, SoLoud and MiniAudio

The WASAPI, OpenSLES and CoreAudio backend code has been taken from the [SoLoud](https://github.com/jarikomppa/soloud) library (with some modifications, so any bugs in there are most likely my fault). If you need a more fully-featured audio solution, check out SoLoud, it's excellent.

Another alternative which feature-wise is somewhere in between SoLoud and Sokol Audio might be [MiniAudio](https://github.com/mackron/miniaudio).

## Glossary

- Stream buffer: The internal audio data buffer, usually provided by the backend API. The size of the stream buffer defines the base latency, smaller buffers have lower latency but may cause audio glitches. Bigger buffers reduce or eliminate glitches, but have a higher base latency.
  
- Stream callback: Optional callback event which is called by Sokol Audio when it needs new samples. This is called in a separate thread.
  
- Channel: A discrete track of audio data, currently 1-channel (mono) and 2-channel (stereo) is supported and tested.
  
- Sample: The magnitude of an audio signal on one channel at a given time. In Sokol Audio, samples are 32-bit float numbers in the range -1.0 to +1.0.
  
- Frame: The tightly packed set of samples for all channels at a given time. For mono 1 frame is 1 sample. For stereo, 1 frame is 2 samples.
  
- Packet: In Sokol Audio, a small chunk of audio data that is moved from the main thread to the audio streaming thread in order to decouple the rate at which the main thread provides new audio data, and the streaming thread consuming audio data.

## Working with Sokol Audio

First call `TAudio.Setup` with your preferred audio playback options. In most cases you can stick with the default values. These provide a good balance between low-latency and glitch-free playback on all audio backends.

If you want to use the callback-model, you need to provide a stream callback event in `TAudioDesc.OnStream`. Otherwise keep this event nil.

Use push model and default playback parameters:

```pascal
var Desc := TAudioDesc.Create;
TAudio.Setup(Desc);
```

Use stream callback model and default playback parameters:

```pascal
var Desc := TAudioDesc.Create;
Desc.OnStream := StreamAudio;
TAudio.Setup(Desc);
```

The following playback parameters can be provided through the `TAudioDesc` record:

General parameters (both for stream-callback and push-model):

* `SampleRate: Integer;` -- the sample rate in Hz, default: 44100
* `NumChannels: Integer;` -- number of channels, default: 1 (mono)
* `BufferFrames: Integer;` -- number of frames in streaming buffer, default: 2048

The stream callback event:

```pascal
TOnAudioStream = procedure(const ABuffer: PAudioSample; const ANumFrames, ANumChannels: Integer) of object;
```

Push-model parameters:
* `PacketFrames: Integer;` -- number of frames in a packet, default: 128
* `NumPackets: Integer;` -- number of packets in ring buffer, default: 64

The `SampleRate` and `NumChannels` fields are only hints for the audio backend. It isn't guaranteed that those are the values used for actual playback.

To get the actual parameters, use the following class properties `SampleRate` and `NumChannels` after `TAudio.Setup`:

It's unlikely that the number of channels will be different than requested, but a different sample rate isn't uncommon.

(Note: there's a yet unsolved issue when an audio backend might switch to a different sample rate when switching output devices, for instance plugging in a bluetooth headset, this case is currently not handled in Sokol Audio).

You can check if audio initialization was successful with `TAudio.IsValid`. If backend initialization failed for some reason (for instance when there's no audio device in the machine), this will return `False`. Not checking for success won't do any harm; all Sokol Audio function will silently fail when called after initialization has failed. So apart from missing audio output, nothing bad will happen.

Before your application exits, you should call `TAudio.Shutdown`. This stops the audio thread and properly shuts down the audio backend.

## The Stream Callback Model

To use Sokol Audio in stream-callback-mode, provide a callback event like this in the `TAudioDesc` record when calling `TAudio.Setup`:

```pascal
procedure TMyApp.StreamAudio(const ABuffer: PAudioSample; const ANumFrames, ANumChannels: Integer);
begin
  ...
end;
```

The job of the callback event is to fill the `ABuffer` with 32-bit float sample values.

To output silence, fill the buffer with zeros:

```pascal
procedure TMyApp.StreamAudio(const ABuffer: PAudioSample; const ANumFrames, ANumChannels: Integer);
begin
  FillChar(ABuffer^, ANumFrames * ANumChannels * SizeOf(TAudioSample), 0);
end;
```

For stereo output (`ANumChannels` = 2), the samples for the left and right channel are interleaved:

```pascal
procedure TMyApp.StreamAudio(const ABuffer: PAudioSample; const ANumFrames, ANumChannels: Integer);
begin
  Assert(ANumChannels = 2);
  for var I := 0 to ANumFrames - 1 do
  begin
    ABuffer[2 * I + 0] := ...; // Left channel
    ABuffer[2 * I + 1] := ...; // Right channel
  end;
end;
```

Please keep in mind that the stream callback event is running in a separate thread. If you need to share data with the main thread you need to take care yourself to make the access to the shared data thread-safe!

## The Push Model

To use the push-model for providing audio data, simply don't set (keep zero-initialized) the `OnStream` field in the `TAudioDesc` record when calling `TAudio.Setup`.

To provide sample data with the push model, call the `TAudio.Push` method at regular intervals (for instance once per frame). You can call the `TAudio.Expect` method to ask Sokol Audio how much room is in the ring buffer, but if you provide a continuous stream of data at the right sample rate, `TAudio.Expect` isn't required (it's a simple way to sync/throttle your sample generation code with the playback rate though).

With `TAudio.Push` you may need to maintain your own intermediate sample buffer, since pushing individual sample values isn't very efficient. The following example is from the MOD player sample:

```pascal
var NumFrames := TAudio.Expect;
if (NumFrames > 0) then
begin
  var NumSamples := NumFrames * TAudio.NumChannels;
  ReadSamples(Buf, NumSamples);
  TAudio.Push(Buf, NumFrames);
end;
```

Another option is to ignore `TAudio.Expect`, and just push samples as they are generated in small batches. In this case you *need* to generate the samples at the right sample rate.
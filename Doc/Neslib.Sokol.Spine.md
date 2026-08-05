# Neslib.Sokol.Spine

A [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md) renderer for the [spine-c runtime](https://github.com/EsotericSoftware/spine-runtimes/tree/4.1/spine-c)

> **IMPORTANT**: Using this unit for purposes other than evaluation requires a [Spine License](https://esotericsoftware.com/spine-purchase)!

## Feature Overview

Neslib.Sokol.Spine is a Neslib.Sokol.Gfx renderer and 'handle wrapper' for [Spine](http://en.esotericsoftware.com/spine-in-depth) on top of the
[spine-c runtime](http://en.esotericsoftware.com/spine-c).

The [Neslib.Sokol.Gfx](Neslib.Sokol.Gfx.md) renderer allows to manage multiple contexts for rendering Spine scenes into different Gfx render passes (similar to [Neslib.Sokol.GL](Neslib.Sokol.GL.md) and [Neslib.Sokol.DebugText](Neslib.Sokol.DebugText.md)), allows to split rendering into layers to mix Spine rendering with other rendering operations, and it automatically batches adjacent draw calls for Spine objects that use the same texture and in the same layer.

Neslib.Sokol.Spine wraps 'raw' spine-c objects with tagged index handles. This eliminates the risk of memory corruption via dangling pointers. Any API calls involving invalid objects either result in a no-op, or
in a proper error.

The Neslib.Sokol.Spine API exposes four 'base object types', and a number of 'subobject types' which are owned by base objects.

Base object types are:

- `TSpineAtlas`: A wrapper around a spine-c `spAtlas` object. Each `TSpineAtlas` object owns at least one `TSpineAtlasPage` object, and each `TSpineAtlasPage` object owns one Neslib.Sokol.Gfx `TImage`, `TView` and `TSampler` object.
  
- `TSpineSkeleton`: A skeleton object requires an atlas object for creation, and is a wrapper around one spine-c `spSkeletonData` and one `spAnimationStateData` object.  both contain the shared static data for individual spine instances.
  
- `TSpineInstance`: Instance objects are created from skeleton objects. Instances are the objects that are actually getting rendered. Each instance tracks its own transformation and animation state, but otherwise just references shared data of the skeleton object it was created from. A `TSpineInstance` object is a wrapper around one spine-c `spSkeleton`, `spAnimationState` and `spSkeletonClipping` object each.
  
- `TSpineSkinset`: Skin-set objects are collections of skins which define the look of an instance. Some Spine scenes consist of combinable skins (for instance a human character could offer different skins for different types of clothing, hats, scarfs, shirts, pants, and so on..., and a skin
  set would represent a specific outfit).

Subobject types allow to inspect and manipulate Spine objects in more detail:

- `TSpineAnim`: Each skeleton object usually offers animations which can then be scheduled and mixed on an instance.
  
- `TSpineBone`: Bone objects are the hierarchical transform nodes of a skeleton. The Neslib.Sokol.Spine API allows both to inspect the shared static bone attributes of a `TSpineSkeleton` object, as well as
  inspecting and manipulating the per-instance bone attributes on a `TSpineInstance` object.
  
- `TSpineEvent`: A running Spine animation may fire 'events' at certain positions in time (for instance a 'footstep' event whenever a foot hits the ground). Events can be used to play sound effects (or visual
  effects) at the right time.
  
- `TSpineIKTarget`: Allows to set the target position for a group of bones controlled by inverse kinematics.

There's a couple of other subobject types which are mostly useful to inspect the interior structure of skeletons. Those will be explained in detail further down.

## Minimal API usage overview

During initialization:

- call `TSpine.Setup` after initializing Neslib.Sokol.Gfx
- create an atlas object from a Spine atlas file with `TSpineAtlas.Create`
- load and initialize the Neslib.Sokol.Gfx image, view and sampler objects for the texture data referenced by the atlas
- create a skeleton object from a Spine skeleton file with `TSpineSkeleton.Create`
- create at least one instance object with `TSpineInstance.Create`

In the frame loop, outside of Neslib.Sokol.Gfx render passes:

- if needed, move instances around with the `TSpineInstance.Position` property
- if needed, schedule new animations with `TSpineInstance.SetAnimation` and `TSpineInstance.AddAnimation`
- each frame, advance the current instance animation state with `TSpineInstance.Update`
- each frame, render instances with `TSpineInstance.Draw`. This just records vertices, indices and draw commands into internal buffers, but does no actual Gfx rendering

In the frame loop, inside a Neslib.Sokol.Gfx render pass:

- call `TSpine.DrawLayer` to draw all previously recorded instances in a specific layer

On shutdown:

- call `TSpine.Shutdown`, ideally before shutting down Neslib.Sokol.Gfx

## Quickstart step-by-step

See the SpineSimple sample application for a minimal example.

- Neslib.Sokol.Gfx must be initialized before Neslib.Sokol.Spine:

  ```pascal
  TGfx.Setup(...);
  TSpine.Setup(...);
  ```

- You should always provide a logging callback to, otherwise no warning or errors will be logged. The easiest way is using the DefaultLogger provided by Sokol:

  ```pascal
  var Desc := TSpineDesc.Create;
  Desc.Logger := Desc.DefaultLogger;
  TSpine.Setup(Desc);
  ```

- You can tweak the memory usage of sokol-spine by limiting or expanding the maximum number of vertices, draw commands and pool sizes:

  ```pascal
  var Desc := TSpineDesc.Create;
  Desc.MaxVertices := 1024;    // Default 65536
  Desc.MaxCommand := 128;	     // Default 16384
  Desc.ContextPoolSize := 1;   // Default 4
  Desc.AtlasPoolSize := 1;     // Default 64
  Desc.SkeletontPoolSize := 1; // Default 64
  Desc.SkinsetPoolSize := 1;   // Default 64
  Desc.InstancePoolSize := 16; // Default 1024
  Desc.Logger := Desc.DefaultLogger;
  TSpine.Setup(Desc);
  ```

  Neslib.Sokol.Spine uses 32-bit vertex-indices for rendering (`TIndexType.UInt32`), so that the maximum number of Spine vertices in a frame isn't limited to 65536.
  
- After initialization, the first thing you need is a `TSpineAtlas` object. Neslib.Sokol.Spine doesn't concern itself with file IO, it expects all external data to be provided as pointer/size pairs:

  ```pascal
  var Desc := TSpineAtlasDesc.Create;
  Desc.Data := TSpineRange.Create(DataPtr, DataSize);
  var Atlas := TSpineAtlas.Create(Desc);
  Assert(Atlas.Valid);
  ```
  If you load the atlas data asynchronously, you can still run your per-frame rendering code without waiting for the atlas data to be loaded and the atlas to be created. This works because calling Neslib.Sokol.Spine functions with 'invalid' object handles is a valid no-op.

- Optionally you can override some or all of the atlas texture creation parameters:

  ```pascal
  var Desc := TSpineAtlasDesc.Create;
  Desc.Data := TSpineRange.Create(DataPtr, DataSize);
  Desc.MinFilter := TFilter.Nearest;
  Desc.MagFilter := TFilter.Nearest;
  Desc.MipmapFilter := TFilter.Nearest;
  Desc.WrapU := TWrap.Mirror;
  Desc.WrapV := TWrap.Mirror;
  Desc.PremulAlphaEnabled := ...;
  Desc.PremulAlphaDisabled := ...;
  var Atlas := TSpineAtlas.Create(Desc);
  ```

- The atlas file itself doesn't contain any texture data, it only contains filenames of the required textures. Neslib.Sokol.Spine has already allocated a Neslib.Sokol.Gfx `TImage`, `TView` and `TSampler` handle for each required texture, but the actual loading and initialization must be performed by user code:

  ```pascal
  { Iterate over atlas textures and initialize 
    Gfx image objects with existing handles }
  for var I := 0 to Atlas.ImageCount - 1 do
  begin
    var Img: TSpineImage := Atlas.Images[I];
    var ImgInfo := Image.Info;
    Assert(ImgInfo.Valid);
    Assert(not ImgInfo.Filename.Truncated);
    
    { The filename is now in ImgInfo.Filename, which is of a
      TSpineString type that can be converted to a Delphi string 
      (either implicitly or through the ToString method). 
      "Somehow" load and decode the image data into memory, and then
      initialize the Gfx image, view and sampler from existing 
      handles in ImgInfo.Image: }
    var ImageDesc := TImageDesc.Create;
    ImageDesc.Width := ...;
    ImageDesc.Height := ...;
    ImageDesc.PixelFormat := ...;
    ImageDesc.MipLevels[0] := TRange.Create(DecodedImageData);
    ImgInfo.Image.Setup(ImageDesc);
    
    var ViewDesc := TViewDesc.Create;
    ViewDesc.Texture.Image := ImgInfo.Image;
    ImgInfo.View.Setup(ViewDesc);
    
    var SamplerDesc := TSamplerDesc.Create;
    SamplerDesc.MinFilter := ImgInfo.MinFilter;
    SamplerDesc.MagFilter := ImgInfo.MagFilter;
    SamplerDesc.MipmapFilter := ImgInfo.MipmapFilter;
    SamplerDesc.WrapU := ImgInfo.WrapU;
    SamplerDesc.WrapV := ImgInfo.WrapV;
    ImgInfo.Sampler.Setup(SamplerDesc);
  end;
  ```

  If you load the image data asynchronously, you can still simply start rendering before the image data is loaded. This works because Neslib.Sokol.Gfx will silently drop any rendering operations that involve 'incomplete' objects.

- Once an atlas object has been created (independently from loading any image data), a `TSpineSkeleton` object is needed next. This requires a valid atlas object handle as input, and the Spine skeleton file data loaded into memory.

  Spine skeleton files come in two flavours: binary or json. For binary data, a pointer/size pair must be provided:

  ```pascal
  var Desc := TSpineSkeletonDesc.Create;
  Desc.Atlas := Atlas; // Must be as valid TSpineAtlas
  Desc.BinaryData.Data := ...; // Pointer to binary skeleton data
  Desc.BinaryData.Size := ...; // Size in bytes
  var Skeleton := TSpineSkeleton.Create(SkeletonDesc);
  Assert(Skeleton.Valid);
  ```

  For JSON skeleton file data, the data must be provided as a `UTSF8String`:

  ```pascal
  var Desc := TSpineSkeletonDesc.Create;
  Desc.Atlas := Atlas; 
  Desc.JsonData := ...; // JSON skeleton dagta
  var Skeleton := TSpineSkeleton.Create(SkeletonDesc);
  ```

  Like with all Neslib.Sokol.Spine objects, if you load the skeleton data asynchronously and only then create a skeleton object, you can already start rendering before the data is loaded and the Spine objects have been created. Any operations involving 'incomplete' handles will be dropped.

- You can pre-scale the Spine scene size, and you can provide a default cross-fade duration for animation mixing:

  ```pascal
  var Desc := TSpineSkeletonDesc.Create;
  Desc.Atlas := Atlas; 
  Desc.BinaryData := ...;
  Desc.Prescale = 0.5; // Scale to half size
  Desc.AnimDefaultMix := 0.2; // default anim mixing cross-fade duration 0.2 seconds
  var Skeleton := TSpineSkeleton.Create(SkeletonDesc);
  ```

- Once the skeleton object has been created, it's finally time to create one or many instance objects. If you want to independently render and animate the 'same' Spine object many times in a frame, you should only create one `TSpineSkeleton` object, and then as many `TSpineInstance` objects as needed from the shared skeleton object:

  ```pascal
  var Desc := TSpineInstanceDesc.Create;
  Desc.Skeleton := Skeleton; // Must be a valid TSpineSkeleton 
  var Instance := TSpineInstance.Create(SkeletonDesc);
  Assert(Instance.Valid)
  ```

  After creation, the `TSpineInstance` will have a 'default skin' set as its appearance.

- To set the position of an instance:

  ```pascal
  Instance.Postion := Vector2(X, Y);
  ```

  Neslib.Sokol.Spine doesn't define a specific unit (like pixels or meters), instead the rendering coordinate system is defined later at 'render time'.

- To schedule an initial looping animation by its name:

  ```pascal
  { First lookup up the animation by name on the skeleton: }
  var Anim := Skeleton.AnimByName('walk');
  Assert(Anim.Valid);
  
  { Then schedule the animation on the instance, 
    on mixer track 0, as looping: }
  Instance.SetAnimation(Anim, 0, True);
  ```

  Scheduling and mixing animations will be explained in more detail further down.

- To advance and mix instance animations:

  ```pascal
  Instance.Update(DeltaTimeInSeconds);
  ```

  Usually you'd call this each frame for each active instance with the frame duration in seconds.

- Now it's finally time to 'render' the instance at its current position and animation state:

  ```pascal
  Instance.Draw(0);
  ```

  Instances are generally rendered into numbered virtual 'render layers' (in this case, layer 0). Layers are useful for interleaving Neslib.Sokol.Spine rendering with other rendering commands (like background and foreground tile maps, sprites or text).

- It's important to note that no actual Neslib.Sokol.Gfx rendering happens in `TSpineInstance.Draw`. Instead only vertices, indices and draw commands are recorded into internal memory buffers.

- The only Neslib.Sokol.Spine function which *must* (and should) be called inside a Neslib.Sokol.Gfx rendering pass is `TSpine.DrawLayer`.

  This renders all draw commands that have been recorded previously in a specific layer via `TSpineInstance.Draw`.

  ```pascal
  var Transform: TSpineLayerTransform := ...;
  
  TGfx.BeginPass(...);
  TSpine.DrawLayer(0, Transform);
  TGfx.EndPass;
  TGfx.Commit;
  ```

  **IMPORTANT**: Do *not* mix any calls to `TSpineInstance.Draw` with `TSpine.Draw`, as this will confuse the internal draw command recording. Ideally, move all Gfx pass rendering (including all `TSpine.DrawLayer` calls) towards the end of the frame, separate from any other Neslib.Sokol.Spine calls.

  The`TSpineLayerTransform` record defines the layer's screen space coordinate system. For instance to map Spine coordinates to framebuffer pixels, with the origin in the screen center, you'd setup the layer transform like this:

  ```pascal
  var Width: Single := FramebufferWidth;
  var Height: Single := FramebufferHeight;
  var Transform: TSpineLayerTransform;
  Transform.Size := Vector2(Width, Height);
  Transform.Origin := Vectcor2(0.5 * Width, 0.5 * Height);
  ```

  With this pixel mapping, the Spine scene would *not* scale with window size, which often is not very useful. Instead it might make more sense to render to a fixed 'virtual' resolution, for instance 1024 * 768:

  ```pascal
  var Transform: TSpineLayerTransform;
  Transform.Size := Vector2(1024, 768);
  Transform.Origin := Vectcor2(512, 384);
  ```

  How to configure a virtual resolution with a fixed aspect ratio is left as an exercise to the reader ;)

- That's it for basic Spine setup and rendering. Any existing objects will automatically be cleaned up when calling `TSpine.Shutdown`. This should be called before shutting down `TGfx`, but this is not required:

  ```pascal
  TSpine.Shutdown;
  TGfx.Shutdown;
  ```

- You can explicitly destroy the base object types if you don't need them any longer. This will cause the underlying spine-c objects to be freed and the memory to be returned to the operating system:

  ```pascal
  procedure TSpineInstance.Free;
  procedure TSpineSkinset.Free;
  procedure TSpineSkeleton.Free;
  procedure TSpineAtlas.Free;
  ```

  You can destroy these objects in any order without causing memory corruption issues. Instead any dependent object handles will simply become invalid (e.g. if you destroy an atlas object, all skeletons and instances created from this atlas will 'technically' still exist, but their handles will resolve to 'invalid' and all Neslib.Sokol.Spine calls involving these handles will silently fail).

  For instance:

  ```pascal
  { Create an atlas, skeleton and instance }
  var Atlas := TSpineAtlas.Create(...);
  Assert(Atlas.Valid);
  
  var SkeletonDesc := TSpineSkeletonDesc.Create;
  SkeletonDesc.Atlas := Atlas;
  SkeletonDesc...
  var Skeleton := TSpineSkeleton.Create(SkeletonDesc);
  Assert(Skeleton.Valid);
  
  var InstanceDesc := TSpineInstanceDesc.Create;
  InstanceDesc.Skeleton := Skeleton;
  var Instance := TSpineInstance.Create;
  Assert(Instance.Valid);
  
  { Destroy the atlas object }
  Atlas.Free;
  
  { The skeleton and instance handle should now be invalid, 
    but otherwise, nothing bad will happen: }
  if (not Skeleton.Valid) then...
  if (not Instance.Valid) then...
  ```

## Rendering with contexts
At first glance, render contexts may look like more heavy-weight render layers, but they serve a different purpose: they are useful if Spine rendering needs to happen in different Neslib.Sokol.Gfx render passes with different pixel formats and MSAA sample counts.

All Spine rendering happens within a context, even you don't call any of the context API functions. In this case, an internal 'default context' will be used.

Each context has its own internal vertex-, index- and command buffer and all context state is completely independent from any other contexts.

To create a new context object, call:

```pascal
var Desc := TSpineContextDesc.Create;
Desc.MaxVertices := ...;
Desc.MaxCommands := ...;
Desc.ColorFormat := TPixelFormat....;
Desc.DepthFormat := TPixelFormat....;
Desc.SampleCount := ...;
Desc.ColorWriteMask := TColorMask....;
var Context := TSpineContext.Create(Desc);
```

The `ColorFormat`, `DepthFormat` and `SampleCount` items must be compatible with the Neslib.Sokol.Gfx render pass you're going to render into.

If you omit the `ColorFormat`, `DepthFormat` and `SampleCount` designators, the new context will be compatible with the Gfx default pass (which is most likely not what you want, unless your offscreen render passes exactly match the default pass attributes).

Once a context has been created, it can be made active with:

```pascal
TSpine.Context := Context;
```

To set the default context again:

```pascal
TSpine.Context := TSpineContext.Default;
```

...and to get the currently active context:

```pascal
var CurContext := TSpine.Context;
```

The currently active context only matter for two functions:

- `TSpineInstance.Draw(const ALayer: Integer)`
- `TSpine.DrawLayer(const ALayer: Integer; ...)`

Alternatively you can bypass the currently set context with these alternative functions:

- `TSpineInstance.Draw(const AContext: TSpineContext; const ALayer: Integer)`, which is equivalent to:
- `TSpineContext.DrawInstance(const AInstance: TSpineInstance; const ALayer: Integer)`
- `TSpine.DrawLayer(const AContext: TSpineContext; const ALayer: Integer; ...)`, which is equivalent to:
- `TSpineContext.DrawLayer(const ALayer: Integer; ...)`

These explicitly take a context argument, completely ignore and don't change the active context.

You can query some information about a context using the `Info` property:

```pascal
var Info := Context.Info;
```

This returns the current number of recorded vertices, indices and draw commands.

## Resource states
Similar to Neslib.Sokol.Gfx, you can query the current 'resource state' of Spine objects:

- `property TSpineAtlas.ResourceState: TSpineResourceState;`
- `property TSpineSkeleton.ResourceState: TSpineResourceState;`
- `property TSpineInstance.ResourceState: TSpineResourceState;`
- `property TSpineSkinset.ResourceState: TSpineResourceState;`
- `property TSpineContext.ResourceState: TSpineResourceState;`

This returns one of

- `TSpineResourceState.Valid`: the object is valid and ready to use
- `TSpineResourceState.Failed`: the object creation has failed
- `TSpineResourceState.Invalid`: the object or one of its dependencies is invalid, it either no longer exists, or the handle hasn't been initialized with a call to one of the object creation functions

## Misc helpers
There's a couple of helpers functions which don't fit into a big enough category of their own:

You can ask a skeleton for the atlas it has been created from:

```pascal
var Atlas := Skeleton.Atlas;
```

...and likewise, ask an instance for the skeleton it has been created from:

```pascal
var Skeleton := Instance.Skeleton;
```

...and finally you can convert a layer transform record into a 4x4 projection matrix that's  compatible with Neslib.Sokol.GL:

```pascal
var Transform: TSpineLayerTransform;
Transform.Size := ...;
Transform.Origin := ...;
var Proj := Transform.ToMatrix;
sglMatrixModeProjection;
sglLoadMatrix(Proj);
```

## Animations
Animations have their own handle type `TSpineAnim`. A valid `TSpineAnim` handle is either obtained by looking up an animation by name from a skeleton:

```pascal
var Anim := Skeleton.AnimByName('walk');
```

...or by index:

```pascal
var Anim := Skeleton.Anims[0];
```

The returned anim handle will be invalid if an animation of that name doesn't exist, or the provided index is out-of-range:

```pascal
if (not Anim.Valid) then
  // animation handle is not valid
```

An animation handle will also become invalid when the skeleton object it was created from is destroyed, or otherwise becomes invalid.

You can iterate over all animations in a skeleton:

```pascal
for var I := 0 to Skeleton.AnimCount - 1 do
begin
  var Anim := Skeleton.Anims[I];
  ...
end;
```

Since `TSpineAnim` is a 'fat handle' (it houses a skeleton handle and an index), there's an equality operator which checks if two anim handles are equal:

```pascal
if (Anim1 = Anim2) then
  ...
```

To query information about an animation:

```pascal
var Info := Anim.Info;
if (Info.Valid) then
begin
  Log('Index: %d, Duration: %f, Name: %s',
    [Info.Index, Info.Duration, Info.Name.ToString]);
end;    
```

Scheduling and mixing animations is controlled through the following functions:

```pascal
procedure TSpineInstance.ClearAnimationTracks; 

procedure TSpineInstance.ClearAnimationTrack(const ATrackIndex: Integer); 

procedure TSpineInstance.SetAnimation(const AAnim: TSpineAnim; const ATrackIndex: Integer = 0; const ALoop: Boolean = False); 

procedure TSpineInstance.AddAnimation(const AAnim: TSpineAnim; const ATrackIndex: Integer = 0; const ALoop: Boolean = False; const ADelay: Single = 0);

procedure TSpineInstance.SetEmptyAnimation(const ATrackIndex: Integer; const AMixDuration: Single);

procedure TSpineInstance.AddEmptyAnimation(const ATrackIndex: Integer; const AMixDuration: Single; const ADelay: Single = 0);
```

Please refer to the [spine-c documentation](http://en.esotericsoftware.com/spine-c#Applying-animations) to get an idea what these functions do.

## Events

For a general idea of Spine events, see [here](http://esotericsoftware.com/spine-events)

After calling `TSpineInstance.Update` to advance the currently configured animations,
you can poll for triggered events like this:

```pascal
for var I := 0 to Instance.TriggeredEventCount - 1 do
begin
  var Info := Instance.TriggeredEvents[I];
  if (Info.Valid) then ...
end;
```

The returned `TSpineTriggeredEventInfo` record gives you the current runtime properties of the event (in case the event has keyed properties). For the actual list of event
properties please see the actual `TSpineTriggeredEventInfo` record declaration.

It's also possible to inspect the static event definition on a skeleton. This works the same as iterating through animations. You can lookup an event by name, get the number of events, lookup an event by its index, and get detailed information about an event:

```pascal
property TSpineSkeleton.EventCount: Integer;
property TSpineSkeleton.Events[const AIndex: Integer]: TSpineEvent;
function TSpineSkeleton.EventByName(const AName: PUTFChar): TSpineEvent;
property TSpineEvent.Valid: Boolean;
property TSpineEvent.Info: TSpineEventInfo;
```

## IK targets
The Inverse Kinematics (IK) target function group allows to iterate over the IK targets that have been defined on a skeleton, find an IK target by name, get detailed information about an IK target, and most importantly, set the world space position of an IK target which updates the position of all bones influenced by the IK target:

```pascal
property TSpineSkeleton.IKTargetCount: Integer;
property TSpineSkeleton.IKTargets[const AIndex: Integer]: TSpineIKTarget;
function TSpineSkeleton.IKTargetByName(const AName: PUTFChar): TSpineIKTarget;
property TSpineIKTarget.Valid: Boolean;
property TSpineIKTarget.Info: TSpineIKTargetInfo;
procedure TSpineInstance.SetIKTargetWorldPos(const AIKTarget: TIKTarget; const AWorldPos: TSpineVec2);
```

## Bones
Skeleton bones are wrapped with an `TSpineBone` handle which can be created from a skeleton handle, and either a bone name:

```pascal
var Bone := Skeleton.BoneByName('root');
Assert(Bone.Valid);
```

...or a bone index:

```pascal
var Bone := Skeleton.Bones[0];
Assert(Bone.Valid);
```

...to iterate over all bones of a skeleton and query information about each bone:

```pascal
for var I := 0 to Skeleton.BoneCount - 1 do
begin
  var Bone := Skeleton.Bones[I];
  var Info := Bone.Info;
  if (Info.Valid) then ...
end;
```

The `TSpineBoneInfo` record provides the shared, static bone state in the skeleton (like the name, a parent bone handle, bone length, pose transform and a color attribute), but doesn't contain any dynamic information of per-instance bones.

To manipulate the per-instance bone attributes:

```pascal
property TSpineInstance.BoneTransform[const ABone: TSpineBone]: TSpineBoneTransform;
property TSpineInstance.BonePosition[const ABone: TSpineBone]: TSpineVec2;
property TSpineInstance.BoneRotation[const ABone: TSpineBone]: Single;
property TSpineInstance.BoneScale[const ABone: TSpineBone]: TSpineVec2;
property TSpineInstance.BoneShear[const ABone: TSpineBone]: TSpineVec2;
```

These properties all work in the local bone coordinate system (relative to a bone's parent bone).

To transform positions between bone-local and global space use the following helper functions:

```pascal
function TSpineInstance.BoneLocalToWorld(const ABone: TSpineBone; const ALocalPos: TSpineVec2): TSpineVec2;

function TSpineInstance.BoneWorldToLocal(const ABone: TSpineBone; const AWorldPos: TSpineVec2): TSpineVec2;
```

...and as a convenience, there's a helper property which obtains the bone position in global space directly:

```pascal
property TSpineInstance.BoneWorldPosition[const ABone: TSpineBone]: TSpineVec2;
```

## Skins and skinsets
Skins are named pieces of geometry which can be turned on and off. What makes Spine skins a bit confusing is that they are hierarchical. A skin can itself be a collection of other skins. Setting the 'root skin' will also make all 'child skins' visible. In Neslib.Sokol.Spine, collections of skins are managed through dedicated 'skin set' objects. Under the hood they create a 'root skin' where the skins of the skin set are attached to, but from the outside it just looks like a 'flat' collection of skins without the tricky hierarchical management.

Like other 'subobjects', skin handles can be obtained by the skin name from a skeleton handle:

```pascal
var Skin: TSpineSkin := Skeleton.SkinByName('jacket');
Assert(Skin.Valid);
```

...or by a skin index:

```pascal
var Skin := Skeleton.Skins[0];
Assert(Skin.Valid);
```

...you can iterate over all skins of a skeleton and query some information about the skin:

```pascal
for var I := 0 to Skeleton.SkinCount - 1 do
begin
  var Skin := Skeleton.Skins[I];
  var Info: TSpineSkinInfo := Skin.Info;
  if (Info.Valid) then ...
end;
```

Currently, the only useful query item is the skin name though.

To make a skin visible on an instance, just call:

```pascal
Instance.SetSkin(Skin);
```

...this will first deactivate the previous skin before setting a new skin.

A more powerful way to configure the skin visibility is through 'skin sets'. Skin sets are simply flat collections of skins which should be made visible at once. A new skin set is created like this:

```pascal
var Desc := TSpineSkinsetDesc.Create;
Desc.Skeleton := Skeleton;
Desc.Skins[0] := Skeleton.SkinByName('blue-jacket');
Desc.Skins[1] := Skeleton.SkinByName('green-pants');
Desc.Skins[2] := Skeleton.SkinByName('blonde-hair');
var Skinset := TSpineSkinset.Create(Desc);
Assert(Skinset.Valid);
```

...then simply set the skinset on an instance to reconfigure the appearance of the instance:

```pascal
Instance.SetSkinset(Skinset);
```

The functions `TSpineInstance.SetSkinset` and `TSpineInstance.SetSkin` will cancel each other. Calling `TSpineInstance.SetSkinset` deactivates the effect of `TSpineInstance.SetSkin` and vice versa.

## Memory Allocation Override

You can use Delphi's memory manager instead of the system memory manager by setting `TSpineDesc.UseDelphiMemoryManager` to `True`.  This only affects memory allocation calls done by Neslib.Sokol.Spine itself though, not any allocations in OS libraries.

## Error reporting and logging

To get any logging information at all you need to provide a logging callback in the `TSpineDesc` record. The easiest way is using the DefaultLogger provided by Sokol:

```pascal
  var Desc := TSpineDesc.Create;
  Desc.Logger := Desc.DefaultLogger;
  ...
  TSpine.Setup(Desc);
```

The provided logging function must be reentrant (e.g. be callable from different threads).

If you don't want to provide your own custom logger it is highly recommended to use the standard logger, otherwise you won't see any warnings or errors.
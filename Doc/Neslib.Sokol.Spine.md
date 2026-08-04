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
  Desc.MaxCommand := 128;	   // Default 16384
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

    // iterate over atlas textures and initialize sokol-gfx image objects
    // with existing handles
    const int num = sspine_num_images(atlas);
    for (int i = 0; i < num; i++) {
        const sspine_image img = sspine_image_by_index(atlas, i);
        const sspine_image_info img_info = sspine_get_image_info(img);
        assert(img_info.valid);
        assert(!img_info.filename.truncated);

        // the filename is now in img_info.filename.cstr, 'somehow'
        // load and decode the image data into memory, and then
        // initialize the sokol-gfx image, view and sampler from the existing
        // handles in img_info.sgimage:
        sg_init_image(img_info.sgimage, &(sg_image_desc){
            .width = ...,
            .height = ...,
            .pixel_format = ...,
            .data.subimage[0][0] = {
                .ptr = ...,     // pointer to decoded image pixel data
                .size = ...,    // size of decoded image pixel data in bytes
            }
        });
        sg_init_view(img_info.sgview, &(sg_view_desc){
            .texture = { .image = img_info.sgimage },
        });
        sg_init_sampler(img_info.sgsampler, &(sg_image_desc){
            .min_filter = img_info.min_filter,
            .mag_filter = img_info.mag_filter,
            .mipmap_filter = img_info.mipmap_filter,
            .wrap_u = img_info.wrap_u,
            .wrap_v = img_info.wrap_v,
        });
    }

  If you load the image data asynchronously, you can still simply start rendering
  before the image data is loaded. This works because sokol-gfx will silently drop
  any rendering operations that involve 'incomplete' objects.

- Once an atlas object has been created (independently from loading any image data),
  an sspine_skeleton object is needed next. This requires a valid atlas object
  handle as input, and a pointer to the Spine skeleton file data loaded into memory.

  Spine skeleton files come in two flavours: binary or json, for binary data,
  a ptr/size pair must be provided:

    sspine_skeleton skeleton = sspine_make_skeleton(&(sspine_skeleton_desc){
        .atlas = atlas,     // atlas must be a valid sspine_atlas handle
        .binary_data = {
            .ptr = ...,     // pointer to binary skeleton data in memory
            .size = ...,    // size of binary skeleton data in bytes
        }
    });
    assert(sspine_skeleton_valid(skeleton));

  For JSON skeleton file data, the data must be provided as a zero-terminated C string:

    sspine_skeleton skeleton = sspine_make_skeleton(&(sspine_skeleton_desc){
        .atlas = atlas,
        .json_data = ...,   // JSON skeleton data as zero-terminated(!) C-string
    });

  Like with all sokol-spine objects, if you load the skeleton data asynchronously
  and only then create a skeleton object, you can already start rendering before
  the data is loaded and the Spine objects have been created. Any operations
  involving 'incomplete' handles will be dropped.

- You can pre-scale the Spine scene size, and you can provide a default cross-fade
  duration for animation mixing:

    sspine_skeleton skeleton = sspine_make_skeleton(&(sspine_skeleton_desc){
        .atlas = atlas,
        .binary_data = { ... },
        .prescale = 0.5f,           // scale to half-size
        .anim_default_mix = 0.2f,   // default anim mixing cross-fade duration 0.2 seconds
    });

- Once the skeleton object has been created, it's finally time to create one or many instance objects.
  If you want to independently render and animate the 'same' Spine object many times in a frame,
  you should only create one sspine_skeleton object, and then as many sspine_instance object
  as needed from the shared skeleton object:

    sspine_instance instance = sspine_make_instance(&(sspine_instance_desc){
        .skeleton = skeleton,   // must be a valid skeleton handle
    });
    assert(sspine_instance_valid(instance));

  After creation, the sspine_instance will have a 'default skin' set as its appearance.

- To set the position of an instance:

    sspine_set_position(inst, (sspine_vec2){ .x=..., .y=... });

  Sokol-spine doesn't define a specific unit (like pixels or meters), instead the
  rendering coordinate system is defined later at 'render time'.

- To schedule an initial looping animation by its name:

    // first lookup up the animation by name on the skeleton:
    sspine_anim anim = sspine_anim_by_name(skeleton, "walk");
    assert(sspine_anim_valid(anim));

    // then schedule the animation on the instance, on mixer track 0, as looping:
    sspine_set_animation(instance, anim, 0, true);

  Scheduling and mixing animations will be explained in more detail further down.

- To advance and mix instance animations:

    sspine_update_instance(instance, delta_time_in_seconds);

  Usually you'd call this each frame for each active instance with the
  frame duration in seconds.

- Now it's finally time to 'render' the instance at its current position and
  animation state:

    sspine_draw_instance_in_layer(instance, 0);

  Instances are generally rendered into numbered virtual 'render layers' (in this
  case, layer 0). Layers are useful for interleaving sokol-spine rendering
  with other rendering commands (like background and foreground tile maps,
  sprites or text).

- It's important to note that no actual sokol-gfx rendering happens in
  sspine_draw_instance_in_layer(), instead only vertices, indices and
  draw commands are recorded into internal memory buffers.

- The only sokol-spine function which *must* (and should) be called inside
  a sokol-gfx rendering pass is sspine_draw_layer().

  This renders all draw commands that have been recorded previously in a
  specific layer via sspine_draw_instance_in_layer().

    const sspine_layer_transform tform = { ... };

    sg_begin_pass(...);
    sspine_draw_layer(0, tform);
    sg_end_pass();
    sg_commit();

  IMPORTANT: DO *NOT* MIX any calls to sspine_draw_instance_in_layer()
  with sspine_draw_layer(), as this will confuse the internal draw command
  recording. Ideally, move all sokol-gfx pass rendering (including all
  sspine_draw_layer() calls) towards the end of the frame, separate from
  any other sokol-spine calls.

  The sspine_layer_transform struct defines the layer's screen space coordinate
  system. For instance to map Spine coordinates to framebuffer pixels, with the
  origin in the screen center, you'd setup the layer transform like this:

    const float width = sapp_widthf();
    const float height = sapp_heightf();
    const sspine_layer_transform tform = {
        .size = { .x = width, .y = height },
        .origin = { .x = width * 0.5f, .y = height * 0.5f },
    };

  With this pixel mapping, the Spine scene would *not* scale with window size,
  which often is not very useful. Instead it might make more sense to render
  to a fixed 'virtual' resolution, for instance 1024 * 768:

    const sspine_layer_transform tform = {
        .size = { .x = 1024.0f, .y = 768.0f },
        .origin = { .x = 512.0f, .y = 384.0f },
    };

  How to configure a virtual resolution with a fixed aspect ratio is
  left as an exercise to the reader ;)

- That's it for basic sokol-spine setup and rendering. Any existing objects
  will automatically be cleaned up when calling sspine_shutdown(), this
  should be called before shutting down sokol-gfx, but this is not required:

    sspine_shutdown();
    sg_shutdown();

- You can explicitly destroy the base object types if you don't need them
  any longer. This will cause the underlying spine-c objects to be
  freed and the memory to be returned to the operating system:

    sspine_destroy_instance(instance);
    sspine_destroy_skinset(skinset);
    sspine_destroy_skeleton(skeleton);
    sspine_destroy_atlas(atlas);

  You can destroy these objects in any order without causing memory corruption
  issues. Instead any dependent object handles will simply become invalid (e.g.
  if you destroy an atlas object, all skeletons and instances created from
  this atlas will 'technically' still exist, but their handles will resolve to
  'invalid' and all sokol-spine calls involving these handles will silently fail).

  For instance:

    // create an atlas, skeleton and instance
    sspine_atlas atlas = sspine_make_atlas(&(sspine_atlas_desc){ ... });
    assert(sspine_atlas_valid(atlas));

    sspine_skeleton skeleton = sspine_make_skeleton(&(sspine_skeleton_desc){
        .atlas = atlas,
        ...
    });
    assert(sspine_skeleton_valid(skeleton));

    sspine_instance instance = sspine_make_instance(&(sspine_instance_desc){
        .skeleton = skeleton,
    });
    assert(sspine_instance_valid(instance));

    // destroy the atlas object:
    sspine_destroy_atlas(atlas);

    // the skeleton and instance handle should now be invalid, but
    // otherwise, nothing bad will happen:
    if (!sspine_skeleton_valid(skeleton)) {
        ...
    }
    if (!sspine_instance_valid(instance)) {
        ...
    }

RENDERER DETAILS
================
Any rendering related work happens in the functions sspine_draw_instance_in_layer() and
sspine_draw_layer().

sspine_draw_instance_in_layer() will result in vertices, indices and internal
draw commands which will be recorded into internal memory buffers (e.g.
no sokol-gfx functions will be called here).

If possible, batching will be performed by merging a new draw command with
the previously recorded draw command. For two draw commands to be merged,
the following conditions must be true:

    - rendering needs to go into the same layer
    - the same atlas texture must be used
    - the blend mode must be compatible (the Spine blending modes
      'normal' and 'additive' can be merged, but not 'multiply')
    - the same premultiplied alpha mode must be used

To make the most out of batching:

    - use Spine objects which only have a single atlas texture
      and blend mode across all slots
    - group sspine_draw_instance_in_layer() calls by layer

After all instances have been 'rendered' (or rather: recorded) into layers,
the actually rendering happens inside a sokol-gfx pass by calling the
function sspine_draw_layer() for each layer in 'z order' (e.g. the layer
index doesn't matter for z-ordering, only the order how sspine_draw_layer() is
called).

Only the first call to sspine_draw_layer() in a frame will copy the recorded
vertices and indices into sokol-gfx buffers.

Each call to sspine_draw_layer() will iterate over all recorded (and
hopefully well-batched) draw commands, skip any draw commands with a
non-matching layer index, and draw only those with a matching layer by
calling:

    - if the pipeline object has changed:
        - sg_apply_pipeline()
        - sg_apply_uniforms() for the vertex stage
    - if the atlas texture has changed:
        - sg_apply_bindings()
    - if the premultiplied-alpha mode has changed:
        - sg_apply_uniforms() for the fragment stage
    - and finally sg_draw()

The main purpose of render layers is to mix Spine rendering with other
render operations. In the not too distant future, the same render layer idea
will also be implemented at least for sokol-gl and sokol-debugtext.

FIXME: does this section need more details about layer transforms?

RENDERING WITH CONTEXTS
=======================
At first glance, render contexts may look like more heavy-weight
render layers, but they serve a different purpose: they are useful
if Spine rendering needs to happen in different sokol-gfx render passes
with different pixel formats and MSAA sample counts.

All Spine rendering happens within a context, even you don't call any
of the context API functions, in this case, an internal 'default context'
will be used.

Each context has its own internal vertex-, index- and command buffer and
all context state is completely independent from any other contexts.

To create a new context object, call:

    sspine_context ctx = sspine_make_context(&(sspine_context_desc){
        .max_vertices = ...,
        .max_commands = ...,
        .color_format = SG_PIXELFORMAT_...,
        .depth_format = SG_PIXELFORMAT_...,
        .sample_count = ...,
        .color_write_mask = SG_COLORMASK_...,
    });

The color_format, depth_format and sample_count items must be compatible
with the sokol-gfx render pass you're going to render into.

If you omit the color_format, depth_format and sample_count designators,
the new context will be compatible with the sokol-gfx default pass
(which is most likely not what you want, unless your offscreen render passes
exactly match the default pass attributes).

Once a context has been created, it can be made active with:

    sspine_set_context(ctx);

To set the default context again:

    sspine_set_contxt(sspine_default_context());

...and to get the currently active context:

    sspine_context cur_ctx = sspine_get_context();

The currently active context only matter for two functions:

    - sspine_draw_instance_in_layer()
    - sspine_draw_layer()

Alternatively you can bypass the currently set context with these
alternative functions:

    - sspine_context_draw_layer_in_instance(ctx, ...)
    - sspine_context_draw_layer(ctx, ...)

These explicitly take a context argument, completely ignore
and don't change the active context.

You can query some information about a context with the function:

    sspine_context_info info = ssgpine_get_context_info(ctx);

This returns the current number of recorded vertices, indices
and draw commands.

RESOURCE STATES:
================
Similar to sokol-gfx, you can query the current 'resource state' of Spine
objects:

    sspine_resource_state sspine_get_atlas_resource_state(sspine_atlas atlas);
    sspine_resource_state sspine_get_skeleton_resource_state(sspine_atlas atlas);
    sspine_resource_state sspine_get_instance_resource_state(sspine_atlas atlas);
    sspine_resource_state sspine_get_skinset_resource_state(sspine_atlas atlas);
    sspine_resource_state sspine_get_context_resource_state(sspine_atlas atlas);

This returns one of

    - SSPINE_RESOURCE_VALID: the object is valid and ready to use
    - SSPINE_RESOURCE_FAILED: the object creation has failed
    - SSPINE_RESOURCE_INVALID: the object or one of its dependencies is
      invalid, it either no longer exists, or the handle hasn't been
      initialized with a call to one of the object creation functions

MISC HELPER FUNCTIONS:
======================
There's a couple of helper functions which don't fit into a big enough category
of their own:

You can ask a skeleton for the atlas it has been created from:

    sspine_atlas atlas = sspine_get_skeleton_atlas(skeleton);

...and likewise, ask an instance for the skeleton it has been created from:

    sspine_skeleton skeleton = sspine_get_instance_skeleton(instance);

...and finally you can convert a layer transform struct into a 4x4 projection
matrix that's memory-layout compatible with sokol-gl:

    const sspine_layer_transform tform = { ... };
    const sspine_mat4 proj = sspine_layer_transform_to_mat4(&tform);
    sgl_matrix_mode_projection();
    sgl_load_matrix(proj.m);

ANIMATIONS
==========
Animations have their own handle type sspine_anim. A valid sspine_anim
handle is either obtained by looking up an animation by name from a skeleton:

    sspine_anim anim = sspine_anim_by_name(skeleton, "walk");

...or by index:

    sspine_anim anim = sspine_anim_by_index(skeleton, 0);

The returned anim handle will be invalid if an animation of that name doesn't
exist, or the provided index is out-of-range:

    if (!sspine_anim_is_valid(anim)) {
        // animation handle is not valid
     }

An animation handle will also become invalid when the skeleton object it was
created is destroyed, or otherwise becomes invalid.

You can iterate over all animations in a skeleton:

    const int num_anims = sspine_num_anims(skeleton);
    for (int anim_index = 0; anim_index < num_anims; anim_index++) {
        sspine_anim anim = sspine_anim_by_index(skeleton, anim_index);
        ...
    }

Since sspine_anim is a 'fat handle' (it houses a skeleton handle and an index),
there's a helper function which checks if two anim handles are equal:

    if (sspine_anim_equal(anim0, anim1)) {
        ...
    }

To query information about an animation:

    const sspine_anim_info info = sspine_get_anim_info(anim);
    if (info.valid) {
        printf("index: %d, duration: %f, name: %s", info.index, info.duration, info.name.cstr);
    }

Scheduling and mixing animations is controlled through the following functions:

    void sspine_clear_animation_tracks(sspine_instance instance);
    void sspine_clear_animation_track(sspine_instance instance, int track_index);
    void sspine_set_animation(sspine_instance instance, sspine_anim anim, int track_index, bool loop);
    void sspine_add_animation(sspine_instance instance, sspine_anim anim, int track_index, bool loop, float delay);
    void sspine_set_empty_animation(sspine_instance instance, int track_index, float mix_duration);
    void sspine_add_empty_animation(sspine_instance instance, int track_index, float mix_duration, float delay);

Please refer to the spine-c documentation to get an idea what these functions do:

    http://en.esotericsoftware.com/spine-c#Applying-animations

EVENTS
======
For a general idea of Spine events, see here: http://esotericsoftware.com/spine-events

After calling sspine_update_instance() to advance the currently configured animations,
you can poll for triggered events like this:

    const int num_triggered_events = sspine_num_triggered_events(instance);
    for (int i = 0; i < num_triggered_events; i++) {
        const sspine_triggered_event_info info = sspine_get_triggered_event_info(instance, i);
        if (info.valid) {
            ...
        }
    }

The returned sspine_triggered_event_info struct gives you the current runtime properties
of the event (in case the event has keyed properties). For the actual list of event
properties please see the actual sspine_triggered_event_info struct declaration.

It's also possible to inspect the static event definition on a skeleton, this works
the same as iterating through animations. You can lookup an event by name,
get the number of events, lookup an event by its index, and get detailed
information about an event:

    int sspine_num_events(sspine_skeleton skeleton);
    sspine_event sspine_event_by_name(sspine_skeleton skeleton, const char* name);
    sspine_event sspine_event_by_index(sspine_skeleton skeleton, int index);
    bool sspine_event_valid(sspine_event event);
    bool sspine_event_equal(sspine_event first, sspine_event second);
    sspine_event_info sspine_get_event_info(sspine_event event);

(FIXME: shouldn't the event info struct contains an sspine_anim handle?)

IK TARGETS
==========
The IK target function group allows to iterate over the IK targets that have been
defined on a skeleton, find an IK target by name, get detailed information about
an IK target, and most importantly, set the world space position of an IK target
which updates the position of all bones influenced by the IK target:

    int sspine_num_iktargets(sspine_skeleton skeleton);
    sspine_iktarget sspine_iktarget_by_name(sspine_skeleton skeleton, const char* name);
    sspine_iktarget sspine_iktarget_by_index(sspine_skeleton skeleton, int index);
    bool sspine_iktarget_valid(sspine_iktarget iktarget);
    bool sspine_iktarget_equal(sspine_iktarget first, sspine_iktarget second);
    sspine_iktarget_info sspine_get_iktarget_info(sspine_iktarget iktarget);
    void sspine_set_iktarget_world_pos(sspine_instance instance, sspine_iktarget iktarget, sspine_vec2 world_pos);

BONES
=====
Skeleton bones are wrapped with an sspine_bone handle which can be created from
a skeleton handle, and either a bone name:

    sspine_bone bone = sspine_bone_by_name(skeleton, "root");
    assert(sspine_bone_valid(bone));

...or a bone index:

    sspine_bone bone = sspine_bone_by_index(skeleton, 0);
    assert(sspine_bone_valid(bone));

...to iterate over all bones of a skeleton and query information about each
bone:

    const int num_bones = sspine_num_bones(skeleton);
    for (int bone_index = 0; bone_index < num_bones; bone_index++) {
        sspine_bone bone = sspine_bone_by_index(skeleton, bone_index);
        const sspine_bone_info info = sspine_get_bone_info(skeleton, bone);
        if (info.valid) {
            ...
        }
    }

The sspine_bone_info struct provides the shared, static bone state in the skeleton (like
the name, a parent bone handle, bone length, pose transform and a color attribute),
but doesn't contain any dynamic information of per-instance bones.

To manipulate the per-instance bone attributes use the following setter functions:

    void sspine_set_bone_transform(sspine_instance instance, sspine_bone bone, const sspine_bone_transform* transform);
    void sspine_set_bone_position(sspine_instance instance, sspine_bone bone, sspine_vec2 position);
    void sspine_set_bone_rotation(sspine_instance instance, sspine_bone bone, float rotation);
    void sspine_set_bone_scale(sspine_instance instance, sspine_bone bone, sspine_vec2 scale);
    void sspine_set_bone_shear(sspine_instance instance, sspine_bone bone, sspine_vec2 shear);

...and to query the per-instance bone attributes, the following getters:

    sspine_bone_transform sspine_get_bone_transform(sspine_instance instance, sspine_bone bone);
    sspine_vec2 sspine_get_bone_position(sspine_instance instance, sspine_bone bone);
    float sspine_get_bone_rotation(sspine_instance instance, sspine_bone bone);
    sspine_vec2 sspine_get_bone_scale(sspine_instance instance, sspine_bone bone);
    sspine_vec2 sspine_get_bone_shear(sspine_instance instance, sspine_bone bone);

These functions all work in the local bone coordinate system (relative to a bone's parent bone).

To transform positions between bone-local and global space use the following helper functions:

    sspine_vec2 sspine_bone_local_to_world(sspine_instance instance, sspine_bone bone, sspine_vec2 local_pos);
    sspine_vec2 sspine_bone_world_to_local(sspine_instance instance, sspine_bone bone, sspine_vec2 world_pos);

...and as a convenience, there's a helper function which obtains the bone position in global space
directly:

    sspine_vec2 sspine_get_bone_world_position(sspine_instance instance, sspine_bone bone);

SKINS AND SKINSETS
==================
Skins are named pieces of geometry which can be turned on and off, what makes Spine skins a bit
confusing is that they are hierarchical. A skin can itself be a collection of other skins. Setting
the 'root skin' will also make all 'child skins' visible. In sokol-spine collections of skins are
managed through dedicated 'skin set' objects. Under the hood they create a 'root skin' where the
skins of the skin set are attached to, but from the outside it just looks like a 'flat' collection
of skins without the tricky hierarchical management.

Like other 'subobjects', skin handles can be obtained by the skin name from a skeleton handle:

    sspine_skin skin = sspine_skin_by_name(skeleton, "jacket");
    assert(sspine_skin_valid(skin));

...or by a skin index:

    sspine_skin skin = sspine_skin_by_index(skeleton, 0);
    assert(sspine_skin_valid(skin));

...you can iterate over all skins of a skeleton and query some information about the skin:

    const int num_skins = sspine_num_skins(skeleton);
    for (int skin_index = 0; skin_index < num_skins; skin_index++) {
        sspine_skin skin = sspine_skin_by_index(skin_index);
        sspine_skin_info info = sspine_get_skin_info(skin);
        if (info.valid) {
            ...
        }
    }

Currently, the only useful query item is the skin name though.

To make a skin visible on an instance, just call:

    sspine_set_skin(instance, skin);

...this will first deactivate the previous skin before setting a new skin.

A more powerful way to configure the skin visibility is through 'skin sets'. Skin
sets are simply flat collections of skins which should be made visible at once.
A new skin set is created like this:

    sspine_skinset skinset = sspine_make_skinset(&(sspine_skinset_desc){
        .skeleton = skeleton,
        .skins = {
            sspine_skin_by_name(skeleton, "blue-jacket"),
            sspine_skin_by_name(skeleton, "green-pants"),
            sspine_skin_by_name(skeleton, "blonde-hair"),
            ...
        }
    });
    assert(sspine_skinset_valid(skinset))

...then simply set the skinset on an instance to reconfigure the appearance
of the instance:

    sspine_set_skinset(instance, skinset);

The functions sspine_set_skinset() and sspine_set_skin() will cancel each other.
Calling sspine_set_skinset() deactivates the effect of sspine_set_skin() and
vice versa.


ERROR REPORTING AND LOGGING
===========================
To get any logging information at all you need to provide a logging callback in the setup call,
the easiest way is to use sokol_log.h:

    #include "sokol_log.h"
    
    sspine_setup(&(sspine_desc){ .logger.func = slog_func });

To override logging with your own callback, first write a logging function like this:

    void my_log(const char* tag,                // e.g. 'sspine'
                uint32_t log_level,             // 0=panic, 1=error, 2=warn, 3=info
                uint32_t log_item_id,           // SSPINE_LOGITEM_*
                const char* message_or_null,    // a message string, may be nullptr in release mode
                uint32_t line_nr,               // line number in sokol_spine.h
                const char* filename_or_null,   // source filename, may be nullptr in release mode
                void* user_data)
    {
        ...
    }

...and then setup sokol-spine like this:

    sspine_setup(&(sspine_desc){
        .logger = {
            .func = my_log,
            .user_data = my_user_data,
        }
    });

The provided logging function must be reentrant (e.g. be callable from
different threads).

If you don't want to provide your own custom logger it is highly recommended to use
the standard logger in sokol_log.h instead, otherwise you won't see any warnings or
errors.


MEMORY ALLOCATION OVERRIDE
==========================
You can override the memory allocation functions at initialization time
like this:

    void* my_alloc(size_t size, void* user_data) {
        return malloc(size);
    }
    
    void my_free(void* ptr, void* user_data) {
        free(ptr);
    }
    
    ...
        sspine_setup(&(sspine_desc){
            // ...
            .allocator = {
                .alloc_fn = my_alloc,
                .free_fn = my_free,
                .user_data = ...;
            }
        });
    ...

If no overrides are provided, malloc and free will be used.

This only affects memory allocation calls done by sokol_gfx.h
itself though, not any allocations in OS libraries.




























Pixel framebuffer for CPU rendering.

This is a light-weight OOP layer on top of [sokol_framebuffer.h](https://github.com/floooh/sokol).

## Feature Overview

Provides old-school pixel framebuffers for CPU rendering in two pixel format:

  - direct RGBA8 (32 bits per pixel)
  - 8-bits per pixel indexing a 256-entry RGBA8 color palette

## Step-by-Step

### Initialize Neslib.Sokol.Framebuffer

First initialize Neslib.Sokol.Framebuffer via:

```pascal
var SetupDesc := TFramebufferSetupDesc.Create;
SetupDesc.Logger := SetupDesc.DefaultLogger;
TFramebuffer.Setup(SetupDesc);
```

If you need more than 8 framebuffers at the same time, increase the framebuffer pool:

```pascal
var SetupDesc := TFramebufferSetupDesc.Create;
SetupDesc.FramebufferPoolSize := 129;
SetupDesc.Logger := SetupDesc.DefaultLogger;
TFramebuffer.Setup(SetupDesc);
```

### Create framebuffer

Next, create one or more framebuffers. You need to provide at leastb a width and height:

```pascal
var Desc := TFramebufferDesc.Create;
Desc.Width := 320;
Desc.Height := 256;
var Framebuffer := TFramebuffer.Create(Desc);
```

By default this creates an RGBA8 framebuffer. To get the paletted format (1 byte per pixel and 256 color palette entries):

```pascal
var Desc := TFramebufferDesc.Create;
Desc.Width := 320;
Desc.Height := 256;
Desc.Format := TFramebufferFormat.Palette8;
var Framebuffer := TFramebuffer.Create(Desc);
```

You can also provide a 'prescale factor'. This allows to balance pixel crispiness against bluriness. E.g. if you want your final rendered framebuffer to look less blurry but not quite have the harsh look of nearest filtering, try a prescale factor of 2:

```pascal
var Desc := TFramebufferDesc.Create;
Desc.Width := 320;
Desc.Height := 256;
Desc.Format := TFramebufferFormat.Palette8;
Desc.Prescale := 2;
var Framebuffer := TFramebuffer.Create(Desc);
```

You can rotate the framebuffer by 90 degrees, this is mainly useful to emulate some classic arcade machines where a regular 4:3 CRT was installed in 'portrait mode':

```pascal
var Desc := TFramebufferDesc.Create;
Desc.Width := 320;
Desc.Height := 256;
Desc.Format := TFramebufferFormat.Palette8;
Desc.Prescale := 2;
Desc.Rotate90 := True;
var Framebuffer := TFramebuffer.Create(Desc);
```

You can define a sub-rectangle of the framebuffer to be rendered. For instance to only render the upper-left quadrant of a 320x256 framebuffer:

```pascal
var Desc := TFramebufferDesc.Create;
Desc.Width := 320;
Desc.Height := 256;
Desc.Format := TFramebufferFormat.Palette8;
Desc.Prescale := 2;
Desc.Rotate90 := True;
Desc.Cliprect.X := 0;
Desc.Cliprect.Y := 0;
Desc.Cliprect.Width := 160;
Desc.Cliprect.Height := 128;
var Framebuffer := TFramebuffer.Create(Desc);
```

Finally if you plan to render the framebuffer in a render pass with different properties than the default swapchain format, you'll need to provide a color- and depth-pixelformat and a sample count which matches the properties of the render pass:

```pascal
var Desc := TFramebufferDesc.Create;
Desc.Width := 320;
Desc.Height := 256;
Desc.Format := TFramebufferFormat.Palette8;
Desc.Prescale := 2;
Desc.Rotate90 := True;
Desc.RenderPass.ColorFormat := TPixelFormat....;
Desc.RenderPass.DepthFormat := TPixelFormat....;
Desc.RenderPass.SampleCount := ...;
var Framebuffer := TFramebuffer.Create(Desc);
```

### Define pixel buffer and optional color palette

The actual pixel buffer and color palette are owned by you. For a 320x256  framebuffer with 32-bits per pixel (`TFramebufferFormat.Rgba8`), use an UInt32 buffer like this:

```pascal
var Pixels: array [0..255, 0..319] of UInt32;
```

For the paletted format (1 byte per pixel and a 256 entry color palette):

```pascal
var Pixels: array [0..255, 0..319] of UInt8;
var Palette: array [0..255] of UInt32;
```

You can pass the pixel buffer to a graphics library like Skia to render 2D geometry. Or you can 'render' to the pixel buffer yourself:

### Fill pixel buffer and optional palette

Now 'render' into the pixel and palette buffers with the CPU.

An RGBA8 pixel or palette entry split into red, green, blue, alpha like this:

```
|AAAAAAAA|BBBBBBBB|GGGGGGGG|RRRRRRRR|
```

E.g. bits 24 to 31 are the alpha component, bits 16 to 23 the blue component, bits 8 to 15 to green component and bits 0 to 7 the red component. Or typically:

```pascal
var A: Byte := 255;
var R: Byte := ...;
var G: Byte := ...;
var B: Byte := ...;
var Pixel: UInt32 := (A shl 24) or (B shl 16) or (G shl 8) or R;
```

Whenever the pixel buffer or color palette content changes, call` TFramebuffer.Update` outside a Neslib.Sokol.Gfx render pass, and *only once per frame* at most:

```pascal
var UpdateDesc := TFramebufferUpdateDesc.Create;
UpdateDesc.Pixels := TRange.Create(Pixels);
UpdateDesc.Palette := TRange.Create(Palette);
Framebuffer.Update(UpdateDesc);
```

Of course for an RGBA8 framebuffer you'd only provide the pixels:

```pascal
var UpdateDesc := TFramebufferUpdateDesc.Create;
UpdateDesc.Pixels := TRange.Create(Pixels);
Framebuffer.Update(UpdateDesc);
```

But even for a paletted framebuffer you can omit the data that doesn't change. E.g. when only the palette changes but not the pixel data:

```pascal
var UpdateDesc := TFramebufferUpdateDesc.Create;
UpdateDesc.Palette := TRange.Create(Palette);
Framebuffer.Update(UpdateDesc);
```

Or vice versa when only the pixels but not the palette entries change:

```pascal
var UpdateDesc := TFramebufferUpdateDesc.Create;
UpdateDesc.Pixels := TRange.Create(Pixels);
Framebuffer.Update(UpdateDesc);
```

The `TFramebuffer.Update` method will do up to two calls to the Neslib.Sokol.Gfx method `TImage.Update`: once for the pixel data and once for the palette data (this is why the function must only be called at most once per frame), and then do an render pass into an internal color attachment texture (this is why the function must be called outside any Neslib.Sokol.Gfx pass).

Finally, to render your framebuffer to the display, call `TFramebuffer.Render` *inside* a Neslib.Sokol.Gfx render pass:

```pascal
TGfx.BeginPass(Pass);
Framebuffer.Render;
...
TGfx.EndPass;
```

This will stretch the framebuffer to the whole canvas which might distort its aspect ratio. If you want a fixed aspect ratio consider setting a viewport with the help of Neslib.Sokol.Letterbox.

For more control over the rendering process, call `TFramebuffer.Render` with a `TFramebufferRenderDesc` instead. For instance to override the default sampler with linear filtering and instead use a builtin sampler with nearest filtering:

```pascal
var RenderDesc := TFramebufferRenderDesc.Create;
RenderDesc.UseNearestFilter := True;
Framebuffer.Render(RenderDesc);
```

Note though that the prescale factor provided in `TFramebufferDesc` is a better way to tweak bluriness vs crispiness. Only use the nearest-filter override if you want a 100% pixelized look.

The main purpose of `TFramebufferRenderDesc` is to inject a more advanced shader though (like a CRT shader).

### Resizing

If any of the sizing properties of the framebuffer changes, call:

```pascal
var ResizeDesc := TFramebufferResizerDesc.Create;
ResizeDesc.Width := NewWidth;
ResizeDesc.Height := NewHeight;
ResizeDesc.Prescale := NewPrescale;
ResizeDesc.ClipRect := NewClipRect;
Framebuffer.Resize(ResizeDesc);
```

The `TFramebuffer.Resize` method function is 'lazy'; It will only destroy and recreate internal objects when actually needed (e.g. the size of image objects has changed). In that case, `True` is returned. When the function returns `False`, it was basically a cheap no-op.

### Query information

If you want to do the final rendering entirely yourself you can get handles to all the internally used resources of a framebuffer object via:

```pascal
var Info := Framebuffer.Info;
```

This returns handles to all internal image, view and sampler objects as well as image sizes and pixel formats.

To query the current 'resource state' of a framebuffer:

```pascal
var State := Framebuffer.State;
```

Tthis is mainly useful to check whether framebuffer creation via `TFramebuffer.Create` had failed.

To get a copy the the` TFramebufferDesc` record struct (patched with defaults) of a framebuffer object:

```pascal
var Desc := Framebuffer.Desc;
```

### Cleanup

To destroy a framebuffer object:

```pascal
Framebuffer.Free;
```

Calling `TFramebuffer.Shutdown` will also destroy any remaining framebuffer objects:

```pascal
TFramebuffer.Shutdown;
```

## Memory Allocation Override

You can use Delphi's memory manager instead of the system memory manager by setting `TFramebufferSetupDesc.UseDelphiMemoryManager` to `True`.  This only affects memory allocation calls done by Neslib.Sokol.Framebuffer itself though, not any allocations in OS libraries.

## Error reporting and logging

To get any logging information at all you need to provide a logging callback in the `TFramebufferSetupDesc` record. The easiest way is using the DefaultLogger provided by Sokol:

```pascal
  var Desc := TFramebufferSetupDesc.Create;
  Desc.Logger := Desc.DefaultLogger;
  ...
  TFramebuffer.Setup(Desc);
```

The provided logging function must be reentrant (e.g. be callable from different threads).

If you don't want to provide your own custom logger it is highly recommended to use the standard logger, otherwise you won't see any warnings or errors.
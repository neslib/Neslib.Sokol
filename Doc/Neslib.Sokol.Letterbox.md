# Neslib.Sokol.Letterbox

Provide fixed-aspect viewport for random-aspect framebuffer..

This is a light-weight layer on top of [sokol_letterbox.h](https://github.com/floooh/sokol).

## Feature Overview

Computes viewport parameters to render fixed-aspect content in a variable-aspect framebuffer (e.g. position a 16:9 frame in a randomly sized window) - commonly known as 'letterboxing'.

## Step-by-Step

Just call the `Letterbox` function and plug the result into `TGfx.ApplyViewport`.

Takes a framebuffer width/height as input and a TLetterboxDesc record:

```pascal
var Width := FramebufferWidth;
var Height := FramebufferHeight;
var Desc := TLetterboxDesc.Create;
Desc.ContentAspectRatio := 16 / 9;
var VP := Letterbox(Width, Height, Desc);
```

Then plug the resulting viewport parameters into `TGfx.ApplyViewport` (or a similar viewport function).

```pascal
TGfx.ApplyViewport(VP.X, VP.Y, VP.Width, VP.Height, True);
```

You can define a 'safe border' in pixels:

```pascal
var Desc := TLetterboxDesc.Create;
Desc.ContentAspectRatio := 16 / 9;
Desc.Border.Left := 10;
Desc.Border.Right := 10;
Desc.Border.Top := 10;
Desc.Border.Bottom := 10;
var VP := Letterbox(Width, Height, Desc);
```

and finally you can anchor the content so that it sticks to an edge of the framebuffer (the default behaviour is to center the content):

```pascal
var Desc := TLetterboxDesc.Create;
Desc.ContentAspectRatio := 16 / 9;
Desc.Anchor := TLetterboxAnchor.Top;
Desc.Border.Left := 10;
Desc.Border.Right := 10;
Desc.Border.Top := 10;
Desc.Border.Bottom := 10;
var VP := Letterbox(Width, Height, Desc);
```
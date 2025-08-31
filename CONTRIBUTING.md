# Contributing

This document explains how to add new emotes (static and animated) to TwitchEmotes-335 and how to register them in `Emotes.lua`.

## Adding New Emotes

You can add custom emotes by placing properly formatted `.tga` files into the `Emotes/` folder and registering them in `Emotes.lua`.

## Video example

A short video (not my video) demonstrating a static image emote: https://www.youtube.com/watch?v=y8gDFt1nOSg

### Quick edit (recommended)

If you only need to add or tweak a single emote, the easiest approach is to edit an existing emote rather than creating everything from scratch:

- Replace or copy an existing `.tga` from `Emotes/` and edit the pixel data (for example in GIMP).
- Update the corresponding Lua entries in `Emotes.lua` so the addon knows the correct path and display size. You must update both the `TwitchEmotes_defaultpack` mapping (path and display size) and `TwitchEmotes_emoticons` name/alias entry. If the emote is animated, also update `TwitchEmotes_animation_metadata`.

Size notes:
- Source `.tga` files are commonly prepared at 32x32 px.
- The display size used by the addon (the size encoded in the Lua entry) is commonly `28:28`. It can differ from the source `.tga` size, e.g., a 32x32 source can be shown as `28:28` in chat.
- The project also supports named sizes such as `LARGE` (i.e. 56x56), use the same naming conventions found elsewhere in `Emotes.lua`

### Converting images to TGA (ImageMagick examples)

Use ImageMagick `magick` / `convert`. Replace `FRAME_SIZE` with your target frame size (e.g. `32x32`) and `n` with number of frames.

For static images (PNG/JPG to TGA):

```bash
magick input.png -resize 32x32! -depth 8 -type TrueColorAlpha output.tga
```

For animated GIFs (extract frames, resize, stack vertically into a TGA):

```bash
# 1) Extract frames from GIF
mkdir -p frames
magick input.gif -coalesce frames/frame_%03d.png

# 2) (optional) Select frames to match target count
mkdir -p selected
# Example: pick every 3rd frame to reduce 72 -> 48 frames
ls frames/frame_*.png | awk 'NR % 3 != 0' | xargs -I{} cp {} selected/

# 3) Resize frames to target frame size (use the size you want, e.g. 32x32)
mogrify -resize 32x32\! selected/*.png

# 4) Stack frames vertically and export as TGA with RLE compression
magick selected/*.png -append -depth 8 -type TrueColorAlpha -compress RLE output.tga
```

If after `4)`, the `output.tga` does not render properly ingame, try copying the frames from `output.tga` and overwriting an existing animated emote.

## Registering emotes in `Emotes.lua`

There are three tables you must update:

- `TwitchEmotes_defaultpack`: maps emote text to the TGA path + size used by the addon.
- `TwitchEmotes_animation_metadata`: (animated only) contains per-image animation metadata.
- `TwitchEmotes_emoticons`: maps emote typed names (and aliases) to canonical names.

### `TwitchEmotes_defaultpack` (static and animated)

```lua
TwitchEmotes_defaultpack = {
  -- static
  ["myEmote"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\Custom\\myEmote.tga:28:28",

  -- animated (path points to the stacked-frames TGA; size is per-frame)
  ["myAnimated"] = "Interface\\AddOns\\TwitchEmotes\\Emotes\\Custom\\myAnimated.tga:28:28",
}
```

### `TwitchEmotes_animation_metadata` (animated only)

Provide metadata for the stacked-frames TGA. `imageHeight` should equal `frameHeight * nFrames`.

```lua
TwitchEmotes_animation_metadata = {
  ["Interface\\AddOns\\TwitchEmotes\\Emotes\\Custom\\myAnimated.tga"] = {
    nFrames = 48,
    frameWidth = 28,
    frameHeight = 28,
    imageWidth = 28,
    imageHeight = 28 * 48, -- 1344
    framerate = 24,
  },
}
```

### `TwitchEmotes_emoticons` (names and aliases)

```lua
TwitchEmotes_emoticons = {
  ["myEmote"] = "myEmote",
  ["aliasName"] = "myEmote",
}
```

## PR checklist

- Add the `.tga` file(s) under `Emotes/` and reference the correct path in `Emotes.lua`.
- Static emotes: add an entry in `TwitchEmotes_defaultpack`.
- Animated emotes: add an entry in `TwitchEmotes_defaultpack` and a metadata entry in `TwitchEmotes_animation_metadata`.
- Update `TwitchEmotes_emoticons` for any aliases.
- Keep code formatting consistent with existing file style.
- Check in-game: after adding files, start the WoW client and verify the emote renders correctly in chat.
- Reload the game after changing `.tga` files or `/reload` after changing `Emotes.lua`
- Include a short PR description: which emotes were added, whether animated, and any special notes.

Example PR for reference (one static + one animated): https://github.com/sogladev/TwitchEmotes-335/pull/3

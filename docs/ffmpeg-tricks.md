# ffmpeg tricks

Using ffmpeg is quite straightforward following documentation or using oneliners from the web, but I find useful having a quick cheatsheet here for some common tasks. This is not intended to be a guide.

<!-- TOC -->

- [Animations](#animations)
  - [Extract frames from video](#extract-frames-from-video)
  - [Export to GIF](#export-to-gif)
- [Video](#video)
  - [Static image and background sound](#static-image-and-background-sound)
  - [Rotate 180°](#rotate-180°)
  - [List encoders/decoders](#list-encodersdecoders)
  - [Scaling](#scaling)
  - [Trimming](#trimming)
  - [Merging](#merging)
- [Audio](#audio)
  - [Cut audio from one point to other (trim)](#cut-audio-from-one-point-to-other-trim)
  - [Extract audio from video](#extract-audio-from-video)

<!-- /TOC -->

## Animations

### Extract frames from video

```sh
ffmpeg -i input.mp4 frame-%04d.jpg
```

### Export to GIF

Just rename the output so it ends with `.gif`

## Video

### Static image with background sound

```sh
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -c:a copy -c:v libx264 -shortest out.mp4
```

### Rotate video 180°

```sh
ffmpeg -i input.mp4 -vf "hflip,vflip" output.mp4
```

### List encoders/decoders

```sh
ffmpeg -encoders
ffmpeg -decoders
```

### Scaling

The example below resizes the output to a width of 320px while keeping the original aspect ratio.

```sh
ffmpeg -i input.mp4 -vf "scale=320:-1" output.mp4
```

It is possible to use `iw` and `ih` (_initial width_, _inital height_) multiplied/divided by a scalar. [More info](https://trac.ffmpeg.org/wiki/Scaling)

### Trimming

Using timestamps:

```sh
ffmpeg -i input.mp4 -ss 00:12:35 -to 00:12:50 output.mp4
```

Using values in seconds:

```sh
ffmpeg -i input.mp4 -ss 35 -to 50 output.mp4
```

Use `-t` (instead of `-to`) to define _length_ instead of destination time:

```sh
ffmpeg -i input.mp4 -ss 35 -t 15 output.mp4
```

### Merging

To merge a series of files one after the other (and copying the audio+video stream):

```sh
ffmpeg -f concat -i list.txt -c copy output.mp4
```

Where `list.txt` is as follows:

```
file 'foo.mp4'
file 'bar.mp4'
file 'baz.mp4'
```

## Audio

### Trim

Set the `ss` value to the starting point (in seconds) and `t` to the desired length (or use `-to` to set a fixed stop position).

```sh
ffmpeg -ss 4 -t 12 -i input.mp3 -acodec copy output.mp3
```

### Extract audio from video

Tip: This may be combined with trimming parameters as well to extract a fragment.

```sh
ffmpeg -i input.mp4 -q:a 0 -map a output.mp3
```

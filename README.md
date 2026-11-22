# svgTrace

A learning project written in Zig: find the raster images (JPEG, PNG) embedded in an SVG file and turn them into vector paths.

> **Status: work in progress.** See the checklist below for what already works.

## Goal

SVG files often embed raster images as data URIs (`<image href="data:image/jpeg;base64,...">`). svgTrace aims to:

1. find those `<image>` tags,
2. decode the embedded JPEG/PNG into pixels,
3. trace the pixels into vector shapes,
4. put the resulting paths back in place, with the same position and size.

Tracing is always an approximation. It works well for logos and flat illustrations, and gives a posterized look on photographs.

## Status

- [x] Pixel buffer (`Image`)
- [x] Base64 decoding (ignores whitespace and line breaks)
- [ ] Find embedded `<image>` tags (`src/svg.zig`, in progress)
- [ ] CLI: read an SVG file given as an argument
- [ ] Decode JPEG and PNG into pixels
- [ ] Color quantization
- [ ] Contour tracing
- [ ] Curve fitting (Bézier curves)
- [ ] Write the output SVG

## Requirements

- [Zig](https://ziglang.org/download/) **0.17.1**. The standard library changes a lot between versions, so other versions may not compile.

## Build, run and test

```sh
zig build                    # build
zig build run -- input.svg   # run on an SVG file
zig test src/image.zig       # tests, one file at a time
zig test src/base64.zig
zig test src/svg.zig
zig fmt src/                 # format the code
```

## Project layout

| File | Purpose |
| --- | --- |
| `src/main.zig` | Entry point: command line arguments and reading the SVG file |
| `src/image.zig` | `Pixel` and `Image`: an RGB pixel buffer |
| `src/base64.zig` | Base64 decoding on top of `std.base64` |
| `src/svg.zig` | Finds `<image>` tags with embedded data and reads their attributes |
| `src/root.zig` | Left over from `zig init` |

## SVG support

Supported:
- `href` and `xlink:href` with a `data:<mime>;base64,` URI
- attributes written with double quotes: `x`, `y`, `width`, `height`, `transform` on the `<image>` tag

Not supported yet:
- `transform` on parent elements (`<g transform="...">`)
- `preserveAspectRatio`, `opacity`, `clip-path`, `mask`
- attributes written with single quotes, or set inside `style="..."`

## Inspiration

[VTracer](https://github.com/visioncortex/vtracer) (Rust) solves the same tracing problem and is used as a reference to compare results.

## License

MIT. See [LICENSE](LICENSE).

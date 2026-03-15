All builds and tests pass. Here's a summary of what was implemented:

## Summary

### `src/main.zig` (primary deliverable)
- **Two subcommands**: `encode` and `decode`, each taking two positional args (input_path, output_path)
- **`encode`**: Reads PPM/PAM via `image_io.readImage`, encodes via `encoder.encode`, writes QOI to disk, prints `"Encoded {w}x{h} image to {path}"`
- **`decode`**: Reads QOI via `decoder.decode`, converts `Pixel` array to raw bytes, writes PPM (3-ch) or PAM (4-ch) via `image_io.writeImage`, prints `"Decoded {w}x{h} image to {path}"`
- **Error handling**: All errors produce descriptive messages on stderr and exit code 1, matching spec examples exactly (e.g., "Invalid PPM/PAM header", "Not a QOI file", "Truncated file or unexpected end of data", etc.)
- **Zig 0.15.2 compatible**: Uses `std.posix.STDERR_FILENO`/`STDOUT_FILENO` with `std.fmt.bufPrint` instead of the removed `std.io.getStdErr().writer()` API

### `src/qoi.zig` (minimal supporting change)
- Added 3 lines to re-export `encoder`, `decoder`, and `image_io` as public sub-modules, needed because Zig 0.15's module system requires files to belong to exactly one module
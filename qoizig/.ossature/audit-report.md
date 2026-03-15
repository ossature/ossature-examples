# Audit Report: qoizig v0.0.1

**Date:** 2026-03-11T21:43:28Z
**Specs:** QOI_CODEC

## QOI_CODEC Findings

### WARNING: Requirements > Encode Command (`qoizig encode`)

**Issue:** The encode command CLI example shows two positional arguments (input and output path), but the requirement only specifies one positional argument: `input`. The output path is not documented as accepted input. It's unclear whether the output path is a second positional argument, derived from the input filename, or specified via a flag.

**Suggestion:** Add `output` (positional, optional or required) to the Accepts list for the encode command, and clarify the default behavior if omitted (e.g., replace extension with .qoi).

### WARNING: Requirements > Decode Command (`qoizig decode`)

**Issue:** Same as the encode command: the CLI example shows two positional arguments (input QOI path and output PPM/PAM path), but only `input` is documented. The output path is undocumented.

**Suggestion:** Add `output` (positional, optional or required) to the Accepts list for the decode command, and clarify the default behavior if omitted.

### INFO: Requirements > Decode Command (`qoizig decode`)

**Issue:** The decode command says it outputs PPM P6 for RGB and PAM P7 for RGBA, but doesn't specify how the format choice is made. Is it determined by the QOI header's channel count, by the output file extension, or by a flag?

**Suggestion:** Clarify that the output format is determined by the QOI header's channels field (3 -> PPM, 4 -> PAM), or by the output file extension, or document another mechanism.


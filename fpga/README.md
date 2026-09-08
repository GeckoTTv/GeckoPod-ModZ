# FPGA — Project 001 AMOLED bridge

## Target

**Lattice CrossLink-NX LIFCL-17**

The MVP should first prove the data path, not optimize every resource.

## Functional blocks

```text
ipod_bus_capture
      |
      v
raw transaction stream / FIFO
      |
      v
ipod_lcd_trace_parser -----> command/data trace
      |
      v
lcd_command_decoder -----> verified register/state model
      |
      v
framebuffer_320x240_rgb565
      |
      v
scaler_320x240_to_600x450
      |
      v
orientation / pixel-format conversion
      |
      v
mipi_dsi_tx / hardened D-PHY
      |
      v
RM690B0 AMOLED
```

## Current RTL

### `rtl/ipod_bus_capture.v`

Inputs expected from the original LCD connection:

- `D[15:0]`
- `/WR`
- `/CS`
- `RS` (command/data)
- `/RESET`

The original interface is reported as ~1.8 V logic and approximately 5.5 MHz during writes. Exact FPGA bank voltage and whether direct 1.8 V connection is legal must be checked against the chosen LIFCL-17 package/bank before schematic freeze.

The capture block deliberately does **not** assume S1D19122 register addresses. `/WR`, `/CS`, `RS`, and `/RESET` are synchronized into the internal clock domain. `D[15:0]` is sampled continuously and shadow-latched during the low phase of `/WR`, then a single-cycle transaction event is emitted on the synchronized rising edge. This gives the asynchronous payload several system-clock cycles to settle before use.

This is an MVP CDC scheme, not the final timing closure strategy. The production design should add explicit input-delay constraints and, where practical, place capture flops in or near the FPGA I/O cells.

### `rtl/ipod_lcd_trace_parser.v`

This parser keeps the most recently observed command/index and associates following data writes with it. It is intentionally controller-agnostic so real iPod traces can establish the actual command set before framebuffer behavior is hard-coded.

This replaces the earlier speculative `0x20/0x21/0x22` framebuffer decoder. Do not label the design as a full Epson S1D19122 emulator until the controller identity and command map are verified against hardware captures.

### Next RTL block

Add a small transaction FIFO/logger between capture and parser. A logic-analyzer trace from a working 5G/5.5G should then be converted into a simulation fixture so command behavior can be inferred and regression tested.

## Verified decoder goals

Once real captures establish the command set, implement only the subset exercised by the iPod firmware:

- initialization writes required for host compatibility
- display/window address registers
- GRAM write command
- sequential RGB565 pixel writes
- reset behavior
- reads only if captures prove the iPod depends on them

A logic-analyzer capture from a real 5/5.5G should become a regression-test fixture.

### Framebuffer

320×240×16 = **1,228,800 bits = 153,600 bytes**.

LIFCL-17 has enough aggregate internal memory for the MVP framebuffer. Double buffering is theoretically close to the LRAM capacity alone (307,200 bytes vs ~320 KiB LRAM), but memory organization, D-PHY pipeline requirements and tool inference matter. Start with a single framebuffer plus line buffering; add double buffering only if needed.

When linear framebuffer addressing is implemented, prefer a running pixel pointer for sequential writes rather than synthesizing `row * 320 + column` on every pixel. If Cartesian addressing is unavoidable, `row * 320` can be expressed as `(row << 8) + (row << 6)`.

### Scaling

Native landscape transformation:

- input: 320×240
- output image: 600×450
- scale: 1.875× both axes
- panel native: 450×600 portrait, therefore rotate/address appropriately

Nearest-neighbor is acceptable for first light. Bilinear or other filtering can follow after timing/resource characterization.

### MIPI-DSI

Use CrossLink-NX hardened D-PHY where possible. D-PHY capability does **not by itself guarantee a complete DSI display controller**; the HDL/IP stack must generate the required DSI packets/timing and match the RM690B0 panel mode. Confirm whether the selected panel supports command mode, video mode, lane count and target lane rate before implementation.

## First-light milestones

1. Simulate bus capture with synthetic 16-bit transactions.
2. Add a transaction FIFO/logger and verify no dropped writes.
3. Capture a recorded real-iPod initialization/write trace.
4. Infer and document the command set actually exercised by the iPod.
5. Reconstruct a 320×240 framebuffer in simulation.
6. Generate a known test pattern to the AMOLED independent of the iPod.
7. Connect the two pipelines.
8. Verify full-screen writes and partial-window updates.
9. Characterize latency, tearing and power.

## HDL language

Use **SystemVerilog or Verilog** unless a Lattice reference IP block imposes another wrapper format. Keep vendor-specific D-PHY/IP integration isolated from the generic bus decoder/framebuffer/scaler so those blocks remain simulatable and portable.

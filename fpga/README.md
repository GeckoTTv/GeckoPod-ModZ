# FPGA — Project 001 AMOLED bridge

## Target

**Lattice CrossLink-NX LIFCL-17**

The MVP should first prove the data path, not optimize every resource.

## Functional blocks

```text
ipod_bus_capture
      |
      v
lcd_command_decoder -----> register/state model
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

### `ipod_bus_capture`

Inputs expected from the original LCD connection:

- `D[15:0]`
- `/WR`
- `/RD`
- `/CS`
- `RS` (command/data)
- `/RESET`

The original interface is reported as ~1.8 V logic and approximately 5.5 MHz during writes. Exact FPGA bank voltage and whether direct 1.8 V connection is legal must be checked against the chosen LIFCL-17 package/bank before schematic freeze.

### `lcd_command_decoder`

MVP goal is not necessarily a cycle-perfect S1D19122 clone. Implement the subset of behavior exercised by the iPod firmware:

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
2. Decode a recorded real-iPod initialization/write trace.
3. Reconstruct a 320×240 framebuffer in simulation.
4. Generate a known test pattern to the AMOLED independent of the iPod.
5. Connect the two pipelines.
6. Verify full-screen writes and partial-window updates.
7. Characterize latency, tearing and power.

## HDL language

Use **SystemVerilog or Verilog** unless a Lattice reference IP block imposes another wrapper format. Keep vendor-specific D-PHY/IP integration isolated from the generic bus decoder/framebuffer/scaler so those blocks remain simulatable and portable.
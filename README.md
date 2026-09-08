# GeckoPod-ModZ

Open-source experiments, restorations, and hardware mods for retro iPods and MP3 players — flash storage, batteries, displays, USB-C, and more.

## Project 001 — iPod Video 5/5.5G AMOLED retrofit

The first project is an adapter that replaces the original 320×240 LCD in an iPod Video 5th/5.5th generation with a modern 2.4-inch 450×600 AMOLED while leaving the original iPod logic board and firmware in control.

The original display is **not LVDS**. Reverse-engineering shows a **1.8 V, 16-bit MCU-style RGB565 interface** with D0–D15 plus `/WR`, `/RD`, `/CS`, RS and RESET. Published captures put the write bus around **5.5 MHz**. Later physical reverse-engineering strongly indicates that the original LCD controller is an **Epson S1D19122** configured for its 16-bit MPU interface.

### Proposed architecture

```text
iPod 5/5.5G logic board
        |
        | 1.8 V, 16-bit RGB565 MPU bus
        v
+-------------------------+
| Lattice CrossLink-NX    |
| LIFCL-17 FPGA           |
|                         |
| LCD command emulator    |
| 320x240 RGB565 buffer   |
| scaler / rotation       |
| MIPI D-PHY transmitter  |
+------------+------------+
             |
             | MIPI-DSI
             v
+-------------------------+
| 2.4-inch AMOLED         |
| 450x600 / RM690B0       |
+-------------------------+
```

A single RGB565 framebuffer is **153,600 bytes**. The LIFCL-17 provides **2,560 Kbit (~320 KiB) LRAM** plus **432 Kbit EBR**, 17K logic cells, 24 multipliers, and hardened MIPI D-PHY hardware. This makes a single-FPGA bridge plausible without an external MCU or framebuffer RAM. The first prototype should prioritize testability; the later revision can be shrunk to the iPod display envelope.

### Target AMOLED

Current leading candidate:

- **BOE / Chance ZB024JMV-N50-6DP0 / 024JMV-N50-6DP0**
- 2.4-inch AMOLED
- 450×600, 3:4 native orientation
- RM690B0 driver
- 38.72 × 51.56 mm module outline
- 36.72 × 48.96 mm active area
- 800 nit advertised brightness
- 45-pin FPC
- MIPI / CPU / SPI interface options
- Alibaba listing/product ID: **1600903194040**

The 2.5-inch 400×721 DXQ panel originally considered is documented in `docs/display-candidates.md`, but its wide aspect ratio makes it a poorer mechanical match for the iPod's 4:3 display window.

### FPGA target

**Lattice CrossLink-NX LIFCL-17** is the initial target. QFN72 is attractive for a bench prototype; csfBGA121 is worth considering for the compact production revision if routing/I/O constraints justify it.

### MVP goals

1. Capture and decode the iPod's original LCD transactions without altering iPod firmware.
2. Emulate the command/window/GRAM behavior needed by the iPod.
3. Store a 320×240 RGB565 framebuffer in FPGA memory.
4. Scale/rotate the framebuffer for the 450×600 AMOLED.
5. Initialize and continuously drive the RM690B0 AMOLED through MIPI-DSI.
6. Fit the final bridge PCB behind/in place of the original LCD with acceptable idle and active power consumption.

## Repository layout

- `docs/` — research, source links, display candidates and engineering notes
- `fpga/` — HDL architecture and eventual Lattice Radiant project
- `hardware/` — KiCad design notes and eventual schematic/PCB

## Status

**Research / architecture stage.** No PCB or HDL in this repository should yet be considered tested hardware. Signal assignments, power rails, MIPI configuration and AMOLED initialization must be verified against primary datasheets before fabrication.

## References

See [`docs/references.md`](docs/references.md).
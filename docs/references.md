# References

These are the starting references for Project 001. Prefer primary manufacturer documentation for electrical design; community reverse-engineering is used where Apple/panel documentation is unavailable.

## Original iPod Video LCD

### Mike Harrison / Electric Stuff — iPod LCD hacking
https://www.electricstuff.co.uk/ipodlcd.html

Key reverse-engineering source for the iPod Video 5G LCD connector and host interface. Documents the 32-pin flex, 16-bit color data bus, `/WR`, RS, `/RD`, VSYNC output and measured bus behavior. The page maps D0–D15 to RGB565 and reports a roughly 5.5 MHz transfer clock during screen writes.

### The Electron Vault — iPod Video 5th Generation LCD
https://theelectronvault.substack.com/p/ipod-video-5th-generation-lcd

Physical investigation of the controller-on-glass. Die dimensions, bump shapes and glass traces strongly match the Epson S1D19122. The observed configuration includes `IF16BIT` asserted and MPU-interface configuration; VSYNC/HSYNC/DCK/ENA are not used as the host pixel interface.

### Epson S1D19122 datasheet
https://aitendo3.sakura.ne.jp/aitendo_data/product_img/lcd/tft/STM025QVT-001/STM025QVT001_S1D19122_rev0.8c.pdf

Useful controller reference. The S1D19122 includes internal VRAM organized for 320×240 pixels and supports MPU access. Treat the S1D19122 identification in the iPod as strongly supported reverse-engineering rather than official Apple documentation.

## FPGA

### Lattice CrossLink-NX product page
https://www.latticesemi.com/CrossLink-NX

### CrossLink-NX Family Data Sheet — FPGA-DS-02049
https://www.latticesemi.com/-/media/LatticeSemi/Documents/DataSheets/CrossLink/FPGA-DS-02049-2-4-CrossLink-NX-Family.ashx?document_id=52780

Initial target: **LIFCL-17**. Current Lattice documentation lists 17K logic cells, 2,560 Kbit LRAM, 432 Kbit EBR, 24 18×18 multipliers, GPLLs and hardened MIPI D-PHY resources. Candidate packages include QFN72, WLCSP72 and csfBGA121.

Also retrieve from Lattice before schematic freeze:

- CrossLink-NX Hardened D-PHY Usage Guide — FPGA-TN-02081
- CrossLink-NX Hardware Checklist — FPGA-TN-02149
- CrossLink-NX High-Speed I/O Interface — FPGA-TN-02097
- CrossLink-NX LIFCL-17 Pinout — FPGA-SC-02006
- Memory User Guide for Nexus Platform — FPGA-TN-02094

## AMOLED candidate

### 2.4-inch 450×600 AMOLED

Manufacturer/part identifiers encountered:

- **024JMV-N50-6DP0**
- **ZB024JMV-N50-6DP0**
- Driver: **RM690B0**

DXQ catalog:
https://www.dxqdisplay.com/products/

Chance Display product page:
https://chance-display.com/product/2-4-inch-450600-hd-high-contrast-high-luminance-oled-module/

Hicenda product page:
https://www.hicenda.com/product/AMOLED-display-450600.html

Alibaba listing:
https://www.alibaba.com/product-detail/2-4-inch-450-600-resolution_1600903194040.html

**Alibaba product/listing ID: `1600903194040`**

Published specifications across these sources include 450×600 resolution, 38.72×51.56 mm outline, 36.72×48.96 mm active area, RM690B0 controller, 45-pin FPC and MIPI/CPU/SPI interface capability.

> Note: the marketplace screenshot that started this search was from **Alibaba**, not AliExpress. Do not invent an AliExpress item ID. If an AliExpress listing is sourced later, record its exact item ID and seller here.

## Connector lead

A historical Crystalfontz discussion by the original LCD reverse-engineer identifies the 5G LCD connector as a DDK FF12-series **FF12-32A-R11B**:
https://forum.crystalfontz.com/threads/ipod-video-lcd-anyone-know-which-controller.4529/

Availability and exact mating geometry need verification before this is used in the BOM.

## Verification rule

Marketplace specifications are leads, not design authority. Before ordering the PCB, obtain the exact AMOLED datasheet/drawing for the purchased panel revision and verify FPC pinout, rail sequencing, D-PHY lane assignment, supported DSI mode, initialization command sequence, current requirements and mechanical dimensions.
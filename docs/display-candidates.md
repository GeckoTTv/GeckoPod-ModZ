# Display candidates

## Original iPod Video 5/5.5G target

- Resolution: 320×240
- Aspect ratio: 4:3
- Nominal diagonal: 2.5 inch
- Calculated 4:3 active area from nominal diagonal: ~50.8×38.1 mm

The exact mechanical window and LCD module outline should be measured from physical donor hardware before the production PCB/mechanical design is frozen.

## Preferred candidate — 2.4-inch 450×600 AMOLED

**Part:** ZB024JMV-N50-6DP0 / 024JMV-N50-6DP0  
**Driver:** RM690B0  
**Resolution:** 450×600  
**Outline:** 38.72×51.56 mm  
**Active area:** 36.72×48.96 mm  
**Interface:** MIPI / CPU / SPI, 45-pin FPC  
**Advertised brightness:** 800 nit

Rotated to landscape, the active area is **48.96×36.72 mm**, approximately 1.84 mm narrower and 1.38 mm shorter than the nominal 50.8×38.1 mm iPod 4:3 active area. This is close enough to justify mechanical prototyping.

The aspect ratio is exactly 4:3 after rotation, avoiding geometric distortion. Scaling 320×240 to 600×450 is 1.875× in both axes.

Alibaba product/listing ID: **1600903194040**.

## Alternate candidate — DXQ 2.5-inch 400×721 AMOLED

The original marketplace screenshot showed a DXQ listing titled approximately:

> 2.5 Inch AMOLED Display MIPI Interface 400×721 High Brightness 800nits 30 Pin for Cameras

Known from the listing/catalog:

- 2.5 inch
- 400×721
- MIPI
- 800 nit advertised brightness
- 30 pin

This panel is not preferred for the stock iPod window because 400×721 is about 1.80:1 rather than 4:3. A nominal 2.5-inch square-pixel panel at that aspect ratio would have a substantially shorter active height than the iPod display.

DXQ catalog: https://www.dxqdisplay.com/products/

## Selection criteria

A production candidate should satisfy all of the following:

1. Fits the original iPod front-window and internal depth with minimal/no case machining.
2. 4:3 or sufficiently close that the original UI is not visibly distorted.
3. Documented controller and initialization sequence.
4. Documented FPC pinout and power sequencing.
5. Interface that the LIFCL-17 can drive reliably; MIPI-DSI is preferred for the current architecture.
6. Stable supply chain and purchasable samples.
7. Acceptable active and standby power for battery operation.
8. Long-term availability or at least multiple interchangeable sources.
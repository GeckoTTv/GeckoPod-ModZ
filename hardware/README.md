# Hardware — Project 001 AMOLED bridge

## Rev A philosophy

Rev A is a **bench-development adapter**, not the final ultra-thin iPod replacement PCB. It should expose enough test points and programming access to prove the electrical interface before shrinking the design.

## Core blocks

1. **iPod LCD-side connector/interface**
   - 32-pin original LCD interface for 5/5.5G
   - historical connector lead: DDK FF12-32A-R11B; verify before BOM lock
   - D0–D15 and LCD control signals routed cleanly to FPGA

2. **Lattice CrossLink-NX LIFCL-17**
   - QFN72 preferred for Rev A if pin/bank allocation supports the required iPod bus plus D-PHY
   - csfBGA121 is a fallback/production candidate with more I/O and D-PHY resources
   - JTAG/programming header or pads
   - configuration circuitry per Lattice documentation

3. **Power**
   - derive all FPGA and AMOLED rails only after measuring available iPod rails/current capability
   - FPGA core/aux/I/O rails per Lattice hardware checklist
   - AMOLED rails per exact purchased panel datasheet
   - known panel information suggests VDDIO/VCI/ELVDD/ELVSS rails are involved; do not design converters from marketplace summaries alone
   - provide rail test points and current-measurement options on Rev A

4. **AMOLED FPC**
   - 45-pin connector matching the exact ZB024JMV-N50-6DP0 FPC
   - controlled-impedance MIPI routing
   - short D-PHY lane routing with appropriate reference plane and pair matching
   - reset/control pins exposed to FPGA as required

5. **Clocking**
   - determine whether internal oscillator/PLL is sufficient for MVP and D-PHY reference requirements
   - footprint an external oscillator on Rev A if useful for bring-up flexibility

6. **Debug**
   - test points for `/WR`, `/RD`, `/CS`, RS, RESET and selected data bits
   - FPGA JTAG
   - power-rail test points
   - optional header/pads for logic-analyzer access

## Electrical caution

Published iPod LCD reverse-engineering reports approximately **1.8 V host I/O**. Do not assume 3.3 V tolerance. Select an LIFCL-17 bank and VCCIO arrangement that natively accepts the bus if possible; otherwise use appropriately fast level translation. Verify all absolute maximums from current Lattice documentation.

## Mechanical targets for later revision

Preferred AMOLED module outline: **38.72×51.56 mm**. In landscape this becomes 51.56×38.72 mm, which is close to the original iPod display footprint/window. The final bridge should ideally occupy the unused rear area of the AMOLED/FPC rather than increase case thickness significantly.

Physical measurements from actual 5G and 5.5G donor units are required before Rev B board outline/keepouts are frozen.

## Before ordering Rev A

- obtain exact BOE/Chance AMOLED datasheet and mechanical drawing
- verify RM690B0 initialization and DSI requirements
- verify LIFCL-17 package pinout/bank voltage plan
- verify hardened D-PHY lane availability in chosen package
- verify iPod connector sourcing and footprint
- capture real iPod power-up/display transactions
- measure iPod LCD rail voltages and available current
- run ERC/DRC and review power sequencing against both manufacturer datasheets
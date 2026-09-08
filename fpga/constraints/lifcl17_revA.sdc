# ==============================================================================
# GeckoPod-ModZ: Rev-A Timing Constraints
# Target: CrossLink-NX LIFCL-17
# ==============================================================================

# Nominal 100 MHz system clock. Change this if the actual board oscillator/PLL
# frequency differs.
create_clock -name {clk_sys} -period 10.000 [get_ports clk_sys]

# The iPod LCD bus is asynchronous to clk_sys and is captured through explicit
# synchronizer/capture logic. For the initial MVP, do not ask STA to time the
# external bus directly into synchronous logic as if it were source-synchronous.
set_false_path -from [get_ports {ipod_wr_n ipod_cs_n ipod_rs ipod_reset_n ipod_db[*]}]

# NOTE:
# Once measured bus timing is available, replace overly broad asynchronous
# exceptions where practical with explicit constraints around the capture
# architecture. A false path prevents STA from checking those external paths;
# it does not make unsafe CDC logic safe.

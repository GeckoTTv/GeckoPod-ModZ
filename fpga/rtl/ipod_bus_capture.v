// ============================================================================
// GeckoPod-ModZ: iPod Video (5G/5.5G) LCD Bus Capture Front-End
// Target: Lattice CrossLink-NX LIFCL-17
//
// Purpose:
//   Capture the iPod's asynchronous 16-bit LCD write bus into clk_sys domain
//   without assuming a specific LCD controller command map.
//
// Notes:
//   * The host bus is believed to be an 8080/MPU-style 16-bit interface.
//   * /WR, /CS, RS and /RESET are synchronized into clk_sys.
//   * DB[15:0] is sampled continuously, then shadow-latched while /WR is low.
//     The emitted transaction therefore uses data/control observed near the end
//     of the write strobe, after the asynchronous bus has had time to settle.
//   * This is an MVP CDC strategy. Final hardware should add explicit timing
//     constraints and preferably place capture flops in/near the I/O cells.
//   * No S1D19122 (or other controller) register addresses are assumed here.
// ============================================================================

module ipod_bus_capture (
    input  wire        clk_sys,          // e.g. 100-150 MHz
    input  wire        rst_n,            // board/system reset, asynchronous low

    // Physical iPod LCD bus (nominally 1.8 V domain; board must ensure legality)
    input  wire [15:0] ipod_db,
    input  wire        ipod_wr_n,
    input  wire        ipod_cs_n,
    input  wire        ipod_rs,          // 0 = command/index, 1 = data
    input  wire        ipod_reset_n,

    // One-cycle transaction stream in clk_sys domain
    output reg         tx_valid,
    output reg         tx_is_data,
    output reg  [15:0] tx_word,

    // One-cycle pulse when a synchronized iPod display reset is observed
    output reg         display_reset_pulse
);

    // ------------------------------------------------------------------------
    // Synchronizers
    // ------------------------------------------------------------------------
    reg [2:0] wr_sync;
    reg [2:0] cs_sync;
    reg [2:0] rs_sync;
    reg [2:0] reset_sync;

    // Multi-bit data bus sampling pipeline. The bus is not independently
    // handshake-synchronized bit-by-bit; instead we rely on the iPod holding
    // data stable around /WR and capture late in the low phase of /WR.
    reg [15:0] db_s1;
    reg [15:0] db_s2;

    // Shadow copies continuously refreshed while synchronized /WR is low.
    reg [15:0] wr_data_shadow;
    reg        wr_rs_shadow;
    reg        wr_cs_shadow;

    wire wr_rising;
    wire reset_falling;

    assign wr_rising     = (wr_sync[2:1]    == 2'b01);
    assign reset_falling = (reset_sync[2:1] == 2'b10);

    always @(posedge clk_sys or negedge rst_n) begin
        if (!rst_n) begin
            wr_sync            <= 3'b111;
            cs_sync            <= 3'b111;
            rs_sync            <= 3'b000;
            reset_sync         <= 3'b111;
            db_s1              <= 16'h0000;
            db_s2              <= 16'h0000;
            wr_data_shadow     <= 16'h0000;
            wr_rs_shadow       <= 1'b0;
            wr_cs_shadow       <= 1'b1;
            tx_valid           <= 1'b0;
            tx_is_data         <= 1'b0;
            tx_word            <= 16'h0000;
            display_reset_pulse<= 1'b0;
        end else begin
            // Synchronize control inputs.
            wr_sync    <= {wr_sync[1:0],    ipod_wr_n};
            cs_sync    <= {cs_sync[1:0],    ipod_cs_n};
            rs_sync    <= {rs_sync[1:0],    ipod_rs};
            reset_sync <= {reset_sync[1:0], ipod_reset_n};

            // Sample the data bus through two stages.
            db_s1 <= ipod_db;
            db_s2 <= db_s1;

            tx_valid            <= 1'b0;
            display_reset_pulse <= 1'b0;

            // While /WR is asserted, keep a late/stable shadow of the payload.
            // Using the synchronized low phase gives the asynchronous DB/RS/CS
            // signals several clk_sys cycles to settle before the rising edge.
            if (!wr_sync[1]) begin
                wr_data_shadow <= db_s2;
                wr_rs_shadow   <= rs_sync[1];
                wr_cs_shadow   <= cs_sync[1];
            end

            // Emit one transaction on the synchronized 0->1 transition of /WR.
            // Only writes captured while /CS was active are forwarded.
            if (wr_rising && !wr_cs_shadow) begin
                tx_word    <= wr_data_shadow;
                tx_is_data <= wr_rs_shadow;
                tx_valid   <= 1'b1;
            end

            // Treat iPod display reset as a synchronized event, not as a second
            // asynchronous reset tree inside the functional logic.
            if (reset_falling) begin
                display_reset_pulse <= 1'b1;
            end
        end
    end

endmodule

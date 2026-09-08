// ============================================================================
// GeckoPod-ModZ: Controller-Agnostic iPod LCD Trace Parser
// Target: Lattice CrossLink-NX LIFCL-17
//
// Purpose:
//   Consume transactions from ipod_bus_capture and preserve command/data
//   ordering without assuming the LCD controller command map. This block is
//   intentionally conservative: it remembers the most recent command/index
//   and annotates subsequent data writes for logging, simulation, or FIFO
//   storage. Framebuffer semantics should only be added once real traces have
//   confirmed the command set used by the iPod firmware.
// ============================================================================

module ipod_lcd_trace_parser (
    input  wire        clk_sys,
    input  wire        rst_n,

    input  wire        display_reset_pulse,
    input  wire        tx_valid,
    input  wire        tx_is_data,
    input  wire [15:0] tx_word,

    // Most recently observed command/index word
    output reg  [15:0] current_command,
    output reg         current_command_valid,

    // Parsed event stream. One-cycle pulse for every accepted transaction.
    output reg         event_valid,
    output reg         event_is_data,
    output reg  [15:0] event_command,
    output reg  [15:0] event_word
);

    always @(posedge clk_sys or negedge rst_n) begin
        if (!rst_n) begin
            current_command       <= 16'h0000;
            current_command_valid <= 1'b0;
            event_valid           <= 1'b0;
            event_is_data         <= 1'b0;
            event_command         <= 16'h0000;
            event_word            <= 16'h0000;
        end else begin
            event_valid <= 1'b0;

            if (display_reset_pulse) begin
                current_command       <= 16'h0000;
                current_command_valid <= 1'b0;
            end

            if (tx_valid) begin
                event_valid   <= 1'b1;
                event_is_data <= tx_is_data;
                event_word    <= tx_word;

                if (!tx_is_data) begin
                    // Command/index write. Record it and emit the command as its
                    // own associated command for trace readability.
                    current_command       <= tx_word;
                    current_command_valid <= 1'b1;
                    event_command         <= tx_word;
                end else begin
                    // Data write. Associate it with the most recent command.
                    // If no command has been seen since reset, event_command is
                    // reported as zero and current_command_valid remains false.
                    event_command <= current_command_valid ? current_command
                                                           : 16'h0000;
                end
            end
        end
    end

endmodule

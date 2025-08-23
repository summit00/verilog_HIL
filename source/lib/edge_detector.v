// -----------------------------------------------------------------------------
// Module: edge_detector
// Description: Detects rising, falling, or both edges on an input signal.
//              Outputs a 1-cycle pulse for each detected edge.
// ----------------------------------------------------------------------------
// Parameters:
//   DETECT_RISE  : Enable rising edge detection (default: 1)
//   DETECT_FALL  : Enable falling edge detection (default: 0)
//
// Inputs:
//   clk        : Clock input
//   reset      : Synchronous reset (active high)
//   signal_in  : Input signal to detect edges on
//
// Outputs:
//   pulse      : One-cycle pulse on edge detection
// -----------------------------------------------------------------------------

module edge_detector #(
    parameter bit DETECT_RISE = 1,
    parameter bit DETECT_FALL = 0
)(
    input  wire clk,        // Clock input
    input  wire reset,      // Synchronous reset (active high)
    input  wire signal_in,  // Input signal to detect edges on
    output reg  pulse       // One-cycle pulse on edge detection
);

    // Register to store previous signal state
    reg prev_signal;

    // Edge detection combinatorial logic
    wire rising_edge  =  signal_in & ~prev_signal;
    wire falling_edge = ~signal_in &  prev_signal;

    always @(posedge clk) begin
        if (reset) begin
            pulse       <= 1'b0;
            prev_signal <= 1'b0;
        end else begin
            pulse       <= (DETECT_RISE && rising_edge) ||
                           (DETECT_FALL && falling_edge);
            prev_signal <= signal_in;
        end
    end

endmodule

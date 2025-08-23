
// -----------------------------------------------------------------------------
// Button Debouncer
// -----------------------------------------------------------------------------
// Parameters:
//   N      : Number of bits for the debounce counter (sets debounce time)
//
// Inputs:
//   clk    : Clock input
//   reset  : Synchronous reset (active high)
//   noisy  : Raw (noisy) button input
//
// Outputs:
//   clean  : Debounced button output
// -----------------------------------------------------------------------------

module debouncer #(
    parameter int N = 20  // Debounce counter width (adjust for debounce time)
)(
    input  wire clk,      // Clock input
    input  wire reset,    // Synchronous reset
    input  wire noisy,    // Noisy button input
    output reg  clean     // Debounced output
);

    reg [N-1:0] count = 0;
    reg         sync_noisy = 0;

    // Synchronize the noisy input to the clock domain
    always @(posedge clk) begin
        if (reset)
            sync_noisy <= 0;
        else
            sync_noisy <= noisy;
    end

    // Debounce logic
    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            clean <= 0;
        end else if (sync_noisy != clean) begin
            count <= count + 1'b1;
            if (count == {N{1'b1}})
                clean <= sync_noisy;
        end else begin
            count <= 0;
        end
    end

endmodule

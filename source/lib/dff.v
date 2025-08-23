// -----------------------------------------------------------------------------
// D Flip-Flop with synchronous reset and optional enable
// -----------------------------------------------------------------------------
// Parameters:
//   WIDTH   : Bit-width of the data (default: 1)
//   ENABLED : Enables gating with an 'enable' signal (default: 1)
//
// Inputs:
//   clk     : Clock input
//   reset   : Synchronous reset (active high)
//   d       : Data input [WIDTH-1:0]
//   enable  : Enable 
//
// Outputs:
//   q       : Data output [WIDTH-1:0]
//
// -----------------------------------------------------------------------------

module dff #(
    parameter WIDTH   = 1,
    parameter ENABLED = 1
)(
    input  wire                 clk,     // Clock input
    input  wire                 reset,   // Synchronous reset (active high)
    input  wire [WIDTH-1:0]     d,       // Data input
    output reg  [WIDTH-1:0]     q,       // Data output
    input  wire                 enable   // Enable 
);

    // -------------------------------------------------------------------------
    // Flip-Flop Logic
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset)
            q <= {WIDTH{1'b0}};
        else if (!ENABLED || enable)
            q <= d;
    end

endmodule

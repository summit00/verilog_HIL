// -----------------------------------------------------------------------------
// Parameterized Up Counter with synchronous reset
// -----------------------------------------------------------------------------
// Parameters:
//   WIDTH   :      Bit-width of the counter (default: 8)
//
// Inputs:
//   clk     : Clock input
//   reset   : Synchronous reset (active high)
//   enable  : Enable 
//
// Outputs:
//   count   : Current count value
// -----------------------------------------------------------------------------

module counter_sync #(
    parameter WIDTH        = 8  // Width of the counter
)(
    input  wire              clk,     // Clock input
    input  wire              reset,   // Reset (active high)
    input  wire              enable,  // Enable signal
    output reg  [WIDTH-1:0]  count    // Current count value
);

    always @(posedge clk) begin
        if (reset) begin
            count <= {WIDTH{1'b0}};
        end else if (enable) begin
            count <= count + 1'b1;
        end
    end

endmodule

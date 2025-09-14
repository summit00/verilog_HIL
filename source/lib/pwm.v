// -----------------------------------------------------------------------------
// Module: pwm
// Description: Pulse Width Modulation (PWM) generator using counter_sync module
// -----------------------------------------------------------------------------
// Parameters:
//   WIDTH   : Bit-width of counter (defines PWM resolution)
// -----------------------------------------------------------------------------

module pwm #(
    parameter int WIDTH = 8  // PWM resolution (e.g. 8-bit => 256 levels)
)(
    input  wire              clk,      // Clock input
    input  wire              reset,    // Synchronous reset (active high)
    input  wire [WIDTH-1:0]  duty,     // Duty cycle input (0 to 2^WIDTH - 1)
    output wire              pwm_out   // PWM output
);

    // Internal counter signal
    wire [WIDTH-1:0] count;

    // Instantiate the synchronous counter
    counter_sync #(
        .WIDTH(WIDTH)
    ) counter_inst (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),     // Always counting
        .count(count)
    );

    // Compare logic: PWM output is high when count < duty
    assign pwm_out = (count < duty);

endmodule

module blinky (
    input wire clk,
    output reg led
); 

    // Parameters
    parameter CLK_FREQ_HZ = 50000000;    // 50 MHz clock
    parameter BLINK_HZ = 1;              // 1 Hz blink rate (500ms ON, 500ms OFF)

    // Calculate number of clock cycles for 0.5s
    localparam integer COUNT_MAX = CLK_FREQ_HZ / (2 * BLINK_HZ);

    // Counter
    reg [25:0] counter = 0;

    always @(posedge clk) begin
        if (counter >= COUNT_MAX - 1) begin
            counter <= 0;
            led <= ~led;
        end else begin
            counter <= counter + 1;
        end
    end

endmodule

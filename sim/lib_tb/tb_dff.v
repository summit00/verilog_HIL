`timescale 1ns / 1ps
`include "tb_dump.vh"
`include "tb_check.vh"

module tb_dff;

    // Clock and control signals
    reg clk = 0;
    always #5 clk = ~clk; // 100 MHz clock

    // DUT signals
    reg reset;
    reg enable;
    reg [0:0] d1;
    wire [0:0] q1;

    reg [2:0] d3;
    wire [2:0] q3;

    // Instantiate WIDTH=1 DFF with enable
    dff #(.WIDTH(1), .ENABLED(1)) dut1 (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .d(d1),
        .q(q1)
    );

    // Instantiate WIDTH=3 DFF with enable
    dff #(.WIDTH(3), .ENABLED(1)) dut2 (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .d(d3),
        .q(q3)
    );

    // VCD dump
    `INIT_VCD("build/tb_dff.vcd", tb_dff)

    initial begin
        $display("Running dff testbench...");

        // Initial values
        reset = 1;
        enable = 0;
        d1 = 1'bx;
        d3 = 3'bxxx;
        @(posedge clk);

        // Release reset
        reset = 0;
        enable = 1;
        d1 = 1;
        d3 = 3'b101;
        #1; @(posedge clk);
        `CHECK_EQ(q1, 1, "q1 should follow d1=1")
        `CHECK_EQ(q3, 3'b101, "q3 should follow d3=101")

        // Change values again
        d1 = 0;
        d3 = 3'b111;
        #1; @(posedge clk);
        `CHECK_EQ(q1, 0, "q1 should follow d1=0")
        `CHECK_EQ(q3, 3'b111, "q3 should follow d3=111")

        // Disable enable, try new inputs
        enable = 0;
        d1 = 1;
        d3 = 3'b010;
        #1; @(posedge clk);
        `CHECK_EQ(q1, 0, "q1 should hold when enable=0")
        `CHECK_EQ(q3, 3'b111, "q3 should hold when enable=0")

        // Re-enable
        enable = 1;
        #1; @(posedge clk);
        `CHECK_EQ(q1, 1, "q1 should latch new value after enable=1")
        `CHECK_EQ(q3, 3'b010, "q3 should latch new value after enable=1")

        // Test reset behavior again
        d1 = 0;
        d3 = 3'b000;
        reset = 1;
        #1; @(posedge clk);
        `CHECK_ZERO(q1, "q1 should reset to 0")
        `CHECK_ZERO(q3, "q3 should reset to 0")

        $display("dff testbench completed successfully.");
        $display("");
        $display("");
        $finish;
    end

endmodule

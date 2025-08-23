`timescale 1ns / 1ps
`include "tb_dump.vh"  // Include VCD dump macro
`include "tb_check.vh"  // Include check macro

// Testbench module for counter
module tb_counter_sync;

    parameter WIDTH = 3;

    reg clk = 0;
    reg reset = 0;
    reg enable = 0;
    wire [WIDTH-1:0] count;
    integer i;

    // Instantiate DUT
    counter_sync #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .count(count)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Dump waveform
    `INIT_VCD("build/tb_counter_sync.vcd", tb_counter_sync)

    // Test logic
    initial begin
        $display("Starting testbench");

        // Test count sequence
        reset = 1; 
        #10; 
        reset = 0;
        enable = 1;

        // Check initial count
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge clk);
            `CHECK_EQ(count, i, $sformatf("Count match at step %0d", i));
        end

        reset = 1; enable = 0;
        #12;
        reset = 0;

        enable = 1; 
        `CHECK_ZERO(count, "Count should start from 0");
        repeat (4) @(posedge clk);
        enable = 0; 
        `CHECK_EQ(count, 3, "Count should still be 4 after disabling");
        repeat (3) @(posedge clk);
        enable = 1; 
        repeat (5) @(posedge clk);

        #3; 
        reset = 1; 
        #10;
        `CHECK_ZERO(count, "Count should be 0 after reset"); 
        reset = 0;

        repeat (4) @(posedge clk);
        #1;
        `CHECK_EQ(count, 4, "Count should be 4");

        $display("Testbench complete");
        $display("");
        $display("");
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time: %0dns | reset=%b enable=%b count=%0d", $time, reset, enable, count);
    end

endmodule
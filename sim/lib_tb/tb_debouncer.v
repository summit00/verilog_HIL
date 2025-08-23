`timescale 1ns / 1ps
`include "tb_dump.vh"
`include "tb_check.vh"

module tb_debouncer;

    // Clock and control signals
    reg clk = 0;
    always #5 clk = ~clk; // 100 MHz clock

    reg reset;
    reg noisy;
    wire clean;

    // Instantiate debouncer (default N=20, can be overridden)
    debouncer #(.N(2)) dut (
        .clk(clk),
        .reset(reset),
        .noisy(noisy),
        .clean(clean)
    );

    // VCD dump
    `INIT_VCD("build/tb_debouncer.vcd", tb_debouncer)

    initial begin
        $display("Running debouncer testbench...");

        // Initial state
        reset = 1;
        noisy = 0;
        repeat (2) @(posedge clk);
        reset = 0;
        @(posedge clk);
        `CHECK_ZERO(clean, "clean should be 0 after reset")

        // Simulate bouncing: noisy toggles rapidly
        noisy = 1;
        repeat (2) @(posedge clk); // Not enough for debounce
        noisy = 0;
        repeat (1) @(posedge clk);
        noisy = 1;
        repeat (2) @(posedge clk);
        `CHECK_EQ(clean, 0, "clean should still be 0 during bouncing")

        // Hold noisy high long enough for debounce
        repeat (16) @(posedge clk);
        `CHECK_EQ(clean, 1, "clean should go high after stable input")

        // Simulate falling edge with bounce
        noisy = 0;
        repeat (2) @(posedge clk);
        noisy = 1;
        repeat (2) @(posedge clk);
        noisy = 0;
        repeat (2) @(posedge clk);
        `CHECK_EQ(clean, 1, "clean should still be 1 during falling bounce")

        // Hold noisy low long enough for debounce
        repeat (16) @(posedge clk);
        `CHECK_EQ(clean, 0, "clean should go low after stable input")

        $display("debouncer testbench completed successfully.");
        $display("");
        $display("");
        $finish;
    end

endmodule

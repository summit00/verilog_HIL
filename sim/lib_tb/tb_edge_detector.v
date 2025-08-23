`timescale 1ns / 1ps
`include "tb_dump.vh"
`include "tb_check.vh"

module tb_edge_detector;

    // Clock and control signals
    reg clk = 0;
    always #5 clk = ~clk; // 100 MHz clock

    reg reset;
    reg signal_in;
    wire pulse_rise, pulse_fall;

    // Instantiate edge detector for both edges
    edge_detector #(.DETECT_RISE(1), .DETECT_FALL(1)) dut (
        .clk(clk),
        .reset(reset),
        .signal_in(signal_in),
        .pulse(pulse) // We'll use pulse for both, see below
    );

    // For this version, pulse will pulse on either edge. If you want separate outputs, adjust the module accordingly.

    // VCD dump
    `INIT_VCD("build/tb_edge_detector.vcd", tb_edge_detector)

    initial begin
        $display("Running edge detector testbench...");

        signal_in = 0;
        reset = 1;
        #10;
        reset = 0;

        #2.5;
        signal_in = 1; 
        `CHECK_ZERO(pulse, "No pulse before clk")
        #5;
        `CHECK_EQ(pulse, 1, "Detected rising edge");
        #10;
        `CHECK_ZERO(pulse, "No pulse after one complete cycle");
        repeat (2) @(posedge clk);
        `CHECK_ZERO(pulse, "No pulse after no edge");
        #7.5;
        
        signal_in = 0;  
        `CHECK_ZERO(pulse, "No pulse before clk")
        #5;
        `CHECK_EQ(pulse, 1, "Detected falling edge");
        repeat (1) @(posedge clk);
        #5;
        `CHECK_ZERO(pulse, "No pulse after one complete cycle");
        repeat (1) @(posedge clk);
        

        $display("");
        $display("");
        $finish;
    end

endmodule

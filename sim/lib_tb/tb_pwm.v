`timescale 1ns / 1ps
`include "tb_dump.vh"
`include "tb_check.vh"

// -----------------------------------------------------------------------------
// Testbench: tb_pwm
// Description: Verifies PWM output matches duty cycle
// -----------------------------------------------------------------------------
module tb_pwm;

  localparam WIDTH = 4;              // 4-bit PWM (16 levels)

  reg clk = 0;
  always #5 clk = ~clk;

  reg reset = 0;
  reg [WIDTH-1:0] duty = 0;
  wire pwm_out;

  // DUT instantiation
  pwm #(
    .WIDTH(WIDTH)
  ) dut (
    .clk(clk),
    .reset(reset),
    .duty(duty),
    .pwm_out(pwm_out)
  );

  // VCD dump
  `INIT_VCD("build/tb_pwm.vcd", tb_pwm)

  integer high_count;
  integer i;

  initial begin
    $display("Running PWM testbench...");

    reset = 1;
    #15;
    reset = 0;

    // Test different duty cycles
    for (i = 0; i <= 15; i = i + 2) begin
      duty = i;
      high_count = 0;

      // Count high pulses over full period
      repeat (16) begin
        @(posedge clk);
        if (pwm_out)
          high_count = high_count + 1;
      end

      `CHECK_EQ(high_count, i, $sformatf("Duty = %0d should result in %0d high cycles", i, i));
    end

    // Test 100% duty
    duty = 15;
    high_count = 0;
    repeat (16) begin
      @(posedge clk);
      if (pwm_out)
        high_count = high_count + 1;
    end
    `CHECK_EQ(high_count, 15, "Duty = 15 -> 15 high cycles");

    $display("✅ PWM test complete.");
    $finish;
  end

endmodule

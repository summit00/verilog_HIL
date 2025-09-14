# Verilog HDL Style Guide

This guide defines conventions for writing clean, modular, and maintainable Verilog HDL used across the `em-fpga` project.

>  Goal: Produce high-quality, testable, and scalable Verilog for real-time FPGA-based HIL systems.

---

## General Principles

| Guideline                        | Recommendation                                                       |
|----------------------------------|----------------------------------------------------------------------|
| **Clarity over cleverness**      | Write for readers, not for synthesizers                             |
| **Parameterization**             | Use `parameter` to generalize bit-widths and behavior                |
| **Synchronous design**           | Favor `posedge clk` with synchronous resets                          |
| **Port naming**                  | Use `snake_case` for signals and ports                              |
| **Simulation separation**        | Wrap all test/simulation-only logic in `` `ifdef SIM ``             |
| **Line length**                  | Max ~100 characters for readability                                  |

---

## Module Formatting

### Header Block

Each module should start with a descriptive header:

```verilog
// -----------------------------------------------------------------------------
// Module Name: pulse_generator
// Description: Generates a one-cycle pulse every N clock cycles
// -----------------------------------------------------------------------------
```

---

### Module Template

```verilog
module module_name #(
    parameter int WIDTH = 8
)(
    input  wire clk,
    input  wire reset,
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q

`ifdef SIM
    , output wire debug_signal
`endif
);
```

- **Parameters**: Use `int` or `bit` for clarity.
- **Formatting**: Align signals and indent consistently (2 or 4 spaces).
- **Simulation**: Always guard with `` `ifdef SIM ``.

---

## Naming Conventions

| Entity           | Style          | Example         |
|------------------|----------------|-----------------|
| Signals/ports    | `snake_case`   | `data_out`, `reset_n` |
| Modules          | `lowerCamelCase` | `pulseGen`, `bldcModel` |
| Constants/macros | `ALL_CAPS`     | `WIDTH`, `TARGET_COUNT` |

---

## Flip-Flops and Resets

- Use synchronous resets unless you have a good reason otherwise.
- For parameterized resets:
  ```verilog
  q <= {WIDTH{1'b0}};
  ```

- Example flip-flop with optional enable:

  ```verilog
  always @(posedge clk) begin
      if (reset)
          q <= {WIDTH{1'b0}};
      else if (!ENABLED || enable)
          q <= d;
  end
  ```

---

## Simulation Best Practices

- **Dumpfiles**: Use a macro for consistent VCD naming.
  ```verilog
  `INIT_VCD("build/tb_module.vcd", tb_module)
  ```

- **Check Macros**: Use test macros for consistent pass/fail output.
  ```verilog
  `CHECK_EQ(actual, expected, "Check label")
  ```

- **Testbench Structure**:
  - One top-level `initial` block for stimulus.
  - One `initial` for `$monitor` or `$display`.

---

## Testbench Naming

| File Type       | Directory        | Pattern              |
|------------------|------------------|-----------------------|
| Module source    | `source/lib/`     | `modulename.v`        |
| Testbench        | `sim/lib_tb/`     | `tb_modulename.v`     |
| Macros           | `sim/common/`     | `tb_check.vh`, `tb_dump.vh` |

---

## Example: Clean Flip-Flop

```verilog
module dff #(
    parameter int WIDTH   = 1,
    parameter bit ENABLED = 1
)(
    input  wire clk,
    input  wire reset,
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q,
    input  wire enable

`ifdef SIM
    , output wire valid
`endif
);

    always @(posedge clk) begin
        if (reset)
            q <= {WIDTH{1'b0}};
        else if (!ENABLED || enable)
            q <= d;
    end

`ifdef SIM
    assign valid = !reset;
`endif

endmodule
```

---

## Summary Checklist

- [x] Use snake_case for all signals
- [x] Add VCD dumping with `INIT_VCD`
- [x] Wrap all test logic in `ifdef SIM`
- [x] Reset registers with `{WIDTH{1'b0}}`
- [x] Keep modules parameterized and reusable
- [x] Write tests with macros (`CHECK_EQ`, etc.)

---

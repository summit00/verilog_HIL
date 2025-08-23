# Syntax Best Practices

## 1. Always Blocks

- Use `always @(*)` for **combinational logic** (e.g., muxes, decoders).
- Use `always @(posedge clk)` for **sequential logic** (e.g., counters, FSMs).

```verilog
// Combinational logic
always @(*) begin
    case (sel)
        2'b00: out = a;
        2'b01: out = b;
        default: out = 0;
    endcase
end

// Sequential (clocked) logic
always @(posedge clk) begin
    counter <= counter + 1;
end
```

## 2. = vs <=

Understanding the difference between blocking (`=`) and non-blocking (`<=`) assignments is one of the most important concepts in Verilog. This guide explains how each behaves, when to use them, and common mistakes to avoid.

---

### What’s the Difference?

| Operator | Name                  | Use In                      | Behavior                             |
|----------|-----------------------|-----------------------------|--------------------------------------|
| `=`      | Blocking assignment   | `always @(*)`               | Executes immediately, in order       |
| `<=`     | Non-blocking assignment | `always @(posedge clk)`    | Executes all updates in parallel at clock edge |

---

### Blocking Assignment (`=`)

- **Used for combinational logic**
- Each line executes **in order**
- Later lines see the updated result of earlier lines

```verilog
always @(*) begin
    a = b;    // a gets b's value immediately
    b = a;    // b gets updated a (== b) → not a swap
end
```

### Non-Blocking Assignment (`=`)

- **Used for sequential (clocked) logic**
- Right-hand sides are all evaluated first
- Updates happen together at the next clock edge

```verilog
always @(*) begin
    a <= b;    // a gets b's value immediately
    b <= a;    // b gets updated a (== b) → not a swap
end
```



## 3. reg vs wire
- use reg for values stored or updated in always blocks
- use wire for continous assignments

```verilog
reg [7:0] my_reg;
wire [7:0] my_wire;

assign my_wire = my_reg + 1;
```


## 4. Synchronize Asynchronous Inputs
All external signlas (buttons, UART, etc.) should be synchronized into the system clock domain:

```verilog
reg sync_0, sync_1;
always @(posedge clk) begin
    sync_0 <= async_input;
    sync_1 <= sync_0;
end
```

## 5. Debounce Physical Buttons
Mechanical buttons bounce. Use simple delay counters or debounce filters to ignore false transitions.

## 6. Use Parameters
Replace magic numbers with named parameters to improve readability and portability.

```verilog
parameter CLK_FREQ = 12000000;
parameter DEBOUNCE_TIME = 20000;
```
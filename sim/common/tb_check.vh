`ifndef TB_CHECK_VH
`define TB_CHECK_VH

`define CHECK_EQ(signal, expected, message) \
    if ((signal) !== (expected)) begin \
        $display("FAIL: %s | Got: %0d, Expected: %0d", message, signal, expected); \
        $fatal; \
    end else begin \
        $display("PASS: %s", message); \
    end

`define CHECK_ZERO(signal, message) \
    `CHECK_EQ(signal, 0, message)

`define CHECK_ONE(signal, message) \
    `CHECK_EQ(signal, 1, message)

`endif

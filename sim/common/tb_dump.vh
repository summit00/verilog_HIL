`ifndef TB_DUMP_VH
`define TB_DUMP_VH

// Define VCD dump macro for this file
`define INIT_VCD(FILE, MODULE) \
    initial begin \
        $dumpfile(FILE); \
        $dumpvars(0, MODULE); \
    end
`endif
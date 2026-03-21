`timescale 1ns / 1 ps 

module cwru_data_mem # (
    parameter WIDTH = 32
)(
    input wire clk,
    input wire rst_n,
    input wire[WIDTH-1:0] addr,
    input wire[WIDTH-1:0] wr_data,

    // control flags
    input mem_read,
    input mem_write,

    // output res
    output mem_data
);

// define your logic starting here

endmodule
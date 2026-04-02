`timescale 1ns / 1ps 

module cwru_control_unit (
    input wire[6:0] opcode,
    input wire[2:0] funct3,
    input wire[6:0] funct7,

    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg branch_eq,
    output reg mem_to_reg,
    output reg alu_src,
    output reg[3:0] alu_cont,
    output reg jump
);

// define your logic here
// if you need help, refer to doc or ask 
// me on discord

endmodule
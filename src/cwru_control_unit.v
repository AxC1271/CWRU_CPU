`timescale 1ns / 1ps 

module cwru_control_unit (
    input wire[6:0] opcode,
    input wire[2:0] funct3,
    input wire[6:0] funct7,

    output logic reg_write,
    output logic mem_read,
    output logic mem_write,
    output logic branch_eq,
    output logic mem_to_reg,
    output logic alu_src,
    output logic alu_cont,
    output logic jump
);

// define your logic here
// if you need help, refer to doc or ask 
// me on discord

endmodule
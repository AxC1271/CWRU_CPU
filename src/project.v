/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_cwru_cpu (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // instantiate ALL necessary signals here

  // program counter
  wire[31:0] pc_in, pc_out;

  // instruction memory
  wire[31:0] current_instruction;

  // register file
  wire[4:0] rd_addr1, rd_addr2, wr_addr;
  wire[31:0] rd_data1, rd_data2, wr_data;

  // control unit
  wire[6:0] opcode;
  wire[2:0] funct3;
  wire[6:0] funct7;

  wire reg_write, mem_read, mem_write, branch_eq;
  wire mem_to_reg, alu_src, jump;
  wire[3:0] alu_cont;

  // immediate generator
  wire[31:0] immediate;

  // arithmetic logic unit
  wire[31:0] res;
  wire zero_flag;

  // data memory
  wire[31:0] mem_data;
  

  // instantiate modules here, fill in the blanks
  // what else would we need here besides the modules?
  cwru_program_counter pc (
    .clk(),
    .pc_in(),
    .pc_out()
  );

  cwru_instr_mem im (
    .pc(),
    .instr()
  );

  cwru_register_file rf (
    .clk(),
    .rst_n(),
    .rd_addr1(),
    .rd_addr2(),
    .rd_data1(),
    .rd_data2(),
    .wr_addr(),
    .reg_write(),
    .wr_data()
  );

  cwru_control_unit cu (
    .opcode(),
    .funct3(),
    .funct7(),
    .reg_write(),
    .mem_read(),
    .mem_write(),
    .branch_eq(),
    .mem_to_reg(),
    .alu_src(),
    .alu_cont(),
    .jump()
  );

  cwru_imm_gen ig (
    .instruction(),
    .immediate()
  );

  cwru_alu alu (
    .op1(),
    .op2(),
    .alu_cont(),
    .res(),
    .zero_flag()
  );

  cwru_data_mem dm (
    .clk(),
    .rst_n(),
    .addr(),
    .wr_data(),
    .mem_read(),
    .mem_write(),
    .mem_data()
  );


  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};

endmodule

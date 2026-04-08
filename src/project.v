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
  
  // instruction fields
  assign opcode   = current_instruction[6:0]; 
  assign wr_addr  = current_instruction[11:7];
  assign funct3   = current_instruction[14:12];
  assign rd_addr1 = current_instruction[19:15];
  assign rd_addr2 = current_instruction[24:20];
  assign funct7   = current_instruction[31:25];


  // instantiate modules here, fill in the blanks
  // what else would we need here besides the modules?
  cwru_program_counter pc (
    .clk(clk),
    .pc_in(pc_in),
    .pc_out(pc_out)
  );

  cwru_instr_mem im ( 
    .pc(pc_out), // from program counter
    .instr(current_instruction)
  );

  cwru_register_file rf (
    .clk(clk),
    .rst_n(rst_n),
    .rd_addr1(rd_addr1),
    .rd_addr2(rd_addr2),
    .rd_data1(rd_data1),
    .rd_data2(rd_data2),
    .wr_addr(wr_addr),
    .reg_write(reg_write),
    .wr_data(wr_data)
  );

  cwru_control_unit cu (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(),
    .reg_write(),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .branch_eq(branch_eq),
    .mem_to_reg(mem_to_reg),
    .alu_src(alu_src),
    .alu_cont(alu_cont),
    .jump(jump)
  );

  cwru_imm_gen ig (
    .instruction(current_instruction),
    .immediate(immediate)
  );

  cwru_alu alu (
    .op1(op1),
    .op2(op2),
    .pc(pc),
    .alu_cont(alu_cont),
    .res(res),
    .zero_flag(zero_flag)
  );

  cwru_data_mem dm (
    .clk(clk),
    .rst_n(rst_n),
    .addr(res),
    .wr_data(rd_data2),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_data(mem_data)
  );


  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in, uio_in 1'b0};

endmodule

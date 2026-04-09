`default_nettype none
`timescale 1ns / 1ps

module tt_um_cwru_cpu (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

  assign uo_out  = 8'b0;
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;

  wire [31:0] pc_in, pc_out;
  wire [31:0] current_instruction;

  wire [4:0]  rd_addr1, rd_addr2, wr_addr;
  wire [31:0] rd_data1, rd_data2, wr_data;

  wire [6:0]  opcode;
  wire [2:0]  funct3;
  wire [6:0]  funct7;

  wire        reg_write, mem_read, mem_write, branch_eq;
  wire        mem_to_reg, alu_src, jump, display;
  wire [3:0]  alu_cont;

  wire [31:0] immediate;
  wire [31:0] res;
  wire        zero_flag;
  wire [31:0] mem_data;

  // instruction fields
  assign opcode   = current_instruction[6:0];
  assign wr_addr  = current_instruction[11:7];
  assign funct3   = current_instruction[14:12];
  assign rd_addr1 = current_instruction[19:15];
  assign rd_addr2 = current_instruction[24:20];
  assign funct7   = current_instruction[31:25];

  // ALU operands
  wire [31:0] op1, op2;
  assign op1 = rd_data1;
  assign op2 = alu_src ? immediate : rd_data2;

  // pc next: reset takes priority, then jump, then branch, then pc+4
  wire        branch_taken;
  wire [31:0] pc_plus4, pc_branch, pc_jump;
  assign pc_plus4  = pc_out + 32'd4;
  assign pc_branch = pc_out + (immediate << 1);
  assign pc_jump = pc_out + immediate;
  assign branch_taken  = branch_eq & zero_flag;
  assign pc_in = !rst_n       ? 32'h0     :
                 jump         ? pc_jump   :
                 branch_taken ? pc_branch :
                                pc_plus4;

  // writeback mux
  assign wr_data = mem_to_reg ? mem_data : res;

  cwru_program_counter pc_inst (
    .clk(clk),
    .pc_in(pc_in),
    .pc_out(pc_out)
  );

  cwru_instr_mem im (
    .pc(pc_out),
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
    .funct7(funct7),
    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .branch_eq(branch_eq),
    .mem_to_reg(mem_to_reg),
    .alu_src(alu_src),
    .alu_cont(alu_cont),
    .jump(jump),
    .display(display)
  );

  cwru_imm_gen ig (
    .instruction(current_instruction),
    .immediate(immediate)
  );

  cwru_alu alu (
    .op1(op1),
    .op2(op2),
    .pc(pc_out),
    .alu_cont(alu_cont),
    .res(res),
    .zero_flag(zero_flag)
  );

   wire _unused = &{ena, ui_in, uio_in, display, 1'b0};

endmodule
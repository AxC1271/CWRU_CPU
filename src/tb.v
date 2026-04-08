`default_nettype none
`timescale 1ns / 1ps

module tb ();

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  initial clk = 0;
  always #5 clk = ~clk;

  tt_um_cwru_cpu user_project (
      .ui_in  (ui_in),
      .uo_out (uo_out),
      .uio_in (uio_in),
      .uio_out(uio_out),
      .uio_oe (uio_oe),
      .ena    (ena),
      .clk    (clk),
      .rst_n  (rst_n)
  );

  initial begin
    ena    = 1;
    ui_in  = 8'h00;
    uio_in = 8'h00;
    rst_n  = 0;

    repeat(4) @(posedge clk);
    rst_n = 1;

    repeat(500) @(posedge clk);
    $finish;
  end

  // print header
  initial $display("time\t\tpc\t\tinstr\t\tx1\t\tx2\t\tx3\t\tx4");

  // monitor every cycle
  always @(posedge clk) begin
    if (rst_n) begin
      $display("%0t\t\t%h\t\t%h\t\t%h\t\t%h\t\t%h\t\t%h",
        $time,
        user_project.pc_out,
        user_project.current_instruction,
        user_project.rf.registers[1],   // x1 (F_n-2)
        user_project.rf.registers[2],   // x2 (F_n-1)
        user_project.rf.registers[3],   // x3 (current fib)
        user_project.rf.registers[4]    // x4 (counter)
      );
    end
  end

  // flag every print instruction
  always @(posedge clk) begin
    if (rst_n && user_project.current_instruction[6:0] == 7'h7F) begin
      $display(">>> PRINT at t=%0t  x3 = %0d", $time, user_project.rf.registers[3]);
    end
  end

  always @(posedge clk) begin
    if (rst_n && user_project.current_instruction[6:0] == 7'h63) begin
      $display("BRANCH: pc=%h imm=%h pc_branch=%h branch_eq=%b zero=%b taken=%b",
        user_project.pc_out,
        user_project.immediate,
        user_project.pc_branch,
        user_project.branch_eq,
        user_project.zero_flag,
        user_project.branch_taken
      );
    end
  end

endmodule
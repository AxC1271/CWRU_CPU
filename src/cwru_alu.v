`timescale 1ns / 1ps

module cwru_alu # (
    parameter WIDTH = 32
)(
    input wire[WIDTH-1:0] op1,
    input wire[WIDTH-1:0] op2,
    input wire[3:0] alu_cont,
    output reg[31:0] res,
    output zero_flag
);

// define your logic here
always @(*) begin

end

endmodule
`timescale 1ns / 1ps 

module cwru_instr_mem # (
    parameter WIDTH = 32,
    parameter DEPTH = 256
)(
    input wire[WIDTH-1:0] pc,
    output reg[WIDTH-1:0] instr
);

   reg [WIDTH-1:0] mem [0:DEPTH-1];

    // define your logic starting here
    initial begin
        $readmemh("program.hex", mem);
    end

   always @(*) begin
        instr = mem[pc[7:2]];
    end

endmodule
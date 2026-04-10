module cwru_instr_mem # (
    parameter WIDTH = 32,
    parameter DEPTH = 16
)(
    input wire[WIDTH-1:0] pc,
    output reg[WIDTH-1:0] instr
);

   reg [WIDTH-1:0] mem [0:DEPTH-1];

    // define your logic starting here
   initial begin
        mem[0]  = 32'h00000093; // addi x1, x0, 0       -- x1 = 0
        mem[1]  = 32'h00100113; // addi x2, x0, 1       -- x2 = 1
        mem[2]  = 32'h00000213; // addi x4, x0, 0       -- x4 = 0 (counter)
        mem[3]  = 32'h00B00293; // addi x5, x0, 11      -- x5 = 11 (limit)

        // loop:
        mem[4]  = 32'h00428663; // beq x4, x5, +12      -- if counter==11, jump to done
        mem[5]  = 32'h002081B3; // add x3, x1, x2       -- x3 = x1 + x2
        mem[6]  = 32'h00010093; // addi x1, x2, 0       -- x1 = x2
        mem[7]  = 32'h00018113; // addi x2, x3, 0       -- x2 = x3
        mem[8]  = 32'h0001807F; // prnt x3               -- display x3
        mem[9]  = 32'h00120213; // addi x4, x4, 1       -- counter++
        mem[10] = 32'hFE000AE3; // beq x0, x0, -12      -- jump back to loop

        // done:
        mem[11] = 32'h0001807F; // prnt x3               -- display final value
        mem[12] = 32'hFE000FE3; // beq x0, x0, -1       -- halt

        for (integer i = 13; i < DEPTH; i = i + 1) begin
            mem[i] = 32'h00000000;
        end
    end

   always @(*) begin
        instr = mem[pc[7:2]];
    end

endmodule
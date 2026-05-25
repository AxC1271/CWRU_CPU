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
        mem[0]  = 32'h00000093; // addi x1, x0, 0       -- x1 = 0 (counter)
        mem[1]  = 32'h00100113; // addi x2, x0, 1       -- x2 = 1 (increment)

        // loop:
        mem[2]  = 32'h0000807F; // prnt x1               -- display x1
        mem[3]  = 32'h002080B3; // add x1, x1, x2        -- x1 = x1 + 1
        mem[4]  = 32'hFF9FF06F; // jal x0, -8            -- jump back to loop (mem[2])

        for (integer i = 5; i < DEPTH; i = i + 1)
            mem[i] = 32'h00000000;
    end

   always @(*) begin
        instr = mem[pc[7:2]];
    end

endmodule
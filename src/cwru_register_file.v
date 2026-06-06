module cwru_register_file #(
    parameter WIDTH = 32
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire [4:0]       rd_addr1,
    input  wire [4:0]       rd_addr2,
    output wire [WIDTH-1:0] rd_data1,
    output wire [WIDTH-1:0] rd_data2,
    input  wire [4:0]       wr_addr,
    input  wire             reg_write,
    input  wire [WIDTH-1:0] wr_data
);
    reg [WIDTH-1:0] regs [1:31];
    wire we = reg_write && (wr_addr != 5'b0);

    always @(posedge clk) begin
        if (!rst_n) begin
            regs[1]  <= 0; regs[2]  <= 0; regs[3]  <= 0; regs[4]  <= 0;
            regs[5]  <= 0; regs[6]  <= 0; regs[7]  <= 0; regs[8]  <= 0;
            regs[9]  <= 0; regs[10] <= 0; regs[11] <= 0; regs[12] <= 0;
            regs[13] <= 0; regs[14] <= 0; regs[15] <= 0; regs[16] <= 0;
            regs[17] <= 0; regs[18] <= 0; regs[19] <= 0; regs[20] <= 0;
            regs[21] <= 0; regs[22] <= 0; regs[23] <= 0; regs[24] <= 0;
            regs[25] <= 0; regs[26] <= 0; regs[27] <= 0; regs[28] <= 0;
            regs[29] <= 0; regs[30] <= 0; regs[31] <= 0;
        end else if (we) begin
            regs[wr_addr] <= wr_data;
        end
    end

    assign rd_data1 = (rd_addr1 == 5'b0) ? {WIDTH{1'b0}} : regs[rd_addr1];
    assign rd_data2 = (rd_addr2 == 5'b0) ? {WIDTH{1'b0}} : regs[rd_addr2];
endmodule
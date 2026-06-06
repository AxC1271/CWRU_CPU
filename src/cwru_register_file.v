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

    integer i;
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 1; i < 32; i = i + 1)
                regs[i] <= {WIDTH{1'b0}};
        end else if (we) begin
            regs[wr_addr] <= wr_data;
        end
    end

    assign rd_data1 = (rd_addr1 == 5'b0) ? {WIDTH{1'b0}} : regs[rd_addr1];
    assign rd_data2 = (rd_addr2 == 5'b0) ? {WIDTH{1'b0}} : regs[rd_addr2];
endmodule
module cwru_register_file # (
    parameter WIDTH = 32
)(
    input wire clk,
    input wire rst_n,

    input wire [4:0]        rd_addr1,
    input wire [4:0]        rd_addr2,
    output wire [WIDTH-1:0] rd_data1,
    output wire [WIDTH-1:0] rd_data2,

    input wire [4:0]        wr_addr,
    input wire              reg_write,
    input wire [WIDTH-1:0]  wr_data
);

    reg [WIDTH-1:0] registers [31:0];

    integer i;

    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end else begin
            if (reg_write && (wr_addr != 5'b0))
                registers[wr_addr] <= wr_data;
        end
    end

    assign rd_data1 = registers[rd_addr1];
    assign rd_data2 = registers[rd_addr2];

endmodule
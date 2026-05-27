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

    always @(posedge clk or negedge rst_n) begin : reg_block
        if (!rst_n) begin
            registers[0]  <= 32'b0; registers[1]  <= 32'b0;
            registers[2]  <= 32'b0; registers[3]  <= 32'b0;
            registers[4]  <= 32'b0; registers[5]  <= 32'b0;
            registers[6]  <= 32'b0; registers[7]  <= 32'b0;
            registers[8]  <= 32'b0; registers[9]  <= 32'b0;
            registers[10] <= 32'b0; registers[11] <= 32'b0;
            registers[12] <= 32'b0; registers[13] <= 32'b0;
            registers[14] <= 32'b0; registers[15] <= 32'b0;
            registers[16] <= 32'b0; registers[17] <= 32'b0;
            registers[18] <= 32'b0; registers[19] <= 32'b0;
            registers[20] <= 32'b0; registers[21] <= 32'b0;
            registers[22] <= 32'b0; registers[23] <= 32'b0;
            registers[24] <= 32'b0; registers[25] <= 32'b0;
            registers[26] <= 32'b0; registers[27] <= 32'b0;
            registers[28] <= 32'b0; registers[29] <= 32'b0;
            registers[30] <= 32'b0; registers[31] <= 32'b0;
        end else begin
            if (reg_write && (wr_addr != 5'b0))
                registers[wr_addr] <= wr_data;
        end
    end

    assign rd_data1 = registers[rd_addr1];
    assign rd_data2 = registers[rd_addr2];

endmodule
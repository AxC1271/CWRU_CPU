`timescale 1ns / 1ps 

// quick note, based on how you write
// the register file, should rd_data/wr_data
// be reg or wire? this is an open-ended question
module cwru_register_file # (
    parameter WIDTH = 32
)(
    input wire clk,
    input wire rst_n,

    // rd interface
    input wire[4:0] rd_addr1,
    input wire[4:0] rd_addr2,
    output wire[WIDTH-1:0] rd_data1,
    output wire[WIDTH-1:0] rd_data2,

    // wr interface
    input wire[4:0] wr_addr,
    input wire reg_write,
    input wire[WIDTH-1:0] wr_data
);

    // define your logic starting here
    // quick pointers: register 0 shouldn't be writeable
    // decide if your reads use combinational or sequential logic
    reg [WIDTH-1:0] registers [WIDTH-1:0];


    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b00;
            end
        else begin
            if (reg_write) begin
                if (wr_addr != 5'b00000) begin
                    registers[wr_addr] <= wr_data;
                end
            end
        end      
    end

    assign rd_data1 = registers[rd_addr1];
    assign rd_data2 = registers[rd_addr2];
endmodule

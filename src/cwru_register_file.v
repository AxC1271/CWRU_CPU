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
            r1<=0;  r2<=0;  r3<=0;  r4<=0;  r5<=0;  r6<=0;  r7<=0;  r8<=0;
            r9<=0;  r10<=0; r11<=0; r12<=0; r13<=0; r14<=0; r15<=0; r16<=0;
            r17<=0; r18<=0; r19<=0; r20<=0; r21<=0; r22<=0; r23<=0; r24<=0;
            r25<=0; r26<=0; r27<=0; r28<=0; r29<=0; r30<=0; r31<=0;
        end else if (we) begin
            case (wr_addr)
                5'd1:  r1<=wr_data;   5'd2:  r2<=wr_data;
                5'd3:  r3<=wr_data;   5'd4:  r4<=wr_data;
                5'd5:  r5<=wr_data;   5'd6:  r6<=wr_data;
                5'd7:  r7<=wr_data;   5'd8:  r8<=wr_data;
                5'd9:  r9<=wr_data;   5'd10: r10<=wr_data;
                5'd11: r11<=wr_data;  5'd12: r12<=wr_data;
                5'd13: r13<=wr_data;  5'd14: r14<=wr_data;
                5'd15: r15<=wr_data;  5'd16: r16<=wr_data;
                5'd17: r17<=wr_data;  5'd18: r18<=wr_data;
                5'd19: r19<=wr_data;  5'd20: r20<=wr_data;
                5'd21: r21<=wr_data;  5'd22: r22<=wr_data;
                5'd23: r23<=wr_data;  5'd24: r24<=wr_data;
                5'd25: r25<=wr_data;  5'd26: r26<=wr_data;
                5'd27: r27<=wr_data;  5'd28: r28<=wr_data;
                5'd29: r29<=wr_data;  5'd30: r30<=wr_data;
                5'd31: r31<=wr_data;
                default: ;
            endcase
        end
    end

    assign rd_data1 = (rd_addr1 == 5'b0) ? {WIDTH{1'b0}} : regs[rd_addr1];
    assign rd_data2 = (rd_addr2 == 5'b0) ? {WIDTH{1'b0}} : regs[rd_addr2];
endmodule
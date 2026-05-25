module cwru_display (
    input  wire        clk,
    input  wire        rst,
    input  wire        print,
    input  wire [31:0] val,
    output reg  [6:0]  seg,
    output reg         ade
);

    always @(posedge clk or posedge rst) begin
        if (rst || !print) begin
            seg <= 7'b1111110;
            ade <= 1'b1;
        end else begin
            case (val % 10)
                4'd0: seg <= 7'b0000001;
                4'd1: seg <= 7'b1001111;
                4'd2: seg <= 7'b0010010;
                4'd3: seg <= 7'b0000110;
                4'd4: seg <= 7'b1001100;
                4'd5: seg <= 7'b0100100;
                4'd6: seg <= 7'b0100000;
                4'd7: seg <= 7'b0001111;
                4'd8: seg <= 7'b0000000;
                default: seg <= 7'b0000100;
            endcase
            ade <= 1'b1;
        end
    end

endmodule
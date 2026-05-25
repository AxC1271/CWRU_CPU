module seven_seg_mux (
    input  wire        clk,
    input  wire        rst,
    input  wire        print,
    input  wire [31:0] val,
    output reg  [6:0]  seg,
    output reg  [3:0]  ade
);

    localparam CLK_MAX = (100_000_000 / 500) / 2;

    reg        seg_clk;
    reg [31:0] clk_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            seg_clk <= 1'b0;
            clk_cnt <= 0;
        end else begin
            if (clk_cnt == CLK_MAX) begin
                seg_clk <= ~seg_clk;
                clk_cnt <= 0;
            end else begin
                clk_cnt <= clk_cnt + 1;
            end
        end
    end

    always @(posedge seg_clk or posedge rst) begin
        if (rst) begin
            ade <= 4'b1110;
        end else begin
            case (ade)
                4'b1110: ade <= 4'b1101;
                4'b1101: ade <= 4'b1011;
                4'b1011: ade <= 4'b0111;
                default: ade <= 4'b1110;
            endcase
        end
    end

    reg [3:0] digit;

    always @(posedge seg_clk or posedge rst) begin
        if (rst || !print) begin
            seg <= 7'b1111110;
        end else begin
            case (ade)
                4'b1110: digit = val % 10;
                4'b1101: digit = (val / 10) % 10;
                4'b1011: digit = (val / 100) % 10;
                default: digit = (val / 1000) % 10;
            endcase

            case (digit)
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
        end
    end

endmodule
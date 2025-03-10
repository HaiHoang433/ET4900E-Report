module pe #(
    parameter BW = 8, // bitwidth
    parameter N = 5
) (
    input clk, // posedge-triggered
    input rst_n, // negedge-triggered
    input [BW-1:0] iRow,
    input [BW-1:0] iCol,
    output reg [BW-1:0] oRow,
    output reg [BW-1:0] oCol,
    output reg [N*2*BW-1:0] oRes
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        oRow <= {BW{1'b0}};
        oCol <= {BW{1'b0}};
        oRes <= {(N*2*BW){1'b0}};
    end
    else begin
        oRow <= iRow;
        oCol <= iCol;
        oRes <= oRes + iRow * iCol;
    end
end
    
endmodule
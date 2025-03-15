// M x N * N x P

module pe #(
    parameter BW = 16, // Bfloat16
    parameter N = 4
) (
    input clk, // posedge-triggered
    input rst_n, // negedge-triggered
    input [BW-1:0] iRow,
    input [BW-1:0] iCol,
    output reg [BW-1:0] oRow,
    output reg [BW-1:0] oCol,
    output reg [BW-1:0] oRes
);

// Instantiate bfloat16Multiplier & bfloat16Add
logic [BW-1:0] mul_result;
logic [BW-1:0] add_result;

bfloat16Multiplier bfloat16Multiplier_inst (
    .a(iRow),
    .b(iCol),
    .result(mul_result)
);

bfloat16Add bfloat16Add_inst (
    .a(oRes),
    .b(mul_result),
    .result(add_result)
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        oRow <= {BW{1'b0}};
        oCol <= {BW{1'b0}};
        oRes <= {BW{1'b0}};
    end
    else begin
        oRow <= iRow;
        oCol <= iCol;
        oRes <= add_result;
    end
end

endmodule
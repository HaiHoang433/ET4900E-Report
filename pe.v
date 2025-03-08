// each posclk, shift the input iRow and iCol to oRow and oCol
// each posclk, oAcc accummulate iRow*iCol

module pe #(
    parameter BITWIDTH = 8
) (
    input clk,
    input reset,
    input [BITWIDTH-1:0] iRow,
    input [BITWIDTH-1:0] iCol,
    output [BITWIDTH-1:0] oRow,
    output [BITWIDTH-1:0] oCol,
    output [2*BITWIDTH-1:0] oAcc
);

reg [BITWIDTH-1:0] regRow;
reg [BITWIDTH-1:0] regCol;
reg [2*BITWIDTH-1:0] regAcc;

always @(posedge clk or posedge reset) begin
    if (reset) begin // initialize
        regAcc <= 0;
        regRow <= 0;
        regCol <= 0;
    end else begin
        regAcc <= regAcc + iRow * iCol;
        regRow <= iRow;
        regCol <= iCol;
    end
end

assign oRow = regRow;
assign oCol = regCol;
assign oAcc = regAcc;

endmodule
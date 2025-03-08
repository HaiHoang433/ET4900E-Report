module systolicArray #(
    parameter M = 4,
    parameter P = 4,
    parameter BITWIDTH = 8
) (
    input clk,
    input reset,
    // Flattened inputs
    input [M*BITWIDTH-1:0] iRow, // 1, 5, 9, 13 
    input [P*BITWIDTH-1:0] iCol, // 1, 2, 3, 4
    // Flattened output
    output [M*P*2*BITWIDTH-1:0] oRes
);

genvar i, j;
generate
    for (i = 0; i < M; i = i + 1) begin: genRow
        for (j = 0; j < P; j = j + 1) begin: genCol
            wire [BITWIDTH-1:0] iRowPE, iColPE;
            wire [BITWIDTH-1:0] oRowPE, oColPE;
            wire [2*BITWIDTH-1:0] oAccPE;
            
            // Extract row_in for this row.
            // Fix part-select indexing direction
            if (j == 0) begin
                assign iRowPE = iRow[((M-i-1)*BITWIDTH) +: BITWIDTH];
            end else begin
                assign iRowPE = genRow[i].genCol[j-1].oRowPE;
            end
            
            // Fix part-select indexing direction for column input
            if (i == 0) begin
                assign iColPE = iCol[((P-j-1)*BITWIDTH) +: BITWIDTH];
            end else begin
                assign iColPE = genRow[i-1].genCol[j].oColPE;
            end
            
            pe #(
                .BITWIDTH(BITWIDTH)
            ) pe_inst (
                .clk(clk),
                .reset(reset),
                .iRow(iRowPE),
                .iCol(iColPE),
                .oRow(oRowPE),
                .oCol(oColPE),
                .oAcc(oAccPE)
            );
            
            // Correct output assignment indexing direction
            assign oRes[((M*P - (i*P + j + 1)) * 2 * BITWIDTH) +: (2 * BITWIDTH)] = oAccPE;
        end
    end
endgenerate

endmodule

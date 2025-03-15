// M x N * N x P

module systolicArray #(
    parameter BW = 16,  // Bfloat16
    parameter M = 3, 
    parameter N = 4,
    parameter P = 5
) (
    input clk,
    input rst_n,
    input [BW-1:0] iRow [0:M-1],  // M row inputs
    input [BW-1:0] iCol [0:P-1],  // P column inputs
    output reg [BW-1:0] oRes [0:M-1][0:P-1]  // MxP results
);

genvar i, j;
generate
    for (i = 0; i < M; i = i + 1) begin: row
        for (j = 0; j < P; j = j + 1) begin: col
            wire [BW-1:0] iRow_wire, iCol_wire;
            wire [BW-1:0] oRow_wire, oCol_wire;
            wire [BW-1:0] oRes_wire;

            pe #(
                .BW(BW),
                .N(N)
            ) pe_inst (
                .clk(clk),
                .rst_n(rst_n),
                .iRow(iRow_wire),
                .iCol(iCol_wire),
                .oRow(oRow_wire),
                .oCol(oCol_wire),
                .oRes(oRes_wire)
            );

            assign oRes[i][j] = oRes_wire;

            // Vertical data flow (columns)
            if (i == 0) assign iCol_wire = iCol[j];         // Top boundary
            else        assign iCol_wire = row[i-1].col[j].oCol_wire;  // From above

            // Horizontal data flow (rows)
            if (j == 0) assign iRow_wire = iRow[i];         // Left boundary
            else        assign iRow_wire = row[i].col[j-1].oRow_wire;  // From left
        end
    end
endgenerate

endmodule
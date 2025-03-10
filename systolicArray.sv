module systolicArray #(
    parameter BW = 8,
    parameter N = 5
) (
    input clk,
    input rst_n,
    input [BW-1:0] iRow [0:N-1],
    input [BW-1:0] iCol [0:N-1],
    output reg [N*2*BW-1:0] oRes [0:N-1][0:N-1]
);

genvar i, j;
generate
    for(i = 0; i < N; i = i + 1) begin: row
        for(j = 0; j < N; j = j + 1) begin: col
            wire [BW-1:0] iRow_wire;
            wire [BW-1:0] iCol_wire;
            wire [BW-1:0] oRow_wire;
            wire [BW-1:0] oCol_wire;
            wire [N*2*BW-1:0] oRes_wire;

            pe #(.BW(BW), .N(N)) pe_inst (
                .clk(clk),
                .rst_n(rst_n),
                .iRow(iRow_wire),
                .iCol(iCol_wire),
                .oRow(oRow_wire),
                .oCol(oCol_wire),
                .oRes(oRes_wire)
            );

            assign oRes[i][j] = oRes_wire;

            // Connect iCol_wire based on current row (i)
            if (i == 0) begin
                assign iCol_wire = iCol[j];
            end else begin
                assign iCol_wire = row[i-1].col[j].oCol_wire;
            end

            // Connect iRow_wire based on current column (j)
            if (j == 0) begin
                assign iRow_wire = iRow[i];
            end else begin
                assign iRow_wire = row[i].col[j-1].oRow_wire;
            end
        end
    end
endgenerate

endmodule
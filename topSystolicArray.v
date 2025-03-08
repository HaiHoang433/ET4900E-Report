module topSystolicArray #(
    parameter N = 4,
    parameter BITWIDTH = 8
) (
    input clk,
    input reset,
    input [N*N*BITWIDTH-1:0] iRow,
    input [N*N*BITWIDTH-1:0] iCol,
    output wire [N*N*2*BITWIDTH-1:0] oRes // Use 'wire' since it's driven by systolicArray_inst
);

// 1. Generating (N+N-1) N*BITWIDTH-length seriesRow
reg [N*BITWIDTH-1:0] seriesRow [0:N+N-2];
reg [N*BITWIDTH-1:0] seriesCol [0:N+N-2];
integer i, j, k;

always @(*) begin
    for (k = 0; k < 2*N-1; k = k + 1) begin
        seriesRow[k] = {N{1'b0}}; // Initialize
        seriesCol[k] = {N{1'b0}}; // Initialize

        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                if (i + j == k) begin
                    // Correct part-select direction
                    seriesRow[k] = (seriesRow[k] << BITWIDTH) | 
                                   iRow[((N*N-i*N-j+1)*BITWIDTH-1) -: BITWIDTH];

                    seriesCol[k] = (seriesCol[k] << BITWIDTH) | 
                                   iCol[((N*N-i*N-j+1)*BITWIDTH-1) -: BITWIDTH];
                end
            end
        end
    end
end

// 2. Shift the generated sequences into systolicArray_inst
reg [N*BITWIDTH-1:0] iRowSA;
reg [N*BITWIDTH-1:0] iColSA;

parameter maxAddCounter = $clog2(2*N-1);
reg [maxAddCounter:0] counter = 0;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 0;
        iRowSA  <= 0;
        iColSA  <= 0;
    end else begin
        if (counter < 2*N-1) begin
            iRowSA <= seriesRow[counter];
            iColSA <= seriesCol[counter];
            counter <= counter + 1;
        end
    end
end

// Instantiate the systolic array
systolicArray #(
    .M(N), 
    .P(N),
    .BITWIDTH(BITWIDTH)
) systolicArray_inst (
    .clk(clk),
    .reset(reset),
    .iRow(iRowSA),
    .iCol(iColSA),
    .oRes(oRes) // Drive oRes directly from the systolic array
);

endmodule

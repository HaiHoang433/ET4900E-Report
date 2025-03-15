// Purpose: Rearrange the weight matrices to be capable of GEMM

module weightRearrange #(
    parameter K = 10,   // number of filters in 1 CNN layer
    parameter C = 3,    // number of filter channels in 1 CNN layer
    parameter wH = 5,   // size of filters in 1 CNN layer
    parameter BW = 16   // Bfloat16 format
) (
    input [BW-1:0] iWeight[0:K-1][0:C-1][0:wH-1][0:wH-1],
    output reg [BW-1:0] iWeight_rearranged[0:K-1][0:C*wH*wH-1]
);

integer jK, jC, jwH_row, jwH_col;
integer j_flatten;

always_comb begin
    for (jK = 0; jK < K; jK = jK + 1) begin
        for (jC = 0; jC < C; jC = jC + 1) begin 
            for (jwH_row = 0; jwH_row < wH; jwH_row = jwH_row + 1) begin
                for (jwH_col = 0; jwH_col < wH; jwH_col = jwH_col + 1) begin
                    // Calculate flattened index
                    j_flatten = (jC * wH * wH) + (jwH_row * wH) + jwH_col;
                    // Rearrange weights
                    iWeight_rearranged[jK][j_flatten] = iWeight[jK][jC][jwH_row][jwH_col];
                end
            end
        end
    end
end

endmodule
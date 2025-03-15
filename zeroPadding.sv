// Zero padding the ifmap matrix

module zeroPadding #(
    parameter C,    // number of ifmap channels for 1 CNN layer
    parameter iH,   // size of ifmap for 1 CNN layer
    parameter P,    // zero-padding size for ifmap for 1 CNN layer
    parameter BW    // Bfloat16 format
) (
    input [BW-1:0] ifmap[0:C-1][0:iH-1][0:iH-1],
    output reg [BW-1:0] ifmap_zeropad[0:C-1][0:(iH+2*P)-1][0:(iH+2*P)-1],
);

    always_comb begin
        // Initialize output with zeros
        for (int jC = 0; jC < C; jC = jC + 1) begin
            for (int jiHP_row = 0; jiHP_row < (iH + 2*P); jiHP_row = jiHP_row + 1) begin
                for (int jiHP_col = 0; jiHP_col < (iH + 2*P); jiHP_col = jiHP_col + 1) begin
                    // Check if current position is in the padding region
                    if ((jiHP_row >= P) && (jiHP_row < (iH + P)) && 
                        (jiHP_col >= P) && (jiHP_col < (iH + P))) begin
                        // Copy value from input ifmap
                        ifmap_zeropad[jC][jiHP_row][jiHP_col] = ifmap[jC][jiHP_row-P][jiHP_col-P];
                    end 
                    else begin
                        // Zero padding
                        ifmap_zeropad[jC][jiHP_row][jiHP_col] = {BW{1'b0}};
                    end
                end
            end
        end
    end
    
endmodule
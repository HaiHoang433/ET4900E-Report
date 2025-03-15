// Purpose: Rearrange 1 ifmap matrix to be capable of GEMM
// Note: This module NEEDS filter information (wH)

module ifmapRearrange #(
    parameter C,    // number of ifmap channels for 1 CNN layer
    parameter iH,   // size of ifmap for 1 CNN layer
    parameter wH,   // size of filters in 1 CNN layer
    parameter P,    // zero-padding size for ifmap for 1 CNN layer
    parameter S,    // stride
    parameter BW    // Bfloat16 format
) (
    input [BW-1:0] ifmap_zeropad[0:C-1][0:(iH+2*P)-1][0:(iH+2*P)-1],
    output reg [BW-1:0] ifmap_rearranged[0:C*wH*wH-1][0:oH*oH-1]
);

localparam oH = (iH - wH + 2*P)/S + 1;

genvar joCol, jC, jwH_row, jwH_col;

generate
for (joCol = 0; joCol < oH*oH; joCol = joCol + 1)
    // Calculate (x_start, y_start) - coordinate of left-up-most ifmap_zeropad to be extracted
    localparam i = joCol / oH;
    localparam j = joCol % oH;
    localparam x_start = i * S;
    localparam y_start = j * S;

    // Iterate over each channel and window position
    for (jC = 0; jC < C; jC = jC + 1)
        for (jwH_row = 0; jwH_row < wH; jwH_row = jwH_row + 1)
            for (jwH_col = 0; jwH_col < wH; jwH_col = jwH_col + 1)
                // Calculate input coordinates of the ifmap_zeropad
                localparam x_ifmap_zeropad = x_start + jwH_row;
                localparam y_ifmap_zeropad = y_start + jwH_col;

                // Calculate output row
                localparam joRow = jC * wH * wH + jwH_row * wH + jwH_col;

                // Assign value
                always_comb begin
                    ifmap_rearranged[joRow][joCol] = ifmap_zeropad[jC][x_ifmap_zeropad][y_ifmap_zeropad];
                end
            end
        end
    end
end
endgenerate

endmodule
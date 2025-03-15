module ofmapDearrange #(
    parameter K,    // number of filters in 1 CNN layer
    parameter iH,   // size of ifmap for 1 CNN layer
    parameter wH,   // size of filters in 1 CNN layer
    parameter P,    // zero-padding size for ifmap for 1 CNN layer
    parameter S,    // stride
    parameter BW    // Bfloat16 format
) (
    input [BW-1:0] ofmap_rearranged[0:K-1][0:oH*oH-1],
    output reg [BW-1:0] ofmap[0:K-1][0:oH-1][0:oH-1]
);

localparam oH = (iH - wH + 2*P)/S + 1;

integer row, col;
integer rowOfmap, colOfmap;
for (row = 0; row < K; row = row + 1) begin
    for(col = 0; col < oH*oH; col = col + 1) begin
        rowOfmap = col / oH;
        colOfmap = col % oH;
        ofmap[row][rowOfmap][colOfmap] = ofmap_rearranged[row][col];
    end
end

endmodule
// Interconnection

module topLayerCal #(
    parameter C,    // number of ifmap channels for 1 CNN layer
    parameter K,    // number of filters in 1 CNN layer
    parameter iH,   // size of ifmap for 1 CNN layer
    parameter wH,   // size of filters in 1 CNN layer
    parameter P,    // zero-padding size for ifmap for 1 CNN layer
    parameter S,    // stride
    parameter BW    // Bfloat16 format
) (
    input [BW-1:0] iWeight[0:K-1][0:C-1][0:wH-1][0:wH-1],
    input [BW-1:0] ifmap[0:C-1][0:iH-1][0:iH-1],
    output [BW-1:0] ofmap[0:K-1][0:oH-1][0:oH-1]
);

localparam oH = (iH - wH + 2*P)/S + 1;

wire [BW-1:0] iWeight_rearranged[0:K-1][0:C*wH*wH-1];
wire [BW-1:0] ifmap_zeropad[0:C-1][0:(iH+2*P)-1][0:(iH+2*P)-1];
wire [BW-1:0] ifmap_rearranged[0:C*wH*wH-1][0:oH*oH-1];
wire [BW-1:0] oRes [0:K-1][0:oH*oH-1];
wire oFinishedSystolicArray;

weightRearrange #(.K(K), .C(C), .wH(wH), .BW(BW)) weightRearrange_inst(
    .iWeight(iWeight),
    .iWeight_rearranged(iWeight_rearranged)
);

zeroPadding #(.C(C), .iH(iH), .P(P), .BW(BW)) zeroPadding_inst(
    .ifmap(ifmap),
    .ifmap_zeropad(ifmap_zeropad)
);

ifmapRearrange #(.C(C), .iH(iH), .wH(wH), .P(P), .S(S), .BW(BW)) ifmapRearrange_inst(
    .ifmap_zeropad(ifmap_zeropad),
    .ifmap_rearranged(ifmap_rearranged)
);

topSystolicArray #(.BW(BW), .M(K), .N(C*wH*wH), .P(oH*oH)) topSystolicArray_inst(
    .clk(clk), 
    .rst_n(rst_n), 
    .iRow(iWeight_rearranged),
    .iCol(ifmap_rearranged),
    .oRes(oRes),
    .oFinishedSystolicArray(oFinishedSystolicArray)
);

always_comb begin
    if(oFinishedSystolicArray) begin
        ofmapDearrange #(.K(K), .iH(iH), .wH(wH), .P(P), .S(S), .BW(BW)) ofmapDearrange_inst(
            .ofmap_rearranged(oRes),
            .ofmap(ofmap)
        );
    end
end
    
endmodule
// All elements of filters and feature maps share the same bitwidth
// Mostly used BF16 & Implicit (BFloat16) = Sign-bit + 8-b Exponent + 7-b Fraction
// All below BRAMs are for one corresponding CNN layer only

module bramWeight #(
    parameter K = 10,   // number of filters in 1 CNN layer
    parameter C = 3,    // number of filter channels in 1 CNN layer
    parameter wH = 5,   // size of filters in 1 CNN layer
    parameter BW = 16   // Bfloat16 format
) (
    input clk, // posedge-active
    input rst_n, // negedge-active
    input write_en,
    input [BW-1:0] iData,
    output reg [BW-1:0] oData[0:K-1][0:C-1][0:wH-1][0:wH-1], // Storage
    output reg storageFull // Flag
);

localparam TOTAL_ELEMENTS = K * C * wH * wH; // total no of elements of K filters for 1 corresponding CNN layer

integer jK, jC, jwH_row, jwH_col;
integer counter, remainder;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        // Outputs
        oData = {(TOTAL_ELEMENTS*BW){1'b0}};
        storageFull = 1'b0;

        // Integers
        jK = 0;
        jC = 0;
        jwH_row = 0;
        jwH_col = 0;
        counter = 0;
        remainder = 0;
    end
    else begin
        if(write_en && !storageFull) begin
            // Calculate 4D indices from counter
            jK          = counter / (C * wH * wH);
            remainder   = counter % (C * wH * wH);
            jC          = remainder / (wH * wH);
            remainder   = remainder % (wH * wH);
            jwH_row     = remainder / wH;
            jwH_col     = remainder % wH;

            // Assign input to current position
            oData[jK][jC][jwH_row][jwH_col] = iData;

            // Update counter
            counter = counter + 1;

            storageFull = (counter == TOTAL_ELEMENTS) ? (1'b1) : (1'b0);
        end
    end
end
    
endmodule

module bramIfmap #(
    parameter C = 3,        // number of ifmap channels of 1 CNN layer
    parameter iH = 32,      // size of ifmap of 1 CNN layer
    parameter BW = 16       // Bfloat16 format
) (
    input clk, // posedge-active
    input rst_n, // negedge-active
    input write_en,
    input [BW-1:0] iData,
    output reg [BW-1:0] oData[0:C-1][0:iH-1][0:iH-1], // Storage
    output reg storageFull // Flag
);

localparam TOTAL_ELEMENTS = C * iH * iH; // total no of elements of 1 ifmap of 1 corresponding CNN layer

integer jC, jiH_row, jiH_col;
integer counter, remainder;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        // Outputs
        oData = {(TOTAL_ELEMENTS*BW){1'b0}};
        storageFull = 1'b0;

        // Integers
        jC = 0;
        jiH_row = 0;
        jiH_col = 0;
        counter = 0;
        remainder = 0;
    end
    else begin
        if(write_en && !storageFull) begin
            // Calculate 3D indices from counter
            jC          = counter / (iH * iH);
            remainder   = counter % (iH * iH);
            jiH_row     = remainder / iH;
            jiH_col     = remainder % iH;

            // Assign input to current position
            oData[jC][jiH_row][jiH_col] = iData;

            // Update counter
            counter = counter + 1;

            storageFull = (counter == TOTAL_ELEMENTS) ? (1'b1) : (1'b0);
        end
    end
end

endmodule

module bramOfmap #(
    parameter K = 3,        // number of ofmap channels of 1 CNN layer
    parameter oH = 32,      // size of ofmap of 1 CNN layer
    parameter BW = 16       // Bfloat16 format
) (
    input clk, // posedge-active
    input rst_n, // negedge-active
    input write_en,
    input [BW-1:0] iData,
    output reg [BW-1:0] oData[0:K-1][0:oH-1][0:oH-1], // Storage
    output reg storageFull // Flag
);

localparam TOTAL_ELEMENTS = K * oH * oH; // total no of elements of 1 ofmap of 1 corresponding CNN layer

integer jK, joH_row, joH_col;
integer counter, remainder;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        // Outputs
        oData = {(TOTAL_ELEMENTS*BW){1'b0}};
        storageFull = 1'b0;

        // Integers
        jK = 0;
        joH_row = 0;
        joH_col = 0;
        counter = 0;
        remainder = 0;
    end
    else begin
        if(write_en && !storageFull) begin
            // Calculate 3D indices from counter
            jK          = counter / (oH * oH);
            remainder   = counter % (oH * oH);
            joH_row     = remainder / oH;
            joH_col     = remainder % oH;

            // Assign input to current position
            oData[jK][joH_row][joH_col] = iData;

            // Update counter
            counter = counter + 1;

            storageFull = (counter == TOTAL_ELEMENTS) ? (1'b1) : (1'b0);
        end
    end
end
    
endmodule
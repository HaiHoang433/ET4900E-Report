module rearrangeArray #(
    parameter BW = 8, 
    parameter N = 5
) (
    input clk, // posedge-triggered
    input rst_n, // negedge-triggered
    input [BW-1:0] iRow [0:N-1][0:N-1],
    input [BW-1:0] iCol [0:N-1][0:N-1],
    output reg [BW-1:0] oRow [0:N-1],
    output reg [BW-1:0] oCol [0:N-1],
    output reg oFinishedRearranging
);

reg [BW-1:0] iRow_rearranged [0:N-1][0:2*N-2];
reg [BW-1:0] iCol_rearranged [0:N-1][0:2*N-2];

integer i, j, k;
reg [BW-1:0] tempRow [0:2*N-2];  
reg [BW-1:0] tempCol [0:2*N-2];

// Rearranging iRow into iRow_rearranged
always @(*) begin
    for (i = 0; i < N; i = i + 1) begin
        // Initialize with zeros
        for (k = 0; k <= 2*N-2; k = k + 1)
            tempRow[k] = {BW{1'b0}};

        // Copy actual row data to the correct position
        for (k = 0; k < N; k = k + 1)
            tempRow[i + k] = iRow[i][k];

        // Store in rearranged array
        for (k = 0; k <= 2*N-2; k = k + 1)
            iRow_rearranged[i][k] = tempRow[k];
    end
end

// First transpose the iCol matrix. Then rearranging transposed iCol into iCol_rearranged

always @(*) begin
    for (j = 0; j < N; j = j + 1) begin
        // Initialize with zeros
        for (k = 0; k <= 2*N-2; k = k + 1)
            tempCol[k] = {BW{1'b0}};

        // Copy actual column data to the correct position
        for (k = 0; k < N; k = k + 1)
            tempCol[j + k] = iCol[k][j]; // Transposed iCol

        // Store in rearranged array
        for (k = 0; k <= 2*N-2; k = k + 1)
            iCol_rearranged[j][k] = tempCol[k];
    end
end

// Sequential logic for output
integer cnt;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
        oFinishedRearranging <= 1'b0;
        for (i = 0; i < N; i = i + 1) begin
            oRow[i] <= {BW{1'b0}};
            oCol[i] <= {BW{1'b0}};
        end
    end else begin
        if (cnt <= 2*N-2) begin
            for (i = 0; i < N; i = i + 1) begin
                oRow[i] <= iRow_rearranged[i][cnt];
                oCol[i] <= iCol_rearranged[i][cnt];
            end
            cnt <= cnt + 1;
        end
        else begin
            oFinishedRearranging <= 1'b1;
            for (i = 0; i < N; i = i + 1) begin
                oRow[i] <= {BW{1'b0}};
                oCol[i] <= {BW{1'b0}};
            end 
        end
    end
end

endmodule
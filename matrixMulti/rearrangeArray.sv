// M x N * N x P

module rearrangeArray #(
    parameter BW = 16,  // Bfloat16
    parameter M = 3, 
    parameter N = 4,
    parameter P = 5
) (
    input clk, // posedge-triggered
    input rst_n, // negedge-triggered
    input [BW-1:0] iRow [0:M-1][0:N-1], // M x (M+N-1) => M x sizeMiddle
    input [BW-1:0] iCol [0:N-1][0:P-1], // (N+P-1) x P => sizeMiddle x P
    output reg [BW-1:0] oRow [0:M-1],
    output reg [BW-1:0] oCol [0:P-1],
    output reg oFinishedRearranging
);

localparam sizeMiddle = (M+N-1 > N+P-1) : (M+N-1) ? (N+P-1);

reg [BW-1:0] iRow_rearranged [0:M-1][0:sizeMiddle-1];
reg [BW-1:0] iCol_rearranged [0:P-1][0:sizeMiddle-1];

integer i, j, k;
reg [BW-1:0] tempRow [0:sizeMiddle-1];
reg [BW-1:0] tempCol [0:sizeMiddle-1];

// Rearranging iRow into iRow_rearranged
always_comb begin
    for (i = 0; i < M; i = i + 1) begin
        // Initialize with zeros
        for (k = 0; k < sizeMiddle; k = k + 1)
            tempRow[k] = {BW{1'b0}};

        // Copy actual row data to the correct position
        for (k = 0; k < N; k = k + 1)
            tempRow[i + k] = iRow[i][k];

        // Store in rearranged array
        for (k = 0; k < sizeMiddle; k = k + 1)
            iRow_rearranged[i][k] = tempRow[k];
    end
end

// Rearranging transposed iCol into iCol_rearranged
always_comb begin
    for (j = 0; j < P; j = j + 1) begin
        // Initialize with zeros
        for (k = 0; k < sizeMiddle; k = k + 1)
            tempCol[k] = {BW{1'b0}};

        // Copy transposed column data to the correct position
        for (k = 0; k < N; k = k + 1)
            tempCol[j + k] = iCol[k][j]; // Transposed iCol

        // Store in rearranged array
        for (k = 0; k < sizeMiddle; k = k + 1)
            iCol_rearranged[j][k] = tempCol[k];
    end
end

// Sequential logic for output
integer cnt;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
        oFinishedRearranging <= 1'b0;
        for (i = 0; i < M; i = i + 1) oRow[i] <= {BW{1'b0}};
        for (i = 0; i < P; i = i + 1) oCol[i] <= {BW{1'b0}};
    end 
    else begin
        if (cnt <= sizeMiddle - 1) begin
            for (i = 0; i < M; i = i + 1) oRow[i] <= iRow_rearranged[i][cnt];
            for (i = 0; i < P; i = i + 1) oCol[i] <= iCol_rearranged[i][cnt];
            cnt = cnt + 1;
        end else begin
            oFinishedRearranging <= 1'b1;
            for (i = 0; i < M; i = i + 1) oRow[i] <= {BW{1'b0}};
            for (i = 0; i < P; i = i + 1) oCol[i] <= {BW{1'b0}};
        end
    end
end

endmodule
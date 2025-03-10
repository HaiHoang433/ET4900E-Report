module tb_rearrangeArray;

localparam BW = 8;
localparam N = 5;

reg clk;
reg rst_n;
reg [BW-1:0] iRow [0:N-1][0:N-1];
reg [BW-1:0] iCol [0:N-1][0:N-1];
reg [BW-1:0] oRow [0:N-1];
reg [BW-1:0] oCol [0:N-1];
reg oFinishedRearranging;

// Instantiate top module
rearrangeArray #(.BW(BW), .N(N)) rearrangeArray_dut (
    .clk(clk),
    .rst_n(rst_n),
    .iRow(iRow),
    .iCol(iCol),
    .oRow(oRow),
    .oCol(oCol),
    .oFinishedRearranging(oFinishedRearranging)
);

// Define period of clk. Period: 10 time units
always begin
    #5 clk = ~clk;
end

// Initialize clk and rst_n
initial begin
    clk = 1'b0;
    rst_n = 1'b0; // Initial reset
    #53 rst_n = 1; // Release reset after 53 time units
end

integer i, j;

// Process
initial begin
    for(i = 0; i < N; i = i + 1) begin
        for(j = 0; j < N; j = j + 1) begin
            iRow[i][j] = i*N + j;
            iCol[i][j] = i*N + j + 100;
        end
    end
    #2004 $stop;
end
    
endmodule
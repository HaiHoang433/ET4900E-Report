`timescale 1ns / 1ps

module tb_topSystolicArray;

localparam BW = 16;
localparam N = 5;

// Variables occur in waveform
reg clk; // posedge-triggered
reg rst_n; // negedge-triggered
reg [BW-1:0] iRow [0:N-1][0:N-1];
reg [BW-1:0] iCol [0:N-1][0:N-1];
wire [N*2*BW-1:0] oRes [0:N-1][0:N-1];
wire oFinishedSystolicArray;

// Instantiation of top module
topSystolicArray #(.BW(BW), .N(N)) topSystolicArray_dut (
    .clk(clk), 
    .rst_n(rst_n), 
    .iRow(iRow), 
    .iCol(iCol), 
    .oRes(oRes),
    .oFinishedSystolicArray(oFinishedSystolicArray)
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
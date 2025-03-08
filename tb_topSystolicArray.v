// `timescale 1ns / 1ps

module tb_topSystolicArray;

    parameter N = 4;
    parameter BITWIDTH = 8;

    reg clk;
    reg reset;
    reg [N*N*BITWIDTH-1:0] iRow;
    reg [N*N*BITWIDTH-1:0] iCol;
    wire [N*N*2*BITWIDTH-1:0] oRes;

    topSystolicArray #(.N(N), .BITWIDTH(BITWIDTH)) uut (
        .clk(clk),
        .reset(reset),
        .iRow(iRow),
        .iCol(iCol),
        .oRes(oRes)
    );

    always #5 clk = ~clk; // 10 ns clock period

    initial begin
        clk = 0;
        reset = 1;
        iRow = 0;
        iCol = 0;
        #20 reset = 0;

        // Apply test data
        iRow = 128'h123456789abcdef10;
        iCol = 80'h1234432156788765;
        #100; // Wait for computation
        $display("oRes = %h", oRes);
        #20;
        $finish;
    end

endmodule

// only interconnection of rearrangeArray module and systolicArray module
// M x N * N x P

module topSystolicArray #(
    parameter BW = 16,  // Bfloat16
    parameter M = 3, 
    parameter N = 4,
    parameter P = 5
) (
    input clk, // posedge-triggered
    input rst_n, // negedge-triggered
    input [BW-1:0] iRow[0:M-1][0:N-1], // wire
    input [BW-1:0] iCol[0:N-1][0:P-1], // wire
    output [BW-1:0] oRes [0:M-1][0:P-1], // wire
    output reg oFinishedSystolicArray // wire
);

wire [BW-1:0] oRow_wire[0:M-1];
wire [BW-1:0] oCol_wire[0:P-1];

rearrangeArray #(.BW(BW), .M(M), .N(N), .P(P)) rearrangeArray_inst
    (.clk(clk), .rst_n(rst_n), .iRow(iRow), .iCol(iCol), .oRow(oRow_wire), .oCol(oCol_wire));

systolicArray #(.BW(BW), .M(M), .N(N), .P(P)) systolicArray_inst
    (.clk(clk), .rst_n(rst_n), .iRow(oRow_wire), .iCol(oCol_wire), .oRes(oRes));

// Determine oFinishedSystolicArray based of the number of posedge required
integer cnt;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        oFinishedSystolicArray <= 1'b0;
        cnt <= 0;
    end 
    else begin
        cnt <= cnt + 1;
        if(cnt == M+N+P-2) oFinishedSystolicArray <= 1'b1;
    end
end

endmodule
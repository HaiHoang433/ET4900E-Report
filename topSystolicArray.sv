// only interconnection of rearrangeArray module and systolicArray module

module topSystolicArray #(
    parameter BW = 8,
    parameter N = 5
) (
    input clk, // posedge-triggered
    input rst_n, // negedge-triggered
    input [BW-1:0] iRow[0:N-1][0:N-1], // wire
    input [BW-1:0] iCol[0:N-1][0:N-1], // wire
    output [N*2*BW-1:0] oRes [0:N-1][0:N-1], // wire
    output reg oFinishedSystolicArray // wire
);

wire [BW-1:0] oRow_wire[0:N-1];
wire [BW-1:0] oCol_wire[0:N-1];

rearrangeArray #(.BW(BW), .N(N)) rearrangeArray_inst
    (.clk(clk), .rst_n(rst_n), .iRow(iRow), .iCol(iCol), .oRow(oRow_wire), .oCol(oCol_wire));

systolicArray #(.BW(BW), .N(N)) systolicArray_inst
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
        if(cnt == 3*N - 2) oFinishedSystolicArray <= 1'b1;
    end
end

endmodule
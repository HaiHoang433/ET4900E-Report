#include <iostream>
#include <fstream>
#include <vector>
#include <bitset>

void generateVerilogTestbench(int N, int BITWIDTH, const std::vector<std::vector<int>> &A, const std::vector<std::vector<int>> &B) {
    std::ofstream file("tb_topSystolicArray.v");
    if (!file.is_open()) {
        std::cerr << "Error: Could not open file." << std::endl;
        return;
    }

    // file << "`timescale 1ns / 1ps\n";
    file << "\n";
    file << "module tb_topSystolicArray;\n";
    file << "\n";
    file << "    parameter N = " << N << ";\n";
    file << "    parameter BITWIDTH = " << BITWIDTH << ";\n";
    file << "\n";
    file << "    reg clk;\n";
    file << "    reg reset;\n";
    file << "    reg [N*N*BITWIDTH-1:0] iRow;\n";
    file << "    reg [N*N*BITWIDTH-1:0] iCol;\n";
    file << "    wire [N*N*2*BITWIDTH-1:0] oRes;\n";
    file << "\n";
    file << "    topSystolicArray #(.N(N), .BITWIDTH(BITWIDTH)) uut (\n";
    file << "        .clk(clk),\n";
    file << "        .reset(reset),\n";
    file << "        .iRow(iRow),\n";
    file << "        .iCol(iCol),\n";
    file << "        .oRes(oRes)\n";
    file << "    );\n";
    file << "\n";
    file << "    always #5 clk = ~clk; // 10 ns clock period\n";
    file << "\n";
    file << "    initial begin\n";
    file << "        clk = 0;\n";
    file << "        reset = 1;\n";
    file << "        iRow = 0;\n";
    file << "        iCol = 0;\n";
    file << "        #20 reset = 0;\n";
    file << "\n";
    file << "        // Apply test data\n";

    file << "        iRow = " << N * N * BITWIDTH << "'h";
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            file << std::hex << (A[i][j] & ((1 << BITWIDTH) - 1));
        }
    }
    file << ";\n";

    file << "        iCol = " << N * N * BITWIDTH << "'h";
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            file << std::hex << (B[i][j] & ((1 << BITWIDTH) - 1));
        }
    }
    file << ";\n";

    file << "        #100; // Wait for computation\n";
    file << "        $display(\"oRes = %h\", oRes);\n";
    file << "        #20;\n";
    file << "        $finish;\n";
    file << "    end\n";
    file << "\n";
    file << "endmodule\n";
    file.close();
    std::cout << "Testbench written to tb_topSystolicArray.v" << std::endl;
}

int main() {
    int N, BITWIDTH;
    std::cout << "Enter N (Matrix Size): ";
    std::cin >> N;
    std::cout << "Enter BITWIDTH: ";
    std::cin >> BITWIDTH;

    std::vector<std::vector<int>> A(N, std::vector<int>(N)), B(N, std::vector<int>(N)), C(N, std::vector<int>(N));

    std::cout << "Enter matrix A (NxN integers):\n";
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            std::cin >> A[i][j];

    std::cout << "Enter matrix B (NxN integers):\n";
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            std::cin >> B[i][j];

    // Compute matrix multiplication C = A * B
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            C[i][j] = 0;
            for (int k = 0; k < N; ++k) {
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }

    // Print the result matrix
    std::cout << "Resulting Matrix (A * B):\n";
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            std::cout << C[i][j] << " ";
        }
        std::cout << "\n";
    }

    // Generate testbench
    generateVerilogTestbench(N, BITWIDTH, A, B);

    return 0;
}
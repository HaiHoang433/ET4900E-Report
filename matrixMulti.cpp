#include <iostream>
#include <vector>

using namespace std;

// Function to multiply two NxN matrices
vector<vector<int>> multiplyMatrices(const vector<vector<int>>& A, const vector<vector<int>>& B, int N) {
    vector<vector<int>> result(N, vector<int>(N, 0));

    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            for (int k = 0; k < N; ++k) {
                result[i][j] += A[i][k] * B[k][j];
            }
        }
    }

    return result;
}

int main() {
    int N;
    cout << "Enter the size of the matrices (N): ";
    cin >> N;

    vector<vector<int>> A(N, vector<int>(N));
    vector<vector<int>> B(N, vector<int>(N));

    cout << "Elements of matrix A:" << endl;
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            A[i][j] = i*N + j;
            cout << A[i][j] << " ";
        }
        cout << endl;
    }

    cout << endl;

    cout << "Enter the elements of matrix B:" << endl;
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            B[i][j] = i*N + j + 100;
            cout << B[i][j] << " ";
        }
        cout << endl;
    }

    cout << endl;

    vector<vector<int>> result = multiplyMatrices(A, B, N);

    cout << "Resultant matrix:" << endl;
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            cout << result[i][j] << " ";
        }
        cout << endl;
    }

    return 0;
}

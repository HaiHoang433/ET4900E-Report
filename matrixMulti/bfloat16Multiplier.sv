module bfloat16Multiplier (
    input  [15:0] a,
    input  [15:0] b,
    output [15:0] result
);

    // Unpack Bfloat16 components
    logic sign_a, sign_b;
    logic [7:0] exp_a, exp_b;
    logic [6:0] mantissa_a, mantissa_b;
    assign sign_a = a[15];
    assign exp_a = a[14:7];
    assign mantissa_a = a[6:0];
    assign sign_b = b[15];
    assign exp_b = b[14:7];
    assign mantissa_b = b[6:0];

    // Zero detection
    logic a_is_zero, b_is_zero;
    assign a_is_zero = (exp_a == 8'b0) && (mantissa_a == 7'b0);
    assign b_is_zero = (exp_b == 8'b0) && (mantissa_b == 7'b0);
    logic result_is_zero;
    assign result_is_zero = a_is_zero || b_is_zero;

    // Result sign calculation
    logic sign_result;
    assign sign_result = sign_a ^ sign_b;

    // Significand multiplication (including implicit 1)
    logic [7:0] sig_a, sig_b;
    logic [15:0] product;
    assign sig_a = {1'b1, mantissa_a};
    assign sig_b = {1'b1, mantissa_b};
    assign product = sig_a * sig_b;

    // Normalization check
    logic shift;
    assign shift = (product[15:14] != 2'b01);

    // Exponent calculation
    logic [31:0] sum_exp;
    assign sum_exp = exp_a + exp_b - 127 + shift;

    // Result components
    logic [7:0] new_exp;
    logic [6:0] mantissa_result;

    always_comb begin
        if (result_is_zero) begin
            new_exp = 8'h00;
            mantissa_result = 7'b0;
        end
        else if (sum_exp > 255) begin
            new_exp = 8'hff;  // Infinity
            mantissa_result = 7'b0;
        end
        else if (sum_exp < 0) begin
            new_exp = 8'h00;  // Zero
            mantissa_result = 7'b0;
        end
        else begin
            new_exp = sum_exp[7:0];
            
            if (shift) begin
                logic [15:0] product_shifted = product >> 1;
                mantissa_result = product_shifted[14:8];
            end
            else begin
                mantissa_result = product[14:8];
            end
        end
    end

    // Repack Bfloat16 result
    assign result = {sign_result, new_exp, mantissa_result};

endmodule
module bfloat16Add (
    input  [15:0] a,
    input  [15:0] b,
    output [15:0] result
);

// Unpack components
logic sa, sb;
logic [7:0] exp_a, exp_b;
logic [7:0] sig_a, sig_b;

// Special case flags
logic is_nan_a, is_nan_b;
logic is_inf_a, is_inf_b;
logic is_zero_a, is_zero_b;

// Result components
logic s_result;
logic [7:0] exp_result;
logic [7:0] sig_result;

// Unpack inputs
assign sa = a[15];
assign exp_a = a[14:7];
assign sig_a = a[6:0];

assign sb = b[15];
assign exp_b = b[14:7];
assign sig_b = b[6:0];

// Special case detection
assign is_nan_a = (exp_a == 8'hFF) && (sig_a != 7'b0);
assign is_inf_a = (exp_a == 8'hFF) && (sig_a == 7'b0);
assign is_zero_a = (exp_a == 8'h00) && (sig_a == 7'b0);

assign is_nan_b = (exp_b == 8'hFF) && (sig_b != 7'b0);
assign is_inf_b = (exp_b == 8'hFF) && (sig_b == 7'b0);
assign is_zero_b = (exp_b == 8'h00) && (sig_b == 7'b0);

// Handle special cases
always_comb begin
    // Default values
    s_result = sa ^ sb;
    exp_result = exp_a;
    sig_result = sig_a;

    // NaN handling
    if (is_nan_a || is_nan_b) begin
        s_result = 1'b0;
        exp_result = 8'hFF;
        sig_result = 7'b1;
    end
    // Inf handling
    else if (is_inf_a && is_inf_b) begin
        if (sa == sb) begin
            s_result = sa;
            exp_result = 8'hFF;
            sig_result = 7'b0;
        end else begin
            s_result = 1'b0;
            exp_result = 8'hFF;
            sig_result = 7'b1;
        end
    end
    else if (is_inf_a || is_inf_b) begin
        s_result = is_inf_a ? sa : sb;
        exp_result = 8'hFF;
        sig_result = 7'b0;
    end
    // Zero handling
    else if (is_zero_a && is_zero_b) begin
        s_result = 1'b0;
        exp_result = 8'h00;
        sig_result = 7'b0;
    end
    else if (is_zero_a) begin
        s_result = sb;
        exp_result = exp_b;
        sig_result = sig_b;
    end
    else if (is_zero_b) begin
        s_result = sa;
        exp_result = exp_a;
        sig_result = sig_a;
    end
    // Regular addition
    else begin
        // Significand extension (with hidden bit)
        logic [15:0] sig_a_ext = {1'b1, sig_a, 8'b0};
        logic [15:0] sig_b_ext = {1'b1, sig_b, 8'b0};
        
        // Exponent alignment
        logic [7:0] exp_diff = exp_a > exp_b ? exp_a - exp_b : exp_b - exp_a;
        logic [15:0] shifted_sig;
        
        if (exp_a > exp_b) begin
            shifted_sig = sig_b_ext >> exp_diff;
            sig_a_ext = sig_a_ext + shifted_sig;
            exp_result = exp_a;
        end else begin
            shifted_sig = sig_a_ext >> exp_diff;
            sig_b_ext = sig_b_ext + shifted_sig;
            exp_result = exp_b;
        end
        
        // Normalization (simplified)
        logic [15:0] sum = (sa == sb) ? (sig_a_ext + sig_b_ext) : (sig_a_ext - sig_b_ext);
        logic [3:0] leading_zeros;
        
        // Leading zero count (simplified)
        for (int i = 0; i < 16; i++) begin
            if (sum[i]) begin
                leading_zeros = 15 - i;
                break;
            end
        end
        
        // Normalize and round
        logic [7:0] normalized_sig = sum >> leading_zeros;
        exp_result -= leading_zeros;
        
        // Rounding (simplified)
        logic round_bit = sum[6];
        logic sticky_bit = |sum[5:0];
        logic increment = round_bit | sticky_bit;
        
        sig_result = normalized_sig[7:1] + increment;
        exp_result += increment ? 1 : 0;
        
        // Handle overflow/underflow
        if (exp_result >= 255) begin
            s_result = sa;
            exp_result = 8'hFF;
            sig_result = 7'b0;
        end
    end
end

// Pack result
assign result = {s_result, exp_result, sig_result};

endmodule
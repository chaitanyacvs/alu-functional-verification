module alu_assertions #(
    parameter int WIDTH = 32
) (
    input logic             clk,
    input logic             reset_n,
    input logic [WIDTH-1:0] a,
    input logic [WIDTH-1:0] b,
    input logic [3:0]       op,
    input logic [WIDTH-1:0] result,
    input logic             zero,
    input logic             carry,
    input logic             overflow
);

    localparam int SHAMT_WIDTH = $clog2(WIDTH);

    logic [WIDTH:0] add_ext;

    always_comb begin
        add_ext = {1'b0, a} + {1'b0, b};
    end

    // Zero flag must agree with the result for every opcode.
    property p_zero_flag;
        @(posedge clk) disable iff (!reset_n)
        zero == (result == '0);
    endproperty

    assert property (p_zero_flag)
        else $error("SVA: zero flag mismatch");

    // ADD
    property p_add_result;
        @(posedge clk) disable iff (!reset_n)
        (op == 4'h0) |-> (
            result == a + b &&
            carry == add_ext[WIDTH] &&
            overflow == (
                (~(a[WIDTH-1] ^ b[WIDTH-1])) &
                (result[WIDTH-1] ^ a[WIDTH-1])
            )
        );
    endproperty

    assert property (p_add_result)
        else $error("SVA: ADD result/flags mismatch");

    // SUB: carry=1 means no unsigned borrow.
    property p_sub_result;
        @(posedge clk) disable iff (!reset_n)
        (op == 4'h1) |-> (
            result == a - b &&
            carry == (a >= b) &&
            overflow == (
                (a[WIDTH-1] ^ b[WIDTH-1]) &
                (result[WIDTH-1] ^ a[WIDTH-1])
            )
        );
    endproperty

    assert property (p_sub_result)
        else $error("SVA: SUB result/flags mismatch");

    property p_and_result;
        @(posedge clk) disable iff (!reset_n)
        (op == 4'h2) |-> (result == (a & b));
    endproperty

    assert property (p_and_result)
        else $error("SVA: AND mismatch");

    property p_or_result;
        @(posedge clk) disable iff (!reset_n)
        (op == 4'h3) |-> (result == (a | b));
    endproperty

    assert property (p_or_result)
        else $error("SVA: OR mismatch");

    property p_xor_result;
        @(posedge clk) disable iff (!reset_n)
        (op == 4'h4) |-> (result == (a ^ b));
    endproperty

    assert property (p_xor_result)
        else $error("SVA: XOR mismatch");

    property p_sll_result;
        @(posedge clk) disable iff (!reset_n)
        (op == 4'h5) |->
        (result == (a << b[SHAMT_WIDTH-1:0]));
    endproperty

    assert property (p_sll_result)
        else $error("SVA: SLL mismatch");

    property p_srl_result;
        @(posedge clk) disable iff (!reset_n)
        (op == 4'h6) |->
        (result == (a >> b[SHAMT_WIDTH-1:0]));
    endproperty

    assert property (p_srl_result)
        else $error("SVA: SRL mismatch");

    logic [WIDTH-1:0] expected_sra;

    always_comb begin
        expected_sra = $unsigned(
            $signed(a) >>> b[SHAMT_WIDTH-1:0]
        );
    end

    property p_sra_result;
        @(posedge clk) disable iff (!reset_n)
        (op == 4'h7) |-> (result == expected_sra);
    endproperty

    assert property (p_sra_result)
        else $error(
            "SVA: SRA mismatch a=%h b=%h result=%h expected=%h",
            a, b, result, expected_sra
        );

    property p_slt_result;
        @(posedge clk) disable iff (!reset_n)
        (op == 4'h8) |->
        (result == ($signed(a) < $signed(b) ? 1 : 0));
    endproperty

    assert property (p_slt_result)
        else $error("SVA: SLT mismatch");

    property p_sltu_result;
        @(posedge clk) disable iff (!reset_n)
        (op == 4'h9) |-> (result == (a < b ? 1 : 0));
    endproperty

    assert property (p_sltu_result)
        else $error("SVA: SLTU mismatch");

    // Non-arithmetic and invalid operations clear carry/overflow.
    property p_other_flags;
        @(posedge clk) disable iff (!reset_n)
        (op >= 4'h2) |-> (!carry && !overflow);
    endproperty

    assert property (p_other_flags)
        else $error("SVA: unexpected carry/overflow");

    // Unsupported opcodes A-F produce zero result.
    property p_invalid_opcode;
        @(posedge clk) disable iff (!reset_n)
        (op >= 4'hA) |->
        (result == '0 && zero && !carry && !overflow);
    endproperty

    assert property (p_invalid_opcode)
        else $error("SVA: invalid opcode behavior mismatch");

endmodule


`timescale 1ns/1ps

module tb_alu;

    localparam WIDTH = 32;
    localparam RANDOM_TESTS = 1000;

    logic [WIDTH-1:0] a, b;
    logic [3:0] op;
    logic [WIDTH-1:0] result;
    logic zero, carry, overflow;

    integer errors = 0;
    integer tests_run = 0;
    integer i;

    // Functional coverage counters
    integer op_coverage [0:15];
    integer zero_result_coverage = 0;
    integer nonzero_result_coverage = 0;
    integer add_carry_coverage = 0;
    integer add_overflow_coverage = 0;
    integer sub_borrow_coverage = 0;
    integer sub_overflow_coverage = 0;

    logic [32:0] coverage_sum;
    logic [31:0] coverage_difference;

    alu #(.WIDTH(WIDTH)) dut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .zero(zero),
        .carry(carry),
        .overflow(overflow)
    );

    // Independent reference model for the ALU result.
    function automatic [31:0] reference_model(
        input logic [3:0] operation,
        input logic [31:0] x,
        input logic [31:0] y
    );
        begin
            case (operation)
                4'h0: reference_model = x + y;
                4'h1: reference_model = x - y;
                4'h2: reference_model = x & y;
                4'h3: reference_model = x | y;
                4'h4: reference_model = x ^ y;
                4'h5: reference_model = x << y[4:0];
                4'h6: reference_model = x >> y[4:0];
                4'h7: reference_model = $signed(x) >>> y[4:0];
                4'h8: reference_model =
                    ($signed(x) < $signed(y)) ? 32'd1 : 32'd0;
                4'h9: reference_model =
                    (x < y) ? 32'd1 : 32'd0;
                default: reference_model = 32'd0;
            endcase
        end
    endfunction

    task automatic check_transaction(
        input logic [3:0] operation,
        input logic [31:0] x,
        input logic [31:0] y
    );
        logic [31:0] expected;
        logic [32:0] extended_sum;
        logic [31:0] difference;
        logic expected_overflow;
        begin
            a = x;
            b = y;
            op = operation;
            #1;

            expected = reference_model(operation, x, y);
            tests_run = tests_run + 1;

            // Count opcode and result coverage.
            op_coverage[operation] = op_coverage[operation] + 1;

            if (expected == 32'd0)
                zero_result_coverage = zero_result_coverage + 1;
            else
                nonzero_result_coverage = nonzero_result_coverage + 1;

            // Check result against the reference model.
            if (result !== expected) begin
                $display(
                    "FAIL result: test=%0d op=%h a=%h b=%h expected=%h got=%h",
                    tests_run, operation, x, y, expected, result
                );
                errors = errors + 1;
            end

            // Check zero flag.
            if (zero !== (expected == 32'd0)) begin
                $display(
                    "FAIL zero: test=%0d expected=%b got=%b",
                    tests_run, (expected == 32'd0), zero
                );
                errors = errors + 1;
            end

            // Check arithmetic flags and collect flag coverage.
            if (operation == 4'h0) begin
                extended_sum = {1'b0, x} + {1'b0, y};
                expected_overflow =
                    (~(x[31] ^ y[31])) & (expected[31] ^ x[31]);

                if (extended_sum[32])
                    add_carry_coverage = add_carry_coverage + 1;

                if (expected_overflow)
                    add_overflow_coverage = add_overflow_coverage + 1;

                if (carry !== extended_sum[32]) begin
                    $display("FAIL ADD carry: test=%0d", tests_run);
                    errors = errors + 1;
                end

                if (overflow !== expected_overflow) begin
                    $display("FAIL ADD overflow: test=%0d", tests_run);
                    errors = errors + 1;
                end
            end
            else if (operation == 4'h1) begin
                difference = x - y;
                expected_overflow =
                    (x[31] ^ y[31]) & (difference[31] ^ x[31]);

                if (x < y)
                    sub_borrow_coverage = sub_borrow_coverage + 1;

                if (expected_overflow)
                    sub_overflow_coverage = sub_overflow_coverage + 1;

                // For SUB, carry=1 means no unsigned borrow.
                if (carry !== (x >= y)) begin
                    $display("FAIL SUB carry/no-borrow: test=%0d", tests_run);
                    errors = errors + 1;
                end

                if (overflow !== expected_overflow) begin
                    $display("FAIL SUB overflow: test=%0d", tests_run);
                    errors = errors + 1;
                end
            end
            else begin
                if ((carry !== 1'b0) || (overflow !== 1'b0)) begin
                    $display("FAIL unexpected flags: test=%0d", tests_run);
                    errors = errors + 1;
                end
            end
        end
    endtask

    initial begin
        // Initialize opcode coverage counters.
        for (i = 0; i < 16; i = i + 1)
            op_coverage[i] = 0;

        $display("Starting ALU verification...");

        // Directed tests ensure every valid and invalid opcode is exercised.
        check_transaction(4'h0, 32'hFFFF_FFFF, 32'd1);
        check_transaction(4'h0, 32'h7FFF_FFFF, 32'd1);
        check_transaction(4'h0, 32'h7FFF_FFFF, 32'h7FFF_FFFF);
        check_transaction(4'h1, 32'd3, 32'd5);
        check_transaction(4'h1, 32'h8000_0000, 32'd1);
        check_transaction(4'h1, 32'hFFFF_FFFF, 32'hFFFF_FFFF);
        check_transaction(4'h2, 32'hF0F0_F0F0, 32'h0FF0_0FF0);
        check_transaction(4'h3, 32'hF000_0000, 32'h0000_00F0);
        check_transaction(4'h4, 32'hAAAA_AAAA, 32'hFFFF_FFFF);
        check_transaction(4'h5, 32'd1, 32'd4);
        check_transaction(4'h6, 32'h8000_0000, 32'd4);
        check_transaction(4'h7, 32'h8000_0000, 32'd4);
        check_transaction(4'h8, 32'hFFFF_FFFF, 32'd1);
        check_transaction(4'h9, 32'hFFFF_FFFF, 32'd1);

        // Exercise all invalid opcodes (A through F).
        check_transaction(4'hA, 32'd123, 32'd456);
        check_transaction(4'hB, 32'd123, 32'd456);
        check_transaction(4'hC, 32'd123, 32'd456);
        check_transaction(4'hD, 32'd123, 32'd456);
        check_transaction(4'hE, 32'd123, 32'd456);
        check_transaction(4'hF, 32'd123, 32'd456);

        // Randomized testing.
        for (i = 0; i < RANDOM_TESTS; i = i + 1) begin
            check_transaction(
                $random,
                {$random, $random},
                {$random, $random}
            );
        end

        // Print summary.
        $display("");
        $display("========== VERIFICATION SUMMARY ==========");
        $display("Transactions checked: %0d", tests_run);
        $display("Errors: %0d", errors);

        $display("");
        $display("========== OPCODE COVERAGE ===============");
        for (i = 0; i < 10; i = i + 1)
            $display("Opcode %0h: %0d hits", i, op_coverage[i]);

        for (i = 10; i < 16; i = i + 1)
            $display("Invalid opcode %0h: %0d hits", i, op_coverage[i]);

        $display("");
        $display("========== RESULT/FLAG COVERAGE ==========");
        $display("Zero results: %0d", zero_result_coverage);
        $display("Non-zero results: %0d", nonzero_result_coverage);
        $display("ADD carry cases: %0d", add_carry_coverage);
        $display("ADD overflow cases: %0d", add_overflow_coverage);
        $display("SUB borrow cases: %0d", sub_borrow_coverage);
        $display("SUB overflow cases: %0d", sub_overflow_coverage);
        $display("==========================================");

        if (errors == 0)
            $display("PASS: ALU scoreboard verification passed");
        else
            $display("FAIL: ALU scoreboard verification failed");

        $finish;
    end

endmodule


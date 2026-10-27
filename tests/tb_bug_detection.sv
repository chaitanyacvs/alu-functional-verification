
`timescale 1ns/1ps

module tb_bug_detection;

    logic [31:0] a, b;
    logic [3:0] op;
    logic [31:0] result;
    logic zero, carry, overflow;
    logic [31:0] expected;

    integer errors = 0;

    // Use the intentionally faulty ALU.
    alu #(.WIDTH(32)) dut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .zero(zero),
        .carry(carry),
        .overflow(overflow)
    );

    initial begin
        // XOR must produce 0x0000000F.
        a = 32'h0000_00F0;
        b = 32'h0000_00FF;
        op = 4'h4;
        expected = a ^ b;

        #1;

        if (result !== expected) begin
            $display("EXPECTED BUG DETECTED");
            $display("Expected XOR result: %h", expected);
            $display("Buggy ALU result:    %h", result);
        end
        else begin
            $display("ERROR: injected XOR bug was not detected");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("PASS: bug detection test behaved as expected");
        else
            $display("FAIL: bug detection test");

        $finish;
    end

endmodule

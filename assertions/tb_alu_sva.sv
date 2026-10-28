module tb_alu_sva;

    logic clk = 0;
    logic reset_n = 0;
    logic [31:0] a, b;
    logic [3:0] op;
    logic [31:0] result;
    logic zero, carry, overflow;

    integer i, j;

    always #5 clk = ~clk;

    alu #(.WIDTH(32)) dut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .zero(zero),
        .carry(carry),
        .overflow(overflow)
    );

    alu_assertions #(.WIDTH(32)) checks (
        .clk(clk),
        .reset_n(reset_n),
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .zero(zero),
        .carry(carry),
        .overflow(overflow)
    );

    initial begin
        a = 0;
        b = 0;
        op = 0;

        repeat (2) @(negedge clk);
        reset_n = 1;

        // Exercise every opcode, including invalid opcodes.
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 50; j = j + 1) begin
                @(negedge clk);
                op = i;
                a = $urandom;
                b = $urandom;

                // Include arithmetic boundary cases.
                if (j == 0) begin
                    a = 32'h7fffffff;
                    b = 32'h00000001;
                end
                if (j == 1) begin
                    a = 32'hffffffff;
                    b = 32'h00000001;
                end
                if (j == 2) begin
                    a = 32'h80000000;
                    b = 32'h00000001;
                end

                @(posedge clk);
                #1;
            end
        end

        @(negedge clk);
        $display("PASS: ALU SVA regression completed.");
        $finish;
    end

endmodule

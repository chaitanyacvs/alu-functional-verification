
module alu #(
    parameter WIDTH = 32
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic [3:0]       op,
    output logic [WIDTH-1:0] result,
    output logic             zero,
    output logic             carry,
    output logic             overflow
);

    localparam OP_ADD  = 4'h0;
    localparam OP_SUB  = 4'h1;
    localparam OP_AND  = 4'h2;
    localparam OP_OR   = 4'h3;
    localparam OP_XOR  = 4'h4;
    localparam OP_SLL  = 4'h5;
    localparam OP_SRL  = 4'h6;
    localparam OP_SRA  = 4'h7;
    localparam OP_SLT  = 4'h8;
    localparam OP_SLTU = 4'h9;

    logic [WIDTH:0] extended_result;

    always @(*) begin
        result = '0;
        carry = 1'b0;
        overflow = 1'b0;
        extended_result = '0;

        case (op)
            OP_ADD: begin
                extended_result = {1'b0, a} + {1'b0, b};
                result = extended_result[WIDTH-1:0];
                carry = extended_result[WIDTH];
                overflow = (~(a[WIDTH-1] ^ b[WIDTH-1])) &
                           (result[WIDTH-1] ^ a[WIDTH-1]);
            end

            OP_SUB: begin
                result = a - b;
                carry = (a >= b);
                overflow = (a[WIDTH-1] ^ b[WIDTH-1]) &
                           (result[WIDTH-1] ^ a[WIDTH-1]);
            end

            OP_AND: result = a & b;
            OP_OR:  result = a | b;

            // INTENTIONAL BUG: OR used instead of XOR.
            OP_XOR: result = a | b;

            OP_SLL:  result = a << b[$clog2(WIDTH)-1:0];
            OP_SRL:  result = a >> b[$clog2(WIDTH)-1:0];
            OP_SRA:  result = $signed(a) >>> b[$clog2(WIDTH)-1:0];
            OP_SLT:  result = ($signed(a) < $signed(b)) ? 1 : 0;
            OP_SLTU: result = (a < b) ? 1 : 0;

            default: result = '0;
        endcase

        zero = (result == '0);
    end

endmodule

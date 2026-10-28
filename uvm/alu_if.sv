interface alu_if #(parameter int WIDTH = 32) (input logic clk);

    logic [WIDTH-1:0] a;
    logic [WIDTH-1:0] b;
    logic [3:0]       op;
    logic [WIDTH-1:0] result;
    logic             zero;
    logic             carry;
    logic             overflow;

    clocking driver_cb @(negedge clk);
        output a, b, op;
    endclocking

    clocking monitor_cb @(posedge clk);
        input a, b, op;
        input result, zero, carry, overflow;
    endclocking

endinterface

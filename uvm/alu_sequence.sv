class alu_sequence extends uvm_sequence #(alu_transaction);

    `uvm_object_utils(alu_sequence)

    function new(string name = "alu_sequence");
        super.new(name);
    endfunction

    task body();
        alu_transaction tr;

        // Exercise all ten supported ALU operations.
        for (int op_code = 0; op_code < 10; op_code++) begin
            repeat (20) begin
                tr = alu_transaction::type_id::create("tr");

                start_item(tr);
                if (!tr.randomize() with { op == op_code; })
                    `uvm_fatal("RAND", "Transaction randomization failed")
                finish_item(tr);
            end
        end
    endtask

endclass

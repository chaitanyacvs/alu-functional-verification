class alu_transaction extends uvm_sequence_item;

    rand bit [31:0] a;
    rand bit [31:0] b;
    rand bit [3:0]  op;

    bit [31:0] result;
    bit        zero;
    bit        carry;
    bit        overflow;

    `uvm_object_utils_begin(alu_transaction)
        `uvm_field_int(a,        UVM_ALL_ON)
        `uvm_field_int(b,        UVM_ALL_ON)
        `uvm_field_int(op,       UVM_ALL_ON)
        `uvm_field_int(result,   UVM_ALL_ON)
        `uvm_field_int(zero,     UVM_ALL_ON)
        `uvm_field_int(carry,    UVM_ALL_ON)
        `uvm_field_int(overflow, UVM_ALL_ON)
    `uvm_object_utils_end

    constraint valid_opcode_c {
        op inside {[4'h0:4'h9]};
    }

    function new(string name = "alu_transaction");
        super.new(name);
    endfunction

endclass

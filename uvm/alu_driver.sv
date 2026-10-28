class alu_driver extends uvm_driver #(alu_transaction);

    `uvm_component_utils(alu_driver)

    virtual alu_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual alu_if)::get(
                this, "", "vif", vif))
            `uvm_fatal("NOVIF", "ALU virtual interface not configured")
    endfunction

    task run_phase(uvm_phase phase);
        alu_transaction tr;

        forever begin
            seq_item_port.get_next_item(tr);

            @(vif.driver_cb);
            vif.driver_cb.a  <= tr.a;
            vif.driver_cb.b  <= tr.b;
            vif.driver_cb.op <= tr.op;

            seq_item_port.item_done();
        end
    endtask

endclass

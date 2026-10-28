class alu_monitor extends uvm_monitor;

    `uvm_component_utils(alu_monitor)

    virtual alu_if vif;
    uvm_analysis_port #(alu_transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
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
            @(vif.monitor_cb);

            tr = alu_transaction::type_id::create("tr", this);
            tr.a        = vif.monitor_cb.a;
            tr.b        = vif.monitor_cb.b;
            tr.op       = vif.monitor_cb.op;
            tr.result   = vif.monitor_cb.result;
            tr.zero     = vif.monitor_cb.zero;
            tr.carry    = vif.monitor_cb.carry;
            tr.overflow = vif.monitor_cb.overflow;

            ap.write(tr);
        end
    endtask

endclass

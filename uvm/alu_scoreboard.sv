class alu_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(alu_scoreboard)

    uvm_analysis_imp #(alu_transaction, alu_scoreboard) analysis_export;

    int checked = 0;
    int errors  = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
    endfunction

    function void write(alu_transaction tr);
        bit [31:0] expected;
        bit [32:0] extended;
        bit expected_carry;
        bit expected_overflow;

        expected          = '0;
        expected_carry    = 0;
        expected_overflow = 0;

        case (tr.op)
            4'h0: begin
                extended = {1'b0, tr.a} + {1'b0, tr.b};
                expected = extended[31:0];
                expected_carry = extended[32];
                expected_overflow =
                    (~(tr.a[31] ^ tr.b[31])) &
                    (expected[31] ^ tr.a[31]);
            end
            4'h1: begin
                expected = tr.a - tr.b;
                expected_carry = (tr.a >= tr.b);
                expected_overflow =
                    (tr.a[31] ^ tr.b[31]) &
                    (expected[31] ^ tr.a[31]);
            end
            4'h2: expected = tr.a & tr.b;
            4'h3: expected = tr.a | tr.b;
            4'h4: expected = tr.a ^ tr.b;
            4'h5: expected = tr.a << tr.b[4:0];
            4'h6: expected = tr.a >> tr.b[4:0];
            4'h7: expected = $signed(tr.a) >>> tr.b[4:0];
            4'h8: expected = ($signed(tr.a) < $signed(tr.b)) ? 1 : 0;
            4'h9: expected = (tr.a < tr.b) ? 1 : 0;
            default: begin
                `uvm_error("ALU_SCB", "Unsupported opcode")
                errors++;
                return;
            end
        endcase

        checked++;

        if (tr.result !== expected) begin
            errors++;
            `uvm_error("ALU_SCB",
                $sformatf("op=%h a=%h b=%h expected=%h actual=%h",
                          tr.op, tr.a, tr.b, expected, tr.result))
        end

        if (tr.zero !== (expected == 0)) begin
            errors++;
            `uvm_error("ALU_SCB", "Zero flag mismatch")
        end

        if (tr.carry !== expected_carry) begin
            errors++;
            `uvm_error("ALU_SCB", "Carry flag mismatch")
        end

        if (tr.overflow !== expected_overflow) begin
            errors++;
            `uvm_error("ALU_SCB", "Overflow flag mismatch")
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("ALU_SUMMARY",
            $sformatf("Checked=%0d Errors=%0d", checked, errors),
            UVM_NONE)

        if (errors != 0)
            `uvm_error("ALU_SUMMARY", "ALU scoreboard detected failures")
    endfunction

endclass

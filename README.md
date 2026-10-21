# ALU Verification Starter

Starter for a 32-bit combinational ALU using VS Code + Icarus Verilog.

**UVM note:** Icarus Verilog does not support the full standard class-based UVM environment. This starter runs the RTL and a self-checking testbench first; a UVM-capable simulator (Questa, VCS, or Xcelium) is needed for the complete UVM phase.

## Operations
- `0`: ADD
- `1`: SUB
- `2`: AND
- `3`: OR
- `4`: XOR
- `5`: SLL
- `6`: SRL
- `7`: SRA
- `8`: SLT (signed)
- `9`: SLTU (unsigned)
- Other opcodes return zero.

Flags: `zero` means result is zero; ADD `carry` is carry-out; SUB `carry` is 1 when there is no unsigned borrow; `overflow` indicates signed ADD/SUB overflow. Other operations clear carry and overflow.

## Run on macOS
```bash
iverilog -g2012 -s tb_alu -o /tmp/alu_sim rtl/alu.sv tb/tb_alu.sv
vvp /tmp/alu_sim
```
Or run `./scripts/run.sh`.

Expected final line: `PASS: all ALU tests passed`

## Layout
- `rtl/alu.sv`: ALU RTL
- `tb/tb_alu.sv`: Icarus-compatible self-checking testbench
- `uvm/`, `assertions/`, `tests/`: reserved for next phases
- `scripts/run.sh`: compile and execute

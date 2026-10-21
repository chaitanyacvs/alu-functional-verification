#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p reports
iverilog -g2012 -s tb_alu -o /tmp/alu_starter_sim rtl/alu.sv tb/tb_alu.sv
vvp /tmp/alu_starter_sim | tee reports/last_run.log

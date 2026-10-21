
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "===================================="
echo " ALU BUG-INJECTION REGRESSION TEST"
echo "===================================="

iverilog -g2012 -s tb_bug_detection \
    -o /tmp/alu_bug_sim \
    rtl/alu_buggy.sv \
    tb/tb_bug_detection.sv

output=$(vvp /tmp/alu_bug_sim)
echo "$output"

if echo "$output" | grep -q "EXPECTED BUG DETECTED" &&
   echo "$output" | grep -q "PASS: bug detection test behaved as expected"; then
    echo "REGRESSION PASS: injected bug was detected."
else
    echo "REGRESSION FAIL: injected bug was not detected."
    exit 1
fi

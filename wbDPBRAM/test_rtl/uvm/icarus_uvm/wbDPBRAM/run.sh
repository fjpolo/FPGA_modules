#!/bin/bash

# Source the OSS CAD Suite environment
echo "        [SBY] Sourcing OSS CAD Suite environment..."
source ~/oss-cad-suite/environment
if [ $? -ne 0 ]; then
    echo "        [SBY] Failed to source OSS CAD Suite environment. Exiting script."
    exit 1
fi

# Copy original rtl here
cp ${PWD}/../../../../rtl/wbDPBRAM.v .

# Build and run icaris UVM
iverilog -g2012 -I/path/to/uvm-1.2/src -D UVM_NO_DEPRECATED -o simv tb_top.sv dut_wrapper.sv wbDPBRAM.v
vvp -n simv +UVM_TESTNAME=wbDPBRAM_test +UVM_VERBOSITY=UVM_MEDIUM

# Remove testbench
# rm wbDPBRAM.v
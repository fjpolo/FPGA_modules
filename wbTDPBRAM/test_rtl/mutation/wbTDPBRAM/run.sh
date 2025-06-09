    #!/bin/bash

    # Source the OSS CAD Suite environment
    echo "        [MCY] Sourcing OSS CAD Suite environment..."
    source ~/oss-cad-suite/environment
    if [ $? -ne 0 ]; then
        echo "        [MCY] FAIL: Failed to source OSS CAD Suite environment. Exiting script."
        exit 1
    fi

    # Copy original rtl here
    cp ${PWD}/../../../rtl/wbTDPBRAM.v .

    # Append `define MCY after `timescale 1ps/1ps to wbTDPBRAM.v using awk
    awk '1;/`timescale 1ps\/1ps/{print "`define MCY"}' wbTDPBRAM.v > wbTDPBRAM_temp.v
    mv wbTDPBRAM_temp.v wbTDPBRAM.v

    # Append `define MCY after `timescale 1ps/1ps to testbench.v using awk
    awk '1;/`timescale 1ps\/1ps/{print "`define MCY"}' testbench.v > testbench_temp.v
    mv testbench_temp.v testbench.v

    # Move create scripts to $SCRIPTS
    cp ${PWD}/../create_mutated_eq.sh ~/oss-cad-suite/share/mcy/scripts/
    cp ${PWD}/../create_mutated_fm.sh ~/oss-cad-suite/share/mcy/scripts/

    # Generate mutations using mcy
    echo "        [MCY] Generating mutations using mcy..."
    mcy purge; mcy init; mcy run -j8
    if [ $? -ne 0 ]; then
        echo "        [MCY] FAIL: mcy process failed. Exiting script."
        exit 1
    fi
    echo "        [MCY] PASS: mcy process passed"

    # Remove testbench
    rm testbench.v

    # Copy original rtl here
    rm wbTDPBRAM.v
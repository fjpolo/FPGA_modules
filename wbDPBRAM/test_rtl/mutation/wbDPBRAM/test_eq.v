// =============================================================================
// File        : miter.v
// Description : Miter module for formal equivalence checking of wbDPBRAM.
//               Compares two instances of wbDPBRAM (reference and UUT)
//               by feeding them identical inputs and asserting that their
//               outputs (specifically o_doutB) are always identical.
//               This version is optimized for formal verification tools like Yosys.
// License     : MIT License
//
// Copyright (c) 2025 | @fjpolo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================

`default_nettype none
`timescale 1ps/1ps

module miter #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 10,
  parameter MEM_DEPTH  = (1 << ADDR_WIDTH) // Calculate memory depth from address width
) (
    input   wire  [0:0]               i_clk,
    // Common inputs for Port A (fed to both ref and uut)
    input   wire  [0:0]               i_enA,
    input   wire  [0:0]               i_weA,
    input   wire  [(ADDR_WIDTH-1):0]  i_addrA,
    input   wire  [(DATA_WIDTH-1):0]  i_dinA,
    // Common inputs for Port B (fed to both ref and uut)
    input   wire  [0:0]               i_enB,
    input   wire  [(ADDR_WIDTH-1):0]  i_addrB,
    // Output indicating equivalence (1'b1 = equivalent, 1'b0 = not equivalent)
    output  wire  [0:0]               o_equal
);

    // Internal wires for outputs from reference and UUT instances
    wire [DATA_WIDTH-1:0] o_doutB_ref;
    wire [DATA_WIDTH-1:0] o_doutB_uut;

    // Instantiate the reference wbDPBRAM module
    // All inputs to the reference are directly from the miter's common inputs.
    wbDPBRAM ref (
        .i_clk    (i_clk),
        .i_enA    (i_enA),
        .i_weA    (i_weA),
        .i_addrA  (i_addrA),
        .i_dinA   (i_dinA),
        .i_enB    (i_enB),
        .i_addrB  (i_addrB),
        .o_doutB  (o_doutB_ref)
    );

    // Instantiate the Unit Under Test (UUT) wbDPBRAM module
    // All inputs to the UUT are also directly from the miter's common inputs.
    wbDPBRAM uut (
        .i_clk    (i_clk),
        .i_enA    (i_enA),
        .i_weA    (i_weA),
        .i_addrA  (i_addrA),
        .i_dinA   (i_dinA),
        .i_enB    (i_enB),
        .i_addrB  (i_addrB),
        .o_doutB  (o_doutB_uut)
    );

    // Equivalence check logic:
    // The 'o_equal' output is high if the outputs from Port B of both instances
    // are identical, but only when Port B is enabled (i_enB is high).
    // If Port B is not enabled, we consider them equivalent (as their outputs
    // might be undefined or hold previous values, and we don't care about their
    // exact match in that state for this check).
    assign o_equal = (i_enB == 1'b1) ? (o_doutB_ref == o_doutB_uut) : 1'b1;

    // Formal verification assertion (for tools like Yosys/SymbiYosys):
    // This 'assert' statement formally states that whenever Port B is enabled,
    // the output data from the reference and the UUT must be identical.
    // If this condition ever becomes false during formal verification,
    // the tool will report a non-equivalence.
    always @(posedge i_clk) begin
        if (i_enB) begin // Only assert when Port B is actively reading
            assert(o_doutB_ref == o_doutB_uut); // Removed 'else $error' for formal tool compatibility
        end
    end

    // Note: For a comprehensive formal verification, you might also add 'assume'
    // statements to specify valid input sequences or constraints (e.g., no
    // simultaneous writes to the same address from different ports if that's
    // a design constraint for your wbDPBRAM). However, for basic equivalence
    // checking, feeding identical inputs and asserting output equality is key.

endmodule

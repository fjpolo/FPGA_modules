// =============================================================================
// File        : Equivalence Check for wbTDPBRAM.v mutations
// Author      : @fjpolo
// email       : fjpolo@gmail.com
// Description : <Brief description of the module or file>
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

module miter#(
                    parameter DATA_WIDTH = 32,
                    parameter ADDR_WIDTH = 10,
                    parameter MEM_DEPTH   = (1 << ADDR_WIDTH) // Calculate memory depth from address width
                 )(
                    // Port A
                    input   wire    [0:0]               i_clkA,
                    input   wire    [0:0]               i_enA,
                    input   wire    [0:0]               i_weA,
                    input   wire    [(ADDR_WIDTH-1):0]  i_addrA,
                    input   wire    [(DATA_WIDTH-1):0]  i_dinA,
                    output  reg     [(DATA_WIDTH-1):0]  o_doutA,
                    // Port B
                    input   wire    [0:0]               i_clkB,
                    input   wire    [0:0]               i_enB,
                    input   wire    [0:0]               i_weB,
                    input   wire    [(ADDR_WIDTH-1):0]  i_addrB,
                    input   wire    [(DATA_WIDTH-1):0]  i_dinB,
                    output  reg     [(DATA_WIDTH-1):0]  o_doutB
                );

    // Reference signals
    wire    [(DATA_WIDTH-1):0]   i_dinA_ref;
    wire    [(DATA_WIDTH-1):0]   i_dinB_ref;
    wire    [(DATA_WIDTH-1):0]   o_doutA_ref;
    wire    [(DATA_WIDTH-1):0]   o_doutB_ref;

    // DUT signals
    wire    [(DATA_WIDTH-1):0]   i_dinA_uut;
    wire    [(DATA_WIDTH-1):0]   i_dinB_uut;
    wire    [(DATA_WIDTH-1):0]   o_doutA_uut;
    wire    [(DATA_WIDTH-1):0]   o_doutB_uut;

    // Instantiate the reference
    wbTDPBRAM ref(
        // Port A
        .i_clkA(i_clkA),
        .i_enA(i_enA),
        .i_weA(i_weA),
        .i_addrA(i_addrA),
        .i_dinA(i_dinA),
        .o_doutA(o_doutA_ref),
        // Port B
        .i_clkB(i_clkB),
        .i_enB(i_enB),
        .i_weB(i_weB),
        .i_addrB(i_addrB),
        .i_dinB(i_dinB),
        .o_doutB(o_doutB_ref),
        .mutsel(1'b0)
    );

    // Instantiate the UUT
    wbTDPBRAM uut(
        // Port A
        .i_clkA(i_clkA),
        .i_enA(i_enA),
        .i_weA(i_weA),
        .i_addrA(i_addrA),
        .i_dinA(i_dinA),
        .o_doutA(o_doutA_uut),
        // Port B
        .i_clkB(i_clkB),
        .i_enB(i_enB),
        .i_weB(i_weB),
        .i_addrB(i_addrB),
        .i_dinB(i_dinB),
        .o_doutB(o_doutB_uut),
        .mutsel(1'b1)
    );

    // Assumptions
    // Assume same clock domain
    always @(*)
        assume(i_clkA == i_clkB);
    // Assume input data stays consistent
    always @(*) begin
        assume(i_dinA == i_dinA_ref == i_dinA_ref);
        assume(i_dinB == i_dinB_ref == i_dinB_ref);
    end


    // Assertions
    always @(posedge i_clkA)
        assert(o_doutA_ref == o_doutA_uut);
    always @(posedge i_clkB)
        assert(o_doutB_ref == o_doutB_uut);

    always @(*)
        assert(o_doutA_ref == o_doutA_uut);
    always @(*)
        assert(o_doutB_ref == o_doutB_uut);

endmodule
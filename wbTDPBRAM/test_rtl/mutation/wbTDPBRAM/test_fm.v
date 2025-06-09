// =============================================================================
// File        : Formal properties for wbTDPBRAM.v mutations
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

parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 10;
parameter MEM_DEPTH   = (1 << ADDR_WIDTH);

module testbench(
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
    // Instantiate the dut
    wbTDPBRAM ref(
        // Port A
        .i_clkA(i_clkA),
        .i_enA(i_enA),
        .i_weA(i_weA),
        .i_addrA(i_addrA),
        .i_dinA(i_dinA),
        .o_doutA(o_doutA),
        // Port B
        .i_clkB(i_clkB),
        .i_enB(i_enB),
        .i_weB(i_weB),
        .i_addrB(i_addrB),
        .i_dinB(i_dinB),
        .o_doutB(o_doutB)
    );

    ////////////////////////////////////////////////////
	//
	// f_past_valid register
	//
	////////////////////////////////////////////////////

    /* Global clock for formal verification */
    (* gclk *) reg clk; // Use 'clk' as the global clock
	always @(*) assume(i_clkA == i_clkB); 
    // f_past_valid
	reg f_past_valid;
    initial f_past_valid = 0;
    always @(posedge i_clkA)
        f_past_valid <= 1'b1;
    //
    always @(*)
        assert((i_clkA)||(!i_clkA));
    always @(*)
        assert((i_clkB)||(!i_clkB));

        
    /* test our memory */
    (* anyconst *)  wire    [(ADDR_WIDTH-1):0]  f_tracked_addr;
    reg [(DATA_WIDTH)-1:0]  f_expected_data_at_tracked_addr_portA;
    reg [(DATA_WIDTH)-1:0]  f_expected_data_at_tracked_addr_portB;
    always @(posedge i_clkA) begin
        if ((i_enA)&&(i_weA)&&(i_addrA == f_tracked_addr)) begin
            f_expected_data_at_tracked_addr_portA <= i_dinA;
        end
    end
    always @(posedge i_clkA) begin
        if ((i_enA)&&(i_weA)&&(i_addrA == f_tracked_addr)) begin
            f_expected_data_at_tracked_addr_portB <= i_dinB;
        end
    end
    // PortA write->Read
    always @(posedge i_clkA) begin // Use global 'clk'
        if (
				(f_past_valid)&&($past(f_past_valid))&&($past(f_past_valid, 2))&&
				($past(i_enA))&&($past(i_enA,2))&&
				($past(i_weA,2))&&
				($past(i_addrA) == f_tracked_addr)&&($past(i_addrA,2) == f_tracked_addr)
			) begin
            assert(o_doutA == f_expected_data_at_tracked_addr_portA);
        end
    end
    // PortB write->Read
    always @(posedge i_clkA) begin // Use global 'clk'
        if (
				(f_past_valid)&&($past(f_past_valid))&&($past(f_past_valid, 2))&&
				($past(!i_enA))&&(!$past(i_enA,2))&&
				($past(i_enB))&&($past(i_enB,2))&&
				($past(!i_weA,2))&&
				($past(i_weB,2))&&
				($past(i_addrA) != f_tracked_addr)&&($past(i_addrA,2) != f_tracked_addr)&&
				($past(i_addrB) == f_tracked_addr)&&($past(i_addrB,2) == f_tracked_addr)
			) begin
            assert(o_doutB == f_expected_data_at_tracked_addr_portB);
        end
    end

    // PortA write->PortB Read
    always @(posedge i_clkA) begin // Use global 'clk'
        if (
				(f_past_valid)&&($past(f_past_valid))&&($past(f_past_valid, 2))&&
				($past(!i_enA))&&($past(i_enA,2))&&
				($past(i_enB))&&(!$past(i_enB,2))&&
				($past(i_weA,2))&&
				($past(!i_weB,2))&&
				($past(i_addrA) != f_tracked_addr)&&($past(i_addrA,2) == f_tracked_addr)&&
				($past(i_addrB) == f_tracked_addr)&&($past(i_addrB,2) == f_tracked_addr)
			) begin
            assert(o_doutB == f_expected_data_at_tracked_addr_portB);
        end
    end

    // PortB write->PortA Read
    always @(posedge i_clkA) begin // Use global 'clk'
        if (
				(f_past_valid)&&($past(f_past_valid))&&($past(f_past_valid, 2))&&
				($past(i_enA))&&(!$past(i_enA,2))&&
				($past(!i_enB))&&($past(i_enB,2))&&
				($past(!i_weA,2))&&
				($past(i_weB,2))&&
				($past(i_addrA) == f_tracked_addr)&&($past(i_addrA,2) != f_tracked_addr)&&
				($past(i_addrB) == f_tracked_addr)&&($past(i_addrB,2) == f_tracked_addr)
			) begin
            assert(o_doutA == f_expected_data_at_tracked_addr_portA);
        end
    end

        
endmodule
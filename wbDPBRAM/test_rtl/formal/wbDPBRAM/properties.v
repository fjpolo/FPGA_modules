// =============================================================================
// File        : Formal Properties for wbDPBRAM.v
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
`ifdef	FORMAL
// Change direction of assumes
`define	ASSERT	assert
`ifdef	wbDPBRAM
`define	ASSUME	assume
`else
`define	ASSUME	assert
`endif

    ////////////////////////////////////////////////////
	//
	// f_past_valid register
	//
	////////////////////////////////////////////////////
	reg	f_past_valid;
	initial	f_past_valid = 0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;



    ////////////////////////////////////////////////////
	//
	// Reset
	//
	////////////////////////////////////////////////////

    ////////////////////////////////////////////////////
	//
	// BMC
	//
	////////////////////////////////////////////////////
	(* anyconst *)	wire	[(ADDR_WIDTH-1):0]	f_addr;
	reg	[(DATA_WIDTH)-1:0]	f_expected_data_at_f_addr;
	always @(posedge i_clk)
		if ((i_enA)&&(i_weA)&&(i_addrA == f_addr))
			f_expected_data_at_f_addr <= i_dinA;
	// Verify write
	always @(posedge i_clk)
		if((f_past_valid)&&(($past(f_past_valid))&&($past(i_enA))&&($past(i_weA))&&($past(i_addrA) == $past(f_addr))))
			assert(ram[$past(f_addr)] == f_expected_data_at_f_addr);

    ////////////////////////////////////////////////////
	//
	// Contract
	//
	////////////////////////////////////////////////////   

    ////////////////////////////////////////////////////
	//
	// Induction
	//
	////////////////////////////////////////////////////
    
	////////////////////////////////////////////////////
	//
	// Cover
	//
	////////////////////////////////////////////////////   

	always @(posedge i_clk) begin
		if((f_past_valid)&&(o_doutB != 0))
			cover(o_doutB == $past(ram[i_addrB]));
	end  
`endif


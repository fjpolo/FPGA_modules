// =============================================================================
// File        : Formal Properties for wbTDPBRAM.v
// Author      : @fjpolo
// email       : fjpolo@gmail.com
// Description : Formal properties for True Dual Port Block RAM with Port A write priority.
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
`ifdef  FORMAL
// Change direction of assumes
`define ASSERT  assert
`ifdef  wbTDPBRAM // This should match the top module name (DUT)
`define ASSUME  assume
`else
`define ASSUME  assert
`endif

    /* Global clock for formal verification */
    (* gclk *) reg clk; // Use 'clk' as the global clock
	always @(posedge clk) begin
		assume(i_clkA == !$past(i_clkA));
		assume(i_clkB == !$past(i_clkB));
	end
	always @(*) assume(i_clkA == i_clkB); 


    ////////////////////////////////////////////////////
    //
    // f_past_valid register
    //
    ////////////////////////////////////////////////////
    reg f_past_valid;
    initial f_past_valid = 0;
    always @(posedge i_clkA)
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

    /* Port A write (priority) followed by read from port A*/
    // Define a specific address to track for properties
    (* anyconst *)  wire    [(ADDR_WIDTH-1):0]  f_tracked_addr;

    // Register to store the data that should be written to f_tracked_addr by Port A
    reg [(DATA_WIDTH)-1:0]  f_expected_data_at_tracked_addr;
    always @(posedge i_clkA) begin
        // If Port A attempts to write to f_tracked_addr
        if ((i_enA)&&(i_weA)&&(i_addrA == f_tracked_addr)) begin
            f_expected_data_at_tracked_addr <= i_dinA;
        end
    end

    // Assertion: If Port A successfully wrote to f_tracked_addr in the previous cycle,
    // then the RAM content at f_tracked_addr must match the expected data in the current cycle.
    always @(posedge i_clkA) begin // Use global 'clk'
        if (
				(f_past_valid)&&
				($past(f_past_valid))&&
				(($past(i_enA))&&
				($past(i_weA))&&
				($past(i_addrA) == f_tracked_addr))
			) begin
            assert(ram[f_tracked_addr] == f_expected_data_at_tracked_addr);
        end
    end

    // --- NEW PROPERTY: Port B write priority check ---
    // If Port B attempts to write to f_tracked_addr, but Port A has priority (is writing to same address),
    // then Port B's write should be suppressed.
    always @(posedge i_clkB) begin // Use global 'clk'
        if (f_past_valid &&
            ($past(i_enB) && $past(i_weB) && ($past(i_addrB) == f_tracked_addr)) && // Port B wants to write to f_tracked_addr
            ($past(i_enA) && $past(i_weA) && ($past(i_addrA) == f_tracked_addr))) begin // AND Port A also wants to write to same address
            // In this case, Port B's write should NOT happen, so ram[f_tracked_addr] should NOT be i_dinB from Port B
            // It should be i_dinA from Port A.
            assert(ram[f_tracked_addr] == f_expected_data_at_tracked_addr); // Assert it's Port A's data
            // This second assert ensures that if dinB was different from dinA, dinB was NOT written.
            // This is a stronger guarantee for priority.
            assert(ram[f_tracked_addr] != $past(i_dinB) || (f_expected_data_at_tracked_addr == $past(i_dinB)));
            // The above means: Either ram[f_tracked_addr] is not dinB, OR dinB happened to be the same as dinA anyway.
        end
    end


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

    // Cover a Port A write
    always @(posedge clk) begin
        cover(((i_enA && i_weA) && (i_addrA == f_tracked_addr)));
    end

    // Cover a Port B write attempt where Port A has priority
    always @(posedge clk) begin
        cover(((i_enB && i_weB) && (i_addrB == f_tracked_addr)) &&
              ((i_enA && i_weA) && (i_addrA == f_tracked_addr)));
    end

`endif

// =============================================================================
// File        : wbTDPBRAM.v
// Author      : @fjpolo
// email       : fjpolo@gmail.com
// Description : True Dual Port Block RAM with Port A write priority on collision.
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

module wbTDPBRAM#(
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

// Internal memory array
reg [(DATA_WIDTH-1):0] ram [(MEM_DEPTH-1):0];

// Define a wire to indicate if Port A is actively trying to write to the same address as Port B
wire port_a_writing_to_same_address = ((i_enA)&&(i_weA)&&(i_addrA == i_addrB));

// Port A - Write
always @(posedge i_clkA) begin
    if (i_enA) begin
        if (i_weA) begin
            ram[i_addrA] <= i_dinA;
        end
    end
end

// Port A - Read
always @(posedge i_clkA) begin
    if (i_enA) begin
        o_doutA <= ram[i_addrA];
    end
end

// Port B - Write
always @(posedge i_clkB) begin
    if (i_enB && i_weB) begin
        if (!port_a_writing_to_same_address) begin // If Port A is NOT writing to this address, Port B can write
            ram[i_addrB] <= i_dinB;
        end
    end
end

// Port B - Read
always @(posedge i_clkB) begin
    if (i_enB) begin
        o_doutB <= ram[i_addrB];
    end
end

endmodule

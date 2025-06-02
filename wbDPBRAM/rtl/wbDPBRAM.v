// =============================================================================
// File        : wbDPBRAM.v
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
//
// wbDPBRAM - Double Port Block RAM (SDR)
//
// This module implements a synchronous dual-port block RAM that can be configured
// using parameters for data width, address width, and memory depth.
// Each port operates independently with its own clock, enable, write enable,
// address, data in, and data out signals.
//
// This version operates in a Single Data Rate (SDR) fashion,
// meaning it will perform read/write operations only on the positive edge
// of the respective port clocks.
//
// Parameters:
//   DATA_WIDTH: Specifies the width of the data bus in bits.
//   ADDR_WIDTH: Specifies the width of the address bus in bits.
//               The memory depth will be 2^ADDR_WIDTH.
//   MEM_DEPTH:  Specifies the total number of memory locations.
//               This parameter is derived from ADDR_WIDTH, but can be
//               overridden if a specific depth is required (though ADDR_WIDTH
//               should then be adjusted accordingly for correct addressing).
//               For simplicity, it's calculated as (1 << ADDR_WIDTH).
//
// Ports:
//   input                   i_clk,     // Clock for Port A and port B (SDR operation)
//   input                   i_reset_n, // Reset active low
//
//   // Port A
//   input                   i_enA,     // Enable for Port A (active high)
//   input                   i_weA,     // Write Enable for Port A (active high)
//   input  [ADDR_WIDTH-1:0] i_addr_A,   // Address input for Port A
//   input  [DATA_WIDTH-1:0] i_dinA,    // Data input for Port A (write data)
//   output [DATA_WIDTH-1:0] o_doutA,   // Data output for Port A (read data)
//
//   // Port B
//   input                   i_enB,     // Enable for Port B (active high)
//   input                   i_weB,     // Write Enable for Port B (active high)
//   input  [ADDR_WIDTH-1:0] i_addrB,   // Address input for Port B
//   input  [DATA_WIDTH-1:0] i_dinB,    // Data input for Port B (write data)
//   output [DATA_WIDTH-1:0] o_doutB    // Data output for Port B (read data)
//
`default_nettype none
`timescale 1ps/1ps

module wbDPBRAM #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 10,
  parameter MEM_DEPTH  = (1 << ADDR_WIDTH) // Calculate memory depth from address width
) (
  input wire    [0:0]             i_clk,
  input wire    [0:0]             i_reset_n,

  // Port A
  input   wire  [0:0]             i_enA,
  input   wire  [0:0]             i_weA,
  input   wire  [ADDR_WIDTH-1:0]  i_addr_A,
  input   wire  [DATA_WIDTH-1:0]  i_dinA,
  output  wire  [DATA_WIDTH-1:0]  o_doutA,

  // Port B
  input   wire  [0:0]             i_enB,
  input   wire  [0:0]             i_weB,
  input   wire  [ADDR_WIDTH-1:0]  i_addrB,
  input  wire   [DATA_WIDTH-1:0]  i_dinB,
  output wire   [DATA_WIDTH-1:0]  o_doutB
);

  // Internal memory array
  // The memory is declared as a register array, indexed by address.
  reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

  // Registers to hold the output data for each port
  // This is crucial for synchronous read behavior, where data is available
  // on the next clock cycle after the address is provided.
  reg [DATA_WIDTH-1:0] doutA_reg;
  reg [DATA_WIDTH-1:0] doutB_reg;

  // Assign the internal output registers to the module outputs
  assign o_doutA = doutA_reg;
  assign o_doutB = doutB_reg;

  // Port A Read/Write Logic - Operates only on positive clock edge
  always @(posedge i_clk) begin
    if(i_reset_n) begin
      if (i_enA) begin // Only operate if Port A is enabled
        if (i_weA) begin // Write operation for Port A
          // Write data to memory at the specified address
          mem[i_addr_A] <= i_dinA;
          // Read-before-write behavior
          doutA_reg <= mem[i_addr_A];
        end else begin // Read operation for Port A
          // Read data from memory at the specified address
          doutA_reg <= mem[i_addr_A];
        end
      end
    end
  end

  // Port B Read/Write Logic - Operates only on positive clock edge
  always @(posedge i_clk) begin
    if(i_reset_n) begin
      if (i_enB) begin // Only operate if Port B is enabled
        if (i_weB) begin // Write operation for Port B
          // Write data to memory at the specified address
          mem[i_addrB] <= i_dinB;
          // Read-before-write behavior for Port B
          doutB_reg <= mem[i_addrB];
        end else begin // Read operation for Port B
          // Read data from memory at the specified address
          doutB_reg <= mem[i_addrB];
        end
      end
    end
  end

endmodule

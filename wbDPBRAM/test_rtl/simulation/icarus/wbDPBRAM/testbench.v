// =============================================================================
// File        : testbench.v for wbDPBRAM.v
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

module testbench;

  localparam HALF_CLOCK = 5;
  localparam FULL_CLOCK = 2 * HALF_CLOCK;

  // Parameters for the wbDPBRAM module instance
  parameter DATA_WIDTH = 32;
  parameter ADDR_WIDTH = 10;
  parameter MEM_DEPTH  = (1 << ADDR_WIDTH); // 2^10 = 1024 locations

  // Testbench signals (wires and regs to connect to the DUT)
  reg                   clk;
  // Port A signals
  reg                   i_enA;
  reg                   i_weA;
  reg  [ADDR_WIDTH-1:0] i_addrA;
  reg  [DATA_WIDTH-1:0] i_dinA;
  // Port B signals
  reg                   i_enB;
  reg  [ADDR_WIDTH-1:0] i_addrB;
  wire [DATA_WIDTH-1:0] o_doutB; // Output from DUT

  // Test status variables
  integer test_count = 0;
  integer pass_count = 0;
  integer fail_count = 0;
  integer error_flag = 0; // Set to 1 if a fatal error occurs

  // Instantiate the Device Under Test (DUT) - wbDPBRAM
  // Ensure wbDPBRAM.v is in the same directory or accessible via your simulator's paths.
  wbDPBRAM #(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH),
    .MEM_DEPTH  (MEM_DEPTH)
  ) dut (
    .i_clk    (clk),
    .i_enA    (i_enA),
    .i_weA    (i_weA),
    .i_addrA  (i_addrA),
    .i_dinA   (i_dinA),
    .i_enB    (i_enB),
    .i_addrB  (i_addrB),
    .o_doutB  (o_doutB)
  );

    reg [(ADDR_WIDTH)-1:0] random_addr;
    reg [(DATA_WIDTH-1):0] random_data;

  // Clock generation
  initial begin
    clk = 0;
    forever #HALF_CLOCK clk = ~clk; // 10ns period (100 MHz clock)
  end

  // Main test sequence
  initial begin
    // Initialize all inputs
    i_enA   = 0;
    i_weA   = 0;
    i_addrA = 0;
    i_dinA  = 0;
    i_enB   = 0;
    i_addrB = 0;

    // Give some time for initial reset/stabilization
    #(10*FULL_CLOCK); $display("TIME %0t: Starting test sequence...", $time);

    // --- Test 1: Write to a random address and read back ---
    // Generate random address and data
    random_addr = {$random} % MEM_DEPTH; // Random address within memory bounds
    random_data = {$random}; // Random data (will be truncated/extended to DATA_WIDTH)

    $display("--------------------------------------------------");
    $display("TIME %0t: Test 1: Writing random data 0x%H to random address 0x%H via Port A", $time, random_data, random_addr);

    // Write operation
    i_enA   = 1;
    i_weA   = 1;
    i_addrA = random_addr;
    i_dinA  = random_data;
    #(FULL_CLOCK) // Apply inputs on posedge
    i_enA   = 0; // Deassert enable after one cycle
    i_weA   = 0;
    $display("TIME %0t: Port A write complete.", $time);

    // Wait some cycles for stability
    #(FULL_CLOCK)
    #(FULL_CLOCK)

    $display("--------------------------------------------------");
    $display("TIME %0t: Test 1: Reading from address 0x%H via Port B, expecting 0x%H", $time, random_addr, random_data);

    // Read operation
    i_enB   = 1;
    i_addrB = random_addr;
    #(FULL_CLOCK) // Apply address, wait for data to propagate (one cycle latency for synchronous read)

    test_count = test_count + 1;
    if (o_doutB === random_data) begin
      $display("TIME %0t: TEST %0d PASSED: Read data 0x%H matches expected 0x%H for address 0x%H.",
               $time, test_count, o_doutB, random_data, random_addr);
      pass_count = pass_count + 1;
    end else begin
      $display("TIME %0t: TEST %0d FAILED: Read data 0x%H MISMATCHES expected 0x%H for address 0x%H.",
               $time, test_count, o_doutB, random_data, random_addr);
      fail_count = fail_count + 1;
      error_flag = 1;
    end
    i_enB   = 0; // Deassert enable after read
    $display("TIME %0t: Port B read complete. Read data: 0x%H", $time, o_doutB);


    // --- Final Report ---
    $display("==================================================");
    $display("TIME %0t: Simulation finished.", $time);
    $display("Total Tests: %0d", test_count);
    $display("Passed:      %0d", pass_count);
    $display("Failed:      %0d", fail_count);
    $display("==================================================");

    if (error_flag) begin
      $display("STATUS: FAIL (One or more tests failed)");
      $finish;
    end else if (pass_count == test_count) begin
      $display("STATUS: PASS (All tests passed)");
      $finish;
    end else begin
      $display("STATUS: ERROR (Unexpected state, not all tests passed or failed cleanly)");
      $finish;
    end
  end

endmodule

// =============================================================================
// File        : testbench.v for wbTDPBRAM.v
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

    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 10;
    parameter MEM_DEPTH  = (1 << ADDR_WIDTH); // MEM_DEPTH is not used in the testbench, but good for completeness

    // Port A - These signals will be driven by the testbench, so they must be 'reg'
    reg     [0:0]               i_clkA;
    reg     [0:0]               i_enA;   // Changed from wire to reg
    reg     [0:0]               i_weA;   // Changed from wire to reg
    reg     [(ADDR_WIDTH-1):0]  i_addrA; // Changed from wire to reg
    reg     [(DATA_WIDTH-1):0]  i_dinA;  // Changed from wire to reg
    wire    [(DATA_WIDTH-1):0]  o_doutA; // Output from the DUT, remains wire

    // Port B - These signals will be driven by the testbench, so they must be 'reg'
    reg     [0:0]               i_clkB;
    reg     [0:0]               i_enB;   // Changed from wire to reg
    reg     [0:0]               i_weB;   // Changed from wire to reg
    reg     [(ADDR_WIDTH-1):0]  i_addrB; // Changed from wire to reg
    reg     [(DATA_WIDTH-1):0]  i_dinB;  // Changed from wire to reg
    wire    [(DATA_WIDTH-1):0]  o_doutB; // Output from the DUT, remains wire

    parameter HALF_CLK = 5;
    parameter FULL_CLK = 2 * HALF_CLK;

    integer addr;
    reg [DATA_WIDTH-1:0] test_data;


    // Clock generation for Port A
    initial begin
        i_clkA = 0;
        forever #(HALF_CLK) i_clkA = ~i_clkA; // 10ps clock period
    end

    // Clock generation for Port B
    initial begin
        i_clkB = 0;
        forever #(HALF_CLK) i_clkB = ~i_clkB; // 10ps clock period
    end

    // Waveform dumping
    initial begin
        $dumpfile("dump.vcd"); // Specify the waveform file name
        $dumpvars(0, testbench); // Dump all signals in the testbench module
    end

    // Instantiate wbTDPBRAM
    // MEM_DEPTH is typically also a parameter to the BRAM module
    // If wbTDPBRAM also has a MEM_DEPTH parameter, you should pass it.
    // For now, only DATA_WIDTH and ADDR_WIDTH are passed as per your instantiation.
    wbTDPBRAM #(
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH)
    ) tdpbram(
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

    // Test sequence
    initial begin
        // Initialize inputs for both ports to a known state
        i_enA <= 1'b0;
        i_weA <= 1'b0;
        i_addrA <= 'h0;
        i_dinA <= 'h0;

        i_enB <= 1'b0;
        i_weB <= 1'b0;
        i_addrB <= 'h0;
        i_dinB <= 'h0;

        #(FULL_CLK * 2); // Wait a couple of clock cycles for clocks to stabilize and initial values to propagate

        $display("---------------------------------------");
        $display("Starting Test Sequence for wbTDPBRAM");
        $display("---------------------------------------");

        // Test 1: Write to Port A, then read from Port A
        $display("Time %0t: Test 1: Writing 0xdeadbeef to addr 0x001 via Port A", $time);
        #(FULL_CLK);
        i_enA <= 1'b1;
        i_weA <= 1'b1;
        i_addrA <= 'h0001;
        i_dinA <= 'hdeadbeef;

        #(FULL_CLK);
        i_weA <= 1'b0; // De-assert write enable after the write cycle
        i_enA <= 1'b0; // De-assert enable for the next cycle

        $display("Time %0t: Test 1: Reading from addr 0x001 via Port A", $time);
        #(FULL_CLK);
        i_enA <= 1'b1;
        i_weA <= 1'b0; // Ensure it's a read operation
        i_addrA <= 'h0001;

        #(FULL_CLK);
        if (o_doutA !== 'hdeadbeef) begin
            $display("Time %0t: FAIL: Write->Read from Port A at addr 0x%x failed. Read 0x%x instead of 0x%x", $time, i_addrA, o_doutA, 'hdeadbeef);
            $finish;
        end else begin
            $display("Time %0t: PASS: Write->Read from Port A at addr 0x%x successful. Read 0x%x", $time, i_addrA, o_doutA);
        end

        #(FULL_CLK);
        i_enA <= 1'b0; // De-assert enable after read

        $display("---------------------------------------");

        // Test 2: Write to Port B, then read from Port B
        $display("Time %0t: Test 2: Writing 0xdeadbeef to addr 0x002 via Port B", $time);
        #(FULL_CLK);
        i_enB <= 1'b1;
        i_weB <= 1'b1;
        i_addrB <= 'h0002;
        i_dinB <= 'hdeadbeef;

        #(FULL_CLK);
        i_weB <= 1'b0; // De-assert write enable after the write cycle
        i_enB <= 1'b0; // De-assert enable for the next cycle

        $display("Time %0t: Test 2: Reading from addr 0x001 via Port B", $time);
        #(FULL_CLK);
        i_enB <= 1'b1;
        i_weB <= 1'b0; // Ensure it's a read operation
        i_addrB <= 'h0002;

        #(FULL_CLK);
        if (o_doutB !== 'hdeadbeef) begin
            $display("Time %0t: FAIL: Write->Read from Port B at addr 0x%x failed. Read 0x%x instead of 0x%x", $time, i_addrB, o_doutB, 'hdeadbeef);
            $finish;
        end else begin
            $display("Time %0t: PASS: Write->Read from Port B at addr 0x%x successful. Read 0x%x", $time, i_addrB, o_doutB);
        end

        #(FULL_CLK);
        i_enB <= 1'b0; // De-assert enable after read

        $display("---------------------------------------");

        // Test 3: Write to Port A, then read from Port B
        $display("Time %0t: Test 3: Writing 0xdeadbeef to addr 0x003 via Port A", $time);
        #(FULL_CLK);
        i_enA <= 1'b1;
        i_weA <= 1'b1;
        i_addrA <= 'h0003;
        i_dinA <= 'hdeadbeef;

        #(FULL_CLK);
        i_weA <= 1'b0; // De-assert write enable after the write cycle
        i_enA <= 1'b0; // De-assert enable for the next cycle

        $display("Time %0t: Test 3: Reading from addr 0x003 via Port B", $time);
        #(FULL_CLK);
        i_enB <= 1'b1;
        i_weB <= 1'b0; // Ensure it's a read operation
        i_addrB <= 'h0003;

        #(FULL_CLK);
        if (o_doutB !== 'hdeadbeef) begin
            $display("Time %0t: FAIL: Write->Read from Port B at addr 0x%x failed. Read 0x%x instead of 0x%x", $time, i_addrB, o_doutB, 'hdeadbeef);
            $finish;
        end else begin
            $display("Time %0t: PASS: Write->Read from Port B at addr 0x%x successful. Read 0x%x", $time, i_addrB, o_doutB);
        end

        #(FULL_CLK);
        i_enB <= 1'b0; // De-assert enable after read

        $display("---------------------------------------");

        // Test 4: Write to Port B, then read from Port A
        $display("Time %0t: Test 4: Writing 0xdeadbeef to addr 0x004 via Port B", $time);
        #(FULL_CLK);
        i_enB <= 1'b1;
        i_weB <= 1'b1;
        i_addrB <= 'h0004;
        i_dinB <= 'hdeadbeef;

        #(FULL_CLK);
        i_weB <= 1'b0; // De-assert write enable after the write cycle
        i_enB <= 1'b0; // De-assert enable for the next cycle

        $display("Time %0t: Test 4: Reading from addr 0x004 via Port A", $time);
        #(FULL_CLK);
        i_enA <= 1'b1;
        i_weA <= 1'b0; // Ensure it's a read operation
        i_addrA <= 'h0004;

        #(FULL_CLK);
        if (o_doutA !== 'hdeadbeef) begin
            $display("Time %0t: FAIL: Write->Read from Port A at addr 0x%x failed. Read 0x%x instead of 0x%x", $time, i_addrA, o_doutA, 'hdeadbeef);
            $finish;
        end else begin
            $display("Time %0t: PASS: Write->Read from Port A at addr 0x%x successful. Read 0x%x", $time, i_addrA, o_doutA);
        end

        #(FULL_CLK);
        i_enA <= 1'b0; // De-assert enable after read

        $display("---------------------------------------");

        // Test 5: Loop through all addresses: Write to Port A, then read from Port B
        $display("Time %0t: Test 5: Iterating through all addresses (0 to %0d). Write Port A, Read Port B.", $time, MEM_DEPTH - 1);
        for (addr = 0; addr < MEM_DEPTH; addr = addr + 1) begin
            test_data = {32'hAAAA_0000 | addr}; // Generate unique test data for each address

            // Write to Port A
            #(FULL_CLK);
            i_enA <= 1'b1;
            i_weA <= 1'b1;
            i_addrA <= addr;
            i_dinA <= test_data;

            #(FULL_CLK);
            i_weA <= 1'b0;
            i_enA <= 1'b0;
            
            // Read from Port B
            #(FULL_CLK);
            i_enB <= 1'b1;
            i_weB <= 1'b0; // Ensure it's a read operation
            i_addrB <= addr;

            #(FULL_CLK);
            // Based on previous instructions: "check the output only when o_ce is high, and account for the fact that o_ce toggles."
            // Since `o_ce` is not an explicit output, we assume `o_doutB` is valid after `i_enB` is high for one clock cycle.
            if (o_doutB !== test_data) begin
                $display("Time %0t: FAIL: Port A Write -> Port B Read at addr 0x%x failed. Read 0x%x instead of expected 0x%x", $time, addr, o_doutB, test_data);
                $finish; // Terminate simulation on first failure
            end else begin
                // $display("Time %0t: PASS: Port A Write -> Port B Read at addr 0x%x successful. Read 0x%x", $time, addr, o_doutB);
            end

            #(FULL_CLK);
            i_enB <= 1'b0; // De-assert enable after read
        end
        $display("Time %0t: Test 5: All Port A Writes -> Port B Reads completed successfully for all addresses.", $time);
        $display("---------------------------------------");

        // Test 6: Loop through all addresses: Write to Port B, then read from Port A
        $display("Time %0t: Test 6: Iterating through all addresses (0 to %0d). Write Port B, Read Port A.", $time, MEM_DEPTH - 1);
        for (addr = 0; addr < MEM_DEPTH; addr = addr + 1) begin
            test_data = {32'hAAAA_0000 | addr}; // Generate unique test data for each address

            // Write to Port B
            #(FULL_CLK);
            i_enB <= 1'b1;
            i_weB <= 1'b1;
            i_addrB <= addr;
            i_dinB <= test_data;

            #(FULL_CLK);
            i_weB <= 1'b0;
            i_enB <= 1'b0;
            
            // Read from Port A
            #(FULL_CLK);
            i_enA <= 1'b1;
            i_weA <= 1'b0; // Ensure it's a read operation
            i_addrA <= addr;

            #(FULL_CLK);
            // Based on previous instructions: "check the output only when o_ce is high, and account for the fact that o_ce toggles."
            // Since `o_ce` is not an explicit output, we assume `o_doutA` is valid after `i_enA` is high for one clock cycle.
            if (o_doutA !== test_data) begin
                $display("Time %0t: FAIL: Port A Write -> Port A Read at addr 0x%x failed. Read 0x%x instead of expected 0x%x", $time, addr, o_doutA, test_data);
                $finish; // Terminate simulation on first failure
            end else begin
                // $display("Time %0t: PASS: Port A Write -> Port A Read at addr 0x%x successful. Read 0x%x", $time, addr, o_doutA);
            end

            #(FULL_CLK);
            i_enA <= 1'b0; // De-assert enable after read
        end
        $display("Time %0t: Test 6: All Port A Writes -> Port B Reads completed successfully for all addresses.", $time);
        $display("---------------------------------------");


        // Test 7: If Port A and Port B want to write to the same address at the same time, Port A has priority
        $display("Time %0t: Test 7: Writing 0xdeadbeef to addr 0x006 via Port A", $time);
        $display("                    Writing 0xdeadb00b to addr 0x006 via Port B");
        #(FULL_CLK);
        i_enA <= 1'b1;
        i_enB <= 1'b1;
        i_weA <= 1'b1;
        i_weB <= 1'b1;
        i_addrA <= 'h0001;
        i_addrB <= 'h0001;
        i_dinA <= 'hdeadbeef;
        i_dinB <= 'hdeadb00b;

        #(FULL_CLK);
        i_weA <= 1'b0; // De-assert write enable after the write cycle
        i_weB <= 1'b0; // De-assert write enable after the write cycle
        i_enA <= 1'b0; // De-assert enable for the next cycle
        i_enB <= 1'b0; // De-assert enable for the next cycle

        $display("Time %0t: Test 1: Reading from addr 0x006 via Port A", $time);
        #(FULL_CLK);
        i_enA <= 1'b1;
        i_weA <= 1'b0; // Ensure it's a read operation
        i_addrA <= 'h0001;

        #(FULL_CLK);
        if (o_doutA !== 'hdeadbeef) begin
            $display("Time %0t: FAIL: Write->Read from Port A at addr 0x%x failed. Read 0x%x instead of 0x%x", $time, i_addrA, o_doutA, 'hdeadbeef);
            $finish;
        end else begin
            $display("Time %0t: PASS: Write->Read from Port A at addr 0x%x successful. Read 0x%x", $time, i_addrA, o_doutA);
        end

        #(FULL_CLK);
        i_enA <= 1'b0; // De-assert enable after read

        $display("---------------------------------------");
 




        // If all tests pass
        $display("Time %0t: PASS: All tests completed.", $time);
        $finish;
    end

    // Monitor for errors or timeout
    initial begin
        #(20000 * FULL_CLK); // Increased timeout to allow for more tests
        $display("Time %0t: ERROR: Simulation timed out.", $time);
        $finish;
    end

endmodule
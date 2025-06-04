# wbTDPBRAM Module - True Double Port Block RAM

This Verilog module implements...

## Features

* Feature1
* Feature2
* Feature3

## Usage

1. **Instantiate the module:**

   ```verilog
    module wbTDPBRAM#(
                        parameter DATA_WIDTH = 32,
                        parameter ADDR_WIDTH = 10,
                        parameter MEM_DEPTH  = (1 << ADDR_WIDTH) // Calculate memory depth from address width
                     )(
                        input   wire    [0:0]               i_clkA,
                        input   wire    [0:0]               i_clkB,
                        input   wire    [0:0]               i_enA,
                        input   wire    [0:0]               i_enB,
                        input   wire    [0:0]               i_weA,
                        input   wire    [0:0]               i_weB,
                        input   wire    [(ADDR_WIDTH-1):0]  i_addrA,
                        input   wire    [(ADDR_WIDTH-1):0]  i_addrB,
                        input   wire    [(DATA_WIDTH-1):0]  i_dinA,
                        input   wire    [(DATA_WIDTH-1):0]  i_dinB,
                        output  reg     [(DATA_WIDTH-1):0]  o_doutA,
                        output  reg     [(DATA_WIDTH-1):0]  o_doutB
                    ) ;
   );
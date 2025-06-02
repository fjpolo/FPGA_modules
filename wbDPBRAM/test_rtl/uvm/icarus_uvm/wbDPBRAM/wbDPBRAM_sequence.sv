class wbDPBRAM_sequence extends uvm_sequence #(wbDPBRAM_transaction);
    `uvm_object_utils(wbDPBRAM_sequence)
    
    function new(string name = "wbDPBRAM_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        wbDPBRAM_transaction trans;
        
        // Apply reset
        trans = wbDPBRAM_transaction::type_id::create("trans");
        trans.reset_n = 0;
        start_item(trans);
        finish_item(trans);
        
        // Release reset and send random data
        repeat(10) begin
            trans = wbDPBRAM_transaction::type_id::create("trans");
            trans.reset_n = 1;
            assert(trans.randomize());
            start_item(trans);
            finish_item(trans);
        end
    endtask
endclass
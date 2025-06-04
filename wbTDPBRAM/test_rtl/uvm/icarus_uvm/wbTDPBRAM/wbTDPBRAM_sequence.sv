class wbTDPBRAM_sequence extends uvm_sequence #(wbTDPBRAM_transaction);
    `uvm_object_utils(wbTDPBRAM_sequence)
    
    function new(string name = "wbTDPBRAM_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        wbTDPBRAM_transaction trans;
        
        // Apply reset
        trans = wbTDPBRAM_transaction::type_id::create("trans");
        trans.reset_n = 0;
        start_item(trans);
        finish_item(trans);
        
        // Release reset and send random data
        repeat(10) begin
            trans = wbTDPBRAM_transaction::type_id::create("trans");
            trans.reset_n = 1;
            assert(trans.randomize());
            start_item(trans);
            finish_item(trans);
        end
    endtask
endclass
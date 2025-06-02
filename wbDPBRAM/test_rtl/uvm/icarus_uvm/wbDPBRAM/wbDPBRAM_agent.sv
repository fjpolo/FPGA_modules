class wbDPBRAM_agent extends uvm_agent;
    `uvm_component_utils(wbDPBRAM_agent)
    
    wbDPBRAM_driver driver;
    wbDPBRAM_monitor monitor;
    uvm_sequencer #(wbDPBRAM_transaction) sequencer;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = wbDPBRAM_monitor::type_id::create("monitor", this);
        if(get_is_active() == UVM_ACTIVE) begin
            driver = wbDPBRAM_driver::type_id::create("driver", this);
            sequencer = uvm_sequencer #(wbDPBRAM_transaction)::type_id::create("sequencer", this);
        end
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        monitor.vif = vif;
        if(get_is_active() == UVM_ACTIVE) begin
            driver.vif = vif;
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction
    
    virtual wbDPBRAM_if vif;
endclass
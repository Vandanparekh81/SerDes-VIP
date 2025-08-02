class serdes_agent extends uvm_agent;

  `uvm_component_utils(serdes_agent);
  serdes_agent_config agt_cfg;
  serdes_driver drv;
  serdes_sequencer seqr;
  serdes_monitor mon;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    
    if(agt_cfg.active == UVM_ACTIVE) begin
      drv = serdes_driver::type_id::create("drv", this);
      drv.parallel_driver = agt_cfg.is_parallel;
      seqr = serdes_sequencer::type_id::create("seqr", this);
    end

    mon = serdes_monitor::type_id::create("mon", this);
    mon.is_parallel = agt_cfg.is_parallel;
    mon.is_active = agt_cfg.is_active;
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(agt_cfg.active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction : connect_phase

endclass : serdes_agent


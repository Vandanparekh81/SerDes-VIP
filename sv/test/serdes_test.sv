class serdes_test extends uvm_test;

   `uvm_component_utils(serdes_test);
   serdes_env env;
   serdes_sequence seq[2];
   serdes_test_config test_cfg;
   virtual serdes_interface vif;

  function new (string name, uvm_component parent);
    super.new(name, parent);
    test_cfg = serdes_test_config::type_id::create("test_cfg");
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual serdes_interface)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    env = serdes_env::type_id::create("env", this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);

    foreach(seq[i]) begin
      seq[i] = serdes_sequence::type_id::create($sformatf("seq[%0d]", i));
      seq[i].is_parallel = env.agt[i*2].agt_cfg.is_parallel;
      `uvm_info(get_type_name(), $sformatf("seq[%0d].is_parallel = %b | env.agt[%0d].agt_cfg.is_parallel = %b", i,seq[i].is_parallel,i,env.agt[i*2].agt_cfg.is_parallel), UVM_LOW)
    end

    foreach(env.scb[i]) begin
      env.scb[i].test_cfg = test_cfg;
    end

    fork
      seq[0].start(env.agt[0].seqr);
      seq[1].start(env.agt[2].seqr);
    join

    phase.phase_done.set_drain_time(this, 7000);
    phase.drop_objection(this);

  endtask : run_phase

  virtual function void report_phase(uvm_phase phase);
    if((seq[0].transaction_count+1 == env.scb[0].actual_count) && (seq[1].transaction_count+1 == env.scb[1].actual_count)) begin
      `uvm_info("Report_Phase of test", $sformatf("Testcase Passed"), UVM_LOW)
    end
    
    else begin
      `uvm_error("Report phase of test",$sformatf("Testcase Failed"))
    end
  endfunction : report_phase


endclass : serdes_test

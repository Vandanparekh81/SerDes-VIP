// -------------------------------------------------------------------------------------------- //
// This is test class 
// This class basically create the environment component and it will create the env and sequence and start to sequence on the sequencer and it also check total number of transactions is equal to scoreboard actual transaction
// -------------------------------------------------------------------------------------------- //

class serdes_same_data_for_tx_rx_test extends uvm_test;

   // Factory registration of test class     
   `uvm_component_utils(serdes_same_data_for_tx_rx_test);

   // Properties declaration of test class
   serdes_env env; // Serdes env class instance
   serdes_same_data_for_tx_rx_sequence seq[2]; // Two instance of sequence one for parallel sequencer and one for serial sequencer
   serdes_test_config test_cfg; // Test config class Instance
   int serial_transaction_count; // Serial transaction count
   int parallel_transaction_count; // Parallel transaction count
   real serial_clk_period;
   real drain_time;
   virtual serdes_interface vif; // Virtual Interface handle
   string force_path = "tb_top.serdes_reset";
   event synchro_between_seq;

  // Constructor of serdes_same_data_for_tx_rx_test class
  function new (string name, uvm_component parent);
    super.new(name, parent);
    test_cfg = serdes_test_config::type_id::create("test_cfg"); // Creation of test_cfg class instance
  endfunction : new

  // Build phase of serdes test class
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Get interface from tb_top using config db
    if(!uvm_config_db#(virtual serdes_interface)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});

    // Get Serdes Speed from tb_top using config db
    if(!uvm_config_db#(real)::get(this, "", "serial_clk_period", serial_clk_period))
      `uvm_fatal("NO_SERIAL_CLK_PERIOD",{"serial_clk_period must be set for: ",get_full_name()});

    `uvm_info(get_type_name(), $sformatf("serial_clk_period = %f", serial_clk_period), UVM_LOW)
    drain_time = (serial_clk_period * 20) * 1000;
    `uvm_info(get_type_name(), $sformatf("Drain time = %0d ps", drain_time), UVM_LOW)

    env = serdes_env::type_id::create("env", this); // Cretion of env class instance
  endfunction : build_phase

  // Connect phase of test class
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  // End of elaboration phase of test class
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("Test EOE Phase", $sformatf("Inside the EOE Phase of test class"), UVM_LOW)
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  // Run phase of test class
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this); // Objection is raised

    // Foreach loop of sequence instance here the sequence is created and if it is parallel sequence then is_parallel = 1 otherwise is_parallel = 0
    foreach(seq[i]) begin
      seq[i] = serdes_same_data_for_tx_rx_sequence::type_id::create($sformatf("seq[%0d]", i)); // Creation of sequence
      seq[i].is_parallel = env.agt[i*2].agt_cfg.is_parallel; // Is_parallel configuration
      `uvm_info(get_type_name(), $sformatf("seq[%0d].is_parallel = %b | env.agt[%0d].agt_cfg.is_parallel = %b", i,seq[i].is_parallel,i,env.agt[i*2].agt_cfg.is_parallel), UVM_LOW)
      seq[i].synchro_seq = synchro_between_seq;
    end

    foreach(env.scb[i]) begin
      env.scb[i].test_cfg = test_cfg; // Provide the test config instance to scoreboard
    end

    // Inside the fork join the sequende is started
    fork
      begin
        #13000;
        uvm_hdl_force(force_path, 1'b0);
        `uvm_info("RESET", $sformatf("RESET_dEasserted"), UVM_LOW)
      end
      seq[0].start(env.agt[0].seqr); // Sequence is started on sequencer 1
      seq[1].start(env.agt[2].seqr); // Sequence is started on sequencer 2
    join
    phase.phase_done.set_drain_time(this, drain_time); // Drain time 
    phase.drop_objection(this); // Objection dropped

  endtask : run_phase

  // Report phase of test
  // Inside the report phase the transaction count is checked and if it is match with actual count of respective scoreboard then testcase is passed otherwise it is display uvm error as testcase is failed
  virtual function void report_phase(uvm_phase phase);
    if((test_cfg.parallel_transaction_count == env.scb[0].match) && (test_cfg.serial_transaction_count == env.scb[1].match)) begin
      `uvm_info("Report_Phase of test", $sformatf("Testcase Passed"), UVM_LOW)
    end
    
    else begin
      `uvm_error("Report phase of test",$sformatf("Testcase Failed"))
    end
  endfunction : report_phase

endclass : serdes_same_data_for_tx_rx_test

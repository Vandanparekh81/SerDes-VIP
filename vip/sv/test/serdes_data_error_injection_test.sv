// -------------------------------------------------------------------------------------------- //
// This is data_error_injection test class 
// This class basically create the environment component and it will create the env and sequence and start to sequence on the sequencer and it also check total number of transactions is equal to scoreboard actual transaction
// this testclass verified data error injection in this testcase sequence directly send original packet to scoreboard and after that it toggle one bit of data and send to sequencer
// Scoreboard inject the error during the comparison
// -------------------------------------------------------------------------------------------- //

class serdes_data_error_injection_test extends uvm_test;

   // Factory registration of test class     
   `uvm_component_utils(serdes_data_error_injection_test);

   // Properties declaration of test class
   serdes_env env; // Serdes env class instance
   serdes_data_error_injection_sequence seq[2]; // Two instance of sequence one for parallel sequencer and one for serial sequencer
   serdes_test_config test_cfg; // Test config class Instance
   int serial_transaction_count; // Serial transaction count
   int parallel_transaction_count; // Parallel transaction count
   real serial_clk_period;
   real drain_time;
   virtual serdes_interface vif; // Virtual Interface handle
   string force_path = "tb_top.serdes_reset";


  // Constructor of serdes_data_error_injection_test class
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

    // Drain time calculation
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

    // Print the topology
    uvm_top.print_topology();

    // For this data error injection testcase purpose scoreboard data error injection become 1
    foreach(env.scb[i]) begin
      env.scb[i].data_error_injection = 1;
    end

  endfunction : end_of_elaboration_phase

  // Run phase of test class
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this); // Objection is raised

    // Foreach loop of sequence instance here the sequence is created and if it is parallel sequence then is_parallel = 1 otherwise is_parallel = 0
    foreach(seq[i]) begin
      seq[i] = serdes_data_error_injection_sequence::type_id::create($sformatf("seq[%0d]", i)); // Creation of sequence
      seq[i].is_parallel = env.agt[i*2].agt_cfg.is_parallel; // Is_parallel configuration
      `uvm_info(get_type_name(), $sformatf("seq[%0d].is_parallel = %b | env.agt[%0d].agt_cfg.is_parallel = %b", i,seq[i].is_parallel,i,env.agt[i*2].agt_cfg.is_parallel), UVM_LOW)
    end

    foreach(env.scb[i]) begin
      env.scb[i].test_cfg = test_cfg; // Provide the test config instance to scoreboard
    end

    // Inside the fork join the sequende is started
    fork
      // Reset Initiation From Test
      begin
        #1000;
        uvm_hdl_force(force_path, 1'b0);
        `uvm_info("RESET", $sformatf("RESET_dEasserted"), UVM_LOW)
      end
      seq[0].start(env.agt[0].seqr); // Parallel Sequence is started on Parallel sequencer
      seq[1].start(env.agt[2].seqr); // Serial Sequence is started on Serial sequencer
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


endclass : serdes_data_error_injection_test


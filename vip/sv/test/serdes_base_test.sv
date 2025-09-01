//-----------------------------------------------------------------------------//
// File Name : serdes_base_test.sv
// Author Name : Vandan Parekh
// Propetier Name : ASICraft Technologies LLP.
// Decription : This is base test class inside this all the reusable content
// is written which is used by all the test class and all the test class 
// extended from the base test class. Inside this class env is created and 
// other requirements which is used by this class is written here
// ----------------------------------------------------------------------------//

class serdes_base_test extends uvm_test;
  `uvm_component_utils(serdes_base_test)
  serdes_env env; // Serdes env class instance
  serdes_test_config test_cfg; // Test config class Instance
  real serial_clk_period;
  real drain_time;
  virtual serdes_interface vif; // Virtual Interface handle
  string force_path = "tb_top.serdes_reset";
  
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

    `uvm_info(get_type_name(), $sformatf("serial_clk_period = %f", serial_clk_period), UVM_HIGH)
    drain_time = (serial_clk_period * 20) * 1000;
    `uvm_info(get_type_name(), $sformatf("Drain time = %0d ps", drain_time), UVM_LOW)

    env = serdes_env::type_id::create("env", this); // Cretion of env class instance
  endfunction : build_phase

  virtual task reset(int reset_deassert_time = 1000);
    #reset_deassert_time;
    uvm_hdl_force(force_path, 1'b0);
    test_cfg.serdes_reset = 0;
    `uvm_info("RESET", $sformatf("RESET_dEasserted"), UVM_DEBUG)
  endtask : reset

  // Connect phase of test class
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  // End of elaboration phase of test class
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("Base Test EOE Phase", $sformatf("Inside the EOE Phase of Base test class"), UVM_DEBUG)
    uvm_top.print_topology();
    foreach(env.scb[i]) begin
      env.scb[i].scoreboard_enable = test_cfg.scoreboard_enable;
    end
  endfunction : end_of_elaboration_phase

  // Run phase of test class
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask : run_phase
  
  // Report phase of test
  // Inside the report phase the transaction count is checked and if it is match with actual count of respective scoreboard then testcase is passed otherwise it is display uvm error as testcase is failed
  virtual function void report_phase(uvm_phase phase);
    if(env.scb[0].scoreboard_enable) begin
      if((test_cfg.parallel_transaction_count == env.scb[0].match) && (test_cfg.serial_transaction_count == env.scb[1].match)) begin
        `uvm_info("Report_Phase of test", $sformatf("Testcase Passed"), UVM_LOW)
      end
      
      else begin
        `uvm_error("Report phase of test",$sformatf("Testcase Failed"))
      end
    end

    else begin
      `uvm_info(get_type_name(), $sformatf("Scoreboard is Disabled so no comparison is happen"), UVM_LOW)
    end
      
  endfunction : report_phase

endclass : serdes_base_test

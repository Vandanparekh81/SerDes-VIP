//-----------------------------------------------------------------------------------//
// This is driver class
// This is responsible to drive transactions from sequencer to interface
// This driver component is resusable in my testbench architecture there are two active agent and there are two passive agent and so two active agent driver has a different task one is drive serial data and one is drive parallel data  so this both driver task that can be taken by this driver
//-----------------------------------------------------------------------------------//

// Macro for using interface modport and clocking block of driver 
`define DRIV_IF vif.driver_cb

class serdes_driver extends uvm_driver #(serdes_transaction);

  // Factory registration of driver class
  `uvm_component_utils(serdes_driver)

  //Properties declaration of driver
  virtual serdes_interface.DRIVER vif; //Virtual interface handle 
  bit parallel_driver; // This is bit is responsible to manage both task of driver
  
  // Constructor of driver
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //Build phase of driver
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("Driver Build Phase", $sformatf("Inside the build phase of driver class"), UVM_LOW)

    //We get interface using config_db which is set from top module using config_db
    if(!uvm_config_db#(virtual serdes_interface.DRIVER)::get(this, "", "drv_vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    
    //if(!uvm_config_db#(int)::get(null, "", "is_parallel", parallel_driver))
      //`uvm_fatal("NO_is_parallel",{"do not get value for is parallel from agent_config: ",get_full_name(),".parallel_driver"});  
    `uvm_info(get_type_name(), $sformatf("BUILD parallel_driver = %b", parallel_driver), UVM_LOW)

  endfunction : build_phase
  
  //Connect phase of driver
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("Driver Connect Phase", $sformatf("Inside the Connect Phase of driver class"), UVM_LOW)
  endfunction : connect_phase
  

  //EOE Phase of driver
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("Driver EOE Phase", $sformatf("Inside the EOE Phase of driver class"), UVM_LOW)
  endfunction : end_of_elaboration_phase

  //Run phase of driver
  virtual task run_phase(uvm_phase phase);
      
      // When reset is off then driver starts to drive the transaction
      forever begin
        fork

          // Thread 1
          // When reset is off then this thread drive the data to interface there are two driver in my tb_architecture one is driving parallel data another one driving serial data this all take care by drive task
          begin
            
            if(!vif.serdes_reset) begin
              
              seq_item_port.get_next_item(req);// Get the transaction from sequencer
              `uvm_info(get_type_name(), $sformatf("after get next item req.Tx0 = %b | req.Rx0_p = %b | req.Rx0_n = %b", req.Tx0,req.Rx0_p,req.Rx0_n), UVM_LOW)
              drive(parallel_driver); // Drive task if parallel driver is called this task then it will drive parallel data to interface otherwise it will drive serial data
              seq_item_port.item_done(); // When driving data to interface is completed then it will give item done
            end

            //This condition when reset is on
            else begin
              wait(!vif.serdes_reset); // Wait to reset goes off
            end

          end

          //Thread 2
          //This is for reset condition task when the reset is on it will drive default values to interface
          begin

            //Reset condition 
            if(vif.serdes_reset) begin
              reset(); // Call the reset task which will drive default values to interface
            end

            else begin
              wait(vif.serdes_reset); // Wait for reset goes high
            end

          end
        join_any
      end
  endtask : run_phase

  // This task drive serial data to interface
  virtual task drive(bit parallel_driver);
    
    // If it is a serial agent driver then it is drive serial data to interface
    if(parallel_driver == 0) begin
      @(posedge vif.serial_clk); // Wait for posedge of serial clock
      `DRIV_IF.Rx0_p <= req.Rx0_p; // Drive Rx0_p to interface
      `DRIV_IF.Rx0_n <= req.Rx0_n; // Drive Rx0_n to interface
      `uvm_info(get_type_name(), $sformatf("After serial drive DRIV_IF.Rx0_p = %b | DRIV_IF.Rx0_n = %0d",`DRIV_IF.Rx0_p, `DRIV_IF.Rx0_n), UVM_LOW)

    end

    //If it is parallel agent driver then it is drive parallel data to interface
    else begin
      @(posedge vif.parallel_clk); // Wait for posedge parallel clock
      `DRIV_IF.Tx0 <= req.Tx0; // Drive Tx0 to interface
      `uvm_info(get_type_name(), $sformatf("After parallel drive DRIV_IF.Tx0 = %b | DRIV_IF.Tx0 = %0d",`DRIV_IF.Tx0, `DRIV_IF.Tx0), UVM_LOW)
    end

  endtask : drive

  // This task is for reset condition
  virtual task reset();
    `DRIV_IF.Rx0_p <= 0; // Drive 0 at Rx0_p
    `DRIV_IF.Rx0_n <= 1; // Drive 1 at Rx0_n
    `DRIV_IF.Tx0 <= 0; // Drive 0 to Tx0
    wait(!vif.serdes_reset); // Wait fotr reset goes off
  endtask : reset

endclass : serdes_driver

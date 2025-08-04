//----------------------------------------------------------------------------------------------//
// This is my agent class
// This class is create sequencer, driver and monitor according to agent state  means if agent state is active then it will create all this three components otherwise it will only create monitor component and this all process happen inside build phase
// Insidr the connect phase the connection between driver and sequencer is
// happen it is basically connect driver seq_item_pull_port to sequencer seq_item_pull_imp port
//----------------------------------------------------------------------------------------------//

class serdes_agent extends uvm_agent;

  // Factory Registration of agent class
  `uvm_component_utils(serdes_agent);

  //Properties declaration of agent class
  serdes_agent_config agt_cfg; // Agent config class Instance for configuring it is parallel or serial and it is active or passive
  serdes_sequencer seqr; // Sequencer Instance
  serdes_driver drv; // Driver Instance
  serdes_monitor mon; // Monitor Instance

  //Constructor of serdes agent class
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //This is a build phase of serdes_agent class inside this build phase driver, sequencer, monitor creation is happen if agent is active otherwise only monitor creation is happen
  //This active passive consider from agent_config active bit according to that logic is written
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    
    //agt_cfg.active == UVM_ACTIVE then it will satisfy the below condition then driver and sequencer creation is happen
    if(agt_cfg.active == UVM_ACTIVE) begin
      drv = serdes_driver::type_id::create("drv", this); // Creation of driver
      drv.parallel_driver = agt_cfg.is_parallel; // In my tb_architecture there are two driver one driver drive parallel data only so it will be called as parallel driver and other driver drive serial data so it will be called as serial driver
      seqr = serdes_sequencer::type_id::create("seqr", this); // Creation of sequencer is happen 
    end

    mon = serdes_monitor::type_id::create("mon", this); // Creation of monitor 

    // There are 4 monitor in my tb_architecture 

    // one sample parallel data Tx0 which is input to serializer so it will be called as active parallel monitor and passive parallel monitor sample  deserializer output Rx0 which is parallel 

    // active serial monitor sample serial data which is input to deserializer Rx0_p and Rx0_n and parallel serial monitor sample serial data which is output of serializer Tx0_p and Tx0_n
    mon.is_parallel = agt_cfg.is_parallel; // This will configure it is parallel or not
    mon.is_active = agt_cfg.is_active; // This will configure it is active or not
  endfunction : build_phase

  //This is connect phase inside this the connection between sequencer and driver is happen if the agent is active otherwise driver and sequencer is not created so connection is not happen
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(agt_cfg.active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction : connect_phase

endclass : serdes_agent


// ---------------------------------------------------------------------------------------------------------- //
// This serdes environment class
// This env class consists agent and scoreboard in my tb_architecture there are 4 agents and two scoreboard and this all creation is happen inside build phase and also the connection between monitor and scoreboards is happen here
// ---------------------------------------------------------------------------------------------------------- //

class serdes_env extends uvm_env;

  // Factory Registration
  `uvm_component_utils(serdes_env);

  //Properties Declaration of Scoreboard
  int no_of_agents = 4; // Variable for storing number of agents which is give from command line
  
  serdes_agent_config cfg[4]; // considering 4 agents for that 0 : Active parallel agent config || 1 : passive paralllel agent config || 2 : active serial agent config || 3 : passive serial agent config
  
  serdes_agent agt[4];// considering 4 agent for that 0 : Active parallel agent || 1 : Passive parallel agent || 2 : active serial agent || 3 : passive serial agent

  serdes_scoreboard scb[2]; // Variable for storing number of scoreboards which is divide by 2 of number of agents
  serdes_subscriber sub[2]; // Variable for storing number of subscribers which is divide by 2 of number of agents
  bit is_tx;
  // Constructor of serdes_env class
  function new (string name, uvm_component parent);
    super.new(name, parent);
    
    uvm_config_db #(int)::set(null, "", "no_of_agt", no_of_agents);

    //Creation of agent config is happen
    foreach(cfg[i]) begin
      
      //This config db set which agt_cfg number will be going for create according that is_parallel and is_active will configure which is inside agent_config class
      uvm_config_db #(int) :: set(null, "", "current_agt_no", i);
      cfg[i] = serdes_agent_config::type_id::create($sformatf("cfg[%0d]", i)); // Creation of agent config class instances
    end

  endfunction : new

  //Build phase of env inside this agent and scoreboard is created and also there two scoreboard in my tb_Architecture one for tx and one for rx data 
  //The scoreboard is tx or rx that will be given from here
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);

    //below the is_parallel and is_active value is given to agent
    foreach(agt[i]) begin
      agt[i] = serdes_agent::type_id::create($sformatf("agt[%0d]", i), this); // creation of agent
      agt[i].agt_cfg = cfg[i]; // according to agent nu,ber config is also given
      `uvm_info(get_type_name(), $sformatf("agt[%0d].agt_cfg.is_parallel = %b | agt[%0d].agt_cfg.is_active = %b", i,agt[i].agt_cfg.is_parallel,i, agt[i].agt_cfg.is_active), UVM_LOW)
    end

    // There are two scoreboards in my testbench architecture one is only stores tx data Tx0 and Tx0_p and Tx0_n and compare that if they match then pass otherwise fail
    // Second scoreboard collect Rx0 and Rx0_p and Rx0_n data from monitor and compare that if they match then pass successfully otherwise it is fail
    foreach(scb[i]) begin
      scb[i] = serdes_scoreboard::type_id::create($sformatf("scb[%0d]", i), this); // Creation of Scoreboard
      if(i < (no_of_agents/4))begin
        scb[i].is_tx = 1; // First scoreboard is tx scoreboard 
      end
      else begin
        scb[i].is_tx = 0; // Second scoreboard is rx scoreboard
      end
    end

    foreach(sub[i]) begin
      if(i < (no_of_agents/4))begin
        is_tx = 1; // First subscriber is tx subscriber 
      end
      else begin
        is_tx = 0; // Second subscriber is rx subscriber
      end
      uvm_config_db#(int)::set(this, "*", "is_tx", is_tx);
      sub[i] = serdes_subscriber::type_id::create($sformatf("sub[%0d]", i), this); // Creation of Subscriber
    end

     /* foreach(agt_srl) begin
      agt_srl[i] = serdes_agent::type_id::create($sformatf("agt_srl[%0d]", i), this);
      agt_srl[i].agt_cfg = cfg_srl[i];
    end */

  endfunction : build_phase

  //This is connect phase of env
  //It is connect the monitor with scoreboard
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt[0].mon.packet_collected_port.connect(scb[0].expected_imp);
    agt[0].mon.packet_collected_port.connect(sub[0].expected_imp);
    agt[1].mon.packet_collected_port.connect(scb[1].actual_imp);
    agt[1].mon.packet_collected_port.connect(sub[1].actual_imp);
    agt[2].mon.packet_collected_port.connect(scb[1].expected_imp);
    agt[2].mon.packet_collected_port.connect(sub[1].expected_imp);
    agt[3].mon.packet_collected_port.connect(scb[0].actual_imp);
    agt[3].mon.packet_collected_port.connect(sub[0].actual_imp);
  endfunction : connect_phase
    
endclass : serdes_env


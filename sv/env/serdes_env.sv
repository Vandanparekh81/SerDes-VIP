class serdes_env extends uvm_env;

  `uvm_component_utils(serdes_env);
  int no_of_agents;
  
  serdes_agent_config cfg[]; // considering 4 agents for that 0 : Active parallel agent config || 1 : passive paralllel agent config || 2 : active serial agent config || 3 : passive serial agent config
  
  serdes_agent agt[];// considering 4 agent for that 0 : Active parallel agent || 1 : Passive parallel agent || 2 : active serial agent || 3 : passive serial agent

  serdes_scoreboard scb[];

  function new (string name, uvm_component parent);
    super.new(name, parent);
    if (!$value$plusargs("NO_OF_AGENTS=%d", no_of_agents)) begin
      $display("Warning: You did not provide a value for number of agents. Using default.");
      no_of_agents = 4; 
    end 
    else begin
      $display("Number of agents is = %0d", no_of_agents);
    end
    cfg = new[no_of_agents];
    agt = new[no_of_agents];
    scb = new[no_of_agents/2];


    uvm_config_db #(int)::set(null, "", "no_of_cfg", no_of_agents);

    foreach(cfg[i]) begin
      uvm_config_db #(int) :: set(null, "", "a", i);
      cfg[i] = serdes_agent_config::type_id::create($sformatf("cfg[%0d]", i));
    end

    /* foreach(cfg_srl) begin
      cfg_srl[i] = serdes_agent_config::type_id::create($sformatf("cfg_srl[%0d]", i));
      cfg.srl[i].is_parallel = 0;
      cfg.srl[i].active = (i==0) ? UVM_ACTIVE : UVM_PASSIVE;
    end */
    
  endfunction : new

  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);

    foreach(agt[i]) begin
      agt[i] = serdes_agent::type_id::create($sformatf("agt[%0d]", i), this);
      agt[i].agt_cfg = cfg[i];
      $display("Agent %0d is created", i);
      `uvm_info(get_type_name(), $sformatf("agt[%0d].agt_cfg.is_parallel = %b | agt[%0d].agt_cfg.is_active = %b", i,agt[i].agt_cfg.is_parallel,i, agt[i].agt_cfg.is_active), UVM_LOW)
    end

    foreach(scb[i]) begin
      scb[i] = serdes_scoreboard::type_id::create($sformatf("scb[%0d]", i), this);
      if(i < (no_of_agents/4))begin
        scb[i].is_tx = 1;
      end
      else begin
        scb[i].is_tx = 0;
      end
    end

     /* foreach(agt_srl) begin
      agt_srl[i] = serdes_agent::type_id::create($sformatf("agt_srl[%0d]", i), this);
      agt_srl[i].agt_cfg = cfg_srl[i];
    end */

  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt[0].mon.packet_collected_port.connect(scb[0].expected_imp);
    agt[1].mon.packet_collected_port.connect(scb[1].actual_imp);
    agt[2].mon.packet_collected_port.connect(scb[1].expected_imp);
    agt[3].mon.packet_collected_port.connect(scb[0].actual_imp);
  endfunction : connect_phase
    
endclass : serdes_env


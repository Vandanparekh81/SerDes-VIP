//---------------------------------------------------------------------------------------------------------//
// This is agent config class
// In my tb architecture there are 4 agents two parallel(Active, Passive) and  two serial(Active, passive) make 4 agents from one agent class this agent_config class help me, it basically give reusability 
// This class basically configure is_parallel = 1 if it is parallel agent otherwise 0 and it is configure active = UVM_ACTIVE if it is active otherwise it will configure as a UVM_PASSIVE
// -------------------------------------------------------------------------------------------------------//

class serdes_agent_config extends uvm_object;

  // Factory Registration
  `uvm_object_utils (serdes_agent_config)

  // Properties declaration
  int no_of_agt; // This variable represent total number of agents in my architecture it is 4
  int current_agt_no; // This variable represent the current number of agent like during first agent creation it is 0, for second it is 1 likewise 2 and 3
  bit is_parallel; // This variable represent it is parallel agent or serial agent if 1 then it is parallel agent and if it is 0 then it is serial agent
  bit is_active; // This variable represent it is passive agent or active agent if it is 1 then it is active agent otherwise it is passive agent
  uvm_active_passive_enum active = UVM_ACTIVE; // This enum is taken for give active and passive agent
  
  // Constructor of serdes_config
  function new(string name = "serdes_agent_config");
    super.new(name);

    // This all variable sets in env class using uvm_config_db::set
    if(!uvm_config_db#(int)::get(null, "", "no_of_agt", no_of_agt)) // Total number of agents get from env
      `uvm_fatal("NO Number agent is get ",{"number of agent must be set for: ",get_full_name()}); 
    if(!uvm_config_db#(int)::get(null, "", "current_agt_no", current_agt_no))  // The current agent number
      `uvm_fatal("NO_current agent number is get",{"current agent number is must be set for: ",get_full_name()});
  
    // So for my architecture there 4 agents first two are parallel and other two is serial
    // Below condition is for if current agent number is 0 and 1 then it will set is_parallel bit 1
    if(current_agt_no < no_of_agt/2) begin 
      is_parallel = 1; 
      `uvm_info(get_type_name(), $sformatf("current_agt_no = %0d and is_parallel = %b", current_agt_no, is_parallel), UVM_LOW)
    end
    
    //Below condition is satisfy if my agent number is 2 and 3 then it will set is_parallel bit 0 it will make them serial agent 
    else begin
      is_parallel = 0;
    end
    
    //In my tb_Architecture first parallel agent and first serial agent is active other two are passive
    //Below condition is satisfy if the current agent number is 0 and 2 means first parallel agent and first serial agent
    if(current_agt_no % 2 == 0) begin
      active = UVM_ACTIVE;
    end
   
    else begin
      active = UVM_PASSIVE;
    end


    //It is also set this agent or passive
    is_active = (active == UVM_ACTIVE) ? 1 : 0 ; 
  endfunction : new

endclass : serdes_agent_config

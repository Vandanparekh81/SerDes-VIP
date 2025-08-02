class serdes_agent_config extends uvm_object;
  `uvm_object_utils (serdes_agent_config)

  int no_of_cfg;
  int a;
  bit is_parallel;
  bit is_active;
  uvm_active_passive_enum active = UVM_ACTIVE;
  
  function new(string name = "serdes_agent_config");
    super.new(name);
    uvm_config_db #(int)::get(null, "", "no_of_cfg", no_of_cfg);
    uvm_config_db #(int)::get(null, "", "a", a);
  
    if(a < no_of_cfg/2) begin
      is_parallel = 1;
      $display("[%0t] a = %0d and is_parallel = %b", $time, a, is_parallel);
    end
    
    else begin
      is_parallel = 0;
      $display("[%0t] a = %0d and is_parallel = %b", $time, a, is_parallel);
    end
    
    if(a % 2 == 0) begin
      active = UVM_ACTIVE;
    end
   
    else begin
      active = UVM_PASSIVE;
    end

    is_active = (active == UVM_ACTIVE) ? 1 : 0 ;
    //uvm_config_db #(int)::set(null, "", "is_parallel", is_parallel);
    //$display("[%0t] AFter set config db is parallel a = %0d and is_parallel = %b", $time, a, is_parallel);
    //uvm_config_db #(int)::set(null, "", "is_active", is_active);
    //$display("[%0t] after set config db is active a = %0d and is_parallel = %b | is_active = %b", $time, a, is_parallel, is_active);
  endfunction : new

endclass : serdes_agent_config

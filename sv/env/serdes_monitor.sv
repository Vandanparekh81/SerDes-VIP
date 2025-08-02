//--------------------------------------------------------------------------------------------------/
// This is monitor class
// monitor class basically samples the signal from interface and make packet of all signals and send to scoreboard using uvm_analysis_port.
// This is reusable monitor class there are 4 agents in my testbench architecture and that has all different task that can be implemented inside this monitor.
//--------------------------------------------------------------------------------------------------/

class serdes_monitor extends uvm_monitor;

  // factory Registration
  `uvm_component_utils(serdes_monitor)

  //Declarations 
  parameter WIDTH = 10;
  virtual serdes_interface.MONITOR vif; // Virtual interface handle
  uvm_analysis_port #(serdes_transaction) packet_collected_port; //Analysis port used to broadcast transaction packet.
  serdes_transaction mon_pkt; // Transaction Packet.
  bit is_parallel; // This bit tells agent is serial parallel according to this and is_active i have to call the task.
  bit is_active; // This bit tells agent is active or passive.

  // Constructor of monitor class
  function new (string name, uvm_component parent);
    super.new(name, parent);
    packet_collected_port = new("packet_collected_port", this);
  endfunction : new

  // Reusable task for all monitor 
  // inside this task i have taken all 4 monitor activities 
  task monitoring(serdes_transaction mon_pkt);
    
    // If parallel agent monior call this task then it is go inside this if loop
    if(is_parallel == 1) begin

      // If parallel active agent monitor calls monitoring task then it will go inside this loop and at the posedge of parallel clk monitor Tx0 which is input for serializer
      if(is_active == 1) begin 
        @(posedge vif.parallel_clk); 
        mon_pkt.Tx0 = vif.monitor_cb.Tx0; // Sample Tx0 pparallelarallel data from interface
        `uvm_info(get_type_name(), $sformatf("ACTIVE_PARALLEL_MONITOR mon_pkt.Tx0 = %b | mon_pkt.Tx0 = %0d", mon_pkt.Tx0, mon_pkt.Tx0), UVM_LOW)
      end

      // If parallel passive agent monitor call this task then it will go inside  this else loop and sample parallel output Rx0 of deserializer at the posedge of parallel clock
      else begin
        @(posedge vif.parallel_clk);
        mon_pkt.Rx0 = vif.monitor_cb.Rx0; // Sample Rx0 parallel data from interface
        `uvm_info(get_type_name(), $sformatf("PASSIVE_PARALLEL_MONITOR mon_pkt.Rx0 = %b | mon_pkt.Rx0 = %0d", mon_pkt.Rx0, mon_pkt.Rx0), UVM_LOW)
      end

    end

    // If serial agent monitor call the monitor task then it will go inside this else loop
    else begin

      // If serial active agent call the monitoring task then it will go inside this if loop and it will sample interface serial signal which is input of deserializer at the posedge of serial clock
      
      // it will convert that data into parallel form for sending into scoreboard
      if(is_active == 1) begin
        for(int count1 = 0; count1 < WIDTH; count1++) begin
          @(posedge vif.serial_clk); 
          mon_pkt.Rx0_p = vif.monitor_cb.Rx0_p; // sample Rx0_p from interface
          mon_pkt.Rx0_n = vif.monitor_cb.Rx0_n; // sample Rx0_p from interface
        `uvm_info(get_type_name(), $sformatf("ACTIVE SERIAL MONITOR serial data | mon_pkt.Rx0_p = %b | mon_pkt.Rx0_n = %b", mon_pkt.Rx0_p, mon_pkt.Rx0_n), UVM_LOW)
          mon_pkt.mon_parallel_Rx0 = {mon_pkt.mon_parallel_Rx0 [WIDTH-2 : 0], mon_pkt.Rx0_p};
        end    
      end

      // If serial passive agent call the monitoring task then it will go inside this else loop and it will sample interface serial signal which is output of serializer at the posedge of serial clock
      
      // it will convert that data into parallel form for sending into scoreboard
      else begin
        for(int count2 = 0; count2 < WIDTH; count2++) begin
          @(posedge vif.serial_clk);
          mon_pkt.Tx0_p = vif.monitor_cb.Tx0_p; // Sample Tx0_p from interface
          mon_pkt.Tx0_n = vif.monitor_cb.Tx0_n; // Sample Tx0_n from interface
        `uvm_info(get_type_name(), $sformatf("PASSIVE SERIAL MONITOR serial data | mon_pkt.Tx0_p = %b | mon_pkt.Tx0_n = %b | count2 = %0d", mon_pkt.Tx0_p, mon_pkt.Tx0_n, count2), UVM_LOW)
          mon_pkt.mon_parallel_Tx0 = {mon_pkt.mon_parallel_Tx0 [WIDTH-2 : 0], mon_pkt.Tx0_p};
        end
        `uvm_info(get_type_name(), $sformatf("HELLO monitor converting serial data into parallel data | mon_pkt.mon_parallel_Tx0 = %b | mon_pkt.mon_parallel_Tx0 = %0d", mon_pkt.mon_parallel_Tx0, mon_pkt.mon_parallel_Tx0), UVM_LOW)
      end
    end

  endtask : monitoring
 
  // When serial active agent is implement monitor then this task is called 
  /* task serial_active_monitor();
    int count = 0;
    bit [WIDTH-1:0] mon_parallel_Rx0;
    for(count = 0; count < WIDTH; count++) begin
      @(posedge vif.serial_clk); 
      mon_pkt.Rx0_p <= MON_IF.Rx0_p; // sample Rx0_p from interface
      mon_pkt.Rx0_n <= MON_IF.Rx0_n; // sample Rx0_p from interface
      mon_parallel_Rx0 <= {mon_parallel_Rx0 [WIDTH-2 : 0], mon_pkt.Rx0_p};
    end
  endtask

  // When serial passive agent is implement monitor then this task is called 
  task serial_passive_monitor();
    bit [WIDTH-1:0] mon_parallel_Tx0; 
    for(int count = 0; count < WIDTH; count++) begin
      @(posedge vif.serial_clk);
      mon_pkt.Tx0_p <= MON_IF.Tx0_p; // Sample Tx0_p from interface
      mon_pkt.Tx0_n <= MON_IF.Tx0_n; // Sample Tx0_n from interface
      mon_parallel_Tx0 <= {mon_parallel_Tx0 [WIDTH-2 : 0], mon_pkt.Tx0_p};
    end
  endtask

  // When parallel active agent is implement monitor then this task is called 
  task parallel_active_monitor();
    @(posedge vif.parallel_clk); 
    mon_pkt.Tx0 <= MON_IF.Tx0; // Sample Tx0 parallel data from interface
  endtask

  // When parallel passive agent is implement monitor then this task is called 
  task parallel_passive_monitor();
    @(posedge vif.parallel_clk);
    mon_pkt.Rx0 <= MON_IF.Rx0; // Sample Rx0 parallel data from interface
  endtask */

  task reset();
    mon_pkt.Tx0 = 0;
    mon_pkt.Rx0 = 0;
    mon_pkt.Tx0_p = 0;
    mon_pkt.Tx0_n = 0;
    mon_pkt.Rx0_p = 0;
    mon_pkt.Rx0_n = 0;
    wait(!vif.serdes_reset);
  endtask : reset

    

  // Build phase of monitor class
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);

    // Get interface using config_fb which is set from top module using config_db
    if(!uvm_config_db#(virtual serdes_interface.MONITOR)::get(this, "", "mon_vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});  
    
    //if(!uvm_config_db#(int)::get(null, "", "is_parallel", is_parallel))
      //`uvm_fatal("NO_is_parallel",{"do not get value for is parallel from agent_config: ",get_full_name(),".is_parallel"});  
    
    //if(!uvm_config_db#(int)::get(null, "", "is_active", is_active))
      //`uvm_fatal("NO_is_active",{"do not get value for is active from agent_config: ",get_full_name(),".is_active"});  

  endfunction : build_phase

  // Connect phase of monitor
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
      `uvm_info(get_type_name(), $sformatf("TIME ANY ACTIVE = %0t", $time), UVM_LOW)
    if(is_parallel == 1 && is_active == 1) begin
      `uvm_info(get_type_name(), $sformatf("TIME PARALLEL ACTIVE = %0t", $time), UVM_LOW)
      @(posedge vif.parallel_clk);
    end

    else if(is_parallel == 1 && is_active  == 0) begin
      `uvm_info(get_type_name(), $sformatf("TIME PARALLEL PASSIVE = %0t", $time), UVM_LOW)
      repeat(2) begin 
        @(posedge vif.parallel_clk);
      end
        `uvm_info(get_type_name(), $sformatf("TIME PARALLEL PASSIVE = %0t", $time), UVM_LOW)
    end

    else if(is_parallel == 0 && is_active == 1) begin
      @(posedge vif.parallel_clk);
      @(posedge vif.serial_clk);
      @(posedge vif.serial_clk);
      `uvm_info(get_type_name(), $sformatf("TIME SERIAL ACTIVE = %0t", $time), UVM_LOW)
    end

    else begin
      @(posedge vif.parallel_clk);
      @(posedge vif.serial_clk);
        `uvm_info(get_type_name(), $sformatf("TIME SERIAL = %0t", $time), UVM_LOW)
    end
      // when reset is off then monitor have to monitor signal from interface
      forever begin
        mon_pkt = serdes_transaction::type_id::create("mon_pkt");
        fork

          // Thread 1
          begin

            if(!vif.serdes_reset) begin
              monitoring(mon_pkt);
              `uvm_info(get_type_name(), $sformatf("Sending transaction: Tx0=%b, Rx0=%b, mon_parallel_Tx0=%b, mon_parallel_Rx0=%b", mon_pkt.Tx0, mon_pkt.Rx0, mon_pkt.mon_parallel_Tx0, mon_pkt.mon_parallel_Rx0), UVM_LOW)
              packet_collected_port.write(mon_pkt);
            end

            else begin
              wait(!vif.serdes_reset);
            end

          end

          //Thread 2
          begin

            if(vif.serdes_reset) begin
              reset();       
            end

            else begin
              wait(vif.serdes_reset);
            end

          end

        join_any
      end

  endtask : run_phase


endclass : serdes_monitor

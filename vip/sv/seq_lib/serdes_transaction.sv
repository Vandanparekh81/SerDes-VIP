//-----------------------------------------------------------------------------------//
// File Name : serdes_transaction.sv
// Author Name : Vandan Parekh
// Propetier Name : ASICraft Technologies LLP.
// Description : This is transaction class in this class we take all the itmes that 
// can send from one component to another component in a packet form and there are 
// some constraint written inside this class that can use to ensure data generate 
// with respect to condition that is written inside that
// ----------------------------------------------------------------------------------//


class serdes_transaction extends uvm_sequence_item;
  
  rand bit [WIDTH-1:0] Tx0; //Parallel input that can be send to serializer
  bit [WIDTH-1:0] Rx0; // Parallel output that can be received from deserializer
  bit [WIDTH-1:0] mon_parallel_Rx0, mon_parallel_Tx0; // This signals is taken for monitor because i have to send parallel packets to scoreboard so there are two monitors that sample serial data so i have to convert that serial data into parallel data

  rand bit [WIDTH-1 : 0] Rx0_p; // parallel data which is go Serially as a input to deserializer
  typedef enum { RANDOM = 0, ALL_ZERO = 1, ALL_ONE = 2, ALTERNATING_5 = 3, ALTERNATING_A = 4, WALKING_1 = 5, WALKING_0 = 6, INCREMENT = 7, DECREMENT = 8} data_pattern_e;
  rand data_pattern_e data_pattern; // Data pattern enum

  bit[WIDTH : 0] walk1 = 1; // Flag for generating walking_1 and walking_0 pattern
  int decrement = 100; // Flag for generating decrement value from 100 to 1 
  int increment = 1; // Flag for generating increment value from 1 to 100
  int serdes_speed; // Speed of serdes which value is taken using config_db and it is set from tb_top for coverage purpose

  // Factory registeration of transaction class and properties
 `uvm_object_utils_begin(serdes_transaction)
   `uvm_field_int(Tx0, UVM_DEFAULT)
   `uvm_field_int(Rx0, UVM_DEFAULT)
   `uvm_field_int(Rx0_p, UVM_DEFAULT)
   `uvm_field_int(serdes_speed, UVM_DEFAULT)
   `uvm_field_int(mon_parallel_Rx0, UVM_DEFAULT)
   `uvm_field_int(mon_parallel_Tx0, UVM_DEFAULT)
   `uvm_field_enum(data_pattern_e, data_pattern, UVM_DEFAULT)
 `uvm_object_utils_end

  // Constructor of transaction class
  function new(string name = "serdes_transaction");
    super.new(name);

    // Config db for serdes_speed
    if(!uvm_config_db#(int)::get(null, "*", "serdes_speed", serdes_speed))
      `uvm_fatal("SERDES_SPEED",{"SERDES_SPEED must be set for: ",get_full_name(),".vif"}); 
  endfunction : new

  //Constraint for generating data pattern like ALL_ZERO, ALL_ONE,ALTERNATING_5, ALTERNATING_A, WALKING_1, WALKING_0, INCREMENT, DECREMENT
  constraint data_pattern_test {if(data_pattern == ALL_ZERO) { Tx0 == 0; Rx0_p == 0; } 
                           else if(data_pattern == ALL_ONE) { Tx0 == 10'h3ff; Rx0_p == 10'h3ff;} 
                           else if(data_pattern ==  ALTERNATING_5){Tx0 == 10'h155; Rx0_p == 10'h155;} 
                           else if(data_pattern == ALTERNATING_A) { Tx0 == 10'h2AA; Rx0_p == 10'h2AA; } 
                           else if(data_pattern == WALKING_1) {Tx0 == walk1; Rx0_p == walk1;}  
                           else if(data_pattern == WALKING_0) {Tx0 == ~(walk1[WIDTH-1:0]); Rx0_p == ~(walk1[WIDTH-1:0]); } 
                           else if(data_pattern == INCREMENT) {Tx0 == increment; Rx0_p == increment; } 
                           else if(data_pattern == DECREMENT) {Tx0 == decrement; Rx0_p == decrement; } 
                           else {Tx0 != 0; Rx0_p != 0;} }

  // Post randomize function for updating flag of their respective patterns
  function void post_randomize();
    if(data_pattern == WALKING_1 || data_pattern == WALKING_0) begin
      walk1 = walk1 * 2;
      if(walk1 == 1024) walk1 = 1;
    end

    if(data_pattern == INCREMENT) begin
      increment = increment + 1;
      if(increment == 101) increment = 1;
    end

    if(data_pattern == DECREMENT) begin
      decrement = decrement - 1;
      if(decrement == 0) decrement = 100;
    end

  endfunction : post_randomize

endclass : serdes_transaction

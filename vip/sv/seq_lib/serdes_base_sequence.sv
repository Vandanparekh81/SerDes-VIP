//-----------------------------------------------------------------------------------//
// File Name : serdes_base_sequence.sv
// Author Name : Vandan Parekh
// Propetier Name : ASICraft Technologies LLP.
// Decription : This is base sequence inside this all the reusable content is written 
// which is used by all the sequence class and all the sequence class extended from 
// the base sequence class. Inside this class env is created and other requirements 
// which is used by this class is written here
// ----------------------------------------------------------------------------------//

class serdes_base_sequence extends uvm_sequence #(serdes_transaction);

  // Factory registration of sequence class
  `uvm_object_utils(serdes_base_sequence);

  // Properties declaration of sequence class
  int serial_transaction_count; // Number of serial transactions
  int parallel_transaction_count; // Number of parallel transactions 

  bit is_parallel; // Indicates if the sequence is for a parallel or serial agent

  // Constructor of sequence class
  function new(string name = "serdes_sequence");
    super.new(name);
    
    // Get serial transaction count from test using config db
    if(!uvm_config_db#(int)::get(null, "*", "serial_transaction_count", serial_transaction_count))
      `uvm_fatal("NO_SERIAL_TRANSACTION_COUNT",{"Serial Transaction count must be set for: ",get_full_name()});
      
    // Get parallel transaction count from test using config db
    if(!uvm_config_db#(int)::get(null, "*", "parallel_transaction_count", parallel_transaction_count))
      `uvm_fatal("NO_PARALLEL_TRANSACTION_COUNT",{"Parallel transaction count must be set for: ",get_full_name()});
  endfunction : new

  // Pre body task
  virtual task pre_body();
    `uvm_info("PRE-BODY", $sformatf("INSIDE PRE-BODY TASK"), UVM_DEBUG)
    `uvm_info("PRE_BODY", $sformatf("serial_transaction_count=%0d, parallel_transaction_count = %0d, is_parallel=%b", serial_transaction_count, parallel_transaction_count, is_parallel), UVM_LOW)
  endtask : pre_body

  // Post body task
  virtual task post_body();
    `uvm_info("POST-BODY", $sformatf("INSIDE POST-BODY TASK"), UVM_DEBUG)
  endtask : post_body

endclass : serdes_base_sequence

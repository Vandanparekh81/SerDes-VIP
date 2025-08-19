
//---------------------------------------------------------------------------------------------//
// This sequence class used to randomize properties of transaction class and responsible for generating different scenarios and this sequence generate basic transactions one for rx and one for tx in serdes tb architecture there are two sequence one generate parallel data and one generate serial data
//---------------------------------------------------------------------------------------------//

class serdes_data_pattern_sequence extends uvm_sequence #(serdes_transaction);

  // Factory registration of sequence class
  `uvm_object_utils(serdes_data_pattern_sequence);

  // Properties declaration of sequence class
  parameter WIDTH = 10;
  serdes_transaction::data_pattern_e data_pattern_seq;
  int parallel_transaction_count, serial_transaction_count;

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
    `uvm_info("PRE-BODY", $sformatf("INSIDE PRE-BODY TASK"), UVM_LOW)
    `uvm_info("PRE_BODY", $sformatf("serial_transaction_count=%0d, parallel_transaction_count = %0d, is_parallel=%b", serial_transaction_count, parallel_transaction_count, is_parallel), UVM_LOW)
    `uvm_info("PRE_BODY", $sformatf("data_pattern_seq=%s" , data_pattern_seq.name()), UVM_LOW)
  endtask : pre_body

  // This body task generate transactions and send to arbitration of sequencer and this task also differentiate between generate serial transaction and parallel transaction
  virtual task body();
    req = serdes_transaction::type_id::create("req"); // Creation of transaction packet
    // IF is_parallel is 1 then it will generate parallel data otherwise it will generate serial data
    if(is_parallel) begin
      // For parallel agent: Generate one transaction with randomized Tx0
      repeat(parallel_transaction_count) begin
        `uvm_info("BODY", $sformatf("Before Start item"), UVM_LOW)
        start_item(req);
        assert(req.randomize() with {data_pattern == data_pattern_seq;});
        `uvm_info("BODY", $sformatf("Parallel transaction: data_pattern = %s | Tx0 in Binary=%b | Tx0 in Decimal = %0d", req.data_pattern.name(),req.Tx0,req.Tx0), UVM_LOW)
        finish_item(req); // This task will return if driver provide item_done
      end
    end

    // If is_parallel is 0 means i have to generate serial transactions 
    else begin
      // For serial agent: Generate 1 transactions for Rx0_p and Rx0_n
      repeat(serial_transaction_count) begin // WIDTH=10 for serikal bits
        start_item(req);
        assert(req.randomize() with {data_pattern == data_pattern_seq;});
        `uvm_info("BODY", $sformatf("Serial transaction: data_pattern = %s | Rx0_p=%b (%0d)", req.data_pattern.name(), req.Rx0_p, req.Rx0_p), UVM_LOW)
        finish_item(req); // This task will return if driver provide item_done
      end
    end
  endtask : body

  // Post body task
  virtual task post_body();
    `uvm_info("POST-BODY", $sformatf("INSIDE POST-BODY TASK"), UVM_LOW)
  endtask : post_body

endclass : serdes_data_pattern_sequence

//---------------------------------------------------------------------------------------------//
// This sequence class used to randomize properties of transaction class and responsible for generating different scenarios and this sequence generate basic transactions one for rx and one for tx in serdes tb architecture there are two sequence one generate parallel data and one generate serial data
//---------------------------------------------------------------------------------------------//

class serdes_opposite_data_for_tx_rx_sequence extends uvm_sequence #(serdes_transaction);

  // Factory registration of sequence class
  `uvm_object_utils(serdes_opposite_data_for_tx_rx_sequence);

  // Properties declaration of sequence class
  parameter WIDTH = 10;

  int serial_transaction_count; // Number of serial transactions
  int parallel_transaction_count; // Number of parallel transactions 

  bit is_parallel; // Indicates if the sequence is for a parallel or serial agent
  event synchro_seq;

  // Constructor of sequence class
  function new(string name = "serdes_opposite_data_for_tx_rx_sequence");
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
    `uvm_info("PRE_BODY", $sformatf("serial_transaction_count=%0d, parallel_transaction_count = %0d, is_parallel=%b", serial_transaction_count, parallel_transaction_count, is_parallel), UVM_LOW)
  endtask : pre_body

  // This body task generate transactions and send to arbitration of sequencer and this task also differentiate between generate serial transaction and parallel transaction
  virtual task body();
    req = serdes_transaction::type_id::create("req"); // Creation of transaction packet
    // IF is_parallel is 1 then it will generate parallel data otherwise it will generate serial data
    if(is_parallel) begin
        `uvm_info("BODY", $sformatf("Begin of parallel"), UVM_LOW)
      // For parallel agent: Generate one transaction with randomized Tx0
      repeat(parallel_transaction_count) begin
        `uvm_info("BODY", $sformatf("Begin of parallel  2"), UVM_LOW)
        start_item(req);
        `uvm_info("BODY", $sformatf("Begin of parallel 3"), UVM_LOW)
        assert(req.randomize() with { Tx0 != 0; });// Ensure non-zero for testing
        uvm_config_db#(int)::set(null, "*", "same_data", req.Tx0);
        -> synchro_seq;
        `uvm_info("BODY", $sformatf("Parallel transaction: Tx0 in Binary=%b | Tx0 in Decimal = %0d", req.Tx0,req.Tx0), UVM_LOW)
        finish_item(req); // This task will return if driver provide item_done
        `uvm_info("BODY", $sformatf("AFTER Finish Item Parallel transaction: Tx0 in Binary=%b | Tx0 in Decimal = %0d", req.Tx0,req.Tx0), UVM_LOW)
      end
    end

    // If is_parallel is 0 means i have to generate serial transactions 
    else begin
        `uvm_info("BODY", $sformatf("Begin of Serial"), UVM_LOW)
      // For serial agent: Generate 1 transactions for Rx0_p and Rx0_n
      repeat(serial_transaction_count) begin // WIDTH=10 for serial bits
        `uvm_info("BODY", $sformatf("Begin of Serial 2"), UVM_LOW)
        start_item(req); 
        `uvm_info("BODY", $sformatf("Begin of Serial 3"), UVM_LOW)
        @(synchro_seq);
        if(!uvm_config_db#(int)::get(null, "*", "same_data", req.Rx0_p))
          `uvm_fatal("NO_SAMEDATA",{"Same data should be set for sequence 1: ",get_full_name()});
        req.Rx0_p = ~req.Rx0_p;
        //assert(req.randomize() with { Rx0_p != 0; }); // Equal distribution for 0 and 1
        `uvm_info("BODY", $sformatf("Serial transaction: Rx0_p=%b (%0d)",req.Rx0_p, req.Rx0_p), UVM_LOW)
        finish_item(req); // This task will return if driver provide item_done
        `uvm_info("BODY", $sformatf("After Finish item Serial transaction: Rx0_p=%b (%0d)",req.Rx0_p, req.Rx0_p), UVM_LOW)
      end
    end
        `uvm_info("BODY", $sformatf("After Finish item Serial transaction: Rx0_p=%b (%0d)",req.Rx0_p, req.Rx0_p), UVM_LOW)
  endtask : body

  // Post body task
  virtual task post_body();
    `uvm_info("POST-BODY", $sformatf("INSIDE POST-BODY TASK"), UVM_LOW)
  endtask : post_body

endclass : serdes_opposite_data_for_tx_rx_sequence




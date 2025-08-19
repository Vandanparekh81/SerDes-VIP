//---------------------------------------------------------------------------------------------//
// This sequence class used to randomize properties of transaction class and responsible for generating different scenarios and this sequence generate basic transactions one for rx and one for tx in serdes tb architecture there are two sequence one generate parallel data and one generate serial data
//---------------------------------------------------------------------------------------------//

class serdes_data_error_injection_sequence extends uvm_sequence #(serdes_transaction);

  // Factory registration of sequence class
  `uvm_object_utils(serdes_data_error_injection_sequence);

  // Properties declaration of sequence class
  parameter WIDTH = 10;

  int serial_transaction_count; // Number of serial transactions
  int parallel_transaction_count; // Number of parallel transactions 

  bit is_parallel; // Indicates if the sequence is for a parallel or serial agent
  string event_name;
  uvm_event exp_event;
  serdes_transaction orig_req;

  // Constructor of sequence class
  function new(string name = "serdes_data_error_injection");
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
  endtask : pre_body

  // This body task generate transactions and send to arbitration of sequencer and this task also differentiate between generate serial transaction and parallel transaction
  virtual task body();
    `uvm_info("INDIDE BODY", $sformatf(" Decimal"), UVM_LOW)
    req = serdes_transaction::type_id::create("req"); // Creation of transaction packet
    orig_req = serdes_transaction::type_id::create("orig_req"); // Creation of transaction packet
    `uvm_info("INDIDE BODY", $sformatf(" HEXA"), UVM_LOW)
    
    // IF is_parallel is 1 then it will generate parallel data otherwise it will generate serial data
    if(is_parallel) begin
      // For parallel agent: Generate one transaction with randomized Tx0
      repeat(parallel_transaction_count) begin
        start_item(req);
        assert(req.randomize() with { Tx0 != 0; }); // Ensure non-zero for testing
        event_name = "tx_exp_event";
        exp_event = uvm_event_pool::get_global(event_name);
        orig_req.copy(req);
        //#10000;
        exp_event.trigger(orig_req);

        `uvm_info("BODY", $sformatf("Parallel transaction: Tx0 in Binary=%b | Tx0 in Decimal = %0d", req.Tx0,req.Tx0), UVM_LOW)
        req.Tx0[0] = ~req.Tx0[0];
        `uvm_info("BODY", $sformatf("Parallel transaction: Tx0 in Binary=%b | Tx0 in Decimal = %0d", req.Tx0,req.Tx0), UVM_LOW)

        finish_item(req); // This task will return if driver provide item_done
      `uvm_info("INDIDE BODY", $sformatf("HELLOSINGLE"), UVM_LOW)
      end
    end

    // If is_parallel is 0 means i have to generate serial transactions 
    else begin
      // For serial agent: Generate 1 transactions for Rx0_p and Rx0_n
      `uvm_info("INDIDE BODY", $sformatf("fejkfhh BINARY"), UVM_LOW)
      repeat(serial_transaction_count) begin // WIDTH=10 for serial bits
      `uvm_info("INDIDE BODY", $sformatf("vdvvvlvhklvklv BINARY"), UVM_LOW)
        start_item(req); 
      `uvm_info("INDIDE BODY", $sformatf("jklvjvjkvjfklv BINARY"), UVM_LOW)
        assert(req.randomize() with { Rx0_p != 0; }); // Equal distribution for 0 and 1
        event_name = "rx_exp_event";
        exp_event = uvm_event_pool::get_global(event_name);
        orig_req.copy(req);
        exp_event.trigger(orig_req);
        `uvm_info("BODY", $sformatf("Serial transaction: Rx0_p=%b",req.Rx0_p), UVM_LOW)
        req.Rx0_p[0] = ~req.Rx0_p[0];
        `uvm_info("BODY", $sformatf("Serial transaction: Rx0_p=%b",req.Rx0_p), UVM_LOW)
        finish_item(req); // This task will return if driver provide item_done
      `uvm_info("INDIDE BODY", $sformatf("oppkdkdlcvl; BINARY"), UVM_LOW)
      end
    end
  endtask : body

  // Post body task
  virtual task post_body();
    `uvm_info("POST-BODY", $sformatf("INSIDE POST-BODY TASK"), UVM_LOW)
  endtask : post_body

endclass : serdes_data_error_injection_sequence



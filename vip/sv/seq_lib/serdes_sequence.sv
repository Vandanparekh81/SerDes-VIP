//-----------------------------------------------------------------------------------------------//
// File Name : serdes_sequence.sv
// Author Name : Vandan Parekh
// Propetier Name : ASICraft Technologies LLP.
// Description : This sequence class used to randomize properties of transaction class and 
// responsible for  generating different scenarios and this sequence generate basic 
// transactions one for rx and one for tx in serdes tb architecture there are two sequence one
// generate parallel data and one generate serial data
//-----------------------------------------------------------------------------------------------//

class serdes_sequence extends serdes_base_sequence;

  // Factory registration of sequence class
  `uvm_object_utils(serdes_sequence);

  // Properties declaration of sequence class
  bit is_parallel; // Indicates if the sequence is for a parallel or serial agent

  // Constructor of sequence class
  function new(string name = "serdes_sequence");
    super.new(name);
  endfunction : new

  // Pre body task
  virtual task pre_body();
    super.pre_body();
  endtask : pre_body

  // This body task generate transactions and send to arbitration of sequencer and this task also differentiate between generate serial transaction and parallel transaction
  virtual task body();
    req = serdes_transaction::type_id::create("req"); // Creation of transaction packet
    
    // IF is_parallel is 1 then it will generate parallel data otherwise it will generate serial data
    if(is_parallel) begin
      // For parallel agent: Generate one transaction with randomized Tx0
      repeat(parallel_transaction_count) begin
        start_item(req);
        assert(req.randomize() with { Tx0 != 0; }); // Ensure non-zero for testing
        `uvm_info("BODY", $sformatf("Parallel transaction: Tx0 in Binary=%b | Tx0 in Decimal = %0d", req.Tx0,req.Tx0), UVM_LOW)
        finish_item(req); // This task will return if driver provide item_done
      end
    end

    // If is_parallel is 0 means i have to generate serial transactions 
    else begin
      // For serial agent: Generate 1 transactions for Rx0_p and Rx0_n
      repeat(serial_transaction_count) begin // WIDTH=10 for serial bits
        start_item(req); 
        assert(req.randomize() with { Rx0_p != 0; }); // Equal distribution for 0 and 1
        `uvm_info("BODY", $sformatf("Serial transaction: Rx0_p=%b [%0d]",req.Rx0_p, req.Rx0_p), UVM_LOW)
        finish_item(req); // This task will return if driver provide item_done
      end
    end
  endtask : body

  // Post body task
  virtual task post_body();
    super.post_body();
  endtask : post_body

endclass : serdes_sequence

//---------------------------------------------------------------------------------------------//
// File Name : serdes_data_pattern_sequence.sv
// Author Name : Vandan Parekh
// Propetier Name : ASICraft Technologies LLP.
// Decription : This is data_error_injection sequence in this sequence it generates different 
// patterns like walking_1, walking_0 and many others and send it to sequencer
//---------------------------------------------------------------------------------------------//

class serdes_data_pattern_sequence extends serdes_base_sequence;

  // Factory registration of sequence class
  `uvm_object_utils(serdes_data_pattern_sequence);

  // Properties declaration of sequence class
  bit is_parallel; // Indicates if the sequence is for a parallel or serial agent
  serdes_transaction::data_pattern_e data_pattern_seq;
  
  // Constructor of sequence class
  function new(string name = "serdes_data_pattern");
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
      `uvm_info(get_type_name(), $sformatf("Parallel Transaction Count = %0d", parallel_transaction_count), UVM_DEBUG)
      // For parallel agent: Generate one transaction with randomized Tx0
      repeat(parallel_transaction_count) begin
        `uvm_info("BODY", $sformatf("Before Start item"), UVM_DEBUG)
        start_item(req);
        assert(req.randomize() with {data_pattern == data_pattern_seq;});
        `uvm_info("BODY", $sformatf("Parallel transaction: data_pattern = %s | Tx0 in Binary=%b | Tx0 in Decimal = %0d", req.data_pattern.name(),req.Tx0,req.Tx0), UVM_LOW)
        finish_item(req); // This task will return if driver provide item_done
        `uvm_info("BODY", $sformatf("After Finish item"), UVM_DEBUG)
      end
    end

    // If is_parallel is 0 means i have to generate serial transactions 
    else begin
      // For serial agent: Generate 1 transactions for Rx0_p and Rx0_n
      `uvm_info(get_type_name(), $sformatf("Serial Transaction Count = %0d", serial_transaction_count), UVM_DEBUG)
      repeat(serial_transaction_count) begin // WIDTH=10 for serikal bits
        `uvm_info(get_type_name(), $sformatf("Before Start item"), UVM_DEBUG)
        start_item(req);
        assert(req.randomize() with {data_pattern == data_pattern_seq;});
        `uvm_info("BODY", $sformatf("Serial transaction: data_pattern = %s | Rx0_p=%b (%0d)", req.data_pattern.name(), req.Rx0_p, req.Rx0_p), UVM_LOW)
        finish_item(req); // This task will return if driver provide item_done
        `uvm_info(get_type_name(), $sformatf("After Finish item"), UVM_DEBUG)
      end
    end
  endtask : body

  // Post body task
  virtual task post_body();
    super.post_body();
  endtask : post_body

endclass : serdes_data_pattern_sequence

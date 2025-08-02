//---------------------------------------------------------------------------------------------//
// This sequence class used to randomize properties of transaction class and responsible for generating different scenarios and this sequence generate basic transactions one for rx and one for tx
//---------------------------------------------------------------------------------------------//



class serdes_sequence extends uvm_sequence #(serdes_transaction);

  `uvm_object_utils(serdes_sequence);
  parameter WIDTH = 10;
  int count = 0;

  int transaction_count; // Number of transactions (for parallel agent, typically 1; for serial agent, typically 10)
  bit is_parallel; // Indicates if the sequence is for a parallel or serial agent

  function new(string name = "serdes_sequence");
    super.new(name);
    // Get transaction_count from config_db
    if(!uvm_config_db#(int)::get(null, "*", "transaction_count", transaction_count))
      `uvm_fatal("NO_TRANS_COUNT", "transaction_count not found in config_db");
    // Get is_parallel from config_db (set by agent)
    //if(!uvm_config_db#(int)::get(null, get_full_name(), "is_parallel", is_parallel))
      //`uvm_fatal("NO_IS_PARALLEL", "is_parallel not found in config_db");
  endfunction : new

  virtual task pre_body();
    `uvm_info("PRE-BODY", $sformatf("INSIDE PRE-BODY TASK"), UVM_LOW)
    `uvm_info("PRE_BODY", $sformatf("transaction_count=%0d, is_parallel=%b", transaction_count, is_parallel), UVM_LOW)
  endtask : pre_body

  virtual task body();
    
    if(is_parallel) begin
      // For parallel agent: Generate one transaction with randomized Tx0
      repeat(transaction_count) begin
        req = serdes_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with { Tx0 != 0; }); // Ensure non-zero for testing
        `uvm_info("BODY", $sformatf("Parallel transaction: Tx0 in Binary=%b | Tx0 in Decimal = %0d", req.Tx0,req.Tx0), UVM_LOW)
        finish_item(req);
      end
    end
    else begin
      // For serial agent: Generate 1 transactions for Rx0_p and Rx0_n
      repeat(transaction_count * WIDTH) begin // WIDTH=10 for serial bits
        req = serdes_transaction::type_id::create("req");
        start_item(req);
        /*if(count % 2 != 0) begin
          assert(req.randomize() with { Rx0_p == 0; });// Equal distribution for 0 and 1
          count++;
        end
        else begin
          assert(req.randomize() with { Rx0_p == 1; }); // Equal distribution for 0 and 1
          count++;
        end*/ 

        assert(req.randomize() with { Rx0_p dist {0:/50, 1:/50}; }); // Equal distribution for 0 and 1
        `uvm_info("BODY", $sformatf("Serial transaction: Rx0_p=%b, Rx0_n=%b", req.Rx0_p, req.Rx0_n), UVM_LOW)
        finish_item(req);
      end
    end
  endtask : body

  virtual task post_body();
    `uvm_info("POST-BODY", $sformatf("INSIDE POST-BODY TASK"), UVM_LOW)
  endtask : post_body

endclass : serdes_sequence


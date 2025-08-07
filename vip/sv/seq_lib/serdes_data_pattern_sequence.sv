
//---------------------------------------------------------------------------------------------//
// This sequence class used to randomize properties of transaction class and responsible for generating different scenarios and this sequence generate basic transactions one for rx and one for tx in serdes tb architecture there are two sequence one generate parallel data and one generate serial data
//---------------------------------------------------------------------------------------------//

class serdes_data_pattern_sequence extends uvm_sequence #(serdes_transaction);

  // Factory registration of sequence class
  `uvm_object_utils(serdes_data_pattern_sequence);

  // Properties declaration of sequence class
  parameter WIDTH = 10;
  int count = 0;
            assert(req.randomize() with { Tx0 == 10'haaa; });
  
  int serial_transaction_count; // Number of serial transactions
  int parallel_transaction_count; // Number of parallel transactions 

  bit is_parallel; // Indicates if the sequence is for a parallel or serial agent
  typedef enum { ALL_ZERO, ALL_ONE, ALTERNATING_5, ALTERNATING_A, WALKING_1, WALKING_0, INCREMENT, DECREMENT} data_pattern_e;
  data_pattern_e data_pattern;

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
  endtask : pre_body

  // This body task generate transactions and send to arbitration of sequencer and this task also differentiate between generate serial transaction and parallel transaction
  virtual task body();
    
    // IF is_parallel is 1 then it will generate parallel data otherwise it will generate serial data
    if(is_parallel) begin
      // For parallel agent: Generate one transaction with randomized Tx0
      repeat(parallel_transaction_count) begin
        req = serdes_transaction::type_id::create("req"); // Creation of transaction packet
        start_item(req);
        case (data_pattern) 
          ALL_ZERO : begin
            assert(req.randomize() with { Tx0 == 0; });
          end
          ALL_ONE : begin
            assert(req.randomize() with { Tx0 == 10'hfff; });
          end
          ALTERNATING_5 : begin
            assert(req.randomize() with { Tx0 == 10'h555; });
          end
          ALTERNATING_A : begin
            assert(req.randomize() with { Tx0 == 10'haaa; });
          end
          WALKING_1 : begin
            
        endcase
        `uvm_info("BODY", $sformatf("Parallel transaction: data_pattern = %s | Tx0 in Binary=%b | Tx0 in Decimal = %0d", data_pattern.name(),req.Tx0,req.Tx0), UVM_LOW)
        finish_item(req); // This task will return if driver provide item_done
      end
    end

    // If is_parallel is 0 means i have to generate serial transactions 
    else begin
      // For serial agent: Generate 1 transactions for Rx0_p and Rx0_n
      repeat(serial_transaction_count * WIDTH) begin // WIDTH=10 for serikal bits
        req = serdes_transaction::type_id::create("req"); // Creation of transaction packet
        start_item(req);
        case (data_pattern)
          ALL_ZERO : begin
            assert(req.randomize() with { Rx0_p == 0; });
          end
          ALL_ONE : begin
            assert(req.randomize() with { Rx0_p == 1; });
          end
          ALTERNATING_5 : begin
            if(count % 2 == 0) begin
              assert(req.randomize() with { Rx0_p == 0; });
            end
            else begin
              assert(req.randomize() with { Rx0_p == 1; });
            end        
            count++;
          end
          ALTERNATING_A : begin
            if(count % 2 == 0) begin
              assert(req.randomize() with { Rx0_p == 1; });
            end
            else begin
              assert(req.randomize() with { Rx0_p == 0; });
            end        
            count++;
          end
        endcase
            
        `uvm_info("BODY", $sformatf("Serial transaction: data_pattern = %s | Rx0_p=%b,| Rx0_n=%b", data_pattern.name(), req.Rx0_p, req.Rx0_n), UVM_LOW)
        finish_item(req); // This task will return if driver provide item_done
      end
    end
  endtask : body

  // Post body task
  virtual task post_body();
    `uvm_info("POST-BODY", $sformatf("INSIDE POST-BODY TASK"), UVM_LOW)
  endtask : post_body

endclass : serdes_sequence


virtual task body();

  if (is_parallel) begin
    // For parallel agent
    repeat(parallel_transaction_count) begin
      req = serdes_transaction::type_id::create("req");
      start_item(req);
      case (data_pattern)
        ALL_ZERO      : assert(req.randomize() with { Tx0 == 0; });
        ALL_ONE       : assert(req.randomize() with { Tx0 == 10'h3FF; });
        ALTERNATING_5 : assert(req.randomize() with { Tx0 == 10'h155; });
        ALTERNATING_A : assert(req.randomize() with { Tx0 == 10'h2AA; });
        
        WALKING_1     : begin
          int walk1 = 1 << (count % WIDTH); // shifts 1 across WIDTH
          assert(req.randomize() with { Tx0 == walk1; });
          count++;
        end

        WALKING_0     : begin
          int walk0 = ~(1 << (count % WIDTH)) & ((1 << WIDTH) - 1); // all 1's except one 0
          assert(req.randomize() with { Tx0 == walk0; });
          count++;
        end

        default : `uvm_error("UNKNOWN_PATTERN", "Unsupported data_pattern for parallel")
      endcase
      `uvm_info("BODY", $sformatf("Parallel transaction: data_pattern = %s | Tx0 in Binary=%b | Tx0 in Decimal = %0d", data_pattern.name(),req.Tx0,req.Tx0), UVM_LOW)
      finish_item(req);
    end

  end else begin
    // For serial agent
    repeat(serial_transaction_count * WIDTH) begin
      req = serdes_transaction::type_id::create("req");
      start_item(req);
      case (data_pattern)
        ALL_ZERO      : assert(req.randomize() with { Rx0_p == 0; });
        ALL_ONE       : assert(req.randomize() with { Rx0_p == 1; });

        ALTERNATING_5 : begin
          assert(req.randomize() with { Rx0_p == (count % 2 == 0) ? 0 : 1; });
          count++;
        end

        ALTERNATING_A : begin
          assert(req.randomize() with { Rx0_p == (count % 2 == 0) ? 1 : 0; });
          count++;
        end

        WALKING_1 : begin
          assert(req.randomize() with { Rx0_p == (count % WIDTH == 0) ? 1 : 0; });
          count++;
        end

        WALKING_0 : begin
          assert(req.randomize() with { Rx0_p == (count % WIDTH == 0) ? 0 : 1; });
          count++;
        end

        default : `uvm_error("UNKNOWN_PATTERN", "Unsupported data_pattern for serial")
      endcase

      `uvm_info("BODY", $sformatf("Serial transaction: data_pattern = %s | Rx0_p=%b | Rx0_n=%b", data_pattern.name(), req.Rx0_p, req.Rx0_n), UVM_LOW)
      finish_item(req);
    end
  end

endtask : body


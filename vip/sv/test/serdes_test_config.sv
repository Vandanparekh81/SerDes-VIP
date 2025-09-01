// -------------------------------------------------------------------------------------------- //
// File Name : serdes_test_config.sv
// Author Name : Vandan Parekh
// Propetier Name : ASICraft Technologies LLP.
// Decription : This is serdes_test_config class 
// In this component all value plusargs are defined that is used by most of components for 
// example it takes serial and parallel transaction count data from command line 
// It is also use for providing reset value to scoreboard
// -------------------------------------------------------------------------------------------- //

class serdes_test_config extends uvm_object;

  // Factory Registration of test config class
  `uvm_object_utils(serdes_test_config)

  // Serdes reset signal
  bit serdes_reset = 1;
  bit scoreboard_enable = 1;
  int serial_transaction_count;
  int parallel_transaction_count;

  // Constructor of serdes_test_config
  function new(string name = "test_config");
    super.new(name);

    // Here we take serial transaction count value from command line.
    if (!$value$plusargs("SERIAL_TRANSACTION_COUNT=%0d", serial_transaction_count)) begin
      `uvm_warning(get_type_name(), $sformatf("Serial_Transaction_Count not given from command so by default taking one"));
      serial_transaction_count = 1; // If user did not give value from command line we take by default 1 
    end else begin
      `uvm_info(get_type_name(), $sformatf("Serial Transaction count is = %0d", serial_transaction_count), UVM_LOW)
    end

    // Here we take parallel transaction count value from command line.
    if (!$value$plusargs("PARALLEL_TRANSACTION_COUNT=%0d", parallel_transaction_count)) begin
      `uvm_warning(get_type_name(), $sformatf("Parallel_Transaction_Count not given from command so by default taking one"));
      parallel_transaction_count = 1; // If user did not give value from command line we take by default 1 
    end else begin
      `uvm_info(get_type_name(), $sformatf("Parallel Transaction count is = %0d", parallel_transaction_count), UVM_LOW)
    end

    if (!$value$plusargs("SCOREBOARD_ENABLE=%0d", scoreboard_enable)) begin
      `uvm_warning(get_type_name(), $sformatf("scoreboard enable/disable configuration not given from command so by default taking scoreboard as a enable"));
      scoreboard_enable = 1; // If user did not give value from command line we take by default 1 
    end else begin
        if(scoreboard_enable) begin
          `uvm_info(get_type_name(), $sformatf("Scoreboard is ENABLED"), UVM_LOW)
        end
        else begin
          `uvm_info(get_type_name(), $sformatf("Scoreboard is DISABLED"), UVM_LOW)
        end
    end

    // Store values in config database
    uvm_config_db #(int)::set(null, "*", "serial_transaction_count", serial_transaction_count);
    uvm_config_db #(int)::set(null, "*", "parallel_transaction_count", parallel_transaction_count);

  endfunction : new

endclass : serdes_test_config

// ------------------------------------------------------------------------- //
// This is test config class 
// This class is used to provide test property or any other property which is directly not accessible 
// For example reset signal to scoreboard 
// ------------------------------------------------------------------------- //

class serdes_test_config extends uvm_object;

  // Factory Registration of test config class
  `uvm_object_utils(serdes_test_config)

  // Serdes reset signal
  bit serdes_reset = 0;
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

    uvm_config_db #(int)::set(null, "*", "serial_transaction_count", serial_transaction_count); // Serial Transaction count
    uvm_config_db #(int)::set(null, "*", "parallel_transaction_count", parallel_transaction_count); // Parallel Transaction count

  endfunction : new

endclass : serdes_test_config

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
  endfunction : new

endclass : serdes_test_config

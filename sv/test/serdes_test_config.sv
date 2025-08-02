class serdes_test_config extends uvm_object;
  
  `uvm_object_utils(serdes_test_config)

  bit serdes_reset = 0;

  function new(string name = "test_config");
    super.new(name);
  endfunction : new

endclass : serdes_test_config

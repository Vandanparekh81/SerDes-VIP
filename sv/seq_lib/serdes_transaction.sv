//-----------------------------------------------------------------------------------//
//This is transaction class in this class we take all the itmes that can send from one component to another component in a packet form 

//you can consider this class as a container of properties and there are some constraint writteninside this class that can use to ensure data generate with respect to condition that is written inside that

// ----------------------------------------------------------------------------------//


class serdes_transaction extends uvm_sequence_item;
  
  // Factory registeration of transaction class      

  parameter WIDTH = 10;
  rand bit [WIDTH-1:0] Tx0; //Parallel input that can be send to serializer
  bit [WIDTH-1:0] Rx0; // Parallel output that can be received from deserializer
  bit [WIDTH-1:0] mon_parallel_Rx0, mon_parallel_Tx0; // This signals is taken for monitor because i have to send parallel packets to scoreboard so there are two monitors that sample serial data so i have to convert that serial data into parallel data

  bit Tx0_p; // Serial output that can be received from serializer
  bit Tx0_n; // Inverse signal of Tx0_p this is also serial output of serializer
  rand bit Rx0_p; // Serial input to deserializer
  rand bit Rx0_n; // Inverse of Rx0_p and this also serial input to deserializer

 constraint inverse_polarity { Rx0_n == ~Rx0_p; } // Constraint for maintaining inverse polarity of serial inputs of deserializer

 `uvm_object_utils_begin(serdes_transaction)
   `uvm_field_int(Tx0, UVM_DEFAULT)
   `uvm_field_int(Rx0, UVM_DEFAULT)
   `uvm_field_int(Tx0_p, UVM_DEFAULT)
   `uvm_field_int(Tx0_n, UVM_DEFAULT)
   `uvm_field_int(Rx0_p, UVM_DEFAULT)
   `uvm_field_int(Rx0_n, UVM_DEFAULT)
   `uvm_field_int(mon_parallel_Rx0, UVM_DEFAULT)
   `uvm_field_int(mon_parallel_Tx0, UVM_DEFAULT)
 `uvm_object_utils_end


  // Constructor of transaction class
  function new(string name = "serdes_transaction");
    super.new(name);
  endfunction : new

endclass : serdes_transaction

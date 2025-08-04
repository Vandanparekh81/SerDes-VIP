//-------------------------------------------------------------------//
//This is sequencer class and inside this class sequence selection of arbitration is happen this component is decide which sequence go to driver.
// Inside the source code there is one port sequence_item_pull_imp that is use to connenct with driver. 
//-------------------------------------------------------------------//

class serdes_sequencer extends uvm_sequencer #(serdes_transaction);

  // Factory registeration of sequencer class
  `uvm_component_utils(serdes_sequencer)

  //Constructor of sequencer class
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //Build phase of sequencer class
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("Sequencer Build Phase", $sformatf("Inside the build phase of sequencer class"), UVM_LOW)
  endfunction : build_phase

endclass : serdes_sequencer

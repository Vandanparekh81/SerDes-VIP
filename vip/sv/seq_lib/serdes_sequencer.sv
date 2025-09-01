//------------------------------------------------------------------------//
// File Name : serdes_sequencer.sv
// Author Name : Vandan Parekh
// Propetier Name : ASICraft Technologies LLP.
// Decription : This is serdes_sequencer class this class takes data 
// from sequence and send it to driver and there are two sequencer in
// serdes tb architecture one is parallel sequencer(TX) and one is 
// serial sequencer(RX) 
//------------------------------------------------------------------------//

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

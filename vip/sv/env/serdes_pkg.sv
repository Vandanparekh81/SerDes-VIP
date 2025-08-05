// -------------------------------------------------------------------------------------------- //
// This is package that basically contain all the files of vip and take care compilation flow
// -------------------------------------------------------------------------------------------- //

package serdes_pkg; 
  // uvm source code files
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "../seq_lib/serdes_transaction.sv" // Serdes_transaction file
  `include "../seq_lib/serdes_sequence.sv" // Serdes sequencre file
  `include "serdes_agent_config.sv" // Serdes agent config file
  `include "../test/serdes_test_config.sv" // Serdes test config file
  `include "../seq_lib/serdes_sequencer.sv" // Serdes sequencer file
  `include "serdes_driver.sv" // Serdes driver file
  `include "serdes_monitor.sv" // Serdes Monitor file
  `include "serdes_scoreboard.sv" // Serdes scoreboard file
  `include "serdes_subscriber.sv" // Serdes subscriber file
  `include "serdes_agent.sv" // Serdes agent file
  `include "serdes_env.sv" // Serdes environment file
  `include "../test/serdes_test.sv" // Serdes test component file
endpackage
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../../tb_top/serdes_top_tb.sv" // Tb_top file
`include "serdes_interface.sv" // Serdes Interface file
`include "../../sve/serdes_dut.sv" // Serdes DUT File

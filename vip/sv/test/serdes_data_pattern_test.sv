// ---------------------------------------------------------------------------------------------- //
// File Name : serdes_data_pattern_test.sv
// Author Name : Vandan Parekh
// Propetier Name : ASICraft Technologies LLP.
// Decription : This is data_pattern_test class 
// This testcase generate different patterns for verifying data_transaction
// ---------------------------------------------------------------------------------------------- //

class serdes_data_pattern_test extends serdes_base_test;

  // Factory registration of test class     
  `uvm_component_utils(serdes_data_pattern_test);

  // Properties declaration of test class
  serdes_data_pattern_sequence seq[2]; // Two instance of sequence one for parallel sequencer and one for serial sequencer
  serdes_transaction::data_pattern_e data_pattern_seq; // New field for data pattern

  // Constructor of serdes_test class
  function new (string name, uvm_component parent);
    super.new(name, parent);
    // Parse data pattern from command line
    begin
      string data_pattern_str;
      if (!$value$plusargs("DATA_PATTERN=%s", data_pattern_str)) begin
        `uvm_warning(get_type_name(), $sformatf("DATA_PATTERN not provided, defaulting to RANDOM"));
        data_pattern_seq = serdes_transaction::RANDOM; // Default to RANDOM
      end else begin
        case (data_pattern_str)
          "RANDOM":       data_pattern_seq = serdes_transaction::RANDOM;
          "ALL_ZERO":     data_pattern_seq = serdes_transaction::ALL_ZERO;
          "ALL_ONE":      data_pattern_seq = serdes_transaction::ALL_ONE;
          "ALTERNATING_5": data_pattern_seq = serdes_transaction::ALTERNATING_5;
          "ALTERNATING_A": data_pattern_seq = serdes_transaction::ALTERNATING_A;
          "WALKING_1":    data_pattern_seq = serdes_transaction::WALKING_1;
          "WALKING_0":    data_pattern_seq = serdes_transaction::WALKING_0;
          "INCREMENT":    data_pattern_seq = serdes_transaction::INCREMENT;
          "DECREMENT":    data_pattern_seq = serdes_transaction::DECREMENT;
          default: begin
            `uvm_warning(get_type_name(), $sformatf("Invalid DATA_PATTERN=%s, defaulting to RANDOM", data_pattern_str));
            data_pattern_seq = serdes_transaction::RANDOM;
          end
        endcase
        `uvm_info(get_type_name(), $sformatf("Data Pattern set to %s", data_pattern_seq.name()), UVM_LOW)
      end
    end
  endfunction : new

  // Build phase of serdes test class
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase

  // Connect phase of test class
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  // End of elaboration phase of test class
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
  endfunction : end_of_elaboration_phase

  // Run phase of test class
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this); // Objection is raised

    // Foreach loop of sequence instance here the sequence is created and if it is parallel sequence then is_parallel = 1 otherwise is_parallel = 0
    foreach(seq[i]) begin
      seq[i] = serdes_data_pattern_sequence::type_id::create($sformatf("seq[%0d]", i)); // Creation of sequence
      seq[i].is_parallel = env.agt[i*2].agt_cfg.is_parallel; // Is_parallel configuration
      seq[i].data_pattern_seq = data_pattern_seq;
      `uvm_info(get_type_name(), $sformatf("seq[%0d].is_parallel = %b | env.agt[%0d].agt_cfg.is_parallel = %b", i,seq[i].is_parallel,i,env.agt[i*2].agt_cfg.is_parallel), UVM_LOW)
    end

    foreach(env.scb[i]) begin
      env.scb[i].test_cfg = test_cfg; // Provide the test config instance to scoreboard
    end

    // Inside the fork join the sequende is started
    fork
      begin
        #1000;
        uvm_hdl_force(force_path, 1'b0);
        test_cfg.serdes_reset = 0;
        `uvm_info("RESET", $sformatf("RESET_dEasserted"), UVM_LOW)
      end
      seq[0].start(env.agt[0].seqr); // Sequence is started on sequencer 1
      seq[1].start(env.agt[2].seqr); // Sequence is started on sequencer 2
    join

    phase.phase_done.set_drain_time(this, drain_time); // Drain time 
    phase.drop_objection(this); // Objection dropped

  endtask : run_phase

  // Report phase of test
  // Inside the report phase the transaction count is checked and if it is match with actual count of respective scoreboard then testcase is passed otherwise it is display uvm error as testcase is failed
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
  endfunction : report_phase

endclass : serdes_data_pattern_test

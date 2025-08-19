// -------------------------------------------------------------------------------------------------- //
// This is subscriber class. 
// This class is used for taking coverage of data which is sample by monitor and this class basically track particular signal cover their all values of range and give result in percentage according signal cover which values of its range
// -------------------------------------------------------------------------------------------------- // 

// Macro for taking multiple ports because each subscriber getting data from two monitor class 
`uvm_analysis_imp_decl(_subscriber_expected)
`uvm_analysis_imp_decl(_subscriber_actual)

class serdes_subscriber extends uvm_component;
 
    // Factory Registration of serdes_subscriber
    `uvm_component_utils(serdes_subscriber)
    
    bit is_tx; // Flag to indicate Tx (1) or Rx (0)
    
    // Port Declaration of serdes subscriber
    uvm_analysis_imp_subscriber_expected #(serdes_transaction, serdes_subscriber) expected_imp;
    uvm_analysis_imp_subscriber_actual #(serdes_transaction, serdes_subscriber) actual_imp;
    
    // Transaction packet declaration of uvm_subscriber
    serdes_transaction exp_tr; // Expected transaction
    serdes_transaction act_tr; // Actual transaction
    real cov_percent ;
    
    // Covergroup for coverage collection
    covergroup cg;
      option.per_instance = 1;

      // For TX Expected
      cp_tx_expected: coverpoint exp_tr.Tx0 iff (is_tx) {
        bins zero = {0};
        bins walking_one[] = {1,2,4,8,16,32,64,128,256,512};
        bins walking_zero[] = {1022,1021,1019,1015,1007,991,959,895,767,511};
        bins alternate_5 = {341}; // 1023 minus bit 2
        bins alternate_a = {682}; // 1023 minus bit 4
        bins all_one = {1023};
        bins increment = {[1:100]};
        bins low_range = {[1:255]};
        bins mid_range = {[256:511]};
        bins high_range = {[512:767]};
        bins max_range = {[768:1023]};
      }

      // For TX Actual
      cp_tx_actual: coverpoint act_tr.mon_parallel_Tx0 iff (is_tx) {
        bins zero = {0};
        bins walking_one[] = {1,2,4,8,16,32,64,128,256,512};
        bins walking_zero[] = {1022,1021,1019,1015,1007,991,959,895,767,511};
        bins alternate_5 = {341};
        bins alternate_a = {682};
        bins all_one = {1023};
        bins increment = {[1:100]};
        bins low_range = {[1:255]};
        bins mid_range = {[256:511]};
        bins high_range = {[512:767]};
        bins max_range = {[768:1023]};
      }

      // For RX Expected
      cp_rx_expected: coverpoint exp_tr.mon_parallel_Rx0 iff (!is_tx) {
        bins zero = {0};
        bins walking_one[] = {1,2,4,8,16,32,64,128,256,512};
        bins walking_zero[] = {1022,1021,1019,1015,1007,991,959,895,767,511};
        bins alternate_5 = {341};
        bins alternate_a = {682};
        bins all_one = {1023};
        bins increment = {[1:100]};
        bins low_range = {[1:255]};
        bins mid_range = {[256:511]};
        bins high_range = {[512:767]};
        bins max_range = {[768:1023]};
      }

      // For RX Actual
      cp_rx_actual: coverpoint act_tr.Rx0 iff (!is_tx) {
        bins zero = {0};
        bins walking_one[] = {1,2,4,8,16,32,64,128,256,512};
        bins walking_zero[] = {1022,1021,1019,1015,1007,991,959,895,767,511};
        bins alternate_5 = {341};
        bins alternate_a = {682};
        bins all_one = {1023};
        bins increment = {[1:100]};
        bins low_range = {[1:255]};
        bins mid_range = {[256:511]};
        bins high_range = {[512:767]};
        bins max_range = {[768:1023]};
      }
    endgroup

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);

        // Creation of ports and covergroup
        expected_imp = new("expected_imp", this);
        actual_imp = new("actual_imp", this);
        cg = new();
    endfunction : new
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Creation of expected and actual transaction
        exp_tr = serdes_transaction::type_id::create("exp_tr");
        act_tr = serdes_transaction::type_id::create("act_tr");
    endfunction : build_phase
    
    // Write method for expected transactions
    function void write_subscriber_expected(serdes_transaction t);
        exp_tr.copy(t);
        cg.sample();
        `uvm_info(get_type_name(), $sformatf("Coverage collected for expected: Tx0=%b, mon_parallel_Rx0=%b", exp_tr.Tx0, exp_tr.mon_parallel_Rx0), UVM_LOW)
    endfunction : write_subscriber_expected
    
    // Write method for actual transactions
    function void write_subscriber_actual(serdes_transaction t);
        act_tr.copy(t);
        cg.sample();
        `uvm_info(get_type_name(), $sformatf("Coverage collected for actual: mon_parallel_Tx0=%b, Rx0=%b", act_tr.mon_parallel_Tx0, act_tr.Rx0), UVM_LOW)
    endfunction : write_subscriber_actual

    // Report phase: display overall coverage
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        cov_percent = cg.get_inst_coverage(); // per-instance coverage
        `uvm_info(get_type_name(),$sformatf("Final SERDES Subscriber Coverage: %.2f%%", cov_percent),UVM_NONE)
    endfunction

endclass : serdes_subscriber


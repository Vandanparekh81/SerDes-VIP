// ------------------------------------------------------------------------------ //
// File Name : serdes_subscriber.sv
// Author Name : Vandan Parekh
// Propetier Name : ASICraft Technologies LLP.
// This is subscriber class.
// This class is used for taking coverage of data which is sampled by monitor and 
// this class basically tracks particular signals to cover all values of their 
// range and gives results in percentage according to which values of its range 
// are covered
// ------------------------------------------------------------------------------ //

// Macro for taking multiple ports because each subscriber gets data from two monitor classes
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
    real cov_percent;
    
    // Covergroup for TX coverage (active when is_tx = 1)
    covergroup cg_tx;
      option.per_instance = 1;

      cp_serdes_speed: coverpoint exp_tr.serdes_speed {
        bins speed_range[] = {[1:10]};    // High speeds
        illegal_bins invalid = {0, [11:$]};  // Flag invalid speeds
      }

      cp_tx_expected: coverpoint exp_tr.Tx0 {
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

      cp_tx_actual: coverpoint act_tr.mon_parallel_Tx0 {
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

    // Covergroup for RX coverage (active when is_tx = 0)
    covergroup cg_rx;
      option.per_instance = 1;

      cp_serdes_speed: coverpoint exp_tr.serdes_speed {
        bins speed_range[] = {[1:10]};    // High speeds
        illegal_bins invalid = {0, [11:$]};  // Flag invalid speeds
      }

      cp_rx_expected: coverpoint exp_tr.mon_parallel_Rx0 {
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

      cp_rx_actual: coverpoint act_tr.Rx0 {
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
        // Creation of ports and covergroups
        expected_imp = new("expected_imp", this);
        actual_imp = new("actual_imp", this);
         if(!uvm_config_db#(int)::get(this, "", "is_tx", is_tx))
           `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
        if (is_tx) begin 
          `uvm_info(get_full_name(), $sformatf("CG TX covergroup is created is_tx = %b", is_tx), UVM_LOW)
           
           cg_tx = new();
        end

        else begin
          `uvm_info(get_full_name(), $sformatf("CG RX covergroup is created is_tx = %b", is_tx), UVM_LOW)
          cg_rx = new();
        end
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
        if (is_tx) begin 
          `uvm_info(get_full_name(), $sformatf("COVERAGE collected for expected tx"), UVM_LOW)
          cg_tx.sample();
        end

        else begin 
          `uvm_info(get_full_name(), $sformatf("COVERAGE collected for expected rx"), UVM_LOW)
          cg_rx.sample();
        end

        `uvm_info(get_type_name(), $sformatf("Coverage collected for expected: Tx0=%b, mon_parallel_Rx0=%b", exp_tr.Tx0, exp_tr.mon_parallel_Rx0), UVM_LOW)
    endfunction : write_subscriber_expected
    
    // Write method for actual transactions
    function void write_subscriber_actual(serdes_transaction t);
        act_tr.copy(t);
        if(is_tx) begin 
          `uvm_info(get_full_name(), $sformatf("COVERAGE collected for actual tx"), UVM_LOW)
          cg_tx.sample();
        end
        else begin
          `uvm_info(get_full_name(), $sformatf("COVERAGE collected for actual rx"), UVM_LOW)
          cg_rx.sample();
        end

        `uvm_info(get_type_name(), $sformatf("Coverage collected for actual: mon_parallel_Tx0=%b, Rx0=%b", act_tr.mon_parallel_Tx0, act_tr.Rx0), UVM_LOW)
    endfunction : write_subscriber_actual

    // Report phase: display overall coverage
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        if (is_tx) begin
            cov_percent = cg_tx.get_inst_coverage(); // per-instance coverage for TX
            `uvm_info(get_type_name(), $sformatf("Final SERDES TX Subscriber Coverage: %.2f%%", cov_percent), UVM_NONE)
        end else begin
            cov_percent = cg_rx.get_inst_coverage(); // per-instance coverage for RX
            `uvm_info(get_type_name(), $sformatf("Final SERDES RX Subscriber Coverage: %.2f%%", cov_percent), UVM_NONE)
        end
    endfunction

endclass : serdes_subscriber

// ------------------------------------------------------------------------------ //
// This is scoreboard class
// This scoreboard class takes data from monitor and it will compare expected data and actual data of monitor and it will give result pass if they match else it will give result as a fail
// There are two scoreboard onein serdes tb_architecture one is tx scoreboard and one is rx scoreboard and it will take data from 4 monitor so we have to use `uvm_analysis_imp_decl that basically give two connection of one scoreboard
// ------------------------------------------------------------------------------ //

// using below macro we take two implementation port
`uvm_analysis_imp_decl(_expected) // This port is for expected data
`uvm_analysis_imp_decl(_actual) // This port is for actual data

class serdes_scoreboard extends uvm_scoreboard;
 
  // Factory Registration
  `uvm_component_utils(serdes_scoreboard);

  // Port declaration of scoreboard 
  uvm_analysis_imp_expected #(serdes_transaction, serdes_scoreboard) expected_imp; // Expected Implementation Port 
  uvm_analysis_imp_actual #(serdes_transaction, serdes_scoreboard) actual_imp; // Actual Implementation Port
 
  serdes_transaction exp; // Instance of serdes transaction for expected   
  serdes_transaction act; // Instance of serdes transaction for actual
  serdes_transaction expected_q[$]; // To store expected packet we have one queue Expected packet queue
  serdes_transaction actual_q[$]; // To store actual packet we have one actual queue Actual packet queue 
  serdes_test_config test_cfg; // Test_config class instance to access reset from test
  int expected_count = 0;  // Expected Count 
  int actual_count = 0; // Actual Packet Count
  
  //serdes_transaction cpy;

  bit is_tx = 0; // If scoreboard is tx scoreboard then it is 1 otherwise it will be zero
  int match = 0; // If comparison match then this will increment othewise mismatch will Increment
  int mismatch = 0; // if comparison do not match then this will increment otherwise match is increment
  
  // Constructor of serdes Scoreboard 
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Build phase of serdes scoreboard
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    expected_imp = new("expected_imp", this); // Creation expected implementation port
    actual_imp = new("actual_imp", this); // Creation of actual implmentation port
  endfunction : build_phase

  // Connect phase of serdes scoreboard
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  // If monitor send expected packet then this method is called this method basically copy that packet and push back into the expected queue
  function void write_expected(serdes_transaction tr);
    serdes_transaction cpy = serdes_transaction::type_id::create("cpy"); // Creation of copy packet
    `uvm_info(get_type_name(), $sformatf("SCOREBOARD Received expected transaction: Tx0=%b, mon_parallel_Tx0=%b", tr.Tx0, tr.mon_parallel_Tx0), UVM_LOW)
    cpy.copy(tr); // Copy method is called
    expected_q.push_back(cpy); // Store into expected queue
    `uvm_info(get_type_name(), $sformatf("Received expected transaction: Tx0=%b, mon_parallel_Tx0=%b", cpy.Tx0, cpy.mon_parallel_Tx0), UVM_LOW)
  endfunction
  
  // If monitor send actual packet then this method is called this method basically copy that packet and store into actual queue
  function void write_actual(serdes_transaction tr);
    serdes_transaction cpy = serdes_transaction::type_id::create("cpy"); //Creation of copy object
    cpy.copy(tr); // Copy method is called
    actual_q.push_back(cpy); // Store into expected queue
    `uvm_info(get_type_name(), $sformatf("Received actual transaction: Tx0=%b, mon_parallel_Tx0=%b", cpy.Tx0, cpy.mon_parallel_Tx0), UVM_LOW)
  endfunction

  // Below function compare expected and actual tx packet if they match then this function will return 1 otherwise it will return zero
  function bit compare_tx(serdes_transaction exp, serdes_transaction act);

    // Comparison of actual and expected tx packet if they match it will satisfy below condition otherwise it will return zero
    if(exp.Tx0 == act.mon_parallel_Tx0) begin

      `uvm_info(get_type_name(), $sformatf("[Scoreboard Tx] COMPARISON TX PASSED | exp.Tx0 = %b | exp_Tx0 = %0d | act.mon_parallel_Tx0 = %b | act.mon_parallel_Tx0 = %0d", exp.Tx0,exp.Tx0,act.mon_parallel_Tx0,act.mon_parallel_Tx0), UVM_LOW)
      return 1;
    end

    // Comparison of actual and expected packet if not match it will return zero and gave uvm error
    else begin
      `uvm_error(get_type_name(), $sformatf("[Scoreboard Tx] COMPARISON FAILED | exp.Tx0 = %b | exp_Tx0 = %0d | act.mon_parallel_Tx0 = %b | act.mon_parallel_Tx0 = %0d", exp.Tx0,exp.Tx0,act.mon_parallel_Tx0,act.mon_parallel_Tx0))
      return 0;
    end
  endfunction : compare_tx
  
  // Below function compare expected and actual rx packet if they match then this function will return 1 otherwise it will return zero
  function bit compare_rx(serdes_transaction exp, serdes_transaction act);
    
    // Comparison of actual and expected tx packet if they match it will satisfy below condition otherwise it will return zero
    if(exp.mon_parallel_Rx0 == act.Rx0) begin
      `uvm_info(get_type_name(), $sformatf("[Scoreboard Rx] COMPARISON RX PASSED | exp.mon_parallel_Rx0 = %b | exp_mon_parallel_Rx0 = %0d | act.Rx0 = %b | act.Rx0 = %0d", exp.mon_parallel_Rx0,exp.mon_parallel_Rx0,act.Rx0,act.Rx0), UVM_LOW)
      `uvm_info(get_type_name(), $sformatf("[Scoreboard Rx] COMPARISON RX PASSED"), UVM_LOW)
      return 1;
    end
    
    // Comparison of actual and expected packet if not match it will return zero and gave uvm error
    else begin
      `uvm_error(get_type_name(), $sformatf("[Scoreboard Rx] COMPARISON FAILED | exp.mon_parallel_Rx0 = %b | exp_mon_parallel_Rx0 = %0d | act.Rx0 = %b | act.Rx0 = %0d", exp.mon_parallel_Rx0,exp.mon_parallel_Rx0,act.Rx0,act.Rx0))
      return 0;
    end
  endfunction : compare_rx

  task run_phase (uvm_phase phase);
    super.run_phase(phase);
     
      // Forever loop of run phase
      forever begin // Loop 1

        //Fork join any for run parallel two threads one for reset condition and one for scoreboarding
        fork //Loop 2

          //Thread 1 for scoreboarding
          begin // Loop 3

            // We have to do scoreboarding if it is not in reset state
            // `uvm_info(get_type_name(), $sformatf("Inside Scoreboard Run Phase"), UVM_LOW)
            if(!test_cfg.serdes_reset) begin // Loop 4

              // We have to start scoreboarding if we have both queue size greter than or equal to 1 otherwise we have to wait to become queue size 1 that part is written in else loop
              //`uvm_info(get_type_name(), $sformatf("Inside Scoreboard Run Phase before actual packet is got"), UVM_LOW)
              wait(actual_q.size() >= 1);
              wait(expected_q.size() >= 1);
              //`uvm_info(get_type_name(), $sformatf("Inside Scoreboard Run Phase after WAIT is got"), UVM_LOW)
              `uvm_info(get_type_name(), $sformatf("PACKET SIZE Inside Scoreboard Run Phase actual packet is got actual_q.size = %0d | Expected_q.size = %0d", actual_q.size(), expected_q.size()), UVM_LOW)
              if(expected_q.size() >= 1) begin // Loop 5
                //`uvm_info(get_type_name(), $sformatf("Inside Scoreboard Run Phase Expected packet condition"), UVM_LOW)

                //If both queue size greater than or equal to 1 then we have to pop their first element
                exp = expected_q.pop_front(); // Pop the element of expected queue
                expected_count++;
                `uvm_info(get_type_name(), $sformatf("exp.mon_parallel_Rx0 = %b", exp.mon_parallel_Rx0), UVM_LOW)
                act = actual_q.pop_front(); // Pop the element of actual queue
                `uvm_info(get_type_name(), $sformatf("act.Rx0 = %b", act.Rx0), UVM_LOW)
                actual_count++;

                //In the tb_Architecture we have two instance of scoreboard, one instance is doing comparison of Tx input and Tx output and second instance is doing comparison of rx input and rx output
                
                //This if condition is true then it is tx instance of scoreboard and it is doing tx input and output comparison
                if(is_tx) begin // Loop 6

                  //Compare tx is function that returns 1 if comparison match otherwise it is return 0                   
                `uvm_info(get_type_name(), $sformatf("Inside Scoreboard Run Phase Tx scoreboard condition"), UVM_LOW)
                  if(compare_tx(exp, act)) begin // Loop 7
                    match++; // if return 1 then we have to plus match 
                  end // Loop 7 end

                  else begin// Loop 8
                    mismatch++; // If return 0 then we have to plus mismatch
                  end // loop 8  

                end // loop 6

                else begin // loop 9

                  // If it is rx scoreboard then we have to compare rx input and rx output
                  
                  //compare_rx is function that returns 1 if comparison match otherwise it will to return 0
                  //`uvm_info(get_type_name(), $sformatf("Inside Scoreboard Run Phase Rx scoreboard condition"), UVM_LOW)
                  if(compare_rx(exp, act)) begin // loop 10
                    match++; // If return 1 then match++
                  end // loop 10

                  else begin // loop 11
                    mismatch++; //If return 0 then mismatch++
                  end // loop 11

                end// loop 9
              end // loop 5
              else begin 
              end

              //This else is for if any one or both packet is not come inside this we take 50000ns time to wait for any one or both packet not come
              //This portion is commented out due we thinking both packet come at same time
              /* else begin // loop 12 else of loop 5
                
                // This fork join any is for if we get the packet then we have to go for comparison
                fork // loop 13
                 
                  // Thread 1
                  
                  // If expected packet not come then it will go inside this loop 
                  if(actual_q.size() >= 1) begin // loop 14
                    fork // loop 15
                      
                      // Thread 1 it is waiting for expected queue size become 1 
                      begin // loop 16
                        wait(expected_q.size() >= 1);
                      end // loop 16

                      // Thread 2 it is waiting for 50000 ns if packet is not come then it will give uvm_error
                      begin // loop 17
                        #50000;
                        `uvm_error(get_type_name(), $sformatf("Scoreboard did not get expected packet"))
                      end // loop 17

                    join_any // loop 15
                  end // loop 14

                  // Thread 2
                  
                  //If actual packet not come then it will go inside this loop and it will wait for 50000 ns in that time packet will come then it is ok otherwise it display uvm_error
                  if(expected_q.size() >= 1) begin // loop 18

                    // This fork join_any is written if actual queue packet is come within 50000 ns otherwise it will display error
                    fork // loop 19

                      //Thread 1
                      //wait for actual packet
                      begin // loop 20
                       wait(actual_q.size() >= 1);
                      end // loop 20

                      //Thread 2
                      //wait for actual packet is come within 50000 ns otherwise it will give uvm_error 
                      begin // loop 21
                        #50000;
                        `uvm_error(get_type_name(), $sformatf("Scoreboard did not get actual packet"))
                      end // loop 21

                    join_any // loop 19
                  end // loop 18
                join //loop 13

              end // loop 12 */
            end // loop 4 

            // This loop is for wait until reset go off
            else begin // loop 22 else of loop 4
              wait(!test_cfg.serdes_reset);
            end // loop 22

          end // loop 3

          // Thread 2 for reset condition
          begin // loop 23
            if(test_cfg.serdes_reset == 1) begin
              if(expected_q.size() >= 1 && actual_q.size() == 0) begin
                expected_q.delete();
                expected_count = 0;
                actual_count = 0;
                `uvm_info(get_type_name(), $sformatf("Reset Expected queue is flushed and expected and actual count set to zero"), UVM_LOW)
              end
              wait(!test_cfg.serdes_reset);
            end

            else begin 
              wait(test_cfg.serdes_reset);
            end
          end // loop 23
     join_any // loop 2
   end // loop 1

  endtask : run_phase

  virtual function void check_phase(uvm_phase phase);
    if(expected_count == actual_count) begin
      `uvm_info("Scoreboard_Check_Phase", $sformatf("Expected count is equal to actual count | Expected_count = %0d | actual count = %0d", expected_count, actual_count), UVM_LOW)
    end
    else begin
      `uvm_error("Scoreboard_Check_Phase", $sformatf("Expected count is not equal to actual count | Expected_count = %0d | Actual count = %0d", expected_count, actual_count) )
    end
  endfunction : check_phase

endclass : serdes_scoreboard

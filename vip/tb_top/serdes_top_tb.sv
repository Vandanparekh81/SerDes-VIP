// -------------------------------------------------------------------------------- //
// This is tb_top component which is responsible to create test inside the top  clock configuration and interface to dut connection is happen inside the top
// we take instance of interface and we provide the input signal of interface for example clock and we also take instance of dut and provide them interface signals and this the way to connection of interface and DUT
// -------------------------------------------------------------------------------- // 

// importing the serdes package file which include all the component files
import serdes_pkg::*;

// Timescale
`timescale 1ns/1ps

module tb_top;

  // Properties declaration of top
  parameter WIDTH = 10; // Width of parallel data
  real serdes_speed; // Speed of transfer data which is given from command line
  real speed_frequency;// Frequency of given speed from command line
  real serial_freq; // Frequency of serial clock
  real parallel_freq; // Frequency of parallel clock
  real serial_clk_period; // Serial clock period
  real parallel_clk_period; // Parallel clock period
  real parallel_lanes = 10.0; // Parallel lanes width
  int serial_transaction_count; // Transaction count of serial 
  int parallel_transaction_count; // Transaction count of parallel
  int no_of_agents; // No of agentd which is given from command line

  bit serdes_reset = 1; // Active High Reset 
  bit serial_clk = 0; // Serial clock
  bit parallel_clk = 1; // Parallel Clock

  serdes_interface #(.WIDTH(WIDTH)) intf (.serial_clk(serial_clk), .parallel_clk(parallel_clk), .serdes_reset(serdes_reset)); // Interface

  // Serial to parallel shift register dut instance
  sipo_shift_register #(.WIDTH(WIDTH)) sipo_inst (
        .serial_clk(intf.serial_clk),
        .parallel_clk(intf.parallel_clk),
        .rst(intf.serdes_reset), // Active-high reset
        .Rx0_p(intf.Rx0_p),
        .Rx0_n(intf.Rx0_n),
        .Rx0(intf.Rx0)
  );

    // PISO shift register instantiation (active-High reset)
    piso_shift_register #(.WIDTH(WIDTH)) piso_inst (
        .serial_clk(intf.serial_clk),
        .parallel_clk(intf.parallel_clk),
        .rst(intf.serdes_reset),
        .Tx0(intf.Tx0),
        .Tx0_p(intf.Tx0_p),
        .Tx0_n(intf.Tx0_n)
    );

    task reset_initiate(int asserted, int deasserted);
      #(asserted) serdes_reset = 1;
      #(deasserted) serdes_reset = 0;
    endtask

    function real get_time_period_rounded(real frequency_hz, int decimal_places);
      real time_period, multiplier;
      if (frequency_hz <= 0) begin
          $display("Error: Frequency must be greater than zero.");
          return 0.0;
      end
      time_period = 1.0 * 1e9/ frequency_hz;
      multiplier = 1.0;
      repeat (decimal_places)
          multiplier *= 10.0;
      return $rtoi(time_period * multiplier + 0.5) / multiplier;
    endfunction
 


  // Below we take value from command line using Value plus args
  initial begin
    // Here we take serdes speed value from command line generally which is 1G, 2G
    if (!$value$plusargs("SPEED=%f", serdes_speed)) begin
      $display("Warning: You did not provide a SPEED value. Using default.");
      serdes_speed = 1000000000.0;  // If user did not give value from command line we take by default 1G
    end else begin
      $display("Your Selected Speed is %0d G", serdes_speed);
      speed_frequency = serdes_speed * 1000000000.0;  
      $display("Serdes speed is = %0f Hz", speed_frequency);
    end

    // Here we take serial transaction count value from command line.
    if (!$value$plusargs("SERIAL_TRANSACTION_COUNT=%0d", serial_transaction_count)) begin
      $display("Warning: You did not provide a transaction value. Using default.");
      serial_transaction_count = 1; // If user did not give value from command line we take by default 1 
    end else begin
      $display("Transaction count is = %0d", serial_transaction_count);
    end

    // Here we take parallel transaction count value from command line.
    if (!$value$plusargs("PARALLEL_TRANSACTION_COUNT=%0d", parallel_transaction_count)) begin
      $display("Warning: You did not provide a transaction value. Using default.");
      parallel_transaction_count = 1; // If user did not give value from command line we take by default 1 
    end else begin
      $display("Transaction count is = %0d", serial_transaction_count);
    end

    // Here we take number of agents value from command line.
    if (!$value$plusargs("NO_OF_AGENTS=%d", no_of_agents)) begin
      $display("Warning: You did not provide a value for number of agents. Using default.");
      no_of_agents = 4; // If user did not give value from command line we take by default 4
    end 
    else begin
      $display("Number of agents is = %0d", no_of_agents);
    end

    //Calculation for clock configuration
    serial_freq = speed_frequency; // Serial frequency which is frequency of speed which is given from command line
    //parallel_freq = speed_frequency / parallel_lanes; // Parallel frequency which is division of serdes speed by parallel lanes
    serial_clk_period = get_time_period_rounded(serial_freq, 2); //serial Clock period is Inverse of serial frequency taking into nanoseconds we take 1e9
    parallel_clk_period = serial_clk_period * 10.0; //parallel Clock period is Inverse of parallel frequency taking into nanoseconds we take 1e9

    `uvm_info("COMMAND LINE", $sformatf("Serial CLK Period = %f ns", serial_clk_period), UVM_LOW)
    `uvm_info("COMMAND LINE", $sformatf("Parallel CLK Period = %f ns", parallel_clk_period), UVM_LOW)
  end

  // Serial Clock configuration
  initial begin
    forever begin
      if(serdes_reset == 0) begin
        #((serial_clk_period) / 2.0) serial_clk = ~serial_clk;
        `uvm_info("Serial clock top", $sformatf("FROM TOP SERIAL TIME = %0t", $time), UVM_LOW)
      end
      else begin
        serial_clk = 0;
        wait(!serdes_reset);
        serial_clk = 1;
      end
    end
  end
  
  //Parallel clock configuration
  initial begin
    //#(serial_clk_period);
    forever begin
      if(serdes_reset == 0) begin
        #((parallel_clk_period) / 2.0) parallel_clk = ~parallel_clk;
        `uvm_info("Serial clock top", $sformatf("FROM TOP SERIAL TIME = %0t", $time), UVM_LOW)
      end
      else begin
        parallel_clk = 0;
        wait(!serdes_reset);
        parallel_clk = 1;
      end
    end
  end


  /*initial begin
    #1000000 $finish;
  end */ 
  
  // Here we set all the variables which is given from command line using config_db
  initial begin
    uvm_config_db #(virtual serdes_interface)::set(uvm_root::get(), "*", "vif", intf); // Virtual Interface Handle
    uvm_config_db#(virtual serdes_interface.DRIVER)::set(null, "uvm_test_top.env.*", "drv_vif", intf.DRIVER); // Virtual interface with Driver modport handle
    uvm_config_db#(virtual serdes_interface.MONITOR)::set(null, "uvm_test_top.env.*", "mon_vif", intf.MONITOR); // Virtual interface with Driver modport handle
    uvm_config_db #(int)::set(uvm_root::get(), "*", "serial_transaction_count", serial_transaction_count); // Transaction count
    uvm_config_db #(int)::set(uvm_root::get(), "*", "parallel_transaction_count", parallel_transaction_count); // Transaction count
    uvm_config_db #(int)::set(uvm_root::get(), "uvm_test_top.env", "no_of_agents", no_of_agents); // Number of agents
    uvm_config_db #(real)::set(uvm_root::get(), "uvm_test_top", "serial_clk_period", serial_clk_period); // Serial clk period
    run_test("serdes_test");
  end 
  
  initial begin
    #(((serial_clk_period) / 1.0)) serdes_reset = 0; //Deassert of Reset
  end

endmodule : tb_top


 

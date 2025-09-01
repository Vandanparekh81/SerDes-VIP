// -------------------------------------------------------------------------------- //
// File Name : serdes_top_tb.sv
// Author Name : Vandan Parekh
// Propetier Name : ASICraft Technologies LLP
// Description : This Tb Top module inside this module parallel clock serial
// clock configuration is happen and also it connect the dut with interface. 
// -------------------------------------------------------------------------------- // 

// importing the serdes package file which include all the component files
import serdes_pkg::*;

// Timescale
`timescale 1ns/1ps

module tb_top;

  // Properties declaration of top
  int serdes_speed; // Speed of transfer data which is given from command line
  real serial_freq; // Frequency of serial clock
  real parallel_freq; // Frequency of parallel clock
  real serial_clk_period; // Serial clock period
  real parallel_clk_period; // Parallel clock period
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

    function real get_time_period_rounded(real frequency_hz, int decimal_places);
      real time_period, multiplier;
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
      `uvm_warning("Warning FROM TOP", $sformatf("You did not provide a SPEED value from command line. Using default 1G"))
      serdes_speed = 1;  // If user did not give value from command line we take by default 1G
    end else begin
      `uvm_info("Serdes Speed", $sformatf("Your Selected Speed is %0d G", serdes_speed), UVM_LOW)
      if(serdes_speed > 10 || serdes_speed < 1) begin
        `uvm_fatal("No support for Serdes_Speed",{"serdes speed must be between 1 to 10 G"})
      end
      serial_freq = serdes_speed * 1000000000.0;  
      `uvm_info("Speed Frequency", $sformatf("Serdes_speed frequency is %0f", serial_freq), UVM_LOW)
    end

    //Calculation for clock configuration
    serial_clk_period = get_time_period_rounded(serial_freq, 2); //serial Clock period is Inverse of serial frequency taking into nanoseconds we take 1e9
    parallel_clk_period = serial_clk_period * WIDTH; //parallel Clock period is Inverse of parallel frequency taking into nanoseconds we take 1e9

    `uvm_info("Serial CLK Period", $sformatf("Serial CLK Period = %f ns", serial_clk_period), UVM_LOW)
    `uvm_info("Parallel CLK Period", $sformatf("Parallel CLK Period = %f ns", parallel_clk_period), UVM_LOW)
  end

  //Configuration of parallel clock and serial clock
  //If reset is off then both clock immediately become zero
  initial begin
    fork
      
      // Parallel Clock 
      forever begin
        fork
          
          // Thread 1
          begin
            if(serdes_reset == 0) begin
              #((parallel_clk_period) / 2.0) parallel_clk = ~parallel_clk;
            end

            else begin
              wait(!serdes_reset);
            end
          end

          // Thread 2
          begin
            if(serdes_reset == 1) begin
              parallel_clk = 0;
            end

            else begin
              wait(serdes_reset);
            end
          end

        join_any
        disable fork;
        if(serdes_reset == 1) begin
          parallel_clk = 0;
          wait(!serdes_reset);
          parallel_clk = 1;
        end

      end

      // Serial Clock
      forever begin
        fork
          begin
            if(serdes_reset == 0) begin
              #((serial_clk_period) / 2.0) serial_clk = ~serial_clk;
            end

            else begin
              wait(!serdes_reset);
            end

          end

          begin

            if(serdes_reset) begin
              serial_clk = 0;
            end

            else begin
              wait(serdes_reset);
            end

          end

        join_any
        disable fork;
        if(serdes_reset == 1) begin
          serial_clk = 0;
          wait(!serdes_reset);
          serial_clk = 1;
        end
      end

    join
  end

  
  // Here we set all the variables which is given from command line using config_db
  initial begin
    uvm_config_db #(virtual serdes_interface)::set(null, "*", "vif", intf); // Virtual Interface Handle
    uvm_config_db#(virtual serdes_interface.DRIVER)::set(null, "uvm_test_top.env.*", "drv_vif", intf.DRIVER); // Virtual interface with Driver modport handle
    uvm_config_db#(virtual serdes_interface.MONITOR)::set(null, "uvm_test_top.env.*", "mon_vif", intf.MONITOR); // Virtual interface with Driver modport handle
    uvm_config_db #(real)::set(null, "uvm_test_top", "serial_clk_period", serial_clk_period); // Serial clk period
    uvm_config_db #(int)::set(null, "*", "serdes_speed", serdes_speed); // Speed of serdes this is get in the transaction class for coverage purpose
    run_test("serdes_test");
  end 
  
endmodule : tb_top

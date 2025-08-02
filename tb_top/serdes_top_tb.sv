import serdes_pkg::*;
`timescale 1ns/1ps
module tb_top;
  parameter WIDTH = 10; 
  real serdes_speed;
  real serial_freq;
  real parallel_freq;
  real serial_clk_period;
  real parallel_clk_period;
  int parallel_lanes = WIDTH;
  int transaction_count;

  bit serdes_reset = 1;
  bit serial_clk = 0;
  bit parallel_clk = 1;

  serdes_interface #(.WIDTH(WIDTH)) intf (.serial_clk(serial_clk), .parallel_clk(parallel_clk), .serdes_reset(serdes_reset));

      sipo_shift_register #(.WIDTH(WIDTH)) sipo_inst (
        .serial_clk(intf.serial_clk),
        .parallel_clk(intf.parallel_clk),
        .rst(intf.serdes_reset), // Active-high reset
        .Rx0_p(intf.Rx0_p),
        .Rx0_n(intf.Rx0_n),
        .Rx0(intf.Rx0)
    );

    // PISO shift register instantiation (active-low reset)
    piso_shift_register #(.WIDTH(WIDTH)) piso_inst (
        .serial_clk(intf.serial_clk),
        .parallel_clk(intf.parallel_clk),
        .rst(intf.serdes_reset), // Invert reset for active-low
        .Tx0(intf.Tx0),
        .Tx0_p(intf.Tx0_p),
        .Tx0_n(intf.Tx0_n)
    );
  initial begin
    if (!$value$plusargs("SPEED=%f", serdes_speed)) begin
      $display("Warning: You did not provide a SPEED value. Using default.");
      serdes_speed = 1000000000.0; 
    end else begin
      serdes_speed = serdes_speed * 1000000000.0;  
      $display("Serdes speed is = %0f Hz", serdes_speed);
    end

    if (!$value$plusargs("TRANSACTION_COUNT=%0d", transaction_count)) begin
      $display("Warning: You did not provide a transaction value. Using default.");
      transaction_count = 1; 
    end else begin
      $display("Transaction count is = %0d", transaction_count);
    end

    serial_freq = serdes_speed;
    parallel_freq = serdes_speed / parallel_lanes;
    serial_clk_period = 1.0 * 1e9/ serial_freq;
    parallel_clk_period = 1.0 * 1e9 / parallel_freq; 

    $display("Serial CLK Period = %0f ns", serial_clk_period);
    $display("Parallel CLK Period = %0f ns", parallel_clk_period);
  end

   
  initial begin
    forever begin
      if(serdes_reset == 0) begin
        #((serial_clk_period) / 2.0) serial_clk = ~serial_clk;
      end
      else begin
        serial_clk = 0;
        wait(!serdes_reset);
        serial_clk = 1;
      end
    end
  end
  
  initial begin
    //#(serial_clk_period);
    forever begin
      if(serdes_reset == 0) begin
        #((parallel_clk_period) / 2.0) parallel_clk = ~parallel_clk;
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
  
  initial begin
    uvm_config_db #(virtual serdes_interface)::set(uvm_root::get(), "*", "vif", intf);
    uvm_config_db#(virtual serdes_interface.DRIVER)::set(null, "uvm_test_top.*", "drv_vif", intf.DRIVER);
        uvm_config_db#(virtual serdes_interface.MONITOR)::set(null, "uvm_test_top.*", "mon_vif", intf.MONITOR);
    uvm_config_db #(int)::set(uvm_root::get(), "*", "transaction_count", transaction_count);
    run_test("serdes_test");
  end 
  
  initial begin
    #(((serial_clk_period) / 1.0)) serdes_reset = 0;
  end

endmodule : tb_top

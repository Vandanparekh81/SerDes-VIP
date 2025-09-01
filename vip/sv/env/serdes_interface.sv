//---------------------------------------------------------------------------------------------------//
// File Name : serdes_interface.sv
// Author Name : Vandan Parekh
// Propetier Name : ASICraft Technologies LLP.
// Decription : Interface : This is use to communicate testbench to dut.
// Interface is also a container that contain signal that can be use by dut.
// It is also responsible for synchronization between componentss and tell the directions of the 
// signals to particular component direction means input or output
//---------------------------------------------------------------------------------------------------//

//Parameterized Interface
interface serdes_interface #(parameter WIDTH = 10)
  (
    //port declarations of interface
    input logic serial_clk, // Serial clock :- which is used to convert parallel data to serial data in serializer
    input logic parallel_clk, // Parallel Clock :- which is used to convert serial data into parallel data in deserializer
    input logic serdes_reset // Reset of serdes
  );

  logic [WIDTH-1 : 0] Tx0; // Parallel data that is go inside serializer as a input
  logic [WIDTH-1 : 0] Rx0; // Parallel data that is come from deserializer as a output

  logic Tx0_p; // serial data that is come from serializer as a output
  logic Tx0_n; // Inverse of Tx0_p and this is also output of a serializer

  logic Rx0_p; // serial data that is go to deserializer as a input;
  logic Rx0_n; // this ia also serial data that is go to deserializer as a input and this is inverse of Rx0_p

  //clocking block of driver
  clocking driver_cb @(posedge serial_clk or posedge parallel_clk);
    default input #0 output #0;
    output Tx0;
    output Rx0_p;
    output Rx0_n;
    input Rx0;
    input Tx0_p;
    input Tx0_n;
  endclocking : driver_cb

  //clocking block of monitor
  clocking monitor_cb @(posedge serial_clk or posedge parallel_clk);
    default input #0 output #0;
    input Tx0;
    input Rx0_p;
    input Rx0_n;
    input Rx0;
    input Tx0_p;
    input Tx0_n;
  endclocking : monitor_cb

  //Modport of Driver
  modport DRIVER (clocking driver_cb, input serial_clk, parallel_clk, serdes_reset);
  
  //Modport of Monitor
  modport MONITOR (clocking monitor_cb, input serial_clk, parallel_clk, serdes_reset);

  // Assertions for SerDes protocol verification
    // A1: Inverse polarity for serial signals
    property inverse_polarity_tx;
        @(posedge serial_clk) disable iff (serdes_reset)
        Tx0_n == ~Tx0_p;
    endproperty
    assert_inverse_polarity_tx: assert property(inverse_polarity_tx) $info("Tx0_p is inverse of Tx0_n");
        else `uvm_error("ASSERT_TX_POLARITY", "Tx0_n is not inverse of Tx0_p");

    property inverse_polarity_rx;
        @(posedge serial_clk) disable iff (serdes_reset)
        Rx0_n == ~Rx0_p;
    endproperty
    assert_inverse_polarity_rx: assert property(inverse_polarity_rx) $info("Rx0_p is inverse of Rx0_n");
        else `uvm_error("ASSERT_RX_POLARITY", "Rx0_n is not inverse of Rx0_p");

    // A2: Serial data valid only after reset deassertion
    property serial_data_after_reset;
        @(posedge serial_clk) disable iff (serdes_reset)
        $rose(Tx0_p) || $rose(Rx0_p) |-> ##1 (!$isunknown(Tx0_p) && !$isunknown(Rx0_p));
    endproperty
    assert_serial_data_valid: assert property(serial_data_after_reset) $info("Serial data not unknown after reset");
        else `uvm_error("ASSERT_SERIAL_VALID", "Serial data (Tx0_p or Rx0_p) unknown after reset");

    // A3: Clock activity only when reset is low
    property clocks_active;
        @(posedge serdes_reset)
        ##1 (serial_clk == 0 && parallel_clk == 0);
    endproperty
    assert_clocks_active: assert property(clocks_active) $info("Clock is disable during the reset condition");
        else `uvm_error("ASSERT_CLOCKS", "Clocks active during reset");

endinterface : serdes_interface

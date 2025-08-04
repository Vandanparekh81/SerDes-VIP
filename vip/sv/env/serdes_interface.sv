//---------------------------------------------------------------------------------------------------//
// Interface : This is use to communicate testbench to dut.
// Interface is also a container that contain signal that can be use by dut.
// It is also responsible for synchronization between componentss and tell the directions of the signals to particular component direction means input or output
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
    // A1: Reset behavior - All outputs should be at reset values
    property reset_values;
        @(posedge serdes_reset)
        (Tx0 == 0 && Rx0 == 0 && Tx0_p == 0 && Tx0_n == 1 && Rx0_p == 0 && Rx0_n == 1);
    endproperty
    assert_reset_values: assert property (reset_values)
        else `uvm_error("ASSERT_RESET", "Reset values for signals not met during serdes_reset high");

    // A2: Inverse polarity for serial signals
    property inverse_polarity_tx;
        @(posedge serial_clk) disable iff (serdes_reset)
        Tx0_n == ~Tx0_p;
    endproperty
    assert_inverse_polarity_tx: assert property (inverse_polarity_tx)
        else `uvm_error("ASSERT_TX_POLARITY", "Tx0_n is not inverse of Tx0_p");

    property inverse_polarity_rx;
        @(posedge serial_clk) disable iff (serdes_reset)
        Rx0_n == ~Rx0_p;
    endproperty
    assert_inverse_polarity_rx: assert property (inverse_polarity_rx)
        else `uvm_error("ASSERT_RX_POLARITY", "Rx0_n is not inverse of Rx0_p");

    // A3: Parallel data stability during serial transmission
    property parallel_data_stable;
        @(posedge parallel_clk) disable iff (serdes_reset)
        $stable(Tx0) |-> ##[1:WIDTH] $stable(Rx0);
    endproperty
    assert_parallel_data_stable: assert property (parallel_data_stable)
        else `uvm_error("ASSERT_STABLE", "Tx0 or Rx0 changed unexpectedly during parallel clock cycle");

    // A4: Serial data valid only after reset deassertion
    property serial_data_after_reset;
        @(posedge serial_clk) disable iff (serdes_reset)
        $rose(Tx0_p) || $rose(Rx0_p) |-> ##1 (!$isunknown(Tx0_p) && !$isunknown(Rx0_p));
    endproperty
    assert_serial_data_valid: assert property (serial_data_after_reset)
        else `uvm_error("ASSERT_SERIAL_VALID", "Serial data (Tx0_p or Rx0_p) unknown after reset");

    // A5: PISO serial output matches parallel input
    /* logic [WIDTH-1:0] captured_Tx0;
    always @(posedge parallel_clk) if (!serdes_reset) captured_Tx0 <= Tx0;
    property piso_serial_output;
        @(posedge serial_clk) disable iff (serdes_reset)
        for (genvar i = 0; i < WIDTH; i++) (
            ##i Tx0_p == captured_Tx0[WIDTH-1-i]
        );
    endproperty
    assert_piso_output: assert property (piso_serial_output)
        else `uvm_error("ASSERT_PISO", $sformatf("Tx0_p does not match captured Tx0: %b", captured_Tx0));*/

    // A6: SIPO parallel output matches serial input
    /*logic [WIDTH-1:0] captured_Rx0_p;
    always @(posedge serial_clk) begin
        if (!serdes_reset) begin
            for (int i = 0; i < WIDTH; i++) begin
                ##i captured_Rx0_p[WIDTH-1-i] <= Rx0_p;
            end
        end
    end
    property sipo_parallel_output;
        @(posedge parallel_clk) disable iff (serdes_reset)
        Rx0 == captured_Rx0_p;
    endproperty
    assert_sipo_output: assert property (sipo_parallel_output)
        else `uvm_error("ASSERT_SIPO", $sformatf("Rx0 does not match captured Rx0_p: %b", captured_Rx0_p));*/

    // A7: Clock activity only when reset is low
    property clocks_active;
        @(posedge serdes_reset)
        (serial_clk == 0 && parallel_clk == 0);
    endproperty
    assert_clocks_active: assert property (clocks_active)
        else `uvm_error("ASSERT_CLOCKS", "Clocks active during reset");
    
endinterface : serdes_interface


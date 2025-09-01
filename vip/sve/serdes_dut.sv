// -------------------------------------------------------------------------------------------- //
// File Name : serdes_dut.sv
// Author Name : Vandan Parekh
// Propetier Name : ASICraft Technologies LLP.
// Decription : This is sanity_dut 
// This is dut of serializer and deserializer 
// Serializer DUT convert parallel data into serial data and gives serial data  at every 
// rising edge of the serial clock.
// Deserializer DUT Convert serial data into parallel data and give parallel data at every 
// rising edge of parallel clock.
// -------------------------------------------------------------------------------------------- //

// Timescale of Dut
`timescale 1ns/1ps

// Deserializer Dut
module sipo_shift_register #(parameter WIDTH=10) 
(
  // Port Declaration
  input wire serial_clk, //Serial clock
  input wire parallel_clk, // Parallel_clock
  input wire rst, // Reset
  input wire Rx0_p, Rx0_n, // Serial data
  output reg [WIDTH-1 : 0] Rx0 // parallel data
);

  reg [WIDTH-1 : 0] shift_reg; // Temporary register
  reg [WIDTH-1 : 0] parallel_data; // Temporary Register
  int sipo_main_count = 0; // Flag
  int count = 0; // Flag

// Inside this always block serial data continously converted into parallel
   always @(posedge serial_clk or posedge rst) begin
    if(rst) begin
      // Reset Condition
      shift_reg <= '0;
      parallel_data <= 0;
      sipo_main_count <= 1;
      count = 0;
      `uvm_info("DUT SIPO RESET", $sformatf("RESET CONDITION DISPLAY Serial clock [%0t] Rx0_p = %b | Rx0_p Decimal = %0d |shift_reg = %b | shift_reg in decimal = %0d", $time, Rx0_p, Rx0_p, shift_reg, shift_reg), UVM_LOW)
    end
    else begin
       // Logic of conversion
      if(sipo_main_count >= 1) begin
        shift_reg <= {shift_reg[WIDTH-2:0], Rx0_p};
        sipo_main_count++;
        if(count == 0) begin
          if(sipo_main_count == WIDTH+4) begin
            sipo_main_count <= 1;
            parallel_data <= shift_reg;
            count<=count+1;
          end
        end
        else begin
          if(sipo_main_count == WIDTH+1) begin
            sipo_main_count <= 1;
            parallel_data <= shift_reg;
            count<= count+1;
          end
        end
      `uvm_info("DUT SIPO", $sformatf("Serial clock [%0t] Rx0_p = %b | Rx0_p Decimal = %0d |shift_reg = %b | shift_reg in decimal = %0d | sipo_main_count = %0d", $time, Rx0_p, Rx0_p, shift_reg, shift_reg, sipo_main_count), UVM_LOW);
      end
    end
  end

  // Assigning the parallel data to interface
  assign Rx0 = parallel_data;

   /* always_ff @(posedge serial_clk or posedge rst) begin
    if (rst) begin
      shift_reg <= '0;
      sipo_main_count <= '0;
    end else begin
      shift_reg <= {shift_reg[WIDTH-2:0], Rx0_p}; // shift left
      sipo_main_count <= (sipo_main_count == WIDTH-1) ? 0 : sipo_main_count + 1;
    end
  end

  // Parallel Clock Domain: Capturing 10-bit data after full collection
  always_ff @(posedge parallel_clk or posedge rst) begin
    if (rst) begin
      parallel_data <= '0;
    end else begin
      parallel_data <= shift_reg;
      `uvm_info("DUT SIPO", $sformatf("Parallel clock [%0t] parallel_data = %b | parallel_data Decimal = %0d |shift_reg = %b | shift_reg in decimal = %0d | sipo_main_count = %0d", $time, parallel_data, parallel_data, shift_reg, shift_reg, sipo_main_count), UVM_LOW)
    end
  end

  // Connect to interface output
  assign Rx0 = parallel_data; */

endmodule  


//Serializer Dut
module piso_shift_register #(
    parameter WIDTH = 10 
) (
    // Port Declaration
    input wire serial_clk, // Serial clock
    input wire parallel_clk, // Parallel clock
    input wire rst, // Reset
    input reg [WIDTH-1:0] Tx0, // Parallel data 
    output reg Tx0_p, Tx0_n  // Serial Data
);
    reg [WIDTH-1:0] shift_reg; // Temporary register
    int i = 1; // Flag
    int count = 0; // Flag
    int main_count = 0; // Flag


    /* always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= '0;
        end 
        else if (load) begin
            shift_reg <= Rx0_p;
        end 
        else begin
            shift_reg <= {shift_reg[WIDTH-2:0], 1'b0}; 
        end
    end */

    // Inside this loop every posedge of serial clock parallel data msb given to serial data
    always @(posedge serial_clk or posedge rst) begin
      if(rst) begin
        Tx0_p <= 0;
        Tx0_n <= 1;
        `uvm_info("DUT PISO RESET CONDITION", $sformatf("RESET CONDITION Serial Clock [%0t] Tx0 = %b | Tx0 Decimal = %0d |Tx0_p = %b | Tx0_n = %0d", $time, Tx0, Tx0, Tx0_p, Tx0_n), UVM_LOW)
      end
      else begin
        if(main_count >= 1) begin 
          Tx0_p <= Tx0[WIDTH-i];
          Tx0_n <= ~Tx0[WIDTH-i];
          `uvm_info("DUT PISO", $sformatf("Serial Clock [%0t] Tx0 = %b | Tx0 Decimal = %0d |Tx0_p = %b | Tx0_n = %0d", $time, Tx0, Tx0, Tx0_p, Tx0_n), UVM_LOW)
          main_count++;
          if(main_count == WIDTH+1) begin
            main_count <= 0;
            i <= 1;
          end
          else begin
            i <= i+1;
          end
        end

      end
    end

    // Inside this loop flag is resetting
    always @(posedge parallel_clk or posedge rst) begin
      if(rst) begin
        main_count <= 0;
      end

      else begin
        main_count <= 1;
        i <= 1;
      end

    end


endmodule


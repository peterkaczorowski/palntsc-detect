// =============================================================================
// Project      : SavoMax Video Mode Detector
// File         : savomax.v / tb_savomax.v
// Description  : Example module and testbench for detecting NTSC/PAL video
//                standards based on VSYNC signal analysis.
//
// Author       : Piotr D. Kaczorowski
// =============================================================================

`timescale 10ns / 10ns


`define FALSE       1'b0
`define TRUE        1'b1

`define FORMAT_UNKNOWN  3'b000
`define FORMAT_NTSC     3'b010
`define FORMAT_PAL      3'b100


module savomax(clk_in, csync_in, csync_out, vsync_in);

  parameter CLK_FREQ = 250_000;
  parameter NTSC_PAL_TRESHOLD = 18;
  localparam TRESHOLD_COUNTER = (CLK_FREQ / 1000) * NTSC_PAL_TRESHOLD;

  input clk_in;
  input csync_in;
  output csync_out;
  input vsync_in;


  // Counter to count clock cycles between falling edges
  reg [31:0] clk_counter = 0;

  // Internal register to store the previous state of vsync
  reg [0:0] vsync_prev;
  reg [0:0] vsync_sampled;

  // PAL/NTSC format validation flag
  reg [0:0] format_valid;
  reg [2:0] format_type;
  reg [31:0] vsync_prev_counter;
  reg [31:0] vsync_period;



  initial begin
    vsync_sampled = `FALSE;

    format_valid = `FALSE;
    format_type = `FORMAT_UNKNOWN;

    vsync_prev_counter = 0;
    vsync_period = 0;
  end


  // Detect falling edge on vsync_in
  always @(posedge clk_in) begin

    // determine vsync period
    if (!format_valid) begin

      if (vsync_sampled) begin

        // VSYNC falling edge detectection
        if (vsync_prev && !vsync_in) begin

          if (vsync_prev_counter == 0) begin
              vsync_prev_counter <= clk_counter;
          end else begin
              vsync_period <= clk_counter - vsync_prev_counter;
              vsync_prev_counter <= clk_counter;
              format_valid <= `TRUE;
          end

        end
      end else begin
        vsync_sampled <= `TRUE;
      end

      vsync_prev <= vsync_in;

    // determine format type
    end else if (format_type == `FORMAT_UNKNOWN) begin

      format_type <= (vsync_period > TRESHOLD_COUNTER) ? `FORMAT_PAL : `FORMAT_NTSC;

    // log detected format_type and end the simulation
    end else begin

      $display("[clk_counter=%d] ->>> Format valided with period time %d: for clk=250kHz. Format: %s", clk_counter, vsync_period, (format_type == `FORMAT_PAL) ? "PAL" : "NTSC" );
      $finish;
    end


      clk_counter <= clk_counter + 1;
  end


endmodule

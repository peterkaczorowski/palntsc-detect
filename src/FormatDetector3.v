// =============================================================================
// Project      : SAVO MAX
// File         : FormatDetector3.v
// Description  : Simple NTSC/PAL detector based on VSYNC period
// Author       : Piotr D. Kaczorowski
// =============================================================================

`timescale 10ns / 10ns
`include "Consts.vh"

module FormatDetector3 (clk_in, vsync_in, format_valid, format_type);

  input  wire clk_in;
  input  wire vsync_in;
  output reg  format_valid;
  output reg  format_type;


  localparam CLK_FREQ           = `CLK_FREQ;
  localparam NTSC_PAL_THRESHOLD = `NTSC_PAL_THRESHOLD;
  localparam THRESHOLD_COUNTER  = (CLK_FREQ / 1000) * NTSC_PAL_THRESHOLD;

  reg vsync_prev = 0;
  reg [20:0] vsync_counter = 0;

  initial begin
    format_valid = `FALSE;
    format_type  = `FORMAT_NTSC;
  end

  always @(posedge clk_in) begin
    vsync_prev <= vsync_in;

    if (!format_valid) begin
      // Detect falling edge on vsync
      if (vsync_prev && !vsync_in) begin
        if (vsync_counter != 0) begin
          format_type  <= (vsync_counter > THRESHOLD_COUNTER) ? `FORMAT_PAL : `FORMAT_NTSC;
          format_valid <= `TRUE;
        end
        vsync_counter <= 1;  // Start counting from 1
      end else if (vsync_counter != 0) begin
        vsync_counter <= vsync_counter + 1;
      end
    end
  end

endmodule


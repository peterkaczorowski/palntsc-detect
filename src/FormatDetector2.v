// =============================================================================
// Project      : SAVO MAX
// File         : FormatDetector2.v
// Description  :
//
//
// Author       : Piotr D. Kaczorowski
// =============================================================================


`timescale 10ns / 10ns

`include "Consts.vh"


module FormatDetector2(clk_in, vsync_in, format_valid, format_type);

  input clk_in;
  input vsync_in;
  output reg format_valid;
  output reg format_type;

  localparam CLK_FREQ = `CLK_FREQ;
  localparam NTSC_PAL_THRESHOLD = `NTSC_PAL_THRESHOLD;
  localparam THRESHOLD_COUNTER = (CLK_FREQ / 1000) * NTSC_PAL_THRESHOLD;

  reg vsync_sampled;
  reg vsync_prev;
  reg [20:0] vsync_counter;


  initial begin
    vsync_sampled = `FALSE;
    vsync_counter = 0;
    format_valid = `FALSE;
    format_type = `FORMAT_NTSC;
  end


  always @(posedge clk_in) begin

    // first read the vsync state
    if (vsync_sampled == `FALSE) begin

      vsync_prev <= vsync_in;
      vsync_sampled <= `TRUE;

    // vsync sampled and we are looking for 1st vblank and 2nd to measure the counter
    end else if (format_valid == `FALSE) begin

      // VSYNC falling edge detectection
      if (vsync_prev == 1 && vsync_in == 0) begin

        // 2nd edge
        if (vsync_counter != 0) begin
          format_type <= (vsync_counter > THRESHOLD_COUNTER) ? `FORMAT_PAL : `FORMAT_NTSC;
          format_valid <= `TRUE;
        end

        // reset the counter
        vsync_counter <= 1;

      // increment if counter is 1 or higher
      end else if (vsync_counter != 0) begin
        vsync_counter <= vsync_counter + 1;
      end

      vsync_prev <= vsync_in;
    end

  end

endmodule


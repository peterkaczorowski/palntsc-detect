// =============================================================================
// Project      : SAVO MAX
// File         : FormatDetector3.v
// Description  : Simple NTSC/PAL detector based on VSYNC period
// Author       : Piotr D. Kaczorowski
// =============================================================================

`timescale 10ns / 10ns
`include "Consts.vh"

module FormatDetector5 (clk_in, rst, vsync_in, format_valid, format_type);

  input wire  clk_in;
  input wire  rst;
  input wire  vsync_in;
  output reg  format_valid;
  output reg  format_type;

  localparam THRESHOLD_COUNTER  = `CLK_FREQ * `NTSC_PAL_THRESHOLD_MS / 1000;

  reg vsync_prev;
  reg [20:0] vsync_counter;
  reg [1:0] sample_count;


  always @(posedge clk_in) begin
    if (rst) begin
      vsync_prev    <= 0;
      vsync_counter <= 0;
      sample_count  <= 0;
      format_valid  <= `FALSE;
      format_type   <= `FORMAT_NTSC;
    end else begin
      vsync_prev <= vsync_in;

      if (!format_valid) begin
        // Detect falling edge on vsync
        if (vsync_prev && !vsync_in) begin
          if (vsync_counter != 0) begin
            sample_count <= sample_count + 1;

            // 3rd measurement is important
            if (sample_count == 2) begin
              format_type  <= (vsync_counter > THRESHOLD_COUNTER) ? `FORMAT_PAL : `FORMAT_NTSC;
              format_valid <= `TRUE;
            end
          end
          vsync_counter <= 1;  // Start counting from 1
        end else if (vsync_counter != 0) begin
          vsync_counter <= vsync_counter + 1;
        end
      end
    end

  end

endmodule


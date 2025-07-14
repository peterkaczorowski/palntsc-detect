// =============================================================================
// Project      : SAVO MAX
// File         : HSyncCounter.v
// Description  : Simple line counter based on CSYNC
// Author       : Piotr D. Kaczorowski
// =============================================================================

`include "Consts.svh"

module HSyncCounter (
    clk_in,
    rst,
    csync_in,
    line_count,
    line_count_valid,
    format_valid,
    format_type
);

  input  logic clk_in;
  input  logic rst;
  input  logic csync_in;
  output logic [8:0] line_count;
  output logic line_count_valid;
  output logic format_valid;
  output logic format_type;

  localparam HSYNC_THRESHOLD = `CLK_FREQ * `HSYNC_THRESHOLD_US / 1_000_000;
  localparam NTSC_PAL_THRESHOLD_LINES   = 287;   // PAL ~312, NTSC ~262

  logic        csync_prev;
  logic        measuring;
  logic  [4:0] counter;  //12:0, 4
  logic  [1:0] wide_count;
  logic [ 1:0] validation_counter;
  logic [ 8:0] last_line_count;


  always_ff @(posedge clk_in) begin
    if (rst) begin
      csync_prev          <= 1'b1;
      measuring           <= `FALSE;
      counter             <= 5'b0;  //13'b , 5
      wide_count          <= 2'b0;
      line_count          <= 9'b0;
      line_count_valid    <= `FALSE;
      format_valid        <= `FALSE;
      format_type         <= `FORMAT_NTSC;  // Default to NTSC
      validation_counter  <= 2'b0;
      last_line_count     <= 0;
    end else begin
      csync_prev <= csync_in;

      // Detect falling edge: start measuring
      if (!measuring && csync_prev && !csync_in) begin
        measuring <= `TRUE;
        counter   <= 1'b0;

        // Count duration of the low-level signal
      end else if (measuring && !csync_in) begin
        counter <= counter + 1'b1;

        // Detect rising edge: stop measuring
      end else if (measuring && !csync_prev && csync_in) begin
        measuring <= `FALSE;

        // Wide pulse detected
        if (counter >= HSYNC_THRESHOLD) begin
          wide_count <= wide_count + 1'b1;

          if (wide_count == 2) begin
            wide_count <= 1'b0;
            line_count <= 1'b0;
            line_count_valid <= `TRUE;
            validation_counter <= validation_counter + 1'b1;
            last_line_count <= line_count;
          end

          // Short pulse detected: increment line counter
        end else begin
          line_count <= line_count + 1'b1;
        end

        if (validation_counter == 2'b11) begin
          format_type  <= (last_line_count > NTSC_PAL_THRESHOLD_LINES) ? `FORMAT_PAL : `FORMAT_NTSC;
          format_valid <= `TRUE;
        end

      end
    end
  end

endmodule


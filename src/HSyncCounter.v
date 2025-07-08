// =============================================================================
// Project      : SAVO MAX
// File         : HSyncCounter.v
// Description  : Simple line counter based on CSYNC
// Author       : Piotr D. Kaczorowski
// =============================================================================

`timescale 10ns / 10ns   

`include "Consts.vh"

module HSyncCounter (clk_in, rst, csync_in, line_count, line_count_valid);
  
  input             clk_in;                   
  input             rst;
  input             csync_in;
  output reg [8:0]  line_count;
  output reg        line_count_valid;
  
  
  localparam HSYNC_THRESHOLD = `CLK_FREQ * `HSYNC_THRESHOLD_US / 1_000_000; 
    
  reg csync_prev;
  reg measuring;
  reg [31:0] counter;
  reg [1:0] wide_count;
  
  
  always @(posedge clk_in) begin
    if (rst) begin
      csync_prev       <= 1'b1;
      measuring        <= `FALSE;
      counter          <= 32'd0;
      wide_count       <= 2'd0;
      line_count       <= 9'd0;
      line_count_valid <= `FALSE;
    end else begin
      csync_prev <= csync_in;

      // Detect falling edge: start measuring
      if (!measuring && csync_prev && !csync_in) begin
        measuring <= `TRUE;
        counter   <= 32'd0;
      end
      // Count duration of the low-level signal
      else if (measuring && !csync_in) begin
          counter <= counter + 1;
      end
      // Detect rising edge: stop measuring
      else if (measuring && !csync_prev && csync_in) begin
        measuring <= `FALSE;

        if (counter >= HSYNC_THRESHOLD) begin
          // Wide pulse detected
          wide_count <= wide_count + 1;

          // Reset line counter after 3 wide pulses
          if (wide_count == 2) begin
              wide_count <= 0;
              line_count <= 9'd0;
              line_count_valid <= `TRUE;
          end
        end else begin
          // Short pulse detected: increment line counter
          line_count <= line_count + 1;
        end
      end
    end
  end
  
endmodule

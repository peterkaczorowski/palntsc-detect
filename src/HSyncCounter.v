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
    
  localparam        HSYNC_THRESHOLD = `CLK_FREQ * `HSYNC_THRESHOLD_US / 1_000_000; 
    
  reg               csync_prev;
  reg               measuring;  
  reg [12:0]        counter;
  reg [1:0]         wide_count;
  
  
  always @(posedge clk_in) begin
    if (rst) begin
      csync_prev        <= 1;
      measuring         <= `FALSE;
      counter           <= 0;
      wide_count        <= 0;
      line_count        <= 0;
      line_count_valid  <= `FALSE;
    end else begin
      csync_prev <= csync_in;

      // Detect falling edge: start measuring
      if (!measuring && csync_prev && !csync_in) begin
        measuring <= `TRUE;
        counter   <= 0;
      
      // Count duration of the low-level signal
      end else if (measuring && !csync_in) begin
          counter <= counter + 1;
      
      // Detect rising edge: stop measuring
      end else if (measuring && !csync_prev && csync_in) begin
        measuring <= `FALSE;
        
        // Wide pulse detected
        if (counter >= HSYNC_THRESHOLD) begin          
          wide_count <= wide_count + 1;

          // Reset line counter after 3 wide v-sync pulses
          if (wide_count == 2) begin
              wide_count <= 0;
              line_count <= 0;
              line_count_valid <= `TRUE;
          end                                
          
        // Short pulse detected: increment line counter
        end else begin          
          line_count <= line_count + 1;
        end           
      
      end
    end
  end
  
endmodule

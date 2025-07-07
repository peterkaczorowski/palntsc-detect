// =============================================================================
// Project      : SavoMax Video Mode Detector
// File         : savomax.v / tb_savomax.v
// Description  : Example module and testbench for detecting NTSC/PAL video
//                standards based on VSYNC signal analysis.
// 
// Author       : Piotr D. Kaczorowski
// =============================================================================

`timescale 10ns / 10ns


`define FALSE  			1'b0	   
`define TRUE  			1'b1

`define FORMAT_NTSC     3'b010
`define FORMAT_UNKNOWN  3'b000
`define FORMAT_NTSC     3'b010
`define FORMAT_PAL      3'b100

module savomax #(
	CLK_FREQ = 250_000,			// 250 kHz
	NTSC_PAL_TRESHOLD = 18		// 18 ms (~55Hz)
)(
	input wire clk_in, 
	
	input wire csync_in,
	output wire csync_out,
	
	input wire vsync_in
);

	localparam TRESHOLD_COUNTER = (CLK_FREQ / 1000) * NTSC_PAL_TRESHOLD;

	// Counter to count clock cycles between falling edges
	reg [31:0] clk_counter = 0;

	// Internal register to store the previous state of vsync
	reg [0:0] vsync_prev;	
	
	// PAL/NTSC format validation flag
	reg [0:0] format_valid;
	reg [2:0] format_type;
	reg [31:0] vsync_prev_counter;
	reg [31:0] vsync_period;
	
	
	
	initial format_valid = `FALSE;		   
	initial format_type = `FORMAT_UNKNOWN;
	initial vsync_prev_counter = 0;
	initial vsync_period = 0;	
		

	// Detect falling edge on vsync_in
	always @(posedge clk_in) begin			
		
		// determine vsync period
		if (!format_valid) begin
			
			// VSYNC falling edge detectection
			if (vsync_prev == 1 && vsync_in == 0) begin
		        	
	            if (vsync_prev_counter == 0) begin
	                vsync_prev_counter <= clk_counter;
	            end else begin
	                vsync_period <= clk_counter - vsync_prev_counter;
	                vsync_prev_counter <= clk_counter;
	                format_valid <= `TRUE;
				end				 						
				
			end	 
			
			vsync_prev <= vsync_in;
			
		// determine format type
		end else if (format_type == `FORMAT_UNKNOWN) begin
										
			format_type <= (vsync_period > TRESHOLD_COUNTER) ? `FORMAT_PAL : `FORMAT_NTSC;		
			
		// log detected format_type and end the simulation
		end	else begin
		
			$display("3. [clk_counter=%d] ->>> Format valided with period time %d: for clk=250kHz. Format: %s", clk_counter, vsync_period, (format_type == `FORMAT_PAL) ? "PAL" : "NTSC" ); 
			$finish;
		end
		
		
	    clk_counter <= clk_counter + 1;
	end


endmodule

// =============================================================================
// Project      : SAVO MAX
// File         : NTSCPALDetector.sv
// Description  : NTSC/PAL detector based on VSYNC period and 10 kHz oscillator
// Author       : Piotr D. Kaczorowski
// =============================================================================


module NTSCPALDetector (
    input clk_10k,
    input vsync_in,
    output logic is_pal,
    output logic is_ntsc
);

  // 8× prescaler divides 10 kHz input into 1.25 kHz pulses
  bit   [2:0] counter = 1'b0;
  bit         rst_n = 1'b0;
  logic       pulse;

  always_ff @(posedge clk_10k or negedge rst_n) begin
    if (!rst_n) begin
      counter <= 0;
    end else begin
      counter <= counter + 1'b1;
    end
  end
  assign pulse = &counter;


  // VSYNC debouncing logic to filter noise and glitches.
  // Ensures stable VSYNC signal before further processing.
  logic vsync_ff1, vsync_ff2, vsync_clean;

  always_ff @(posedge clk_10k) begin
    vsync_ff1 <= vsync_in;
    vsync_ff2 <= vsync_ff1;
  end
  assign vsync_clean = vsync_ff2;


  // NTSC/PAL detector using 1.25 kHz pulses.
  // Count >= 24 indicates PAL; less means NTSC.
  bit [4:0] pulse_counter    = 5'b0;
  bit [4:0] pulses_per_frame = 5'b0;
  logic vsync_prev;

  always_ff @(posedge clk_10k) begin
    vsync_prev <= vsync_clean;
    if (vsync_prev && !vsync_clean) begin
      pulses_per_frame <= pulse_counter;
      pulse_counter <= 5'b0;
      rst_n <= 1'b1;
    end else if (pulse) begin
      pulse_counter <= pulse_counter + 1'b1;
    end
  end

  // Status logic
  // Test if the 5-bit value is '11000' (decimal 24) or greater
  assign is_pal  = pulses_per_frame[4] & pulses_per_frame[3];
  assign is_ntsc = !is_pal;

endmodule


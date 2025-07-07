// =============================================================================
// Project      : SavoMax Video Mode Detector
// File         : savomax.v / tb_savomax.v
// Description  : Example module and testbench for detecting NTSC/PAL video
//                standards based on VSYNC signal analysis.
//
// Author       : Piotr D. Kaczorowski
// =============================================================================

`timescale 10ns / 10ns

module UUT;

  reg clk_in;

  reg csync_in;
  wire csync_out;

  reg vsync_in;

  reg csync2_in;
  reg vsync2_in;


  // Module init
  savomax uut (
    .clk_in(clk_in),
    .csync_in(csync_in),
    .csync_out(csync_out),
    .vsync_in(vsync_in)
  );

  // Clock 250 kHz - #200
  initial begin
    clk_in = 0;
    forever #200 clk_in = ~clk_in;
  end


  // Start simulation
  initial begin
    //#500000;  //  5 ms
    //#200000;  // 20 ms

    #5000000;   // 50 ms

    $display("That's all folks");
    $finish;
  end

endmodule

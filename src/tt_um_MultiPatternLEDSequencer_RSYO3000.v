module tt_um_MultiPatternLEDSequencer_RSYO3000 (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches for clk_selector and pattern_sel
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 LEDs
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled, not used circuit can be turned off when pattern_sel = 0
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
assign uio_out = 0;
assign uio_oe = 0;
    
MultiPatternLEDSequencer M0
(
    .clk_10MHz(clk),
    .rstn(rst_n),
    .clk_selector(ui_in[1:0]),
    .pattern_sel(ui_in[6:2]),
    .led_out(uo_out)
);

endmodule

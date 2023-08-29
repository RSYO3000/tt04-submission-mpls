module MultiPatternLEDSequencer (
    input wire clk_10MHz,
    input wire rstn,
    input wire [1:0] clk_selector,
    input wire [4:0] pattern_sel,
    output wire [7:0] led_out
);

wire clk_pll;

PLL_10MHztoNHz PLL_INSTANCE
(
.clk_10MHz(clk_10MHz),
.rstn(rstn),
.clk_selector(clk_selector),
.clk_pll(clk_pll)
);

MPLS MPLS_INSTANCE
(
.clk_pll(clk_pll),
.rstn(rstn),
.pattern_sel(pattern_sel),
.led_out(led_out)
);


endmodule

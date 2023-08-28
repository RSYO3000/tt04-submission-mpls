module PLL_10MHztoNHz (
    input wire clk_10MHz,
    input wire rstn,
    input wire [1:0] clk_selector,
    output reg clk_pll
);

reg [21:0] counter = 0;

always @(posedge clk_10MHz or negedge rstn) begin
    if (!rstn) begin
        counter <= 0;
        clk_pll <= 0;
    end else if (counter == 0) begin
        case (clk_selector)
            2'b00: counter <= 10_000_000; // 10_000_000 cycles of 10MHz = 1s, 1Hz
            2'b01: counter <= 5_000_000;  // 5_000_000 cycles of 10MHz = 500ms, 2Hz
            2'b10: counter <= 1_000_000;  // 1_000_000 cycles of 10MHz = 100ms, 10Hz
            2'b11: counter <= 20_000_000; // 20_000_000 cycles of 10MHz = 2s, 0.5Hz
            default: counter <= 0;
        endcase
        clk_pll <= ~clk_pll;
    end else begin
        counter <= counter - 1;
    end
end
endmodule

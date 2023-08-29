module PLL_10MHztoNHz (
    input wire clk_10MHz,
    input wire rstn,
    input wire [1:0] clk_selector,
    output reg clk_pll
);

reg [23:0] counter;

always @(posedge clk_10MHz or negedge rstn) begin
    if (!rstn) begin
        counter <= 0;
        clk_pll <= 0;
    end else if (counter == 0) begin
        case (clk_selector)
            2'b00: counter <= 4_999_999; // 1Hz
            2'b01: counter <= 2_499_999; // 2Hz
            2'b10: counter <= 499_999;  // 10Hz
            2'b11: counter <= 99_999; // 50Hz
            default: counter <= 0;
        endcase
        clk_pll <= ~clk_pll;
    end else begin
        counter <= counter - 1;
    end
end
endmodule

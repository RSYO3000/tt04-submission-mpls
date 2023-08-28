module MPLS (
    input wire clk_pll,
    input wire rstn,
    input wire [3:0] pattern_sel,
    output reg [7:0] led_out
);


reg [3:0] prev_pattern_sel;
always @(posedge clk_pll) begin
    prev_pattern_sel <= pattern_sel;
end

reg [7:0] pattern_counter;
always @(posedge clk_pll or negedge rstn) begin
    if (!rstn) begin
        pattern_counter <= 8'b00000000;
    end else begin
        pattern_counter <= pattern_counter + 1;
    end
end

reg [7:0] oh_counter;
always @(posedge clk_pll or negedge rstn) begin
    if (!rstn) begin
        oh_counter <= 8'b00000001;
    end else if (pattern_sel !== prev_pattern_sel) begin
        oh_counter <= 8'b00000001;
    end else begin
    oh_counter <= {oh_counter[6],oh_counter[5],oh_counter[4],oh_counter[3],
            oh_counter[2],oh_counter[1],oh_counter[0],oh_counter[7]};
    end
end

reg [7:0] lfsr_reg;
wire feedback = lfsr_reg[6] ^ lfsr_reg[4] ^ lfsr_reg[3] ^ lfsr_reg[2]; // Feedback taps

always @(posedge clk_pll or negedge rstn) begin
    if (!rstn) begin
        lfsr_reg <= 8'b11111111;
    end else if (pattern_sel !== prev_pattern_sel) begin
        lfsr_reg <= pattern_counter;
    end else begin
        lfsr_reg <= {lfsr_reg[6:0], feedback};
    end
end


always @(posedge clk_pll) begin
    case (pattern_sel)
        // Pattern 0: All LEDs OFF
        4'd0: led_out <= 8'b00000000;

        // Pattern 1: All LEDs ON
        4'd1: led_out <= 8'b11111111;

        // Pattern 2: Blinking LEDs
        4'd2: led_out <= pattern_counter[0] ? 8'b11111111 : 8'b00000000;

	// Pattern 3: Running lights
	4'd3: led_out <= oh_counter;

        // Pattern 4: Alternating LEDs
        4'd4: led_out <= pattern_counter[0] ? 8'b10101010 : 8'b01010101;

        // Pattern 5: Negative running lights
	4'd5: led_out <= ~oh_counter;

        // Pattern 6: KR effect
        //4'd6: led_out = {led_out[6:1], pattern_counter[1], pattern_counter[1], led_out[0]};
 	4'd6: led_out <= {led_out[6:0], pattern_counter[1], pattern_counter[1]};

        // Pattern 7: Bouncing lights
        4'd7: led_out <= (pattern_counter[4]) ? oh_counter : ~oh_counter; 

        // Pattern 8: LED wave effect
	4'd8: begin
	    if (pattern_counter[1]) begin
		led_out <= {led_out[6:1], lfsr_reg[7], lfsr_reg[0]};
	    end else begin
		led_out <= {lfsr_reg[7], lfsr_reg[0], led_out[6:1]};
	    end
	end
        // Pattern 9: Alternating LED groups
        4'd9: led_out <= pattern_counter[1] ? 8'b11001100 : 8'b00110011;

        // Pattern 10: Heartbeat
        4'd10: led_out <= ((oh_counter[2] || pattern_counter[0]) & (oh_counter[0] || pattern_counter[2])) ? 8'b11110000 : 8'b00001111;

        // Pattern 11: p-Random LFSR LEDs
        4'd11: led_out <= lfsr_reg;

        // Pattern 12: XOR All
        4'd12: led_out <= lfsr_reg ^ pattern_counter ^ oh_counter;

        // Pattern 13: Binary counter
        4'd13: led_out <= pattern_counter[7:0];

        // Pattern 14: Clockwise LED rotation
	4'd14: begin
	    led_out <= (pattern_counter >> pattern_counter[1:0]) | (pattern_counter << (5 - pattern_counter[1:0]));
	end
        // Pattern 15: XOR Pattern
        4'd15: led_out <= pattern_counter ^ oh_counter;

        default: led_out <= 8'b00000000;
    endcase
end

endmodule

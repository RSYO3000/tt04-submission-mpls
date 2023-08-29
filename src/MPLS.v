module MPLS (
    input wire clk_pll,
    input wire rstn,
    input wire [4:0] pattern_sel,
    output reg [7:0] led_out
);

wire [4:0] internal_pattern_sel;
assign internal_pattern_sel = (&pattern_sel) ? demo_counter[4:0] : pattern_sel;

reg [4:0] demo_counter;
always @(posedge clk_pll or negedge rstn) begin
    if (!rstn) begin
        demo_counter <= 5'b00000;
    end 
    else if (&pattern_sel & oh_counter[7]) begin
        demo_counter <= demo_counter + 1;
    end
    else begin
        demo_counter <= demo_counter;
    end
end

reg [5:0] prev_pattern_sel;
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
    case (internal_pattern_sel)
        // Pattern 0: All LEDs OFF
        5'd0: led_out <= 8'b00000000;

        // Pattern 1: All LEDs ON
        5'd1: led_out <= 8'b11111111;

        // Pattern 2: Blinking LEDs
        5'd2: led_out <= pattern_counter[0] ? 8'b11111111 : 8'b00000000;

	// Pattern 3: Running lights
	5'd3: led_out <= oh_counter;

        // Pattern 4: Alternating LEDs
        5'd4: led_out <= pattern_counter[0] ? 8'b10101010 : 8'b01010101;

        // Pattern 5: Negative running lights
	5'd5: led_out <= ~oh_counter;

        // Pattern 6: KR effect
        //5'd6: led_out = {led_out[6:1], pattern_counter[1], pattern_counter[1], led_out[0]};
 	5'd6: led_out <= {led_out[6:0], pattern_counter[1], pattern_counter[1]};

        // Pattern 7: Bouncing lights
        5'd7: led_out <= (pattern_counter[4]) ? oh_counter : ~oh_counter; 

        // Pattern 8: LED wave effect
	5'd8: begin
	    if (pattern_counter[1]) begin
		led_out <= {led_out[6:1], lfsr_reg[7], lfsr_reg[0]};
	    end else begin
		led_out <= {lfsr_reg[7], lfsr_reg[0], led_out[6:1]};
	    end
	end
        // Pattern 9: Alternating LED groups
        5'd9: led_out <= pattern_counter[1] ? 8'b11001100 : 8'b00110011;

        // Pattern 10: Heartbeat
        5'd10: led_out <= ((oh_counter[2] || pattern_counter[0]) & (oh_counter[0] || pattern_counter[2])) ? 8'b11110000 : 8'b00001111;

        // Pattern 11: p-Random LFSR LEDs
        5'd11: led_out <= lfsr_reg;

        // Pattern 12: XOR All
        5'd12: led_out <= lfsr_reg ^ pattern_counter ^ oh_counter;

        // Pattern 13: Binary counter
        5'd13: led_out <= pattern_counter[7:0];

        // Pattern 14: Clockwise LED rotation
	5'd14: begin
	    led_out <= (pattern_counter >> pattern_counter[1:0]) | (pattern_counter << (5 - pattern_counter[1:0]));
	end
        // Pattern 15: XOR Pattern
        5'd15: led_out <= pattern_counter ^ oh_counter;

        // Pattern 16: Bouncing lights
        5'd16: begin
            if (|oh_counter[7:4]) 
                led_out <= { oh_counter[4], 
                                oh_counter[5], 
                                oh_counter[6], 
                                oh_counter[7], 
                                oh_counter[7], 
                                oh_counter[6], 
                                oh_counter[5], 
                                oh_counter[4] 
                                };
            else 
                led_out <= { oh_counter[3], 
                                oh_counter[2], 
                                oh_counter[1], 
                                oh_counter[0], 
                                oh_counter[0], 
                                oh_counter[1], 
                                oh_counter[2], 
                                oh_counter[3] 
                                };
        end

        // Pattern 17: Diagonal Bounce
        5'd17: begin
            if (|oh_counter[7:4]) 
                led_out <= { oh_counter[4], 1'b0, oh_counter[5], 1'b0, oh_counter[6], 1'b0, oh_counter[7], 1'b0 };
            else 
                led_out <= { oh_counter[3], 1'b0, oh_counter[2], 1'b0, oh_counter[1], 1'b0, oh_counter[0], 1'b0 };
        end

        // Pattern 18: Circular Bounce
        5'd18: begin
            case (pattern_counter[1:0])
                2'b00: led_out <= 8'b10000001;
                2'b01: led_out <= 8'b01000010;
                2'b10: led_out <= 8'b00100100;
                2'b11: led_out <= 8'b00011000;
            endcase
        end

        // Pattern 19: Random Bounce
        5'd19: led_out <= (pattern_counter[3:0] == lfsr_reg[3:0]) ? ~oh_counter : oh_counter;

        // Pattern 20: Negative Diagonal Bounce
        5'd20: begin
            if (|oh_counter[7:4]) 
                led_out <= { ~oh_counter[4], 1'b0, ~oh_counter[5], 1'b0, ~oh_counter[6], 1'b0, ~oh_counter[7], 1'b0 };
            else 
                led_out <= { ~oh_counter[3], 1'b0, ~oh_counter[2], 1'b0, ~oh_counter[1], 1'b0, ~oh_counter[0], 1'b0 };
        end

        // Pattern 21: Accelerating Bounce
        5'd21: begin
            if (pattern_counter >= 8'b11000000) 
                led_out <= (pattern_counter[0]) ? oh_counter : ~oh_counter; 
            else 
                led_out <= (pattern_counter[1]) ? oh_counter : ~oh_counter;
        end

        // Pattern 22: Gravity Effect
        5'd22: begin
            if (|oh_counter[7:4]) 
                led_out <= { ~oh_counter[4], ~oh_counter[5], ~oh_counter[6], ~oh_counter[7], ~oh_counter[7], ~oh_counter[6], ~oh_counter[5], ~oh_counter[4] };
            else 
                led_out <= { ~oh_counter[3], ~oh_counter[2], ~oh_counter[1], ~oh_counter[0], ~oh_counter[0], ~oh_counter[1], ~oh_counter[2], ~oh_counter[3] };
        end

        // Pattern 23: Spring Effect
        5'd23: begin
            if (pattern_counter[1]) 
                led_out <= {led_out[6:1], lfsr_reg[7], lfsr_reg[0]};
            else 
                led_out <= {lfsr_reg[7], lfsr_reg[0], led_out[6:1]};
        end

        // Pattern 24: Reflecting Bounce
        5'd24: begin
            if (|oh_counter[7:4]) 
                led_out <= { oh_counter[4], oh_counter[5], oh_counter[6], ~oh_counter[7], ~oh_counter[7], oh_counter[6], oh_counter[5], oh_counter[4] };
            else 
                led_out <= { oh_counter[3], oh_counter[2], oh_counter[1], ~oh_counter[0], ~oh_counter[0], oh_counter[1], oh_counter[2], oh_counter[3] };
        end

        // Pattern 25: Double Bounce
        5'd25: begin
            if (|oh_counter[7:4]) 
                led_out <= { ~oh_counter[4], oh_counter[4], ~oh_counter[5], oh_counter[5], ~oh_counter[6], oh_counter[6], ~oh_counter[7], oh_counter[7] };
            else 
                led_out <= { ~oh_counter[3], oh_counter[3], ~oh_counter[2], oh_counter[2], ~oh_counter[1], oh_counter[1], ~oh_counter[0], oh_counter[0] };
        end

        // Pattern 26: Wave Bounce
        5'd26: begin
            if (pattern_counter[1]) 
                led_out <= {led_out[6:1], lfsr_reg[7], lfsr_reg[0]};
            else 
                led_out <= {lfsr_reg[7], lfsr_reg[0], led_out[6:1]};
        end

        // Pattern 27: Breathing Effect
        5'd27: begin
            case (pattern_counter[2:0])
                3'd0: led_out <= 8'b0_0_0_0_0_0_0_0;
                3'd1: led_out <= 8'b0_0_0_1_1_0_0_0;
                3'd2: led_out <= 8'b0_0_1_1_1_1_0_0;
                3'd3: led_out <= 8'b0_1_1_1_1_1_1_0;
                3'd4: led_out <= 8'b1_1_1_1_1_1_1_1;
                3'd5: led_out <= 8'b0_1_1_1_1_1_1_0;
                3'd6: led_out <= 8'b0_0_1_1_1_1_0_0;
                3'd7: led_out <= 8'b0_0_0_1_1_0_0_0;
            endcase
        end

        // Pattern 28: Alternating Binary and One-Hot
        5'd28: begin
            if (pattern_counter[0])
                led_out <= pattern_counter;
            else
                led_out <= oh_counter;
        end

        // Pattern 29: Alternating LFSR and One-Hot
        5'd29: begin
            if (pattern_counter[0])
                led_out <= lfsr_reg;
            else
                led_out <= oh_counter;
        end

        // Pattern 30: Alternating LFSR and Binary
        5'd30: begin
            if (pattern_counter[0])
                led_out <= lfsr_reg;
            else
                led_out <= pattern_counter;
        end


        default: led_out <= 8'b00000000;
    endcase
end

endmodule

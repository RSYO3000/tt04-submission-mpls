`timescale 1ns/1ps

module MPLS_tb;  

  reg clk;
  reg rstn;
  reg [4:0] pattern_sel;
  wire [7:0] led_out;


  always #5 clk = ~clk;

  MPLS DUT (clk, rstn, pattern_sel, led_out);

reg [8*100-1:0] msg_box;
always @(*)
begin
    case (pattern_sel)
        0: msg_box = "All LEDs OFF";
        1: msg_box = "All LEDs ON";
        2: msg_box = "Blinking LEDs";
        3: msg_box = "Running lights";
        4: msg_box = "Alternating LEDs";
        5: msg_box = "Negative running lights";
        6: msg_box = "KR effect";
        7: msg_box = "Bouncing lights";
        8: msg_box = "LED wave effect";
        9: msg_box = "Alternating LED groups";
        10: msg_box = "Heartbeat";
        11: msg_box = "p-Random LFSR LEDs";
        12: msg_box = "XOR All";
        13: msg_box = "Binary counter";
        14: msg_box = "Clockwise LED rotation";
        15: msg_box = "XOR Pattern";
        16: msg_box = "Bouncing lights";
        17: msg_box = "Diagonal Bounce";
        18: msg_box = "Circular Bounce";
        19: msg_box = "Random Bounce";
        20: msg_box = "Negative Diagonal Bounce";
        21: msg_box = "Accelerating Bounce";
        22: msg_box = "Gravity Effect";
        23: msg_box = "Spring Effect";
        24: msg_box = "Reflecting Bounce";
        25: msg_box = "Double Bounce";
        26: msg_box = "Wave Bounce";
        27: msg_box = "Breathing Effect";
        28: msg_box = "Alternating Binary and One-Hot";
        29: msg_box = "Alternating LFSR and One-Hot";
        30: msg_box = "Alternating LFSR and Binary";
        31: msg_box = "DEMO";
        default: msg_box = "Unknown Pattern";
    endcase
end


  initial begin
    $display("INITIALIZING DUMPFILE");
    $dumpfile("MPLS_tb.vcd");
    $dumpvars;
  end

  integer i;

  task test_pattern_selector;
    begin
      for(i = 0; i < 2**5; i=i+1)
        begin
          pattern_sel = i;
          $display("\tPATTERN SEL: %d | TIME: %t", i, $realtime);
          if (i == 31)
          #6000;
          else
          #200;
        end
    end
  endtask

	task test_random_pattern(input integer x);
	    reg [3:0] random_var;
	    begin
		for (i = 0; i < x; i = i + 1) begin
		    random_var = $urandom; // Using $urandom for random values
		    pattern_sel = random_var;
		    $display("\tRANDOM PATTERN SEL: %d | TIME: %t", random_var, $realtime);
		    #200;
		end
	    end
	endtask

  initial begin
    clk = 0;
    pattern_sel = 0;
    $display("START OF SIM: %t", $realtime);
    rstn = 1;
    #0.1;
    rstn = 0;
    #0.1;
    rstn = 1;
    test_pattern_selector;
    $finish;
  end


endmodule
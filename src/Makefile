mpls_sim:
	iverilog -o MPLS_tb.vvp MPLS.v MPLS_tb.v
	vvp MPLS_tb.vvp
	gtkwave MPLS_tb.vcd --save MPLS_tb.gtkw
mpls_wave:
	gtkwave MPLS_tb.vcd --save MPLS_tb.gtkw

tt_sim:
	iverilog -o tt_um_MultiPatternLEDSequencer_RSYO3000_tb.vvp tt_um_MultiPatternLEDSequencer_RSYO3000.v MultiPatternLEDSequencer.v MPLS.v PLL_10MHztoNHz.v tt_um_MultiPatternLEDSequencer_RSYO3000_tb.v
	vvp tt_um_MultiPatternLEDSequencer_RSYO3000_tb.vvp
	gtkwave tt_um_MultiPatternLEDSequencer_RSYO3000_tb.vcd --save tt_um_MultiPatternLEDSequencer_RSYO3000_tb.gtkw
tt_wave:
	gtkwave tt_um_MultiPatternLEDSequencer_RSYO3000_tb.vcd --save tt_um_MultiPatternLEDSequencer_RSYO3000_tb.gtkw
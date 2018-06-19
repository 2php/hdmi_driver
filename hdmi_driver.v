


module hdmi_driver(
	input pixclk,  // 25MHz
	input rst,
	output [2:0] TMDS_txp, TMDS_txn,
	output TMDS_txp_clock, TMDS_txn_clock,
	output vsync_out,
	
	input [2:0] TMDS_rxp, TMDS_rxn,
	input TMDS_rxp_clock, TMDS_rxn_clock
);

	wire [7 : 0] red;
	wire [7 : 0] green;
	wire [7 : 0] blue;
	wire 		 vsync;
	wire     	 hsync;
	
	wire         vde;
	wire [3 : 0] cntrl;
	assign vsync_out = vsync;


 hdmi_tx hdmi_tx_i(
	.pixclk(pixclk),
	.rst(rst),
	
	.red(red),
	.green(green),
	.blue(blue),
	
	.vsync(vsync),
	.hsync(hsync),
	.vde(vde), 
	.cntrl(cntrl),
	
	.TMDSp(TMDS_txp), 
	.TMDSn(TMDS_txn),
	.TMDSp_clock(TMDS_txp_clock), 
	.TMDSn_clock(TMDS_txn_clock)	
);

hdmi_rx hdmi_rx_i(
    .pixclk(pixclk),
	.rst(rst),
	
	.TMDSp(TMDS_rxp), 
	.TMDSn(TMDS_rxn),
	.TMDSp_clock(TMDS_rxp_clock), 
	.TMDSn_clock(TMDS_rxn_clock),
	
	.red(red),
	.green(green),
	.blue(blue),
	
	.vsync(vsync),
	.hsync(hsync),
	.vde(vde), 
	.cntrl(cntrl)
	);




endmodule


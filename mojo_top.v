module mojo_top(
    // 50MHz clock input
    input clk,
    // Input from reset button (active low)
    input rst_n,
    // cclk input from AVR, high when AVR is ready
    input cclk,
    // Outputs to the 8 onboard LEDs
    output[7:0]led,
    // AVR SPI connections
    output spi_miso,
    input spi_ss,
    input spi_mosi,
    input spi_sck,
    // AVR ADC channel select
    output [3:0] spi_channel,
    // Serial connections
    input avr_tx, // AVR Tx => FPGA Rx
    output avr_rx, // AVR Rx => FPGA Tx
    input avr_rx_busy, // AVR Rx buffer full
	 
	output [2:0] TMDS_txp, TMDS_txn,
	output TMDS_txp_clock, TMDS_txn_clock,
	
	input [2:0] TMDS_rxp, TMDS_rxn,
	input TMDS_rxp_clock, TMDS_rxn_clock
    );

wire rst = ~rst_n; // make reset active high

// these signals should be high-z when not used
assign spi_miso = 1'bz;
assign avr_rx = 1'bz;
assign spi_channel = 4'bzzzz;
reg [1 : 0] cnt;
wire pixelclk = cnt[0];
wire vsync_out;

	always @(posedge clk) if(rst) cnt <= 0; else cnt <= cnt + 1;

  
 led_blinking led_blinking_i (.clk(pixelclk), .rst_n(rst_n), .led(led), .en(vsync_out));
 
 //pll_clocking pll_clocking_i (.CLK_IN1(clk), .CLK_OUT1(pixelclk), .RESET(rst));
 
 hdmi_driver  hdmi_driver_i  (
	.pixclk(pixelclk), 
	.rst(rst),
	
	.TMDS_txp(TMDS_txp),
	.TMDS_txn(TMDS_txn),
	.TMDS_txp_clock(TMDS_txp_clock),
	.TMDS_txn_clock(TMDS_txn_clock),
	.vsync_out(vsync_out),
	
	.TMDS_rxp(TMDS_rxp),
	.TMDS_rxn(TMDS_rxn),
	.TMDS_rxp_clock(TMDS_rxp_clock),
	.TMDS_rxn_clock(TMDS_rxn_clock)
);
 
 
		

endmodule
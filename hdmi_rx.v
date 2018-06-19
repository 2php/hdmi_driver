`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:     Riftek LLC
// Engineer:    Alexey Rostov
// Email:       a.rostov@riftek.com 
// Create Date: 14/05/18
// Design Name: hdmi_receiver
////////////////////////////////////////////////////////////////////////////////
module hdmi_rx(
    input          pixclk,
	input          rst,
	input  [2 : 0] TMDSp, TMDSn,
	input          TMDSp_clock, TMDSn_clock,
	
	output [7 : 0] red,
	output [7 : 0] green,
	output [7 : 0] blue,
	
	output         vsync,
	output         hsync,
	
	output         vde,
	output [3 : 0] cntrl
    );

	wire [9 : 0] TMDS_red, TMDS_green, TMDS_blue;
	wire [2 : 0] de;
	assign vde = de[0] || de[1] || de[2];


wire [2 : 0] tmds;
wire         tmds_clk;
wire         tmds_10xclk;


TMDS_decoder decode_R(.clk(tmds_clk),.rst(rst),.datain(TMDS_red)  , .de(de[2]), .tmdsout(red),   .ctrl(cntrl[3 : 2]));
TMDS_decoder decode_G(.clk(tmds_clk),.rst(rst),.datain(TMDS_green), .de(de[1]), .tmdsout(green), .ctrl(cntrl[1 : 0]));
TMDS_decoder decode_B(.clk(tmds_clk),.rst(rst),.datain(TMDS_blue) , .de(de[0]), .tmdsout(blue),  .ctrl({vsync, hsync}));

IBUFDS #(.DIFF_TERM("TRUE"), .IOSTANDARD("DEFAULT")) i0 (.O(tmds[0]) ,.I(TMDSp[0])   ,.IB(TMDSn[0]));
IBUFDS #(.DIFF_TERM("TRUE"), .IOSTANDARD("DEFAULT")) i1 (.O(tmds[1]) ,.I(TMDSp[1])   ,.IB(TMDSn[1]));
IBUFDS #(.DIFF_TERM("TRUE"), .IOSTANDARD("DEFAULT")) i2 (.O(tmds[2]) ,.I(TMDSp[2])   ,.IB(TMDSn[2]));

IBUFDS #(.DIFF_TERM("TRUE"), .IOSTANDARD("DEFAULT")) i3 (.O(tmds_clk),.I(TMDSp_clock),.IB(TMDSn_clock));

wire DCM_TMDS_CLKFX;  // 25MHz x 10 = 250MHz
DCM_SP #(.CLKFX_MULTIPLY(10)) DCM_TMDS_inst(.CLKIN(tmds_clk), .CLKFX(DCM_TMDS_CLKFX), .RST(rst));
BUFG BUFG_TMDSp(.I(DCM_TMDS_CLKFX), .O(tmds_10xclk));

	reg 			pixclk_delay;
	reg 			strob;
	reg [9 : 0] shift_red, shift_green, shift_blue;
	always@(posedge tmds_10xclk)strob <= (!pixclk_delay && tmds_clk)? 1'b1 : 1'b0;
	always@(posedge tmds_10xclk)if(rst)pixclk_delay <= 0; else pixclk_delay <= tmds_clk;
	always@(posedge tmds_10xclk)if(rst)shift_red    <= 0; else shift_red    <= {tmds[2],   shift_red[9 : 1]};
	always@(posedge tmds_10xclk)if(rst)shift_green  <= 0; else shift_green  <= {tmds[1], shift_green[9 : 1]};
	always@(posedge tmds_10xclk)if(rst)shift_blue   <= 0; else shift_blue   <= {tmds[0],  shift_blue[9 : 1]};
	
	assign TMDS_red   = (strob) ? shift_red   : (rst) ? 10'd0 : TMDS_red;
	assign TMDS_green = (strob) ? shift_green : (rst) ? 10'd0 : TMDS_green;
	assign TMDS_blue  = (strob) ? shift_blue  : (rst) ? 10'd0 : TMDS_blue;
	

endmodule



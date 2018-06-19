`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:39:54 06/18/2018 
// Design Name: 
// Module Name:    led_blinking 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module led_blinking(
    input clk,
    input rst_n,
    output [7:0] led,
	input en
    );

   reg [31 : 0] usec_tmr;
	localparam usec = 32'h00800000;
	reg [7 : 0] led_reg;
	
	always @(posedge clk)
		if(!rst_n) begin
					usec_tmr <= 0;
					led_reg  <= 0;
		end else if (en) begin
				if(usec_tmr == usec) begin 
							usec_tmr <= 0;
							led_reg  <= led_reg + 2;
				end else begin 
				            usec_tmr <= usec_tmr + 1;
				end // usec
		end
	

	assign led = led_reg;


endmodule

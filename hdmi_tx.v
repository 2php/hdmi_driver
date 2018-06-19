



module hdmi_tx(
	input pixclk,
	input rst,
	
	input  [7 : 0] red,
	input  [7 : 0] green,
	input  [7 : 0] blue,
	
	input  		   vsync,
	input  		   hsync,
	input          vde, 
	input  [3 : 0] cntrl,
	
	output [2 : 0] TMDSp, TMDSn,
	output TMDSp_clock, TMDSn_clock	
);


		reg [9:0] CounterX, CounterY;
		reg hSync, vSync, DrawArea;
		always @(posedge pixclk) if (rst)  DrawArea <= 0; else  DrawArea <= (CounterX<640) && (CounterY<480);

		always @(posedge pixclk) if (rst)  CounterX <= 0; else CounterX <= (CounterX==799) ? 0 : CounterX+1;
		always @(posedge pixclk) if(CounterX==799) CounterY <= (CounterY==524) ? 0 : CounterY+1; else if (rst) CounterY <= 0;

		always @(posedge pixclk) if (rst) hSync <= 0; else hSync <= (CounterX>=656) && (CounterX<752);
		always @(posedge pixclk) if (rst) vSync <= 0; else vSync <= (CounterY>=490) && (CounterY<492);
		
        reg [7 : 0] de_red, de_green, de_blue;
		////////////////
		wire [7:0] W = {8{CounterX[7:0]==CounterY[7:0]}};
		wire [7:0] A = {8{CounterX[7:5]==3'h2 && CounterY[7:5]==3'h2}};
		//reg [7:0] red, green, blue;
		always @(posedge pixclk) if (rst)  de_red  <= 0; else de_red   <= ({CounterX[5:0] & {6{CounterY[4:3]==~CounterX[4:3]}}, 2'b00} | W) & ~A;
		always @(posedge pixclk) if (rst) de_green <= 0; else de_green <= (CounterX[7:0] & {8{CounterY[6]}} | W) & ~A;
		always @(posedge pixclk) if (rst)  de_blue <= 0; else de_blue  <= CounterY[7:0] | W | A;

		////////////////////////////////////////////////////////////////////////
		wire [9:0] TMDS_red, TMDS_green, TMDS_blue;
		TMDS_encoder encode_R(.rst(rst), .clk(pixclk), .VD(de_red  ), .CD(2'b00)        , .VDE(DrawArea), .TMDS(TMDS_red));
		TMDS_encoder encode_G(.rst(rst), .clk(pixclk), .VD(de_green), .CD(2'b00)        , .VDE(DrawArea), .TMDS(TMDS_green));
		TMDS_encoder encode_B(.rst(rst), .clk(pixclk), .VD(de_blue ), .CD({vSync,hSync}), .VDE(DrawArea), .TMDS(TMDS_blue));
		////////////////////////////////////////////////////////////////////////

	/* wire [9:0] TMDS_red, TMDS_green, TMDS_blue;
	
	TMDS_encoder encode_R(.rst(rst), .clk(pixclk), .VD(red  ), .CD(cntrl[3 : 2]) , .VDE(vde), .TMDS(TMDS_red));
	TMDS_encoder encode_G(.rst(rst), .clk(pixclk), .VD(green), .CD(cntrl[1 : 0]) , .VDE(vde), .TMDS(TMDS_green));
	TMDS_encoder encode_B(.rst(rst), .clk(pixclk), .VD(blue ), .CD({vsync,hsync}), .VDE(vde), .TMDS(TMDS_blue)); */



	////////////////////////////////////////////////////////////////////////
	wire clk_TMDS, DCM_TMDS_CLKFX;  // 25MHz x 10 = 250MHz
	DCM_SP #(.CLKFX_MULTIPLY(10)) DCM_TMDS_inst(.CLKIN(pixclk), .CLKFX(DCM_TMDS_CLKFX),.RST(rst));
	BUFG BUFG_TMDSp(.I(DCM_TMDS_CLKFX), .O(clk_TMDS));

	////////////////////////////////////////////////////////////////////////
	reg [3:0] TMDS_mod10=0;  // modulus 10 counter
	reg [9:0] TMDS_shift_red=0, TMDS_shift_green=0, TMDS_shift_blue=0;
	reg TMDS_shift_load=0;
	always @(posedge clk_TMDS) if (rst) TMDS_shift_load <= 0; else TMDS_shift_load <= (TMDS_mod10==4'd9);

	always @(posedge clk_TMDS)
	begin
		if(rst) begin
			TMDS_shift_red   <= 0;
			TMDS_shift_green <= 0;
			TMDS_shift_blue  <= 0;
			TMDS_mod10       <= 0;
		end else begin
			TMDS_shift_red   <= TMDS_shift_load ? TMDS_red   : TMDS_shift_red  [9:1];
			TMDS_shift_green <= TMDS_shift_load ? TMDS_green : TMDS_shift_green[9:1];
			TMDS_shift_blue  <= TMDS_shift_load ? TMDS_blue  : TMDS_shift_blue [9:1];	
			TMDS_mod10 <= (TMDS_mod10==4'd9) ? 4'd0 : TMDS_mod10+4'd1;
		end
	end


	OBUFDS OBUFDS_red  (.I(TMDS_shift_red  [0]), .O(TMDSp[2]), .OB(TMDSn[2]));
	OBUFDS OBUFDS_green(.I(TMDS_shift_green[0]), .O(TMDSp[1]), .OB(TMDSn[1]));
	OBUFDS OBUFDS_blue (.I(TMDS_shift_blue [0]), .O(TMDSp[0]), .OB(TMDSn[0]));
	OBUFDS OBUFDS_clock(.I(pixclk), .O(TMDSp_clock), .OB(TMDSn_clock));



endmodule
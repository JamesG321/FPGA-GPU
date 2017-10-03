// Top-level module that defines the I/Os for the DE-1 SoC board

module DE1_SoC (CLOCK_50,HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW,GPIO_1);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input logic CLOCK_50; // 50MHz clock. 
	output logic [39:0] GPIO_1;
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	
	logic reset;
	assign reset = ~KEY[0];
	

	logic [31:0] divided_clocks;
	clock_divider (CLOCK_50, divided_clocks);
	
	//read reg * 2
	//write reg * 2
	//alternate between read/write
	
	logic Dclk;
	assign Dclk = ~ divided_clocks[0];
	assign GPIO_1[1] = Dclk;
	
	LCDinterface(Dclk,reset,x,y,GPIO_1,R,G,B);
	logic [9:0] x;
	logic [8:0] y;

	logic [7:0] R,G,B;
	logic VSync;
	assign VSync = ~GPIO_1[31];
	logic loaded;
	logic ready;
	logic [8:0] dataIn;
	int drawIndex;
	doubleBuffer(.x,.y,.clk(CLOCK_50),.reset,.VSync,.R,.G,.B,.SW,.loaded,.ready,.dataIn,.drawIndex);
	vertex(.clk(CLOCK_50),.reset,.ready,.SW,.loaded,.dataIn,.drawIndex);
endmodule


// divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ...


//FPGA GPU
//James Guo
//DE1-SoC.sv
// Top-level module that defines the I/Os and connects all modules for the DE-1 SoC board

module DE1_SoC (CLOCK_50,HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW,GPIO_1);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;//hex digit display on board
	output logic [9:0] LEDR;//LED display
	input logic [3:0] KEY;//buttons
	input logic [9:0] SW;//swithces
	input logic CLOCK_50; // 50MHz clock. 
	output logic [39:0] GPIO_1;//GPIO Input/outputs
	
	//HEX displays are active low, set to high to turn them off by default
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	//reset key for system
	logic reset;
	assign reset = ~KEY[0];
	
	//module to access slower system clock divided from fasted 50MHz clk
	logic [31:0] divided_clocks;
	clock_divider (CLOCK_50, divided_clocks);
	
	//Dclk signal for LCD interface
	logic Dclk;
	assign Dclk = ~ divided_clocks[0];
	assign GPIO_1[1] = Dclk;
	//LCD interface module, connected to GPIOs on the board
	LCDinterface(Dclk,reset,x,y,GPIO_1,R,G,B);
	//registers used by LCD protocol, holds value of current pixel LCD is reading
	logic [9:0] x;
	logic [8:0] y;
	//Sends RGB value of current pixel to LCD display
	logic [7:0] R,G,B;
	//VSync pulse for LCD
	logic VSync;
	assign VSync = ~GPIO_1[31];
	
	//logic for double frame buffer
	logic loaded;//tells frame buffer that loading frame is finished rendering
	logic ready;//tells rendering module (vetex) that buffer can be edited now
	logic [8:0] dataIn; //RGB data for pixel that goes into the buffer
	int drawIndex;//index of pixel to buffer
	doubleBuffer(.x,.y,.clk(CLOCK_50),.reset,.VSync,.R,.G,.B,.SW,.loaded,.ready,.dataIn,.drawIndex);
	vertex(.clk(CLOCK_50),.reset,.ready,.SW,.loaded,.dataIn,.drawIndex);
endmodule

//Clock divider, utility module that creates slower clocks divided from CLOCK_50 system clock
// divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ...
module clock_divider (clock, divided_clocks);
	input clock;
	output [31:0] divided_clocks;
	reg [31:0] divided_clocks;
	
	initial
		divided_clocks = 0;
		
	always @(posedge clock)
		divided_clocks = divided_clocks + 1;
endmodule


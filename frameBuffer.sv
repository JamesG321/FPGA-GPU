module frameBuffer(clk,readIndex,writeIndex,write,dataWrite,dataRead);
	input logic clk;

	input int readIndex, writeIndex;
	input logic write;
	input logic [8:0] dataWrite;
	output logic [8:0] dataRead;
	logic [8:0] mem [95999:0];

	always_ff @(posedge clk) begin
			if (write) mem[writeIndex] <= dataWrite;
			dataRead <= mem[readIndex];
	end
	
endmodule


module doubleBuffer(x,y,clk,reset,VSync,R,G,B,SW,loaded,ready,dataIn,drawIndex);
	input logic [9:0] SW;
	input logic [9:0] x;
	input logic [8:0] y;
	input logic clk, reset,VSync;
	output logic [7:0] R,G,B;
	input logic loaded;
	output logic ready;
	input logic [8:0] dataIn;
	input int drawIndex;
	
	int xRead,yRead,readIndex;
	int writeIndex;
	//index of address writing into RAM

	logic write1,write2;

	assign xRead = x  >> 1;
	assign yRead = y  >> 1;
	assign readIndex = (399 * yRead) + xRead;
	logic [8:0] pixelColor1,pixelColor2,pixelColorCurr;
	logic [8:0] dataWrite;
	logic [8:0] dataRead1, dataRead2;
	//TODO: change to only one dataWrite register
	frameBuffer buffer1(.clk,.readIndex,.writeIndex,.write(write1),.dataWrite(dataWrite),.dataRead(dataRead1));
	frameBuffer buffer2(.clk,.readIndex,.writeIndex,.write(write2),.dataWrite(dataWrite),.dataRead(dataRead2));
	
	logic readBuffer;
	logic [1:0] state;
	logic frameLoaded;
	//TODO delete?
	logic prevVsync;
	logic VsyncePulse;
	//clear, draw,read,switch
	always @ (posedge clk) begin
		if(reset) begin
			state <= 2'b00;
			writeIndex <= 0;
			readBuffer <= 0;
		end
		
		prevVsync <= VSync;
		
		case(state)
			//clear
			2'b00:begin
				dataWrite <= 9'b000000000;		
				if(writeIndex >= 95999) begin
					state <= 2'b01;
					writeIndex <= 0;
				end else begin
					writeIndex <= writeIndex + 1;
				end
				if(readBuffer) begin
						write2 <= 1;
						write1 <= 0;
					end else begin
						write1 <= 1;
						write2 <= 0;
				end	
			end
			
			//write
			2'b01:begin	
				if(loaded) begin
					frameLoaded <= 1;
				end
				
				if (loaded) begin
					//stop writing to screen, wait for VSync to load
					ready <= 0;
					frameLoaded <= 0;
					state <= 2'b10;
				end else begin
					ready <= 1;
					writeIndex <= drawIndex;
					dataWrite <= dataIn;
				end	
				
			end
			
			//load/switch
			2'b10:begin
				if(VSync) begin
					write1 <= 0;
					write2 <= 0;
					writeIndex <= 0;
					state <= 2'b00;
					readBuffer <= ~readBuffer;
				end
			end
		endcase
		
	end
	
	always_comb begin
			R = pixelColorCurr[8:6] * 255 / 7;
			G = pixelColorCurr[5:3] * 255 / 7;
			B = pixelColorCurr[2:0] * 255 / 7;
			if(readBuffer == 0) begin 	
				pixelColorCurr = dataRead1;
			end else begin 
				pixelColorCurr = dataRead2;
			end
	end

endmodule

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

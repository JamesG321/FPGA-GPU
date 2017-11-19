//FPGA GPU
//James Guo
//frameBuffer.sv
//Double frame buffer module with frame delay support

//Memory module that uses on-chip memory, for a single fram buffer
module frameBuffer(clk,readIndex,writeIndex,write,dataWrite,dataRead);
	input logic clk;

	input int readIndex, writeIndex;//index of buffer to read and write
	input logic write;//Write enable
	input logic [8:0] dataWrite;//Data to write to module
	output logic [8:0] dataRead;//Data read from module
	logic [8:0] mem [95999:0];//On chip memory decleration

	always_ff @(posedge clk) begin
			if (write) mem[writeIndex] <= dataWrite;
			dataRead <= mem[readIndex];
	end
	
endmodule

//Puts 2 frameBuffer modules together with proper I/O signal management
module doubleBuffer(x,y,clk,reset,VSync,R,G,B,SW,loaded,ready,dataIn,drawIndex);
	input logic [9:0] SW;
	input logic [9:0] x;//from LCD interface
	input logic [8:0] y;//from LCD interface
	input logic clk, reset,VSync;
	output logic [7:0] R,G,B;
	input logic loaded;
	output logic ready;
	input logic [8:0] dataIn;
	input int drawIndex;
	
	int xRead,yRead,readIndex;//intermedate states to translate between LCD coorinates and framebuffer coordinates
	
	int writeIndex;
	//index of address writing into on chip memory
	
	//Write enbale for frame buffer 1 and 2
	logic write1,write2;
	//translates x y from LCD to frame buffer coordinates
	assign xRead = x  >> 1;
	assign yRead = y  >> 1;
	assign readIndex = (399 * yRead) + xRead;
	//RGB data for 2 buffers and intermediate state
	logic [8:0] pixelColor1,pixelColor2,pixelColorCurr;
	//Register to write to both frame buffers
	logic [8:0] dataWrite;
	//registers to read data from both buffers
	logic [8:0] dataRead1, dataRead2;
	//decleration of both buffer modules
	frameBuffer buffer1(.clk,.readIndex,.writeIndex,.write(write1),.dataWrite(dataWrite),.dataRead(dataRead1));
	frameBuffer buffer2(.clk,.readIndex,.writeIndex,.write(write2),.dataWrite(dataWrite),.dataRead(dataRead2));
	//read Enable
	logic readBuffer;
	//3-state loop for reading frames:
	//clear buffer, write, load/switch buffers
	logic [1:0] state;
	//frame is loaded
	logic frameLoaded;
	
	//state machine to orchistrate two buffers
	//clear, draw,read,switch
	always @ (posedge clk) begin
		if(reset) begin
			state <= 2'b00;
			writeIndex <= 0;
			readBuffer <= 0;
		end
		
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
			//Combination logic to "upscale" RGB from frame buffer percision to LCD
			R = pixelColorCurr[8:6] * 255 / 7;
			G = pixelColorCurr[5:3] * 255 / 7;
			B = pixelColorCurr[2:0] * 255 / 7;
			//Alternate bewteen 2 frame buffers according to read/write state
			//to read data from
			if(readBuffer == 0) begin 	
				pixelColorCurr = dataRead1;
			end else begin 
				pixelColorCurr = dataRead2;
			end
	end

endmodule


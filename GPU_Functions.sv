//FPGA GPU
//James Guo
//GPU_Functions.sv
//Double frame buffer module with frame delay support

//vertex storage module + triangle drawing 
module vertex(clk,reset,ready,SW,loaded,dataIn,drawIndex);
	input logic clk,reset;
	input logic ready;
	input logic [9:0] SW;
	output logic loaded;
	output logic [8:0] dataIn;
	output int drawIndex;
	int xDraw, yDraw;
	logic [31:0] divided_clocks;
	clock_divider (clk, divided_clocks);	
	//Index (coordingates of 3 points of triangle)
	int indexA,indexB,indexC;
	//assign arbitrary value for testing module
	assign indexC = (100*399) + 200;
	assign indexB = (120*399) + 300;
	assign indexA = (150*399) + 250;

	
	
	//get x,y coordinates of A,B,C from index
	int xA,yA,xB,yB,xC,yC;
	assign xA = indexA % 399;
	assign xB = indexB % 399;
	assign xC = indexC % 399;
	
	assign yA = indexA / 399;
	assign yB = indexB / 399;
	assign yC = indexC / 399;
	
	//Rearrange point A,B,C to point 1,2,3
	//according to relative position of 3 points
	int x1,x2,x3,y1,y2,y3;
	int dx1,dx2,dx3,dy1,dy2,dy3;
	
	//get dx,dy for line 1, 2, 3
	assign dx1 = x2-x1;
	assign dx2 = x3-x1;
	assign dx3 = x3-x2;
	
	assign dy1 = y2-y1;
	assign dy2 = y3-y1;
	assign dy3 = y3-y2;
	//get 
	int b1,b2,b3;
	assign b1 = y2 - (x2 *dy1/dx1);
	assign b2 = y1 - (x1 *dy2/dx2);
	assign b3 = y2 - (x2 *dy3/dx3);

	
	

	
	int xMax,xMin,yMax,yMin;
	
	//in between states
	//true if point is inbetween any line of triangle
	logic case1,case2,case3,case4,case5,case6;
	assign case1 = xDraw >= dx1 * (yDraw - b1) /dy1 && xDraw <= dx2 * (yDraw - b2) /dy2;
	assign case2 = xDraw <= dx1 * (yDraw - b1) /dy1 && xDraw >= dx2 * (yDraw - b2) /dy2;
	assign case3 = xDraw >= dx2 * (yDraw - b2) /dy2 && xDraw <= dx3 * (yDraw - b3) /dy3;
	assign case4 = xDraw <= dx2 * (yDraw - b2) /dy2 && xDraw >= dx3 * (yDraw - b3) /dy3;
	
	logic[3:0] points;
	//case state to assign point ABC to 1 2 3
	
	
	always_comb begin

	//determine point 1, 2, 3 according to relative position of A,B,C
	//Determine xMax,yMax, xMin, yMin of all points of triangle
		if(xA>xB && xA > xC) begin
			xMax = xA; 
			x2 = xA;
			y2 = yA;
		end else if (xB > xA && xB > xC) begin
			xMax = xB;
			x2 = xB;
			y2 = yB;
		end else begin
			xMax = xC;
			x2 = xC;
			y2 = yC;
		end
		
		if(xA<xB && xA < xC) begin
			xMin = xA;
			x1 = xA;
			y1 = yA;
		end else if (xB < xA && xB < xC) begin
			xMin = xB;
			x1 = xB;
			y1 = yB;
		end else begin
			xMin = xC;
			x1 = xC;
			y1 = yC;
		end
		
		if( (xA<xB && xA>xC) || (xA>xB && xA<xC) ) begin
			x3 = xA;
			y3 = yA;
		end else if ((xB<xA && xB>xC) || (xB>xA && xB<xC)) begin
			x3 = xB;
			y3 = yB;
		end else begin
			x3 = xC;
			y3 = yC;
		end
		
		
		if(yA>yB && yA > yC) begin
			yMax = yA; 
		end else if (yB > yA && yB > yC) begin
			yMax = yB;
		end else begin
			yMax = yC;
		end
		
		if(yA<yB && yA < yC) begin
			yMin = yA; 
		end else if (yB < yA && yB < yC) begin
			yMin = yB;
		end else begin
			yMin = yC;
		end
	
	end
	
	
	//drawing logic for triangle
	//goes through pixels in smallest rectangle holding triangle
	logic [1:0] drawingState;
	logic [2:0] drawCount;	
	int loadedDelay;
	always @(posedge clk) begin
	
		if(reset) begin
			drawingState <=0;
			loaded <= 0;
			drawCount <= 0;
			xDraw <= 0;
			yDraw <= 0;
		end else begin
			if(ready) begin
				//Draw color & index
				drawIndex <= xDraw + (yDraw * 399);
				if(xDraw >= xMax) begin
					yDraw <= yDraw +1;
					xDraw <= xMin;
				end else begin
					xDraw <= xDraw + 1;
				end	
				if((case1 || case2) && (case3 || case4) ) begin
					dataIn <= 2054;
				end else begin
					dataIn <= 9'b111111111;
				end
			end
			
			if(yDraw >= yMax) begin
				//if(finish draw) send loaded flag
				loaded <= 1;
				xDraw <= xMin;
				yDraw <= yMin;
			end else begin
				loaded <= 0;
			end
		end
	
	
	end

endmodule

	 
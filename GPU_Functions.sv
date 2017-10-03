//test 2's comp
module lineDraw();

	logic clk;
	
	int x0,x1,y0,y1;	
	
	logic start;
	logic done;
	logic reset;

	//diagonal line max length ~ 480 pixels
	logic [17:0] line [399:0];
	
	//length (# of pixels) of line
	logic [8:0] length;
	
	//current x and y coordinate for the algorithm process (its a "for loop")
	int xCurr,yCurr,dx,dy;
	assign dx = x1-x0;
	assign dy = y1-y0;
	
	logic right,down;

	//for seq.logic states
	logic [1:0] state;
	
	//an artificial delay for the done signal
	logic [1:0] doneDelay;
	
	
	//TODO: look up comb for loop
	
	always @ (posedge clk) begin
	
		if(reset) begin
			state <= 2'b00;
		end
		
		if(state == 2'b01) begin
			line [length] <= xCurr + (yCurr * 399);
		end
		
		case (state)
			//idle state, clear buffer 
			2'b00:begin
				done <= 0;
				doneDelay <=0;
				if(start) begin
					state <= 2'b01;
					length <= 0;
					xCurr <= x0;
					yCurr <= y0;
				end
			end
			//write state, write data to buffer
			2'b01:begin
			
				if(xCurr >= x1) begin
					state <= 2'b10; 
				end else begin
					xCurr <= xCurr + 1;
					
				end
			end


			//done state
			2'b10:begin
				doneDelay <= doneDelay + 1;
				done <= 1;
				
				if(doneDelay == 2'b11) state <= 2'b00;
			end
		
		
		endcase
		
	end


endmodule


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
	//logic [17:0] vertecies [9:0];

	int indexA,indexB,indexC;
	int xA,yA,xB,yB,xC,yC;
	int x1,x2,x3,y1,y2,y3;
	
	assign xA = indexA % 399;
	assign xB = indexB % 399;
	assign xC = indexC % 399;
	
	assign yA = indexA / 399;
	assign yB = indexB / 399;
	assign yC = indexC / 399;
	
	int dx1,dx2,dx3,dy1,dy2,dy3;
	
	assign dx1 = x2-x1;
	assign dx2 = x3-x1;
	assign dx3 = x3-x2;
	
	assign dy1 = y2-y1;
	assign dy2 = y3-y1;
	assign dy3 = y3-y2;
	
	

	int b1,b2,b3;
	assign b1 = y2 - (x2 *dy1/dx1);
	assign b2 = y1 - (x1 *dy2/dx2);
	assign b3 = y2 - (x2 *dy3/dx3);

	
	
	assign indexC = (100*399) + 200;
	assign indexB = (120*399) + 300;
	assign indexA = (150*399) + 250;
	
	int xMax,xMin,yMax,yMin;
	
	//in between states
	logic case1,case2,case3,case4,case5,case6;
	assign case1 = xDraw >= dx1 * (yDraw - b1) /dy1 && xDraw <= dx2 * (yDraw - b2) /dy2;
	assign case2 = xDraw <= dx1 * (yDraw - b1) /dy1 && xDraw >= dx2 * (yDraw - b2) /dy2;
	assign case3 = xDraw >= dx2 * (yDraw - b2) /dy2 && xDraw <= dx3 * (yDraw - b3) /dy3;
	assign case4 = xDraw <= dx2 * (yDraw - b2) /dy2 && xDraw >= dx3 * (yDraw - b3) /dy3;
	
	logic[3:0] points;
	//case state to assign point ABC to 1 2 3
	
	
	always_comb begin

	
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
	
	
	//drawing logic
	
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
				//xDraw >= dx1 * (yDraw - b1) /dy1 || xDraw <= dx2 * (yDraw - b2) /dy2
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

//	//drawing logic
//	int xDraw,yDraw;
//	//int drawIndex;
//	int speedCount;
//	logic [9:0] speed;
//	assign speed = SW;
//	//assign speed = SW;
//
//	
//	logic [17:0] vertecies [9:0];
//	int vertexCount;
//	assign vertexCount = 4;
//	always @ (posedge divided_clocks[15])begin
//		vertecies[0] <= vertexCount;
//		if(reset) begin
//			speedCount <= 0;
//			//drawIndex <= 2;
//			vertecies[1] <=0;
//			vertecies[2] <=0;
//			vertecies[3] <=0;
//			vertecies[4] <=0;
//		end
//
//		if(speedCount >= speed)begin
//			speedCount <= 0;
////			if(drawIndex >= 95999) begin
////				drawIndex <= 2;
////			end else begin	
////				drawIndex <= drawIndex + 399;
////			end
//			vertecies[1] <= vertecies[1] + 400;
//			vertecies[2] <= vertecies[2] + 399;
//			vertecies[3] <= vertecies[3] + 798;
//			vertecies[4] <= vertecies[4] + 800;
//			if(vertecies[1] >= 95999) vertecies[1] <=0;
//			if(vertecies[2] >= 95999) vertecies[2] <=0;
//			if(vertecies[3] >= 95999) vertecies[3] <=0;
//			if(vertecies[4] >= 95999) vertecies[4] <=0;
//			
//		end else begin
//			speedCount <= speedCount +1;
//		end	
//	
//	end
	 
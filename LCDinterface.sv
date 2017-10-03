module Hsync (Dclk,HSout,reset,xActive);

	input logic Dclk,reset;
	output logic HSout;
	output logic xActive;
	int stateCount;
	logic [4:0] fpCounter;
	
	//3 states: h blanking, active and h front porch for each line
	// timing: 46 + 800 + 210 (178 + 32??)
	always @ (negedge Dclk)begin
		if (reset || stateCount == 1055) begin
			stateCount <= 0;
		end else begin
			stateCount <= stateCount + 1;
		end
		
		if(stateCount > 45 && stateCount <= 845)begin
			//active state
			xActive <= 1;
		end else begin
			xActive <= 0;
		end
		
		if(stateCount <= 10) begin
			HSout <= 0;
		end else begin
			HSout <= 1;
		end
		
	end
	
	
	
endmodule

module Vsync (HS,VSout,reset,yActive);

	input logic HS,reset;
	output logic VSout, yActive;
	
	int stateCount;
	//3 states: h blanking, active and h front porch for each line
	// timing: 23 + 480 + 22 (9 + 13??)
	always @ (negedge HS)begin
//		if(fpCounter == 0)begins
//			stateCount <= stateCount + 1;
//		end

		if (reset || stateCount == 525) begin
			stateCount <= 0;
		end else begin
			stateCount <= stateCount + 1;
		end
		
		if(stateCount > 22 && stateCount <= 502)begin
			//active area
			yActive <= 1;
		end else begin 
			yActive <= 0;
		end
		
		if(stateCount <= 9) begin
			VSout <= 0;
		end else begin
			VSout <= 1;
		end
		
	end
	
	
	
endmodule

//module that connects both 
module LCDinterface(Dclk,reset,x,y,GPIO_1,R,G,B);
	input logic Dclk,reset;
	logic HSout,VSout;
	output logic [9:0] x;
	output logic [8:0] y;
	output logic [39:0] GPIO_1;
	input logic [7:0] R,G,B;
	
	
	wire HS;
	assign HS = HSout;
	Hsync(Dclk,HSout,reset,xActive);
	Vsync(HS,VSout,reset,yActive);
	logic xActive,yActive;

	always @ (negedge Dclk)begin
		if(reset)begin
			x <=0;
			y <=0;	
		end else begin
			if(xActive && yActive)begin
				if(x == 799) begin
					x <= 0;
					if (y == 479) begin
						y <= 0;
					end else begin
						y <= y+1;
					end
				end else begin
					x <= x + 1;
				end
			end
		
		end
	end
	
	assign GPIO_1[3] = R[0];
	assign GPIO_1[4] = R[1];
	assign GPIO_1[5] = R[2];
	assign GPIO_1[6] = R[3];
	assign GPIO_1[7] = R[4];
	assign GPIO_1[8] = R[5];
	assign GPIO_1[9] = R[6];
	assign GPIO_1[10] = R[7];
	
	assign GPIO_1[11] = G[0];
	assign GPIO_1[12] = G[1];
	assign GPIO_1[13] = G[2];
	assign GPIO_1[14] = G[3];
	assign GPIO_1[15] = G[4];
	assign GPIO_1[18] = G[5];
	assign GPIO_1[19] = G[6];
	assign GPIO_1[21] = G[7];
	
	assign GPIO_1[20] = B[0];
	assign GPIO_1[22] = B[1];
	assign GPIO_1[23] = B[2];
	assign GPIO_1[24] = B[3];
	assign GPIO_1[25] = B[4];
	assign GPIO_1[26] = B[5];
	assign GPIO_1[27] = B[6];
	assign GPIO_1[28] = B[7];

	assign GPIO_1[30] = HSout;
	assign GPIO_1[31] = VSout;
	assign GPIO_1[1] = Dclk;
	
endmodule

	
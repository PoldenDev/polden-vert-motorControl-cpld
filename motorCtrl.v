module motorCtrl(
	input CLK_10MHZ,
	input clock_4ms,
	//input [23:0] velocity_rpm,
	input [15:0] newPos,
	input newPosSignal,
	output reg dir,
	output reg step,
	output reg [15:0] cur_position = 0 
);

//reg [11:0] velocity_rpm_locked = 10;


reg [15:0] deltaPos = 100;

parameter idleState = 0;
parameter speedUpState = 1;
parameter speedConstState = 2;
parameter speedDownSpeedState = 3;

reg [2:0] state = idleState;

//reg [9:0] divider = 1023;
//reg [9:0] clockCounter = 0;


parameter speedDeviationCount = 8'd244; //244*4,096 ms ~ 1sec
reg [7:0] timerCounterInc = 0;

wire timerFinal = (timerCounterInc==0);
reg stepClockEna = 0;
 
always @(posedge CLK_10MHZ) begin
	//if(velocity_rpm_locked != velocity_rpm) begin
		//velocity_rpm_locked <= velocity_rpm;	
	//end
	
	if(newPosSignal) begin
		//new_position <= newPos;
		state <= speedConstState;		
		//if(newPos > new_position) begin
		//	dir <= 1;
		//end
		dir <= 0;
		//divider <= 1023;
		//clockCounter <= 1023;
		timerCounterInc <= 100;
		stepClockEna <= 1;
		state <= speedConstState;
		deltaPos <= newPos - cur_position; 					
	end

	case(state)
		idleState: begin
			//state <= speedUpState;
			//stepClockEna <= 0;
		end
		
		speedUpState: begin				
			if(timerFinal) begin			
				state <= speedConstState;					
			end
			if(clock_4ms) begin			
				//divider <= divider - 100;
			end
		end
		
		speedConstState: begin	
			if(timerFinal)
				state <= speedDownSpeedState;
		end
		
		speedDownSpeedState: begin
			if(timerFinal) begin			
				state <= idleState;	
				stepClockEna <= 0;
			end
			if(clock_4ms) begin			
				//divider <= divider + 100;
			end			
		end		
	endcase
	
	if(stepClockEna) begin
//		if(clockCounter > 0) begin
//			clockCounter <= clockCounter - 1;			
//		end 
		//else begin
			//clockCounter <= divider;
		if(deltaPos > 0) begin
			step <= ~step;
			deltaPos <= deltaPos - 1;
			if((step==1'b1) && (dir==1'b1)) begin
				cur_position <= cur_position + 1;
			end
			if((step==1'b1) && (dir==1'b0)) begin
				cur_position <= cur_position - 1;
			end
		end
				
		//end
	end
	
	
	if(timerCounterInc == 0) begin				
		//divider <= divider - 100;			
		timerCounterInc <= 100;					
	end
	if(clock_4ms) begin			 
		timerCounterInc <= timerCounterInc - 1;							
	end	
	
end


endmodule

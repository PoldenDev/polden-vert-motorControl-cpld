module motorCtrl(
	input CLK_10MHZ,
	input clock_1_5mks,
	input clock_6ms,
	//input [23:0] velocity_rpm,
	input [15:0] deltaPos,
	input newPosSignal,
	output reg dir,
	output reg step//,
	//output reg [15:0] cur_position = 0 
);

parameter idleState = 0;
parameter speedUpState = 1;
parameter speedConstState = 2;
parameter speedDownSpeedState = 3;

parameter speedDeviationCount = 8'd244; //244*4,096 ms ~ 1sec

reg [7:0] deltaPosLoc = 100;
reg [1:0] state = idleState;
reg [7:0] timer6msPulsesCnt = 0;


reg [15:0] clockCounter = 0;
reg [15:0] divider = 0;


//reg [3:0] stepPulseCounter = 0;
 
wire timerFinal = (timer6msPulsesCnt==0);
reg stepClockEna = 0;
 
always @(posedge CLK_10MHZ) begin
	//if(velocity_rpm_locked != velocity_rpm) begin
		//velocity_rpm_locked <= velocity_rpm;	
	//end
	
	if(newPosSignal) begin
		//new_position <= newPos;
		//state <= speedConstState;		
		//if(newPos > new_position) begin
		//	dir <= 1;
		//end
		dir <= 0;
		divider <= 16'h800;
		clockCounter <= 0;
		//timer6msPulsesCnt <= 100;
		stepClockEna <= 1;
		state <= speedUpState;
		deltaPosLoc <= deltaPos; 					
	end

	case(state)
		idleState: begin
			//state <= speedUpState;
			//stepClockEna <= 0;
		end
		
		speedUpState: begin				
			if(timerFinal) begin			
				//state <= speedConstState;					
				//timerCounterInc <= 100;
			end
			if(clock_6ms) begin			
				if(divider > 16'h50) begin
					divider <= divider - 10;
				end
				else begin
					state <= speedConstState;
					timer6msPulsesCnt <= 100;
				end
				
			end
		end
		
		speedConstState: begin	
			if(timerFinal) begin
				state <= speedDownSpeedState;
				//timerCounterInc <= 100;
			end
		end
		
		speedDownSpeedState: begin
//			if(timerFinal) begin			
//				state <= idleState;	
//				stepClockEna <= 0;
//			end
//			if(clock_4ms) begin			
//				divider <= divider + 100;
//			end

			if(clock_6ms) begin			
				if(divider < 16'h800) begin
					divider <= divider + 10;
				end
				else begin
					state <= speedUpState;
				end
				
			end
			
		end		
	endcase
	
	if(stepClockEna) begin 		
		if(clockCounter == 0) begin
			clockCounter <= divider;
			step <= 1'b1;			
			//deltaPosLoc <= deltaPosLoc - 1;
		end
		else begin
			clockCounter <= clockCounter - 1;
			if(clockCounter == {1'b0, divider[15:1]}) 
				step <= 1'b0;							
		end

		
		//if((step==1'b1) && (dir==1'b1)) begin
		//	cur_position <= cur_position + 1;
		//end
		//if((step==1'b1) && (dir==1'b0)) begin
		//	cur_position <= cur_position - 1;
		//end
	end
	
	
	if(timer6msPulsesCnt == 0) begin				
		//divider <= divider - 100;			
		//timerCounterInc <= 100;					
	end
	if(clock_6ms && (timer6msPulsesCnt>0)) begin			 
		timer6msPulsesCnt <= timer6msPulsesCnt - 1;							
	end	
	

	
end


endmodule

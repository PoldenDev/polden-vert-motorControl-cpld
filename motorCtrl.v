module motorCtrl(
	input CLK_10MHZ,
	input clock_4ms,
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
reg [7:0] timerCounterInc = 0;


reg [9:0] clockCounter = 0;
reg [9:0] divider = 0;
 
wire timerFinal = (timerCounterInc==0);
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
		divider <= 1023;
		//clockCounter <= 1023;
		timerCounterInc <= 100;
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
				state <= speedConstState;					
				timerCounterInc <= 100;
			end
			if(clock_4ms) begin			
				divider <= divider - 100;
			end
		end
		
		speedConstState: begin	
			if(timerFinal) begin
				state <= speedDownSpeedState;
				timerCounterInc <= 100;
			end
		end
		
		speedDownSpeedState: begin
			if(timerFinal) begin			
				state <= idleState;	
				stepClockEna <= 0;
			end
			if(clock_4ms) begin			
				divider <= divider + 100;
			end			
		end		
	endcase
	
	if((stepClockEna)&&(deltaPosLoc > 0)) begin 
		if(clockCounter == 0) begin
			clockCounter <= divider;
			step <= ~step;
			deltaPosLoc <= deltaPosLoc - 1;
		end
		else begin
			clockCounter <= clockCounter - 1;
		end

		
		//if((step==1'b1) && (dir==1'b1)) begin
		//	cur_position <= cur_position + 1;
		//end
		//if((step==1'b1) && (dir==1'b0)) begin
		//	cur_position <= cur_position - 1;
		//end
	end
	
	
	if(timerCounterInc == 0) begin				
		//divider <= divider - 100;			
		//timerCounterInc <= 100;					
	end
	if(clock_4ms && (timerCounterInc>0)) begin			 
		timerCounterInc <= timerCounterInc - 1;							
	end	
	

	
end


endmodule

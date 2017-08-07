module motorCtrlSimple_v2(
	input CLK,
	input reset,
	input [14:0] divider,
	//input moveDir,
	//input moveDirInvers,
	//input stepClockEna,	
	input [14:0] stepsToGo,
	input dirInput,
	output reg dir = 0,
	output reg step = 0,
	//output reg signed [18:0] cur_position = 0,
	output reg activeMode = 0
);


//reg stepR=0; always @(posedge CLK) stepR <= step;
//wire step_risingedge = ((stepR==1'b0)&&(step==1'b1));  
//wire step_fallingedge = ((stepR==1'b1)&&(step==1'b0));  

//assign active = (newPos != cur_position);
reg [14:0] clockCounter = 0;
reg [14:0] dividerLoc;
//reg [18:0] newPosLoc;
reg [14:0] stepsCnt = 0;


//reg state = 0;
//reg signed [1:0] inc = 0;
//parameter idle=0;
//parameter going=1;
always @(posedge CLK) begin
	
	//if(reset) begin
		//cur_position <= 19'h0;	
	//end
	
	//activeMode <= ((stepsCnt != 0)||(clockCounter!=15'h0));
	if((stepsCnt==19'h0)&&(clockCounter==15'h0)) begin
		activeMode <= 0;		
		stepsCnt <= stepsToGo[14:0];	
		dividerLoc <= divider;
		dir <= dirInput;
		//clockCounter <= 15'h0;	
		
	end
	else begin	
		activeMode <= 1;		
		if(clockCounter == 0) begin
			step <= 1;	
			clockCounter <= dividerLoc;	
			stepsCnt <= stepsCnt - 15'h1;
			//if(cur_position == newPosLoc) begin
			//	state <= 1'b0;				
			//end
			//else begin
				
			//end			
		end
		else begin
			clockCounter <= clockCounter - 15'h1;						
			if(clockCounter == {1'b0, dividerLoc[14:1]})
				step <= 0;										
		end		
	end
	
	
	
//	case(state)
//	0:begin
//		if(cur_position != newPos) begin
//			//dividerLoc <= divider;
//			//clockCounter <= divider;		
//			step <= 1'b1;	
//			rdAck <= 1'b1;	
//			dir <= (newPos>cur_position) ? 1'b1 : 1'b0;	
//			newPosLoc <= newPos;
//			//stepsCnt <= stepsToGo;
//			state <= 1'b1;	
////			if(newPos>cur_position)
////				inc <= 2'd1;
////			else
////				inc <= -1;		
//		end
//	end
//	
//	1: begin
//		rdAck <= 1'b0;				
//		if(clockCounter == 0) begin
//			if(cur_position == newPosLoc) begin
//				state <= 1'b0;				
//			end
//			else begin
//				clockCounter <= dividerLoc;						
//			end			
//		end
//		else begin
//			clockCounter <= clockCounter - 13'h1;						
//			if(clockCounter == {1'b0, divider[12:1]})
//				step <= 1'b0;										
//		end	
//	end
//	
//	endcase
//	

		
//	if(step_risingedge) begin
//		//cur_position <= cur_position + inc;
//		if(dir == 1'b1) begin
//			cur_position <= cur_position + 19'h1;
//		end
//		else begin
//			cur_position <= cur_position - 19'h1;
//		end	
//	end
end
endmodule



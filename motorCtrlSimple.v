module motorCtrlSimple(
	input CLK,
	input reset,
	input [12:0] divider,
	input moveDir,
	//input moveDirInvers,
	input stepClockEna,	
	output reg dir,
	output reg step,
	output reg signed [19:0] cur_position = 0
);

reg [12:0] clockCounter = 0;
reg stepR=0; always @(posedge CLK) stepR <= step;
wire step_risingedge = ((stepR==1'b0)&&(step==1'b1));  
wire step_fallingedge = ((stepR==1'b1)&&(step==1'b0));  
//assign dir = moveDirInvers?~moveDir : moveDir;
//assign dir = moveDir;

always @(posedge CLK) begin
		
		if(clockCounter == 0) begin
			clockCounter <= divider;
			//step <= (1'b1);			
			step <= stepClockEna;			
			//deltaPosLoc <= deltaPosLoc - 1;
			//deltaPosCur <= deltaPosCur + 16'h1;
			dir <= moveDir;

	
		end
		else begin
			clockCounter <= clockCounter - 1;
			if(clockCounter == {1'b0, divider[11:1]}) 
				step <= 1'b0;							
		end		

	if(reset) begin
		cur_position <= 20'h0;	
	end	
	else if(step_risingedge) begin
		if(moveDir==1'b1) begin
			cur_position <= cur_position + 20'h1;
			//cur_position <= cur_position + step;	
		end
		else if(moveDir==1'b0) begin
			cur_position <= cur_position - 20'h1;
			//cur_position <= cur_position - step;
		end	
	end
end
endmodule



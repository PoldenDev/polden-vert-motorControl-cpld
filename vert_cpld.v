/* maxv_5m570z_start_golden_top.v
 This is a top level wrapper file that instanciates the
 golden top project
 */
 
 module vert_cpld(
 input   CLK_SE_AR,
 
//input CAP_PB_1,
output reg USER_LED0,

// Motor 
output [9:0] step,
output [9:0] dir,
input [9:0] term,

input 	UART_RX,
output 	UART_TX,

output DebugPin1 = 0,
output reg DebugPin2 = 0,
output reg DebugPin3 = 0,
output DebugPin4,
output DebugPin5,
output DebugPin6
);  

wire rst;

reg [32:0] counter = 0; 
always @(posedge CLK_SE_AR) begin
	USER_LED0 <= counter[24];
	counter <= counter + 1;
end

reg [9:0] posReset = 0;
//reg [9:0] fifoWrReq=0;
//wire [31:0] fifoDataOut[9:0];
wire [9:0] fifoEmpty;

wire [9:0] mrCtrlActive;
reg [9:0] mrCtrlActiveR;

reg [14:0] divider[9:0];
reg [14:0] stepCounter[9:0];
reg dirReg[9:0];

reg [9:0] dataPending = 0;


assign DebugPin4 = step[0];
assign DebugPin5 = mrCtrlActive[0];
assign DebugPin6 = dataPending[0];
genvar i;
generate
for(i = 0; i < 10; i = i + 1 ) begin : motorControlBlock

//cmdFifo fifo(.clock(CLK_SE_AR), 
//				.data(uartCmd), 
//				.rdreq((~mrCtrlActive[i])&(~fifoEmpty[i])), 
//				.wrreq(fifoWrReq[i]), 
//				.q(fifoDataOut[i]), 
//				.empty(fifoEmpty[i]));
				
//fifo_cust fifo(.clk(CLK_SE_AR), 
//					.rst(rst), 
//					.buf_in(uartCmd), 
//					.buf_out(fifoDataOut[i]), 
//					.wr_en(fifoWrReq[i]),
//					.rd_en((~mrCtrlActive[i])&(~fifoEmpty[i])),
//					.buf_empty(fifoEmpty[i]));
//motorCtrlSimple_v2 mr(.CLK(CLK_SE_AR), .reset(posReset[i]), .divider(fifoDataOut[i][12:0]), .newPos(fifoDataOut[i][31:13]), .dir(dir[i]), .step(step[i]), .active(mrCtrlActive[i]));

//always @(posedge CLK_SE_AR) begin
//	mrCtrlActiveR[i] <= mrCtrlActive[i];
//	if((mrCtrlActive[i]==1)&&(mrCtrlActiveR[i]==0)) begin
//		divider[i] <= 0;
//		stepCounter[i]<= 0;
//	end
//		
//end	

motorCtrlSimple_v2 mr(.CLK(CLK_SE_AR), 
							 .reset(posReset[i]),
							 .divider(divider[i][14:0]), 
							 .stepsToGo(stepCounter[i][14:0]), 
							 .dirInput(dirReg[i]),
							 .dir(dir[i]), 
							 .step(step[i]), 
							 .activeMode(mrCtrlActive[i]));
end
endgenerate

reg [31:0] timerCounter; always @(posedge CLK_SE_AR) timerCounter <= timerCounter + 31'h1;

wire uartRxDataReady;
wire [7:0] uartRxData;
reg uartRxDataReadyL=1'b0; always @(posedge CLK_SE_AR) uartRxDataReadyL <= uartRxDataReady;
wire uartRxDataReadyPE = ((uartRxDataReady==1'b1)&&(uartRxDataReadyL==1'b0));
wire uartRxDataReadyNE = ((uartRxDataReady==1'b0)&&(uartRxDataReadyL==1'b1));

assign DebugPin1 = uartRxDataReadyPE;
//assign DebugPin3 = uartRxDataReadyPE;

async_receiver #(.ClkFrequency(24000000), .Baud(115200)) RX(.clk(CLK_SE_AR),
													 								//.BitTick(uartTick1),
																					.RxD(UART_RX), 
																					.RxD_data_ready(uartRxDataReady), 
																					.RxD_data(uartRxData));
	
reg [3:0] uartRecvState = 0;	
reg [3:0] curMrCtrl = 0;
reg [39:0] uartCmd;
reg [31:0] uartTimeOutCounter = 32'h0;
integer c;
always @(posedge CLK_SE_AR) begin
	if(uartRxDataReadyPE) begin
		if(uartRecvState == 0) begin
			curMrCtrl <= uartRxData[3:0];
			//uartRecvState <= uartRecvState + 4'h1;
		end		
		uartRecvState <= uartRecvState + 4'h1;		
		uartCmd[39:0] <= {uartRxData[7:0], uartCmd[39:8]}; 		
		//uartCmdRecvData[curMrCtrl] <= {uartRxData[7:0], uartCmdRecvData[curMrCtrl][31:8]};			
		//DebugPin1 <= 1'b1;				
	end	
	else begin
		if(uartTimeOutCounter == 32'h0) begin
			uartRecvState <= 4'h0;	
			DebugPin3 <= 1;
		end
		else begin
			DebugPin3 <= 0;
		end
	end
	
	if(uartRxDataReadyPE) begin
		uartTimeOutCounter <= 32'h249f00;		
	end
	else begin
		uartTimeOutCounter <= uartTimeOutCounter - 32'h1;		
	end
	
	DebugPin2 <=  uartRxDataReadyNE && (uartRecvState == 5);
	if(uartRxDataReadyNE) begin	
		if(uartRecvState == 5) begin
			uartRecvState <= 0;		
			//fifoWrReq[curMrCtrl] <= 1'b1;
			//uartCmd <= {uartRxData[7:0], uartCmdRecvData[curMrCtrl][31:8]};
			//uartCmdRecvData[curMrCtrl] <= uartCmd;
			if(dataPending[curMrCtrl] == 0) begin
				divider[curMrCtrl] <= uartCmd[18:4];
				stepCounter[curMrCtrl] <= uartCmd[33:19];		
				dirReg[curMrCtrl] <= uartCmd[34];
				dataPending[curMrCtrl] <= 1;
				
				//divider[9] <= 15'hff;
				//stepCounter[9] <= 14'h6;
			end
			//DebugPin2 <= 1'b1;						
		end		
	end
	else begin	
		//fifoWrReq <= 10'h0;
		//DebugPin1 <= 1'b0;			
		mrCtrlActiveR <= mrCtrlActive;		
		for ( c = 0; c < 10; c = c + 1) begin: lbl        
			if({mrCtrlActive[c], mrCtrlActiveR[c]}==2'b10) begin
				dataPending[c] <= 0;
				stepCounter[c] <= 0;
			end	
		end		
	end
	

end



//endgenerate
 

reg [17:0] sendDelay;
wire uartBusy; reg uartBusyR; 

reg [2:0] uartSendState = 2'b000;
//reg uartSendPartNum = 0;
reg uartStartSignal = 0;
reg [7:0] uartTxData;

//wire uart19200StartSignal = (timerCounter[12:0] == 13'h1FFF);
async_transmitter #(.ClkFrequency(24000000), .Baud(115200)) TX(.clk(CLK_SE_AR),
																					//.BitTick(uartTick1),
																					.TxD(UART_TX), 
																					.TxD_start(uartStartSignal), 
																					.TxD_data(uartTxData),
																					.TxD_busy(uartBusy));
																					
parameter delay_between_bytes=18'hfff;
parameter delay_between_packs=18'h3ffff;
	
always @(posedge CLK_SE_AR) begin
	case(uartSendState)
		3'b000:  begin
			//if(dataPending[9:0] != 10'h3ff) begin				
				uartTxData[7:0] <= {2'h0, 1'b0, dataPending[4:0]};
				//uartTxData[7:0] <= {uartSendPartNum, 3'h0, uartSendPartNum+4'h1};
				//uartSendPartNum <= uartSendPartNum + 1'h1;				
				uartStartSignal <= 1;				
				sendDelay <= delay_between_bytes;
				uartSendState <= 3'b001;
			//end			
		end
		3'b001: begin
			uartStartSignal <= 0;			
			if(sendDelay == 0) begin
				uartSendState <= 3'b010;
			end
			else begin
				sendDelay <= sendDelay - 18'h1;
			end			
		end		
		3'b010: begin			
			uartTxData[7:0] <= {2'h1, 1'b0, dataPending[9:5]};
			uartStartSignal <= 1;									
			sendDelay <= delay_between_bytes;
			uartSendState <= 3'b011;
		end
		3'b011: begin
			uartStartSignal <= 0;					
			if(sendDelay == 0) begin
				uartSendState <= 3'b100;
			end
			else begin
				sendDelay <= sendDelay - 18'h1;
			end	
		end				
		
		
		3'b100: begin
			uartTxData[7:0] <= {2'h2, 1'b0, ~term[4:0]};
			//uartTxData[7:0] <= {uartSendPartNum, 3'h0, uartSendPartNum+4'h1};
			//uartSendPartNum <= uartSendPartNum + 1'h1;				
			uartStartSignal <= 1;				
			sendDelay <= delay_between_bytes;
			uartSendState <= 3'b101;	
		end	
		3'b101: begin
			uartStartSignal <= 0;			
			if(sendDelay == 0) begin
				uartSendState <= 3'b110;
			end
			else begin
				sendDelay <= sendDelay - 18'h1;
			end	
		end	
		3'b110: begin
			uartTxData[7:0] <= {2'h3, 1'b0, ~term[9:5]};
			uartStartSignal <= 1;									
			sendDelay <= delay_between_packs;
			uartSendState <= 3'b111;
		end	
		3'b111: begin
			uartStartSignal <= 0;					
			if(sendDelay == 0) begin
				uartSendState <= 3'b000;
			end
			else begin
				sendDelay <= sendDelay - 18'h1;
			end	
		end	

	endcase	
end
	

endmodule


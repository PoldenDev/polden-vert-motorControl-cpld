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

input 	UART_RX,
output 	UART_TX,

output reg DebugPin1 = 0,
output reg DebugPin2 = 0,
output reg DebugPin3 = 0
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
reg [13:0] stepCounter[9:0];
reg [9:0] dataPending = 0;


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
							 .stepsToGo(stepCounter[i][13:0]), 
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
//wire uartRxDataReadyNE = ((uartRxDataReady==1'b0)&&(uartRxDataReadyL==1'b1));
async_receiver #(.ClkFrequency(24000000), .Baud(230400)) RX(.clk(CLK_SE_AR),
													 								//.BitTick(uartTick1),
																					.RxD(UART_RX), 
																					.RxD_data_ready(uartRxDataReady), 
																					.RxD_data(uartRxData));
	
reg [3:0] uartRecvState = 0;	
reg [3:0] curMrCtrl = 0;
reg [31:0] uartCmd;
integer c;
always @(posedge CLK_SE_AR) begin
	DebugPin3 <= uartRxDataReadyPE;
	if(uartRxDataReadyPE) begin
		if(uartRecvState == 0) begin
			curMrCtrl <= uartRxData[3:0];
			uartRecvState <= uartRecvState + 4'h1;
		end
		else if(uartRecvState < 4) begin 
			uartRecvState <= uartRecvState + 4'h1;
		end 
		else if(uartRecvState == 4) begin
			uartRecvState <= 0;
			//fifoWrReq[curMrCtrl] <= 1'b1;
			//uartCmd <= {uartRxData[7:0], uartCmdRecvData[curMrCtrl][31:8]};
			//uartCmdRecvData[curMrCtrl] <= uartCmd;
			if(dataPending[curMrCtrl] == 0) begin
				divider[curMrCtrl] <= uartCmd[18:4];
				stepCounter[curMrCtrl] <= uartCmd[31:19];		
				dataPending[curMrCtrl] <= 1;
				
				//divider[9] <= 15'hff;
				//stepCounter[9] <= 14'h6;
			end
			DebugPin2 <= 1'b1;
		end		
		//uartCmdRecvData[curMrCtrl] <= {uartRxData[7:0], uartCmdRecvData[curMrCtrl][31:8]};		
		uartCmd <= {uartRxData[7:0], uartCmd[31:8]};
		DebugPin1 <= 1'b1;
	end	
	else begin	
		//fifoWrReq <= 10'h0;
		DebugPin1 <= 1'b0;
		DebugPin2 <= 1'b0;	
	
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

reg [1:0] uartSendState = 2'b00;
//reg uartSendPartNum = 0;
reg uartStartSignal = 0;
reg [7:0] uartTxData;

//wire uart19200StartSignal = (timerCounter[12:0] == 13'h1FFF);
async_transmitter #(.ClkFrequency(24000000), .Baud(230400)) TX(.clk(CLK_SE_AR),
																					//.BitTick(uartTick1),
																					.TxD(UART_TX), 
																					.TxD_start(uartStartSignal), 
																					.TxD_data(uartTxData),
																					.TxD_busy(uartBusy));
																					
always @(posedge CLK_SE_AR) begin
	case(uartSendState)
		2'b00:  begin
			if(dataPending[9:0] != 10'h3ff) begin				
				uartTxData[7:0] <= {1'b0, 2'h0, dataPending[4:0]};
				//uartTxData[7:0] <= {uartSendPartNum, 3'h0, uartSendPartNum+4'h1};
				//uartSendPartNum <= uartSendPartNum + 1'h1;				
				uartStartSignal <= 1;				
				sendDelay <= 18'h3fff;
				uartSendState <= 2'b01;
			end			
		end
		2'b01: begin
			uartStartSignal <= 0;			
			if(sendDelay == 0) begin
				uartSendState <= 2'b10;
			end
			else begin
				sendDelay <= sendDelay - 18'h1;
			end			
		end		
		2'b10: begin			
			uartTxData[7:0] <= {1'b1, 2'h0, dataPending[9:5]};
			uartStartSignal <= 1;									
			sendDelay <= 18'h3ffff;
			uartSendState <= 2'b11;
		end
		2'b11: begin
			uartStartSignal <= 0;					
			if(sendDelay == 0) begin
				uartSendState <= 2'b00;
			end
			else begin
				sendDelay <= sendDelay - 18'h1;
			end	
		end		
	endcase	
end

endmodule


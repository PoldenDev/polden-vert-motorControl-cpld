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
output reg DebugPin2 = 0
);  

 
//parameter uartIdle = 0; 
//parameter recvNum = 1;
//parameter recvPos = 2;

//reg [2:0] uartState = uartIdle;

//wire uartRxDataReady;
//wire [7:0] uartRxData;
wire rst;

//assign UART_TX = UART_RX;

reg [32:0] counter = 0; 
always @(posedge CLK_SE_AR) begin
	USER_LED0 <= counter[24];
	counter <= counter + 1;
end

// async_receiver #(.ClkFrequency(10000000), .Baud(230400)) RX(.clk(CLK_SE_AR),
//																				 //.BitTick(uartTick1),
//																				 .RxD(BGPIO[36]), 
//																				 .RxD_data_ready(uartRxDataReady), 
//																				 .RxD_data(uartRxData));
																					
//reg [23:0] newPos;
//reg [3:0] posNum;
//reg [11:0] newPosSignal ;
//reg sign = 0;
////assign AGPIO[34] = sign;
//always @(posedge CLK_SE_AR) begin
//
//		
//		if(uartRxDataReady) begin
//			case(uartState)
//				uartIdle: begin				
//					if(uartRxData == "S") begin
//						uartState <= recvNum;	
//						newPosSignal[0] <=1'b1;	
//						sign <=1'b1;
//						USER_LED0 <= 1'b0;						
//					end
//					else begin
//						USER_LED0 <= 1'b1;						
//					end	
//					
//				end			
//				recvNum: begin
//					posNum <= uartRxData;
//					uartState <= recvPos;	
//					newPosSignal[posNum] <=1'b0;
//					sign <=1'b0;	
//					uartState <= uartIdle;
//					USER_LED0 <= 1'b1;	
//										
//				end
//				recvPos: begin
//					newPos <= uartRxData;
//					newPosSignal[posNum] <=1'b1;
//					uartState <= uartIdle;
//				end
//			
//			endcase
//		end
//		else begin
//			newPosSignal[0] <=1'b0;	
//		end
//
//end

//assign USER_LED0 = stepClockEna[0];
//assign USER_LED1 = stepClockEna[1];
//wire [31:0] curPositionW[9:0];
//reg [31:0] pospos[9:0];
//reg [12:0] divider[9:0];
//reg moveDirInverse;
//reg [9:0] stepClockEna;
//reg [9:0] moveDir;
reg [9:0] posReset = 0;
reg [9:0]fifoWrReq=0;
//wire [31:0] fifoDataOut[9:0];
wire [9:0] fifoEmpty;

wire [9:0] mrCtrlActive;
reg [9:0] mrCtrlActiveR;

reg [14:0] divider[9:0];
reg [13:0] stepCounter[9:0];
reg dataPending[9:0];


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
motorCtrlSimple_v2 mr(.CLK(CLK_SE_AR), 
							 .reset(posReset[i]), 
							 .divider(divider[i][14:0]), 
							 .stepsToGo(stepCounter[i][13:0]), 
							 .dir(dir[i]), 
							 .step(step[i]), 
							 .activeMode(mrCtrlActive[i]));

//always @(posedge CLK_SE_AR) begin
//	mrCtrlActiveR[i] <= mrCtrlActive[i];
//	if((mrCtrlActive[i]==1)&&(mrCtrlActiveR[i]==0)) begin
//		divider[i] <= 0;
//		stepCounter[i]<= 0;
//	end
//		
//end						 

							 
end
endgenerate

//generate
//for(i = 0; i < 10; i = i + 1 ) begin : motorControlBlock
//end
//endgenerate


reg [31:0] timerCounter; always @(posedge CLK_SE_AR) timerCounter <= timerCounter + 31'h1;
//wire uartBusy;
////reg [15:0] uartBusyR; always @(posedge CLK_SE_AR) uartBusyR[7:0] <= {uartBusyR[14:0], uartBusy};
reg uartEna = 0;
reg uartStartSignal = 0;
//wire uartStartSignalWire = uartStartSignal && uartEna;
//wire uart19200StartSignal = (timerCounter[12:0] == 13'h1FFF);
async_transmitter #(.ClkFrequency(24000000), .Baud(230400)) TX(.clk(CLK_SE_AR),
																					//.BitTick(uartTick1),
																					.TxD(UART_TX), 
																					.TxD_start(uartStartSignal), 
																					.TxD_data(uartDataReg),
																					.TxD_busy(uartBusy));
wire uartRxDataReady;
wire [7:0] uartRxData;
reg uartRxDataReadyL; always @(posedge CLK_SE_AR) uartRxDataReadyL <= uartRxDataReady;
wire uartRxDataReadyPE = ((uartRxDataReady==1'b1)&&(uartRxDataReadyL==1'b0));
wire uartRxDataReadyNE = ((uartRxDataReady==1'b0)&&(uartRxDataReadyL==1'b1));
async_receiver #(.ClkFrequency(24000000), .Baud(230400)) RX(.clk(CLK_SE_AR),
													 								//.BitTick(uartTick1),
																					.RxD(UART_RX), 
																					.RxD_data_ready(uartRxDataReady), 
																					.RxD_data(uartRxData));
	
reg [3:0] uartRecvState = 0;	
reg [3:0] curMrCtrl = 0;

reg [31:0] uartCmd;

always @(posedge CLK_SE_AR) begin
	if(uartRxDataReadyPE) begin
		if(uartRecvState == 0) begin
			curMrCtrl <= uartRxData;
		end
		else if(uartRecvState < 4) begin 
			uartRecvState <= uartRecvState +1;
		end else if(uartRecvState == 4) begin
			uartRecvState <= 0;
			fifoWrReq[curMrCtrl] <= 1'b1;
			//uartCmd <= {uartRxData[7:0], uartCmdRecvData[curMrCtrl][31:8]};
			//uartCmdRecvData[curMrCtrl] <= uartCmd;
			divider[curMrCtrl] <= uartCmd[14:0];
			stepCounter[curMrCtrl] <= uartCmd[31:15];
			DebugPin2 <= 1'b1;
		end		
		//uartCmdRecvData[curMrCtrl] <= {uartRxData[7:0], uartCmdRecvData[curMrCtrl][31:8]};		
		uartCmd <= {uartRxData[7:0], uartCmd[31:8]};
		DebugPin1 <= 1'b1;
	end	
	else begin	
		fifoWrReq <= 10'h0;
		DebugPin1 <= 1'b0;
		DebugPin2 <= 1'b0;		
	end
	
	mrCtrlActiveR[0] <= mrCtrlActive[0];
	if((mrCtrlActive[0]==1)&&(mrCtrlActiveR[0]==0)) begin
		dataPending[0] <= 1;
	end	
		
end	

//wire [15:0] SSPrecvdData;
//wire [3:0] motorNumW = SSPrecvdData[3:0];
//wire newWordRecvd;
//reg newWordRecvdR;  always @(posedge CLK_SE_AR) newWordRecvdR <= newWordRecvd;
//wire newWordRecvd_risingedge = ((newWordRecvdR==1'b0)&&(newWordRecvd==1'b1));  
//wire newWordRecvd_fallingedge = ((newWordRecvdR==1'b1)&&(newWordRecvd==1'b0));  

//wire [15:0] dataToTransfer = curPosition[0][19:4];
//reg  [15:0] dataToTransfer;
//reg AGPIO_4_SSELR;  always @(posedge CLK_SE_AR) AGPIO_4_SSELR <= AGPIO_4_SSEL;
//wire AGPIO_4_SSEL_fallingedge = ((AGPIO_4_SSELR==1'b1)&&(AGPIO_4_SSEL==1'b0)); 
//SSP ssp(.clk(CLK_SE_AR), .SCK(AGPIO_1_SCK), .MOSI(AGPIO_2_MOSI), .MISO(AGPIO_3_MISO), .SSEL(AGPIO_4_SSEL), .recvdData(SSPrecvdData), .word_received(newWordRecvd), .wordDataToSend(dataToTransfer), .SCK_risingedgeDeb(AGPIO[7]));

//parameter wait_cmd_state = 0;
//parameter sendCurrentPosition_state = 0;

//reg [3:0] state = wait_cmd_state;
//reg [3:0] motorNum;

//reg [9:0] lowerPosSignal;
//assign AGPIO[5] = newWordRecvd;

//initial begin
//	pospos[0] = 32'h000aaaab;
//	pospos[1] = 32'hfffffffb;
//end
//always @(posedge CLK_SE_AR) begin
//
//	if(newWordRecvd_risingedge) begin
//		case(SSPrecvdData[15:13]) 
//			3'd0: begin				//num reset
//				motorNum <= motorNumW; 		  //motorNum  not yet locked							
//			end					  
//			3'd1: begin					
//				dataToTransfer[15:0] <= "OK";
//			end
//			3'd2: begin			//div
//				
//				dataToTransfer[15:0] <= "OK";
//			end			
//			3'd3: begin			//ena
//				
//				dataToTransfer[15:0] <= "OK";					
//			end			
//			3'd4: begin		   //empty. only get cur pos				
//			end
//			3'd5: begin							
//			end
//			3'd6: begin			//reserv				
//			end
//			3'd7: begin			//reserv			
//			end
//
//		endcase
//	end
//	if(newWordRecvd_fallingedge) begin
//			case(SSPrecvdData[15:13]) 
//			3'd0: begin				//num reset
//				posReset[motorNum] <= SSPrecvdData[4];	//resetBit
//				dataToTransfer[15:0] <= curPositionW[motorNum][15:0];
//			end					  
//			3'd1: begin	
//				moveDir[motorNum] <=  SSPrecvdData[0];	//dirBit				
//			end
//			3'd2: begin			//div
//				divider[motorNum] <= SSPrecvdData[12:0];				
//			end			
//			3'd3: begin			//ena
//				stepClockEna[motorNum] <= SSPrecvdData[0];	//enabit			
//			end			
//			3'd4: begin		   //empty. only get cur pos
//				dataToTransfer[15:0] <= curPositionW[motorNum][31:16];					
//			end
//			3'd5: begin			
//				dataToTransfer[15:0] <= curPositionW[motorNum][31:16];					
//			end
//			3'd6: begin			//reserv
//				dataToTransfer[15:0] <= curPositionW[motorNum][31:16];					
//			end
//			3'd7: begin			//reserv
//				dataToTransfer[15:0] <= curPositionW[motorNum][31:16];					
//			end
//
//		endcase
//		
//	end

endmodule


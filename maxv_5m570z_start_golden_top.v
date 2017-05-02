/* maxv_5m570z_start_golden_top.v
 This is a top level wrapper file that instanciates the
 golden top project
 */
 
 module maxv_5m570z_start_golden_top(
 
input   CLK_SE_AR,

// GPIO
input USER_PB0, USER_PB1,
input CAP_PB_1,
input USER_LED0, USER_LED1,

// Connector A 
output   [  36: 1] 	AGPIO,

// Connector B
input   [  36: 7] 	BGPIO,
input 	BGPIO_P_1, BGPIO_N_1,
input 	BGPIO_P_2, BGPIO_N_2,
input 	BGPIO_P_3, BGPIO_N_3,

// Motor 1
input MOTOR_1_FB_A, MOTOR_1_FB_B, MOTOR_1_CTRL,
input   [  5: 0] 	MAX_MOTOR_1, 

// Motor 2
input MOTOR_2_FB_A, MOTOR_2_FB_B, MOTOR_2_CTRL,
input   [  5: 0] 	MAX_MOTOR_2, 

// Speaker
input   [  7: 0] 	MAX_SPK, 

// I2C EEPROM
input I2C_PROM_SCL, I2C_PROM_SDA, 
 
// SPI EEPROM
input SPI_MOSI, SPI_SCK, SPI_CSN, SPI_MISO
 );  

parameter uartIdle = 0; 
parameter recvNum = 1;
parameter recvPos = 2;

reg [2:0] uartState = uartIdle;

wire uartRxDataReady;
wire [7:0] uartRxData;

reg [11:0] counter = 0; always @(posedge CLK_SE_AR) counter <= counter + 1;
wire clock_4ms = (counter== 12'hfff);

 async_receiver #(.ClkFrequency(10000000), .Baud(230400)) RX(.clk(CLK_SE_AR),
																				 //.BitTick(uartTick1),
																				 .RxD(BGPIO[36]), 
																				 .RxD_data_ready(uartRxDataReady), 
																				 .RxD_data(uartRxData));
																					
 
reg [23:0] newPos;
reg [3:0] posNum;
reg [11:0] newPosSignal ;

always @(posedge CLK_SE_AR) begin

		
		if(uartRxDataReady) begin
			case(uartState)
				uartIdle: begin				
					if(uartRxData == "S") begin
						uartState <= recvNum;						
					end	
					newPosSignal[posNum] <=1'b0;
				end			
				recvNum: begin
					posNum <= uartRxData;
					uartState <= recvPos;		
					
				end
				recvPos: begin
					newPos <= uartRxData;
					newPosSignal[posNum] <=1'b1;
					uartState <= uartIdle;
				end
			
			endcase
		end

end
 
motorCtrl mr00(.CLK_10MHZ(CLK_SE_AR), .clock_4ms(clock_4ms), .newPos(newPos[0]), .newPosSignal(newPosSignal[0]), .dir(AGPIO[35]), .step(AGPIO[36]));
motorCtrl mr01(.CLK_10MHZ(CLK_SE_AR), .clock_4ms(clock_4ms), .newPos(newPos[1]), .newPosSignal(newPosSignal[1]), .dir(AGPIO[33]), .step(AGPIO[34]));
motorCtrl mr02(.CLK_10MHZ(CLK_SE_AR), .clock_4ms(clock_4ms), .newPos(newPos[2]), .newPosSignal(newPosSignal[2]), .dir(AGPIO[31]), .step(AGPIO[32]));
motorCtrl mr03(.CLK_10MHZ(CLK_SE_AR), .clock_4ms(clock_4ms), .newPos(newPos[3]), .newPosSignal(newPosSignal[3]), .dir(AGPIO[29]), .step(AGPIO[30]));
motorCtrl mr04(.CLK_10MHZ(CLK_SE_AR), .clock_4ms(clock_4ms), .newPos(newPos[4]), .newPosSignal(newPosSignal[4]), .dir(AGPIO[27]), .step(AGPIO[28]));
motorCtrl mr05(.CLK_10MHZ(CLK_SE_AR), .clock_4ms(clock_4ms), .newPos(newPos[5]), .newPosSignal(newPosSignal[5]), .dir(AGPIO[25]), .step(AGPIO[26]));
motorCtrl mr06(.CLK_10MHZ(CLK_SE_AR), .clock_4ms(clock_4ms), .newPos(newPos[6]), .newPosSignal(newPosSignal[6]), .dir(AGPIO[23]), .step(AGPIO[24]));
motorCtrl mr07(.CLK_10MHZ(CLK_SE_AR), .clock_4ms(clock_4ms), .newPos(newPos[7]), .newPosSignal(newPosSignal[7]), .dir(AGPIO[21]), .step(AGPIO[22]));
motorCtrl mr08(.CLK_10MHZ(CLK_SE_AR), .clock_4ms(clock_4ms), .newPos(newPos[8]), .newPosSignal(newPosSignal[8]), .dir(AGPIO[19]), .step(AGPIO[20]));
motorCtrl mr09(.CLK_10MHZ(CLK_SE_AR), .clock_4ms(clock_4ms), .newPos(newPos[9]), .newPosSignal(newPosSignal[9]), .dir(AGPIO[17]), .step(AGPIO[18]));
motorCtrl mr10(.CLK_10MHZ(CLK_SE_AR), .clock_4ms(clock_4ms), .newPos(newPos[10]), .newPosSignal(newPosSignal[10]), .dir(AGPIO[15]), .step(AGPIO[16]));
motorCtrl mr11(.CLK_10MHZ(CLK_SE_AR), .clock_4ms(clock_4ms), .newPos(newPos[11]), .newPosSignal(newPosSignal[11]), .dir(AGPIO[13]), .step(AGPIO[14]));
endmodule


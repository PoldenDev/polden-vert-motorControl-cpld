module SSP(
	input clk,
	input SCK,
	input MOSI,
	output MISO,
	input SSEL,
	output reg [15:0] recvdData,  // high when a byte has been received
	output reg word_received,
	input [15:0] wordDataToSend,
	output SCK_risingedgeDeb
);
// sync SCK to the FPGA clock using a 3-bits shift register
reg [2:0] SCKr;  always @(posedge clk) SCKr <= {SCKr[1:0], SCK};
wire SCK_risingedge = (SCKr[2:1]==2'b01); 
wire SCK_fallingedge = (SCKr[2:1]==2'b10); 

assign SCK_risingedgeDeb = word_received;
// same thing for SSEL
reg [2:0] SSELr;  always @(posedge clk) SSELr <= {SSELr[1:0], SSEL};
wire SSEL_active = ~SSELr[1];  // SSEL is active low
wire SSEL_startmessage = (SSELr[2:1]==2'b10);  // message starts at falling edge
wire SSEL_endmessage = (SSELr[2:1]==2'b01);  // message stops at rising edge

// and for MOSI
reg [1:0] MOSIr;  always @(posedge clk) MOSIr <= {MOSIr[0], MOSI};
wire MOSI_data = MOSIr[1];


// we handle SPI in 8-bits format, so we need a 3 bits counter to count the bits as they come in
reg [3:0] bitcnt;


//reg [7:0] byte_data_received;

always @(posedge clk)
begin
  if(~SSEL_active)
    bitcnt <= 4'h0;
  else
  if(SCK_risingedge)
  begin
    bitcnt <= bitcnt + 4'b001;

    // implement a shift-left register (since we receive the data MSB first)
    recvdData <= {recvdData[14:0], MOSI_data};
  end
end

always @(posedge clk) word_received <= SSEL_active && SCK_risingedge && (bitcnt==4'b1111);


reg [15:0] wordDataSendLoc;

reg [15:0] cnt;
always @(posedge clk) if(SSEL_startmessage) cnt<=cnt+16'h1;  // count the messages

always @(posedge clk)
if(SSEL_active)
begin
  if(SSEL_startmessage)
    wordDataSendLoc <= wordDataToSend;  // first byte sent in a message is the message count
  else if(SCK_fallingedge) begin
    if(bitcnt==4'h0)
      wordDataSendLoc <= 16'h00;  // after that, we send 0s
    else
      wordDataSendLoc <= {wordDataSendLoc[14:0], 1'b0};
  end
end

assign MISO = wordDataSendLoc[15];  // send MSB first
// we assume that there is only one slave on the SPI bus
// so we don't bother with a tri-state buffer for MISO
// otherwise we would need to tri-state MISO when SSEL is inactive


endmodule

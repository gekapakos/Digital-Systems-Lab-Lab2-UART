`timescale 1ns / 1ps


module uart_receiver_tb;

reg reset, clk;
reg [2:0] baud_select;
reg Rx_EN;
reg RxD;
wire [7:0] Rx_DATA;
wire Rx_FERROR; // Framing Error //
wire Rx_PERROR; // Parity Error //
wire Rx_VALID; // Rx_DATA is Valid //

uart_receiver uart_receiver_u(.reset(reset), .clk(clk), .Rx_DATA(Rx_DATA), .baud_select(baud_select), .Rx_PERROR(Rx_PERROR), .Rx_EN(Rx_EN), .RxD(RxD), .Rx_FERROR(Rx_FERROR), .Rx_VALID(Rx_VALID));

initial begin
	clk = 0;
	forever #5 clk = ~clk;
end

/*In this testbench we would like to check for all the occasions meaning that we check for both the error cases 
and the case that the code is fine*/
initial begin
	reset = 1;
	#100 reset = 0;
	baud_select = 3'b111;
	Rx_EN = 1;
	RxD=1;
	#9905 RxD=0;//start bit
	/*01010101*/
	//We transmit 8'h55, with no parity or frame errors.
	#8800 RxD=1;
	#8800 RxD=0;
	#8800 RxD=1;
	#8800 RxD=0;
	#8800 RxD=1;
	#8800 RxD=0;
	#8800 RxD=1;
	#8800 RxD=0;
	#8800 RxD=0;//parity bit
	#8800 RxD=1;//stop bit
	
	#9905 RxD=0;//start bit
	/*10101010*/
	//We transmit 8'haa, with parity error.
	#8800 RxD=0;
	#8800 RxD=1;
	#8800 RxD=0;
	#8800 RxD=1;
	#8800 RxD=0;
	#8800 RxD=1;
	#8800 RxD=0;
	#8800 RxD=1;
	#8800 RxD=1;//parity bit
	#8800 RxD=1;//stop bit
	
	#9905 RxD=0;//start bit
	/*11001100*/
	//We transmit 8'hcc, with framing error.
	#8800 RxD=0;
	#8800 RxD=0;
	#8800 RxD=1;
	#8800 RxD=1;
	#8800 RxD=0;
	#8800 RxD=0;
	#8800 RxD=1;
	#8800 RxD=1;
	#8800 RxD=0;//parity bit
	#8800 RxD=0;//stop bit
 	
end

endmodule
`timescale 1ns / 1ps

module baud_controller_tb;

reg reset, clk;
reg [2:0] baud_select;
wire sample_ENABLE;

baud_controller baud_controller_u(.reset(reset), .clk(clk), .baud_select(baud_select), .sample_ENABLE(sample_ENABLE));


initial begin
	clk = 0;
	forever #5 clk = ~clk;
end

/*Checks for 4 values of baud_select*/
initial begin
	reset = 1;
	baud_select = 3'b111;
	#100 reset = 0;
	#100 baud_select = 3'b111;
	#100 reset = 1'b1;
	#100 reset = 1'b0;
	#1000 baud_select = 3'b110;
	#100 reset = 1'b1;
	#100 reset = 1'b0;
	#10000 baud_select = 3'b101;
	#100 reset = 1'b1;
	#100 reset = 1'b0;
	#100000 baud_select = 3'b100;
end

endmodule
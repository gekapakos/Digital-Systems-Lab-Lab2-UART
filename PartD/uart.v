`timescale 1ns / 1ps

module uart(reset, clk, Tx_DATA, baud_select, Rx_EN, Tx_WR, Tx_EN, Rx_DATA, Rx_FERROR, Rx_PERROR, Rx_VALID, Tx_BUSY);

input reset, clk, Tx_EN, Tx_WR, Rx_EN;
input [2:0] baud_select;
input [7:0] Tx_DATA;
output [7:0] Rx_DATA;
output Rx_FERROR, Rx_PERROR, Rx_VALID, Tx_BUSY;
wire TxD, RxD;

assign RxD = TxD;

uart_transmitter uart_transmitter_inst(.reset(reset), .clk(clk), .Tx_DATA(Tx_DATA), .baud_select(baud_select), .Tx_WR(Tx_WR), .Tx_EN(Tx_EN), .TxD(TxD), .Tx_BUSY(Tx_BUSY));
uart_receiver uart_receiver_inst(.reset(reset), .clk(clk), .Rx_DATA(Rx_DATA), .baud_select(baud_select), .Rx_EN(Rx_EN), .RxD(RxD), .Rx_FERROR(Rx_FERROR), .Rx_PERROR(Rx_PERROR), .Rx_VALID(Rx_VALID));

endmodule
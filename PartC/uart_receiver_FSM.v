`timescale 1ns / 1ps

module uart_receiver_FSM(reset, clk, Rx_DATA, Rx_EN, RxD, Rx_sample_ENABLE, Rx_FERROR, Rx_PERROR, Rx_VALID);
input reset, clk;
input Rx_EN;
input RxD;
input Rx_sample_ENABLE;
output [7:0] Rx_DATA;
output Rx_FERROR; // Framing Error //
output Rx_PERROR; // Parity Error //
output Rx_VALID; // Rx_DATA is Valid //

wire [7:0] Rx_DATA;
wire Rx_PERROR, Rx_FERROR, Rx_VALID;
reg Rx_PERROR_reg, Rx_PERROR_reg_next, Rx_FERROR_reg, Rx_FERROR_reg_next;
reg [2:0] decision, decision_next;//decision stands for state and decision_next for next_state
reg [3:0] count_n, count_s, count_n_next, count_s_next;
reg [7:0] buffer, buffer_next;
reg add, add_next;//used to check if the parity bit is being transmitted correctly
reg flag;//used to assign the value to Rx_DATA only when it is valid
reg [7:0] Rx_DATA_reg;

/*Declare the states in the fsm*/
parameter 	idle = 0,
			start = 1,
			trans = 2,
			parity = 3,
			stop = 4;


/*Sequential logic*/
always@ (posedge clk or posedge reset) begin
	if(reset) begin
		decision <= idle;
		count_n <= 4'b0000;
		count_s <= 4'b0000;
		buffer <= 8'b00000000;
		add <= 1'b0;
		Rx_PERROR_reg <= 1'b0;
		Rx_FERROR_reg <= 1'b0;
	end
	else begin
		decision <= decision_next;
		count_n <= count_n_next;
		count_s <= count_s_next;
		buffer <= buffer_next;
		add <= add_next;
		Rx_FERROR_reg <= Rx_FERROR_reg_next;
		Rx_PERROR_reg <= Rx_PERROR_reg_next;
	end
end

/*Combinational logic*/
always@ (RxD or Rx_EN or decision or Rx_sample_ENABLE or count_s or count_n or buffer or add or Rx_FERROR_reg or Rx_PERROR_reg) begin
	Rx_PERROR_reg_next = Rx_PERROR_reg;
	Rx_FERROR_reg_next = Rx_FERROR_reg;
	decision_next = decision;
	count_n_next = count_n;
	count_s_next = count_s;
	buffer_next = buffer;
	add_next = add;
	flag = 0;
	if(Rx_EN) begin
		case(decision)
		idle: begin
				if(~RxD) begin
					count_s_next = 0;
					buffer_next = 0;
					decision_next = start;
					Rx_FERROR_reg_next = 1'b0;
					Rx_PERROR_reg_next = 1'b0;
				end
				else begin
					decision_next = idle;
					buffer_next = 0;
					Rx_FERROR_reg_next = 1'b0;
					Rx_PERROR_reg_next = 1'b0;
				end
			  end
		start: begin
				   if(Rx_sample_ENABLE) begin
					   if(count_s == 7) begin
						   add_next = RxD;
						   count_s_next = 0;
						   count_n_next = 0;
						   decision_next = trans;
						   if(~RxD) begin
							   Rx_FERROR_reg_next = 1'b0;
							   Rx_PERROR_reg_next = 1'b0;
						   end
						   else begin
							   Rx_FERROR_reg_next = 1'b1;
							   Rx_PERROR_reg_next = 1'b0;
						   end
					   end
					   else begin
						   count_s_next = count_s + 1;
					   end
				   end
				   else begin
					   decision_next = start;
					   Rx_FERROR_reg_next = 1'b0;
					   Rx_PERROR_reg_next = 1'b0;
				   end
			   end
		trans: begin
				   if(Rx_sample_ENABLE) begin
					   if(count_s == 15) begin
						   if(Rx_FERROR_reg) begin
							   Rx_FERROR_reg_next = 1'b1;
							   Rx_PERROR_reg_next = 1'b0;
						   end
						   else begin
							   Rx_FERROR_reg_next = 1'b0;
							   Rx_PERROR_reg_next = 1'b0;
						   end
						   add_next = add + RxD;
						   count_s_next = 0;
						   buffer_next = {RxD, buffer[7:1]};
						   if(count_n == 7)
							   decision_next = parity;
						   else 
							   count_n_next = count_n + 1;
					   end
					   else
						   count_s_next = count_s + 1;
				   end
				   else begin
					   decision_next = trans;
				   end
			   end
		parity: begin
					if(Rx_sample_ENABLE) begin
						if(count_s == 15) begin
							count_s_next = 4'b0000;
							if(Rx_FERROR_reg)
								Rx_FERROR_reg_next = 1'b1;
							else
								Rx_FERROR_reg_next = 1'b0;
							if(RxD != add) begin
								Rx_PERROR_reg_next = 1'b1;
							end
							else begin
								Rx_PERROR_reg_next = 1'b0;
							end
							decision_next = stop;
						end
						else
							count_s_next = count_s + 4'b0001;
					end
					else begin
						decision_next = parity;
					end
				end
		stop: begin
				  if(Rx_sample_ENABLE) begin
					  if(count_s == 15) begin
						if(Rx_PERROR_reg) begin
							Rx_PERROR_reg_next = 1'b1;
						end
						else if(Rx_FERROR_reg) begin
							Rx_FERROR_reg_next = 1'b1;
						end
						else if((RxD)) begin
							flag = 1;
							Rx_FERROR_reg_next = 1'b0;
							Rx_PERROR_reg_next = 1'b0;
						end
						else begin
							Rx_FERROR_reg_next = 1'b1;
						end
							decision_next = idle;
					  end
					  else
						  count_s_next = count_s + 1;
				  end
				  else
					  decision_next = stop;
			  end
		default: decision_next = idle;
	endcase
    end
end

assign Rx_FERROR = Rx_FERROR_reg;
assign Rx_PERROR = Rx_PERROR_reg;

/*Checks if there are errors and then assigns the right value to Rx_VALID,for 1 clock cycle*/
assign Rx_VALID = flag;

/*Checks if the data that were received are valid and then stores them inside Rx_DATA*/
always@ (Rx_VALID or buffer) begin
	if(Rx_VALID) begin
		Rx_DATA_reg = buffer;
	end
	else
	   Rx_DATA_reg = 0;
end

assign Rx_DATA = Rx_DATA_reg;

endmodule

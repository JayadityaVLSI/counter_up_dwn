module dut_counter_up_dwn(
	input clk,
	input rstn,
	input up_dwn,
	output reg [3:0] count_out
);

	always@(posedge clk) begin
		if(!rstn)
			count_out <= 0;
		else if(up_dwn)			//Count Up
			count_out <= count_out + 1;
		else if(!up_dwn)		//Count Down
			count_out <= count_out - 1;
	end
endmodule

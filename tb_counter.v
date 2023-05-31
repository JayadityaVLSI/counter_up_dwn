module testbench_4bit_counter;

	reg clk;
	reg rstn;
	reg up_dwn;
	wire [3:0] count_out;
	integer error_count;

	dut_counter_up_dwn dut_counter_up_dwn_inst(
		.clk(clk),
		.rstn(rstn),
		.up_dwn(up_dwn),
		.count_out(count_out)
);
		
	always #5 clk = ~clk;

	initial begin : test_stimulus
                error_count = 0;
                clk = 0;
                $monitor("[%0tns] clk=%0b rstn=%0b count_out=0x%0h up_dwn=%0b",$time, clk, rstn, count_out, up_dwn);
		test1();
		test2();
		test3();
                repeat(3)
			test4();
 		$finish();
	end
	
	//TEST1 : Check whether counter reset to 0x0 on reset assertion, Max
	//count is reached after 16 clock cycles and counter rolls over to 0x0
	//in next cycle (UP_COUNTER)
	task test1;
		@(posedge clk);
		rstn <= 0;
		up_dwn <= 1;
		@(posedge clk);
		@(posedge clk);
		rstn <= 1;
		repeat(16) begin
			@(posedge clk);
		end
		
		if(count_out != 4'hf) begin
			$display("[%0tns] Error: Max count check: Expected count_out to be \
                                  0xf but found 0x%0h", $time, count_out);
			error_count = error_count + 1;
		end
  		@(posedge clk);
		if(count_out != 4'h0) begin
			$display("[%0tns] Error: Roll over check: Expected count_out to be \
                                  0x0 but found 0x%0h", $time, count_out);
			error_count = error_count + 1; 
		end
		
		error_check(error_count, "TEST_1");
	endtask

	//TEST2: Reset assertion in middle of count (UP COUNTER)
	task test2;
		@(posedge clk);
		rstn <= 0;
		@(posedge clk);
		@(posedge clk);
		rstn <= 1;
		repeat(10) begin
			@(posedge clk);
		end
		rstn <= 0;
		@(posedge clk);
		@(posedge clk);
		if(count_out != 4'h0) begin
			$display("[%0tns] Error: Reset assertion check: Expected count_out to be \
                                  0x0 but found 0x%0h", $time, count_out);
			error_count = error_count + 1; 
		end
		
		error_check(error_count, "TEST_2");
	
        endtask
	
	//TEST3: DOWN COUNTER After reset assertion and deassertion, counter down counts from
	//0xFh to 0x0 and rolls over to 0xFh 
	task test3;
		@(posedge clk);
		rstn <= 0;
		up_dwn <= 0;
		@(posedge clk);
		@(posedge clk);
		rstn <= 1;
		@(posedge clk);
		repeat(16) begin
			@(posedge clk);
		end
		
		if(count_out != 4'h0) begin
			$display("[%0tns] Error: Count check: Expected count_out to be \
                                  0x0 but found 0x%0h", $time, count_out);
			error_count = error_count + 1;
		end
  		@(posedge clk);
		if(count_out != 4'hf) begin
			$display("[%0tns] Error: Roll over check: Expected count_out to be \
                                  0xf but found 0x%0h", $time, count_out);
			error_count = error_count + 1; 
		end
		
		error_check(error_count, "TEST_3");
	endtask
	//TEST4: Dynamically changing up and down counting
	task test4;
		//Count up after initial reset assertion and deassertion
		integer incr_value;
		reg [3:0] current_count;
                incr_value = $urandom_range(1,15);
                $display("Incr_value: %0d",incr_value);
		@(posedge clk);
		rstn <= 0;
		up_dwn <= 1;
		@(posedge clk);
		@(posedge clk);
		rstn <= 1;
		@(posedge clk);
		repeat(incr_value) begin
			@(posedge clk);
		end
		
		if(count_out != incr_value) begin
			$display("[%0tns] Error: Count check: Expected count_out to be \
                                  0x%0h but found 0x%0h", $time, incr_value, count_out);
			error_count = error_count + 1;
		end
		
		current_count = count_out;
		up_dwn = 0;
		repeat(incr_value) begin
			@(posedge clk);
		end

		if(count_out != (current_count - incr_value)) begin
			$display("[%0tns] Error: Count check: Expected count_out to be \
                                  0x%0h but found 0x%0h", $time, (current_count - incr_value), count_out);
			error_count = error_count + 1; 
		end
		
		error_check(error_count, "TEST_4");
	endtask
	
	task error_check(input integer error_count, input [8*7:1] testnum);
		
		if(error_count == 0)
			$display("%s PASSED", testnum);
		else
			$display("%s FAILED", testnum);		
	endtask 



endmodule

module top ();
	bit clk;
	initial begin
		clk=0;
		forever begin
			#1 clk=~clk;
		end
	end
	fifo_If FIFO_if(clk);
	FIFO DUT(FIFO_if);
	FIFO_TB TEST(FIFO_if);
	monitor MONITOR(FIFO_if);
endmodule : top
import  fifo_tr_pkg ::*;
import  shared_pkg ::*;

module FIFO_TB(fifo_If.TEST FIFO_if);
	FIFO_transiction F_tra=new();
	
	initial begin
		FIFO_if.rd_en=0;
		FIFO_if.wr_en=0;
		reset;
		repeat(8)begin
		FIFO_if.wr_en=1;//write only
		FIFO_if.rd_en=0;
			assert(F_tra.randomize());
			FIFO_if.data_in=F_tra.data_in;
			@(negedge  FIFO_if.clk);
		end

		
		repeat(8)begin
		FIFO_if.wr_en=0;//read only
		FIFO_if.rd_en=1;
			@(negedge  FIFO_if.clk);
		end
		/// try to write and read when fifo is empty write only
		
		repeat(8)begin
		FIFO_if.wr_en=1;
		FIFO_if.rd_en=1;
			assert(F_tra.randomize());
			FIFO_if.data_in=F_tra.data_in;
			@(negedge  FIFO_if.clk);
		end
		reset;
		repeat(8)begin
		FIFO_if.wr_en=1;
		FIFO_if.rd_en=0;
			assert(F_tra.randomize());
			FIFO_if.data_in=F_tra.data_in;
			@(negedge  FIFO_if.clk);
		end
		// fifo is full and write and read is high
		
		repeat(10)begin
		FIFO_if.wr_en=1;
		FIFO_if.rd_en=1;
			assert(F_tra.randomize());
			FIFO_if.data_in=F_tra.data_in;
			@(negedge  FIFO_if.clk);
		end
		reset;
		repeat(4)begin
		FIFO_if.wr_en=1;
		FIFO_if.rd_en=0;
			assert(F_tra.randomize());
			FIFO_if.data_in=F_tra.data_in;
			@(negedge  FIFO_if.clk);
		end
		// fifo is half full and write and read is high
		repeat(8)begin
		FIFO_if.wr_en=1;
		FIFO_if.rd_en=1;
			assert(F_tra.randomize());
			FIFO_if.data_in=F_tra.data_in;
			@(negedge  FIFO_if.clk);
		end
		repeat(1000)begin
			assert(F_tra.randomize());
			FIFO_if.rst_n=F_tra.rst_n;
			FIFO_if.data_in=F_tra.data_in;
			FIFO_if.wr_en=F_tra.wr_en;
			FIFO_if.rd_en=F_tra.rd_en;
			@(negedge  FIFO_if.clk);
		end

		test_finished=1;
		$display("Test:",test_finished);
	end
 	task reset;
 		FIFO_if.rst_n=0;
 		@(negedge  FIFO_if.clk);
 		FIFO_if.rst_n=1;
 	endtask : reset

endmodule
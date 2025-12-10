import fifo_tr_pkg::*;
import fifo_sco_pkg::*;
import fifo_func_pkg::*;
import shared_pkg ::*;
module monitor(fifo_If.monitor FIFO_if);
	FIFO_transiction F_tra=new();
	FIFO_coverage F_cov=new();
	FIFO_scoreboard F_sco=new();
initial begin
	forever begin
		@(negedge FIFO_if.clk);
		F_tra.data_in=FIFO_if.data_in;
		F_tra.data_out=FIFO_if.data_out;
		F_tra.wr_en=FIFO_if.wr_en;
		F_tra.wr_ack=FIFO_if.wr_ack;
		F_tra.rd_en=FIFO_if.rd_en;
		F_tra.full=FIFO_if.full;
		F_tra.almostempty=FIFO_if.almostempty;
		F_tra.almostfull=FIFO_if.almostfull;
		F_tra.underflow=FIFO_if.underflow;
		F_tra.overflow=FIFO_if.overflow;
		F_tra.rst_n=FIFO_if.rst_n;
		F_tra.empty=FIFO_if.empty;
		fork
			begin
			 	F_cov.sample_data(F_tra);
			end
			begin
				#0 F_sco.check_data(F_tra);
			end
		join

		if (test_finished==1) begin
			$display("Test finished=%0d with Correct_counter=%0d and errors=%0d.",test_finished,Correct_counter, error_counter);
			$stop;
		end
	end
end


endmodule
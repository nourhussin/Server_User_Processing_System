
module FIFO(fifo_If.DUT FIFO_if);

localparam max_fifo_addr = $clog2(FIFO_if.FIFO_DEPTH);

reg [FIFO_if.FIFO_WIDTH-1:0] mem [FIFO_if.FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge FIFO_if.clk or negedge FIFO_if.rst_n) begin
	if (!FIFO_if.rst_n) begin
		wr_ptr <= 0;
		FIFO_if.wr_ack<=0;
		FIFO_if.overflow <= 0;
	end
	else if (FIFO_if.wr_en && count < FIFO_if.FIFO_DEPTH) begin
		mem[wr_ptr] <= FIFO_if.data_in;
		FIFO_if.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
	end
	else begin 
		FIFO_if.wr_ack <= 0; 
		if (FIFO_if.full && FIFO_if.wr_en)//first bug
			FIFO_if.overflow <= 1;
		else
			FIFO_if.overflow <= 0;
	end
end

always @(posedge FIFO_if.clk or negedge FIFO_if.rst_n) begin
	if (!FIFO_if.rst_n) begin
		rd_ptr <= 0;
		FIFO_if.underflow<=0;
	end
	else if (FIFO_if.rd_en && count != 0) begin
		FIFO_if.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end
	else begin
		if (FIFO_if.empty&&FIFO_if.rd_en) begin
			FIFO_if.underflow<=1;
		end
		else FIFO_if.underflow<=0;
	end
end

always @(posedge FIFO_if.clk or negedge FIFO_if.rst_n) begin
	if (!FIFO_if.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({FIFO_if.wr_en, FIFO_if.rd_en} == 2'b10) && !FIFO_if.full) 
			count <= count + 1;
		else if ( ({FIFO_if.wr_en, FIFO_if.rd_en} == 2'b01) && !FIFO_if.empty)
			count <= count - 1;
		else if ( ({FIFO_if.wr_en, FIFO_if.rd_en} == 2'b11) &&!FIFO_if.full&& !FIFO_if.empty)
			count <= count ;
		else if ( ({FIFO_if.wr_en, FIFO_if.rd_en} == 2'b11) && FIFO_if.full&& !FIFO_if.empty)
			count <= count-1 ;
		else if ( ({FIFO_if.wr_en, FIFO_if.rd_en} == 2'b11) &&!FIFO_if.full&& FIFO_if.empty)
			count <= count+1 ;			
	end
end

assign FIFO_if.full = (count == FIFO_if.FIFO_DEPTH)? 1 : 0;
assign FIFO_if.empty = (count == 0)? 1 : 0;
//assign FIFO_if.underflow = (FIFO_if.empty && FIFO_if.rd_en)? 1 : 0; // sequtential 
assign FIFO_if.almostfull = (count == FIFO_if.FIFO_DEPTH-1)? 1 : 0; // edit it by 1 and the past value was 2
assign FIFO_if.almostempty = (count == 1)? 1 : 0;
////////////////// Assertion //////////////////
////////////////// immediate assertion for reset ////////////////// 
`ifdef SIM
always_comb begin
	if (!FIFO_if.rst_n) begin
		reset:assert  final (FIFO_if.empty==1&&wr_ptr==0&&rd_ptr==0&&FIFO_if.full==0&&count==0);
		cov_reset:cover  final (FIFO_if.empty==1&&wr_ptr==0&&rd_ptr==0&&FIFO_if.full==0&&count==0);
	end
end
////////////////// immediate assertion for full //////////////////
always_comb begin
	if (count==FIFO_if.FIFO_DEPTH&&FIFO_if.rst_n) begin
		FULL:assert final (FIFO_if.full=='b1);
		cov_full:cover final (FIFO_if.full==1'b1);
	end
end
////////////////// immediate assertion for empty //////////////////
always_comb begin
	if (count==0&&FIFO_if.rst_n) begin
		EMPTY:assert final (FIFO_if.empty==1'b1);
		cov_empty:cover final (FIFO_if.empty==1'b1);
	end
end
////////////////// immediate assertion for Almost empty //////////////////
always_comb begin
	if (count==1&&FIFO_if.rst_n) begin
		ALMOST_EMPTY:assert final (FIFO_if.almostempty==1'b1);
		cov_al_emp:cover final (FIFO_if.almostempty==1'b1);
	end
end
////////////////// immediate assertion for almost full //////////////////
always_comb begin
	if (count==FIFO_if.FIFO_DEPTH-1&&FIFO_if.rst_n) begin
		ALMOST_FULL:assert final (FIFO_if.almostfull==1'b1);
		cov_AL_full:cover final (FIFO_if.almostfull==1'b1);
	end
end
////////////////// Concurrent assertion for overflow //////////////////
property Over_flow;
 @(posedge  FIFO_if.clk) disable iff (!FIFO_if.rst_n) (FIFO_if.full && FIFO_if.wr_en) |=> FIFO_if.overflow==1;
endproperty 
	over_FLOW:assert property(Over_flow) else $display("%t:Fail",$time);
	cov_over_flow:cover property(Over_flow);
////////////////// Concurrent assertion for underflow //////////////////
property UNDER_FLOW;
	@(posedge  FIFO_if.clk) disable iff (!FIFO_if.rst_n) (FIFO_if.empty&&FIFO_if.rd_en) |=> FIFO_if.underflow==1;
endproperty
	under_FLOW:assert property(UNDER_FLOW) else $display("%t:Fail",$time);
	cov_under_flow:cover property(UNDER_FLOW);
	////////////////// Concurrent assertion for FUll with wr_en  //////////////////
	property Full_wr_en;
		@(posedge FIFO_if.clk) disable iff (!FIFO_if.rst_n) (FIFO_if.full&&FIFO_if.wr_en&&!FIFO_if.rd_en)|=> $stable(wr_ptr);
	endproperty
	FULL_WR_EN:assert property(Full_wr_en) else $display("%t:Fail",$time);
	cov_full_wr_en:cover property(Full_wr_en);
	////////////////// Concurrent assertion for empty with rd_en //////////////////
	property Full_rd_en;
		@(posedge FIFO_if.clk) disable iff (!FIFO_if.rst_n) (FIFO_if.empty&&!FIFO_if.wr_en&&FIFO_if.rd_en)|=> $stable(rd_ptr);
	endproperty
	FULL_RD_EN:assert property(Full_rd_en) else $display("%t:Fail",$time);
	cov_full_rd_en:cover property(Full_rd_en);
	////////////////// concurrent assertion  Warning when fifo is full and try  writing in it //////////////////
	property warning_Full;
		@(posedge FIFO_if.clk) disable iff (!FIFO_if.rst_n) FIFO_if.full |-> !FIFO_if.wr_en ; 
	endproperty
	warning_FULL:assert property(warning_Full) else $display("%t:Warning try to write in full fifo",$time);
	cov_warning_full:cover property(warning_Full);
	////////////////// concurrent assertion  Warning when fifo is empty and try to  read from it //////////////////
	property warning_empty;
		@(posedge FIFO_if.clk) disable iff (!FIFO_if.rst_n) FIFO_if.empty |-> !FIFO_if.rd_en ; 
	endproperty
	warning_Empty:assert property(warning_empty) else $display("%t:Warning try to read from empty fifo",$time);
	cov_warning_Empty:cover property(warning_empty);
	////////////////// concurrent assertion for wr_ack //////////////////
	property wr_ACk;
		@(posedge  FIFO_if.clk) disable iff (!FIFO_if.rst_n) FIFO_if.wr_en&&!FIFO_if.full|=> FIFO_if.wr_ack;
	endproperty	
	wr_ACK:assert property(wr_ACk) else $display("%t:Warning try to read from empty fifo",$time);
	cov_wr_ack:cover property(wr_ACk);
	////////////////// concurrent assertion for count_full //////////////////
	property count_full;
		@(posedge  FIFO_if.clk) disable iff (!FIFO_if.rst_n) FIFO_if.full  |-> count==FIFO_if.FIFO_DEPTH ;
	endproperty
	count_FULL:assert property(count_full) else $display("%t:Warning try to read from empty fifo",$time);
	cov_count_full:cover property(count_full);
	////////////////// concurrent assertion for count_empty //////////////////
	property count_empty;
		@(posedge  FIFO_if.clk) disable iff (!FIFO_if.rst_n) FIFO_if.empty  |-> count==0 ;
	endproperty
	count_EMPTY:assert property(count_empty) else $display("%t:Warning try to read from empty fifo",$time);
	cov_count_empty:cover property(count_empty);
	////////////////// concurrent assertion for count_Almost_empty //////////////////
	property count_Almost_empty;
		@(posedge  FIFO_if.clk) disable iff (!FIFO_if.rst_n) FIFO_if.almostempty  |-> count==1 ;
	endproperty
	count_ALMOST_EMPTY:assert property(count_Almost_empty) else $display("%t:Warning try to read from empty fifo",$time);
	cov_count_almost_empty:cover property(count_Almost_empty);
		////////////////// concurrent assertion for count_almpst_full //////////////////
	property count_almpst_full;
		@(posedge  FIFO_if.clk) disable iff (!FIFO_if.rst_n) FIFO_if.almostfull  |-> count==7 ;
	endproperty
	count_ALmpst_full:assert property(count_almpst_full) else $display("%t:Warning try to read from empty fifo",$time);
	count_almpst_Full:cover property(count_almpst_full);
	
`endif
endmodule
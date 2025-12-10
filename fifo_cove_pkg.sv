package fifo_func_pkg;
import fifo_tr_pkg :: *;
  class FIFO_coverage;
    FIFO_transiction F_cvg_txn=new();
    covergroup cg;
    wr_en_cob:coverpoint F_cvg_txn.wr_en;
    rd_en_cob:coverpoint F_cvg_txn.rd_en;
    wr_ack_cov:coverpoint F_cvg_txn.wr_ack;
    underflow_cov:coverpoint F_cvg_txn.underflow;
    overflow_cov:coverpoint F_cvg_txn.overflow;
    coverpoint F_cvg_txn.almostempty;
    coverpoint F_cvg_txn.almostfull;
    full_cov:coverpoint F_cvg_txn.full;
    coverpoint F_cvg_txn.empty;
wr_ACK:
          cross wr_en_cob,rd_en_cob,wr_ack_cov{
                ignore_bins wr_ack_cant=binsof(wr_en_cob) intersect {0} && binsof(rd_en_cob) intersect{1} && binsof(wr_ack_cov) intersect {1};
                ignore_bins wr_ack0=binsof(wr_en_cob) intersect {0} && binsof(rd_en_cob) intersect{0} && binsof(wr_ack_cov) intersect {1};
        }
UnderFlow:
        cross wr_en_cob,rd_en_cob,underflow_cov
        {
                ignore_bins under_flow_cant = binsof(wr_en_cob) intersect {0} && binsof(rd_en_cob) intersect{0} && binsof(underflow_cov) intersect {1};
                ignore_bins under_flow_wr_en = binsof(wr_en_cob) intersect {1} && binsof(rd_en_cob) intersect{0} && binsof(underflow_cov) intersect {1};
        }
OverFlow:
        cross wr_en_cob,rd_en_cob,overflow_cov
        {
                ignore_bins overflow_cant = binsof(wr_en_cob) intersect {0} && binsof(rd_en_cob) intersect{1} && binsof(overflow_cov) intersect {1};
                ignore_bins overflow_rd_en = binsof(wr_en_cob) intersect {0} && binsof(rd_en_cob) intersect{0} && binsof(overflow_cov) intersect {1};
        }
AlmostEmpty:
        cross F_cvg_txn.wr_en,F_cvg_txn.rd_en,F_cvg_txn.almostempty;
AlmostFull:
        cross F_cvg_txn.wr_en,F_cvg_txn.rd_en,F_cvg_txn.almostfull;
Full:
        cross wr_en_cob,rd_en_cob,full_cov
        {
                ignore_bins full1 = binsof(wr_en_cob) intersect {0} && binsof(rd_en_cob) intersect{1} && binsof(full_cov) intersect {1};
                ignore_bins f1ull2 = binsof(wr_en_cob) intersect {1} && binsof(rd_en_cob) intersect{1} && binsof(full_cov) intersect {1};
                
        }
Empty:
        cross F_cvg_txn.wr_en,F_cvg_txn.rd_en,F_cvg_txn.empty;
   
    endgroup :cg
      
      function  new();
        cg=new();
      endfunction
      function void sample_data(input FIFO_transiction F_txn);
	  		F_cvg_txn=F_txn;
			cg.sample();
      endfunction : sample_data
    endclass :FIFO_coverage
    endpackage :fifo_func_pkg

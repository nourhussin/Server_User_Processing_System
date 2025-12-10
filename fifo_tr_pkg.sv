package fifo_tr_pkg;
  parameter FIFO_WIDTH = 16;
  class FIFO_transiction;
    rand bit [FIFO_WIDTH-1:0] data_in;
    rand bit rst_n, wr_en, rd_en;
    logic [FIFO_WIDTH-1:0] data_out;
    logic wr_ack, overflow;
    logic full, empty, almostfull, almostempty, underflow;
    integer RD_EN_ON_DIST,WR_EN_ON_DIST;
    function new(integer RD_EN_ON_DIST=30,integer WR_EN_ON_DIST=70);
      this.RD_EN_ON_DIST=RD_EN_ON_DIST;
      this.WR_EN_ON_DIST=WR_EN_ON_DIST;
    endfunction
    constraint reset {
                 rst_n dist {0:=2,1:=98};
               }
               constraint write_enable {
                 wr_en dist {1:=WR_EN_ON_DIST,0:=100-WR_EN_ON_DIST};
               }
               constraint read_enable {
                 rd_en dist {1:=RD_EN_ON_DIST,0:=100-RD_EN_ON_DIST};
               }
             endclass :FIFO_transiction
           endpackage :fifo_tr_pkg

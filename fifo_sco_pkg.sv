package fifo_sco_pkg;
import shared_pkg :: *;
import fifo_tr_pkg :: *;

  parameter FIFO_WIDTH = 16;
  class FIFO_scoreboard;
    logic [FIFO_WIDTH-1:0] data_out_ref=0;
    logic [FIFO_WIDTH-1:0] lasr_data_out_ref=0;
    //logic [FIFO_WIDTH-1:0] Que_fif[$];
    reg [3:0]count=0;
    reg [2:0]rd_ptr=0,wr_ptr=0;
    reg [15:0]mem[7:0];
    logic wr_ack_ref, overflow_ref;
    logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;
    function void reference_model(input FIFO_transiction F_txn_R);
    
    //data_out_ref=lasr_data_out_ref;
    wr_ack_ref = 0;
    overflow_ref = 0;
    underflow_ref = 0;
    full_ref = (count==8)?1:0;
    empty_ref = (count == 0)?1:0;
    almostfull_ref = (count == 7)?1:0;  // Assuming almost full when 6 out of 8 are filled
    almostempty_ref = (count == 1)?1:0; // Assuming almost empty when 1 out of 8 is filled
    
    if (!F_txn_R.rst_n) begin
      count=0;
      wr_ptr=0;
      rd_ptr=0;
    end
    ////////////////////// write only ////////////////////// 
    else if (F_txn_R.wr_en&&count<8&&!F_txn_R.rd_en&&F_txn_R.rst_n)begin
      mem[wr_ptr]=F_txn_R.data_in;
       wr_ack_ref=1;
       wr_ptr++;
       count++;
      end
    ////////////////////// Read only //////////////////////  
    else if (F_txn_R.rd_en&&count>0&&!F_txn_R.wr_en&&F_txn_R.rst_n) begin
        data_out_ref=mem[rd_ptr];
        rd_ptr++;
        count--;
        //lasr_data_out_ref=data_out_ref;
    end
    ////////////////////// read when fifo is full and wr_en and rd_en is enable ////////////////////// 
    else if (F_txn_R.rd_en && F_txn_R.wr_en && full_ref && !empty_ref && F_txn_R.rst_n) begin
        data_out_ref=mem[rd_ptr];
        rd_ptr++;
        count--;
        //lasr_data_out_ref=data_out_ref;
    end
    ////////////////////// Write operation only when fifo is empty //////////////////////
    else if (F_txn_R.rd_en&&F_txn_R.wr_en&&empty_ref&&!full_ref&&F_txn_R.rst_n) begin
      /* code */
     mem[wr_ptr]=F_txn_R.data_in;
     wr_ptr++;
     count++;
    end
    ////////////////////// write and read when fifo isn't full or empty ////////////////////// 
    else if (F_txn_R.rd_en && F_txn_R.wr_en && !full_ref && !empty_ref && F_txn_R.rst_n) begin
      mem[wr_ptr]=F_txn_R.data_in;
      data_out_ref=mem[rd_ptr];
      //lasr_data_out_ref=data_out_ref;
      rd_ptr++;
      wr_ptr++;
    end
    // if (!F_txn_R.rst_n) begin
    //   /* code */
    //     count=0;
    //     rd_ptr=0;
    //     wr_ptr=0;
    // end
    // else if  ( ({F_txn_R.wr_en, F_txn_R.rd_en} == 2'b10) && !full_ref) 
    //     count++;
    // else if ( ({F_txn_R.wr_en, F_txn_R.rd_en} == 2'b01) && !empty_ref)
    //     count --;
    endfunction

    function void check_data(input FIFO_transiction F_txn);
      reference_model(F_txn);
        if (F_txn.data_out!==data_out_ref) begin
          $display("%t:Error:Mismatch data_out_ref=%h data_out=%h   ",$time,data_out_ref,F_txn.data_out);
          error_counter++;
        end   
        else Correct_counter++;
    endfunction //new()
  endclass //FIFO_scoreboard


//||wr_ack_ref!==F_txn.wr_ack||underflow_ref!==F_txn.underflow||almostempty_ref!==F_txn.almostempty||empty_ref!==F_txn.empty||full_ref!==F_txn.full||overflow_ref!==F_txn.overflow
//wr_ack_ref=%b F_txn.wr_ack=%b underflow_ref=%b F_txn.underflow=%b almostempty_ref=%b F_txn.almostempty=%b empty_ref=%b F_txn.empty=%b full_ref=%b F_txn.full=%b overflow_ref=%b F_txn.overflow=%b
//,wr_ack_ref,F_txn.wr_ack,underflow_ref,F_txn.underflow,almostempty_ref,F_txn.almostempty,empty_ref,F_txn.empty,full_ref,F_txn.full,overflow_ref,F_txn.overflow
  // function void reference_model(input FIFO_transiction F_txn_m);
    
  // endfunction 

endpackage
 // data_out_ref=lasr_data_out_ref;
 //    wr_ack_ref = 0;
 //    overflow_ref = 0;
 //    underflow_ref = 0;
 //    full_ref = (count==8)?1:0;
 //    empty_ref = (count == 0)?1:0;
 //    almostfull_ref = (count == 7)?1:0;  // Assuming almost full when 6 out of 8 are filled
 //    almostempty_ref = (count == 1)?1:0; // Assuming almost empty when 1 out of 8 is filled
 //    if (F_txn_R.wr_en&&count<8&&!F_txn_R.rd_en&&F_txn_R.rst_n)begin
 //        Que_fif.push_back(F_txn_R.data_in);
 //        wr_ack_ref=1;

 //    end   
 //    else if (F_txn_R.rd_en&&count>0&&!F_txn_R.wr_en&&F_txn_R.rst_n) begin
 //        data_out_ref=Que_fif.pop_front();
 //        lasr_data_out_ref=data_out_ref;
 //    end

 //    else if (F_txn_R.rd_en&&F_txn_R.wr_en&&empty_ref==1&&F_txn_R.rst_n) begin
 //      /* code */
 //      Que_fif.push_back(F_txn_R.data_in);
 //      data_out_ref=lasr_data_out_ref;
 //    end
 //      else if (F_txn_R.rd_en && F_txn_R.wr_en && full_ref && !empty_ref && F_txn_R.rst_n) begin
 //        // Pop oldest data and push new data (overwrite)
 //        data_out_ref = Que_fif.pop_front();  // Pop oldest data
 //        lasr_data_out_ref = data_out_ref;
 //        Que_fif.push_back(F_txn_R.data_in);  // Push new data
 //    end
 //      else if (F_txn_R.rd_en && F_txn_R.wr_en && !full_ref && !empty_ref && F_txn_R.rst_n) begin
 //        Que_fif.push_back(F_txn_R.data_in);
 //        data_out_ref = Que_fif.pop_front();
 //        lasr_data_out_ref = data_out_ref;
 //    end
 //    if (F_txn_R.rd_en&&empty_ref) begin
 //      /* code */
 //      underflow_ref=1;
 //    end
 //    if (F_txn_R.wr_en&&full_ref) begin
 //      /* code */
 //      overflow_ref=1;

 //    end   
 //    if (!F_txn_R.rst_n) begin
 //      /* code */
 //      count=0;
 //      Que_fif.delete();
 //    end
 //    else if  ( ({F_txn_R.wr_en, F_txn_R.rd_en} == 2'b10) && !full_ref) 
 //      count = count + 1;
 //    else if ( ({F_txn_R.wr_en, F_txn_R.rd_en} == 2'b01) && !empty_ref)
 //      count = count - 1;
 //      // data_out_ref=F_txn_R.data_out;
 //      // wr_ack_ref=F_txn_R.wr_en&&!F_txn_R.full;
 //      // underflow_ref=F_txn_R.rd_en&&F_txn_R.empty;
 //      // almostempty_ref=F_txn_R.almostempty;
 //      // empty_ref=F_txn_R.empty;
 //      // full_ref=F_txn_R.full;
 //      // overflow_ref=F_txn_R.full&&F_txn_R.wr_en;
 //      // almostfull_ref=F_txn_R.almostfull;
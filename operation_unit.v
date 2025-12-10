module operation_unit  (
    // Clock and Reset (Fast Clock Domain)
    input clk, rst_n,

    //from server
    input [1:0] op_code,
    input [7:0] data_in,
    input       op_start, //start processing on data

    //to server
    output reg  ack_toggle, 
    
    //to fifo 
    output reg [7:0] data_out,  
    output reg       data_valid      // Valid signal for FIFO    

);


reg operation_done;  

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
            ack_toggle <= 1'b0;
            data_out   <= 1'b0;
            data_valid <= 1'b0;
            operation_done <= 1'b0;
        end
    
    else begin
           data_valid <= 1'b0;
           ack_toggle <= 1'b0;
          if (op_start && !operation_done) begin
                case (op_code)
                    2'b00 : data_out <= data_in; //just restore
                    2'b01 : data_out <= {data_in [5:0], 2'b00};  //data_in << 2
                    2'b10 : data_out <= {data_in[1:0], data_in[7:2]};
                    2'b11 : data_out <= ~data_in;
                endcase

            
            data_valid     <= 1'b1;
            operation_done <= 1'b1;
            ack_toggle     <= ~ack_toggle;
    end
          else if (!op_start) begin
                operation_done <= 1'b0;   // Reset for next operation
            end
            
    end
    
    
    
end


    
endmodule
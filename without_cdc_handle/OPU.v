module OPU (
    input  wire       clk, rst_n,
    input  wire       op_start,
    input  wire [1:0] op_code,
    input  wire [7:0] data_in,
    output reg  [7:0] data_out,
    output reg        op_done
);

    always @(posedge clk) begin
        if (!rst_n) begin
            data_out <= 0;
            op_done  <= 0;
        end else begin
            op_done <= 0; // default

            if (op_start) begin
                case (op_code)
                    2'b00: data_out <= data_in;                       // restore
                    2'b01: data_out <= {data_in[5:0], 2'b00};         // <<2
                    2'b10: data_out <= {data_in[1:0], data_in[7:2]};  // rotate right
                    2'b11: data_out <= ~data_in;                      // invert
                endcase
                op_done <= 1;
            end
        end
    end

endmodule

`timescale 1ns/1ps

module Top_tb();

    reg u_clk, s_clk, op_clk, rst_n;

    reg load;
    reg [3:0] addr;
    reg [7:0] data_in;
    reg [6:0] ID;

    Top dut(
        .u_clk(u_clk),
        .s_clk(s_clk),
        .op_clk(op_clk),
        .rst_n(rst_n),

        .load(load),
        .addr(addr),
        .data_in(data_in),
        .ID(ID)
    );


    initial begin u_clk = 0; forever #20 u_clk = ~u_clk; end  // User clock = 25 MHz
    initial begin s_clk = 0; forever #12 s_clk = ~s_clk; end  // Server clock = 41.7 MHz
    initial begin op_clk = 0;forever #2 op_clk = ~op_clk; end  // OPU clock = 250 MHz 
    initial begin rst_n = 0; #50; rst_n = 1; end

    initial begin
        load_word(4'd2, 7'b1010001, 8'h11);
        load_word(4'd4, 7'b1110010, 8'h22);
        load_word(4'd9, 7'b1010100, 8'h33);
    end

    initial begin
        $dumpfile("top.vcd");
        $dumpvars(0, Top_tb);

        #2000;
        $finish;
    end

    task load_word(input [3:0] a, input [6:0] the_ID, input [7:0] data);
    begin
        @(negedge u_clk);
        load = 1;
        addr = a;
        ID = the_ID;
        data_in = data;
        @(negedge u_clk);
        load = 0;
    end
    endtask

endmodule

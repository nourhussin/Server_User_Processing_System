`timescale 1ns/1ps

module Top_tb();

    reg u_clk, s_clk, op_clk, rst_n;

    Top dut(
        .u_clk(u_clk),
        .s_clk(s_clk),
        .op_clk(op_clk),
        .rst_n(rst_n)
    );


    initial begin
        u_clk = 0;
        forever #20 u_clk = ~u_clk; // User clock = 25 MHz
    end

    initial begin
        s_clk = 0;
        forever #12 s_clk = ~s_clk; // Server clock = 41.7 MHz
    end

    initial begin
        op_clk = 0;
        forever #2 op_clk = ~op_clk;  // OPU clock = 250 MHz 
    end

    initial begin
        rst_n = 0;
        #50;
        rst_n = 1;
    end


    initial begin
        // NOTE: direct access for simulation only
        dut.user.RAM[0] = 16'b0_101_0001_10101010; // ID=5, op_code=0001, data=AA
        dut.user.RAM[1] = 16'b0_101_0100_00001111; // op_code=0100
        dut.user.RAM[2] = 16'b0_101_1000_11110000; // op_code=1000
        dut.user.RAM[3] = 16'b0_101_0010_01010101; // op_code=0010

        dut.user.addr = 0;  // start at address 0
    end

    initial begin
        $dumpfile("top.vcd");
        $dumpvars(0, Top_tb);

        #2000;  // run long enough for all frames
        $finish;
    end

endmodule

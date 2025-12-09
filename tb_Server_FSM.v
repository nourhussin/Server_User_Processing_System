module tb_Server_FSM();
    reg clk, rst_n;

    // User Interface
    reg start;
    reg [15:0] frame;
    wire auth_done;

    // OPU Interface
    wire [1:0] op_code;
    wire [7:0] data;
    wire op_start;
    reg  op_done;

    Server_FSM DUT (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .frame(frame),
        .auth_done(auth_done),
        .op_code(op_code),
        .data(data),
        .op_start(op_start),
        .op_done(op_done)
    );

    always #10 clk = ~clk;

    task send_frame(input [15:0] f);
    begin
        frame = f;
        start = 1;
        @(posedge clk);
        start = 0;
    end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        start = 0;
        frame = 0;
        op_done = 0;

        repeat(3) @(posedge clk);
        rst_n = 1;

        $display("---- TEST 1: VALID AUTH + Operation ----");

        // Frame format:
        // [15] processed_flag = 0
        // [14:12] = 3'b101 (valid)
        // [11:8] = hot-dot operation
        // [7:0] data

        // Example: valid frame → op = 4'b0010 → op_code=01
        send_frame(16'b0_101_0010_11001100);
        wait(auth_done == 1);
        $display("[Time %0t] AUTH DONE", $time);
        wait(op_start == 1);
        $display("[Time %0t] op_start asserted. op_code=%b, data=%h", $time, op_code, data);
        @(posedge clk);
        op_done = 1;
        @(posedge clk);
        op_done = 0;

        $display("---- TEST 1 COMPLETE ----\n");

        // -------------------------------------------------------------
        $display("---- TEST 2: INVALID AUTH (wrong prefix) ----");
        send_frame(16'b0_110_0001_01010101);
        repeat(5) @(posedge clk);
        if(auth_done == 0 && op_start == 0)
            $display("[PASS] Authentication Failed as Expected");
        else
            $display("[FAIL] Invalid frame was incorrectly accepted");

        // -------------------------------------------------------------
        $display("---- TEST 3: MULTIPLE HOT-DOT BITS → INVALID ----");
        send_frame(16'b0_101_0101_11110000);
        repeat(5) @(posedge clk);
        if(auth_done == 0)
            $display("[PASS] Rejected due to multiple hot-dot bits");
        else
            $display("[FAIL] Accepted invalid hot-dot frame");

        // -------------------------------------------------------------
        $display("---- TEST 4: Valid auth but no op_done ----");

        send_frame(16'b0_101_0001_00110011);
        wait(auth_done == 1);
        $display("[Time %0t] AUTH DONE", $time);
        wait(op_start == 1);
        $display("[Time %0t] Waiting for op_done (never sent)...", $time);
        repeat(10) @(posedge clk);
        if(DUT.current_state == 2'b11)
            $display("[PASS] FSM correctly stuck in OP state until op_done");
        else
            $display("[FAIL] FSM incorrectly exited OP state");
        $display("\n---- ALL TESTS COMPLETE ----");
        $stop;
    end
endmodule
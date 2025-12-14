module Top (
    input wire u_clk, s_clk, op_clk , rst_n,

    input wire load,
    input wire [3:0] addr,
    input wire [7:0] data_in,
    input wire [6:0] ID

);

    // USER ↔ SERVER wires
    wire        start;
    wire [15:0] frame;
    wire        auth_done;
    //wire        auth_fail;

    // SERVER ↔ OPU wires
    wire        op_start;
    wire [1:0]  op_code;
    wire [7:0]  data_to_op;
    wire [7:0]  op_result;
    wire        op_done;

    // Sync Wires
    wire sync_start, 
         sync_auth_done, 
         sync_auth_fail, 
         sync_op_start, 
         sync_op_done,
         sync_op_done_user;

    // User Server CDC
    slow_to_fast_pulse_sync sf_sync1(
        .slow_clk(u_clk),
        .fast_clk(s_clk),
        .rst_n(rst_n),
        .pulse_slow_in(start),
        .pulse_fast_out(sync_start)
    );
    fast_to_slow_pulse_sync fs_sync1(
        .fast_clk(s_clk),
        .slow_clk(u_clk),
        .rst_n(rst_n),
        .pulse_fast_in(auth_done),
        .pulse_slow_out(sync_auth_done)
    );
    fast_to_slow_pulse_sync fs_sync2(
        .fast_clk(s_clk),
        .slow_clk(u_clk),
        .rst_n(rst_n),
        .pulse_fast_in(auth_fail),
        .pulse_slow_out(sync_auth_fail)
    );

    // Sever Op CDC
    slow_to_fast_pulse_sync sf_sync2(
        .slow_clk(s_clk),
        .fast_clk(op_clk),
        .rst_n(rst_n),
        .pulse_slow_in(op_start),
        .pulse_fast_out(sync_op_start)
    );
    fast_to_slow_pulse_sync fs_sync3(
        .fast_clk(op_clk),
        .slow_clk(s_clk),
        .rst_n(rst_n),
        .pulse_fast_in(op_done),
        .pulse_slow_out(sync_op_done)
    );

    // Op User CDC
    fast_to_slow_pulse_sync fs_sync4(
        .fast_clk(op_clk),
        .slow_clk(u_clk),
        .rst_n(rst_n),
        .pulse_fast_in(op_done),
        .pulse_slow_out(sync_op_done_user)
    );

    // Instantiate Server FSM
    Server_FSM server(
        .clk(s_clk), .rst_n(rst_n),
        .start(sync_start),
        .frame(frame),
        .auth_done(auth_done),
        .auth_fail(auth_fail),
        .op_code(op_code),
        .data(data_to_op),
        .op_start(op_start),
        .op_done(sync_op_done)
    );

    // Instantiate OPU
    operation_unit opu(
        .clk(op_clk), .rst_n(rst_n),

        .op_start(sync_op_start),
        .op_code(op_code),
        .data_in(data_to_op),

        .ack_toggle(),
        .data_out(op_result),
        .data_valid(op_done)
    );

    // Instantiate User
    User_RAM user(
        .clk(u_clk), .rst_n(rst_n),

        .load(load),
        .addr(addr),
        .data_in(data_in),
        .ID(ID),

        .start(start),
        .frame(frame),
        .auth_done(sync_auth_done),
        .auth_fail(sync_auth_fail),

        .wb_data(op_result),
        .wb_valid(sync_op_done_user)
    );

endmodule
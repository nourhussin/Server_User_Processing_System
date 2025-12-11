module Top (
    input wire u_clk, s_clk, op_clk , rst_n
);

    // USER ↔ SERVER wires
    wire        start;
    wire [15:0] frame;
    wire        auth_done;

    // SERVER ↔ OPU wires
    wire        op_start;
    wire [1:0]  op_code;
    wire [7:0]  data_to_op;
    wire [7:0]  op_result;
    wire        op_done;

    // Instantiate Server FSM
    Server_FSM server(
        .clk(s_clk), .rst_n(rst_n),
        .start(start),
        .frame(frame),
        .auth_done(auth_done),
        .op_code(op_code),
        .data(data_to_op),
        .op_start(op_start),
        .op_done(op_done)
    );

    // Instantiate OPU
    OPU opu(
        .clk(op_clk), .rst_n(rst_n),
        .op_start(op_start),
        .op_code(op_code),
        .data_in(data_to_op),
        .data_out(op_result),
        .op_done(op_done)
    );

    // Instantiate User
    User user(
        .clk(u_clk), .rst_n(rst_n),
        .start(start),
        .frame_out(frame),
        .auth_done(auth_done),
        .processed_data(op_result),
        .write_back_en(op_done)
    );

endmodule

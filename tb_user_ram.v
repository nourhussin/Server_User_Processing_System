module tb_User_RAM();
    reg clk;
    reg rst_n;

    reg load;
    reg [3:0] addr;
    reg [7:0] data_in;
    reg [6:0] ID;

    wire auth_done;
    wire auth_fail;
    wire start;
    wire [15:0] frame;

    reg [7:0] wb_data;
    reg wb_valid;

    wire [1:0] op_code;
    wire [7:0] data;
    wire op_start;
    wire op_done;

    wire data_out;
    wire data_valid;

// Instantiate DUT
    User_RAM DUT (
        .clk(clk),
        .rst_n(rst_n),
        .load(load),
        .addr(addr),
        .data_in(data_in),
        .ID(ID),
        .auth_done(auth_done),
        .auth_fail(auth_fail),
        .start(start),
        .frame(frame),
        .wb_data(wb_data),
        .wb_valid(wb_valid)
    );

    Server_FSM server_fsm_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .frame(frame),
        .auth_done(auth_done),
        .auth_fail(auth_fail),
        .op_code(op_code),
        .data(data),
        .op_start(op_start),
        .op_done(op_done)
    );

    operation_unit op_u  (
        .clk(clk),
        .rst_n(rst_n),
        .op_code(op_code),
        .data_in(data),
        .op_start(op_start), 
        .ack_toggle(op_done), 
        .data_out(data_out),  
        .data_valid(data_valid)
        );

    // clk Generation 
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    integer k;
    initial begin
        initialize_inputs();
        assert_reset();

        load_word(4'd2, 7'b1010001, 8'h11);
        load_word(4'd4, 7'b1110010, 8'h22);
        load_word(4'd9, 7'b1010100, 8'h33);
        
        repeat(5) @(posedge clk);

        $display("Initial memory dump in hexa:");
        for (k=0; k<16; k=k+1) begin
            $display("mem[%0d] = %h", k, DUT.mem[k]);
        end

        $display("Initial memory dump in binary:");
        for (k=0; k<16; k=k+1) begin
            $display("mem[%0d] = %b", k, DUT.mem[k]);
        end

        repeat(10) @(posedge clk);

        write_back(8'hAA);
        write_back(8'hBB);
        write_back(8'hCC);

        repeat(20) @(posedge clk);

        $display("Final memory dump in hexa:");
        for (k=0; k<16; k=k+1) begin
            $display("mem[%0d] = %h", k, DUT.mem[k]);
        end

        $display("Final memory dump in binary:");
        for (k=0; k<16; k=k+1) begin
            $display("mem[%0d] = %b", k, DUT.mem[k]);
        end

        $stop;
    end

    task assert_reset;
		begin
		rst_n = 0;
		repeat(2) @(negedge clk);
		rst_n = 1;
		end
	endtask

    task initialize_inputs;
        begin
            clk = 0;
            load = 0;
            wb_valid = 0;
            wb_data = 0;
            addr = 0;
            ID = 0;
            data_in = 0;
        end
    endtask

    task load_word(input [3:0] a, input [6:0] the_ID, input [7:0] data);
    begin
        @(negedge clk);
        load = 1;
        addr = a;
        ID = the_ID;
        data_in = data;
        @(negedge clk);
        load = 0;
    end
    endtask

    task write_back(input [7:0] processed);
    begin
        @(posedge clk);
        wb_data = processed;
        wb_valid = 1;
        @(posedge clk);
        wb_valid = 0;
    end
    endtask
endmodule


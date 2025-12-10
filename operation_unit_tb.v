module operation_unit_tb;

    reg        clk, rst_n;
    reg [1:0]  op_code;
    reg [7:0]  data_in;
    reg        op_start;
    
    wire       data_ready;
    wire       ack_toggle;
    wire [7:0] data_out;
    wire       data_valid;

    // Instantiate DUT
    operation_unit dut (
        .clk(clk),
        .rst_n(rst_n),
        .op_code(op_code),
        .data_in(data_in),
        .op_start(op_start),
        .ack_toggle(ack_toggle),
        .data_out(data_out),
        .data_valid(data_valid)
    );

    // Clock generation
    always #5 clk = ~clk;  // 100MHz clock

    initial begin
        // Initialize
        clk = 0;
        rst_n = 0;
        op_code = 0;
        data_in = 0;
        op_start = 0;
        
        // Reset
        #20;
        rst_n = 1;
        
        // Test 1: NOP
        #10;
        data_in = 8'hAA;
        op_code = 2'b00;
        op_start = 1;
        #10;
        op_start = 0;
        #10;
        
        // Test 2: Shift left by 2
        data_in = 8'hCC;
        op_code = 2'b01;
        op_start = 1;
        #10;
        op_start = 0;
        #10;
        
        // Test 3: Rotate right by 2
        data_in = 8'hB3;
        op_code = 2'b10;
        op_start = 1;
        #10;
        op_start = 0;
        #10;
        
        // Test 4: Invert bits
        data_in = 8'h55;
        op_code = 2'b11;
        op_start = 1;
        #10;
        op_start = 0;
        
        #50;
        $stop;
    end

    // Display results
    always @(posedge clk) begin
        if (data_valid) begin
            $display("Time=%0t: Result=0x%h, ack_toggle=%b", $time, data_out, ack_toggle);
        end
    end

endmodule
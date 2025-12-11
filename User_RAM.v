module User_RAM (
    // ports
    input wire clk,
    input wire rst_n,

    input wire load,
    input wire [3:0] addr,
    input wire [7:0] data_in,
    input wire [6:0] ID,

    // Server interface
    input wire auth_done,
    input wire auth_fail,
    output reg start,
    output reg [15:0] frame,

    // FIFO interface
    input wire [7:0] wb_data,
    input wire wb_valid
);

reg [15:0] mem [15:0]; // 16 words
integer i;

reg [3:0] p_q [0:15];
reg [3:0] p_head, p_tail;
reg [4:0] p_count;

reg [3:0] wb_q [0:15];
reg [3:0] wb_head, wb_tail;
reg [4:0] wb_count;

localparam IDLE = 1'b0;
localparam SEND = 1'b1;

reg current_state, next_state;

always @(posedge clk) begin
    if (~rst_n) begin
        current_state <= IDLE;
    end
    else begin 
        current_state <= next_state;
    end
end

// load memory
always @(posedge clk) begin
    if (!rst_n) begin 
        for (i=0 ; i < 16 ; i=i+1) begin
            mem[i] <= 0;
        end
    end
    else if (load) begin
        mem[addr] <= {1'b0, ID, data_in};
    end
    else if (wb_valid) begin
        mem[wb_q[wb_head]] <= {1'b1, mem[wb_q[wb_head]][14:8], wb_data};
    end
end


always @(posedge clk) begin
    if (!rst_n) begin 
        p_tail  <= 0;
        p_head  <= 0;
        p_count <= 0;
    end
    else begin
        if (load) begin
            p_q[p_tail] <= addr;
            p_tail <= p_tail + 4'b1;
        end

        if (auth_done || auth_fail) begin
            p_head <= p_head + 4'b1;
        end

        if (load && !auth_done) begin
            p_count <= p_count + 5'b1;
        end   
        else if (!load && auth_done) begin
            p_count <= p_count - 5'b1;
        end
    end
end

// write back handler 
always @(posedge clk) begin
    if (!rst_n) begin 
        wb_head   <= 0;
        wb_tail   <= 0;
        wb_count  <= 0;
    end
    else begin
        if (wb_valid) begin
            wb_head  <= wb_head + 4'b1;
        end

        // id is valid (pkt isn't dropped)
        if (auth_done) begin
            wb_q[wb_tail] <= p_q[p_head];
            wb_tail  <= wb_tail + 4'b1;
        end

        if (wb_valid && !auth_done) begin
            wb_count <= wb_count - 5'b1;
        end
        else if (!wb_valid && auth_done) begin
            wb_count <= wb_count + 5'b1;
        end
    end
end

// next state logic
always @(*) begin
    case (current_state)
        IDLE: begin 
            if (p_count > 0)
                next_state = SEND;
            else  
                next_state = IDLE;
        end

        SEND: begin
            if (auth_done)  
                next_state = IDLE;
            else  
                next_state = SEND;
        end

        default: begin
            next_state = IDLE;
        end
    endcase
end

// output logic
always @(posedge clk) begin
    if (~rst_n) begin
       start    <= 0;
       frame    <= 0;
    end
    else begin 
        case (current_state)
            IDLE: begin
                start <= 0;
            end
            SEND: begin
                start <= 1;
                frame <= mem[p_q[p_head]];
            end
        endcase
    end
end

endmodule

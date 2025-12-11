module User (
    input  wire        clk, rst_n,
    
    // handshake with server
    output reg         start,
    output reg [15:0]  frame_out,
    input  wire        auth_done,
    input  wire [7:0]  processed_data,
    input  wire        write_back_en
);

    // Simple RAM with 16 locations
    reg [15:0] RAM [0:15];
    reg [3:0]  addr;   // counter from 0 to 15

    localparam U_SEND      = 2'b01,
               U_WAIT      = 2'b11, 
               U_WRITEBACK = 2'b10;

    reg [1:0] state, next_state;

    // ============================================================
    // STATE REGISTER
    // ============================================================
    always @(posedge clk) begin
        if(!rst_n)
            state <= U_SEND;
        else
            state <= next_state;
    end

    // ============================================================
    // RESETTABLE start & frame_out
    // ============================================================
    always @(posedge clk) begin
        if(!rst_n) begin
            start     <= 1'b0;
            frame_out <= 16'b0;
        end else begin
            case(state)
                U_SEND: begin
                    start     <= 1'b1;
                    frame_out <= RAM[addr];
                end
                default: begin
                    start     <= 1'b0;
                    frame_out <= 16'b0;
                end
            endcase
        end
    end

    // ============================================================
    // FSM COMBINATIONAL
    // ============================================================
    always @(*) begin
        next_state = state;
        case(state)
            U_SEND:  next_state = U_WAIT;
            U_WAIT:  if (write_back_en) next_state = U_WRITEBACK;
            U_WRITEBACK: next_state = U_SEND;
        endcase
    end

    // ============================================================
    // WRITEBACK & COUNTER UPDATE
    // ============================================================
    always @(posedge clk) begin
        if(!rst_n)
            addr <= 0;
        else begin
            if(state == U_WRITEBACK) begin
                // Only write back if auth succeeded
                if(auth_done && processed_data != 8'd0) begin
                    RAM[addr][15]  <= 1;               // processed flag
                    RAM[addr][7:0] <= processed_data;  // write result
                end
                // Move to next address regardless of auth
                if(addr < 4'd15)
                    addr <= addr + 1;
            end
        end
    end

endmodule

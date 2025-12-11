module Server_FSM (
//---------- Server Clock & Reset ---------
    input wire clk, rst_n,

//---------- User Interface ---------------
    input wire start,
    input wire [15:0] frame,
    output reg auth_done,
    output reg auth_fail,

//---------- OPU Interface-----------------
    output reg [1:0] op_code,
    output reg [7:0] data,
    output reg op_start,
    input  wire op_done
);
    localparam IDLE = 2'b00, 
               Auth = 2'b01, 
               Op   = 2'b11, 
               Done = 2'b10;

    wire not_multiple_ones;
    assign not_multiple_ones = (3'b000 + frame[11]+ frame[10]+ frame[9]+ frame[8]) == 3'b001 ;

    reg[1:0] current_state, next_state;
    
    always@(posedge clk) begin
        if(!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always@(*) begin

        next_state = IDLE;
        auth_done = 0;
        auth_fail = 0;
        op_start = 0;
        op_code = 0;
        //data = 0;

        case(current_state)
        IDLE: begin
            if(start)
                next_state = Auth;
            else
                next_state = IDLE;
        end
        Auth: begin
            if(~frame[15] && frame[14:12] == 3'b101 && not_multiple_ones) begin
                auth_done = 1;
                next_state = Op;
            end
            else begin //Authentication Failed
                auth_fail = 1;
                next_state = IDLE; 
            end
                
        end
        Op: begin
            op_start = 1;
            data = frame[7:0];
            case(frame[11:8])
                4'b0001: op_code = 2'b00;
                4'b0010: op_code = 2'b01;
                4'b0100: op_code = 2'b11;
                4'b1000: op_code = 2'b10;
            endcase

            if(op_done)
                next_state = Done;
            else
                next_state = Op;
        end
        Done:begin
            if(start)
                next_state = Auth;
            else
                next_state = IDLE;
        end

        default: next_state = IDLE;
        endcase
    end
endmodule

// Traffic Light Controller FSM
module traffic_light_controller (
    input  logic clk,           // System Clock
    input  logic reset,         // Active-high Reset
    output logic [2:0] lights_ns, // North-South Lights: [2]=Red, [1]=Yellow, [0]=Green
    output logic [2:0] lights_ew  // East-West Lights:   [2]=Red, [1]=Yellow, [0]=Green
);

    // 1. Define State Encodings (Using Sequential Binary Encoding)
    typedef enum logic [1:0] {
        S0_NSG_EWR = 2'b00, // North-South Green, East-West Red
        S1_NSY_EWR = 2'b01, // North-South Yellow, East-West Red
        S2_NSR_EWG = 2'b10, // North-South Red, East-West Green
        S3_NSR_EWY = 2'b11  // North-South Red, East-West Yellow
    } state_t;

    state_t current_state, next_state;

    // 2. Define Timing Parameters (Number of clock cycles per state)
    localparam int unsigned TIME_GREEN  = 10;
    localparam int unsigned TIME_YELLOW = 3;

    // Internal clock cycle counter
    int unsigned count;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= S0_NSG_EWR;
            count         <= 0;
        end else begin
            current_state <= next_state;
            
            // Increment counter, reset it to 0 when transitioning states
            if (current_state != next_state)
                count <= 0;
            else
                count <= count + 1;
        end
    end

    always_comb begin
        // Default assignment to avoid latches
        next_state = current_state; 

        case (current_state)
            S0_NSG_EWR: begin
                if (count >= (TIME_GREEN - 1))
                    next_state = S1_NSY_EWR;
            end
            
            S1_NSY_EWR: begin
                if (count >= (TIME_YELLOW - 1))
                    next_state = S2_NSR_EWG;
            end
            
            S2_NSR_EWG: begin
                if (count >= (TIME_GREEN - 1))
                    next_state = S3_NSR_EWY;
            end
            
            S3_NSR_EWY: begin
                if (count >= (TIME_YELLOW - 1))
                    next_state = S0_NSG_EWR;
            end
            
            default: next_state = S0_NSG_EWR;
        endcase
    end

    // Mapping: Bit 2 = Red, Bit 1 = Yellow, Bit 0 = Green (3'bR_Y_G)
    always_comb begin
        case (current_state)
            S0_NSG_EWR: begin lights_ns = 3'b001; lights_ew = 3'b100; end // NS Green, EW Red
            S1_NSY_EWR: begin lights_ns = 3'b010; lights_ew = 3'b100; end // NS Yellow, EW Red
            S2_NSR_EWG: begin lights_ns = 3'b100; lights_ew = 3'b001; end // NS Red, EW Green
            S3_NSR_EWY: begin lights_ns = 3'b100; lights_ew = 3'b010; end // NS Red, EW Yellow
            default:    begin lights_ns = 3'b100; lights_ew = 3'b100; end // Default All Red
        endcase
    end

endmodule

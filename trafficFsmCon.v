`timescale 1ns/1ps
// -------------------------------------------------------------
// Traffic Light FSM (2-way: North-South vs East-West)
// - Pure Moore outputs
// - All-red interlock between directions
// - Two car sensors (cars_ns, cars_ew)
// - Synchronizers for async sensors
// - Min/Max green enforcement to avoid flicker/starvation
// -------------------------------------------------------------
module traffic_fsm #(
    parameter integer MIN_GREEN_CYCLES = 10,  // minimum green duration per direction
    parameter integer MAX_GREEN_CYCLES = 40,  // force switch by this time even if no request (fairness)
    parameter integer ALL_RED_CYCLES   = 3    // all-red interlock duration during every transition
)(
    input  wire clk,
    input  wire rst,        // async, active-high
    input  wire cars_ns,    // cars waiting in North-South direction
    input  wire cars_ew,    // cars waiting in East-West direction

    output reg  green_N,
    output reg  red_N,
    output reg  green_E,
    output reg  red_E
);

    // ----------------------------
    // Synchronize external sensors
    // ----------------------------
    reg cars_ns_meta, cars_ns_sync;
    reg cars_ew_meta, cars_ew_sync;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cars_ns_meta <= 1'b0;
            cars_ns_sync <= 1'b0;
            cars_ew_meta <= 1'b0;
            cars_ew_sync <= 1'b0;
        end else begin
            cars_ns_meta <= cars_ns;
            cars_ns_sync <= cars_ns_meta;
            cars_ew_meta <= cars_ew;
            cars_ew_sync <= cars_ew_meta;
        end
    end

    // ----------------------------
    // States
    // ----------------------------
    localparam [1:0]
        S_NS        = 2'd0,  // North-South green, East-West red
        S_ALL_TO_EW = 2'd1,  // all-red, then go to EW
        S_EW        = 2'd2,  // East-West green, North-South red
        S_ALL_TO_NS = 2'd3;  // all-red, then go to NS

    reg [1:0] state, next_state;

    // Generic cycle counter (used for both green timing and all-red timing)
    reg [15:0] timer;

    // --------------------------------
    // State register and timer control
    // --------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_NS;  // safe default on reset
            timer <= 16'd0;
        end else begin
            state <= next_state;
            // Reset timer whenever state changes; else increment
            if (next_state != state)
                timer <= 16'd0;
            else
                timer <= timer + 16'd1;
        end
    end

    // ----------------------------
    // Next-state logic (combinational)
    // ----------------------------
    always @(*) begin
        // Default: hold state
        next_state = state;

        case (state)
            // NS is currently green
            S_NS: begin
                // Stay at least MIN_GREEN_CYCLES
                if (timer < MIN_GREEN_CYCLES) begin
                    next_state = S_NS;
                end else begin
                    // If EW is requesting or we've reached MAX_GREEN (fairness), switch via all-red
                    if (cars_ew_sync || (timer >= MAX_GREEN_CYCLES)) begin
                        next_state = S_ALL_TO_EW;
                    end else begin
                        next_state = S_NS;
                    end
                end
            end

            // All red before giving EW green
            S_ALL_TO_EW: begin
                if (timer >= ALL_RED_CYCLES)
                    next_state = S_EW;
                else
                    next_state = S_ALL_TO_EW;
            end

            // EW is currently green
            S_EW: begin
                if (timer < MIN_GREEN_CYCLES) begin
                    next_state = S_EW;
                end else begin
                    if (cars_ns_sync || (timer >= MAX_GREEN_CYCLES)) begin
                        next_state = S_ALL_TO_NS;
                    end else begin
                        next_state = S_EW;
                    end
                end
            end

            // All red before giving NS green
            S_ALL_TO_NS: begin
                if (timer >= ALL_RED_CYCLES)
                    next_state = S_NS;
                else
                    next_state = S_ALL_TO_NS;
            end

            default: begin
                next_state = S_NS; // safe fallback
            end
        endcase
    end

    // ----------------------------
    // Output logic (pure Moore)
    // Always assign every output (no latches)
    // ----------------------------
    always @(*) begin
        // Safe defaults: ALL-RED (fail-safe)
        green_N = 1'b0; red_N = 1'b1;
        green_E = 1'b0; red_E = 1'b1;

        case (state)
            S_NS: begin
                green_N = 1'b1; red_N = 1'b0; // NS green
                green_E = 1'b0; red_E = 1'b1; // EW red
            end

            S_ALL_TO_EW: begin
                // keep defaults: both red
            end

            S_EW: begin
                green_N = 1'b0; red_N = 1'b1; // NS red
                green_E = 1'b1; red_E = 1'b0; // EW green
            end

            S_ALL_TO_NS: begin
                // keep defaults: both red
            end
        endcase
    end

    // ----------------------------
    // Optional safety assertion (simulation-time)
    // Ensures never both directions are green simultaneously.
    // ----------------------------
    // synthesis translate_off
    always @(posedge clk) begin
        if (!rst && (green_N && green_E)) begin
            $display("FATAL: Both greens asserted at t=%0t", $time);
            $fatal;
        end
    end
    // synthesis translate_on

endmodule

`timescale 1ns/1ps

module tb_traffic_fsm;

    // Parameters for quick sim
    localparam MIN_G = 8;
    localparam MAX_G = 24;
    localparam ALL_R = 3;

    // DUT I/O
    reg  clk;
    reg  rst;
    reg  cars_ns;
    reg  cars_ew;
    wire green_N, red_N, green_E, red_E;

    // Instantiate DUT
    traffic_fsm #(
        .MIN_GREEN_CYCLES(MIN_G),
        .MAX_GREEN_CYCLES(MAX_G),
        .ALL_RED_CYCLES  (ALL_R)
    ) dut (
        .clk     (clk),
        .rst     (rst),
        .cars_ns (cars_ns),
        .cars_ew (cars_ew),
        .green_N (green_N),
        .red_N   (red_N),
        .green_E (green_E),
        .red_E   (red_E)
    );

    // Clock: 10ns period
    initial clk = 1'b0;
    always  #5 clk = ~clk;

    // Pretty-print state (peek internal 'state' & 'timer' for visibility)
    // NOTE: Accessing dut.state/timer is purely for TB display.
    task show;
        $display("t=%0t  state=%0d  timer=%0d  cars_ns=%0b cars_ew=%0b  |  N(G,R)=%0b,%0b  E(G,R)=%0b,%0b",
                 $time, dut.state, dut.timer, cars_ns, cars_ew, green_N, red_N, green_E, red_E);
    endtask

    // Drive sequences
    initial begin
        // Waveform dump
        $dumpfile("traffic_fsm.vcd");
        $dumpvars(0, tb_traffic_fsm);

        // Init
        rst     = 1'b1;
        cars_ns = 1'b0;
        cars_ew = 1'b0;
        repeat (2) @(posedge clk);
        rst = 1'b0;
        repeat (1) @(posedge clk); show();

        // 1) Start in NS green (by reset). Let it run MIN_G cycles with no requests.
        repeat (MIN_G/2) @(posedge clk); show();

        // 2) Request from EW -> expect: wait until MIN_G, all-red for ALL_R, then EW green
        cars_ew = 1'b1;
        repeat (MIN_G) @(posedge clk); show();

        // Keep EW request asserted a bit, then drop it
        repeat (4) @(posedge clk); show();
        cars_ew = 1'b0;

        // 3) No requests; ensure fairness: after MAX_G on EW, it should flip back to NS via all-red
        repeat (MAX_G + 4) @(posedge clk); show();

        // 4) Now request from NS side
        cars_ns = 1'b1;
        repeat (MIN_G + 4) @(posedge clk); show();
        cars_ns = 1'b0;

        // 5) Staggered requests: both sides ask; observe min green + interlock behavior
        repeat (5) @(posedge clk); show();
        cars_ns = 1'b1;
        cars_ew = 1'b1;
        repeat (MAX_G + 6) @(posedge clk); show();
        cars_ns = 1'b0;
        cars_ew = 1'b0;

        // 6) Finish
        repeat (10) @(posedge clk); show();
        $display("Simulation complete.");
        $finish;
    end

    // Continuous monitor (optional)
    initial begin
        $monitor("t=%0t  state=%0d  timer=%0d  cars_ns=%0b cars_ew=%0b  |  N(G,R)=%0b,%0b  E(G,R)=%0b,%0b",
                 $time, dut.state, dut.timer, cars_ns, cars_ew, green_N, red_N, green_E, red_E);
    end

endmodule


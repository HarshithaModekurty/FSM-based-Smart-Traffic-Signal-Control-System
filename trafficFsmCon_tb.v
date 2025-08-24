`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2024 11:10:00 PM
// Design Name: 
// Module Name: tb_trafficFsmCon
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for traffic FSM controller with separate light outputs
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_trafficFsmCon;

// Parameters
parameter N_S = 2'b01, E_W = 2'b10;

// Inputs
reg clk;
reg rst;
reg cars;

// Outputs
wire green_N;
wire red_N;
wire green_E;
wire red_E;

// Instantiate the Unit Under Test (UUT)
trafficFsmCon #(.N_S(N_S), .E_W(E_W)) uut (
    .clk(clk),
    .rst(rst),
    .cars(cars),
    .green_N(green_N),
    .red_N(red_N),
    .green_E(green_E),
    .red_E(red_E)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns clock period
end

// Test sequence
initial begin
    // Monitor outputs
    $monitor("Time: %0t | State: %b | Cars: %b | Green_N: %b | Red_N: %b | Green_E: %b | Red_E: %b", 
             $time, uut.state, cars, green_N, red_N, green_E, red_E);

    // Initialize inputs
    rst = 1;
    cars = 0;
    #10; // Wait for reset
    rst = 0;

    // Test Case 1: Stay in N_S (no cars)
    #10 cars = 0; // No cars detected
    #20;

    // Test Case 2: Transition to E_W (cars detected in the East/West direction)
    cars = 1;
    #20;

    // Test Case 3: Stay in E_W (no cars)
    cars = 0;
    #20;

    // Test Case 4: Transition back to N_S (cars detected in the North/South direction)
    cars = 1;
    #20;

    // Test Case 5: Remain in N_S (no cars detected)
    cars = 0;
    #20;

    // Test Case 6: Reset FSM
    rst = 1;
    #10 rst = 0;

    // Test Case 7: Transition back to E_W (cars detected in the East/West direction)
    cars = 1;
    #20;

    // Finish simulation
    $finish;
end

endmodule

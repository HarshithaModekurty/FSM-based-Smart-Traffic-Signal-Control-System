# Designing-a-Traffic-Signal-Control-System-with-Verilog-HDL

## Overview

This project implements a finite state machine (FSM)-based traffic light controller module, designed to manage traffic flow between North/South (N_S) and East/West (E_W) directions based on detected vehicles. The FSM transitions between states depending on the presence of cars in the respective directions.

## Files Included

- **trafficFsmCon.v:** Implements the FSM traffic controller logic.

- **tb_trafficFsmCon.v:** Testbench to validate the FSM functionality through simulation.

## Parameters:
**Module: trafficFsmCon**
- **File:** trafficFsmCon.v

- **Testbench:** tb_trafficFsmCon
- **N_S :** Binary value representing the North/South state (2'b01).

- **E_W :** Binary value representing the East/West state (2'b10).

## Inputs:

- **clk :** Clock signal.

- **rst :** Reset signal (active high).

- **cars :** Input signal indicating the presence of cars.

## Outputs:

- **green_N :** Controls the green light for the North/South direction.

- **red_N :** Controls the red light for the North/South direction.

- **green_E :** Controls the green light for the East/West direction.

- **red_E :** Controls the red light for the East/West direction.

## Functionality:

The FSM starts in the North/South (N_S) state upon reset.

If cars are detected (cars = 1), the FSM transitions to the other state (E_W or N_S) based on the current state.

Traffic light outputs (green_* and red_*) are updated according to the current state and the cars signal.

## Purpose:

Simulates the trafficFsmCon module to validate its functionality under various conditions.<br>

**Module: tb_trafficFsmCon**

## Inputs:

- **clk:** Simulated clock with a 10ns period.

- **rst:** Simulated reset signal.

- **cars:** Simulated car presence signal.

## Outputs:

green_N, red_N, green_E, red_E: Observed traffic light signals.

## Test Scenarios:

**Initial Reset:** FSM resets to the North/South (N_S) state.

**No Cars Detected:** FSM remains in the current state.

**Cars Detected:** FSM transitions between states based on the presence of cars.

**Reset Behavior:** FSM resets and reinitializes to the North/South state.

## Simulation Instructions

## Prerequisites:

Vivado 2018.2 or any compatible Verilog simulator.

## Steps:

- Open Vivado or your preferred simulator.

- Compile the trafficFsmCon.v file.

- Compile the tb_trafficFsmCon.v file.

- Run the simulation.

- Observe the output in the waveform viewer or console logs.

## Expected Output:

The FSM should start in the N_S state upon reset.

The traffic light signals should transition based on the cars input.

Reset should return the FSM to the initial N_S state.

## Additional Information

Parameters and Constants:

Adjust **N_S** and **E_W** values as required to change state encoding.

## Notes:

- Ensure proper reset of signals before simulation.

- Modify the cars signal in the testbench to simulate various scenarios effectively.



## Author
[Praveen Oruganti](https://github.com/Praveen-Oruganti)  
(Trainee@Ramaiah Skill academy )




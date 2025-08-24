`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2024 10:28:19 PM
// Design Name: 
// Module Name: trafficFsmCon
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module trafficFsmCon#(parameter N_S=2'b01,E_W=2'b10)(
input clk,rst,cars,output reg green_N,red_N,green_E,red_E);
reg [1:0]state,nextState;

////////////////state initilization////////////////////////////////////

always@(posedge clk or rst) begin
	if(rst) begin
		state<=N_S;
	end
	else begin
		state<=nextState;
	end
end
///////////////////state transitions//////////////////////
always@(*) begin
case(state)
N_S:nextState=(cars==1)?E_W:N_S;
E_W:nextState=(cars==1)?N_S:E_W;
default:nextState=N_S;
endcase
end		

//////////////////block for outputs/////////////////////
always@(*)  begin
case(state)
	N_S: begin
	if(cars==1) begin
		green_N=1'b1;
		red_N=1'b0;
		green_E=1'b0;
		red_E=1'b1;
		end
	else begin 
		red_N=1'b1;
		end
	end
	E_W: begin
	if(cars==1) begin
		green_N=1'b0;
            red_N=1'b1;
            green_E=1'b1;
            red_E=1'b0;
	end
	else begin
	   red_E=1'b0;
	 end
	 end
	default: begin green_N=1'b0;
                 red_N=1'b0;
                 green_E=1'b0;
                 red_E=1'b0;
			end
endcase
end
endmodule
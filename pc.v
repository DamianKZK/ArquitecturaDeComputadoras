`timescale 1ns/1ns

module pc(
	input clk,
	input reset,
	input [31:0]pcNext,  //este dato viene del mux
	output reg [31:0] pc //este va a la memoria y al sumador
	);

    initial begin 
        counterOut = 32'b0;
    end

    always @(clk) begin
        counterOut = counterIn + 4;
    end

endmodule

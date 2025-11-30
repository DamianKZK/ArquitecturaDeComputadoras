`timescale 1ns/1ns

module pc(
	input clk,
	input reset,
	input [31:0]pcNext,  //este dato viene del mux
	output reg [31:0] pc //este va a la memoria y al sumador
	);


always @(posedge clk) begin
	if(reset)
		pc <=32'b0;
	else begin
		pc<=pcNext;
	end

	
end



endmodule 
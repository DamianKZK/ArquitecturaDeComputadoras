`timescale 1ns/1ns

module AluControl(
	input [5:0]funct,
	input [1:0]aluOP,
	output reg[2:0]aluSel);

	always @* begin
		case (aluOP)
			//para bw o sw
			2'b00: aluSel = 3'b000;
			//para branch equal
			2'b01: aluSel = 3'b001;

			2'b10: begin
				case (funct)
					6'b100000: aluSel = 3'b000;
					6'b100010: aluSel = 3'b001;
					6'b100100: aluSel = 3'b010;
					6'b100101: aluSel = 3'b011;
					6'b101010: aluSel = 3'b100;
					default: aluSel = 3'b000;
				endcase
			end
			default: aluSel = 3'b000;
		endcase			

	end


endmodule
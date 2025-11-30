`timescale 1ns/1ns

module signExtend(
	input [15:0]inInm,
	output [31:0]outInm);
//se repite 16 veces el bit de signo y se concatena con la entrada
assign outInm ={{16{inInm[15]}}, inInm};

endmodule 


module signtb();
	
	wire[31:0] res;

	signExtend sign(
		.inInm(16'b100000),
		.outInm(res)
	);


endmodule
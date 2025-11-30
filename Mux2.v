module Mux2(
	input[4:0] in_20_16,
	input[4:0] in_15_11,
	input unidadControl,
	output [4:0] salida);

assign salida = (unidadControl)?in_15_11:in_20_16;


endmodule
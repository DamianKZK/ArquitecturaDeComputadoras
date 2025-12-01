`timescale 1ns/1ns
module shiftLeft2(
	input[31:0] inData,
	output[31:0] outData
	);

assign outData = inData<<2;

endmodule
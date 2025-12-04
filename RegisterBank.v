`timescale 1ns/1ns

module registerBank(
    input clk,                 
    input [4:0] readReg1, 
    input [4:0] readReg2, 
    input [4:0] writeReg, 
    input [31:0] writeData, 
    input regWrite, 
    output reg[31:0] readData1, 
    output reg[31:0] readData2
);
    

	reg[31:0] Bank[0:31];
    
	initial begin
		$readmemb("data.txt", Bank);
	end

	always @* begin
		readData1 = Bank[readReg1];
		readData2 = Bank[readReg2];

		if(regWrite) begin

			Bank[writeReg] = writeData;

		end

	end


endmodule

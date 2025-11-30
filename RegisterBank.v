module registerBank(
		input [4:0] readReg1, 	//Dirección del registro 1 a leer
		input [4:0] readReg2,    //Dirección del registro 2 a leer
		input [4:0] writeReg,    //Dirección donde se va a escribir

		input [31:0] writeData,  //Que se va a escribir

		input regWrite,				//Señal de control, indica si se puede escribir

		output reg[31:0] readData1, //Dato que sale de la direccion 1 
		output reg[31:0] readData2  //Dato que sale e la direccion 2
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
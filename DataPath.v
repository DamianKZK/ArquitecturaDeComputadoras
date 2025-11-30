module DataPath(input clk);

//cables para PC, sumador y InstructionMemory
	wire [31:0] wPcActual, wPcSig , wInstruction, pcPlus4;

	pc ProgramCounter(
		.clk(clk),
		.pc(wPcActual),
		.pcNext(wPcSig));

	adder Sumador(
		.pcIn(wPcActual),
		.pcOut(pcPlus4));

	InstructionMemory MemIns(
		.addres(wPcActual),
		.instruction(wInstruction));

	//cables para register bank, sign extend, shift left y Mux2
	wire [31:0] DW;
	wire sel;

	wire [5:0]funct = wInstruction[5:0];
	wire [15:0]inmediate = wInstruction [15:0];
	wire [4:0]AW1 = wInstruction[15:11];
	wire [4:0]AW2 = wInstruction[20:16];
	wire [4:0]AR2 = wInstruction[20:16];
	wire [4:0]AR1 = wInstruction[25:21];
	wire [25:0]desplazamiento = wInstruction[25:0];
	wire [4:0]AW;
	wire [31:0]DR1, DR2;

	Mux2 mux2DP(
		.in_20_16(AW2),
		.in_15_11(AW1),
		.unidadControl(),		//aun no implementado
		.salida(AW));    


	registerBank banco(
		.readReg1(AR1),
		.readReg2(AR2),
		.writeReg(AW),
		.readData1(DR1),
		.readData2(DR2)
		);



endmodule



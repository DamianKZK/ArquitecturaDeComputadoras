`timescale 1ns/1ns

module DataPath(
    input clk,
    input reset
);

   

    // --- Cables del PC y Fetch ---
    wire [31:0] w_pc_actual;
    wire [31:0] w_pc_next;       // Salida del Mux4 (Branch)
    wire [31:0] w_pc_plus_4;     // Salida del PCadder
    wire [31:0] w_instruction;

    // --- Cables de Decodificación (Slicing) ---
    wire [5:0]  opcode = w_instruction[31:26];
    wire [4:0]  rs     = w_instruction[25:21];
    wire [4:0]  rt     = w_instruction[20:16];
    wire [4:0]  rd     = w_instruction[15:11];
    wire [15:0] imm    = w_instruction[15:0];
    wire [5:0]  funct  = w_instruction[5:0];

    // --- Cables de la Unidad de Control ---
    wire w_regDst, w_branch, w_memRead, w_memtoReg, w_memWrite, w_aluSrc, w_regWrite;
    wire [1:0] w_aluOp;

    // --- Cables de Datos y Registros ---
    wire [4:0]  w_write_reg_addr; // Salida del Mux2 (Destino de escritura)
    wire [31:0] w_write_data;     // Salida del Mux1 (Dato final a escribir)
    wire [31:0] w_readData1;
    wire [31:0] w_readData2;
    wire [31:0] w_signExtImm;     // Salida del signExtend

    // --- Cables de Ejecución (ALU) ---
    wire [31:0] w_aluInputB;      // Salida del Mux3
    wire [2:0]  w_aluSel;         // Salida del AluControl
    wire [31:0] w_aluResult;
    wire        w_zeroFlag;

    // --- Cables de Memoria ---
    wire [31:0] w_memDataOut;     // Salida de la RAM

    // --- Cables de Branch ---
    wire [31:0] w_shiftedImm;     // Salida del shiftLeft2
    wire [31:0] w_branchTarget;   // Dirección calculada del salto
    wire        w_pcSrc;          // AND entre Branch y Zero


    

    pc U_PC (
        .clk(clk),
        .reset(reset),
        .pcNext(w_pc_next),      // Viene del Mux4
        .pc(w_pc_actual)
    );

    PCadder U_PC_Adder (
        .pcIn(w_pc_actual),
        .pcOut(w_pc_plus_4)
    );

    InstructionMemory U_IM (
        .address(w_pc_actual),
        .instruction(w_instruction)
    );


    // --- ETAPA 2: DECODE & CONTROL ---

    Control U_Control (
        .opCode(opcode),
        .regDst(w_regDst),
        .branch(w_branch),
        .memRead(w_memRead),
        .memtoReg(w_memtoReg),
        .aluOp(w_aluOp),
        .memWrite(w_memWrite),
        .aluSrc(w_aluSrc),
        .regWrite(w_regWrite)
    );

    // Mux2: Selecciona registro destino (rt vs rd)
    // Entradas: rt_addr, rd_addr, regDst -> Salida: writeReg
    Mux2 U_Mux_RegDst (
        .rt_addr(rt),
        .rd_addr(rd),
        .regDst(w_regDst),
        .writeReg(w_write_reg_addr)
    );

    registerBank U_RegBank (
        .clk(clk),
        .readReg1(rs),
        .readReg2(rt),
        .writeReg(w_write_reg_addr),
        .writeData(w_write_data), // Viene del Mux1
        .regWrite(w_regWrite),
        .readData1(w_readData1),
        .readData2(w_readData2)
    );

    signExtend U_SignExt (
        .inInm(imm),
        .outInm(w_signExtImm)
    );


    // --- ETAPA 3: EXECUTE (ALU) ---

    // Mux3: Selecciona entrada B de la ALU (Registro vs Inmediato)
    // Entradas: readData2, signExtImm, aluSrc -> Salida: aluInputB
    Mux3 U_Mux_ALUSrc (
        .readData2(w_readData2),
        .signExtImm(w_signExtImm),
        .aluSrc(w_aluSrc),
        .aluInputB(w_aluInputB)
    );

    AluControl U_ALU_Control (
        .funct(funct),
        .aluOP(w_aluOp),
        .aluSel(w_aluSel)
    );

    ALUZeroFlag U_ALU (
        .a(w_readData1),
        .b(w_aluInputB),
        .sel(w_aluSel),
        .out(w_aluResult),
        .zeroFlag(w_zeroFlag)
    );

    // --- LÓGICA DE BRANCH ---
    
    // Shift Left 2
    shiftLeft2 U_Shift (
        .inData(w_signExtImm),
        .outData(w_shiftedImm)
    );

    // Sumador simple para Branch
    assign w_branchTarget = w_pc_plus_4 + w_shiftedImm;

    // Compuerta AND para decidir el Branch
    assign w_pcSrc = w_branch & w_zeroFlag;

    // Mux4: Selecciona siguiente PC (PC+4 vs Branch Target)
    // Entradas: pcPlus4, branchTarget, pcSrc -> Salida: nextPcBranch
    Mux4 U_Mux_Branch (
        .pcPlus4(w_pc_plus_4),
        .branchTarget(w_branchTarget),
        .pcSrc(w_pcSrc),
        .nextPcBranch(w_pc_next)
    );


    // --- ETAPA 4: MEMORY ---

    RAM U_RAM (
        .clk(clk),
        .memRead(w_memRead),
        .memWrite(w_memWrite),
        .addrIn(w_aluResult),
        .dataIn(w_readData2),
        .dataOut(w_memDataOut)
    );


    // --- ETAPA 5: WRITE BACK ---

    // Mux1: Selecciona dato a escribir en registro (ALU vs Memoria)
    // Entradas: aluResult, memData, memToReg -> Salida: writeData
    Mux1 U_Mux_MemToReg (
        .aluResult(w_aluResult),
        .memData(w_memDataOut),
        .memToReg(w_memtoReg),
        .writeData(w_write_data)
    );

endmodule
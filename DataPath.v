`timescale 1ns/1ns

module DataPath(
    input clk,
    input reset
);

    // ==========================================
    // 1. CABLES (WIRES) E INTERCONEXIONES
    // ==========================================

    // --- Cables del PC y Fetch ---
    wire [31:0] w_pc_actual;
    wire [31:0] w_pc_next_branch; // Salida del Mux4 (Branch vs PC+4)
    wire [31:0] w_pc_final;       // Salida del Mux5 (Jump vs Branch) -> Entrada al PC
    wire [31:0] w_pc_plus_4;      // Salida del PCadder
    wire [31:0] w_instruction;
    
    // --- Cable para dirección de Jump ---
    wire [31:0] w_jumpAddress;    

    // --- Cables de Decodificación (Slicing) ---
    wire [5:0]  opcode = w_instruction[31:26];
    wire [4:0]  rs     = w_instruction[25:21];
    wire [4:0]  rt     = w_instruction[20:16];
    wire [4:0]  rd     = w_instruction[15:11];
    wire [15:0] imm    = w_instruction[15:0];
    wire [5:0]  funct  = w_instruction[5:0];
    wire [25:0] target = w_instruction[25:0]; // Target Address para Jump

    // --- Cables de la Unidad de Control ---
    wire w_regDst, w_branch, w_memRead, w_memtoReg, w_memWrite, w_aluSrc, w_regWrite, w_jump;
    wire [2:0] w_aluOp; // 3 bits para soportar todas las operaciones inmediatas

    // --- Cables de Datos y Registros ---
    wire [4:0]  w_write_reg_addr; // Salida del Mux2
    wire [31:0] w_write_data;     // Salida del Mux1 (WB)
    wire [31:0] w_readData1;
    wire [31:0] w_readData2;
    wire [31:0] w_signExtImm;     // Inmediato extendido

    // --- Cables de Ejecución (ALU) ---
    wire [31:0] w_aluInputB;      // Salida del Mux3
    wire [2:0]  w_aluSel;         // Salida del AluControl
    wire [31:0] w_aluResult;
    wire        w_zeroFlag;

    // --- Cables de Memoria ---
    wire [31:0] w_memDataOut;     

    // --- Cables de Branch ---
    wire [31:0] w_shiftedImm;     
    wire [31:0] w_branchTarget;   
    wire        w_pcSrc;          


    // ==========================================
    // 2. LÓGICA DE CÁLCULO DE DIRECCIONES
    // ==========================================

    // Cálculo de JUMP: Concatenar 4 bits superiores de PC+4, target y 00
    assign w_jumpAddress = {w_pc_plus_4[31:28], target, 2'b00};

    // Cálculo de BRANCH: PC+4 + (Inmediato * 4)
    assign w_branchTarget = w_pc_plus_4 + w_shiftedImm;

    // Decisión de BRANCH: (Branch activo AND Zero Flag activa)
    assign w_pcSrc = w_branch & w_zeroFlag;


    // ==========================================
    // 3. INSTANCIACIÓN DE MÓDULOS
    // ==========================================

    // --- ETAPA 1: FETCH ---

    // Mux5: Decide entre el flujo de Branch/Normal y un JUMP incondicional
    Mux5 U_Mux_Jump (
        .nextPcBranch(w_pc_next_branch), // Viene del Mux4
        .jumpTarget(w_jumpAddress),
        .jump(w_jump),                   // CORREGIDO: Usamos .jump en vez de .sel
        .finalPC(w_pc_final)             // Va hacia la entrada del PC
    );

    pc U_PC (
        .clk(clk),
        .reset(reset),
        .pcNext(w_pc_final),             // <--- Conectado a la salida del Mux5
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
        .aluOp(w_aluOp),         // 3 bits
        .jump(w_jump),           // Salida de Jump
        .memWrite(w_memWrite),
        .aluSrc(w_aluSrc),
        .regWrite(w_regWrite)
    );

    // Mux2: Decide registro destino (rt vs rd)
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
        .writeData(w_write_data), // Viene de WB
        .regWrite(w_regWrite),
        .readData1(w_readData1),
        .readData2(w_readData2)
    );

    signExtend U_SignExt (
        .inInm(imm),
        .outInm(w_signExtImm)
    );


    // --- ETAPA 3: EXECUTE (ALU) ---

    // Mux3: Decide operando B de la ALU (Registro vs Inmediato)
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

    // --- LÓGICA DE BRANCH (Hardware Adicional) ---
    
    shiftLeft2 U_Shift (
        .inData(w_signExtImm),
        .outData(w_shiftedImm)
    );

    // Mux4: Decide siguiente PC (PC+4 vs Branch Target)
    Mux4 U_Mux_Branch (
        .pcPlus4(w_pc_plus_4),
        .branchTarget(w_branchTarget),
        .pcSrc(w_pcSrc),                 // CORREGIDO: Usamos .pcSrc en vez de .sel
        .nextPcBranch(w_pc_next_branch)  // Va hacia Mux5
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

    // Mux1: Decide dato a escribir en registro (ALU Result vs Memoria)
    Mux1 U_Mux_MemToReg (
        .aluResult(w_aluResult),
        .memData(w_memDataOut),
        .memToReg(w_memtoReg),           // CORREGIDO: Usamos .memToReg en vez de .sel
        .writeData(w_write_data)
    );

endmodule
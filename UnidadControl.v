`timescale 1ns/1ns
module Control(
    input [5:0] opCode,      
    output reg regDst,
    output reg branch,
    output reg memRead,
    output reg memtoReg,
    output reg [2:0] aluOp,  // <--- CAMBIADO A 3 BITS
    output reg memWrite,
    output reg aluSrc,
    output reg regWrite,
    output reg jump          // <--- NUEVA SALIDA
);

    always @* begin
        // Valores por defecto
        regDst    = 0;
        branch    = 0;
        memRead   = 0;
        memtoReg  = 0;
        aluOp     = 3'b000;
        memWrite  = 0;
        aluSrc    = 0;
        regWrite  = 0;
        jump      = 0;

        case (opCode)
            // --- TIPO R ---
            6'b000000: begin
                regDst    = 1;
                regWrite  = 1;
                aluOp     = 3'b010; // "Mira el funct"
            end

            // --- JUMP (J) ---
            6'b000010: begin
                jump      = 1;
            end

            // --- BEQ ---
            6'b000100: begin
                branch    = 1;
                aluOp     = 3'b001; // Resta
            end

            // --- I-TYPE: ARITMÉTICAS/LÓGICAS ---
            // ADDI
            6'b001000: begin
                aluSrc    = 1;
                regWrite  = 1;
                regDst    = 0;
                aluOp     = 3'b000; // Suma
            end
            // SLTI
            6'b001010: begin
                aluSrc    = 1;
                regWrite  = 1;
                regDst    = 0;
                aluOp     = 3'b110; // SLT
            end
            // ANDI
            6'b001100: begin
                aluSrc    = 1;
                regWrite  = 1;
                regDst    = 0;
                aluOp     = 3'b011; // AND
            end
            // ORI
            6'b001101: begin
                aluSrc    = 1;
                regWrite  = 1;
                regDst    = 0;
                aluOp     = 3'b100; // OR
            end
            // XORI
            6'b001110: begin
                aluSrc    = 1;
                regWrite  = 1;
                regDst    = 0;
                aluOp     = 3'b101; // XOR
            end

            // --- MEMORIA ---
            // LW
            6'b100011: begin
                aluSrc    = 1;
                memtoReg  = 1;
                regWrite  = 1;
                memRead   = 1;
                aluOp     = 3'b000; // Suma
            end
            // SW
            6'b101011: begin
                aluSrc    = 1;
                memWrite  = 1;
                aluOp     = 3'b000; // Suma
            end
        endcase
    end
endmodule
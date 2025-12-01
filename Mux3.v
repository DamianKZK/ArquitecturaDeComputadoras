module Mux3(
    input [31:0] readData2,    // Entrada 0 (Del banco de registros)
    input [31:0] signExtImm,   // Entrada 1 (Del Sign Extend)
    input aluSrc,              // Selector
    output [31:0] aluInputB    // Salida hacia puerto B de la ALU
);
    assign aluInputB = (aluSrc) ? signExtImm : readData2;
endmodule
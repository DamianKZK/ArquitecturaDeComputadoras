`timescale 1ns/1ns

module Mux5(
    input [31:0] nextPcBranch, // Entrada 0 (Viene del Mux4)
    input [31:0] jumpTarget,   // Entrada 1 (Direccion de Jump)
    input jump,                // Selector (Señal Jump de Control)
    output [31:0] finalPC      // Salida final hacia el módulo PC
);
    assign finalPC = (jump) ? jumpTarget : nextPcBranch;

endmodule

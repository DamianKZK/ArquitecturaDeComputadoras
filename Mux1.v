`timescale 1ns/1ns
module Mux1(
    input [31:0] aluResult,    // Entrada 0
    input [31:0] memData,      // Entrada 1
    input memToReg,            // Selector
    output [31:0] writeData    // Salida hacia Banco de Registros
);
    assign writeData = (memToReg) ? memData : aluResult;

endmodule

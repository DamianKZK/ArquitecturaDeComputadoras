module Mux4(
    input [31:0] pcPlus4,      // Entrada 0
    input [31:0] branchTarget, // Entrada 1 (Direccion calculada del salto)
    input pcSrc,               // Selector (Branch AND Zero)
    output [31:0] nextPcBranch // Salida hacia el Mux5
);
    assign nextPcBranch = (pcSrc) ? branchTarget : pcPlus4;
endmodule
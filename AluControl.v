`timescale 1ns/1ns
module AluControl(
    input [5:0] funct,
    input [2:0] aluOP,      // <--- CAMBIADO A 3 BITS
    output reg [2:0] aluSel
);

    always @* begin
        case (aluOP)
            // LW, SW, ADDI -> Suma
            3'b000: aluSel = 3'd0; 
            
            // BEQ -> Resta
            3'b001: aluSel = 3'd1;

            // TIPO R (Miramos funct)
            3'b010: begin
                case (funct)
                    6'b100000: aluSel = 3'd0; // ADD
                    6'b100010: aluSel = 3'd1; // SUB
                    6'b100100: aluSel = 3'd2; // AND
                    6'b100101: aluSel = 3'd3; // OR
                    6'b101010: aluSel = 3'd4; // SLT
                    
                    default:   aluSel = 3'd0;
                endcase
            end

            // I-TYPE ESPECÍFICOS (Vienen directo del Control)
            3'b011: aluSel = 3'd2; // ANDI -> AND
            3'b100: aluSel = 3'd3; // ORI  -> OR
            3'b101: aluSel = 3'd5; // XORI -> XOR
            3'b110: aluSel = 3'd4; // SLTI -> SLT

            default: aluSel = 3'd0;
        endcase
    end
endmodule
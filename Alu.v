`timescale 1ns/1ns

module ALUZeroFlag(
    input [31:0] a, b,
    input [2:0] sel,
    output reg [31:0] out,
    output reg zeroFlag
);

always @* begin
    case(sel)
        3'd0: out = a + b;       
        3'd1: out = a - b;        
        3'd2: out = a & b;        
        3'd3: out = a | b;        
        3'd4: out = (a < b) ? 32'd1 : 32'd0; // SLT
        3'd5: out = a ^ b;        // XOR (NUEVO para XORI)
        
        default: out = 32'b0;
    endcase

    zeroFlag = (out == 32'b0);
end
endmodule
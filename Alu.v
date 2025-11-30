`timescale 1ns/1ns
module ALU(
input reg[31:0] a, b,
input reg[2:0] sel,
output reg[31:0] out
);

always @* begin
case(sel)
3'd0: out = a + b;
3'd1: out = a - b;
3'd2: out = (a > b) ? 3'b1 : 3'b0;
3'd3: out = a & b;
3'd4: out = a | b;
3'd5: out = a ^ b;

endcase
end

endmodule
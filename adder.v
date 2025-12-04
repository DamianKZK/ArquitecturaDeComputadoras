`timescale 1ns/1ns
module PCadder(
    input [31:0] pcIn,  
    output [31:0] pcOut  
);
    assign pcOut = pcIn + 4;

endmodule

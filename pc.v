`timescale 1ns/1ns

module pc(
        input clk,
        input reg [31:0] counterIn,
        output reg [31:0] counterOut
    );

    initial begin 
        counterOut = 32'b0;
    end

    always @(clk) begin
        counterOut = counterIn + 4;
    end

endmodule

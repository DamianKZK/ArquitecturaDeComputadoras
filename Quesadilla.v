`timescale 1ns/1ns

module programCounter(
    input clk,
    input [31:0] counterIn,
    output reg [31:0] counterOut
);
    initial begin 
        counterOut = 32'b0;
    end

    always @(posedge clk) begin
        counterOut <= counterIn;
    end
endmodule

module adder(
    input [31:0] op1,
    input [31:0] op2,
    output [31:0] res
);
    assign res = op1 + op2;
endmodule

module memInstr(
    input [31:0] dirIn,
    output reg [31:0] valueOut
);
    reg [31:0] Bank[0:255];

    initial begin
        $readmemb("Quesadilla/data.txt", Bank);
    end

    always @(dirIn) begin
        valueOut = Bank[dirIn];
    end
endmodule

module quesadilla(
    input clk,
    output [31:0] valueOut
);
    wire [31:0] wPcIn, wPcOut;

    programCounter pc(
        .clk(clk),
        .counterIn(wPcIn),
        .counterOut(wPcOut)
    );

    adder add(
        .op1(32'd4),
        .op2(wPcOut),
        .res(wPcIn)
    );

    memInstr memory(
        .dirIn(wPcOut),
        .valueOut(valueOut)
    );
endmodule

module QuesadillaTB();
    reg clk = 0;
    wire [31:0] InstQ_TB;

    quesadilla UUT (
        .clk(clk),
        .valueOut(InstQ_TB)
    );

    always #50 clk = ~clk;

    initial begin
        #350;
        $stop;
    end
endmodule
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

module Control(
        input[4:0] instr,
        output regDst,
        output branch,
        output memRead,
        output memtoReg,
        output[2:0] aluOp,
        output memWrite,
        output aluSrc,
        output regWrite
    );

    

endmodule

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

module ALUZeroFlag(
    input reg[31:0] a, b,
    input reg[2:0] sel,
    output reg[31:0] out,
    output reg zeroFlag
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

    zeroFlag = (out == 32'b0);
end

endmodule

module RAM(
    input reg memRead,
    input reg memWrite,
    input reg [31:0] addrIn,
    input reg [31:0] dataIn,
    output reg [31:0] dataOut
);
    
    reg[31:0] memory [0:255];

    always@* begin
        if(memRead) begin
            dataOut = memory[addrIn];
        end
        if(memWrite) begin 
            memory[addrIn] = dataIn;
        end
    end

endmodule

module signExtend( // Untested
        input [15:0]inInm,
        output [31:0]outInm
    );
//se repite 16 veces el bit de signo y se concatena con la entrada
assign outInm ={{16{inInm[15]}}, inInm};

endmodule 

module registerBank(

    input reg[4:0] readReg1,    //Dirección del registro 1 a leer
    input reg[4:0] readReg2,    //Dirección del registro 2 a leer
    input reg[4:0] writeReg,    //Dirección donde se va a escribir

    input reg[31:0] writeData,  //Que se va a escribir

    input regWrite,             //Señal de control, indica si se puede escribir

    output reg[31:0] readData1, //Dato que sale de la direccion 1 
    output reg[31:0] readData2  //Dato que sale e la direccion 2
);


reg[31:0] Bank[0:255];

initial begin
$readmemb("data.txt", Bank);
end

always @* begin

readData1 = Bank[readReg1];
readData2 = Bank[readReg2];

if(regWrite) begin

Bank[writeReg] = writeData;

end

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
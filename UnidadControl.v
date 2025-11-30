`timescale 1ns/1ns
module Control(
        input[5:0] opCode,
        output reg regDst,
        output reg branch,
        output reg memRead,
        output reg memtoReg,
        output reg[1:0] aluOp,
        output reg memWrite,
        output reg aluSrc,
        output reg regWrite
    );


    always @* begin
            //iniciamos todo en
            regDst = 0;
            branch = 0;
            memRead = 0;
            memtoReg = 0;
            aluOp = 2'b0;
            memWrite = 0;
            aluSrc = 0;
            regWrite = 0;
   

            case (opCode)
                //las instrucciones tipo R tienen el OpCode en 0´s, por lo tanto:
                6'b000000: begin
                        regDst = 1;
                        regWrite = 1;
                        aluOp = 2'b10;
                end
                6'b100011:begin
                        regDst = 0;
                        aluSrc= 1;
                        memtoReg = 1;
                        regWrite = 1;
                        memRead = 1;
                        memWrite = 0;
                        aluOp = 2'b00;
                        regDst = 0;
                end
                6'b101011:begin
                        aluSrc = 1;
                        memWrite = 1;
                        aluOp = 2'b00;
                end
                6'b000100:begin
                        branch = 1;
                        aluOp = 2'b01;

                end

            endcase
            
        end


endmodule
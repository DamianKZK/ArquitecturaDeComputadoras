module RAM(
    input clk,              
    input memRead,
    input memWrite,
    input [31:0] addrIn,
    input [31:0] dataIn,
    output reg[31:0] dataOut
);
    

    reg[31:0] memory [0:255];
    
    initial begin
        $readmemb("RAM.txt", memory); //Falta el archivo
    end

    always@* begin
        if(memRead) begin
            dataOut = memory[addrIn];
        end
        if(memWrite) begin 
            memory[addrIn] = dataIn;
        end
    end

endmodule
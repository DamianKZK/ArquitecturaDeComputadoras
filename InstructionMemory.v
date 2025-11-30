module InstructionMemory(
	input [31:0]address,      //viene de pc
	output [31:0] instruction //va hacia unidad de control y registros
	);
	

	reg [31:0]memory[0:255];


	initial begin
        $readmemb("memoria.txt", memory); //Falta el archivo
    end


endmodule
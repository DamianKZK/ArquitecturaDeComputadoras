module Mux2(
    input [4:0] rt_addr,  
    input [4:0] rd_addr,  
    input regDst,          
    output [4:0] writeReg  
);
    assign writeReg = (regDst) ? rd_addr : rt_addr;
endmodule
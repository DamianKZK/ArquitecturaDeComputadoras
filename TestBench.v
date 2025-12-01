`timescale 1ns/1ns

module Testbench;

    // 1. Señales de control
    reg clk;
    reg reset;

    // 2. Instancia del Procesador (Unit Under Test)
    DataPath UUT (
        .clk(clk),
        .reset(reset)
    );

    // 3. Generación del Reloj (50 MHz -> Periodo 20ns)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // 4. Secuencia de Prueba
    initial begin
        // A. Estado Inicial: Reset activado
        reset = 1; 
        #40;       // Esperar 2 ciclos para asegurar limpieza
        
        // B. Inicio: Soltamos el Reset
        reset = 0;
        
        // C. Ejecución: Dejamos correr el tiempo suficiente 
        // para que se ejecuten las instrucciones de memoria.txt
        #500; 

        // D. Pausa: Detiene la simulación para que inspecciones las ondas
        $stop; 
    end

endmodule
MIPS Single-Cycle DataPath

Este repositorio contiene la implementación en Verilog de la Ruta de Datos (DataPath) para un procesador arquitectura MIPS de ciclo único (Single-Cycle).

El módulo DataPath actúa como el bloque principal que interconecta la Unidad de Control, la ALU, las Memorias (Instrucciones y Datos) y el Banco de Registros para ejecutar instrucciones de 32 bits.

Descripción General

El módulo integra las 5 etapas clásicas de la ejecución de una instrucción:

Fetch (Búsqueda): Obtención de la instrucción desde la memoria.

Decode (Decodificación): Lectura de registros y extensión de signo.

Execute (Ejecución): Operaciones aritméticas/lógicas en la ALU y cálculo de direcciones de salto.

Memory (Memoria): Lectura o escritura en la memoria de datos (RAM).

Write Back (Escritura): Escritura del resultado en el banco de registros.

Gestión del Program Counter (PC)

pc: Registro que guarda la dirección de la instrucción actual.

PCadder: Sumador simple que incrementa el PC en 4 bytes.

Mux4 (Branch Mux): Decide si el siguiente PC es PC+4 o la dirección de salto (Branch Target) basándose en la señal ZeroFlag y Branch.

Memorias

InstructionMemory: Almacena el código del programa.

RAM: Memoria de datos para instrucciones lw y sw.

Unidad de Control y Decodificación

Control: Unidad de Control principal. Decodifica el opcode (bits 31:26).

registerBank: Banco de 32 registros de propósito general.

signExtend: Extiende inmediatos de 16 bits a 32 bits.

Mux2 (RegDst): Selecciona si la dirección de escritura es rt (bits 20:16) o rd (bits 15:11).

Ejecución (ALU)

AluControl: Determina la operación específica de la ALU basándose en el campo funct y ALUOp.

ALUZeroFlag: Unidad Lógica Aritmética principal. Genera el resultado y la bandera Zero.

Mux3 (ALUSrc): Selecciona la segunda entrada de la ALU (Dato de registro o Inmediato extendido).

shiftLeft2: Desplaza el inmediato extendido para calcular offsets de saltos.

Write Back

Mux1 (MemToReg): Selecciona qué dato se escribe en el registro destino (Resultado de la ALU o Dato leído de Memoria).

Diagrama de Flujo de Datos

El flujo de la señal sigue el estándar MIPS:

PC direcciona la Instruction Memory.

La instrucción se divide (Slicing) para alimentar la Control Unit y el Register Bank.

La Control Unit configura los Multiplexores y la ALU.

La ALU procesa los operandos.

Si es un Branch, se calcula el nuevo PC.

Si es acceso a memoria (Load/Store), se interactúa con la RAM.

El resultado final se escribe de vuelta en el Register Bank.

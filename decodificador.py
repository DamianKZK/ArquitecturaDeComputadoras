import tkinter
from tkinter import filedialog

# --- Diccionarios de Opcodes y Funct ---

# Tipo R: Opcode es 000000, se identifica por el FUNCT
Tipo_R = {
    "add": "100000",
    "sub": "100010",
    "or":  "001101", # Nota: MIPS estandar suele ser 100101, pero mantengo tu valor
    "and": "100100",
    "slt": "101010"
}

# Tipo I: Se identifica por el OPCODE
Tipo_I = {
    "lw":  "100011",
    "sw":  "101011",
    "beq": "000100", # Branch on Equal (tu "bq")
    "addi":"001000"
}

# Tipo J: Se identifica por el OPCODE
Tipo_J = {
    "j":   "000010",
    "jal": "000011"
}

def entero_a_binario(numero, bits):
    """Convierte int a binario respetando negativos (complemento a 2)"""
    val = int(numero)
    if val < 0:
        val = (1 << bits) + val
    return format(val, f'0{bits}b')

def decodificar_linea(instruccion):
    try:
        # Limpieza básica
        instruccion = instruccion.strip()
        # Separar por comas primero para facilitar sintaxis tipo lw
        partes_crudas = instruccion.replace(",", " ").split()
        operacion = partes_crudas[0].lower()

        # ------------------- TIPO R -------------------
        if operacion in Tipo_R:
            # Formato: add $rd, $rs, $rt
            rd = int(partes_crudas[1].replace("$", ""))
            rs = int(partes_crudas[2].replace("$", ""))
            rt = int(partes_crudas[3].replace("$", ""))

            op = "000000"
            shamt = "00000"
            funct = Tipo_R[operacion]

            return f"{op}_{format(rs, '05b')}_{format(rt, '05b')}_{format(rd, '05b')}_{shamt}_{funct}"

        # ------------------- TIPO I -------------------
        elif operacion in Tipo_I:
            op = Tipo_I[operacion]
            
            # Caso 1: LW y SW (Sintaxis: lw $rt, offset($rs))
            if operacion in ["lw", "sw"]:
                # partes_crudas ejemplo: ['lw', '$1', '100($2)']
                rt_val = int(partes_crudas[1].replace("$", ""))
                
                # Desglosar '100($2)'
                offset_rs = partes_crudas[2].replace(")", "") # queda '100($2'
                offset_str, rs_str = offset_rs.split("(")     # queda '100' y '$2'
                
                offset = int(offset_str)
                rs_val = int(rs_str.replace("$", ""))
                
                bin_rs = format(rs_val, '05b')
                bin_rt = format(rt_val, '05b')
                bin_imm = entero_a_binario(offset, 16)

                return f"{op}_{bin_rs}_{bin_rt}_{bin_imm}"

            # Caso 2: BEQ (Sintaxis: beq $rs, $rt, offset)
            else:
                rs = int(partes_crudas[1].replace("$", ""))
                rt = int(partes_crudas[2].replace("$", ""))
                imm = int(partes_crudas[3]) # Offset numérico
                
                bin_rs = format(rs, '05b')
                bin_rt = format(rt, '05b')
                bin_imm = entero_a_binario(imm, 16)

                return f"{op}_{bin_rs}_{bin_rt}_{bin_imm}"

        # ------------------- TIPO J -------------------
        elif operacion in Tipo_J:
            op = Tipo_J[operacion]
            target = int(partes_crudas[1])
            
            bin_target = format(target, '026b')
            
            return f"{op}_{bin_target}"

        else:
            return f"Operación '{operacion}' no reconocida"

    except Exception as e:
        return f"Error sintaxis: {e}"

def convertir_manual():
    instrucciones = entrada.get("1.0", "end-1c").strip().splitlines()
    resultado = ""
    for idx, linea in enumerate(instrucciones, start=1):
        if not linea.strip():
            continue
        binario = decodificar_linea(linea)
        resultado += f"{binario}\n"
    mostrar_resultado(resultado)

def mostrar_resultado(res):
    entrada.delete("1.0", tkinter.END)
    entrada.insert(tkinter.END, res)

def Seleccionar():
    ruta = filedialog.askopenfilename(
        title="Selecciona un archivo de texto",
        filetypes=[("Archivos de texto", "*.txt")]
    )
    if not ruta:
        return
    resultado = ""
    try:
        with open(ruta, "r") as archivo:
            lineas = archivo.readlines()
            for linea in lineas:
                if not (linea := linea.strip()):
                    continue
                binario = decodificar_linea(linea)
                resultado += f"{binario}\n"
        mostrar_resultado(resultado)
    except Exception as e:
        mostrar_resultado(f"Error al abrir el archivo: {e}")

def guardar():
    contenido = entrada.get("1.0", "end-1c")
    with open("Binarios.txt", "a") as binarios:
        binarios.write(contenido + "\n")
    
    ventana_exito = tkinter.Toplevel()
    ventana_exito.configure(bg="grey30")
    ventana_exito.title("Guardado")
    ventana_exito.geometry("300x100")   
    TextoE = tkinter.Label(ventana_exito, text="¡Guardado exitosamente!", bg="royalblue", fg="white", font=("BOLD", 12))
    TextoE.pack(expand=True)

# --- Interfaz gráfica ---
ventana = tkinter.Tk()
ventana.title("Decodificador MIPS (R, I, J)")
ventana.geometry("550x550")
ventana.configure(bg="grey20")

etiqueta = tkinter.Label(ventana, text="Decodificador MIPS Completo", fg="white", font=("TimesNewRoman", 20), bg="grey10")
etiqueta.pack(fill=tkinter.X)

info_text = "Ejemplos:\nadd $1, $2, $3\nlw $1, 100($2)\nbeq $1, $2, 25\nj 2500"
TextoB = tkinter.Label(ventana, text=info_text, bg="royalblue", fg="white", font=("BOLD", 11), justify="left")
TextoB.pack(pady=10)

entrada = tkinter.Text(ventana, width=60, height=12, bg="grey50", font=("Consolas", 10))
entrada.pack(pady=5)

botonD = tkinter.Button(ventana, text="Decodificar", command=convertir_manual, bg="darkblue", fg="white", font=("BOLD", 10))
botonD.place(relx=0.5, rely=0.70, anchor="center")

botonT = tkinter.Button(ventana, text="Cargar Archivo .txt", command=Seleccionar, bg="darkblue", fg="white")
botonT.place(relx=0.5, rely=0.80, anchor="center")

botonG = tkinter.Button(ventana, text="Guardar", command=guardar, bg="darkblue", fg="white")
botonG.place(relx=0.90, rely=0.95, anchor="se")

botonS = tkinter.Button(ventana, text="Salir", command=ventana.quit, bg="darkblue", fg="white")
botonS.place(relx=0.10, rely=0.95, anchor="sw")

ventana.mainloop()
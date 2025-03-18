%{
/*
 Descripción del Programa

El presente programa es un Analizador Léxico desarrollado utilizando la herramienta Flex (Fast Lexical Analyzer Generator). El objetivo principal del analizador léxico es identificar y clasificar correctamente los componentes básicos de un lenguaje específico a partir de un código fuente.

El analizador reconoce diferentes categorías de tokens como palabras reservadas, identificadores, símbolos especiales, operadores aritméticos, relacionales y de asignación, así como constantes numéricas (enteras y reales) y cadenas literales. Además, ignora comentarios y maneja errores léxicos, mostrando información útil sobre estos últimos en la salida estándar.

El programa estructura la información obtenida en tres tablas:
	•	Tabla de Tokens: Contiene los tokens reconocidos con su clasificación y posición respectiva.
	•	Tabla de Símbolos: Almacena los identificadores encontrados en el código.
	•	Tabla de Literales: Guarda cadenas y constantes numéricas detectadas.

Cada una de estas tablas se exporta en archivos separados (tokens.txt, simbolos.txt y literales.txt) para facilitar posteriores etapas de análisis sintáctico y semántico.

⸻

Autores del Programa:
	•	Yaretzi Calzontzi Hernández
	•	Emilio Sebastián Contreras Colmenero

Fecha de elaboracion: 15/03/25
   -----------------------------------------------------------------------
   INSTRUCCIONES DE CABECERA
   -----------------------------------------------------------------------
   Este bloque se utiliza para incluir bibliotecas de C y declaraciones 
   globales. También definimos estructuras para la tabla de símbolos, 
   tabla de literales y la tabla de tokens. 
*/

#include <stdio.h>
#include <string.h>

#define MAX_TOKENS 300

/* Estructura para la tabla de símbolos (identificadores).
   Cada identificador tiene:
   - pos: índice en la tabla
   - nombre: el texto del identificador
   - tipo: por defecto -1, ya que no se define en esta etapa. 
*/
typedef struct {
    int pos;
    char nombre[50];
    int tipo; 
} Simbolo;

/* Estructura para la tabla de literales (cadenas y constantes numéricas).
   Cada literal tiene:
   - pos: índice en la tabla
   - dato: el texto de la cadena o número */
typedef struct {
    int pos;
    char dato[100];
} Literal;

/* Estructura para la tabla de tokens.
   Cada token tiene:
   - clase: el código de la clase (0=reservada, 1=símbolo, 2=ident, etc.)
   - posicion: el índice dentro de su tabla (o -1 si no aplica) */
typedef struct {
    int clase;      
    int posicion;   
} TokenInfo;

/* Declaración de tablas globales:
   - tabla_simbolos (identificadores)
   - tabla_literales (cadenas, números)
   - tabla_tokens (lista de todos los tokens capturados) 
*/
Simbolo tabla_simbolos[MAX_TOKENS];
int simbolos_count = 0;

Literal tabla_literales[MAX_TOKENS];
int literales_count = 0;

TokenInfo tabla_tokens[MAX_TOKENS];
int token_count = 0;

/* Declaración de los archivos de salida */
FILE *archivo_tokens = NULL;
FILE *archivo_simbolos = NULL;
FILE *archivo_literales = NULL;

/* 
   Tablas predefinidas con las palabras reservadas, símbolos especiales,
   operadores aritméticos, operadores relacionales y operadores de asignación.
   Cada una tiene una posición fija en dichas tablas.
*/

/* Palabras reservadas (clase 0) */
const char *palabras_reservadas[] = {
    "Bool", "Cade", "Continuar", "Devo", "Ent", "Fals", "Flota", "Global",
    "Haz", "Mientras", "Nulo", "Para", "Parar", "Si", "Sino", "Ver"
};
const int total_palabras_reservadas = 16;

/* Símbolos especiales (clase 1) */
const char *simbolos_especiales[] = {
    "<", ">", "<<", ">>", "#", "#!", "*", "|", "•"
};
const int total_simbolos_especiales = 9;

/* Operadores aritméticos (clase 3) */
const char *operadores_aritmeticos[] = {
    "sum", "rest", "mult", "div", "mod", "inc", "dec", "exp", "dive"
};
const int total_operadores_aritmeticos = 9;

/* Operadores relacionales (clase 4) */
const char *operadores_relacionales[] = {
    "h", "m", "e", "c", "he", "me"
};
const int total_operadores_relacionales = 6;

/* Operadores de asignación (clase 5) */
const char *operadores_asignacion[] = {
    "->", "+->", "-->", "*->", "/->", "%->", ">>->", "<<->", "^->", "&->"
};
const int total_operadores_asignacion = 10;

/* 
   -----------------------------------------------------------------------
   DECLARACIÓN DE FUNCIONES
   -----------------------------------------------------------------------
   Funciones para buscar y asignar posiciones, así como para imprimir
   las tablas resultantes.
*/

/* 
   buscar_posicion:
   Busca el valor 'valor' en la tabla[] de cadenas, devolviendo el índice
   si lo encuentra, o -1 en caso contrario.
*/
int buscar_posicion(const char *valor, const char *tabla[], int total) {
    for (int i = 0; i < total; i++) {
        if (strcmp(tabla[i], valor) == 0) {
            return i;
        }
    }
    return -1; 
}

/* 
   obtener_posicion_simbolo:
   Busca el identificador 'nombre' en la tabla de símbolos (tabla_simbolos).
   Si existe, devuelve su índice. Si no, lo inserta y devuelve el nuevo índice.
*/
int obtener_posicion_simbolo(const char* nombre) {
    for (int i = 0; i < simbolos_count; i++) {
        if (strcmp(tabla_simbolos[i].nombre, nombre) == 0) {
            return i; 
        }
    }
    if (simbolos_count < MAX_TOKENS) {
        tabla_simbolos[simbolos_count].pos = simbolos_count;
        strcpy(tabla_simbolos[simbolos_count].nombre, nombre);
        tabla_simbolos[simbolos_count].tipo = -1;
        return simbolos_count++;
    }
    return -1; 
}

/* 
   obtener_posicion_literal:
   Busca el literal 'dato' en la tabla de literales. 
   Si existe, devuelve su índice; si no, lo inserta.
*/
int obtener_posicion_literal(const char* dato) {
    for (int i = 0; i < literales_count; i++) {
        if (strcmp(tabla_literales[i].dato, dato) == 0) {
            return i; 
        }
    }
    if (literales_count < MAX_TOKENS) {
        tabla_literales[literales_count].pos = literales_count;
        strcpy(tabla_literales[literales_count].dato, dato);
        return literales_count++;
    }
    return -1; 
}

/* 
   agregar_token:
   Determina la posición 'pos' del valor 'valor' según su clase. 
   Si es una palabra reservada (clase=0), operador aritmético (clase=3), etc.,
   lo busca en las tablas predefinidas. 
   Si es identificador (clase=2), se guarda en tabla_simbolos.
   Si es literal (cadena, entero o real) se guarda en tabla_literales.
   Si es error (clase=9), pos=-1. 
   Luego, inserta el token en la lista tabla_tokens, con su clase y posición.
*/
void agregar_token(const char *valor, int clase) {
    int pos = -1;
    switch (clase) {
        case 0: 
            pos = buscar_posicion(valor, palabras_reservadas, total_palabras_reservadas);
            break;
        case 1: 
            pos = buscar_posicion(valor, simbolos_especiales, total_simbolos_especiales);
            break;
        case 3: 
            pos = buscar_posicion(valor, operadores_aritmeticos, total_operadores_aritmeticos);
            break;
        case 4: 
            pos = buscar_posicion(valor, operadores_relacionales, total_operadores_relacionales);
            break;
        case 5: 
            pos = buscar_posicion(valor, operadores_asignacion, total_operadores_asignacion);
            break;
        case 2: {
            pos = obtener_posicion_simbolo(valor);
        } break;
        case 6: 
        case 7: 
        case 8: {
            pos = obtener_posicion_literal(valor);
        } break;
        case 9: 
            pos = -1; 
            break;
    }
    
    /* Si no se encontró pos en tablas predefinidas (y no es error),
       no lo insertamos en la tabla de tokens. */
    if (clase != 9 && pos == -1) {
        return;
    }

    /* Insertar en la tabla de tokens. */
    if (token_count < MAX_TOKENS) {
        tabla_tokens[token_count].clase = clase;
        tabla_tokens[token_count].posicion = pos;
        token_count++;
    }
}

/* 
   -----------------------------------------------------------------------
   FUNCIONES PARA IMPRIMIR LAS TABLAS
   -----------------------------------------------------------------------
   Cada función escribe el resultado en el archivo *fp correspondiente.
*/

/* imprimir_tabla_tokens:
   Muestra la lista de tokens, con su clase y su posición (en la tabla predefinida, 
   de símbolos o de literales) */



void imprimir_tabla_tokens(FILE *fp) {
    fprintf(fp, "\n===== TABLA DE TOKENS =====\n");
    fprintf(fp, "| %-5s | %-10s |\n", "Clase", "Posición");
    fprintf(fp, "|------------------|\n");
    for (int i = 0; i < token_count; i++) {
        fprintf(fp, "| %-5d | %-10d |\n",
                tabla_tokens[i].clase,
                tabla_tokens[i].posicion);
    }
    fprintf(fp, "==========================\n");
}
/* imprimir_tabla_simbolos:
   Muestra la tabla de identificadores con pos, nombre y tipo. */

void imprimir_tabla_simbolos(FILE *fp) {
    fprintf(fp, "\n===== TABLA DE SÍMBOLOS (IDENT) =====\n");
    fprintf(fp, "| %-5s | %-15s | %-5s |\n", "Pos", "Nombre", "Tipo");
    fprintf(fp, "|--------------------------------|\n");
    for (int i = 0; i < simbolos_count; i++) {
        fprintf(fp, "| %-5d | %-15s | %-5d |\n",
            tabla_simbolos[i].pos,
            tabla_simbolos[i].nombre,
            tabla_simbolos[i].tipo);
    }
    fprintf(fp, "================================\n");
}
/* imprimir_tabla_literales:
   Muestra las cadenas, enteros, reales detectados y su posición. */

void imprimir_tabla_literales(FILE *fp) {
    fprintf(fp, "\n===== TABLA DE LITERALES =====\n");
    fprintf(fp, "| %-5s | %-15s |\n", "Pos", "Valor");
    fprintf(fp, "|-----------------------|\n");
    for (int i = 0; i < literales_count; i++) {
        fprintf(fp, "| %-5d | %-15s |\n",
            tabla_literales[i].pos,
            tabla_literales[i].dato);
    }
    fprintf(fp, "=======================\n");
}
%}

%%



[ \t\n]+  {  }



"Bool"|"Cade"|"Continuar"|"Devo"|"Ent"|"Fals"|"Flota"|"Global"|"Haz"|"Mientras"|"Nulo"|"Para"|"Parar"|"Si"|"Sino"|"Ver" {
    agregar_token(yytext, 0);
    printf("[CLASE 0 - Pal.Res]: %s\n", yytext);
}

"<"|"<<"|">"|">>"|"#"|"#! "|"*"|"|"|"•" {
    agregar_token(yytext, 1);
    printf("[CLASE 1 - Símb.Esp]: %s\n", yytext);
}

@([A-Za-zÑñÁÉÍÓÚÜáéíóúü0-9]*)_ {
    agregar_token(yytext, 2);
    printf("[CLASE 2 - Identif]: %s\n", yytext);
}

"sum"|"rest"|"mult"|"div"|"mod"|"inc"|"dec"|"exp"|"dive" {
    agregar_token(yytext, 3);
    printf("[CLASE 3 - Op.Aritm]: %s\n", yytext);
}

"h"|"m"|"e"|"c"|"he"|"me" {
    agregar_token(yytext, 4);
    printf("[CLASE 4 - Op.Relac]: %s\n", yytext);
}

"->"|"+->"|"-->"|"*->"|"/->"|"%->"|"\^->"|"&->" {
    agregar_token(yytext, 5);
    printf("[CLASE 5 - Op.Asig]: %s\n", yytext);
}

--([^-\n]*)-- {
    agregar_token(yytext, 6);
    printf("[CLASE 6 - Cadena]: %s\n", yytext);
}

([+-]?[0-9]*\x27[0-9]+)|([+-]?[0-9]+[rR]) {
    agregar_token(yytext, 8);
    printf("[CLASE 8 - Real]: %s\n", yytext);
}

[+-]?([1-9][0-9]*|0)[pPgG]? {
    agregar_token(yytext, 7);
    printf("[CLASE 7 - Entera]: %s\n", yytext);
}

\[.*?\] {
    printf("[Comentario] %s\n", yytext);
}

[^ \t\n]+ {
    printf("[ Error Lexico]: %s\n", yytext);
}

%%
int main() {
        /* Archivos de salida */

    FILE *archivoTokens = fopen("tokens.txt", "w");
    if (!archivoTokens) {
        printf("No se pudo abrir tokens.txt\n");
        return 1;
    }

    FILE *archivoSimbolos = fopen("simbolos.txt", "w");
    if (!archivoSimbolos) {
        printf("No se pudo abrir simbolos.txt\n");
        return 1;
    }

    FILE *archivoLiterales = fopen("literales.txt", "w");
    if (!archivoLiterales) {
        printf("No se pudo abrir literales.txt\n");
        return 1;
    }

    printf("Analizador Léxico iniciado...\n");
    yylex();

    /* Imprimimos cada tabla en su respectivo archivo */
    imprimir_tabla_tokens(archivoTokens);
    imprimir_tabla_simbolos(archivoSimbolos);
    imprimir_tabla_literales(archivoLiterales);
    
    /* Cerramos los archivos */

    fclose(archivoTokens);
    fclose(archivoSimbolos);
    fclose(archivoLiterales);
    printf("Tablas escritas en archivos tokens.txt, simbolos.txt y literales.txt\n");
    return 0;
}

int yywrap() {
    return 1;
}
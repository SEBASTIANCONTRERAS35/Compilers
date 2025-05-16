/*
-----------------------------------------------------------------------
TABLA DE EQUIVALENCIAS LÉXICAS (Átomos)
-----------------------------------------------------------------------
Asigna un símbolo terminal (átomo) a cada tipo de token.
Útil para alimentar el análisis sintáctico posteriormente.
*/


/*
 * scanner.l – Analizador Léxico y Sintáctico Descendente Recursivo
 * 
 * Este archivo combina:
 * 1) El analizador léxico (Flex) para tokenizar el lenguaje definido en el Anexo A.
 * 2) Un parser LL(1) embebido en C que consume los átomos generados.
 *
 * El analizador léxico identifica:
 * - Palabras reservadas (clase 0) y genera sus átomos.
 * - Símbolos especiales (clase 1).
 * - Identificadores (clase 2).
 * - Operadores aritméticos (clase 3).
 * - Operadores relacionales (clase 4).
 * - Operadores de asignación (clase 5).
 * - Literales (cadenas, enteros, reales).
 * - Comentarios y errores léxicos.
 *
 * El parser embebido recorre la cadena de átomos y verifica la sintaxis según la gramática LL(1).
 * Incluye funciones para cada no-terminal y muestra mensajes de depuración (DEBUG).
 */


Descripción del Programa

El presente programa implementa un Analizador Léxico y Sintáctico Descendente Recursivo, diseñado para procesar programas escritos en un lenguaje específico definido por una gramática LL(1) (ver Anexo A). Su propósito es verificar, en una misma ejecución, tanto la validez léxica como la validez sintáctica del código fuente de entrada.

Este sistema combina dos componentes fundamentales:
	1.	Analizador Léxico (utilizando Flex)
Su función principal es identificar y clasificar correctamente los componentes básicos del lenguaje a partir del código fuente. Reconoce diferentes categorías de tokens, tales como:
	•	Palabras reservadas
	•	Identificadores
	•	Símbolos especiales
	•	Operadores aritméticos, relacionales y de asignación
	•	Constantes numéricas (enteras y reales)
	•	Cadenas literales
Además, ignora comentarios y detecta errores léxicos, mostrando información útil sobre estos en la salida estándar. Los resultados se organizan en tres estructuras principales:
	•	Tabla de Tokens: lista de tokens reconocidos con su clase y posición.
	•	Tabla de Símbolos: identificadores encontrados.
	•	Tabla de Literales: cadenas y constantes numéricas.
Estas tablas se exportan a archivos separados (tokens.txt, simbolos.txt, literales.txt, etc.) para su uso en etapas posteriores del proceso de compilación.
	2.	Analizador Sintáctico Descendente Recursivo (embebido en C)
Este componente consume la secuencia de átomos léxicos generados por el analizador léxico y verifica que la estructura del código fuente siga correctamente las reglas gramaticales definidas. Para ello, implementa funciones recursivas que representan cada uno de los no-terminales de la gramática. Si la estructura del programa es válida, se confirma que el análisis fue exitoso; en caso contrario, se reportan los errores sintácticos detectados.

⸻

Autores del Programa:
•	Yaretzi Calzontzi Hernández
•	Emilio Sebastián Contreras Colmenero

Fecha de elaboracion: 16/05/25
-----------------------------------------------------------------------
INSTRUCCIONES DE CABECERA
-----------------------------------------------------------------------
Este bloque se utiliza para incluir bibliotecas de C y declaraciones 
globales. También definimos estructuras para la tabla de símbolos, 
tabla de literales y la tabla de tokens. 
*/

/* === INCLUSIÓN DE CABECERAS Y DEFINICIONES GLOBALES === */
%{
#define YY_NO_MAIN 1
/*

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_TOKENS 300

/* ============================================================================
DEFINICIÓN DE ESTRUCTURAS PARA TABLAS DE SÍMBOLOS Y LITERALES
============================================================================ */

/*
Estructura: Simbolo
--------------------------------------------------------------------------
Representa un identificador encontrado durante el análisis léxico.
Cada símbolo tiene:
- pos: posición dentro de la tabla de símbolos
- nombre: nombre textual del identificador
- tipo: tipo de dato asociado (inicialmente se puede dejar como -1)
*/
typedef struct {
    int pos;
    char nombre[50];
    int tipo; 
} Simbolo;

/* ============================================================================
MAPEADO DE CLASES Y POSICIONES A ÁTOMOS LÉXICOS
============================================================================ */

/*
Función: obtener_atomo
--------------------------------------------------------------------------
Recibe como entrada la clase léxica y la posición de un token, y devuelve
el átomo correspondiente (símbolo terminal) que representa ese token en 
el análisis sintáctico.

Este átomo es una versión simplificada del token usada para recorrer
la gramática durante el análisis sintáctico.
*/
const char* obtener_atomo(int clase, int posicion) {
    switch (clase) {
        case 0: { // Palabras reservadas
            switch (posicion) {
                case 0: return "b";  // Bool
                case 1: return "c";  // Cade
                case 2: return "t";  // Continuar
                case 3: return "d";  // Devo
                case 4: return "n";  // Ent
                case 5: return "q";  // Fals
                case 6: return "f";  // Flota
                case 7: return "g";  // Global
                case 8: return "h";  // Haz
                case 9: return "w";  // Mientras
                case 10: return "u"; // Nulo
                case 11: return "o"; // Para
                case 12: return "p"; // Parar
                case 13: return "i"; // Si
                case 14: return "l"; // Sino
                case 15: return "m"; // Ver
                default: return "?";
            }
        }
        case 1: { // Símbolos especiales
            switch (posicion) {
                case 0: return "(";  // <
                case 1: return ")";  // >
                case 2: return "[";  // <<
                case 3: return "]";  // >>
                case 4: return "{";  // #
                case 5: return "}";  // #!
                case 6: return ";";  // *
                case 7: return ",";  // |
                case 8: return ".";  // °
                default: return "?";
            }
        }
        case 2: return "a"; // Identificador
        case 3: { // Operadores aritméticos
            switch (posicion) {
                case 0: return "+";  // sum
                case 1: return "-";  // rest
                case 2: return "*";  // mult
                case 3: return "/";  // div
                case 4: return "%";  // mod
                case 5: return "z";  // inc
                case 6: return "j";  // dec
                case 7: return "k";  // exp
                case 8: return "~";  // dive
                default: return "?";
            }
        }
        case 4: { // Operadores relacionales
            switch (posicion) {
                case 0: return ">";  // h
                case 1: return "<";  // m
                case 2: return "¡";  // e
                case 3: return "!";  // c
                case 4: return "x";  // he
                case 5: return "y";  // me
                default: return "?";
            }
        }
        case 5: { // Operadores de asignación
            switch (posicion) {
                case 0: return "=";   // ->
                case 1: return "#";   // +->
                case 2: return "ñ";   // -->
                case 3: return "$";   // *->
                case 4: return "v";   // /->
                case 5: return "?";   // %->
                case 6: return ":";   // >>->
                case 7: return "\"";  // <<->
                case 8: return "^";   // ^->
                case 9: return "&";   // &->
                default: return "?";
            }
        }
        case 6: return "s"; // Cadena literal
        case 7: return "e"; // Entero
        case 8: return "r"; // Real
        case 9: return "!"; // Error léxico
        default: return "?";
    }
}

/* ============================================================================
DEFINICIÓN DE ESTRUCTURAS PARA LITERALES (CADENAS, REALES, ENTEROS)
============================================================================ */

/*
Estas estructuras representan las constantes encontradas en el código fuente
que no son identificadores ni palabras clave. Se dividen por tipo:
- CadenaLiteral: para textos entre comillas o delimitadores
- RealLiteral: para números con punto decimal
- EnteroLiteral: para números enteros
*/

typedef struct {
    int pos;
    char dato[100];
} CadenaLiteral;

typedef struct {
    int pos;
    double valor;
} RealLiteral;

typedef struct {
    int pos;
    long valor;
} EnteroLiteral;

/* ============================================================================
ESTRUCTURA PARA LA TABLA DE TOKENS
============================================================================ */

/*
Estructura: TokenInfo
--------------------------------------------------------------------------
Representa un token reconocido por el analizador léxico. 
Cada token contiene:
- clase: código que indica el tipo de token (por ejemplo: 0 = palabra reservada,
         1 = símbolo especial, 2 = identificador, etc.)
- posicion: índice en su tabla correspondiente (identificadores, literales, etc.)
            En algunos casos puede ser -1 si no aplica.
*/
typedef struct {
    int clase;      
    int posicion;   
} TokenInfo;

/* ============================================================================
DECLARACIÓN DE TABLAS GLOBALES
============================================================================ */

/*
Estas son las tablas que almacenan los elementos léxicos reconocidos.
Cada una tiene un límite máximo de elementos (MAX_TOKENS).
*/
Simbolo tabla_simbolos[MAX_TOKENS];
int simbolos_count = 0;  // Contador de identificadores

CadenaLiteral cadena_literales[MAX_TOKENS];
int cadena_literales_count = 0;  // Contador de cadenas

RealLiteral real_literales[MAX_TOKENS];
int real_literales_count = 0;  // Contador de números reales

EnteroLiteral entero_literales[MAX_TOKENS];
int entero_literales_count = 0;  // Contador de enteros

TokenInfo tabla_tokens[MAX_TOKENS];
int token_count = 0;  // Contador de tokens generales

/* ============================================================================
DECLARACIÓN DE ARCHIVOS DE SALIDA
============================================================================ */

/*
Archivos de texto utilizados para almacenar las tablas y los errores
detectados durante el análisis. Se generan al ejecutar el programa.
*/
FILE *archivo_tokens = NULL;
FILE *archivo_simbolos = NULL;
FILE *archivo_literales = NULL;
FILE *archivo_cadenas = NULL;
FILE *archivo_enteros = NULL;
FILE *archivo_reales = NULL;
FILE *archivo_errores = NULL;

/* ============================================================================
TABLAS PREDEFINIDAS DE ELEMENTOS DEL LENGUAJE
============================================================================ */

/*
Estas tablas contienen los elementos conocidos del lenguaje que se reconocen 
directamente: palabras clave, símbolos, y operadores.
Cada uno tiene una posición fija que se utiliza para mapearlos a sus respectivos átomos.
*/

/* Palabras reservadas (clase 0) */
const char *palabras_reservadas[] = {
    "Bool", "Cade", "Continuar", "Devo", "Ent", "Fals", "Flota", "Global",
    "Haz", "Mientras", "Nulo", "Para", "Parar", "Si", "Sino", "Ver"
};
const int total_palabras_reservadas = 16;

/* Símbolos especiales (clase 1) */
const char *simbolos_especiales[] = {
    "<", ">", "<<", ">>", "#", "#!", "*", "|", "°"
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
/* ============================================================================
DECLARACIÓN DE FUNCIONES
===============================================================================
Funciones auxiliares utilizadas para:
- Buscar valores existentes en tablas predefinidas
- Insertar nuevos identificadores o literales en sus respectivas tablas
- Evitar duplicados
============================================================================ */

/* ----------------------------------------------------------------------------
buscar_posicion
----------------------------------------------------------------------------
Busca un valor (como un operador o palabra reservada) dentro de una tabla 
de cadenas. Si lo encuentra, devuelve su índice. Si no, retorna -1.

Parámetros:
- valor: cadena a buscar
- tabla: arreglo de cadenas donde buscar
- total: número de elementos en la tabla

Uso típico: localizar un símbolo conocido en tablas como palabras_reservadas,
operadores, etc.
---------------------------------------------------------------------------- */
int buscar_posicion(const char *valor, const char *tabla[], int total) {
    for (int i = 0; i < total; i++) {
        char limpio[50];
        strcpy(limpio, valor);
        limpio[strcspn(limpio, "\n")] = 0; // Elimina salto de línea si existe
        if (strcmp(tabla[i], limpio) == 0) {
            return i;
        }
    }
    return -1; // No encontrado
}

/* ============================================================================
FUNCIONES AUXILIARES: GESTIÓN DE TABLAS DE SÍMBOLOS Y LITERALES
============================================================================ */

/* ----------------------------------------------------------------------------
obtener_posicion_simbolo
----------------------------------------------------------------------------
Busca un identificador (nombre) en la tabla de símbolos.
Si ya existe, devuelve su índice. Si no existe, lo inserta y devuelve su nueva
posición.

Parámetro:
- nombre: identificador a registrar
---------------------------------------------------------------------------- */
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

/* ----------------------------------------------------------------------------
obtener_posicion_literal_cadena
----------------------------------------------------------------------------
Busca una cadena literal en la tabla correspondiente. Si ya existe, devuelve 
su índice. Si no, la inserta y devuelve su nueva posición.

Parámetro:
- dato: cadena literal a registrar
---------------------------------------------------------------------------- */
int obtener_posicion_literal_cadena(const char* dato) {
    for (int i = 0; i < cadena_literales_count; i++) {
        if (strcmp(cadena_literales[i].dato, dato) == 0) {
            return i;
        }
    }
    if (cadena_literales_count < MAX_TOKENS) {
        cadena_literales[cadena_literales_count].pos = cadena_literales_count;
        strcpy(cadena_literales[cadena_literales_count].dato, dato);
        return cadena_literales_count++;
    }
    return -1;
}

/* ----------------------------------------------------------------------------
obtener_posicion_literal_real
----------------------------------------------------------------------------
Convierte una cadena a número real y lo busca en la tabla.
Si ya existe, devuelve su índice. Si no, lo inserta.

Parámetro:
- dato: cadena que representa un número real
---------------------------------------------------------------------------- */
int obtener_posicion_literal_real(const char* dato) {
    double valor = atof(dato);
    for (int i = 0; i < real_literales_count; i++) {
        if (real_literales[i].valor == valor) {
            return i;
        }
    }
    if (real_literales_count < MAX_TOKENS) {
        real_literales[real_literales_count].pos = real_literales_count;
        real_literales[real_literales_count].valor = valor;
        return real_literales_count++;
    }
    return -1;
}

/* ----------------------------------------------------------------------------
obtener_posicion_literal_entero
----------------------------------------------------------------------------
Convierte una cadena a número entero y lo busca en la tabla.
Si ya existe, devuelve su índice. Si no, lo inserta.

Parámetro:
- dato: cadena que representa un número entero
---------------------------------------------------------------------------- */
int obtener_posicion_literal_entero(const char* dato) {
    long valor = strtol(dato, NULL, 10);
    for (int i = 0; i < entero_literales_count; i++) {
        if (entero_literales[i].valor == valor) {
            return i;
        }
    }
    if (entero_literales_count < MAX_TOKENS) {
        entero_literales[entero_literales_count].pos = entero_literales_count;
        entero_literales[entero_literales_count].valor = valor;
        return entero_literales_count++;
    }
    return -1;
}

/* ============================================================================
AGREGAR TOKENS A LA TABLA Y EMITIR ÁTOMOS
===============================================================================
Función: agregar_token
----------------------------------------------------------------------------
Registra un token en la tabla de tokens y genera su representación en forma 
de átomo léxico. También guarda el átomo correspondiente en el archivo 
"atomos.txt", que será utilizado por el analizador sintáctico posterior.

Parámetros:
- valor: texto del token reconocido (ej. "sum", "Bool", "@var_")
- clase: clase léxica (0=pal. reservada, 1=símbolo especial, etc.)
- posicion: índice conocido en su tabla (si ya fue identificado previamente),
            o -1 si debe buscarse

Flujo general:
1. Determina la posición del token dentro de su tabla correspondiente.
2. Registra el token en tabla_tokens.
3. Obtiene su átomo léxico.
4. Imprime y guarda el átomo en el archivo "atomos.txt".
============================================================================ */

void agregar_token(const char *valor, int clase, int posicion) {
    int pos = -1;

    // Si ya se pasó una posición válida, se usa directamente
    if (posicion != -1) {
        pos = posicion;
    } else {
        // Si no, se determina la posición según la clase léxica
        switch (clase) {
            case 1: // Símbolos especiales
                pos = buscar_posicion(valor, simbolos_especiales, total_simbolos_especiales);
                break;
            case 3: // Operadores aritméticos
                pos = buscar_posicion(valor, operadores_aritmeticos, total_operadores_aritmeticos);
                break;
            case 4: // Operadores relacionales
                pos = buscar_posicion(valor, operadores_relacionales, total_operadores_relacionales);
                break;
            case 5: // Operadores de asignación
                pos = buscar_posicion(valor, operadores_asignacion, total_operadores_asignacion);
                break;
            case 2: // Identificadores
                pos = obtener_posicion_simbolo(valor);
                break;
            case 6: // Literales cadena
                pos = obtener_posicion_literal_cadena(valor);
                break;
            case 7: // Literales enteros
                pos = obtener_posicion_literal_entero(valor);
                break;
            case 8: // Literales reales
                pos = obtener_posicion_literal_real(valor);
                break;
            case 9: // Error léxico (no se busca posición)
                pos = -1;
                break;
        }
    }

    // Si no se pudo determinar posición y no es error léxico, no se agrega
    if (clase != 9 && pos == -1) {
        return;
    }

    // Verifica que no se exceda el límite de tokens
    if (token_count < MAX_TOKENS) {
        // Guarda el token con su clase y posición en la tabla principal
        tabla_tokens[token_count].clase = clase;
        tabla_tokens[token_count].posicion = pos;
        token_count++;

        // Obtiene el átomo correspondiente al token
        const char* atomo = obtener_atomo(clase, pos);
        printf("Átomo: %s\n", atomo); // Muestra el átomo por consola

        // Escribe el átomo en el archivo de salida para el parser
        FILE* archivo_atomos = fopen("atomos.txt", "a");
        if (archivo_atomos) {
            fprintf(archivo_atomos, "%s\n", atomo);
            fclose(archivo_atomos);
        }
    }
}

/*
===============================================================================
FUNCIONES PARA IMPRIMIR LAS TABLAS
===============================================================================
Cada una de estas funciones escribe el contenido de las tablas generadas 
durante el análisis léxico en su archivo correspondiente. Estas tablas ayudan 
a documentar lo que el analizador reconoció y pueden usarse en etapas futuras 
como el análisis semántico o generación de código.
===============================================================================
*/

/* ----------------------------------------------------------------------------
imprimir_tabla_tokens
----------------------------------------------------------------------------
Imprime la tabla de tokens reconocidos.
Cada entrada incluye su clase léxica y la posición dentro de su tabla específica.
Se escribe en el archivo apuntado por 'fp'.
---------------------------------------------------------------------------- */
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

/* ----------------------------------------------------------------------------
imprimir_tabla_simbolos
----------------------------------------------------------------------------
Imprime la tabla de símbolos, es decir, los identificadores encontrados.
Cada símbolo incluye:
- posición
- nombre textual
- tipo asociado (si ya fue asignado; -1 por defecto)
---------------------------------------------------------------------------- */
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

/* ----------------------------------------------------------------------------
imprimir_tabla_literales
----------------------------------------------------------------------------
Versión consolidada: imprime en una misma función las tres tablas de literales:
- cadenas
- enteros
- reales

Esta función es útil cuando se desea un único archivo con todos los literales.
---------------------------------------------------------------------------- */
void imprimir_tabla_literales(FILE *fp) {
    // Literales tipo cadena
    fprintf(fp, "\n===== TABLA DE LITERALES (Cadenas) =====\n");
    fprintf(fp, "| %-5s | %-15s |\n", "Pos", "Valor");
    fprintf(fp, "|-----------------------|\n");
    for (int i = 0; i < cadena_literales_count; i++) {
        fprintf(fp, "| %-5d | %-15s |\n",
            cadena_literales[i].pos,
            cadena_literales[i].dato);
    }
    fprintf(fp, "=======================\n");

    // Literales tipo entero
    fprintf(fp, "\n===== TABLA DE LITERALES (Enteros) =====\n");
    fprintf(fp, "| %-5s | %-15s |\n", "Pos", "Valor");
    fprintf(fp, "|-----------------------|\n");
    for (int i = 0; i < entero_literales_count; i++) {
        fprintf(fp, "| %-5d | %-15ld |\n",
            entero_literales[i].pos,
            entero_literales[i].valor);
    }
    fprintf(fp, "=======================\n");

    // Literales tipo real
    fprintf(fp, "\n===== TABLA DE LITERALES (Reales) =====\n");
    fprintf(fp, "| %-5s | %-15s |\n", "Pos", "Valor");
    fprintf(fp, "|-----------------------|\n");
    for (int i = 0; i < real_literales_count; i++) {
        fprintf(fp, "| %-5d | %-15g |\n",
            real_literales[i].pos,
            real_literales[i].valor);
    }
    fprintf(fp, "=======================\n");
}

/* ----------------------------------------------------------------------------
imprimir_tabla_cadenas
----------------------------------------------------------------------------
Imprime exclusivamente los literales tipo cadena en su propio archivo.
---------------------------------------------------------------------------- */
void imprimir_tabla_cadenas(FILE *fp) {
    fprintf(fp, "\n===== TABLA DE CADENAS =====\n");
    fprintf(fp, "| %-5s | %-15s |\n", "Pos", "Valor");
    fprintf(fp, "|-----------------------|\n");
    for (int i = 0; i < cadena_literales_count; i++) {
        fprintf(fp, "| %-5d | %-15s |\n",
            cadena_literales[i].pos,
            cadena_literales[i].dato);
    }
    fprintf(fp, "=======================\n");
}

/* ----------------------------------------------------------------------------
imprimir_tabla_enteros
----------------------------------------------------------------------------
Imprime exclusivamente los literales enteros reconocidos.
---------------------------------------------------------------------------- */
void imprimir_tabla_enteros(FILE *fp) {
    fprintf(fp, "\n===== TABLA DE ENTEROS =====\n");
    fprintf(fp, "| %-5s | %-15s |\n", "Pos", "Valor");
    fprintf(fp, "|-----------------------|\n");
    for (int i = 0; i < entero_literales_count; i++) {
        fprintf(fp, "| %-5d | %-15ld |\n",
            entero_literales[i].pos,
            entero_literales[i].valor);
    }
    fprintf(fp, "=======================\n");
}

/* ----------------------------------------------------------------------------
imprimir_tabla_reales
----------------------------------------------------------------------------
Imprime exclusivamente los literales numéricos reales.
---------------------------------------------------------------------------- */
void imprimir_tabla_reales(FILE *fp) {
    fprintf(fp, "\n===== TABLA DE REALES =====\n");
    fprintf(fp, "| %-5s | %-15s |\n", "Pos", "Valor");
    fprintf(fp, "|-----------------------|\n");
    for (int i = 0; i < real_literales_count; i++) {
        fprintf(fp, "| %-5d | %-15g |\n",
            real_literales[i].pos,
            real_literales[i].valor);
    }
    fprintf(fp, "=======================\n");
}

/* === REGLAS DE FLEX: DE DEFINICIONES LÉXICAS A TOKENS === */

%%

/*
----------------------------------------------------------------------------
Ignora espacios en blanco, tabulaciones y saltos de línea.
Estos caracteres no generan tokens y son descartados por el analizador léxico.
----------------------------------------------------------------------------
*/
[ \t\n]+  {  }

/*
----------------------------------------------------------------------------
Palabras reservadas (CLASE 0)
Se comparan directamente con la lista de palabras definidas y se insertan en
la tabla de tokens como clase 0. Se busca su posición para obtener el átomo.
----------------------------------------------------------------------------
*/
"Bool"|"Cade"|"Continuar"|"Devo"|"Ent"|"Fals"|"Flota"|"Global"|"Haz"|"Mientras"|"Nulo"|"Para"|"Parar"|"Si"|"Sino"|"Ver" {
    int pos = buscar_posicion(yytext, palabras_reservadas, total_palabras_reservadas);
    agregar_token(yytext, 0, pos);
    printf("[CLASE 0 - Pal.Res]: %s (pos: %d)\n", yytext, pos);
}

/*
----------------------------------------------------------------------------
Operadores de asignación (CLASE 5)
Cada uno tiene una posición fija en su tabla, por lo que se pasa directamente.
----------------------------------------------------------------------------
*/
"->"    { agregar_token(yytext, 5, 0); printf("[CLASE 5 - Op.Asig]: %s\n", yytext); }
"+->"   { agregar_token(yytext, 5, 1); printf("[CLASE 5 - Op.Asig]: %s\n", yytext); }
"-->"   { agregar_token(yytext, 5, 2); printf("[CLASE 5 - Op.Asig]: %s\n", yytext); }
"*->"   { agregar_token(yytext, 5, 3); printf("[CLASE 5 - Op.Asig]: %s\n", yytext); }
"/->"   { agregar_token(yytext, 5, 4); printf("[CLASE 5 - Op.Asig]: %s\n", yytext); }
"%->"   { agregar_token(yytext, 5, 5); printf("[CLASE 5 - Op.Asig]: %s\n", yytext); }
">>->"  { agregar_token(yytext, 5, 6); printf("[CLASE 5 - Op.Asig]: %s\n", yytext); }
"<<->"  { agregar_token(yytext, 5, 7); printf("[CLASE 5 - Op.Asig]: %s\n", yytext); }
"^->"   { agregar_token(yytext, 5, 8); printf("[CLASE 5 - Op.Asig]: %s\n", yytext); }
"&->"   { agregar_token(yytext, 5, 9); printf("[CLASE 5 - Op.Asig]: %s\n", yytext); }

/*
----------------------------------------------------------------------------
Símbolos especiales (CLASE 1)
Caracteres individuales o pares que representan puntuación o estructura.
----------------------------------------------------------------------------
*/
"<<" { agregar_token(yytext, 1, -1); printf("[CLASE 1 - Símb.Esp]: <<\n"); }
">>" { agregar_token(yytext, 1, -1); printf("[CLASE 1 - Símb.Esp]: >>\n"); }
"<"  { agregar_token(yytext, 1, -1); printf("[CLASE 1 - Símb.Esp]: <\n"); }
">"  { agregar_token(yytext, 1, -1); printf("[CLASE 1 - Símb.Esp]: >\n"); }
"#!" { agregar_token(yytext, 1, -1); printf("[CLASE 1 - Símb.Esp]: #!\n"); }
"#"  { agregar_token(yytext, 1, -1); printf("[CLASE 1 - Símb.Esp]: #\n"); }
"\*" { agregar_token(yytext, 1, -1); printf("[CLASE 1 - Símb.Esp]: *\n"); }
"\|" { agregar_token(yytext, 1, -1); printf("[CLASE 1 - Símb.Esp]: |\n"); }
"°"  { agregar_token(yytext, 1, -1); printf("[CLASE 1 - Símb.Esp]: °\n"); }

/*
----------------------------------------------------------------------------
Identificadores (CLASE 2)
Reconoce cadenas alfanuméricas con caracteres especiales iniciadas por '@' y
finalizadas con '_'. Se agregan como identificadores.
----------------------------------------------------------------------------
*/
@([A-Za-zÑñÁÉÍÓÚÜáéíóúü0-9]*)_ {
    agregar_token(yytext, 2, -1);
    printf("[CLASE 2 - Identif]: %s\n", yytext);
}

/*
----------------------------------------------------------------------------
Operadores aritméticos (CLASE 3)
Palabras clave asociadas a operaciones matemáticas básicas.
----------------------------------------------------------------------------
*/
"sum"|"rest"|"mult"|"div"|"mod"|"inc"|"dec"|"exp"|"dive" {
    agregar_token(yytext, 3, -1);
    printf("[CLASE 3 - Op.Aritm]: %s\n", yytext);
}

/*
----------------------------------------------------------------------------
Operadores relacionales (CLASE 4)
Símbolos y combinaciones usados para comparar valores.
----------------------------------------------------------------------------
*/
"h"|"m"|"e"|"c"|"he"|"me" {
    agregar_token(yytext, 4, -1);
    printf("[CLASE 4 - Op.Relac]: %s\n", yytext);
}

/*
----------------------------------------------------------------------------
Cadenas literales (CLASE 6)
Delimitadas por -- doble guion --. No se permite contenido con guiones intermedios.
----------------------------------------------------------------------------
*/
--([^-\n]*)-- {
    agregar_token(yytext, 6, -1);
    printf("[CLASE 6 - Cadena]: %s\n", yytext);
}

/*
----------------------------------------------------------------------------
Números reales (CLASE 8)
Reconoce varios formatos válidos de número real con separadores especiales.
----------------------------------------------------------------------------
*/
[+-]?[0-9]+'[0-9]+ {
    agregar_token(yytext, 8, -1);
    printf("[CLASE 8 - Real]: %s\n", yytext);
}
[+-]?[0-9]+’[0-9]+ {
    agregar_token(yytext, 8, -1);
    printf("[CLASE 8 - Real]: %s\n", yytext);
}
[+-]?[0-9]+[rR] {
    agregar_token(yytext, 8, -1);
    printf("[CLASE 8 - Real]: %s\n", yytext);
}

/*
----------------------------------------------------------------------------
Números enteros (CLASE 7)
Reconoce enteros opcionalmente precedidos por + o - y/o terminados en sufijo.
----------------------------------------------------------------------------
*/
[+-]?([1-9][0-9]*|0)[pPgG]? {
    agregar_token(yytext, 7, -1);
    printf("[CLASE 7 - Entera]: %s\n", yytext);
}

/*
----------------------------------------------------------------------------
Comentarios
Texto entre corchetes se reconoce como comentario y se omite del análisis.
----------------------------------------------------------------------------
*/
\[.*?\] {
    printf("[Comentario] %s\n", yytext);
}

/*
----------------------------------------------------------------------------
Errores léxicos
Todo lo que no coincide con patrones válidos se reporta como error.
----------------------------------------------------------------------------
*/
[^ \t\n]+ {
    fprintf(archivo_errores, "[ Error Léxico] '%s' en línea %d\n", yytext, yylineno);
    printf("[ Error Lexico]: %s\n", yytext);
}

%%
/* === FIN DE LAS REGLAS LÉXICAS / INICIO DEL PARSER EMBEBIDO === */

/*
----------------------------------------------------------------------------
DECLARACIÓN DE FUNCIONES DEL PARSER DESCENDENTE RECURSIVO
Estas son las cabeceras de todas las funciones correspondientes a no-terminales
de la gramática definida en el Anexo A.
Se definen más abajo en el mismo archivo.
----------------------------------------------------------------------------
*/
extern char* atomos[];
extern int total_atomos;
extern int indice_actual;

void cargar_atomos(const char* archivo);
void Program();
void ListDecGlob();
void DecGlob();
void Decl();
void Tipo();
void list();
void Func();
void otraFunc();
void Arg();
void listArg();
void listaDec();
void listaSent();
void Sent();
void Asig();
void ExprGral();
void E();
void Ep();
void Tp();
void G();
void expRel();
void Sino();
void Param();
void listP();
void LlamaFunc();
void opRel();
void opAsig();
void OpAsigSimple();
void OpAsigComp();
void Fp();
void valRet();
// Prototipos de funciones agregadas
void HazM();

// === Helper para errores sintácticos ===
/*
----------------------------------------------------------------------------
errorSintactico:
Imprime un mensaje de error sintáctico detallado indicando cuál átomo fue
encontrado y cuál se esperaba. Se registra también en el archivo de errores.

Parámetro:
- esperado: átomo esperado según la gramática
----------------------------------------------------------------------------
*/
void errorSintactico(const char *esperado) {
    fprintf(archivo_errores, "[ Error Sintáctico] átomo '%s' (índice %d): se esperaba '%s'\n",
        (indice_actual < total_atomos ? atomos[indice_actual] : "EOF"),
        indice_actual,
        esperado);
}

/* === PUNTO DE ENTRADA: INVOCACIÓN DEL ANALIZADOR LÉXICO Y PARSER SINTÁCTICO === */
/*
----------------------------------------------------------------------------
main:
Función principal del programa. Coordina todo el flujo del análisis léxico y
sintáctico:

1. Valida el argumento del archivo fuente.
2. Abre el archivo de entrada y todos los archivos de salida.
3. Ejecuta el analizador léxico (yylex).
4. Imprime las tablas resultantes del análisis.
5. Carga los átomos generados para el análisis sintáctico.
6. Llama a la función inicial del parser: Program().
7. Verifica si todos los átomos fueron consumidos correctamente.
----------------------------------------------------------------------------
*/
int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Uso: %s archivo_entrada\n", argv[0]);
        return 1;
    }

    FILE *entrada = fopen(argv[1], "r");
    if (!entrada) {
        perror("No se pudo abrir el archivo de entrada");
        return 1;
    }

    yyin = entrada;

    archivo_tokens = fopen("tokens.txt", "w");
    archivo_simbolos = fopen("simbolos.txt", "w");
    archivo_literales = fopen("literales.txt", "w");
    archivo_cadenas = fopen("cadenas.txt", "w");
    archivo_enteros = fopen("enteros.txt", "w");
    archivo_reales = fopen("reales.txt", "w");
    archivo_errores = fopen("errores.txt", "w");

    if (!archivo_tokens || !archivo_simbolos || !archivo_literales || !archivo_cadenas || !archivo_enteros || !archivo_reales || !archivo_errores) {
        fprintf(stderr, "No se pudieron abrir archivos de salida\n");
        return 1;
    }

    printf("Analizador Léxico iniciado...\n");
    printf("🪛 DEBUG: Iniciando análisis léxico...\n");
    printf("🪛 DEBUG: Ejecutando yylex()...\n");
    fclose(fopen("atomos.txt", "w"));  // Limpia atomos.txt
    yylex();
    printf("🪛 DEBUG: Finalizó yylex(). Tokens generados: %d\n", token_count);

    imprimir_tabla_tokens(archivo_tokens);
    imprimir_tabla_simbolos(archivo_simbolos);
    imprimir_tabla_literales(archivo_literales);
    imprimir_tabla_cadenas(archivo_cadenas);
    imprimir_tabla_enteros(archivo_enteros);
    imprimir_tabla_reales(archivo_reales);

    fclose(archivo_tokens);
    fclose(archivo_simbolos);
    fclose(archivo_literales);
    fclose(archivo_cadenas);
    fclose(archivo_enteros);
    fclose(archivo_reales);
    fclose(entrada);

    // Ahora, cargar los átomos y ejecutar el "parser" embebido:
    printf("Tablas escritas en archivos tokens.txt, simbolos.txt, literales.txt, cadenas.txt, enteros.txt y reales.txt\n");
    printf("Errores (léxicos y sintácticos) en 'errores.txt'\n");
    printf("🪛 DEBUG: Cargando átomos desde atomos.txt...\n");
    cargar_atomos("atomos.txt");
    printf("🪛 DEBUG: Iniciando análisis sintáctico con Program()\n");
    Program();
    printf("🪛 DEBUG: Terminó Program(). Atomos consumidos: %d de %d\n", indice_actual, total_atomos);
    if (indice_actual == total_atomos) {
        printf("✅ Análisis sintáctico exitoso. Todos los átomos fueron consumidos.\n");
    } else {
        printf("❌ Error: quedaron átomos sin procesar desde '%s'\n", atomos[indice_actual]);
    }

    fclose(archivo_errores);

    return 0;
}

// --- SINTÁCTICO: Variables y funciones para analizar los átomos generados ---
// (Colocados después de las reglas de Flex, en ámbito global)

/*
----------------------------------------------------------------------------
Declaración e inicialización de variables globales para el análisis sintáctico.
- atomos[]: almacena los átomos leídos del archivo generado por el lexer.
- total_atomos: cantidad total de átomos leídos.
- indice_actual: índice actual que está siendo evaluado por el parser.
----------------------------------------------------------------------------
*/
char* atomos[MAX_TOKENS];
int total_atomos = 0;
int indice_actual = 0;

/*
----------------------------------------------------------------------------
cargar_atomos:
Lee el archivo "atomos.txt" línea por línea y almacena los átomos en el arreglo
global atomos[].

Parámetro:
- archivo: ruta del archivo a cargar (por defecto "atomos.txt")
----------------------------------------------------------------------------
*/
void cargar_atomos(const char* archivo) {
    FILE* f = fopen(archivo, "r");
    char linea[100];
    while (fgets(linea, sizeof(linea), f)) {
        linea[strcspn(linea, "\n")] = 0;
        atomos[total_atomos++] = strdup(linea);
    }
    fclose(f);
}

/*
----------------------------------------------------------------------------
match:
Verifica si el átomo actual coincide con el esperado.
- Si coincide, avanza al siguiente átomo.
- Si no coincide, lanza un error sintáctico pero también avanza.

Parámetro:
- esperado: átomo que debería aparecer según la gramática.

Retorna:
- 1 si hay coincidencia (match), 0 en caso contrario.
----------------------------------------------------------------------------
*/
int match(const char* esperado) {
    printf("🪛 DEBUG: match(): esperando '%s', actual='%s' (índice %d)\n", esperado, atomos[indice_actual], indice_actual);
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], esperado) == 0) {
        printf("✔️ Match: %s\n", esperado);
        indice_actual++;
        return 1;
    } else {
        errorSintactico(esperado);
        printf("⚠️ Error sintáctico: se esperaba '%s' pero se encontró '%s'\n",
               esperado,
               (indice_actual < total_atomos ? atomos[indice_actual] : "EOF"));
        indice_actual++;
        return 0;
    }
}

// --- INICIO: Gramática para <Arg>, <listArg> y <listaDec> ---


// --- FIN: Gramática para <Arg>, <listArg> y <listaDec> ---
/* === PARSER: Decl === */


// --- INICIO: Gramática para listaSent y Sent ---











/* === PARSER: Program === */

// --- Fin sintáctico ---


// === STUBS DEL PARSER LL(1) ===
// Aquí se colocan las funciones para cada no-terminal de la gramática.

// listaDec analiza múltiples declaraciones (Decl) si el lookahead es un tipo válido
void listaDec() {
    if (indice_actual < total_atomos) {
        char *la = atomos[indice_actual];
        if (strcmp(la, "b") == 0 || strcmp(la, "c") == 0 ||
            strcmp(la, "n") == 0 || strcmp(la, "f") == 0) {
            Decl();
            listaDec();
        }
    }
}

// Func analiza una función: tipo, identificador, argumentos, declaraciones locales y sentencias
void Func() {
    Tipo();
    match("a");
    match("(");
    Arg();
    match(")");
    match("[");
    listaDec();
    listaSent();
    match("]");
}

// otraFunc analiza más funciones de forma recursiva si el siguiente token es un tipo válido
void otraFunc() {
    if (indice_actual < total_atomos && (
        strcmp(atomos[indice_actual], "b") == 0 ||
        strcmp(atomos[indice_actual], "c") == 0 ||
        strcmp(atomos[indice_actual], "n") == 0 ||
        strcmp(atomos[indice_actual], "f") == 0
    )) {
        Func();
        otraFunc();
    }
}

// Arg analiza un argumento de función (tipo seguido de identificador), con lista opcional
void Arg() {
    if (indice_actual < total_atomos &&
        (strcmp(atomos[indice_actual], "n") == 0 ||
         strcmp(atomos[indice_actual], "f") == 0 ||
         strcmp(atomos[indice_actual], "c") == 0 ||
         strcmp(atomos[indice_actual], "b") == 0)) {
        Tipo();
        match("a");
        listArg();
    }
}

// listArg analiza argumentos adicionales separados por comas
void listArg() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], ",") == 0) {
        match(",");
        Arg();
    }
}


/* === PARSER FUNCTIONS FOR NON-TERMINALS (Parte I) === */

// Program es el punto de entrada principal del parser
void Program() {
    printf("↪ Analizando &lt;Program&gt;, lookahead='%s' (índice %d)\n", atomos[indice_actual], indice_actual);
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "g") == 0) {
        ListDecGlob();
        Func();
        otraFunc();
    } else {
        errorSintactico("Program (esperado: g)");
    }
}

// ListDecGlob analiza una lista de declaraciones globales (recursiva o epsilon)
void ListDecGlob() {
    if (indice_actual >= total_atomos) {
        printf("🛑 DEBUG: Fin de entrada alcanzado en ListDecGlob (índice %d)\n", indice_actual);
        return;
    }

    printf("↪ Analizando <ListDecGlob>, lookahead='%s' (índice %d)\n", atomos[indice_actual], indice_actual);
    if (strcmp(atomos[indice_actual], "g") == 0) {
        DecGlob();
        ListDecGlob();
    } else {
        printf("ℹ️ DEBUG: <ListDecGlob> termina (no hay 'g') en índice %d\n", indice_actual);
    }
}

// DecGlob analiza una declaración global que inicia con 'g' seguida de Decl
void DecGlob() {
    printf("↪ Analizando <DecGlob>, lookahead='%s'\n", atomos[indice_actual]);
    if (strcmp(atomos[indice_actual], "g") == 0) {
        match("g");
        Decl();
    } else {
        errorSintactico("g");
    }
}

// Decl analiza una declaración: tipo, identificador y posible lista, seguida de punto y coma
void Decl() {
    printf("🧠 DEBUG: Entrando a Decl()\n");
    printf("↪ Analizando <Decl>, lookahead='%s'\n", atomos[indice_actual]);
    if (!(strcmp(atomos[indice_actual], "b") == 0 ||
          strcmp(atomos[indice_actual], "c") == 0 ||
          strcmp(atomos[indice_actual], "n") == 0 ||
          strcmp(atomos[indice_actual], "f") == 0)) {
        errorSintactico("Tipo esperado en Decl");
        return;
    }
    Tipo();
    match("a");
    list();
    match(";");
}

// Tipo reconoce un tipo primitivo: b, c, n, o f
void Tipo() {
    printf("↪ Analizando <Tipo>, lookahead='%s'\n", atomos[indice_actual]);
     if (indice_actual >= total_atomos) {
        printf("🛑 DEBUG: Fin de entrada alcanzado en Tipo (índice %d)\n", indice_actual);
        return;
    }
    if (strcmp(atomos[indice_actual], "b") == 0) {
        match("b");
    } else if (strcmp(atomos[indice_actual], "c") == 0) {
        match("c");
    } else if (strcmp(atomos[indice_actual], "n") == 0) {
        match("n");
    } else if (strcmp(atomos[indice_actual], "f") == 0) {
        match("f");
    } else {
        errorSintactico("Tipo");
        indice_actual++;
    }
}

// list analiza una lista de identificadores separados por comas o epsilon
void list() {
    printf("↪ Analizando <list>, lookahead='%s'\n", atomos[indice_actual]);
    printf("🪛 DEBUG: Entering <list>\n");
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], ",") == 0) {
        printf("🪛 DEBUG: <list> comma branch taken\n");
        match(",");
        match("a");
        list();
    } else {
        printf("🪛 DEBUG: <list> epsilon branch taken (no comma)\n");
    }
}

/* — Próximas funciones a implementar:
   Func, otraFunc, Arg, listArg, listaDec, Sent, Asig, opAsig,
   ExprGral, E, T, F, etc.
*/

/* === NUEVO PARSER RECURSIVO DESCENDENTE CON getchar() === */
char c; // caracter actual leído desde entrada

// Manejadores de aceptación y rechazo de la cadena
void aceptar() {
    printf("✅ Cadena aceptada\n");
    exit(0);
}
void rechazar() {
    printf("❌ Error sintáctico en caracter '%c'\n", c);
    exit(1);
}

// Avanza al siguiente caracter de entrada
void avanzar() {
    c = getchar();
}

// Declaración de las funciones para cada no-terminal de la gramática
// (para poder usarlas antes de su definición)

void DecGlob();
void Decl();
void Para();
void list();
void Func();
void otraFunc();
void Arg();
void listArg();
void listaDec();
void listaSent();
void Sent();
void Asig();
void Si(void);
void Dev(void);
void ExprGral();
void E();
void T();
void Expr();
void Cuerpo();
void F();

// listaSent analiza una lista de sentencias, si el token inicial pertenece a FIRST(Sent)
void listaSent() {
    if (indice_actual < total_atomos) {
        const char *la = atomos[indice_actual];
        if (strcmp(la, "a") == 0 || strcmp(la, "h") == 0 || strcmp(la, "i") == 0 ||
            strcmp(la, "o") == 0 || strcmp(la, "d") == 0 || strcmp(la, "t") == 0 ||
            strcmp(la, "p") == 0 || strcmp(la, "m") == 0) {
            Sent();
            listaSent();
        }
        // else ε
    }
}

// Sent reconoce distintos tipos de sentencias según el token lookahead
void Sent() {
    if (indice_actual < total_atomos) {
        char *la = atomos[indice_actual];

        if (strcmp(la, "a") == 0) {
            Asig();
            match(";");
        } else if (strcmp(la, "h") == 0) {
            match("h");
            match("[");
            listaSent();
            match("]");
            match("w");
            match("(");
            expRel();
            match(")");
            match("[");
            listaSent();
            match("]");
        } else if (strcmp(la, "i") == 0) {
            Si();
        } else if (strcmp(la, "o") == 0) {
            Para();
        } else if (strcmp(la, "d") == 0) {
            Dev();
        } else if (strcmp(la, "t") == 0) {
            match("t");
            match(";");
        } else if (strcmp(la, "p") == 0) {
            match("p");
            match(";");
        } else if (strcmp(la, "m") == 0) {
            match("m");
            match(";");
        } else {
            errorSintactico("Sent");
            indice_actual++;
        }
    }
}

// Asig analiza una asignación: a opAsig ExprGral
void Asig() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "a") == 0) {
        match("a");
        opAsig();
        ExprGral();
    } else {
        errorSintactico("a");
        indice_actual++;
    }
}

// opAsig analiza operadores de asignación: simples (=) o compuestos
void opAsig() {
    if (indice_actual < total_atomos) {
        char *la = atomos[indice_actual];
        if (strcmp(la, "=") == 0) {
            OpAsigSimple();
        } else if (
            strcmp(la, "#") == 0 || strcmp(la, "ñ") == 0 || strcmp(la, "$") == 0 ||
            strcmp(la, "v") == 0 || strcmp(la, "?") == 0 || strcmp(la, ":") == 0 ||
            strcmp(la, "\"") == 0 || strcmp(la, "^") == 0 || strcmp(la, "&") == 0
        ) {
            OpAsigComp();
        } else {
            errorSintactico("opAsig");
            indice_actual++;
        }
    }
}

// ExprGral analiza una expresión general (inicia con identificador, número, etc.)
void ExprGral() {
    char *la = atomos[indice_actual];
    if (strcmp(la, "a") == 0 || strcmp(la, "e") == 0 ||
        strcmp(la, "r") == 0 || strcmp(la, "s") == 0 ||
        strcmp(la, "(") == 0) {
        E();
    } else {
        errorSintactico("ExprGral");
        indice_actual++;
    }
}

// T analiza términos de una expresión (E → T Ep)
void T() {
    char *la = atomos[indice_actual];
    if (strcmp(la, "a") == 0 || strcmp(la, "e") == 0 ||
        strcmp(la, "r") == 0 || strcmp(la, "s") == 0 ||
        strcmp(la, "(") == 0) {
        F();
        Tp();
    } else {
        errorSintactico("T");
        indice_actual++;
    }
}

// Tp analiza operadores multiplicativos y su continuación
void Tp() {
    if (indice_actual < total_atomos &&
        (strcmp(atomos[indice_actual], "*") == 0 ||
         strcmp(atomos[indice_actual], "/") == 0 ||
         strcmp(atomos[indice_actual], "%") == 0 ||
         strcmp(atomos[indice_actual], "~") == 0 ||
         strcmp(atomos[indice_actual], "k") == 0)) {
        match(atomos[indice_actual]);
        F();
        Tp();
    }
}

// E analiza expresiones completas (E → T Ep)
void E() {
    char *la = atomos[indice_actual];
    if (strcmp(la, "a") == 0 || strcmp(la, "e") == 0 ||
        strcmp(la, "r") == 0 || strcmp(la, "s") == 0 ||
        strcmp(la, "(") == 0) {
        T();
        Ep();
    } else {
        errorSintactico("E");
        indice_actual++;
    }
}

// F analiza factores: identificadores, literales, paréntesis o llamadas
void F() {
    if (indice_actual < total_atomos) {
        const char *la = atomos[indice_actual];
        if (strcmp(la, "a")==0 || strcmp(la, "e")==0 ||
            strcmp(la, "r")==0 || strcmp(la, "s")==0) {
            match(la);
            Fp();
        }
        else if (strcmp(la, "(")==0) {
            match("("); E(); match(")");
        }
        else if (strcmp(la, "{")==0) {
            LlamaFunc();
        }
        else if (strcmp(la, "m")==0) {
            match("m");
        }
        else {
            errorSintactico("F");
            indice_actual++;
        }
    }
}

// opRel analiza operadores relacionales
void opRel() {
    if (indice_actual < total_atomos) {
        char *la = atomos[indice_actual];
        if (
            strcmp(la, "h") == 0 || strcmp(la, "m") == 0 ||
            strcmp(la, "¡") == 0 || strcmp(la, "!") == 0 ||
            strcmp(la, "x") == 0 || strcmp(la, "y") == 0
        ) {
            match(la);
        } else {
            errorSintactico("opRel");
            indice_actual++;
        }
    }
}

// G analiza sufijos opcionales j o z
void G() {
    if (indice_actual < total_atomos) {
        const char *la = atomos[indice_actual];
        if (strcmp(la, "z") == 0) {
            match("z");
        } else if (strcmp(la, "j") == 0) {
            match("j");
        }
    }
}

// Fp analiza operadores postfijo j o z (usado después de variables o literales)
void Fp() {
    if (indice_actual < total_atomos) {
        if (strcmp(atomos[indice_actual], "j") == 0 || strcmp(atomos[indice_actual], "z") == 0) {
            match(atomos[indice_actual]);
        }
    }
}

// expRel analiza expresiones relacionales compuestas por dos ExprGral y un opRel
void expRel() {
    const char *la = atomos[indice_actual];
    if (strcmp(la, "a") == 0 || strcmp(la, "e") == 0 ||
        strcmp(la, "r") == 0 || strcmp(la, "s") == 0 || strcmp(la, "(") == 0) {
        ExprGral();
        opRel();
        ExprGral();
    } else {
        errorSintactico("expRel");
        indice_actual++;
    }
}

// OpAsigComp analiza operadores de asignación compuesta
void OpAsigComp() {
    if (indice_actual < total_atomos) {
        char *la = atomos[indice_actual];
        if (
            strcmp(la, "#") == 0 || strcmp(la, "ñ") == 0 ||
            strcmp(la, "$") == 0 || strcmp(la, "v") == 0 ||
            strcmp(la, "?") == 0 || strcmp(la, ":") == 0 ||
            strcmp(la, "\"") == 0 || strcmp(la, "^") == 0 ||
            strcmp(la, "&") == 0
        ) {
            match(la);
        } else {
            errorSintactico("OpAsigComp");
        }
    }
}

// OpAsigSimple analiza el operador de asignación simple (=)
void OpAsigSimple() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "=") == 0) {
        match("=");
    } else {
        errorSintactico("OpAsigSimple");
    }
}

// Param analiza parámetros adicionales para llamadas a funciones
void Param() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], ",") == 0) {
        match(",");
        ExprGral();
        Param();
    }
}

// listP analiza una lista de parámetros de función
void listP() {
    if (indice_actual < total_atomos) {
        const char *la = atomos[indice_actual];
        if (strcmp(la, "s") == 0 || strcmp(la, "q") == 0 ||
            strcmp(la, "m") == 0 || strcmp(la, "u") == 0 ||
            strcmp(la, "(") == 0 || strcmp(la, "a") == 0 ||
            strcmp(la, "n") == 0 || strcmp(la, "r") == 0) {
            ExprGral();
            Param();
        }
    }
}

// Args analiza los argumentos de una función (ExprGral, Param)
void Args() {
    if (indice_actual < total_atomos) {
        const char *la = atomos[indice_actual];
        if (strcmp(la, "a") == 0 || strcmp(la, "e") == 0 ||
            strcmp(la, "r") == 0 || strcmp(la, "s") == 0 ||
            strcmp(la, "(") == 0) {
            ExprGral();
            Param();
        }
        // else: ε
    }
}

// Definition for yywrap to allow Flex lexer to link
int yywrap(void) {
    return 1; // indica a Flex que finalizó la lectura del archivo de entrada
}

// Ep analiza la continuación de una expresión con operadores + o -
void Ep() {
    if (indice_actual < total_atomos &&
        (strcmp(atomos[indice_actual], "+") == 0 ||
         strcmp(atomos[indice_actual], "-") == 0)) {
        match(atomos[indice_actual]); // consume + o -
        T(); // analiza el siguiente término
        Ep(); // recursividad para múltiples sumas/restas
    }
}

// Cuerpo analiza el cuerpo de una función o estructura delimitado por corchetes [ ]
void Cuerpo() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "[") == 0) {
        match("[");
        listaSent(); // lista de sentencias dentro del cuerpo
        match("]");
    } else {
        errorSintactico("Cuerpo (esperado: [)");
        indice_actual++;
    }
}

// Expr analiza expresiones que inician con identificador, literal, paréntesis, etc.
void Expr() {
    if (indice_actual < total_atomos) {
        const char *la = atomos[indice_actual];
        if (strcmp(la, "a") == 0 || strcmp(la, "e") == 0 ||
            strcmp(la, "r") == 0 || strcmp(la, "s") == 0 ||
            strcmp(la, "(") == 0) {
            E(); // expresión completa
        } else {
            errorSintactico("Expr (esperado: a, e, r, s, ()");
            indice_actual++;
        }
    }
}

// Sino analiza el bloque opcional else de una estructura condicional
void Sino() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "l") == 0) {
        match("l");
        match("[");
        listaSent(); // bloque de sentencias del else
        match("]");
    }
    // si no hay "l", se asume epsilon
}

// Dev analiza una sentencia de retorno: d <valRet> ;
void Dev() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "d") == 0) {
        match("d");
        valRet(); // valor devuelto
        match(";");
    } else {
        errorSintactico("Dev (esperado: d)");
        indice_actual++;
    }
}

// valRet analiza el valor de retorno, que debe ser una expresión válida
void valRet() {
    const char *la = atomos[indice_actual];
    if (strcmp(la, "a") == 0 || strcmp(la, "e") == 0 ||
        strcmp(la, "r") == 0 || strcmp(la, "s") == 0 ||
        strcmp(la, "(") == 0) {
        ExprGral();
    } else {
        errorSintactico("valRet (esperado: a, e, r, s, ()");
        indice_actual++;
    }
}

// Si analiza la estructura condicional: if (...) [sentencias] else
void Si() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "i") == 0) {
        match("i");
        match("(");
        expRel(); // condición relacional
        match(")");
        match("[");
        listaSent(); // bloque del if
        match("]");
        Sino(); // bloque opcional del else
    } else {
        errorSintactico("Si (esperado: i)");
        indice_actual++;
    }
}

// Para analiza la estructura de repetición tipo for/simplificada: o(E) [sentencias]
void Para() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "o") == 0) {
        match("o");
        match("(");
        E(); // expresión de condición o control
        match(")");
        match("[");
        listaSent(); // bloque de sentencias del for
        match("]");
    } else {
        errorSintactico("Para (esperado: o)");
        indice_actual++;
    }
}

// LlamaFunc analiza una llamada a función: {a( lista de parámetros )}
void LlamaFunc() {
    match("{");
    match("a"); // nombre de la función
    match("(");
    listP(); // lista de parámetros
    match(")");
    match("}");
}

// HazM analiza una instrucción especial que también usa la sintaxis de corchetes
void HazM() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "h") == 0) {
        match("h");
        match("[");
        listaSent(); // sentencias dentro del bloque especial
        match("]");
    } else {
        errorSintactico("HazM (esperado: h)");
        indice_actual++;
    }
}
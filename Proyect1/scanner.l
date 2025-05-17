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

/* === INCLUSIÓN DE CABECERAS Y DEFINICIONES GLOBALES === */
%{
#define YY_NO_MAIN 1
/*
Descripción del Programa

El presente programa es un Analizador Léxico desarrollado utilizando la herramienta Flex (Fast Lexical Analyzer Generator). El objetivo principal del analizador léxico es identificar y clasificar correctamente los componentes básicos de un lenguaje específico a partir de un código fuente.

El analizador reconoce diferentes categorías de tokens como palabras reservadas, identificadores, símbolos especiales, operadores aritméticos, relacionales y de asignación, así como constantes numéricas (enteras y reales) y cadenas literales. Además, ignora comentarios y maneja errores léxicos, mostrando información útil sobre estos últimos en la salida estándar.

El programa estructura la información obtenida en tres tablas:
• Tabla de Tokens: Contiene los tokens reconocidos con su clasificación y posición respectiva.
• Tabla de Símbolos: Almacena los identificadores encontrados en el código.
• Tabla de Literales: Guarda cadenas y constantes numéricas detectadas.

Cada una de estas tablas se exporta en archivos separados (tokens.txt, simbolos.txt y literales.txt) para facilitar posteriores etapas de análisis sintáctico y semántico.

⸻

Autores del Programa:
• Yaretzi Calzontzi Hernández
• Emilio Sebastián Contreras Colmenero

Fecha de elaboración:
• Parte Léxica: 12/03/25
• Parte Sintáctica: 16/05/25
-----------------------------------------------------------------------
INSTRUCCIONES DE CABECERA
-----------------------------------------------------------------------
Este bloque se utiliza para incluir bibliotecas de C y declaraciones 
globales. También definimos estructuras para la tabla de símbolos, 
tabla de literales y la tabla de tokens.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_TOKENS 300

/* === DEFINICIÓN DE ESTRUCTURAS PARA TABLAS DE SÍMBOLOS Y LITERALES === */

typedef struct {
int pos;
char nombre[50];
int tipo; 
} Simbolo;

/* === MAPEADO DE CLASES Y POSICIONES A ÁTOMOS LÉXICOS === */

const char* obtener_atomo(int clase, int posicion) {
switch (clase) {
    case 0: {
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
 case 1: {
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
    case 3: {
        switch (posicion) {
            case 0: return "+"; // sum
            case 1: return "-"; // rest
            case 2: return "*"; // mult
            case 3: return "/"; // div
            case 4: return "%"; // mod
            case 5: return "z"; // inc
            case 6: return "j"; // dec
            case 7: return "k"; // exp
            case 8: return "~"; // dive (changed from '&' to '~')
            default: return "?";
        }
    }
    case 4: {
        switch (posicion) {
            case 0: return ">"; // h
            case 1: return "<"; // m
            case 2: return "¡"; // e
            case 3: return "!"; // c
            case 4: return "x"; // he
            case 5: return "y"; // me
            default: return "?";
        }
    }
    case 5: {
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
    case 6: return "s"; // Cadena
    case 7: return "e"; // Entero
    case 8: return "r"; // Real
    case 9: return "!"; // Error léxico
    default: return "?";
}
}
/* === DEFINICIÓN DE ESTRUCTURAS PARA TABLAS DE SÍMBOLOS Y LITERALES === */
/* Tablas separadas para literales: cadenas, reales y enteros */
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

/* Estructura para la tabla de tokens.
Cada token tiene:
- clase: el código de la clase (0=reservada, 1=símbolo, 2=ident, etc.)
- posicion: el índice dentro de su tabla (o -1 si no aplica) */
typedef struct {
int clase;      
int posicion;   
} TokenInfo;

/* Declaración de tablas globales */
Simbolo tabla_simbolos[MAX_TOKENS];
int simbolos_count = 0;

CadenaLiteral cadena_literales[MAX_TOKENS];
int cadena_literales_count = 0;

RealLiteral real_literales[MAX_TOKENS];
int real_literales_count = 0;

EnteroLiteral entero_literales[MAX_TOKENS];
int entero_literales_count = 0;

TokenInfo tabla_tokens[MAX_TOKENS];
int token_count = 0;

/* Declaración de los archivos de salida */
FILE *archivo_tokens = NULL;
FILE *archivo_simbolos = NULL;
FILE *archivo_literales = NULL;
FILE *archivo_cadenas = NULL;
FILE *archivo_enteros = NULL;
FILE *archivo_reales = NULL;
FILE *archivo_errores = NULL;

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
        char limpio[50];
        strcpy(limpio, valor);
        limpio[strcspn(limpio, "\n")] = 0;
        if (strcmp(tabla[i], limpio) == 0) {
            return i;
        }
    }
    return -1;
}

/* === FUNCIONES AUXILIARES: GESTIÓN DE TABLAS DE SÍMBOLOS Y LITERALES === */

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

/* === AGREGAR TOKENS A LA TABLA Y EMITIR ÁTOMOS === */

void agregar_token(const char *valor, int clase, int posicion) {
    int pos = -1;
    if (posicion != -1) {
        pos = posicion;
    } else {
        switch (clase) {
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
            case 2:
                pos = obtener_posicion_simbolo(valor);
                break;
            case 6:
                pos = obtener_posicion_literal_cadena(valor);
                break;
            case 7:
                pos = obtener_posicion_literal_entero(valor);
                break;
            case 8:
                pos = obtener_posicion_literal_real(valor);
                break;
            case 9:
                pos = -1;
                break;
        }
    }

    if (clase != 9 && pos == -1) {
        return;
    }

    if (token_count < MAX_TOKENS) {
        tabla_tokens[token_count].clase = clase;
        tabla_tokens[token_count].posicion = pos;
        token_count++;

        const char* atomo = obtener_atomo(clase, pos);
        printf("Átomo: %s\n", atomo);

        FILE* archivo_atomos = fopen("atomos.txt", "a");
        if (archivo_atomos) {
            fprintf(archivo_atomos, "%s\n", atomo);
            fclose(archivo_atomos);
        }
    }
}

/* 
-----------------------------------------------------------------------
FUNCIONES PARA IMPRIMIR LAS TABLAS
-----------------------------------------------------------------------
Cada función escribe el resultado en el archivo *fp correspondiente.
*/

/* === FUNCIONES PARA IMPRIMIR TABLAS DE RESULTADOS EN ARCHIVOS === */

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
Por compatibilidad, imprime todas las tablas de literales juntas (opcional). */
void imprimir_tabla_literales(FILE *fp) {
fprintf(fp, "\n===== TABLA DE LITERALES (Cadenas) =====\n");
fprintf(fp, "| %-5s | %-15s |\n", "Pos", "Valor");
fprintf(fp, "|-----------------------|\n");
for (int i = 0; i < cadena_literales_count; i++) {
    fprintf(fp, "| %-5d | %-15s |\n",
        cadena_literales[i].pos,
        cadena_literales[i].dato);
}
fprintf(fp, "=======================\n");
fprintf(fp, "\n===== TABLA DE LITERALES (Enteros) =====\n");
fprintf(fp, "| %-5s | %-15s |\n", "Pos", "Valor");
fprintf(fp, "|-----------------------|\n");
for (int i = 0; i < entero_literales_count; i++) {
    fprintf(fp, "| %-5d | %-15ld |\n",
        entero_literales[i].pos,
        entero_literales[i].valor);
}
fprintf(fp, "=======================\n");
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
%}

/* === REGLAS DE FLEX: DE DEFINICIONES LÉXICAS A TOKENS === */

%%




[ \t\n]+  {  }

("Bool"|"Cade"|"Continuar"|"Devo"|"Ent"|"Fals"|"Flota"|"Global"|"Haz"|"Mientras"|"Nulo"|"Para"|"Parar"|"Si"|"Sino"|"Ver")([^A-Za-zÑñÁÉÍÓÚÜáéíóúü0-9_]) {
    char palabra[100];
    strncpy(palabra, yytext, yyleng-1);
    palabra[yyleng-1] = '\0';
    int pos = buscar_posicion(palabra, palabras_reservadas, total_palabras_reservadas);
    agregar_token(palabra, 0, pos);
    printf("[CLASE 0 - Pal.Res]: %s (pos: %d)\n", palabra, pos);
    unput(yytext[yyleng-1]);
}







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


@([A-Za-zÑñÁÉÍÓÚÜáéíóúü0-9]*)_ {
    agregar_token(yytext, 2, -1);
    printf("[CLASE 2 - Identif]: %s\n", yytext);
}

"<<" {
    agregar_token(yytext, 1, -1);
    printf("[CLASE 1 - Símb.Esp]: <<\n");
}
">>" {
    agregar_token(yytext, 1, -1);
    printf("[CLASE 1 - Símb.Esp]: >>\n");
}
"<" {
    agregar_token(yytext, 1, -1);
    printf("[CLASE 1 - Símb.Esp]: <\n");
}
">" {
    agregar_token(yytext, 1, -1);
    printf("[CLASE 1 - Símb.Esp]: >\n");
}
"#!" {
    agregar_token(yytext, 1, -1);
    printf("[CLASE 1 - Símb.Esp]: #!\n");
}
"#" {
    agregar_token(yytext, 1, -1);
    printf("[CLASE 1 - Símb.Esp]: #\n");
}
"\*" {
    agregar_token(yytext, 1, -1);
    printf("[CLASE 1 - Símb.Esp]: *\n");
}
"\|" {
    agregar_token(yytext, 1, -1);
    printf("[CLASE 1 - Símb.Esp]: |\n");
}
"°" {
    agregar_token(yytext, 1, -1);
    printf("[CLASE 1 - Símb.Esp]: °\n");
}


"sum"|"rest"|"mult"|"div"|"mod"|"inc"|"dec"|"exp"|"dive" {
agregar_token(yytext, 3, -1);
printf("[CLASE 3 - Op.Aritm]: %s\n", yytext);
}

"h"|"m"|"e"|"c"|"he"|"me" {
agregar_token(yytext, 4, -1);
printf("[CLASE 4 - Op.Relac]: %s\n", yytext);
}



--([^-\n]*)-- {
agregar_token(yytext, 6, -1);
printf("[CLASE 6 - Cadena]: %s\n", yytext);
}


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

[+-]?([1-9][0-9]*|0)[pPgG]? {
agregar_token(yytext, 7, -1);
printf("[CLASE 7 - Entera]: %s\n", yytext);
}

\[.*?\] {
printf("[Comentario] %s\n", yytext);
}


. {
    fprintf(archivo_errores, "[ Error Léxico] '%s' en línea %d\n", yytext, yylineno);
    printf("[ Error Lexico]: %s\n", yytext);
}

%%
/* === FIN DE LAS REGLAS LÉXICAS / INICIO DEL PARSER EMBEBIDO === */

/* Forward declarations for parser atomos variables */
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
void errorSintactico(const char *esperado) {
    fprintf(archivo_errores, "[ Error Sintáctico] átomo '%s' (índice %d): se esperaba '%s'\n",
        (indice_actual < total_atomos ? atomos[indice_actual] : "EOF"),
        indice_actual,
        esperado);
}
/* === PUNTO DE ENTRADA: INVOCACIÓN DEL ANALIZADOR LÉXICO Y PARSER SINTÁCTICO === */
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
    printf(" DEBUG: Iniciando análisis léxico...\n");
    printf(" DEBUG: Ejecutando yylex()...\n");
    fclose(fopen("atomos.txt", "w"));  // Limpia atomos.txt
    yylex();
    printf(" DEBUG: Finalizó yylex(). Tokens generados: %d\n", token_count);

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
    printf(" DEBUG: Cargando átomos desde atomos.txt...\n");
    cargar_atomos("atomos.txt");
    printf("DEBUG: Iniciando análisis sintáctico con Program()\n");
    Program();
    printf("DEBUG: Terminó Program(). Atomos consumidos: %d de %d\n", indice_actual, total_atomos);
    if (indice_actual == total_atomos) {
        printf(" Análisis sintáctico exitoso. Todos los átomos fueron consumidos.\n");
    } else {
        printf(" Error: quedaron átomos sin procesar desde '%s'\n", atomos[indice_actual]);
    }

    fclose(archivo_errores);

    return 0;
}

// --- SINTÁCTICO: Variables y funciones para analizar los átomos generados ---
// (Colocados después de las reglas de Flex, en ámbito global)


char* atomos[MAX_TOKENS];
int total_atomos = 0;
int indice_actual = 0;

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
-----------------------------------------------------------------------
match:
Función clave en el parser descendente recursivo.

Recibe un átomo esperado y lo compara con el átomo actual en la entrada
(usando el índice `indice_actual` sobre el arreglo global `atomos[]`).
  
- Si coincide: avanza al siguiente átomo (incrementa `indice_actual`) y retorna 1.
- Si no coincide: reporta un error sintáctico indicando qué se esperaba
  y qué se encontró, luego también avanza para evitar bucles infinitos.
  
Esta función es usada por todas las reglas del parser para confirmar
si el átomo actual es el que dicta la gramática.
-----------------------------------------------------------------------
*/
int match(const char* esperado) {
    printf(" DEBUG: match(): esperando '%s', actual='%s' (índice %d)\n", esperado, atomos[indice_actual], indice_actual);
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], esperado) == 0) {
        printf(" Match: %s\n", esperado);
        indice_actual++;
        return 1;
    } else {
        errorSintactico(esperado);
        printf(" Error sintáctico: se esperaba '%s' pero se encontró '%s'\n",
               esperado,
               (indice_actual < total_atomos ? atomos[indice_actual] : "EOF"));
        // Avanza al siguiente átomo incluso si hay error, para evitar ciclos infinitos.
        indice_actual++;
        return 0;
    }
}


/*
-----------------------------------------------------------------------
listaDec:
Esta función analiza una lista de declaraciones locales dentro de un
bloque de función. Cada declaración debe iniciar con un tipo válido:
b (Bool), c (Cade), n (Ent) o f (Flota). La función es recursiva, 
consumiendo múltiples declaraciones si están presentes una tras otra.
-----------------------------------------------------------------------
*/
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

/*
-----------------------------------------------------------------------
Func:
Representa la producción de una función completa.
Espera una estructura con el siguiente patrón:
<Tipo> a ( <Arg> ) [ <listaDec> <listaSent> ]

- Primero analiza el tipo de retorno.
- Luego espera un identificador (a).
- Después, los argumentos de la función entre paréntesis.
- Dentro de corchetes, analiza las declaraciones locales y sentencias.
-----------------------------------------------------------------------
*/
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

/*
-----------------------------------------------------------------------
otraFunc:
Esta función permite definir múltiples funciones seguidas.
Si el lookahead es un tipo (b, c, n, f), interpreta que inicia otra función
y llama recursivamente a Func y otraFunc.

Esto implementa la regla:
<otraFunc> → <Func> <otraFunc> | ε
-----------------------------------------------------------------------
*/
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

/*
-----------------------------------------------------------------------
Arg:
Analiza la producción de argumentos de funciones. La regla a seguir es:
<Arg> → <Tipo> a <listArg>

- Espera un tipo válido (b, c, n, f).
- Luego un identificador (a).
- Después, una posible lista de argumentos adicionales (<listArg>).
-----------------------------------------------------------------------
*/
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

/*
-----------------------------------------------------------------------
listArg:
Analiza argumentos adicionales en una función, separados por coma.
La regla que sigue es:
<listArg> → , <Arg> | ε
Es recursiva solo si encuentra una coma.
-----------------------------------------------------------------------
*/
void listArg() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], ",") == 0) {
        match(",");
        Arg();
    }
}

/* === PARSER FUNCTIONS FOR NON-TERMINALS (Parte I) === */

/*
-----------------------------------------------------------------------
Program:
Es el punto de entrada del parser sintáctico.
La regla principal que implementa es:
<Program> → g <ListDecGlob> <Func> <otraFunc>

- Solo inicia si el primer átomo es 'g' (Global).
- Llama secuencialmente a la lista de declaraciones globales,
  una función principal, y otras funciones adicionales si existen.
-----------------------------------------------------------------------
*/
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

/*
-----------------------------------------------------------------------
ListDecGlob:
Analiza múltiples declaraciones globales al inicio del programa.

Sigue la producción:
<ListDecGlob> → <DecGlob> <ListDecGlob> | ε

- Si encuentra el átomo "g", llama a DecGlob() y se llama recursivamente.
- Si no encuentra "g", concluye la lista (producción vacía).
-----------------------------------------------------------------------
*/
void ListDecGlob() {
    if (indice_actual >= total_atomos) {
        printf(" DEBUG: Fin de entrada alcanzado en ListDecGlob (índice %d)\n", indice_actual);
        return;
    }

    printf("↪ Analizando <ListDecGlob>, lookahead='%s' (índice %d)\n", atomos[indice_actual], indice_actual);
    if (strcmp(atomos[indice_actual], "g") == 0) {
        DecGlob();
        ListDecGlob();
    } else {
        printf(" DEBUG: <ListDecGlob> termina (no hay 'g') en índice %d\n", indice_actual);
    }
}

/*
-----------------------------------------------------------------------
DecGlob:
Implementa la producción:
<DecGlob> → g <Decl>

- Verifica que el átomo actual sea "g".
- Si es así, consume "g" y llama a Decl().
- En otro caso, reporta un error sintáctico.
-----------------------------------------------------------------------
*/
void DecGlob() {
    printf("↪ Analizando <DecGlob>, lookahead='%s'\n", atomos[indice_actual]);
    if (strcmp(atomos[indice_actual], "g") == 0) {
        match("g");
        Decl();
    } else {
        errorSintactico("g");
    }
}

/*
-----------------------------------------------------------------------
Decl:
Reconoce una declaración de variable(s) global(es) o local(es).
Regla gramatical:
<Decl> → <Tipo> a <list> ;

- Espera un tipo válido (b, c, n, f).
- Luego, un identificador.
- Después, una posible lista de identificadores separados por comas.
- Termina con punto y coma (;)
-----------------------------------------------------------------------
*/
void Decl() {
    printf(" DEBUG: Entrando a Decl()\n");
    printf("↪ Analizando <Decl>, lookahead='%s'\n", atomos[indice_actual]);
    // FIRST(Decl) = b, c, n, f
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

/*
-----------------------------------------------------------------------
Tipo:
Reconoce un tipo de dato válido para declaraciones o funciones.
Producción:
<Tipo> → b | c | n | f

- 'b' para Bool
- 'c' para Cade
- 'n' para Ent
- 'f' para Flota
-----------------------------------------------------------------------
*/
void Tipo() {
    printf("↪ Analizando <Tipo>, lookahead='%s'\n", atomos[indice_actual]);
     if (indice_actual >= total_atomos) {
        printf("DEBUG: Fin de entrada alcanzado en Tipo (índice %d)\n", indice_actual);
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

/*
-----------------------------------------------------------------------
list:
Esta función representa la producción recursiva para una lista de
identificadores separados por coma en una declaración.

Regla gramatical:
<list> → , a <list> | ε

- Si detecta una coma (',') como lookahead, consume la coma, luego un
  identificador ('a') y llama de nuevo a sí misma (recursión).
- Si no hay coma, se interpreta como producción vacía (ε).

Se utiliza en declaraciones como: Ent a, b, c;
-----------------------------------------------------------------------
*/
void list() {
    // 12–13: <list> → , a <list> | ε
    printf("↪ Analizando <list>, lookahead='%s'\n", atomos[indice_actual]);
    printf(" DEBUG: Entering <list>\n");
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], ",") == 0) {
        printf(" DEBUG: <list> comma branch taken\n");
        match(",");
        match("a");
        list();
    } else {
        printf(" DEBUG: <list> epsilon branch taken (no comma)\n");
    }
}

// Declaración de las funciones para cada no-terminal de tu gramática


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

/*
-----------------------------------------------------------------------
listaSent:
Esta función representa la producción recursiva para una lista de sentencias.
Regla:
<listaSent> → <Sent> <listaSent> | ε

- Evalúa el lookahead para saber si se puede iniciar una sentencia válida.
- Si es así, llama a Sent() y luego se llama recursivamente.
- Si no hay coincidencia con el FIRST de Sent, se considera ε (vacío).
-----------------------------------------------------------------------
*/
void listaSent() {
    if (indice_actual < total_atomos) {
        const char *la = atomos[indice_actual];
        // todos los posibles primeros de Sent
        if (strcmp(la, "a") == 0 || strcmp(la, "h") == 0 || strcmp(la, "i") == 0 ||
            strcmp(la, "o") == 0 || strcmp(la, "d") == 0 || strcmp(la, "t") == 0 ||
            strcmp(la, "p") == 0 || strcmp(la, "m") == 0) {
            Sent();
            listaSent();
        }
        // else ε (no hacer nada)
    }
}

/*
-----------------------------------------------------------------------
Sent:
Representa las distintas sentencias del lenguaje, tales como:
- Asignaciones: a opAsig ExprGral ;
- Estructuras de control: if, while, for, else, return, etc.
- Sentencias simples como t;, p;, m; (Continuar, Parar, Ver).

El selector se basa en el valor del lookahead actual.
-----------------------------------------------------------------------
*/
void Sent() {
    if (indice_actual < total_atomos) {
        char *la = atomos[indice_actual];

        if (strcmp(la, "a") == 0) {
            Asig();
            match(";");
        } else if (strcmp(la, "h") == 0) {
            // h [ <listaSent> ] w ( <expRel> ) [ <listaSent> ]
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
            // i ( <expRel> ) [ <listaSent> ] <Sino>
            Si();
        } else if (strcmp(la, "o") == 0) {
            // o ( <ExprGral> ) [ <listaSent> ]
            Para();
        } else if (strcmp(la, "d") == 0) {
            // d <valRet> ;
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
            indice_actual++; // skip erroneous token to avoid infinite loop
        }
    }
}

/*
-----------------------------------------------------------------------
Asig:
Analiza una sentencia de asignación.
Regla:
<Asig> → a opAsig ExprGral

- Inicia con identificador (a).
- Luego un operador de asignación (simple o compuesto).
- Finalmente una expresión general.
-----------------------------------------------------------------------
*/
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

/*
-----------------------------------------------------------------------
opAsig:
Determina si el operador de asignación es simple (=) o compuesto (#, ñ, $, etc.).
Dependiendo del símbolo detectado en el lookahead, llama a la función
correspondiente para consumir el token.

Implementa:
<opAsig> → = | <OpAsigComp>
-----------------------------------------------------------------------
*/
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

/*
-----------------------------------------------------------------------
ExprGral:
Representa el punto de entrada para una expresión general.

Regla:
<ExprGral> → E

- Esta función valida que el lookahead sea válido para comenzar una expresión.
- FIRST(ExprGral) = { "a", "e", "r", "s", "(" }
- Si es válido, llama a E(), que representa la expresión completa.
- Si no es válido, lanza un error sintáctico.
-----------------------------------------------------------------------
*/
void ExprGral() {
    // FIRST(ExprGral) = { "a", "e", "r", "s", "(" }
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
/*
-----------------------------------------------------------------------
T:
Analiza términos dentro de una expresión.

Regla:
<T> → F Tp

- FIRST(T) = { "a", "e", "r", "s", "(" }
- Llama a F() para analizar un factor.
- Luego llama a Tp() para manejar operadores multiplicativos (*, /, %, etc.)
-----------------------------------------------------------------------
*/
void T() {
    // FIRST(T) = { "a", "e", "r", "s", "(" }
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

/*
-----------------------------------------------------------------------
Tp:
Esta función analiza operadores de multiplicación/división/modulo y
su secuencia en la expresión.

Regla:
<Tp> → op_mul F Tp | ε

- Detecta si el lookahead es un operador multiplicativo: *, /, %, ~, k.
- Si es así, consume el operador y el siguiente factor.
- Se llama recursivamente para manejar expresiones con múltiples operadores.
-----------------------------------------------------------------------
*/
void Tp() {
    if (indice_actual < total_atomos &&
        (strcmp(atomos[indice_actual], "*") == 0 ||
         strcmp(atomos[indice_actual], "/") == 0 ||
         strcmp(atomos[indice_actual], "%") == 0 ||
         strcmp(atomos[indice_actual], "~") == 0 || // dive
         strcmp(atomos[indice_actual], "k") == 0)) { // exp
        match(atomos[indice_actual]);
        F();
        Tp();
    }
}
/*
-----------------------------------------------------------------------
E:
Esta función analiza expresiones aritméticas completas.

Regla:
<E> → T Ep

- FIRST(E) = { "a", "e", "r", "s", "(" }
- Llama a T() para procesar el primer término.
- Luego Ep() para manejar operadores aditivos (+, -).
-----------------------------------------------------------------------
*/
void E() {
    // FIRST(E) = { "a", "e", "r", "s", "(" }
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

/*
-----------------------------------------------------------------------
F:
Analiza factores en una expresión. Sigue la regla:
<F> → a Fp | e | r | s | ( E ) | { LlamaFunc } | m

- Si el lookahead es a, e, r o s: se hace match y luego se evalúa Fp (j o z opcional).
- Si es "(", se espera una subexpresión entre paréntesis.
- Si es "{", se espera una llamada a función.
- Si es "m", se considera como una expresión válida (como Ver).
-----------------------------------------------------------------------
*/
void F() {
    // <F> → a F' | e | r | s | ( E ) | { LlamaFunc } | m
    if (indice_actual < total_atomos) {
        const char *la = atomos[indice_actual];
        if (strcmp(la, "a")==0 || strcmp(la, "e")==0 ||
            strcmp(la, "r")==0 || strcmp(la, "s")==0) {
            match(la);
            Fp();      // maneja j o z (postfijo)
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



/*
-----------------------------------------------------------------------
opRel:
Analiza operadores relacionales.

Regla:
<opRel> → h | m | ¡ | ! | x | y

- Evalúa si el lookahead es uno de los operadores relacionales válidos.
- Si lo es, hace match; de lo contrario, lanza error sintáctico.
-----------------------------------------------------------------------
*/
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

/*
-----------------------------------------------------------------------
G:
Reconoce los operadores postfijo opcionales j o z (incremento/decremento).

Regla:
<G> → j | z | ε

- Si el lookahead es j o z, los consume.
- Si no, no hace nada (ε).
-----------------------------------------------------------------------
*/
void G() {
    if (indice_actual < total_atomos) {
        const char *la = atomos[indice_actual];
        if (strcmp(la, "z") == 0) {
            match("z");
        } else if (strcmp(la, "j") == 0) {
            match("j");
        }
        // else: ε (no hacer nada)
    }
}

/*
-----------------------------------------------------------------------
Fp:
Implementa la producción para operadores postfijo j o z después de un
identificador o literal.

Regla:
<Fp> → j | z | ε

- Si encuentra j o z en el lookahead, los consume.
- En otro caso, representa epsilon (vacío).
-----------------------------------------------------------------------
*/
void Fp() {
    if (indice_actual < total_atomos) {
        if (strcmp(atomos[indice_actual], "j") == 0 || strcmp(atomos[indice_actual], "z") == 0) {
            match(atomos[indice_actual]); // j o z
        }
        // Si no es j o z, entonces es ε (no hacer nada)
    }
}

/*
-----------------------------------------------------------------------
expRel:
Analiza expresiones relacionales.

Regla:
<expRel> → ExprGral opRel ExprGral

- Evalúa una expresión, luego un operador relacional y luego otra expresión.
- Utiliza las funciones ya definidas: ExprGral y opRel.
-----------------------------------------------------------------------
*/
void expRel() {
    // FIRST(expRel) = FIRST(ExprGral) = { a, e, r, s, ( }
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

/*
-----------------------------------------------------------------------
OpAsigComp:
Reconoce operadores de asignación compuesta.

Regla:
<OpAsigComp> → # | ñ | $ | v | ? | : | " | ^ | &

- Consume el operador correspondiente si es válido.
- Si no lo es, lanza error sintáctico.
-----------------------------------------------------------------------
*/
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

/*
-----------------------------------------------------------------------
OpAsigSimple:
Reconoce el operador de asignación simple.

Regla:
<OpAsigSimple> → =

- Solo hace match si el lookahead es "=".
-----------------------------------------------------------------------
*/
void OpAsigSimple() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "=") == 0) {
        match("=");
    } else {
        errorSintactico("OpAsigSimple");
    }
}



/*
-----------------------------------------------------------------------
Param:
Esta función analiza parámetros adicionales en una lista de argumentos
de llamada a función.

Regla:
<Param> → , ExprGral <Param> | ε

- Si detecta una coma, consume el símbolo y una nueva expresión como
  argumento, luego se llama recursivamente.
-----------------------------------------------------------------------
*/
void Param() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], ",") == 0) {
        match(",");
        ExprGral();
        Param();
    }
}


/*
-----------------------------------------------------------------------
listP:
Esta función analiza la lista completa de parámetros que recibe una
llamada a función.

Regla:
<listP> → ExprGral <Param> | ε

- Evalúa si el token actual pertenece al conjunto FIRST(ExprGral).
- Si es así, analiza una expresión y luego parámetros adicionales.
-----------------------------------------------------------------------
*/
void listP() {
    if (indice_actual < total_atomos) {
        const char *la = atomos[indice_actual];
        // first(ExprGral) = {"s","q","m","u","(","a","n","r"}
        if (strcmp(la, "s") == 0 || strcmp(la, "q") == 0 ||
            strcmp(la, "m") == 0 || strcmp(la, "u") == 0 ||
            strcmp(la, "(") == 0 || strcmp(la, "a") == 0 ||
            strcmp(la, "n") == 0 || strcmp(la, "r") == 0) {
            ExprGral();
            Param();
        }
    }
}


/*
-----------------------------------------------------------------------
Args:
Función auxiliar que permite analizar argumentos generales en llamadas
a funciones. Se comporta como listP pero con un conjunto más reducido.

Regla:
<Args> → ExprGral <Param> | ε

- Evalúa si el token es válido para una expresión.
-----------------------------------------------------------------------
*/
void Args() {
    if (indice_actual < total_atomos) {
        const char *la = atomos[indice_actual];
        // FIRST(ExprGral) = { a, e, r, s, ( }
        if (strcmp(la, "a") == 0 || strcmp(la, "e") == 0 ||
            strcmp(la, "r") == 0 || strcmp(la, "s") == 0 ||
            strcmp(la, "(") == 0) {
            ExprGral();
            Param();
        }
        // else: ε
    }
}


/*
-----------------------------------------------------------------------
yywrap:
Función obligatoria para Flex que indica fin del archivo.

Siempre retorna 1 para que Flex sepa que no hay más entradas.
-----------------------------------------------------------------------
*/
int yywrap(void) {
    return 1;
}

/*
-----------------------------------------------------------------------
Ep:
Extiende la expresión E para incluir operadores aditivos (suma/resta).

Regla:
<Ep> → + T Ep | - T Ep | ε

- Si encuentra un "+" o "-", lo consume y analiza el siguiente término.
- Se llama recursivamente para múltiples sumas/restas.
-----------------------------------------------------------------------
*/
void Ep() {
    if (indice_actual < total_atomos &&
        (strcmp(atomos[indice_actual], "+") == 0 ||
         strcmp(atomos[indice_actual], "-") == 0)) {
        match(atomos[indice_actual]);
        T();
        Ep();
    }
}

/*
-----------------------------------------------------------------------
Cuerpo:
Analiza el cuerpo de una función o estructura entre corchetes.

Regla:
<Cuerpo> → [ listaSent ]

- Verifica la apertura con "[" y el cierre con "]".
- Dentro del bloque, analiza una lista de sentencias válidas.
-----------------------------------------------------------------------
*/
void Cuerpo() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "[") == 0) {
        match("[");
        listaSent();
        match("]");
    } else {
        errorSintactico("Cuerpo (esperado: [)");
        indice_actual++;
    }
}

/*
-----------------------------------------------------------------------
Expr:
Punto de entrada alternativo para una expresión.

Regla:
<Expr> → E

- Evalúa si el lookahead pertenece al conjunto FIRST(E).
- Si lo es, invoca la función E() que maneja la estructura general
  de expresiones aritméticas.
-----------------------------------------------------------------------
*/
void Expr() {
    if (indice_actual < total_atomos) {
        const char *la = atomos[indice_actual];
        // FIRST(E) = { a, e, r, s, ( }
        if (strcmp(la, "a") == 0 || strcmp(la, "e") == 0 ||
            strcmp(la, "r") == 0 || strcmp(la, "s") == 0 ||
            strcmp(la, "(") == 0) {
            E();
        } else {
            errorSintactico("Expr (esperado: a, e, r, s, ()");
            indice_actual++;
        }
    }
}





/*
-----------------------------------------------------------------------
Sino:
Representa la cláusula "Sino" de una sentencia condicional.

Regla:
<Sino> → l [ <listaSent> ]

- Solo se ejecuta si el lookahead es 'l' (Sino).
- Luego analiza una lista de sentencias encerradas entre corchetes.
-----------------------------------------------------------------------
*/
void Sino() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "l") == 0) {
        match("l");
        match("[");
        listaSent();
        match("]");
    }
}

/*
-----------------------------------------------------------------------
Dev:
Representa una sentencia de retorno.

Regla:
<Dev> → d <valRet> ;

- Se inicia con 'd' (Devo).
- Luego espera una expresión de retorno (valRet).
- Termina con punto y coma.
-----------------------------------------------------------------------
*/
void Dev() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "d") == 0) {
        match("d");
        valRet();
        match(";");
    } else {
        errorSintactico("Dev (esperado: d)");
        indice_actual++;
    }
}

/*
-----------------------------------------------------------------------
valRet:
Evalúa el valor de retorno para una sentencia Devo.

Regla:
<valRet> → ExprGral

- Llama a ExprGral si el lookahead es válido.
- En otro caso, lanza un error sintáctico.
-----------------------------------------------------------------------
*/
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

/*
-----------------------------------------------------------------------
Si:
Analiza la estructura condicional if.

Regla:
<Si> → i ( expRel ) [ listaSent ] <Sino>

- Verifica la condición entre paréntesis.
- Ejecuta el bloque verdadero.
- Luego intenta procesar la rama opcional Sino().
-----------------------------------------------------------------------
*/
void Si() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "i") == 0) {
        match("i");
        match("(");
        expRel();
        match(")");
        match("[");
        listaSent();
        match("]");
        Sino();
    } else {
        errorSintactico("Si (esperado: i)");
        indice_actual++;
    }
}

/*
-----------------------------------------------------------------------
Para:
Analiza la estructura "Para".

Regla:
<Para> → o ( E ) [ listaSent ]

- El token 'o' inicia el bloque (equivalente a "for").
- Luego espera una expresión y un bloque de sentencias.
-----------------------------------------------------------------------
*/
void Para() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "o") == 0) {
        match("o");
        match("(");
        E(); // o(E)
        match(")");
        match("[");
        listaSent();
        match("]");
    } else {
        errorSintactico("Para (esperado: o)");
        indice_actual++;
    }
}

/*
-----------------------------------------------------------------------
LlamaFunc:
Llama a una función usando la siguiente producción:

Regla:
<LlamaFunc> → { a ( listP ) }

- Espera el inicio con llave, identificador y parámetros.
- Termina con cierre de llave.
-----------------------------------------------------------------------
*/
void LlamaFunc() {
    match("{");
    match("a");
    match("(");
    listP();
    match(")");
    match("}");
}

/*
-----------------------------------------------------------------------
HazM:
Analiza bloques del tipo "Haz [...]".

Regla:
<HazM> → h [ listaSent ]

- Requiere que el lookahead sea 'h'.
- Luego consume y analiza una lista de sentencias entre corchetes.
-----------------------------------------------------------------------
*/
void HazM() {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "h") == 0) {
        match("h");
        match("[");
        listaSent();
        match("]");
    } else {
        errorSintactico("HazM (esperado: h)");
        indice_actual++;
    }
}



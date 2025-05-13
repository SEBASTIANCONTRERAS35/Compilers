/*
-----------------------------------------------------------------------
TABLA DE EQUIVALENCIAS LÉXICAS (Átomos)
-----------------------------------------------------------------------
Asigna un símbolo terminal (átomo) a cada tipo de token.
Útil para alimentar el análisis sintáctico posteriormente.
*/


%{
#define YY_NO_MAIN 1
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
#include <stdlib.h>

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

const char* obtener_atomo(int clase, int posicion) {
switch (clase) {
    case 0: return "n"; // Palabras reservadas tipo dato
    case 1: return "s"; // Símbolos especiales
    case 2: return "a"; // Identificador
    case 3: return "+"; // Operador aritmético (simbolizar suma, etc.)
    case 4: return "?"; // Operador relacional (puedes refinar si lo deseas)
    case 5: return "="; // Asignación
    case 6: return "s"; // Cadena
    case 7: return "e"; // Entero
    case 8: return "r"; // Real
    case 9: return "!"; // Error léxico
    default: return "?";
}
}
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
obtener_posicion_literal_cadena:
Busca la cadena literal 'dato' en la tabla de cadenas. Si existe, devuelve índice. Si no, la inserta.
*/
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

/*
obtener_posicion_literal_real:
Busca el literal real 'dato' en la tabla de reales. Si existe, devuelve índice. Si no, lo inserta.
*/
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

/*
obtener_posicion_literal_entero:
Busca el literal entero 'dato' en la tabla de enteros. Si existe, devuelve índice. Si no, lo inserta.
*/
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
    case 6: { // Cadena
        pos = obtener_posicion_literal_cadena(valor);
    } break;
    case 7: { // Entero
        pos = obtener_posicion_literal_entero(valor);
    } break;
    case 8: { // Real
        pos = obtener_posicion_literal_real(valor);
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
    /* Imprimir el átomo correspondiente y escribirlo en atomos.txt */
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

"->"|"+->"|"-->"|"*->"|"/->"|"%->"|"<<->"|">>->"|"\^->"|"&->" {
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
/* Forward declarations for parser atomos variables */
extern char* atomos[];
extern int total_atomos;
extern int indice_actual;

void cargar_atomos(const char* archivo);
void Program();
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

if (!archivo_tokens || !archivo_simbolos || !archivo_literales || !archivo_cadenas || !archivo_enteros || !archivo_reales) {
    fprintf(stderr, "No se pudieron abrir archivos de salida\n");
    return 1;
}

printf("Analizador Léxico iniciado...\n");
yylex();

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

// --- SINTÁCTICO: Variables y funciones para analizar los átomos generados ---
// (Se insertan justo después de las funciones de Flex)

printf("Tablas escritas en archivos tokens.txt, simbolos.txt, literales.txt, cadenas.txt, enteros.txt y reales.txt\n");

// Ahora, cargar los átomos y ejecutar el "parser" embebido:
    cargar_atomos("atomos.txt");
    Program();
    if (indice_actual == total_atomos) {
        printf("✅ Análisis sintáctico exitoso. Todos los átomos fueron consumidos.\n");
    } else {
        printf("❌ Error: quedaron átomos sin procesar desde '%s'\n", atomos[indice_actual]);
    }

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

int match(const char* esperado) {
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], esperado) == 0) {
        printf("✔️ Match: %s\n", esperado);
        indice_actual++;
        return 1;
    } else {
        printf("❌ Error: se esperaba '%s' pero se encontró '%s'\n",
               esperado,
               (indice_actual < total_atomos ? atomos[indice_actual] : "EOF"));
        exit(1);
    }
}


int DecGlob();

int ListDecGlob() {
    printf("↪ Analizando <ListDecGlob>\n");
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], "g") == 0) {
        DecGlob();
        ListDecGlob();
    } else {
        printf("ε (vacío) en <ListDecGlob>\n");
    }
    return 1;
}

int Tipo() {
    printf("↪ Analizando <Tipo>\n");
    if (match("b") || match("c") || match("n") || match("f")) {
        return 1;
    }
    printf("❌ Error: Se esperaba un tipo (b|c|n|f)\n");
    exit(1);
}

int list() {
    printf("↪ Analizando <list>\n");
    if (indice_actual < total_atomos && strcmp(atomos[indice_actual], ",") == 0) {
        match(",");
        match("a");
        list();
    } else {
        printf("ε (vacío) en <list>\n");
    }
    return 1;
}

int Decl() {
    printf("↪ Analizando <Decl>\n");
    Tipo();
    match("a");
    list();
    match("*");
    return 1;
}

int DecGlob() {
    printf("↪ Analizando <DecGlob>\n");
    match("g");
    Decl();
    return 1;
}

// --- INICIO: Gramática para listaSent y Sent ---

int Sent();

int listaSent() {
    printf("↪ Analizando <listaSent>\n");
    if (indice_actual < total_atomos &&
       (strcmp(atomos[indice_actual], "a") == 0 ||  // <Asig>
        strcmp(atomos[indice_actual], "h") == 0 ||  // <HazM>
        strcmp(atomos[indice_actual], "i") == 0 ||  // <Si>
        strcmp(atomos[indice_actual], "o") == 0 ||  // <Para>
        strcmp(atomos[indice_actual], "d") == 0 ||  // <Dev>
        strcmp(atomos[indice_actual], "t") == 0 ||  // Continuar
        strcmp(atomos[indice_actual], "p") == 0)) { // Parar
        Sent();
        listaSent();
    } else {
        printf("ε (vacío) en <listaSent>\n");
    }
    return 1;
}

int Asig();

int Sent() {
    printf("↪ Analizando <Sent>\n");
    if (strcmp(atomos[indice_actual], "a") == 0) {
        Asig();  // Sentencia de asignación
    } else {
        printf("❌ Error: sentencia no reconocida aún en <Sent>\n");
        exit(1);
    }
    return 1;
}

int ExprGral();
int E();

int Asig() {
    printf("↪ Analizando <Asig>\n");
    match("a"); // Identificador
    if (strcmp(atomos[indice_actual], "=") == 0) {
        match("=");       // Asignación simple
        ExprGral();       // Valor a asignar
    } else {
        // Asignación compuesta
        // Puede ser #, ñ, $ ... (10 posibles símbolos)
        if (strcmp(atomos[indice_actual], "#") == 0 || strcmp(atomos[indice_actual], "ñ") == 0 ||
            strcmp(atomos[indice_actual], "$") == 0 || strcmp(atomos[indice_actual], "v") == 0 ||
            strcmp(atomos[indice_actual], "?") == 0 || strcmp(atomos[indice_actual], ":") == 0 ||
            strcmp(atomos[indice_actual], "\"") == 0 || strcmp(atomos[indice_actual], "^") == 0 ||
            strcmp(atomos[indice_actual], "&") == 0) {
            match(atomos[indice_actual]); // operador compuesto
            E(); // expresión aritmética
        } else {
            printf("❌ Error: operador de asignación inválido\n");
            exit(1);
        }
    }
    match("."); // Fin de la sentencia
    return 1;
}

// --- FIN: Gramática para listaSent y Sent ---

int Func() {
    printf("↪ Analizando <Func> (dummy)\n");
    return 1;
}

int otraFunc() {
    printf("↪ Analizando <otraFunc> (dummy)\n");
    return 1;
}

void Program() {
    printf("↪ Analizando <Program>\n");
    ListDecGlob();
    Func();
    otraFunc();
}

// --- Fin sintáctico ---

int yywrap() {
    return 1;
}

// --- INICIO: Gramática para ExprGral y expresiones aritméticas ---

int E();
int T();
int F();
int Eprima();
int Tprima();

int ExprGral() {
    printf("↪ Analizando <ExprGral>\n");
    if (strcmp(atomos[indice_actual], "s") == 0 ||
        strcmp(atomos[indice_actual], "q") == 0 ||
        strcmp(atomos[indice_actual], "m") == 0 ||
        strcmp(atomos[indice_actual], "u") == 0) {
        match(atomos[indice_actual]);
    } else {
        E(); // expresión aritmética
    }
    return 1;
}

int E() {
    printf("↪ Analizando E → T E'\n");
    T();
    Eprima();
    return 1;
}

int Eprima() {
    printf("↪ Analizando E'\n");
    if (strcmp(atomos[indice_actual], "+") == 0) {
        match("+");
        T();
        Eprima();
    } else if (strcmp(atomos[indice_actual], "-") == 0) {
        match("-");
        T();
        Eprima();
    } else {
        printf("ε (vacío) en E'\n");
    }
    return 1;
}

int T() {
    printf("↪ Analizando T → F T'\n");
    F();
    Tprima();
    return 1;
}

int Tprima() {
    printf("↪ Analizando T'\n");
    if (strcmp(atomos[indice_actual], "*") == 0) {
        match("*");
        F();
        Tprima();
    } else if (strcmp(atomos[indice_actual], "/") == 0) {
        match("/");
        F();
        Tprima();
    } else if (strcmp(atomos[indice_actual], "%") == 0) {
        match("%");
        F();
        Tprima();
    } else if (strcmp(atomos[indice_actual], "~") == 0) {
        match("~");
        F();
        Tprima();
    } else if (strcmp(atomos[indice_actual], "k") == 0) {
        match("k");
        F();
        Tprima();
    } else {
        printf("ε (vacío) en T'\n");
    }
    return 1;
}

int F() {
    printf("↪ Analizando F\n");
    if (strcmp(atomos[indice_actual], "(") == 0) {
        match("(");
        E();
        match(")");
    } else if (strcmp(atomos[indice_actual], "a") == 0) {
        match("a");
    } else if (strcmp(atomos[indice_actual], "n") == 0) {
        match("n");
    } else if (strcmp(atomos[indice_actual], "r") == 0) {
        match("r");
    } else {
        printf("❌ Error: no se reconoce F\n");
        exit(1);
    }
    return 1;
}

// --- FIN: Gramática para ExprGral y expresiones aritméticas ---
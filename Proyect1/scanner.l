%{
#include <stdio.h>
#include <string.h>

#define MAX_TOKENS 300

/* Estructura para la tabla de símbolos (identificadores) */
typedef struct {
    int pos;
    char nombre[50];
    int tipo; // -1 por defecto
} Simbolo;

/* Estructura para la tabla de literales (cadenas y reales) */
typedef struct {
    int pos;
    char dato[100];
} Literal;

/* Estructura para la tabla de tokens */
typedef struct {
    int clase;      // Código de la clase
    int posicion;   // Posición en su tabla (o -1)
} TokenInfo;

/* Tablas principales */
Simbolo tabla_simbolos[MAX_TOKENS];
int simbolos_count = 0;

Literal tabla_literales[MAX_TOKENS];
int literales_count = 0;

TokenInfo tabla_tokens[MAX_TOKENS];
int token_count = 0;

/* Archivo de salida */
FILE *archivo_tokens = NULL;
FILE *archivo_simbolos = NULL;
FILE *archivo_literales = NULL;

/* Tablas predefinidas para asignar posición fija */
const char *palabras_reservadas[] = {
    "Bool", "Cade", "Continuar", "Devo", "Ent", "Fals", "Flota", "Global",
    "Haz", "Mientras", "Nulo", "Para", "Parar", "Si", "Sino", "Ver"
};
const int total_palabras_reservadas = 16;

const char *simbolos_especiales[] = {
    "<", ">", "<<", ">>", "#", "#!", "*", "|", "•"
};
const int total_simbolos_especiales = 9;

const char *operadores_aritmeticos[] = {
    "sum", "rest", "mult", "div", "mod", "inc", "dec", "exp", "dive"
};
const int total_operadores_aritmeticos = 9;

const char *operadores_relacionales[] = {
    "h", "m", "e", "c", "he", "me"
};
const int total_operadores_relacionales = 6;

const char *operadores_asignacion[] = {
    "->", "+->", "-->", "*->", "/->", "%->", ">>", "<<", "^->", "&->"
};
const int total_operadores_asignacion = 10;

/* ----------------------------------------------------------------
   Funciones de apoyo
   ---------------------------------------------------------------- */

/* Devuelve la posición fija en la tabla predefinida; -1 si no existe */
int buscar_posicion(const char *valor, const char *tabla[], int total) {
    for (int i = 0; i < total; i++) {
        if (strcmp(tabla[i], valor) == 0) {
            return i;
        }
    }
    return -1; // no encontrado
}

/* Inserta / busca un identificador en la tabla de símbolos */
int obtener_posicion_simbolo(const char* nombre) {
    for (int i = 0; i < simbolos_count; i++) {
        if (strcmp(tabla_simbolos[i].nombre, nombre) == 0) {
            return i; // ya existe
        }
    }
    // si no existe, lo insertamos
    if (simbolos_count < MAX_TOKENS) {
        tabla_simbolos[simbolos_count].pos = simbolos_count;
        strcpy(tabla_simbolos[simbolos_count].nombre, nombre);
        tabla_simbolos[simbolos_count].tipo = -1; // sin tipo
        return simbolos_count++;
    }
    return -1; 
}

/* Inserta / busca un literal en la tabla de literales */
int obtener_posicion_literal(const char* dato) {
    for (int i = 0; i < literales_count; i++) {
        if (strcmp(tabla_literales[i].dato, dato) == 0) {
            return i; 
        }
    }
    // si no existe, lo insertamos
    if (literales_count < MAX_TOKENS) {
        tabla_literales[literales_count].pos = literales_count;
        strcpy(tabla_literales[literales_count].dato, dato);
        return literales_count++;
    }
    return -1; 
}

/* 
   Agrega un token a la tabla de tokens.
   - `valor`: la cadena real (yytext)
   - `clase`: clase del token (0=pal res, 1=simbolo, 2=ident, etc.)
*/
void agregar_token(const char *valor, int clase) {
    // Para la mayoría de clases, usamos la posición fija con buscar_posicion
    int pos = -1;

    switch (clase) {
        case 0: // Palabras reservadas
            pos = buscar_posicion(valor, palabras_reservadas, total_palabras_reservadas);
            break;
        case 1: // Símbolos especiales
            pos = buscar_posicion(valor, simbolos_especiales, total_simbolos_especiales);
            break;
        case 3: // Operadores aritméticos
            pos = buscar_posicion(valor, operadores_aritmeticos, total_operadores_aritmeticos);
            break;
        case 4: // Operadores relacionales
            pos = buscar_posicion(valor, operadores_relacionales, total_operadores_relacionales);
            break;
        case 5: // Operadores asignación
            pos = buscar_posicion(valor, operadores_asignacion, total_operadores_asignacion);
            break;
        case 2: { // Identificador => tabla_simbolos
            pos = obtener_posicion_simbolo(valor);
        } break;
        case 6: // Cadena => tabla_literales
        case 7: // Entera => tabla_literales
        case 8: // Real => tabla_literales
        {
            pos = obtener_posicion_literal(valor);
        } break;
        case 9: 
            pos = -1; 
            break;
    }

    
    if (clase!=9 && pos==-1) {
        return;
    }

    if (token_count < MAX_TOKENS) {
        tabla_tokens[token_count].clase = clase;
        tabla_tokens[token_count].posicion = pos;
        token_count++;
    }
}



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

    /* Imprimir en los 3 archivos */
    imprimir_tabla_tokens(archivoTokens);
    imprimir_tabla_simbolos(archivoSimbolos);
    imprimir_tabla_literales(archivoLiterales);

    fclose(archivoTokens);
    fclose(archivoSimbolos);
    fclose(archivoLiterales);
    printf("Tablas escritas en archivos tokens.txt, simbolos.txt y literales.txt\n");
    return 0;
}

int yywrap() {
    return 1;
}
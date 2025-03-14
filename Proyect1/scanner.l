%{
#include <stdio.h>
#include <string.h>

#define MAX_TOKENS 300

typedef struct {
    int pos;
    char nombre[50];
    int tipo; /* Por defecto -1 */
} Simbolo;

Simbolo tabla_simbolos[MAX_TOKENS];
int simbolos_count = 0;

typedef struct {
    char palabra[50];
} Token;
typedef struct {
    int pos;
    char dato[100];
} Literal;

Token tokens[MAX_TOKENS]; 
int token_count = 0;

Literal tabla_literales[MAX_TOKENS];
int literales_count = 0;


Token simbolos[MAX_TOKENS];
int simbolo_count = 0;

Token identificadores[MAX_TOKENS];
int identificador_count = 0;

Token operadores[MAX_TOKENS];
int operador_count = 0;

Token constantes_enteras[MAX_TOKENS];
int constante_entera_count = 0;

Token constantes_reales[MAX_TOKENS];
int constante_real_count = 0;

Token errores_lex[MAX_TOKENS];
int error_count = 0;

Token operadores_rela[MAX_TOKENS];
int operador_rela_count = 0;

Token operadores_asig[MAX_TOKENS];
int operador_asig_count = 0;

Token constante_cadena[MAX_TOKENS];
int constante_cadena_count = 0;

FILE *archivo_salida = NULL;


int existe_literal(const char* dato) {
    for (int i = 0; i < literales_count; i++) {
        if (strcmp(tabla_literales[i].dato, dato) == 0) {
            return 1;
        }
    }
    return 0;
}

void agregar_literal(const char* dato) {
    if (!existe_literal(dato) && literales_count < MAX_TOKENS) {
        tabla_literales[literales_count].pos = literales_count;
        strcpy(tabla_literales[literales_count].dato, dato);
        literales_count++;
    }
}
int existe_token(const char* palabra, Token* lista, int count) {
    for (int i = 0; i < count; i++) {
        if (strcmp(lista[i].palabra, palabra) == 0) {
            return 1;
        }
    }
    return 0;
}
int existe_simbolo(const char* nombre) {
    for (int i = 0; i < simbolos_count; i++) {
        if (strcmp(tabla_simbolos[i].nombre, nombre) == 0) {
            return 1; // Ya existe
        }
    }
    return 0;
}
void agregar_simbolo(const char* nombre) {
    if (!existe_simbolo(nombre) && simbolos_count < MAX_TOKENS) {
        tabla_simbolos[simbolos_count].pos = simbolos_count;
        strcpy(tabla_simbolos[simbolos_count].nombre, nombre);
        tabla_simbolos[simbolos_count].tipo = -1;
        simbolos_count++;
    }
}

void agregar_token(const char* palabra, Token* lista, int* count) {
    if (!existe_token(palabra, lista, *count) && *count < MAX_TOKENS) {
        strcpy(lista[*count].palabra, palabra);
        (*count)++;
    }
}


void imprimir_tabla_literales() {
    fprintf(archivo_salida, "\n===== TABLA DE LITERALES (Cadenas y Reales) =====\n");
    fprintf(archivo_salida, "| %-5s | %-15s |\n", "Pos", "Valor");
    fprintf(archivo_salida, "|-----------------------|\n");
    for (int i = 0; i < literales_count; i++) {
        fprintf(archivo_salida, "| %-5d | %-15s |\n", tabla_literales[i].pos, tabla_literales[i].dato);
    }
    fprintf(archivo_salida, "=======================\n");
}
void imprimir_tabla_simbolos() {
    fprintf(archivo_salida, "\n===== TABLA DE SÍMBOLOS (IDENTIFICADORES) =====\n");
    fprintf(archivo_salida, "| %-5s | %-15s | %-5s |\n", "Pos", "Nombre", "Tipo");
    fprintf(archivo_salida, "|--------------------------------|\n");
    for (int i = 0; i < simbolos_count; i++) {
        fprintf(archivo_salida, "| %-5d | %-15s | %-5d |\n",
               tabla_simbolos[i].pos,
               tabla_simbolos[i].nombre,
               tabla_simbolos[i].tipo);
    }
    fprintf(archivo_salida, "================================\n");
}
void imprimir_tabla(const char* titulo, Token* lista, int count) {
    fprintf(archivo_salida, "\n===== %s =====\n", titulo);
    fprintf(archivo_salida, "| %-5s | %-15s |\n", "ID", "Valor");
    fprintf(archivo_salida, "|-----------------------|\n");
    for (int i = 0; i < count; i++) {
        fprintf(archivo_salida, "| %-5d | %-15s |\n", i, lista[i].palabra);
    }
    fprintf(archivo_salida, "=======================\n");
}
%}

%%
[ \t\n]+  { /* no acción */ }

"Bool"|"Cade"|"Continuar"|"Devo"|"Ent"|"Fals"|"Flota"|"Global" {
    agregar_token(yytext, tokens, &token_count);
    printf("[CLASE 0 - PALABRA RESERVADA]: %s\n", yytext);
}

"<"   { agregar_token("<", simbolos, &simbolo_count);  printf("[CLASE 1 - SÍMBOLO ESP]: < ( \n"); }
">"   { agregar_token(">", simbolos, &simbolo_count);  printf("[CLASE 1 - SÍMBOLO ESP]: > ) \n"); }
"<<"  { agregar_token("<<", simbolos, &simbolo_count); printf("[CLASE 1 - SÍMBOLO ESP]: << [ \n"); }
">>"  { agregar_token(">>", simbolos, &simbolo_count); printf("[CLASE 1 - SÍMBOLO ESP]: >> ] \n"); }
"#"   { agregar_token("#", simbolos, &simbolo_count);  printf("[CLASE 1 - SÍMBOLO ESP]: # { \n"); }
"#! " { agregar_token("#!", simbolos, &simbolo_count); printf("[CLASE 1 - SÍMBOLO ESP]: #! } \n"); }
"*"   { agregar_token("*", simbolos, &simbolo_count);  printf("[CLASE 1 - SÍMBOLO ESP]: * ; \n"); }
"|"   { agregar_token("|", simbolos, &simbolo_count);  printf("[CLASE 1 - SÍMBOLO ESP]: | , \n"); }
"•"   { agregar_token("•", simbolos, &simbolo_count);  printf("[CLASE 1 - SÍMBOLO ESP]: • . \n"); }

@([A-Za-zÑñÁÉÍÓÚÜáéíóúü][A-Za-zÑñÁÉÍÓÚÜáéíóúü0-9]*)_ {
        agregar_simbolo(yytext);
    printf("[CLASE 2 - IDENTIFICADOR]: %s\n", yytext);
}

"sum"|"rest"|"mult"|"div"|"mod"|"inc"|"dec"|"exp"|"dive" {
    agregar_token(yytext, operadores, &operador_count);
    printf("[CLASE 3 - OPERADOR ARITMÉTICO]: %s\n", yytext);
}

"h"|"m"|"e"|"c"|"he"|"me" {
    agregar_token(yytext, operadores_rela, &operador_rela_count);
    printf("[CLASE 4 - OPERADOR RELACIONAL]: %s\n", yytext);
}

"->"|"+->"|"-->"|"*->"|"/->"|"%->"|"\^->"|"&->" {
    agregar_token(yytext, operadores_asig, &operador_asig_count);
    printf("[CLASE 5 - OPERADOR DE ASIGNACION]: %s\n", yytext);
}

--([^-\n]*)-- {
        agregar_literal(yytext);
    agregar_token(yytext, constante_cadena, &constante_cadena_count);
    printf("[CLASE 6 - CONSTANTE CADENA]: %s\n", yytext);
}

([+-]?[0-9]*\x27[0-9]+)|([+-]?[0-9]+[rR]) {
        agregar_literal(yytext);
    agregar_token(yytext, constantes_reales, &constante_real_count);
    printf("[CLASE 8 - REAL]: %s\n", yytext);
}

[+-]?([1-9][0-9]*|0)[pPgG]? {
        agregar_literal(yytext);
    agregar_token(yytext, constantes_enteras, &constante_entera_count);
    printf("[CLASE 7 - CONSTANTE ENTERA]: %s\n", yytext);
}

\[.*?\] {
    printf("[COMENTARIO]: %s\n", yytext);
}

[^ \t\n]+ {
    agregar_token(yytext, errores_lex, &error_count);
    printf("[ERROR LÉXICO]: %s\n", yytext);
}

%%

int main() {
     archivo_salida = fopen("salida.txt", "w");
    if (!archivo_salida) {
        printf("No se pudo abrir 'salida.txt' para escribir.\n");
        return 1;
    }

  
    printf("Analizador Léxico iniciado...)\n");
    yylex();
    imprimir_tabla_simbolos();
    imprimir_tabla_literales();
    imprimir_tabla("TABLA DE PALABRAS RESERVADAS", tokens, token_count);
    imprimir_tabla("TABLA DE SÍMBOLOS ESPECIALES", simbolos, simbolo_count);
    imprimir_tabla("TABLA DE OPERADORES ARITMÉTICOS", operadores, operador_count);
    imprimir_tabla("TABLA DE OPERADORES RELACIONALES", operadores_rela, operador_rela_count);
    imprimir_tabla("TABLA DE OPERADORES DE ASIGNACION", operadores_asig, operador_asig_count);
    imprimir_tabla("TABLA DE CONSTANTES CADENA", constante_cadena, constante_cadena_count);
    imprimir_tabla("TABLA DE CONSTANTES ENTERAS", constantes_enteras, constante_entera_count);
    imprimir_tabla("TABLA DE CONSTANTES REALES", constantes_reales, constante_real_count);
    imprimir_tabla("TABLA DE ERRORES LÉXICOS", errores_lex, error_count);



    fclose(archivo_salida);
    printf("Tablas escritas en 'salida.txt'\n");
    return 0;
}

int yywrap() {
    return 1;
} 

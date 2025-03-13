%{
#include <stdio.h>
#include <string.h>

#define MAX_TOKENS 300  

typedef struct {
    char palabra[50];
} Token;

Token tokens[MAX_TOKENS]; 
int token_count = 0;

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
int operador_rela_count=0;

Token operadores_asig[MAX_TOKENS];
int operador_asig_count=0;

Token constante_cadena[MAX_TOKENS];
int constante_cadena_count=0;

int existe_token(const char* palabra, Token* lista, int count) {
    for (int i = 0; i < count; i++) {
        if (strcmp(lista[i].palabra, palabra) == 0) {
            return 1;
        }
    }
    return 0;
}

void agregar_token(const char* palabra, Token* lista, int* count) {
    if (!existe_token(palabra, lista, *count) && *count < MAX_TOKENS) {
        strcpy(lista[*count].palabra, palabra);
        (*count)++;
    }
}

void imprimir_tabla(const char* titulo, Token* lista, int count) {
    printf("\n===== %s =====\n", titulo);
    printf("| %-5s | %-15s |\n", "ID", "Valor");
    printf("|-----------------------|\n");
    for (int i = 0; i < count; i++) {
        printf("| %-5d | %-15s |\n", i, lista[i].palabra);
    }
    printf("=======================\n");
}
%}

%%

[ \t\n]+  {  }

"Bool"|"Cade"|"Continuar"|"Devo"|"Ent"|"Fals"|"Flota"|"Global" {
    agregar_token(yytext, tokens, &token_count);
    printf("[CLASE 0 - PALABRA RESERVADA]: %s\n", yytext);
}

"<"  { agregar_token("<", simbolos, &simbolo_count); printf("[CLASE 1 - SÍMBOLO ESPECIAL]: < ( \n"); }
">"  { agregar_token(">", simbolos, &simbolo_count); printf("[CLASE 1 - SÍMBOLO ESPECIAL]: > ) \n"); }
"<<" { agregar_token("<<", simbolos, &simbolo_count); printf("[CLASE 1 - SÍMBOLO ESPECIAL]: << [ \n"); }
">>" { agregar_token(">>", simbolos, &simbolo_count); printf("[CLASE 1 - SÍMBOLO ESPECIAL]: >> ] \n"); }
"#"  { agregar_token("#", simbolos, &simbolo_count); printf("[CLASE 1 - SÍMBOLO ESPECIAL]: # { \n"); }
"#! " { agregar_token("#!", simbolos, &simbolo_count); printf("[CLASE 1 - SÍMBOLO ESPECIAL]: #! } \n"); }
"*"  { agregar_token("*", simbolos, &simbolo_count); printf("[CLASE 1 - SÍMBOLO ESPECIAL]: * ; \n"); }
"|"  { agregar_token("|", simbolos, &simbolo_count); printf("[CLASE 1 - SÍMBOLO ESPECIAL]: | , \n"); }
"•"  { agregar_token("•", simbolos, &simbolo_count); printf("[CLASE 1 - SÍMBOLO ESPECIAL]: • . \n"); }

@([A-Za-zÑñÁÉÍÓÚÜáéíóúü][A-Za-zÑñÁÉÍÓÚÜáéíóúü0-9]*)_ {
    agregar_token(yytext, identificadores, &identificador_count);
    printf("[CLASE 2 - IDENTIFICADOR]: %s\n", yytext);
}

"sum"|"rest"|"mult"|"div"|"mod"|"inc"|"dec"|"exp"|"dive" {
    agregar_token(yytext, operadores, &operador_count);
    printf("[CLASE 3 - OPERADOR ARITMÉTICO]: %s\n", yytext);
}

([+-]?[0-9]*\x27[0-9]+)|([+-]?[0-9]+[rR]) {
    agregar_token(yytext, constantes_reales, &constante_real_count);
    printf("[CLASE 8 - REAL]: %s\n", yytext);
}

[+-]?([1-9][0-9]*|0)[pPgG]? {
    agregar_token(yytext, constantes_enteras, &constante_entera_count);
    printf("[CLASE 7 - CONSTANTE ENTERA]: %s\n", yytext);
}



[^ \t\n]+ {
    agregar_token(yytext, errores_lex, &error_count);
    printf("[ERROR LÉXICO]: %s\n", yytext);
}
"h"|"m"|"e"|"c"|"he"|"me" {
    agregar_token(yytext,operadores_rela, &operador_rela_count);
    printf("[CLASE 4  - OPERADOR RELACIONAL]: %s\n", yytext);
}

"->"|"+->"|"-->"|"*->"|"/->"|"%->"|">>"|"<<"|"^->"|"&->" {
    agregar_token(yytext,operadores_asig, &operador_asig_count);
    printf("[CLASE 5  - OPERADOR DE ASIGNACION]: %s\n", yytext);
}

--([^-\n]*)-- {
    agregar_token(yytext, constante_cadena, &constante_cadena_count);
    printf("[CLASE 6 - CONSTANTE CADENA]: %s\n", yytext);
}



%%

int main() {
    printf("Analizador Léxico iniciado. (Ctrl+D para terminar)\n");
    yylex();
    imprimir_tabla("TABLA DE PALABRAS RESERVADAS", tokens, token_count);
    imprimir_tabla("TABLA DE SÍMBOLOS ESPECIALES", simbolos, simbolo_count);
    imprimir_tabla("TABLA DE IDENTIFICADORES", identificadores, identificador_count);
    imprimir_tabla("TABLA DE OPERADORES ARITMÉTICOS", operadores, operador_count);
    imprimir_tabla("TABLA DE CONSTANTES ENTERAS", constantes_enteras, constante_entera_count);
   imprimir_tabla("TABLA DE CONSTANTES REALES", constantes_reales, constante_real_count);
   imprimir_tabla("TABLA DE ERRORES LÉXICOS", errores_lex, error_count);

    imprimir_tabla("TABLA DE OPERADORES RELACIONALES", operadores_rela, operador_rela_count);
    return 0;
}

int yywrap() {
    return 1;
}
%{
#include <stdio.h>
#include <string.h>

#define MAX_TOKENS 100  

typedef struct {
    char palabra[50];
} Token;

Token tokens[MAX_TOKENS]; 
int token_count = 0;      

int existe_token(const char* palabra) {
    for (int i = 0; i < token_count; i++) {
        if (strcmp(tokens[i].palabra, palabra) == 0) {
            return 1;  
        }
    }
    return 0;  
}

void agregar_token(const char* palabra) {
    if (!existe_token(palabra) && token_count < MAX_TOKENS) {
        strcpy(tokens[token_count].palabra, palabra);
        token_count++;
    }
}

void imprimir_tabla() {
    printf("\n===== TABLA DE PALABRAS RESERVADAS ENCONTRADAS =====\n");
    printf("| %-5s | %-15s |\n", "ID", "Palabra");
    printf("|---------------------------|\n");
    for (int i = 0; i < token_count; i++) {
        printf("| %-5d | %-15s |\n", i, tokens[i].palabra);
    }
    printf("====================================================\n");
}
%}

%%

"Bool"|"Cade"|"Continuar"|"Devo"|"Ent"|"Fals"|"Flota"|"Global" {
    agregar_token(yytext);
    printf("[CLASE 0 - PALABRA RESERVADA]: %s\n", yytext);
}

. {
    printf("[Otra cosa]: %s\n", yytext);
}

%%

int main() {
    printf("Analizador Léxico iniciado. (Ctrl+D para terminar)\n");
    yylex();  
    imprimir_tabla();  
    return 0;
}

int yywrap() {
    return 1;
}
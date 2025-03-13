%{
#include <stdio.h>
%}

/* Definiciones de patrones */
DIGITO          [0-9]
LETRA           [A-Za-z]
IDENTIFICADOR   [A-Za-z_][A-Za-z0-9_]*
NUMERO          {DIGITO}+
REAL            {DIGITO}+"."{DIGITO}+
OPERADOR        [\+\-\*/=<>]
SIMBOLO_ESP     [\(\)\[\]{};.,]
CADENA          \"[^\"]*\"
%%

"int"|"float"|"return"|"if"|"else"|"while"|"for" { printf("PALABRA RESERVADA: %s\n", yytext); }
{IDENTIFICADOR}   { printf("IDENTIFICADOR: %s\n", yytext); }
{NUMERO}          { printf("NÚMERO ENTERO: %s\n", yytext); }
{REAL}            { printf("NÚMERO REAL: %s\n", yytext); }
{OPERADOR}        { printf("OPERADOR: %s\n", yytext); }
{SIMBOLO_ESP}     { printf("SÍMBOLO ESPECIAL: %s\n", yytext); }
"//".*            { /* Comentario de línea: no hacemos nada */ }
{CADENA}          { printf("CADENA DE TEXTO: %s\n", yytext); }
[ \t\n]+          ; /* Ignorar espacios y saltos de línea */
.                 { printf("CARÁCTER DESCONOCIDO: %s\n", yytext); }

%%

int main() {
    yylex();
    return 0;
}

int yywrap() {
    return 1;
}
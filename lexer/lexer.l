%{
#include "parser.tab.h"
int contaLinhas = 0;
%}

%%

[0-9]+          { yylval = atoi(yytext); return NUM; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return TIMES; }
"/"             { return DIVIDE; }
"("             { return LPAREN; }
")"             { return RPAREN; }
";"             { return SEMICOLON; }
"[\n]+"         { contaLinhas++; }
[ \t]+        { /* Ignorar espaços em branco */ }
.               { printf("Caractere inválido: %s\n", yytext); }

%%

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
"^"             { return POWER; } 
"%"             { return MOD; }
"=="            { return EQ; }
"!="            { return NEQ; }
"<"             { return LT; }
">"             { return GT; }
"<="            { return LEQ; }
">="            { return GEQ; }
"&&"            { return AND; }
"||"            { return OR; }
"!"             { return NOT; }
"("             { return LPAREN; }
")"             { return RPAREN; }
";"             { return SEMICOLON; }
"[\n]+"         { contaLinhas++; }
[ \t]+        { /* Ignorar espaços em branco */ }
.               { printf("Caractere inválido: %s\n", yytext); }


"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }

%%

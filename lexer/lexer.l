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
"="             { return ASSIGN; }
"+="            { return PLUS_ASSIGN; }
"-="            { return MINUS_ASSIGN; }
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
"{"             { return LBRACE; }
"}"             { return RBRACE; }
";"             { return SEMICOLON; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
"["             { return LBRACKET; }
"]"             { return RBRACKET; }
";"             { return SEMICOLON; }
","             { return COMMA; }
"++"            { return INCREMENT; }
"--"            { return DECREMENT; }
"->"            { return ARROW; }
"[\n]+"         { contaLinhas++; }
[ \t]+        { /* Ignorar espaços em branco */ }
.               { printf("Caractere inválido: %s\n", yytext); }


"int"           { return INT; }
"float"         { return FLOAT; }
"double"        { return DOUBLE; }
"char"          { return CHAR; }
"const"         { return CONST; }
"void"          { return VOID; }
"short"         { return SHORT; }
"long"          { return LONG; }
"signed"        { return SIGNED; }
"unsigned"      { return UNSIGNED; }
"auto"          { return AUTO; }
"continue"      { return CONTINUE; }
"enum"          { return ENUM; }
"extern"        { return EXTERN; }
"register"      { return REGISTER; }
"sizeof"        { return SIZEOF; }
"static"        { return STATIC; }
"struct"        { return STRUCT; }
"typedef"       { return TYPEDEF; }
"union"         { return UNION; }
"volatile"      { return VOLATILE; }

"if"            { return IF; }
"else"          { return ELSE; }
"else if"       { return ELSEIF}
"while"         { return WHILE; }
"for"           { return FOR; }
"do"            { return DO; }
"switch"        { return SWITCH; }
"case"          { return CASE; }
"default"       { return DEFAULT; }
"break"         { return BREAK; }
"return"        { return RETURN; }

%%

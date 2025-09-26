/* Cabeçalho */
%{
    #include <string.h> 
    #include <stdio.h>
    #include "parser.tab.h"
    int contaLinhas = 1;
%}

/* Regras Léxicas */
%%
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
"while"         { return WHILE; }
"for"           { return FOR; }
"do"            { return DO; }
"switch"        { return SWITCH; }
"case"          { return CASE; }
"default"       { return DEFAULT; }
"break"         { return BREAK; }
"return"        { return RETURN; }

[+-]?[0-9]+          { yylval.ival = atoi(yytext); return NUM; }
[+-]?[0-9]+"."[0-9]+ { yylval.fval = atof(yytext); return FLOAT_NUM; }
[a-zA-Z_][a-zA-Z0-9_]* { return VAR; }
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
";"             { return SEMICOLON; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
"["             { return LBRACKET; }
"]"             { return RBRACKET; }
","             { return COMMA; }
"++"            { return INCREMENT; }
"--"            { return DECREMENT; }
"->"            { return ARROW; }
"//.*"          { /* Ignorar comentários de linha */ }
"/*"([^*]|"*"[^/])*"*/" { /* Ignorar comentários de bloco */ }
\n              { contaLinhas++; }
[ \t]+          { /* Ignorar espaços em branco */ }
.               { 
                    fprintf(stderr, "Erro Léxico: Caractere inválido '%s' na linha %d.\n", yytext, contaLinhas); 
                    exit(1); 
                }

%%


int yywrap(void) {
    return 1;
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (file) {
            yyin = file;
        }
    }
    return yyparse();
}